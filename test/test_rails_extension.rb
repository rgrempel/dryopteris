require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

require 'rubygems'
require 'active_record'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'init'))

ActiveRecord::Base.establish_connection :database => ":memory:",
                                        :adapter => "sqlite3",
                                        :timout => 500

ActiveRecord::Schema.define do
  create_table :records, :force => true do |t|
    t.string :string
    t.text   :text
  end
end

class TestRailsExtension < Test::Unit::TestCase
  SCRIPT_TAG = "<script></script>"
  IMG_TAG = "<img src=\"test.png\"/>"

  def setup
    ActiveRecord::Base.connection.execute "DELETE FROM records"
  end

  class UnsanitizedRecord < ActiveRecord::Base
    set_table_name "records"
  end

  def test_does_nothing_for_unsanitized_record
    r = UnsanitizedRecord.create :string => SCRIPT_TAG, :text => SCRIPT_TAG

    assert_equal SCRIPT_TAG, r.string
    assert_equal SCRIPT_TAG, r.text
  end

  class SanitizedRecordNoParams < ActiveRecord::Base
    set_table_name "records"
    sanitize_fields
  end

  def test_sanitizes_all_textish_fields_if_no_params
    r = SanitizedRecordNoParams.create :string => SCRIPT_TAG, :text => SCRIPT_TAG

    assert_equal "", r.string
    assert_equal "", r.text
  end

  class SanitizedRecordParamsOnly < ActiveRecord::Base
    set_table_name "records"
    sanitize_fields :only => [:string]
  end

  def test_sanitizes_some_fields_if_params_only
    r = SanitizedRecordParamsOnly.create :string => SCRIPT_TAG, :text => SCRIPT_TAG

    assert_equal "", r.string
    assert_equal SCRIPT_TAG, r.text
  end

  class SanitizedRecordParamsExcept < ActiveRecord::Base
    set_table_name "records"
    sanitize_fields :except => [:text]
  end

  def test_sanitizes_some_fields_if_params_except
    r = SanitizedRecordParamsExcept.create :string => SCRIPT_TAG, :text => SCRIPT_TAG

    assert_equal "", r.string
    assert_equal SCRIPT_TAG, r.text
  end

  class SanitizedRecordParamsAllowTags < ActiveRecord::Base
    set_table_name "records"
    sanitize_fields :allow_tags => [:text]
  end

  def test_allows_tags
    r = SanitizedRecordParamsAllowTags.create :string => IMG_TAG, :text => IMG_TAG

    assert_equal "", r.string
    assert_equal IMG_TAG, r.text
  end
end
