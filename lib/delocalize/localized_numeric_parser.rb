# TODO:
#   * proper documentation (comments)
module Delocalize
  class LocalizedNumericParser
    class << self
      # Parse numbers replacing locale specific delimeters and separators with
      # standard ruby _ and .
      def parse(value)
        if value.is_a?(String)
          separator = I18n.t(:'number.format.separator')
          delimeter = I18n.t(:'number.format.delimiter')
          delocalized_value = value.strip.tr("#{separator}#{delimeter}", "._")
          # try to parse the delocalized string to a number
          if is_numerical?(delocalized_value)
            delocalized_value
          else
            # if the delocalized string is not parsable to a number
            # return the original so that <attribute>_before_type_cast is preserved
            value
          end
        else
          value
        end
      end

      def is_numerical?(string)
        begin
          Float(string)
          true
        rescue
          false
        end
      end
    end
  end
end
