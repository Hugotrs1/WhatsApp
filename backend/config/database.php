<?php

$maxAttempts = 20;
$attempt = 0;

while (true) {
    try {
        return new PDO(
            'mysql:host=db;dbname=whatsapp;charset=utf8mb4',
            'whatsapp',
            'whatsapp',
            [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_TIMEOUT => 5
            ]
        );
    } catch (PDOException $e) {
        $attempt++;
        if ($attempt >= $maxAttempts) {
            throw new RuntimeException('Database connection failed');
        }
        sleep(1);
    }
}
