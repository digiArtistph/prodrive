<?php
/**
 * 
 * @author Mugs and Coffee
 * @since Tuesday, April 9, 2013
 * @version 1.0
 * 
 */
class almdMainFrameWindow {
	
	/**
	 * This makes the class a singleton
	 */
	private function __construct() {
		
		echo 'Initialising alamid Main Frame Window';
		
	}
	
	/**
	 * Keeps the class unclonable
	 */
	public function __clone() {}
	
	public static function get_instance() {
		
	}
	
}

?>