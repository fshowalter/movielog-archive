require 'inquirer'

module Movielog
  module Console
    #
    # Responsible for providing a console interface to create new viewings.
    #
    class CreateViewing
      class << self
        #
        # Responsible for processing a new viewing command.
        #
        # @return [Hash] The new viewing.
        def call
          viewing = Movielog.create_viewing(**viewing_data)

          puts "\n Created Viewing ##{Bold.call(text: viewing.number.to_s)}!\n" \
          " #{Bold.call(text: '        Title:')} #{viewing.title}\n" \
          " #{Bold.call(text: 'Display Title:')} #{viewing.display_title}\n" \
          " #{Bold.call(text: '         Date:')} #{viewing.date}\n" \
          " #{Bold.call(text: '        Venue:')} #{viewing.venue}\n\n"

          viewing
        end

        private

        def viewing_data
          query_proc = ->(db, query) { MovieDb.search_titles(db: db, query: query) }

          db = Movielog.db
          movie = GetTitle.call(db: db, query_proc: query_proc)

          {
            title: movie.title,
            display_title: movie.display_title,
            date: GetDate.call,
            venue: get_venue
          }
        end

        def get_venue
          venue = nil
          venues = Movielog.venues
          choices = venues + ['Add New Venue']

          while venue.nil?
            idx = Ask.list('Venue', choices)

            if idx == venues.length
              new_venue = Ask.input 'New Venue Name'
              venue = new_venue if Ask.confirm "#{new_venue}?"
            else
              venue = venues[idx]
            end
          end

          venue
        end
      end
    end
  end
end
