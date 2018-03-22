# MyAnimeList-Wrapper
This is a simple ruby wrapper for the [MyAnimeList.net API](https://myanimelist.net/modules.php?go=api).

It can search the database for animes or mangas and allows managing of your watch and read lists.

## Installing
This Wrapper uses the Rest-Client and crack gems
You should be able to install them with

```
gem install rest-client crack
```
If this does not work check their github sites
 * [REST-Client](https://github.com/rest-client/rest-client)
 * [crack](https://github.com/jnunemaker/crack/)

## Usage
Here is a basic example of how to search for animes
```ruby
# creating a new Instance with username 'user' and password 'password'
list = MyAnimeList.new('user', 'password')

# searching and displaying all matching animes
animes = list.search_anime('Steins;Gate')
animes.each do |anime|
  puts "#{anime[:title]} (#{anime[:id]})"
end
```
For more examples check out the example.rb file 

## Built With
 * [REST-Client](https://github.com/rest-client/rest-client) - used access the REST API
 * [crack](https://github.com/jnunemaker/crack/) - used for parsing XML files


## Acknowledgments

* Thanks to the authors of the REST-Client and crack Gems for creating such easy to use gems.
* Thanks to MyAnimeList.net for providing the API 

