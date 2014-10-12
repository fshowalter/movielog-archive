module Movielog
  #
  # Responsible for providing template helper methods.
  #
  module Helpers
    def description_for_review(review:, aka_titles:, headline_cast:)
      description = "A review of the movie #{review.display_title}"

      if aka_titles && aka_titles.any?
        aka_titles = aka_titles.select { |t| t != review.display_title }
        description = "#{description} (also known as #{aka_titles.to_sentence})"
      end

      headline_cast = headline_cast.map { |p| "#{p.first_name} #{p.last_name}" }

      "#{description} starring #{headline_cast.to_sentence}."
    end
  end
end
