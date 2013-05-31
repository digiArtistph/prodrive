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
//  	call_debug($data['jbo_det']);
		$data['colors'] = $this->_color_list();
		$data['vehicles'] = $this->_vehicle_list();
		$data['main_content'] = 'tranx/joborder/editjoborder';
		$this->load->view('includes/template', $data);
	}
	
	private function _joborders($id){
		global $almd_db;
		$almd_db = new Almdtables();
		
		$strqry = sprintf('SELECT jd.jo_id, jd.labor, lt.name as labort, jd.partmaterial, jd.details,  jd.amnt, lt.name FROM `%s` jd LEFT JOIN `labortype` lt on lt.laborid=jd.labor WHERE `jo_id`="%d"', $almd_db->jodetails ,$id);
		
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
	
		$strqry = sprintf('SELECT jo.jo_number as jo_num,jo.jo_id, ve.make as vehicle, cl.name as color, cr.fname, cr.mname, cr.lname, jo.plate, jo.contactnumber as num, jo.address as addr, jo.trnxdate as date FROM `%s` jo LEFT JOIN `%s` ve on ve.v_id=jo.v_id LEFT JOIN `%s` cr on cr.custid=jo.customer LEFT JOIN `%s` cl on cl.clr_id=jo.color ORDER BY jo.`jo_id` DESC LIMIT %d, %d  ',$almd_db->joborder, $almd_db->vehicle, $almd_db->customer, $almd_db->color, $start, $end);
	
		$query = $this->db->query($strqry);
	
		if( $query->num_rows() <1 )
			return false;
	
		return $query->result();
	}
	
	private function _addjoborder(){
		$this->db->query('CALL sp_create_jo_cache()');
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
			$arr = $this->mdl_autocomplete->findkeyword('vehicle', 'v_id', 'make' , $this->input->post('term'));
			$json = '[';
			foreach ($arr as $key){
				$json = $json . '{"label":"' . $key['make'] . '", "val": "' . $key['v_id'] . '"},';
			}
			$json = substr($json, 0, strlen($json)-1);
			$json = $json. ']';
			echo $json;
		}
	}
	
	public function autocomplete_customer(){
		$this->load->library('form_validation');
		$validation = $this->form_validation;
	
		$validation->set_rules('term', '',  'required');
		if($validation->run() === FALSE) {
			show_error('Please Check Url again');
		}else{
			
			$this->load->model('mdl_autocomplete');
			$arr = $this->mdl_autocomplete->findkeyword3( $this->input->post('term') );
			$json = '[';
			foreach ($arr as $key){
				$json = $json . '{"label":"' . $key['name'] . '", "val": "' . $key['id'] . '"},';
			}
			$json = substr($json, 0, strlen($json)-1);
			$json = $json. ']';
			echo $json;
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
			$arr = $this->mdl_autocomplete->findkeyword('color', 'clr_id' ,'name' , $this->input->post('term'));
			$json = '[';
			foreach ($arr as $key){
				$json = $json . '{"label":"' . $key['name'] . '", "val": "' . $key['clr_id'] . '"},';
			}
			$json = substr($json, 0, strlen($json)-1);
			$json = $json. ']';
			echo $json;
		}
	}
	
	public function autocomplete_labortype(){
		
		$this->load->library('form_validation');
		$validation = $this->form_validation;
	
		$validation->set_rules('term', '',  'required');
		if($validation->run() === FALSE) {
			return false;
		}else{
			$this->load->model('mdl_autocomplete');
			$arr = $this->mdl_autocomplete->findkeyword('labortype', 'laborid' ,'name' , $this->input->post('term'));
			$json = '[';
			foreach ($arr as $key){
				$json = $json . '{"label":"' . $key['name'] . '", "val": "' . $key['laborid'] . '"},';
			}
			$json = substr($json, 0, strlen($json)-1);
			$json = $json. ']';
			echo $json;
		}
	}


}