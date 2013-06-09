<div class="wrapper">
	<h3 class="heading">Add New Owned-Vehicle</h3>
    <div class="toolbar"><a class="cancenewlbtn" href="<?php echo base_url('master/ownedvehicle'); ?>">Cancel New Owned-Vehicle</a></div>
    <?php echo form_open(base_url('master/ownedvehicle/validateaddownedvehicle')); ?>
    	<p><label>Plate No.</label><input type="text" value="<?php echo set_value('plateno'); ?>" name="plateno" /><?php echo form_error('plateno', '<span class="error">', '</span>'); ?></p>
        <p><label>Make</label><input type="hidden" name="makecode" value="<?php echo set_value('makecode'); ?>" /><input class="vehicleowner" type="text" name="make" value="<?php echo set_value('make'); ?>" /><?php echo form_error('make', '<span class="error">','</span>'); ?></p>
        <p><label>Color</label><input type="hidden" name="colorcode" value="<?php echo set_value('colorcode'); ?>" /><input class="vehiclecolor" type="text" name="color" value="<?php echo set_value('color'); ?>"/><?php echo form_error('color', '<span class="error">','</span>'); ?></p>
        <p><label>Description</label><textarea name="description"><?php echo set_value('description'); ?></textarea></p>
        <p><label>Owner</label><input type="hidden" name="customercode" value="<?php echo set_value('customercode'); ?>" /><input class="vehiclecustomer" type="text" name="owner" value="<?php echo set_value('owner'); ?>"/><?php echo form_error('owner', '<span class="error">','</span>'); ?></p>
        <p class="submit"><input type="submit" value="Save" /></p>
        
    <?php echo form_close(); ?>
</div>