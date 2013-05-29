<div class="wrapper">
	<h3 class="heading">Backup Database</h3>
	<div class="minidashboard">
    	<div class="panelOne">        	<p>Select a destination folder for the backup data to be stored in.</strong></p>            
        </div>        
    </div>
	<?php echo form_open(base_url() . 'utility/datarecovery/validatebackup');?>
	<p><label>Destination Folder: </label><select class="drives" name="dir"> 
	<?php if(!empty($drivers)):?>
	<option selected="selected" value="">Select Drive</option>
	<?php foreach ($drivers as $key => $val):?>
	<option value="<?php echo $key?>"> <?php echo $val;?></option>
	<?php endforeach;?>
	
	<?php else:?>
	<option value=""> There are no drives Available</option>
	<?php endif;?>
	</select><?php echo form_error('dir');?></p>
	<p class="submit"><input type="submit" value="Start Backup" /></p>
	<?php echo form_close();?>
</div>