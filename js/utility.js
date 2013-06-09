$(document).ready(function(){
	
	var base_url = $('meta[name*="url"]').attr('content');
	
	
	$('.jo_buildform').populatetable();
	$('#dcrdatagrid').dcrgrid();
	// Data Validation
	
	$('.amnt, .datavaldecimal, input[name="tax"], input[name="discount"]').decimal();
	var dir = $('.dir');
	dir.change(loaddataDir);
	var dataFile = $('.datafile');
	function loaddataDir(){
		
		if(dir.val() == ""){
			
			dataFile.html('<option value="none">Select source file</option>');
		}else{
			
			var inputr = {'directory' : dir.val()}
			
			dataFile.html('<option value="none">Loading files</option>');
			
			$.post(base_url + "utility/datarecovery/dirdata", inputr)
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
	$('.restore_db').click(function(){
		
		var tr = $(this).closest("tr");
		var input = {
					'ajax' : 1,
					'file_name' : tr.find("td:nth-child(2)").text()
					}
		
		$.post(base_url + "utility/datarecovery/validaterestoredefault", input)
		.success(function(data) {
			if(data ==1){
				tr.animate({ 
			        'color': '#000000',
			        backgroundColor: "#009ACD" 
			    }, 1000);
				tr.animate({ 
			        'color': '#000000',
			        backgroundColor: "#FFFFFF" 
			    }, 1000);
				$( ".dialog p").text("\"" + tr.find("td:nth-child(2)").text() +"\" has been restored!");
				$( ".dialog" ).dialog("open");
				
				
			}else{
				$( ".dialog p").text("SOMETHINE WENT WRONG");
				$( ".dialog" ).dialog();
			}
		});	
	return false;
	}
);
	
	//submit add order
	$('.submit').click(function(){
		
		if( ValidateDiscnt() & ValidateTax() & ValidateCust() & ValidateVhcle() ){
			
			var input = {
				'jo_orid' : $('input[name="jo_number"]').val(),
				'jo_date' : $('input[name="jo_date"]').val(),
				'cust' : $('.cust_id').val(),
				'vehicle' : $('.v_id').val(),
				'plate' : $('.vehicle').val(),
				'tax' : $('input[name="tax"]').val(),
				'discount' : $('input[name="discount"]').val()
				}
			
			$.post(base_url + 'ajax/ajaxjo/savejoborder', input)
			.success(function(data) {
				if(data != 0){
					window.location = base_url + "tranx/joborder/section/editjoborder/" + data;
				}else{
					$("#dialogerror p").text('');
					$("#dialogerror p").append('Opps!!! saving record to database has error');
					 $("#dialogerror").dialog({
						modal : true,
						buttons : {
							Ok : function() {
								$(this).dialog("close");
							}
						}
					});
				}
			});
		}else{
			
		}
	});
	
	
	//submit edit order clicked
	$('.submitedit').click(function(){
		console.log('clicked!!1');
		if( ValidateDiscnt() & ValidateTax() & ValidateCust() & ValidateVhcle() ){
			
			var input = {
				'id'	  : $('.joborderid').val(),
				'jo_orid' : $('input[name="jo_number"]').val(),
				'jo_date' : $('input[name="jo_date"]').val(),
				'cust' : $('.cust_id').val(),
				'vehicle' : $('.v_id').val(),
				'plate' : $('.vehicle').val(),
				'tax' : $('input[name="tax"]').val(),
				'discount' : $('input[name="discount"]').val()
				}
			
			$.post(base_url + 'ajax/ajaxjo/savejoborderedit', input)
			.success(function(data) {
				
				if(data == 0){
					
					$("#dialogerror p").text('');
					$("#dialogerror p").append('Record saved');
					 $("#dialogerror").dialog({
						modal : true,
						title: 'Job Order',
						buttons : {
							Ok : function() {
								window.location = base_url + "tranx/joborder/section/editjoborder/" + $('.joborderid').val();
								$(this).dialog("close");
							}
						}
					});
				}else{
					$("#dialogerror p").text('');
					$("#dialogerror p").append('Opps!!! saving record to database has error');
					 $("#dialogerror").dialog({
						modal : true,
						buttons : {
							Ok : function() {
								$(this).dialog("close");
							}
						}
					});
				}
			});
		}else{
			
		}
	});
	
	function ValidateCust(){
		$('.jocustomer').parent().children('span').remove('span.error');
		$('.jocustomer').parent().children('span').text('');
		if($('.cust_id').val() == ''){
			$('.jocustomer').parent().append('<span class="error">Select a customer first</span>');
			return false;
		}else{
			$('.jocustomer').parent().children('span').removeClass('error');
			$('.jocustomer').parent().children('span').text('');
			return true;
		}
		
	}

	function ValidateVhcle(){
		$('.vehicle').closest('p').children('span').remove('span.error');
		$('.vehicle').closest('p').children('span').text('');
		if($('.v_id').val() == 0){
			$('.vehicle').closest('p').append('<span class="error">Select a Vehicle first</span>');
			return false;
		}else{
			$('.vehicle').closest('p').append('<span class="error"></span>');
			return true;
		}
		
	}
	
	function ValidateTax(){
		$('input[name="tax"]').closest('p').children('span').remove('span.error');
		$('input[name="tax"]').closest('p').children('span').text('');
		if( ($('input[name="tax"]').val() == 'NaN') || ($('input[name="tax"]').val() == '') ){
			$('input[name="tax"]').closest('p').append('<span class="error">Select a Tax first</span>');
			return false;
		}else{
			$('input[name="tax"]').closest('p').append('<span class="error"></span>');
			return true;
		}
	}
	
	function ValidateDiscnt(){
		$('input[name="discount"]').closest('p').children('span').remove('span.error');
		$('input[name="discount"]').closest('p').children('span').text('');
		if( ($('input[name="discount"]').val() == 'NaN')|| ($('input[name="discount"]').val() == '') ){
			$('input[name="discount"]').closest('p').append('<span class="error">Select a Discount first</span>');
			return false;
		}else{
			$('input[name="discount"]').closest('p').append('<span class="error"></span>');
			return true;
		}
	}
	
	/* tooltips */
	$( document ).tooltip({track:true});
	
	/* closes JO - tag as paid */
	$('.jotagaspaidbtn').click(function(){
		//alert('You are going to close this Job Order.');
		$("#dialog-close-jo").dialog("open");
		return false;
	});
	
	/* print tasks */
	$('.prnt-print-button').click(function() {
		window.print();
		return false;
	});
	
	/* autocomplete by digiArtist_ph */
	$(".vehicleowner").autocomplete({ autoFocus: true }, {source: 'http://localhost/prodrive/ajax/ajxautocomplete/vehicle'}, {select: function(evt, ui){
			$('input[name="makecode"]').val(ui.item.index);
		}});
	$(".vehiclecolor").autocomplete({ autoFocus: true }, {source: 'http://localhost/prodrive/ajax/ajxautocomplete/color'}, {select: function(evt, ui){
			$('input[name="colorcode"]').val(ui.item.index);
		}});
	$(".vehiclecustomer").autocomplete({ autoFocus: true }, {source: 'http://localhost/prodrive/ajax/ajxautocomplete/customer'}, {select: function(evt, ui){
			$('input[name="customercode"]').val(ui.item.index);
		}});
	$(".vehiclecustomer-ownedvehicle").autocomplete({ autoFocus: true }, {source: 'http://localhost/prodrive/ajax/ajxautocomplete/customer'}, {select: function(evt, ui){
			$('input[name="customercode"]').val(ui.item.index);	
			var customerId = ui.item.index;	
			// loads the filtered data
			$.post(base_url + 'ajax/ajxautocomplete/ownedvehicle', {post_customer: customerId})
			.success(function(data){
				// appends dom
				data = $.parseJSON(data);
				var output = '';
				var cntr = 0;
				
				for(x in data) {
					
					if(cntr == 0)
						output += '<option selected="selected" value="' + data[x].index  +  '">' + data[x].value + '</option>';
					else
						output += '<option value="' + data[x].index  +  '">' + data[x].value + '</option>';
					
					cntr++;
				}
				
				$('#dialog-receiving select').empty().append(output);
				// opens the dialog box
				$("#dialog-receiving").dialog("open");
			});
			
		}});
		
	$('.ownedvehicle')
	 $("#dialog-receiving").dialog({
		autoOpen: false,
		height: 300,
		width: 350,
		modal: true,
		title: "Select a vehicle",
		buttons: {
				"Select this vehicle": function(){
					var selectedVehicleCode = $('select option:selected', this).val();
					var selectedVehicleDescription = $('select option:selected', this).text();
					// closes the dialog box
					// assigns seleted record into some form element
					$('input[name="ownedvehiclecode"]').val(selectedVehicleCode);
					$('input[name="ownedvehicle"]').val(selectedVehicleDescription);					
					$(this).dialog("close");
				}
			}
		});
		
		
		 $("#dialog-close-jo").dialog({
		autoOpen: false,
		height: 200,
		width: 350,
		modal: true,
		title: "Tagging job order as PAID",
		buttons: {
				"Cancel" : function() {
					$(this).dialog("close");
				},
				"Tag as Paid": function(){
					var jo_id = $('.joborderid').val();
					
					$.post(base_url + 'ajax/ajaxjo/tagJoAsPaid', {post_jo_id: jo_id})
					.success(function(data){
						if(data == 1)
							window.location = base_url + 'tranx/joborder'
						else
							alert("Failed");
					});
					
					$(this).dialog("close");
				}				
			}
		});
		
		$("#dcr_dialog").dialog({
		autoOpen: false,
		height: 390,
		width: 350,
		modal: true,
		title: "Enter particulars",
		buttons: {
				"Ok": function(){
					
					/*var selectedItem = $('select option:selected', this).text();*/
					var customedParticular = $('input[name="dcrparticular"]', this).val();
					var currrentJoBalance = $('.curJoBalance').text();
					
					$('input[name="particular"]').val(customedParticular);					
					$(this).dialog("close");
					
					$('input[name="amount"]').val(currrentJoBalance);					
				}
			}
		});
	
	$('.jovehicledialog').dialog({
		autoOpen:false,
		height:300,
		width: 350,
		modal: true,
		title: "Select a vehicle",
		buttons: {
				"Select this vehicle" : function(){
					var joVehicleCode = $('select option:selected', this).val();
					var joVehicleDescript = $('select option:selected', this).text();
					
					
					// assings selected record into some form element
					$('input[name="v_id"]').val(joVehicleCode);
					$('input[name="vehicle"]').val(joVehicleDescript);
					
					$(this).dialog("close");
					}
			}	
		});
	/* jo customer */
	$('.jocustomer').autocomplete(
			{autoFocus: true},
			{source: base_url + 'ajax/ajxautocomplete/customer'},
			{select: function(evt, ui){		
			var customerId = ui.item.index;
			$('input[name="cust_id"]').val(customerId);				
				$.post(base_url + 'ajax/ajxautocomplete/vehiclereceived', {post_customer: customerId})
				.success(function(data){
					data = $.parseJSON(data);
					var output = '';
					var vehicleCode = $('input[name="v_id"]');
					var vehicle = $('input[name="vehicle"]');
					var vehicle = $('input[name="plate"]');
					var cntr = 0;

					for(x in data) {
						
						if(cntr == 0)
							output += '<option selected="selected" value="' +  data[x].ownedvehicle + '"> '  +  data[x].plateno + ' -- ' + data[x].make + '</option>'
						else
							output += '<option value="' +  data[x].ownedvehicle + '"> '  +  data[x].plateno + ' -- ' + data[x].make + '</option>'
							
						cntr++;	
					}
					
					// appends dom
					$('.jovehicledialog select').empty().append(output);
					
					// opends dialog box
					$('.jovehicledialog').dialog("open");
				});
				
				
			}}
		);
	
	/* datepicker */
	$( ".datepicker" ).datepicker({dateFormat: 'yy-mm-dd'});
	
	// autocomplete vehicle
	$('.vehicle').autocomplete(
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
								
								 response( $.map( data, function( item ) {
				                        return {
				                            label: item.label,
				                            val: item.val
				                        }
				                    }));
							}
						});
						
					}
			},
			{select : function(evt, u) {
				$('.v_id').val(u.item.val);
			}}
	);
	
	//color autocomplete
	$('.color').autocomplete(
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
								
								 response( $.map( data, function( item ) {
				                        return {
				                            label: item.label,
				                            val: item.val
				                        }
				                    }));
							}
						});
						
					}
			},
			{select : function(evt, u) {
				$('.clr_id').val(u.item.val);
			}}
	);
	
	
	//customer autocomplete
	$('.customer').autocomplete(
			{ autoFocus: true },
			{source: function(request, response) {
				
					$.ajax({
							url: base_url + "tranx/joborder/autocomplete_customer",
							type: 'POST',
							dataType: "json",
							data: {
								'term' : request.term
								},
							success: function(data) {
								
								 response( $.map( data, function( item ) {
				                        return {
				                            label: item.label,
				                            val: item.val
				                        }
				                    }));
							}
						});
						
					}
			},
			{select : function(evt, u) {
				$('.cust_id').val(u.item.val);
			}}
	);
	
	// labor autocomplete
	$('.labor').keydown( function( event ) {
		
		if( $('.jotype').val() == 'labor'){
			$('.labor').autocomplete(
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
									
									 response( $.map( data, function( item ) {
					                        return {
					                            label: item.label,
					                            val: item.val
					                        }
					                    }));
								}
							});
							
						}
				},
				{select : function(evt, u) {
					$('.lbr').val(u.item.val);
				}}
			);
		}else if ( $('.jotype').val() == 'parts' ) {
			$('.labor').autocomplete({ disabled: true });
		}else if ( $('.jotype').val() == '' ) {
			$('.labor').autocomplete({ disabled: true });
		}

	})
	

	/*
	 * Generic AJAX delete record from view list
	 * required:
	 *     post-url & reggriddelbtn classname in the <a> tag
	 *     <div> tag with an id of dialog-confirm
	 *     
	 * sample code:
	 *     <a class="reggriddelbtn delete-record-view" href="#" post-url="master/customer/ajaxdelcust" custcode="<?php echo $customer->custid;?>">delete</a>
	 *     <div id="dialog-confirm" title="Delete Record!!!"><p></p></div>
	 *
	 */
	$('.delete-record-view').click(function(){
		var currtr = $(this);
		var currentRow = currtr.parent().parent();
		var fieldValue =  $('td:first', currentRow).text();
		var postUrl = currtr.attr('post-url');

		$("#dialog-confirm p").text("Delete " + fieldValue + " ?");
	 	$("#dialog-confirm").dialog({
						resizable : false,
						height : 145,
						modal : true,
						buttons : {
							"Delete" : function() {
								
								var inputcust = {'id' : currtr.attr('code') }
								$.post(base_url + postUrl, inputcust)
								.success(function(data) {
									if(data == 1){
										currentRow.remove();
									}else{
										alert('data cannot be deleted');
									}
								});
								$(this).dialog("close");
								
							},
							Cancel : function() {
								$(this).dialog("close");
							}
						}
					});
		
		return false;
	});

	//delete function in baseurl() . tranx/joborder
	$('.deljo').click(function(){
		var currtr = $(this);
		//alert(currtr.attr("jocode"));
		$("#dialog-confirm p").text("Delete Order No. : " + $(this).closest('tr').find('td:eq(0)').text() + " ?");
	 	$("#dialog-confirm").dialog({
						resizable : false,
						height : 150,
						width	: 350,
						modal : true,
						buttons : {
							"Delete" : function() {
								
								var inputcust = {'id' : currtr.attr('jocode') }
								$.post(base_url + 'tranx/joborder/ajaxdeljo', inputcust)
								.success(function(data) {
									if(data == 1){
										currtr.closest('tr').remove('tr');
									}else{
										alert('data cannot be deleted');
									}
								});
								$(this).dialog("close");
								
							},
							Cancel : function() {
								$(this).dialog("close");
							}
						}
					});
		return false;
	});
	
	//delete function in baseurl() . tranx/joborder
	$('.delrcv').click(function(){
		var currtr = $(this);
		//alert(currtr.attr("delrcv"));
		$("#dialog-confirm p").text("Delete Order No. : " + $(this).closest('tr').find('td:eq(0)').text() + " ?");
	 	$("#dialog-confirm").dialog({
						resizable : false,
						height : 150,
						width	: 350,
						modal : true,
						buttons : {
							"Delete" : function() {
								
								var inputcust = {'id' : currtr.attr('delrcv') }
								$.post(base_url + 'tranx/receiving/ajaxdelvr', inputcust)
								.success(function(data) {
									if(data == 1){
										currtr.closest('tr').remove('tr');
									}else{
										alert('data cannot be deleted');
									}
								});
								$(this).dialog("close");
								
							},
							Cancel : function() {
								$(this).dialog("close");
							}
						}
					});
		return false;
	});
	
});	//end of parent Dom