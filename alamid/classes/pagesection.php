<?php
/**
 * 
 * @author Mugs and Coffee
 * @written Kenneth "digiArtist_ph" P. Vallejos
 * @since Tuesday, April 9, 2013
 * @version 1.0.0
 *
 */
abstract class Pagesection {
	abstract public static function loadSection(Pagetemplate $page);
	abstract protected static function buildDOM();
	abstract protected static function buildChildDOM($chld);
} 