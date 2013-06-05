<?php if( !defined('BASEPATH')) exit('Direct script access not allowed');

class Receiving extends CI_Controller{
	
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
			default:
				$this->_receiving();
		}
	}
	
	private function _receiving() {
		
		$data['main_content'] = 'tranx/vehicle_receiving/vehicle_receiving_view';
		$this->load->view('includes/template', $data);
		
	}
	
	private function _addreceiving() {
		
		$data['main_content'] = 'tranx/vehicle_receiving/vehicle_receiving_add_view';
		$this->load->view('includes/template', $data);
		
	}
	
}