<div>
	<h3>Load Data</h3>
	
	<?php echo form_open(base_url() . 'temp/validaterestore');?>
	
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
	<p><input type="submit" value="Load Data" /></p>
	<?php echo form_close();?>
</div>