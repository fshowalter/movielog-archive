module Movielog
  module Console
    #
    # Responsible for providing a console interface to create new viewings.
    #
    class CreateViewing
      class << self
        #
        # Responsible for providing a console interface to create a new viewing.
        #
        # @return [void]
        def call
          require 'inquirer'

          loop do
            viewing_hash = build_viewing_hash

            Movielog::App.create_viewing(viewing_hash)

            puts "\n Created Viewing ##{bold(viewing_hash[:number].to_s)}!\n" \
            " #{bold('        Title:')} #{viewing_hash[:title]}\n" \
            " #{bold('Display Title:')} #{viewing_hash[:display_title]}\n" \
            " #{bold('         Date:')} #{viewing_hash[:date]}\n" \
            " #{bold('        Venue:')} #{viewing_hash[:venue]}\n\n"
          end
        end

        private

        def build_viewing_hash
          title, display_title = get_title
          {
            title: title,
            display_title: display_title,
            date: get_date,
            venue: get_venue
          }
        end

        def bold(text)
          term = Term::ANSIColor
          term.cyan text
        end

        def get_venue(venue = nil)
          while venue.nil?
            venues = Movielog::App.venues
            choices = venues + ['Add New Venue']
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
        
        def get_date(date = nil)
          last_viewing = Movielog::App.viewings[Movielog::App.viewings.length]
          default = last_viewing.try(:[], :date).to_s

          while date.nil?
            entered_date = Ask.input 'Date', default: default
            next unless (entered_date = Date.parse(entered_date))

            date = entered_date if Ask.confirm entered_date.strftime('%A, %B %d, %Y?  ')
          end

          date
        end

        def get_title(title = nil, display_title = nil)
          while title.nil?
            query = Ask.input 'Search'
            results = Movielog::App.search_titles(query)
            choices = format_title_results(results)
            choices << 'Search Again'
            idx = Ask.list(' Title', choices)

            next if idx == results.length

            title = results[idx].title
            display_title = results[idx].display_title
          end

          [title, display_title]
        end
        
        def format_title_results(results)
          results.map do |movie|
            [
              movie.display_title,
              headline_cast(movie.title),
              aka_titles(movie.title),
              "\n"
            ].join
          end
        end

        def aka_titles(title)
          aka_titles = Movielog::App.aka_titles_for_title(title)
          return unless aka_titles.any?

          "\n   " + aka_titles.map { |aka_title| "aka #{aka_title.aka_title}" }.join("\n   ")
        end

        def headline_cast(title)
          headline_cast = Movielog::App.headline_cast_for_title(title)
          return unless headline_cast.any?

          "\n   " + headline_cast.map do |person|
            "#{person.first_name} #{person.last_name}"
          end.join(', ')
        end
      end
    end
  end
end
