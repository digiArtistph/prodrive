<div class="wrapper">
<h3 class="heading">Labor Type</h3>
<div class="minidashboard">
    	<div class="panelOne">        	<p>Labor Type Count: <strong><?php ''; ?></strong></p>            
        </div>        
    </div>
<div class="toolbar"><a href="<?php echo base_url() . 'master/labortype/section/addlabortype'; ?>">Add Labor type</a></div>
	<div id="view_form">
	<?php if(! empty( $labortypes ) ):?>
	
	<table  class="regdatagrid">
    	<thead>
        	<tr> 
        		<th>Name</th> 
            	<th>Categories</th>  
            	<th>Status</th>
            	<th>Action</th>
            </tr>
        </thead>
        <tbody>
		<?php foreach ($labortypes as $labortype):?>
			<tr>
				<td><?php echo $labortype->name;?></td>
				<td><?php echo $labortype->category;?></td>
				<td><?php if($labortype->status == 1){echo 'Active';}else{echo 'In active';} ?></td>
            	<td><a class="reggrideditbtn" href="<?php echo base_url() . 'master/labortype/section/editlabor/' . $labortype->laborid ;?>">edit</a>|<a  class="reggriddelbtn" href="<?php echo base_url() . 'master/labortype/section/deletelabor/' . $labortype->laborid ;?>">delete</a></td>
        	</tr>   
		<?php endforeach;?>
		</tbody>
    </table>
	<?php else:?>
		<p>No labor types Added!!!</p>
	<?php endif;?>
	</div>
</div>