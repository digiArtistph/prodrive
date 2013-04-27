<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Customer extends CI_Controller {
	
	public function __construct() {
	
		parent::__construct();
	
		// authorizes access
		authUser(array('sessvar' => array('uname', 'islog', 'fullname')));
	}
	
	public function index() {
		
		$window = almdMainFrameWindow::get_instance();
		$data['content'] = $window->createWindow();
		
		$this->load->view('test_view', $data);
	}
}