<?php
/**
 * Generates standard form element
 * @author Mugs and Coffee
 * @written Kenneth "digiArtist_ph" P. Vallejos
 * @since Thursday, April 25, 2013
 * @version 1.0.0
 *
 */
class Formelement {
	
	private static $instance = null;
	
	private function __construct() {}
	
	public function __clone() {}
	
	public static function get_instance() {
		if(! self::$instance instanceof self) {
			self::$instance = new self();
		}
		
		return self::$instance;
	}
	
	public function getAllFormElments() {
		$this->getTextarea();
		$this->getTextfield();
		
	}
	
	private function getTextfield() {
		$almd_xmlparser = new Xmlparser();
		$almd_xmlparser->loadXml('alamid/structure/libs/form_elements/text.xml');
// 				$almd_xmlparser->resetdata();
		$almd_xmlparser->arrtoxml();
		call_debug($almd_xmlparser->mParseData, FALSE);
	}
	
	private function getTextarea() {
		$almd_xmlparser = new Xmlparser();
		$almd_xmlparser->loadXml('alamid/structure/libs/form_elements/textarea.xml');
// 				$almd_xmlparser->resetdata();
		$almd_xmlparser->arrtoxml();
		call_debug($almd_xmlparser->mParseData, FALSE);
	}
	
}