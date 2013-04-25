$(document).ready(function(){
	/*
	var l = window.location;
	var base_url = l.protocol + "//" + l.host + "/" + l.pathname.split('/')[1] + "/";
	var domainName = $('meta[name*="url"]').attr('content');
	*/
	
	var base_url = $('meta[name*="url"]').attr('content');

	details.blur(loaddataDir);
	
	//On key press
	details.keyup(loaddataDir);
	
	function loaddataDir(){
		$.post(base_url + "temp/dirdata")
		.success(function(data) {
			$('.modal-body table tbody').empty().html(data);
			$('.messages_gen').bind('click', function() {
				var t = $(this).closest('tr');
				inputm = {
						 'message_id' : $(this).closest('tr').find('.val_message').text()
				 		}
				
				$.post(base_url + "response/inbox/updateInboxMessage", inputm)
				.success(function(data) {
					t.remove();
				});	
				
			}); 
			
		});
	}
	
});