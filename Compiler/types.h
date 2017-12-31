#pragma once

#include <string>

class value_t
{
public:
    value_t(bool isArray, bool possibleIterator, int memory_position, std::string name) :
        isArray(isArray),
        possibleIterator(possibleIterator),
        memory_position(memory_position),
        name(name)
    {
    }


    ~value_t()
    {
    }

    bool isArray = false;
    bool possibleIterator = false;
    int capacity;
    int memory_position;

    std::string name;
    
};