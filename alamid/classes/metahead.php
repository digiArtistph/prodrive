<?php

class Metahead extends Pagesection {
	private static $domElem;
	private static $objSiblings;
	
	public static function loadSection(Pagetemplate $page) {
		self::buildDOM();		
		// builds the masthead
		self::$domElem = $page->get_meta() . self::$objSiblings;
		$page->set_meta(self::$domElem);
		
	}
	
	protected static  function buildDOM() {
		global $almd_wrap;
		$output ='';
		
		// runs hook here
		Bootstrap::execute('section_metahead');		
		self::$domElem = self::$objSiblings;

	}
	
	public static function buildChildDOM($chld) {}
	
	public static function buildSiblingDOM($siblng) {
		self::$objSiblings .= $siblng;
	}
	
}

?>