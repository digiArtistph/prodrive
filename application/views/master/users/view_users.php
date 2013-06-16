<div class="wrapper">
<h3 class="heading">Users</h3>
<div class="minidashboard">
    	<div class="panelOne">        	<p>Users Count: <strong><?php echo $count; ?></strong></p>            
        </div>        
  </div>
<div class="toolbar"><a href="<?php echo base_url() . 'master/users/section/addusers'; ?>">Add New User</a></div>
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
		<?php if(!empty($users)):?>
		<table  class="regdatagrid">
    	<thead>
        	<tr> 
            	<th>Username</th> 
            	<th>User Type</th>    
            	<th>Fullname</th>
            	<th>Address</th>
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
        		<td><a class="reggrideditbtn" href="<?php echo base_url() . 'master/users/section/editusers/' . $user->u_id;?>">Edit</a>|<a class="reggriddelbtn delete-record-view" post-url="master/users/ajaxdeluser" code="<?php echo $user->u_id;?>" href="#">Delete</a></td>
        	</tr>
        <?php endforeach;?>
        </tbody>
        </table>
		<?php else:?>
		<p>No Users</p>
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
        <?php endif; ?>
        </div>
    </div>
<div id="dialog-confirm" title="Delete Record"><p></p></div>
</div>