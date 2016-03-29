#!/usr/bin/perl -wT
#****************************************************************************************
use strict;
use warnings;
use CGI qw{ :standard };
use CGI::Carp qw ( fatalsToBrowser );
use File::Basename;
use Graphics::DZI::Files;
use Image::Magick;
use Log::Log4perl qw(:easy);
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
#****************************************************************************************
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
&Inicio;
&Proceso;
&Fin;
exit 0;
}
#****************************************************************************************
sub Inicio
{
printInfo("Inicio");
return;
}
#****************************************************************************************
sub Proceso
{
printInfo("Proceso");
open ( UPLOADFILE, ">$upload_dir/$filename" ) or die "Error($!)";
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
	printInfo("DZI_creation started - Proceso");
	$t0 = [gettimeofday];
	if ($debug_info eq "true")
	{
		#Maybe a hook of the CGI here could be a good solution to the DZI composing progress bar.
		#Or maybe defining the logfile with the sessid and parsing the tiles written.
		Log::Log4perl->easy_init( { level   => $DEBUG, file    => "STDOUT" } );
	}
#	if ($log_info eq "true")
#	{
	my $filelog = Untantizeme("$sessid.log");
	if ($filelog =~ /^([-\@\w.]+)$/)
	{
		$filelog = $1; 			# $data now untainted
	} else
	{
		die Error("Bad data in '$filelog'"); 	# log this somewhere
	}	
		Log::Log4perl->easy_init( { level => $DEBUG, file => "$filelog" } );
#	}
	my $image = new Image::Magick;
	$image->Read("$upload_dir/$filename");
	my ($width, $height) = $image->Get('width', 'height');
	printInfo("Image::Magick object done - DZI_creation started - Proceso");
	my $dzi = new Graphics::DZI::Files (image => $image, overlap  => $overlap, tilesize => $tilesize, format => "jpg", compression => 'JPEG', quality => '70', dzi => "$upload_dir/$filename.dzi") or die Error("Error in tiling $!");
	printInfo("generate - DZI_creation started - Proceso");
	my $jsonStr = "{Image: {xmlns: 'http://schemas.microsoft.com/deepzoom/2008', Format: 'jpg', Overlap: $overlap, TileSize: $tilesize, Size: { Width: $width , Height: $height } }}";
	printFile("$upload_dir/$filename.json", ">" ,$jsonStr);
	$dzi->generate ();
	$elapsed = tv_interval ($t0);
	if ($log_info eq "false")
	{
		$log_info = "true";
		printInfo("DZI_creation ended - Proceso. Time to complete: $elapsed.");
	$log_info = "false";
	}
	else{printInfo("DZI_creation ended - Proceso. Time to complete: $elapsed.");}
		
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
		die Error("Bad data in '$fichero'"); 	# log this somewhere
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
my ($Mensaje, $Parametro) = @_;
my @dateandtime = Datetime();
$log_info = "true";
printInfo("Error - $Mensaje, $Parametro");
print "Content-type: text/html\n\n";
print "<HTML><HEAD><TITLE>$Mensaje</TITLE>";
print "</HEAD><BODY BGCOLOR='#FFFFFF' TEXT='#000000' LINK='#ff80ff' VLINK='#ff80ff' ALINK='#ff80ff'>$dateandtime[0] - $dateandtime[1]<br />Ha habido un error, $Mensaje: $Parametro.</BODY></HTML>"; 
exit 0; 
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
open (FILE,"$mode$fileName") || die Error("Can't open $fileName");
	print FILE $fileContents;
close (FILE);

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
	open (LOG,'>>upload.log.txt') || die;
		print LOG "$dateandtime[0] - $dateandtime[1] - $ENV{'HTTP_REFERER'} - $filename - $filesize_real - $sessid - $Mensaje\n";
	close (LOG);
	}
return;
}