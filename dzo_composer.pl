#!/usr/bin/perl -wTU
#****************************************************************************************
use strict;
use warnings;
use CGI qw{ :standard };
use CGI::Carp qw ( fatalsToBrowser );
use File::Basename;
use File::Path qw(make_path);
use Image::Magick;
use POSIX qw(ceil);
use Time::HiRes qw(gettimeofday tv_interval);
#****************************************************************************************
my $query = new CGI;
my $safe_filename_characters = "a-zA-Z0-9_.-";
my $upload_dir = $query->param("upload_dir"); #Using precreated dirs, tiles and info will be created under this dir.
	$upload_dir =~  m/^([a-zA-Z0-9\._\/\-]+)$/ or Error(0,"Tainted $upload_dir","$!");
	$upload_dir = $1;
my $filename = $query->param("file");
	$filename =~ s/(?:\\|\/)([^\\\/]+)$/$1/g;
my ( $name, $path, $extension ) = fileparse ( $filename, '..*' );
	$filename = $name . $extension;
my $upload_filehandle = $query->upload("file");
my $overlap = $query->param("overlap");
my $tilesize = $query->param("tilesize");
my $filesize_real = $query->param("file_size"); #The real file size, not the form data one
my $sessid = $query->param("sessid");
	$sessid =~  m/^([a-zA-Z0-9\._]+)$/ or Error(0,"Tainted $sessid","$!");
my $pingfile = "$1.log";
my $debug_info = $query->param("debug_info"); #Pass additional debug info to the referrer.
my $log_info = $query->param("log_info"); #write additional log info.
my $t0 = [gettimeofday]; #Vars used to stat timelapses
my $elapsed = tv_interval ($t0);
#****************************************************************************************/^(\w+)$/
MAIN:
{
print "Content-type: text/html\n\n";
if ($log_info eq "false")
{
	$log_info = "true";
	printInfo("MAIN");
	$log_info = "false";
}
else{printInfo("MAIN");}
&Proceso;
&Fin;
exit 0;
}
#****************************************************************************************
sub Proceso
{
printInfo("Proceso");
open ( UPLOADFILE, ">$upload_dir/$filename" ) or  Error(2,"Tainted $upload_dir","$!");;
binmode UPLOADFILE;
while ( <$upload_filehandle> )
{
	print UPLOADFILE;
}
close UPLOADFILE;
printInfo("File uploaded and written - Proceso");
DZI_creation();
html_examples();
return;
}
sub html_examples
{
printInfo("Parsing example - Proceso");
printInfo("Example parsed - Proceso");
return;
}
sub DZI_creation
{
	printInfo("generate - DZI_creation started - Proceso");
	$t0 = [gettimeofday]; #start time profiler
	# Create the tiles
	#Parameters
	#Image, path ,.dzi name, output format, tilesize, overlap, width, height, zipped output, reason, progress(fine/coarse)
	my $image = new Image::Magick;
	$image->Read("$upload_dir/$filename");
	my $tempImage = $image->Clone();
	my $croppedImage = $tempImage->Clone();
	my ($width, $height) = $image->Get('width', 'height');#Get dimensions of the image.
	my $maxDimension = ($width, $height)[$width < $height]; #Get the larger side
	#Create DZI and Json info
	my $dziStr = "<?xml version='1.0' encoding='UTF-8'?><Image xmlns='http://schemas.microsoft.com/deepzoom/2008' Format='jpg' Overlap='$overlap' TileSize='$tilesize' ><Size Height='$height' Width='$width' /></Image>";
	my $jsonStr = "{Image: {xmlns: 'http://schemas.microsoft.com/deepzoom/2008', Format: 'jpg', Overlap: $overlap, TileSize: $tilesize, Size: { Width: $width , Height: $height } }}";
	printFile("$upload_dir/$filename.dzi",">",$dziStr);
	printFile("$upload_dir/$filename.json",">",$jsonStr);
	#Calculate resize steps. Bassically calculate how many times we need to elevate 2 to get the goal size.
	my $stepsmax = int((log($maxDimension)/log(2)) + 1);

	my $tempX = $width;
	my $tempY = $height;
	my $steps = $stepsmax;
	my $stepsX = 0;
	my $stepsY = 0;
	my $j = 0;
	my $k = 0;
	my $X1 = 0;
	my $Y1 = 0;
	my $stro = "";
	for (my $i = 0; $i <= $stepsmax; $i++)
	{
		#Create a clone to use as a temp image.
		$tempImage = $image->Clone();
		#First step no resize.
		if ($steps == $stepsmax)
		{
			printInfo("First Step:  $steps  \n");
			($width, $height) = $image->Get('width', 'height');
			$stepsX = int(($width/$tilesize));
			$stepsY = int(($height/$tilesize));
			printInfo("First dimensions.Tilesize: $tilesize TempX: $tempX X: $width Y: $height\n");
		}
		else #Resize the temp image
		{
			printInfo("Next Steps: $steps\n");
			$tempX = int(ceil($tempX / 2));
			$tempY = int(ceil($tempY / 2));
			$tempImage->Scale(width=>$tempX, height=>$tempY);
			($width, $height) = $tempImage->Get('width', 'height');
			$stepsX = int(($width/$tilesize));
			$stepsY = int(($height/$tilesize));
			printInfo("$sessid $filename Next dimensions. TempX: $tempX X: $width Y: $height\n");
		}
		#while cropped width > tilesize
		for ($j = 0; $j <= $stepsX; $j++)
		{
			$X1=($tilesize*$j)-($overlap*$j);
			for ($k = 0; $k <= $stepsY; $k++)
			{
				if (-e "$upload_dir/$filename\_files/$steps/$j\_$k.jpg")
				{
					print "$upload_dir/$filename\_files/$steps/$j\_$k.jpg already Exists";
					printFile("$pingfile", ">", "$sessid:$i:$stepsmax\n");
				}
				else
				{
			#Create a clone of the resized clone to use as a temp image for every crop done.
					$Y1=($tilesize*$k)-($overlap*$k);
					$croppedImage = $tempImage->Clone();
					$croppedImage->Crop(width=>$tilesize,height=>$tilesize,x=>$X1,y=>$Y1);
					($width, $height) = $croppedImage->Get('width', 'height');
					make_path("$upload_dir/$filename\_files/$steps");
					$croppedImage->Write(filename=>"$upload_dir/$filename\_files/$steps/$j\_$k.jpg", compression => 'JPEG', quality => '85');
					$stro = "File: $filename step: $i $steps $stepsmax stepX: $j $stepsX StepY: $k $stepsY X1: $X1 Y1: $Y1 cropped width: $width cropped height: $height\n";
					printInfo("$sessid $filename $stro");
					printFile("$pingfile", ">", "$sessid:$i:$stepsmax\n");
				}
			}
		}
	$steps--;
	}
	$elapsed = tv_interval ($t0); #Finish profiling
	my @dateandtime = Datetime();
	printFile("upload.log.txt",">>","@dateandtime DZI_creation ended - Proceso. Time to complete: $elapsed.\n");
return;
}
sub Untantizeme
{
my ($fichero) = @_;
	if ($fichero =~ /^([-\@\w.]+)$/)
	{
		$fichero = $1; 			# $data now untainted
	} else
	{
		 Error(0,"Tainted $fichero","$!"); 	# log this somewhere
	}	
return $fichero;
}
#****************************************************************************************
sub Fin
{
my ($Mensaje, $Parametro) = @_;
if ($log_info eq "false")
{
	$log_info = "true";
	printInfo("Fin");
	$log_info = "false";
}
else {printInfo("Fin");}
print "<HTML><HEAD><TITLE></TITLE>"; 
print print "</HEAD><BODY BGCOLOR='#FFFFFF' TEXT='#000000' LINK='#ff80ff' VLINK='#ff80ff' ALINK='#ff80ff'>Proceso finalizado</BODY></HTML>"; 
exit 0;
}
#*******************************************************************************

sub Error
{
my ($criticidad, $Mensaje, $Parametro) = @_;
my @dateandtime = Datetime();
	printInfo("Error - $Mensaje, $Parametro");
	print "Content-type: text/html\n\n";
	print "<HTML><HEAD><TITLE>$Mensaje</TITLE>";
	print "</HEAD><BODY BGCOLOR='#FFFFFF' TEXT='#000000' LINK='#ff80ff' VLINK='#ff80ff' ALINK='#ff80ff'>$dateandtime[0] - $dateandtime[1]<br />Ha habido un error, $Mensaje: $Parametro.</BODY></HTML>"; 
	if ($criticidad > 0){exit 0;}
	else {return;}
}

sub Datetime
{
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
my $Ano  = $year + 1900;
my $Mes = $mon + 1;
my $Dia = $mday;
my $Decimal;
for ($Decimal = 0 ; $Decimal < 10 ;$Decimal++)
	{
	if ($mday eq "$Decimal") {$Dia = join("","0",$mday);}
	if ($Mes eq "$Decimal") {$Mes = join("","0",$Mes);}
	}
my $Fecha = join ("\/",$Ano,$Mes,$Dia);
my $Hora = join (":",$hour,$min,$sec);
if ($Fecha eq ""){$Fecha = "50000000";}
my @dateandtime = ($Fecha,$Hora);
return @dateandtime;
}
sub printFile
{
my ($fileName, $mode, $fileContents) = @_;
open (FILE,"$mode$fileName") || Error(1,"can't open $filename","$!");
	print FILE $fileContents;
close (FILE);
return;
}
sub printInfo
{
my ($Mensaje) = @_;
my @dateandtime = Datetime();
if ($debug_info eq "true")
	{
	print "$dateandtime[0] - $dateandtime[1] - $ENV{'HTTP_REFERER'} - $filename - $filesize_real - $sessid - $Mensaje\n<BR/>";
	}
if ($log_info eq "true")
	{
	open (LOG,'>>upload.log.txt') || Error(1,"can't open >>upload.log.txt","$!");
		print LOG "$dateandtime[0] - $dateandtime[1] - $ENV{'HTTP_REFERER'} - $filename - $filesize_real - $sessid - $Mensaje\n";
	close (LOG);
	}
return;
}
