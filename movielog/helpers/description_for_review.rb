module Movielog
  #
  # Responsible for providing template helper methods.
  #
  module Helpers
    def description_for_review(review:, aka_titles:)
      description = "A review of #{review.display_title}"

      return "#{description}." unless aka_titles && aka_titles.any?

      "#{description}, also known as #{aka_titles.to_sentence}."
    end
  end
end
