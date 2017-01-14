# frozen_string_literal: true
# rubocop:disable Metrics/BlockLength
require 'movielog/movielog'
require 'active_support/core_ext/array/conversions'
require 'active_support/core_ext/integer/inflections'
require 'time'

# Reload the browser automatically whenever files change
configure :development do
  activate :livereload, ignore: [/coverage/, /\.haml_lint\./, /spec/]
end

configure :build do
  Movielog.cache_reviews = true
end

helpers Movielog::Helpers

# Methods defined in the helpers block are available in templates
helpers do
  def cast_and_crew_link(person, options = {})
    name = "#{person.first_name} #{person.last_name}"

    if Movielog.cast_and_crew.key?(person.full_name)
      return link_to(name, "/cast-and-crew/#{Movielog.cast_and_crew[person.full_name].slug}/", options)
    end

    name
  end

  def href_for_review(review)
    "/reviews/#{review.slug}/"
  end

  def link_review_titles!(text)
    Movielog.reviews.values.each do |review|
      text.gsub!(review.title, link_to(review.title, href_for_review(review)))
    end
  end

  def markdown(source)
    return source if source.blank?

    content = Tilt['markdown'].new(footnotes: true) { source }.render

    link_review_titles!(content)

    content
  end

  def inline_css(_file)
    filename = File.expand_path("../#{yield_content(:inline_css)}", __FILE__)
    style = Tilt['scss'].new { File.open(filename, 'rb', &:read) }.render

    Middleman::Extensions::MinifyCss::SassCompressor.compress(style)
  end

  def first_paragraph(source)
    return source if source.blank?

    source = source.split("\n\n", 2)[0]

    content = Tilt['markdown'].new { source }.render.gsub(/\[\^\d\]/, '')

    link_review_titles!(content)

    content
  end
end

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

set :markdown_engine, :redcarpet
set :markdown, footnotes: true

set :haml, remove_whitespace: true

page 'feed.xml', mime_type: 'text/xml'

activate :directory_indexes

page '/googlee90f4c89e6c3d418.html', directory_index: false

ignore 'templates/*'

activate :autoprefixer do |config|
  config.inline = true
  config.browsers = ['last 2 versions', 'Firefox ESR']
end

activate :pagination do
  pageable_set :reviews do
    Movielog.reviews_by_sequence
  end
end

activate :deploy do |deploy|
  deploy.method = :git
  deploy.build_before = true
  deploy.clean = true
end

activate :sitemap, hostname: 'https://www.franksmovielog.com'

# Build-specific configuration
configure :build do
  activate :minify_css
  activate :minify_javascript
  activate :minify_html, remove_input_attributes: false, remove_http_protocol: false

  set :js_compressor, Uglifier.new(output: { comments: :jsdoc })

  # Enable cache buster
  activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  activate :gzip
end

ready do
  proxy('index.html', 'templates/home/home.html', ignore: true)
  proxy('404.html', 'templates/404/404.html', directory_index: false, ignore: true)
  proxy('viewings/index.html', 'templates/viewings/viewings.html', ignore: true)
  proxy('reviews/index.html', 'templates/reviews/reviews.html', ignore: true)
  proxy('how-i-grade/index.html', 'templates/how_i_grade/how_i_grade.html', ignore: true)
  proxy('about/index.html', 'templates/about/about.html', ignore: true)
  proxy('metrics/index.html', 'templates/metrics/metrics.html', ignore: true)
  proxy('cast-and-crew/index.html', 'templates/cast_and_crew/cast_and_crew.html', ignore: true)

  Movielog.reviews.values.each do |review|
    movie = Movielog.movies[review.db_title]
    proxy("reviews/#{review.slug}/index.html", 'templates/review/review.html',
          locals: { review: review, title: "#{movie.display_title} Movie Review" }, ignore: true)
  end

  Movielog.cast_and_crew.each do |_id, person|
    proxy("cast-and-crew/#{person.slug}/index.html", 'templates/reviews_for_person/reviews_for_person.html',
          locals: { person: person }, ignore: true)
  end

  [
    ['reviews/psycho-circus-1967', 'reviews/circus-of-fear-1966/'],
    ['browse/reviews/hell-is-for-heroes-1962', 'reviews/hell-is-for-heroes-1962/'],
    ['browse/reviews/the-searchers-1956', 'reviews/the-searchers-1956/'],
    ['reviews/kingsman-the-secret-service-2015', 'reviews/kingsman-the-secret-service-2014/'],
    ['browse/reviews/dangerous-mission-1954', 'reviews/dangerous-mission-1954/'],
    ['browse/reviews/straw-dogs-1971', 'reviews/straw-dogs-1971/'],
    ['browse/reviews/oceans-thirteen-2007', 'reviews/oceans-thirteen-2007/'],
    ['page/2', 'page-2/'],
    ['page/3', 'page-3/'],
    ['page/4', 'page-4/'],
    ['browse/reviews/rachel-and-the-stranger-1948', 'reviews/rachel-and-the-stranger-1948/'],
    ['browse/reviews/the-long-night-1947', 'reviews/the-long-night-1947/'],
    ['performers/robert-mitchum', 'cast-and-crew/robert-mitchum-i/'],
    ['browse/reviews', 'reviews/'],
    ['browse/humphrey-bogart', 'cast-and-crew/humphrey-bogart/'],
    ['browse/sam-peckinpah', 'cast-and-crew/sam-peckinpah/'],
    ['browse/peter-cushing', 'cast-and-crew/peter-cushing/'],
    ['performers/yakima-canutt', 'cast-and-crew/yakima-canutt/'],
    ['reviews/how-i-grade', 'how-i-grade/'],
    ['reviews/welcome-back', 'about/'],
    ['features/how-i-grade', 'how-i-grade/'],
    ['features/welcome-back', 'about/'],
    ['feed', 'feed.xml'],
    ['browse/reviews/haunted-gold-1932', 'reviews/haunted-gold-1932/'],
    ['browse/reviews/ride-him-cowboy-1932', 'reviews/ride-him-cowboy-1932/'],
  ].each do |redirect|
    old_slug, new_slug = redirect
    proxy("#{old_slug}.html", 'redirect.html', layout: false, locals: { new_slug: new_slug }, ignore: true)
  end
end

require 'sass'
require 'cgi'

#
# Opened to add the encode_svg helper function.
#
module Sass::Script::Functions # rubocop:disable Style/ClassAndModuleChildren
  def encode_svg(svg)
    encoded_svg = CGI.escape(svg.value).gsub('+', '%20')
    data_url = "url('data:image/svg+xml;charset=utf-8," + encoded_svg + "')"
    Sass::Script::String.new(data_url)
  end
end

#
# Opened to fix build deleting the .git directory.
#
class Middleman::Cli::BuildAction < ::Thor::Actions::EmptyDirectory # rubocop:disable Style/ClassAndModuleChildren
  # Remove files which were not built in this cycle
  # @return [void]
  def clean!
    @to_clean.each do |f|
      base.remove_file(f, force: true) unless f =~ /\.git/
    end

    ::Middleman::Util.glob_directory(@build_dir.join('**', '*'))
                     .select { |d| File.directory?(d) }
                     .each do |d|
      base.remove_file d, force: true if directory_empty? d
    end
  end
end
