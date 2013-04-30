<div id="container">
<h3>Add Labor Types</h3>
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
		</select>
		<span class="error"><?php echo form_error('cat');?></span></p>
		<p><label>status :</label> 
		Active <input type="radio" name="status" checked="checked" value="1"/>
		In active <input type="radio" name="status"  value="0"/><span class="error"><?php echo form_error('status');?></span></p>
		<p><input type="submit" value="Add Labor type"/></p>
		<?php echo form_close();?>
	</div>
</div>