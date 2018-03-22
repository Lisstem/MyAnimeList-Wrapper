require 'rest-client' # see https://github.com/rest-client/rest-client
require 'crack/xml' # see https://github.com/jnunemaker/crack/
require 'date'

# author 'Lisstem'
#
# Wrapper for the MyAnimeList.net API
# See https://myanimelist.net/modules.php?go=api for more information on the API including usage and values
#
# please note that the password will be stored in plain text in your RAM
class MyAnimeList
  # Tags used in the anime XML
  @anime_tags = [:episode, :status, :score, :storage_type, :storage_value, :times_rewatched, :rewatch_value,
                 :date_start, :date_finish, :priority, :enable_discussion, :enable_rewatching, :comments, :tags]
  # Tags used in the manga XML
  @manga_tags = [:chapter, :volume, :status, :score, :times_reread, :reread_value, :date_start,:date_finish, :date,
                 :priority, :enable_discussion, :enable_rereading, :comments, :scan_group, :tags, :retail_volumes]

  # accessors for user and password
  attr_accessor :user, :password

  # Initializes new instances
  # @param [String] user username for MyAnimeList.net
  # @param [String] password password for MyAnimeList.net
  # it is sufficient if user and password to_s evaluates to the name and password
  def initialize(user, password)
    @user = user
    @password = password
  end

  # searches for matches of Animes for a given string
  # @param [String] waldo String to search for (will be automatically escaped)
  # @return [Array] returns an array of hashes of the matches for waldo
  #   in case of a unknown status code the Restclient::Response is returned
  #   each hash represents a match and includes the following key value pairs:
  #     :id => integer ;id on MyAnimeList.net
  #     :title => string (might be nil);japanese title
  #     :english => string (might be empty string) ;english title
  #     :synonyms => array of strings (might be empty) ;each string is a synonym
  #     :episodes => integer ;count of episodes
  #     :score => float ;score on MyAnimeList.net
  #     :type => symbol ;type of the anime as symbol
  #     :status => string ;status of the anime i.e. 'Finished Airing'
  #     :start_date => Date or String if unconvertable ;start of airing
  #     :end_date => Date or String if unconvertable ;end of airing
  #     :synopsis => string ;synopsis
  #     :image => string (might be nil) ;link to the image on MyAnimeList.net
  def search_anime(waldo)
    response = RestClient.get "https://#{user}:#{password}@myanimelist.net/api/anime/search.xml?q=#{CGI::escapeHTML(waldo)}"
    case response.code
      when 200
        return MyAnimeList.create_animes response.body
      when 204
        return []
      else
        return response
    end
  end

  # adds an anime to the watchlist
  # @param [Integer] id id of the anime on MyAnimeList.net
  # @param [Hash] data hash with the data of the read anime
  #   The hash must contain some of the symbols in @anime_tags (i don't know which must)
  #   not all values have to be present (i don't know which must)
  #   for further information check the MyAnimeList API site
  # @return [Object] the result of RestClient.post
  def add_anime(id, data)
    RestClient.post "https://#{user}:#{password}@myanimelist.net/api/animelist/add/#{id}.xml",
                    {:data => MyAnimeList.anime_xml(data)}
  end

  # updates an anime on the watchlist
  # @param [Integer] id id of the anime on MyAnimeList.net
  # @param [Hash] data hash with the data of the read anime
  #   The hash must contain some of the symbols in @anime_tags (i don't know which must)
  #   not all values have to be present, (i don't know which must)
  #   for further information check the MyAnimeList API site
  # @return [Object] the result of RestClient.post
  def update_anime(id, data)
    RestClient.post "https://#{user}:#{password}@myanimelist.net/api/animelist/update/#{id}.xml",
                    {:data => MyAnimeList.anime_xml(data)}
  end

  # deletes an anime from the watchlist
  # @param [Integer] id id of the anime on MyAnimeList.net
  # @return [Object] the result of RestClient.delete
  def delete_anime(id)
    RestClient.delete "https://#{user}:#{password}@myanimelist.net/api/animelist/delete/#{id}.xml"
  end

  # searches for matches of Mangas for a given string
  # @param [String] waldo String to search for (will be automatically escaped)
  # @return [Array of Hashes] returns an array of hashes of the matches for waldo
  #   in case of a unknown status code the Restclient::Response is returned
  #   each hash represents a match and includes the following key value pairs:
  #     :id => integer ;id on MyAnimeList.net
  #     :title => string ;japanese title
  #     :english => string (might be empty string) ;english title
  #     :synonyms => array of strings (might be empty) ;each string is a synonym
  #     :chapters => integer ;count of chapters
  #     :volumes = integer ;count of english volumes
  #     :score => float ;score on MyAnimeList.net
  #     :type => symbol ;type of the anime as symbol
  #     :status => string ;status of the anime i.e. 'Finished Airing'
  #     :start_date => Date or String if unconvertable ;start of airing
  #     :end_date => Date or String if unconvertable ;end of airing
  #     :synopsis => string ;synopsis
  #     :image => string (might be nil) ;link to the image on MyAnimeList.net
  def search_manga(waldo)
    response = RestClient.get "https://#{user}:#{password}@myanimelist.net/api/manga/search.xml?q=#{CGI::escapeHTML(waldo)}"
    case response.code
      when 200
        return MyAnimeList.create_mangas response.body
      when 204
        return []
      else
        return response
    end
  end

  # adds a manga to the readlist
  # @param [Integer] id id of the manga on MyAnimeList.net
  # @param [Hash] data hash with the data of the read manga
  #   The hash must contain some of the symbols in @manga_tags (i don't know which must)
  #   not all values have to be present (i don't know which must)
  #   for further information check the MyAnimeList API site
  # @return [Object] the result of RestClient.post
  def add_manga(id, data)
    RestClient.post "https://#{user}:#{password}@myanimelist.net/api/mangalist/add/#{id}.xml",
                    {:data => MyAnimeList.manga_xml(data)}
  end

  # updates a manga on the readlist
  # @param [Integer] id id of the manga on MyAnimeList.net
  # @param [Hash] data hash with the data of the read manga
  #   The hash must contain some of the symbols in @manga_tags (i don't know which must)
  #   not all values have to be present (i don't know which must)
  #   for further information check the MyAnimeList API site
  # @return [Object] the result of RestClient.post
  def update_manga(id, data)
    RestClient.post "https://#{user}:#{password}@myanimelist.net/api/mangalist/update/#{id}.xml",
                    {:data => MyAnimeList.manga_xml(data)}
  end

  # deletes a manga from the readlist
  # @param [Integer] id id of the manga on MyAnimeList.net
  # @return [Object] the result of RestClient.delete
  def delete_manga(id)
    RestClient.delete "https://#{user}:#{password}@myanimelist.net/api/mangalist/delete/#{id}.xml"
  end

  # creates the anime XML string for MyAnimeList.net for a data hash
  # @param [Hash] data the data hash
  # @return [String] the XML string
  def self.anime_xml(data)
    create_xml(@anime_tags, data)
  end

  # creates the manga XML string for MyAnimeList.net for a data hash
  # @param [Hash] data the data hash
  # @return [String] the XML string
  def self.manga_xml(data)
    create_xml(@manga_tags, data)
  end

  # creates a XML string given a set of tags and data hash
  # @param [Array] tags the tags
  # @param [Hash] data the data hash
  # @return [String] the XML string
  def self.create_xml(tags, data)
    xml = '<?xml version="1.0" encoding="UTF-8"?>'
    xml << "\n<entry>\n"
    tags.each do |tag|
      value = data[tag]
      unless value.nil?
        value = value.join(',') if value.respond_to? :each
        xml << "  <#{tag.to_s}>#{value.to_s}</#{tag.to_s}>\n"
      end
    end
    xml << "</entry>"
    puts xml
    xml
  end

  # Parses the XML response to a Array of Hashes representing the animes
  # @param [String] xml the XML response as string
  # @return [Array] the Array of Hashes
  def self.create_animes(xml)
    animes = []
    xml = Crack::XML.parse(xml)['anime']['entry']
    if xml.respond_to? :each_pair
      xml = [xml]
    end
    xml.each do |entry|
      anime = {}
      anime[:id] = entry['id'].to_i
      anime[:title] = entry['title']
      anime[:english] = entry['english']
      anime[:synonyms] = entry['synonyms']
      if anime[:synonyms].nil?
        anime[:synonyms] = []
      else
        anime[:synonyms] = anime[:synonyms].split(';')
      end
      anime[:episodes] = entry['episodes'].to_i
      anime[:score] = entry['score'].to_f
      anime[:type] = entry['type'].downcase.to_sym
      anime[:status] = entry['status']
      begin
        anime[:start_date] = Date.parse(entry['start_date'])
      rescue ArgumentError
        anime[:start_date] = entry['start_date']
      end
      begin
        anime[:end_date] = Date.parse(entry['end_date'])
      rescue ArgumentError
        anime[:end_date] = entry['end_date']
      end
      anime[:synopsis] = entry['synopsis']
      anime[:image] = entry['image']
      animes << anime
    end
    animes
  end

  # Parses the XML response to a Array of Hashes representing the mangas
  # @param [String] xml the XML response as string
  # @return [Array] the Array of Hashes
  def self.create_mangas(xml)
    mangas = []
    xml = Crack::XML.parse(xml)['manga']['entry']
    if xml.respond_to? :each_pair
      xml = [xml]
    end
    xml.each do |entry|
      manga = {}
      puts entry
      manga[:id] = entry['id'].to_i
      manga[:title] = entry['title']
      manga[:english] = entry['english']
      if manga[:synonyms].nil?
        manga[:synonyms] = []
      else
        manga[:synonyms] = manga[:synonyms].split(';')
      end
      manga[:chapters] = entry['chapters'].to_i
      manga[:volumes] = entry['volumes'].to_i
      manga[:score] = entry['score'].to_f
      manga[:type] = entry['type'].downcase.to_sym
      manga[:status] = entry['status']
      begin
        manga[:start_date] = Date.parse(entry['start_date'])
      rescue ArgumentError
        manga[:start_date] = entry['start_date']
      end
      begin
        manga[:end_date] = Date.parse(entry['end_date'])
      rescue ArgumentError
        manga[:end_date] = entry['end_date']
      end
      manga[:synopsis] = entry['synopsis']
      manga[:image] = entry['image']
      mangas << manga
    end
    mangas
  end
end
