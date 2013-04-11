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
	
	private static $domElem;

	public static function loadSection(Pagetemplate $page) {
		// runs hooks in the section. checks hooks on the options table
		
		// builds the masthead
		$page->set_mastHead('<div class="masthead"><ul><li><a href="#">Cashier</a></li></li><li><a href="#">Log-out</a></li></ul></div>');
		
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
		$childNode = '';
		
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