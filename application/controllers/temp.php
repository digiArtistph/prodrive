<?php

class Temp extends CI_Controller {
	
	public function __construct() {
	
		parent::__construct();

		// authorizes access
		authUser(array('sessvar' => array('uname', 'islog', 'fullname')));
	}
	
	public function index(){
		$this->datarecovery();
	}
	
	public function datarecovery(){
		$data['main_content'] = 'datarecovery/recovery_page';
		$this->load->view('includes/template', $data);
	}
	
	public function databackup(){
		
		$data['drivers'] = $this->_loaddir();
		$data['main_content'] = 'datarecovery/backup_view';
		$this->load->view('includes/template', $data);
	}
	
	public function loaddata(){
		$data['drivers'] = $this->_loaddir();
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
			
			$dbgen = new Alamiddbgenerator();
			$dir = $this->input->post('dir') . '\\' . 'prodrive';
			
			if( !$dbgen->backupDatabase( $dir ) )
					$data['backup_feedback'] = 'Saving Prodrive Data failed !!!';
			else
				$data['backup_feedback'] = 'The Prodrive Data has been sent to : "' .$dbgen->mData .'"';
			
			$data['main_content'] = 'datarecovery/feedback_page';
			$this->load->view('includes/template', $data);
		}
	}
	
	public function validaterestore(){
	
		$this->load->library('form_validation');
		$validation = $this->form_validation;
	
		$validation->set_rules('dir', 'Directory',  'required');
		$validation->set_rules('datafile', 'Data file',  'required');
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
	
	private function _loaddir(){
		
		$mFilesystem = new COM('Scripting.FileSystemObject');
		$mMachinedrives = $mFilesystem->Drives;
		$type = array("Unknown","Removable","Fixed","Network","CD-ROM","RAM Disk");
		
		$drivesinmachine = array();
		$temp = array();
		foreach($mMachinedrives as $mdrives ){
			$drivespec = $mFilesystem->GetDrive($mdrives);
			
			$temp = array( $drivespec->DriveLetter. ':' => $drivespec->DriveLetter . ' - ' . $type[$drivespec->DriveType]);
			$drivesinmachine += $temp;
		
		}
		
		return $drivesinmachine;
	}
		
	
}