<div class="wrapper">
<h3 class="heading">Company</h3>
<div class="minidashboard">
    	<div class="panelOne">        	<p>Company Count: <strong><?php echo $count; ?></strong></p>            
        </div>        
    </div>
<div class="toolbar"><a href="<?php echo base_url() . 'master/company/section/addcompany'; ?>">Add New Company</a></div>
<?php getPagination(); ?>
	<div id="view_form">
	<?php if(! empty($companies)):?>
	
	<table class="regdatagrid">
    	<thead>
        	<tr> 
            	<th>Name</th>     
            	<th>Address</th>
            	<th>Phone</th>
            	<th>Action</th>
            </tr>
        </thead>
        <tbody>
		<?php foreach ($companies as $company): ?>
			<tr>
            	<td><?php echo $company->name ; ?></td>
                <td><?php  echo ($company->addr) ? $company->addr : '' ; ?></td>
                <td><?php if( empty($company->phone) ){echo 'No Phone number';}else{ echo $company->phone;}?></td>
                <td><a class="reggrideditbtn" href="<?php echo base_url() . 'master/company/section/editcompany/' . $company->co_id;?>">Edit</a>|<a post-url="ajax/ajxcompany/deleteCompany" class="reggriddelbtn delete-record-view" href="#" code="<?php echo $company->co_id;?>">Delete</a></td>
        	</tr>   
		<?php endforeach;?>
		</tbody>
    </table>
	<?php else: ?>
    
		<p>No record found.</p>
	
	<?php endif; ?>
	</div>
    <?php getPagination(); ?>
<div id="dialog-confirm" title="Delete Record"><p></p></div>
</div>