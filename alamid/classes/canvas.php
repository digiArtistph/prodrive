<?php
/**
 * Generates the base container object of all dom
 * @author Mugs and Coffee
 * @written Kenneth "digiArtist_ph" P. Vallejos
 * @since Tuesday, April 9, 2013
 * @version 1.0
 *
 */
class Canvas extends Pagesection {
	private static $domElem;
	private static $ojbChild;
		
	public static function loadSection(Pagetemplate $page) {
		self::buildDOM();
			 	
		// builds the canvas here
		$page->set_canvas(self::$domElem);
		
	}
	
	protected static  function buildDOM() {
		global $almd_wrap;
		
		$output ='';
		$dom = array(
					'node' => 'div',
					'child' => '%s%s%s%s%s',
					'prop' => get_elem_properties(array(
								'id' => 'container'
							))
				);
		
		$output = $almd_wrap->wrap($dom);		
		self::$domElem = trim($output);
		
	}
	
	public static function buildChildDOM($chld) {
		self::$objChild = $chld;
	}
}

?>