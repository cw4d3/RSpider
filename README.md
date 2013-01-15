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
  -c, --code          Include page response code in report
  -t, --time          Include page response time (in milliseconds) for the request

Example:
  ruby rspider.rb --code --relative --html -o /Users/johnsnow/Desktop/ my_filename http://tar.get
