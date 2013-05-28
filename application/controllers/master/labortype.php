<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Labortype extends CI_Controller {
	
	public function __construct() {
	
		parent::__construct();
	
		// authorizes access
		authUser(array('sessvar' => array('uname', 'islog', 'fullname')));
	}
	
	public function index(){
		$this->section();
	}
	
	public function section(){
	
		$section = ($this->uri->segment(4)) ? $this->uri->segment(4) : '';
		$id = ($this->uri->segment(5)) ? $this->uri->segment(5) : '';
	
		switch($section){
			case 'viewlabortype':
				$this->_laborview();
				break;
			case 'addlabortype':
				$this->_addlabortype();
				break;
			case 'editlabor':
				$this->_editlabor($id);
				break;
			case 'deletelabor':
				$this->_deletelabor($id);
				break;
			default:
				$this->_laborview();
		}
	}
	
	private function _laborview(){
		$data['labortypes'] = $this->_laborlist();
		$data['main_content'] = 'master/labortype/view_types';
		$this->load->view('includes/template', $data);
	}
	
	private function _addlabortype(){
		$data['categories'] = $this->_categ_list();
		$data['main_content'] = 'master/labortype/add_types';
		$this->load->view('includes/template', $data);
	}
	
	private function _editlabor($id){
		$data['laborlists'] = $this->_laborlist($id);
		//call_debug($data['laborlists']);
		$data['categories'] = $this->_categ_list();
		$data['main_content'] = 'master/labortype/edit_types';
		$this->load->view('includes/template', $data);
	}
	
	private function _deletelabor($id){
		if($this->_del_labor($id))
			redirect( base_url() . 'master/labortype');
	}
	
	private function _categ_list(){
		global $almd_db;
		$almd_db = new Almdtables();
	
		if(empty($id))
			$strqry = mysql_real_escape_string('SELECT * FROM ' . $almd_db->categories);
	
		$query = $this->db->query($strqry);
	
		if( $query->num_rows() <1 )
			return false;
	
		return $query->result();
	}
	
	private function _laborlist($id = ''){
		global $almd_db;
		$almd_db = new Almdtables();
	
		if(empty($id))
			$strqry = mysql_real_escape_string('SELECT * FROM ' . $almd_db->labortype . ' lt LEFT JOIN ' . $almd_db->categories . ' ct ON lt.category = ct.categ_id');
		else
			$strqry = sprintf('SELECT * FROM `%s` WHERE laborid="%s"',$almd_db->labortype, $id);
	
		$query = $this->db->query($strqry);
	
		if( $query->num_rows() <1 )
			return false;
	
		return $query->result();
	}
	
	private function _del_labor($id){
		global $almd_db;
		$almd_db = new Almdtables();
	
		$strqry = sprintf('DELETE FROM `%s` WHERE `laborid`="%s"', $almd_db->labortype, $id);
	
		$query = $this->db->query($strqry);
	
		if( !$query )
			return false;
	
		return true;
	}
	
	public function validateaddlabor(){
		$this->load->library('form_validation');
		$validation = $this->form_validation;
		
		$validation->set_rules('lname', 'Category Name',  'required');
		$validation->set_rules('cat', 'Category Parent',  'required');
		if($validation->run() === FALSE) {
			$this->_addlabortype();
		} else {
			global $almd_db;
			$almd_db = new Almdtables();
			$db = $this->input;
			$strqry = 'INSERT INTO '. $almd_db->labortype . ' (`laborid`, `name`, `category`) VALUES (NULL, "' . $db->post('lname') .'", "' . $db->post('cat') .'")';
			
			$query = $this->db->query($strqry);
			if(!$query){
				$this->_addlabortype();
			}
				
			redirect( base_url() . 'master/labortype/' );
		}
	}
	
	public function validateeditlabor(){
		$this->load->library('form_validation');
		$validation = $this->form_validation;
		
		$validation->set_rules('lt', '',  'required');
		$validation->set_rules('lname', 'Labor type name',  'required');
		$validation->set_rules('cat', 'Category',  'required');
		if($validation->run() === FALSE) {
			$this->_editlabor($this->input->post('lt'));
		} else {
			global $almd_db;
			$almd_db = new Almdtables();
			$db = $this->input;
			
			$strqry = sprintf('UPDATE `%s` SET `name`="%s", `category`="%s" WHERE laborid="%s" ', $almd_db->labortype, $this->input->post('lname'), $this->input->post('cat'), $this->input->post('lt') );
			//call_debug($strqry);
			$query = $this->db->query($strqry);
			if(!$query){
				$this->_editlabor($this->input->post('lt'));
			}
				
			redirect( base_url() . 'master/labortype/' );
		}
	}
	
}