<?php

class Home extends CI_Controller {
	
	public function index () {
		$window = almdMainFrameWindow::get_instance();

		$data['content'] = $window->createWindow();		
		$this->load->view('test_view', $data);
			
	}
	
	
	public function test () {
// 		$json = '{"right":"name1", "left":"name2"}';
		
// // 		$obj = json_decode($json);
// 		$obj = json_decode($json);
// 		echo $obj->right;

		add_settings('section_canvas', 'functiononehundred');
		on_watch(get_setting('section_mastheads', FALSE, FALSE));
	}

}