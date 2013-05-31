<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Ajaxjo extends CI_Controller {
	
	function __construct(){
		parent::__construct();
	}
	
	public function createtable(){
		$query = $this->db->query('CALL sp_create_jo_cache();');
		if(!$query)
			echo '1';
		else
			echo '0';
	}
	
	
	//	CALL sp_insert_jo_cache( p_labor INT, p_partmaterial text, p_details text, p_amnt, @p_last_id , @p_status  );
	public function addjodet(){
		$jo_type = $this->input->post('labor');
		
		if($jo_type == 'labor'){
			$strqry = 'CALL sp_insert_jo_cache( '. $this->input->post('part') .', "", "'. $this->input->post('det') .'", '. $this->input->post('amnt') .', @p_last_id , @p_status  );';
		}else{
			$strqry = 'CALL sp_insert_jo_cache( 0, "'. $this->input->post('part') .'", "'. $this->input->post('det') .'", '. $this->input->post('amnt') .', @p_last_id , @p_status  );';
		}
		
		$query = $this->db->query($strqry);

		if(!$query)
			return false;
		
		
		$strqry2 = 'SELECT @p_last_id as id, @p_status as status;';
		
		$query2 = $this->db->query($strqry2);
		if(!$query2)
			return false;
		
		//echo $strqry;
		$result = '';
		foreach ( $query2->result() as $res){
			$result = $res->id . '|' . $res->status;
		}
		
		echo $result;
	}
	
	public function savejoborder(){
		$strqry = sprintf('CALL sp_addJO(%d, %d, %d, "%s", %d, "%s", "%s", "%s", @id );', $this->input->post('jo_num'),  $this->input->post('vehicle'), $this->input->post('cust'), $this->input->post('p_plate'), $this->input->post('p_color'), $this->input->post('phone'),  $this->input->post('addr'),  $this->input->post('jo_date') );
		$query = $this->db->query($strqry);
		
		if(!$query)
			return false;
		
		$strqry2 = sprintf('SELECT @id as id');
		$query2 = $this->db->query($strqry2);
		
		if(!$query2)
			return false;
		
		$result = '';
		foreach ( $query2->result() as $res){
			$result = $res->id;
		}
		
		echo $result;
	}
	
}