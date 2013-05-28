<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8" />
<meta name="description"  content="Prodrive Motowerks" />
<meta name="keywords"  content="HTML,CSS,XML,JavaScript" />
<meta name="author"  content="Mugs and Coffee" />
<meta name="Viewport"  width="devicewidth" />
<meta name="url" content="<?php echo base_url();?>" />
<title>Prodrive Motorwerks System</title>
<?php getHeader(); ?>
<?php
	global $almd_userfullname;
?>
</head>

<body>
	<?php $this->load->view($main_content); ?>
</body>

</html>