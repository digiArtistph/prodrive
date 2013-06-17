<?php if (!defined('BASEPATH')) exit ('No direct script access allowed.');

class Mdl_labortype extends CI_Model{
	
	public function retrieveAllLaborType($id = '') {
		
		if(empty($id)) {
			$strQry = sprintf("SELECT * FROM labortype lt LEFT JOIN categories c ON lt.category=c.categ_id");
		} else {
			$strQry = sprintf("SELECT * FROM labortype WHERE laborid=%d", $id);
		}
		
		$resultset = $this->db->query($strQry);
		
		if($resultset->num_rows < 1)
			return FALSE;
			
		$record['count'] = $resultset->num_rows;
		$record['records'] = $resultset->result();
		
		return $record;
		
	}
	
	public function paginate() {
		
		$config = array(
						'base_url' => base_url('master/labortype/section/viewlabortype'),
						'query' => sprintf("SELECT * FROM labortype lt LEFT JOIN categories c ON lt.category=c.categ_id %s", ''),
						'callback' => 'readFilterPerPage'
					);
		
		$result = paginate($config);
		
		return $result;
	}
	
	
}