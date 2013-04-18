<?php

class Footer extends Pagesection {
	private static $domElem;
	private static $objChild;
	
	public static function loadSection(Pagetemplate $page) {
		self::buildDOM();		
		// builds the masthead
		$page->set_footer(self::$domElem);
		
	}
	
	protected static  function buildDOM() {
		global $almd_wrap;
		$output ='';
		
		// runs hook here
		Bootstrap::execute($objChild, 'section_footer');
		
		self::$objChild = sprintf("<ul>%s</ul>", self::$objChild);
		$dom = array(
					'node' => 'div',
					'child' =>  self::$objChild ,
					'prop' => get_elem_properties(array(
								'id' => 'footer'
							))
				);
		
		$output = $almd_wrap->wrap($dom);	
		self::$domElem = trim($output);

	}
	
	public static function buildChildDOM($chld) {
		self::$objChild .= $chld;
	}
	
}