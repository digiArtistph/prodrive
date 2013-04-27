<?php

class Dbtables{
	
	private static $tables;
	
	public static function getalltables(){
		self::_dbtables();
		return self::$tables;
	}
	
	private static function _dbtables(){
		$CI =& get_instance();
		$strQry = sprintf('SHOW TABLES FROM prodrivedb' );
		$query = $CI->db->query($strQry);
		
		if( $query->num_rows() <1 )
			return false;
		
		self::$tables['rowCount'] = $query->num_rows();
		
		self::$tables['mData'] = array();
		foreach ($query->result_array() as $key){
			self::$tables['mData'][] = $key['Tables_in_prodrivedb'];
			
		}
	}
	
}

?>