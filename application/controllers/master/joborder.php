<?php if( !defined('BASEPATH')) exit('Direct script access not allowed');
class joborder extends CI_Controller{
	
	public function __construct() {
	
		parent::__construct();
	
		// authorizes access
		authUser(array('sessvar' => array('uname', 'islog', 'fullname')));
	}
	
	public function index() {
		echo 'Job Order Page';
	}
}