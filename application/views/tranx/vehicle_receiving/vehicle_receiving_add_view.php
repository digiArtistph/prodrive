<div class="wrapper">
	<h3 class="heading">Vehicle Receiving</h3>
	<div class="toolbar"><a class="cancenewlbtn" href="<?php echo base_url('tranx/receiving'); ?>">Cancel New Received Vehicle</a></div>
    <?php echo form_open(base_url()); ?>
    <p><label>Date Received</label><input class="datepicker" type="text" readonly="readonly" name="recdate" /></p>
    <p><label>Customer</label><input type="hidden" name="customercode" value="<?php echo set_value('customercode'); ?>" /><input class="vehiclecustomer" type="text" name="customer" /><?php echo form_error('customer', '<span class="error">', '</span>'); ?></p>
    <p><label>Vehicle</label><input type="hidden" name="ownedvehiclecode" value="<?php echo set_value('ownedvehiclecode'); ?>" /><input type="text" name="ownedvehicle" /><?php echo form_error('ownedvehicle', '<span class="error">', '</span>'); ?></p>
    <p class="submit"><input type="submit" value="Save" /></p>
    <?php echo form_close(); ?>
</div>