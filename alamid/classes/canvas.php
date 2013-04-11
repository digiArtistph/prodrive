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
	private static $domElem;
	
	public static function loadSection(Pagetemplate $page) {
		
		// runs hooks in the section. checks hooks on the options table
		self::buildDOM();
			
		// builds the canvas here
		$page->set_canvas(self::$domElem);
		
	}
	
	protected static  function buildDOM() {
		
		$output ='';
		$node = '<div>';
		$coreNode = '';
		$before_hWnd = '';
		$after_hWnd = '';
		$classes = '';
		$id = 'container';
		$xtra_prop = '';
		$childNode = 'Hello World!';
		
		preg_match('/(?<=\<)[\w]+(?=\>)/', $node, $matches);

		if(count($matches) > 0) {
			$coreNode = $matches[0];
			$endnode = sprintf("</ %s>", $matches[0]);				
		}
		
		$node = sprintf("<%s %s %s %s>", $coreNode, ($id != "") ? 'id="' . $id . '"' : "", ($classes != "") ? 'class="' . $classes . '"' : "", ($xtra_prop != "") ? $xtra_prop : "");
		$output .= sprintf("%s%s" . $childNode . "%s%s", $before_hWnd, $node,$endnode, $after_hWnd);
		
		self::$domElem = trim($output);
		
	}
}

?>