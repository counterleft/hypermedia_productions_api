require "spec_helper"

describe Production do
  subject { Production.new({category: 'Code'}) }

  it "has a category" do
    subject.category.should == 'Code'
  end

  it "has many episodes" do
    episode1 = double("Episode")
    episode2 = double("Episode")

    subject.add_episode(episode1)
    subject.add_episode(episode2)

    subject.episodes.should include(episode1, episode2)

    subject.remove_episode(episode1)
    subject.remove_episode(episode2)

    subject.episodes.should_not include(episode1, episode2)
  end
end