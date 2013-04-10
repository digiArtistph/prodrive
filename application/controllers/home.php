<?php

class Home extends CI_Controller {
	
	public function index () {
		// echo 'this is a homepage.' . '<br />';
		
		$window = almdMainFrameWindow::get_instance();
		
		$data['content'] = $window->createWindow();		
		$this->load->view('test_view', $data);
		
	}
	

}