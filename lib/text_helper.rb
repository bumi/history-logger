require 'singleton'

# Singleton to be called in wrapper module
class TextHelperSingleton
  include Singleton
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::TagHelper #tag_options needed by auto_link
  include ActionView::Helpers::SanitizeHelper
end

# Wrapper module
module Railslabs #:nodoc:
  module CoreExtensions #:nodoc:
    module String #:nodoc:
      module TextHelper

        def auto_link(link = :all, href_options = {}, &block)
          TextHelperSingleton.instance.auto_link(self, link, href_options, &block)
        end

        def excerpt(phrase, radius = 100, excerpt_string = "...")
          TextHelperSingleton.instance.excerpt(self, phrase, radius, excerpt_string)
        end

        def highlight(phrase, highlighter = '<strong class="highlight">\1</strong>')
          TextHelperSingleton.instance.highlight(self, phrase, highlighter)
        end
 
        begin
          require_library_or_gem 'bluecloth'

          def markdown
            TextHelperSingleton.instance.markdown(self)
          end
        rescue LoadError
          # do nothing.  method will be undefined
        end

        def sanitize
          TextHelperSingleton.instance.sanitize(self)
        end

        def simple_format
          TextHelperSingleton.instance.simple_format(self)
        end

        def strip_tags
          TextHelperSingleton.instance.strip_tags(self)
        end

        begin
          require_library_or_gem "superredcloth" unless Object.const_defined?(:SuperRedCloth)

          def textilize
            TextHelperSingleton.instance.textilize(self)
          end

          def textilize_without_paragraph
            TextHelperSingleton.instance.textilize_without_paragraph(self)
          end
        rescue LoadError
          # do nothing.  methods will be undefined
        end

        def truncate(length = 30, truncate_string = "...")
          TextHelperSingleton.instance.truncate(self, length, truncate_string)
        end

        def word_wrap(line_width = 80)
          TextHelperSingleton.instance.word_wrap(self, line_width)
        end

      end
    end
  end
end

# extend String with the TextHelper functions
class String #:nodoc:
  include Railslabs::CoreExtensions::String::TextHelper
end
