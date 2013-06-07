<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Cashfloat extends CI_Controller {
	private $_mRedFlag;
	
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
		
		$this->load->model('mdl_cashfloat');
		$this->_mRedFlag = $this->mdl_cashfloat->hasActiveShift();
		
		// redirects
		if(!$this->_mRedFlag) {
			$this->_cashFloatUnable();
			return;
		}
		
		switch($section){			
			case 'viewcashfloat':
				$this->_cashfloats();
				break;
			case 'addcashfloat':
				$this->_addcashfloat();
				break;
			case 'delete':
				$this->_deletecashfloat($id);
				break;
			default:
				$this->_cashfloats();
		}
		
	}
	
	private function _deletecashfloat($id = 0) {
		
		$strQry = sprintf("DELETE FROM cashfloat WHERE cf_id=%d", $id);
		$this->db->query($strQry);
		
		redirect(base_url('tranx/cashfloat'));
	}
	
	private function _addcashfloat() {
		global $almd_userid;
		global $almd_username;

		$data['cashierid'] = $almd_userid;
		$data['cashiername'] = $almd_username;
		
		$data['main_content'] = 'tranx/cashfloat/cash_float_add_view';
		$this->load->view('includes/template', $data);
	}
	
	private function _cashfloats() {
		
		$data['cashfloats'] = $this->retrieveAllCashFloat();
		$data['total'] = $this->getTotalCashFloatAmount($data['cashfloats']);
		$data['main_content'] = 'tranx/cashfloat/cash_float_view';
		$this->load->view('includes/template', $data);	
	}
	
	public function validateaddcashfloat() {
		$this->load->library('form_validation');
		$validation = $this->form_validation;
		
		$validation->set_rules('particulars', 'Particulars', 'required');
		$validation->set_rules('amnt', 'Amount', 'required|decimal');
		
		if($validation->run() === FALSE ) {
			$this->_addcashfloat();
		} else {
			if($this->insertNewCashFloat()){
				$this->_addConfirmed();
			} else {
				echo 'Insert new record failed.';
			}
		}		
	}
	
	private function _addConfirmed() {
		$data['main_content'] = 'tranx/cashfloat/cash_float_add_confirm_view';
		$this->load->view('includes/template', $data);
	}
	
	private function insertNewCashFloat() {
		
		$strQry = sprintf("INSERT INTO cashfloat SET refno='%s', particulars='%s', amnt=%f, trnxdate='%s', cashier=%d",
							mysql_real_escape_string($this->input->post('refno')),
							mysql_real_escape_string($this->input->post('particulars')),
							mysql_real_escape_string($this->input->post('amnt')),
							mysql_real_escape_string($this->input->post('curdate')),
							mysql_real_escape_string($this->input->post('cashierid')));
		
		if(!$this->db->query($strQry))
			return FALSE;
		
		return TRUE;
	}
	
	private function retrieveAllCashFloat() {
		global $almd_userid;

		$strQry = sprintf("SELECT * FROM cashfloat WHERE cashier=%d AND trnxdate='%s' AND status='1'",
							$almd_userid, curdate());
		$record = $this->db->query($strQry)->result();
		
		return $record;
	}
	
	private function getTotalCashFloatAmount($resultset = array()) {
		$total = 0.00;
		
		foreach($resultset as $rec) {
			$total += $rec->amnt;
		}
		
		return $total;
	}
	
	private function _cashFloatUnable() {
		
		$data['main_content'] = 'tranx/cashfloat/cash_float_unable_view';
		$this->load->view('includes/template', $data);
		
	}
	
}