<div class="wrapper">
<h3 class="heading">Company</h3>
<div class="minidashboard">
    	<div class="panelOne">        	<p>Company Count: <strong><?php echo $count; ?></strong></p>            
        </div>        
    </div>
<div class="toolbar"><a href="<?php echo base_url() . 'master/company/section/addcompany'; ?>">Add New Company</a></div>
<div class="clearthis">&nbsp;</div>
<div class="pagination-record">
	<div class="pagination-controls">
    	<?php echo $paginate; ?>
    </div>
    
    <div class="record-filter">
	    <?php if($paginate !=""): ?>
            View <select name="viewperpage">
            <option value="10">10</option>
            <option value="20">20</option>
            <option value="30">30</option>
            <option value="50">50</option>
            <option value="75">75</option>
            <option value="100">100</option>
            <option value="-1">All</option>
            </select> per page
        <?php endif; ?>
        </div>
    </div>
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
    <div class="clearthis">&nbsp;</div>
<div class="pagination-record">
	<div class="pagination-controls">
    	<?php echo $paginate; ?>
    </div>
    
    <div class="record-filter">
	    <?php if($paginate !=""): ?>
            View <select name="viewperpage">
            <option value="10">10</option>
            <option value="20">20</option>
            <option value="30">30</option>
            <option value="50">50</option>
            <option value="75">75</option>
            <option value="100">100</option>
            <option value="-1">All</option>
            </select> per page
        <?php endif; ?>
        </div>
    </div>
<div id="dialog-confirm" title="Delete Record"><p></p></div>
</div>