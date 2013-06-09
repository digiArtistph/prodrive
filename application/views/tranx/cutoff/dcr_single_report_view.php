<?php global $almd_userfullname; ?>
<div class="wrapper">
	<h3 class="heading">DAILY COLLECTION REPORT</h3>
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
    <div class="prntview prnt-company-header">
    	<h2>Prodrive Motorwerks</h2>
        <p>Jr. Borja Extension cor. Lim Ketkai Drive, Cagayan de Oro City<br />Tel. No.: 8800-759</p>
        <h4>DAILY COLLECTION REPORT</h4>
        <p class="prnt-trnxdate">Date: <?php echo longDate(curdate()); ?></p>
    </div>
    <div id="view_form">
    <div class="clearthis">&nbsp;</div>
    <?php if(!empty($fullpaid)): ?>
    	<table class="prnt-regdatagrid">
        	<thead>
            	<tr>
                	<th>
                    	Particulars
                    </th>
                    <th>
                    	Tender
                    </th>
                    <th>
                    	Amount
                    </th>
                    
                </tr>
            </thead>
            <tbody>
            	<?php foreach($fullpaid as $fpRecord): ?>
            	<tr>
                	<td><?php echo $fpRecord->particulars; ?></td>                    
					<td><?php echo $fpRecord->tender; ?></td>
                    <td><?php echo $fpRecord->amnt; ?></td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
	<?php else: ?>
    	<p>------</p>
	<?php endif; ?>
    <h4>Advances</h4>
    <?php if(!empty($advances)): ?>
    	<table class="prnt-regdatagrid">
        	
            <tbody>
            	<?php foreach($advances as $adRecord): ?>
            	<tr>
                	<td><?php echo $adRecord->particulars; ?></td>                    
					<td><?php echo $adRecord->tender; ?></td>
                    <td><?php echo sCurrency($adRecord->amnt); ?></td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    <?php else: ?>
    	<p>---</p>
    <?php endif; ?>
    <table class="prnt-regdatagrid">
    <tbody>
    	<tr><td colspan="3">&nbsp;</td></tr>
    	<tr><td></td><td></td><td style="text-align:right;">Total Sales: <strong><?php echo sCurrency($totalsales); ?></strong></td></tr>
        <tr><td></td><td></td><td>Beginning Balance: <strong><?php echo sCurrency($begbal); ?></strong></td></tr>
        <tr><td></td><td></td><td>Cash on Hand <strong><?php echo sCurrency($coh); ?></strong></td></tr>
        </tbody>
    </table>
    
    <div class="prnt-cash-lift-box">
    <h4>Cash Lift</h4>
    
    <?php if(!empty($cashliftdetails)): ?>
    	<table class="prnt-regdatagrid">
        	
            <tbody>
            	<?php foreach($cashliftdetails as $adCLDtls): ?>
            	<tr>
                	<td><?php echo $adCLDtls->particulars; ?></td>                    
                    <td><?php echo sCurrency($adCLDtls->amnt); ?></td>                   
                </tr>                
                <?php endforeach; ?>
                <tr>
                	<td></td>
                	<td style="border-top:1px solid #636363;"><?php echo sCurrency($cashlift); ?></td>
                </tr>
            </tbody>
        </table>
    <?php else: ?>
    	<p>---</p>
    <?php endif; ?>
    
     <h4>Cash Float</h4>
    
    <?php if(!empty($cashfloatdetails)): ?>
    	<table class="prnt-regdatagrid">
        	
            <tbody>
            	<?php foreach($cashfloatdetails as $adCFDtls): ?>
            	<tr>
                	<td><?php echo $adCFDtls->particulars; ?></td>                    
                    <td><?php echo sCurrency($adCFDtls->amnt); ?></td>                   
                </tr>                
                <?php endforeach; ?>
                <tr>
                	<td></td>
                	<td style="border-top:1px solid #636363;"><?php echo sCurrency($cashfloat); ?></td>
                </tr>
            </tbody>
        </table>
    <?php else: ?>
    	<p>---</p>
    <?php endif; ?>
    <p class="prnt-button-container"><a title="This will pop out the printer dialog box" class="prnt-print-button" href="#">Print</a></p>
    </div>
    
        <div class="prnt-cash-float-box">
	       <p>&nbsp;</p>
           <p>Prepared by: <?php echo $userfullname; ?></p>
           <p>&nbsp;</p>
           <p>Received by: </p>
        </div>
    </div>
    
</div>