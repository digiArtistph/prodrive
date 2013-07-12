<div class="wrapper">
<h3 class="heading">Dupliate Record</h3>
	<?php if($owner != ""): ?>
	<p><?php echo "Plate no <span class='error'>$plateNo</span> is already assigned to <span class='error'>$owner</span>. " . anchor(base_url('master/ownedvehicle'), 'Go back');	?></p>
    
    <?php else: ?>
    	<p><?php echo "Plate no <span class='error'>$plateNo</span> is already assigned to someone else. " . anchor(base_url('master/ownedvehicle/section/addownedvehicle'), 'Try another plate no.');	?></p>
    <?php endif; ?>
</div>