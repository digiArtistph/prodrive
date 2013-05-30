<?php
class mdl_autocomplete extends CI_Model{
	
	public function findkeywordsingle($table, $culumn, $word){
		
		
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
	
	public function findkeyword($table, $culumn1, $culumn2, $word){
	
	
		$strqry = 'SELECT `'. $culumn1 .'`, `'. $culumn2 .'` FROM `'. $table. '` WHERE `'. $culumn2 .'`  like "'. $word .'%" ORDER BY `'. $culumn2 .'` ASC';
	
		$query = $this->db->query($strqry);
	
		if( $query->num_rows() <1 )
			return false;
	
		$rows = array();
		//call_debug($query->result_array());
		foreach($query->result_array() as $row )
		{
			$temp = array($culumn1 => $row[$culumn1], $culumn2 => $row[$culumn2]);
			array_push($rows, $temp);
	
		}
		return $rows;
	}
	
}