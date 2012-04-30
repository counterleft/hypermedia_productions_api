class Production
  attr_accessor :category

  def initialize(param_hash)
    param_hash.each { |k,v| send("#{k}=", v) }
    @episodes ||= Set.new
  end

  def episodes
    Set.new(@episodes)
  end

  def add_episode(episode)
    @episodes.add(episode)
  end

  def remove_episode(episode)
    @episodes.delete(episode)
  end

  private
  def episodes=(episodes)
    @episodes = episodes
  end

end