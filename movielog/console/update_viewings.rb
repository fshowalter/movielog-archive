module Movielog
  module Console
    #
    # Responsible for providing a console interface to update viewings.
    #
    class UpdateViewings
      class << self
        #
        # Responsible for processing a update viewings command.
        #
        # @return [void]
        def call
          Movielog::Db::Commands::UpdateMostWatchedTables.call(
            db: Movielog.db, viewings: Movielog.viewings)
        end
      end
    end
  end
end
