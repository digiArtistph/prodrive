<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Vehicle extends CI_Controller {
	
	public function __construct() {
	
		parent::__construct();
	
		// authorizes access
		authUser(array('sessvar' => array('uname', 'islog', 'fullname')));
	}
	
	public function index() {
		echo 'This is a vehicle page';
	}
}
