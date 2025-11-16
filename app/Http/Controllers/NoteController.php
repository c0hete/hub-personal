<?php

namespace App\Http\Controllers;

use App\Models\Note;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;
use Illuminate\Http\RedirectResponse;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;  

/**
 * @meta-start
 * @session: 2025-11-16-003
 * @file: app/Http/Controllers/NoteController.php
 * @refs: [ARCH:FOLDERS]
 * @changes: Added AuthorizesRequests trait for authorization
 * @doc-update: [ARCH:FOLDERS] MODIFY NoteController ADD AuthorizesRequests trait
 * @meta-end
 */

class NoteController extends Controller
{
    use AuthorizesRequests;  

    /**
     * Mostrar lista de notas del usuario
     */
    public function index(): Response
    {
        $notes = Note::with('tags', 'category')
            ->where('user_id', auth()->id())
            ->orderByDesc('is_pinned')
            ->latest()
            ->get();

        return Inertia::render('Notes/Index', [
            'notes' => $notes,
        ]);
    }

    /**
     * Mostrar formulario de creación
     */
    public function create(): Response
    {
        return Inertia::render('Notes/Create');
    }

    /**
     * Guardar nueva nota
     */
    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'title' => 'nullable|string|max:200',
            'content' => 'required|string',
            'date' => 'nullable|date',
            'time' => 'nullable|date_format:H:i',
            'is_pinned' => 'boolean',
            'color' => 'nullable|string|max:20',
            'priority' => 'nullable|string|in:low,medium,high',
            'category_id' => 'nullable|exists:categories,id',
        ]);

        $note = auth()->user()->notes()->create($validated);

        return redirect()
            ->route('notes.index')
            ->with('success', 'Nota creada exitosamente');
    }

    /**
     * Mostrar nota específica
     */
    public function show(Note $note): Response
    {
        // Verificar autorización
        $this->authorize('view', $note);

        $note->load('tags', 'category');

        return Inertia::render('Notes/Show', [
            'note' => $note,
        ]);
    }

    /**
     * Mostrar formulario de edición
     */
    public function edit(Note $note): Response
    {
        $this->authorize('update', $note);

        return Inertia::render('Notes/Edit', [
            'note' => $note,
        ]);
    }

    /**
     * Actualizar nota
     */
    public function update(Request $request, Note $note): RedirectResponse
    {
        $this->authorize('update', $note);

        $validated = $request->validate([
            'title' => 'nullable|string|max:200',
            'content' => 'required|string',
            'date' => 'nullable|date',
            'time' => 'nullable|date_format:H:i',
            'is_pinned' => 'boolean',
            'color' => 'nullable|string|max:20',
            'priority' => 'nullable|string|in:low,medium,high',
            'category_id' => 'nullable|exists:categories,id',
        ]);

        $note->update($validated);

        return redirect()
            ->route('notes.index')
            ->with('success', 'Nota actualizada exitosamente');
    }

    /**
     * Eliminar nota (soft delete)
     */
    public function destroy(Note $note): RedirectResponse
    {
        $this->authorize('delete', $note);

        $note->delete();

        return redirect()
            ->route('notes.index')
            ->with('success', 'Nota eliminada exitosamente');
    }
}