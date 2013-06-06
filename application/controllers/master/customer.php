<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Customer extends CI_Controller {
	
	public function __construct() {
	
		parent::__construct();
	
		// authorizes access
		authUser(array('sessvar' => array('uname', 'islog', 'fullname')));
	}
	
	public function index(){
		$this->section();
	}
	
	public function section(){
	
		$section = ($this->uri->segment(4)) ? $this->uri->segment(4) : '';
		$id = ($this->uri->segment(5)) ? $this->uri->segment(5) : '';
	
		switch($section){
			case 'viewcustomer':
				$this->_customer();
				break;
			case 'addcustomer':
				$this->_addcustomer();
				break;
			case 'editcustomer':
				$this->_editcustomer($id);
				break;
			case 'feedbackcustomer':
				$this->_feedbackcustomer($id);
				break;
			default:
				$this->_customer();
		}
	}
	
	private function _customer(){
		$data['customers'] = $this->_custom_list();
		$data['main_content'] = 'master/customer/view_customer';
		$this->load->view('includes/template', $data);
	}
	
	private function _addcustomer(){
		$data['main_content'] = 'master/customer/add_customer';
		$this->load->view('includes/template', $data);
	}
	
	private function _editcustomer($id){
		$customer = $this->_custom_list($id);
		if(false == $customer)
			show_404();
		
		$data['customers'] = $customer;
		$data['main_content'] = 'master/customer/edit_customer';
		$this->load->view('includes/template', $data);
	}
	
	private function _deletecustomer($id){
		$customer = $this->_custom_list($id);
		if(false == $customer)
			show_404();
		
		if( ! $this->_del_customer($id) )
			redirect( base_url() . 'master/customer/section/feedbackcustomer/2' );
		
		redirect( base_url() . 'master/customer/' );
	}
	
	private function _feedbackcustomer($id = ''){
		if(empty($id))
			$data['feedback'] = "";
		
		if($id==1)
			$data['feedback'] = "Success";
		elseif ($id==2) 
			$data['feedback'] = "Failed";
		
		$data['main_content'] = 'master/customer/feedback_customer';
		$this->load->view('includes/template', $data);
	}
	
	private function _custom_list($id = ''){
		global $almd_db;
		$almd_db = new Almdtables();
		
		if(empty($id))
			$strqry = 'SELECT * FROM ' . $almd_db->customer . ' WHERE `status`="1"';
		else
			$strqry = sprintf('SELECT * FROM `%s` WHERE custid="%s"',$almd_db->customer, $id);
		
		$query = $this->db->query($strqry);
		
		if( $query->num_rows() <1 )
			return false;
		
		return $query->result();
	}
	
	public function ajaxdelcust(){
		$strQry = sprintf("DELETE FROM `customer` WHERE `custid`=%d", $this->input->post('id'));
		$query = $this->db->query($strQry);
		if(!$query)
			echo "0";
		else
			echo "1";
	}
	
	public function validateaddcustomer(){
		$this->load->library('form_validation');
		$validation = $this->form_validation;
		
		$validation->set_rules('fname', 'First Name',  'required');
		$validation->set_rules('mname', 'Middle Name',  'required');
		$validation->set_rules('lname', 'Last Name',  'required');
		$validation->set_rules('addr', 'Address',  'required');
		$validation->set_rules('phone', 'Phone Number',  'required');
		if($validation->run() === FALSE) {
			$this->_addcustomer();
		} else {
			global $almd_db;
			$almd_db = new Almdtables();
			$db = $this->input;
			$strqry = 'INSERT INTO '. $almd_db->customer . ' (`custid`, `fname`, `mname`, `lname`, `addr`, `phone`) VALUES (NULL, "' . $db->post('fname') .'", "' . $db->post('mname') .'", "' . $db->post('lname') .'", "' . $db->post('addr') .'", "' . $db->post('phone') .'")';
			$query = $this->db->query($strqry);
			if(!$query){
				redirect( base_url() . 'master/customer/section/feedbackcustomer/2' );
			}
			
			redirect( base_url() . 'master/customer/' );
		}
	}
	
	public function validateeditcustomer(){
		$this->load->library('form_validation');
		$validation = $this->form_validation;
		
		$validation->set_rules('ct_id', '',  'required');
		$validation->set_rules('fname', 'First Name',  'required');
		$validation->set_rules('mname', 'Middle Name',  'required');
		$validation->set_rules('lname', 'Last Name',  'required');
		$validation->set_rules('addr', 'Address',  'required');
		$validation->set_rules('phone', 'Phone Number',  'required');
		if($validation->run() === FALSE) {
			$this->_editcustomer($this->input->post('ct_id'));
		} else {
			global $almd_db;
			$almd_db = new Almdtables();
			$db = $this->input;
			
			$strqry = sprintf('UPDATE `%s` SET `fname`="%s", `mname`="%s", `lname`="%s", `addr`="%s", `phone`="%s" WHERE custid="%s" ', $almd_db->customer, $this->input->post('fname'), $this->input->post('mname'), $this->input->post('lname'), $this->input->post('addr'), $this->input->post('phone'),  $this->input->post('ct_id') );
			$query = $this->db->query($strqry);
			if(!$query){
				redirect( base_url() . 'master/customer/section/feedbackcustomer/2' );
			}
				
			redirect( base_url() . 'master/customer/' );
		}
	}
}