<div class="wrapper">
<h3 class="heading">Category View</h3>
	<div id="view_form">
	<?php if(! empty( $categories ) ):?>
	
	<table>
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
            	<td><a href="<?php echo base_url() . 'master/categories/section/editcategories/' . $category->categ_id;?>">edit</a>|<a href="<?php echo base_url() . 'master/categories/section/deletecategories/' . $category->categ_id;?>">delete</a></td>
        	</tr>   
		<?php endforeach;?>
		</tbody>
    </table>
	<?php else:?>
		<p>No Categories Added!!!</p>
	<?php endif;?>
	</div>
	<p><a href="<?php echo base_url() . 'master/categories/section/addcategories'; ?>">Add Categories</a></p>
</div>