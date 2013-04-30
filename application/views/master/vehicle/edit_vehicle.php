<div id="container">
<h3>Edit Vehicle View</h3>
	<div id="edit_form">
	<?php if(!empty($vehicles)):?>
	<?php echo form_open( base_url() . 'master/vehicle/validateeditvehicle' );?>
		<?php foreach ($vehicles as $vehicle): ?>
		<input type="hidden" name="vh" value="<?php echo $vehicle->v_id;?>" />
		<p><label>Make: </label><input type="text" name="make" value=" <?php echo $vehicle->make; ?>  "/><span class="error"><?php echo form_error('make'); ?></span></p>
		<p><label>Status: </label> Active <input type="radio" name="status" value="1" <?php if($vehicle->status == 1){echo 'checked="checked"';}?>/> In active<input type="radio" name="status" <?php if($vehicle->status == 0){echo 'checked="checked"';}?> value="0"/><span class="error"><?php echo form_error('status'); ?></span></p>
		<p><input type="submit" value="Edit Vehicle" /></p>
		<?php endforeach;?>
	<?php echo form_close();?>
	<?php endif;?>
	</div>
</div>