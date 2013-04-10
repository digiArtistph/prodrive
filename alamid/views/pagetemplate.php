<?php
/**
 * Description/ function
 * @author Mugs and Coffee
 * @written Kenneth "digiArtist_ph" P. Vallejos
 * @since Wednesday, April 10, 2013
 * @version 1.0.0
 *
 */
class Pagetemplate {

	private $title = null;
	private $head_open = null;
	private $head_close = null;
	private $meta = null;
	private $scripts = null;
	private $styles = null;
	private static final $html_open = '<html lang="en">';
	private static final $html_close = '</html>';
	private static final $body_open = '<body>';
	private static final $body_close = '</body>';
	
	const DOCTYPE = '<!DOCTYPE html>';

	public function __construct() {
		// initialises some member variables
		$this->title = 'Prodrive System';
		$this->head_open = '<head>';
		$this->head_close = '</head>';
		$this->meta = '<meta charset="utf-8" />';
		$this->scripts = '';
		$this->styles = '';
		
	}
	
	public function renderPage() {
		$page = '';
		
		$page .= self::DOCTYPE;
		$page .= self::$html_open;
		$page .= $this->meta;
		$page .= $this->head_open;
		$page .= ($this->scripts != '') ? $this->scripts: '';
		$page .= $this->styles = ($this->styles != '') ? $this->styles : '';
		$page .= $this->head_close;
		$page .= self::$body_open;
		
		$page .= self::$body_close;
		$page .= self::$html_close;
		
		return trim($page);
		
	}
	
}