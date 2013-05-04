<?php

class Find extends CI_Controller {
	
	public function __construct() {
	
		parent::__construct();
	
		// authorizes access
		authUser(array('sessvar' => array('uname', 'islog', 'fullname')));
	}
	
	public function index () {
		$this->_loadautocomplete();
	}
	
	private function _loadautocomplete(){
		global $almd_all_tables;
		
		if(empty($almd_all_tables))
			$almd_all_tables = Dbtables::getalltables();
		
		$data['tables'] = $almd_all_tables['mData'];
		$data['main_content'] = 'find/view_autocomplete';
		$this->load->view('includes/template', $data);
	}
	
	public function autocomplete(){
		$this->load->library('form_validation');
		$validation = $this->form_validation;
		
		$validation->set_rules('tbl', 'Table',  'required');
		$validation->set_rules('term', 'word',  'required');
		$validation->set_rules('tblcln', 'Culumn',  'required');
		if($validation->run() === FALSE) {
			show_error('Please Check Url again');
		}else{
			$this->load->model('mdl_autocomplete');
			$temp = $this->mdl_autocomplete->findkeyword($this->input->post('tbl'), $this->input->post('tblcln') , $this->input->post('term'));
			$objarr = json_encode($temp);
			echo $objarr;
		}
	}

}