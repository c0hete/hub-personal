<?php

namespace App\Providers;

use App\Models\Note;
use App\Policies\NotePolicy;
use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;

/**
 * @meta-start
 * @session: 2025-11-16-001
 * @file: app/Providers/AuthServiceProvider.php
 * @refs: [AUTH:POLICY]
 * @changes: Created AuthServiceProvider and registered NotePolicy
 * @doc-update: [AUTH:POLICY] ADD AuthServiceProvider created with NotePolicy registration
 * @meta-end
 */

class AuthServiceProvider extends ServiceProvider
{
    /**
     * The policy mappings for the application.
     *
     * @var array<class-string, class-string>
     */
    protected $policies = [
        Note::class => NotePolicy::class,
    ];

    /**
     * Register any authentication / authorization services.
     */
    public function boot(): void
    {
        //
    }
}