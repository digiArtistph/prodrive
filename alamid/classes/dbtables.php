<?php

class Dbtables{
	
	private static $_mDB;
	private static $tables;
	
	public static function getalltables(){
		self::_dbtables();
		return self::$tables;
	}
	
	private static function _dbtables(){
		self::_connectDB('localhost', 'root', '');
		
		$tables = array();
		$list_tables_sql = 'SHOW TABLES FROM prodrivedb';
		$result = mysqli_query(self::$_mDB,$list_tables_sql);
	
		if($result)
			while($table = mysqli_fetch_row($result)){
			$tables[] = $table[0];
		}
	
		$results = array(
				'rowCount' => mysqli_num_rows($result ),
				'mData' => $tables
				);
		
		self::$tables = $results;
	}
	
		// 	connecting to database
	private static function _connectDB($server, $user, $pass){
	
		self::$_mDB = mysqli_connect($server,$user,$pass);
	
		if (mysqli_connect_errno(self::$_mDB)) {
			return false;
		}else
			return true;
	
	}
	
}

?>