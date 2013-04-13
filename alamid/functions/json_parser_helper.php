<?php if(!defined('BASEPATH')) exit('No direct script access allowed');
/**
 * Description: Json parser
 * @author Mugs and Coffee
 * @written Norberto Q. Libago Jr.
 * @since Wednesday, April 10, 2013
 * @version 1.0.0
 *
 *
 *	FUNCTIONS:
 *		get_setting('<name>',bool)  // <name>: is an name value. bool is TRUE | FALSE. 
 *			
 *		legend:	
 *			TRUE : returns all array object. This is the Default
 *			FALSE: return only the first object 
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
 *						get_setting('sidebar', true); 
 *
 *					}
 *
 */
	if(!function_exists('get_setting') ) {

		function get_setting($param, $flag = TRUE) {
			
			$CI =& get_instance();
			$temp = array();
			
			$str = 'SElECT option_value FROM `option` WHERE option_name like "%' . $param . '%"';
			$query = $CI->db->query($str);
			
			if($query->num_rows() <= 0){
				return false;
			}
			
			if($flag){
				$result = $query->result();
				$arr = json_decoder($result[0]->option_value);
				$cnt = count(get_object_vars($arr));
				if ($cnt == 1){
					foreach ($arr as $key => $val){
						$temp = $val;break;
					}
					return $temp;
				}else
					return $arr;
				
			}
			
			if($flag  == false){
				$result = $query->result();
				$arr = json_decode($result[0]->option_value);
				
				foreach ($arr as $key => $val){
					$temp = $val;break;
				}
				return $temp;
			}
			
		}
	}
