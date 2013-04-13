<?php

class DBGenerator{
	
	private $mDB;
	private $mDBServer;
	private $mDBUser;
	private $mDBPass;
	private $mDBError;
	private $mDBReport;
	private $mDBName;
	private $mDBTblprefix;
	
	public function __construct(){
		
		$this->mDBReport = 'on';	// put empty value if u dont want mysql error reporting
		$this->mDBError = 'Oops !!! Error in Database: ';
		$this->mDBServer = 'localhost';
		$this->mDBUser = 'root';
		$this->mDBPass = '';
		$this->mDBName = 'prodriveDB';
		$this->mDBTblprefix = '';
		
		$this->_initialize();
	}
	
	private function _initialize($config = array()){
		
		if(!empty($config))
			$this->_getConfiguration($config);
		
		if(! $this->_connectDB() ){
			$this->_checkReport();
		}
		
		if(! $this->_constructDB()){
			$this->_checkReport();
		}
		
		$this->_checktables();
	}
	
	private function _getConfiguration($config){
		
		$this->mDBServer = $config['db_server'];
		$this->mDBUser = $config['db_user'];
		$this->mDBPass = $config['db_pass'];
		$this->mDBName = $config['db_name'];
	}
	
	private function _getTablePrefix(){
		
	}
	
	// 	connect to database
	private function _connectDB(){
		$this->mDB = mysql_connect($this->mDBServer, $this->mDBUser, $this->mDBPass);
		
		//return false if cannot connect to database
		if (!$this->mDB) {
			$this->mDBError .=  mysql_error(). '\n';
			return false;
		}else
			return true;
		
	}
	
	//construct database
	private function _constructDB(){
		
		
		$db_selected = mysql_select_db($this->mDBName, $this->mDB);
		
		if (!$db_selected) {
			
			//create database
			$sql = 'CREATE DATABASE ' . $DBname;
			if (mysql_query($sql, $link)) {
				$this->mDBError = 'DATABASE "' .$this->mDBName . '" created';
				return true;
			}else {
				$this->mDBError .=  mysql_error(). '\n';
				return false;
			}
		}else{
			$this->mDBError = 'DATABASE "' .$this->mDBName . '" connected';
			return true;
		}
	}
	
	private function _checktables(){
		echo 'df'; die();
		$tables = $this->_getTables();
		if($tables['rowCount']<1){
// 			no tables
		}else{
			echo 'sdf';
// 			check if tables have order,customer
			foreach ($tables['mData'] as $key){
				echo $key; die();
				//if()
			}
		}
	}
	
	private function _getTables(){
		$tables = array();
	    $list_tables_sql = "SHOW TABLES FROM {$this->mDBName};";
	    $result = mysql_query($list_tables_sql);
	    
	    if($result)
	    	while($table = mysql_fetch_row($result)){
	        	$tables[] = $table[0];
	    	}
	    	
	    $results = array(
	    		'rowCount' => mysql_num_rows($result ),
	    		'mData' => $tables
	    		);
	    
	    return $results;
	}
	
	private function _checkReport(){
		if($this->mDBReport == 'on'){
			echo $this->mDBError; die();
		}
	}
}