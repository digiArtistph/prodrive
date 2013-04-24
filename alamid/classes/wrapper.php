<?php

/**
 * This is in-charge of wrapping html objects into a string
 * @author Mugs and Coffee
 * @written Kenneth "digiArtist_ph" P. Vallejos
 * @since Friday, April 12, 2013
 * @version 1.0.0
 *
 */
class Wrapper {

	public function __construct() {
		// echo "Initialising Wrapper class...<br />";		
	}
	
	public function wrap($domElem) {
		
		foreach ($domElem as $key => $val) {
			$this->{$key} = $val;
		}
		
		// node, child, prop
		$this->node = (isset($this->node))? $this->node :'div';
		$this->prop = (isset($this->prop))? $this->prop : '';
		$this->child = (isset($this->child)) ? $this->child : '';
		
		if($this->child == "")
			return sprintf("<%s %s />", $this->node, $this->prop);
		else
			return sprintf("<%s %s>%s</%s>", $this->node, $this->prop, $this->child,$this->node);
		
	}
	
}