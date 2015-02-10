Web Crawler README
author: Max Bucci
date created: 11/11/14
last modified: 11/16/14

Requires:
	open-uri
	fuzzystringmatch
	noko-giri

How to Run:

	from the Crawler directory:
		ruby webCrawler.rb 

Input:
			
	The program listens for user input. If the user enters "end"
	the program will terminate early. Any other input will do
	nothing. 

Output:
	
	Upon completion or early termination by the user, the total number
	and urls of all found broken links will be printed to the user. 
