<?php if( !defined('BASEPATH')) exit('Direct script access not allowed');

class Mdl_users extends CI_Model {
	
	public  function userHasAccess() {
		global $almd_useraccess;
		
		if($almd_useraccess < 3)
			return FALSE;
			
		return TRUE;
	}
}