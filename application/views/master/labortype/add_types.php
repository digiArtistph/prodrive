<div class="wrapper">
<h3 class="heading">Add Labor type</h3>
<div class="toolbar"><a class="cancenewlbtn" href="<?php echo base_url('master/labortype'); ?>">Cancel New Labor type</a></div>
	<div id="add_form">
		<?php echo form_open(base_url() . 'master/labortype/validateaddlabor');?>
 	 	 
		<p><label>Labor name: </label> <input type="text" name="lname" /><span class="error"><?php echo form_error('lname');?></span></p>
		<p><label>category name: </label> 
		<select name="cat">
			<option value="" selected="selected">Select Category</option>
			<?php if(!empty($categories) ):?>
			<?php foreach ($categories as $category):?>
			<option value="<?php echo $category->categ_id;?>"><?php echo $category->category;?></option>
			<?php endforeach;?>
			<?php endif;?>
		</select><span class="error"><?php echo form_error('cat');?></span></p>
		<p class="submit"><input type="submit" value="Save"/></p>
		<?php echo form_close();?>
	</div>
</div>