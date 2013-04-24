<?php

class Home extends CI_Controller {
	
	public function index () {
		
		$almd_db = new Alamiddbgenerator();
		$almd_db->loadDatabase("c:", 'prodrivedb20130424.sql');
		call_debug('');
		$dbhooks = AlamidDBGenerator::get_instance();
		$config = array(
				'db_server' => 'localhost',
				'db_user' => 'root',
				'db_pass' => '',
				'db_name' => 'prodrivedb',
				'db_tbl_prefix' => 'to'
				);
		$dbhooks->initialize($config);
	}
	
	public function test() {

		$param = array(
				'script' => array(
						array('type' => 'text/javascript', 'src' => 'http://localhost/alamid/js/jsni.js'),
						array('type' => 'text/javascript', 'src' => '//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js')
				)
		);
		
// 		call_debug($param);	
		almd_build_metascript($param);

	}

}