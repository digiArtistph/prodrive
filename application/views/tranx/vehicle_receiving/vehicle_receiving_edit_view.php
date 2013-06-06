<div class="wrapper">
	<h3 class="heading">Vehicle Receiving</h3>
	<div class="toolbar"><a class="cancenewlbtn" href="<?php echo base_url('tranx/receiving'); ?>">Cancel New Received Vehicle</a></div>
    <?php echo form_open(base_url('tranx/receiving/validateaddreceivedvehicle')); ?>
    <input type="hidden" name="rcvcode" value="<?php echo $id;?>"/>
    <p><label>Date Received</label><input class="datepicker" type="text" readonly="readonly" name="recdate" /></p>
    <p><label>Customer</label><input type="hidden" name="customercode" value="<?php echo set_value('customercode'); ?>" /><input class="vehiclecustomer-ownedvehicle" type="text" name="customer" /><?php echo form_error('customer', '<span class="error">', '</span>'); ?></p>
    <p><label>Vehicle</label><input type="hidden" name="ownedvehiclecode" value="<?php echo set_value('ownedvehiclecode'); ?>" /><input type="text" readonly="readonly" name="ownedvehicle" /><?php echo form_error('ownedvehicle', '<span class="error">', '</span>'); ?></p>
    <p class="submit"><input type="submit" value="Save" /></p>
    <?php echo form_close(); ?>
</div>
<div id="dialog-receiving">
        <select name="cars" multiple="multiple" style="height:100%; width:100%;" >
          
        </select>
</div>