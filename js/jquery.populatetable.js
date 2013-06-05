 // JavaScript Document
/**
 * @author Mugs and Coffee
 * @written Norberto "juntals" Q. Libago
 * @since Thursday, May 30, 2013
 * 
 */
(function($){
	var jobase_url = $('meta[name*="url"]').attr('content');
	var _currobj = null;
	
	$.fn.populatetable = function(options) {
		_currobj = $(this);
		init();
		$('.jodet_action').unbind('click', evtActionJodet).bind('click', evtActionJodet);	
	}
	
	var cnt = 0;
	function evtActionJodet(){
		//in case add
		if( Validateamnt() & Validatelabor() & Validatejobtype() ){
			
			
			if( $('.jodet_action').val() == 'Add'){
				var input = null;
				if($('.jotype').val() == 'labor'){
					input = {
						'labor' : $('.jotype').val(),
						'part' : $('.lbr').val(),
						'det' : $('.det').val(),
						'amnt' : $('.amnt').val()
					}
				}else{
					input = {
						'labor' : $('.jotype').val(),
						'part' : $('.labor').val(),
						'det' : $('.det').val(),
						'amnt' : $('.amnt').val()
						}
				}
					$.post(jobase_url + 'ajax/ajaxjo/addjodet', input)
					.success(function(data) {
						var result = data.split('|');
						if(result[1] == 1){
							populateTblBody();
							var totalamnt = parseFloat( $('.panelOne p strong span.total_amount').text() );
							var amnt = parseFloat( $('.amnt').val() );
							$('.panelOne p strong span.total_amount').text( totalamnt + amnt );
							$('.jo_orders tr:last').attr('id', result[0]);
							$('.jo_orders tr:last').attr('lbr', $('.lbr').val());
							cleanform();
						}else{
						
						}
						$('.edit_jodet').unbind('click', evntjoEdit).bind('click', evntjoEdit);
						$('.del_jodet').unbind('click', evntjoDel).bind('click', evntjoDel);
						return true;
					});
					$('.jodet_action').unbind('click', evtActionJodet).bind('click', evtActionJodet);	
					//$('.suggestion p span.error').text('Adding entry failed');
				}else{
					
					var input = null;
					if( $('.jotype').val() == 'labor'){
						input = {
							'id' : $('.jodet tbody').find('tr.editon').attr('id'),
							'labor' : $('.jotype').val(),
							'part' : $('.lbr').val(),
							'det' : $('.det').val(),
							'amnt' : $('.amnt').val()
						}
					}else{
						input = {
							'id' : $('.jodet tbody').find('tr.editon').attr('id'),
							'labor' : $('.jotype').val(),
							'part' : $('.labor').val(),
							'det' : $('.det').val(),
							'amnt' : $('.amnt').val()
							}
					}
						$.post(jobase_url + 'ajax/ajaxjo/editjodet', input)
						.success(function(data) {
							if(data == 1){
								var totalamnt = parseFloat( $('.panelOne p strong span.total_amount').text() );
								var amnt = parseFloat( $('.amnt').val() );
								if( ( (totalamnt - tempval ) + amnt ) == 0 ){
									$('.panelOne p strong span.total_amount').text( '0' );
								}else{
									$('.panelOne p strong span.total_amount').text( (totalamnt - tempval ) + amnt );
								}
								
								$('.jodet_action').val('Add');
								
								$('.jodet tbody').find('tr.editon td:First-child').text( $('.jodet tbody').find('tr.editon').attr('num') );
								
									if($('.jotype').val() == 'labor'){
										$('.jodet tbody').find('tr.editon td:nth-child(2)').text('Labor');
										$('.jodet tbody').find('tr.editon td:nth-child(3)').text( $('.labor').val() );
										$('.jodet tbody').find('tr.editon td:nth-child(4)').text( '' );
										$('.jodet tbody').find('tr.editon').attr('lbr', $('.lbr').val());
									}else{
										$('.jodet tbody').find('tr.editon td:nth-child(2)').text('Parts or Material');
										$('.jodet tbody').find('tr.editon td:nth-child(3)').text( '' );
										$('.jodet tbody').find('tr.editon td:nth-child(4)').text( $('.labor').val() );
									
									}
								$('.jodet tbody').find('tr.editon td:nth-child(5)').text( $('.det').val() );
								$('.jodet tbody').find('tr.editon td:nth-child(6)').text( $('.amnt').val() );
								
								$('.jodet tbody').find('tr.editon').removeClass('editon');
								cleanform();
								
							}else{
								cleanform();
								$('.jodet_action').val('Add');
							}
							
							return true;
						});
				}
			
			$('.jodet_action').unbind('click', evtActionJodet).bind('click', evtActionJodet);	
			$('.edit_jodet').unbind('click', evntjoEdit).bind('click', evntjoEdit);
			$('.del_jodet').unbind('click', evntjoDel).bind('click', evntjoDel);
		}
	}
	
	function Validatejobtype(){
		if( $('.jotype').val() == '' ){
			$("#dialogerror p").text('');
			$("#dialogerror p").append('You missed to select a job type');
			 $("#dialogerror").dialog({
				modal : true,
				buttons : {
					Ok : function() {
						$(this).dialog("close");
					}
				}
			});
			return false;
		}else{
			return true;
		}
	}
	
	function Validatelabor(){
		if ( $('.jotype').val() == 'labor' ) {
			if( $('.lbr').val() == ''){
				$("#dialogerror p").text('');
				$("#dialogerror p").append('You missed to input a Labor');
				 $("#dialogerror").dialog({
					modal : true,
					buttons : {
						Ok : function() {
							$(this).dialog("close");
						}
					}
				});
				return false;
			}else{
				return true;
			}
		}else{
			if( $('.labor').val() == ''){
				$("#dialogerror p").text('');
				$("#dialogerror p").append('You missed to input Parts or Material');
				 $("#dialogerror").dialog({
					modal : true,
					buttons : {
						Ok : function() {
							$(this).dialog("close");
						}
					}
				});
				return false;
			}else{
				return true;
			}
		}
	}
	
	function Validateamnt(){
		if($('.amnt').val() == ''){
			$("#dialogerror p").text('');
			$("#dialogerror p").append('You missed to input Amount');
			 $("#dialogerror").dialog({
				modal : true,
				buttons : {
					Ok : function() {
						$(this).dialog("close");
					}
				}
			});
			return false;
		}else{
			return true;
		}
	}
	
var table_entry = '<table id="entryfield">';
table_entry += '<thead>';
table_entry += '<tr>';
table_entry += '<td>Job Type</td>';
table_entry += '<td class="jotypename">Labor/Parts or Material</td>';
table_entry += '<td>Details</td>';
table_entry += '<td>Amount</td>';
table_entry += '<td>Action</td>';
table_entry += '</tr>';
table_entry += '</thead>';
table_entry += '<tbody>';
table_entry += '<tr>';
table_entry += '<td><select class="jotype">';
table_entry += '<option value="" selected="selected">Select Job Type</option>';
table_entry += '<option value="labor">Labor</option>';
table_entry += '<option value="parts">Parts/Materials</option>';
table_entry += '</select></td>';
table_entry += '<td><input class="labor" type="text" /></td>';
table_entry += '<td><input class="det" type="text" /></td>';
table_entry += '<td><input class="amnt" type="text" /></td>';
table_entry += '<td><input class="jodet_action" type="button" value="Add" /></td>';
table_entry += '</tr>';
table_entry += '</tbody>';
table_entry += '</table><input class="lbr" type="hidden" value="0" />';

var jo_ordertbl = '<table class="jodet regdatagrid" >';
jo_ordertbl += '<thead>';
jo_ordertbl += '<tr>';
jo_ordertbl += '<th>No.</th>';
jo_ordertbl += '<th>Job Type</th>';
jo_ordertbl += '<th>Labor</th>';
jo_ordertbl += '<th>Parts/Material</th>';
jo_ordertbl += '<th>Details</th>';
jo_ordertbl += '<th>Amount</th>';
jo_ordertbl += '<th>Action</th>';
jo_ordertbl += '</tr>';
jo_ordertbl += '</thead>';
jo_ordertbl += '<tbody class="jo_orders">';	
jo_ordertbl += '</tbody>';
jo_ordertbl += '</table>';

function init(){

	_currobj.html(table_entry + jo_ordertbl);
	populateTblBody();

	//change text onchange select job type
	$('.jotype').change( function(){
		if( $('.jotype').val() == ''){
			$('.jotypename').text('Labor/Parts or Material');
			$('.lbr').val('');
		}else if ( $('.jotype').val() == 'labor' ) {
			$('.jotypename').text('Labor');
			$('.labor').val('');
			$('.lbr').val('');
		}else if ( $('.jotype').val() == 'parts' ) {
			$('.jotypename').text('Parts/Material');
			$('.lbr').val('');
		}
	});
}


var index=0;
function populateTblBody(){
	
	if( index == 0 ){
		_currobj.find('.jo_orders').append('<tr><td colspan="7">No Entry Added</td></tr>');
		index = 1;
	}else if(index == 1){
			_currobj.find('.jo_orders').html('');
			generaterow( $('.jotype').val() );
			index = 2;
	}else{
			generaterow( $('.jotype').val() );
	}
	
}

function generaterow(type){
	if(type == 'labor'){
		_currobj.find('.jo_orders').append('<tr><td>'+ (_currobj.find('.jo_orders tr').length + 1) + '</td><td>Labor</td><td>'+ $('.labor').val() +'</td><td></td><td>'+ $('.det').val() +'</td><td>'+ $('.amnt').val() +'</td><td><a class="edit_jodet reggrideditbtn" href="#">Edit</a>|<a  class="del_jodet reggriddelbtn" href="#">Delete</a></td></tr>');
	}else if(type == 'parts'){
		_currobj.find('.jo_orders').append('<tr><td>'+ (_currobj.find('.jo_orders tr').length + 1) + '</td><td>Parts or Material</td><td></td><td>'+ $('.labor').val() +'</td><td>'+ $('.det').val() +'</td><td>'+ $('.amnt').val() +'</td><td><a class="edit_jodet reggrideditbtn" href="#">Edit</a>|<a  class="del_jodet reggriddelbtn" href="#">Delete</a></td></tr>');
	}else{
		return false;
	}
	$('.edit_jodet').unbind('click', evntjoEdit).bind('click', evntjoEdit);
	$('.del_jodet').unbind('click', evntjoDel).bind('click', evntjoDel);
}

function cleanform(){
	$('.jotype').val('');
	$('.labor').val('');
	$('.det').val('');
	$('.amnt').val('');
}

var tempval = 0;
function evntjoEdit(){

	if( $(this).closest('tr').find("td:nth-child(2)").text() == 'Labor'){
		$('.jotype').val('labor');
		$('.lbr').val( $(this).closest('tr').attr('lbr') );
		$(this).closest('tr').attr('num', $(this).closest('tr').find("td:First-child").text() );
		$('.labor').val( $(this).closest('tr').find("td:nth-child(3)").text() );
		$('.det').val( $(this).closest('tr').find("td:nth-child(5)").text() ); 
		$('.amnt').val( $(this).closest('tr').find("td:nth-child(6)").text() );
		$('.jodet_action').val('Edit');
		$(this).closest('tr').addClass("editon");
		$('.edit_jodet').unbind('click', evntjoEdit).bind('click', evntjoEdit);
		$('.del_jodet').unbind('click', evntjoDel).bind('click', evntjoDel);
	}else{
		$('.jotype').val('parts');
		$('.lbr').val( '' );
		$('.labor').val( $(this).closest('tr').find("td:nth-child(4)").text() );
		$('.det').val( $(this).closest('tr').find("td:nth-child(5)").text() ); 
		$('.amnt').val( $(this).closest('tr').find("td:nth-child(6)").text() );
		$('.jodet_action').val('Edit');
		$(this).closest('tr').addClass("editon");
		$('.edit_jodet').unbind('click', evntjoEdit).bind('click', evntjoEdit);
		$('.del_jodet').unbind('click', evntjoDel).bind('click', evntjoDel);
		
	}
	tempval = parseFloat($('.amnt').val());
	$('.edit_jodet').unbind('click', evntjoEdit).bind('click', evntjoEdit);
	$('.del_jodet').unbind('click', evntjoDel).bind('click', evntjoDel);
	$('.jodet_action').unbind('click', evtActionJodet).bind('click', evtActionJodet);	
	return false;
}
function evntjoDel(){
	var curtr = $(this).closest('tr');
	var input1 = {
			'id': $(this).find('.jo_orders').closest('tr').attr('id')
		}
	
		$.post(jobase_url + 'ajax/ajaxjo/deljodet', input1)
		.success(function(data) {
			if(data == 1){
				var totalamnt = parseFloat( $('.panelOne p strong span.total_amount').text() );
				var amnt = parseFloat( curtr.find("td:nth-child(6)").text() );
				if( (totalamnt-amnt) == 0 ){
					$('.panelOne p strong span.total_amount').text( '0' );
				}else{
					$('.panelOne p strong span.total_amount').text( totalamnt-amnt );
				}
				
				curtr.remove('tr');
			}
		});
	$('.jodet_action').unbind('click', evtActionJodet).bind('click', evtActionJodet);	
	return false;
}

})(jQuery);