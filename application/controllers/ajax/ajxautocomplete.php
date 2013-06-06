<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Ajxautocomplete extends CI_Controller {
	
	public function vehicle() {
		
		$this->load->model('mdl_autocomplete');
		$record = $this->mdl_autocomplete->vehicle();
		$record = json_encode($record);
	
		echo $record;
	}
	
	public function color() {
		
		$this->load->model('mdl_autocomplete');
		$record = $this->mdl_autocomplete->color();
		$record = json_encode($record);
	
		echo $record;
	}
	
	public function customer() {
		
		$this->load->model('mdl_autocomplete');
		$record = $this->mdl_autocomplete->customer();
		$record = json_encode($record);
	
		echo $record;
	}
	
	public function ownedvehicle() {
		
		$this->load->model('mdl_autocomplete');
		$record = $this->mdl_autocomplete->ownedvehicle();
		$record = json_encode($record);
		
		echo $record;
	}

	public function vehiclereceived() {
		$this->load->model('mdl_autocomplete');
		$record = $this->mdl_autocomplete->getvehiclereceived();
		$record = json_encode($record);
		
		echo $record;
	}
}
	