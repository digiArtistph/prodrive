<div id="wrapper">
<h3>Edit Category</h3>
	<div id="add_form">
	<?php if(! empty($categories)):?>
	
	<?php foreach ($categories as $category):?>
		<?php echo form_open(base_url() . 'master/categories/validateeditcategories');?>
		<input type="hidden" name="cat" value="<?php echo $category->categ_id;?>" />
		<p><label>Category Name: </label> <input type="text" name="cat_name" value="<?php echo $category->category;?>"/><span class="error"><?php echo form_error('cat_name');?></span></p>
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
			
				
			</select><span class="error"><?php echo form_error('cat_parent');?></span>
			
		<p><input type="submit" value="Edit Category"/></p>
		<?php echo form_close();?>
		
		<?php endif;?>
	</div>
</div>