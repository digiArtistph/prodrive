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

	protected  $title = null;
	protected $head_open = null;
	protected $head_close = null;
	protected $meta = null;
	protected $scripts = null;
	protected $styles = null;
	protected $masthead = null;
	protected $panels = null;
	protected $toolbars = null;
	protected $pasteboard = null;
	protected $html_open = '<html lang="en">';
	protected $html_close = '</html>';
	protected $body_open = '<body>';
	protected $maincontent = null;
	protected $body_close = '</body>';
	protected $footer = null;
	
	const DOCTYPE = '<!DOCTYPE html>';

	public function __construct() {
		// initialises some member variables
		$this->title = 'Prodrive System';
		$this->head_open = '<head>';
		$this->head_close = '</head>';
		$this->masthead = '';
		$this->maincontent = '';
		$this->pasteboard = '';
		$this->panels = '';
		$this->meta = '<meta charset="utf-8" />';
		$this->scripts = '';
		$this->styles = '';
		$this->toolbars = '';
		$this->footer = '';
		
	}
	
	public function renderPage() {
		$page = '';
		
		$page .= self::DOCTYPE;
		$page .= $this->html_open;		
		$page .= $this->head_open;
		$page .= $this->meta;
		$page .= ($this->scripts != '') ? $this->scripts: '';
		$page .= $this->styles = ($this->styles != '') ? $this->styles : '';
		$page .= $this->head_close;
		$page .= $this->body_open;
		
		// perform sprintf here for all DOM elements
		$page .= sprintf($this->maincontent, $this->masthead, $this->panels,$this->pasteboard, $this->toolbars, $this->footer);
		$page .= $this->body_close;
		$page .= $this->html_close;
		
		return trim($page);
		
	}
	
	// properties 
	public function set_canvas($canvas='') {
		$this->maincontent = $canvas;
	}
	
	public function get_canvas() {
		return trim($this->maincontent);
	}
	
	public function set_mastHead($mast) {
		$this->masthead = $mast;
	}
	
	public function get_mastHead() {
		return trim($this->masthead);
	}
	
	public function set_panels($panels) {
		$this->panels = $panels;
	}
	
	public function get_panels() {
		return trim($this->panels);
	}
	
	public function set_pasteboard($pasteboard) {
		$this->pasteboard = $pasteboard;
	}
	
	public function get_pasteboard() {
		return trim($this->pasteboard);
	}
	
	public function set_toolbars($toolbars) {
		$this->toolbars = $toolbars;
	}
	
	public function get_toolbar() {
		return trim($this->toolbars);
	}
	
	public function set_footer($footer) {
		$this->footer = $footer;
	}
	
	public function get_footer() {
		return trim($this->footer);
	}
}