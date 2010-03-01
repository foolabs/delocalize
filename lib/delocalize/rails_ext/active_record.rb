# let's hack into ActiveRecord a bit - everything at the lowest possible level, of course, so we minimalize side effects
ActiveRecord::ConnectionAdapters::Column.class_eval do
  def date?
    klass == Date
  end

  def time?
    klass == Time
  end
end

ActiveRecord::Base.class_eval do
  def convert_number_column_value_with_localization(value)
    if I18n.delocalization_enabled?
      value = Numeric.parse_localized(value)
    else
      value = convert_number_column_value_without_localization(value)
    end
    value
  end
  alias_method_chain :convert_number_column_value, :localization
end

column_class = ActiveRecord::ConnectionAdapters::Column
def column_class.string_to_date(value)
  Date.parse_localized(value)
end

def column_class.string_to_time(value)
  Time.parse_localized(value)
end