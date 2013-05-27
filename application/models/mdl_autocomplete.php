<?php
class mdl_autocomplete extends CI_Model{
	
	public function findkeyword($table, $culumn, $word){
		
		
		$strqry = 'SELECT `'. $culumn .'` FROM `'. $table. '` WHERE `'. $culumn .'`  like "'. $word .'%" ORDER BY `'. $culumn .'` ASC';
		
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