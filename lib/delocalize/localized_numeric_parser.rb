# TODO:
#   * proper documentation (comments)
module Delocalize
  class LocalizedNumericParser
    class << self
      # Parse numbers replacing locale specific delimeters and separators with
      # standard ruby _ and .
      def parse(value)
        if value == false
          0
        elsif value == true
          1
        elsif value.is_a?(String) && value.blank?
          nil
        elsif value.is_a?(String)
          separator = I18n.t(:'number.format.separator')
          delimeter = I18n.t(:'number.format.delimiter')
          value.strip.tr("#{separator}#{delimeter}", "._")
        else
          value
        end
      end
    end
  end
end
