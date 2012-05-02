require 'sinatra'
require 'jbuilder'
require 'haml'
require 'less'
require './lib/production'
require './lib/episode'

# Fake production data
# Since this is a proof-of-concept, we use a static dataset.
def production_data(category = nil)
  productions = []
  music = Production.new(category: "Music")

  music.add_episode(Episode.new(summary: "Music Ep1 Summary", video_link: url("/production/music/video1")))
  music.add_episode(Episode.new(summary: "Music Ep2 Summary", video_link: url("/production/music/video2")))
  music.add_episode(Episode.new(summary: "Music Ep3 Summary", video_link: url("/production/music/video3")))

  code = Production.new(category: "Code")

  code.add_episode(Episode.new(summary: "Code Ep1 Summary", video_link: url("/production/code/video1")))
  code.add_episode(Episode.new(summary: "Code Ep2 Summary", video_link: url("/production/code/video2")))
  code.add_episode(Episode.new(summary: "Code Ep3 Summary", video_link: url("/production/code/video3")))

  productions.push(music)
  productions.push(code)

  productions.select! { |p| p.category.downcase == category.downcase } if category

  productions
end

get '/docs' do
  haml :index, :format => :html5
end

get '/docs.css' do
  less :docs
end

get '/api' do
  set_headers
  new_productions = production_data.select { |p| p.category.downcase == "code" }
  productions_view(production_data, new_productions)
end

get '/api/productions/filtered' do
  set_headers
  new_productions = production_data.select { |p| p.category.downcase == "code" }
  productions_view(production_data(params[:category]), new_productions)
end

get '/api/production/:category' do
  set_headers
  production = production_data.find { |p| p.category.downcase == params[:category].downcase }
  episodes_view(production)
end

def set_headers
  headers "Content-type" => "application/vnd.brian.productions+json"
end

# TODO real code would probably extract all view code into its own class(es)
# so we don't pollute the routing section of the app
def episodes_view(production)
  Jbuilder.encode do |json|
    json.episodes do |json|
      json.array!(production.episodes) do |json, episode|
        json.summary episode.summary
        json.links do |json|
          json.child! do |json|
            json.rel "video"
            json.href episode.video_link
          end
        end
      end
    end
  end
end

def productions_view(productions, new_productions)
  Jbuilder.encode do |json|
    json.productions do |json|
      json.array!(productions) do |json, production|
        production_view(json, production)
      end
    end

    json.new_productions do |json|
      json.array!(new_productions) do |json, production|
        production_view(json, production)
      end
    end

    json.forms do |json|
      json.child! do |json|
        json.rel "category_filter"
        json.href url("/api/productions/filtered")
        json.method "get"
        json.data do |json|
          json.child! do |json|
            json.name "category"
            json.value ""
          end
        end
      end
    end

    json.links do |json|
      root_link(json)
    end
  end
end

def root_link(json)
  json.child! do |json|
    json.rel "root"
    json.href url("/api")
  end
end

def production_view(json, production)
  json.category production.category
    json.links do |json|
      json.child! do |json|
        json.rel "episodes"
        json.href url("/api/production/#{production.category.downcase}")
      end
    end
end