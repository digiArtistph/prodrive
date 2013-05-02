<?php
class Home extends CI_Controller {
	
	public function __construct() {
	
		parent::__construct();
	
		// authorizes access
		authUser(array('sessvar' => array('uname', 'islog', 'fullname')));
	}
	public function index () {
		// benchmarking
		$this->benchmark->mark('start');
		$window = almdMainFrameWindow::get_instance();
 		
		$data['content'] = $window->createWindow();
		$this->load->view('test_view', $data);
		
	}

	public function test () {
		global $almd_xmlparser;
			
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
	function traversethis($item, $key) {
			echo "$key -> $item" . "<br />";
		}
