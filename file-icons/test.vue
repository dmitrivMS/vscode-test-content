<template>
  <div class="search-bar">
    <input
      v-model="query"
      type="text"
      placeholder="Search items..."
      @keyup.enter="search"
    />
    <button @click="search" :disabled="loading">
      {{ loading ? 'Searching...' : 'Search' }}
    </button>
    <ul v-if="results.length">
      <li v-for="item in results" :key="item.id">{{ item.name }}</li>
    </ul>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';

const query = ref('');
const loading = ref(false);
const results = ref<{ id: number; name: string }[]>([]);

async function search() {
  loading.value = true;
  const response = await fetch(`/api/search?q=${encodeURIComponent(query.value)}`);
  results.value = await response.json();
  loading.value = false;
}
</script>

<style scoped>
.search-bar input {
  padding: 0.5rem;
  border: 1px solid #ccc;
  border-radius: 4px;
  margin-right: 0.5rem;
}
</style>
