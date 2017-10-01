# frozen_string_literal: true
require 'inquirer'

module Movielog
  module Console
    #
    # Responsible for providing a console interface to update the local database.
    #
    class UpdateDb
      class << self
        #
        # Responsible for processing an update db command.
        #
        def call
          tmdb_ids = Movielog.viewings.map(&:tmdb_id)

          MovieDb::Update.call(db: Movielog.db, ids: tmdb_ids)
        end
      end
    end
  end
end
