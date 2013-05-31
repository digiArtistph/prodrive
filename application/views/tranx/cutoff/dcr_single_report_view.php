<?php global $almd_userfullname; ?>
<div class="wrapper">
	<h3 class="heading">Daily Cash Report</h3>
    <div class="minidashboard">
    	<div class="panelTwo">
        	<p>No. of success logins: <strong><?php echo $successlogin; ?></strong></p> 
        	<p>No. of failure logins:<strong><?php echo $failurelogin; ?></strong></p>
        </div> 
       	<!--<div class="panelTwo">
          	<p>Total Sales:</p>
            <p></p>
        </div>   -->     
        <div class="panelThree">
          	<p>Date: <?php echo longDate(curdate()); ?></p>
            <p>Cashier: <strong><?php echo $almd_userfullname; ?></strong></p>
        </div>    
    </div>
    <div id="view_form">
    <form>
        <p>Beginning Balance: Php <strong><?php echo $begbal; ?></strong></p>
        <p>Cash Float: Php <strong><?php echo $cashfloat; ?></strong></p>
        <p>Cash Lift: Php <strong><?php echo $cashlift; ?></strong></p>
        <p>Cash: Php <strong><?php echo $salescash; ?></strong></p>
        <p>Check: Php <strong><?php echo $salescheck; ?></strong></p>
        <p>Cash on Hand: Php <strong><?php echo $coh; ?></strong></p>
        <p>Total Sales: Php <strong><?php echo $totalsales; ?></strong> </p>
        <p><a class="addnmorebtn" href="#">Print Daily Cash Report</a></p>
    </form>
    </div>
</div>