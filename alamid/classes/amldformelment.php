<?php if (! defined('BASEPATH')) exit('No direct script access allowed.');

class Amldformelement {
	
	private static $instance = null;
	
	private function __construct() {}
	
	public function __clone() {}
	
	public static function get_instance() {
		if(! self::$instance instanceof self) {
			self::$instance = new self();
		}
		
		return self::$instance;
	}
	
	
}
