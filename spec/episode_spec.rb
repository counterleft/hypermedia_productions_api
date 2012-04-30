require 'spec_helper'

describe Episode do
  let(:video_link) { "http://foo.com/video.mpg" }
  let(:summary) { "this is an example summary" }
  subject { Episode.new(summary: summary, video_link: video_link) }

  it "has a summary" do
    subject.summary.should == summary
  end

  it "has a video link" do
    subject.video_link == video_link
  end
end