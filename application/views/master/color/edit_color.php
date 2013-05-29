<div class="wrapper">
<h3 class="heading">Edit Color</h3>
<div class="toolbar"><a class="canceleditbtn" href="<?php echo base_url('master/color'); ?>">Cancel Edit Color</a></div>
	<div id="add_form">
	<?php if(! empty($colors)):?>
	
	<?php foreach ($colors as $color):?>
		<?php echo form_open(base_url() . 'master/color/validateeditcolor');?>
		<input type="hidden" name="clr_id" value="<?php echo $color->clr_id;?>" />
		<p><label>Color Name: </label> <input type="text" name="clr_name" value="<?php echo $color->name;?>"/><?php echo form_error('clr_name', '<span class="error">','</span>');?></p>
		<?php endforeach;?>
		
		<p class="submit"><input type="submit" value="Save"/></p>
		<?php echo form_close();?>
		
		<?php endif;?>
	</div>
</div>