require_relative 'myanimelist'

# creating a new MyAnimeList instance
# exchange 'user' and 'password' with your username and password
list = MyAnimeList.new('user', 'password')

# searching for animes
search_string = 'Naruto'
animes = list.search_anime(search_string)

# prints all animes
puts 'print all animes'
animes.each do |anime|
  puts "#{anime[:title]} (#{anime[:id]})
\tEnglish title: #{anime[:english]}
\tSynonyms:      #{anime[:synonyms].join(', ')}
\tScore:         #{anime[:score]}/10
\tType:          #{anime[:type]}
\tEpisodes:      #{anime[:episodes]}
\tStart date:    #{(anime[:start_date].respond_to? :strftime) ? anime[:start_date].strftime('%d %b %Y') : anime[:start_date]}
\tEnd date:      #{(anime[:end_date].respond_to? :strftime) ? anime[:end_date].strftime('%d %b %Y') : anime[:end_date]}
\tStatus:        #{anime[:status]}
\tSynopsis:      #{anime[:synopsis]}
\tImage link:    #{anime[:image]}"
end

# searching for mangas
search_string = 'Naruto'
mangas = list.search_manga(search_string)

# prints all mangas
puts 'print all mangas'
mangas.each do |manga|
  puts "#{manga[:title]} (#{manga[:id]})
\tEnglish title: #{manga[:english]}
\tSynonyms:      #{manga[:synonyms].join(', ')}
\tScore:         #{manga[:score]}/10
\tType:          #{manga[:type]}
\tChapters:      #{manga[:chapters]}
\tVolumes        #{manga[:volumes]}
\tStart date:    #{(manga[:start_date].respond_to? :strftime) ? manga[:start_date].strftime('%d %b %Y') : manga[:start_date]}
\tEnd date:      #{(manga[:end_date].respond_to? :strftime) ? manga[:end_date].strftime('%d %b %Y') : manga[:end_date]}
\tStatus:        #{manga[:status]}
\tSynopsis:      #{manga[:synopsis]}
\tImage link:    #{manga[:image]}"
end

# adding an anime
# first create a data hash
data = {:episode =>10,
        :status => 'watching',
        :score =>7,
        :tags => 'test tag, 2nd tag'}
# 28999 is the id of the anime on MyAnimeList.net
puts 'adding anime'
puts list.add_anime(28999, data)

# updating an anime
data[:episode] += 1
# 28999 is the id of the anime on MyAnimeList.net
puts 'updating anime'
puts list.update_anime(28999, data)

# deleting an anime
# 28999 is the id of the anime on MyAnimeList.net
puts 'deleting anime'
puts list.delete_anime(28999)

# it can take MyAnimeList.net to update your stats after you changed your watch/read list
# this cannot be changed by this Wrapper and does not mean something is broken

# adding/updating/deleting a manga is mostly the same
# for a full list of the tags see the MyAnimeList.net API documentation (https://myanimelist.net/modules.php?go=api)
