<?php

class Home extends CI_Controller {
	
	public function index () {
		$window = almdMainFrameWindow::get_instance();
			
		$data['content'] = $window->createWindow();		
		$this->load->view('test_view', $data);
		
		$str = 'Ako si tarzan hari ng kagubatan';
		//call_debug(trunc_words($str) );
		
		$dbhooks = new DBGenerator();

	}
	

}