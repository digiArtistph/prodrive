<?php
/**
 * Description: alamid Database Generator
 * @author Mugs and Coffee
 * @written Norberto Q. Libago Jr.
 * @since Friday, April 19, 2013
 * @version 2.0.1
 *
 *
 *							
 *	1)	to backup database
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
 *	2) to import datase
 *
 *				$path = "c:/wamp/www/prodrive/";
 *				$filename = "prodrive20130427.sql";
 *				$dbhooks->loadDatabase($path, $filename);
 *
 *			it will import the database file 
 *
 *	3) returns 
 *
 *	
 */

class Alamiddbgenerator{
	
	public $mData;	// returns data from the function which called 
	
	public function backupDatabase($pathto = ''){	//exports data to designated file
		
		if($pathto == ''){
			$this->mData = 'Specify a valid Directory!!!';
			return false;
		}
		
		if(!$this->_isValidDir($pathto)){
			$this->mData = 'Specify a valid Directory!!!';
			mkdir($pathto);
		}
		
		if( !is_writable($pathto)){
			$this->mData = 'Cannot save Data to Specified directory!!';
			return false;
		}
		
		$path_mysqldump = '"' . realpath( FCPATH .  '../../') . "\\bin\\mysql\\mysql5.1.53\\bin\\mysqldump.exe\"";
		$DB_HOST = 'localhost';
		$DB_USER = 'root';
		$DB_PASS = '';
		$DB_NAME = 'prodrivedb';
		$filename = '\\' . $DB_NAME .date("Ymd") . '.sql';
		
		if( strlen($pathto) < 1 )
			$pathdir = realpath( ALAMIDSTRUCTURE  ) . $filename;
		else
			$pathdir = $pathto . $filename;
		
		$command = "{$path_mysqldump}  --opt --skip-extended-insert --complete-insert --host=".$DB_HOST." --user=".$DB_USER." --password=".$DB_PASS." ".$DB_NAME." > {$pathdir}";
		exec($command, $ret_arr, $ret_code);
		
		$this->mData = $pathdir;
		
		return true;
	}
	
	public function loadDatabase($path, $filename){		//load data to the database from which the filepath is required
		
		if( ($path == '') || ($filename == '') ){
			$this->mData = 'Pls Specify Valid Directory: ' . $path .$filename;
			return false;
		}
		
		if( !$this->_isValidDir( $path ) ){
			$this->mData = 'Pls Specify Valid Directory: ' . $path .$filename;
			return false;
		}
			
		$path_mysql = '"' . realpath( FCPATH .  '../../') . "\\bin\\mysql\\mysql5.1.53\\bin\\mysql.exe\"";
		$DBName = 'prodrivedb';
		
		if( strlen($path) < 1 )
			$pathdir = realpath(ALAMIDSTRUCTURE  ) . '\\' .$filename;
		else
			$pathdir = $path . '\\' .$filename;
		
		if(!is_readable($pathdir)){
			$this->mData = 'Cannot Read Data from directory: ' . $pathdir;
			return false;
		}
		
		$command = "{$path_mysql} -u root {$DBName} < {$pathdir}";
		
		set_time_limit(0);
		exec($command, $ret_arr, $ret_code);
		
		$this->mData = $pathdir;
		
		return true;
	}
	
	
	public function getfiledir($dirpath = ''){		//returns array prodrive database
		
		if( !$this->_isValidDir($dirpath) ){
			$this->mData = 'Pls Specify Valid Directory: ' . $path .$filename;
			return false;
		}
		if($dirpath == ''){
			$this->mData = 'Pls Specify Valid Directory: ' . $path .$filename;
			return false;
		}
		if(!is_readable($dirpath)){
			$this->mData = 'Cannot Read Data from directory: ' . $dirpath;
			return false;
		}
		
		$dirfiles  = opendir($dirpath);
		
		while (false !== ($filename = readdir($dirfiles)) ) {
			$files[] = $filename;
		}
		
		$arrdbFiles = $this->_prodrivedb($files);
		
		$this->mData = $arrdbFiles;
		
		return true;
	}
	
	private function _prodrivedb($files){		//return array of matches database_name.sql
		
			$pattern = ' /((P|p)rodrivedb)[\d]{8}(\.sql)/';
			$arrFiles = array();
			
			foreach ($files as $filename){
				$filename = trim($filename);
				
				if(preg_match($pattern, $filename)){
					$arrFiles[] = $filename;
				}
			}
			return $arrFiles;
		}
	

	private function _isValidDir($dir){		//checks valid dir
		
		$directory = realpath($dir);
		
		if( is_dir( $directory) )
			return true;
		else
			return false;
	}
	
}
?>