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