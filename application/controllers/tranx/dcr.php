<?php if (!defined('BASEPATH')) exit ('No direct script access allowed.');
class Dcr extends CI_Controller {
	private $DCR = null;
	
	public function __construct() {
		parent::__construct();
		// authorizes access
		authUser(array('sessvar' => array('uname', 'islog', 'fullname')));

	}
	
	public function index() {
		$this->section();
	}
	
	public function section() {
		$section = ($this->uri->segment(1)) ? $this->uri->segment(1) : '';
		$id = ($this->uri->segment(5)) ? $this->uri->segment(5) : '';
		
		switch($section){
			case 'trnx':
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
			$data['dcr'] = $dcrNo;
					
			$data['main_content'] = 'tranx/dcr_view';
			$this->load->view('includes/template', $data);
		} else {
			// redirects to a form that asks for a new beg bal
			$this->_dcrnew();
		}
	}
	
	private function _dcrnew() {
		global $almd_userid;
		global $almd_username;
		$data['cashierid'] = $almd_userid;
		$data['cashiername'] = $almd_username;
		$data['main_content'] = 'tranx/dcr_new_view';
		$this->load->view('includes/template', $data);
	}
	
	public function validatenewdcr() {
		
		$this->load->library('form_validation');
		$validation = $this->form_validation;
		
		// sets rules
		$validation->set_rules('trnxdate', 'Tranx Date', 'required');
		$validation->set_rules('begbal', 'Beginning Balance', 'required');
		$validation->set_rules('cashier', 'Cashier', 'required');
		
		if($validation->run() === FALSE) {
			$this->_dcrnew();
		} else {
			$this->load->model('mdl_dcr');
			$this->mdl_dcr->newDCR($this->DCR);
			
			redirect(base_url('tranx/dcr'));
		}
		
	}
	
	
}
