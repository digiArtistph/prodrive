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
	/* if(!function_exists('get_setting') ) {

		function get_setting($param, $flag = TRUE) {
			
			$CI =& get_instance();
			$temp = array();
			
			$str = 'SElECT option_value FROM `option` WHERE option_name like "%' . $param . '%"';
			$query = $CI->db->query($str);
			
// 			call_debug($query);
			if($query->num_rows() <= 0){
				return false;
			}
			
			if($flag){
				$result = $query->result();
				$arr = json_decode($result[0]->option_value);
				//call_debug($arr);
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
	} */
	

	if(! function_exists('add_settings')) {
		function add_settings($name, $value = '') {
			$CI =& get_instance();
			$setting = '';
			$strQry = sprintf("SELECT option_value FROM `option` WHERE option_name='%s'", $name);
			
			$records = $CI->db->query($strQry);
			$result = $records->result();			
			$numrow = $records->num_rows;
			
			if($numrow < 1) {
				// preps data
				$setting = array($value); 
// 				call_debug($setting);
				$setting = json_encode($setting, JSON_FORCE_OBJECT);
				$strQry = sprintf("INSERT INTO `option` SET option_name='%s', option_value='%s'", $name, $setting);
				
				if(! $CI->db->query($strQry))
					return 0;
				else
					return 1; // success insert				
				
			}
			
			foreach($result as $rec) {
				$setting = $rec->option_value;
			}
			
			// retrieves settings values
			$setting = json_decode($setting, TRUE);
			// adds the new settings into the array
			$setting[] = $value;

			// deletes the duplicate values in the array
			$setting = array_unique($setting);
			
			// encodes into json
			$setting = json_encode($setting, JSON_FORCE_OBJECT);
			$strQryUpdate = sprintf("UPDATE `option` SET option_value='%s' WHERE option_name='%s'", $setting, $name);
			
			if(! $CI->db->query($strQryUpdate))
				return 0;
			else
				return 2; // success update

		}
	}
	
	if(! function_exists('get_setting')) {
		/**
		 * Gets the specified settings from options table
		 * @param string $name
		 * @param boolean $all
		 * @param boolean $includeindex
		 * @return boolean|multitype:|mixed
		 * @author Mugs and Coffee
		 * @written Kenneth "digiArtist_ph" P. Vallejos
		 * @since Monday, April 15, 2013
		 */
		function get_setting($name, $all = FALSE, $includeindex = FALSE) {
			// $all, when TRUE, retrieves all values in an array form
			// $includeindex, when TRUE, retrieves key-value pair
			
			$CI =& get_instance();
			$setting = array();
			$strQry = sprintf("SELECT option_value FROM `option` WHERE option_name='%s'", $name);
			$record = $CI->db->query($strQry);
			$result = $record->result();
			$numrows = $record->num_rows; 
			
			if($numrows < 1)
				return FALSE;
			
			foreach ($result as $val) {
				$setting = $val->option_value;
			}
			
			// decodes into php array
			$setting = json_decode($setting, TRUE);
			
			// returns one single record array with index
			if((count($setting) > 0 && !$all) && $includeindex)
				return array_slice($setting, 1, TRUE);
			
			// returns one single record in a string format
			if((count($setting) > 0 && !$all) && !$includeindex) {
				foreach($setting as $value) {
					return trim($value);
				}
			}
			// returns multiple records in an array format with index
			if(count(	$setting) > 0 && $all && $includeindex)
				return $setting;
						
			// returns multiple records in an array format without index
			if(count($setting) > 0 && $all && !$includeindex) {
				remove_array_index($setting);
				
				return $setting;
			}
							
		}
	}
	
	?>
