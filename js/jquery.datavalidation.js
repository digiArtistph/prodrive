// JavaScript Document
(function($){
	
	$.fn.decimal = function(options) {
		var settings = $.extend({
						message : 'Numeric values only',
						decimalPlaces : 2,
						prompt : false,
						cbFunction : null
					}, options);
		
		var curElement = $(this);
	
		// event handlers
		curElement.bind('blur', function(){
			
			// checks if the input is a number
			if(!isNaN(curElement.val())) {
				currentValue = curElement.val();
				currentValue = parseFloat(currentValue);
				curElement.val(currentValue.toFixed(settings.decimalPlaces));
				
			} else { // not a number
				
				if(null === settings.cbFunction) {
					if(settings.prompt)
						alert(settings.message);
						
					curElement.val('0.00');					
				} else {
					// calls callback function - user-defined function
					// alert("'Calling user-defined function");
					//alert(settings.cbFunction);
					settings.cbFunction;
				}
				
			}
			
		});
	}

	
})(jQuery);