<?php if (!defined('BASEPATH')) exit ('No direct script access allowed.');

class Mdl_category extends CI_Model{
	
	private $tableName;
	
	public function __construct() {
		
		$this->tableName = "categories";
		
	}
	
	public function retrieveAllCategories($id = '') {
		
		if(empty($id)) {
			$strQry = sprintf("SELECT * FROM $this->tableName");
		} else {
			$strQry = sprintf("SELECT * FROM $this->tableName WHERE categ_id=%d", $id);
		}
		
		$resultset = $this->db->query($strQry);
		
		if($resultset->num_rows < 1)
			return FALSE;
		
		$record['count'] = $resultset->num_rows;
		$record['records'] = $resultset->result();
		
		return $record;
		
	}
	
	public function paginate() {
		
		$config['base_url'] = base_url('master/categories/section/viewcategories');
		$config['query'] = sprintf("SELECT * FROM $this->tableName ORDER BY category ASC %s", '');
		$config['callback'] = 'readFilterPerPage';
		$result = paginate($config);
		
		return $result;
		
	}
	
	public  function find($search) {
		
		$strQry = sprintf("SELECT * FROM $this->tableName WHERE category LIKE '%c%s%c'", 37,$search,37);				
		$dataset = $this->db->query($strQry);
		$result['overallcount'] = $dataset->num_rows;
		$result['paginate'] = "";
		$result['records'] = $dataset->result();
		
		return $result;
	}	
}