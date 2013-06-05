<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Users extends CI_Controller {
	
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
			case 'viewusers':
				$this->_users();
				break;
			case 'addusers':
				$this->_addusers();
				break;
			case 'editusers':
				$this->_editusers($id);
				break;
			default:
				$this->_users();
		}
	}
	
	private function _users(){
		$data['users'] = $this->_userlists();
		$data['main_content'] = 'master/users/view_users';
		$this->load->view('includes/template', $data);
	}
	
	private function _addusers($err = ''){
		$data['error'] = $err;
		$data['utypes'] = $this->_usertypelists();
		$data['main_content'] = 'master/users/add_users';
		$this->load->view('includes/template', $data);
	}
	
	private function _editusers($id = '', $err = ''){
		if(empty($id))
			show_404();
		
		$data['error'] = $err;
		$data['utypes'] = $this->_usertypelists();
		$data['users'] = $this->_userlists($id);
		//call_debug($data['users']);
		$data['main_content'] = 'master/users/edit_users';
		$this->load->view('includes/template', $data);
	}
	
	private function _usertypelists($id = ''){
		global $almd_db;
		$almd_db = new Almdtables();
		
		$strqry = mysql_real_escape_string('SELECT * FROM `' . $almd_db->usertype . '` ');
		
		$query = $this->db->query($strqry);
		
		if( $query->num_rows() <1 )
			return false;
		
		return $query->result();
	}
	
	private function _userlists($id = ''){
		
		global $almd_db;
		$almd_db = new Almdtables();
		
		if(empty($id))
			$strqry = mysql_real_escape_string('SELECT us.u_id, us.fname, us.mname, us.lname, us.username, us.addr, us.status, ut.type, ut.id FROM `' . $almd_db->users . '` us LEFT JOIN `' . $almd_db->usertype .'` ut ON us.ut_id = ut.id');
		else
			$strqry = sprintf('SELECT us.u_id, us.fname, us.mname, us.lname, us.username, us.addr, us.status, ut.id,  ut.type FROM `%s` us LEFT JOIN `%s` ut ON us.ut_id = ut.id WHERE us.u_id="%s"',$almd_db->users, $almd_db->usertype, $id);
		
		$query = $this->db->query($strqry);
		
		if( $query->num_rows() <1 )
			return false;
		
		return $query->result();
	}
	
	private function _isUserExist($username){
		global $almd_db;
		$almd_db = new Almdtables();
		
		
			$strqry = sprintf('SELECT username 	FROM `%s` WHERE `username`="%s"', $almd_db->users, $username);
		
		$query = $this->db->query($strqry);
		
		if( $query->num_rows() > 0 )
			return false;
		
		return true;
	}
	
	public function validateaddusers(){
		$this->load->library('form_validation');
		$validation = $this->form_validation;
		
		$validation->set_rules('username', 'User Name',  'required');
		$validation->set_rules('utype', 'User Type',  'required');
		$validation->set_rules('pword', 'Password',  'required');
		$validation->set_rules('fname', 'First Name',  'required');
		$validation->set_rules('mname', 'Middle Name',  'required');
		$validation->set_rules('lname', 'Last Name',  'required');
		$validation->set_rules('addr', 'Address',  'required');
		if($validation->run() === FALSE) {
			$this->_addusers();
		} else {
			global $almd_db;
			$almd_db = new Almdtables();
			
			if(! $this->_isUserExist($this->input->post('username'))){
				$err = 'User name Already exist';
				$this->_addusers($err);
			}else{
				$db = $this->input;
				$strqry = 'INSERT INTO '. $almd_db->users . ' (`u_id`, `fname`, `mname`, `lname`, `username`, `pword`, `addr`, `ut_id` ) VALUES (NULL, "' . $db->post('fname') .'", "' . $db->post('mname') .'", "' . $db->post('lname') .'", "' . $db->post('username') .'", "' . md5($db->post('pword')) .'", "' . $db->post('addr') .'","' . $db->post('utype') .'")';
				
				$query = $this->db->query($strqry);
				if(!$query){
					$this->_addusers();
				}
				
				redirect( base_url() . 'master/users' );
			}
		}
	}
	
	public function validateeditusers(){
		$this->load->library('form_validation');
		$validation = $this->form_validation;
	
		$validation->set_rules('user_id', '',  'required');
		$validation->set_rules('username', 'User Name',  'required');
		$validation->set_rules('utype', 'User Type',  'required');
		$validation->set_rules('pword', 'Password',  'required');
		$validation->set_rules('fname', 'First Name',  'required');
		$validation->set_rules('mname', 'Middle Name',  'required');
		$validation->set_rules('lname', 'Last Name',  'required');
		$validation->set_rules('addr', 'Address',  'required');
		
		if($validation->run() === FALSE) {
			$this->_editusers($this->input->post('user_id'));
		} else {
			global $almd_db;
			$almd_db = new Almdtables();
			
			if( ! $this->_isUserExist($this->input->post('username'))){
				$err = 'User name Already exist';
				$this->_editusers($this->input->post('user_id'), $err);
			}else{
				$db = $this->input;
					
				$strqry = sprintf('UPDATE `%s` SET `username`="%s", `ut_id`="%s", `pword`="%s", `fname`="%s", `mname`="%s", `lname`="%s", `addr`="%s" WHERE u_id="%s" ', $almd_db->users, $this->input->post('username'), $this->input->post('utype'), md5( $this->input->post('pword') ), $this->input->post('fname'), $this->input->post('mname'), $this->input->post('lname'), $this->input->post('addr'),   $this->input->post('user_id') );
				
				$query = $this->db->query($strqry);
				if(!$query){
					$this->_editusers($this->input->post('user_id'));
				}
		
				redirect( base_url() . 'master/users/' );
			}
		}
	}
	
	public function ajaxdeluser(){
		$strQry = sprintf("DELETE FROM `users` WHERE `u_id`=%d", $this->input->post('id'));
		$query = $this->db->query($strQry);
		if(!$query)
			echo "0";
		else
			echo "1";
	}
	
}