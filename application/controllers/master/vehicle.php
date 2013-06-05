<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Vehicle extends CI_Controller {
	
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
			case 'viewvehicle':
				$this->_vehicle();
				break;
			case 'addvehicle':
				$this->_addvehicle();
				break;
			case 'editvehicle':
				$this->_editvehicle($id);
				break;
			default:
				$this->_vehicle();
		}
	}
	
	private function _vehicle(){
		$data['vehicles'] = $this->_vehiclelists();
		$data['main_content'] = 'master/vehicle/view_vehicle';
		$this->load->view('includes/template', $data);
	}
	
	private function _addvehicle(){
		$data['main_content'] = 'master/vehicle/add_vehicle';
		$this->load->view('includes/template', $data);
	}
	
	private function _editvehicle($id){
		$data['vehicles'] = $this->_vehiclelists($id);
		
		$data['main_content'] = 'master/vehicle/edit_vehicle';
		$this->load->view('includes/template', $data);
	}
	
	public function ajaxdelveh(){
		$strQry = sprintf("DELETE FROM `vehicle` WHERE `v_id`=%d", $this->input->post('id'));
		$query = $this->db->query($strQry);
		if(!$query)
			echo "0";
		else
			echo "1";
	}
	
	
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
