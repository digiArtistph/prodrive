<?php if ( ! defined("BASEPATH")) exit ("No direct script access allowed.");

class Quicksearch extends MX_Controller {
	
	private $mModel;
	
	public function __construct() {
		
		$this->load->model('mdl_quicksearch');
		$this->mModel = $this->mdl_quicksearch;
	}
	
	public function index() {
		$this->section();
	}
	
	public function section() {
		
		$section = ($this->uri->segment(4)) ? $this->uri->segment(4) : '';
		$id = ($this->uri->segment(5)) ? $this->uri->segment(5) : '';
		
		switch($section){
		case 'search':
			$this->_search();
			break;
		default:			
			$this->_search();
		}
	}
	
	private function _search() {
		// if(isset($_POST['customer']))
			// call_debug($_POST);
		$data['main_content'] = "quick_search_view";
		$data['modules'] = "quicksearch";
		$dataset = $this->mModel->find();
		$data['joborders'] = $dataset['records'];
		$data['total_rows'] = $dataset['overallcount'];
		$data['paginate'] = '';
		echo modules::run('templates/oneCol', $data);	
	}
}