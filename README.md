# Just scan one time and login in a second without username password 

## Flutter web login with qr code

![Screenshot_1659205634](https://user-images.githubusercontent.com/70555095/181936917-51b8041b-212b-476b-ab04-509b77ad1caf.png)

![Screenshot_1659205650](https://user-images.githubusercontent.com/70555095/181936927-9179c431-96db-4c7d-9aec-0656bd2cea21.png)


### Used plugins - 
<code> 
  http 
  qr_flutter
  shared_preferences
</code> 

You can compile for any platform like Web, Windows, Mac, Linux etc. 

## PHP API 
<code> 
<?php 

header("Access-Control_Allow_Origin: *");
header("Access-Control-Allow-Credentials: true");
header("Content-type:application/json;charset=utf-8"); 
header("Access-Control-Allow-Methods: GET,POST");

    $con= mysqli_connect("localhost","username","password","database_name"); 
    
    if(!$con) {
        echo "<script>alert('Database is not connected ')</script>";
    }

if(isset($_GET['session']) && isset($_GET['uid'])) {
    $session = $_GET['session']; 
    $uid = $_GET['uid']; 
    date_default_timezone_set("Asia/Kolkata");
    $date = date("d-m-Y h:i:s A"); 
    $q = mysqli_query("SELECT * FROM `weblogin` WHERE `uid`='$uid' and `status`='Active' "); 
    mysqli_query($con,"UPDATE `weblogin` SET `status`='Logged out' WHERE `uid`='$uid' ");   
    $ins = mysqli_query($con,"INSERT INTO `weblogin` SET `session`='$session',`uid`='$uid',`status`='Active',`date_time`='$date' ");
    
    if($ins) {
        echo "done";
    } else {
        echo "failed";
    }
}

if(isset($_POST['getLogin'])) {
    extract($_POST);
    $session = str_replace("session=","",explode("?",$getLogin)[1]);
    $session = explode("&",$session)[0];
    $q=mysqli_query($con,"SELECT * FROM `weblogin` WHERE `session`='$session' and `status`='Active' order by id desc "); 
    $res =mysqli_fetch_array($q);
     
    if($res!=null) {
        $jsonData1[]=$res;
        echo json_encode($jsonData1); 
    } else {
        echo "failed ". $session. " ".json_encode($jsonData1)  ;
    }
}


if(isset($_POST['getSessionData'])) {
    $session = $_POST['getSessionData']; 
    $uid= $_POST['uid']; 
     $xq = mysqli_query($con,"SELECT * FROM `weblogin` WHERE `uid`='$uid' and `session`='$session' and `status`='Active' "); 
     $data = mysqli_fetch_array($xq); 
     if($data!=null) {
         echo "Active";
     }
}
 

?>
</code>

## Kanai Shil - DEV SEC IT Pvt. Ltd. 
