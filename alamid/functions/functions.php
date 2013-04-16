<?php
/**
 * Add you hooks here
 */

/* masthead */
add_settings('section_masthead', 'funcone');
add_settings('section_masthead', 'functwo');
add_settings('section_masthead', 'functhree');

function funcone() {
	echo 'Calling funcone <br />';
	// calls the almd_panels 
}

function functwo() {
	echo 'Calling functwo<br />';
}

function functhree() {
	echo 'Calling functhree<br />';
}

/* panels */
 


/* toolbars */
 


/* footers */
 

?>