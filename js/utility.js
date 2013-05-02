$(document).ready(function(){

	var base_url = $('meta[name*="url"]').attr('content');
	var dir = $('.dir');
	var dataFile = $('.datafile');
	var option = $('.datafile option');
	var loadqry = $('.find_val');
	
	dir.change(loaddataDir);
	loadqry.blur(function(){
		
				var input = {'term' : loadqry.val()}
				
				$.post(base_url + "find/autocomplete", input)
				.success(function(data) {
					alert(data);
				});
	
	});
	
	
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