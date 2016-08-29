# frozen_string_literal: true
require 'inquirer'

module Movielog
  module Console
    #
    # Responsible for providing a console interface to update viewings.
    #
    class UpdateViewings
      class << self
        #
        # Responsible for processing an update viewings command.
        #
        def call
          Movielog::Db::UpdateMostWatchedTables.call(
            db: Movielog.db, viewings: Movielog.viewings(getInfo: false)
          )
        end
      end
    end
  end
end
