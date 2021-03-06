<?php
/**
 * 
 * @author Mugs and Coffee
 * @since Tuesday, April 9, 2013
 * @written Kenneth "digiArtist_ph" P. Vallejos
 * @version 1.0
 * 
 */
class almdMainFrameWindow {
	private static $instance = null;
	
	/**
	 * This makes the class a singleton
	 */
	private function __construct() {		
		// echo 'Initialising alamid Main Frame Window' . '<br />';		
	}
	
	/**
	 * Keeps the class unclonable
	 */
	public function __clone() {}
	
	public static function get_instance() {
		if(! self::$instance instanceof self) {
			self::$instance = new self();
		}
		
		return self::$instance;
	}	
	
	public function createWindow() {
		$page = new Pagetemplate();
		
		Metahead::loadSection($page);
		Metastyle::loadSection($page);
		Metascript::loadSection($page);
		Canvas::loadSection($page);
		Masthead::loadSection($page);
		Panels::loadSection($page);	
		Pasteboard::loadSection($page);
		Toolbars::loadSection($page);
		Footer::loadSection($page);
		
		return $page->renderPage();		
	}

	
}

?>