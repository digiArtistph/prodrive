<?php

class Home extends CI_Controller {
	
	public function index () {
		// benchmarking
		$this->benchmark->mark('start');
		$window = almdMainFrameWindow::get_instance();
 		
		$data['content'] = $window->createWindow();
		$this->load->view('test_view', $data);
		
	}

	public function test () {
		global $almd_xmlparser;
		
		$filepath = 'alamid/structure/libs/form_elements/text.xml';
		$almd_xmlparser->resetdata();
		$almd_xmlparser->loadXml($filepath);			//reads xml from file
		$almd_xmlparser->arrtoxml();
		call_debug($almd_xmlparser->mParseData);
	}
	
	public function xml () {
		$xml = Formelement::get_instance();
		$xml->getAllFormElments();
	}
}
