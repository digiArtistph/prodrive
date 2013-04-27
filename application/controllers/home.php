<?php
// Array
// (
// 		[0] => Array
// 		(
// 				[field] => Array
// 				(
// 						[attrib] => Array
// 						(
// 								[type] => text
// 								[attrib] => class::textfield required hidden|href::'mailto:kenn_vall@yahoo.com'
// 								[siblings] => label[value::'%1$'|tag::open]|%s|label[tag:close]|span[class::error hidden]
// 								[parent] => p[class::defaultform masterfile|prior::1]|span[class::txtfld]
// 						)

// 				)

// 		)

// )
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
		$xml->getText(null, '{attrib}inputfield hidden shown|skill', '{siblings}student|First Name|Last Name');
		
		$items = preg_split('/\|/', 'inputfield hidden shown|skill');
		
		call_debug($items);
	}
}
