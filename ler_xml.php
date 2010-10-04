<?php
//$URL_PARCEIRO = "http://www.teens180.com/eleicoes2010/1turno";
$URL_PARCEIRO = "http://download.uol.com.br/eleicoes/2010/1turno";
$LOCAL_DIR = dirname(__FILE__) . "/temp";

$uf = strtolower($_GET['uf']);
$cargo = $_GET['cargo'];
$file = $_GET['file'];
$fixo = $_GET['fixo'];

if ((strlen($uf) != 2 || !preg_match('/^[13567]$/',$cargo) || !preg_match('/^[12]$/',$file)) && $fixo == '') {
	echo "Parametros incorretos!";
	exit;
}

if ($fixo != '') { //pi13v0003
	$uf = substr($fixo, 0, 2);
	$cargo = substr($fixo, 3, 6);
	
	if ($cargo == '5v0004') $cargo = '5v0005';
	//else if ($cargo == '6v0003') $cargo = '6v0014';

/*	if ($uf == 'ma' && $cargo == 7) {
		$cargo .= 'v0002';
	} else {
		$cargo .= 'v0001';
	}*/
}

$handle = fopen($URL_PARCEIRO . "/$uf/${uf}1${cargo}.zip", "rb");
$contents = stream_get_contents($handle);
fclose($handle);

$zipFile = $LOCAL_DIR . "/${uf}1${cargo}.zip";

$f = fopen($zipFile, 'wb');
fwrite($f,$contents,strlen($contents));
fclose($f); 

$zip = new ZipArchive;
if ($zip->open($zipFile) === TRUE) {
    $zip->extractTo($LOCAL_DIR);
    $zip->close();
    //echo 'ok';
} else {
    //echo 'failed';
}

header("Content-Type: text/xml;  charset=iso-8859-1");
$xml = fopen($LOCAL_DIR . "/${uf}1${cargo}.xml", "rb");
fpassthru($xml); 
fclose($xml);

/*
$xml = simplexml_load_file($LOCAL_DIR . "/${uf}1${cargo}.xml");
//print_r($xml);
echo ">" . $xml['cargo'];
foreach ($xml->Resultado as $tags) {
	echo "-" . $tags['cargo'];
}
*/