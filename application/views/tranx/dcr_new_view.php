<?php echo form_open(base_url('tranx/dcr/validatenewdcr')); ?>
	<p><label>Tranx Date: </label><input type="text" name="tranxdate" value="<?php echo set_value('tranxdate'); ?>" /><?php echo form_error('tranxdate', '<span class="error">', '</span>'); ?></p>
    <p><label>Beginning Balance: </label><input type="text" name="begbal" value="0.00" /></p>
    <p><label>Cashier: </label><input type="text" name="cashier" value="<?php echo set_value('cashier'); ?>" /><?php echo form_error('cashier', '<span class="error">', '</span>'); ?></p>
    <p><input type="submit" value="Save" /></p>
<?php echo form_close(); ?>