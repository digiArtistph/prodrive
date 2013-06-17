<?php if( !defined('BASEPATH')) exit('Direct script access not allowed');

class Mdl_receiving extends CI_Model {
	
	//SELECT vo.vo_id, CONCAT(v.make, ' -- ', vo.plateno) AS `vehicle` FROM vehicle_owner vo LEFT JOIN vehicle v ON vo.make=v.v_id WHERE owner=5;
	
	public function add() {
		global $almd_userid;
			
		// preps some data
		$curdate = mysql_real_escape_string($this->input->post('recdate'));
		$customerCode = mysql_real_escape_string($this->input->post('customercode'));
		$vehicleCode = mysql_real_escape_string($this->input->post('ownedvehiclecode'));
		$receivedBy = $almd_userid;
		$strQry = sprintf("INSERT INTO vehicle_receive SET customer=%d, vehicle=%d, recdate='%s', recby=%d",
					$customerCode, $vehicleCode, $curdate, $receivedBy);
					
		if(! $this->db->query($strQry))
			return FALSE;
			
		return  TRUE;
		
	}
	
	public function edit() {
		global $almd_userid;
			
		// preps some data
		$curdate = mysql_real_escape_string($this->input->post('recdate'));
		$customerCode = mysql_real_escape_string($this->input->post('customercode'));
		$vehicleCode = mysql_real_escape_string($this->input->post('ownedvehiclecode'));
		$rcvCode = mysql_real_escape_string($this->input->post('rcvcode'));
		$receivedBy = $almd_userid;
		$strQry = sprintf("UPDATE vehicle_receive SET customer=%d, vehicle=%d, recdate='%s', recby=%d WHERE vr_id=%d",
				$customerCode, $vehicleCode, $curdate, $receivedBy, $rcvCode);
			
		if(! $this->db->query($strQry))
			return FALSE;
			
		return  TRUE;
	
	}
	
	public function retrieve() {
		
		$strQry = "SELECT vr.vr_id, CONCAT(c.lname, ', ', c.fname) AS `customer`, CONCAT(vo.plateno, ', ', v.make) AS `plateno` FROM (((vehicle_receive vr LEFT JOIN customer c ON vr.customer=c.custid) LEFT JOIN vehicle_owner vo ON vr.vehicle=vo.vo_id) LEFT JOIN vehicle v ON vo.make=v.v_id)  WHERE vr.`status`='1' ORDER BY c.lname ASC";
		$resultset = $this->db->query($strQry);
		
		$data['count'] = $resultset->num_rows;
		$data['records'] = $resultset->result();
		
		return $data;
	}
	
	public function retrieveqry($id = ''){
	
		$strqry = sprintf("SELECT vr.vr_id, vr.customer, vr.vehicle, vr.recdate, v.make as vname, CONCAT(c.lname, ', ', c.fname) as custname FROM `vehicle_receive` vr LEFT JOIN customer c on c.custid=vr.customer LEFT JOIN vehicle v on v.v_id=vr.vehicle WHERE vr_id=%d", $id);
		$resultset = $this->db->query($strqry);
		$data['records'] = $resultset->result();
		
		return $data;
	}
	
	public function paginate() {
		
		$config['base_url'] = base_url('tranx/receiving/section/receiving');
		$config['query'] = sprintf("SELECT vr.vr_id, CONCAT(c.lname, ', ', c.fname) AS `customer`, CONCAT(vo.plateno, ', ', v.make) AS `plateno` FROM (((vehicle_receive vr LEFT JOIN customer c ON vr.customer=c.custid) LEFT JOIN vehicle_owner vo ON vr.vehicle=vo.vo_id) LEFT JOIN vehicle v ON vo.make=v.v_id)  WHERE vr.`status`='1' ORDER BY c.lname ASC %s", '');
		$config['callback'] = 'readFilterPerPage';
		$result = paginate($config);
		
		return $result;
		
	}
	
}