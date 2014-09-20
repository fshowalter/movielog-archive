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
    Tilt['markdown'].new { source }.render
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
