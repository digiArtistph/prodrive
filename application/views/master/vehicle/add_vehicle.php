<div id="wrapper">
<h3>Add Vehicle View</h3>
	<div id="add_form">
	<?php echo form_open( base_url() . 'master/vehicle/validateaddvehicle' );?>
		<p><label>Make: </label><input type="text" name="make" /><span class="error"><?php echo form_error('make'); ?></span></p>
		<p><label>Status: </label> Active <input type="radio" name="status" value="1" checked="checked"/> In active<input type="radio" name="status" value="0"/><span class="error"><?php echo form_error('status'); ?></span></p>
		<p><input type="submit" value="Add Vehicle" /></p>
	<?php echo form_close();?>
	</div>
</div>