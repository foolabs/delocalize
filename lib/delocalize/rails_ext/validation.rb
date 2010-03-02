module ActiveRecord::Validations::ClassMethods
  # Validates whether the value of the specified attribute is numeric by trying to convert it to
  # a float with Kernel.Float (if <tt>only_integer</tt> is false) or applying it to the regular expression
  # <tt>/\A[\+\-]?\d+\Z/</tt> (if <tt>only_integer</tt> is set to true).
  #
  #   class Person < ActiveRecord::Base
  #     validates_numericality_of :value, :on => :create
  #   end
  #
  # Configuration options:
  # * <tt>:message</tt> - A custom error message (default is: "is not a number").
  # * <tt>:on</tt> - Specifies when this validation is active (default is <tt>:save</tt>, other options <tt>:create</tt>, <tt>:update</tt>).
  # * <tt>:only_integer</tt> - Specifies whether the value has to be an integer, e.g. an integral value (default is +false+).
  # * <tt>:allow_nil</tt> - Skip validation if attribute is +nil+ (default is +false+). Notice that for fixnum and float columns empty strings are converted to +nil+.
  # * <tt>:greater_than</tt> - Specifies the value must be greater than the supplied value.
  # * <tt>:greater_than_or_equal_to</tt> - Specifies the value must be greater than or equal the supplied value.
  # * <tt>:equal_to</tt> - Specifies the value must be equal to the supplied value.
  # * <tt>:less_than</tt> - Specifies the value must be less than the supplied value.
  # * <tt>:less_than_or_equal_to</tt> - Specifies the value must be less than or equal the supplied value.
  # * <tt>:odd</tt> - Specifies the value must be an odd number.
  # * <tt>:even</tt> - Specifies the value must be an even number.
  # * <tt>:if</tt> - Specifies a method, proc or string to call to determine if the validation should
  #   occur (e.g. <tt>:if => :allow_validation</tt>, or <tt>:if => Proc.new { |user| user.signup_step > 2 }</tt>).  The
  #   method, proc or string should return or evaluate to a true or false value.
  # * <tt>:unless</tt> - Specifies a method, proc or string to call to determine if the validation should
  #   not occur (e.g. <tt>:unless => :skip_validation</tt>, or <tt>:unless => Proc.new { |user| user.signup_step <= 2 }</tt>).  The
  #   method, proc or string should return or evaluate to a true or false value.
  def validates_numericality_of(*attr_names)
    configuration = { :on => :save, :only_integer => false, :allow_nil => false }
    configuration.update(attr_names.extract_options!)


    numericality_options = ALL_NUMERICALITY_CHECKS.keys & configuration.keys

    (numericality_options - [ :odd, :even ]).each do |option|
      raise ArgumentError, ":#{option} must be a number" unless configuration[option].is_a?(Numeric)
    end

    validates_each(attr_names,configuration) do |record, attr_name, value|
      raw_value = record.send("#{attr_name}_before_type_cast") || value

      next if configuration[:allow_nil] and raw_value.nil?

      unless raw_value.is_a?(Numeric)
        if configuration[:only_integer]
          matcher = /^[-+]?\d+([_]\d{3})*$/
        else
          matcher = /^[-+]?\d+([_]\d{3})*[.]?\d*$/
        end

        unless matcher.match(raw_value.to_s.strip)
          record.errors.add(attr_name, :not_a_number, :value => raw_value, :default => configuration[:message])
          next
        end

        raw_value = configuration[:only_integer] ? raw_value.to_i : raw_value.to_f
      end

      numericality_options.each do |option|
        case option
        when :odd, :even
          unless raw_value.to_i.method(ALL_NUMERICALITY_CHECKS[option])[]
            record.errors.add(attr_name, option, :value => raw_value, :default => configuration[:message])
          end
        else
          record.errors.add(attr_name, option, :default => configuration[:message], :value => raw_value, :count => configuration[option]) unless raw_value.method(ALL_NUMERICALITY_CHECKS[option])[configuration[option]]
        end
      end
    end
  end

  def validates_date_format_of(*attr_names)
    configuration = { :on => :save, :allow_nil => false }
    configuration.update(attr_names.extract_options!)

    validates_each(attr_names,configuration) do |record, attr_name, value|
      raw_value = record.send("#{attr_name}_before_type_cast") || value
      Delocalize::LocalizedDateTimeParser.valid_format?(raw_value, Date)
    end
  end

  def validates_time_format_of(*attr_names)
    configuration = { :on => :save, :allow_nil => false }
    configuration.update(attr_names.extract_options!)

    validates_each(attr_names,configuration) do |record, attr_name, value|
      raw_value = record.send("#{attr_name}_before_type_cast") || value
      Delocalize::LocalizedDateTimeParser.valid_format?(raw_value, Time)
    end
  end
end