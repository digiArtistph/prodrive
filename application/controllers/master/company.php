<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Company extends CI_Controller {
	private $_mModel;
	
	public function __construct() {
		
		parent::__construct();
		
		// authorizes access
		authUser(array('sessvar' => array('uname', 'islog', 'fullname')));
		
		$this->load->model('mdl_company');
		$this->_mModel = $this->mdl_company;
		
	}
	
	public function index() {
		
		$this->section();
		
	}
	
	public function section(){
		
		$section = ($this->uri->segment(4)) ? $this->uri->segment(4) : '';
		$id = ($this->uri->segment(5)) ? $this->uri->segment(5) : '';
	
		switch($section){
			case 'company':
				$this->_company();
				break;
			case 'addcompany':
				$this->_addcompany();
				break;
			default:
				$this->_company();
		}
	} 
	
	public function validateaddcompany() {
		
		$this->load->library('form_validation');
		$validation = $this->form_validation;
		
		$validation->set_rules('companyname', 'Company Name', 'callback_isCompanyExists');
		$validation->set_rules('addr');
		$validation->set_rules('phone', 'Phone', 'required');
		$validation->set_rules('fax');
		$validation->set_rules('email');
		$validation->set_rules('url');
		
		if($validation->run() === FALSE) {
			$this->_addcompany();
		} else {
			if($this->_mModel->addCompany())
				redirect(base_url('master/company'));
			else
				echo 'Inserting new record failed.';
		}
	}
	
	
	public function isCompanyExists($companyname) {
		$this->load->library('form_validation');
		$validation = $this->form_validation;
		
		if($this->_mModel->isUserExists($companyname)) {
			$validation->set_message('isCompanyExists', "$companyname already exists. Please enter another company name.");
			return FALSE;
		}
		
		if($companyname == "") {
			$validation->set_message('isCompanyExists', "The Company Name field is required.");
			return FALSE;
		}
			
		return TRUE;
	}
	
	private function _company() {
		
		$this->load->model('mdl_company');
		$dataset = $this->mdl_company->retrieveAllCompany();
		$data['companies'] = $dataset['records'];
		$data['count'] = $dataset['count'];
		$data['main_content'] = 'master/company/company_view';
		$this->load->view('includes/template', $data);
		
	}
	
	private function _addcompany() {
		
		$data['main_content'] = 'master/company/company_add_view';
		$this->load->view('includes/template', $data);
		
	}
}