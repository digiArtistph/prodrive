<?php

class Home extends CI_Controller {
	
	public function index () {
		// echo 'this is a homepage.' . '<br />';
		
		$window = almdMainFrameWindow::get_instance();
		
		$data['content'] = $window->createWindow();		
		$this->load->view('test_view', $data);
		
		$arr = array(
				'title' => "my Title",
				'id' => "jun",
				'class' => "myClassName"
				);
		call_debug(get_elem_properties($arr) );
	}
	

}