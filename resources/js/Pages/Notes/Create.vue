<script setup>
import { Head, useForm } from '@inertiajs/vue3'
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue'
import InputError from '@/Components/InputError.vue'
import InputLabel from '@/Components/InputLabel.vue'
import PrimaryButton from '@/Components/PrimaryButton.vue'
import TextInput from '@/Components/TextInput.vue'

const form = useForm({
  title: '',
  content: '',
  date: null,
  time: null,
  is_pinned: false,
  color: 'yellow',
  priority: 'medium',
  category_id: null,
})

const submit = () => {
  form.post(route('notes.store'), {
    onSuccess: () => form.reset(),
  })
}
</script>

<template>
  <Head title="Nueva Nota" />

  <AuthenticatedLayout>
    <template #header>
      <h2 class="font-semibold text-xl text-gray-800 leading-tight">
        Nueva Nota
      </h2>
    </template>

    <div class="py-12">
      <div class="max-w-2xl mx-auto sm:px-6 lg:px-8">
        <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg">
          <form @submit.prevent="submit" class="p-6 space-y-6">
            <!-- Title -->
            <div>
              <InputLabel for="title" value="Título (opcional)" />
              <TextInput
                id="title"
                v-model="form.title"
                type="text"
                class="mt-1 block w-full"
                placeholder="Título de la nota..."
              />
              <InputError class="mt-2" :message="form.errors.title" />
            </div>

            <!-- Content -->
            <div>
              <InputLabel for="content" value="Contenido *" />
              <textarea
                id="content"
                v-model="form.content"
                rows="8"
                class="mt-1 block w-full border-gray-300 focus:border-indigo-500 focus:ring-indigo-500 rounded-md shadow-sm"
                placeholder="Escribe tu nota aquí..."
                required
              ></textarea>
              <InputError class="mt-2" :message="form.errors.content" />
            </div>

            <!-- Date & Time (optional) -->
            <div class="grid grid-cols-2 gap-4">
              <div>
                <InputLabel for="date" value="Fecha (opcional)" />
                <TextInput
                  id="date"
                  v-model="form.date"
                  type="date"
                  class="mt-1 block w-full"
                />
                <InputError class="mt-2" :message="form.errors.date" />
              </div>

              <div>
                <InputLabel for="time" value="Hora (opcional)" />
                <TextInput
                  id="time"
                  v-model="form.time"
                  type="time"
                  class="mt-1 block w-full"
                />
                <InputError class="mt-2" :message="form.errors.time" />
              </div>
            </div>

            <!-- Priority & Color -->
            <div class="grid grid-cols-2 gap-4">
              <div>
                <InputLabel for="priority" value="Prioridad" />
                <select
                  id="priority"
                  v-model="form.priority"
                  class="mt-1 block w-full border-gray-300 focus:border-indigo-500 focus:ring-indigo-500 rounded-md shadow-sm"
                >
                  <option value="low">Baja</option>
                  <option value="medium">Media</option>
                  <option value="high">Alta</option>
                </select>
                <InputError class="mt-2" :message="form.errors.priority" />
              </div>

              <div>
                <InputLabel for="color" value="Color" />
                <select
                  id="color"
                  v-model="form.color"
                  class="mt-1 block w-full border-gray-300 focus:border-indigo-500 focus:ring-indigo-500 rounded-md shadow-sm"
                >
                  <option value="yellow">Amarillo</option>
                  <option value="blue">Azul</option>
                  <option value="green">Verde</option>
                  <option value="pink">Rosa</option>
                  <option value="purple">Púrpura</option>
                </select>
                <InputError class="mt-2" :message="form.errors.color" />
              </div>
            </div>

            <!-- Pin -->
            <div class="flex items-center">
              <input
                id="is_pinned"
                v-model="form.is_pinned"
                type="checkbox"
                class="rounded border-gray-300 text-indigo-600 shadow-sm focus:ring-indigo-500"
              />
              <label for="is_pinned" class="ml-2 text-sm text-gray-600">
                📌 Fijar nota
              </label>
            </div>

            <!-- Actions -->
            <div class="flex items-center justify-end gap-4">
              
           <Link
  :href="route('notes.index')"
  class="text-sm text-gray-600 hover:text-gray-900"
>
  Cancelar
</Link>

              <PrimaryButton :disabled="form.processing">
                {{ form.processing ? 'Guardando...' : 'Guardar Nota' }}
              </PrimaryButton>
            </div>
          </form>
        </div>
      </div>
    </div>
  </AuthenticatedLayout>
</template>