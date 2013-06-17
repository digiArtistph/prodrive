<?php if (! defined('BASEPATH')) exit ('No direct script access allowed.');


if (! function_exists('getHeader')) {
	
	function getHeader() {
		$CI =& get_instance();
		$data['section'] = getSection();
			
		$CI->load->view('includes/header', $data);
		
	}
}

if(! function_exists('getPagination')) {
	function getPagination() {
		$CI =& get_instance();
		
		$CI->load->view('includes/pagination');
	}
}

if(! function_exists('getMenuNav')) {
	function getMenuNav() {
		$CI =& get_instance();
		
		$data['section'] = getSection();
		
		$CI->load->view('includes/navigation', $data);
		
	}
}

if (! function_exists('getFooter')) {
	function getFooter() {
		
		$CI =& get_instance();
		
		$data['section'] = getSection();
		$CI->load->view('includes/footer', $data);
		
	}
}

if (! function_exists('getSection')) {
	function getSection() {
		
		$CI =& get_instance();
		$section = '';
		$sought = '';
		$uri = uri_string();
		
		// generic
		$sought =  $CI->uri->segment(1);
		
		switch($sought) {
			case 'home':
				$section = 'home';
				break;
			case 'tranx':
				$section = 'tranx';
				break;
			case 'master':
				$section = 'master';
				break;
				
			case 'reports':
				$section = 'reports';
				break;
			case 'login':
				$section = 'login';
				break;
			case 'reports':
				$section = 'reports';
				break;
			default:
				$section = 'home';
		}
				
		return $section;
	}
}

if(! function_exists('isTabSelected')) {
	function isTabSelected($section, $tag = 'selected', $part = 1) {
		echo isSection($section, $part) ? ' class="'. $tag . '" ' : '';
	}	
}

if(! function_exists('isSection')) {
		
		function isSection($section, $part = 1) {
			$CI =& get_instance();	
			
			if(strtolower($CI->uri->segment($part)) != strtolower($section))
				return FALSE;
						
			return TRUE;
		}		
}

if(! function_exists('toggleButton')) {
	function toggleButton($section, $tab = FALSE) {
		$CI =& get_instance();
		$val = '';
		$url = sprintf("%s/%s", $CI->uri->segment(1), $CI->uri->segment(2));
		
		if($tab) {
			if(strtolower($section) == strtolower($CI->uri->segment(1)))
				$val = " in ";
		} else {
			if(strtolower($section) == strtolower($url))
				$val = ' class="active" ';
		}
		
		return $val;	
	}
}

if(! function_exists('toggleBcrumbs')) {
	function toggleBcrumbs($section, $path) {
		$CI =& get_instance();
		$val = '';
		$url = sprintf("%s/%s", $CI->uri->segment(1), $CI->uri->segment(2));

		if(strtolower($path) == strtolower($url))
			$val = $section; 
		else
			$val = sprintf('<a class="ext_disabled" href="%s">%s</a>', base_url(strtolower($path)), $section); 

		return $val;	
	}
}

if ( ! function_exists('paginate_helper')) {
	function paginate_helper($links) {
		$pattern = '/<li class="disabled"\>([\d])+<\/li>/';
		$toreplace = '<li class="disabled"><a href="#">$1</a></li>';
		
		$page = preg_replace($pattern, $toreplace, $links);
		
		return $page;
	}
}

if ( ! function_exists('getsideBarAccidents')) {
	function getsideBarAccidents($flag) {
		
		$CI =& get_instance();
		
		switch($flag) {
			case 1: // today's accidents
				$strQry = sprintf("SELECT IF(ASCII(COUNT(a.acdntdate)), COUNT(a.acdntdate), 0) AS `count`  FROM accidents a WHERE a.acdntdate=CURDATE()");
				break;
				
			case 2: // last week's accidents
				$strQry = sprintf("SELECT IF(ASCII(COUNT(a.acdntdate)),COUNT(a.acdntdate), 0) AS `count`  FROM accidents a WHERE stamp BETWEEN DATE_SUB(a.stamp, INTERVAL 1 WEEK) AND CURDATE()");
				break;
				
			case 3:
				$strQry = sprintf("SELECT IF(ASCII(COUNT(a.acdntdate)), COUNT(a.acdntdate), 0) AS `count`  FROM accidents a WHERE stamp BETWEEN DATE_SUB(a.stamp, INTERVAL 2 MONTH) AND CURDATE()");	
				break;
				
			default:
				$strQry = sprintf("SELECT IF(ASCII(COUNT(a.acdntdate)), COUNT(a.acdntdate), 0) AS `count`  FROM accidents a WHERE a.acdntdate=CURDATE()");
		}
		
		// executes query
		$rec =  $CI->db->query($strQry)->result();
		
		return $rec[0]->count;
	}
}