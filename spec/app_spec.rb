require 'spec_helper'
require 'yajl'

describe "Productions API (app)" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def parse(last_response)
    last_response.content_type.should == 'application/vnd.brian.productions+json'
    Yajl::Parser.parse(last_response.body, {symbolize_keys: true})
  end

  before do
    get '/api'
  end

  context "api root url" do
    it "responds with all productions" do
      actual = parse(last_response)

      actual[:productions].should be_an(Array)
      actual[:productions].should have_at_least(1).items

      actual[:productions].each do |production|
        production[:category].should_not be_nil
        production[:category].should_not be_empty
        production[:links].should be_an(Array)

        episodes_link = production[:links].find { |l| l[:rel] == "episodes" }
        episodes_link.should_not be_empty
        episodes_link[:href].should_not be_empty
      end
    end

    it "has category filter form" do
      actual = parse(last_response)

      actual[:forms].should be_an(Array)
      category_filter = actual[:forms].find { |f| f[:rel] == "category_filter" }
      category_filter[:href].should_not be_nil
      category_filter[:data].should be_an(Array)
      category_filter[:data].first[:name].should == "category"
      category_filter[:data].first[:value].should == ""
      category_filter[:method].should == "get"
    end

    it "has link to root" do
      actual = parse(last_response)
      actual[:links].find { |l| l[:rel] == "root" }.should_not be_empty
      actual[:links].find { |l| l[:rel] == "root" }[:href].should_not be_empty
    end

    it "has new productions" do
      actual = parse(last_response)
      actual[:new_productions].should be_an(Array)
      actual[:new_productions].should have_at_least(1).items

      actual[:new_productions].each do |production|
        production[:category].should_not be_nil
        production[:category].should_not be_empty
        production[:links].should be_an(Array)

        episodes_link = production[:links].find { |l| l[:rel] == "episodes" }
        episodes_link.should_not be_empty
        episodes_link[:href].should_not be_empty
      end
    end
  end

  it "filters productions by category" do
    root_response = parse(last_response)

    category_filter = root_response[:forms].find { |f| f[:rel] == "category_filter" }
    filtered_url = category_filter[:href] + '?' + category_filter[:data].first[:name] + '=' + "music"

    get filtered_url
    actual = parse(last_response)
    actual[:productions].find { |p| p[:category].downcase == "music"}.should_not be_empty
  end

  context "when accessing episodes" do
    before do
      root_response = parse(last_response)

      episodes_link = root_response[:productions].first[:links].find { |l| l[:rel] == "episodes" }[:href]
      get episodes_link
    end

    it "has access to a production's episodes" do
      actual = parse(last_response)
      actual[:episodes].should be_an(Array)
      actual[:episodes].should have_at_least(1).items
      actual[:episodes].first[:summary].should_not be_nil
      actual[:episodes].first[:links].should be_an(Array)
      actual[:episodes].first[:links].find { |l| l[:rel] == "video" }[:href].should_not be_nil
    end

    it "has link back to root url" do
      actual = parse(last_response)
      actual[:links].find { |l| l[:rel] == "root" }.should_not be_nil
    end

  end

end