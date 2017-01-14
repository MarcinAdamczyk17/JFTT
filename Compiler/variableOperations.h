var* createVariable(){
    var* variable = (var*) malloc(sizeof(var*));
    variable->name = (char*) malloc(sizeof(char)*20);
    variable->isArray = false;
    variable->isInitialized = false;
    return variable;
}

void declareVariable(char* name){
    //cout << "variable: '" << name << "' declaration" << endl;
    if(checkIfAlreadyDeclared(name)){
	cout << " error: variable '" << name << "' already declared" << endl;
    }
    var* variable = createVariable();
    variable->name = name;
    variable->isArray = false;
    variable->name = name;

    variable->memoryLocation = variablesContainer.size();
    variablesContainer.push_back(variable);

}

void declareArray(char* name, int size){
    if(checkIfAlreadyDeclared(name)){
	cout << "error: array " << name << " already declared" << endl;
    }
    var* variable = createVariable();
    variable->isArray = true;
    variable->name = name;
    variable->value = size;

    variablesContainer.push_back(variable);
    for(int i = 0; i < size; ++i){
	var* temp = createVariable();
	variablesContainer.push_back(temp);
    }

}

void initializeVariable(char* name, int value){
    var* variable = getVariable(name);

    if(variable == nullptr){
	cout << "error: variable " << name << " not declared" << endl;
	return;
    }
    variable->value = value;
    variable->isInitialized = true;
}

var* getVariable(char* name){

    for(var* variable : variablesContainer){
	if(!strcmp(name, variable->name)){
	    return variable;
	}
    }
    cout << "variable '" << name << "' not declared;" <<endl;
    return nullptr;
}

int getVariableValue(char* name){
    var* variable = getVariable(name);

    if(variable == nullptr){
	cout << "error: variable " << name << " not declared" << endl;
	return 0;
    }
    if(!variable->isInitialized){
	cout << "error: variable " << name << " not initialized" << endl;
	return 0;
    }

    return variable->value;
}

int getArrayVariableValue(char* name, int position){
    var* array = getVariable(name);
    if(array == nullptr){
	cout << "error: variable '" << name << "' not declared" << endl;
	return 0;
    }
    if(position >= array->value){
	cout << "error: array '" << name << "': out of bound exception" << endl;
	return 0;
    }
    if(!array->isArray){
	cout << "error: '" << name << "' is not an array" << endl;
	return 0;
    }

    int i = 0;
    for(var* variable : variablesContainer){
	if(!strcmp(name, variable->name)){
	    break;
	}
	i++;
    }

    if(!variablesContainer[i+position+1]->isInitialized){
	cout << "error: " << name << "[" << position <<"] is not initialized" << endl;
    }
    return variablesContainer[i+position+1]->value;
}

var* getArrayVariable(char* name, int position){
    var* array = getVariable(name);
    if(array == nullptr){
	cout << "error: variable '" << name << "' not declared" << endl;
	return 0;
    }
    if(position >= array->value){
	cout << "error: array '" << name << "': out of bound exception" << endl;
	return 0;
    }
    if(!array->isArray){
	cout << "error: '" << name << "' is not an array" << endl;
	return 0;
    }

    int i = 0;
    for(var* variable : variablesContainer){
	if(!strcmp(name, variable->name)){
	    break;
	}
	i++;
    }

    return variablesContainer[i+position+1];
}

void initializeArrayVariable(char* name, int position, int value){
    var* array = getVariable(name);
    if(array == nullptr){
	cout << "error: variable '" << name << "' not declared" << endl;
	return;
    }
    if(position >= array->value){
	cout << "error: array '" << name << "': out of bound exception" << endl;
	return;
    }
    if(!array->isArray){
	cout << "error: '" << name << "' is not an array" << endl;
	return;
    }

    int i = 0;
    for(var* variable : variablesContainer){
	if(!strcmp(name, variable->name)){
	    break;
	}
	i++;
    }

    variablesContainer[i+position+1]->value = value;
    variablesContainer[i+position+1]->isInitialized = true;
}

bool checkIfAlreadyDeclared(char* name){
    for(var* variable : variablesContainer){
	if(!strcmp(name, variable->name)){
	    return true;
	}
    }
    return false;
}
