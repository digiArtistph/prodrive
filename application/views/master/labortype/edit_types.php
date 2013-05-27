<div id="wrapper">
<h3>Add Labor Types</h3>
	<div id="add_form">
		<?php if(!empty($laborlists)):?>
		<?php echo form_open(base_url() . 'master/labortype/validateeditlabor');?>
 	 	<?php foreach ($laborlists as $laborlist):?>
 	 	<input type="hidden" name="lt" value="<?php echo $laborlist->laborid;?>" />
		<p><label>Labor name: </label> <input type="text" name="lname" value="<?php echo $laborlist->name;?>" /><span class="error"><?php echo form_error('lname');?></span></p>
		<p><label>category name: </label> 
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
		<span class="error"><?php echo form_error('cat');?></span></p>
		<p><label>status :</label> 
		Active <input type="radio" name="status" <?php if($laborlist->status == 1){echo 'checked="checked"';}?> value="1"/>
		In active <input type="radio" name="status" <?php if($laborlist->status == 0){echo 'checked="checked"';}?>  value="0"/><span class="error"><?php echo form_error('status');?></span></p>
		<p><input type="submit" value="Edit Labor type"/></p>
		<?php endforeach;?>
		<?php echo form_close();?>
		<?php endif;?>
	</div>
</div>