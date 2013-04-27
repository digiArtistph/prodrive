<?php
	class test extends CI_Controller {
 
 	public function index() {
 		

 		global $almd_db;
 		$almd_db->option;
 		echo $almd_db->option . '<br />';
 		echo $almd_db->user . '<br />';
		
		}
	}
?>