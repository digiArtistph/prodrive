<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Color extends CI_Controller {
	
	private $_mModel;
	
	function __construct(){
		parent::__construct();
		authUser(array('sessvar' => array('uname', 'islog', 'fullname')));
		
		$this->load->model('mdl_colors');
		$this->_mModel = $this->mdl_colors;
		
	}
	
	public function index(){
		$this->section();
	}
	
	public function section(){
	
		$section = ($this->uri->segment(4)) ? $this->uri->segment(4) : '';
		$id = ($this->uri->segment(5)) ? $this->uri->segment(5) : '';
		
		switch($section){
			case 'viewcolor':
				$this->_colors();
				break;
			case 'addcolor':
				$this->_addcolor();
				break;
			case 'editcolor':
				$this->_editcolor($id);
				break;
			case 'find':
				$this->_find();
				break;
			default:
				$this->_colors();
		}
	}

	private function _find(){
		
		$search = mysql_real_escape_string($this->input->post('search'));
		$dataset = $this->_mModel->find($search);
		$data['colors'] = $dataset['records'];
		$data['count'] = $dataset['overallcount'];
		$data['paginate'] = $dataset['paginate'];		
		$data['search_keyword'] = $search;
		
		$data['main_content'] = 'master/color/view_color';
		$this->load->view('includes/template', $data);
		
	}
	
	private function _colors(){
		
		$dataset = $this->_mModel->paginate();
		$data['colors'] = $dataset['records'];
		$data['count'] = $dataset['overallcount'];
		$data['paginate'] = $dataset['paginate'];
		$data['main_content'] = 'master/color/view_color';
		$this->load->view('includes/template', $data);
	}
	
	private function _colorlist($id = ''){
		global $almd_db;
		$almd_db = new Almdtables();
		
		if(empty($id))
			$strqry = mysql_real_escape_string('SELECT * FROM ' . $almd_db->color);
		else
			$strqry = sprintf('SELECT * FROM `%s` WHERE clr_id="%d"',$almd_db->color, $id);
		
		$query = $this->db->query($strqry);
		
		if( $query->num_rows() <1 )
			return false;
		
		return $query->result();
	}
	
	private function _addcolor(){
		$data['main_content'] = 'master/color/add_color';
		$this->load->view('includes/template', $data);
	}
	
	public function validateaddcolor(){
		$this->load->library('form_validation');
		$validation = $this->form_validation;
	
		$validation->set_rules('color_name', 'Color',  'required');
		if($validation->run() === FALSE) {
			$this->_addcolor();
		} else {
			global $almd_db;
			$almd_db = new Almdtables();
				
			$db = $this->input;
			$strqry = 'INSERT INTO '. $almd_db->color . ' (`clr_id`, `name` ) VALUES (NULL, "' . $db->post('color_name') .'")';
	
			$query = $this->db->query($strqry);
			if(!$query){
				$this->_addcolor();
			}
	
			redirect( base_url() . 'master/color' );
		
		}
	}
	
	private function _editcolor($id = ''){
		if(empty($id))
			show_404();
		
		$dataset = $this->_mModel->retrieveAllColors($id);
		$data['colors'] = $dataset['records']; // $this->_colorlist($id);
		$data['main_content'] = 'master/color/edit_color';
		$this->load->view('includes/template', $data);
	}
	
	public function validateeditcolor(){
		$this->load->library('form_validation');
		$validation = $this->form_validation;
	
		$validation->set_rules('clr_id', '',  'required');
		$validation->set_rules('clr_name', 'Color Name',  'required');
	
		if($validation->run() === FALSE) {
			$this->_editcolor($this->input->post('clr_id'));
		} else {
			global $almd_db;
			$almd_db = new Almdtables();
				
			$strqry = sprintf('UPDATE `%s` SET `name`="%s" WHERE `clr_id`="%d" ', $almd_db->color, $this->input->post('clr_name'), $this->input->post('clr_id') );
				
			$query = $this->db->query($strqry);
			if(!$query){
				$this->_editcolor($this->input->post('clr_id'));
			}
	
			redirect( base_url() . 'master/color/' );
		}
	}
	
	public function ajaxdelclr(){
		$strQry = sprintf("DELETE FROM `color` WHERE `clr_id`=%d", $this->input->post('id'));
		$query = $this->db->query($strQry);
		if(!$query)
			echo "0";
		else
			echo "1";
	}
}