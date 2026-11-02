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
