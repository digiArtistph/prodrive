<?php
class mdl_autocomplete extends CI_Model{
	
	public function findkeyword($table, $culumn, $word){
		global $almd_db;
		$almd_db = new Almdtables();

		$strqry = 'SELECT `'. $culumn .'` FROM `'. $almd_db->{$table}. '` WHERE `'. $culumn .'`  like "'. $word .'%"';
		
		$query = $this->db->query($strqry);
		
		if( $query->num_rows() <1 )
			return false;
		
		$rows = array();
		foreach($query->result_array() as $row )
		{
			$rows[] = $row[$culumn];
		}
		
		return $rows;
	}
	
}