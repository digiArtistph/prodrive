<?php
class test extends CI_Controller {
 
 	public function index() {

 		$json = '{"0": [""],"1": ["labor","fds","no value","sfd","sdf","edit|delete",""],"2": ["pnm","no value","fds","sfd","dsf","edit|delete",""],"3": ["labor","fds","no value","dfs","sfd","edit|delete",""],"4": ["pnm","no value","tongbes","sdf","ds","edit|delete",""]}';
		
 		call_debug(json_decode($json) );
	}
}
?>