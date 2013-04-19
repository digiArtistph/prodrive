<?php

/**
 * Description: Json parser
 * @author Mugs and Coffee
 * @written Norberto Q. Libago Jr.
 * @since Friday, April 19, 2013
 * @version 1.0.0
 *
 *
 *	1) Calls database predifined table
 *		$almd->customer 	returns [prefix of table]_customer
 *		$almd->joborder		returns [prefix of table]_joborder
 *
 *
 *	SAMPLE CODE
 *
 *		{CONTROLLER}
 *
 *			<?php
 *				class somecontroller extends CI_Controller {
 *
 *					public function index() {
 *
 *						$almd = almdtables::get_instance();
 *
 *						 echo $almd->customer; die(); 	// if prefix of predefined table is "almd"
 *					 									// it return "almd_customer"
 *					}
 *			?>
 *
 */

class almdtables extends alamidDBScheaReader{
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