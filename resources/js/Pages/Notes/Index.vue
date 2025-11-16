<script setup>
import { Head, Link, router } from '@inertiajs/vue3'
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue'
import { TrashIcon, PencilIcon, PlusIcon } from '@heroicons/vue/24/outline'

const props = defineProps({
  notes: Array
})

function deleteNote(noteId) {
  if (confirm('¿Estás seguro de eliminar esta nota?')) {
    router.delete(`/notes/${noteId}`)
  }
}
</script>

<template>
  <Head title="Mis Notas" />

  <AuthenticatedLayout>
    <template #header>
      <div class="flex justify-between items-center">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">
          Mis Notas
        </h2>
        <Link 
          :href="route('notes.create')"
          class="inline-flex items-center px-4 py-2 bg-blue-600 border border-transparent rounded-md font-semibold text-xs text-white uppercase tracking-widest hover:bg-blue-700 focus:bg-blue-700 active:bg-blue-900 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition ease-in-out duration-150"
        >
          <PlusIcon class="w-4 h-4 mr-2" />
          Nueva Nota
        </Link>
      </div>
    </template>

    <div class="py-12">
      <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
        <!-- Empty State -->
        <div v-if="notes.length === 0" class="bg-white overflow-hidden shadow-sm sm:rounded-lg">
          <div class="p-6 text-center text-gray-500">
            <p class="text-lg mb-4">No tienes notas aún</p>
            <Link 
              :href="route('notes.create')"
              class="inline-flex items-center px-4 py-2 bg-blue-600 border border-transparent rounded-md font-semibold text-xs text-white uppercase tracking-widest hover:bg-blue-700"
            >
              <PlusIcon class="w-4 h-4 mr-2" />
              Crear primera nota
            </Link>
          </div>
        </div>

        <!-- Notes Grid -->
        <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <div 
            v-for="note in notes" 
            :key="note.id"
            class="bg-white overflow-hidden shadow-sm sm:rounded-lg hover:shadow-md transition-shadow"
            :class="`border-l-4 border-${note.color}-500`"
          >
            <div class="p-6">
              <!-- Header -->
              <div class="flex justify-between items-start mb-3">
                <h3 
                  v-if="note.title" 
                  class="text-lg font-semibold text-gray-900 truncate flex-1"
                >
                  {{ note.title }}
                </h3>
                <span 
                  v-if="note.is_pinned"
                  class="text-yellow-500 text-xl"
                >
                  📌
                </span>
              </div>

              <!-- Content -->
              <p class="text-gray-600 text-sm mb-4 line-clamp-3">
                {{ note.content }}
              </p>

              <!-- Meta -->
              <div class="flex items-center justify-between text-xs text-gray-500 mb-4">
                <span v-if="note.date">
                  📅 {{ note.formatted_date }}
                </span>
                <span v-if="note.category">
                  🏷️ {{ note.category.name }}
                </span>
              </div>

              <!-- Actions -->
              <div class="flex gap-2">
                <Link 
                  :href="route('notes.edit', note.id)"
                  class="flex-1 inline-flex items-center justify-center px-3 py-2 bg-gray-100 border border-gray-300 rounded-md font-semibold text-xs text-gray-700 uppercase tracking-widest hover:bg-gray-200"
                >
                  <PencilIcon class="w-4 h-4 mr-1" />
                  Editar
                </Link>
                <button
                  @click="deleteNote(note.id)"
                  class="inline-flex items-center px-3 py-2 bg-red-100 border border-red-300 rounded-md font-semibold text-xs text-red-700 uppercase tracking-widest hover:bg-red-200"
                >
                  <TrashIcon class="w-4 h-4" />
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </AuthenticatedLayout>
</template>

<style scoped>
.line-clamp-3 {
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>