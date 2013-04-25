<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Customer extends CI_Controller {
	
	public function index() {
		
		$window = almdMainFrameWindow::get_instance();
		$data['content'] = $window->createWindow();
		
		$this->load->view('test_view', $data);
	}
}