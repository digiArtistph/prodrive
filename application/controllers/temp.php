<?php

class Temp extends CI_Controller {
	
	public function index(){
		$data['main_content'] = 'datarecovery/backup_view';
		$this->load->view('includes/template', $data);
	}
}