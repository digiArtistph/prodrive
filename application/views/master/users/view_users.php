<div id="container">
<h3>Customer View</h3>
	<div id="view_form">
		<?php if(!empty($users)):?>
		<table>
    	<thead>
        	<tr> 
            	<th>Username</th> 
            	<th>User Type</th>    
            	<th>Fullname</th>
            	<th>Address</th>
            	<th>Status</th>
            	<th>Action</th>
            </tr>
        </thead>
        <tbody>
        <?php foreach ($users as $user):?>
        	<tr>
        		<td><?php echo $user->username;?></td>
        		<td><?php echo $user->type;?></td>
        		<td><?php echo ucfirst($user->fname) . ' ' . ucfirst($user->mname[0]) . '. ' . ucfirst($user->lname);?></td>
        		<td><?php echo $user->addr;?></td>
        		<td><?php if($user->status == 1){echo 'Active';}else{echo 'In Active';}?></td>
        		<td><a href="<?php echo base_url() . 'master/users/section/editusers/' . $user->u_id;?>">Edit</a>|<a href="<?php echo base_url() . 'master/users/section/deleteusers/' . $user->u_id;?>">delete</a></td>
        	</tr>
        <?php endforeach;?>
        </tbody>
        </table>
		<?php else:?>
		<p>No Users</p>
		<?php endif;?>
	<p><a href="<?php echo base_url() . 'master/users/section/addusers';?>">Add Users</a></p>
	</div>
</div>