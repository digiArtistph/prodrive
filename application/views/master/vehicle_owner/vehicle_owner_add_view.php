<div class="wrapper">
	<h3 class="heading">Add New Owned-Vehicle</h3>
    
    <?php echo form_open(base_url()); ?>
    	<p><label>Plate No.</label><input type="text" name="plateno" /></p>
        <p><label>Make</label><input class="vehicleowner" type="text" name="make" /></p>
        <p><label>Color</label><input class="vehiclecolor" type="text" name="color"/></p>
        <p><label>Description</label><textarea name="description"></textarea></p>
        <p><label>Owner</label><input class="vehiclecustomer" type="text" name="owner" /></p>
        <p class="submit"><input type="submit" value="Save" /></p>
        
    <?php echo form_close(); ?>
</div>