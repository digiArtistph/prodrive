<div class="wrapper">
<h3 class="heading">Edit Vehicle</h3>
<div class="toolbar"><a class="canceleditbtn" href="<?php echo base_url('master/vehicle'); ?>">Cancel Edit Vehicle</a></div>
	<div id="add_form">
	<?php if(!empty($vehicles)):?>
	<?php echo form_open( base_url() . 'master/vehicle/validateeditvehicle' );?>
		<?php foreach ($vehicles as $vehicle): ?>
		<input type="hidden" name="vh" value="<?php echo $vehicle->v_id;?>" />
		<p><label>Make: </label><input type="text" name="make" value=" <?php echo $vehicle->make; ?>  "/><span class="error"><?php echo form_error('make'); ?></span></p>
		<p class="submit"><input type="submit" value="Save"/></p>
		<?php endforeach;?>
	<?php echo form_close();?>
	<?php endif;?>
	</div>
</div>