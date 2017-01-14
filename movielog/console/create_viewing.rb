# frozen_string_literal: true
require 'inquirer'
require 'awesome_print'

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
        # @return [OpenStruct] The new viewing.
        def call(query_proc: Movielog.method(:search_for_movie), venues: Movielog.venues)
          movie = AskForMovie.call(query_proc: query_proc)
          viewing = Movielog::CreateViewing.call(**build_viewing_data(movie: movie, venues: venues))

          puts "\n Created Viewing ##{Bold.call(text: viewing.number.to_s)}!\n"
          ap(viewing.to_h, ruby19_syntax: true)

          viewing
        end

        private

        def build_viewing_data(movie:, venues:)
          {
            movie: movie,
            date: ask_for_date,
            venue: ask_for_venue(venues: venues),
          }
        end

        def ask_for_venue(venues:)
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
