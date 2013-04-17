<?php
/**
 * Add you hooks here
 */

/* masthead */
add_settings('section_masthead', 'funcone');

function funcone() {

	$param = array(
				'section_title' => 'Master Files ',
				'items' => array(
							array('menu1', 'url1'),
							array('menu2', 'url2'),
							array('menu3', 'url3'),
							array('menu4', 'url4')
						) 
			);

	almd_draw_panel($param);
	
}

function functwo() {
	
	$param = array(
			'section_title' => 'Email Servers ',
			'items' => array(
					array('Mail Yahoo', 'http://mail.yahoo.com'),
					array('Gmail', 'http://gmail.com'),
					array('XU Mail', 'http://xu.edu.ph'),
					array('Alamid Mail', 'htpp://mnc.com')
			)
	);
	
	almd_draw_panel($param);
	
}

function functhree() {
	
	//echo 'Calling functhree<br />';
}

/* panels */
 


/* toolbars */
 


/* footers */
 

?>