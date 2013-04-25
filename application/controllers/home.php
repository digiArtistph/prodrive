<?php

class Home extends CI_Controller {
	
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
		
// 		$xmlfilename = 'alamid/structure/Form_elemets.xml';
// 		$xmlreader->loadXml($xmlfilename);
// 		$xmlreader->arrtoxml();
// 		call_debug($xmlreader->mParseData);
		

		
	}

}