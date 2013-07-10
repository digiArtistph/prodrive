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
            <div id="companylogo">Prodrive Motorwerks System</div>
            
            <div class="usercontextinfo">
            	<ul>
                	<li><span class="welcomeusermsg"><img title="Current logged in user." src="<?php echo base_url('images/user_avatar.png'); ?>" /> <?php echo (isset($almd_userfullname)) ? $almd_userfullname : "Welcome User!" ; ?></span></li>
                    <li><a href="<?php echo base_url('login/logout'); ?>">Log Out</a></li>
                    <li><a href="http://localhost/prodrivehelpsystem/doku.php?id=start" target="_new">Help</a></li>
                </ul>
                <div class="calendar"><i title="Is this the correct date?" class="sprite calendaricon"></i>Today is <?php echo longDate(curdate()); ?></div>
                <!--<div class="quicksearch"><a href="#">Job History</a></div>--> 
            </div>
        </div>
        <!-- navigation menu -->
        <?php $this->load->view('includes/navigation'); ?>
        <?php $this->load->view('includes/searchbox'); ?>
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