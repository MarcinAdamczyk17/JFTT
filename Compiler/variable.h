    typedef struct variable var;
    struct variable{
	bool isArray;
	bool isInitialized;
	int memoryLocation;
	int registerLocation;
	int value;
	char* name;
    };

    typedef struct value val;
    struct value{
	var* variable = nullptr;
	int value = 0;
    };

    typedef struct condition cond;
    struct condition{
	val* val1 = nullptr;
	string op;
	val* val2 = nullptr;
    };
