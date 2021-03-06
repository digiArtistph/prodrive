<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Vehicle extends CI_Controller {
	
	private $_mModel;
	
	public function __construct() {
	
		parent::__construct();
	
		// authorizes access
		authUser(array('sessvar' => array('uname', 'islog', 'fullname')));
		
		$this->load->model('mdl_vehicle');
		$this->_mModel = $this->mdl_vehicle;
		
	}
	
	public function index(){
		$this->section();
	}
	
	public function section(){
	
		$section = ($this->uri->segment(4)) ? $this->uri->segment(4) : '';
		$id = ($this->uri->segment(5)) ? $this->uri->segment(5) : '';
	
		switch($section){
			case 'viewvehicle':
				$this->_vehicle();
				break;
			case 'addvehicle':
				$this->_addvehicle();
				break;
			case 'editvehicle':
				$this->_editvehicle($id);
				break;
			case 'find':
				$this->_find();
				break;
			default:
				$this->_vehicle();
		}
	}
	
	private function _find(){
		
		$search = mysql_real_escape_string($this->input->post('search'));
		$dataset = $this->_mModel->find($search);
		$data['vehicles'] = $dataset['records'];
		$data['count'] = $dataset['overallcount'];
		$data['paginate'] = $dataset['paginate'];
		$data['search_keyword'] = $search;
		
		$data['main_content'] = 'master/vehicle/view_vehicle';
		$this->load->view('includes/template', $data);
		
	}
	
	private function _vehicle(){
		
		$dataset = $this->_mModel->paginate(); // $this->_mModel->retrieveAllVehicles();
		$data['vehicles'] = $dataset['records']; // $this->_vehiclelists();
		$data['count'] = $dataset['overallcount'];
		$data['paginate'] = $dataset['paginate'];
		$data['main_content'] = 'master/vehicle/view_vehicle';
		$this->load->view('includes/template', $data);
	}
	
	private function _addvehicle(){
		$data['main_content'] = 'master/vehicle/add_vehicle';
		$this->load->view('includes/template', $data);
	}
	
	private function _editvehicle($id){
		
		$dataset = $this->_mModel->retrieveAllVehicles($id);
		$data['vehicles'] = $dataset['records']; // $this->_vehiclelists($id);
		
		$data['main_content'] = 'master/vehicle/edit_vehicle';
		$this->load->view('includes/template', $data);
	}
	
	public function ajaxdelveh(){
		$strQry = sprintf("UPDATE `vehicle` SET `status`='0' WHERE `v_id`=%d", $this->input->post('id'));
		$query = $this->db->query($strQry);
		if(!$query)
			echo "0";
		else
			echo "1";
	}
	
	
	/*
	private function _vehiclelists($id = ''){
		
		global $almd_db;
		$almd_db = new Almdtables();
		
		if(empty($id))
			$strqry = mysql_real_escape_string('SELECT * FROM `' . $almd_db->vehicle . '` ');
		else
			$strqry = sprintf('SELECT * FROM `%s` WHERE v_id="%s"', $almd_db->vehicle,  $id);
		
		$query = $this->db->query($strqry);
		
		if( $query->num_rows() <1 )
			return false;
		
		return $query->result();
	}
	*/
	
	public function validateaddvehicle(){
		$this->load->library('form_validation');
		$validation = $this->form_validation;
		
		$validation->set_rules('make', 'User Name',  'required');
		if($validation->run() === FALSE) {
			$this->_addvehicle();
		} else {
			global $almd_db;
			$almd_db = new Almdtables();
				
			$db = $this->input;
			$strqry = 'INSERT INTO '. $almd_db->vehicle . ' (`v_id`, `make` ) VALUES (NULL, "' . $db->post('make') .'")';
			
			$query = $this->db->query($strqry);
			if(!$query){
				$this->_addvehicle();
			}
				
			redirect( base_url() . 'master/vehicle' );
		}
	}
	
	public function validateeditvehicle(){
		$this->load->library('form_validation');
		$validation = $this->form_validation;
		
		$validation->set_rules('vh', '',  'required');
		$validation->set_rules('make', 'User Name',  'required');
		if($validation->run() === FALSE) {
			$this->_editvehicle($this->input->post('vh'));
		} else {
			global $almd_db;
			$almd_db = new Almdtables();
		
			$db = $this->input;
			$strqry = sprintf('UPDATE `%s` SET `make`="%s" WHERE v_id="%s" ', $almd_db->vehicle, $this->input->post('make'),  $this->input->post('vh') );
			
			$query = $this->db->query($strqry);
			if(!$query){
				$this->_editvehicle($this->input->post('vh'));
			}
	
			redirect( base_url() . 'master/vehicle/' );
		}
	}
}
