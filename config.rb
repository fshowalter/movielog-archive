require 'movielog'
require 'active_support/core_ext/array/conversions'

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

  def headline_cast(title)
    Movielog::App.headline_cast_for_title(title).map do |person|
      "#{person.first_name} #{person.last_name}"
    end.to_sentence
  end

  def markdown(source)
    Tilt['markdown'].new { source }.render
  end

  def grade_to_stars(grade)
    return if grade.blank?

    case grade
    when 'A+'
      return [star, star, star, star, star].join
    when 'A'
      return [star, star, star, star, half_star].join
    when 'A-'
      return [star, star, star, star, empty_star].join
    when 'B+'
      return [star, star, star, half_star, empty_star].join
    when 'B'
      return [star, star, star, empty_star, empty_star].join
    when 'B-'
      return [star, star, star, empty_star, empty_star].join
    when 'C+'
      return [star, star, half_star, empty_star, empty_star].join
    when 'C'
      return [star, star, half_star, empty_star, empty_star].join
    when 'C-'
      return [star, star, empty_star, empty_star, empty_star].join
    when 'D+'
      return [star, half_star, empty_star, empty_star, empty_star].join
    when 'D'
      return [star, empty_star, empty_star, empty_star, empty_star].join
    when 'D-'
      return [half_star, empty_star, empty_star, empty_star, empty_star].join
    when 'F'
      return [empty_star, empty_star, empty_star, empty_star, empty_star].join
    end
  end

  def star
    <<-SVG
      <svg class="star" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512">
        <polygon points="256,389.375 97.781,499.477 153.601,314.977 0,198.523 192.71,194.59 256,12.523 319.297,194.59 512,198.523 358.399,314.977 414.226,499.477 "/>
      </svg>
    SVG
  end

  def half_star
    <<-SVG
      <svg class="half-star" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512">
        <path class="half-star-empty" d="M 512,198.526 319.289,194.594 255.994,12.525 192.707,194.594 0,198.526 153.599,314.975 97.784,499.475 255.996,389.381 414.225,499.475 358.394,314.975 512,198.526 z M 359.201,423.656 256,351.744 V 106.115 l 41.284,118.766 125.701,2.559 -100.199,75.969 36.415,120.247 z" />
        <path class="half-star-full" d="M 255.32812,16.638245 193.39062,194.82574 0.67187503,198.76324 154.26562,315.20075 l -55.812495,184.5 156.874995,-109.15625 0,-373.906255 z" />
      </svg>
    SVG
  end

  def empty_star
    <<-SVG
      <svg class="empty-star" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512">
        <path d="M512,198.52l-192.709-3.924L255.995,12.524l-63.288,182.071L0,198.52l153.599,116.463L97.781,499.476l158.214-110.103 l158.229,110.103l-55.831-184.493L512,198.52z M359.202,423.764L255.994,351.94l-103.207,71.823l36.414-120.35L89.003,227.448 l125.708-2.566l41.292-118.773l41.283,118.773l125.699,2.566l-100.2,75.967L359.202,423.764z"/>
      </svg>
    SVG
  end
end

set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

set :markdown_engine, :redcarpet

activate :directory_indexes

activate :pagination do
  pageable_set :reviews do
    Movielog::App.reviews.keys.sort.reverse
  end
end

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
    proxy "/reviews/#{review.slug}/index.html", "review.html",
      locals: { review: review }
  end
end
