<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Cutoff extends CI_Controller {
	
	function __construct(){
		parent::__construct();
		authUser(array('sessvar' => array('uname', 'islog', 'fullname')));
	}
	
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
	
	public function validatecutoff() {
		$this->load->library('form_validation');
		
		$validation = $this->form_validation;
		
		$validation->set_rules('pword', 'Password', 'required');
		
		if($validation->run() === FALSE) {
			$this->_closeshift();
		} else {
			if($this->usermatched()) {
				// deactivate cashier's status
				$this->_dcrview();
			} else {
				$this->_closeshift("Your username and password do not match.");
			}
		}
	}
	
	private function _dcrview() {
		
		
		$this->load->model('mdl_cutoff');
		// calls sp
		$datasets = $this->mdl_cutoff->getDailyCollection();
		$data['cashlift'] = $this->mdl_cutoff->getCashLiftTotal();//$this->_getcashlift();
		$data['begbal'] = $this->_getbegbal();
		$data['salescash'] = $this->_getsalescash();
		$data['salescheck'] = $this->_getcheckcash();
		$data['cashfloat'] =  $this->mdl_cutoff->getCashFloatTotal();//$this->_getcashfloat();
		
		$data['coh'] = ($data['begbal'] + $data['cashfloat'] + $data['salescash']) -($data['cashlift']);
		$data['totalsales'] = ($data['salescash'] + $data['salescheck']);
		$data['successlogin'] = $this->_getsuccesslogin();
		$data['failurelogin'] = $this->_getfailurelogin();
		$data['fullpaid'] = $datasets['fullpaid'];
		$data['advances'] = $datasets['advances'];
		$data['cashliftdetails'] = $datasets = $this->mdl_cutoff->getCashLiftDetails();
		$data['cashfloatdetails'] = $datasets = $this->mdl_cutoff->getCashFloatDetails();
		
		//call_debug($data);
		//if($this->mdl_cutoff->cashierCutOff() && $this->mdl_cutoff->cashFloatCutOff() && $this->mdl_cutoff->cashLiftCutOff()) {
			$data['main_content'] = 'tranx/cutoff/dcr_single_report_view';
			$this->load->view('includes/template', $data);
		//} else {
		//	echo 'Closing shift was unsccessful.';
		//} 
		
				
	}
	
	private function usermatched() {
		global $almd_username;
		$pword = mysql_real_escape_string($this->input->post('pword'));
		$strQry = sprintf("SELECT * FROM users WHERE username='%s' AND pword='%s'", $almd_username, MD5($pword));
		
		$count = $this->db->query($strQry)->num_rows;
		
		if($count > 0)
			return TRUE;
			
		return FALSE;
	}
	
	private function _closeshift($msg = '') {
		
		$this->load->model('mdl_dcr');
		if($this->mdl_dcr->hasCurrentDCR()) {
			$data['msg'] = $msg;
			$data['main_content'] = 'tranx/cutoff/close_shift_view';
			$this->load->view('includes/template', $data);
		} else {
			$data['main_content'] = 'tranx/cutoff/close_shift_unable_view';
			$this->load->view('includes/template', $data);
		}
			
		
	}
	
	private function _getsuccesslogin() {
		global $almd_username;
		
		$strQry = sprintf("SELECT * FROM logintrace WHERE username='%s' AND succeeded = '1' AND  tracetime LIKE '%s'", $almd_username, curdate().'%');
		$count = $this->db->query($strQry)->num_rows;
		
		return $count;
	}
	
	private function _getfailurelogin() {
		global $almd_username;
		
		$strQry = sprintf("SELECT * FROM logintrace WHERE username='%s' AND succeeded = '0' AND  tracetime LIKE '%s'", $almd_username, curdate().'%');
		$count = $this->db->query($strQry)->num_rows;
		
		return $count;
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
	
	private function _getcashfloat() {
		global $almd_userid;
		
		$strQry = sprintf("SELECT SUM(amnt) AS total FROM cashfloat c WHERE cashier=%d AND trnxdate='%s' AND `status`='1'", $almd_userid, curdate());		
		$record = $this->db->query($strQry)->result();
		
		foreach($record as $rec) {
			return $rec->total;
		}
	}
	
	private function _getcashlift() {
		global $almd_userid;
		
		$strQry = sprintf("SELECT SUM(amnt) AS total FROM cashlift c WHERE cashier=%d AND trnxdate='%s' AND `status`='1'", $almd_userid, curdate());		
		$record = $this->db->query($strQry)->result();
		
		foreach($record as $rec) {
			return $rec->total;
		}		
	}
	
	private function _getsalescash() {
		global $almd_userid;
		
		$strQry = sprintf("SELECT SUM(amnt) AS total FROM dcrdetails d WHERE dcr_id=(SELECT dcr_id FROM dcr d WHERE cashier=%d AND trnxdate='%s' AND `status`='1') AND tender=1", $almd_userid, curdate());
		$record = $this->db->query($strQry)->result();
		
		foreach($record as $rec) {
			return $rec->total;
		}
	}
	
	private function _getcheckcash() {
		global $almd_userid;
		
		$strQry = sprintf("SELECT SUM(amnt) AS total FROM dcrdetails d WHERE dcr_id=(SELECT dcr_id FROM dcr d WHERE cashier=%d AND trnxdate='%s' AND `status`='1') AND tender=2", $almd_userid, curdate());
		$record = $this->db->query($strQry)->result();
		
		foreach($record as $rec) {
			return $rec->total;
		}
	}
	
	
	
}