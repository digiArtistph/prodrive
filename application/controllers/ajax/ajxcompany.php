<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Ajxcompany extends CI_Controller {
	
	public function deleteCompany() {
		$id = $this->input->post('code');
		
		$this->load->model('mdl_company');
		if($this->mdl_company->deleteCompany($id))
			echo 1;
		else
			echo 0;
	}
}