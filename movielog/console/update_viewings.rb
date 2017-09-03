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
        # def call
        #   Movielog::Db::UpdateMostWatchedTables.call(
        #     db: Movielog.db, viewings: Movielog.viewings,
        #   )
        # end

        def call
          viewings= Dir["#{Movielog.viewings_path}/*.yml"].each_with_object({}) do |file, hash|
            viewing_data = read_viewing(file)
            next unless viewing_data.is_a?(Hash)
            next if viewing_data[:tmdb_id]

            hash[viewing_data[:db_title]] ||= []
            hash[viewing_data[:db_title]] << file

          end

          viewings.each do |title, files|
            confirmed = false
            movie = nil

            while not confirmed
              IO.popen('pbcopy', 'w') { |f| f << title[0...-6] }
              tmdb_id = Ask.input(text: "TMDB ID for \"#{title}\":")
              movie = Tmdb::Movie.detail(tmdb_id)

              confirmed = Ask.confirm(prompt: movie.title)
            end

            files.each do |file_name|
              viewing_data = read_viewing(file_name)
              next unless viewing_data.is_a?(Hash)
              viewing_data[:tmdb_id] = movie.id
              viewing_data[:imdb_id] = movie.imdb_id

              content = "#{viewing_data.to_yaml}\n"

              File.open(file_name, 'w') { |file| file.write(content) }
            end
          end

        end

        private

        def read_viewing(file)
          YAML.load(IO.read(file))
        rescue YAML::SyntaxError => e
          puts "YAML Exception reading #{file}: #{e.message}"
        rescue => e
          puts "Error reading file #{file}: #{e.message}"
        end
      end
    end
  end
end
