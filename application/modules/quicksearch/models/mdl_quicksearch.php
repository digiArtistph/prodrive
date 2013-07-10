<?php if(! defined("BASEPATH")) exit ('No direct script access allowed.');

class Mdl_quicksearch extends CI_Model {
	
	private $tableName;
	
	public function __construct() {
		$this->tableName = "joborder";
	}
	
	
	public  function find() {
		$customer = mysql_real_escape_string($this->input->post('customer'));
		$plateno =  mysql_real_escape_string($this->input->post('plateno'));
		$datefrom = mysql_real_escape_string($this->input->post('datefrom'));
		$dateto = mysql_real_escape_string($this->input->post('dateto'));
		$jounpaid = $this->input->post('jounpaid');
		$jopaid = $this->input->post('jopaid');
		$whereClause = '';
			
		// unpaid, customer or plateno
		//$whereClause .= sprintf("WHERE ((jo.plate LIKE '%c%s%c' OR cr.lname LIKE '%c%s%c' OR cr.fname LIKE '%c%s%c') AND (jo.`status`='1'))", 37,$plateno,37, 37,$customer,37, 37,$customer,37);
		// customer
		
		if($customer != "") {
			if($this->hasWhereClause($whereClause))
				$whereClause .= " AND (cr.lname LIKE '%" . $customer . "%' OR cr.fname LIKE '%" . $customer . "%')";
			else
				$whereClause .= "WHERE (cr.lname LIKE '%" . $customer . "%' OR cr.fname LIKE '%" . $customer . "%')";	
		}
		
		if($datefrom != "" && $dateto != ""){
			if($this->hasWhereClause($whereClause))
				$whereClause .=  " AND (trnxdate BETWEEN '" . $datefrom . "' AND '" . $dateto . "') ";
			else
				$whereClause .=  "WHERE (trnxdate BETWEEN '" . $datefrom . "' AND '" . $dateto . "') ";
		}
		
		if($plateno != ""){
			if($this->hasWhereClause($whereClause))
				$whereClause .=  " AND jo.plate LIKE '%" . $plateno . "%' ";
			else
				$whereClause .= "WHERE jo.plate LIKE '%" . $plateno . "%' ";
		}
		
		if($jounpaid == 'on' AND $jopaid == "") {
			if($this->hasWhereClause($whereClause))
				$whereClause .=  " AND jo.`status`='1' ";
			else
				$whereClause .= "WHERE jo.`status`='1' ";
		}
		
		if($jopaid == 'on' AND $jounpaid == "") {
			if($this->hasWhereClause($whereClause))
				$whereClause .=  " AND jo.`status`='0' ";
			else
				$whereClause .= "WHERE jo.`status`='0' ";
		}
		
		$strQry = sprintf("SELECT jo.jo_number as jo_num,jo.jo_id, ve.make as vehicle, cl.name as color, cr.fname, cr.mname, cr.lname, CONCAT(cr.lname, ', ', cr.fname) AS owner, jo.plate, jo.contactnumber as num, jo.address as addr, jo.trnxdate as date, fnc_joPayment(jo.jo_id) AS `balance`, fnc_dcrPayments(jo.jo_id) AS `payment` FROM $this->tableName jo LEFT JOIN vehicle ve on ve.v_id=jo.v_id LEFT JOIN customer cr on cr.custid=jo.customer LEFT JOIN color cl on cl.clr_id=jo.color ");
		$strQry .= $whereClause;
		$dataset = $this->db->query($strQry);
		$result['overallcount'] = $dataset->num_rows;
		$result['paginate'] = "";
		$result['records'] = $dataset->result();
		
		return $result;
	}
	
	private function hasWhereClause($hay) {
		
		$pattern = '/(?<=where\s)[\w\W]+/i';
		if(! preg_match($pattern, $hay))
			return FALSE;
		
		return TRUE;
		
	}
}