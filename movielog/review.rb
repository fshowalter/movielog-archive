# frozen_string_literal: true
module Movielog
  #
  # Responsible for holding review data.
  #
  class Review
    attr_reader :sequence, :db_title, :title, :slug, :date, :imdb_id, :grade, :backdrop, :backdrop_placeholder, :content

    def initialize(sequence:,
                   db_title:,
                   title:,
                   slug:,
                   date:,
                   imdb_id:,
                   grade:,
                   backdrop:,
                   backdrop_placeholder:,
                   content:)
      @sequence = sequence
      @db_title = db_title
      @title = title
      @slug = slug
      @date = date
      @imdb_id = imdb_id
      @grade = grade
      @backdrop = backdrop
      @backdrop_placeholder = backdrop_placeholder
      @content = content
    end

    def title_without_year
      title.gsub(/\([^\)]+\)$/, '').strip
    end

    def year
      (db_title || display_title)[/\((\d{4}).*\)$/, 1]
    end
  end
end
