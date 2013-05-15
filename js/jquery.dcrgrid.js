 // JavaScript Document
/**
 * @author Mugs and Coffee
 * @written Kenneth "digiArtist_ph" P. Vallejos
 * @since Wednesday, May 15, 2013
 * 
 */
(function($){
	
	$.fn.dcrgrid = function(options) {
		var curObj = $(this);
		var settings = $.extend({}, options);
		
		// builds datagrid
		curObj.append(tableEntry);
		curObj.append(tablegrid);
		
		// event listeners
		$('#addbtn').bind('click', evtAdd);
		
		
	}

	var tablegrid = function() {
		var output = '';
		
		
		output += '<table id="datagrid">';
		output += '<thead>';
		output += '<tr>';
		output += '<th>Particular</th>';
		output += '<th>Tender</th>';
		output += '<th>Reference No.</th>';
		output += '<th>Amount</th>';
		output += '<th>Action</th>';
		output += '</tr>';
		output += '</thead>';
		output += '<tbody>';
		output += '</tbody>';
		output += '</table>';
		
		return output;
	}
	
	var tableEntry = function() {
		var output = '';
		
		output += '<table id="entryfield">';
		output += '<thead>';
		output += '<tr>';
		output += '<th>Particular</th>';
		output += '<th>Tender</th>';
		output += '<th>Reference No.</th>';
		output += '<th>Amount</th>';
		output += '<th>Action</th>';
		output += '</tr>';
		output += '</thead>';
		output += '<tbody>';
		output += '<tr>';
		output += '<td><input type="text" name="particular" /></td>';
		output += '<td><select name="tender"><option value=""> Select a tender </option><option value="cash">Cash</option><option value="check">Check</option></select></td>';
		output += '<td><select name="refernce"><option value=""> Select a reference no. </option><option value="ref1">Reference 1</option><option value="ref2">Reference 2</option></select></td>';
		output += '<td><input type="text" name="amount" /></td>';
		output += '<td><input type="button" id="addbtn" value="Add" /></td>';
		output += '</tr>';
		output += '</tbody>';
		output += '</table>';
		
		return output;
	}
	
	// event handlers
	var evtAdd = function() {
		var output = '';
		var mParticular = $('input[name="particular"]').val();
		var mTender = $('select[name="tender"] option:selected').text();
		var mTenderCode = $('select[name="tender"] option:selected').val();
		var mReferenceNo = $('select[name="refernce"] option:selected').text();
		var mReferenceNoCode = $('select[name="refernce"] option:selected').val();
		var mAmt = $('input[name="amount"]').val();
		
		if(mParticular == "" || mAmt == "" || mTenderCode == "")
			return;
			
		output += '<tr>';
		output += '<td>' + mParticular + '</td>';
		output += '<td>' + mTender + '</td>';
		output += '<td>' + ((mReferenceNoCode!="") ? mReferenceNo : "" ) + '</td>';
		output += '<td>' + mAmt + '</td>';
		output += '<td><a class="EditBtn" href="#">Edit</a>&nbsp;<a class="DelBtn" href="#">Delete</a></td>';
		output += '</tr>';
		
		// appends new dom
		$('#datagrid tbody').append(output);
		
		// event handlers
		$('.DelBtn').bind('click', evtDelBtn);
		
		// clears the entry fields
		$('input[name="particular"]').val("");
		$('select[name="tender"]').val("");
		$('select[name="refernce"]').val("");
	 	$('input[name="amount"]').val("");
		
		// sets focus
		$('#entryfield input[name="particular"]').focus();
		
	}
	
	var evtDelBtn = function() {
		var curObj = $(this);
		curObj.parent().parent().remove();
	}
	
})(jQuery);
