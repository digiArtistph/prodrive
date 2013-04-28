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
		//$xml->getText(null, '{attrib}inputfield hidden shown|skill', '{siblings}student|First Name|Last Name');
		/*
		$walk = Array
			(
			   Array
			        (
			            'field' => Array
			                (
			                    'attrib' => Array
			                        (
			                            'type' => 'text',
			                            'attrib' => "class::textfield required hidden|href::'mailto:kenn_vall@yahoo.com",
			                            'siblings' => "label[tag::open]|%1$|%s|label[tag:close]|span[class::error hidden]|%2$|span[tag:close]",
			                            'parent' => "p[class::defaultform masterfile||prior::1||tag:open]|%^s|span[class::txtfld||tag::open]|%3$|span[tag::close]|p[tag:close]",
			                            'defaults' => "First Name|Required Field|Another Required Field"
			                        )
			
			                )
			
			        )
			
			);
		
			array_walk_recursive($walk, 'traversethis');
		
		
		$items = preg_split('/\|/', 'inputfield hidden shown|skill');
		$siblings = preg_split('/(?<!\|)\|(?!\|)/', "label[tag::open]|%1$|%s|label[tag:close]|span[class::error hidden]|%2$|span[tag:close]");
		$parent = preg_split('/(?<!\|)\|(?!\|)/', "p[class::defaultform masterfile||prior::1||tag:open]|%^s|span[class::txtfld||tag::open]|%3$|span[tag::close]|p[tag:close]");
		$attribs = preg_split('/(?<!\|)\|(?!\|)/', "class::textfield required hidden|href::'mailto:kenn_vall@yahoo.com'");
		
		call_debug($siblings, FALSE);
		call_debug($parent, FALSE);
		call_debug($attribs);
		*/
		
		//call_debug($items, FALSE);
		//echo 'Items[0] ' . $items[0];
	}
	
	
}
	function traversethis($item, $key) {
			echo "$key -> $item" . "<br />";
		}