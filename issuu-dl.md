# NAME

issuu-dl.pl

# VERSION

1.3.0

# SYNOPSIS

    by prompts: (prompts for URL or other options)
      issuu-dl.pl

    by URL:
      issuu-dl.pl --url=[string] [options]

    by list of URLs:
      issuu-dl.pl --list=[urls_list_file.txt] [options]

      [urls_list_file.txt] should be a file containing one URL per line.

    by document id:
      issuu-dl.pl [title] [total_pages] [document_id] [options]

    example: 
      issuu-dl.pl "The Document Title" aaabbccccaoeuaeou-23434242 201

    The title will be used to create a directory under ./downloads
      example:
        "./downloads/The Document Title"

    options:
      --debug            print extra debug output
      --sleep=[integer]  (default: 0) sleep for seconds after downloading 
                         each page, to decrease the load on the network

# CHANGES

Issuu Publication Downloader v1.0
  by eqagunn

    2015-04-20 zgarnog
      - now uses leading zeros on numbers less than 100

    2015-05-11 zgarnog
      - converted to perl script
      - can now pass URL and will get details needed from 
        URL automatically

    2015-05-12 zgarnog
      - now calls other perl script to convert jpg to pdf,
      - now asks for URL interactively if not received
        via option.
