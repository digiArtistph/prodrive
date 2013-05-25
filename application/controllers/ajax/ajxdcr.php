<?php

class Ajxdcr extends CI_Controller {
	
	public function addDcrDetail() {
		$dcr_id = $this->input->post('post_dcr');
		$particulars = $this->input->post('post_particulars');
		$refno = $this->input->post('post_refno');
		$amnt = $this->input->post('post_amnt');
		$tender = $this->input->post('post_tender');
		
		$strQry = sprintf("CALL sp_addDcrDetails(" . $dcr_id . ", '" . $particulars . "', '" . $refno . "', " . $amnt . ", " . $tender . ", @status, @lastid)"); 
		// on_watch($strQry);
		$this->db->query($strQry);
		$qryStatus = $this->db->query("SELECT @status AS `status`")->result();
		$qryLastid = $this->db->query("SELECT @lastid AS `lastid`")->result();
		$l_status = 0;
		$l_lastid = 0;
		
		
		// gets the status of the execution of the stored procedure
		foreach ($qryStatus as $st) {
			$l_status = $st->status;
		}
		
		
		// gets the last inserted id from the db
		foreach($qryLastid as $lstid) {
			$l_lastid = $lstid->lastid;
		}
		
		echo $l_status . '|' . $l_lastid;	
		
	}
}