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
	// properties of dom
	if(isDomProp($item))
		$item = dompropToString($item);
	// dom
	
	if(isDomElem($item)) {
		$domName = getDomName($item);
		$openTag = FALSE;
		$closeTag = FALSE;
		
		// parses the properties
		$pattern = '/[\w]+::[\w\s]+/';
		preg_match($pattern, $item, $matches);
		$output = '';
		//call_debug($matches);
		foreach ($matches as $prop) {
			if(preg_match('/tag::open/', $prop))
				$openTag = TRUE;
				
			if(preg_match('/tag::close/', $prop))
				$closeTag = TRUE;
			
			if(!$openTag and !$closeTag)
				$output .= sprintf(" %s ", trim(dompropToString($prop)));
		}
		//on_watch($closeTag);
		if($openTag)
			$item = sprintf('<%s>', $domName);
		
		$item = sprintf('<%s%s>', $domName, $output);
	
		if($closeTag)
			$item = sprintf('</%s>', $domName);
		
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

function getDomName($str) {
	$pattern = '/^[\w]+(?=\[)/';	
	preg_match($pattern, $str, $matches);

	if(count($matches) > 0)
		return trim($matches[0]);
	
	return '';
}

function isTagOpen($str) {
	$patternDomElem = '/[\w]+\[(([\w]+::[\w\s]+)([\|\|])*)*\]/';
	$patternOpenTag = '/tag::open/';
	
	if(preg_match($patternDomElem, $str) && preg_match($patternOpenTag, $str))
		return TRUE;		
	
	return FALSE;
}