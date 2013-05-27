<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="description"  content="Prodrive Motowerks" />
    <meta name="keywords"  content="HTML,CSS,XML,JavaScript" />
    <meta name="author"  content="Mugs and Coffee" />
    <meta name="Viewport"  width="devicewidth" />
    <meta name="url" content="<?php echo base_url();?>" />
    <title>Prodrive System</title>
  	<?php getHeader(); ?>

<body>
    <div  id="container">
    	<div>
                <ul>
                    <li><a href="#">Log-out</a></li>
                </ul>
            </div>
        <div  id="masthead">
        	
            <ul>
                <li  class="menu-item"><a  href="url1" >Transaction</a>
                	<ul>
                    	<li><a href="<?php echo base_url('tranx/dcr'); ?>">DCR Entry</a></li>
                        <li><a href="<?php echo base_url('tranx/joborder'); ?>">Job Order</a></li>
                        <li><a href="#">Cash Float</a></li>
                        <li><a href="#">Cash Lift</a></li>
                        <li><a href="#">Cut-Off</a></li>
                    </ul>
                </li>
                <li  class="menu-item"><a  href="url2" >Master Files</a>
                	<ul>
                    	<li><a href="<?php echo base_url('master/customer'); ?>">Customers</a></li>
                        <li><a href="<?php echo base_url('master/categories'); ?>">Categories</a></li>
                        <li><a href="<?php echo base_url('master/labortype'); ?>">Labor Type</a></li>
                        <li><a href="<?php echo base_url('master/users'); ?>">Users</a></li>
                        <li><a href="<?php echo base_url('master/vehicle'); ?>">Vehicles</a></li>
                        <li><a href="#">Colors</a></li>
                    </ul>
                </li>
                <li  class="menu-item"><a  href="url3" >Reports</a>
                	<ul>
                    	<li><a href="#">Daily Cash Report</a></li>
                        <li><a href="#">Job Order History</a></li>
                    </ul>
                </li>
                <li  class="menu-item"><a  href="url4" >Utility</a>
                	<ul>
                    	<li><a href="<?php echo base_url() . 'utility/backup';?>">Backup Database</a></li>
                        <li><a href="<?php echo base_url() . 'utility/restore';?>">Restore Database</a></li>
                    </ul>
                </li>
            </ul>
        </div>

    
        <div  id="content">
            <?php $this->load->view($main_content); ?>
        </div>

        
        <div  id="footer">
        	
        </div>
    </div>
</body>
</html>