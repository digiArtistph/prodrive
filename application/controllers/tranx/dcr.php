<?php if (!defined('BASEPATH')) exit ('No direct script access allowed.');
class Dcr extends CI_Controller {
	private $DCR = null;
	private $username;
	
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

		$this->load->model('mdl_dcr');
		if($this->mdl_dcr->hasCurrentDCR($dcrNo)) {
			// pass value to the controller
			$data['dcr'] = $dcrNo;
			$data['begbal'] = $this->_getbegbal();
			$data['cashfloat'] = $this->_getcashfloat();
			$data['cashlift'] = $this->_getcashlift();	
			$data['salescash'] = $this->_getsalescash();
			$data['salescheck'] = $this->_getsalescheck();
			$data['coh'] = ($data['begbal'] + $data['cashfloat'] + $data['salescash']) -($data['cashlift']);
			$data['main_content'] = 'tranx/dcr/dcr_view';
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
		
		$data['main_content'] = 'tranx/dcr/dcr_new_view';
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
	
private function _getcashfloat() {
		global $almd_userid;
		
		$strQry = sprintf("SELECT SUM(amnt) AS total FROM cashfloat c WHERE cashier=%d AND trnxdate='%s' AND `status`='1'", $almd_userid, curdate());		
		$record = $this->db->query($strQry)->result();
		
		foreach($record as $rec) {
			return ($rec->total != '') ? $rec->total : '0.00';
		}
		
	}
	
	private function _getcashlift() {
		global $almd_userid;
		
		$strQry = sprintf("SELECT SUM(amnt) AS total FROM cashlift c WHERE cashier=%d AND trnxdate='%s' AND `status`='1'", $almd_userid, curdate());		
		$record = $this->db->query($strQry)->result();

		foreach($record as $rec) {
			return ($rec->total != '') ? $rec->total : '0.00';
		}
	}
	
	private function _getsalescash() {
		global $almd_userid;
		
		$strQry = sprintf("SELECT SUM(amnt) AS total FROM dcrdetails d WHERE dcr_id=(SELECT dcr_id FROM dcr d WHERE cashier=%d AND trnxdate='%s' AND `status`='1') AND tender=1", $almd_userid, curdate());
		$record = $this->db->query($strQry)->result();
		
		foreach($record as $rec) {
			return ($rec->total != '') ? $rec->total : '0.00';
		}
	}
	
	private function _getsalescheck() {
		global $almd_userid;
		
		$strQry = sprintf("SELECT SUM(amnt) AS total FROM dcrdetails d WHERE dcr_id=(SELECT dcr_id FROM dcr d WHERE cashier=%d AND trnxdate='%s' AND `status`='1') AND tender=2", $almd_userid, curdate());
		$record = $this->db->query($strQry)->result();
		
		foreach($record as $rec) {
			return ($rec->total != '') ? $rec->total : '0.00';
		}
	}
	
	private function _getbegbal() {
		global $almd_username;
		global $almd_userid;
		
		$strQry = sprintf("SELECT * FROM dcr WHERE cashier=%d AND trnxdate='%s' AND `status`='1'", $almd_userid, curdate());
		$record = $this->db->query($strQry)->result();
		
		foreach($record as $rec) {
			return ($rec->begbal != '') ? $rec->begbal : '0.00';
		}
	}
	
}
