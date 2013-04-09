<?php

/**
 * Generates the base object of all dom
 * @author Mugs and Coffee
 * @written Kenneth "digiArtist_ph" P. Vallejos
 * @since Tuesday, April 9, 2013
 * @version 1.0
 *
 */
class Canvas {
	
	public function __construct() {
		echo 'Initialising Canvas class. <br />';
	}
	
	public static function loadCanvas() {
		return '<div class="container">This is the main canvas</div>';
	}
	
}

?>