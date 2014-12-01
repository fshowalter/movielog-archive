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
  def markdown(source)
    return source if source.blank?
    Tilt['markdown'].new { source }.render
  end

  def inline_svg(filename, options = {})
    file = sprockets.find_asset(filename).to_s.force_encoding('UTF-8')
    doc = Nokogiri::HTML::DocumentFragment.parse file
    svg = doc.at_css 'svg'
    svg['class'] = options[:class] if options[:class].present?
    doc.to_html
  end

  def grade_to_image(grade:, css_class:)
    rating = OpenStruct.new

    if grade == 'A+'
      rating.file = '5-stars.svg'
      rating.alt = '5 Stars (out of 5)'
    elsif grade.start_with?('A')
      rating.file = '4-stars.svg'
      rating.alt = '4 Stars (out of 5)'
    elsif grade.start_with?('B')
      rating.file = '3-stars.svg'
      rating.alt = '3 Stars (out of 5)'
    elsif grade.start_with?('C')
      rating.file = '2-stars.svg'
      rating.alt = '2 Stars (out of 5)'
    elsif grade.start_with?('D')
      rating.file = '1-star.svg'
      rating.alt = '1 Star (out of 5)'
    else
      rating.file = 'no-stars.svg'
      rating.alt = '0 Stars (out of 5)'
    end

    unless development?
      rating.file = 'https://www.franksmovielog.com/' + image_path(rating.file)
    end

    image_tag(rating.file, alt: rating.alt, class: css_class)
  end

  def reviews
    @reviews ||= begin
      Movielog.reviews.values.reduce({}) do |hash, review|
        hash[review.title] = review
        hash
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
end

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

set :markdown_engine, :redcarpet

set :haml, remove_whitespace: true

page 'feed.xml', mime_type: 'text/xml'

activate :directory_indexes

activate :autoprefixer do |config|
  config.browsers = ['last 2 versions', 'Explorer >= 9', 'Firefox ESR']
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

activate :sitemap, hostname: 'http://www.franksmovielog.com'

# Build-specific configuration
configure :build do
  activate :minify_css
  activate :minify_javascript

  set :js_compressor, Uglifier.new(output: { comments: :jsdoc })

  # Enable cache buster
  activate :asset_hash

  # Use relative URLs
  activate :relative_assets

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
end
