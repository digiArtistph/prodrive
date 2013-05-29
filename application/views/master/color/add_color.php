<div class="wrapper">
<h3 class="heading">Add Color</h3>
<div class="toolbar"><a class="cancenewlbtn" href="<?php echo base_url('master/color'); ?>">Cancel New Color</a></div>
	<div id="add_form">
		<?php echo form_open(base_url() . 'master/color/validateaddcolor');?>
		<p><label>Color Name: </label> <input type="text" name="color_name" /><?php echo form_error('color_name', '<span class="error">', '</span>');?></p>
		<p class="submit"><input type="submit" value="Save"/></p>
		<?php echo form_close();?>
	</div>
</div>