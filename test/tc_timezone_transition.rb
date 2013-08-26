#--
# Copyright (c) 2005-2013 Philip Ross
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#++

require File.join(File.expand_path(File.dirname(__FILE__)), 'test_utils')
require 'date'

include TZInfo

class TCTimezoneTransition < Test::Unit::TestCase
  
  class TestTimezoneTransition < TimezoneTransition
    def initialize(offset, previous_offset, at)
      super(offset, previous_offset)
      @at = TimeOrDateTime.wrap(at)
    end
    
    def at
      @at
    end
  end
  
  def test_offset
    t = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDT),
      TimezoneOffset.new(3600, 0, :TST), 1148949080)
    
    assert_equal(TimezoneOffset.new(3600, 3600, :TDT), t.offset)
  end
  
  def test_previous_offset
    t = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDT),
      TimezoneOffset.new(3600, 0, :TST), 1148949080)
    
    assert_equal(TimezoneOffset.new(3600, 0, :TST), t.previous_offset)
  end
  
  def test_local_end
    t1 = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDT),
      TimezoneOffset.new(3600, 0, :TST), 1148949080)
    t2 = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDT),
      TimezoneOffset.new(3600, 0, :TST), DateTime.new(2006, 5, 30, 0, 31, 20))
    t3 = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDT),
      TimezoneOffset.new(3600, 0, :TST), Time.utc(2006, 5, 30, 0, 31, 20))
      
    assert(TimeOrDateTime.new(1148952680).eql?(t1.local_end))
    assert(TimeOrDateTime.new(DateTime.new(2006, 5, 30, 1, 31, 20)).eql?(t2.local_end))
    assert(TimeOrDateTime.new(Time.utc(2006, 5, 30, 1, 31, 20)).eql?(t3.local_end))
  end
  
  def test_local_start
    t1 = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDT),
      TimezoneOffset.new(3600, 0, :TST), 1148949080)
    t2 = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDT),
      TimezoneOffset.new(3600, 0, :TST), DateTime.new(2006, 5, 30, 0, 31, 20))
    t3 = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDT),
      TimezoneOffset.new(3600, 0, :TST), Time.utc(2006, 5, 30, 0, 31, 20))
      
    assert(TimeOrDateTime.new(1148956280).eql?(t1.local_start))
    assert(TimeOrDateTime.new(DateTime.new(2006, 5, 30, 2, 31, 20)).eql?(t2.local_start))
    assert(TimeOrDateTime.new(Time.utc(2006, 5, 30, 2, 31, 20)).eql?(t3.local_start))
  end
  
  if RubyCoreSupport.time_supports_negative
    def test_local_end_before_negative_32bit
      t = TestTimezoneTransition.new(TimezoneOffset.new(-7200, 3600, :TDT),
        TimezoneOffset.new(-7200, 0, :TST), -2147482800)

      if RubyCoreSupport.time_supports_64bit
        assert(TimeOrDateTime.new(-2147490000).eql?(t.local_end))
      else
        assert(TimeOrDateTime.new(DateTime.new(1901, 12, 13, 19, 0, 0)).eql?(t.local_end))
      end
    end
  
    def test_local_start_before_negative_32bit
      t = TestTimezoneTransition.new(TimezoneOffset.new(-7200, 3600, :TDT),
        TimezoneOffset.new(-7200, 0, :TST), -2147482800)

      if RubyCoreSupport.time_supports_64bit
        assert(TimeOrDateTime.new(-2147486400).eql?(t.local_start))
      else
        assert(TimeOrDateTime.new(DateTime.new(1901, 12, 13, 20, 0, 0)).eql?(t.local_start))
      end
    end
  end
  
  def test_local_end_before_epoch
    t = TestTimezoneTransition.new(TimezoneOffset.new(-7200, 3600, :TDT),
      TimezoneOffset.new(-7200, 0, :TST), 1800)
      
    if RubyCoreSupport.time_supports_negative
      assert(TimeOrDateTime.new(-5400).eql?(t.local_end))
    else
      assert(TimeOrDateTime.new(DateTime.new(1969, 12, 31, 22, 30, 0)).eql?(t.local_end))
    end
  end
  
  def test_local_start_before_epoch
    t = TestTimezoneTransition.new(TimezoneOffset.new(-7200, 3600, :TDT),
      TimezoneOffset.new(-7200, 0, :TST), 1800)
    
    if RubyCoreSupport.time_supports_negative
      assert(TimeOrDateTime.new(-1800).eql?(t.local_start))
    else
      assert(TimeOrDateTime.new(DateTime.new(1969, 12, 31, 23, 30, 0)).eql?(t.local_start))
    end
  end
  
  def test_local_end_after_32bit
    t = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDT),
      TimezoneOffset.new(3600, 0, :TST), 2147482800)
      
    if RubyCoreSupport.time_supports_64bit
      assert(TimeOrDateTime.new(2147486400).eql?(t.local_end))
    else
      assert(TimeOrDateTime.new(DateTime.new(2038, 1, 19, 4, 0, 0)).eql?(t.local_end))
    end
  end
  
  def test_local_start_after_32bit
    t = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDT),
      TimezoneOffset.new(3600, 0, :TST), 2147482800)
      
    if RubyCoreSupport.time_supports_64bit
      assert(TimeOrDateTime.new(2147490000).eql?(t.local_start))
    else    
      assert(TimeOrDateTime.new(DateTime.new(2038, 1, 19, 5, 0, 0)).eql?(t.local_start))
    end
  end
  
  def test_equality_timestamp
    t1 = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDT),
      TimezoneOffset.new(3600, 0, :TST), 1148949080)
    t2 = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDT),
      TimezoneOffset.new(3600, 0, :TST), 1148949080)
    t3 = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDT),
      TimezoneOffset.new(3600, 0, :TST), DateTime.new(2006, 5, 30, 0, 31, 20))
    t4 = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDT),
      TimezoneOffset.new(3600, 0, :TST), Time.utc(2006, 5, 30, 0, 31, 20))
    t5 = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDT),
      TimezoneOffset.new(3600, 0, :TST), 1148949081)
    t6 = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDT),
      TimezoneOffset.new(3600, 0, :TST), DateTime.new(2006, 5, 30, 1, 31, 21))
    t7 = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDT),
      TimezoneOffset.new(3600, 0, :TST), Time.utc(2006, 5, 30, 1, 31, 21))
    t8 = TestTimezoneTransition.new(TimezoneOffset.new(3601, 3600, :TDT),
      TimezoneOffset.new(3600, 0, :TST), 1148949080)
    t9 = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDT),
      TimezoneOffset.new(3601, 0, :TST), 1148949080)
      
    assert_equal(true, t1 == t1)
    assert_equal(true, t1 == t2)
    assert_equal(true, t1 == t3)
    assert_equal(true, t1 == t4)
    assert_equal(false, t1 == t5)
    assert_equal(false, t1 == t6)
    assert_equal(false, t1 == t7)
    assert_equal(false, t1 == t8)
    assert_equal(false, t1 == t9)
    assert_equal(false, t1 == Object.new)
    
    assert_equal(true, t1.eql?(t1))
    assert_equal(true, t1.eql?(t2))
    assert_equal(false, t1.eql?(t3))
    assert_equal(false, t1.eql?(t4))
    assert_equal(false, t1.eql?(t5))
    assert_equal(false, t1.eql?(t6))
    assert_equal(false, t1.eql?(t7))
    assert_equal(false, t1.eql?(t8))
    assert_equal(false, t1.eql?(t9))
    assert_equal(false, t1.eql?(Object.new))
  end
  
  def test_equality_datetime
    t1 = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDT),
      TimezoneOffset.new(3600, 0, :TST), DateTime.new(2006, 5, 30, 0, 31, 20))
    t2 = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDT),
      TimezoneOffset.new(3600, 0, :TST), DateTime.new(2006, 5, 30, 0, 31, 20))
    t3 = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDT),
      TimezoneOffset.new(3600, 0, :TST), 1148949080)
    t4 = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDT),
      TimezoneOffset.new(3600, 0, :TST), Time.utc(2006, 5, 30, 0, 31, 20))
    t5 = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDT),
      TimezoneOffset.new(3600, 0, :TST), DateTime.new(2006, 5, 30, 1, 31, 21))
    t6 = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDT),
      TimezoneOffset.new(3600, 0, :TST), 1148949081)
    t7 = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDT),
      TimezoneOffset.new(3600, 0, :TST), Time.utc(2006, 5, 30, 1, 31, 21))
    t8 = TestTimezoneTransition.new(TimezoneOffset.new(3601, 3600, :TDT),
      TimezoneOffset.new(3600, 0, :TST), DateTime.new(2006, 5, 30, 0, 31, 20))
    t9 = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDT),
      TimezoneOffset.new(3601, 0, :TST), DateTime.new(2006, 5, 30, 0, 31, 20))
      
    assert_equal(true, t1 == t1)
    assert_equal(true, t1 == t2)
    assert_equal(true, t1 == t3)
    assert_equal(true, t1 == t4)
    assert_equal(false, t1 == t5)
    assert_equal(false, t1 == t6)
    assert_equal(false, t1 == t7)
    assert_equal(false, t1 == t8)
    assert_equal(false, t1 == t9)
    assert_equal(false, t1 == Object.new)
    
    assert_equal(true, t1.eql?(t1))
    assert_equal(true, t1.eql?(t2))
    assert_equal(false, t1.eql?(t3))
    assert_equal(false, t1.eql?(t4))
    assert_equal(false, t1.eql?(t5))
    assert_equal(false, t1.eql?(t6))
    assert_equal(false, t1.eql?(t7))
    assert_equal(false, t1.eql?(t8))
    assert_equal(false, t1.eql?(t9))
    assert_equal(false, t1.eql?(Object.new))
  end
  
  def test_equality_time
    t1 = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDT),
      TimezoneOffset.new(3600, 0, :TST), Time.utc(2006, 5, 30, 0, 31, 20))
    t2 = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDT),
      TimezoneOffset.new(3600, 0, :TST), Time.utc(2006, 5, 30, 0, 31, 20))
    t3 = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDT),
      TimezoneOffset.new(3600, 0, :TST), DateTime.new(2006, 5, 30, 0, 31, 20))
    t4 = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDT),
      TimezoneOffset.new(3600, 0, :TST), 1148949080)
    t5 = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDT),
      TimezoneOffset.new(3600, 0, :TST), Time.utc(2006, 5, 30, 0, 31, 21))
    t6 = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDT),
      TimezoneOffset.new(3600, 0, :TST), DateTime.new(2006, 5, 30, 1, 31, 21))
    t7 = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDT),
      TimezoneOffset.new(3600, 0, :TST), 1148949081)
    t8 = TestTimezoneTransition.new(TimezoneOffset.new(3601, 3600, :TDT),
      TimezoneOffset.new(3600, 0, :TST), 1148949080) 
    t9 = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDT),
      TimezoneOffset.new(3601, 0, :TST), 1148949080)
      
    assert_equal(true, t1 == t1)
    assert_equal(true, t1 == t2)
    assert_equal(true, t1 == t3)
    assert_equal(true, t1 == t4)
    assert_equal(false, t1 == t5)
    assert_equal(false, t1 == t6)
    assert_equal(false, t1 == t7)
    assert_equal(false, t1 == t8)
    assert_equal(false, t1 == t9)
    assert_equal(false, t1 == Object.new)
    
    assert_equal(true, t1.eql?(t1))
    assert_equal(true, t1.eql?(t2))
    assert_equal(false, t1.eql?(t3))
    assert_equal(false, t1.eql?(t4))
    assert_equal(false, t1.eql?(t5))
    assert_equal(false, t1.eql?(t6))
    assert_equal(false, t1.eql?(t7))
    assert_equal(false, t1.eql?(t8))
    assert_equal(false, t1.eql?(t9))
    assert_equal(false, t1.eql?(Object.new))
  end
  
  def test_hash
    t1 = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDTA),
      TimezoneOffset.new(3600, 0, :TSTA), 1148949080)
    t2 = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDTB),
      TimezoneOffset.new(3600, 0, :TSTB), DateTime.new(2006, 5, 30, 1, 31, 20))
    t3 = TestTimezoneTransition.new(TimezoneOffset.new(3600, 3600, :TDTC),
      TimezoneOffset.new(3600, 0, :TSTC), Time.utc(2006, 5, 30, 1, 31, 20))
      
    assert_equal(TimezoneOffset.new(3600, 3600, :TDTA).hash ^
      TimezoneOffset.new(3600, 0, :TSTA).hash ^ TimeOrDateTime.new(1148949080).hash,
      t1.hash)
    assert_equal(TimezoneOffset.new(3600, 3600, :TDTB).hash ^
      TimezoneOffset.new(3600, 0, :TSTB).hash ^ TimeOrDateTime.new(DateTime.new(2006, 5, 30, 1, 31, 20)).hash,
      t2.hash)
    assert_equal(TimezoneOffset.new(3600, 3600, :TDTC).hash ^
      TimezoneOffset.new(3600, 0, :TSTC).hash ^ TimeOrDateTime.new(Time.utc(2006, 5, 30, 1, 31, 20)).hash,
      t3.hash)
  end
end