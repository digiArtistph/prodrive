<?php if( !defined('BASEPATH')) exit('Direct script access not allowed');

class Receiving extends CI_Controller{	
	
	private $_mModel;
	
	function __construct(){
		parent::__construct();
		authUser(array('sessvar' => array('uname', 'islog', 'fullname')));
		
		$this->load->model('mdl_receiving');
		$this->_mModel = $this->mdl_receiving;
		
	}
	
	public function index() {
		$this->section();
	}
	
	public function section() {
		
		$section = ($this->uri->segment(4)) ? $this->uri->segment(4) : '';
		$id = ($this->uri->segment(5)) ? $this->uri->segment(5) : '';
		
		switch($section){
			case 'receiving':
				$this->_receiving();
				break;
			case 'addreceiving':
				$this->_addreceiving();
				break;
			case 'editreceiving':
				$this->_editreceiving($id);
				break;
			default:
				$this->_receiving();
		}
	}
	
	private function _receiving() {
		
		$dataset = $this->_mModel->paginate();
		$data['records'] = $dataset['records'];
		$data['count'] = $dataset['overallcount'];
		$data['paginate'] = $dataset['paginate'];
		$data['main_content'] = 'tranx/vehicle_receiving/vehicle_receiving_view';
		$this->load->view('includes/template', $data);
		
	}
	
	private function _addreceiving() {
// 		retrieveqry
		$this->load->model('mdl_receiving');
		$dataset = $this->mdl_receiving->retrieve();
		$data['records'] = $dataset['records'];
		$data['count'] = $dataset['count'];
		
		$data['main_content'] = 'tranx/vehicle_receiving/vehicle_receiving_add_view';
		$this->load->view('includes/template', $data);
		
	}
	
	public function validateaddreceivedvehicle() {
		
		$this->load->library('form_validation');
		$validation = $this->form_validation;
		
		$validation->set_rules('recdate', 'Date Received', 'required');
		$validation->set_rules('customercode', 'Customer Code');
		$validation->set_rules('customer', 'Customer', 'required');
		$validation->set_rules('ownedvehiclecode', 'Vehicle Code');
		$validation->set_rules('ownedvehicle', 'Vehicle', 'required');
		
		if($validation->run() === FALSE) {
			$this->_addreceiving();
		} else {
			$this->load->model('mdl_receiving');
			
			if($this->mdl_receiving->add()) {
				redirect(base_url('tranx/receiving'));
			} else {
				echo 'Inserting new record failed.';
			}
		}
		
	}
	
	private function _editreceiving($id){
		
		$this->load->model('mdl_receiving');
		$dataset = $this->mdl_receiving->retrieveqry($id);
		$data['records'] = $dataset['records'];
// 		call_debug($dataset['records'] );
		$data['main_content'] = 'tranx/vehicle_receiving/vehicle_receiving_edit_view';
		$this->load->view('includes/template', $data);
	}
	
	public function validateeditreceivedvehicle(){
		
		$this->load->library('form_validation');
		$validation = $this->form_validation;
		
		$validation->set_rules('rcvcode', '', 'required');
		$validation->set_rules('recdate', 'Date Received', 'required');
		$validation->set_rules('customercode', 'Customer Code');
		$validation->set_rules('customer', 'Customer', 'required');
		$validation->set_rules('ownedvehiclecode', 'Vehicle Code');
		$validation->set_rules('ownedvehicle', 'Vehicle', 'required');
		
		if($validation->run() === FALSE) {
			$this->_editreceiving( $this->input->post('rcvcode') );
		} else {
			$this->load->model('mdl_receiving');
				
			if($this->mdl_receiving->edit()) {
				redirect(base_url('tranx/receiving'));
			} else {
				echo 'Inserting new record failed.';
			}
		}
		
	}
	
	public function ajaxdelvr(){
		$strQry = sprintf("DELETE FROM `vehicle_receive` WHERE `vr_id`=%d", $this->input->post('id'));
		$query = $this->db->query($strQry);
		
		if(!$query)
			echo "0";
		else
			echo "1";
	}
}