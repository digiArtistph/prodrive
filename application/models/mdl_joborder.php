<?php
class mdl_joborder extends CI_Model{
	
	public function get_orders(){
		
		$sql = 'SELECT * FROM jo';
		$results = $this->db->query($sql)->result();
		return $results;
	}
	
	public function set_jo($params){
		$tablename = 'jo';
		$sql = 'INSERT INTO ' . $tablename . ' SET name="'. $params->name .'", address="' . $params->address . '", jodate="'. $params->jodate . '",vid="' .$params->vid .'",plate="' . $params->plate.'",color="' . $params->color .'",contact="'. $params->contact .'"';
		$this->db->query($sql);
		return true;
	}

	public function insert_joborder($params){
		
	}
	
	//SELECT CONCAT(c.lname, ', ', c.fname) AS `customer`, vr.vehicle FROM (customer c LEFT JOIN vehicle_receive vr ON c.custid=vr.customer) WHERE c.`status`='1' AND vr.`status`='1';
	// SELECT c.custid, CONCAT(c.lname, ', ', c.fname) AS `customer`, vr.vehicle AS `ownedvehicle`, vo.plateno  FROM ((customer c LEFT JOIN vehicle_receive vr ON c.custid=vr.customer) LEFT JOIN vehicle_owner vo ON vr.vehicle=vo.vo_id) WHERE c.`status`='1' AND vr.`status`='1' AND vo.`status`='1';
}