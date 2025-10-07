from datetime import datetime
timeNow = datetime.now().isoformat()

try:
    from yaml import CLoader as Loader
except ImportError:
    from yaml import Loader

from util.expressions import *
from util.objects import add_global, get_global, Object, resolve
from util import logger
from util import versions
from util.versions import is_marvel, is_mtcs, statuses, processes



class Primitive(Object):
    """
    A class to represent a primitive type (t_bool, t_double, ...).
    """

    def __init__(self, name, plc_symbol=None) -> None:
        super().__init__(name, None)
        self.plc_symbol = plc_symbol


class PRIMITIVE_TYPES:
    """
    Just a class to hold the various primitive types.
    """
    t_bool       = Primitive("t_bool"       , plc_symbol="BOOL")
    t_bit        = Primitive("t_bit"        , plc_symbol="BIT")
    t_bytestring = Primitive("t_bytestring" , plc_symbol=None)
    t_double     = Primitive("t_double"     , plc_symbol="LREAL")
    t_float      = Primitive("t_float"      , plc_symbol="REAL")
    t_int16      = Primitive("t_int16"      , plc_symbol="INT")
    t_int32      = Primitive("t_int32"      , plc_symbol="DINT")
    t_int64      = Primitive("t_int64"      , plc_symbol="LINT")
    t_int8       = Primitive("t_int8"       , plc_symbol="SINT")
    t_uint16     = Primitive("t_uint16"     , plc_symbol="UINT")
    t_uint32     = Primitive("t_uint32"     , plc_symbol="UDINT")
    t_uint64     = Primitive("t_uint64"     , plc_symbol="ULINT")
    t_uint8      = Primitive("t_uint8"      , plc_symbol="USINT")
    t_string     = Primitive("t_string"     , plc_symbol="STRING")
    t_byte       = Primitive("t_byte"       , plc_symbol="BYTE")
    t_word       = Primitive("t_word"       , plc_symbol="WORD")
    t_dword      = Primitive("t_dword"      , plc_symbol="DWORD")


# add the above primitive types to the global namespace
add_global("t_bool",       PRIMITIVE_TYPES.t_bool)
add_global("t_bit",        PRIMITIVE_TYPES.t_bit)
add_global("t_bytestring", PRIMITIVE_TYPES.t_bytestring)
add_global("t_double",     PRIMITIVE_TYPES.t_double)
add_global("t_float",      PRIMITIVE_TYPES.t_float)
add_global("t_int16",      PRIMITIVE_TYPES.t_int16)
add_global("t_int32",      PRIMITIVE_TYPES.t_int32)
add_global("t_int64",      PRIMITIVE_TYPES.t_int64)
add_global("t_int8",       PRIMITIVE_TYPES.t_int8)
add_global("t_uint16",     PRIMITIVE_TYPES.t_uint16)
add_global("t_uint32",     PRIMITIVE_TYPES.t_uint32)
add_global("t_uint64",     PRIMITIVE_TYPES.t_uint64)
add_global("t_uint8",      PRIMITIVE_TYPES.t_uint8)
add_global("t_string",     PRIMITIVE_TYPES.t_string)
add_global("t_byte",       PRIMITIVE_TYPES.t_byte)
add_global("t_word",       PRIMITIVE_TYPES.t_word)
add_global("t_dword",       PRIMITIVE_TYPES.t_dword)



class PlcOpenAttribute:
    """
    A class representing a PLCopen attribute
    """

    def __init__(self, symbol, value):
        self.plc_symbol = symbol
        self.value = value

    def __eq__(self, value):
        return (value.plc_symbol == self.plc_symbol) and (value.value == self.value)

class QUALIFIERS:
    """
    Just a class to hold various qualifiers.
    """
    OPC_UA_DEACTIVATE = PlcOpenAttribute(symbol = 'OPC.UA.DA', value = '0')
    OPC_UA_ACTIVATE = PlcOpenAttribute(symbol = 'OPC.UA.DA', value = '1')
    OPC_UA_ACCESS = PlcOpenAttribute(symbol = 'OPC.UA.DA.Access', value = '0')
    OPC_UA_ACCESS_R = PlcOpenAttribute(symbol = 'OPC.UA.DA.Access', value = '1')
    OPC_UA_ACCESS_W = PlcOpenAttribute(symbol = 'OPC.UA.DA.Access', value = '2')
    OPC_UA_ACCESS_RW = PlcOpenAttribute(symbol = 'OPC.UA.DA.Access', value = '3')
    QUALIFIED_ONLY = PlcOpenAttribute(symbol = 'qualified_only', value = '')


class Namespace(Object):
    """
    A class representing a PLCopen namespace
    """

    def __init__(self, name: str, parent: Object):
        super().__init__(name, parent)

    def __setitem__(self, name: str, item: Object):
        self.register_child(name, item)
    
    def __getitem__(self, name: str):
        return self.children[name]
    
    def items(self):
        return self.children.items()
    
    def get_statemachines(self, recursive: bool, statemachines: list):
        for child in self.children.values():
            if isinstance(child, Namespace):
                if recursive:
                    child.get_statemachines(recursive, statemachines)
            elif isinstance(child, Statemachine):
                if child not in statemachines:
                    statemachines.append(child)
    
    def get_processes(self, recursive: bool, processes: list):
        for child in self.children.values():
            if isinstance(child, Namespace):
                if recursive:
                    child.get_processes(recursive, processes)
            elif isinstance(child, Process):
                if child not in processes:
                    processes.append(child)
    
    def get_namespaces(self, recursive: bool, namespaces: list):
        for child in self.children.values():
            if isinstance(child, Namespace):
                if recursive:
                    child.get_namespaces(recursive, namespaces)
                namespaces.append(child)
    
    def get_enums(self, recursive: bool, enums: list):
        for child in self.children.values():
            if isinstance(child, Namespace) and recursive:
                child.get_enums(recursive, enums)
            elif isinstance(child, Enum):
                if child not in enums:
                    enums.append(child)
    
    def get_fbs(self, recursive: bool, fbs: list):
        for child in self.children.values():
            if isinstance(child, Namespace) and recursive:
                child.get_fbs(recursive, fbs)
            elif isinstance(child, FunctionBlock):
                if child not in fbs:
                    fbs.append(child)
    
    def get_functions(self, recursive: bool, functions: list):
        for child in self.children.values():
            if isinstance(child, Namespace) and recursive:
                child.get_functions(recursive, functions)
            elif isinstance(child, Function) and not isinstance(child, Method):
                if child not in functions:
                    functions.append(child)
    
    def get_structs(self, recursive: bool, structs: list):
        for child in self.children.values():
            if isinstance(child, Namespace) and recursive:
                child.get_structs(recursive, structs)
            elif isinstance(child, Struct):
                if child not in structs:
                    structs.append(child)
    

# define the global namespace
GLOBAL_NS = Namespace("GLOBAL_NS", None)



class Library(Namespace):

    class StatemachinesNamespace(Namespace):
        def __init__(self, name, parent):
            super().__init__(name, parent)
            self.parts = Namespace("Parts", self)
            self.processes = Namespace("Processes", self)
            self.statuses = Namespace("Statuses", self)
            if is_marvel():
                self.models = Namespace("Models", self)

    class ProcessesNamespace(Namespace):
        def __init__(self, name, parent):
            super().__init__(name, parent)
            self.args = Namespace("Args", self)


    def __init__(self, name, args):
        super().__init__(name, GLOBAL_NS)  # a library has no parent!

        # define the sub-namespaces
        self.enums = Namespace("Enums", self)
        self.statuses = Namespace("Statuses", self)
        self.statemachines = Library.StatemachinesNamespace("StateMachines", self)
        self.configs = Namespace("Configs", self)
        self.structs = Namespace("Structs", self)
        self.processes = Library.ProcessesNamespace("Processes", self)   
        self.functionblocks = Namespace("Functionblocks", self)
        self.functions = Namespace("Functions", self)
        if is_marvel():
            self.models = Namespace("Models", self)

        # add the items
        for arg_k, arg_v in args.items():
            if isinstance(arg_k, ENUMERATION):
                self.enums[arg_k.name] = Enum(arg_k.name, self, arg_v) 
            elif isinstance(arg_k, STATEMACHINE):
                sm = Statemachine(arg_k.name, self, arg_v)
                self.statemachines[arg_k.name] = sm
            elif isinstance(arg_k, STATUS):
                if is_mtcs():
                    sts = Status(arg_k.name, self, arg_v) 
                    self.statuses[arg_k.name] = sts
                elif is_marvel():
                    enum, function = make_marvel_status(arg_k.name, self, arg_v)
                    self.functions[function.name] = function
                    self.enums[enum.name] = enum
            elif isinstance(arg_k, FB):
                fb = FunctionBlock(arg_k.name, self, arg_v) 
                self.functionblocks[arg_k.name] = fb
            elif isinstance(arg_k, CONFIG):
                cfg = Config(arg_k.name, self, arg_v) 
                self.configs[arg_k.name] = cfg
                #self.structs[arg_k.name] = cfg
            elif isinstance(arg_k, STRUCT):
                struct = Struct(arg_k.name, self, arg_v) 
                self.structs[arg_k.name] = struct
            elif isinstance(arg_k, PROCESS):
                proc = Process(arg_k.name, self, arg_v) 
                self.processes[arg_k.name] = proc
        
        if is_marvel():
            add_models(self)


def check_args(name, args, allowed_args):
    """Helper function to check if the arguments are in an allowed list"""
    for arg in args:
        if arg not in allowed_args:
            raise Exception(f"{name} contains illegal argument '{arg}' (allowed: {allowed_args})")


class Enum(Object):
    """
    PLCOpen Enumeration.
    """

    def __init__(self, name: str, parent: Object, args={}):
        super().__init__(name, parent)
        check_args("Enum", args, ["type", "items", "comment"])
        
        self.type = None
        self.items = []
        self.comment = None
        self.plc_symbol = None
        self.is_ref = False
        self.calulcated_by = None
        self.items_by_name = {}
        self.qualifiers = None

        if is_marvel():
            self.qualifiers = [ QUALIFIERS.QUALIFIED_ONLY ]


        if 'comment' in args:
            self.comment = args['comment']
        
        if 'type' in args:
            self.type = resolve(args['type'], self)

        if 'items' in args:
            for item_number, item_name in enumerate(args['items']):
                item = EnumItem(item_name, self, item_number)
                self.items.append(item)
                self.items_by_name[item_name] = item


def ENUM_constructor(loader: Loader, node):
    """
    Constructor for the Enum class.
    """
    mapping = loader.construct_mapping(node)
    for name, args in mapping.items():
        return Enum(name, args['parent'], args)


class ENUMERATION:
    """
    Class respresenting the "!ENUMERATION <name>" tag.
    """
    def __init__(self, name: str):
        self.name = name


def ENUMERATION_constructor(loader: Loader, node):
    """
    Constructor for the "!ENUMERATION <name>" tag.
    """
    name = loader.construct_scalar(node)
    return ENUMERATION(name)


class LIBRARY:
    """
    Class respresenting the "!LIBRARY <name>" tag.
    """
    def __init__(self, name):
        self.name = name

def LIBRARY_constructor(loader: Loader, node):
    """
    Constructor for the "!LIBRARY <name>" tag.
    """
    name = loader.construct_scalar(node)
    return LIBRARY(name)


class STATEMACHINE:
    """
    Class respresenting the "!STATEMACHINE <name>" tag.
    """
    def __init__(self, name):
        self.name = name


def STATEMACHINE_constructor(loader: Loader, node):
    """
    Constructor for the "!STATEMACHINE <name>" tag.
    """
    name = loader.construct_scalar(node)
    return STATEMACHINE(name)


class STATUS:
    """
    Class respresenting the "!STATUS <name>" tag.
    """
    def __init__(self, name):
        self.name = name


def STATUS_constructor(loader: Loader, node):
    """
    Constructor for the "!STATUS <name>" tag.
    """
    name = loader.construct_scalar(node)
    return STATUS(name)


class CONFIG:
    """
    Class respresenting the "!CONFIG <name>" tag.
    """
    def __init__(self, name):
        self.name = name


def CONFIG_constructor(loader: Loader, node):
    """
    Constructor for the "!CONFIG <name>" tag.
    """
    name = loader.construct_scalar(node)
    return CONFIG(name)


class FB:
    """
    Class respresenting the "!FB <name>" tag.
    """
    def __init__(self, name):
        self.name = name


def FB_constructor(loader: Loader, node):
    """
    Constructor for the "!FB <name>" tag.
    """
    name = loader.construct_scalar(node)
    return FB(name)


class STRUCT:
    """
    Class respresenting the "!STRUCT <name>" tag.
    """
    def __init__(self, name):
        self.name = name


def STRUCT_constructor(loader: Loader, node):
    """
    Constructor for the "!STRUCT <name>" tag.
    """
    name = loader.construct_scalar(node)
    return STRUCT(name)


class PROCESS:
    """
    Class respresenting the "!PROCESS <name>" tag.
    """
    def __init__(self, name):
        self.name = name

def PROCESS_constructor(loader: Loader, node):
    """
    Constructor for the "!PROCESS <name>" tag.
    """
    name = loader.construct_scalar(node)
    return PROCESS(name)


class Variable(Object):
    """
    Class respresenting a PLCopen Variable.
    """

    def __init__(self, name, parent, args={}):
        super().__init__(name, parent)
        check_args(f"Variable {name}", args, 
                   ["type", "expand", "initial", "comment",
                    "pointsToType", "attributes", "qualifiers", "arguments",
                    "address", "isRef"])
        
        self.raw_args = args
        
        if 'type' in args and 'pointsToType' in args:
            raise Exception(f"Variable {name} contains BOTH 'type' and 'pointsToType', this is not allowed!")
        
        self.type = None
        self.expand = True
        self.initial = None
        self.comment = ""
        self.points_to_type = None
        self.attributes = None
        self.qualifiers = []
        self.arguments = None
        self.address = None
        self.copyFrom = None
        self.methods = {}
        self.is_ref = False

        if 'expand' in args:
            self.expand = args['expand']

        if 'type' in args:
            self.type = resolve(args['type'], self)

            if self.expand:
                for child_name, child in self.type.children.items():
                    if hasattr(child, 'type'):
                        if child.type is not None:
                            self.register_child(child_name, Variable(child_name, self, { "type": child.type  }))
                        elif isinstance(child, Method):
                            method_args = {}
                            method_args["inputArgs"] = {}
                            method_args["inOutArgs"] = {}
                            for var_name, var in child.var_in.items():
                                method_args["inputArgs"][var_name] = {}
                            for var_name, var in child.var_inout.items():
                                method_args["inOutArgs"][var_name] = {}
                            if child.return_type is not None:
                                method_args["returnType"] = child.return_type
                            self.register_child(child_name, Method(child_name, self, method_args))
                        elif hasattr(child, 'raw_args'):
                            child_args = {}
                            if 'attributes' in child.raw_args:
                                child_args['attributes'] = child.raw_args['attributes']
                            if 'arguments' in child.raw_args:
                                child_args['arguments'] = child.raw_args['arguments']

                            self.register_child(child_name, Variable(child_name, self, child_args))

        if 'initial' in args:
            self.initial = args['initial']
        if 'comment' in args:
            self.comment = args['comment']
        if 'pointsToType' in args:
            self.points_to_type = resolve(args['pointsToType'], self)
        if 'attributes' in args:
            self.attributes = {}
            for attribute_k, attribute_v in args['attributes'].items():
                    self.attributes[attribute_k] = Variable(attribute_k, self, attribute_v)
        if 'qualifiers' in args:
            for qualifier in args['qualifiers']:
                # TODO: resolve?
                if isinstance(qualifier, dict):
                    self.qualifiers.append(PlcOpenAttribute(symbol=qualifier['symbol'], value=qualifier['value']))
                else:
                    self.qualifiers.append(qualifier)
                
        if 'arguments' in args:
            self.arguments = {}
            for argument_k, argument_v in args['arguments'].items():
                self.arguments[argument_k] = Variable(argument_k, self, argument_v)

        if 'address' in args:
            self.address = args['address']
        
        if 'isRef' in args:
            self.is_ref = str(args['isRef']).upper() == "TRUE"

            


class EnumItem(Variable):
    """
    Class respresenting a PLCopen enum item.
    """
    def __init__(self, name, parent, number) -> None:
        super().__init__(name, parent)
        self.number = number


class GlobalVariable(Variable):
    """
    Class respresenting a PLCopen global Variable.
    """
    pass


class Struct(Object):
    """
    Class respresenting a PLCopen Struct.
    """

    def __init__(self, name, parent, args={}) -> None:
        super().__init__(name, parent)

        logger.info(f"Creating {versions.CODEGEN_VERSION} Struct {name}")

        self.items = None
        self.plc_symbol = None
        self.qualifiers = None
        self.is_ref = False
        self.extends = None
        self.render = True

        for arg in args:
            if arg not in ["items", "comment", "typeOf", "qualifiers", "extends"]:
                raise Exception(f"Struct {name} contains illegal argument '{arg}'")
        
        if 'comment' in args:
            self.comment = args['comment']

        if 'items' in args:
            self.items = {}
            for item_k, item_v in args['items'].items():
                self.items[item_k] = Variable(item_k, self, item_v)

        if 'qualifiers' in args:
            self.qualifiers = []
            for qualifier in args['qualifiers']:
                self.qualifiers.append(PlcOpenAttribute(qualifier['symbol'], qualifier['value']))

        if 'typeOf' in args:
            typeOfList = args['typeOf']
            if not isinstance(args['typeOf'], list):
                typeOfList = [ typeOfList ]
            for typeOf in typeOfList:
                subject = resolve(typeOf, self)
                subject.type = self
        
        if "extends" in args:
            self.extends = resolve(args["extends"], self)

class Model(Struct):
    def __init__(self, name, parent) -> None:
        super().__init__(name, parent, { 'items' : {}})

class Call:
    """
    Class respresenting a PLCopen call.
    """
    
    def __init__(self, name, lib, args={}) -> None:
        self.name = name
        self.lib = lib
        check_args("Call", args, 
                   ["calls", "assigns"])
        self.calls = None
        if "calls" in args:
            self.calls = args["calls"]
        self.assignments = []
        if "assigns" in args:
            self.assignments = args["assigns"]
      

class Function(Object):
    """
    Class respresenting a PLCopen function.
    """
    def __init__(self, name, parent, args={}) -> None:
        super().__init__(name, parent)
        check_args("Function", args, 
            ["inputArgs", "inOutArgs", "localArgs", "returnType", 
             "comment", "implementation"])
        
        self.comment = ""
        self.var_in = {}
        self.var_inout = {}
        self.var_local = {}
        self.var_out = {} # only here for backwards compatibility
        self.return_type = None
        self.implementation = None
        self.extends = None
        self.type = None
        self.points_to_type = None

        if "comment" in args:
            self.comment = args["comment"]

        if "inputArgs" in args:
            self.var_in = {}
            for arg_name, arg in args["inputArgs"].items():
                self.var_in[arg_name] = Variable(arg_name, self, arg)
        
        if "inOutArgs" in args:
            self.var_inout = {}
            for arg_name, arg in args["inOutArgs"].items():
                self.var_inout[arg_name] = Variable(arg_name, self, arg)
        
        if "localArgs" in args:
            self.var_local = {}
            for arg_name, arg in args["localArgs"].items():
                self.var_local[arg_name] = Variable(arg_name, self, arg)
        
        if "returnType" in args:
            self.return_type = resolve(args['returnType'], self)
        
        if "implementation" in args:
            raise NotImplementedError()


class Method(Function):
    """
    Class respresenting a PLCopen method.
    """

    def __init__(self, name, parent, args={}) -> None:
        super().__init__(name, parent, args)



class FunctionBlock(Object):
    """
    Class respresenting a PLCopen FB.
    """
    
    def __init__(self, name, parent, args={}) -> None:
        logger.info(f"Creating {versions.CODEGEN_VERSION} FunctionBlock {name}")

        super().__init__(name, parent)
        
        check_args("FunctionBlock", args, 
                   ["typeOf", "extends", "comment", "in", "out", "inout", "render"])
        
        self.var_in = {}
        self.var_out = {}
        self.var_inout = {}
        self.var_local = {}
        self.attributes = {}
        self.extends = None
        self.methods = {}
        self.plc_symbol = None
        self.implementation = []
        self.is_ref = False

        if "render" in args:
            self.render = args["render"]
        else:
            self.render = True
        
        if 'typeOf' in args:
            typeOfList = args['typeOf']
            if not isinstance(args['typeOf'], list):
                typeOfList = [ typeOfList ]
            for typeOf in typeOfList:
                subject = resolve(typeOf, self)
                subject.type = self

        if "in" in args:
            for var_name, var_args in args["in"].items():
                self.var_in[var_name] = Variable(var_name, self, var_args)

        if "out" in args:
            for var_name, var_args in args["out"].items():
                self.var_out[var_name] = Variable(var_name, self, var_args)

        if "inout" in args:
            for var_name, var_args in args["inout"].items():
                self.var_inout[var_name] = Variable(var_name, self, var_args)

        if "extends" in args:
            self.extends = resolve(args["extends"], self)
            self.attributes["SUPER"] = Pointer("SUPER", self, { "type": self.extends })
            
            for child_name, child in self.extends.children.items():
                if not child_name == "SUPER":
                    self.register_child(child_name, child)


class Status(FunctionBlock):
    """
    Class respresenting a Status.
    """
    
    def __init__(self, name, parent, args={}) -> None:
        logger.info(f"Creating {versions.CODEGEN_VERSION} Status {name}")

        super().__init__(name, parent)
        check_args("Status", args, ["typeOf", "variables_input", "states", "render"])

        if 'typeOf' in args:
            typeOfList = args['typeOf']
            if not isinstance(args['typeOf'], list):
                typeOfList = [ typeOfList ]
            for typeOf in typeOfList:
                subject = resolve(typeOf, self)
                subject.type = self
        
        self.variables = {}
        self.states = {}

        if "render" in args:
            self.render = args["render"]
        else:
            self.render = True
        
        self.var_in["superState"] = Variable(
            "superState", 
            self, 
            {
                "comment": "Super state (TRUE if the super state is active, or if there is no super state)",
                "type": "t_bool",
                "initial": Bool(True)
            })

        if "variables_input" in args:
            for var_name, var_args in args["variables_input"].items():
                self.var_in[var_name] = Variable(var_name, self, var_args)
        
        if "states" in args:
            for var_name, var_args in args["states"].items():
                v = Variable(
                    var_name, 
                    self, 
                    {
                        "type": "t_bool",
                        "comment": var_args["comment"] 
                    })
                v.qualifiers = [QUALIFIERS.OPC_UA_ACTIVATE, QUALIFIERS.OPC_UA_ACCESS_R]
                self.var_out[var_name] = v
        
        self.implementation = []
        for state_name, state_args in args["states"].items():
            assignment = ASSIGN([self.get_child(state_name), AND([state_args['expr'], self.get_child('superState')])])
            assignment.resolve_children(self)
            self.implementation.append(assignment)
        

class Config(Struct):
    """
    Class respresenting a Config.
    """
    
    def __init__(self, name, parent, args={}) -> None:
        logger.info(f"Creating {versions.CODEGEN_VERSION} Config {name}")
        super().__init__(name, parent, args)


class Pointer(Variable):
    """
    Class respresenting a Pointer.
    """

    def __init__(self, name, parent, args={}) -> None:
        super().__init__(name, parent)
        
        check_args("Pointer", args, ["to", "type"])

        self.points_to = None
        self.points_to_type = None

        if "to" in args:
            self.points_to = resolve(args["to"], self)
        if "type" in args:
            self.points_to_type = resolve(args["type"], self)



class Statemachine(FunctionBlock):
    """
    Class respresenting a state machine.
    """

    def __init__(self, name, parent, args={}) -> None:
        logger.info(f"Creating {versions.CODEGEN_VERSION} StateMachine {name}")
        if "extends" in args:
            super().__init__(f"SM_{name}", parent, { "extends" : args["extends"] } )
        else:
            super().__init__(f"SM_{name}", parent)
        
        check_args("Statemachine", args,
                   ["variables_input", "variables_hidden", "variables_output",
                    "statuses", "parts", "local", "local_rw", "methods", "calls", statuses(),
                    "disabled_calls", "updates", "references", "extends",
                    processes(), "constraints", "render", "typeOf"])
        
        self.variables = {}
        self.variables_hidden = {}
        self.variables_output = {}
        self.statuses = {}
        self.parts = {}
        self.methods = {}
        self.processes = {}
        # self.model = None

        # if is_marvel():
        #     self.model = Model(f"M_{name}", self.parent, { "items" : {} })
        #     # self.parent.register_child(f"M_{name}", self.model)
        #     self.parent.statemachines.models[self.model.name] = self.model

        if "render" in args:
            self.render = args["render"]
            # if is_marvel():
            #     self.model.render = False
            #     #self.model.render = self.render
        else:
            self.render = True
        
        self.vars = {}
        self.disabledCallNames = []

        if "actualStatus" not in self.children:
            v = Variable("actualStatus", self)
            v.type = PRIMITIVE_TYPES.t_string
            v.comment = "Current status description"
            v.qualifiers = [QUALIFIERS.OPC_UA_ACTIVATE, QUALIFIERS.OPC_UA_ACCESS_R]
            self.var_out['actualStatus'] = v
            self.vars['actualStatus'] = v
            # if is_marvel():
            #     self.model.items['actualStatus'] = Variable('actualStatus', self.model)
        
        if is_mtcs():
            if "previousStatus" not in self.children:
                v = Variable("previousStatus", self)
                v.type = PRIMITIVE_TYPES.t_string
                v.comment = "Previous status description"
                v.qualifiers.append(QUALIFIERS.OPC_UA_DEACTIVATE)
                self.var_out["previousStatus"] = v
                self.vars['previousStatus'] = v

        if "variables_input" in args:
            for var_name, var in args['variables_input'].items():
                v = Variable(var_name, self, var)
                if QUALIFIERS.OPC_UA_ACTIVATE not in v.qualifiers:
                    v.qualifiers.append(QUALIFIERS.OPC_UA_ACTIVATE)
                if QUALIFIERS.OPC_UA_ACCESS_R not in v.qualifiers:
                    v.qualifiers.append(QUALIFIERS.OPC_UA_ACCESS_R)
                self.var_in[var_name] = v
                self.vars[var_name] = v

        if "variables_output" in args:
            for var_name, var in args['variables_output'].items():
                v = Variable(var_name, self, var)
                if QUALIFIERS.OPC_UA_ACTIVATE not in v.qualifiers:
                    v.qualifiers.append(QUALIFIERS.OPC_UA_ACTIVATE)
                if QUALIFIERS.OPC_UA_ACCESS_R not in v.qualifiers:
                    v.qualifiers.append(QUALIFIERS.OPC_UA_ACCESS_R)
                self.var_out[var_name] = v
                self.vars[var_name] = v

        if "variables_hidden" in args:
            for var_name, var in args['variables_hidden'].items():
                v = Variable(var_name, self, var)
                if QUALIFIERS.OPC_UA_DEACTIVATE not in v.qualifiers:
                    v.qualifiers.append(QUALIFIERS.OPC_UA_DEACTIVATE)
                self.var_in[var_name] = v
                self.vars[var_name] = v

        if "references" in args:
            for var_name, var in args['references'].items():
                v = Variable(var_name, self, var)
                if QUALIFIERS.OPC_UA_DEACTIVATE not in v.qualifiers:
                    v.qualifiers.append(QUALIFIERS.OPC_UA_DEACTIVATE)
                self.var_inout[var_name] = v
                self.vars[var_name] = v

        if statuses() in args:
            struct = Struct(
                name = f'{name}Statuses',
                parent = self.parent,
                args = { "items": args[statuses()] }
            )
            if is_marvel():
                for item in struct.items.values():
                    item.qualifiers = [QUALIFIERS.OPC_UA_ACTIVATE, QUALIFIERS.OPC_UA_ACCESS_R]
            
            self.parent.statemachines.statuses[struct.name] = struct
            self.var_out[statuses()] = Variable(
                name=statuses(), 
                parent=self,
                args = {
                    "comment": "Statuses of the state machine",
                    "type": f'{name}Statuses'})
            for status_name in args[statuses()]:
                self.statuses[status_name] = self.var_out[statuses()].get_child(status_name)
            
            # if is_marvel():
            #     self.model.items[statuses()] = Variable(name=statuses(), parent=self.model, args = {"type": f'{name}Statuses'})

        if "parts" in args:
            struct = Struct(
                name = f'{name}Parts',
                parent = self.parent,
                args = { "items" : args['parts'] }
            )
            self.parent.statemachines.parts[struct.name] = struct
            self.var_out["parts"] = Variable(
                name='parts', 
                parent=self,
                args = {
                    "comment": "Parts of the state machine",
                    "type": f'{name}Parts'})
            for part_name in args['parts']:
                try:
                    self.parts[part_name] = self.var_out["parts"].get_child(part_name)
                except Exception as e:
                    print("=========")
                    import pprint
                    pprint.pprint(self.var_out["parts"].__dict__)
                    print("=========")
                    pprint.pprint(struct.__dict__)
                    print("=========")
                    pprint.pprint(struct.items["io"].__dict__)
                    print("=========")
                    raise
            
            # if is_marvel():
            #     m_struct = Struct(
            #         name = f'M_{name}Parts',
            #         parent = self.parent,
            #         args = { "items" : {} })
            #     self.parent.statemachines.models[m_struct.name] = m_struct
            #     self.model.items['parts'] = Variable('parts', self.model, { 'type' : f'M_{name}Parts' })
            #     for part_name in args['parts']:
            #         m_struct.items[part_name] = Variable(part_name, m_struct)
            #         t = self.var_out["parts"].get_child(part_name).type
            #         if t is not None:
            #             m_struct.items[part_name].type = t

            #     #for item_name, item in struct.items.items():
            #     #     m_struct.items[item_name] = Variable(f'M_{item_name}', m_struct, { 'type': f'M_{item.type.name}' })


        if "disabled_calls" in args:
            for disabled_call in args["disabled_calls"]:
                self.disabledCallNames.append(disabled_call)

        if processes() in args:
            struct = Struct(
                name = f'{name}Processes',
                parent = self.parent,
                args = {"items" : args[processes()]})
            self.parent.statemachines.processes[struct.name] = struct
            self.var_out[processes()] = Variable(
                name=processes(), 
                parent=self,
                args = {
                    "comment": "Processes of the state machine",
                    "type": f'{name}Processes'
                })
            for process_name in args[processes()]:
                self.processes[process_name] = self.var_out[processes()].get_child(process_name)

        if is_mtcs():
            if processes() in args:
                for process_name, process_args in args[processes()].items():
                    input_args = {}
                    for var_name, var in resolve(process_args["type"], context=self).request.var_in.items():
                        input_args[var_name] = { "type": var.type }

                    m = Method(
                        name = process_name,
                        parent = self,
                        args = {
                            "comment": process_args["comment"],
                            "returnType": f"{get_common_lib()}.RequestResults",
                            "inputArgs": input_args
                        })
                    
                    self.methods[process_name] = m

                    c = Call(f"call_{process_name}", self.processes[process_name])
                    c.calls = self.processes[process_name].get_child("request")
                    c.assignments = []
                    for k, v in input_args.items():
                        assignment = ASSIGN([c.calls.get_child(k, recursive=False), m.get_child(k, recursive=False)])
                        assignment.resolve_children(self)
                        c.assignments.append(assignment)

                    m.implementation = [
                        ASSIGN([m, c])
                    ]

        # add the local variables
        if "local_rw" in args:
            for var_name, var in args['local_rw'].items():
                v = Variable(var_name, self, var)
                v.qualifiers = [QUALIFIERS.OPC_UA_ACTIVATE, QUALIFIERS.OPC_UA_ACCESS_RW]
                self.var_local[var_name] = v
                self.vars[var_name] = v

        # add the local variables
        if "local" in args:
            for var_name, var in args['local'].items():
                v = Variable(var_name, self, var)
                v.qualifiers = [QUALIFIERS.OPC_UA_ACTIVATE]
                self.var_local[var_name] = v
                self.vars[var_name] = v

        # add the methods
        if "methods" in args:
            for method_name, method in args["methods"].items():
                self.methods[method_name] = Method(method_name, self, method)


        # ============ IMPLEMENTATION PART ============

        # call the variables (if specified by the "calls" argument)
        objects_to_call = {}
        for var_name, var in self.vars.items():
            if "calls" in args:
                if (var_name in args["calls"]) and (var_name not in self.disabledCallNames):
                    objects_to_call[var_name] = var
        for part_name, part in self.parts.items():
            if part_name not in self.disabledCallNames:
                objects_to_call[part_name] = part

        if self.implementation is None:
            self.implementation = []
         
        for child_name, child in objects_to_call.items():
            c = Call(f"call_{child_name}", self)
            c.calls = child
            c.assignments = []
            if "calls" in args:
                if child_name in args["calls"]:
                    for k, v in args["calls"][child_name].items():
                        # k should be a child of the callee (c.calls)!
                        assignment = ASSIGN([c.calls.get_child(k, recursive=False), v])
                        assignment.resolve_children(self)
                        c.assignments.append(assignment)

            self.implementation.append(c)

        objects_to_call = {}


        if versions.CODEGEN_VERSION == versions.CodeGenVersion.MARVEL:
            for status_name, status in self.statuses.items():
                if "calls" in args:
                    if status_name in args["calls"]:
                        function = status.type.calculated_by

                        c = Call(f"call_{status_name}", function.parent)
                        c.calls = function
                        c.assignments = []

                        for k, v in args["calls"][status_name].items():
                            # k should be a child of the callee (c.calls)!
                            assignment = ASSIGN([c.calls.get_child(k, recursive=False), v])
                            assignment.resolve_children(self)
                            c.assignments.append(assignment)
                                    
                        function_assign = ASSIGN([self.statuses[status_name], c])
                        self.implementation.append(function_assign)



        elif versions.CODEGEN_VERSION == versions.CodeGenVersion.MTCS:
            for status_name, status in self.statuses.items():
                if status_name not in self.disabledCallNames:
                    objects_to_call[status_name] = status
        else:
            raise Exception("Invalid version")
        
        for process_name, process in self.processes.items():
            if process_name not in self.disabledCallNames:
                objects_to_call[process_name] = process

        for child_name, child in objects_to_call.items():
            c = Call(f"call_{child_name}", self)
            c.calls = child
            c.assignments = []
            if "calls" in args:
                if child_name in args["calls"]:
                    for k, v in args["calls"][child_name].items():
                        # k should be a child of the callee (c.calls)!
                        assignment = ASSIGN([c.calls.get_child(k, recursive=False), v])
                        assignment.resolve_children(self)
                        c.assignments.append(assignment)
            
            self.implementation.append(c)
        

        if is_mtcs():
            for var in self.vars.values():
                if var.address is not None:
                    if var.address.startswith("%I"):
                        name_ro = f"{var.name}_ro"
                        var_ro = Variable(name_ro, self)
                        var_ro.type = var.type
                        var_ro.qualifiers = var.qualifiers
                        self.var_local[name_ro] = var_ro
                                    
                        if self.implementation is None:
                            self.implementation = []
                            
                        self.implementation.append(ASSIGN([var_ro, var]))


        if self.extends is not None:
            if self.implementation is None:
                self.implementation = []
            
            c = Call(f"call_SUPER", self)
            c.calls = PLC_DEREF(self.children["SUPER"])
            self.implementation.append(c)
        
        if is_mtcs():
            if not '_log' in self.children:
                m = Method("_log", self, {
                            "comment"   : "Log to buffer",
                            "inputArgs" : {
                                "name": {
                                        "type": "t_string", 
                                        "comment": "Name of this function block instance"} },
                            "inOutArgs" : {
                                "buffer" : {
                                        "type": "LogBuffer", 
                                        "comment": "Buffer to write all logging to" } },
                            "localArgs": {
                                    "subBuffer" : { 
                                        "type": "LogBuffer", 
                                        "comment": "Temporary buffer to write logging by parts (sub-statemachines) to" } },
                            "returnType": "t_bool" })
                
                m.implementation = []

                c = Call("loggerCall", self)
                c.calls = resolve("LOGGER", None)
                c.assignments = [
                    ASSIGN([get_global("LOGGER").get_child("name"), m.get_child("name")]),
                    ASSIGN([get_global("LOGGER").get_child("actualStatus"), self.get_child("actualStatus")]),
                    ASSIGN([get_global("LOGGER").get_child("previousStatus"), self.get_child("previousStatus")]),
                    ASSIGN([get_global("LOGGER").get_child("buffer"), m.get_child("buffer")]),
                    ASSIGN([get_global("LOGGER").get_child("subBuffer"), m.get_child("subBuffer")])
                ]

                for part_name, part in self.parts.items():
                    if not "_log" in part.children:
                        part.methods["_log"] = \
                            Method("_log", part, {
                            "inputArgs" : { "name": { "type": "t_string" } },
                            "inOutArgs" : { "buffer" : { "type": "LogBuffer" } },
                            "returnType": "t_bool" })
                        
                    part_call = Call(f"call_{part_name}", self)
                    part_call.calls = part.children["_log"]
                    part_call.assignments = [
                        ASSIGN([part_call.calls.get_child("name"), String(part_name)]),
                        ASSIGN([part_call.calls.get_child("buffer"), m.var_local["subBuffer"]]),
                    ]

                    m.implementation.append(part_call)

                for process_name, process in self.processes.items():
                    if not "_log" in process.children:
                        process.methods["_log"] = \
                            Method("_log", process, {
                            "inputArgs" : { "name": { "type": "t_string" } },
                            "inOutArgs" : { "buffer" : { "type": "LogBuffer" } },
                            "returnType": "t_bool" })
                        
                    process_call = Call(f"call_{process_name}", self)
                    process_call.calls = process.children["_log"]
                    process_call.assignments = [
                        ASSIGN([process_call.calls.get_child("name"), String(f"{processes()}.{process_name}")]),
                        ASSIGN([process_call.calls.get_child("buffer"), m.var_local["subBuffer"]]),
                    ]

                    m.implementation.append(process_call)
                        

                if "healthStatus" in self.statuses:
                        c.assignments.append(  
                            ASSIGN([get_global("LOGGER").get_child("pHealthStatus"), ADR(self.statuses["healthStatus"])])
                        )
                if "busyStatus" in self.statuses:
                        c.assignments.append(  
                            ASSIGN([get_global("LOGGER").get_child("pBusyStatus"), ADR(self.statuses["busyStatus"])])
                        )


                m.implementation.append(c)

                self.methods["_log"] = m

        # finally, also add the main state machine (to be implemented by the user):
        self.main_sm = FunctionBlock(name, self.parent, { "extends": f"SM_{name}", "render": False })
        self.parent.register_child(name, self.main_sm)
        self.main_sm.is_main_sm_of = self

        if 'typeOf' in args:
            typeOfList = args['typeOf']
            if not isinstance(args['typeOf'], list):
                typeOfList = [ typeOfList ]
            for typeOf in typeOfList:
                subject = resolve(typeOf, self)
                subject.type = self.main_sm

        

# create the global LogBuffer struct
add_global("LogBuffer", Struct(name="LogBuffer", parent=None))

# create the global LOGGER
add_global("LOGGER", GlobalVariable(name="LOGGER", 
                                    parent=None, 
                                    args={ "arguments": 
                                            {
                                              "name": {"type": "t_string"},
                                              "actualStatus" : {"type": "t_string"},
                                              "previousStatus" : {"type": "t_string"},
                                              "buffer" : {"type": "LogBuffer"},
                                              "subBuffer" : {"type": "LogBuffer"},
                                              "pHealthStatus" : {"type": "t_string"},
                                              "pBusyStatus" : {"type": "t_string"}
                                            }
                                    }))


def get_common_lib():
    if versions.CODEGEN_VERSION == versions.CodeGenVersion.MARVEL:
        return "marvel_common"
    elif versions.CODEGEN_VERSION == versions.CodeGenVersion.MTCS:
        return "mtcs_common"
    else:
        raise Exception(f"Trying to get common_lib from version")


class Process(FunctionBlock):
    """
    Class respresenting a Process.
    """

    def __init__(self, name, parent, args={}) -> None:
        logger.info(f"Creating {versions.CODEGEN_VERSION} Process {name}")
        if "extends" in args:
            super().__init__(name, parent, { "extends" : args["extends"] } )
        else:
            super().__init__(name, parent, { "extends" : f"{get_common_lib()}.BaseProcess" })
        
        check_args("Process", args,
                   ["extends", "arguments", "variables_input", "variables_hidden", "references"])
        
        self.request = None
        
        if "variables_input" in args:
            for var_name, var in args['variables_input'].items():
                v = Variable(var_name, self, var)
                self.var_in[var_name] = v
        
        if "references" in args:
            for var_name, var in args['references'].items():
                v = Variable(var_name, self, var)
                if QUALIFIERS.OPC_UA_DEACTIVATE not in v.qualifiers:
                    v.qualifiers.append(QUALIFIERS.OPC_UA_DEACTIVATE)
                self.var_inout[var_name] = v

                
        # in case we have arguments, add a <ProcessName>Args Struct, containing the arguments!
        if "arguments" in args:
            struct = Struct(
                name = f"{name}Args", 
                parent = self.parent,
                args = { "items": args['arguments'] })
            self.parent.processes.args[struct.name] = struct

        if is_mtcs():
            if not ("variables_input" in args or "arguments" in args):
                
                self.var_local["testVar"] = Variable(
                    "testVar", 
                    self, 
                    {
                        "comment":  "At least 1 variable needed because subclass members of an empty class are not exposed by OPC UA (TwinCAT bug!)",
                        "type": "t_bool",
                        "qualifiers": [ QUALIFIERS.OPC_UA_DEACTIVATE ]
                    })
        
        # in case we have arguments, also add a 'set' and 'get' instance of this <ProcessName>Args struct
        if "arguments" in args:
            self.var_in["set"] = Variable(
                "set",
                self,
                {
                    "type": struct,
                    "comment": "Arguments to be set, before writing do_request TRUE",
                    "qualifiers": [ QUALIFIERS.OPC_UA_ACTIVATE, QUALIFIERS.OPC_UA_ACCESS_RW ]
                })
            if is_mtcs():
                qualifiers = [ QUALIFIERS.OPC_UA_ACTIVATE, QUALIFIERS.OPC_UA_ACCESS_R ]
            else:
                qualifiers = [ QUALIFIERS.OPC_UA_DEACTIVATE ]
            
            self.var_out["get"] = Variable(
                "get",
                self,
                {
                    "type": struct,
                    "comment": "Arguments in use by the process, if do_request was accepted",
                    "qualifiers": qualifiers
                })

        # add a start(...) method
        if "arguments" in args:
            start = Method(
                name = "start",
                parent = self,
                args = {
                    "comment": "Start the process. This method does not check the enabledStatus, and should not be exposed via OPC UA!",
                    "inputArgs": args["arguments"]
                })
        else:
            start = Method(
                name = "start",
                parent = self,
                args = {
                    "comment": "Start the process. This method does not check the enabledStatus, and should not be exposed via OPC UA!"
                })

        self.methods["start"] = start
        
        # add implementation of the start method
        start.implementation = []
        if "arguments" in args:
            for arg_name in args["arguments"]:
                assignment = ASSIGN([
                    self.var_out["get"].get_child(arg_name), 
                    start.get_child(arg_name)])
                assignment.resolve_children(self)
                start.implementation.append(assignment)

        if versions.CODEGEN_VERSION == versions.CodeGenVersion.MARVEL:        
            start.implementation.append(
                ASSIGN([self.get_child(statuses()).get_child("busy"), resolve("marvel_common.BusyStatus.busy", context=parent)]))
            start.implementation.append(
                ASSIGN([self.get_child(statuses()).get_child("health"), resolve("marvel_common.HealthStatus.good", context=parent)]))
        elif versions.CODEGEN_VERSION == versions.CodeGenVersion.MTCS:
            start.implementation.append(
                Call("setBusy", start, { "calls": self.get_child(statuses()).get_child("busyStatus"), "assigns": [ ASSIGN([self.get_child(statuses()).get_child("busyStatus").get_child("isBusy"), Bool("TRUE")]) ] }))
            start.implementation.append(
                Call("setGood", start, { "calls": self.get_child(statuses()).get_child("healthStatus"), "assigns": [ ASSIGN([self.get_child(statuses()).get_child("healthStatus").get_child("isGood"), Bool("TRUE")]) ] }))
        else:
            raise Exception("Invalid version")

        # add a request(...) method
        if "arguments" in args:
            self.request = Method(
                name = "request",
                parent = self,
                args = {
                    "comment": "Request the start of this process",
                    "inputArgs": args["arguments"],
                    "returnType": f"{get_common_lib()}.RequestResults"
                })
        else:
            self.request = Method(
                name = "request",
                parent = self,
                args = {
                    "comment": "Request the start of this process",
                    "returnType": f"{get_common_lib()}.RequestResults"
                })
            
        self.methods["request"] = self.request

        
        start_call = Call("call_start", self.request)
        start_call.calls = start
        if "arguments" in args:
            for arg_name in args["arguments"]:
                start_call.assignments.append(ASSIGN([start.get_child(arg_name, False),  self.request.get_child(arg_name, False)]))
        
        if is_marvel():
            req_if = EQ( [self.children[statuses()].children["enabled"], 
                          resolve(f"{get_common_lib()}.EnabledStatus.enabled", self.parent)] )
        elif is_mtcs():
            req_if = self.children[statuses()].children["enabledStatus"].children["enabled"]
        else:
            raise Exception("Invalid version")

        self.request.implementation = [
            IfThen(
                name = "ifthen", 
                parent = self.request, 
                if_ = req_if,
                then_ = [
                    ASSIGN([self.request, resolve(f"{get_common_lib()}.RequestResults.ACCEPTED", self.parent)]),
                    start_call
                ],
                else_ = [
                    ASSIGN([self.request, resolve(f"{get_common_lib()}.RequestResults.REJECTED", self.parent)])
                ])
        ]
        
        request_call = Call("call_request", self.request)
        request_call.calls = self.request
        if "arguments" in args:
            for arg_name in args["arguments"]:
                request_call.assignments.append(ASSIGN([self.request.get_child(arg_name, False),  self.var_in["set"].get_child(arg_name, False)]))
        
        self.implementation = [
            IfThen(
                name = "ifthen", 
                parent = self, 
                if_ = self.get_child("do_request"),
                then_ = [
                    ASSIGN([self.get_child("do_request_result"), request_call]),
                    ASSIGN([self.children["do_request"], Bool("FALSE")])
                ]),
            Call("callSuper", self, { "calls": PLC_DEREF(self.children["SUPER"]) })
            
        ]


def make_marvel_status(name, parent, args={}):
    
    enum_items = [var_name for var_name in args["states"]]
    enum_items.insert(0, "invalid_model")
    enum_items.insert(0, "unknown")
    enum = Enum(name, parent=parent, args={ "items": enum_items, "type": "t_byte" })

    function = Function(f"F_{name}", parent=parent, args={})
    function.return_type = enum

    if "render" in args:
        function.render = args["render"]
    else:
        function.render = True
    
    function.var_in["superState"] = Variable(
        "superState", 
        function, 
        {
            "comment": "Super state (TRUE if the super state is active, or if there is no super state)",
            "type": "t_bool",
            "initial": Bool(True)
        })

    if "variables_input" in args:
        for var_name, var_args in args["variables_input"].items():
            function.var_in[var_name] = Variable(var_name, function, var_args)
    
    function.implementation = []
    elif_expr_list = []
    elif_then_list = []
    for state_name, state_args in args["states"].items():
        expr = resolve(state_args['expr'], function)
        expr.resolve_children(function)
        elif_expr_list.append(expr)
        assignment = ASSIGN([function, enum.items_by_name[state_name] ])
        assignment.resolve_children(function)
        elif_then_list.append([ assignment ])

    function.implementation = [
        IfThen(
            name = "ifthen",
            parent = function, 
            if_ = NOT(function.var_in["superState"]),
            #then_ = ASSIGN([function, resolve(f"{name}.unknown", enum)]),
            then_ = [ ASSIGN([function, enum.items_by_name["unknown"]]) ],
            elif_expr = elif_expr_list,
            elif_then = elif_then_list,
            else_ = [ ASSIGN([function, enum.items_by_name["invalid_model"]]) ]
            )
    ]

    enum.calculated_by = function

    return enum, function



def add_models(lib: Library):
    fbs = []
    lib.get_fbs(recursive=True, fbs=fbs)
    for fb in fbs:
        fb.model = Model('M_' + fb.name, lib.models)
        fb.model.render = fb.render
    
    for fb in fbs:
        if fb.extends is not None:
            fb.model.extends = fb.extends.model
    
    statemachines = []
    lib.get_statemachines(recursive=True, statemachines=statemachines)
    for sm in statemachines:
        sm: Statemachine
        assert(sm.name.startswith('SM_'))

        m = sm.model
        m: Model

        for var in list(sm.var_in.values()) + list(sm.var_local.values()) + list(sm.var_out.values()):
            var: Variable

            if var.type is None:
                raise Exception(f"Adding model for variable {var.name} of {sm.name} failed, type is None!")
            elif (QUALIFIERS.OPC_UA_ACTIVATE not in var.qualifiers) and (var.name not in ["parts", "proc"]):
                pass # skip
            elif isinstance(var.type, Primitive) or isinstance(var.type, Enum):
                v = Variable(name=var.name, parent=m)
                if QUALIFIERS.OPC_UA_ACCESS_RW in var.qualifiers:
                    v.qualifiers = [QUALIFIERS.OPC_UA_ACTIVATE, QUALIFIERS.OPC_UA_ACCESS_RW]
                else:
                    v.qualifiers = [QUALIFIERS.OPC_UA_ACTIVATE, QUALIFIERS.OPC_UA_ACCESS_R]
                v.type = var.type
                m.items[var.name] = v
            elif var.name == "stat":
                v = Variable(name=var.name, parent=m)
                v.qualifiers = [QUALIFIERS.OPC_UA_ACTIVATE, QUALIFIERS.OPC_UA_ACCESS_R]
                v.type = var.type
                m.items[var.name] = v
            elif var.name == "parts":
                parts_struct = Model(m.name + "Parts", parent=lib.models)
                for part in resolve(f'{sm.name.replace("SM_", "")}Parts', sm.parent).items.values():
                    part: Variable
                    parts_struct_var = Variable(part.name, parts_struct)
                    parts_struct_var.type = part.type.model
                    parts_struct.items[part.name] = parts_struct_var
                v = Variable(name="parts", parent=m)
                v.qualifiers = [QUALIFIERS.OPC_UA_ACTIVATE]
                v.type = parts_struct
                m.items[var.name] = v
            elif var.name == "proc":
                proc_struct = Model(m.name + "Processes", parent=lib.models)
                for proc in resolve(f'{sm.name.replace("SM_", "")}Processes', sm.parent).items.values():
                    proc: Variable
                    proc_struct_var = Variable(proc.name, proc_struct)
                    assert(isinstance(proc.type, Process))
                    proc_struct_var.type = proc.type.model
                    proc_struct.items[proc.name] = proc_struct_var
                v = Variable(name="proc", parent=m)
                v.qualifiers = [QUALIFIERS.OPC_UA_ACTIVATE]
                v.type = proc_struct
                m.items[var.name] = v
            elif isinstance(var.type, Struct):
                v = Variable(name=var.name, parent=m)
                if QUALIFIERS.OPC_UA_ACCESS_RW in var.qualifiers:
                    v.qualifiers = [QUALIFIERS.OPC_UA_ACTIVATE, QUALIFIERS.OPC_UA_ACCESS_RW]
                else:
                    v.qualifiers = [QUALIFIERS.OPC_UA_ACTIVATE, QUALIFIERS.OPC_UA_ACCESS_R]
                v.type = var.type
                m.items[var.name] = v

    processes = []
    lib.get_processes(recursive=True, processes=processes)
    for proc in processes:
        proc: Process
        
        m = proc.model
        m: Model

        for var in list(proc.var_in.values()) + list(proc.var_local.values()) + list(proc.var_out.values()):

            if var.type is None:
                raise Exception(f"Adding model for variable {var.name} of {proc.name} failed, type is None!")
            elif QUALIFIERS.OPC_UA_ACTIVATE not in var.qualifiers:
                pass # skip
            elif isinstance(var.type, Primitive) or isinstance(var.type, Enum) or isinstance(var.type, Struct):
                v = Variable(name=var.name, parent=m)
                if QUALIFIERS.OPC_UA_ACCESS_RW in var.qualifiers:
                    v.qualifiers = [QUALIFIERS.OPC_UA_ACTIVATE, QUALIFIERS.OPC_UA_ACCESS_RW]
                else:
                    v.qualifiers = [QUALIFIERS.OPC_UA_ACTIVATE, QUALIFIERS.OPC_UA_ACCESS_R]
                v.type = var.type
                m.items[var.name] = v


    fbs = []
    lib.get_fbs(recursive=True, fbs=fbs)
    for fb in fbs:

        copyFromModel = Method('_copyFromModel_' + fb.name, fb.model, 
            {
                "inOutArgs" : {
                    "model": {"type": fb.model, "qualifiers": [ QUALIFIERS.OPC_UA_DEACTIVATE ]}
                }
            })
        fb.methods['_copyFromModel_' +  fb.name] = copyFromModel
        copyFromModelArg = copyFromModel.var_inout["model"]
        copyFromModelArg: Variable

        copyToModel = Method('_copyToModel_' +  fb.name, fb.model, 
            {
                "inOutArgs" : {
                    "model": {"type": fb.model, "qualifiers": [ QUALIFIERS.OPC_UA_DEACTIVATE ]}
                }
            })
        fb.methods['_copyToModel_' +  fb.name] = copyToModel
        copyToModelArg = copyToModel.var_inout["model"]
        copyToModelArg: Variable

        copyFromModel.implementation = []
        copyToModel.implementation = []

        for item in fb.model.items.values():
            item: Variable

            if (isinstance(item.type, Primitive) or isinstance(item.type, Enum) or isinstance(item.type, Struct) or item.name == "stat") \
                and not ((item.name == "parts") or (item.name == "proc")):

                add_to_copyFromModel = (QUALIFIERS.OPC_UA_ACCESS_RW in item.qualifiers) or (QUALIFIERS.OPC_UA_ACCESS_W in item.qualifiers)
                add_to_copyToModel = not (QUALIFIERS.OPC_UA_ACCESS_W in item.qualifiers)
                if add_to_copyFromModel:
                    assignment = ASSIGN([fb.get_child(item.name), copyFromModelArg.get_child(item.name)])
                    assignment.resolve_children(lib)
                    copyFromModel.implementation.append(assignment)
                if add_to_copyToModel:
                    assignment = ASSIGN([copyToModelArg.get_child(item.name), fb.get_child(item.name)])
                    assignment.resolve_children(lib)
                    copyToModel.implementation.append(assignment)


            elif item.name == "parts" or item.name == "proc":

                parts = []
                if item.name == "parts":
                    for part in resolve(f'{fb.name.replace("SM_", "")}Parts', fb.parent).items.values():
                        parts.append(part)
                if item.name == "proc":
                    for proc in resolve(f'{fb.name.replace("SM_", "")}Processes', fb.parent).items.values():
                        parts.append(proc)
                
                for part in parts:

                    call_to = Call(f"call_to_{part.name}", fb)
                    
                    # fb.children[item.name].children[part.name] was already instantiated before we added the copyToModel and copyFromModel methods to 
                    # their type.
                    # So, these variables don't have copyToModel and copyFromModel children, and we must add them now:
                    call_to.calls = Method('_copyToModel_' + part.type.name, fb.children[item.name].children[part.name], 
                        {
                            "inOutArgs" : {
                                "model": {} # no need to specify the type, it's just a simple call
                            }
                        })
                    
                    call_to.assignments = [
                        ASSIGN([call_to.calls.get_child("model"), copyToModelArg.get_child(item.name).get_child(part.name)])
                    ]

                    copyToModel.implementation.append(call_to)
                    

                    call_from = Call(f"call_from_{part.name}", fb)
                    
                    # fb.children["parts"].children[part.name] was already instantiated before we added the copyToModel and copyFromModel methods to 
                    # their type.
                    # So, these variables don't have copyFromModel and copyFromModel children, and we must add them now:
                    call_from.calls = Method('_copyFromModel_' +  part.type.name, fb.children[item.name].children[part.name], 
                        {
                            "inOutArgs" : {
                                "model": {} # no need to specify the type, it's just a simple call
                            }
                        })
                    
                    call_from.assignments = [
                        ASSIGN([call_from.calls.get_child("model"), copyFromModelArg.get_child(item.name).get_child(part.name)])
                    ]

                    copyFromModel.implementation.append(call_from)

        if fb.extends is not None:
            
            call_to_super = Call(f"call_to_super", fb)
            call_to_super.calls = Method('_copyToModel_' + fb.extends.name, fb.children["SUPER"], 
                {
                    "inOutArgs" : {
                        "model": {} # no need to specify the type, it's just a simple call
                    }
                })
            call_to_super.assignments.append(
                ASSIGN([call_to_super.calls.children['model'], copyToModelArg])
            )
            copyToModel.implementation.append(call_to_super)
            
            call_from_super = Call(f"call_from_super", fb)
            call_from_super.calls = Method('_copyFromModel_' + fb.extends.name, fb.children["SUPER"], 
                {
                    "inOutArgs" : {
                        "model": {} # no need to specify the type, it's just a simple call
                    }
                })
            call_from_super.assignments.append(
                ASSIGN([call_from_super.calls.children['model'], copyFromModelArg])
            )
            copyFromModel.implementation.append(call_from_super)