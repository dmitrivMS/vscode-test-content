#ifndef RING_BUFFER_H
#define RING_BUFFER_H

#include <stddef.h>
#include <stdbool.h>

typedef struct {
	void *buffer;
	size_t capacity;
	size_t element_size;
	size_t head;
	size_t tail;
	size_t count;
} RingBuffer;

RingBuffer *ring_buffer_create(size_t capacity, size_t element_size);
void ring_buffer_destroy(RingBuffer *rb);

bool ring_buffer_push(RingBuffer *rb, const void *element);
bool ring_buffer_pop(RingBuffer *rb, void *element);
bool ring_buffer_peek(const RingBuffer *rb, void *element);

size_t ring_buffer_count(const RingBuffer *rb);
bool ring_buffer_is_empty(const RingBuffer *rb);
bool ring_buffer_is_full(const RingBuffer *rb);
void ring_buffer_clear(RingBuffer *rb);

#endif /* RING_BUFFER_H */
