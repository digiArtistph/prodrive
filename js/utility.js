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
	var trind = null;
	var totalprice = 0;
	var tempprice = 0;
	
	dir.change(loaddataDir);
	jotypeqry.change(loadJobType);
	addjodetails.click(submitadd);
	clickbinder();
	
	//resettablecolor();
	if( $('div.suggestion p span.total_amount').text() > 0){
		var temptot =  parseFloat( $('div.suggestion p span.total_amount').text() );
		totalprice = totalprice + temptot;
		$('div.suggestion p span.total_amount').text( 'Php ' + totalprice.toFixed(2));
	}
	
	$('select[name="vehicle"]').combobox();
	$('select[name="customer"]').combobox();
	$('select[name="color"]').combobox();
	
	function html2json() {
		   var json = '{';
		   var otArr = [];
		   var tbl2 = $('.jodet tbody tr').each(function(i) {        
		      x = $(this).children();
		      var itArr = [];
		      x.each(function() {
		         itArr.push('"' + $(this).text() + '"');
		      });
		      otArr.push('"' + i + '": [' + itArr.join(',') + ']');
		   })
		   json += otArr.join(",") + '}'

		   return json;
		}
	
	$('.saveorder').click( function() {
		if( validatePlate() & validateAddr() & validateVehicle() & validateCustomer() & validateDate() & validateColor() ){
			
			var joborderdetails = html2json();
			
			var message = '';
			errorreciever(message);
			postdata = {
					 'joborderid' : $('.joborderid').val(),
					 'order_det' : joborderdetails,
					 'odate'	: $('input[name="jo_date"]').val(),
					 'customer'	: $('input[name="customer"]').val(),
					 'vehicle'	: $('input[name="vehicle"]').val(),
					 'addr'	: $('input[name="addr"]').val(),
					 'plate'	: $('input[name="plate"]').val(),
					 'color'	: $('input[name="color"]').val(),
					 'number'	: $('input[name="number"]').val()
			 		}
			$('input[name="customer"]').val(tempc);
			$('input[name="vehicle"]').val(tempv);
			$('input[name="color"]').val(tempcr);
			$.post(base_url + "tranx/joborder/validateorder", postdata)
			.success(function(data) {
				
				var item = jQuery.parseJSON(data);
				
				if (item.flag == 0){
					var message = 'Job Order Saved';
					errorreciever(message);
					$('div.suggestion').animate({ 
				        'color': '#000000',
				        backgroundColor: "#FF0000" 
				    }, 1000);
					$('div.suggestion').animate({ 
				        'color': '#000000',
				        backgroundColor: "#FFFFFF" 
				    }, 500);
					$('.saveorder').val('Edit Job Order');
					$('.joborderid').val(item.jo_id);
				}else{
					var message = 'Job Order saving failed';
					errorreciever(message);
					$('div.suggestion').animate({ 
				        'color': '#000000',
				        backgroundColor: "#FF0000" 
				    }, 1000);
					$('div.suggestion').animate({ 
				        'color': '#000000',
				        backgroundColor: "#FFFFFF" 
				    }, 500);
				}
			
			});	
		}else{
			$('div.suggestion').animate({ 
		        'color': '#000000',
		        backgroundColor: "#FF0000" 
		    }, 1000);
			$('div.suggestion').animate({ 
		        'color': '#000000',
		        backgroundColor: "#FFFFFF" 
		    }, 500);
			return false;
		}
	});
	
	function validateDate(){
		
		if( $('input[name="jo_date"]').val() == '' ){
			var message = 'Job Order Date has empty field';
			errorreciever(message);
			return false;
		}else{
			return true;
		}
	}
	
	var tempcr='';
	function validateColor(){
		tempcr = $('input[name="color"]').val();
		if( $('select[name="color"]').val() != ''  ){
			$('input[name="color"]').val( $('select[name="color"]').val() );
		}
		return true;
	}
	
	var tempc = '';
	function validateCustomer(){
		tempc = $('input[name="customer"]').val();
		if( $('input[name="customer"]').val() == '' ){
			var message = 'Job Order Customer has empty field';
			errorreciever(message);
			return false;
		}else{
			
			if( $('select[name="customer"]').val() != ''  ){
				$('input[name="customer"]').val( $('select[name="customer"]').val() );
			}
			return true;
		}
	}
	
	var tempv='';
	function validateVehicle(){
		tempv = $('input[name="vehicle"]').val();
		if( $('input[name="vehicle"]').val() == '' ){
			var message = 'Job Order Vehicle has empty field';
			errorreciever(message);
			return false;
		}else{
			if( $('select[name="vehicle"]').val() != ''  ){
				$('input[name="vehicle"]').val( $('select[name="vehicle"]').val() );
			}
			return true;
		}
	}
	
	function validateAddr(){
		if( $('input[name="addr"]').val() == '' ){
			var message = 'Job Order Address has empty field';
			errorreciever(message);
			return false;
		}else{
			return true;
		}
	}
	
	function validatePlate(){
		if( $('input[name="plate"]').val() == '' ){
			var message = 'Job Order Plate No. has empty field';
			errorreciever(message);
			return false;
		}else{
			return true;
		}
	}
	
	function submitadd(){
		
		if( Validateamount() & Validatelabor() & Validatejotype() ){

			$('.jodet tbody tr td[colspan="3"]').remove();
			if( jotypeqry.val() == 'labor' ){
				
				//checks if editing job details
				if(trind == null){
					calc_amount();
					$('.jodet tbody').append("<tr><td></td><td>" + jotypeqry.val() + "</td><td>" + laborqry.val() + "</td><td></td><td>"+ $('.det').val() +"</td><td>" + $('.amnt').val() +"</td><td><a class=\"edit\" href=\"#\">edit</a>|<a class=\"delete\" href=\"#\">delete</a></td><td></td></tr>");
					resettablecolor();
					
				}else{
					
					$(".jodet tbody tr:eq("+ trind +")").html('');
					$(".jodet tbody tr:eq("+ trind +")").html("<td></td><td>" + jotypeqry.val() + "</td><td>" + laborqry.val() + "</td><td></td><td>"+ $('.det').val() +"</td><td>" + $('.amnt').val() +"</td><td><a class=\"edit\" href=\"#\">edit</a>|<a class=\"delete\" href=\"#\">delete</a></td><td></td>");
					resettablecolor();
					trind = null;
					addjodetails.val('add');
					calc_amount();
					tempprice = 0;
				}
				resetformvalue();
				clickbinder();
			
				return true;
				
			}else if( jotypeqry.val() == 'Parts or Materials' ){
				
				//checks if editing job details
				if(trind == null){
					calc_amount();
					$('.jodet tbody').append("<tr><td></td><td>" + jotypeqry.val() + "</td><td></td><td>" + laborqry.val() +"</td><td>"+ $('.det').val() +"</td><td>" + $('.amnt').val() +"</td><td><a class=\"edit\" href=\"#\">edit</a>|<a class=\"delete\" href=\"#\">delete</a></td><td></td></tr>");
					resettablecolor();
				
				}else{
					$(".jodet tbody tr:eq("+ trind +")").html('');
					$(".jodet tbody tr:eq("+ trind +")").html("<td></td><td>" + jotypeqry.val() + "</td><td></td><td>" + laborqry.val() +"</td><td>"+ $('.det').val() +"</td><td>" + $('.amnt').val() +"</td><td><a class=\"edit\" href=\"#\">edit</a>|<a class=\"delete\" href=\"#\">delete</a></td><td></td>");
					
					calc_amount();
					tempprice = 0;
					resettablecolor();
					trind = null;
					addjodetails.val('add');
				}
				
				resetformvalue();
				clickbinder();
				
				return true;
			}
			
		}else{
			$('div.suggestion').animate({ 
		        'color': '#000000',
		        backgroundColor: "#FFFF66" 
		    }, 1000);
			$('div.suggestion').animate({ 
		        'color': '#000000',
		        backgroundColor: "#FFFFFF" 
		    }, 500);
			return false;
		}
		
		
	}
	
	function errorreciever(errmessage){
		$('div.suggestion p span.error').text(errmessage);
	}
	
	function calc_amount(){
		var totalamnt = parseFloat( $('.amnt').val() );
		totalprice = (totalprice - tempprice ) + totalamnt;
		$("div.suggestion").animate({ backgroundColor: "#3399FF" }, 1000);
		$("div.suggestion").animate({ backgroundColor: "#FFFFFF" }, 500);

		$('div.suggestion p span.total_amount').text('Php. ' + totalprice.toFixed(2));
	}
	
	function resetformvalue(){
		$('div.suggestion p span.error').text('');
		$(".jotype").val( "" ).attr('selected',true);
		laborqry.val(''); 
		$('.det').val(''); 
		$('.amnt').val('');
	}
	
	function clickbinder(){
		$('.edit').unbind('click').bind('click', editordet );
		$('.delete').unbind('click').bind('click', deleteordet );
	}
	
	function resettablecolor(){
		$(".jodet tbody tr:even").css("background-color", "#5CB3FF");
		$(".jodet tbody tr:odd").css("background-color", "#CDFFFF");
		$('.jodet tbody tr').each(function(idx){
		    $(this).children().first().text(idx);
		});
	}
	
	function editordet(){
		tempprice = parseFloat( $(this).closest("tr").find("td:nth-child(6)").text() );
		addjodetails.val('edit');
		resettablecolor();
		$(this).closest("tr").css("background-color", "#FFFF66");
		trind = $(this).closest("tr").index();
		if( $(this).closest("tr").find("td:nth-child(2)").text() == 'labor' ){
			
			$(".jotype").val( "labor" ).attr('selected',true);
			$('.jotypename').text('Labor');
			laborqry.val( $(this).closest("tr").find("td:nth-child(3)").text() );
		
		}else if( $(this).closest("tr").find("td:nth-child(2)").text() == 'Parts or Materials' ){
		
			$(".jotype").val( "Parts or Materials" ).attr('selected',true);
			$('.jotypename').text('Parts/Material');
			laborqry.val( $(this).closest("tr").find("td:nth-child(4)").text() );
		
		}
		
		$('.det').val( $(this).closest("tr").find("td:nth-child(5)").text() );
		$('.amnt').val( $(this).closest("tr").find("td:nth-child(6)").text() );
		
		return false;
	}
	
	function deleteordet(){
		$("div.suggestion").animate({ backgroundColor: "#FF9900" }, 1000);
		$("div.suggestion").animate({ backgroundColor: "#FFFFFF" }, 500);
		resetformvalue();
		tempprice = parseFloat( $(this).closest("tr").find("td:nth-child(6)").text() );
		totalprice = totalprice - tempprice;
		$('div.suggestion p span.total_amount').text('Php. ' + totalprice.toFixed(2));
		tempprice = 0;
		$(this).closest("tr").remove('tr');
		resettablecolor();
		return false;
	}
	
	
	function Validatejotype(){
		if(jotypeqry.val() == ''){
			var message = 'Select a Job Type';
			errorreciever(message);
			return false;
		}else{
			return true;
		}
	}
	
	function Validatelabor(){
		if( laborqry.val() == '' ){
			var message = 'Labor has empty field';
			errorreciever(message);
			return false;
		}else{
			return true;
		}
	}
	
	function Validateamount(){
		
		var regex = /[0-9]+(\.[0-9]{0,2})?/; 
		var input = $('.amnt').val(); 
		if(regex.test(input)) { 
			return true;
		} else { 
			var message = 'Please use decimal input for Amount';
			errorreciever(message);
			return false;
		}
		
	}
	
	laborqry.keydown( function( event ) {
		
		if(jotypeqry.val() == 'labor'){
			laborqry.autocomplete(
					{ disabled: false },
					{minLength: 0},
					{ autoFocus: true },
					{source: function(request, response) {
						
							$.ajax({
									url: base_url + "tranx/joborder/autocomplete_labortype",
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
		}else if ( jotypeqry.val() == 'Parts or Materials' ) {
			laborqry.autocomplete({ disabled: true });
		}else if ( jotypeqry.val() == '' ) {
			laborqry.autocomplete({ disabled: true });
		}

	})
	 
	
	colorqry.autocomplete(
			{ autoFocus: true },
			{source: function(request, response) {
				
					$.ajax({
							url: base_url + "tranx/joborder/autocomplete_color",
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
			{ autoFocus: true },
			{source: function(request, response) {
				
					$.ajax({
							url: base_url + "tranx/joborder/autocomplete_vehicle",
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
	
	//sample autocomplte base_url() . /find
	loadqry.autocomplete(
			{ delay: 0 },
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
		}else if ( jotypeqry.val() == 'Parts or Materials' ) {
			$('.jotypename').text('Parts/Material');
		}
	}
	
	
});	//end of parent Dom