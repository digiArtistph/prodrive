<?php

class Footer extends Pagesection {
	private static $domElem;

	public static function loadSection(Pagetemplate $page) {
		self::buildDOM();		
		// builds the masthead
		$page->set_footer(self::$domElem);
		
	}
	
	protected static  function buildDOM() {
		global $almd_wrap;		
		$output ='';
		
		// runs hook here
		$objChild = 'Copyright 2013 Prodrive Motorwerks';
		$dom = array(
					'node' => 'div',
					'child' => $objChild,
					'prop' => get_elem_properties(array(
								'id' => 'footer'
							))
				);
		
		$output = $almd_wrap->wrap($dom);
		
		self::$domElem = trim($output);

	}
	
}