#pragma once

#include <string>

class value_t
{
public:
    value_t(bool isArray, bool forIterator, int memory_position, std::string name) :
        isArray(isArray),
        forIterator(forIterator),
        memory_position(memory_position),
        name(name)
    {
    }


    ~value_t()
    {
    }

    bool isArray = false;
    bool forIterator = false;
    bool possibleForIterator = false;
    int capacity;
    int memory_position;

    std::string name;
    
};