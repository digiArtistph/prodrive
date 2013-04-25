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
 *
 *						 echo $almd->customer; die(); 	// if prefix of predefined table is "almd"
 *					 									// it return "almd_customer"
 *					}
 *			?>
 *
 */


class Almdtables{
	
	public function __construct(){
		
	}
	
	public function __get($name){
		
		global $almd_all_tables;
		global $DBT;
		
		if($DBT == false){
			$almd_all_tables = Dbtables::getalltables();
			$DBT =  true;
		}
		
		if($almd_all_tables['rowCount']<0)
			return false;
		
		foreach ($almd_all_tables['mData'] as $table){		// check table prefix and return tables preped
			
			$missingobject = substr($table, -strlen($name));  
			if($missingobject == $name)
				return $table;
		}
		return 'no table';
	}
	

}