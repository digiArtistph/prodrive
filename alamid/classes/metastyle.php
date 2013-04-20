<?php

class Metastyle extends Pagesection {
	private static $domElem;
	private static $objSiblings;

	public static function loadSection(Pagetemplate $page) {
		self::buildDOM();
		// builds the masthead
		self::$domElem = $page->get_scripts() . self::$objSiblings;
		$page->set_styles(self::$domElem);
		
	}

	protected static  function buildDOM() {
		global $almd_wrap;
		$output ='';

		// runs hook here
		Bootstrap::execute('section_metastyle');
		self::$domElem = self::$objSiblings;

	}

	public static function buildChildDOM($chld) {}

	public static function buildSiblingDOM($siblng) {
		self::$objSiblings .= $siblng;
	}

}

?>