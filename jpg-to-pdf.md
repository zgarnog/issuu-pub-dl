# NAME

jpg-to-pdf.pl

# SYNOPSIS

    This program will read all *.jpg files from the
    given directory and create a single pdf file, 
    by using ImageMagick.

    jpg-to-pdf.pl # prompts for directory

    jpg-to-pdf.pl [directory]

    jpg-to-pdf.pl [directory] [options]

    options:
      --output=[filename.pdf]
      --density=[integer]
      --convert-limit-memory=[integer MB]
      --convert-limit-map=[integer MB]

# AUTHOR

zgarnog <zgarnog@yandex.com>

# DEPENDENCIES

    Perl v5.14.2

    ImageMagick 6.7.6-3 

# CHANGES

    - 2015-04-20
       - created
