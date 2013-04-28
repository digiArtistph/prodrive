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
		
		echo $xml->getText(null, 'First Name', 'fname', 'Required Field');
		echo $xml->getText(null, 'Middle Name', 'mname', 'Required Field');
		echo $xml->getText(null, 'Last Name', 'lname', 'Required Field');
		echo $xml->getText(null, 'Address', 'address', 'Required Field');
		
	}
	
	
}
	function traversethis($item, $key) {
			echo "$key -> $item" . "<br />";
		}