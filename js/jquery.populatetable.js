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
	
	function evtActionJodet(){
		//in case add
		if($('.jodet_action').val() == 'Add'){
			var input = {
					'labor' : $('.jotype').val(),
					'part' : $('.labor').val(),
					'det' : $('.det').val(),
					'amnt' : $('.amnt').val()
					}
		$.post(jobase_url + 'ajax/ajaxjo/addjodet', input)
		.success(function(data) {
			alert(data);
			return true;
		});
				
				//$('.suggestion p span.error').text('Adding entry failed');
			}
		
		
		
		
	}
	
	
	
var table_entry = '<table>';
table_entry += '<thead>';
table_entry += '<tr>';
table_entry += '<td>Job Type</td>';
table_entry += '<td class="jotypename">Labor/Parts/Material</td>';
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
table_entry += '</table>';

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
		_currobj.find('.jo_orders').append('<tr><td>'+ (_currobj.find('.jo_orders tr').length + 1) + '</td><td>'+ $('.jotype').val()  +'</td><td>'+ $('.labor').val() +'</td><td></td><td>'+ $('.det').val() +'</td><td>'+ $('.amnt').val() +'</td><td><a class="edit_jodet" href="#">Edit</a>|<a  class="del_jodet" href="#">Delete</a></td></tr>');
	}else if(type == 'parts'){
		_currobj.find('.jo_orders').append('<tr><td>'+ (_currobj.find('.jo_orders tr').length + 1) + '</td><td>'+ $('.jotype').val()  +'</td><td></td><td>'+ $('.labor').val() +'</td><td>'+ $('.det').val() +'</td><td>'+ $('.amnt').val() +'</td><td><a class="edit_jodet" href="#">Edit</a>|<a  class="del_jodet" href="#">Delete</a></td></tr>');
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

function evntjoEdit(){
	alert('edit');
	return false;
}
function evntjoDel(){
	alert('delete');
	return false;
}
})(jQuery);