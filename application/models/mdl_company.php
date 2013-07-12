<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Mdl_company extends CI_Model {
	
	private $tableName;
	
	public function __construct() {
		
		$this->tableName = "company";
		
	}
	
	public function retrieveAllCompany() {
		
		$strQry = sprintf("SELECT * FROM $this->tableName WHERE `status`='1'");
		$resultset = $this->db->query($strQry);
		
		$record['count'] = $resultset->num_rows;
		$record['records'] = $resultset->result();
		
		return $record;
	
	}
	
	public function isUserExists($name) {
		
		$strQry = sprintf("SELECT name FROM $this->tableName WHERE name='%s'", $name);
		
		if($this->db->query($strQry)->num_rows < 1)
			return FALSE;
			
		return TRUE;
	}
	
	public function addCompany() {
		
		// preps data from user
		$strQry = sprintf("INSERT INTO company (name, addr, phone, fax, email, url) VALUES('%s', '%s', '%s', '%s', '%s', '%s')",
		mysql_real_escape_string($this->input->post('companyname')),
		mysql_real_escape_string($this->input->post('addr')),
		mysql_real_escape_string($this->input->post('phone')),
		mysql_real_escape_string($this->input->post('fax')),
		mysql_real_escape_string($this->input->post('email')),
		mysql_real_escape_string($this->input->post('url')));

		if(!$this->db->query($strQry))
			return FALSE;
			
		return TRUE;
		
	}
	
	public function deleteCompany($id) {
		
		$strQry =sprintf("UPDATE $this->tableName SET `status`='0' WHERE co_id=%d", $id);
				
		if(! $this->db->query($strQry))
			return FALSE;
			
		return TRUE;

	}
	
	public function updateCompany($id) {
		
		$strQry = sprintf("UPDATE company SET name='%s', addr='%s', phone='%s', fax='%s', email='%s', url='%s' WHERE co_id=%d",
		mysql_real_escape_string($this->input->post('companyname')),
		mysql_real_escape_string($this->input->post('addr')),
		mysql_real_escape_string($this->input->post('phone')),
		mysql_real_escape_string($this->input->post('fax')),
		mysql_real_escape_string($this->input->post('email')),
		mysql_real_escape_string($this->input->post('url')),
		$id);
//on_watch($strQry);
		if(!$this->db->query($strQry))
			return FALSE;
			
		return TRUE;
		
	}
	
	public function retrieveCompany($id) {
		
		$strQry = sprintf("SELECT * FROM company WHERE co_id=%d", $id);
		$record = $this->db->query($strQry)->result();
		
		return $record;
		
	}
	
	public function paginate() {
		
		$config['base_url'] = base_url('master/company/section/company');
		$config['query'] = sprintf("SELECT * FROM company WHERE `status`='1' %s", '');
		$config['callback'] = 'readFilterPerPage';
		$result = paginate($config);
		
		return $result;
		
	}
	
	public  function find($search) {
		
		$strQry = sprintf("SELECT * FROM $this->tableName WHERE `status`='1' AND name LIKE '%c%s%c'", 37, $search, 37);				
		$dataset = $this->db->query($strQry);
		$result['overallcount'] = $dataset->num_rows;
		$result['paginate'] = "";
		$result['records'] = $dataset->result();
		
		return $result;
	}
}