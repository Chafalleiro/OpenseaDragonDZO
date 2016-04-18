<?php
//PHP DZO configurator v.01
//Part of the OpenSeadragon DZI online composer utils.
//Alfonso Abelenda Escudero, chafalladas.com. (c) 2016 license BSD-type 2.
//It lacks functions and a proper structure since I was learning how to use PHP.
//But it does the job for the good local people.
//Error control
global $debug_info, $log_info, $sessid;
function prof_flag($str)
{
    global $prof_timing, $prof_names, $sessid;
    $prof_timing[] = microtime(true);
    $prof_names[] = $str;
}
function prof_print()
{
    global $prof_timing, $prof_names, $sessid;
    $size = count($prof_timing);
    for($i=0;$i<$size - 1; $i++)
    {
		FilePrint("log_dzo.txt", "",date(DATE_RFC2822) . " " . $sessid . " " . $target_file .  $prof_names[$i] . ": ","a+", true);
		FilePrint("log_dzo.txt", "", sprintf("%f\n", $prof_timing[$i+1]-$prof_timing[$i]),"a+", true);
    }
}
prof_flag("Error Handling");
function myErrorHandler($errno, $errstr, $errfile, $errline)
{
global $sessid;
//Take care of known warning so they don't get logged
$myWarns = array("Undefined variable: tileSize","File exists");
foreach ($myWarns as $warn){$pos = strpos($errstr, $warn);$warn = $warn + $pos;}
if($warn !== false)
{
	return;
}
else
{
    switch ($errno)
	{
    case E_USER_ERROR:
        echo "<b>My ERROR</b> [$errno] $errstr<br />\n";
        echo "  Fatal error on line $errline in file $errfile";
        echo ", PHP " . PHP_VERSION . " (" . PHP_OS . ")<br />\n";
        echo "Aborting...<br />\n";
		FilePrint("log_dzo.txt", "",date(DATE_RFC2822) . " " . $sessid . " " . $target_file .  "My ERROR</b> [$errno] $errstr at $errline in $errfile\n","a+", true);
        exit(1);
        break;
    case E_USER_WARNING:
        echo "My WARNING</b> [$errno] $errstr<br />\n";
		FilePrint("log_dzo.txt", "",date(DATE_RFC2822) . " " . $sessid . " " . $target_file .  "My WARNING</b> [$errno] $errstr at $errline in $errfile\n","a+", true);
        break;
    case E_WARNING:
        echo "<b>My WARNING</b> [$errno] $errstr<br />\n";
		FilePrint("log_dzo.txt", "",date(DATE_RFC2822) . " " . $sessid . " " . $target_file .  "My WARNING</b> [$errno] $errstr at $errline in $errfile\n","a+", true);
        break;
    case E_USER_NOTICE:
        echo "<b>My NOTICE</b> [$errno] $errstr<br />\n";
		FilePrint("log_dzo.txt", "",date(DATE_RFC2822) . " " . $sessid . " " . $target_file .  "My NOTICE</b> [$errno] $errstr at $errline in $errfile\n","a+", true);
        break;
    default:
        echo "Unknown error type: [$errno] $errstr<br />\n";
		FilePrint("log_dzo.txt", "",date(DATE_RFC2822) . " " . $sessid . " " . $target_file .  "Unknown error type: [$errno] $errstr at $errline in $errfile\n","a+", true);
        break;
    }
    /* Don't execute PHP internal error handler */
    return true;
}
}
$old_error_handler = set_error_handler("myErrorHandler",E_ALL | E_WARNING);
//Error control

$JSONData = $_POST['JSONData'];
$optionData = $_POST['optionData'];
$optionArray = explode("\n",$_POST['optionArray']);
$usrID = $_POST['usrID'];
$psswd = $_POST['psswd'];
$bsURL = $_POST['bsURL'];
$perlfiles = array("dzi_maker.pl","dzo_composer.pl","ping.pl","zipper.pl","config.pl"); #It recomended to chown cleanup.sh to root if you plan to use it as a cron task or delete it if you dont plan to use it
$otherfiles = array("cleanup.sh",".htaccess","install.html","index.html","template.html","license.txt","openseadragon_license.txt","dirs.json","vardirs.json","dzo_creator_php.html","dzo_composer.php","dzo_composer_gd.php","ping.php","zipper.php","readme_php_version.txt","dzo_creator_perl.html","dzo_composer.pl","readme_Perl.txt","background.jpg","chafalladas_plain.svg","pantallazo.jpg","perlcamel.jpg","php-med-trans.png","openseadragon.min.js");
$file = "";
$httpauthstr = "RewriteEngine On\nRewriteCond %{HTTPS} !=on\nRewriteRule ^/?(.*) https://%{SERVER_NAME}%{REQUEST_URI} [R,L]\nAuthName \"Protected Folder\"\nAuthType Basic\nAuthUserFile " . getcwd() . "/.htpasswd\nRequire valid-user\n<files ~ \"^\.ht\">\nOrder allow,deny\nDeny from all\n</files>\n";
$httpasswd = "user:\$apr1\$gbLA4g1g\$5eOmsmO4w75nGVMSq2C6J0"; # "user:password"
$mode = 0644;
#Make dirs
//
foreach ($optionArray as $option)
	{
		$option = explode(";",$option); #Array with file names.
		if ($option[0])
		{
			mkdir($option[0], 0755) || FilePrint("log_dzo.txt", "", date(DATE_RFC2822) . " " . $option[0] . " Error creating\n","a+", true);
			FilePrint("log_dzo.txt", "", date(DATE_RFC2822) . " " . $option[0] . " Dir made\n","a+", true);
		}
		
	}
#Make users
	if ($psswd != "")
	{
		$psswd = crypt($psswd,base64_encode($psswd));
		FilePrint(".htpasswd", "", $usrID . ":" . $psswd . "\n","w", true); #subtitute "w" by "a+" to add new users instead replacing the existent
		FilePrint("log_dzo.txt", "", date(DATE_RFC2822) . " Made password files\n","a+", true);
	}
#Copy files
	#Make an .htaccess file for the app. It will redirect to https protocol, block file downloads and password protect the dir.
	#Not a hell of security, but enough for most sites. If there is another htaccess file it will not be overwritten.
	#It is recommended that you update the existing file adding the directives of this one.
	if (!file_exists(".htaccess"))
	{
		FilePrint(".htaccess", "", $httpauthstr ,"w", true); #subtitute "w" by "a+" to add new users instead replacing the existent
		chmod(".htaccess", $mode);  // octal; correct value of mode
		FilePrint("log_dzo.txt", "", date(DATE_RFC2822) . " Made apache config files\n","a+", true);
	}
	if (!file_exists("../openseadragon"))
	{
		mkdir("../openseadragon", 0755);
		copy("openseadragon_license.txt","../openseadragon/openseadragon_license.txt");
		copy("openseadragon.min.js","../openseadragon/openseadragon.min.js");
		recurse_copy("images","../openseadragon/images");
		FilePrint("log_dzo.txt", "", date(DATE_RFC2822) . " Makig openseadragon dir\n","a+", true);
	}
	$Plantilla = file_get_contents('dzo_TEMPLATE_perl.html');
	$Plantilla = str_replace("DIROPTIONSDIROPTIONS", $optionData, $Plantilla);
	$Plantilla = str_replace("BASEURLBASEURL", $bsURL, $Plantilla);
	file_put_contents('dzo_creator_perl.html', $Plantilla);
	$Plantilla = file_get_contents('dzo_TEMPLATE_php.html');
	$Plantilla = str_replace("DIROPTIONSDIROPTIONS", $optionData, $Plantilla);
	$Plantilla = str_replace("BASEURLBASEURL", $bsURL, $Plantilla);
	file_put_contents('dzo_creator_php.html', $Plantilla);
		FilePrint("log_dzo.txt", "", date(DATE_RFC2822) . " Made HTML\n","a+", true);
	#Update or create the data files. They have the dir tree for the galleries.
	FilePrint("vardirs.json", "", $JSONData, "w", true);
	FilePrint("log_dzo.txt", "", date(DATE_RFC2822) . " Printed JSON with " . $JSONData . "\n","a+", true);
#Set permissions
	#perl scripts must have 0755 permissions, the rest 0644, so start putting all files at 0644.
foreach ($otherfiles as $file)
		{
			chmod($file, $mode);  // octal; correct value of mode
		}
		$mode = 0755;
foreach ($perlfiles as $file)
		{
			chmod($file, $mode);  // octal; correct value of mode
		}
FilePrint("log_dzo.txt", "", date(DATE_RFC2822) . " Changed permissions\n","a+", true);
function FilePrint($file,$ext,$string,$mode,$mandatory)
{
global $debug_info, $log_info;
	if ($debug_info == "true"){echo $string;}
	if ($log_info == "true" || $mandatory == true)
	{
		$fp = fopen($file . $ext, $mode);
		fwrite($fp, $string);
		fclose($fp);
	}	
}
//http://php.net/manual/en/function.copy.php#91010
function recurse_copy($src,$dst) { 
    $dir = opendir($src); 
    @mkdir($dst); 
    while(false !== ( $file = readdir($dir)) ) { 
        if (( $file != '.' ) && ( $file != '..' )) { 
            if ( is_dir($src . '/' . $file) ) { 
                recurse_copy($src . '/' . $file,$dst . '/' . $file); 
            } 
            else { 
                copy($src . '/' . $file,$dst . '/' . $file); 
            } 
        } 
    } 
    closedir($dir); 
} 
?>