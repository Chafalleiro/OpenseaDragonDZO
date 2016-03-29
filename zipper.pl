#!/usr/bin/perl -wTU
#****************************************************************************************
#Archiver and cleaner for the OpenSeadragon DZI online composer Perl version. v.02
#Part of the OpenSeadragon DZI online composer utils.
#Alfonso Abelenda Escudero, chafalladas.com. (c) 2016 license BSD-type 2.
#Needs some cleaning.
use strict;
use warnings;
#use Carp;
use CGI qw{ :standard };
use CGI::Carp qw( fatalsToBrowser );
use File::Basename;
use File::Path qw(make_path remove_tree);
use Error qw(:try);
use Archive::Zip qw(:CONSTANTS :ERROR_CODES);
#****************************************************************************************
my $divisor = "#****************************************************************************************";
my $query = new CGI;
my $safe_filename_characters = "a-zA-Z0-9_.-";
my $upload_dir = $query->param("upload_dir"); #Using precreated dirs, tiles and info will be created under this dir.
	$upload_dir =~  m/^([a-zA-Z0-9\._\/\-]+)$/ or Error(0,"Tainted $upload_dir",$!);
	$upload_dir = $1;
my $prefix = "images";
my @Plantilla = ();
my $Plantilla = "";
my $namearray = "";
my $sessid = $query->param("sessid"); #Session identificator
	$sessid =~  m/^([a-zA-Z0-9\._]+)$/ or Error(0,"Tainted $sessid",$!);
my $zipName = "$1.zip";	
my $debug_info = $query->param("debug_info"); #Pass debug info to the referrer.
my $log_info = $query->param("log_info"); #Pass log info to the referrer.
my $del_info = $query->param("del_info"); #Must temp files be deleted now?
my $bg_color = $query->param("bg_color"); #Background color info
my $tilesources = $query->param("tilesources"); #Tilesources list
my $mynamlist = $query->param("mynamlist"); #List of file names.
my $myseslist = $query->param("myseslist"); #List of sessions.
my $sequenceDisplay = $query->param("sequenceDisplay"); #Multi image display type.
my $EmbedCCSTop = $query->param("EmbedCCSTop");
my $EmbedCCSBottom = $query->param("EmbedCCSBottom");
my $EmbedDiv = $query->param("EmbedDiv");
my $EmbedIframe = $query->param("EmbedIframe");
my $EmbedWP = $query->param("EmbedWP");
my @namearray = split(/\+/,$mynamlist); #Array with file names.
my @sessarray = split(/\+/,$myseslist); #Array with sessions.
#****************************************************************************************
MAIN:
{
print "Content-type: text/html\n\n";
if ($log_info eq "false")
{
	$log_info = "true";
	printInfo("MAIN - Started.");
	$log_info = "false";
}
&Proceso;
&Fin;
exit 0;
}
#****************************************************************************************
sub Proceso
{
printInfo("Proceso");
abrefich("template.html");
foreach $Plantilla (@Plantilla)
	{
	$Plantilla =~s/TITLEJUSTTITLE/@namearray/g;
	$Plantilla =~s/TITLEOFTHEPAGE/@namearray/g;
	$Plantilla =~s/DESCRIPTIONDESCRIPTION/@namearray/g;
	$Plantilla =~s/DESCRIPTIONDESCRIPTION/@namearray/g;
	$Plantilla =~s/PREFIXURLPREFIXURL/$prefix/g;
	$Plantilla =~s/TILESOURCESTILESOURCES/$tilesources/g;
	$Plantilla =~s/SEQUENCEDISPLAYSEQUENCEDYSPLAY/$sequenceDisplay/g;
	$Plantilla =~s/BGCOLORBGCOLOR/$bg_color/g;
	}
print @Plantilla;
Grabar("$sessid.html");
printFile("./$upload_dir/$sessid\_embeds.txt",">>","$divisor Script Top\n$EmbedCCSTop\n$divisor Script Bottom\n$EmbedCCSBottom\n$divisor Div\n$EmbedDiv\n$divisor Iframe\n$EmbedIframe\n$divisor WP code\n$EmbedWP");
printInfo("Proceso - html grabado");
my $zip = Archive::Zip->new();
my $i = 0;
my $myzipdir = "";
my $myzipimg = "";
my $myzipses = "";
my $myziphtm = "";
my $myzipDZI = "";
my $myzipJSON = "";
my $myzipEmbed = "";
my $myimgdir = "images";
my $openseadragonmin = "openseadragon.min.js";
my $openseadragonlicense = "openseadragon_license.txt";
my $flnm = "";
my $sssnm = "";
foreach $namearray (@namearray)
{
$namearray[$i] =~  m/^([a-zA-Z0-9\._\-]+)$/ or Error(0,"Tainted $namearray[$i]",$!);
$flnm = "$1";	
$sessarray[$i] =~  m/^([a-zA-Z0-9\._\-]+)$/ or Error(0,"Tainted $sessarray[$i]",$!);
$sssnm = "$1";	
	$myzipimg = "./$upload_dir/$flnm";
	$myzipDZI = "./$upload_dir/$flnm.dzi";
	$myzipJSON = "./$upload_dir/$flnm.json";
	$myzipdir = "./$upload_dir/$flnm\_files";
	$myzipdir =~  m/^([a-zA-Z0-9\._\/\-]+)$/ or Error(0,"Tainted $myzipdir",$!);
	$myzipdir = "$1";	
	if ( ( -r $myzipimg ) && ( ( -f $myzipimg ) || ( -l $myzipimg ) ) ){
		#add to zip
		}
	else{
		print "$myzipimg is not a readable valid file id\n"
	}	
	$zip->addFile($myzipimg) or die Error(0,"Can't add file $myzipimg","$!\n");
	printInfo("Proceso -  zipping $myzipimg - IMG");
	$zip->addFile($myzipDZI) or die Error(0,"Can't add file $myzipDZI","$!\n");
	printInfo("Proceso -  zipping $myzipDZI - DZI");
	$zip->addFile($myzipJSON) or Error(0,"Can't add file $myzipJSON","$!\n");
	printInfo("Proceso -  zipping $myzipJSON - JSON");
	$zip->addTree("$myzipdir/", "$myzipdir/");
	printInfo("Proceso -  zipping $myzipdir - DIR");
}
	my $sessid = $query->param("sessid"); #Session identificator
		$sessid =~  m/^([a-zA-Z0-9\._]+)$/ or  Error(0, "Tainted $sessid","$!\n");
	$myziphtm = "$1.html";
	$zip->addFile($myziphtm) or Error(0, "Can't add file $myziphtm","$!\n");
	printInfo("Proceso -  zipping $myziphtm - HTML");
	$myzipEmbed = "./$upload_dir/$sessid\_embeds.txt";
	$zip->addFile($myzipEmbed) or Error(0, "Can't add file $myziphtm", "$!\n");
	$zip->addFile($openseadragonmin) or Error(0, "Can't add file $openseadragonmin", "$!\n");
	printInfo("Proceso -  zipping $openseadragonmin - OpenSeadragon");
	$zip->addFile($openseadragonlicense) or Error(0, "Can't add file $openseadragonlicense", "$!\n");
	printInfo("Proceso -  zipping $openseadragonlicense - License");
	$zip->addTree("$myimgdir/", "$myimgdir/");
	printInfo("Proceso -  zipping $myimgdir - DirImg");
	$zip->writeToFileNamed($zipName);# or die Error("Can't create zipfile $zipName\n",$!);
	if ($log_info eq "false")
	{
	$log_info = "true";
	printInfo("Proceso - $zipName ended");
	$log_info = "false";
	}
	else{printInfo("Proceso - $zipName ended");}
return;
}
#****************************************************************************************
sub Fin
{
printInfo("Fin");
#Cleanup logs, images and dirs.
my $filedel = "";
if ($del_info eq "true")
	{
	printInfo("Fin - Delete");
#delete logs
	if($log_info eq "true")
		{
		DeleteFiles("",".log",@sessarray);
		}
	DeleteFiles("" , ".html", $sessid);
	if ($log_info eq "false")
		{
		$log_info = "true";
		printInfo("Fin - Deleted uploaded files.");
		$log_info = "false";
		}
	else{printInfo("Fin - Deleted uploaded files.");}
#delete images
	DeleteFiles("$upload_dir/" , "", @namearray);
	}	
	if ($log_info eq "false")
	{
	$log_info = "true";
	printInfo("Fin.");
	$log_info = "false";
	}
	else{printInfo("Fin.");}
}
#****************************************************************************************
sub DeleteFiles()
{
my ($mydir, $myext, @goners) = @_;
my $file;
printInfo("deleting files with Dir: $mydir, Ext: $myext\n");

foreach $file ( @goners )
{
	$file =~  m/^([a-zA-Z0-9\._\-]+)$/ or Error(0, "Tainted $file", "$!");
	$file = "$mydir$1$myext";	
	printInfo("Fin - deleting $file from @goners");
	unlink $file or die Error("Could not unlink $file: $! from @goners");
}
return;
}

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
sub printInfo
{
my ($Mensaje) = @_;
my @dateandtime = Datetime();
if ($debug_info eq "true")
	{
	print "$dateandtime[0] - $dateandtime[1] - $ENV{'HTTP_REFERER'} - $sessid - $Mensaje\n<BR/>";
	}
if ($log_info eq "true")
	{
	open (LOG,'>>upload.log.txt') || die;
		print LOG "$dateandtime[0] - $dateandtime[1] - $ENV{'HTTP_REFERER'} - $sessid - $Mensaje\n";
	close (LOG);
	}
return;
}

sub abrefich
{
my ($fichero) = @_;
open (PLANTILLA, "$fichero");
@Plantilla = <PLANTILLA>;
close (PLANTILLA);
return;
}
sub Grabar{
my ($fichero) = @_;
	if ($fichero =~ /^([-\@\w.]+)$/)
	{
		$fichero = $1; 			# $data now untainted
	} else
	{
		die Error("Bad data in '$fichero'"); 	# log this somewhere
	}
open (FICH, ">$fichero") or die Error("Grabando $fichero", "$!");
	print FICH @Plantilla;
close (FICH);
return;
}
sub printFile
{
my ($fileName, $mode, $fileContents) = @_;
	if ($fileName =~ /^([-\@\w.\_\/]+)$/)
	{
		$fileName = $1; 			# $data now untainted
	} else
	{
		die myError("Bad data in '$fileName'"); 	# log this somewhere
	}

open (FILE,"$mode$fileName") || die myError("Can't open $fileName");
	print FILE $fileContents;
close (FILE);
return;
}