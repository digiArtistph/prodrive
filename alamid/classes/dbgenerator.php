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
	private $mConsTbl;
	private $mTbl;
	private $mFile;
	

	public function __construct($config = array()){
		$this->_setFileConfiguration();	// set file configuration
		$this->_initialize($config);
	}
	
	//Database Configuration Settings
	private function _setDefaultDBConfiguration() {
		$this->mDBReport = 'on';	// put empty value if u dont want mysql error reporting
		$this->mDBError = 'Oops !!! Error in Database: ';
		$this->mDBServer = 'localhost';
		$this->mDBUser = 'root';
		$this->mDBPass = '';
		$this->mDBName = 'prodriveDB';
		$this->mDBTblprefix = '';
		
	}
	
	//if database configuration is set. this method is called
	private function _setDBConfiguration($config){
		
		if(! is_array($config))
			return false;
		
		$this->mDBServer = $config['db_server'];
		$this->mDBUser = $config['db_user'];
		$this->mDBPass = $config['db_pass'];
		$this->mDBName = $config['db_name'];
		$this->mFile->replacePrefix($config['db_tbl_prefix']);
	}
	
	//File Configuration Settings
	private function _setFileConfiguration(){
		$configfile = array(
						'filename' => 'config.txt',
						'path' => APPPATH . '../alamid/structure/',
						'char_struct' => 'kenn:genius'
						);
		
		$this->mFile = new fileextension();
		$this->mFile->initialize($configfile);
		
		$prefix = $this->_getTableprefix();
		if($prefix['fd_cnt']>0){
			$this->mConsTbl = array( $prefix['fd_prefix'] .'_customer', $prefix['fd_prefix'] .'_joborder', $prefix['fd_prefix'] .'_labortype', $prefix['fd_prefix'].'_option', $prefix['fd_prefix'] .'_orderdetails', $prefix['fd_prefix'] .'_users', $prefix['fd_prefix'] .'_vehicle');
		}
	}
	
	
	//initialize database
	public function _initialize($config = array()){
		
		if(empty($config)){
			call_debug('false');
			$this->_setDBConfiguration($config);
		}else {
			call_debug('true');
			$this->_setDefaultDBConfiguration();
		}
		
		if(! $this->_connectDB() ){
			$this->_checkReport();
		}
		
		if(! $this->_constructDB()){
			$this->_checkReport();
		}
		
		$this->_checktables();
	}
	
	// 	connecting to database
	private function _connectDB(){
		
		$this->mDB = mysql_connect($this->mDBServer, $this->mDBUser, $this->mDBPass);
		//return false if cannot connect to database
		if (!$this->mDB) {
			$this->mDBError .=  mysql_error(). '\n';
			return false;
		}else
			return true;
		
	}
	
	//construct a default database if database name is not defined
	private function _constructDB(){
		
		$db_selected = mysql_select_db($this->mDBName, $this->mDB);
		if (!$db_selected) {
			
			$sql = 'CREATE DATABASE ' . $this->mDBName;	//create database
			if (mysql_query($sql, $this->mDB)) {
				
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
	
	// check Database table if not existed
	private function _checktables(){
		
		$tables = $this->_getTables();
		if($tables['rowCount'] < 1){
			//create all tables
		}else{
			//$prefix =  $this->_getTableprefix();
			$this->_checkValidTables($tables['mData']);
		}
	}
	
	//checking if tables created are valid tables
	private function _checkValidTables($arrTables){
		
		$checkList = array();
		$prefix = $this->_getTableprefix();
		if($prefix['fd_cnt']<0){
			// create all tables
		}
		else {
			
			foreach ($arrTables as $key){
				$key = trim($key);
				foreach ($this->mConsTbl as $val){
					
					$val = trim($val);
					if($key == $val){
						array_push($checkList, $val);
					}
				} //end 2nd for each
				
			} //end 1st for each
			$this->_createTbl($checkList);
		}
		
	}
	
	// get the table prefix in config.txt
	public function _getTableprefix(){
		
		$this->mFile->parseData();
		
		$fileData = $this->mFile->mData;
		if(array_key_exists('kenn', $fileData)){
			
			$results = array(
						'fd_prefix' => 'none',
						'fd_cnt' => 0
					);
		}else{
			
			$results = array(
						'fd_prefix' => trim($fileData['prefix']),
						'fd_cnt' => strlen(trim($fileData['prefix']))
						);
		}
		
		return $results;
	}
	
	// creates table needed if user did not define configuration files
	private function _createTbl($params = array()){
		
		$dbTables = $this->_traverse_array_tables($params);
		$prefix = $this->_getTableprefix();
		
		$tables = array(
					$prefix['fd_prefix'] . '_customer' => 'CREATE TABLE ' .$prefix['fd_prefix'] . '_customer' .' (
															`c_id` int(11) NOT NULL AUTO_INCREMENT,
															  `f_name` varchar(50) NOT NULL,
															  `m_name` varchar(50) NOT NULL,
															  `l_name` varchar(50) NOT NULL,
															  `addr` mediumtext NOT NULL,
															  `phone` varchar(50) NOT NULL,
															  `status` enum("0","1") DEFAULT "0",
															  PRIMARY KEY (`c_id`)
															) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1',
					
					$prefix['fd_prefix'] . '_labortype' => 'CREATE TABLE ' .$prefix['fd_prefix'] . '_labortype' . ' (
															  `lt_id` int(11) NOT NULL AUTO_INCREMENT,
															  `name` varchar(50) NOT NULL,
															  `status` enum("0","1") DEFAULT "0",
															  PRIMARY KEY (`lt_id`)
															) ENGINE=InnoDB DEFAULT CHARSET=latin1',
					$prefix['fd_prefix'] . '_option' => 'CREATE TABLE ' . $prefix['fd_prefix'] . '_option' .' (
														  `id` int(11) NOT NULL AUTO_INCREMENT,
														  `option_name` mediumtext,
														  `option_value` longtext,
														  PRIMARY KEY (`id`)
														) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COMMENT="IMBA JUNTALS"',
					
					$prefix['fd_prefix'] . '_users' => 'CREATE TABLE ' . $prefix['fd_prefix'] . '_users' .' (
														  `u_id` int(11) NOT NULL AUTO_INCREMENT,
														  `f_name` varchar(50) NOT NULL,
														  `m_name` varchar(50) NOT NULL,
														  `l_name` varchar(50) NOT NULL,
														  `status` enum("0","1") DEFAULT "0",
														  PRIMARY KEY (`u_id`)
														) ENGINE=InnoDB DEFAULT CHARSET=latin1',
					$prefix['fd_prefix'] . '_vehicle' => 'CREATE TABLE ' . $prefix['fd_prefix'] . '_vehicle' .' (
														  `v_id` int(11) NOT NULL AUTO_INCREMENT,
														  `name` text,
														  PRIMARY KEY (`v_id`)
														) ENGINE=InnoDB AUTO_INCREMENT=85 DEFAULT CHARSET=latin1',
					$prefix['fd_prefix'] . '_orderdetails' => 'CREATE TABLE ' . $prefix['fd_prefix'] . '_orderdetails' .' (
														  `or_id` int(11) NOT NULL AUTO_INCREMENT,
														  `jo_id` int(11) NOT NULL,
														  `lt_id` int(11) NOT NULL,
														  `l_amnt` decimal(8,2) NOT NULL,
														  `parts` mediumtext NOT NULL,
														  `p_amnt` decimal(8,2) NOT NULL,
														  PRIMARY KEY (`or_id`),
														  KEY `lt_id` (`lt_id`),
														  CONSTRAINT `' .$prefix['fd_prefix'] . '_orderdetails_ibfk_1` FOREIGN KEY (`lt_id`) REFERENCES `' . $prefix['fd_prefix'] . '_labortype` (`lt_id`)
														) ENGINE=InnoDB DEFAULT CHARSET=latin1',
					$prefix['fd_prefix'] . '_joborder' => 'CREATE TABLE ' . $prefix['fd_prefix'] . '_joborder' . '(
																`jo_id` int(11) NOT NULL AUTO_INCREMENT,
																`u_id` int(11) NOT NULL,
																`v_id` int(11) NOT NULL,
																`c_id` int(11) NOT NULL,
																`or_id` int(11) NOT NULL,
																`plate` varchar(50) NOT NULL,
																`color` varchar(20) NOT NULL,
																PRIMARY KEY (`jo_id`),
																KEY `u_id` (`u_id`),
																KEY `v_id` (`v_id`),
																KEY `c_id` (`c_id`),
																KEY `or_id` (`or_id`),
																CONSTRAINT `' . $prefix['fd_prefix'] . '_joborder_ibfk_1` FOREIGN KEY (`u_id`) REFERENCES `' . $prefix['fd_prefix'] . '_users` (`u_id`),
																CONSTRAINT `' . $prefix['fd_prefix'] . '_joborder_ibfk_2` FOREIGN KEY (`v_id`) REFERENCES `' . $prefix['fd_prefix'] . '_vehicle` (`v_id`),
																CONSTRAINT `' . $prefix['fd_prefix'] . '_joborder_ibfk_3` FOREIGN KEY (`c_id`) REFERENCES `' . $prefix['fd_prefix'] . '_customer` (`c_id`),
																CONSTRAINT `' . $prefix['fd_prefix'] . '_joborder_ibfk_4` FOREIGN KEY (`or_id`) REFERENCES `' . $prefix['fd_prefix'] . '_orderdetails` (`or_id`) ON DELETE CASCADE ON UPDATE CASCADE
																) ENGINE=InnoDB DEFAULT CHARSET=latin1'
					);
		
		if($prefix['fd_cnt'] < 1){
			//get prefix
		}else{
			
			array_walk($tables, array('DBGenerator', '_walkTables'), $dbTables);
		}
	}
	
	//walk array of table names to check what must be deliverd
	private function _walkTables(&$item, $key, $params){
		
		foreach ($params as $key2 => $val){
			
			if($key == trim($val) ){
				
				$query = mysql_query($item, $this->mDB);
				if(!$query){
					call_debug(mysql_error());
				}
			}
			
		}
		
	}
	
	//traverse table for checking purposes
	private function _traverse_array_tables($params = array()){
		$tables = array();
		$tables = array_diff($this->mConsTbl, $params);
		return $tables;
	}
	
	
	//gets all tables in database
	public function _getTables(){
		
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
	
	// turning on the default error reporting
	private function _checkReport(){
		if($this->mDBReport == 'on'){
			echo $this->mDBError; die();
		}
	}
	
}