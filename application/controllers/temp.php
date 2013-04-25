<?php

class Temp extends CI_Controller {
	
	public function index(){
		$this->datarecovery();
	}
	
	public function datarecovery(){
		$data['main_content'] = 'datarecovery/recovery_page';
		$this->load->view('includes/template', $data);
	}
	
	public function databackup(){
		$data['main_content'] = 'datarecovery/backup_view';
		$this->load->view('includes/template', $data);
	}
	
	public function loaddata(){
		$data['main_content'] = 'datarecovery/recovery_view';
		$this->load->view('includes/template', $data);
	}
	
	public function validatebackup(){
		
		$this->load->library('form_validation');
		$validation = $this->form_validation;

		$validation->set_rules('dir', 'Directory',  'required');
		if($validation->run() === FALSE) {		
			$this->datarecovery();
		} else {
			
			if( $this->_isValidDir( $this->input->post('dir') ) ){
				$dbgen = new Alamiddbgenerator();
				$dbgen->backupDatabase( $this->input->post('dir') );
				$data['backup_feedback'] = 'The Prodrive Data has been sent to : "' .$dbgen->mData .'"';
			}else{
				$data['backup_feedback'] = 'Saving Prodrive Data failed !!!';
			}
			
			$data['main_content'] = 'datarecovery/feedback_page';
			$this->load->view('includes/template', $data);
		}
	}
	
	public function dirdata(){
		
	}

	
	private function _isValidDir($dir){
		
		$directory = realpath($dir);
		
		if( is_dir( $directory) )
			return true;
		else
			return false;
	}
	
}