<div id="wrapper">
<h3>Labor Type View</h3>
	<div id="view_form">
	<?php if(! empty( $labortypes ) ):?>
	
	<table>
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
            	<td><a href="<?php echo base_url() . 'master/labortype/section/editlabor/' . $labortype->laborid ;?>">edit</a>|<a href="<?php echo base_url() . 'master/labortype/section/deletelabor/' . $labortype->laborid ;?>">delete</a></td>
        	</tr>   
		<?php endforeach;?>
		</tbody>
    </table>
	<?php else:?>
		<p>No labor types Added!!!</p>
	<?php endif;?>
	</div>
	<p><a href="<?php echo base_url() . 'master/labortype/section/addlabortype';?>">Add Labor type</a></p>
</div>