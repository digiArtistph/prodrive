<div class="wrapper">
<h3 class="heading">Edit New Labor Type</h3>
<div class="toolbar"><a class="canceleditbtn" href="<?php echo base_url('master/labortype'); ?>">Cancel Edit Labor Type</a></div>
	<div id="add_form">
		<?php if(!empty($laborlists)):?>
		<?php echo form_open(base_url() . 'master/labortype/validateeditlabor');?>
 	 	<?php foreach ($laborlists as $laborlist):?>
 	 	<input type="hidden" name="lt" value="<?php echo $laborlist->laborid;?>" />
		<p><label>Labor name: </label> <input type="text" name="lname" value="<?php echo $laborlist->name;?>" /><?php echo form_error('lname', '<span class="error">', '</span>');?></p>
		<p>
		<label>Category: </label> 
		<select name="cat">
			
			<?php if(!empty($categories) ):?>
			<option value="" selected="selected">Select Category</option>
			<?php foreach ($categories as $category):?>
				<?php if($category->categ_id == $laborlist->category):?>
				<option value="<?php echo $category->categ_id;?>" selected="selected"><?php echo $category->category;?></option>
				<?php else:?>
				<option value="<?php echo $category->categ_id;?>"><?php echo $category->category;?></option>
				<?php endif;?>
			<?php endforeach;?>
			<?php else:?>
			<option value="" selected="selected">Select Category</option>
			<?php endif;?>
		</select>
		<?php echo form_error('cat', '<span class="error">', '</span>');?></p>
		<?php endforeach;?>
		<p class="submit"><input type="submit" value="Save"/></p>
		<?php echo form_close();?>
		<?php endif;?>
	</div>
</div>