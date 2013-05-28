<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8" />
<meta name="description"  content="Prodrive Motowerks" />
<meta name="keywords"  content="HTML,CSS,XML,JavaScript" />
<meta name="author"  content="Mugs and Coffee" />
<meta name="Viewport"  width="devicewidth" />
<meta name="url" content="<?php echo base_url();?>" />
<title>Prodrive Motorwerks System</title>
<?php getHeader(); ?>
<?php
	global $almd_userfullname;
?>
</head>

<body>

<div id="maincontainer">
	<div id="header">
    	<div id="masthead">
        	<!-- logo and user-context info -->
            <div id="companylogo">Prodrive Motowerks System</div>
            
            <div class="usercontextinfo">
            	<ul>
                	<li><span class="welcomeusermsg"><img src="<?php echo base_url('images/user_avatar.png'); ?>" /> <?php echo (isset($almd_userfullname)) ? $almd_userfullname . "!": "Welcome User!" ; ?></span></li>
                    <li><a href="<?php echo base_url('login/logout'); ?>">Log Out</a></li>
                </ul>
                <div class="calendar"><i class="sprite calendaricon"></i>Today is: <?php echo longDate(curdate()); ?></div>
            </div>
        </div>
        
        <div id="menu">
        	<!-- main menus  -->
            <ul class="menucontainer">
                <li class="selected"><a  href="<?php echo base_url('tranx/dcr/'); ?>" >Transaction</a>
                	<div class="selected">
                        <ul>
                            <li><a href="<?php echo base_url('tranx/dcr'); ?>">DCR Entry</a></li>
                            <li><a href="<?php echo base_url('tranx/joborder'); ?>">Job Order</a></li>
                            <li><a href="<?php echo base_url('tranx/cashfloat'); ?>">Cash Float</a></li>
                            <li><a href="<?php echo base_url('tranx/cashlift'); ?>">Cash Lift</a></li>
                            <li><a href="#">Cut-Off</a></li>
                        </ul>
                    </div>
                </li>
                <li><a  href="<?php echo base_url('master/customer'); ?>" >Master Files</a>
                <div>
                	<ul>
                    	<li><a href="<?php echo base_url('master/customer'); ?>">Customers</a></li>
                        <li><a href="<?php echo base_url('master/categories'); ?>">Categories</a></li>
                        <li><a href="<?php echo base_url('master/labortype'); ?>">Labor Type</a></li>
                        <li><a href="<?php echo base_url('master/users'); ?>">Users</a></li>
                        <li><a href="<?php echo base_url('master/vehicle'); ?>">Vehicles</a></li>
                        <li><a href="#">Colors</a></li>
                    	</ul>
                    </div>
                </li>
                <li><a  href="url3" >Reports</a>
                	<div>
                        <ul>
                            <li><a href="#">Daily Cash Report</a></li>
                            <li><a href="#">Job Order History</a></li>
                        </ul>
					</div>
                </li>
                <li><a  href="<?php echo base_url('utility/backup'); ?>" >Utility</a>
                	<div>
                        <ul>
                            <li><a href="<?php echo base_url() . 'utility/backup';?>">Backup Database</a></li>
                            <li><a href="<?php echo base_url() . 'utility/restore';?>">Restore Database</a></li>
                        </ul>
					</div>
                </li>
            </ul>
        </div>
    </div>
    
    <div id="container">
    	<?php $this->load->view($main_content); ?>
    </div>

	<div id="footer">
		<div class="leftpane"><p>&copy; 2013 <a href="#">prodrivemotowerks</a></p></div>
        <div class="rightpane"><p>powered by: <a href="#">mugs and coffee</a></p></div>
    </div>
</div>

</body>
</html>