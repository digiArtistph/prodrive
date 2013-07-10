<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

function dmax() {
	$CI =& get_instance();
	$strQry = "CALL sp_dmax(@cntr)";
	$CI->db->query($strQry);

	$resultset = $CI->db->query("SELECT @cntr AS dmax")->result();
	
	foreach($resultset as $result) {
		return $result->dmax;
	} 
}
/**
	 * 
	 * Reads filterperpage session and rewrites the $config array that is being passed by reference
	 * @param array $config
	 */
	function readFilterPerPage(&$config) {
		$CI =& get_instance();
		
		// sessionbrowser
		$params = array('pgbookmark', 'pgperpage');
 		$CI->sessionbrowser->getInfo($params);
 		$arr = $CI->sessionbrowser->mData;
 		
 		$config['per_page'] = $arr['pgperpage'];
	}
	
	
	
if( ! function_exists('paginate')) {
	/**
	 * 
	 * Generates pagination and returns resultset ...
	 * @param array $params
	 * @author Mugs and Coffee
	 * @coder Kenneth "digiArtist_ph" P. Vallejos
	 * @since Sunday, June 16, 2013
	 * @version 1.1.0
	 * 
	 */
	function paginate($params = array()) {
		
		$CI =& get_instance();
		$segment = (array_key_exists('uri_segment', $params)) ? $params['uri_segment'] : 5;
		$id = ($CI->uri->segment($segment)) ? $CI->uri->segment($segment) : 0;
		$CI->load->library('pagination');
		
		// checks if index 'query' exists otherwise use the default sql statement
		// use sprintf function inorder this helper to work properly; and ADD a %s on the last part of your sql statemement and add a empty string for the sprintf's replacement variable
		$strQry = (array_key_exists('query', $params)) ? $params['query'] : sprintf("SELECT custid, CONCAT(lname, ', ', fname) AS fullname, addr, phone, company FROM customer WHERE `status`='1' ORDER BY lname %s", '');		
		$base_url = (array_key_exists('base_url', $params)) ? $params['base_url'] : base_url('master/customer/section/viewcustomer'); 
		
		$config = array(
						'base_url' => $base_url,
						'total_rows' => $CI->db->query($strQry)->num_rows,
						'per_page' => 10,
						'num_links' => 3,
						'uri_segment' => 5					
					);

		// the parameter should be passed by reference
		if(array_key_exists('callback', $params))
			call_user_func_array($params['callback'], array(&$config)); 
			
		// overides the default settings
		$config = array_merge($config, $params);
		$CI->pagination->initialize($config);
		
		// preps data
		$strQry = sprintf($strQry . " LIMIT %d, %d", $id, $config['per_page']);
		
		// retrieves datasets
		$dataset = $CI->db->query($strQry);
		$result['paginate'] = $CI->pagination->create_links();
		$result['count'] = $dataset->num_rows;
		$result['overallcount'] = $config['total_rows'];
		$result['records'] = $dataset->result();
		
		return $result;
	}	
}

if (! function_exists('search_highlight')) {
	function search_highlight($keyword, $phase) {
		
		$pattern = "/$keyword/i";		
		return (preg_replace($pattern, "<span class='search-highlight'>$0</span>", $phase));
		
	}
}

