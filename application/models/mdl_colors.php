<?php if( !defined('BASEPATH')) exit('Direct script access not allowed');

class Mdl_colors extends CI_Model {

	private $tableName;
	
	public function __construct() {
		
		$this->tableName = "color";
		
	}
	public function retrieveAllColors($id = '') {
		
		if(empty($id)) {
			$strQry = sprintf("SELECT * FROM $this->tableName ORDER BY name");			
		} else {
			$strQry = sprintf("SELECT * FROM $this->tableName WHERE clr_id=%d", $id);
		}

		$resultset = $this->db->query($strQry);
		
		if($resultset->num_rows < 1)
			return FALSE;
			
		$record['count'] = $resultset->num_rows;
		$record['records'] = $resultset->result();
		
		return $record;
		
	}
	
	public function paginate() {
		
		$config['base_url'] = base_url('master/color/section/viewcolor');
		$config['query'] = sprintf("SELECT * FROM color ORDER BY name ASC %s", '');
		$config['callback'] = 'readFilterPerPage';
		$result = paginate($config);
		
		return $result;
		
	}

	public  function find($search) {
		
		$strQry = sprintf("SELECT * FROM $this->tableName WHERE name LIKE '%c%s%c' ORDER BY name", 37, $search,37);				
		$dataset = $this->db->query($strQry);
		$result['overallcount'] = $dataset->num_rows;
		$result['paginate'] = "";
		$result['records'] = $dataset->result();
		
		return $result;
	}
}