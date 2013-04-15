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
		require_once realpath(ALAMIDCLASSES . 'almdMainFrameWindow' . EXT);
		require_once realpath(ALAMIDCLASSES . 'pagesection' . EXT);
		require_once realpath(ALAMIDCLASSES . 'canvas' . EXT);
		require_once realpath(ALAMIDCLASSES . 'masthead' . EXT);
		require_once realpath(ALAMIDCLASSES . 'panels' . EXT);
		require_once realpath(ALAMIDCLASSES . 'pasteboard' . EXT);
		require_once realpath(ALAMIDCLASSES . 'toolbars' . EXT);
		require_once realpath(ALAMIDCLASSES . 'footer' . EXT);	
		require_once realpath(ALAMIDCLASSES . 'pagetemplate' . EXT);
		require_once realpath(ALAMIDCLASSES . 'wrapper' . EXT);
		require_once realpath(ALAMIDCLASSES . 'misnomer' . EXT);
		require_once realpath(ALAMIDFUNCTIONS . 'json_parser_helper'. EXT);
		require_once realpath(ALAMIDFUNCTIONS . 'dom_elem_helper'. EXT);
		require_once realpath(ALAMIDFUNCTIONS . 'util'. EXT);
		require_once realpath(ALAMIDFUNCTIONS . 'functions'. EXT);

		/**
		 * Activates Alamid Framework
		 */
		$almdHooks = almdMainFrameWindow::get_instance();		
		Misnomer::load();
		loadAlamidGlobals();
		
	}
	
}

?>