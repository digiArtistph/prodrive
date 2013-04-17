<?php
class alamidDBScheaReader{
	
	private $dbgen;
	
	private function __construct(){	
	}
	
	protected function getTables(){
		
		$this->dbgen = new DBGenerator();
		
		if(false == $this->_getTables())
			return false;
		
		foreach ($this->_getTables() as $table){
			$preptbl = substr($table, $this->);
			call_debug($preptbl);
		}
	}
	
	private function _getTables(){
		$dbTables = $this->dbgen->_getTables();
		
		if($dbTables['rowCount']<0)
			return false;
		
		return $dbTables['mData'];
	}
	
	
}