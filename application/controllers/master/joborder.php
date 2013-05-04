<?php if( !defined('BASEPATH')) exit('Direct script access not allowed');
class Joborder extends CI_Controller{
	
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
			case 'viewjobrder':
				$this->_joborder();
				break;
		
			default:
				$this->_joborder();
		}
	}
	
	private function _joborder(){
		
		$data['main_content'] = 'joborder/viewjoborder';
		$this->load->view('includes/template', $data);
	}
	
	public function autocomplete_vehicle(){
		$this->load->library('form_validation');
		$validation = $this->form_validation;
		
		$validation->set_rules('term', '',  'required');
		if($validation->run() === FALSE) {
			show_error('Please Check Url again');
		}else{
			$this->load->model('mdl_autocomplete');
			$temp = $this->mdl_autocomplete->findkeyword('vehicle', 'make' , $this->input->post('term'));
			$objarr = json_encode($temp);
			echo $objarr;
		}
	}
	
	public function autocomplete_color(){
		$this->load->library('form_validation');
		$validation = $this->form_validation;
	
		$validation->set_rules('term', '',  'required');
		if($validation->run() === FALSE) {
			show_error('Please Check Url again');
		}else{
			$this->load->model('mdl_autocomplete');
			$temp = $this->mdl_autocomplete->findkeyword('color', 'name' , $this->input->post('term'));
			$objarr = json_encode($temp);
			echo $objarr;
		}
	}
	
	public function autocomplete_labortype(){
		$this->load->library('form_validation');
		$validation = $this->form_validation;
	
		$validation->set_rules('term', '',  'required');
		if($validation->run() === FALSE) {
			show_error('Please Check Url again');
		}else{
			$this->load->model('mdl_autocomplete');
			$temp = $this->mdl_autocomplete->findkeyword('labortype', 'name' , $this->input->post('term'));
			$objarr = json_encode($temp);
			echo $objarr;
		}
	}
	
}