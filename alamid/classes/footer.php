<?php

class Footer extends Pagesection {
	
	public static function loadSection(Pagetemplate $page) {
		$page->set_footer('<div class="footer">Copyright 2013</div>');
	}
	
	protected static  function buildDOM() {
				
	}
	
	
}