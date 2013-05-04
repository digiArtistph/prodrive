$(document).ready(function(){
	
	var base_url = $('meta[name*="url"]').attr('content');
	var dir = $('.dir');
	var dataFile = $('.datafile');
	var option = $('.datafile option');
	var loadqry = $('.find_val');
	var vehicleqry = $('.vehicle');
	var colorqry = $('.color');
	var jotypeqry = $('.jotype');
	var laborqry = $('.labor');
	var addjodetails = $('.addjodetails');
	
	dir.change(loaddataDir);
	jotypeqry.change(loadJobType);
	addjodetails.click(submitadd);
	
	function submitadd(){
		if( Validatejotype() & Validatelabor() & Validateamount() ){
			alert('validation access true');
			return false;
		}else{
			alert('validation has failed');
			return false;
		}
	}
	
	function Validatejotype(){
		if(jotypeqry.val() == ''){
			return false;
		}else{
			return true;
		}
	}
	
	function Validatelabor(){
		if( laborqry.val() == '' ){
			return false;
		}else{
			return true;
		}
	}
	
	function Validateamount(){
		if( $('.amnt').val() == '' ){
			return false;
		}else{
			return true;
		}
	}
	
	laborqry.keydown( function( event ) {
		
		if(jotypeqry.val() == 'labor'){
			laborqry.autocomplete(
					{ disabled: false },
					{ minLength: 0 },
					{ autoFocus: true },
					{source: function(request, response) {
						
							$.ajax({
									url: base_url + "master/joborder/autocomplete_labortype",
									type: 'POST',
									dataType: "json",
									data: {
										'term' : request.term
										},
									success: function(data) {
										
										response(data);
									}
								});
								
							}
					}
			);
		}else if ( jotypeqry.val() == 'pnm' ) {
			laborqry.autocomplete({ disabled: true });
		}else if ( jotypeqry.val() == '' ) {
			laborqry.autocomplete({ disabled: true });
		}

	})
	 
	
	colorqry.autocomplete(
			{ minLength: 0 },
			{ autoFocus: true },
			{source: function(request, response) {
				
					$.ajax({
							url: base_url + "master/joborder/autocomplete_color",
							type: 'POST',
							dataType: "json",
							data: {
								'term' : request.term
								},
							success: function(data) {
								
								response(data);
							}
						});
						
					}
			}
	);
	
	vehicleqry.autocomplete(
			{ minLength: 0 },
			{ autoFocus: true },
			{source: function(request, response) {
				
					$.ajax({
							url: base_url + "master/joborder/autocomplete_vehicle",
							type: 'POST',
							dataType: "json",
							data: {
								'term' : request.term
								},
							success: function(data) {
								
								response(data);
							}
						});
						
					}
			}
	);
	
	loadqry.autocomplete(
			{ minLength: 0 },
			{ autoFocus: true },
			{source: function(request, response) {
				
					if( $('.find_tbl').val() == '' ){
						alert('select table first');
						loadqry.val('');
						
					}else if ($('.find_tblclmn').val() == '' ) {
						alert('select table column first');
						loadqry.val('');
						
					}else{
						
						$.ajax({
							url: base_url + "find/autocomplete",
							type: 'POST',
							dataType: "json",
							data: {
								'term' : request.term,
								'tbl'  : $('.find_tbl').val(),
								'tblcln' : $('.find_tblclmn').val()
								},
							success: function(data) {
								response(data);
							}
						});
						
					}
				}
	
			}
	);
	// sample autocomplte
	
	function loaddataDir(){
		
		if(dir.val() == ""){
			dataFile.html('<option value="none">Select source file</option>');
		}else{
			
			var input = {'directory' : dir.val()}
			dataFile.html('<option value="none">Loading files</option>');
			$.post(base_url + "temp/dirdata", input)
			.success(function(data) {
				var options = jQuery.parseJSON(data);
				if(options == ''){
					dataFile.html('<option value="none">Select source file</option>');
				}else{
					dataFile.html('');
					dataFile.html('<option>Files Loaded</option>');
					$.each(options, function(key, val){
						dataFile.append('<option value="' + val+ '">' + val +'</option>');
					});
				}
			});	
			
		}
	}
	
	function loadJobType(){
		if(jotypeqry.val() == ''){
			$('.jotypename').text('Labor/Parts/Material');
		}else if ( jotypeqry.val() == 'labor' ) {
			$('.jotypename').text('Labor');
		}else if ( jotypeqry.val() == 'pnm' ) {
			$('.jotypename').text('Parts/Material');
		}
	}
	
	
});	//end of parent Dom