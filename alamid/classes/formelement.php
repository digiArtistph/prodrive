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
	private $formElements;
	public static $tempArray = null;
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
		$this->getTextfieldDef();

	}
	
	private function getTextfieldDef() {
		$almd_xmlparser = new Xmlparser();
		$almd_xmlparser->loadXml('alamid/structure/libs/form_elements/text.xml');
		$almd_xmlparser->arrtoxml();
		$arr = $almd_xmlparser->mParseData;
		
		// traverse the array and assign values to static public variable
		array_walk_recursive($arr, 'traverse');
		
		$this->formElements = array(
							'text' => array(
									'attrib' => $this->_xAttribs(self::$tempArray['attrib']),
									'siblings' => $this->_xSiblings(self::$tempArray['siblings']),
									'parents' => $this->_xParents(self::$tempArray['parents']),
									'defaults' => $this->_xDefaults(self::$tempArray['defaults']),
									'compiled' => ''
								)
						);
		// resets the value
		self::$tempArray = null;
		array_walk_recursive($this->formElements['text'], 'parseArray');
		
		// compiles all elements and properties
		$node = sprintf('<input type="text" %s />', implode(" ", $this->formElements['text']['attrib']));
		$siblings = implode("", $this->formElements['text']['siblings']);
		$parents = implode("", $this->formElements['text']['parents']);
		$siblings = sprintf($siblings, $node);
		$output = sprintf($parents, $siblings);
		$this->formElements['text']['compiled'] = preg_replace('/\d\$/', '%s', $output);
		
	}
	
	private function getTextareaDef() {
		$almd_xmlparser = new Xmlparser();
		$almd_xmlparser->loadXml('alamid/structure/libs/form_elements/textarea.xml');
		$almd_xmlparser->arrtoxml();
		call_debug($almd_xmlparser->mParseData, TRUE);
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
	
	private function _xAttribs($strAttribs = "") {
		$pattern = '/(?<!\|)\|(?!\|)/';
		$arrAttribs = preg_split($pattern, $strAttribs);
		
		return (array)$arrAttribs;
	}
	
	private function _xSiblings($strSiblings = "") {
		$pattern = '/(?<!\|)\|(?!\|)/';
		$arrSiblings = preg_split($pattern, $strSiblings);
		
		return (array)$arrSiblings;
	}
	
	private function _xDefaults($strDefaults = "") {
		$pattern = '/\|/';
		
		$arrDefaults = preg_split($pattern, $strDefaults);
		
		return (array)$arrDefaults;
	}
	
	private function _xParents($strParents = "") {
		$pattern = '/(?<!\|)\|(?!\|)/';
		$arrParents = preg_split($pattern, $strParents);
		
		return (array)$arrParents;
	} 
	

	public function getText($callback = null) {
		$args = func_get_args();
		$numargs = func_num_args();
		$output = '';
		
		$output = $this->formElements['text']['compiled'];
		
		switch ($numargs) {
			case 2:	$output = sprintf($output, $args[1]); break;
			case 3:	$output = sprintf($output, $args[1],$args[2]); break;
			case 4:	$output = sprintf($output, $args[1],$args[2], $args[3]); break;
			case 5:	$output = sprintf($output, $args[1],$args[2], $args[3], $args[4]); break;
			case 6:	$output = sprintf($output, $args[1],$args[2], $args[3], $args[4], $args[5]); break;
			case 7:	$output = sprintf($output, $args[1],$args[2], $args[3], $args[4], $args[5], $args[6]); break;
			case 8:	$output = sprintf($output, $args[1],$args[2], $args[3], $args[4], $args[5], $args[6], $args[7]); break;
			case 9:	$output = sprintf($output, $args[1],$args[2], $args[3], $args[4], $args[5], $args[6], $args[7], $args[8]); break;
			case 10:$output = sprintf($output, $args[1],$args[2], $args[3], $args[4], $args[5], $args[6], $args[7], $args[8], $args[9]); break;
			case 11:$output = sprintf($output, $args[1],$args[2], $args[3], $args[4], $args[5], $args[6], $args[7], $args[8], $args[9], $args[10]); break;
			case 12:$output = sprintf($output, $args[1],$args[2], $args[3], $args[4], $args[5], $args[6], $args[7], $args[8], $args[9], $args[10], $args[11]); break;
			case 13:$output = sprintf($output, $args[1],$args[2], $args[3], $args[4], $args[5], $args[6], $args[7], $args[8], $args[9], $args[10], $args[11], $args[12]); break;
			case 14:$output = sprintf($output,$args[1],$args[2], $args[3], $args[4], $args[5], $args[6], $args[7], $args[8], $args[9], $args[10], $args[11], $args[12], $args[13]); break;
			case 15:$output = sprintf($output, $args[1],$args[2], $args[3], $args[4], $args[5], $args[6], $args[7], $args[8], $args[9], $args[10], $args[11], $args[12], $args[13], $args[14]); break;
		}
		
		return $output;
		
	}
	
}