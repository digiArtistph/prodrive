<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="description"  content="Prodrive Motowerks" />
    <meta name="keywords"  content="HTML,CSS,XML,JavaScript" />
    <meta name="author"  content="Mugs and Coffee" />
    <meta name="Viewport"  width="devicewidth" />
    <title>Prodrive System</title>
  	<?php getHeader(); ?>

<body>
    <div  id="container">
        <div  id="masthead">
            <ul>
                <li  class="menu-item"><a  href="url1" >menu1</a></li>
                <li  class="menu-item"><a  href="url2" >menu2</a></li>
                <li  class="menu-item"><a  href="url3" >menu3</a></li>
                <li  class="menu-item"><a  href="url4" >menu4</a></li>
            </ul>
        </div>
        
        <div  id="panels">
               <ul>
                <li  class="menu-item"><a  href="http://mail.yahoo.com" >Mail Yahoo</a></li>
                <li  class="menu-item"><a  href="http://gmail.com" >Gmail</a></li>
                <li  class="menu-item"><a  href="http://xu.edu.ph" >XU Mail</a></li>
                <li  class="menu-item"><a  href="htpp://mnc.com" >Alamid Mail</a></li>
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