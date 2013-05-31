<?php global $almd_username; ?>
<div class="wrapper">
	<h3 class="heading">Cut Off (Closing Shift)</h3>
    
    <div class="minidashboard">
    	<div class="panelOne"><p>This will close all transaction for this shift and will generate a cash daily report.</p> 
        </div> <div class="panelTwo">
          <p>Please provide your password correctly to proceed on this process.</p> <p>Current user logged in: <strong><?php echo $almd_username; ?></strong></p>
        </div>        
    </div>
	<div id="view_form">
    	<?php echo form_open(base_url('tranx/cutoff/validatecutoff')); ?>
        	<p><label>Enter your password</label><input type="password" name="pword" /><?php echo form_error('pword', '<span class="error">', '</span>'); ?></p>        	
            <p class="submit"><input type="submit" value="Close Shift" /></p>
        <?php echo form_close(); ?>
    </div>
</div>