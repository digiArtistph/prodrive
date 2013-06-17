// JavaScript Document
(function($) {
	var base_url = $('meta[name*="url"]').attr('content');
	
	$.fn.filterperpage = function(options) {							
		return this.each(function(){
			var curElem = $(this);
			
			curElem.bind('change', function(){
				var perpage = $('option:selected', curElem).val();
				var url = curElem.attr('prop-url');
				var controllerMethod = curElem.attr('prop-controller-method');
				$.post(base_url + 'ajax/ajxfilterperpage/setFilterPerPage', {post_perpage : perpage, post_url: url})
				.success(function() {
					window.location = base_url + controllerMethod;
				});				
				
				return false;
			});
			
		});		
	}
	
})(jQuery);