<?php
/**
 * Add you hooks here
 */

/* masthead */
add_settings('section_panels', 'funcone');
add_settings('section_panels', 'functwo');

function funcone($section) {

	$param = array(
				'section_title' => 'Master Files ',
				'items' => array(
							array('menu1', 'url1'),
							array('menu2', 'url2'),
							array('menu3', 'url3'),
							array('menu4', 'url4')
						) 
			);

	almd_draw_panel($param,$section);
	
}

function functwo($test) {
	
	$param = array(
			'section_title' => 'Email Servers ',
			'items' => array(
					array('Mail Yahoo', 'http://mail.yahoo.com'),
					array('Gmail', 'http://gmail.com'),
					array('XU Mail', 'http://xu.edu.ph'),
					array('Alamid Mail', 'htpp://mnc.com')
			)
	);
	
	almd_draw_panel($param, $test);
	
}

/* panels */



/* toolbars */
add_settings('section_toolbars', 'functoolbar');

function functoolbar($t) {
	$param = array(
			'section_title' => 'Toolbar One',
			'items' => array(
					array('Facebook', 'http://facebook.com'),
					array('Twitter', 'http://twitter.com')					
			)
	);
	
	almd_draw_panel($param, $t);
}

/* footers */
add_settings('section_footer', 'footerfunc');

function footerfunc($t) {
	$param = array(
			'section_title' => 'Footer Section',
			'items' => array(
					array('Quick Links', 'http://cnn.com'),
					array('Source', 'http://whitehouse.com')
			)
	);

	almd_draw_panel($param, $t);
}

?>