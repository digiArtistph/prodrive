<?php if( !defined('BASEPATH')) exit('Direct script access not allowed');

class Mdl_users extends CI_Model {
	
	public  function userHasAccess() {
		global $almd_useraccess;
		
		if($almd_useraccess < 3)
			return FALSE;
			
		return TRUE;
	}
	
	public function retrieveAllUsers($id = '') {
		
		if(empty($id)) {
			$strQry = sprintf("SELECT us.u_id, us.fname, us.mname, us.lname, us.username, us.addr, us.status, ut.type, ut.id FROM users us LEFT JOIN usertype ut ON us.ut_id=ut.id");
		} else {
			$strQry = sprintf("SELECT us.u_id, us.fname, us.mname, us.lname, us.username, us.addr, us.status, ut.type, ut.id FROM users us LEFT JOIN usertype ut ON us.ut_id=ut.id WHERE us.u_id=%d", $id);
		}

		$resultset = $this->db->query($strQry);
		
		if($resultset->num_rows < 1)
			return FALSE;
		
		$record['count'] = $resultset->num_rows;
		$record['records'] = $resultset->result();
		
		return $record;
		
	}
	
	public function paginate() {
		
		$config['base_url'] = base_url('aster/users/section/viewusers');
		$config['query'] = sprintf("SELECT us.u_id, us.fname, us.mname, us.lname, us.username, us.addr, us.status, ut.type, ut.id FROM users us LEFT JOIN usertype ut ON us.ut_id=ut.id ORDER BY lname ASC %s", '');
		$config['callback'] = 'readFilterPerPage';
		$result = paginate($config);
		
		return $result;
	
	}
	
}

