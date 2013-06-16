<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Mdl_customer extends CI_Model {
	
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
/*
		$id = ($this->uri->segment(5)) ? $this->uri->segment(5) : 0;
		$this->load->library('pagination');		
		$strQry = sprintf("SELECT custid, CONCAT(lname, ', ', fname) AS fullname, addr, phone, company FROM customer WHERE `status`='1' ORDER BY lname %s", '');	
			
		$config = array(
						'base_url' => base_url('master/customer/section/viewcustomer'),
						'total_rows' => $this->db->query($strQry)->num_rows,
						'per_page' => 10,
						'num_links' => 2,
						'uri_segment' => 5					
					);
		
		// overides the default settings
		$config = array_merge($config, $params);
		$this->pagination->initialize($config);
		
		// preps data
		$strQry = sprintf($strQry . " LIMIT %d, %d", $id, $config['per_page']);
		
		// retrieves datasets
		$dataset = $this->db->query($strQry);
		$result['paginate'] = $this->pagination->create_links();
		$result['count'] = $dataset->num_rows;
		$result['overallcount'] = $config['total_rows'];
		$result['records'] = $dataset->result();
*/
		$result = paginate(array('per_page' => 5));
		
		return $result;
	}
	
}