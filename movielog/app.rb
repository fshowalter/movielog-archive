require 'movie_db'

module Movielog
  class App
    class << self
      #
      # Gets a collection of viewings.
      #
      # @return [Enumerable<Viewing>] A collection of viewings.
      def viewings
        ParseViewings.call(viewings_path)
      end

      #
      # Gets a collection of unique venues.
      #
      # @return [Enumerable<String>] A collection of venue names.
      def venues
        viewings.values.map { |viewing| viewing[:venue] }.uniq
      end

      def search_titles(query, db = db)
        MovieDb::App.search_titles(db, query)
      end

      def headline_cast_for_title(title, db = db)
        MovieDb::App.headline_cast_for_title(db, title)
      end

      def aka_titles_for_title(title, db = db)
        MovieDb::App.aka_titles_for_title(db, title)
      end

      def db
        @db ||= MovieDb::App.connection(db_path)
      end

      #
      # Adds the given viewing.
      #
      # @param viewing_hash [Hash] The viewing to add.
      #
      def add_viewing(viewing_hash)
        viewing_hash[:number] = viewings.length + 1
        CreateViewing.call(viewings_path, viewing_hash)
      end

      private

      def viewings_path
        File.expand_path("../../viewings/", __FILE__)
      end

      def db_path
        File.expand_path("../../db/", __FILE__)
      end

    end
  end
end