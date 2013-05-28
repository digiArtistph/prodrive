<div class="wrapper">
	
    <h3 class="heading">Add New Cash Float</h3>
   <div class="toolbar"><a class="cancenewlbtn" href="<?php echo base_url('tranx/cashfloat'); ?>">Cancel New Cash Float</a></div>
	<?php echo form_open(base_url('tranx/cashfloat/validateaddcashfloat')); ?>
    <input type="hidden" name="cashierid" value="<?php echo $cashierid; ?>" />
    <input type="hidden" name="cashiername" value="<?php echo $cashiername; ?>" />
    <input type="hidden" name="curdate" value="<?php echo curdate(); ?>" />
    <p><label>Particulars</label><input type="text" name="particulars" /><?php echo form_error('particulars', '<span class="error">', '</span>'); ?></p>
    <p><label>Reference No.</label><input type="text" name="refno" /></p>
    <p><label>Amount</label><input id="datavaldecimal" type="text" name="amnt" /><?php echo form_error('amnt', '<span class="error"', '</span>'); ?></p>
    <p class="submit"><input type="submit" value="Save" /></p>
    <?php echo form_close(); ?>
</div>