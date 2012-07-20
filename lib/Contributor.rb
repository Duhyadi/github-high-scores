require 'rubygems'
require 'data_mapper'
require 'net/http'
require 'json'
require 'uri'

class Contributor < BaseModel
  include DataMapper::Resource

  property :id, Serial
  property :login, String
  property :gravatar_id, String
  property :contributions, String

  def self.create_from_user_and_repo(user, repo)
    stored_user = User::create_from_username(user)
    stored_repo = Repo::create_from_username_and_repo(user, repo)

    contributors_url = REPO_BASE_URL + "#{user}/#{repo}/contributors"
    contributors_feed = RestClient.get(contributors_url)
    contributors = contributors_feed.body
    repository_contributors = JSON.parse(contributors)
    contributors_array = Array.new

    repository_contributors.each do |repository_contributor|
      contributor = Contributor.new
      contributor.login = repository_contributor['login']
      contributor.gravatar_id = repository_contributor['gravatar_id']
      contributor.contributions = repository_contributor['contributions']
      contributor.save
    end
  end

  def self.get_json_response(url)
    RestClient.get(url)
  end
end

DataMapper::auto_upgrade!