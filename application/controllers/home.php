<?php

class Home extends CI_Controller {
	
	public function index () {
		$window = almdMainFrameWindow::get_instance();
			
		$data['content'] = $window->createWindow();		
		$this->load->view('test_view', $data);
		
		$str = 'Ako si tarzan hari ng kagubatan';
		//call_debug(trunc_words($str) );
		
		$dbhooks = new DBGenerator();
		$almd = almd_db::get_instance();
		
		call_debug($almd->muser);
		
		$config = array(
				'db_server' => 'localhost',
				'db_user' => 'root',
				'db_name' => 'prodrive',
				'db_pass' => '',
				'db_tbl_prefix' => 'almd'
		);
		$dbhooks->_initialize($config);

	}
	

}