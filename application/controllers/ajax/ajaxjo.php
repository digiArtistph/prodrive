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
	
	public function editjodet(){
		$jo_type = $this->input->post('labor');
		
		if($jo_type == 'labor'){
			$strqry = sprintf('UPDATE `tmp_jo_details_cache` SET labor=%d, partmaterial=null,details="%s", amnt="%s" WHERE `trace_id`=%d', $this->input->post('part'),$this->input->post('det'),$this->input->post('amnt'), $this->input->post('id') );
		}else{
			$strqry = sprintf('UPDATE `tmp_jo_details_cache` SET labor=null, partmaterial="%s",details="%s", amnt="%s" WHERE `trace_id`=%d', $this->input->post('part'),$this->input->post('det'),$this->input->post('amnt'), $this->input->post('id') );
		}
		
		
		$query = $this->db->query($strqry);
		if(!$query)
			echo '0';
		else
			echo '1';
	}
	
	public function deljodet(){
		$jo_type = $this->input->post('labor');
		$jo_type = 1;
// 		echo $jo_type; die();
		$strqry = sprintf('DELETE FROM `tmp_jo_details_cache` WHERE `trace_id`=%d ', $jo_type );
		
		$query = $this->db->query($strqry);
		if(!$query)
			echo '0';
		else
			echo '1';
	}
	
	
	public function savejoborder(){
		$strqry = sprintf('CALL sp_addJO( "%s", %d, %d, "%s", "%s", %s, %s, @id);', $this->input->post('jo_orid'),  $this->input->post('vehicle'), $this->input->post('cust'), $this->input->post('plate'), $this->input->post('jo_date'), $this->input->post('tax'),  $this->input->post('discount') );
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

	public function savejoborderedit(){
		$strqry = sprintf('CALL sp_editJO( %d, "%s", %d, %d, "%s", "%s", %s, %s, @id);',$this->input->post('id'), $this->input->post('jo_orid'),  $this->input->post('vehicle'), $this->input->post('cust'), $this->input->post('plate'), $this->input->post('jo_date'), $this->input->post('tax'),  $this->input->post('discount') );
		$query = $this->db->query($strqry);
		//echo $strqry; die();
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
	
	public function formatCurrency() {
		
		$currency = $this->input->post('post_currency');
		
		echo sCurrency($currency);
	}
	
	public function tagJoAsPaid() {
		$jo_id = $this->input->post('post_jo_id');
		$strQry = sprintf("UPDATE joborder SET `status`='0' WHERE jo_id=%d", $jo_id);
		
		if(!$this->db->query($strQry))
			echo 0;
		else 
			echo 1;

	}
	
}