<div class="wrapper">
<h3 class="heading">Edit Category</h3>
<div class="toolbar"><a class="canceleditbtn" href="<?php echo base_url('master/categories'); ?>">Cancel Edit Category</a></div>
	<div id="add_form">
	<?php if(! empty($categories)):?>
	
	<?php foreach ($categories as $category):?>
		<?php echo form_open(base_url() . 'master/categories/validateeditcategories');?>
		<input type="hidden" name="cat" value="<?php echo $category->categ_id;?>" />
		<p><label>Category Name: </label> <input type="text" name="cat_name" value="<?php echo $category->category;?>"/><?php echo form_error('cat_name', '<span class="error">','</span>');?></p>
		<?php endforeach;?>
		
		<p><label>Parent</label>
			<select name="cat_parent">
			<?php if ($category->parent == 0) :?>
					<option value="0" selected="selected" >None</option>
				<?php foreach ( $parents as $parent):?>
					<option value="<?php echo $parent->categ_id;?>" ><?php echo $parent->category;?></option>
				<?php endforeach;?>
			<?php else:?>
					<option value="0" >None</option>
					<?php foreach ( $parents as $parent):?>
					<?php if($category->parent == $parent->categ_id ):?>
					<option value="<?php echo $parent->categ_id;?>" <?php echo 'selected="selected"'?>><?php echo $parent->category;?></option>
					<?php else:?>
					<option value="<?php echo $parent->categ_id;?>" ><?php echo $parent->category;?></option>
					<?php endif;?>
				<?php endforeach;?>
			<?php endif;?>
			
				
			</select><?php echo form_error('cat_parent','<span class="error">', '</span>');?>
			
		<p class="submit"><input type="submit" value="Save"/></p>
		<?php echo form_close();?>
		
		<?php endif;?>
	</div>
</div>