<?php
/**
 * 
 * @author Mugs and Coffee
 * @written Kenneth "digiArtist_ph" P. Vallejos 
 * @since Friday, April 10, 2013
 * @version 1.0.0
 * 
 */
if(!function_exists('alias')) {
	function alias($name, $nckname) {
		class_alias($name, $nckname);
	}
}

function remove_array_index(&$array) {
	$tmpArr = array();
	
	foreach($array as $val):
		$tmpArr[] = $val;
	endforeach;
	
	call_debug($tmpArr);
	$array = $tmpArr;
}

// create a function here that will log all the function from hooks that are not properly working
 
/**
 * Loads all framework's globals
 */	
if(! function_exists('loadAlamidGlobals')) {
	function loadAlamidGlobals() {
		global $almd_wrap;
		global $almd_db;
		
		$almd_wrap = new Enclose();
	}
}
