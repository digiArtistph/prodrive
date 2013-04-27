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
	private $formElements = array();
	private function __construct() {}
	
	public function __clone() {}
	
	public static function get_instance() {
		if(! self::$instance instanceof self) {
			self::$instance = new self();
		}
		
		return self::$instance;
	}
	
	public function getAllFormElments() {
		// calls all standard form elements
// 		$this->getTextareaDef();
		$this->getTextfieldDef();
		$this->getSelectDef();
// 		$this->getCheckboxDef();
	}
	
	private function getTextfieldDef() {
		$almd_xmlparser = new Xmlparser();
		$almd_xmlparser->loadXml('alamid/structure/libs/form_elements/text.xml');
		$almd_xmlparser->arrtoxml();
		call_debug($almd_xmlparser->mParseData, FALSE);
	}
	
	private function getTextareaDef() {
		$almd_xmlparser = new Xmlparser();
		$almd_xmlparser->loadXml('alamid/structure/libs/form_elements/textarea.xml');
		$almd_xmlparser->arrtoxml();
		call_debug($almd_xmlparser->mParseData, FALSE);
	}
	
	private function getSelectDef() {
		$almd_xmlparser = new Xmlparser();
		$almd_xmlparser->loadXml('alamid/structure/libs/form_elements/select.xml');
		$almd_xmlparser->arrtoxml();
		call_debug($almd_xmlparser->mParseData, FALSE);
	}
	
	private function getCheckboxDef() {
		$almd_xmlparser = new Xmlparser();
		$almd_xmlparser->loadXml('alamid/structure/libs/form_elements/checkbox.xml');
		$almd_xmlparser->arrtoxml();
		call_debug($almd_xmlparser->mParseData, FALSE);
	}
	
	private function _xAttrib() {
		$arrAttrib = array();
		
		
		return $arrAttrib;
	}
	
	private function _xSiblings() {
		$arrSiblings = array();
		
		return $arrSiblings;
	}
	
	private function _xParent() {
		$arrParent = array();
		
		
		return $arrParent;
	} 
	
	public function getText($callback = null) {
		$arg = func_get_args();
		
		call_debug($arg, FALSE);
	}
	
// 	regular expression:
// 	(?<={siblings})[\w|\s]+
// 	(?<={attrib})[\w|\s]+

	
// 	Array
// 	(
// 			[0] => Array
// 			(
// 					[field] => Array
// 					(
// 							[attrib] => Array
// 							(
// 									[type] => select
// 									[attrib] => class::textfield required hidden|name:skills
// 									[siblings] => label[value::'%1$'|tag::open]|%s|label[tag:close]|span  [class::error hidden]
// 									[parent] => p[class::defaultform masterfile|prior::1]|span[class::txtfld]
// 							)
	
// 					)
	
// 			)
	
// 	)
	
// 	Array
// 	(
// 			[0] =>
// 			[1] => {attrib}inputfield hidden shown|skill
// 			[2] => {siblings}student|First Name|Last Name
// 			)
	
	
}