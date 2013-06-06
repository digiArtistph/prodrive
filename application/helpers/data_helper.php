<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

function dmax() {
	$CI =& get_instance();
	
	$strQry = "CALL sp_dmax()"; 	
	
	return;
}