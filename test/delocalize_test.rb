require File.dirname(__FILE__) + '/test_helper'

class DelocalizeActiveRecordTest < ActiveRecord::TestCase
  def setup
    Time.zone = 'Berlin' # make sure everything works as expected with TimeWithZone
    @product = Product.new
  end

  test "delocalizes localized number" do
    @product.price = '1.299,99'
    assert_equal 1299.99, @product.price

    @product.price = '-1.299,99'
    assert_equal -1299.99, @product.price
  end

  test "delocalizes localized date with year" do
    date = Date.civil(2009, 3, 19)

    @product.released_on = '19. März 2009'
    assert_equal date, @product.released_on

    @product.released_on = '19.3.2009'
    assert_equal date, @product.released_on
  end

  test "delocalizes localized date without year" do
    date = Date.civil(Date.today.year, 10, 19)

    @product.released_on = '19. Okt'
    assert_equal date, @product.released_on
  end

  test "delocalizes localized datetime with year" do
    time = Time.zone.local(2009, 3, 1, 12, 0, 0)

    @product.published_at = 'Sonntag, 1. März 2009, 12:00 Uhr'
    assert_equal time, @product.published_at

    @product.published_at = '1. März 2009, 12:00 Uhr'
    assert_equal time, @product.published_at
  end

  test "delocalizes localized datetime without year" do
    time = Time.zone.local(Date.today.year, 3, 1, 12, 0, 0)

    @product.published_at = '1. März, 12:00 Uhr'
    assert_equal time, @product.published_at
  end

  test "delocalizes localized time" do
    time = Time.zone.local(2000, 1, 1, 9, 0, 0)
    @product.cant_think_of_a_sensible_time_field = '09:00 Uhr'
    assert_equal time, @product.cant_think_of_a_sensible_time_field
  end

  test "uses default parse if format isn't found" do
    date = Date.civil(2009, 10, 19)

    @product.released_on = '2009/10/19'
    assert_equal date, @product.released_on

    time = Time.zone.local(2009, 3, 1, 12, 0, 0)
    @product.published_at = '2009/03/01 12:00'
    assert_equal time, @product.published_at

    now = Time.current
    time = Time.zone.local(2000, 1, 1, 9, 0, 0)
    @product.cant_think_of_a_sensible_time_field = '09:00'
    assert_equal time, @product.cant_think_of_a_sensible_time_field
  end

  test "should return nil if the input is empty or invalid" do
    @product.released_on = ""
    assert_nil @product.released_on

    @product.released_on = "aa"
    assert_nil @product.released_on
  end

  test "doesn't raise when attribute is nil" do
    assert_nothing_raised {
      @product.price = nil
      @product.released_on = nil
      @product.published_at = nil
      @product.cant_think_of_a_sensible_time_field = nil
    }
  end

  test "uses default formats if enable_delocalization is false" do
    I18n.enable_delocalization = false

    @product.price = '1299.99'
    assert_equal 1299.99, @product.price

    @product.price = '-1299.99'
    assert_equal -1299.99, @product.price
  end

  test "uses default formats if called with with_delocalization_disabled" do
    I18n.with_delocalization_disabled do
      @product.price = '1299.99'
      assert_equal 1299.99, @product.price

      @product.price = '-1299.99'
      assert_equal -1299.99, @product.price
    end
  end

  test "uses localized parsing if called with with_delocalization_enabled" do
    I18n.with_delocalization_enabled do
      @product.price = '1.299,99'
      assert_equal 1299.99, @product.price

      @product.price = '-1.299,99'
      assert_equal -1299.99, @product.price
    end
  end

  test "dirty attributes must detect changes in decimal columns" do
    @product.price = 10
    @product.save
    @product.price = "10,34"
    assert_equal("10.34", @product.price_before_type_cast)
    assert_equal BigDecimal("10.34"), @product.price
    assert @product.price_changed?
  end

  test "dirty attributes must detect changes in float columns" do
    @product.weight = 10
    @product.save
    @product.weight = "10,34"
    assert_equal 10.34, @product.weight
    assert @product.weight_changed?
  end

  test "serialization and deserialization of 'timestamp' should be symetric" do
    @product.the_timestamp = 1.day.from_now.to_s(:db)  # date
    @product.save
    @product.reload
    assert_equal(1.day.from_now.to_i, @product.the_timestamp.to_i)
  end

  test "before type casting of timestamp" do
    @product.the_timestamp = 1.day.from_now.to_s(:db)  # date
    assert_equal(1.day.from_now.to_s(:db), @product.the_timestamp_before_type_cast)
  end

  test "before type casting of date" do
    @product.released_on = 1.day.from_now.to_s(:db)  # date
    assert_equal(1.day.from_now.to_s(:db), @product.released_on_before_type_cast)
    assert @product.released_on_before_type_cast.is_a?(String)
  end
end

class DelocalizeActionViewTest < ActionView::TestCase
  include ActionView::Helpers::FormHelper

  def setup
    Time.zone = 'Berlin' # make sure everything works as expected with TimeWithZone
    @product = Product.new
  end

  test "shows text field using formatted number" do
    @product.price = 1299.9
    assert_dom_equal '<input id="product_price" name="product[price]" size="30" type="text" value="1.299,90" />',
      text_field(:product, :price)
  end

  test "shows text field using formatted number with options" do
    @product.price = 1299.995
    assert_dom_equal '<input id="product_price" name="product[price]" size="30" type="text" value="1,299.995" />',
      text_field(:product, :price, :precision => 3, :delimiter => ',', :separator => '.')
  end

  test "shows text field using formatted number without precision if column is an integer" do
    @product.times_sold = 20
    assert_dom_equal '<input id="product_times_sold" name="product[times_sold]" size="30" type="text" value="20" />',
      text_field(:product, :times_sold)

    @product.times_sold = 2000
    assert_dom_equal '<input id="product_times_sold" name="product[times_sold]" size="30" type="text" value="2.000" />',
      text_field(:product, :times_sold)
  end

  test "shows text field using formatted date" do
    @product.released_on = Date.civil(2009, 10, 19)
    assert_dom_equal '<input id="product_released_on" name="product[released_on]" size="30" type="text" value="19.10.2009" />',
      text_field(:product, :released_on)
  end

  test "shows text field using formatted date and time" do
    @product.published_at = Time.zone.local(2009, 3, 1, 12, 0, 0)
    # careful - leading whitespace with %e
    assert_dom_equal '<input id="product_published_at" name="product[published_at]" size="30" type="text" value="Sonntag,  1. März 2009, 12:00 Uhr" />',
      text_field(:product, :published_at)
  end

  test "shows text field using formatted date with format" do
    @product.released_on = Date.civil(2009, 10, 19)
    assert_dom_equal '<input id="product_released_on" name="product[released_on]" size="30" type="text" value="19. Oktober 2009" />',
      text_field(:product, :released_on, :format => :long)
  end

  test "shows text field using formatted date and time with format" do
    @product.published_at = Time.zone.local(2009, 3, 1, 12, 0, 0)
    # careful - leading whitespace with %e
    assert_dom_equal '<input id="product_published_at" name="product[published_at]" size="30" type="text" value=" 1. März, 12:00 Uhr" />',
      text_field(:product, :published_at, :format => :short)
  end

  test "shows text field using formatted time with format" do
    @product.cant_think_of_a_sensible_time_field = Time.zone.local(2009, 3, 1, 9, 0, 0)
    assert_dom_equal '<input id="product_cant_think_of_a_sensible_time_field" name="product[cant_think_of_a_sensible_time_field]" size="30" type="text" value="09:00 Uhr" />',
      text_field(:product, :cant_think_of_a_sensible_time_field, :format => :time)
  end

  test "doesn't raise an exception when object is nil" do
    assert_nothing_raised {
      text_field(:not_here, :a_text_field)
    }
  end

  test "doesn't raise for nil Date/Time" do
    @product.published_at, @product.released_on, @product.cant_think_of_a_sensible_time_field = nil
    assert_nothing_raised {
      text_field(:product, :published_at)
      text_field(:product, :released_on)
      text_field(:product, :cant_think_of_a_sensible_time_field)
    }
  end

  test "doesn't override given :value" do
    @product.price = 1299.9
    assert_dom_equal '<input id="product_price" name="product[price]" size="30" type="text" value="1.499,90" />',
      text_field(:product, :price, :value => "1.499,90")
  end

  test "don't convert type if field has errors" do
    @product = ProductWithValidation.new(:price => 'this is not a number')
    @product.valid?
    assert_dom_equal '<div class="fieldWithErrors"><input id="product_price" name="product[price]" size="30" type="text" value="this is not a number" /></div>',
      text_field(:product, :price)
  end

  test "doesn't raise an exception when object isn't an ActiveReccord" do
    @product = NonArProduct.new
    assert_nothing_raised {
      text_field(:product, :name)
      text_field(:product, :times_sold)
      text_field(:product, :published_at)
      text_field(:product, :released_on)
      text_field(:product, :cant_think_of_a_sensible_time_field)
      text_field(:product, :price, :value => "1.499,90")
    }
  end
end
