<?php if( !defined('BASEPATH')) exit('Direct script access not allowed');

class Mdl_colors extends CI_Model {
	
	public function retrieveAllColors($id = '') {
		
		if(empty($id)) {
			$strQry = sprintf("SELECT * FROM color");			
		} else {
			$strQry = sprintf("SELECT * FROM color WHERE clr_id=%d", $id);
		}

		$resultset = $this->db->query($strQry);
		
		if($resultset->num_rows < 1)
			return FALSE;
			
		$record['count'] = $resultset->num_rows;
		$record['records'] = $resultset->result();
		
		return $record;
		
	}
	
}