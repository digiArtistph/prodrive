<?php
class almd_db extends alamidDBScheaReader{
	private static $instance = null;
	

	private function __construct() {
		parent::setIndexes();
	}

	public function __clone() {
	}
	
	public static function get_instance() {
		if(! self::$instance instanceof self) {
			self::$instance = new self();
		}
	
		return self::$instance;
	}

}