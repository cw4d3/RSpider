#!/usr/bin/env ruby

require 'rubygems'
require 'anemone'
require 'optparse'
require 'ostruct'

options = OpenStruct.new
options.relative = false
options.output = false
options.html = false
options.csv = false
options.code = false
options.time = false

begin
  # make sure that the last option is a URL we can crawl, and second to last gets set as filename
  target    = URI(ARGV.last)
  filename  = (ARGV[-2]) if (ARGV[-2]) =~ /^\w.*/
rescue
  puts <<-INFO

Usage:
  ruby rspider.rb [options] <filename> <url>
    
Synopsis:
  Rspider crawls a site starting at the given URL and outputs the URLs (absolute or relative), response time, and response code
  (optional) of each page in the domain as they are encountered. Rspider will only crawl within the given domain. If a directory
  output is not specified, the directory containing the script will be used. If no file output format is specified, STDOUT will be used.
  

Options:
  -r, --relative      Output relative URLs (rather than absolute)
  -o, --output        Specify the output directory (absolute path, including trailing slash)
  -w, --html          File output is HTML format
  -s, --csv           File output is comma-delineated CSV format
  -p, --plaintext     File output is plaintext
  -c, --code          Include page response code in output
  -t, --time          Include page response time (in milliseconds) for the request

Example:
  ruby rspider.rb --code --relative --html -o /Users/johnsnow/Desktop/ my_filename http://tar.get
INFO
  exit(0)
end

# parse command-line options
opts = OptionParser.new
opts.on('-r', '--relative') { options.relative = true }
opts.on('-o', '--output') { options.output = ARGV[-3] if ARGV[-3] != /^-./}
opts.on('-w', '--html') { options.html = true }
opts.on('-s', '--csv') { options.csv = true }
opts.on('-p', '--plaintext') { options.text = true }
opts.on('-c', '--code') { options.code = true }
opts.on('-t', '--time') { options.time = true }
opts.parse!(ARGV)

if options.output
  @output = options.output
end

puts "######################################################
      \nRSpider -- writes URLs and response codes to file 
      \n######################################################"
puts "\nRun without arguments for help\n"
puts "\nTarget:           #{target}"
puts "Output/Filename:  #{@output}" + "#{filename}
      \nProcessing...\n"

###### Create empty arrays for each option
all =  []
urls = []
path = []
code = []
time = []
br   = []
final = []

###### Process Target
Anemone.crawl(target, :discard_page_bodies => true) do |spider|
  spider.on_every_page do |page|
    if !options.relative
      urls.push page.url
    end
    if options.relative
      path.push page.url.path
    end
    if options.code
      code.push page.code
    end
    if options.time
      time.push page.response_time
    end
    br.push "<br />" #for html format output
  end
end

####### HTML Format
if options.html
  urls.map! { |item| "<td><a href=\"#{item}\">#{item}</a></td>" }
  path.map! { |item| "<td><a href=\"#{item}\">#{item}</a></td>" }
  code.map! { |item| "<td>#{item}</td>" }
  time.map! { |item| "<td>#{item}</td>" }
  
  # build the flattened array based on relative or full url options
  if options.relative
    @final = path.zip(code, time, br).sort
  elsif !options.relative
    @final = urls.zip(code, time, br).sort
  end
  
  # write the final array to file
  File.open("#{@output}" + "#{filename}.html", "w") do |f|
    f.puts @final
  end
  puts "\nComplete!" 

####### CSV Format
elsif options.csv
  urls.map! { |item| "#{item}\t" }
  path.map! { |item| "#{item}\t" }
  code.map! { |item| "#{item}\t" }
  time.map! { |item| "#{item}\t" }
  
  # build the flattened array based on relative or full url options
  if options.relative
    @final = path.zip(code, time)
  elsif !options.relative
    @final = urls.zip(code, time).sort
  end
  
  # write the final array to file
  File.open("#{@output}" + "#{filename}.csv", "w") do |f|
    @final.each { |row| f.puts row.join(",") }
  end
  puts "\nComplete!"

####### Plaintext Format
elsif options.text
  if options.relative
    @final = path.zip(code, time)
  elsif !options.relative
    @final = urls.zip(code, time)
  end
  
  File.open("#{@output}" + "#{filename}.txt", "w") do |f|
    @final.each { |row| f.puts row.join(" \t") }
  end
  puts "\nComplete!"

####### STDOUT  
elsif !options.html && !options.csv && !options.text
  if options.relative
    @final = path.zip(code, time)
  elsif !options.relative
    @final = urls.zip(code, time)
  end
  puts "\n"
  @final.each { |row| puts row.join("\t") }
end

