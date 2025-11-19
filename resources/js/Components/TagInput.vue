<!-- File: resources/js/Components/TagInput.vue -->

<script setup>
import { ref, computed, watch } from 'vue'
import { useDebounceFn } from '@vueuse/core'
import { XMarkIcon } from '@heroicons/vue/20/solid'

/**
 * @meta-start
 * @session: 2025-11-16-002
 * @file: resources/js/Components/TagInput.vue
 * @refs: [PRD:TAGS, DESIGN:COMPONENTS]
 * @changes: Created TagInput component with autocomplete and debounce
 * @doc-update: [DESIGN:COMPONENTS] ADD TagInput.vue with autocomplete for tags
 * @meta-end
 */

// Props
const props = defineProps({
  modelValue: {
    type: Array,
    default: () => []
  },
  maxTags: {
    type: Number,
    default: 20
  }
})

// Emits
const emit = defineEmits(['update:modelValue'])

// State
const searchQuery = ref('')
const suggestions = ref([])
const showSuggestions = ref(false)
const isSearching = ref(false)

// Computed
const selectedTags = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const canAddMore = computed(() => selectedTags.value.length < props.maxTags)

const filteredSuggestions = computed(() => {
  // Filtrar tags ya seleccionados
  const selectedIds = selectedTags.value.map(t => t.id)
  return suggestions.value.filter(s => !selectedIds.includes(s.id))
})

// Methods
async function searchTags(query) {
  if (!query || query.length < 1) {
    suggestions.value = []
    showSuggestions.value = false
    return
  }

  isSearching.value = true
  
  try {
    const response = await fetch(`/tags/search?q=${encodeURIComponent(query)}`)
    const data = await response.json()
    suggestions.value = data
    showSuggestions.value = true
  } catch (error) {
    console.error('Error searching tags:', error)
    suggestions.value = []
  } finally {
    isSearching.value = false
  }
}

// Debounced search (300ms)
const debouncedSearch = useDebounceFn((query) => {
  searchTags(query)
}, 300)

// Watch search query
watch(searchQuery, (newQuery) => {
  debouncedSearch(newQuery)
})

function selectTag(tag) {
  if (!canAddMore.value) return
  
  // Agregar tag a seleccionados
  selectedTags.value = [...selectedTags.value, tag]
  
  // Limpiar búsqueda
  searchQuery.value = ''
  suggestions.value = []
  showSuggestions.value = false
}

function removeTag(tagId) {
  selectedTags.value = selectedTags.value.filter(t => t.id !== tagId)
}

function createNewTag() {
  if (!searchQuery.value.trim() || !canAddMore.value) return
  
  // Crear tag nuevo (sin ID, el backend lo asignará)
  const newTag = {
    id: `new_${Date.now()}`, // ID temporal
    name: searchQuery.value.trim(),
    color: getRandomColor(),
    isNew: true // Flag para identificar tags nuevos
  }
  
  selectedTags.value = [...selectedTags.value, newTag]
  
  // Limpiar
  searchQuery.value = ''
  suggestions.value = []
  showSuggestions.value = false
}

function getRandomColor() {
  const colors = ['blue', 'green', 'yellow', 'red', 'purple', 'pink', 'indigo']
  return colors[Math.floor(Math.random() * colors.length)]
}

function handleClickOutside(event) {
  if (!event.target.closest('.tag-input-container')) {
    showSuggestions.value = false
  }
}

// Lifecycle
import { onMounted, onUnmounted } from 'vue'

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})
</script>

<template>
  <div class="tag-input-container">
    <!-- Selected tags -->
    <div v-if="selectedTags.length > 0" class="flex flex-wrap gap-2 mb-3">
      <div
        v-for="tag in selectedTags"
        :key="tag.id"
        class="inline-flex items-center gap-1 px-3 py-1 rounded-full text-sm"
        :class="{
          'bg-blue-100 text-blue-800': tag.color === 'blue',
          'bg-green-100 text-green-800': tag.color === 'green',
          'bg-yellow-100 text-yellow-800': tag.color === 'yellow',
          'bg-red-100 text-red-800': tag.color === 'red',
          'bg-purple-100 text-purple-800': tag.color === 'purple',
          'bg-pink-100 text-pink-800': tag.color === 'pink',
          'bg-indigo-100 text-indigo-800': tag.color === 'indigo',
          'bg-gray-100 text-gray-800': !tag.color,
        }"
      >
        <span>{{ tag.name }}</span>
        <button
          type="button"
          @click="removeTag(tag.id)"
          class="hover:bg-black/10 rounded-full p-0.5"
        >
          <XMarkIcon class="w-4 h-4" />
        </button>
      </div>
    </div>

    <!-- Input -->
    <div class="relative">
      <input
        v-model="searchQuery"
        type="text"
        placeholder="Search or create tags..."
        :disabled="!canAddMore"
        class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent disabled:bg-gray-100 disabled:cursor-not-allowed"
        @focus="showSuggestions = suggestions.length > 0"
      />

      <!-- Max tags warning -->
      <div v-if="!canAddMore" class="mt-2 text-sm text-red-600">
        Maximum {{ maxTags }} tags reached
      </div>

      <!-- Suggestions dropdown -->
      <div
        v-if="showSuggestions && filteredSuggestions.length > 0"
        class="absolute z-10 w-full mt-1 bg-white border border-gray-300 rounded-lg shadow-lg max-h-60 overflow-y-auto"
      >
        <button
          v-for="tag in filteredSuggestions"
          :key="tag.id"
          type="button"
          @click="selectTag(tag)"
          class="w-full px-4 py-2 text-left hover:bg-gray-100 flex items-center gap-2"
        >
          <span
            class="w-3 h-3 rounded-full"
            :class="{
              'bg-blue-500': tag.color === 'blue',
              'bg-green-500': tag.color === 'green',
              'bg-yellow-500': tag.color === 'yellow',
              'bg-red-500': tag.color === 'red',
              'bg-purple-500': tag.color === 'purple',
              'bg-pink-500': tag.color === 'pink',
              'bg-indigo-500': tag.color === 'indigo',
              'bg-gray-500': !tag.color,
            }"
          ></span>
          <span>{{ tag.name }}</span>
        </button>
      </div>

      <!-- Create new tag option -->
      <div
        v-if="searchQuery.trim() && filteredSuggestions.length === 0 && !isSearching && canAddMore"
        class="absolute z-10 w-full mt-1 bg-white border border-gray-300 rounded-lg shadow-lg"
      >
        <button
          type="button"
          @click="createNewTag"
          class="w-full px-4 py-2 text-left hover:bg-gray-100 text-blue-600"
        >
          Create tag "{{ searchQuery }}"
        </button>
      </div>

      <!-- Loading -->
      <div
        v-if="isSearching"
        class="absolute z-10 w-full mt-1 bg-white border border-gray-300 rounded-lg shadow-lg"
      >
        <div class="px-4 py-2 text-gray-500">Searching...</div>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* Estilos manejados por Tailwind en clases */
</style>