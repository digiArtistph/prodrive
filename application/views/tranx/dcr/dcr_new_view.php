<div class="wrapper">
	<h3 class="heading">Daily Cash Entry</h3>
    <div class="minidashboard">
    
    </div><div class="cleafix">&nbsp;</div>
	<?php echo form_open(base_url('tranx/dcr/validatenewdcr')); ?>
        <input type="hidden" name="cashierid" value="<?php echo $cashierid; ?>" />
        
        <p><label>Tranx Date: </label><input type="text" name="trnxdate" value="<?php echo curdate(); ?>" /><?php echo form_error('tranxdate', '<span class="error">', '</span>'); ?></p>
        <p><label>Beginning Balance: </label><input class="datavaldecimal" type="text" name="begbal" value="0.00" /></p>
        <p><label>Cashier: </label><input type="text" name="cashier" readonly="readonly" value="<?php echo $cashiername; ?>" /><?php echo form_error('cashier', '<span class="error">', '</span>'); ?></p>
        <p class="submit"><input type="submit" value="Save" /></p>
    <?php echo form_close(); ?>
</div>