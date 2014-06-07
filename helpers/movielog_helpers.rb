module MovielogHelpers
  def headline_cast(title)
    Movielog::App.headline_cast_for_title(title).map do |person|
      "#{person.first_name} #{person.last_name}"
    end.to_sentence
  end

  def viewings
    @viewings ||= begin
      viewings = Movielog::App.viewings
      viewings.each do |sequence, viewing|
        info = Movielog::App.info_for_title(viewing.title)
        viewing.sortable_title = info.sortable_title
        viewing.release_date = info.release_date
      end
      viewings
    end
  end

  def data_for_viewing(viewing)
    {
      data: {
        title: viewing.sortable_title,
        release_date: viewing.release_date.iso8601,
        release_date_year: viewing.release_date.year,
        viewing_date: viewing.date
      }
    }
  end
end