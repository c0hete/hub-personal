/**
 * @meta-start
 * @session: 2025-11-24-001
 * @file: resources/js/components/ui/Dialog.vue
 * @refs: [DESIGN:COMPONENTS]
 * @changes: Created Dialog component using Radix Vue
 * @doc-update: [DESIGN:COMPONENTS] ADD Dialog.vue modal component with accessibility
 * @meta-end
 */

<script setup lang="ts">
import { ref, computed } from 'vue'
import * as Dialog from 'radix-vue'
import { cn } from '@/lib/utils'

interface Props {
  open?: boolean
  defaultOpen?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  open: undefined,
  defaultOpen: false,
})

const emit = defineEmits<{
  (e: 'openChange', value: boolean): void
}>()

const isOpen = computed({
  get: () => props.open ?? undefined,
  set: (value) => {
    if (value !== props.open) {
      emit('openChange', value)
    }
  },
})
</script>

<template>
  <Dialog.Root v-model:open="isOpen" :default-open="defaultOpen">
    <slot />
  </Dialog.Root>
</template>

---

<script setup lang="ts">
import * as Dialog from 'radix-vue'
</script>

<template>
  <Dialog.Trigger v-bind="$attrs">
    <slot />
  </Dialog.Trigger>
</template>

---

<script setup lang="ts">
import * as Dialog from 'radix-vue'
import { cn } from '@/lib/utils'
</script>

<template>
  <Dialog.Portal>
    <Dialog.Overlay :class="cn('fixed inset-0 z-50 bg-black/80')">
      <Dialog.Content
        :class="cn(
          'fixed left-[50%] top-[50%] z-50 grid w-full max-w-lg translate-x-[-50%] translate-y-[-50%] gap-4',
          'border border-slate-200 bg-white p-6 shadow-lg duration-200 data-[state=open]:animate-in',
          'data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0',
          'data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95',
          'data-[state=closed]:slide-out-to-left-1/2 data-[state=closed]:slide-out-to-top-[48%]',
          'data-[state=open]:slide-in-from-left-1/2 data-[state=open]:slide-in-from-top-[48%]',
          'sm:rounded-lg dark:border-slate-800 dark:bg-slate-950'
        )"
      >
        <slot />
        <Dialog.Close :class="cn('absolute right-4 top-4 rounded-sm opacity-70 ring-offset-white',
          'transition-opacity hover:opacity-100 focus:outline-none focus:ring-2',
          'focus:ring-slate-950 focus:ring-offset-2 disabled:pointer-events-none',
          'dark:ring-offset-slate-950 dark:focus:ring-slate-300')" />
      </Dialog.Content>
    </Dialog.Overlay>
  </Dialog.Portal>
</template>
