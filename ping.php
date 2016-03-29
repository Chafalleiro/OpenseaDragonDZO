<?php
//This script just gives info to the DZI composing progress bar.
//This is a local script for local functions, you have nothing to do here. v01
//Part of the OpenSeadragon DZI online composer utils.
//Alfonso Abelenda Escudero, chafalladas.com. (c) 2016 license BSD-type 2.
function myErrorHandler($errno, $errstr, $errfile, $errline)
{
//Take care of known warning so they don't get logged
$myWarns = array("failed to open stream: No such file or directory","fgets() expects parameter 1 to be resource, boolean given","fclose() expects parameter 1 to be resource, boolean given");
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
		FilePrint("log_dzo.txt", "", "My ERROR</b> [$errno] $errstr at $errline in $errfile\n","a+");
        exit(1);
        break;
    case E_USER_WARNING:
        echo "My WARNING</b> [$errno] $errstr<br />\n";
		FilePrint("log_dzo.txt", "", "My WARNING</b> [$errno] $errstr at $errline in $errfile\n","a+");
        break;
    case E_WARNING:
        echo "<b>My WARNING</b> [$errno] $errstr<br />\n";
		FilePrint("log_dzo.txt", "", "My WARNING</b> [$errno] $errstr at $errline in $errfile\n","a+");
        break;
    case E_USER_NOTICE:
        echo "<b>My NOTICE</b> [$errno] $errstr<br />\n";
		FilePrint("log_dzo.txt", "", "My NOTICE</b> [$errno] $errstr at $errline in $errfile\n","a+");
        break;
    default:
        echo "Unknown error type: [$errno] $errstr<br />\n";
		FilePrint("log_dzo.txt", "", "Unknown error type: [$errno] $errstr at $errline in $errfile\n","a+");
        break;
    }
    /* Don't execute PHP internal error handler */
    return true;
}	
} 
function FilePrint($file,$ext,$string,$mode)
{
	$fp = fopen($file . $ext, $mode);
	fwrite($fp, $string);
	fclose($fp);
}
$old_error_handler = set_error_handler("myErrorHandler",E_ALL | E_WARNING);
$sessid = $_POST['sessid'];
$fp = fopen($sessid . ".txt", "r+");
$line = fgets($fp,1024);
fclose($fp);
echo $line;
?>