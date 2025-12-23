<?php

namespace App\Controller;

use App\Core\Response;

class HealthController
{
    public function health(): void
    {
        Response::success([
            'status' => 'ok',
            'service' => 'api',
            'time' => date('c'),
        ]);
    }
}
