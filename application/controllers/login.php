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
						'fullname' => $this->_mName,
						'uid' => $this->_mUid,
						'utype' => $this->_mUtype,
						'uaccess' => $this->_mAcc
				);
				$this->sessionbrowser->setInfo($params);
				
				//
				$this->load->helper('sessionreader');
				
				read_session();
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
		
		$strQry = sprintf('SELECT us.username, us.fname, us.mname, us.lname, us.u_id, ut.type, ut.access FROM users us LEFT JOIN usertype ut on ut.id = us.ut_id WHERE username="%s" and pword="%s"', $user, md5($pass) );
		$query = $this->db->query($strQry);
		
		if( $query->num_rows() <1 ){
			return false;
		}
		
		foreach ( $query->result() as $key){
			
			if( !empty($key->mname) )
				$midname = ' ' . strtoupper( $key->mname[0] ). '.';
			else
				$midname = '.';
			
			$this->_mName = ucfirst($key->lname) . ', ' . ucfirst($key->fname) . $midname ;
			$this->_mUid = $key->u_id;
			$this->_mUtype = $key->type;
			$this->_mAcc = $key->access;
		}
		
		return true;
	}
}