<div>
	<h3>Backup Data</h3>
	
	<?php echo form_open(base_url() . 'temp/validatebackup');?>
	<p><label>Destination Folder: </label><select name="dir"> 
	<?php if(!empty($drivers)):?>
	
	<?php foreach ($drivers as $key => $val):?>
	<option value="<?php echo $key?>"> <?php echo $val;?></option>
	<?php endforeach;?>
	
	<?php else:?>
	<option value=""> There are no drives Available</option>
	<?php endif;?>
	</select><?php echo form_error('dir');?></p>
	<p><input type="submit" value="Go Back up" /></p>
	<?php echo form_close();?>
</div>