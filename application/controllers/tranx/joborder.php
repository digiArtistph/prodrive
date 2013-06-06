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
			default:
				$this->_joborder($id);
		}
	}
	
	private function _editjoborder($id){
		$data['jbo_order'] = $this->_joborders($id);
		
		$this->db->query('CALL sp_create_jo_cache()');
		$this->db->query('START TRANSACTION');
		$detailsqry = $this->_jobdet($id);
		
		if(!empty($detailsqry) ){
			//call_debug($detailsqry);
			foreach ($detailsqry as $ordet){
				//call_debug($ordet->lbrid);
				$this->db->query('INSERT INTO `tmp_jo_details_cache` SET labor="'. $ordet->lbrid .'", partmaterial="'.$ordet->parts .'", details="'. $ordet->det .'", amnt="'. $ordet->amnt .'"');
			
			}
		}
		$this->db->query('COMMIT');
		$data['jbo_det'] = $this->_getJobDet();
// 		call_debug($data['jbo_order']);
		$data['main_content'] = 'tranx/joborder/editjoborder';
		$this->load->view('includes/template', $data);
	}
	
	private function _getJobDet(){
		$strqry = sprintf('SELECT tdc.trace_id, tdc.labor, lt.name as lbrname, tdc.partmaterial, tdc.details, tdc.amnt FROM `tmp_jo_details_cache` tdc LEFT JOIN labortype lt ON lt.laborid=tdc.labor');
		$query = $this->db->query($strqry);
		
		if( $query->num_rows() <1 )
			return false;
		
		return $query->result();
	}
	
	private function _joborders($id){
		global $almd_db;
		$almd_db = new Almdtables();
		
		$strqry = sprintf('SELECT jo.jo_id as id, jo.jo_number as number,jo.trnxdate as trnxdate, jo.plate as plate, jo.v_id as vehicleid, cust.custid as custid , concat(cust.lname, ", ", cust.fname) as custname, jo.tax, jo.discount FROM `%s` AS jo LEFT JOIN vehicle_owner AS vo ON vo.vo_id=jo.v_id LEFT JOIN vehicle AS v on v.v_id=jo.v_id LEFT JOIN customer AS cust ON cust.custid=jo.customer  WHERE jo.jo_id=%d AND jo.`status`="1"', $almd_db->joborder, $id);
		
		$query = $this->db->query($strqry);
		
		if( $query->num_rows() <1 )
			return false;
		
		return $query->result();
	}
	
	private function _jobdet($id){
		global $almd_db;
		$almd_db = new Almdtables();
		
		$strqry = sprintf('SELECT jo.jo_id as id, jdet.labor as lbrid,jdet.partmaterial as parts, jdet.details as det, jdet.amnt 	 FROM joborder jo LEFT JOIN jodetails jdet ON jo.jo_id=jdet.jo_id  WHERE jdet.jo_id=%d ',$id);

		$query = $this->db->query($strqry);
		
		if( $query->num_rows() <1 )
			return false;
		
		
		return $query->result();
	}
	
	public function ajaxdeljo(){
		
		$strQry = sprintf("DELETE FROM `jodetails` WHERE `jo_id`=%d", $this->input->post('id'));
		$query = $this->db->query($strQry);
		if(!$query)
			return false;
		
		$strQry = sprintf("DELETE FROM `joborder` WHERE `jo_id`=%d", $this->input->post('id'));
		$query = $this->db->query($strQry);
		if(!$query)
			echo "0";
		else
			echo "1";
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
		$data['main_content'] = 'tranx/joborder/addjoborder';
		$this->load->view('includes/template', $data);
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