<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Mdl_cutoff extends CI_Model {
	
	public function cashFloatCutOff() {
		global $almd_userid;
		$curdate = curdate();
		
		$strQry = sprintf("UPDATE cashfloat SET `status`='0' WHERE trnxdate='%s' AND cashier=%d AND `status`='1'", $curdate, $almd_userid);
		
		if(! $this->db->query($strQry))
			return FALSE;
			
		return TRUE;
	}
	
	public function cashLiftCutOff() {
		global $almd_userid;
		$curdate = curdate();
		
		$strQry = sprintf("UPDATE cashlift SET `status`='0' WHERE trnxdate='%s' AND cashier=%d AND `status`='1'", $curdate, $almd_userid);
		
		if(! $this->db->query($strQry))
			return FALSE;
			
		return TRUE;
	}
	
	public function cashierCutOff() {
		global $almd_userid;
		$curDate = curdate();
		
		$strQry = sprintf("UPDATE dcr SET `status`= '0'  WHERE trnxdate='%s' AND cashier=%d", $curDate, $almd_userid);
		
		if(! $this->db->query($strQry))
			return FALSE;
			
		return TRUE;			
	}
	
	public function getCashLiftDetails() {
		global $almd_userid;
		$curdate = curdate();
		
		$strQry = sprintf("SELECT * FROM cashlift c WHERE cashier=%d AND trnxdate='%s' AND `status`='1'", $almd_userid, $curdate);
		$record = $this->db->query($strQry)->result();
		
		return $record;
	}
	
	public function getCashFloatDetails() {
		global $almd_userid;
		$curdate = curdate();
		
		$strQry = sprintf("SELECT * FROM cashfloat c WHERE cashier=%d AND trnxdate='%s' AND `status`='1'", $almd_userid, $curdate);
		$record = $this->db->query($strQry)->result();
		
		return $record;
	}
	
	public function getDailyCollection() {
		global $almd_userid;
		$curdate = curdate();
		
		$strQryDailyCollection = "CALL sp_DailyCollection(?, ?, ?)";
		// calls sp
		$this->db->query($strQryDailyCollection, array($almd_userid, $curdate, '1'));
		
		// full paid
		$records['fullpaid'] = $this->db->query("SELECT d.trnxdate, d.cashier, d.`status`, d.refno, d.amnt, t.name AS `tender`, d.particulars, d.paid FROM tmp_daily_collection d LEFT JOIN tendertype t ON d.tender=t.tdr_id WHERE paid=1")->result();
		// advances
		$records['advances'] = $this->db->query("SELECT d.trnxdate, d.cashier, d.`status`, d.refno, d.amnt, t.name AS `tender`, d.particulars, d.paid FROM tmp_daily_collection d LEFT JOIN tendertype t ON d.tender=t.tdr_id WHERE paid=0")->result();
		
		return $records;
	}
	
	public function getCashLiftTotal() {
		global $almd_userid;
		$curdate = curdate();
		
		$strQry = "SELECT fnc_getCashLift(?, ?, ?) AS `total`";
		$record = $this->db->query($strQry, array($almd_userid, curdate(), '1'))->result();
		
		foreach ($record as $rec) {
			return ($rec->total != '') ? $rec->total : '0.00';
		}
		
	}

	public function getCashFloatTotal() {
		global $almd_userid;
		$curdate = curdate();
		
		$strQry = "SELECT fnc_getCashFloat(?, ?, ?) AS `total`";
		$record = $this->db->query($strQry, array($almd_userid, curdate(), '1'))->result();
		
		foreach ($record as $rec) {
			return ($rec->total != '') ? $rec->total : '0.00';
		}
		
	}
}