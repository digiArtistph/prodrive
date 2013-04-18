<?php
class alamidDBScheaReader{
	
	private $dbgen;
	
	private function __construct(){	
	}
	
	public function __call($name,  $params) {

		$method = '_' . $name;
	
		if(method_exists($this, $method)) {
			return $this->$method($name, $params);
		} else {
			return $this->_noMethod($name);
		}
			
	}
	
	private function _setIndexes(){
		
		$this->dbgen = new DBGenerator();
		
		if(false == $this->_getTables())
			return false;
		
		foreach ($this->_getTables() as $key => $index){
			$this->{$key} = $index;
		}
	}
	
	private function _getTables(){
		
		$dbTables = $this->dbgen->_getTables();		//returns all tables
		if($dbTables['rowCount']<0)
			return false;
		
		$prefix = $this->dbgen->_getTableprefix();	// returns prefix defined
		if($prefix['fd_cnt']<1)
			return false;
		
		$tables = array();
		foreach ($dbTables['mData'] as $table){		// check table prefix and return tables preped
			
			if(substr($table, 0, $prefix['fd_cnt']) == $prefix['fd_prefix']){
				$temp = array(substr($table, ($prefix['fd_cnt'] + 1), strlen($table)) => $table);
				$tables += $temp;
			}
		}
		
		return $tables;
	}
	
	private function _noMethod(){
		return false;
	}
	
}