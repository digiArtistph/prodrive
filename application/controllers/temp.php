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
	
	public function validaterestore(){
	
		$this->load->library('form_validation');
		$validation = $this->form_validation;
	
		$validation->set_rules('dir', 'Directory',  'required');
		$validation->set_rules('datafile', 'options',  'required');
		if($validation->run() === FALSE) {
			
			$this->loaddata();
		} else {
				$almddb = new Alamiddbgenerator();
				$pathto = realpath( $this->input->post('dir') );
				
				$almddb->loadDatabase($pathto, $this->input->post('datafile'));
				$data['backup_feedback'] = 'success';
				
				$data['main_content'] = 'datarecovery/recovery_feedback';
				$this->load->view('includes/template', $data);
		}
	}
	
	public function dirdata(){
		
		$this->load->library('form_validation');
		$validation = $this->form_validation;
		
		$validation->set_rules('directory', 'Directory',  'required');
		
		if($validation->run() === FALSE) {
			return false;
		} else {
			
			$almdb = new Alamiddbgenerator();
			if( !$almdb->getfiledir($this->input->post('directory') ) )
				echo '<option value="none">Select source file</option>';
			
			$options = json_encode($almdb->mData);
			echo $options;
		}
		
		
	}

	private function _isValidDir($dir){
		
		$directory = realpath($dir);
		
		if( is_dir( $directory) )
			return true;
		else
			return false;
	}
	
	private function _readfile($files){
		
		$pattern = ' /((P|p)rodrivedb)[\d]{8}(\.sql)/';
		
		$sqlfiles = array();
		
		foreach ($files as $filename){
			
			$filename = trim($filename);
			
			if(preg_match($pattern, $filename)){
				$sqlfiles[] = $filename;
			}
		}
		
		return $sqlfiles;
	}
}