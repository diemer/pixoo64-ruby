require "./test/test_helper"
# require "vcr"

class Pixoo64DeviceTest < Minitest::Test
  def test_exists
    assert Pixoo64::Device
  end

  def test_it_gives_back_all_the_devices
    VCR.use_cassette("all_devices") do
      # device = Pixoo64::Device.find(300018997)
      result = Pixoo64::Device.all

      # make sure we got all the devices
      assert_equal 2, result.length

      # make sure the JSON was parsed
      assert result.is_a?(Array)
      assert result.first.is_a?(Pixoo64::Device)
    end
  end

  def test_it_gives_back_a_single_device
    VCR.use_cassette("all_devices") do
      device = Pixoo64::Device.find(300_000_001)

      assert_equal Pixoo64::Device, device.class

      # Check that the fields are accessible by our model
      assert_equal 300_000_001, device.id
      assert_equal "Pixoo 1", device.name
      assert_equal "192.168.0.192", device.private_ip
      assert_equal "aabbccddee00", device.mac
    end
  end

  def test_it_gives_back_current_channel
    VCR.use_cassette("all_devices") do
      device = Pixoo64::Device.all.first

      assert_equal :faces, device.current_channel
    end
  end

  def test_it_sets_current_channel
    VCR.use_cassette("all_devices", record: :new_episodes) do
      device = Pixoo64::Device.all.first
      assert :visualizer, device.set_channel(:visualizer)
    end
  end
end
