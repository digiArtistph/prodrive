<div id="menu">
        	<!-- main menus  -->
            <ul class="menucontainer">
                <li <?php isTabSelected('tranx'); ?>><a  href="<?php echo base_url('tranx/dcr/'); ?>" >Transaction</a>
                	<div  <?php isTabSelected('tranx'); ?>>
                        <ul>
                            <li <?php isTabSelected('dcr', 'submenuselected', 2); ?>><a href="<?php echo base_url('tranx/dcr'); ?>">DCR Entry</a></li>
                            <li  <?php isTabSelected('joborder', 'submenuselected', 2); ?>><a href="<?php echo base_url('tranx/joborder'); ?>">Job Order</a></li>
                            <li  <?php isTabSelected('receiving', 'submenuselected', 2); ?>><a href="<?php echo base_url('tranx/receiving'); ?>">Recieving</a></li>
                            <li <?php isTabSelected('cashfloat', 'submenuselected', 2); ?>><a href="<?php echo base_url('tranx/cashfloat'); ?>">Cash Float</a></li>
                            <li <?php isTabSelected('cashlift', 'submenuselected', 2); ?>><a href="<?php echo base_url('tranx/cashlift'); ?>">Cash Lift</a></li>
                            <li <?php isTabSelected('cutoff', 'submenuselected', 2); ?>><a href="<?php echo base_url('tranx/cutoff'); ?>">Cut-Off</a></li>
                        </ul>
                    </div>
                </li>
                <li  <?php isTabSelected('master'); ?>><a  href="<?php echo base_url('master/customer'); ?>" >Master Files</a>
                <div  <?php isTabSelected('master'); ?>>
                	<ul>
                    	<li <?php isTabSelected('customer', 'submenuselected', 2); ?>><a href="<?php echo base_url('master/customer'); ?>">Customers</a></li>
                        <li <?php isTabSelected('categories', 'submenuselected', 2); ?>><a href="<?php echo base_url('master/categories'); ?>">Categories</a></li>
                        <li <?php isTabSelected('labortype', 'submenuselected', 2); ?>><a href="<?php echo base_url('master/labortype'); ?>">Labor Type</a></li>
                        <li <?php isTabSelected('users', 'submenuselected', 2); ?>><a href="<?php echo base_url('master/users'); ?>">Users</a></li>
                        <li <?php isTabSelected('ownedvehicle', 'submenuselected', 2); ?>><a href="<?php echo base_url('master/ownedvehicle'); ?>">Owned-Vehicle</a></li>
                        <li <?php isTabSelected('vehicle', 'submenuselected', 2); ?>><a href="<?php echo base_url('master/vehicle'); ?>">Make</a></li>
                        <li <?php isTabSelected('color', 'submenuselected', 2); ?>><a href="<?php echo base_url('master/color'); ?>">Colors</a></li>
                        <li <?php isTabSelected('company', 'submenuselected', 2); ?>><a href="<?php echo base_url('master/company'); ?>">Company</a></li>
                    	</ul>
                    </div>
                </li>
                <li <?php isTabSelected('reports'); ?>><a  href="<?php echo base_url() . 'reports/dcr';?>" >Reports</a>
                	<div  <?php isTabSelected('reports'); ?>>
                        <ul>
                            <li <?php isTabSelected('dcr', 'submenuselected', 2); ?>><a href="<?php echo base_url('reports/dcr'); ?>">Daily Cash Report</a></li>
                            <li <?php isTabSelected('joborderhistory', 'submenuselected', 2); ?>><a href="#">Job Order History</a></li>
                        </ul>
					</div>
                </li>

                <li  <?php isTabSelected('utility'); ?>><a  href="<?php echo base_url() . 'utility/datarecovery';?>" >Utility</a>

                	<div  <?php isTabSelected('utility'); ?>>
                        <ul>
                            <li <?php isTabSelected('backup', 'submenuselected', 3); ?>><a href="<?php echo base_url() . 'utility/datarecovery/backup';?>">Backup Database</a></li>
                            <li <?php isTabSelected('restore', 'submenuselected', 3); ?>><a href="<?php echo base_url() . 'utility/datarecovery/restore';?>">Restore Database</a></li>
                        </ul>
					</div>
                </li>
            </ul>
        </div>