<?php
//myDeepZoom very nice Composer of the happy ardent OpenSeadragon (DZO) v0.1
//Part of the OpenSeadragon DZI online composer utils.
//Needs imagick.so installed and active in the PHP settings.
//Alfonso Abelenda Escudero, chafalladas.com. (c) 2016 license BSD-type 2.
//In fact is my first PHP script ever, needs a lot of recode and cleansing.
//It lacks functions and a proper structure since I was learning how to use PHP.
//But it does the job for the good local people.
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
$target_dir = $_POST['upload_dir']; #Using precreated dirs, tiles and info will be created under this dir.
$sessid = $_POST['sessid'];
$debug_info = $_POST['debug_info'];
$log_info = $_POST['log_info'];
$overlap = $_POST['overlap'];
$tilesize =  $_POST['tilesize'];
$target_file = $target_dir . "/" . basename($_FILES["file"]["name"]);
$uploadOk = 1;
$imageFileType = pathinfo($target_file,PATHINFO_EXTENSION);
//my $log_info = $query->param("log_info"); #Pass log info to the referrer.
prof_flag("Start");
FilePrint($sessid, ".txt", $sessid . ":0:12\n","w", true);
//print_r(get_declared_classes()); //Good for testing the classes loaded.

// Check if image file is a actual image or fake image
if(isset($_POST["submit"])) {
    $check = getimagesize($_FILES["file"]["tmp_name"]);
    if($check !== false) {
		FilePrint("log_dzo.txt", "",date(DATE_RFC2822) . " " . $sessid . " " . $target_file .  "File is an image - " . $check["mime"] . ".\n","a+", true);
        $uploadOk = 1;
    } else {
		FilePrint("log_dzo.txt", "", date(DATE_RFC2822) . " " . $sessid . " " . $target_file . "File is not an image.\n","a+", true);		
        $uploadOk = 0;
    }
}

// Check if $uploadOk is set to 0 by an error
if ($uploadOk == 0) {
	FilePrint("log_dzo.txt", "", date(DATE_RFC2822) . " " . $sessid . " " . $target_file . "Sorry, there was an error uploading your file.\n","a+", true);
	exit(1);
	// if everything is ok, try to upload file
} else {
    if (move_uploaded_file($_FILES["file"]["tmp_name"], $target_file)) {
		FilePrint("log_dzo.txt", "", date(DATE_RFC2822) . " " . $sessid . " " . $target_file . "The file ". basename( $_FILES["file"]["name"]). " has been uploaded.\n","a+", true);
    } else {
		FilePrint("log_dzo.txt", "", date(DATE_RFC2822) . " " . $sessid . " " . $target_file . "Sorry, there was an error uploading your file.\n","a+", true);
		exit(1);
    }
}
// Create the tiles
//Parameters
//Image, path ,.dzi name, output format, tilesize, overlap, width, height, zipped output, reason, progress(fine/coarse)
prof_flag("Tiling");
try
{
        /*** a valid image file ***/
        $image = $target_file;

        /*** a new imagick object ***/
		$myimage = new Imagick($image);
}
catch(Exception $e)
{
        echo $e->getMessage();
		echo '\n';
}
//Get dimensions of the image.
$d = $myimage->getImageGeometry();
$maxDimension = max($d['height'],$d['width']);
//Create DZI and Json info
$dziStr = "<?xml version='1.0' encoding='UTF-8'?><Image xmlns='http://schemas.microsoft.com/deepzoom/2008' Format='jpg' Overlap='" . $overlap . "' TileSize='" . $tilesize . "' ><Size Height='" . $d['height'] . "' Width='" . $d['width'] . "' /></Image>";
$jsonStr = "{Image: {xmlns: 'http://schemas.microsoft.com/deepzoom/2008', Format: 'jpg', Overlap:" . $overlap . ", TileSize: " . $tileSize . ", Size: { Width: " . $d['width'] . " , Height: " . $d['height'] . " } }}";
FilePrint($target_file,".dzi",$dziStr,"w", true);
FilePrint($target_file,".json",$jsonStr,"w", true);
//Append tilesets to the json file of processed images.
$jsonStr = ",\n{myDirTilesource:'" . $target_dir ."',mytileName:'" . $target_file . ".dzi',tx:1,ty:0, tHeight: " . $d['height'] . ", tWidth: " . $d['width'] . "}]}";
//Calculate resize steps. Bassically calculate how many times we need to elevate 2 to get the goal size.
$stepsmax = (int)(log($maxDimension,2)) + 1;
//We choose to draw the less steps.
//While smaller side > 1
//$steps = $stepsmax;
$tempX = $d['width'];
$tempY = $d['height'];
$steps = $stepsmax;
for ($i = 0; $i <= $stepsmax; $i++)
{
	//Create a clone to use as a temp image.
	$tempImage = clone $myimage;
	//First step no resize.
	if ($steps == $stepsmax)
	{
		FilePrint("log_dzo.txt","",date(DATE_RFC2822) . " " . $sessid . " " . $target_file . " First Step: " . $steps . "\n","a+", true);
		$d = $tempImage->getImageGeometry();
		$stepsX = (int)($d['width']/$tilesize);
		$stepsY = (int)($d['height']/$tilesize);
		FilePrint("log_dzo.txt","",date(DATE_RFC2822) . " " . $sessid . " " . $target_file . "First dimensions. TempX: ". $tempX ." X: " . $d['width'] . " Y: " . $d['height'] . "\n","a+", false);
	}
	else //Resize the temp image
	{
		FilePrint("log_dzo.txt","",date(DATE_RFC2822) . " " . $sessid . " " . $target_file . "Next Steps: " . $steps . "\n", "a+", false);
		$tempX = (int)ceil($tempX / 2);
		$tempY = (int)ceil($tempY / 2);
		$tempImage->scaleImage($tempX, $tempY, true);
		$d = $tempImage->getImageGeometry();
		$stepsX = (int)($d['width']/$tilesize);
		$stepsY = (int)($d['height']/$tilesize);
		FilePrint("log_dzo.txt","",date(DATE_RFC2822) . " " . $sessid . " " . $target_file . "Next dimensions. TempX: ". $tempX ." X: " . $d['width'] . " Y: " . $d['height'] . "\n","a+", false);
	}
	//while cropped width > tilesize
	for ($j = 0; $j <= $stepsX; $j++)
	{
		$X1=($tilesize*$j)-($overlap*$j);
		for ($k = 0; $k <= $stepsY; $k++)
		{
	//Create a clone of the resized clone to use as a temp image for every crop done.
			$Y1=($tilesize*$k)-($overlap*$k);
			$croppedImage = clone $tempImage;
			$croppedImage->cropImage($tilesize,$tilesize, $X1, $Y1);
			$d = $croppedImage->getImageGeometry();
			mkdir($target_file . "_files/", 0755);
			mkdir($target_file . "_files/" . $steps, 0755);
			//Write the cropped file in the correspondent dir.
			$croppedImage->writeImage($target_file . "_files/" . $steps . "/" . $j . "_". $k . ".jpg");
			$stro = "File: " . $target_file . " step: " . $steps . " stepX: " . $j . " StepY: ". $k ." X1: " . $X1 . " Y1: " . $Y1 . " cropped width: " . $d['width'] . " cropped height: " . $d['height'] . "\n";
			FilePrint("log_dzo.txt","",date(DATE_RFC2822) . " " . $sessid . " " . $target_file . $stro,"a+", false);
			FilePrint($sessid, ".txt", $sessid . ":" . $i . ":" . $stepsmax . "\n", "w", true);
		}
	}
$steps--;
}
prof_flag("Done");
prof_print();
//Do a happy day regard to the user.
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
?>