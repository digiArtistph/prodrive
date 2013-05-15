// JavaScript Document
$(function(){
	
	/* add button for dcr */
	$('#dcr_add_btn').click(function(){
		var particular_fld = $('#particular');
		var tender_fld = $('#tender');
		var refno_fld = $('#refno');
		var amount_fld = $('#amount');
		var master_details = $('#dcr_master_details');
		var newrow = '';
		
		//alert('Adding item');
		//alert(particular_fld.val() + ' ' + tender_fld.val() + ' ' + refno_fld.val() + ' ' + amount_fld.val());
		
		newrow += '<tr>';
		newrow += '<td>';
		newrow += particular_fld.val();
		newrow += '</td>';
		newrow += '<td>';
		newrow += tender_fld.val();
		newrow += '</td>';
		newrow += '<td>';
		newrow += refno_fld.val();
		newrow += '</td>';
		newrow += '<td>';
		newrow += amount_fld.val();
		newrow += '</td>';
		newrow += '<td></td>';
		newrow += '</tr>';
		
		// append new row into the master details of dcr entry form
		$('#dcr_master_details tbody').append(newrow);
		
		return false;
	});
	
	
});