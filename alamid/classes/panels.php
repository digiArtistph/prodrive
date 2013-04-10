<?php

/**
 * Generates all the panels on the right side of the graphical user interface
 * @author Mugs and Coffee
 * @written Kenneth "digiArtist_ph" P. Vallejos
 * @since Tuesday, April 9, 2013
 * @version 1.0
 *
 */
class Panels extends Pagesection {
	
	public function __construct() {
		// echo 'Initialising Panels class. <br />';
	}
	
	public static function loadSection(Pagetemplate $page) {
		// runs hooks in the section. checks hooks on the options table
		
		// builds the panels here
		$page->set_mastHead('<div class="masthead"><ul><li><a href="#">Log-out</a></li></ul></div>');
	}
	
	
}

?>