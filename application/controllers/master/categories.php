<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Categories extends CI_Controller {
	
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
			case 'viewcategories':
				$this->_categories();
				break;
			case 'addcategories':
				$this->_addcategories();
				break;
			case 'editcategories':
				$this->_editcategories($id);
				break;
			case 'feedbackcategories':
				$this->_feedbackcategories($id);
				break;
			default:
				$this->_categories();
		}
	}
	
	private function _categories(){
		$data['categories'] = $this->_categ_list();
		$data['main_content'] = 'master/categories/view_categories';
		$this->load->view('includes/template', $data);
	}
	
	private function _addcategories(){
		$data['categories'] = $this->_categ_list();
		$data['main_content'] = 'master/categories/add_categories';
		$this->load->view('includes/template', $data);
	}
	
	private function _editcategories($id){
		$categories = $this->_categ_list($id);
		if(false == $categories)
			show_404();
		
		$data['parents'] = $this->_categ_list();
		$data['categories'] = $categories;
		$data['main_content'] = 'master/categories/edit_categories';
		$this->load->view('includes/template', $data);
	}
	
	private function _deletecategories($id){
		$categories = $this->_categ_list($id);
		if(false == $categories)
			show_404();
		
		if( ! $this->_del_categories($id) )
			redirect( base_url() . 'master/categories/section/feedbackcategories/2' );
		
		redirect( base_url() . 'master/categories/' );
	}
	
	private function _feedbackcategories($id = ''){
		if(empty($id))
			$data['feedback'] = "";
		
		if($id==1)
			$data['feedback'] = "Success";
		elseif ($id==2) 
			$data['feedback'] = "Failed";
		
		$data['main_content'] = 'master/categories/feedback_categories';
		$this->load->view('includes/template', $data);
	}
	
	private function _categ_list($id = ''){
		global $almd_db;
		$almd_db = new Almdtables();
		
		if(empty($id))
			$strqry = mysql_real_escape_string('SELECT * FROM ' . $almd_db->categories);
		else
			$strqry = sprintf('SELECT * FROM `%s` WHERE categ_id="%s"',$almd_db->categories, $id);
		
		$query = $this->db->query($strqry);
		
		if( $query->num_rows() <1 )
			return false;
		
		return $query->result();
	}
	
	public function ajaxdelcat(){
		$strQry = sprintf("DELETE FROM `categories` WHERE `categ_id`=%d", $this->input->post('id'));
		$query = $this->db->query($strQry);
		if(!$query)
			echo "0";
		else
			echo "1";
	}
	
	public function validateaddcategories(){
		$this->load->library('form_validation');
		$validation = $this->form_validation;
		
		$validation->set_rules('cat_name', 'Category Name',  'required');
		$validation->set_rules('cat_parent', 'Category Parent',  'required');
		if($validation->run() === FALSE) {
			$this->_addcategories();
		} else {
			global $almd_db;
			$almd_db = new Almdtables();
			$db = $this->input;
			$strqry = 'INSERT INTO '. $almd_db->categories . ' (`categ_id`, `category`, `parent`) VALUES (NULL, "' . $db->post('cat_name') .'", "' . $db->post('cat_parent') .'")';
			
			$query = $this->db->query($strqry);
			if(!$query){
				redirect( base_url() . 'master/categories/section/feedbackcategories/2' );
			}
			
			redirect( base_url() . 'master/categories/' );
		}
	}
	
	public function validateeditcategories(){
		$this->load->library('form_validation');
		$validation = $this->form_validation;
		
		$validation->set_rules('cat', '',  'required');
		$validation->set_rules('cat_name', 'Category Name',  'required');
		$validation->set_rules('cat_parent', 'Parent Name',  'required');
		
		if($validation->run() === FALSE) {
			$this->_editcategories($this->input->post('cat'));
		} else {
			global $almd_db;
			$almd_db = new Almdtables();
			$db = $this->input;
			
			$strqry = sprintf('UPDATE `%s` SET `category`="%s", `parent`="%s" WHERE `categ_id`="%s" ', $almd_db->categories, $this->input->post('cat_name'), $this->input->post('cat_parent'),  $this->input->post('cat') );
			
			$query = $this->db->query($strqry);
			if(!$query){
				redirect( base_url() . 'master/categories/section/feedbackcategories/2' );
			}
				
			redirect( base_url() . 'master/categories/' );
		}
	}
}