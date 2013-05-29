// JavaScript Document
/**
 * Provides data validation on the forms
 * @author Mugs and Coffee
 * @coder Kenneth "digiArtist_ph" P. Vallejos
 * @since Wednesday, May 29, 2013
 * @version 1.1
 * 
 * Sample Code
 * 	{html}
 * 		<p><label>Beginning Balance: </label><input class="datavaldecimal" type="text" name="begbal" value="0.00" /></p>
 * 
 * 	{javascript file}
 * 		// defines variable function
 * 		var customFunction = function() { alert ("Called from callback function"); }
 * 		
 * 		// Data Validation
 *		$('.amnt, .datavaldecimal').decimal({cbFunction: customFunction});
 *
 *		//parameter
 *		message : (optional) Custome message. You need to set <prompt=true> parameter
 *		decimalPlaces	: (optional) number of digits after the decimal point
 *		prompt	: (optional) true|false
 *		cbFunction	: (optional) this should be a variable function. This will enable the developer to process his/her own algo
 *
 */
(function($){
	$.fn.decimal = function(options) {
		return this.each(function(){ // this line ensures that method chaining will be implement on all matched elements.
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
						settings.cbFunction();
					}				
				}			
			});
		});
		
	}

	// email
	
})(jQuery);