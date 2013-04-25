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
	
	public $_mDB = 'sdf';
	
	public function __get($name){
		
		$dbTables = $this->_dbtables();		//returns all tables
		
		if($dbTables['rowCount']<0)
			return false;
		
		
		$tables = array();
		foreach ($dbTables['mData'] as $table){		// check table prefix and return tables preped
			
			$missingobject = substr($table, -strlen($name));  
			
			if($missingobject == $name){
				return $table;
				
			}
			
		}
		
		return 'no table';
	}
	
	public function __set($name, $val){
		$name = $val;
	}
	
	private function _setIndexes(){
		
		if(false == $this->_dbtables())
			return false;
		
		foreach ($this->_getTables() as $key => $index){
			$this->{$key} = $index;
		}
	}
	
	private function _dbtables(){
		
		$tables = array();
		$list_tables_sql = 'SHOW TABLES FROM prodrivedb';
		
		$this->_connectDB('localhost', 'root', '');
		$result = mysqli_query($this->_mDB,$list_tables_sql);
		
		if($result)
			while($table = mysqli_fetch_row($result)){
			$tables[] = $table[0];
		}
		
		$results = array(
				'rowCount' => mysqli_num_rows($result ),
				'mData' => $tables
		);
			
		//call_debug($results);
		return $results;
	}
	
	// 	connecting to database
	private function _connectDB($server, $user, $pass){
	
		$this->_mDB = mysqli_connect($server,$user,$pass);
	
		if (mysqli_connect_errno($this->_mDB)) {
			return false;
		}else
			return true;
	
	}
	
	private function _noMethod(){
		return false;
	}

}