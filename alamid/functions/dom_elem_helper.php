<?php if(!defined('BASEPATH')) exit('No direct script access allowed');
/**
 * Description: Json parser
 * @author Mugs and Coffee
 * @written Norberto Q. Libago Jr.
 * @since Wednesday, April 12, 2013
 * @version 1.0.0
 *
 *
 *	FUNCTIONS:
 *		1)	
 *	
 *			- get_dom_elem('<name>',bool)  // <name>: is an html element. bool is TRUE | FALSE. 
 *
 * 		legend:	
 *			TRUE : returns closing element of a tag. This is the default bool
 *			FALSE: returns name of the element of tag
 *		
 *		2)
 *
 *			$mArr = array(
 *					'title' => 'My Title', 
 *					'class' => 'My class name',
 *					'id' => 'My Id'
 *					);
 *
 *			-get_elem_properties($mArr)	// returns: title="My Title" class="My class name" id="My Id"
 *		
 *	
 *		3) 
 *			$string = 'Ako si tarzan hari ng kagubatan';
 *			$number = 10;	// default is 10
 *			-trunc_words($string, $number) // returns string from 0 to specified number
 *
 
 *					
 *
 *	SAMPLE CODE
 *
 *		{CONTROLLER}
 *
 *			<?php
 *				class somecontroller extends CI_Controller {
 *
 *					public function index() {
 *
 *						get_dom_elem('<div>', true);    //returns </div> - DEFAULT get_dom_elem('<div>');
 *						get_dom_elem('<div>', false);    //returns div
 *
 *					$mArr = array(
 *						'title' => 'My Title', 
 *						'class' => 'My class name',
 *						'id' => 'My Id'
 *						);
 *
 *					get_elem_properties($mArr);		//returns title="My Title" class="My class name" id="My Id"
 *
 *					$str = 'Ako si tarzan hari ng kagubatan';
 *					trunc_words($str, 4)		// returns	"Ako si tarzan hari . . ."
 *					
 *					}
 *			?>
 *
 */
	if(!function_exists('get_dom_elem') ) {

		function get_dom_elem($param, $flag = true) {
			$pattern = '/(?<=\<)[\w]+/';
			$element = '';
			
			preg_match($pattern, $param, $element);
			
			if($flag){
				$elem = '</'. $element[0] .'>';
				return $elem;
			}
			
			if($flag == false){
				return $element[0];
			}
		}
	}
	
	if(!function_exists('get_elem_properties') ) {
	
		function get_elem_properties($param) {
			
			if(!is_array($param)){
				return false;
			}
			
			$tagproperties = '';
			
			foreach ($param as $key => $val){
				$tagproperties .= ' ' . $key . '="' . $val . '"';
			}
			
			return $tagproperties;
		}
	}
	
	if(!function_exists('trunc_words') ) {
	
		function trunc_words($param, $word_limit = 10) {
			
			if(!is_string($param))
				return false;
			
			if ($word_limit <1)
				return false;
			
			$chars = '0123456789';
			$strConcat = '';
			$result = 'sdf';
			$mArrWords = str_word_count($param, 1, $chars);
			$output = array_slice($mArrWords, 0, $word_limit);
			
			foreach ($output as $key){
				$strConcat .= $key . ' ';
			}
			
			if(count($mArrWords) > $word_limit){
				$result = $strConcat . '. . .';
			}else{
				$result = $strConcat;
			}
			return $result;
		}
	}
