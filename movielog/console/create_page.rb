module Movielog
  module Console
    #
    # Responsible for providing a console interface to create new pages.
    #
    class CreatePage
      class << self
        #
        # Responsible for processing a new page command.
        #
        # @return [Movielog::Page] the new page.
        def call
          title = ask_for_title
          page = Movielog::CreatePage.call(pages_path: Movielog.pages_path,
                                                 title: title,
                                                 sequence: Movielog.next_post_number,
                                                 slug: Movielog::Slugize.call(text: title))

          puts "\n Created Page #{Bold.call(text: page.title)}!\n" \
          " #{Bold.call(text: '     Sequence:')} #{page.sequence}\n"

          page
        end

        private

        def ask_for_title
          title = nil

          while title.nil?
            entered_title = Ask.input 'Page Title'
            title = entered_title if Ask.confirm entered_title
          end

          title
        end
      end
    end
  end
end
