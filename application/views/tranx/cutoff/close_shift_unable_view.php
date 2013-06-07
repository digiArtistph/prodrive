<?php global $almd_username; global  $almd_userfullname; ?>
<div class="wrapper">
	<h3 class="heading">Cut Off (Closing Shift)</h3>
    
    <div class="minidashboard">
    	<div class="panelOne"><p>This will close all transaction for this shift and will generate a cash daily report.</p> 
        </div> <div class="panelTwo">
          <p>Please provide your password correctly to proceed on this process.</p> <p>Current user logged in: <strong><?php echo $almd_username; ?></strong></p>
        </div>        
    </div>
	<div id="view_form">
    <div class="clearthis">&nbsp;</div>
    <div class="ui-widget">
        <div style="padding: 0 .7em;" class="ui-state-error ui-corner-all">
            <p><span style="float: left; margin-right: .3em;" class="ui-icon ui-icon-alert"></span>
            <strong>Alert:</strong> Sorry! You don'nt have a current active shift right now. Please go to <strong>Transaction</strong> tab and <strong>DCR Entry</strong> menu to start a new shift.</p>
        </div>
    </div>
    </div>
</div>
