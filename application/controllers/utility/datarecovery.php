<?php
class Datarecovery extends CI_Controller {
	
	function __construct() {
	
		parent::__construct();
		authUser(array('sessvar' => array('uname', 'islog', 'fullname')));
			
	}
	
	public function index(){
		
		$data['sqlfiles'] = $this->_defaultdir_files();
		$data['main_content'] = 'datarecovery/datarecovery_view';
		$this->load->view('includes/template', $data);
	}
	
	private function _defaultdir_files(){
		if ($handle = opendir('./datawarehouse/')) {
			
			
			$results = array();
			while (false !== ($file = readdir($handle))) {
				if ($file == '.' || $file == '..') {
					continue;
				}
				
				if(substr($file, - 4) == ".sql"){
					array_push($results, $file);
				}
			}
		
			
		}
		
		closedir($handle);
		return $results;
	}
	
	public function backup(){
		$data['drivers'] = $this->_loaddir();
		$data['main_content'] = 'datarecovery/backup_view';
		$this->load->view('includes/template', $data);
		
	}
	
	public function dirdata(){
	
		$this->load->library('form_validation');
		$validation = $this->form_validation;
	
		$validation->set_rules('directory', 'Directory',  'required');
	
		if($validation->run() === FALSE) {
			return false;
		} else {
			define('ALAMIDCLASSES', FCPATH . '/alamid/classes/');
			require_once realpath(ALAMIDCLASSES . 'alamiddbgenerator.php');
			$almdb = new Alamiddbgenerator();
			if( !$almdb->getfiledir($this->input->post('directory') ) )
				echo '<option value="none">Select source file</option>';
				
			$options = json_encode($almdb->mData);
			echo $options;
		}
	
	
	}
	
	public function restore(){
		
		$data['drivers'] = $this->_loaddir();
		$data['main_content'] = 'datarecovery/recovery_view';
		$this->load->view('includes/template', $data);
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
	
	public function validatebackup(){
		$this->load->library('form_validation');
		$validation = $this->form_validation;
		
		$validation->set_rules('dir', 'Directory',  'required');
		if($validation->run() === FALSE) {
			$this->backup();
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
				
			$this->restore();
		} else {
			$almddb = new Alamiddbgenerator();
			$pathto = realpath( $this->input->post('dir') );
		
			$almddb->loadDatabase($pathto, $this->input->post('datafile'));
			$data['backup_feedback'] = 'success';
		
			$data['main_content'] = 'datarecovery/recovery_feedback';
			$this->load->view('includes/template', $data);
		}
	}
	
	public function validaterestoredefault(){
		$this->load->library('form_validation');
		$validation = $this->form_validation;
		
		$validation->set_rules('ajax', '',  'required');
		$validation->set_rules('file_name', '',  'required');
		if($validation->run() === FALSE) {
			return false;
		} else {
			define('ALAMIDCLASSES', FCPATH . '/alamid/classes/');
			require_once realpath(ALAMIDCLASSES . 'alamiddbgenerator.php');
			$almddb = new Alamiddbgenerator();
			$pathto = realpath( "./datawarehouse/" );
		
			echo $almddb->loadDatabase($pathto, $this->input->post('file_name'));
			
		}
	}
}
