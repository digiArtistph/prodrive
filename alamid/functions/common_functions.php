<?php
/**
 * 
 * Where all common utilities being declared
 * @author Mugs and Coffee
 * @written Kenneth "digiArtist_ph" P. Vallejos
 * @since Sunday, April 28, 2013
 * @version 1.0.0
 */

if(! function_exists('traverse')) {
	function traverse($item, $key) {
		Formelement::$tempArray[$key] = $item;
	}
}

function parseArray(&$item) {
		
	if(isDomProp($item)){
		$item = dompropToString($item);
	}
}

function dompropToString($str) {
	$pattern = '/::/';
	
	$arr = preg_split($pattern, $str);

	if(count($arr) > 0)
		return sprintf('%s="%s"', $arr[0], $arr[1]);
	
	return '';
}

function isDomElem($str) {
	$pattern = '/[\w]+\[(([\w]+::[\w\s]+)([\|\|])*)*\]/';
	
	if(preg_match($pattern, $str))
		return TRUE;
		
	return FALSE;
}

function isDomProp($str) {
	$pattern = '/^[\w]+::[\w\s]+/';
	
	if(preg_match($pattern, $str))
		return TRUE;
		
	return FALSE;
}

function isTagOpen($str) {
	$patternDomElem = '/[\w]+\[(([\w]+::[\w\s]+)([\|\|])*)*\]/';
	$patternOpenTag = '/tag::open/';
	
	if(preg_match($patternDomElem, $str) && preg_match($patternOpenTag, $str))
		return TRUE;		
	
	return FALSE;
}