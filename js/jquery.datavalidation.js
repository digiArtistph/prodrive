// JavaScript Document
(function($){
	
	$.fn.decimal = function(options) {
		var settings = $.extend({
						message : 'Error',
						decimalPlaces : 2
					}, options);
		
		var curElement = $(this);
		var isNumber = false;
		var hasDecimal = false;
		var decimalCount = 2;
		var patternOne = '/[\d]+\.[\d]{' + settings.decimalPlaces + '}/';
		var patternIsNumber = /[\d]+/;
		var patternnTwo = '';
		
		// event handlers
		curElement.bind('blur', function(){
			// alert(settings.message + settings.decimalPlaces);
			if(! isNaN(curElement.val())) {
				alert('Number ni bai');	
			} else {
				alert('Dili ni number bai');	
			}
		});
		
		
		
	}

})(jQuery);