<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Dcr extends CI_Controller {

	
	public function index() {
		$this->section();		
	}
	
	public function section() {
	
		$section = ($this->uri->segment(4)) ? $this->uri->segment(4) : '';
		$id = ($this->uri->segment(5)) ? $this->uri->segment(5) : '';
		
		switch($section){
			case 'dailycashreport':
				$this->_dcr();
				break;
			default:
				$this->_dcr();
		}						
	}
	
	private function _dcr() {
		
		$data['main_content'] = 'reports/dcr/dcr_view';
		$this->load->view('includes/template', $data);
		
	}
	
}