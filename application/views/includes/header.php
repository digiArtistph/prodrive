<?php
	switch ($section) {
		case 'home':
		case 'tranx':
			prepare_header_set_A();
	}

	function prepare_header_set_A() { ?>
	
		<link type="text/css"  href="http://localhost/prodrive/alamid/structure/css/main.css"  rel="stylesheet">
		<script src="//ajax.googleapis.com/ajax/libs/jquery/2.0.0/jquery.min.js"></script>
		<script src="//ajax.googleapis.com/ajax/libs/jqueryui/1.10.2/jquery-ui.min.js"></script>
		<script type="text/javascript" src="<?php echo base_url('js/utility.js'); ?>"></script>
		
	<?php }?>
