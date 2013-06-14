<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Mdl_customer extends CI_Model {
	
	public function retrieveAllCompany() {
		
		$strQry = sprintf("SELECT * FROM company WHERE `status`='1'");
		$record = $this->db->query($strQry)->result();
		
		return $record;
	}
	
	public function retrieveAllCustomers($id = '') {
		
		if(empty($id)) {
			$strQry = sprintf("SELECT * FROM customer WHERE `status`='1'");
		} else {
			$strQry = sprintf("SELECT * FROM customer WHERE custid=%d", $id);
		}
		
		$resultset = $this->db->query($strQry);
		
		if($resultset->num_rows < 1)
			return FALSE;
			
		$record['count'] = $resultset->num_rows;
		$record['records'] = $resultset->result();
		
		return $record;
	}
	
}