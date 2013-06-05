<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Ownedvehicle extends CI_Controller {
	
	public function index() {
		
		$this->section();
	}
	
	public function section() {
		
		$section = ($this->uri->segment(1)) ? $this->uri->segment(1) : '';
		$id = ($this->uri->segment(5)) ? $this->uri->segment(5) : '';
		
		switch ($section) {
			case 'ownedvehicle':
				$this->_ownedvehicle();
				break;
			case '':
				break;
			default:
				$this->_ownedvehicle();
		}
	}
	
	private function _ownedvehicle() {
		
		$data['main_content'] = 'master/vehicle_owner/vehicle_owner_add_view';
		$this->load->view('includes/template', $data);
	}
	
} 