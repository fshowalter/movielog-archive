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

  def headline_cast(title)
    Movielog::App.headline_cast_for_title(title).map do |person|
      "#{person.first_name} #{person.last_name}"
    end.to_sentence
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

  def grade_to_number(grade)
    return if grade.blank?

    case grade
    when 'A+'
      15
    when 'A'
      14
    when 'A-'
      13
    when 'B+'
      12
    when 'B'
      11
    when 'B-'
      10
    when 'C+'
      9
    when 'C'
      8
    when 'C-'
      7
    when 'D+'
      6
    when 'D'
      5
    when 'D-'
      4
    when 'F'
      1
    end
  end

  def grade_to_stars(grade)
    return if grade.blank?

    stars = case grade
    when 'A+'
      [star, star(1), star(2), star(3), star(4)].join
    when 'A'
      [star, star(1), star(2), star(3), empty_star(4)].join
    when 'A-'
      [star, star(1), star(2), star(3), empty_star(4)].join
    when 'B+'
      [star, star(1), star(2), empty_star(3), empty_star(4)].join
    when 'B'
      [star, star(1), star(2), empty_star(3), empty_star(4)].join
    when 'B-'
      [star, star(1), star(2), empty_star(3), empty_star(4)].join
    when 'C+'
      [star, star(1), empty_star(2), empty_star(3), empty_star(4)].join
    when 'C'
      [star, star(1), empty_star(2), empty_star(3), empty_star(4)].join
    when 'C-'
      [star, star(1), empty_star(2), empty_star(3), empty_star(4)].join
    when 'D+'
      [star, empty_star(1), empty_star(2), empty_star(3), empty_star(4)].join
    when 'D'
      [star, empty_star(1), empty_star(2), empty_star(3), empty_star(4)].join
    when 'D-'
      [star, empty_star(1), empty_star(2), empty_star(3), empty_star(4)].join
    when 'F'
      [empty_star, empty_star(1), empty_star(2), empty_star(3), empty_star(4)].join
    end

    <<-SVG
      <svg class="rating" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 2560 512">
        #{stars}
      </svg>
    SVG
  end

  def star(index = 0)
    <<-SVG
      <polygon transform="translate(#{512 * index})" class="star" points="256,389.375 97.781,499.477 153.601,314.977 0,198.523 192.71,194.59 256,12.523 319.297,194.59 512,198.523 358.399,314.977 414.226,499.477 "/>
    SVG
  end

  def empty_star(index = 0)
    <<-SVG
      <path transform="translate(#{512 * index})" class="empty-star" d="M512,198.52l-192.709-3.924L255.995,12.524l-63.288,182.071L0,198.52l153.599,116.463L97.781,499.476l158.214-110.103 l158.229,110.103l-55.831-184.493L512,198.52z M359.202,423.764L255.994,351.94l-103.207,71.823l36.414-120.35L89.003,227.448 l125.708-2.566l41.292-118.773l41.283,118.773l125.699,2.566l-100.2,75.967L359.202,423.764z"/>
    SVG
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
