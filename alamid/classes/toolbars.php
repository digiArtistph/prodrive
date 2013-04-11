<?php

/**
 * Generates floatable toolbars on the right panel of the graphical user interface
 * @author Mugs and Coffee
 * @written Kenneth "digiArtist_ph" P. Vallejos
 * @since Tuesday, April 9, 2013
 * @version 1.0
 *
 */
class Toolbars extends Pagesection {
	
	public function __construct() {
		// echo 'Initialising Toolbars class. <br />';
	}
	
	public static function loadSection(Pagetemplate $page) {
		$page->set_toolbars('<div class="toolbars">Toolbars here</div>');
	}
	
	protected static  function buildDOM() {
		
	}
	
}

?>