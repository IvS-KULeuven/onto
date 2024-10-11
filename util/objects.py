from util import logger

# global object store
OBJECTS = {}

def add_global(name, obj):
    global OBJECTS
    OBJECTS[name] = obj

def get_global(name):
    global OBJECTS
    return OBJECTS[name]

def resolve(subject, context):
    #print(f"Resolving {subject}, context {context}")
    if isinstance(subject, str):
        obj = None
        parts = subject.split('.')
        if len(parts) > 1:
            return resolve( subject[len(f"{parts[0]}."):], resolve(parts[0], context) )

        if context is not None:
            try:
                return context.get_child(subject)
            except:
                pass
    
        global OBJECTS
        if subject in OBJECTS:
            return OBJECTS[subject]
        
        raise KeyError(f"Subject '{subject}' was not declared before!")
    
    elif isinstance(subject, Object):
        subject.resolve_children(context)
        return subject
    else:
        raise Exception(f"Resolve subject {subject} is unsupported")



class Object:
    def __init__(self, name, parent) -> None:
        self.name = name
        self.parent = parent
        self.children = {}
        self.resolved = False
        global OBJECTS
        if name is not None:
            if parent is None:
                OBJECTS[name] = self
            else:
                self.parent.register_child(name, self)
                OBJECTS[f"{parent.name}.{name}"] = self
        

    def register_child(self, name, child):
        self.children[name] = child

    def resolve_children(self, context):
        if self.resolved:
            return
        for child_name, child in self.children.items():
            logger.debug(f"Resolving child {child_name} : {child}")
            self.children[child_name] = resolve(child, context)
        self.resolved = True

    def get_child(self, name, recursive=True):
        logger.debug(f"{self.name}.get_child({name})")
        if name in self.children:
            logger.debug(f" .. found {self.children[name]}")
            return self.children[name]
        
        if recursive and self.parent is not None:
            return self.parent.get_child(name)

        raise Exception(f"{name} not found as child of {self.name}!")