<?php
class file_extension extends File_maker{
	
	public function replacePrefix($prefix_name){
		
		$strSession = "prefix:{$prefix_name}";
		
		if(! $handle = fopen($this->_appendSlash($this->_mPath) . $this->_mFilename, "w"))
			return FALSE;
		
		if(! fwrite($handle, $strSession))
			return FALSE;
			
		fclose($handle); 
		
	}
}