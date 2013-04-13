<?php

abstract class Pagesection {
	abstract public static function loadSection(Pagetemplate $page);
	abstract protected static function buildDOM();
} 