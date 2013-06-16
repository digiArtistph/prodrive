<div class="wrapper">
<h3 class="heading">Labor Type</h3>
<div class="minidashboard">
    	<div class="panelOne">        	<p>Labor Type Count: <strong><?php echo $count; ?></strong></p>            
        </div>        
    </div>
<div class="toolbar"><a href="<?php echo base_url() . 'master/labortype/section/addlabortype'; ?>">Add Labor type</a></div>
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
        <?php endif; ?></div>
    </div>
	<div id="view_form">
	<?php if(! empty( $labortypes ) ):?>
	
	<table  class="regdatagrid">
    	<thead>
        	<tr> 
        		<th>Name</th> 
            	<th>Categories</th>  
            	<th>Action</th>
            </tr>
        </thead>
        <tbody>
		<?php foreach ($labortypes as $labortype):?>
			<tr>
				<td><?php echo $labortype->name;?></td>
				<td><?php echo $labortype->category;?></td>
            	<td><a class="reggrideditbtn" href="<?php echo base_url() . 'master/labortype/section/editlabor/' . $labortype->laborid ;?>">Edit</a>|<a  class="reggriddelbtn delete-record-view" post-url="master/labortype/ajaxdeltype" code="<?php echo $labortype->laborid;?>" href="#">Delete</a></td>
        	</tr>   
		<?php endforeach;?>
		</tbody>
    </table>
	<?php else:?>
		<p>No labor types Added!!!</p>
	<?php endif;?>
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
        <?php endif; ?></div>
    </div>
<div id="dialog-confirm" title="Delete Record"><p></p></div>
</div>