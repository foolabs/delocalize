# let's hack into ActiveRecord a bit - everything at the lowest possible level,
# of course, so we minimalize side effects
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
    converted_value = convert_number_column_value_without_localization(value)
    if I18n.delocalization_enabled?
      Numeric.parse_localized(converted_value)
    else
      converted_value
    end
  end
  alias_method_chain :convert_number_column_value, :localization
end

ActiveRecord::Dirty.module_eval do
  # overriding to convert numbers with localization
  # this method belongs to Dirty module
  def field_changed?(attr, old, value)
    if column = column_for_attribute(attr)
      if column.number?
        if column.null && (old.nil? || old == 0) && value.blank?
          # For nullable numeric columns, NULL gets stored in database for blank (i.e. '') values.
          # Hence we don't record it as a change if the value changes from nil to ''.
          # If an old value of 0 is set to '' we want this to get changed to nil as otherwise it'll
          # be typecast back to 0 (''.to_i => 0)
          value = nil
        else
          value = Numeric.parse_localized(value)
        end
      else
        value = column.type_cast(value)
      end
    end

    old != value
  end
end

column_class = ActiveRecord::ConnectionAdapters::Column
def column_class.string_to_date(value)
  Date.parse_localized(value)
end

def column_class.string_to_time(value)
  Time.parse_localized(value)
end
