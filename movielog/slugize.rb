module Movielog
  #
  # Responsible for converting a string into a url slug.
  #
  class Slugize
    class << self
      #
      # Responsible for converting a given string into a url slug.
      #
      # @param words [String] The string to convert.
      # @param slug [String] The default char to replace invalid chars.
      # @return [String] The sluggized string.
      def call(words, slug = '-')
        slugged = words.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
        slugged.gsub!(/&/, 'and')
        slugged.gsub!(/:/, '')
        slugged.gsub!(/[^\w_\-#{Regexp.escape(slug)}]+/i, slug)
        slugged.gsub!(/#{slug}{2,}/i, slug)
        slugged.gsub!(/^#{slug}|#{slug}$/i, '')
        url_encode(slugged.downcase)
      end
    end
  end
end
