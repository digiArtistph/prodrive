<div class="wrapper">
<h3 class="heading">Category</h3>
<div class="minidashboard">
    	<div class="panelOne">        	<p>Category Count: <strong><?php echo $count; ?></strong></p>            
        </div>        
  </div>
<div class="toolbar"><a href="<?php echo base_url() . 'master/categories/section/addcategories'; ?>">Add New Category</a></div>
	<?php getPagination(); ?>   
	<div id="view_form">
	<?php if(! empty( $categories ) ):?>
	
	<table class="regdatagrid">
    	<thead>
        	<tr> 
            	<th>Categories</th> 
            	<th>Action</th>
            </tr>
        </thead>
        <tbody>
		<?php foreach ($categories as $category):?>
			<tr>
				<td><?php echo search_highlight((isset($search_keyword)) ? $search_keyword : '',$category->category);?></td>
            	<td><a class="reggrideditbtn" href="<?php echo base_url() . 'master/categories/section/editcategories/' . $category->categ_id;?>">Edit</a>|<a class="reggriddelbtn delete-record-view" post-url="master/categories/ajaxdelcat" code="<?php echo $category->categ_id;?>" href="#">Delete</a></td>
        	</tr>   
		<?php endforeach;?>
		</tbody>
    </table>
	<?php else:?>
		<p>No Categories Found.</p>
	<?php endif;?>
	</div>
    

<div id="dialog-confirm" title="Delete Record"><p></p></div>
<?php getPagination(); ?>
</div>