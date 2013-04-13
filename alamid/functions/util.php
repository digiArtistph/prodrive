<?php
/**
 * 
 * @author Mugs and Coffee
 * @written Kenneth "digiArtist_ph" P. Vallejos 
 * @since Friday, April 10, 2013
 * @version 1.0.0
 * 
 */
function alias($name, $nckname) {
	class_alias($name, $nckname);
}

/**
 * Loads all framework's globals
 */	
function loadAlamidGlobals() {
	global $almd_wrap;
	$almd_wrap = new Enclose();
	
}
