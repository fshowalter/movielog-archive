# frozen_string_literal: true
module Movielog
  #
  # Responsible for holding viewing data.
  #
  class Viewing
    attr_reader :number, :title, :db_title, :date, :venue

    def initialize(number:, title:, db_title:, date:, venue:)
      @number = number
      @title = title
      @db_title = db_title
      @date = date
      @venue = venue
    end
  end
end
