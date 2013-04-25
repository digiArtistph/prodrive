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

class Alamiddbgenerator{
	
	public function backupDatabase($pathto = ''){
		
		$path_mysqldump = '"' . realpath( FCPATH .  '../../') . "\\bin\\mysql\\mysql5.1.53\\bin\\mysqldump.exe\"";
		$DB_HOST = 'localhost';
		$DB_USER = 'root';
		$DB_PASS = '';
		$DB_NAME = 'prodrivedb';
		$filename = '\\' . $DB_NAME .date("Ymd") . '.sql';
		
		if( strlen($pathto) < 1 )
			$pathdir = realpath(ALAMIDSTRUCTURE  ) . $filename;
		else
			$pathdir = $pathto . $filename;
		//call_debug($path_mysqldump);
		$command = "{$path_mysqldump}  --opt --skip-extended-insert --complete-insert --host=".$DB_HOST." --user=".$DB_USER." --password=".$DB_PASS." ".$DB_NAME." > {$pathdir}";
		exec($command, $ret_arr, $ret_code);
		
		return true;
	}
	
	public function loadDatabase($path, $filename){
		//call_debug('called d');
		$path_mysqldump = '"' . realpath( FCPATH .  '../../') . "\\bin\\mysql\\mysql5.1.53\\bin\\mysql.exe\"";
		$DBName = 'prodrivedb';
		
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