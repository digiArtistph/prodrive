<div>
	<h3>Backup Data</h3>
	
	<?php echo form_open(base_url() . 'temp/validatebackup');?>
	<p><label>Destination Folder: </label><input type="text" name="dir"/><?php echo form_error('dir');?> </p>
	<p><input type="submit" value="Go Back up" /></p>
	<?php echo form_close();?>
</div>