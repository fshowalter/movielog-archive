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
  def next_items(pagination, count = 4)
    array = pagination.pageable_context.set
    first = pagination.per_page * pagination.page_num
    last = first + (count - 1)

    if last > array.length
      return array.slice(first)
    end

    return array.slice(first, count)
  end

  def category_link_for_post(post, options = {})
    link = '/'
    text = 'Unknown'

    if post.is_a?(Movielog::Review)
      link = '/reviews/'
      text = 'Reviews'
    elsif post.is_a?(Movielog::Feature)
      link = '/features/'
      text = 'Features'
    end

    link_to(text, link, options)
  end

  def post_for_key(key)
    Movielog.posts[key]
  end

  def person_slug(person)
    Movielog::Slugize.call(text: "#{person.first_name} #{person.last_name}")
  end

  def cast_and_crew_link(person, options = {})
    name = "#{person.first_name} #{person.last_name}"

    if Movielog.cast_and_crew.key?(person.full_name)
      return link_to(name, "/cast-and-crew/#{Movielog.cast_and_crew[person.full_name].slug}/", options)
    end

    name
  end

  def array_window(array, size, center, even_size_resolution = :prioritize_greater)
    return [] if size <= 0
    return [array[center]] if size == 1
    return array if size >= array.length

    closest_limit = ->(size, index) {
      return 0 if index < 0
      return size - 1 if index >= size
      index }
    array_closest_limit = closest_limit.curry[array.length]

    center = array_closest_limit[array.find_index(center)]

    lower = array_closest_limit[center - size/2]
    upper = array_closest_limit[center + size/2]
    while (lower..upper).count < size
      lower = array_closest_limit[lower - 1]
      upper = array_closest_limit[upper + 1]
    end

    return array.slice(lower..upper) if (lower..upper).count == size

    case even_size_resolution
    when :prioritize_greater
      return array.slice((lower + 1)..upper)
    when :prioritize_lower
      return array.slice(lower..(upper - 1))
    else
      raise ArgumentError, "#{even_size_resolution} is not a known resolution mechanism"
    end
  end

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

  def markdown(source, inline: false)
    return source if source.blank?

    content = Tilt['markdown'].new(footnotes: true) { source }.render

    if inline
      content.gsub!(/<\/?p>/, '');
    end

    reviews.values.each do |review|
      content.gsub!(
        review.title, link_to(review.title, "/reviews/#{review.slug}/"))
    end

    content
  end

  def inline_markdown(source)
    return source if source.blank?

    content = Tilt['markdown'].new(footnotes: true) { source }.render

    content.gsub!(/<\/?p>/, '');

    reviews.values.each do |review|
      content.gsub!(
        review.display_title, link_to(review.display_title, "/reviews/#{review.slug}/"))
    end

    content
  end

  def inline_css(file)
    filename = File.expand_path("../#{yield_content(:inline_css)}", __FILE__)
    style = Tilt['scss'].new() { File.open(filename, 'rb') { |f| f.read } }.render

    Middleman::Extensions::MinifyCss::SassCompressor.compress(style)
  end

  def first_paragraph(source)
    return source if source.blank?

    source = source.split("\n\n", 2)[0]

    content = Tilt['markdown'].new(footnotes: false) { source }.render.gsub(/\[\^\d\]/, '')

    reviews.values.each do |review|
      title = review.display_title || review.db_title
      content.gsub!(
        title, link_to(title, "/reviews/#{review.slug}/"))
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
        info = MovieDb.info_for_title(db: Movielog.db, title: (review.db_title || review.title))
        review.sortable_title = info.sortable_title
        review.release_date = info.release_date
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
# page '404.html', directory_index: false

# ignore 'templates/*'

activate :autoprefixer do |config|
  config.inline = true
  config.browsers = ['last 2 versions', 'Firefox ESR']
end

activate :pagination do
  pageable_set :reviews do
    Movielog.reviews.keys.sort.reverse
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

valid_cast_and_crew_slugs = Movielog.cast_and_crew.values.each_with_object([]) do |person, slugs|
  slugs << person.slug
end

ready do
  proxy('index.html', 'templates/home/home.html', ignore: true)
  proxy('404.html', 'templates/404/404.html', ignore: true)
  proxy('viewings/index.html', 'templates/viewings/viewings.html', ignore: true)
  proxy('reviews/index.html', 'templates/reviews/reviews.html', ignore: true)
  proxy('how-i-grade/index.html', 'templates/how_i_grade/how_i_grade.html', ignore: true)
  proxy('about/index.html', 'templates/about/about.html', ignore: true)
  proxy('metrics/index.html', 'templates/metrics/metrics.html', ignore: true)
  proxy('cast-and-crew/index.html', 'templates/cast_and_crew/cast_and_crew.html', ignore: true)

  Movielog.reviews.each do |_id, review|
    proxy("reviews/#{review.slug}/index.html", 'templates/review/review.html',
          locals: { review: review, title: "#{review.display_title} Movie Review" }, ignore: true)
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
    ['page/2', 'page-2/'],
    ['page/3', 'page-3/'],
    ['page/4', 'page-4/'],
    ['browse/reviews/rachel-and-the-stranger-1948', 'reviews/rachel-and-the-stranger-1948/'],
    ['browse/reviews/the-long-night-1947', 'reviews/the-long-night-1947/'],
    ['performers/robert-mitchum', 'cast-and-crew/robert-mitchum-i/']
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
