<?php if (!defined('BASEPATH')) exit ('No direct script access allowed.');

class Mdl_ownedvehicle extends CI_Model {
	
	public function add() {
		
		// preps data
		$plateNo = mysql_real_escape_string($this->input->post('plateno'));
		$make = mysql_real_escape_string($this->input->post('makecode'));
		$color = mysql_real_escape_string($this->input->post('colorcode'));
		$description = mysql_real_escape_string($this->input->post('description'));
		$customer = mysql_real_escape_string($this->input->post('customercode'));
		
		$strQry = sprintf("INSERT INTO vehicle_owner SET plateno='%s', color=%d, make=%d, description='%s', owner=%d",
				$plateNo, $color, $make, $description, $customer);
				
		if(! $this->db->query($strQry))	
			return FALSE;
		
		return TRUE;
	}
	
	public function retrieve() {
		
		$strQry = sprintf("SELECT vo.vo_id, v.make, vo.plateno, CONCAT(lname, ', ', fname) AS `owner`  FROM ((vehicle_owner vo LEFT JOIN vehicle v ON vo.make=v.v_id) LEFT JOIN customer c ON vo.owner=c.custid) ORDER BY c.lname");
		$resultset = $this->db->query($strQry);
		
		$data['count'] = $resultset->num_rows;
		$data['records'] = $resultset->result();
		
		return $data;
	}
	
	public function retrieve_vehicle($id = '') {
		if(empty($id))
			return false;
		
		$strQry = sprintf("SELECT  vo.vo_id as `id`, vo.plateno as `platenum`, vo.make as `makeid`, v.make as `makename`, vo.color as `colorid`, clr.name as `colorname`, vo.description, vo.owner as `ownerid`, CONCAT(lname, ', ', fname) AS `ownername`  FROM ((vehicle_owner vo LEFT JOIN vehicle v ON vo.make=v.v_id) LEFT JOIN customer c ON vo.owner=c.custid LEFT JOIN color clr ON vo.color=clr.clr_id ) WHERE vo.vo_id=%d ORDER BY c.lname", $id);
		$resultset = $this->db->query($strQry);
	
		return $resultset->result();
	}
	
	public function edit() {
	
		// preps data
		$vehicleNo = mysql_real_escape_string($this->input->post('vehiclecode'));
		$plateNo = mysql_real_escape_string($this->input->post('plateno'));
		$make = mysql_real_escape_string($this->input->post('makecode'));
		$color = mysql_real_escape_string($this->input->post('colorcode'));
		$description = mysql_real_escape_string($this->input->post('description'));
		$customer = mysql_real_escape_string($this->input->post('customercode'));
	
		$strQry = sprintf("UPDATE vehicle_owner SET plateno='%s', color=%d, make=%d, description='%s', owner=%d WHERE vo_id=%d",
				$plateNo, $color, $make, $description, $customer, $vehicleNo);
	
		if(! $this->db->query($strQry))
			return FALSE;
	
		return TRUE;
	}
}