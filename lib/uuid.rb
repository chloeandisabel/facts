class UUID < String

  def initialize
    timestamp = (Time.now.to_f * 1000000).to_i.to_s(36)
    device_id = Mac.addr
    random = SecureRandom.base64
    super "#{timestamp}-#{device_id}-#{random}"
  end

end
