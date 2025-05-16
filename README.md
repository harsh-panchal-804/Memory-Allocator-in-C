
# Custom Memory Allocator in C

This project is an implementation of a dynamic memory allocator for Unix-like systems, written in C. It provides custom versions of `malloc()`, `calloc()`, `realloc()`, and `free()` using the `sbrk()` system call. Memory blocks are managed using a linked list, and all allocator operations are protected by a global mutex for thread safety.

---

## Getting Started

### Clone the Repository

```sh
git clone https://github.com/harsh-panchal-804/Memory-Allocator-in-C
cd Memory-Allocator-in-C
```


### Compile Using Makefile

```sh
make            # Builds the project (output: main.exe)
make asm        # Builds the Assembly Code for main.c
make clean      # Removes build artifacts
```


---

## Project Overview

The goal of this project is to demonstrate the internal workings of dynamic memory allocation at a low level. The allocator keeps track of memory blocks on the heap, reuses freed blocks when possible, and requests more memory from the operating system as needed. This is a great way to learn about how allocators work under the hood, including how memory fragmentation and thread safety are handled.

---

## Process Memory Layout

A process in a Unix-like operating system has its memory divided into several segments:

- **Text Segment**: Contains the executable code.
- **Data Segment**: Stores initialized global and static variables.
- **BSS Segment**: Holds uninitialized global and static variables.
- **Heap**: Used for dynamic memory allocation (e.g., via `malloc()`). Grows upwards.
- **Stack**: Used for function calls and local variables. Grows downwards.

Here’s a commonly used diagram of the process memory layout:

<img src="https://musingsofagator.wordpress.com/wp-content/uploads/2013/03/virtual-mem-layout.jpg">

The **heap** is where dynamic memory allocation happens. The allocator manages this space, requesting more memory from the OS using `sbrk()` and organizing allocated and freed blocks with a linked list.

---

## How the Code Works

### Memory Block Structure

Each memory block consists of a header (metadata) and the user data. The header contains:

- The size of the block (in bytes)
- A flag indicating whether the block is free or in use
- A pointer to the next block in the linked list
- Padding to ensure proper alignment (typically 16 bytes)

This allows the allocator to efficiently track and manage all blocks on the heap.

### Allocation (`my_malloc`)

1. **Search Free List**: The allocator traverses the linked list to find a free block large enough to satisfy the request.
2. **Reuse or Expand**:
    - If a suitable free block is found, it is marked as used and returned.
    - If not, the allocator requests more memory from the OS using `sbrk()`, creates a new block, and appends it to the list.
3. **Thread Safety**: All operations are wrapped in a mutex lock to prevent race conditions.

### Deallocation (`my_free`)

1. **Mark as Free**: The block is marked as free in the header.
2. **Heap Shrinkage**: If the block is at the end of the heap (i.e., the most recently allocated block), the allocator can shrink the heap using `sbrk()` to actually return memory to the OS.
3. **Reuse**: Otherwise, the block remains available for future allocations.

### Reallocation (`my_realloc`)

- If the current block is large enough, it is reused.
- Otherwise, a new block is allocated, the data is copied over, and the old block is freed.


### Zero-Initialized Allocation (`my_calloc`)

- Allocates memory for an array and sets all bytes to zero.


### Thread Safety

All allocator operations are protected by a global mutex (`pthread_mutex_t`). This ensures that only one thread can modify the allocator's data structures at a time, preventing race conditions and ensuring correctness in multi-threaded programs.

---

## About `sbrk()` and How it Differs from `mmap()`

### `sbrk()`

- `sbrk()` is a system call that moves the program’s "break" (the end of the process’s data segment, i.e., the heap).
- When more memory is needed, `sbrk()` increases the size of the heap, returning a pointer to the start of the new memory.
- Memory allocated with `sbrk()` is always contiguous with the existing heap.
- **Limitation**: Only the last block(s) at the top of the heap can be released back to the OS.


### `mmap()`

- `mmap()` creates new memory mappings anywhere in the process’s address space.
- It is used for large allocations, memory-mapped files, and more.
- Memory allocated with `mmap()` does not have to be contiguous with the heap and can be individually unmapped.
- Modern malloc implementations (like glibc) use `mmap()` for large allocations and `sbrk()` for small ones.

**Summary Table:**


| Feature | `sbrk()` | `mmap()` |
| :-- | :-- | :-- |
| Contiguity | Always contiguous heap | Anywhere in address space |
| Use case | Small/medium allocations | Large allocations, files |
| Release memory | Only from heap end | Any mapped region |
| Usage | Legacy | Modern |


---

## Example Usage

```c
int* arr = (int*) my_malloc(5 * sizeof(int));
for (int i = 0; i < 5; i++) arr[i] = i * 10;
my_free(arr);

int* c_arr = (int*) my_calloc(5, sizeof(int)); // All values zeroed
my_free(c_arr);

char* str = (char*) my_malloc(10);
strcpy(str, "Hi");
str = (char*) my_realloc(str, 20);
strcat(str, " there!");
my_free(str);
```

Sample output:

```
Values in mallocd array:
0 10 20 30 40
Values in callocd array:
0 0 0 0 0
Reallocated string: Hi there!
```


---

## Limitations

- **No block splitting or coalescing:** This can lead to fragmentation and inefficient memory use.
- **Linear search for free blocks:** Allocation can become slow if there are many blocks.
- **No support for alignment beyond 16 bytes.**
- **Only works on Unix-like systems with `sbrk()`.**


---



