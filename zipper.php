<?php
//Archiver and cleaner for the OpenSeadragon DZI online composer PHP version. v.01
//Part of the OpenSeadragon DZI online composer utils.
//Alfonso Abelenda Escudero, chafalladas.com. (c) 2016 license BSD-type 2.
global $debug_info, $log_info, $sessid;
$prefix = "images";
$upload_dir = $_POST['upload_dir'];
$debug_info = $_POST['debug_info']; #Pass debug info to the referrer.
$log_info = $_POST['log_info']; #Pass log info to the referrer.
$del_info = $_POST['del_info']; #Must temp files be deleted now?
$bg_color = $_POST['bg_color']; #Background color info
$sessid = $_POST['sessid'];
$tilesources = $_POST['tilesources']; #Tilesources list
$mynamlist = $_POST['mynamlist']; #List of file names.
$myseslist = $_POST['myseslist']; #List of sessions.
$sequenceDisplay = $_POST['sequenceDisplay']; #Multi image display type.
$EmbedCCSTop = $_POST['EmbedCCSTop'];
$EmbedCCSBottom = $_POST['EmbedCCSBottom'];
$EmbedDiv = $_POST['EmbedDiv'];
$EmbedIframe = $_POST['EmbedIframe'];
$EmbedWP = $_POST['EmbedWP'];
$namearray = explode("+",$mynamlist); #Array with file names.
$sessarray = explode("+",$myseslist); #Array with sessions.
$openseadragonmin = "openseadragon.min.js";
$openseadragonlicense = "openseadragon_license.txt";
$divisor = "#****************************************************************************************";
function myErrorHandler($errno, $errstr, $errfile, $errline)
{
global $sessid;
//Take care of known warning so they don't get logged
if($errstr == "substr() expects parameter 2 to be long, string given" || $errstr == "readdir() expects parameter 1 to be resource, boolean given")
{
	return;
}
else{
    switch ($errno)
	{
    case E_USER_ERROR:
        echo "<b>My ERROR</b> [$errno] $errstr<br />\n";
        echo "  Fatal error on line $errline in file $errfile";
        echo ", PHP " . PHP_VERSION . " (" . PHP_OS . ")<br />\n";
        echo "Aborting...<br />\n";
		FilePrint("log_dzo.txt", "", date(DATE_RFC2822) . " " . $sessid . " " . $target_file .  "My ERROR</b> [$errno] $errstr at $errline in $errfile\n","a+", true);
        exit(1);
        break;
    case E_USER_WARNING:
        echo "My WARNING</b> [$errno] $errstr<br />\n";
		FilePrint("log_dzo.txt", "", date(DATE_RFC2822) . " " . $sessid . " " . $target_file .  "My WARNING</b> [$errno] $errstr at $errline in $errfile\n","a+", true);
        break;
    case E_WARNING:
        echo "<b>My WARNING</b> [$errno] $errstr<br />\n";
		FilePrint("log_dzo.txt", "", date(DATE_RFC2822) . " " . $sessid . " " . $target_file .  "My WARNING</b> [$errno] $errstr at $errline in $errfile\n","a+", true);
        break;
    case E_USER_NOTICE:
        echo "<b>My NOTICE</b> [$errno] $errstr<br />\n";
		FilePrint("log_dzo.txt", "", date(DATE_RFC2822) . " " . $sessid . " " . $target_file .  "My NOTICE</b> [$errno] $errstr at $errline in $errfile\n","a+", true);
        break;
    default:
        echo "Unknown error type: [$errno] $errstr<br />\n";
		FilePrint("log_dzo.txt", "", date(DATE_RFC2822) . " " . $sessid . " " . $target_file .  "Unknown error type: [$errno] $errstr at $errline in $errfile\n","a+", true);
        break;
    }
    /* Don't execute PHP internal error handler */
}	
    return true;
} 
$old_error_handler = set_error_handler("myErrorHandler",E_ALL | E_WARNING);
//Create the html demo file. Nothing complex, just replace the text in the template.
$Plantilla = file_get_contents('template.html');
$Plantilla=str_replace("TITLEJUSTTITLE", implode(" - ", $namearray), $Plantilla);
$Plantilla=str_replace("TITLEOFTHEPAGE", implode(" - ", $namearray), $Plantilla);
$Plantilla=str_replace("DESCRIPTIONDESCRIPTION", implode(" - ", $namearray), $Plantilla);
$Plantilla=str_replace("PREFIXURLPREFIXURL", $prefix . "/", $Plantilla);
$Plantilla=str_replace("TILESOURCESTILESOURCES", $tilesources, $Plantilla);
$Plantilla=str_replace("SEQUENCEDISPLAYSEQUENCEDYSPLAY", $sequenceDisplay, $Plantilla);
$Plantilla=str_replace("BGCOLORBGCOLOR", $bg_color, $Plantilla);
file_put_contents($sessid . '.html', $Plantilla);
file_put_contents("./$upload_dir/$sessid" . "_embeds.txt", "$divisor Script Top\n$EmbedCCSTop\n$divisor Script Bottom\n$EmbedCCSBottom\n$divisor Div\n$EmbedDiv\n$divisor Iframe\n$EmbedIframe\n$divisor WP code\n$EmbedWP");
FilePrint($sessid, ".txt", $sessid . " HTML file written\n","w", true);
FilePrint("log_dzo.txt", "", date(DATE_RFC2822) . " " . $sessid . ".html. HTML file written\n","a+", true);

//Create the downloadable zip file.
//Prepare the command arguments
//zip -r -v -9 -m Marina.jpg.zip ./files/Marina.jpg_files files/Marina.jpg files/Marina.jpg.dzi files/Marina.jpg.json
$zip = new ZipArchive;
$res = $zip->open($sessid .".zip", ZipArchive::CREATE);
if($res !== TRUE)
{
	echo 'Error: Unable to create zip file';
	exit;
}
//$namearray Array with file names.
//$sessarray Array with sessions.
foreach ($namearray as $name)
{
	//Add JSON files
	$zip->addFile($upload_dir . "/" . $name .".json", $upload_dir. "/" . $name .".json");
	//Add DZI files
	$zip->addFile($upload_dir . "/" . $name .".dzi", $upload_dir. "/" . $name .".dzi");
	//Add Original files
	$zip->addFile($upload_dir . "/" . $name, $upload_dir. "/" . $name);
	//Add DZI folders
	recurse_zip($upload_dir . "/" . $name . "_files", $zip, $upload_dir . "/" . $name . "_files");
}
//Add HTML files
$zip->addFile($sessid .".html", $sessid .".html");
//Add OpenSeaDragon files
$zip->addFile($openseadragonmin);
$zip->addFile($openseadragonlicense);
//Add Directories files
recurse_zip($prefix,$zip,$prefix);
$zip->close();
FilePrint("log_dzo.txt", "", date(DATE_RFC2822) . " " . $sessid . " Zip file written\n","a+", true);
if ($del_info == "true")
{
	//Delete uploaded and temp log files.
	foreach ($namearray as $name)
	{
		//Remove Original files
		delete_files($upload_dir . "/" . $name);
		delete_files($upload_dir . "/" . $name .".json");
	}
	foreach ($sessarray as $sess)
	{
		delete_files($sess .".txt");
	}
	delete_files($sessid .".html");
	delete_files($sessid .".txt");
FilePrint("log_dzo.txt", "", date(DATE_RFC2822) . " " . $sessid . " Temp files deleted\n","a+", true);
}
//Functions:
//Function from http://ramui.com/articles/php-zip-files-and-directory.html
function recurse_zip($src,&$zip,$path_length) {
        $dir = opendir($src);
        while(false !== ( $file = readdir($dir)) ) {
            if (( $file != '.' ) && ( $file != '..' )) {
                if ( is_dir($src . '/' . $file) ) {
                    recurse_zip($src . '/' . $file,$zip,$path_length);
                }
                else {
                    $zip->addFile($src . '/' . $file,substr($src . '/' . $file,$path_length));
                }
            }
        }
        closedir($dir);
return;
}
//Function from http://www.paulund.co.uk/php-delete-directory-and-files-in-directory
function delete_files($target) {
	if(is_dir($target)){
		$files = glob( $target . '*', GLOB_MARK ); //GLOB_MARK adds a slash to directories returned
		foreach( $files as $file )
		{
			delete_files( $file );
		}
		rmdir( $target );
	} elseif(is_file($target)) {
		unlink( $target );
	}
return;	
}
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
return;
}
?>