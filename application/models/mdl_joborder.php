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

}