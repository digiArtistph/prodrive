<?php if (!defined('BASEPATH')) exit ('No direct script access allowed.');

class Mdl_category extends CI_Model{
	
	public function retrieveAllCategories($id = '') {
		
		if(empty($id)) {
			$strQry = sprintf("SELECT * FROM categories");
		} else {
			$strQry = sprintf("SELECT * FROM categories WHERE categ_id=%d", $id);
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
		$config['query'] = sprintf("SELECT * FROM categories ORDER BY category ASC %s", '');
		$config['callback'] = 'readFilterPerPage';
		$result = paginate($config);
		
		return $result;
		
	}
	
	
}