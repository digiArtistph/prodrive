<?php if (!defined('BASEPATH')) exit ('No direct script access allowed.');

class mdl_autocomplete extends CI_Model{
	
	public function findkeywordsingle($table, $culumn, $word){
		
		
		$strqry = 'SELECT `'. $culumn .'` FROM `'. $table. '` WHERE `'. $culumn .'`  like "'. $word .'%" ORDER BY `'. $culumn .'` ASC';
		
		$query = $this->db->query($strqry);
		
		if( $query->num_rows() <1 )
			return false;
		
		$rows = array();
		foreach($query->result_array() as $row )
		{
			$rows[] = $row[$culumn];
		}
		
		return $rows;
	}
	
	public function findkeyword($table, $culumn1, $culumn2, $word){
	
	
		$strqry = 'SELECT `'. $culumn1 .'`, `'. $culumn2 .'` FROM `'. $table. '` WHERE `'. $culumn2 .'`  like "'. $word .'%" ORDER BY `'. $culumn2 .'` ASC';
	
		$query = $this->db->query($strqry);
	
		if( $query->num_rows() <1 )
			return false;
	
		$rows = array();
		//call_debug($query->result_array());
		foreach($query->result_array() as $row )
		{
			$temp = array($culumn1 => $row[$culumn1], $culumn2 => $row[$culumn2]);
			array_push($rows, $temp);
	
		}
		return $rows;
	}
	
	public function findkeyword3($word){
	
	
		$strqry = 'SELECT custid as cid, fname, mname, lname FROM customer  WHERE fname like "'. $word .'%"  UNION SELECT custid as cid, fname, mname, lname FROM customer  WHERE mname like "'. $word .'%" UNION SELECT custid as cid, fname, mname, lname FROM customer  WHERE lname like "'. $word .'%" ';
	
		$query = $this->db->query($strqry);
	
		if( $query->num_rows() <1 )
			return false;
	
		$rows = array();		
		foreach($query->result_array() as $row )
		{
			$name = ucfirst($row['fname']) . ' ' . ucfirst($row['mname'][0]) . '.' . ucfirst($row['lname']);
			$temp = array('id' => $row['cid'], 'name' => $name);
			array_push($rows, $temp);
	
		}
		return $rows;
	}
	
	
	public function vehicle() {
		
		$term = $this->input->get('term');
		$strQry = "SELECT v_id AS `index`, make AS `value`  FROM vehicle WHERE make LIKE '%" . $term . "%'";
		$resultset= $this->db->query($strQry)->result();
		
		return $resultset;
	}
	
	public function color() {
		
		$term = $this->input->get('term');
		$strQry = "SELECT clr_id AS `index`, name AS `value`  FROM color WHERE name LIKE '%" . $term . "%'";
		$resultset= $this->db->query($strQry)->result();
		
		return $resultset;
	}
	
	public function customer() {
		
		$term = $this->input->get('term');
		$strQry = "SELECT custid AS `index`, CONCAT(lname, ', ', fname)  AS `value`  FROM customer WHERE lname LIKE '%" . $term . "%' AND `status`='1' ORDER BY lname";
		$resultset= $this->db->query($strQry)->result();
		
		return $resultset;
	}
	
	public function ownedvehicle() {
		$customer = $this->input->post('post_customer');
		
		$strQry = sprintf("SELECT vo.vo_id AS `index`, CONCAT(v.make, ' -- ', vo.plateno) AS `value` FROM vehicle_owner vo LEFT JOIN vehicle v ON vo.make=v.v_id WHERE owner=%d AND vo.`status`='1'", $customer);
		$resultset = $this->db->query($strQry)->result();
		
		return $resultset;
	}
	
	public function getvehiclereceived() {
		
		$customer = $this->input->post('post_customer');
		$strQry = sprintf("SELECT c.custid, CONCAT(c.lname, ', ', c.fname) AS `customer`, vr.vehicle AS `ownedvehicle`, vo.plateno, v.make  FROM (((customer c LEFT JOIN vehicle_receive vr ON c.custid=vr.customer) LEFT JOIN vehicle_owner vo ON vr.vehicle=vo.vo_id) LEFT JOIN vehicle v ON vo.make=v.v_id) WHERE c.`status`='1' AND vr.`status`='1' AND vo.`status`='1' AND c.custid=%d",
			$customer);
		$resultset = $this->db->query($strQry)->result();
		
		return $resultset;
		
	}
	//SELECT CONCAT(c.lname, ', ', c.fname) AS `customer`, vr.vehicle FROM (customer c LEFT JOIN vehicle_receive vr ON c.custid=vr.customer) WHERE c.`status`='1' AND vr.`status`='1';
	// SELECT c.custid, CONCAT(c.lname, ', ', c.fname) AS `customer`, vr.vehicle AS `ownedvehicle`, vo.plateno  FROM ((customer c LEFT JOIN vehicle_receive vr ON c.custid=vr.customer) LEFT JOIN vehicle_owner vo ON vr.vehicle=vo.vo_id) WHERE c.`status`='1' AND vr.`status`='1' AND vo.`status`='1';
}