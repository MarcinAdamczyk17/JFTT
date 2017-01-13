    typedef struct variable var;
    struct variable{
	bool isArray;
	bool isInitialized;
	int memoryLocation;
	int registerLocation;
	int value;
	char* name;
    };
