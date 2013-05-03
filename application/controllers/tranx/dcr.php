<?php if (!defined('BASEPATH')) exit ('No direct script access allowed.');
class Dcr extends CI_Controller {
	
	public function __construct() {
		parent::__construct();
		
		// authorizes access
		authUser(array('sessvar' => array('uname', 'islog', 'fullname')));
	
	}
	
	public function index() {
		$this->section();
	}
	
	public function section() {
		$section = ($this->uri->segment(4)) ? $this->uri->segment(4) : '';
		$id = ($this->uri->segment(5)) ? $this->uri->segment(5) : '';
		
		switch($section){
			case 'dcrtrnx':
				$this->_dcr();
				break;
			default:
				$this->_dcr();
		}
	}
	
	private function _dcr() {
		
		// algo
		/*
		 * 1. read database if there exist a current record
		 * 2. if there is then load into the form
		 * 3. save maste detail record when save button is pressed
		 */
		$this->load->model('mdl_dcr');
		if($this->mdl_dcr->hasCurrentDCR($dcrNo)) {
			// pass value to the controller
			$data['dcr_id'] = $dcrNo;
			
			$data['main_content'] = 'tranx/dcr_view';
			$this->load->view('includes/template', $data);
		} else {
			// redirects to a form that asks for a new beg bal
			$data['main_content'] = 'tranx/dcr_new_view';
			$this->load->view('includes/template', $data);
		}
	}
	
	public function validatenewdcr() {
		
		$this->load->library('form_validation');
	}
	
	
}