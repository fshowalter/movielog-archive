# frozen_string_literal: true
require 'inquirer'

module Movielog
  module Console
    #
    # Responsible for providing a console interface to update reviews.
    #
    class UpdateReviews
      class << self
        #
        # Responsible for processing an update reviews command.
        #
        def call
          Movielog::Db::UpdateMostReviewedTables.call(
            db: Movielog.db, reviews: Movielog.reviews
          )
        end
      end
    end
  end
end
