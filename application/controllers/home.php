<?php

class Home extends CI_Controller {
	
	public function __construct() {
	
		parent::__construct();
	
		// authorizes access
		authUser(array('sessvar' => array('uname', 'islog', 'fullname')));
	}
	public function index () {
		
		$window = almdMainFrameWindow::get_instance();
// 		call_debug($window);
		$data['content'] = $window->createWindow();
		$this->load->view('test_view', $data);
	}
	
	public function test() {

// 		$param = array(
// 				'script' => array(
// 						array('type' => 'text/javascript', 'src' => 'http://localhost/alamid/js/jsni.js'),
// 						array('type' => 'text/javascript', 'src' => '//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js')
// 				)
// 		);
		
// // 		call_debug($param);	
// 		almd_build_metascript($param);
// 		$xmlreader = new Xmlparser();
		

		
		
		$config = array(
				'db_server' => 'localhost',
				'db_user' => 'root',
				'db_name' => 'prodrive',
				'db_pass' => '',
				'db_tbl_prefix' => 'almd'
		);
		$dbhooks->_initialize();
		call_debug($almd->customer);


		
	}

}