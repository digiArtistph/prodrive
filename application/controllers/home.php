<?php

class Home extends CI_Controller {
	
	public function index () {
		global $almd_wrap;
		$window = almdMainFrameWindow::get_instance();
	
// 		$tmp = $almd_wrap->wrap(array('node'=>'div', 'prop' =>get_elem_properties(array('title' => 'Called_from_home', 'class' => 'home')), 'child' => 'Wrapper as global'));
// 		on_watch($tmp);
			
		$data['content'] = $window->createWindow();		
		$this->load->view('test_view', $data);
			
	}
	

}