<div class="wrapper">
	<h3 class="heading">Restore Database</h3>
	<div class="minidashboard">
    	<div class="panelOne">        	<p>Select a snapshot of the database to be restored.</strong></p>            
        </div>        
    </div>
	<?php echo form_open(base_url() . 'utility/datarecovery/validaterestore');?>
	
	<p><label>Select Source: </label><select  class="dir" name="dir"> 
	<?php if(!empty($drivers)):?>
	<option selected="selected" value="">Select Drive</option>
	<?php foreach ($drivers as $key => $val):?>
	<option value="<?php echo $key . '\prodrive';?>"> <?php echo $val;?></option>
	<?php endforeach;?>
	
	<?php else:?>
	<option value=""> There are no drives Available</option>
	<?php endif;?>
	</select><?php echo form_error('dir');?></p>
	
	<p><label> Data File: </label>
		<select class="datafile" name="datafile">
			<option selected="selected" value="">Select source file</option>
		</select><?php echo form_error('datafile');?>
	</p>
	<p class="submit"><input type="submit" value="Start Restoring Data" /></p>
	<?php echo form_close();?>
</div>