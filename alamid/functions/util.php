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

if(! function_exists('remove_array_index')) {
	function remove_array_index(&$array) {
		$tmpArr = array();
		
		foreach($array as $val):
			$tmpArr[] = $val;
		endforeach;
		
		//call_debug($tmpArr);
		$array = $tmpArr;
	}
}

if(! function_exists('to_array')) {
	function to_array($str = '', $flag = TRUE) {
		$retVal = array();
		
		$retVal = explode("|", $str);
		
	}
}

// create a function here that will log all the function from hooks that are not properly working
 
/**
 * Loads all framework's globals
 */	
if(! function_exists('loadAlamidGlobals')) {
	function loadAlamidGlobals() {
		global $almd_wrap;
		global $almd_db;
		global $almd_xmlparser;
		global $almd_formelems;
		global $sorting;
		
		global $almd_username;
		global $almd_useraccess;
		global $almd_userfullname;
		global $almd_userisloggedin;
		global $almd_userid;

		
		readUserCredentials();
		
		$almd_db = new Querytables();
		$almd_wrap = new Enclose();
		$sorting = 0;
	}
}

if(! function_exists('readUserCredentials')) {
	function readUserCredentials() {
		$CI =& get_instance();
		
		// loads helper
		$CI->load->helper('sessionreader');
		read_session();
	}
}