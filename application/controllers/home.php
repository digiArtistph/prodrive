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
		$string = 'master/labortype/sectionviewlabortype/30';
		$pattern = '/'.addcslashes('^master/labortype', '/').'/';
		
		if(preg_match($pattern, $string))
			echo 'matched';
		else
			echo 'not matched';

		echo '<br />';
	
		$cntr = array('test' => 'Hello');
		call_user_func('arrayToDBOjbects');
		
		echo $cntr;
		
	}
		
}

function arrayToDBOjbects() {

}
