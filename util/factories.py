from datetime import datetime
timeNow = datetime.now().isoformat()

try:
    from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
    from yaml import Loader, Dumper

from util.expressions import *
from util.objects import add_global, get_global, Object, resolve

class Primitive(Object):
    def __init__(self, name, plc_symbol=None) -> None:
        super().__init__(name, None)
        self.plc_symbol = plc_symbol


class PRIMITIVE_TYPES:
    t_bool       = Primitive("t_bool"       , plc_symbol="BOOL")
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


add_global("t_bool",       PRIMITIVE_TYPES.t_bool)
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



class PlcOpenAttribute:
    def __init__(self, symbol, value):
        self.plc_symbol = symbol
        self.value = value



class QUALIFIERS:
    OPC_UA_DEACTIVATE = PlcOpenAttribute(symbol = 'OPC.UA.DA', value = '0')
    OPC_UA_ACTIVATE = PlcOpenAttribute(symbol = 'OPC.UA.DA', value = '1')
    OPC_UA_ACCESS = PlcOpenAttribute(symbol = 'OPC.UA.DA.Access', value = '0')
    OPC_UA_ACCESS_R = PlcOpenAttribute(symbol = 'OPC.UA.DA.Access', value = '1')
    OPC_UA_ACCESS_W = PlcOpenAttribute(symbol = 'OPC.UA.DA.Access', value = '2')
    OPC_UA_ACCESS_RW = PlcOpenAttribute(symbol = 'OPC.UA.DA.Access', value = '3')



class Namespace(Object):
    def __init__(self, name, parent):
        super().__init__(name, parent)

    def __setitem__(self, name, item):
        self.register_child(name, item)
    
    def __getitem__(self, name):
        return self.children[name]

GLOBAL_NS = Namespace("GLOBAL_NS", None)

class StatemachinesNamespace(Namespace):
    def __init__(self, name, parent):
        super().__init__(name, parent)
        self.parts = Namespace("parts", self)
        self.processes = Namespace("processes", self)
        self.statuses = Namespace("statuses", self)

class ProcessesNamespace(Namespace):
    def __init__(self, name, parent):
        super().__init__(name, parent)
        self.args = Namespace("args", self)

class Library(Namespace):
    def __init__(self, name, args):
        super().__init__(name, GLOBAL_NS)  # a library has no parent!

        # define the sub-namespaces
        self.enums = Namespace("enums", self)
        self.statuses = Namespace("statuses", self)
        self.statemachines = StatemachinesNamespace("statemachines", self)
        self.configs = Namespace("configs", self)
        self.structs = Namespace("structs", self)
        self.processes = ProcessesNamespace("processes", self)

        # new:        
        self.functionblocks = Namespace("functionblocks", self)

        # add the items
        for arg_k, arg_v in args.items():
            if isinstance(arg_k, ENUMERATION):
                self.enums[arg_k.name] = Enum(arg_k.name, self, arg_v) 
            elif isinstance(arg_k, STATEMACHINE):
                sm = Statemachine(arg_k.name, self, arg_v)
                self.statemachines[arg_k.name] = sm
                self.functionblocks[arg_k.name] = sm
            elif isinstance(arg_k, STATUS):
                sts = Status(arg_k.name, self, arg_v) 
                self.statuses[arg_k.name] = sts
                self.functionblocks[arg_k.name] = sts
            elif isinstance(arg_k, CONFIG):
                cfg = Config(arg_k.name, self, arg_v) 
                self.configs[arg_k.name] = cfg
                self.structs[arg_k.name] = cfg



def check_args(name, args, allowed_args):
    for arg in args:
        if arg not in allowed_args:
            raise Exception(f"Enum {name} contains illegal argument '{arg}' (allowed: {allowed_args})")


class Enum(Object):
    def __init__(self, name, parent, args={}):
        super().__init__(name, parent)
        check_args("Enum", args, ["type", "items", "comment"])
        
        self.type = None
        self.items = []
        self.comment = None
        self.plc_symbol = None

        if 'comment' in args:
            self.comment = args['comment']
        
        if 'type' in args:
            self.type = resolve(args['type'], self)

        if 'items' in args:
            for item_number, item_name in enumerate(args['items']):
                self.items.append(EnumItem(item_name, self, item_number))


def ENUM_constructor(loader: Loader, node):
    mapping = loader.construct_mapping(node)
    for name, args in mapping.items():
        return Enum(name, args['parent'], args)

class ENUMERATION:
    def __init__(self, name):
        self.name = name

def ENUMERATION_constructor(loader: Loader, node):
    name = loader.construct_scalar(node)
    return ENUMERATION(name)

class LIBRARY:
    def __init__(self, name):
        self.name = name

def LIBRARY_constructor(loader: Loader, node):
    name = loader.construct_scalar(node)
    return LIBRARY(name)


class STATEMACHINE:
    def __init__(self, name):
        self.name = name

def STATEMACHINE_constructor(loader: Loader, node):
    name = loader.construct_scalar(node)
    return STATEMACHINE(name)

class STATUS:
    def __init__(self, name):
        self.name = name

def STATUS_constructor(loader: Loader, node):
    name = loader.construct_scalar(node)
    return STATUS(name)

class CONFIG:
    def __init__(self, name):
        self.name = name

def CONFIG_constructor(loader: Loader, node):
    name = loader.construct_scalar(node)
    return CONFIG(name)

class Variable(Object):
    def __init__(self, name, parent, args={}):
        super().__init__(name, parent)
        check_args("Variable", args, 
                   ["type", "expand", "initial", "comment",
                    "pointsToType", "attributes", "qualifiers", "arguments",
                    "address", "copyFrom"])
        
        if 'type' in args and 'pointsToType' in args:
            raise Exception(f"Variable {name} contains BOTH 'type' and 'pointsToType', this is not allowed!")
        
        self.type = None
        self.expand = None
        self.initial = None
        self.comment = None
        self.pointsToType = None
        self.attributes = None
        self.qualifiers = []
        self.arguments = None
        self.address = None
        self.copyFrom = None

        if 'type' in args:
            self.type = resolve(args['type'], self)
            for child_name in self.type.children:
                self.register_child(child_name, Variable(child_name, self))
        if 'expand' in args:
            self.expand = args['expand']
        if 'initial' in args:
            self.initial = args['initial']
        if 'comment' in args:
            self.comment = args['comment']
        if 'pointsToType' in args:
            self.pointsToType = resolve(args['pointsToType'], self)
        if 'attributes' in args:
            self.attributes = {}
            for attribute_k, attribute_v in args['attributes'].items():
                self.attributes[attribute_k] = Variable(attribute_k, self, attribute_v)
        if 'qualifiers' in args:
            for qualifier in args['qualifiers']:
                # TODO: resolve?
                self.qualifiers.append(qualifier)
        if 'arguments' in args:
            self.arguments = {}
            for argument_k, argument_v in args['arguments'].items():
                self.arguments[argument_k] = Variable(argument_k, self, argument_v)

        if 'address' in args:
            self.address = args['address']
        if 'copyFrom' in args:
            self.copyFrom = args['copyFrom']

        if 'expand' in args:
            raise NotImplemented("expand is not implemented yet")
        if 'copyFrom' in args:
            raise NotImplemented("expand is not implemented yet")



class EnumItem(Variable):
    def __init__(self, name, parent, number) -> None:
        super().__init__(name, parent)
        self.number = number




class GlobalVariable(Variable):
    pass

class Struct(Object):

    def __init__(self, name, parent, args={}) -> None:
        super().__init__(name, parent)
        self.items = None
        self.plc_symbol = None
        for arg in args:
            #if arg not in ["containedBy", "typeOf", "items", "comment", "label"]:
            if arg not in ["items", "comment"]:
                raise Exception(f"Struct {name} contains illegal argument '{arg}'")
        
        if 'comment' in args:
            self.comment = args['comment']

        if 'items' in args:
            self.items = {}
            for item_k, item_v in args['items'].items():
                self.items[item_k] = Variable(item_k, self, item_v)



# TODO: convert to Object ????
class Call:
    
    def __init__(self, name, lib, args={}) -> None:
        self.name = name
        self.lib = lib
        check_args("Call", args, 
                   ["calls", "assigns"])
        self.calls = None
        self.assignments = []
        
class IfThen:
    
    def __init__(self, name, lib, args={}) -> None:
        self.name = name
        self.lib = lib
        check_args("IfThen", args, 
                   ["if", "then", "else"])
        self._if = None
        self._then = None
        self._else = None

class Method(Object):

    def __init__(self, name, parent, args={}) -> None:
        super().__init__(name, parent)
        check_args("Method", args, 
            ["inputArgs", "inOutArgs", "localArgs", "returnType", 
             "comment", "implementation"])
        
        self.comment = None
        self.var_in = {}
        self.var_inout = {}
        self.var_local = {}
        self.var_out = {} # only here for backwards compatibility
        self.return_type = None
        self.implementation = None
        self.extends = None

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
            for child_name in self.return_type.children:
                self.register_child(child_name, Variable(child_name, self.return_type))
        
        if "implementation" in args:
            raise NotImplementedError()


class FunctionBlock(Object):
    
    def __init__(self, name, parent, args={}) -> None:
        super().__init__(name, parent)
        check_args("FunctionBlock", args, 
                   ["typeOf", "extends", "comment", "in", "out", "inout"])
        
        self.var_in = {}
        self.var_out = {}
        self.var_inout = {}
        self.var_local = {}
        self.extends = None
        self.methods = {}
        self.plc_symbol = None
        self.implementation = None

        if "extends" in args:
            self.extends = resolve(args["extends"], self)
            for child_name, child in self.extends.children.items():
                self.register_child(child_name, child)


class Status(FunctionBlock):
    
    def __init__(self, name, parent, args={}) -> None:
        super().__init__(name, parent)
        check_args("Status", args, ["variables", "states"])

        self.variables = {}
        self.states = {}

        self.var_in["superState"] = Variable(
            "superState", 
            self, 
            {
                "comment": "Super state (TRUE if the super state is active, or if there is no super state)",
                "type": "t_bool",
                "initial": True
            })

        if "variables" in args:
            for var_name, var_args in args["variables"].items():
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
            assignment = ASSIGN(self.get_child(state_name), AND( state_args['expr'], self.get_child('superState') ))
            assignment.resolve_children(self)
            self.implementation.append(assignment)
        

class Config(Struct):
    
    def __init__(self, name, parent, args={}) -> None:
        super().__init__(name, parent, args)


class Statemachine(FunctionBlock):

    def __init__(self, name, parent, args={}) -> None:
        super().__init__(f"SM_{name}", parent)
        
        check_args("Statemachine", args,
                   ["variables", "variables_hidden", "variables_read_only",
                    "statuses", "parts", "local", "methods", "calls",
                    "disabled_calls", "updates", "references", "extends",
                    "processes", "constraints"])
        

        self.extends = None
        self.variables = {}
        self.variables_hidden = {}
        self.variables_read_only = {}
        self.statuses = {}
        self.parts = {}
        self.local = {}
        self.methods = {}
        

        if 'extends' in args:
            raise NotImplemented(f"SM_{name}: 'extends' is not implemented yet")

        self.varNames = []
        self.statusNames = []
        self.partNames = []
        self.processNames = []
        self.disabledCallNames = []

        if "actualStatus" not in self.var_out:
            v = Variable("actualStatus", self)
            v.type = PRIMITIVE_TYPES.t_string
            v.comment = "Current status description"
            v.qualifiers = [QUALIFIERS.OPC_UA_ACTIVATE, QUALIFIERS.OPC_UA_ACCESS_R]
            self.var_out['actualStatus'] = v
        
        if "previousStatus" not in self.var_out:
            v = Variable("previousStatus", self)
            v.type = PRIMITIVE_TYPES.t_string
            v.comment = "Previous status description"
            self.var_out["previousStatus"] = v

        if "variables" in args:
            for var_name, var in args['variables'].items():
                v = Variable(var_name, self, var)
                self.varNames.append(var_name)
                if len(v.qualifiers) == 0:
                    v.qualifiers = [QUALIFIERS.OPC_UA_ACTIVATE, QUALIFIERS.OPC_UA_ACCESS_R]
                self.var_in[var_name] = v

        if "variables_read_only" in args:
            for var_name, var in args['variables_read_only'].items():
                v = Variable(var_name, self, var)
                self.varNames.append(var_name)
                if v.qualifiers is None:
                    v.qualifiers = [QUALIFIERS.OPC_UA_ACTIVATE, QUALIFIERS.OPC_UA_ACCESS_R]
                self.var_out[var_name] = v

        if "variables_hidden" in args:
            for var_name, var in args['variables_hidden'].items():
                v = Variable(var_name, self, var)
                self.varNames.append(var_name)
                if v.qualifiers is None:
                    v.qualifiers = [QUALIFIERS.OPC_UA_DEACTIVATE]
                self.var_in[var_name] = v

        if "references" in args:
            for var_name, var in args['variables'].items():
                v = Variable(var_name, self, var)
                if v.qualifiers is None:
                    v.qualifiers = [QUALIFIERS.OPC_UA_DEACTIVATE]
                self.var_inout[var_name] = v

        if "statuses" in args:
            for status_name in args['statuses']:
                self.statusNames.append(status_name)
            struct = Struct(
                name = f'{name}Statuses',
                parent = self.parent,
                args = { "items": args['statuses'] }
            )
            self.parent["StateMachines"]["Statuses"].append(struct)
            self.parent.structs.append(struct)
            self.var_out["statuses"] = Variable(
                name='statuses', 
                parent=self,
                args = {
                    "comment": "Statuses of the state machine",
                    "type": f'{name}Statuses'})
        
        if "parts" in args:
            raise NotImplementedError()
            for part_name, part in kwargs['statuses']:
                self.partNames.append(part_name)
            struct = Struct(
                name = f'{name}Parts',
                lib = lib,
                items = kwargs['parts'])
            #ns["items"].append(struct)
            lib["StateMachines"]["Parts"].append(struct)
            # TODO arguments, attributes, ...
            self.var_out[part_name] = Variable(
                name='parts', 
                lib=lib,
                type=struct,
                comment="Parts of the state machine")

        # calls of members can be disabled e.g. in case a  
        # separte PLC program (at a faster cycle time) calls
        # the member (as for the 'axes' member of MTCS)
        if "disabled_calls" in args:
            raise NotImplementedError()
            self.disabledCallNames.append(kwargs["disabled_calls"])

        if "processes" in args:
            raise NotImplementedError()
            struct = Struct(
                name = f'{name}Processes',
                lib = lib,
                items = kwargs['processes'])
            lib["StateMachines"]["Processes"].append(struct)
            self.var_out[part_name] = Variable(
                name='processes', 
                lib=lib,
                type=struct,
                comment="Processes of the state machine")

        # ============ IMPLEMENTATION PART ============


        if "calls" in args:
            for call_name, call in args['calls'].items():
                c = Call(f"call_var_{call_name}", self)
                c.calls = resolve(call_name, self)
                c.assignments = []
                for k, v in call.items():
                    # k should be a child of the callee (c.calls)!
                    assignment = ASSIGN(c.calls.get_child(k, recursive=False), v)
                    assignment.resolve_children(self)
                    c.assignments.append(assignment)

                if self.implementation is None:
                    self.implementation = []

                self.implementation.append(c)


        if not '_log' in self.methods:
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
                ASSIGN(get_global("LOGGER").get_child("name"), m.get_child("name")),
                ASSIGN(get_global("LOGGER").get_child("actualStatus"), self.get_child("actualStatus")),
                ASSIGN(get_global("LOGGER").get_child("previousStatus"), self.get_child("previousStatus")),
                ASSIGN(get_global("LOGGER").get_child("buffer"), m.get_child("buffer")),
                ASSIGN(get_global("LOGGER").get_child("subBuffer"), m.get_child("subBuffer"))
            ]

            m.implementation.append(c)

            self.methods["_log"] = m

        # finally, also add the main state machine (to be implemented by the user):
        self.parent.register_child(
            name, 
            FunctionBlock(name, self.parent, { "extends": f"SM_{name}" }))






add_global("LogBuffer", Struct(name="LogBuffer", parent=None))


add_global("LOGGER", GlobalVariable(name="LOGGER", 
                                    parent=None, 
                                    args={ "arguments": 
                                            {
                                              "name": {"type": "t_string"},
                                              "actualStatus" : {"type": "t_string"},
                                              "previousStatus" : {"type": "t_string"},
                                              "buffer" : {"type": "LogBuffer"},
                                              "subBuffer" : {"type": "LogBuffer"}
                                            }
                                    }))
