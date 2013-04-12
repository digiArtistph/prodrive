<?php
	class test extends CI_Controller {
 
 	public function index() {
 
 		get_dom_elem('<div>', true);    //returns </div> - DEFAULT get_dom_elem('<div>');
 		get_dom_elem('<div>', false);    //returns div
 
 		$mArr = array(
 						'title' => 'My Title', 
 						'class' => 'My_class_name',
 						'id' => 'My Id'
 						);
 
 		get_elem_properties($mArr);		//returns title="My Title" class="My class name" id="My Id"
 
 		$str = '';
 		
//  		call_debug(trunc_words($str, 4));
		
// 		echo get_dom_elem('<a>', true);

 		$arr1 = array('one' => 1, 'three' => 3, 'four' => 4);
 		$arr2 = array('two' => 2, 'three' => 15, 'five' => 5);
 		
 		$result = array_merge($arr1, $arr2);
 		
 		call_debug($result);
 				
		}
	}
?>