<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Mdl_customer extends CI_Model {
	
	public function retrieveAllCompany() {
		
		$strQry = sprintf("SELECT * FROM company WHERE `status`='1'");
		$record = $this->db->query($strQry)->result();
		
		return $record;
	}
}