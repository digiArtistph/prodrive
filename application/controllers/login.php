<?php
class Login extends CI_Controller{
	
	private $mName;
	
	public function index(){
		$this->login_page();
	}
	
	public function login_page($param = ''){
		$data['uerror'] = $param;
		$data['main_content'] = 'userlogin/login_view';
		$this->load->view('includes/template', $data);
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
				
				$params = array(
						'uname' => $this->input->post('username'),
						'islog' => TRUE,
						'fullname' => $this->mName
				);
				$this->sessionbrowser->setInfo($params);
				
				redirect(base_url());
			}else{
				$data['uerror'] = 'Hi ' . $this->input->post('username') . ' !!! Please Register First or Login again';
				$data['main_content'] = 'userlogin/login_view';
				$this->load->view('includes/template', $data);
			}
		}
	}
	
	public function logout() {
	
		$params = array('uname', 'islog', 'fullname');
		$this->sessionbrowser->destroy($params);
	
		redirect(base_url());
	
	}
	
	private function __isUserExists($user, $pass) {
		
		$strQry = sprintf('SELECT username, fname, mname, lname FROM users WHERE username="%s" and pword="%s"', $user, md5($pass) );
		$query = $this->db->query($strQry);
		
		if( $query->num_rows() <1 ){
			return false;
		}
		
		foreach ( $query->result() as $key){
			
			if( !empty($key->mname) )
				$midname = ' ' . strtoupper( $key->mname[0] ). '.';
			else
				$midname = '.';
			
			$this->mName = ucfirst($key->lname) . ', ' . ucfirst($key->fname) . $midname ;
		}
		
		return true;
	}
}