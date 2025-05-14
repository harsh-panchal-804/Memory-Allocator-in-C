#include <unistd.h>
#include <string.h>
#include <pthread.h>

#include <stdio.h>
typedef char ALIGN[16];


union header{
    struct{
        size_t size;
        unsigned is_free;
        union header* next;
    }s;
    ALIGN stub;
};
typedef union header header_t;
header_t *head=NULL,*tail=NULL;

pthread_mutex_t global_malloc_lock = PTHREAD_MUTEX_INITIALIZER;



header_t * get_free_block(size_t size){
    header_t * curr = head;
    while(curr){
        if(curr->s.is_free && curr->s.size >= size){
            return curr;
        }
        curr=curr->s.next;
    }
    return NULL;
}
void * my_malloc(size_t size){
    size_t totalsize;
    void * block;
    header_t * header;
    if(!size){
        return NULL;
    }
    pthread_mutex_lock(&global_malloc_lock);
    header=get_free_block(size);
    if(header){
        header->s.is_free=0;
        pthread_mutex_unlock(&global_malloc_lock);
        return (void *) (header+1);
    }
    totalsize=size + sizeof(header_t);
    block=sbrk(totalsize);
    if(block == (void *)-1){
        pthread_mutex_unlock(&global_malloc_lock);
        return NULL;
    }
    header=block;
    header->s.is_free=0;
    header->s.size=size;
    header->s.next=NULL;
    if(!head){
        head=header;
    }
    if(tail){
        tail->s.next=header; //// this new block is after our current tail due to nature of 
                             //// sbrk and the heap (it only grows unidirectional)
    }
    tail=header;
     pthread_mutex_unlock(&global_malloc_lock);
    return (void*) (header+1);
}
void * my_calloc(size_t num,size_t nsize){
    size_t size;
    void* block;
    if(!num || !nsize){
        return NULL;
    }
    size=nsize*num;///check for overflow
    if(nsize != size/num){
        return NULL;
    }
    block=my_malloc(size);
    if(!block){
        return NULL;
    }
    memset(block,0,size);
    return block;
}
void  my_free(void * block){
    header_t * header,*tmp;
    void * program_break;
    if(!block)return ;
    pthread_mutex_lock(&global_malloc_lock);
    header=(header_t*)block -1;
    program_break=sbrk(0);
    if( (char*)block +header->s.size == program_break){
        if(head==tail){
            head=tail=NULL;
        }
        else{
            tmp=head;
            while(tmp && tmp->s.next){
                if(tmp->s.next==tail){
                    tmp->s.next=NULL;
                    tail=tmp;
                    break;
                }
                tmp=tmp->s.next;

            }
        }
        sbrk(0-sizeof(header_t)-header->s.size);
        pthread_mutex_unlock(&global_malloc_lock);
        return;
    }
    header->s.is_free=1;
    pthread_mutex_unlock(&global_malloc_lock);
}

void * my_realloc(void * block,size_t size){
    header_t * header;
    void * ret;
    if(!block || !size){
        return my_malloc(size);
    }
    header=(header_t*)block -1;
    if(header->s.size>=size)return block;
    ret = my_malloc(size);
    if(ret){
        memcpy(ret,block,header->s.size);
        my_free(block);
    }
    return ret;
}




int main() {
    // pthread_mutex_init(&global_malloc_lock, NULL);

    int* arr = (int*) my_malloc(5 * sizeof(int));
    if (arr == NULL) {
        printf("Allocation failed\n");
        return 1;
    }

    for (int i = 0; i < 5; i++) {
        arr[i] = i * 10;
    }

    printf("Values in mallocd array:\n");
    for (int i = 0; i < 5; i++) {
        printf("%d ", arr[i]);
    }
    printf("\n");

    my_free(arr);

    // calloc test
    int* c_arr = (int*) my_calloc(5, sizeof(int));
    if (c_arr) {
        printf("Values in callocd array:\n");
        for (int i = 0; i < 5; i++) {
            printf("%d ", c_arr[i]); // should all be zero
        }
        printf("\n");
        my_free(c_arr);
    }

    // realloc test
    char* str = (char*) my_malloc(10);
    strcpy(str, "Hi");
    str = (char*) my_realloc(str, 2);
    strcat(str, " there!");
    printf("Reallocated string: %s\n", str);
    my_free(str);

    pthread_mutex_destroy(&global_malloc_lock);
    return 0;
}

