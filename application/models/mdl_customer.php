<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Mdl_customer extends CI_Model {
	private $tableName;
	
	public function __construct() {
		
		$this->tableName = "customer";
		
	}
	
	public function retrieveAllCompany() {
		
		$strQry = sprintf("SELECT * FROM company WHERE `status`='1'");
		$record = $this->db->query($strQry)->result();
		
		return $record;
	}
	
	public function retrieveAllCustomers($id = '') {
		
		if(empty($id)) {
			$strQry = sprintf("SELECT custid, CONCAT(lname, ', ', fname) AS fullname, addr, phone, company FROM customer WHERE `status`='1' ORDER BY lname");
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
	
	
	public function paginate() {
		
		$result = paginate(array('callback' => 'readFilterPerPage'));
		
		return $result;
	}
	
	public  function find($search) {		
		$strQry = sprintf("SELECT custid, CONCAT(lname, ', ', fname) AS fullname, addr, phone, company FROM $this->tableName WHERE `status`='1' AND (lname LIKE '%c%s%c' OR fname LIKE '%c%s%c')", 37, $search, 37, 37, $search, 37);				
		$dataset = $this->db->query($strQry);
		$result['overallcount'] = $dataset->num_rows;
		$result['paginate'] = "";
		$result['records'] = $dataset->result();
		
		return $result;
	}

	public function isCustomerExists($fname, $lname) {
		$fname = trim(mysql_real_escape_string($fname));
		$lname = trim(mysql_real_escape_string($lname));
		
		$strQry = sprintf("SELECT * FROM $this->tableName WHERE fname='%s' AND lname='%s'", $fname, $lname);
		$count = $this->db->query($strQry)->num_rows;
		
		if($count < 1)
			return FALSE;
			
		return TRUE;
			
	}
	
}