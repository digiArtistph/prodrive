<div class="wrapper">
<h3 class="heading">Add Vehicle</h3>
<div class="toolbar"><a class="cancenewlbtn" href="<?php echo base_url('master/vehicle'); ?>">Cancel New Vehicle</a></div>
	<div id="add_form">
	<?php echo form_open( base_url() . 'master/vehicle/validateaddvehicle' );?>
		<p><label>Make: </label><input type="text" name="make" /><span class="error"><?php echo form_error('make'); ?></span></p>
		<p class="submit"><input type="submit" value="Save"/></p>
	<?php echo form_close();?>
	</div>
</div>