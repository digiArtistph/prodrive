<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Mdl_utility extends CI_Model {

	public  function userHasAccess() {
		global $almd_useraccess;
		
		if($almd_useraccess < 3)
			return FALSE;
			
		return TRUE;
	}
	
}