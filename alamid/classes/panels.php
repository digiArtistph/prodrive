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
	private static $objChild;
		
	public static function loadSection(Pagetemplate $page) {
		self::buildDOM();		
		// builds the panels here
		$page->set_panels(self::$domElem);
	}
	
	protected static  function buildDOM() {
		global $almd_wrap;
		$output ='';
		
		// runs hook here
		Bootstrap::execute(/* $objChild,  */'section_panels');
		
		self::$objChild = sprintf("<ul>%s</ul>", self::$objChild);
		$dom = array(
					'node' => 'div',
					'child' =>  self::$objChild ,
					'prop' => get_elem_properties(array(
								'id' => 'panels'
							))
				);
		
		$output = $almd_wrap->wrap($dom);	
		self::$domElem = trim($output);

	}
	
	public static function buildChildDOM($chld) {
		self::$objChild .= $chld;
	}
	
}

?>