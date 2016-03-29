OpenSeadragon DZI composer PHP version  readme file.
Version 0.7b March 2016
Licensed under BSD-2 Clause license. https://opensource.org/licenses/BSD-2-Clause
URL: http://chafalladas.com/

Disclaimer.
This software is free for use and copy, the source can be modified as needed and redistributed under the same BSD-2 license as long as the author is recognized.
THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT ANY GUARANTEE MADE AS TO ITS SUITABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. IF YOU CHOOSE TO USE IT, YOU DO SO ENTIRELY AT YOUR OWN RISK.
THE AUTHOR TAKES NO RESPONSIBILITY FOR ANY DAMAGE THAT MAY DIRECTLY OR INDIRECTLY BE CAUSED THROUGH ITS USE OR MISUSE.
IF YOU DO NOT OR CANNOT ACCEPT THESE TERMS FOR WHATEVER REASON, DO NOT USE THIS SOFTWARE.
NO FEE MAY BE CHARGED FOR SUCH DISTRIBUTION OR FOR THE SOFTWARE WITHOUT PRIOR PERMISSION FROM THE AUTHOR.

Objective of this software.

Ease the uploading and creation of DZI tiles and webpages for the OpenSeadragon viewer for large images.

1.- Using this program at the webpage:
1.1 Selection of the options.
1.2 The downloaded file use.
1.3 Caveats.

Further examples and code to show the utility of this action will be provided soon.
==============================================================================

2. Using this program at your own server.
2.1.- Installing the program.
	Copy the files in a dir and edit the HTML lines containing the BASE URL path to properly run the script.
	You can also personalize the other URLs to fit your needs.
2.1.- Prerequisites.
	php 5.4
	php5-dev
	pkg-config
	2.1.1 - If you want to use the Image Magick version instead the GD one you must have these components in your server.
		libmagickwand_dev
		pear
		pcl
		imagick
		You can check if it's installed running this command.
		echo extension=imagick.so > /etc/php5/conf.d/imagick.ini
2.2.- Configuration of the launcher.
	
2.3.- Running.

3. Caveats.
This program will create and delete directories and files, be aware thet the config utility can create directories in all the paths permited to web aplications. Rmember to check the permissions or secure the config files.
4. Useful links.
https://www.caveofprogramming.com/perl-tutorial/perl-file-delete-deleting-files-and-directories-in-perl.html
http://kill.devc.at/node/320
https://github.com/openseadragon/openseadragon
5. Acknowledgements.
OpenseaDragon
	php 5.4
	php5-dev
	pkg-config
	libmagickwand_dev
pear
	pcl
	imagick

	echo extension=imagick.so > /etc/php5/conf.d/imagick.ini
6.Feedback and updates

You can leave a comment at http://chafalladas.com/openseadragon-dzi-composer/
Script updates (if any) will be available at http://chafalladas.com/openseadragon-dzi-composer/

Also I will dance for PED.

7 CHANGELOG.
08/03/2016 First release.

TO-DO:
Installer.
Clean up code, comment it properly document it properly.
Translato to Spanish.
