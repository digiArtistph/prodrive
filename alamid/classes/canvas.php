<?php

/**
 * Generates the base object of all dom
 * @author Mugs and Coffee
 * @written Kenneth "digiArtist_ph" P. Vallejos
 * @since Tuesday, April 9, 2013
 * @version 1.0
 *
 */
class Canvas extends Pagesection {
	
	private $domType = null;
	private $domProps = null;
	
	public function __construct() {	
		// echo 'Initialising Canvas class. <br />';
		$this->domType = '<div>';
		$this->domProps = '';
		
	}
	
	public static function loadSection(Pagetemplate $page) {
		// runs hooks in the section. checks hooks on the options table
		
		// builds the canvas here
		$page->set_canvas('<div class="container">%s</div>');
		
	}
	
}

?>