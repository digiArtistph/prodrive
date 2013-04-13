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
		$prefix = $this->_getTableprefix();
		
		
		echo '<pre />';
		print_r($prefix);
		die();
		// initializes some variables
		foreach ($file_maker->mData as $key => $val) {
			$this->$key = trim($val);
		}
		
		$tables = $this->_getTables();
		if($tables['rowCount']<1){
// 			no tables
		}else{
			
			foreach ($tables['mData'] as $key){
				
				$subString =  substr($key, 0,$strlen);
				$dbTables = array(
						$fileData['prefix'] .'customer',
						$fileData['prefix'] .'joborder',
						$fileData['prefix'] .'labortype',
						$fileData['prefix'] .'option',
						$fileData['prefix'] .'orderdetails',
						$fileData['prefix'] .'users',
						$fileData['prefix'] .'vehicle'
						
						);
				foreach ($dbTables as $val){
					if($key == $val){
						//create table
					}
				}
			}
		}
	}
	
	private function _getTableprefix(){
		$config = array(
				'filename' => 'config.txt',
				'path' => APPPATH . '../alamid/classes/',
				'char_struct' => 'kenn:genius'
		);
		$file_maker = new file_extension();
		$file_maker->initialize($config);
		$file_maker->parseData();
		$fileData = $file_maker->mData;
		print_r($fileData); die();
		$results = array(
				'fd_prefix' => $fileData['prefix'],
				'fd_cnt' => strlen($fileData['prefix'])
				);
		return $results;
	}
	
	private function _createTable($tblName){
		$config = array(
				'filename' => 'config.txt',
				'path' => APPPATH . '../alamid/classes/',
				'char_struct' => 'kenn:genius'
		);
		$file_maker = new file_extension();
		$file_maker->initialize($config);
		$file_maker->parseData();
		$fileData = $file_maker->mData;
		
		$strlen2 = strlen($fileData['prefix']);
		$strlen = strlen($tblName) -1;
		
		$tables = substr($tblName, $strlen2, $strlen);
	//	if($tabl)
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