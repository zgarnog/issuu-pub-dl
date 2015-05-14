# Issuu Publication Downloader v1.3 

**v1.3 by zgarnog**

## Purpose

To download one or more documents from http://issuu.com/ 
and save each document as a pdf.

## Caveats

Can create large pdf files ( > 100M ), because each page is downloaded
as a jpg image, rather than text plus images, as would normally be stored
in a pdf file.

Resulting pdf file size depends on the number of pages in the document, 
and how large each page's image file is. This depends on how complex
the document's page images are.


## Downloading A Document

You can download a document's images by its URL with 
one command.

On Windows, this can be done by running **issuu-dl**.
This is the file with the Issuu icon.

On linux, this can be done by running **issuu-dl.pl** 
or **perl issuu-dl.pl**.

This will show a prompt where you can paste an Issuu document URL.
These are usually in the format ```http://issuu.com/[user]/docs/[title]```.

The program will download each page as a .jpg file stored in a 
subdirectory under **downloads**. It will then convert all of 
the .jpg files to a single .pdf file stored directly 
under **downloads**.


### Other Options

See issuu-dl [html](issuu-dl.html)/[md](issuu-dl.md) SYNOPSIS for options.


### Downloads Directories and Files

The program stores downloaded data in a **downloads** subdirectory under the 
directory the program is located.

*.jpg* files are saved under a directory named in the format **downloads/[title]**.
These files are **left behind** after the .pdf file is created; it is up to you to
clean them up. This also means you can do something different with them if
you want to.

*.pdf* files created are saved in a file named in the format **downloads/[title].pdf**.

### Converting Images to PDF

After downloading, you may want to re-convert images to PDF.
On Windows, you can use **jpg-to-pdf**. On linux use **perl jpg-to-pdf.pl**. 
This is the program run by **issuu-dl** to convert multiple .jpg images 
to a single .pdf file.


#### Other Options

See jpg-to-pdf [html](jpg-to-pdf.html)/[md](jpg-to-pdf.md) SYNOPSIS for options.


## DEPENDENCIES

  - Perl   ( tested with v5.14.2 )
    - under Windows: [DWIM Perl](http://dwimperl.com/)
    - under cygwin:  cygwin perl
  - [Image Magick](http://www.imagemagick.org/) ( tested with 6.9.1-2 Q16 x64 )
    - this is used for converting from .jpg to .pdf

### Testing Done

  - tested under Windows 7, 
    via command prompt and explorer
  - also tested under Windows 7 cygwin 64-bit 
    linux-like command-line

  - tested with Perl v5.14.2 
  - tested with Image Magick 6.9.1-2 Q16 x64

## URLs

[zgarnog on github](https://github.com/zgarnog)

[equagunn on blogspot](http://eqagunn.blogspot.com/)


## Further Notes

The .pl files contain documentation about their usage including
options not described here.


### ImageMagick Convert Options

You can also use ImageMagick **convert** command directly,
in a command prompts or shell, by using a command similar to one
of the following variants. 

See the [ImageMagick convert documentation](http://www.imagemagick.org/script/convert.php) for more options.

#### Windows:

```
convert path_to_document_dir\*.jpg document_name.pdf

convert -density 300 path_to_document_dir\*.jpg document_name.pdf
```

#### Linux:

```
convert path_to_document_dir/*.jpg document_name.pdf

convert -density 300 path_to_document_dir/*.jpg document_name.pdf
```



# Issuu Publication Downloader v1.0 (2012-03-18)

**by eqagunn**

## About Issuu:

Issuu is an online service that allows for realistic and customizable viewing
of digitally uploaded material, such as portfolios, books, magazine issues,
newspapers, and other print media. It integrates with social networking sites
to promote uploaded material. Issuu's service is comparable to what Flickr
does for photo-sharing, and what YouTube does for video-sharing. While most
of the documents are meant to be viewed online, some can be downloaded and
saved as well. Uploaded print material is viewed through a web browser and is
made to look like a printed publication with an animated page flip options.

## About This Tool:

The tool itself is a batch script that uses GNU Wget made by Giuseppe Scrivano
and Hrvoje Nikšiæ. The main purpose of it is downloading Issuu publications
which aren't available for the download the usual way. Normally, to download an
Issuu publication, one has to register first, and publication itself needs to
have download enabled. When using this tool neither of these two requirements
are needed because it downloads the images, shown to users through a Flash
application when they are reading them, directly from the server.

## How to Use It:

You can either run it with Windows Explorer or call it through Command Prompt.
Just run a file named issuudl.bat and you will be asked to enter a document ID
and number of pages of the publication you want to download. All downloaded
files are being saved into downloads folder, into a subfolder named by document
ID. You can also call it with Command Prompt and use it with parameters. First
parameter is Document ID and second one is Number of Pages. Not specifying one
or both of those parameters will result in batch file asking you to input them.
You can also specify a third parameter which is a name of the folder in which
downloaded files will be saved. Keep in mind that a long name argument needs
to be enclosed with quotes. This parameter is optional and if you don't specify
it folder will be named by document ID. Upon downloading the publication
"Done!" message will be displayed accompanied by a beep sound.

## Final Words:

I made this tool because I couldn't find another way to download ebook named
The Art of Video Games: From Pac-Man to Mass Effect. In the end, I decided to
share it hoping it might help someone, somewhere out there. Feel free to visit
my blog http://eqagunn.blogspot.com where I write computer related stuff.


