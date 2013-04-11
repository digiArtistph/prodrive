<?php

/**
 * Generates some admin menu on the top side of the graphical user-interface
 * @author Mugs and Coffee
 * @written Kenneth "digiArtist_ph" P. Vallejos
 * @since Tuesday, April 9, 2013
 * @version 1.0
 *
 */
class Masthead extends Pagesection {
	
	private static $domType = null;
	private static $domProps = null;

	public static function loadSection(Pagetemplate $page) {
		// runs hooks in the section. checks hooks on the options table
		
		// builds the masthead
		$page->set_mastHead('<div class="masthead"><ul><li><a href="#">Cashier</a></li></li><li><a href="#">Log-out</a></li></ul></div>');
		
	}
	
	protected static  function buildDOM() {
		$output = '';
		
		self::$domType = '<div>';
		self::$domProps = '';
		
		return '';
	}
}

?>