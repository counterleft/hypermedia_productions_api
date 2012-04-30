class Episode
  attr_accessor :summary, :video_link

  def initialize(param_hash)
    param_hash.each { |k,v| send("#{k}=", v) }
  end
end