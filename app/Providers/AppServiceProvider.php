<?php

namespace App\Providers;

use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;

/**
 * @meta-start
 * @session: 2025-11-25-001
 * @file: app/Providers/AppServiceProvider.php
 * @refs: [ARCH:EVENTS]
 * @changes: Recreated AppServiceProvider to register hub-api rate limiter
 * @doc-update: [ARCH:EVENTS] ADD rate limiter for supervisor API
 * @meta-end
 */
class AppServiceProvider extends ServiceProvider
{
    /**
     * Register application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap application services.
     */
    public function boot(): void
    {
        RateLimiter::for('hub-api', function (Request $request) {
            // Rate limit by token ID (not user ID) to differentiate supervisor instances
            $key = $request->user()?->currentAccessToken()?->id
                ?? $request->user()?->getAuthIdentifier()
                ?? $request->ip();

            return Limit::perMinute(60)->by($key);
        });
    }
}
