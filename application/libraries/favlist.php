<?php  if(!defined("BASEPATH")) exit("No direct script access allowed");
/**
 * 
 * This class manages the favorites list. 
 * Stores its data in the user's browser only
 * 
 * @package		CodeIgniter
 * @subpackage 	application/libraries
 * @category   	libraries
 * @license GPL
 * @author Kenneth "digiArtist" P. Vallejos
 * @since Thursday, April 26, 2012
 * @version 2.1.1
 * 
 */
class Favlist {
	
	private $CI;
	private $_mFavList;
	private $session;
	
	const favitems = 'FAVLIST';
		
	function __construct() {
			
// 		echo 'Initializing Favlist Class... <br />';		
		// initilizes some member variables
		$this->CI =& get_instance();		
		$config = array(
					'sess_cookie_name' => 'session_favlist',
					'sess_expiration' => 0,
					'sess_use_database' => FALSE,
					'sess_encrypt_cookie' => TRUE
				);
		
		$this->CI->load->library('session', $config, 'session_favlist');
		$this->session = $this->CI->session_favlist;
		
		// defines temp session variable
		$this->_mFavList = ($this->session->userdata(self::favitems)) ? $this->session->userdata(self::favitems) :  null;
		
		// always check the character if is not a comma //@neerevisit: This is a bug is the string on this session has a comma character on the last position. a quick fix has been done here
		if(preg_match('/,$/', $this->_mFavList)) {
			preg_match('/[\w\W](?=,)/', $this->_mFavList, $matches);
			$this->_mFavList = $matches[0];		
		}

			
	}
	
	public function addFav($item) {
		
		// reads data from sessionbrowser		
		if($this->_mFavList != null) {
			$lists = preg_split('/,/', $this->_mFavList);
			
			// trims string
			foreach ($lists as $list) {				
				$list = trim($list);
			}
			
			$lists[] = trim($item);
			
			// removes duplicates entry
			$lists = array_unique($lists);
			
			// converts array into string
			$strArry = implode(',', $lists);
			
			$this->_mFavList = $strArry;
			
			// saves data into sessionbrowser
			$params = $this->_mFavList;
			
			$this->session->set_userdata(self::favitems, $params);
			
		} else {

			$this->_mFavList = $item;
			
			// saves data into session_favlist session						
			$this->session->set_userdata(self::favitems, $item);

		}
		 	
		return TRUE;
		
	}

	public function removeFav($item) {
		$tempList = array();
		
		if($this->_mFavList!= null){
			$lists = preg_split('/,/', $this->_mFavList);
				
			// trims string
			foreach ($lists as $list) {
				if($list != $item)
					$tempList[] = $list;
			}
			
			$lists = $tempList;
			
			// converts array into string
			$strArry = implode(',', $lists);
				
			$this->_mFavList = $strArry;
				
			// saves data into sessionbrowser
			$params = $this->_mFavList;
				
			$this->session->set_userdata(self::favitems, $params);
		}
		
		return TRUE;
	}
	
	public function clearFav() {
		
		$this->_mFavList = '';		
		$params = $this->_mFavList;
		// clears the fav list items
		$this->session->set_userdata(self::favitems, $params);

		return TRUE;
	}
	
	public function readFav() {
		
		// retrieves the current list of items from the fav list
		return $this->_mFavList;
		
	}
		
	
}



