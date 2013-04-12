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
 *		get_dom_elem('<name>',bool)  // <name>: is an html element. bool is TRUE | FALSE. 
 *			
 *		legend:	
 *			TRUE : returns closing element of a tag. This is the default bool
 *			FALSE: returns name of the element of tag
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
 *					}
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
