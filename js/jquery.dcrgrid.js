 // JavaScript Document
/**
 * @author Mugs and Coffee
 * @written Kenneth "digiArtist_ph" P. Vallejos
 * @since Wednesday, May 15, 2013
 * 
 */
(function($){
	var dcrbase_url = $('meta[name*="url"]').attr('content');
	$.fn.dcrgrid = function(options) {
		var curObj = $(this);
		var settings = $.extend({}, options);
		
		// builds datagrid
		curObj.append(tableEntry);
		curObj.append(tablegrid);
		// curObj.append(bntSaveDcrDetails);
		
		// event listeners
		$('#addbtn').bind('click', evtAdd);		
		$('#btnDcrSave').bind('click', evtbtnSaveDcrDetails);
		$('select[name="refernce"]').bind('change',evtChangeReference);
	}
	
	var loadDataGridExistingData = function() {
		// reads dcrdetails table
		var output = '';
		var mDcrId = $('#dcr_id').val();
		
		$.post(dcrbase_url + 'ajax/ajxdcr/retrieveDcrDetails', {post_dcr_id:mDcrId})
		.success(function(data) {
			data = $.parseJSON(data);
			for(var dt in data) {
				output += '<tr' + buildDataProp(data[dt]) + '>';
//				console.log(data[dt].dcrdtl_id + " || " + data[dt].particulars + " || " + data[dt].refno + " || " + data[dt].paytype);
				output += '<td>' + data[dt].refno + '</td> ' + '<td>' + data[dt].paytype + '</td>' +  '<td>' + data[dt].particulars + '</td>' + '<td class="currency">' + data[dt].amnt + '</td>' + '<td><a class="EditBtn" href="#">Edit</a>&nbsp;<a class="DelBtn" href="#">Delete</a></td>';
				output += '</tr>';
			}
			$('#datagrid tbody').append(output);
			
			// event listeners
			$('.DelBtn').bind('click', evtDelBtn);
			$('.EditBtn').bind('click', evtEditData);
		});
	} 
	
	var bntSaveDcrDetails = function() {
		var output = '';		
		
		output += '<p>';
		output += '<input id="btnDcrSave" type="button" value="Save" />';
		output += '</p>';
		
		
		return output;
	}

	var tablegrid = function() {
		var output = '';
		
		
		output += '<table id="datagrid">';
		output += '<thead>';
		output += '<tr>';
		output += '<th>Reference No.</th>';
		output += '<th>Tender</th>';
		output += '<th>Particular</th>';		
		output += '<th>Amount</th>';
		output += '<th>Action</th>';
		output += '</tr>';
		output += '</thead>';
		output += '<tbody>';
		output += '</tbody>';
		output += '</table>';
		
		
		// loads existing data into the datagrid
		loadDataGridExistingData();
		
		
		return output;		
	}
	
	var tableEntry = function() {
		var output = '';
		
		getTender();
		getDcrReference();
		
		output += '<table id="entryfield">';
		output += '<thead>';
		output += '<tr>';
		output += '<th>Reference No.</th>';
		output += '<th>Tender</th>';
		output += '<th>Particular</th>';
		output += '<th>Amount</th>';
		output += '<th>Action</th>';
		output += '</tr>';
		output += '</thead>';
		output += '<tbody>';
		output += '<tr>';
		output += '<td><select name="refernce"><option value=""> Select a reference no. </option><option value="walk-in">Walk-In</option></select></td>';
		output += '<td><select name="tender"><option value=""> Select a tender </option></select></td>';
		output += '<td><input type="text" name="particular" /></td>';		
		output += '<td><input class="datavaldecimal" type="text" name="amount" value="0.00" /></td>';
		output += '<td><input type="button" id="addbtn" value="Add" /></td>';
		output += '</tr>';
		output += '</tbody>';
		output += '</table>';
		
		return output;
	}
	
	// event handlers
	var evtChangeReference = function(){
		alert($('option:selected',this).text());
	}
	
	var evtbtnSaveDcrDetails = function() {
		alert("You've pressed the Save button");
		return false;
	}
	
	var evtAdd = function() {
		var mButton = $('#addbtn');
		var output = '';
		var mParticular;
		var mTender;
		var mTenderCode;
		var mReferenceNo;
		var mReferenceNoCode;
		var mAmt;

		
		// if button is in edit mode
		if(mButton.attr('value')== 'Add') {
			mParticular = $('input[name="particular"]').val();
			mTender = $('select[name="tender"] option:selected').text();
			mTenderCode = $('select[name="tender"] option:selected').val();
			mReferenceNo = $('select[name="refernce"] option:selected').text();
			mReferenceNoCode = $('select[name="refernce"] option:selected').val();
			mAmt = $('input[name="amount"]').val();
			mDcrId = $('#dcr_id').val();
			
			
			if(mParticular == "" || mAmt == "" || mTenderCode == "")
				return;
		
			// AJAX part
			$.post(dcrbase_url + 'ajax/ajxdcr/addDcrDetail', {post_dcr: mDcrId , post_particulars: mParticular, post_refno: mReferenceNoCode, post_amnt: mAmt, post_tender: mTenderCode})
			.success(function(data){
				// parse returned data from ajax call
				var returnedData = data.split("|");
				
				if(returnedData[0] == "1") {
				// appends new dom
				
				// creates new object to be passed into the attribute maker
				var dt = {'particulars': mParticular, 'tendercode': mTenderCode, 'refno': mReferenceNoCode, 'amnt':mAmt, 'dcrdtl_id': returnedData[1]};
				
				output += '<tr ' + buildDataProp(dt) + '>';
				output += '<td>' + ((mReferenceNoCode!="") ? mReferenceNo : "" ) + '</td>';				
				output += '<td>' + mTender + '</td>';
				output += '<td>' + mParticular + '</td>';
				output += '<td class="currency">' + mAmt + '</td>';
				output += '<td><a class="EditBtn" href="#">Edit</a>&nbsp;<a class="DelBtn" href="#">Delete</a></td>';
				output += '</tr>';
				
				// updates the datagrid that's what's been added into the underlying table
				$('#datagrid tbody').append(output);
				
				// event handlers
				$('.DelBtn').unbind('click', evtDelBtn);
				$('.EditBtn').unbind('click', evtEditData);
				$('.DelBtn').bind('click', evtDelBtn);
				$('.EditBtn').bind('click', evtEditData);
				} else {
					alert("Insert failed.");
				}
			});
			
			
			// clears all entry fields
			clearEntryFields();
			
			
		} else  { /* edit button */
			mParticular = $('input[name="particular"]').val();
			mTender = $('select[name="tender"] option:selected').text();
			mTenderCode = $('select[name="tender"] option:selected').val();
			mReferenceNo = $('select[name="refernce"] option:selected').text();
			mReferenceNoCode = $('select[name="refernce"] option:selected').val();
			mAmt = $('input[name="amount"]').val();
			mDcrDtlId = $('#entryfield tbody tr:eq(0)').attr('attrdcrdtl_id');
			
			
			if(mParticular == "" || mAmt == "" || mTenderCode == "")
				return;
			output += '<td>' + ((mReferenceNoCode!="") ? mReferenceNo : "" ) + '</td>';
			output += '<td>' + mTender + '</td>';
			output += '<td>' + mParticular + '</td>';			
			output += '<td class="currency">' + mAmt + '</td>';
			output += '<td><a class="EditBtn" href="#">Edit</a>&nbsp;<a class="DelBtn" href="#">Delete</a></td>';
			
			// AJAX part here
			$.post(dcrbase_url + 'ajax/ajxdcr/editDcrDetail', {post_particulars:mParticular, post_refno:mReferenceNoCode, post_amnt:mAmt, post_tender:mTenderCode, post_dcrdtl_id:mDcrDtlId})
			.success(function(data) {				
				// appends new dom
				if(data == "1") {
					
					$('#datagrid tbody tr.edited')
					.removeAttr('attrdcrdtl_id attramnt attrrefno attrtendercode attrparticulars')
					.attr({'attrdcrdtl_id': mDcrDtlId, 'attramnt': mAmt, 'attrrefno': mReferenceNoCode, 'attrtendercode': mTenderCode, 'attrparticulars': mParticular})
					.empty()
					.append(output)
					.removeClass('edited');
										
					// event handlers
					$('.DelBtn').unbind('click', evtDelBtn);
					$('.EditBtn').unbind('click', evtEditData);
					$('.DelBtn').bind('click', evtDelBtn);
					$('.EditBtn').bind('click', evtEditData);					

				} else {
					alert("Edited data failed.");
				}
			});			
		}

		// clears the entry fields
		$('#entryfield tbody tr:eq(0)').removeAttr('attrdcrdtl_id');
		$('input[name="particular"]').val("");
		$('select[name="tender"]').val("");
		$('select[name="refernce"]').val("");
		$('input[name="amount"]').val("");
		
		// resets the button's caption into "Add"
		mButton.attr('value', 'Add');
		// removes the "edited=true" attribute
		$('#datagrid tbody tr[edited="true"]').removeAttr('edited');
		
		// clears current selection on the dcr details
		clearEditedSelection();

		focusToEntryField();
		
		// sets focus
		//$('#entryfield input[name="particular"]').focus();
		clearEntryFields()
		
	}
	
	var evtDelBtn = function() {
		var curObj = $(this);
		var mButton = $('#addbtn');
		
		var mDcrDtl_id = curObj.parent().parent().attr('attrdcrdtl_id');

		// confirms the user to proceed deletion
		var confirmMessage = confirm("Are you sure you want to delete this record?");
		
		if(confirmMessage) {
			// AJAX part here
			$.post(dcrbase_url + 'ajax/ajxdcr/deleteDcrDetail', {'post_dcrdtl_id': mDcrDtl_id})
			.success(function(data) {	
				
				if(data == "1") {
			// removes the row
				curObj.parent().parent().remove();							
			}			
			// resets the button's caption into "Add"	
			mButton.attr('value', 'Add');
			// clears current selection on the dcr details
			clearEditedSelection();
			// clears all entry fields
			clearEntryFields();
			// sets focus
				focusToEntryField();
				
			});		
		}
	
		
		return false;
	}
	
	var evtEditData = function() {
		
		var parentRow = $(this).parent().parent();
		var entryRow = $('#entryfield tbody tr:eq(0)');
		var recData = $(this).parent().parent().data('record');
		

		toggleEditedRecord(parentRow);
		
		// gets the current selected row and put them into the entry field for edit
		$(entryRow).attr('attrdcrdtl_id', parentRow.attr('attrdcrdtl_id'));
		$('input[name="particular"]', entryRow).val(parentRow.attr('attrParticulars'));
		$('td select[name="tender"]', entryRow).val(parentRow.attr('attrTenderCode'));
		$('select[name="refernce"]', entryRow).val(parentRow.attr('attrRefNo'));
		$('input[name="amount"]', entryRow).val(parentRow.attr('attrAmnt'));

		
		// tags the current row being edited
		//parentRow.attr('Edited', true);
		EditRecord(parentRow);
		
		// setfocus to the entry field
		// $('td input[name="particular"]', entryRow).focus();
		focusToEntryField();
		
		return false;
	}
	
	function getTender() {
		var output = '';
		
		$.post(dcrbase_url + 'ajax/ajxdcr/dcrTender')
		.success(function(data){
			data = $.parseJSON(data);	
			
			for(y in data) {
				output += '<option value="' + data[y].tdr_id + '">' + data[y].name + '</option>';	
			}
			
			$('select[name="tender"]').append(output);
		});
	}
	
	function getDcrReference() {
		var output = '';
		
		$.post(dcrbase_url + 'ajax/ajxdcr/dcrReference')
		.success(function(data) {			
			data = $.parseJSON(data);
			
			for(x in data) {
				// console.log(data[x].plate);	
				output += '<option value="' + data[x].jo_id + '">' + data[x].jo_number + " || " + data[x].plate + " || " + data[x].customer + '</option>';
			}
			
			$('select[name="refernce"]').append(output);
		});		
	}
	
	function focusToEntryField() {
		//$('#entryfield input[name="particular"]').focus();
		$('select[name="refernce"]').focus();
	}
	
	function buildDataProp(dt) {
		var output = '';
		output += ' attrParticulars="' + dt.particulars + '" attrTenderCode="' +  dt.tendercode + '" attrRefNo="' + dt.refno + '" attrAmnt="' + dt.amnt + '" attrDcrdtl_id="' + dt.dcrdtl_id + '" '; 
		
		return output;
	}
	
	function EditRecord(obj, flag) {
		var mButton = $('#addbtn');
		flag = flag || true;
		
		if(flag) {
			obj.addClass('edited');
			mButton.attr('value', 'Edit');
		}		
	}
	
	function toggleEditedRecord(obj) {
		$($('tr', obj.parent().parent()).css({'border':'none'}));
		obj.css({'border': '1px solid #ccc'});
	}
	
	function clearEditedSelection() {
		$($('#datagrid tbody tr').css({'border':'none'}));
	}
	
	function clearEntryFields() {
		// clears the entry fields
		$('input[name="particular"]').val("");
		$('select[name="tender"]').val("");
		$('select[name="refernce"]').val("");
		$('input[name="amount"]').val("");	
	}

})(jQuery);
