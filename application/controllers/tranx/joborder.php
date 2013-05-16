<?php if( !defined('BASEPATH')) exit('Direct script access not allowed');
class Joborder extends CI_Controller{
	
	public function __construct() {
		
		parent::__construct();
		
		// authorizes access
		authUser(array('sessvar' => array('uname', 'islog', 'fullname')));
	}
	
	public function index(){
		$this->section();
	}
	
	public function section(){
	
		$section = ($this->uri->segment(4)) ? $this->uri->segment(4) : '';
		$id = ($this->uri->segment(5)) ? $this->uri->segment(5) : '';
		
		switch($section){
			case 'viewjobrder':
				$this->_joborder($id);
				break;
			case 'addjoborder':
				$this->_addjoborder();
				break;
			case 'editjoborder':
				$this->_editjoborder($id);
				break;
			case 'deletejobrder':
				$this->_deletejoborder($id);
				break;
			default:
				$this->_joborder($id);
		}
	}
	
	private function _editjoborder($id){
		$data['jbo_det'] = $this->_jobdet($id);
		$data['jbo_orders'] = $this->_joborders($id);
// 		call_debug($data['jbo_orders']);
		$data['customers'] = $this->_customer_list();
//  		call_debug($data['customers']);
		$data['colors'] = $this->_color_list();
		$data['vehicles'] = $this->_vehicle_list();
		$data['main_content'] = 'tranx/joborder/editjoborder';
		$this->load->view('includes/template', $data);
	}
	
	private function _joborders($id){
		global $almd_db;
		$almd_db = new Almdtables();
		
		$strqry = sprintf('SELECT jd.jo_id, jd.labor, lt.name as labort, jd.partmaterial, jd.details, jd.laboramnt, jd.partmaterialamnt, lt.name FROM `%s` jd LEFT JOIN `labortype` lt on lt.laborid=jd.labor WHERE `jo_id`="%d"', $almd_db->jodetails ,$id);
		
		$query = $this->db->query($strqry);
		
		if( $query->num_rows() <1 )
			return false;
		
		return $query->result();
	}
	
	private function _jobdet($id){
		global $almd_db;
		$almd_db = new Almdtables();
		
		$strqry = sprintf('SELECT * FROM `%s` WHERE `jo_id`="%d"', $almd_db->joborder ,$id);
		
		$query = $this->db->query($strqry);
		
		if( $query->num_rows() <1 )
			return false;
		
		return $query->result();
	}
	
	private function _deletejoborder($id){
		
		global $almd_db;
		$almd_db = new Almdtables();
		
		$strqry = sprintf('DELETE FROM `%s` WHERE `jo_id`=%d', $almd_db->jodetails, $id);
		if(!$this->db->query($strqry))
			echo 'delete failed'; 
		
		$strqry = sprintf('DELETE FROM `%s` WHERE `jo_id`=%d', $almd_db->joborder, $id);
		
		if(!$this->db->query($strqry))
			echo 'delete failed';

		redirect( base_url() . 'tranx/joborder');
		

	}
	
	private function _joborder($id){
		$this->load->library('pagination');
		global $almd_db;
		$almd_db = new Almdtables();
		
		$config['base_url'] = base_url('tranx/joborder/section/viewjobrder');
		$config['total_rows'] = $this->db->query("SELECT jo_id FROM {$almd_db->joborder}")->num_rows();
		$config['uri_segment'] = 5;
		$config['per_page'] = 10;
		$config['num_links'] = 5;
		$this->pagination->initialize($config);
		$data['paginate'] = paginate_helper($this->pagination->create_links());
		
		$this->pagination->initialize($config);
		
		$data['links'] = $this->pagination->create_links();
		$data['joborders'] = $this->joborder_list($id ,$config['per_page']);
		$data['main_content'] = 'tranx/joborder/viewjoborder';
		$this->load->view('includes/template', $data);
	}
	
	private function joborder_list( $start, $end ){
		global $almd_db;
		$almd_db = new Almdtables();
	
		$strqry = sprintf('SELECT jo.jo_id, ve.make as vehicle, cl.name as color, cr.fname, cr.mname, cr.lname, jo.plate, jo.contactnumber as num, jo.address as addr, jo.trnxdate as date FROM `%s` jo LEFT JOIN `%s` ve on ve.v_id=jo.v_id LEFT JOIN `%s` cr on cr.custid=jo.customer LEFT JOIN `%s` cl on cl.clr_id=jo.color LIMIT %d, %d',$almd_db->joborder, $almd_db->vehicle, $almd_db->customer, $almd_db->color, $start, $end);
	
		$query = $this->db->query($strqry);
	
		if( $query->num_rows() <1 )
			return false;
	
		return $query->result();
	}
	
	private function _addjoborder(){
		
		$data['customers'] = $this->_customer_list();
		$data['colors'] = $this->_color_list();
		$data['vehicles'] = $this->_vehicle_list();
		$data['main_content'] = 'tranx/joborder/addjoborder';
		$this->load->view('includes/template', $data);
	}
	
	private function _vehicle_list($id = ''){
		global $almd_db;
		$almd_db = new Almdtables();
		
		if(empty($id))
			$strqry = sprintf('SELECT v_id, make FROM `%s`', $almd_db->vehicle);
		else
			$strqry = sprintf('SELECT * FROM `%s` WHERE categ_id="%s"',$almd_db->vehicle, $id);
		
		$query = $this->db->query($strqry);
		
		if( $query->num_rows() <1 )
			return false;
		
		return $query->result();
	}
	
	private function _color_list($id = ''){
		global $almd_db;
		$almd_db = new Almdtables();
		
		if(empty($id))
			$strqry = sprintf('SELECT clr_id, name FROM `%s`', $almd_db->color);
		else
			$strqry = sprintf('SELECT clr_id, name FROM `%s` WHERE categ_id="%s"',$almd_db->color, $id);
		
		$query = $this->db->query($strqry);
		
		if( $query->num_rows() <1 )
			return false;
		
		return $query->result();
	}
	
	private function _customer_list($id = ''){
		global $almd_db;
		$almd_db = new Almdtables();
	
		if(empty($id))
			$strqry = sprintf('SELECT custid, fname, mname, lname FROM `%s`', $almd_db->customer);
		else
			$strqry = sprintf('SELECT custid, fname, mname, lname FROM  FROM `%s` WHERE categ_id="%s"',$almd_db->customer, $id);
	
		$query = $this->db->query($strqry);
	
		if( $query->num_rows() <1 )
			return false;
	
		return $query->result();
	}
	
	public function validateorder(){
		$this->load->library('form_validation');
		$validation = $this->form_validation;
		
		$validation->set_rules('joborderid', '',  'required');
		$validation->set_rules('order_det', '',  'required');
		$validation->set_rules('odate', '',  'required');
		$validation->set_rules('customer', '',  'required');
		$validation->set_rules('vehicle', '',  'required');
		$validation->set_rules('addr', '',  'required');
		$validation->set_rules('plate', '',  'required');
		$validation->set_rules('color', '',  'required');
		$validation->set_rules('number', '',  'required');
		
		if($validation->run() === FALSE) {
			show_error('Please Check Url again');
		}else{
			
			$joborder = $this->input->post('joborderid');
			$pattern = "/^[0]$/";
			
			if($joborder != 0){
				
				
				$vehicle = $this->input->post('vehicle');
				$color = $this->input->post('color');
				$customer = $this->input->post('customer');
				$id = $joborder;
				
				
				$strqry = 'call sp_start_editjoborder("'. $id .'", "'. $customer .'", "", "", "", @ret_id, @flag);';
				$pattern = "/^([0-9])+$/";
				if(!preg_match($pattern, $customer)){
					$pattern = '/(\,\s)|(\s)(?=[\w]+\.)/';
					$name = preg_split($pattern, $customer);
					if(isset($name[2]))
						$mname = substr($name[2], 0, strlen($name[2]) - 1);
					else
						$mname = '';
					if(!isset($name[0]))
						$name[0] = '';
					if(!isset($name[1]))
						$name[1] = '';
					$strqry = 'call sp_start_editjoborder("'. $id .'", "0", "' . $name[1] .'", "' . $mname .'", "' . $name[0] .'", @ret_id, @flag);';;
				}
				
				$this->_querydb($strqry);
				$pattern = "/^([0-9])+$/";
				if(preg_match($pattern, $vehicle)){
					if(preg_match($pattern, $color)){
						$strqry = sprintf('call sp_editjoborder("%d", "%s", "%d", "%s", @ret_id, "%s", "%s", "%s", "%s", "%d", @flag);',$vehicle , 0, $color, 0, $this->input->post('plate'), $this->input->post('number'), $this->input->post('addr'), $this->input->post('odate'), $id );
					}else{
						$strqry = sprintf('call sp_editjoborder("%d", "%s", "%d", "%s", @ret_id, "%s", "%s", "%s", "%s", "%d", @flag);',$vehicle , 0, 0, $color, $this->input->post('plate'), $this->input->post('number'), $this->input->post('addr'), $this->input->post('odate'), $id );
					}
						
				}else{
					if(preg_match($pattern, $color)){
						$strqry = sprintf('call sp_editjoborder("%d", "%s", "%d", "%s", @ret_id, "%s", "%s", "%s", "%s", "%d", @flag);',0 , $vehicle, $color, 0, $this->input->post('plate'), $this->input->post('number'), $this->input->post('addr'), $this->input->post('odate'), $id );
					}else{
						$strqry = sprintf('call sp_editjoborder("%d", "%s", "%d", "%s", @ret_id, "%s", "%s", "%s", "%s", "%d", @flag);',0 , $vehicle, 0, $color, $this->input->post('plate'), $this->input->post('number'), $this->input->post('addr'), $this->input->post('odate'), $id );
					}
				
				}
				$this->_querydb($strqry);
				
				$samplejson = $this->input->post('order_det');
				$ordet = json_decode($samplejson, true);
				
				foreach ( $ordet as $key ){
				
					if( $key[1] == 'Parts or Materials' ){
						$strqry1 = sprintf('call sp_editjoborderdet("%d" , "0", "%s", "%s", "0", "%s", "1", @flag);',$id, $key[3], $key[4], $key[5]);
					}elseif( $key[1] == 'labor' ){
						//if(preg_match($pattern, $vehicle))
						$strqry1 = sprintf('call sp_editjoborderdet("%d" , "%s", "", "%s", "%s", "0", "1", @flag);',$id, $key[2], $key[4], $key[5]);
					}
					
					$this->_querydb($strqry1);
				}
				
				
				$strqry2 = 'call sp_end_editjoborder(@flag);';
				$this->_querydb($strqry2);
				
				$strqry3 = 'select @flag as flag';
				$query = $this->db->query($strqry3);
				if($query);
				$result = $query->result();
				
				$resultant = array(
						'flag'	=> $result[0]->flag,
						'jo_id'	=>	$id
				);
				$resulttojson = json_encode($resultant);
				echo $resulttojson;
			}else{
				
				$strqry = 'call sp_start_joborder(@flag);';
				$this->_querydb($strqry);
	
				$vehicle = $this->input->post('vehicle');
				$color = $this->input->post('color');
				$customer = $this->input->post('customer');
	
				$pattern = "/^([0-9])+$/";
	
				if(!preg_match($pattern, $customer)){
						
					$customer = $this->_customercustom($this->input->post('customer'));
				}
	
				if(preg_match($pattern, $vehicle)){
						
					if(preg_match($pattern, $color)){
						$strqry = sprintf('call sp_joborder("%d", "%s", "%d", "%s", "%d", "%s", "%s", "%s", "%s", @o_jo_id, @flag)',$vehicle , 0, $color, 0, $customer, $this->input->post('plate'), $this->input->post('number'), $this->input->post('addr'), $this->input->post('odate') );
					}else{
						$strqry = sprintf('call sp_joborder("%d", "%s", "%d", "%s", "%d", "%s", "%s", "%s", "%s", @o_jo_id, @flag)',$vehicle , 0, 0, $color, $customer, $this->input->post('plate'), $this->input->post('number'), $this->input->post('addr'), $this->input->post('odate') );
					}
						
				}else{
					if(preg_match($pattern, $color)){
						$strqry = sprintf('call sp_joborder("%d", "%s", "%d", "%s", "%d", "%s", "%s", "%s", "%s", @o_jo_id, @flag)',0 , $vehicle, $color, 0, $customer, $this->input->post('plate'), $this->input->post('number'), $this->input->post('addr'), $this->input->post('odate') );
					}else{
						$strqry = sprintf('call sp_joborder("%d", "%s", "%d", "%s", "%d", "%s", "%s", "%s", "%s", @o_jo_id, @flag)',0 , $vehicle, 0, $color, $customer, $this->input->post('plate'), $this->input->post('number'), $this->input->post('addr'), $this->input->post('odate') );
					}
	
				}
					
				$this->_querydb($strqry);
					
					
				$samplejson = $this->input->post('order_det');
				$ordet = json_decode($samplejson, true);
				unset( $ordet[0] );
					
					
				foreach ( $ordet as $key ){
	
					if( $key[1] == 'Parts or Materials' ){
						$strqry1 = sprintf('call sp_joborderdet(@o_jo_id , "0", "%s", "%s", "0", "%s", "1", @flag);', $key[3], $key[4], $key[5]);
					}elseif( $key[1] == 'labor' ){
						//if(preg_match($pattern, $vehicle))
						$strqry1 = sprintf('call sp_joborderdet(@o_jo_id , "%s", "", "%s", "%s", "0", "1", @flag);', $key[2], $key[4], $key[5]);
					}
						
					$this->_querydb($strqry1);
				}
					
					
				$strqry2 = 'call sp_end_joborder(@o_jo_id, @flag);';
				$this->_querydb($strqry2);
					
				$strqry3 = 'SELECT @flag AS flag, @o_jo_id AS jid;';
				$query = $this->db->query($strqry3);
				if($query);
				$result = $query->result();
				
				$resultant = array(
						'flag'	=> $result[0]->flag,
						'jo_id'	=>	$result[0]->jid
						);
				$resulttojson = json_encode($resultant);
				echo $resulttojson;
				
			}
		}
	}
	

	
	private function _querydb($strqry){
		$query = $this->db->query($strqry);
		
		if(!$query)
			return false;
		else
			return true;
			
	}
	
	public function autocomplete_vehicle(){
		$this->load->library('form_validation');
		$validation = $this->form_validation;
		
		$validation->set_rules('term', '',  'required');
		if($validation->run() === FALSE) {
			show_error('Please Check Url again');
		}else{
			$this->load->model('mdl_autocomplete');
			$temp = $this->mdl_autocomplete->findkeyword('vehicle', 'make' , $this->input->post('term'));
			$objarr = json_encode($temp);
			echo $objarr;
		}
	}
	
	public function autocomplete_color(){
		$this->load->library('form_validation');
		$validation = $this->form_validation;
	
		$validation->set_rules('term', '',  'required');
		if($validation->run() === FALSE) {
			show_error('Please Check Url again');
		}else{
			$this->load->model('mdl_autocomplete');
			$temp = $this->mdl_autocomplete->findkeyword('color', 'name' , $this->input->post('term'));
			$objarr = json_encode($temp);
			echo $objarr;
		}
	}
	
	public function autocomplete_labortype(){
		$this->load->library('form_validation');
		$validation = $this->form_validation;
	
		$validation->set_rules('term', '',  'required');
		if($validation->run() === FALSE) {
			show_error('Please Check Url again');
		}else{
			$this->load->model('mdl_autocomplete');
			$temp = $this->mdl_autocomplete->findkeyword('labortype', 'name' , $this->input->post('term'));
			$objarr = json_encode($temp);
			echo $objarr;
		}
	}
	
}