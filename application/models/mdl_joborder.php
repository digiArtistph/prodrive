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

	public function getJoTotal($id) {
		
		$strQry = sprintf("SELECT SUM(amnt) AS `total` FROM jodetails WHERE jo_id=%d", $id);
		$record = $this->db->query($strQry)->result();
		
		foreach($record as $rec) {
			return ($rec->total != '') ? $rec->total : '0.00';
		}
		
	}
	
	public function getJoBalance($id) {
		
		$strQry = sprintf("SELECT fnc_joPayment(%d) AS `total`", $id);
		
	$record = $this->db->query($strQry)->result();
		
		foreach($record as $rec) {
			return ($rec->total != '') ? $rec->total : '0.00';
		}
	}
	
public function getDcrPayments($id) {
		
		$strQry = sprintf("SELECT fnc_dcrPayments(%d) AS `total`", $id);
		
	$record = $this->db->query($strQry)->result();
		
		foreach($record as $rec) {
			return ($rec->total != '') ? $rec->total : '0.00';
		}
	}

}