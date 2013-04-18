<?php
/**
 * Reads all hooks on a respective section
 * @author Mugs and Coffee
 * @written Kenneth "digiArtist_ph" P. Vallejos
 * @since Monday, April 15, 2013
 * @version 1.0.0
 *
 */
class Bootstrap {
	
	public static function execute(&$DOM, $section) {	
		
		// assigns returned recordset into array
		// call_user_func() -- use loop here		
		if(! $hooks = get_setting($section, TRUE, FALSE))
			return ;
		
		foreach ($hooks as $hook) {		
			if(! call_user_func($hook, $section)) {
				log_message('error', $hook);
			}			
		}
		
		
		
	}
}