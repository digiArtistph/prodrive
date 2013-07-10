<?php if( ! defined("BASEPATH")) exit ();

class Templates extends MX_Controller {
	
	public function oneCol($data) {
		
		$data['main_content'] = $data['modules'] . '/' . $data['main_content'];
		//call_debug($data);
		$this->load->view('includes/template', $data);
		
	}
}