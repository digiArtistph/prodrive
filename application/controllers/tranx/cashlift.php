<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Cashlift extends CI_Controller {
	
	public function __construct() {
		parent::__construct();
		// authorizes access
		authUser(array('sessvar' => array('uname', 'islog', 'fullname')));
	}
	
	public function index() {
		$this->section();
	}
	
	public function section(){
	
		$section = ($this->uri->segment(4)) ? $this->uri->segment(4) : '';
		$id = ($this->uri->segment(5)) ? $this->uri->segment(5) : '';
		
		$this->load->model('mdl_cashlift');
		$this->_mRedFlag = $this->mdl_cashlift->hasActiveShift();
		
		// redirects
		if(!$this->_mRedFlag) {
			$this->_cashLifttUnable();
			return;
		}
		
		switch($section){			
			case 'viewcashlift':
				$this->_cashlifts();
				break;
			case 'addcashlift':
				$this->_addcashlift();
				break;
			case 'delete':
				$this->_deletecashlift($id);
				break;
			default:
				$this->_cashlifts();
		}
		
	}
	
	private function _deletecashlift($id = 0) {
		
		$strQry = sprintf("DELETE FROM cashlift WHERE cl_id=%d", $id);
		$this->db->query($strQry);
		
		redirect(base_url('tranx/cashlift'));
	}
	
	private function _addcashlift() {
		global $almd_userid;
		global $almd_username;

		$data['cashierid'] = $almd_userid;
		$data['cashiername'] = $almd_username;
		
		$data['main_content'] = 'tranx/cashlift/cash_lift_add_view';
		$this->load->view('includes/template', $data);
	}
	
	private function _cashlifts() {
		
		$data['cashlifts'] = $this->retrieveAllCashLift();
		$data['total'] = $this->getTotalCashLiftAmount($data['cashlifts']);
		$data['main_content'] = 'tranx/cashlift/cash_lift_view';
		$this->load->view('includes/template', $data);	
	}
	
	public function validateaddcashlift() {
		$this->load->library('form_validation');
		$validation = $this->form_validation;
		
		$validation->set_rules('particulars', 'Particulars', 'required');
		$validation->set_rules('amnt', 'Amount', 'required|decimal');
		
		if($validation->run() === FALSE ) {
			$this->_addcashlift();
		} else {
			if($this->insertNewCashLift()){
				$this->_addConfirmed();
			} else {
				echo 'Insert new record failed.';
			}
		}		
	}
	
	private function _addConfirmed() {
		$data['main_content'] = 'tranx/cashlift/cash_lift_add_confirm_view';
		$this->load->view('includes/template', $data);
	}
	
	private function insertNewCashLift() {
		
		$strQry = sprintf("INSERT INTO cashlift SET refno='%s', particulars='%s', amnt=%f, trnxdate='%s', cashier=%d",
							mysql_real_escape_string($this->input->post('refno')),
							mysql_real_escape_string($this->input->post('particulars')),
							mysql_real_escape_string($this->input->post('amnt')),
							mysql_real_escape_string($this->input->post('curdate')),
							mysql_real_escape_string($this->input->post('cashierid')));
		
		if(!$this->db->query($strQry))
			return FALSE;
		
		return TRUE;
	}
	
	private function retrieveAllCashLift() {
		global $almd_userid;

		$strQry = sprintf("SELECT * FROM cashlift WHERE cashier=%d AND trnxdate='%s' AND status='1'",
							$almd_userid, curdate());
		$record = $this->db->query($strQry)->result();
		
		return $record;
	}
	
	private function getTotalCashLiftAmount($resultset = array()) {
		$total = 0;
		
		foreach($resultset as $rec) {
			$total += $rec->amnt;
		}
		
		return $total;
	}
	
	private function _cashLifttUnable() {
		
		$data['main_content'] = 'tranx/cashlift/cash_liftt_unable_view';
		$this->load->view('includes/template', $data);
		
	}
	
}