<?php
/**
 * Description: alamid Database Generator
 * @author Mugs and Coffee
 * @written Norberto Q. Libago Jr.
 * @since Friday, April 19, 2013
 * @version 1.0.0
 *
 *
 *	1) calling the alamidDbgenerator
 *
 *			$dbhooks = AlamidDBGenerator::get_instance();
 *
 *	2)	initialize the database
 *							$config = array(
 *								'db_server' => 'database_server',
 *								'db_user' => 'database_user',
 *								'db_pass' => 'database_password',
 *								'db_name' => 'database_name',
 *								'db_tbl_prefix' => 'database_table_prefix'
 *						);
 *						$dbhooks->initialize($config);
 *		
 *			note:
 *					if $dbhooks->initialize(); has an empty parameters
 *						then 
 *							the config has a default paramerters
 *
 *							$config = array(
 *								'db_server' => 'localhost',
 *								'db_user' => 'root',
 *								'db_pass' => '',
 *								'db_name' => 'prodrivedb',
 *								'db_tbl_prefix' => 'almd'
 *						);
 *							
 *	3)	to backup database
 *				
 *				$path = <path/to/file/>
 *				$dbhooks->backupDatabase($path);
 *
 *				if $path is empty , or has no value
 *					then
 *					file will be put on "<root directory>/alamid/structure/<database file>.sql" 
 *
 *		
 *				
 *	4) to import datase
 *
 *				$path = "c:/wamp/www/prodrive/";
 *				$filename = "prodrive20130427.sql";
 *				$dbhooks->loadDatabase($path, $filename);
 *
 *			it will import the database file
 *
 *	
 */

 class almd_database{
	
	private $_mDB;
	private $mFile;
	
	private static  $_mDBServer = 'localhost';
	private static  $_mDBUser = 'root';
	private static  $_mDBPass = '';
	public static  $_mDBName = 'prodrivedb';
	private static $_mTblprefix = 'almd';
	
	
	public function __call($name,  $params) {
		
		$method = '_' . $name;
		if(method_exists($this, $method)) {
			return $this->$method($name, $params);
		} else {
			return $this->_noMethod($name);
		}
			
	}
	
	protected function _init(){
		$this->_setFileConfiguration();
		$this->_connectDB(self::$_mDBServer, self::$_mDBUser, self::$_mDBPass);
		$this->_constructDB();
		$this->_checktables();
	}
	
	protected function _setDatabaseConfig($name, $params){
		
		//print_r($params); die();
		
		if(array_key_exists('db_server', $params[0]))
			self::$_mDBServer = $params[0]['db_server'];
		
		if(array_key_exists('db_user', $params[0]))
			self::$_mDBUser = $params[0]['db_user'];
		
		if(array_key_exists('db_pass', $params[0]))
			self::$_mDBPass = $params[0]['db_pass'];
		
		if(array_key_exists('db_tbl_prefix', $params[0])){
			self::$_mTblprefix = $params[0]['db_tbl_prefix'];
			$this->_setFileConfiguration();
			$this->mFile->replacePrefix(self::$_mTblprefix);
		}
		
		if(array_key_exists('db_name', $params[0]))
			self::$_mDBName = $params[0]['db_name'];
		
	}
	
	protected function _defaultconfig(){
		$this->_setFileConfiguration();
		$this->mFile->replacePrefix(self::$_mTblprefix);
	}
	
	// 	connecting to database
	private function _connectDB($server, $user, $pass){
		
		$this->_mDB = mysqli_connect($server,$user,$pass);
		
		if (mysqli_connect_errno($this->_mDB)) {
			return false;
		}else
			return true;
	
	}
	
	private function _setFileConfiguration(){
	
		$configfile = array(
				'filename' => 'config.txt',
				'path' => APPPATH . '../alamid/structure/',
				'char_struct' => 'prefix:almd'
		);
	
		$this->mFile = new fileextension();
		$this->mFile->initialize($configfile);
	
		$prefix = $this->_getTableprefix();
		
		if($prefix['fd_cnt']>0){
			$this->mConsTbl = array( $prefix['fd_prefix'] .'_customer', $prefix['fd_prefix'] .'_joborder', $prefix['fd_prefix'] .'_labortype', $prefix['fd_prefix'].'_option', $prefix['fd_prefix'] .'_orderdetails', $prefix['fd_prefix'] .'_users', $prefix['fd_prefix'] .'_vehicle');
		}
	}
	
	//construct a default database if database name is not defined
	private function _constructDB(){
	
		$db_selected = mysqli_select_db($this->_mDB, self::$_mDBName );
		if (!$db_selected) {
				
			$sql = 'CREATE DATABASE ' . self::$_mDBName;	//create database
			if ( mysqli_query($this->_mDB, $sql ) )
				return true;
			else 
				return false;
		}else
			return true;
	}
	
	// check Database table if not existed
	private function _checktables(){
	
		$tables = $this->_getTables();
		if($tables['rowCount'] < 1){
			$this->_createTbl();
		}else{
			//$prefix =  $this->_getTableprefix();
			$this->_checkValidTables($tables['mData']);
		}
	}
	
	//gets all tables in database
	public function _getTables(){
	
		$tables = array();
		$list_tables_sql = 'SHOW TABLES FROM ' . self::$_mDBName;
		
		
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
	
	//checking if tables created are valid tables
	private function _checkValidTables($arrTables){
		
		$checkList = array();
		$prefix = $this->_getTableprefix();
		if($prefix['fd_cnt']> 0){
				
			foreach ($arrTables as $key){
				//call_debug($key);
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
				
			array_walk($tables, array('alamidDBGenerator', '_walkTables'), $dbTables);
		}
	}
	
	//walk array of table names to check what must be deliverd
	private function _walkTables(&$item, $key, $params){
		
		foreach ($params as $key2 => $val){
				
			if($key == trim($val) ){
				$query = mysqli_query( $this->_mDB, $item);
				
				if(!$query){
					return false;
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

}

class Alamiddbgenerator extends almd_database{
	private static $instance = null;
	private function __construct() {}
	public function __clone() {}
	
	public static function get_instance() {
		if(! self::$instance instanceof self) {
			self::$instance = new self();
		}
	
		return self::$instance;
	}
	
	public function initialize($config = array()){
		if(empty($config))
			parent::defaultconfig();
		else
			parent::setDatabaseConfig($config);
		
		parent::init();
	}
	
	public function backupDatabase($pathto = ''){
		
		$path_mysqldump = "\"C:\\wamp\\bin\\mysql\\mysql5.1.53\\bin\\mysqldump.exe\"";
		$DB_HOST = 'localhost';
		$DB_USER = 'root';
		$DB_PASS = '';
		$DB_NAME = parent::$_mDBName;
		$filename = '\\' . $DB_NAME .date("Ymd") . '.sql';
		
		if( strlen($pathto) < 1 )
			$pathdir = realpath(ALAMIDSTRUCTURE  ) . $filename;
		else
			$pathdir = $pathto . $filename;
		
		$command = "{$path_mysqldump}  --opt --skip-extended-insert --complete-insert --host=".$DB_HOST." --user=".$DB_USER." --password=".$DB_PASS." ".$DB_NAME." > {$pathdir}";
		exec($command, $ret_arr, $ret_code);
		
		return true;
	}
	
	public function loadDatabase($path, $filename){
		//call_debug('called d');
		$path_mysql = "\"C:\\wamp\\bin\\mysql\\mysql5.1.53\\bin\\mysql.exe\"";
		$DBName = parent::$_mDBName;
		
		if( strlen($path) < 1 )
			$pathdir = realpath(ALAMIDSTRUCTURE  ) . '\\' .$filename;
		else
			$pathdir = $path . '\\' .$filename;
		
		$command = "{$path_mysql} -u root {$DBName} < {$pathdir}";
		
		set_time_limit(0);
		exec($command, $ret_arr, $ret_code);
		
		return true;
	}
}
?>