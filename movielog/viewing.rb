# frozen_string_literal: true
module Movielog
  #
  # Responsible for holding viewing data.
  #
  class Viewing
    attr_reader :number, :title, :db_title, :date, :venue, :tmdb_id, :imdb_id

    def initialize(number:, tmdb_id:, imdb_id:, title:, db_title:, date:, venue:)
      @number = number
      @title = title
      @db_title = db_title
      @date = date
      @venue = venue
      @tmdb_id = tmdb_id
      @imdb_id = imdb_id
    end
  end
end
