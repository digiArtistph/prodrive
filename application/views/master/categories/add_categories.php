<div class="wrapper">
<h3 class="heading">Add Category</h3>
<div class="toolbar"><a class="cancenewlbtn" href="<?php echo base_url('master/categories'); ?>">Cancel New Category</a></div>
	<div id="add_form">
		<?php echo form_open(base_url() . 'master/categories/validateaddcategories');?>
		<p><label>Category Name: </label> <input type="text" name="cat_name" /><span class="error"><?php echo form_error('cat_name');?></span></p>
		<p><label>Parent</label>
			<select name="cat_parent">
				<option value="0" selected="selected">None</option>
				<?php if(! empty($categories) ):?>
				<?php foreach ($categories as $category):?>
				<option value="<?php echo $category->categ_id;?>"><?php echo $category->category;?></option>
				<?php endforeach;?>
				<?php endif;?>
			</select><span class="error"><?php echo form_error('cat_parent');?></span>
		<p class="submit"><input type="submit" value="Save"/></p>
		<?php echo form_close();?>
	</div>
</div>