# TODO:
#   * AM/PM calculation
#   * proper documentation (comments)
module Delocalize
  class LocalizedDateTimeParser
    class << self
      def parse(raw_datetime, type)
        return unless raw_datetime
        return raw_datetime if raw_datetime.respond_to?(:strftime) # already a Date/Time object -> no need to parse it

        input_formats(type).each do |original_format, regex_format|
          next unless raw_datetime =~ /^#{regex_format}$/

          begin
            translated = translate_month_and_day_names(raw_datetime)
            datetime = DateTime.strptime(translated, original_format)
          rescue ArgumentError => e
            return default_parse(raw_datetime, type)
          end

          if Date == type
            return datetime.to_date
          else
            return Time.local(
              datetime.year, datetime.mon, datetime.mday,
              datetime.hour, datetime.min, datetime.sec
            )
          end
        end

        default_parse(raw_datetime, type)
      end

      def valid_format?(raw_datetime, type)
        return false unless raw_datetime
        return true if raw_datetime.respond_to?(:strftime) # already a Date/Time object -> no need to parse it

        return input_formats(type).any? do |original_format, regex_format|
          begin
            next unless raw_datetime =~ /^#{regex_format}$/
            translated = translate_month_and_day_names(raw_datetime)
            
            DateTime.strptime(translated, original_format)
          rescue ArgumentError => e
            next
          end
        end
      end

      private
      def default_parse(datetime, type)
        return if datetime.blank?
        begin
          today = Date.current
          parsed = Date._parse(datetime)
          return if parsed.empty? # the datetime value is invalid
          # set default year, month and day if not found
          parsed.reverse_merge!(:year => today.year, :mon => today.mon, :mday => today.mday)
          datetime = Time.local(*parsed.values_at(:year, :mon, :mday, :hour, :min, :sec))
          Date == type ? datetime.to_date : datetime
        rescue
          datetime
        end
      end

      def input_formats(type)
        # Date uses date formats, all others use time formats
        type = (type == Date) ? :date : :time
        @input_formats ||= {}
        @input_formats[I18n.locale] ||= {}
        @input_formats[I18n.locale][type] ||= I18n.t(:"#{type}.formats").values.compact.map { |f| [f, apply_regex(f)] }
      end

      def translate_month_and_day_names(datetime)
        translated = I18n.t([:month_names, :abbr_month_names, :day_names, :abbr_day_names], :scope => :date).flatten.compact
        original = (Date::MONTHNAMES + Date::ABBR_MONTHNAMES + Date::DAYNAMES + Date::ABBR_DAYNAMES).compact
        word_map = {}
        translated.each_with_index{ |k,i| word_map[k] = original[i] }
        datetime.gsub(/[^_\W]+/u){|x| word_map[x] || x}
      end


      def apply_regex(format)
        format.gsub('%B', "(#{I18n.t('date.month_names').compact.join('|')})"). # long month name
        gsub('%b', "(#{I18n.t('date.abbr_month_names').compact.join('|')})"). # short month name
        gsub('%m', "(\\d{1,2})").                                   # numeric month
        gsub('%A', "(#{I18n.t('date.day_names').compact.join('|')})").                # full day name
        gsub('%a', "(#{I18n.t('date.abbr_day_names').compact.join('|')})").           # short day name
        gsub('%Y', "(\\d{4})").                                     # long year
        gsub('%y', "(\\d{2})").                                     # short year
        gsub('%e', "(\\w?\\d{1,2})").                               # short day
        gsub('%d', "(\\d{1,2})").                                   # full day
        gsub('%H', "(\\d{1,2})").                                   # hour (24)
        gsub('%d', "(\\d{1,2})").                                   # full day
        gsub('%H', "(\\d{1,2})").                                   # hour (24)
        gsub('%M', "(\\d{1,2})").                                   # minute
        gsub('%S', "(\\d{1,2})")                                    # second
      end
    end
  end
end
