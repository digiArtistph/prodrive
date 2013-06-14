<?php if( !defined('BASEPATH')) exit('Direct script access not allowed');

class Mdl_vehicle extends CI_Model { 
	
	public function retrieveAllVehicles($id= '') {
		
		if(empty($id)) {
			$strQry = sprintf("SELECT * FROM vehicle WHERE `status`='1'");
		} else {
			$strQry = sprintf("SELECT * FROM vehicle WHERE `status`='1' AND v_id=%d", $id);
		}
		
		$resultset = $this->db->query($strQry);
		
		if($resultset->num_rows < 1)
			return FALSE;
			
		$record['count'] = $resultset->num_rows;
		$record['records'] = $resultset->result();
		
		return $record;		
	}
	
}