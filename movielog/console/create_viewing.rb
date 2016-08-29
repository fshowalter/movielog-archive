# frozen_string_literal: true
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
          viewing = Movielog::CreateViewing.call(**viewing_data)

          puts "\n Created Viewing ##{Bold.call(text: viewing.number.to_s)}!\n" \
          " #{Bold.call(text: '   Title:')} #{viewing.title}\n" \
          " #{Bold.call(text: 'DB Title:')} #{viewing.db_title}\n" \
          " #{Bold.call(text: '    Date:')} #{viewing.date}\n" \
          " #{Bold.call(text: '   Venue:')} #{viewing.venue}\n\n"

          viewing
        end

        private

        def viewing_data
          movie = ask_for_title

          {
            viewings_path: Movielog.viewings_path,
            title: movie.title,
            display_title: movie.display_title,
            date: ask_for_date,
            venue: ask_for_venue,
            number: Movielog.next_viewing_number,
            slug: Movielog::Slugize.call(text: movie.display_title)
          }
        end

        def ask_for_title
          query_proc = ->(db, query) { MovieDb.search_titles(db: db, query: query) }

          db = Movielog.db
          AskForTitle.call(db: db, query_proc: query_proc)
        end

        def ask_for_venue(venues: Movielog.venues)
          venue = nil
          choices = venues + ['Add New Venue']

          while venue.nil?
            idx = Ask.list('Venue', choices)

            venue = idx == venues.length ? ask_for_new_venue : venues[idx]
          end

          venue
        end

        def ask_for_new_venue
          new_venue = Ask.input 'New Venue Name'
          Ask.confirm("#{new_venue}?") ? new_venue : nil
        end

        def ask_for_date
          date = nil

          while date.nil?
            entered_date = Ask.input 'Date', default: Date.today.to_s
            next unless (entered_date = Date.parse(entered_date))

            date = entered_date if Ask.confirm entered_date.strftime('%A, %B %d, %Y?  ')
          end

          date
        end
      end
    end
  end
end
