$(document).ready(function(){
	
	var base_url = $('meta[name*="url"]').attr('content');
	var dir = $('.dir');
	var dataFile = $('.datafile');
	var option = $('.datafile option');
	var loadqry = $('.find_val');
	
	dir.change(loaddataDir);
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
	
});