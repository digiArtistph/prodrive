<?php

class Home extends CI_Controller {
	
	public function index () {
		$window = almdMainFrameWindow::get_instance();
			
		$data['content'] = $window->createWindow();		
		$this->load->view('test_view', $data);
		
		$xmlreader = new xmlparser();
		
		$xmlfilename = 'alamid/structure/Form_elemets.xml';
		$xmlreader->loadXml($xmlfilename);
		$xmlreader->arrtoxml();
		
		call_debug($xmlreader->mParseData);

	}
	

}