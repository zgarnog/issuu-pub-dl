# Issuu Publication Downloader v1.3 

**v1.0 by eqagunn, modified by zgarnog**


## Downloading A Document

You can now download a document's images by its URL with 
one command, without searching through the source of the 
web page. 

On Windows, this can be done by running ```issuu-dl```.
This is the file with the Issuu icon.

On linux, this program is untested but may work
by running: ```issuu-dl.pl``` or ```perl issuu-dl.pl```

This will show a prompt where you can paste an Issuu document URL.

```issuu-dl.pl``` will also convert all .jpg files to a single .pdf, 
after prompting the user to continue. This is done using ImageMagick.

### Converting Images to PDF

To convert images to PDF manually, on Windows, you can use 
```jpg-to-pdf``` (or on linux, ```jpg-to-pdf.pl```). This is the 
program run by ```issuu-dl``` to convert multiple .jpg images to a
single .pdf file.

You can also use ImageMagick ```convert``` command directly,
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


## Notes

To get options for sending a URL without a prompt, 
run ```issuu-dl.pl``` or run ```perldoc issuu-dl.pl```.

## DEPENDENCIES

  - Perl 
    - example: [DWIM Perl](http://dwimperl.com/)
  - [Image Magick](http://www.imagemagick.org/) 
    - this is used for converting from .jpg to .pdf

### Testing Completed

  - tested with Perl v5.14.2), 
  - tested with Image Magick 6.9.1-2 Q16 x64, under Windows 7
  - tested under Windows 7 command prompt and explorer
    - also tested under Windows 7 cygwin 64-bit

## URLs

[zgarnog on github](https://github.com/zgarnog)

[equagunn on blogspot](http://eqagunn.blogspot.com/)


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
and Hrvoje Nik�i�. The main purpose of it is downloading Issuu publications
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


