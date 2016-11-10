#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define FREE(T) do { free (T); T = NULL; } while (0)

typedef struct listNode node;
typedef struct list List;

struct listNode{
    int value;
    node* next;
};

struct list{
    node* head;
    node* tail;
    int size;
};

List* create(){
    List* list = (List*) malloc(sizeof(List*));
    list->head = NULL;
    list->tail = NULL;
    list->size = 0;
    return list;
}

void enqueueHead(List* list, int value){
    node* element = (node*) malloc(sizeof(node*));
    element->value = value;

    if(list->size == 0){
        list->head = element;
        list->tail = element;
        element->next = NULL;
    }
    else{
        element->next = list->head;
        list->head = element;
    }

    ++list->size;
}

void enqueueTail(List* list, int value){
    node* element = (node*) malloc(sizeof(node*));
    element->value = value;

    if(list->size == 0){
        list->head = element;
        list->tail = element;
        element->next = NULL;
    }
    else{
        list->tail->next = element;
        list->tail = element;
    }

    ++list->size;
}

int dequeueHead(List* list){
    if(list->size > 1){
        int value = list->head->value;
        node* temp = list->head;

        list->head = temp->next;
        FREE(temp);
        --list->size;
        return value;
    }else if(list->size == 1){
        int value = list->head->value;
        FREE(list->head);
        --list->size;
        return value;
    }
    else{
        printf("\nDequeue error: queue empty\n");
        return -1;
    }
}

int dequeueTail(List* list){
    if(list->size > 1){
        node* temp = list->head;
        int i;
        for(i = 1; i < list->size - 1; ++i){
            temp = temp->next;
        }
        int value = temp->next->value;
        FREE(temp->next);
        list->tail = temp;
        --list->size;
        return value;
    }
    else if(list->size == 1){
        int value = list->head->value;
        FREE(list->head);
        --list->size;
        return value;
    }
    else{
        printf("\nDequeue error: queue empty\n");
        return -1;
    }
}

int getValue(List* list, int position){
    if(position > list->size || position < 1){
        printf("wrong position indicator\n");
        return -1;
    }
    int i;
    node* element = list->head;
    for(i = 1; i < position; i++){
        element = element->next;
    }

    return element->value;
}

void empty(List* list){
    node* element;
    while(list->size > 1){
        element = list->head;
        list->head = list->head->next;
        FREE(element);
        --list->size;
    }
    FREE(element);
    --list->size;
}

void destroy(List* list){
    if(list->size > 0){
        empty(list);
    }
    FREE(list);
    list->head = NULL;
}

int search(List* list, int value){
    int position = 1;
    node* element = list->head;

    while(element != list->tail){
        if(value == element->value){
            printf("searching success. Value %d found on position: %d\n",value, position);
            return position;
        }
        element = element->next;
        ++position;
    }

    if(value == element->value){
        printf("searching success. Value %d found on position: %d\n",value, position);
        return position;
    }
    else{
        printf("Searching failed. Returning value 0\n");
        return 0;
    }


}


void merge(List* list1, List* list2){
    printf("merging\n");
    list1->tail->next = list2->head;
    list1->size += list2->size;
    list1->tail = list2->tail;
    list2->head = NULL;
    list2->tail = NULL;
    FREE(list2);
}
