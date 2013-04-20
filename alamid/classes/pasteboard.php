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
	private static $objChild;
	
	public static function loadSection(Pagetemplate $page) {
		self::buildDOM();		
		// builds the masthead
		$page->set_pasteboard(self::$domElem);
		
	}
	
	protected static  function buildDOM() {
		global $almd_wrap;
		$output ='';
		
		// runs hook here
		Bootstrap::execute(/* $objChild,  */'section_pasteboard');		

		self::$objChild = sprintf("%s", self::$objChild);
		$dom = array(
					'node' => 'div',
					'child' => self::$objChild,
					'prop' => get_elem_properties(array(
								'id' => 'content'
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