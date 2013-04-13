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
	private static $domElem;

	public static function loadSection(Pagetemplate $page) {
		self::buildDOM();		
		// builds the panels here
		$page->set_panels(self::$domElem);
	}
	
	protected static  function buildDOM() {
		global $almd_wrap;
		$output ='';
		
		// runs hook here
		$objChild = '<ul><li><a href="#">Master Files</a></li><li><a href="#">Utility</a></li><li><a href="#">About</a></li><li><a href="#">Configuration</a></li></ul>';
		$dom = array(
				'node' => 'ul',
				'child' => $objChild,
				'prop' => get_elem_properties(array(
						'class' => 'panel-widgets'
				))
		);
		
		$output = $almd_wrap->wrap($dom);
		
		self::$domElem = trim($output);
	}
	
}

?>