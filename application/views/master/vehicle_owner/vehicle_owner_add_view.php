<div class="wrapper">
	<h3 class="heading">Add New Owned-Vehicle</h3>
    
    <?php echo form_echo(); ?>
    	<p><label>Plate No.</label><input type="text" name="plateno" /></p>
        <p><label>Make</label><input type="text" name="make" /></p>
        <p><label>Color</label><input type="text" name="color" /></p>
        <p><label>Description</label><textarea name="description"></textarea></p>
        <p><label>Owner</label><input type="text" name="owner" /></p>
        <p><input type="submit" value="Save" /></p>
        
    <?php echo form_close(); ?>
</div>