<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Ajxfilterperpage extends CI_Controller {
	
	public function setFilterPerPage() {
		
		$perpage = ($this->input->post('post_perpage')) ? $this->input->post('post_perpage') : 0;
		$url = ($this->input->post('post_url')) ? $this->input->post('post_url') : base_url();
		$params = array(
	 		'pgbookmark' => $url,
	 		'pgperpage' => $perpage
 		);
 			
 		$this->sessionbrowser->setInfo($params);
	}
	
	public function setBookMark() {
				
		$url = $this->input->post('post_bookmark');
		$params = array(
	 		'pgbookmark' => $url
 		);
 			
 		$this->sessionbrowser->setInfo($params);
 		
 		echo '1';
 		
	}
}