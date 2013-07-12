<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Ownedvehicle extends CI_Controller {
	
	private $_mModel;
	
	public function __construct(){
		parent::__construct();
		authUser(array('sessvar' => array('uname', 'islog', 'fullname')));
		
		$this->load->model('mdl_ownedvehicle');
		$this->_mModel = $this->mdl_ownedvehicle;
		
	}
	
	public function index() {
		
		$this->section();
	}
	
	public function section() {
		
		$section = ($this->uri->segment(4)) ? $this->uri->segment(4) : '';
		$id = ($this->uri->segment(5)) ? $this->uri->segment(5) : '';
		
		switch ($section) {
			case 'ownedvehicle':
				$this->_ownedVehicle();
				break;				
			case 'addownedvehicle':
				$this->_addOwnedVehicle();
				break;
			case 'editownedvehicle':
				$this->_editOwnedVehicle($id);
				break;
			case 'deleteownedvehicle':
				$this->_deleteOwnedVehicle($id);
				break;
			case 'find':
				$this->_find();
				break;
			default:
				$this->_ownedVehicle();
		}
	}
	
	private function _ownedVehicle() {
		
				
		$dataset = $this->_mModel->paginate();
		$data['records'] = $dataset['records'];
		$data['count'] = $dataset['overallcount'];
		$data['paginate'] = $dataset['paginate'];
		$data['main_content'] = 'master/vehicle_owner/vehicle_owner_view';
		$this->load->view('includes/template', $data);
	}
	
	private function _addOwnedVehicle() {
		
		$data['main_content'] = 'master/vehicle_owner/vehicle_owner_add_view';
		$this->load->view('includes/template', $data);
	}
	
	public function validateaddownedvehicle() {
		
		$this->load->library('form_validation');
		
		$validation = $this->form_validation;
		
		$validation->set_rules('plateno', 'Plate No.', 'required');
		$validation->set_rules('makecode', 'Make', 'required');
		$validation->set_rules('make', 'Make', 'required');
		$validation->set_rules('colorcode', 'Color', 'required');
		$validation->set_rules('color', 'Color', 'required');
		$validation->set_rules('description', 'Description');
		$validation->set_rules('customercode', 'Owner', 'required');
		$validation->set_rules('owner', 'Owner', 'required');
		
		if($validation->run() === FALSE) {
			$this->_addOwnedVehicle();
		}else {
			// checks plateno and owner contstraints
			if($this->_mModel->isOwnerPlateNoExists($this->input->post('plateno'), $this->input->post('customercode'))== 0) {
				if($this->_mModel->add())
					redirect(base_url('master/ownedvehicle'));
				else
					echo 'Inserting record failed.';
			} elseif ($this->_mModel->isOwnerPlateNoExists($this->input->post('plateno'), $this->input->post('customercode')) == 1) {
				$this->_duplicate_record($this->input->post('plateno'),$this->input->post('customercode'));
			} else {
				$this->_duplicate_record_plate_only($this->input->post('plateno'),$this->input->post('customercode'));
			}
		}
		
	}
	
	private function _find(){
		
		$search = mysql_real_escape_string($this->input->post('search'));
		$dataset = $this->_mModel->find($search);
		$data['records'] = $dataset['records'];
		$data['count'] = $dataset['overallcount'];
		$data['paginate'] = $dataset['paginate'];
		$data['search_keyword'] = $search;
		
		$data['main_content'] = 'master/vehicle_owner/vehicle_owner_view';
		$this->load->view('includes/template', $data);
		
	}	
	
	private function _duplicate_record($plateno, $owner) {
		$results = $this->db->query("SELECT CONCAT(lname, ', ', fname) AS fullname FROM customer WHERE custid=$owner")->result();	
		
		foreach ($results as $result) {
			$owner = $result->fullname;
			break;
		}
		
		$data['plateNo'] = htmlentities(parsePlateNo($plateno), ENT_QUOTES);
		$data['owner'] = $owner;
		$data['main_content'] = 'master/vehicle_owner/dupliate_plateno_owner_view';
		$this->load->view('includes/template', $data);
		
	}

	private function _duplicate_record_plate_only($plateno) {
		
		$data['plateNo'] = htmlentities(parsePlateNo($plateno), ENT_QUOTES);
		$data['owner'] = '';
		$data['main_content'] = 'master/vehicle_owner/dupliate_plateno_owner_view';
		$this->load->view('includes/template', $data);
		
	}
	
	private function _editOwnedVehicle($id = ''){
		if(empty($id))
			return false;
		$this->load->model('mdl_ownedvehicle');
		$data['records'] = $this->mdl_ownedvehicle->retrieve_vehicle($id);
		$data['main_content'] = 'master/vehicle_owner/vehicle_owner_edit';
		$this->load->view('includes/template', $data);
		
	}
	
	public function validateeditownedvehicle() {
	
		$this->load->library('form_validation');
	
		$validation = $this->form_validation;
		
		$validation->set_rules('vehiclecode', '', 'required');
		$validation->set_rules('plateno', 'Plate No.', 'required');
		$validation->set_rules('makecode', 'Make', 'required');
		$validation->set_rules('make', 'Make', 'required');
		$validation->set_rules('colorcode', 'Color', 'required');
		$validation->set_rules('color', 'Color', 'required');
		$validation->set_rules('description', 'Description');
		$validation->set_rules('customercode', 'Owner', 'required');
		$validation->set_rules('owner', 'Owner', 'required');
	
		if($validation->run() === FALSE) {
			$this->_editOwnedVehicle($this->input->post('vehiclecode'));
		}else {
			$this->load->model('mdl_ownedvehicle');
			// checks plateno and owner contstraints
			if($this->_mModel->isOwnerPlateNoExists($this->input->post('plateno'), $this->input->post('customercode')) == 0) {
				if($this->mdl_ownedvehicle->edit())
					redirect(base_url('master/ownedvehicle'));
				else
					echo 'Updating record failed.';
			} else {
				$this->_duplicate_record($this->input->post('plateno'),$this->input->post('customercode'));
			}
		}
		
	
	}
	
	public function ajaxdelvehicle(){
		$strQry = sprintf("DELETE FROM `vehicle_owner` WHERE `vo_id`=%d", $this->input->post('id'));
		$query = $this->db->query($strQry);
		if(!$query)
			echo "0";
		else
			echo "1";
	}
	
} 