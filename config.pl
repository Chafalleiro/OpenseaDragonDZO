#!/usr/bin/perl -w
#****************************************************************************************
#Perl DZO configurator v.01
#Part of the OpenSeadragon DZI online composer utils.
#Alfonso Abelenda Escudero, chafalladas.com. (c) 2016 license BSD-type 2.
#Error control
use strict;
use warnings;
use Cwd;
use CGI qw{ :standard };
use CGI::Carp qw ( fatalsToBrowser );
use File::Basename;
use File::Path qw(make_path);
use File::Copy;
use File::Copy::Recursive qw(dircopy);
#****************************************************************************************
my $query = new CGI;
#default JSON data.
my $JSONData = "var data={'dirs':[{'selDir':'architecture','selNam':'Architecture pics'},{'selDir':'arts','selNam':'Art pics'},{'selDir':'food','selNam':'Food pics'},{'selDir':'funny','selNam':'Funny pics'},{'selDir':'nature','selNam':'Nature pics'},{'selDir':'people','selNam':'People pics'},{'selDir':'transportation','selNam':'Transportation pics'}]}";
$JSONData = $query->param("JSONData");
my $optionData = $query->param("optionData");
my @optionArray = split(/\n/,$query->param("optionArray"));
my $usrID = $query->param("usrID");
chomp(my $psswd = $query->param("psswd"));
my $bsURL = $query->param("bsURL");
my $cwd = getcwd();
my @perlfiles = ("dzi_maker.pl","dzo_composer.pl","ping.pl","zipper.pl"); #It recomended to chown cleanup.sh to root if you plan to use it as a cron task or delete it if you dont plan to use it
my @otherlfiles = ("cleanup.sh",".htaccess","install.html","index.html","template.html","license.txt","openseadragon_license.txt","dirs.json","vardirs.json","dzo_creator_php.html","dzo_composer.php","dzo_composer_gd.php","ping.php","zipper.php","readme_php_version.txt","dzo_creator_perl.html","dzo_composer.pl","readme_Perl.txt","background.jpg","chafalladas_plain.svg","pantallazo.jpg","perlcamel.jpg","php-med-trans.png","openseadragon.min.js");
my $file = "";
my $httpauthstr = "RewriteEngine On\nRewriteCond %{HTTPS} !=on\nRewriteRule ^/?(.*) https://%{SERVER_NAME}%{REQUEST_URI} [R,L]\nAuthName \"Protected Folder\"\nAuthType Basic\nAuthUserFile $cwd\/.htpasswd\nRequire valid-user\n\<files ~ \"^\.ht\">\nOrder allow,deny\nDeny from all\n</files>\n";
my $httpasswd = "user:\$apr1\$gbLA4g1g\$5eOmsmO4w75nGVMSq2C6J0"; # "user:password"
my $mode = 0644;
#****************************************************************************************
MAIN:
{
print "Content-type: text/html\n\n";
#Make dirs
	my @dirs = "";
	my $dirs = "";
	foreach $dirs (@optionArray)
	{
		@dirs = split(/;/,$dirs);
		if (!-e $dirs[0]){Make_dirs($dirs[0]);}
		else{Error(0,"Directory already exists $dirs[0]. ","making path\n");}
	}
#Make users
	if ($psswd ne "")
	{
		printInfo("Making $psswd password files\n");
		$psswd = crypt($psswd,"chain");
		printInfo("Crypted $psswd password files\n");
		printFile(".htpasswd", ">", "$usrID:$psswd\n");#subtitute ">" by ">>" to add new users instead replacing the existent
		printInfo("Made password files\n");
	}
#Modify and copy files
	#Make an .htaccess file for the app. It will redirect to https protocol, block file downloads and password protect the dir.
	#Not a hell of security, but enough for most sites. If there is another htaccess file it will not be overwritten.
	#It is recommended that you update the existing file adding the directives of this one.
	if(!-e ".htaccess")
	{
		printFile(".htaccess",">",$httpauthstr);
		chmod $mode, ".htaccess";
		printInfo("Made apache config files\n");
	}
	if(!-e "../openseadragon")
	{
		Make_dirs("../openseadragon");
		copy("openseadragon_license.txt","../openseadragon/openseadragon_license.txt") or Error(0,"Can't copy license.", $!);
		copy("openseadragon.min.js","../openseadragon/openseadragon.min.js") or Error(0,"Can't copy openseadragon.", $!);
		dircopy("images","../openseadragon/images") or Error(0,"Can't copy DIR images.", $!);
	}
	Template_subs("dzo_TEMPLATE_perl.html","dzo_creator_perl.html");
	Template_subs("dzo_TEMPLATE_php.html","dzo_creator_php.html");
	#Update or create the data files. They have the dir tree for the galleries.
	printFile("vardirs.json",">",$JSONData);
	chmod $mode, "vardirs.json";
	printInfo("Saved JSON data\n");
#Set permissions
	#perl scripts must have 0755 permissions, the rest 0644, so start putting all files at 0644.
	foreach $file (@otherlfiles)
		{
			chmod $mode, "$file" || Error(0,"Can't change permissions of $file to $mode.", $!);
		}
		$mode = 0755;
	foreach $file (@perlfiles)
		{
			chmod $mode, "$file" || Error(0,"Can't change permissions of $file to $mode. ", $!);
		}
	exit 0;
}
#****************************************************************************************
sub Template_subs
{
my ($template,$filedest) = @_;
my @Plantilla;
my $Plantilla;
open (PLANTILLA, "$template");
	@Plantilla = <PLANTILLA>;
close (PLANTILLA);
foreach $Plantilla (@Plantilla)
	{
	$Plantilla =~s/DIROPTIONSDIROPTIONS/$optionData/g;
	$Plantilla =~s/BASEURLBASEURL/$bsURL/g;
	}
open (FICH, ">$filedest") or die Error(0,"Grabando $filedest. ", "$!");
	print FICH @Plantilla;
close (FICH);
return;
}
sub Make_dirs
{
my ($dir) = @_;
	make_path("$dir", {error => \my $err});
	if (@$err) {
		for my $diag (@$err)
		{
			my ($dir, $message) = %$diag;
			if ($dir eq '')
			{
				print "general error: $message\n";
				Error(0,"general error: $message","making path\n");
			}
			else
			{
				print "problem making path $dir\n";
				Error(0,"problem making path $dir","making path\n");
			}
		}
	}
	else
	{
		printInfo("No error encountered making $dir\n");
	}
return;
}
#****************************************************************************************
sub printFile
{
my ($fileName, $mode, $fileContents) = @_;
	open (FILE,"$mode$fileName") || die Error(2, "Can't open $fileName", "In printFile $mode$fileName");
		print FILE $fileContents;
	close (FILE);
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
	print "$dateandtime[0] - $dateandtime[1] - $ENV{'HTTP_REFERER'} - $Mensaje\n<BR/>";
	printFile("upload.log.txt", ">>", "$dateandtime[0] - $dateandtime[1] - $ENV{'HTTP_REFERER'} - $Mensaje\n");
return;
}
