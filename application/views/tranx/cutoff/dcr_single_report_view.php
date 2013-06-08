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
    <div class="prntCompanyLogo"></div>
    <div id="view_form">
    <div class="clearthis">&nbsp;</div>
    <?php if(!empty($fullpaid)): ?>
    	<table>
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
    	<table>
        	
            <tbody>
            	<?php foreach($advances as $adRecord): ?>
            	<tr>
                	<td><?php echo $adRecord->particulars; ?></td>                    
					<td><?php echo $adRecord->tender; ?></td>
                    <td><?php echo $adRecord->amnt; ?></td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    <?php else: ?>
    	<p>---</p>
    <?php endif; ?>
    
    <h4>Cash Lift</h4>
    
    <?php if(!empty($cashliftdetails)): ?>
    	<table>
        	
            <tbody>
            	<?php foreach($cashliftdetails as $adCLDtls): ?>
            	<tr>
                	<td><?php echo $adCLDtls->particulars; ?></td>                    
                    <td><?php echo $adCLDtls->amnt; ?></td>                   
                </tr>                
                <?php endforeach; ?>
                <tr>
                	<td style="border-top:1px solid #636363;"><?php echo $cashlift; ?></td>
                </tr>
            </tbody>
        </table>
    <?php else: ?>
    	<p>---</p>
    <?php endif; ?>
    
    <h4>Cash Float</h4>
    
    <?php if(!empty($cashfloatdetails)): ?>
    	<table>
        	
            <tbody>
            	<?php foreach($cashfloatdetails as $adCFDtls): ?>
            	<tr>
                	<td><?php echo $adCFDtls->particulars; ?></td>                    
                    <td><?php echo $adCFDtls->amnt; ?></td>                   
                </tr>                
                <?php endforeach; ?>
                <tr>
                	<td style="border-top:1px solid #636363;"><?php echo $cashfloat; ?></td>
                </tr>
            </tbody>
        </table>
    <?php else: ?>
    	<p>---</p>
    <?php endif; ?>
    
    </div>
</div>