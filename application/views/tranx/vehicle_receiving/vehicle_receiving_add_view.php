<div class="wrappter">
	<h3 class="heading">Vehicle Receiving</h3>
	
    <?php echo form_open(); ?>
    <p><label>Date Received</label><input type="text" readonly="readonly" name="recdate" /></p>
    <p><label>Customer</label><input type="text" name="customer" /></p>
    <p><label>Vehicle</label><input type="text" name="vehicle" /></p>
    <p><input type="submit" value="Save" /></p>
    <?php echo form_close(); ?>
</div>