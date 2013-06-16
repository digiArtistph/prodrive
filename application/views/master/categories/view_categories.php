<div class="wrapper">
<h3 class="heading">Category</h3>
<div class="minidashboard">
    	<div class="panelOne">        	<p>Category Count: <strong><?php echo $count; ?></strong></p>            
        </div>        
  </div>
<div class="toolbar"><a href="<?php echo base_url() . 'master/categories/section/addcategories'; ?>">Add New Category</a></div>
<div class="pagination-record">
	<div class="pagination-controls">
    	<!--1&nbsp;<a href="#">2</a>&nbsp;<a href="#">3</a>&nbsp;<a href="#">4</a>--><?php echo $paginate; ?>
    </div>
    <div class="record-filter"><select name="viewperpage">
        <option value="10">10</option>
        <option value="20">20</option>
        <option value="30">30</option>
        <option value="50">50</option>
        <option value="75">75</option>
        <option value="100">100</option>
        <option value="-1">All</option>
        </select> per page</div>
    </div>
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
				<td><?php echo $category->category;?></td>
            	<td><a class="reggrideditbtn" href="<?php echo base_url() . 'master/categories/section/editcategories/' . $category->categ_id;?>">Edit</a>|<a class="reggriddelbtn delete-record-view" post-url="master/categories/ajaxdelcat" code="<?php echo $category->categ_id;?>" href="#">Delete</a></td>
        	</tr>   
		<?php endforeach;?>
		</tbody>
    </table>
	<?php else:?>
		<p>No Categories Added!!!</p>
	<?php endif;?>
	</div>
<div id="dialog-confirm" title="Delete Record"><p></p></div>
</div>