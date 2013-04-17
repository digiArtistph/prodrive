<?php
/**
 * Generates the main content of the current page
 * @author Mugs and Coffee
 * @written Kenneth "digiArtist_ph" P. Vallejos
 * @since Sunday, April 14, 2013
 * @version 1.0
 *
 */
class Pasteboard extends Pagesection {	
	private static $domElem;
	private static $ojbChild;
	
	public static function loadSection(Pagetemplate $page) {
		self::buildDOM();		
		// builds the panels here
		$page->set_pasteboard(self::$domElem);
	}
	
	protected static  function buildDOM() {
		global $almd_wrap;
		$output ='';
		
		// runs hook here
		$objChild = 'Home Page!';
		$dom = array(
				'node' => 'div',
				'child' => $objChild,
				'prop' => get_elem_properties(array(
						'class' => 'content'
				))
		);
		
		$output = $almd_wrap->wrap($dom);		
		self::$domElem = trim($output);
	}
	
	public static function buildChildDOM($chld) {
		self::$objChild = $chld;
	}
}