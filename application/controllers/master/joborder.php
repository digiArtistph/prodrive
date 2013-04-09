<?php
class joborder extends CI_Controller{
	
	public function __construct(){
		parent::__construct();
	}
	
	public function index(){
		$this->section();
	}
	
	public function section(){
		
		$section = ($this->uri->segment(4)) ? $this->uri->segment(4) : '';
		
		switch($section) {
			case 'viewjoborder':
				$this->_viewjoborder();
				break;
			case 'newjoborder':
				$this->_newjoborder();
				break;
			default:
				$this->_viewjoborder();
		}
	}
	
	private function _viewjoborder(){
		$data['main_content'] = 'joborder/viewjoborder';
		$this->load->view('includes/template', $data);
	}
	
	
	private function _newjoborder(){
		$data['main_content'] = 'joborder/addjoborder';
		$this->load->view('includes/template', $data);
	}
	
	public function validateaddform(){
		
		$this->load->library('form_validation');
		$validation = $this->form_validation;
		
		$validation->set_rules('jodate', 'Date', 'required');
		$validation->set_rules('name', 'Name', 'required');
		$validation->set_rules('addr', 'Address', 'required');
		$validation->set_rules('vehicle', 'Vehicle', 'required');
		$validation->set_rules('plate', 'Plate', 'required');
		$validation->set_rules('color', 'Color', 'required');
		$validation->set_rules('contact', 'Contact', 'required');
		
		
		if($validation->run() ===  FALSE) {
			$this->_newjoborder();
		} else {
			$this->load->model('mdl_joborder');
			
			$params->name = $this->input->post('name');
			$params->address = $this->input->post('addr');
			$params->jodate = $this->input->post('jodate');
			$params->vid = $this->input->post('vehicle');
			$params->plate = $this->input->post('plate');
			$params->color = $this->input->post('color');
			$params->contact = $this->input->post('contact');
			
			if( ! $this->mdl_joborder->set_jo($params) )
				echo 'Error on updating some record.';
			else
				redirect(base_url());
		}
	}
}