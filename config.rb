require 'movielog/movielog'
require 'active_support/core_ext/array/conversions'
require 'time'

# Reload the browser automatically whenever files change
configure :development do
  activate :livereload
end

helpers Movielog::Helpers

# Methods defined in the helpers block are available in templates
helpers do
  def card_content_for_post(post)
    if post.is_a?(Movielog::Review)
      partial(:review_card_content, locals: { review: post })
    elsif post.is_a?(Movielog::Feature)
      partial(:feature_card_content, locals: { feature: post })
    end
  end

  def href_for_post(post)
    if post.is_a?(Movielog::Review)
      "/reviews/#{post.slug}/"
    elsif post.is_a?(Movielog::Feature)
      "/features/#{post.slug}/"
    end
  end

  def markdown(source)
    return source if source.blank?
    content = Tilt['markdown'].new(footnotes: true) { source }.render

    reviews.values.each do |review|
      content.gsub!(
        review.display_title, link_to(review.display_title, "/reviews/#{review.slug}/"))
    end

    content
  end

  def minutes_to_read(source)
    return 0 if source.blank?

    wordcount = source.scan(/[[:alpha:]]+/).count

    count = wordcount / 275

    return 1 if count == 0

    count
  end

  def inline_svg(filename, options = {})
    file = sprockets.find_asset(filename).to_s.force_encoding('UTF-8')
    doc = Nokogiri::HTML::DocumentFragment.parse file
    svg = doc.at_css 'svg'
    svg['class'] = options[:class] if options[:class].present?
    doc.to_html
  end

  def reviews
    @reviews ||= begin
      Movielog.reviews.values.each_with_object({}) do |review, hash|
        hash[review.title] = review
      end
    end
  end

  def viewings
    @viewings ||= begin
      viewings = Movielog.viewings
      viewings.values.each do |viewing|
        info = MovieDb.info_for_title(db: Movielog.db, title: viewing.title)
        viewing.sortable_title = info.sortable_title
        viewing.release_date = info.release_date
      end
      viewings
    end
  end

  def sorted_posts
    Movielog.posts.keys.sort.reverse
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
page '404.html', directory_index: false

activate :autoprefixer do |config|
  config.inline = true
  config.browsers = ['last 2 versions', 'Firefox ESR']
end

activate :pagination do
  pageable_set :reviews do
    Movielog.reviews.keys.sort.reverse
  end

  pageable_set :posts do
    Movielog.posts.keys.sort.reverse
  end
end

activate :deploy do |deploy|
  deploy.method = :git
  deploy.build_before = true
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
  Movielog.reviews.each do |_id, review|
    proxy("reviews/#{review.slug}.html", 'review.html',
          locals: { review: review, title: "#{review.display_title} Movie Review" }, ignore: true)
  end

  Movielog.features.each do |_id, feature|
    proxy("features/#{feature.slug}.html", 'feature.html',
          locals: { feature: feature, title: "#{feature.title}" }, ignore: true)
  end

  [
    ['reviews/psycho-circus-1967', 'reviews/circus-of-fear-1966/'],
    ['browse/reviews/hell-is-for-heroes-1962', 'reviews/hell-is-for-heroes-1962/'],
    ['browse/reviews/the-searchers-1956', 'reviews/the-searchers-1956/'],
    ['reviews/kingsman-the-secret-service-2015', 'reviews/kingsman-the-secret-service-2014/'],
    ['browse/reviews/dangerous-mission-1954', 'reviews/dangerous-mission-1954/'],
    ['page/2', 'page-2/'],
    ['page/3', 'page-3/'],
    ['page/4', 'page-4/'],
    ['browse/reviews/rachel-and-the-stranger-1948', 'reviews/rachel-and-the-stranger-1948/'],
    ['browse/reviews/the-long-night-1947', 'reviews/the-long-night-1947/']
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
