<div class="wrapper">
	<h3 class="heading">Edit Owned-Vehicle</h3>
    <div class="toolbar"><a class="cancenewlbtn" href="<?php echo base_url('master/ownedvehicle'); ?>">Cancel Edit Owned-Vehicle</a></div>
    <?php if( !empty($records) ):?>
    <?php echo form_open(base_url('master/ownedvehicle/validateeditownedvehicle')); ?>
    	<?php foreach ($records as $record):?>
    	<input type="hidden" value="<?php echo $record->id;?>" name="vehiclecode" />
    	<p><label>Plate No.</label><input type="text" value="<?php echo $record->platenum;?>" name="plateno" /></p>
        <p><label>Make</label><input type="hidden" name="makecode" value="<?php echo $record->makeid;?>" /><input class="vehicleowner" type="text" name="make" value="<?php echo $record->makename;?>" /><?php echo form_error('make', '<span class="error">','</span>'); ?></p>
        <p><label>Color</label><input type="hidden" name="colorcode" value="<?php echo $record->colorid;?>" /><input class="vehiclecolor" type="text" name="color" value="<?php echo $record->colorname;?>"/><?php echo form_error('color', '<span class="error">','</span>'); ?></p>
        <p><label>Description</label><textarea name="description"><?php echo $record->description;?></textarea></p>
        <p><label>Owner</label><input type="hidden" name="customercode" value="<?php echo $record->ownerid;?>" /><input class="vehiclecustomer" type="text" name="owner" value="<?php echo $record->ownername;?>"/><?php echo form_error('owner', '<span class="error">','</span>'); ?></p>
        <p class="submit"><input type="submit" value="Save" /></p>
        <?php endforeach;?>
    <?php echo form_close(); ?>
    <?php else:?>
    <p>No Entry Retrieve!!!</p>
    <?php endif;?>
</div>