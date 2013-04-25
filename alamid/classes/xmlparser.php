<?php 
/**
 * Description: XML Parser. Read xml file and return to array
 * @author Mugs and Coffee
 * @written Norberto Q. Libago Jr.
 * @since Friday, April 24, 2013
 * @version 1.0.0
 *
 *
 *		
 *
 *		$xmlreader = new xmlparser();					calling xmlparser
 *
 *		$filepath = 'alamid/structure/Form_elemets.xml';
 *			
 *		1) $xmlreader->loadXml($xmlfilename);			//reads xml from file
 *			
 *		
 *		2) $xmlreader->resetdata();	reset xmldata		//convert xml
 *		
 *		3) $xmlreader->arrtoxml();	reads xmldata		//convert xml
 *			
 *			
 *		4) $xmlreader->mParseData						// returns array of xml
 *
 *		sample controller:
 *		
 *		function __construct(){
 *
 *			$xmlfilename = 'alamid/structure/Form_elemets.xml';
 *			$xmlreader->loadXml($xmlfilename);
 *			$xmlreader->arrtoxml();
 *			
 *			echo '<pre />';
 *			print_r($xmlreader->mParseData);
 *			die();
 *		}
 *
 *		
 *
 *
 *
 */
class Xmlparser{
		
	public $mParseData;
	
	private $_mXml;
	private $mData;
	private $ms;
	
	public function __construct(){
		$this->mParseData = array();
		$this->_mXml = array();
		$this->mData= array();
		$this->ms = array();
	}
	
	public function loadXml($xmlfile){
		$truepath = FCPATH . $xmlfile;
		$xmlfilepath = realpath($truepath);
		
		if(file_exists($xmlfilepath)){
			//$xmlfile = simplexml_load_file($xmlfilepath, 'SimpleXMLElement', LIBXML_NOCDATA); 
			$xmlfile = file_get_contents($xmlfilepath);
			
			if(false == $xmlfile){ 
				echo 'File is not an XML File';
				return false;
			} else {
				
				$parser = xml_parser_create();
				xml_parser_set_option($parser, XML_OPTION_TARGET_ENCODING, "UTF-8"); # http://minutillo.com/steve/web...
				xml_parser_set_option($parser, XML_OPTION_CASE_FOLDING, 0);
				xml_parser_set_option($parser, XML_OPTION_SKIP_WHITE, 1);
				xml_parse_into_struct($parser, $xmlfile, $this->_mXml);
				xml_parser_free($parser);
				return true;
			}
		}else 
			echo 'File not Found!!!';
	}
	
	public function arrtoxml(){
		$tempkey = '';
		$this->mData = array();
		$cnt = 0;
		//call_debug($this->_mXml, false);
		foreach ($this->_mXml as $tag => $element){		//traverse all array
			
			if($element['type'] == 'close'){
				array_push($this->ms, $this->mData);
				$this->mData = '';
				$tempkey = '';
				$cnt = 0;
				
			}
			if( ($element['type'] == 'open') && ($element['level'] > 1) ){//call_debug($tag);
				$sd = $element['tag'];
				
					$keye = $element['tag'];
					
					if(array_key_exists('attributes', $element)){
						$this->mData[$keye] = array( 'attrib' => $element['attributes']);
						
					}
					$tempkey = $element['tag'];
					$cnt = 0;
				}elseif ( ($element['type'] == 'complete') && ($element['level'] > 1) ){
					
					if($tempkey == ''){
						
						$key = $element['tag'];
						
						if(array_key_exists('attributes', $element)){
							
							$this->mData[$key]['attrib'] = $element['attributes'];
						}
						
						if(array_key_exists('value', $element)){
							$this->mData[$key]['value'] = $element['value'];
						}
						array_push($this->ms, $this->mData);
						$this->mData = '';
					}else{
						
						$key = $element['tag'];
						
						if(array_key_exists('attributes', $element)){
								
							$this->mData[$tempkey]['value'][$cnt][$key]['attrib'] = $element['attributes'];
							
						}
						
						if(array_key_exists('value', $element)){
							$this->mData[$tempkey]['value'][$cnt][$key]['value'] = $element['value'];
						}
						
						
					}
					
					$cnt++;
					
				}
				
			}//end of each array loop
			array_pop($this->ms);
			
		$this->mParseData = $this->ms;
	}//end of function
	
	public function resetdata(){
		$this->_mXml = array();
		$this->mData = array();
		$this->ms = array();
		$this->mParseData = array();
	}
	
}
?>