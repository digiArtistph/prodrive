$(document).ready(function(){
	
	var base_url = $('meta[name*="url"]').attr('content');
	
	
	$('.jo_buildform').populatetable();
	$('#dcrdatagrid').dcrgrid();
	// Data Validation
	$('.amnt, .datavaldecimal').decimal();
	
	//submit clicked
	$('.submit').click(function(){
		
			var input = {
				'jo_num' : $('input[name="jo_number"]').val(),
				'jo_date' : $('input[name="jo_date"]').val(),
				'cust' : $('.cust_id').val(),
				'vehicle' : $('.v_id').val(),
				'addr' : $('input[name="addr"]').val(),
				'plate' : $('input[name="plate"]').val(),
				'clr' : $('input[name="clr_id"]').val(),
				'phone' : $('input[name="number"]').val()
				}
			
			$.post(base_url + 'ajax/ajaxjo/savejoborder', input)
			.success(function(data) {
				alert(data);
				return true;
			});
	});
	
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
		}else if ( $('.jotype').val() == 'Parts or Materials' ) {
			$('.labor').autocomplete({ disabled: true });
		}else if ( $('.jotype').val() == '' ) {
			$('.labor').autocomplete({ disabled: true });
		}

	})
	
});	//end of parent Dom