<?php
// File: app/Http/Controllers/NoteController.php

namespace App\Http\Controllers;

use App\Models\Note;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;
use Illuminate\Http\RedirectResponse;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;

/**
 * @meta-start
 * @session: 2025-11-16-002
 * @file: app/Http/Controllers/NoteController.php
 * @refs: [PRD:NOTES_SYSTEM, PRD:TAGS]
 * @changes: Updated store, update, and edit methods to handle tags
 * @doc-update: [PRD:NOTES_SYSTEM] MODIFY store() to support tag creation and attachment
 * @doc-update: [PRD:NOTES_SYSTEM] MODIFY update() to support tag updates
 * @doc-update: [PRD:NOTES_SYSTEM] MODIFY edit() to load tags for editing
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
            'tag_ids' => 'nullable|array',
            'tag_ids.*' => 'exists:tags,id',
            'new_tags' => 'nullable|array',
            'new_tags.*' => 'string|max:100',
        ]);

        // Crear nota
        $note = auth()->user()->notes()->create([
            'title' => $validated['title'] ?? null,
            'content' => $validated['content'],
            'date' => $validated['date'] ?? null,
            'time' => $validated['time'] ?? null,
            'is_pinned' => $validated['is_pinned'] ?? false,
            'color' => $validated['color'] ?? 'yellow',
            'priority' => $validated['priority'] ?? 'medium',
            'category_id' => $validated['category_id'] ?? null,
        ]);

        // Procesar tags
        $tagIds = [];

        // Tags existentes
        if (!empty($validated['tag_ids'])) {
            $tagIds = array_merge($tagIds, $validated['tag_ids']);
        }

        // Crear tags nuevos
        if (!empty($validated['new_tags'])) {
            foreach ($validated['new_tags'] as $tagName) {
                // Verificar si ya existe
                $tag = auth()->user()->tags()
                    ->where('name', $tagName)
                    ->first();

                if (!$tag) {
                    // Crear nuevo tag
                    $tag = auth()->user()->tags()->create([
                        'name' => $tagName,
                        'color' => $this->getRandomColor(),
                    ]);
                }

                $tagIds[] = $tag->id;
            }
        }

        // Asociar tags a la nota
        if (!empty($tagIds)) {
            $note->tags()->sync($tagIds);
        }

        return redirect()->route('notes.index')
            ->with('success', 'Note created successfully');
    }

    /**
     * Mostrar nota específica
     */
    public function show(Note $note): Response
    {
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

        $note->load('tags', 'category');

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
            'tag_ids' => 'nullable|array',
            'tag_ids.*' => 'exists:tags,id',
            'new_tags' => 'nullable|array',
            'new_tags.*' => 'string|max:100',
        ]);

        // Actualizar nota
        $note->update([
            'title' => $validated['title'] ?? null,
            'content' => $validated['content'],
            'date' => $validated['date'] ?? null,
            'time' => $validated['time'] ?? null,
            'is_pinned' => $validated['is_pinned'] ?? false,
            'color' => $validated['color'] ?? 'yellow',
            'priority' => $validated['priority'] ?? 'medium',
            'category_id' => $validated['category_id'] ?? null,
        ]);

        // Procesar tags
        $tagIds = [];

        // Tags existentes
        if (!empty($validated['tag_ids'])) {
            $tagIds = array_merge($tagIds, $validated['tag_ids']);
        }

        // Crear tags nuevos
        if (!empty($validated['new_tags'])) {
            foreach ($validated['new_tags'] as $tagName) {
                // Verificar si ya existe
                $tag = auth()->user()->tags()
                    ->where('name', $tagName)
                    ->first();

                if (!$tag) {
                    // Crear nuevo tag
                    $tag = auth()->user()->tags()->create([
                        'name' => $tagName,
                        'color' => $this->getRandomColor(),
                    ]);
                }

                $tagIds[] = $tag->id;
            }
        }

        // Sincronizar tags
        $note->tags()->sync($tagIds);

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

    /**
     * Helper para generar color aleatorio para tags
     */
    private function getRandomColor(): string
    {
        $colors = ['blue', 'green', 'yellow', 'red', 'purple', 'pink', 'indigo'];
        return $colors[array_rand($colors)];
    }
}