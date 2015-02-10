#webCraweler.rb
#Author: Max Bucci
#Created: 11/11/14
#Last Modified: 11/16/14
#
#Crawls the bowdoin domain for broken links. 
#Unique sites are only visited once and both
#visted and broken links are kept track of by
#separate classes each with appropriate functions.
#

require 'open-uri'
require 'fuzzystringmatch'
require 'nokogiri'


#Contains data structures and functions for the array of visited links
class VisitedSites
	#Constructor 
	def initialize()
		@visited = []
	end

	#Checks if a given site is in the array (i.e visited)
	def visited?(url)
		@visited.include?(url)
	end

	#Adds a new url to the list
	def append(url)
		@visited.push(url)
	end

	#Returns size of visisted
	def size()
		@visited.size
	end
end


#Contains data structures and funcitons for the array of broken links
class BrokenSites
	#Constructor 
	def initialize()
		@broken = []
	end 

	#Checks if a given site is in the array (i.e. broken)
	def broken?(url)
		@broken.include?(url)
	end

	#Adds a new url to the list
	def append(url)
		@broken.push(url)
	end

	#Returns size of broken
	def size()
		@broken.size
	end

	def printBroken()
		puts @broken, "# of broken links = #{@broken.size()}"
	end
end


#Finds all the links within a given page. Then opens
#each link if it has not been previously visited. 
def getLinks(url)
	page = open(url).read
	links = page.scan(/<a\s+href="(.+?)"/i).flatten
	links.delete("#")
	links = links.uniq
	links.each do |oneLink|
		oneLink.insert(0, url) if oneLink.start_with?("/")
		openPage(oneLink, url) if not $visitedSites.visited?(oneLink)
	end
end


#Decides whether or not to open a page depending on its url and content. 
#Only opens pages that are within the bowdoin domain (bowdoin.edu) and 
#aren't equivalent to the parent page. 
def openPage(url, prevUrl)
	begin 
		#Don't visit this page again
		$visitedSites.append(url)

		if url =~ /http[s]?:\/\/.*?bowdoin\.edu/i and not url =~ /http[s]?:\/\/.*?(\.com|\.net|\.edu|\.gov).*?bowdoin\.edu/i
			if not url =~ /http[s]?:\/\/.*?(\#|\/\/|\.mp3|\.pdf|\.mov|\.xml|\.jpg|digitalcommons)/i

				#Parses urls for comparison. Help from StackOverflow
				page1 = Nokogiri::HTML(open(url))
				page2 = Nokogiri::HTML(open(prevUrl))
				
				#Gets the fuzzy distance (value between 0 and 1) b/w
				#the two pages. >85% similarity is considred equivalent
				#Help for StackOverflow
				delta = 0.85
				distance = $jarow.getDistance(page1, page2)

				if not distance >= delta
					puts $visitedSites.size(), "+++good+++", url
					links = getLinks(url)
				end
			end
		end

	rescue 
		#If the page couldn't be opened but it has a valid url, then it is broken
		if not page1
			if url =~ /http:.*?/i
				$brokenSites.append(url) if not $brokenSites.broken?(url)
			end
		else
			puts "===ERROR===", url, "\t#{$!}"
		end
	end 
end


#Master function which begins the whole program. 
#the open() function requires a valid url so a random
#webiste (google) is passed initially 
def brokenLinks(url)
	openPage(url, "http://www.google.com")
	$brokenSites.printBroken()
	puts "End of program"
end


#Listens for user input without pausing the program.
#Stops the crawl if user inputs "end", else nothing.
#Help from StackOverflow
Thread.new do
  loop do
  	s = gets.chomp
    if s == 'end'
    	$brokenSites.printBroken()
		puts "End of program"
		exit
	end
  end
end


#Global variables
$brokenSites = BrokenSites.new()
$visitedSites = VisitedSites.new()
$jarow = FuzzyStringMatch::JaroWinkler.create( :native )

#Program start
startSite = "http://www.bowdoin.edu"
brokenLinks(startSite)
