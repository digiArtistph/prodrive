<?php if (!defined('BASEPATH')) exit ('No direct script access allowed.');

class Mdl_ownedvehicle extends CI_Model {
	
	private $tableName;
	
	public function __construct() {
		
		$this->tableName = "vehicle_owner";
		
	}
	
	public function add() {
		
		// preps data
		$plateNo = trim(mysql_real_escape_string(parsePlateNo($this->input->post('plateno'))));
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
		
		$strQry = sprintf("SELECT vo.vo_id, v.make, vo.plateno, CONCAT(lname, ', ', fname) AS `owner`  FROM (($this->tableName vo LEFT JOIN vehicle v ON vo.make=v.v_id) LEFT JOIN customer c ON vo.owner=c.custid) WHERE vo.`status`='1' ORDER BY c.lname");
		$resultset = $this->db->query($strQry);
		
		$data['count'] = $resultset->num_rows;
		$data['records'] = $resultset->result();
		
		return $data;
	}
	
	public function retrieve_vehicle($id = '') {
		if(empty($id))
			return false;
		
		$strQry = sprintf("SELECT  vo.vo_id as `id`, vo.plateno as `platenum`, vo.make as `makeid`, v.make as `makename`, vo.color as `colorid`, clr.name as `colorname`, vo.description, vo.owner as `ownerid`, CONCAT(lname, ', ', fname) AS `ownername`  FROM ((vehicle_owner vo LEFT JOIN vehicle v ON vo.make=v.v_id) LEFT JOIN customer c ON vo.owner=c.custid LEFT JOIN color clr ON vo.color=clr.clr_id ) WHERE vo.`status`='1' AND vo.vo_id=%d ORDER BY c.lname", $id);
		$resultset = $this->db->query($strQry);
	
		return $resultset->result();
	}
	
	public function edit() {
	
		// preps data
		$vehicleNo = mysql_real_escape_string($this->input->post('vehiclecode'));
		$plateNo = trim(mysql_real_escape_string($this->input->post('plateno')));
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
	
	public function paginate() {
		
		$config['base_url'] = base_url('master/ownedvehicle/section/ownedvehicle');
		$config['query'] = sprintf("SELECT vo.vo_id, v.make, vo.plateno, CONCAT(lname, ', ', fname) AS `owner`  FROM ((vehicle_owner vo LEFT JOIN vehicle v ON vo.make=v.v_id) LEFT JOIN customer c ON vo.owner=c.custid) WHERE vo.`status`='1' ORDER BY c.lname %s", '');
		$config['callback'] = 'readFilterPerPage';
		$result = paginate($config);
		return $result;
	}
	
	public  function find($search) {
		
		$strQry = sprintf("SELECT vo.vo_id, v.make, vo.plateno, CONCAT(c.lname, ', ', c.fname) AS `owner`  FROM ((vehicle_owner vo LEFT JOIN vehicle v ON vo.make=v.v_id) LEFT JOIN customer c ON vo.owner=c.custid) WHERE (v.make LIKE '%c%s%c' OR c.lname LIKE '%c%s%c' OR c.fname LIKE '%c%s%c') WHERE vo.`status`='1' ORDER BY c.lname", 37,$search,37,37,$search,37,37,$search,37);				
		$dataset = $this->db->query($strQry);
		$result['overallcount'] = $dataset->num_rows;
		$result['paginate'] = "";
		$result['records'] = $dataset->result();
		
		return $result;
	}
	
	public function isOwnerPlateNoExists($plateNo, $owner) {
		$plateNo = trim(mysql_real_escape_string(parsePlateNo($plateNo)));
		$owner = trim(mysql_real_escape_string($owner));
		
		// checks for duplicate plate-owner
		$strQry = sprintf("SELECT * FROM $this->tableName WHERE plateno='%s' AND owner=%d", $plateNo, $owner);		
		$count = $this->db->query($strQry)->num_rows;
		
		if($count > 0 )			
			return 1;
			
		// checks for duplicate plate only
		$strQryPlateOnly = sprintf("SELECT * FROM $this->tableName WHERE plateno='%s'", $plateNo);
		$countDuplicatePlateOnly = $this->db->query($strQryPlateOnly)->num_rows;

		if($countDuplicatePlateOnly > 0)
			return 2;
			
		return FALSE;

	}
}