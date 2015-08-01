module Movielog
  #
  # Responsible for providing template helper methods.
  #
  module Helpers
    def description_for_review(review:)
      paragraphs = review.content.split("\n\n");

      description = ''
      i = 0

      while (description.length < 140 && i < paragraphs.length) do
        description << (' ') unless i == 0
        description << paragraphs[i]
        i += 1
      end

      description
    end
  end
end
