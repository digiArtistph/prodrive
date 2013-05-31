<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Cutoff extends CI_Controller {
	
	public function index() {
		$this->section();
	}
	
	public function section() {
	
		$section = ($this->uri->segment(4)) ? $this->uri->segment(4) : '';
		$id = ($this->uri->segment(5)) ? $this->uri->segment(5) : '';
		
		switch($section){		
			case 'cutoff':
				$this->_closeshift();
				break;
			default:
				$this->_closeshift();			
		}
	}
	
	private function _closeshift() {
		
		$data['main_content'] = 'tranx/cutoff/close_shift_view';
		$this->load->view('includes/template', $data);	
		
	}
	
}