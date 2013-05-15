<?php if(!defined('BASEPATH')) exit('No direct script access allowed');

	if(!function_exists('read_session')) {
		/**
		 * Pass an array in the parameter.
		 * @author Kenneth "digiArtist_ph" P. Vallejos
		 * @param array $obj, $flag This is passed into the function for debugging purposes.
		 * @return null
		 */
		function read_session() {
			
			global $almd_username;
			global $almd_useraccess;
			global $almd_userfullname;
			global $almd_userisloggedin;
			global $almd_userid;
			global $sesarr;
			
			if(empty($sesarr)){
				$CI = get_instance();
				$CI->load->library('file_maker');
				$CI->file_maker->parseData();
				$seskey = $CI->file_maker->mData;
				$params = array();
					
				foreach ($seskey as $key => $val){
					array_push($params, $key);
				}
					
					
				$CI->load->library('sessionbrowser');
					
				$CI->sessionbrowser->getInfo($params);
				$sesarr = $CI->sessionbrowser->mData;
			}else{
			
				if(!empty($almd_username))
					return false;
				else{
					$almd_username = $sesarr[$params[0]];
					$almd_useraccess = $sesarr[$params[5]];
					$almd_userfullname = $sesarr[$params[2]];
					$almd_userisloggedin = $sesarr[$params[1]];
					$almd_userid = $sesarr[$params[3]];
				}
			
			}
		}
		
	}
	
