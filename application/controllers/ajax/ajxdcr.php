<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Ajxdcr extends CI_Controller {
	
	public function addDcrDetail() {
		$dcr_id = $this->input->post('post_dcr');
		$particulars = $this->input->post('post_particulars');
		$refno = $this->input->post('post_refno');
		$amnt = $this->input->post('post_amnt');
		$tender = $this->input->post('post_tender');
		
		
		$strQry = sprintf("CALL sp_addDcrDetails(" . $dcr_id . ", '" . $particulars . "', '" . $refno . "', " . $amnt . ", " . $tender . ", @status, @lastid)");  
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
	
	
	public function editDcrDetail() {
		// fields needed
		$particulars = $this->input->post('post_particulars');
		$refno = $this->input->post('post_refno');
		$amnt = $this->input->post('post_amnt');
		$tender = $this->input->post('post_tender');
		$dcrdtl_id = $this->input->post('post_dcrdtl_id');
		
				
		$strQrySp = sprintf("CALL sp_editDcrDetail('" . $particulars . "', '" . $refno . "', " . $amnt . ", " . $tender . ", " . $dcrdtl_id . ", @status)");
		$this->db->query($strQrySp);		
		$qryStatus = $this->db->query("SELECT @status AS `status`")->result();
		$l_status = 0;
		
		
		foreach ($qryStatus as $st) {
			$l_status = $st->status;
		}
		
		echo $l_status;
		
	}
	
	public function retrieveDcrDetails() {
		$dcr_id = $this->input->post('post_dcr_id');
		$strQry = sprintf("SELECT d.dcrdtl_id, d.particulars, d.refno, d.amnt, d.tender AS tendercode, t.name AS paytype, j.jo_number, j.plate, CONCAT(c.lname, ', ', c.fname) AS `customer`  FROM (((dcrdetails d LEFT JOIN tendertype t ON d.tender=t.tdr_id)LEFT JOIN joborder j ON d.refno=j.jo_id) LEFT JOIN customer c ON j.customer=c.custid) WHERE dcr_id=%d", $dcr_id);
		$record = $this->db->query($strQry)->result();
		
		echo json_encode($record);
	}
	
	public function deleteDcrDetail() {
		$dcrdtl_id = $this->input->post('post_dcrdtl_id');
		$l_status = 0;
		

		$strQrySp = sprintf("CALL sp_deleteDcrDetail(" . $dcrdtl_id . ", @status)");
		$this->db->query($strQrySp);
		$qryStatus = $this->db->query("SELECT @status AS `status`")->result();
		
		foreach ($qryStatus as $st) {
			$l_status = $st->status;
		}
		
		echo $l_status;
	}
	
	public function dcrReference() {
		
		$strQry = sprintf("SELECT j.jo_id, j.jo_number, j.plate , CONCAT(c.lname, ', ', c.fname) AS `customer`, j.trnxdate FROM joborder j LEFT JOIN customer c ON j.customer=c.custid WHERE j.`status`='1'");
		$record = $this->db->query($strQry)->result();
		
		$record = json_encode($record);
		
		echo $record;
		
	}
	
	public function dcrTender() {
		
		$strQry = sprintf("SELECT * FROM tendertype t;");
		$record = $this->db->query($strQry)->result();
		
		$record = json_encode($record);
		
		echo $record;
		
	}
	
	public function getJoItems() {
		
		$joId = $this->input->post('post_joid');
		$strQry = sprintf("SELECT j.jo_id, IF(l.name IS NULL, j.partmaterial, l.name) AS `particulars`, j.partmaterial, j.amnt FROM jodetails j LEFT JOIN labortype l ON j.labor=l.laborid WHERE j.jo_id=%d AND j.`status`='1'", $joId);
		$record = $this->db->query($strQry)->result();
		$record = json_encode($record);
		
		echo $record;
		
	}
	
}