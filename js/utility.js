$(document).ready(function(){
	
	var base_url = $('meta[name*="url"]').attr('content');
	
	
	$('.jo_buildform').populatetable();
	$('#dcrdatagrid').dcrgrid();
	// Data Validation
	$('.amnt, .datavaldecimal').decimal();
	
	
});	//end of parent Dom