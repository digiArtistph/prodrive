<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class mdl_joborder extends CI_Model{
	
	private $tableName;
	
	public function __construct() {
		
		$this->tableName = "customer";
		
	}
	
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

	public function paginate() {
		
		$config['base_url'] = base_url('tranx/joborder/section/viewjobrder');
		$config['query'] = sprintf("SELECT jo.jo_number as jo_num,jo.jo_id, ve.make as vehicle, cl.name as color, cr.fname, cr.mname, cr.lname, CONCAT(cr.lname, ', ', cr.fname) AS owner, jo.plate, jo.contactnumber as num, jo.address as addr, jo.trnxdate as date, fnc_joPayment(jo.jo_id) AS `balance`, fnc_dcrPayments(jo.jo_id) AS `payment` FROM joborder jo LEFT JOIN vehicle ve on ve.v_id=jo.v_id LEFT JOIN customer cr on cr.custid=jo.customer LEFT JOIN color cl on cl.clr_id=jo.color WHERE jo.`status`='1' ORDER BY jo.`jo_id` DESC %s", '');
		$config['callback'] = 'readFilterPerPage';
		$result = paginate($config);
		
		return $result;
		
	}
	
	public  function find($search) {
		
		$strQry = sprintf("SELECT jo.jo_number as jo_num,jo.jo_id, ve.make as vehicle, cl.name as color, cr.fname, cr.mname, cr.lname, CONCAT(cr.lname, ', ', cr.fname) AS owner, jo.plate, jo.contactnumber as num, jo.address as addr, jo.trnxdate as date, fnc_joPayment(jo.jo_id) AS `balance`, fnc_dcrPayments(jo.jo_id) AS `payment` FROM joborder jo LEFT JOIN vehicle ve on ve.v_id=jo.v_id LEFT JOIN customer cr on cr.custid=jo.customer LEFT JOIN color cl on cl.clr_id=jo.color WHERE jo.`status`='1' AND (cr.lname LIKE '%c%s%c' OR cr.fname LIKE '%s%c%s' OR jo.plate LIKE '%c%s%c') ORDER BY jo.`jo_id` DESC %s",37,$search,37,37, $search,37, 37, $search,37,'');				
		$dataset = $this->db->query($strQry);
		$result['overallcount'] = $dataset->num_rows;
		$result['paginate'] = "";
		$result['records'] = $dataset->result();
		
		return $result;
	}
	
}