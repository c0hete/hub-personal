#!/usr/bin/env php
<?php

/**
 * Generate Sanctum token for agent testing
 * Usage: php generate-agent-token.php <agent-name>
 */

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

$agentName = $argv[1] ?? 'test-agent';
$env = $argv[2] ?? 'dev';

$user = App\Models\User::first();

if (!$user) {
    echo "Error: No user found in database\n";
    exit(1);
}

$tokenName = "{$agentName}-{$env}";
$token = $user->createToken($tokenName, ['hub:write']);

echo "\n";
echo "✅ Token generated successfully\n";
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
echo "Agent:  {$agentName}\n";
echo "Env:    {$env}\n";
echo "Scope:  hub:write\n";
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
echo "Token:  {$token->plainTextToken}\n";
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
echo "\n";
echo "💾 Save this token in your agent's .env:\n";
echo "HUB_API_TOKEN={$token->plainTextToken}\n";
echo "\n";
