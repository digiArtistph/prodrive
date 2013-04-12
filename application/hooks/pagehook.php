<?php

/**
 * 
 * @author Mugs and Coffee
 * @written Kenneth "digiArtist_ph" P. Vallejos
 * @since Tuesday, April 9, 2013
 * @version 1.0
 * 
 */
class Pagehook {
	
	
	public function loadAlamidHooks() {
		// echo 'Loading loadAlamidHooks' . '<br />';
		
		// initialises some member variables and globals
		$this->init();
		
	}
	
	/**
	 * Initialises some constants
	 * @author Mugs and Coffee
	 * @written Kenneth "digiArtist_ph" Vallejos
	 * @since Tuesday, April 9, 2013
	 * @version 1.0
	 * 
	 */
	private function init() {
		define('ALAMIDCLASSES', FCPATH . '/alamid/classes/');
		define('ALAMIDVIEWS', FCPATH . '/alamid/views/');
		define('ALAMIDFUNCTIONS', FCPATH . '/alamid/functions/');
		
		// requires once some files
		require_once ALAMIDCLASSES . 'almdMainFrameWindow' . EXT;
		require_once ALAMIDCLASSES . 'pagesection' . EXT;
		require_once ALAMIDCLASSES . 'canvas' . EXT;
		require_once ALAMIDCLASSES . 'masthead' . EXT;
		require_once ALAMIDCLASSES . 'panels' . EXT;
		require_once ALAMIDCLASSES . 'toolbars' . EXT;
		require_once ALAMIDCLASSES . 'footer' . EXT;	
		require_once ALAMIDCLASSES . 'pagetemplate' . EXT;
		require_once ALAMIDCLASSES . 'wrapper' . EXT;
		require_once ALAMIDCLASSES . 'misnomer' . EXT;
		require_once ALAMIDFUNCTIONS . 'util'. EXT;
				
		// activates framework
		$almdHooks = almdMainFrameWindow::get_instance();		
		Misnomer::load();
	
	}
	
}

?>