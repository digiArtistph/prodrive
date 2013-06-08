<?php global $almd_username; ?>
<div class="wrapper">
	<h3 class="heading">Cut Off (Closing Shift)</h3>
    
    <div class="minidashboard">
    	        
    </div>
	<div id="view_form"><div class="clearthis">&nbsp;</div>
    <div class="ui-widget">
	<div style="margin-top: 0; padding: 0 .7em;" class="ui-state-highlight ui-corner-all">
		<p><span style="float: left; margin-right: .3em;" class="ui-icon ui-icon-info"></span>
		<strong>Hey! This process will permanently close your current shift</strong>; thus, <span class="error-two">you won't be able to add more payments for this shift</span>. To continue to close your current shift just enter your password and press the "Close Shift" button.</p>
	</div>
</div>
    
    <p>&nbsp;</p>
    	<?php echo form_open(base_url('tranx/cutoff/validatecutoff')); ?>
        	<p><label>Enter your password</label><input type="password" name="pword" /><?php echo ($msg != '') ? "<span class='error'>$msg</span>": ''; ?><?php echo form_error('pword', '<span class="error">', '</span>'); ?></p>        	
            <p class="submit"><input type="submit" value="Close Shift" /></p>
        <?php echo form_close(); ?>
    </div>
</div>
