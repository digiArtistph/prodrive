<div class="wrapper">
<h3 class="heading">Add New Labor Type</h3>
<div class="toolbar"><a class="cancenewlbtn" href="<?php echo base_url('master/labortype'); ?>">Cancel New Labor Type</a></div>
	<div id="add_form">
		<?php echo form_open(base_url() . 'master/labortype/validateaddlabor');?>
 	 	 
		<p>
		  <label>Labor Name: </label> <input type="text" name="lname" /><?php echo form_error('lname','<span class="error">', '</span>');?></p>
		<p><label>Category: </label> 
		<select name="cat">
			<option value="" selected="selected">Select Category</option>
			<?php if(!empty($categories) ):?>
			<?php foreach ($categories as $category):?>
			<option value="<?php echo $category->categ_id;?>"><?php echo $category->category;?></option>
			<?php endforeach;?>
			<?php endif;?>
		</select><?php echo form_error('cat', '<span class="error">', '</span>');?></p>
		<p class="submit"><input type="submit" value="Save"/></p>
		<?php echo form_close();?>
	</div>
</div>