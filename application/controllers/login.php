<?php
class Login extends CI_Controller{
	
	private $_mName;
	private $_mUtype;
	private $_mUid;
	private $_mAcc;
	
	public function index(){
		$this->login_page();
	}
	
	public function login_page($param = ''){
		$data['uerror'] = $param;
		$data['main_content'] = 'userlogin/login_view';
		$this->load->view('includes/template_login', $data);
	}
	
	public function validatelogin(){
	
		$this->load->library('form_validation');
		$validation = $this->form_validation;
	
		$validation->set_rules('username', 'Username',  'required');
		$validation->set_rules('pword', 'Password',  'required');
		if($validation->run() === FALSE) {
			$this->login_page('Please logged in again!!!');
		} else {
			if( $this->__isUserExists($this->input->post('username'), $this->input->post('pword') ) ){
				$this->_loguser($this->input->post('username'), 1);
				$params = array(
						'uname' => $this->input->post('username'),
						'islog' => TRUE,
						'fullname' => $this->_mName,
						'uid' => $this->_mUid,
						'utype' => $this->_mUtype,
						'uaccess' => $this->_mAcc
				);
				$this->sessionbrowser->setInfo($params);
				
				redirect(base_url());
			}else{
				$this->_loguser($this->input->post('username'), 0);
				$data['uerror'] = 'Hi ' . $this->input->post('username') . '! Your username and password doesn\'t match';
				$data['main_content'] = 'userlogin/login_view';
				$this->load->view('includes/template_login', $data);
			}
			
			
		}
	}
	
	public function logout() {
	
		$params = array('uname', 'islog', 'fullname');
		$this->sessionbrowser->destroy($params);
	
		redirect(base_url());
	
	}
	
	private function __isUserExists($user, $pass) {
		
		$strQry = sprintf('SELECT us.username, us.fname, us.mname, us.lname, us.u_id, ut.type, ut.access FROM users us LEFT JOIN usertype ut on ut.id = us.ut_id WHERE username="%s" and pword="%s"', $user, md5($pass) );
		$query = $this->db->query($strQry);
		
		if( $query->num_rows() <1 ){
			return false;
		}
		
		foreach ( $query->result() as $key){
			
			
			$this->_mName = ucfirst($key->fname) . ' '  . ucfirst($key->lname);
			$this->_mUid = $key->u_id;
			$this->_mUtype = $key->type;
			$this->_mAcc = $key->access;
		}
		
		return true;
	}
	
	private function _loguser($username, $status) {
	
		$strQry = sprintf('INSERT INTO `logintrace` SET `username`="%s", `succeeded`="%d"', $username, $status);
		$query = $this->db->query($strQry);
	
		if(!$query)
			return false;
		else
			return true;
	}
}