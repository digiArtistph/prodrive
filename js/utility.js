$(document).ready(function(){

	var base_url = $('meta[name*="url"]').attr('content');
	var dir = $('.dir');
	var dataFile = $('.datafile');
	var option = $('.datafile option');
	
	dir.blur(loaddataDir);
	
	
	function loaddataDir(){
		
		var input = {
					'directory' : dir.val()
				}
		
		if(dir.val() == ""){
			dataFile.html('<option value="none">Select source file</option>');
		}else{

			dataFile.html('<option value="none">Searching Data</option>');
			$.post(base_url + "temp/dirdata", input)
			.success(function(data) {
				
				var options = jQuery.parseJSON(data);
				dataFile.html('');
				dataFile.html('<option>Files Loaded</option>');
				$.each(options, function(key, val){
					dataFile.append('<option value="' + val+ '">' + val +'</option>');
				});
			});	
		}
		
		
		
	}
	
});