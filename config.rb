require 'movielog'
require 'active_support/core_ext/array/conversions'
require 'time'

###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", :locals => {
#  :which_fake_page => "Rendering a fake page with a local variable" }

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Reload the browser automatically whenever files change
configure :development do
  activate :livereload
end

# Methods defined in the helpers block are available in templates
helpers do
  def site
    OpenStruct.new(YAML::load_file("config.yml"))
  end

  def markdown(source)
    Tilt['markdown'].new { source }.render
  end

  def published_date(review)
    review.date.iso8601
  end

  def description_for_review(review, aka_titles)
    description = "A review of #{review.display_title}"

    return "#{description}." unless aka_titles.any?

    "#{description}, also known as #{aka_titles.map(&:aka_title).to_sentence}."
  end
end

set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

set :markdown_engine, :redcarpet

page 'feed.xml', mime_type: 'text/xml'

activate :directory_indexes

activate :autoprefixer

activate :pagination do
  pageable_set :reviews do
    Movielog::App.reviews.keys.sort.reverse
  end
end

activate :deploy do |deploy|
  deploy.method = :git
  deploy.build_before = true
end

activate :sitemap, hostname: 'http://movielog.frankshowalter.com'

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript

  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"
end

ready do
  Movielog::App.reviews.each do |id, review|
    proxy("reviews/#{review.slug}.html", "review.html",
      locals: { review: review, title: "#{review.display_title} Movie Review" }, ignore: true)
  end
end
