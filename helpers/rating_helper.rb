module RatingHelper
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

  def grade_to_text(grade)
    return if grade.blank?

    case grade
    when 'A+'
      '★★★★★'
    when 'A'
      '★★★★☆'
    when 'A-'
      '★★★★☆'
    when 'B+'
      '★★★☆☆'
    when 'B'
      '★★★☆☆'
    when 'B-'
      '★★★☆☆'
    when 'C+'
      '★★☆☆☆'
    when 'C'
      '★★☆☆☆'
    when 'C-'
      '★★☆☆☆'
    when 'D+'
      '★☆☆☆☆'
    when 'D'
      '★☆☆☆☆'
    when 'D-'
      '★☆☆☆☆'
    when 'F'
      '☆☆☆☆☆'
    end
  end

  def grade_to_stars(grade)
    return if grade.blank?

    stars = case grade
    when 'A+'
      [star, star(1), star(2), star(3), star(4)].join
    when 'A'
      [star, star(1), star(2), star(3), half_star(4)].join
    when 'A-'
      [star, star(1), star(2), star(3), empty_star(4)].join
    when 'B+'
      [star, star(1), star(2), half_star(3), empty_star(4)].join
    when 'B'
      [star, star(1), star(2), empty_star(3), empty_star(4)].join
    when 'B-'
      [star, star(1), star(2), empty_star(3), empty_star(4)].join
    when 'C+'
      [star, star(1), half_star(2), empty_star(3), empty_star(4)].join
    when 'C'
      [star, star(1), half_star(2), empty_star(3), empty_star(4)].join
    when 'C-'
      [star, star(1), half_star(2), empty_star(3), empty_star(4)].join
    when 'D+'
      [star, star(1), empty_star(2), empty_star(3), empty_star(4)].join
    when 'D'
      [star, half_star(1), empty_star(2), empty_star(3), empty_star(4)].join
    when 'D-'
      [star, half_star(1), empty_star(2), empty_star(3), empty_star(4)].join
    when 'F'
      [star, empty_star(1), empty_star(2), empty_star(3), empty_star(4)].join
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

  def half_star(index = 0)
    <<-SVG
      <path transform="translate(#{512 * index})" class="empty-star" d="M 512,198.526 319.289,194.594 255.994,12.525 192.707,194.594 0,198.526 153.599,314.975 97.784,499.475 255.996,389.381 414.225,499.475 358.394,314.975 512,198.526 z M 359.201,423.656 256,351.744 V 106.115 l 41.284,118.766 125.701,2.559 -100.199,75.969 36.415,120.247 z" />
      <path transform="translate(#{512 * index})" class="star" d="M 255.32812,16.638245 193.39062,194.82574 0.67187503,198.76324 154.26562,315.20075 l -55.812495,184.5 156.874995,-109.15625 0,-373.906255 z" />
    SVG
  end

  def empty_star(index = 0)
    <<-SVG
      <path transform="translate(#{512 * index})" class="empty-star" d="M512,198.52l-192.709-3.924L255.995,12.524l-63.288,182.071L0,198.52l153.599,116.463L97.781,499.476l158.214-110.103 l158.229,110.103l-55.831-184.493L512,198.52z M359.202,423.764L255.994,351.94l-103.207,71.823l36.414-120.35L89.003,227.448 l125.708-2.566l41.292-118.773l41.283,118.773l125.699,2.566l-100.2,75.967L359.202,423.764z"/>
    SVG
  end
end