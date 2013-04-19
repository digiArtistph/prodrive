<?php

class Home extends CI_Controller {
	
	public function index () {
		
		$window = almdMainFrameWindow::get_instance();

		$data['content'] = $window->createWindow();		
		$this->load->view('test_view', $data);
			
	}
	
	public function test() {
		echo '<!DOCTYPE html><html lang="en"><head>';
		almd_build_meta();
		echo '</head>';
	}

}