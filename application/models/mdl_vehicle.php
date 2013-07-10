<?php if( !defined('BASEPATH')) exit('Direct script access not allowed');

class Mdl_vehicle extends CI_Model { 
	
	private $tableName;
	
	public function __construct() {
		
		$this->tableName = "vehicle";
		
	}
	
	public function retrieveAllVehicles($id= '') {
		
		if(empty($id)) {
			$strQry = sprintf("SELECT * FROM $this->tableName WHERE `status`='1'");
		} else {
			$strQry = sprintf("SELECT * FROM $this->tableName WHERE `status`='1' AND v_id=%d", $id);
		}
		
		$resultset = $this->db->query($strQry);
		
		if($resultset->num_rows < 1)
			return FALSE;
			
		$record['count'] = $resultset->num_rows;
		$record['records'] = $resultset->result();
		
		return $record;		
	}
	
	public function paginate() {
		
		$config['base_url'] = base_url('master/vehicle/section/viewvehicle');
		$config['query'] = sprintf("SELECT * FROM vehicle WHERE `status`='1' %s", '');
		$config['callback'] = 'readFilterPerPage';
		$result = paginate($config);
		
		return $result;
	}
	
	public  function find($search) {
		
		$strQry = sprintf("SELECT * FROM $this->tableName WHERE `status`='1' AND make LIKE '%c%s%c'", 37,$search,37);				
		$dataset = $this->db->query($strQry);
		$result['overallcount'] = $dataset->num_rows;
		$result['paginate'] = "";
		$result['records'] = $dataset->result();
		
		return $result;
	}
	
}