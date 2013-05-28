<div class="wrapper">
<?php echo form_open(base_url('tranx/dcr/validatenewdcr')); ?>
	<input type="hidden" name="cashierid" value="<?php echo $cashierid; ?>" />
    
	<p><label>Tranx Date: </label><input type="text" name="trnxdate" value="<?php echo curdate(); ?>" /><?php echo form_error('tranxdate', '<span class="error">', '</span>'); ?></p>
    <p><label>Beginning Balance: </label><input type="text" name="begbal" value="0.00" /></p>
    <p><label>Cashier: </label><input type="text" name="cashier" value="<?php echo $cashiername; ?>" /><?php echo form_error('cashier', '<span class="error">', '</span>'); ?></p>
    <p><input type="submit" value="Save" /></p>
<?php echo form_close(); ?>
</div>