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
	
	public function validatecutoff() {
		$this->load->library('form_validation');
		
		$validation = $this->form_validation;
		
		$validation->set_rules('pword', 'Password', 'required');
		
		if($validation->run() === FALSE) {
			$this->_closeshift();
		} else {
			if($this->usermatched()) {
				$this->_dcrview();
			} else {
				echo 'Username and Password are not matched';
			}
		}
	}
	
	private function _dcrview() {
		$data['begbal'] = $this->_getbegbal();
		$data['salescash'] = $this->_getsalescash();
		$data['salescheck'] = $this->_getcheckcash();
		$data['cashfloat'] = $this->_getcashfloat();
		$data['cashlift'] = $this->_getcashlift();
		$data['coh'] = ($data['begbal'] + $data['cashfloat'] + $data['salescash']) -($data['cashlift']);
		$data['totalsales'] = ($data['salescash'] + $data['salescheck']);
		$data['successlogin'] = $this->_getsuccesslogin();
		$data['failurelogin'] = $this->_getfailurelogin();
		$data['main_content'] = 'tranx/cutoff/dcr_single_report_view';
		$this->load->view('includes/template', $data);
				
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
	
	private function _closeshift() {
		
		$data['main_content'] = 'tranx/cutoff/close_shift_view';
		$this->load->view('includes/template', $data);	
		
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
			return $rec->begbal;
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