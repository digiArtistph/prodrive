<?php

class Ajxdcr extends CI_Controller {
	
	public function addDcrDetail() {
		$dcr_id = $this->input->post('post_dcr');
		$particulars = $this->input->post('post_particulars');
		$refno = $this->input->post('post_refno');
		$amnt = $this->input->post('post_amnt');
		$tender = $this->input->post('post_tender');
		
		$strQry = sprintf("CALL sp_addDcrDetails(" . $dcr_id . ", '" . $particulars . "', '" . $refno . "', " . $amnt . ", " . $tender . ", @status)"); 
		// on_watch($strQry);
		$this->db->query($strQry);
		$status = $this->db->query("SELECT @status AS `status`")->result();
		
		foreach ($status as $st) {
			echo $st->status;
		}
		
		
	}
}