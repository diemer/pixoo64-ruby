require "faraday"
require "json"

module Pixoo64
  class Api
    module Request
      DEVICE_LIST = "Device/ReturnSameLANDevice"
    end

    API_URL = "https://app.divoom-gz.com"

    def self.device_list
      request(Request::DEVICE_LIST)
    end

    def self.request(endpoint)
      response = Faraday.post("#{API_URL}/#{endpoint}")
      result = JSON.parse(response.body)
    end
  end

  class Device
    module DeviceCommand
      GET_CHANNEL = "Channel/GetIndex"
      SET_CHANNEL = "Channel/SetIndex"
    end

    module DeviceChannel
      CHANNEL_TYPE = %i[
        faces
        cloud_channel
        visualizer
        custom
        black_screen
      ]
    end

    attr_reader :name, :id, :private_ip, :mac

    def initialize(attributes)
      @name = attributes["DeviceName"]
      @id = attributes["DeviceId"]
      @private_ip = attributes["DevicePrivateIP"]
      @mac = attributes["DeviceMac"]
    end

    def self.find(id)
      all.filter { |d| d.id == id }.first
    end

    def self.all
      result = Api.device_list
      result["DeviceList"].map { |attributes| new(attributes) }
    end

    def current_channel
      selected_index = device_command(DeviceCommand::GET_CHANNEL)["SelectIndex"]
      DeviceChannel::CHANNEL_TYPE[selected_index]
    end

    def set_channel(channel)
      channels = DeviceChannel::CHANNEL_TYPE
      unless channels.include?(channel)
        raise ArgumentException, "Expected one of #{puts channels.join(", ")}, got #{channel}"
      end

      device_command(DeviceCommand::SET_CHANNEL, { "SelectIndex" => channels.find_index(channel) })
    end

    private

    def device_command(command, params = {})
      request({ "Command" => command }.merge(params))
    end

    def request(json_param)
      conn = Faraday.new(
        url: "http://#{@private_ip}",
        headers: { "Content-Type" => "application/json" }
      )
      response = conn.post("post", json_param.to_json)
      JSON.parse(response.body)
    end
  end
end
