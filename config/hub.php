<?php

return [
    'version' => env('HUB_VERSION', '2.1.0'),
    'sources' => [
        [
            'id' => 'energyapp',
            'type' => 'agent',
            'status' => 'active',
        ],
        [
            'id' => 'mailcow',
            'type' => 'agent',
            'status' => 'active',
        ],
        [
            'id' => 'portfolio',
            'type' => 'agent',
            'status' => 'planned',
        ],
    ],
];
