<?php

class Find extends CI_Controller {
	
	public function __construct() {
	
		parent::__construct();
	
		// authorizes access
		authUser(array('sessvar' => array('uname', 'islog', 'fullname')));
	}
	
	public function index () {
		$data['main_content'] = 'find/view_autocomplete';
		$this->load->view('includes/template', $data);
	}
	
	public function autocomplete(){
		$arr = array('c++', 'python', $this->input->post('term'));
		$temp = json_encode($arr);
		echo $this->input->post('term');
	}

}