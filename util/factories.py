from datetime import datetime
timeNow = datetime.now().isoformat()

from util.expressions import *


class Primitive:
    def __init__(self, name, plc_symbol=None) -> None:
        self.name = name
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

OBJECTS = {
    "t_bool"       : PRIMITIVE_TYPES.t_bool,
    "t_bytestring" : PRIMITIVE_TYPES.t_bytestring,
    "t_double"     : PRIMITIVE_TYPES.t_double,
    "t_float"      : PRIMITIVE_TYPES.t_float,
    "t_int16"      : PRIMITIVE_TYPES.t_int16,
    "t_int32"      : PRIMITIVE_TYPES.t_int32,
    "t_int64"      : PRIMITIVE_TYPES.t_int64,
    "t_int8"       : PRIMITIVE_TYPES.t_int8,
    "t_uint16"     : PRIMITIVE_TYPES.t_uint16,
    "t_uint32"     : PRIMITIVE_TYPES.t_uint32,
    "t_uint64"     : PRIMITIVE_TYPES.t_uint64,
    "t_uint8"      : PRIMITIVE_TYPES.t_uint8,
    "t_string"     : PRIMITIVE_TYPES.t_string
}


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



class Namespace(dict):
    def __init__(self, name):
        dict.__init__(self)
        self.name = name
        self.objects = {}

    def get_object(self, name):
        if name in self.objects:
            return self.objects[name]

class StatemachinesNamespace(Namespace):
    def __init__(self, name):
        super().__init__(name)
        self.parts = Namespace("parts")
        self.processes = Namespace("processes")
        self.statuses = Namespace("statuses")

class ProcessesNamespace(Namespace):
    def __init__(self, name):
        super().__init__(name)
        self.args = Namespace("args")

class Library(Namespace):
    def __init__(self, args):
        super().__init__(args['name'])
        self.owner = None

        # define the sub-namespaces
        self.enums = Namespace("enums")
        self.statuses = Namespace("statuses")
        self.statemachines = StatemachinesNamespace("statemachines")
        self.configs = Namespace("configs")
        self.structs = Namespace("structs")
        self.processes = ProcessesNamespace("processes")

        # new:        
        self.functionblocks = Namespace("functionblocks")


        # add the enums
        for enum_k, enum_v in args['enums'].items():
            self.enums[enum_k] = Enum(enum_k, self, enum_v)
        
        # add the statemachines
        for sm_k, sm_v in args['statemachines'].items():
            sm = Statemachine(sm_k, self, sm_v)
            self.statemachines[sm_k] = sm
            self.functionblocks[sm_k] = sm


# def resolve_object(name: str, context):
#     obj = None
#     if context is not None:
#         obj = context.get_object(name)
#     if obj is None:
#         global OBJECTS
#         if name in OBJECTS:
#             obj = OBJECTS[name]
#     if obj is not None:
#         return obj
#     else:
#         raise KeyError(f"Object '{name}' was not declared before!")


def resolve_object(name: str, context):

    parts = name.split('.')
    if len(parts) > 1:
        return resolve_object( name[len(f"{parts[0]}."):], resolve_object(parts[0], context) )

    obj = None
    if context is not None:
        obj = context.get_object(name)
    
    if obj is None:
        global OBJECTS
        if name in OBJECTS:
            obj = OBJECTS[name]
    
    if obj is not None:
        return obj
    else:
        raise KeyError(f"Object '{name}' was not declared before!")


def check_args(name, args, allowed_args):
    for arg in args:
        if arg not in allowed_args:
            raise Exception(f"Enum {name} contains illegal argument '{arg}' (allowed: {allowed_args})")

class Object:
    def __init__(self, name, owner) -> None:
        self.name = name
        self.owner = owner
        self.owner.objects[name] = self
        global OBJECTS
        OBJECTS[f"{owner.name}.{name}"] = self


class Enum(Object):
    def __init__(self, name, owner, args):
        super().__init__(name, owner)
        check_args("Enum", args, ["type", "items", "comment"])
        
        self.type = None
        self.items = []
        self.comment = None
        self.plc_symbol = None
        self.objects = {}

        if 'comment' in args:
            self.comment = args['comment']
        
        if 'type' in args:
            self.type = resolve_object(args['type'], self)

        if 'items' in args:
            for item_number, item_name in enumerate(args['items']):
                item = EnumItem(item_name, self, item_number)
                self.items.append(item)
                self.objects[item_name] = item
        

    def get_object(self, name):
        return self.objects[name]
        

        

class Variable(Object):
    def __init__(self, name, owner, args={}):
        super().__init__(name, owner)
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
        self.qualifiers = None
        self.arguments = None
        self.address = None
        self.copyFrom = None

        if 'type' in args:
            self.type = resolve_object(args['type'], self)
        if 'expand' in args:
            self.expand = args['expand']
        if 'initial' in args:
            self.initial = args['initial']
        if 'comment' in args:
            self.comment = args['comment']
        if 'pointsToType' in args:
            self.pointsToType = resolve_object(args['pointsToType'], self)
        if 'attributes' in args:
            self.attributes = args['attributes']
        if 'qualifiers' in args:
            self.qualifiers = args['qualifiers']
        if 'arguments' in args:
            self.arguments = args['arguments']
        if 'address' in args:
            self.address = args['address']
        if 'copyFrom' in args:
            self.copyFrom = args['copyFrom']

        if 'expand' in args:
            raise NotImplemented("expand is not implemented yet")
        if 'copyFrom' in args:
            raise NotImplemented("expand is not implemented yet")

    def get_object(self, name):
        for d in [self.attributes, self.qualifiers, self.arguments]:
            if d is not None:
                if name in d:
                    return d[name]
        return self.owner.get_object(name)



class EnumItem(Variable):
    def __init__(self, name, owner, number) -> None:
        super().__init__(name, owner)
        self.number = number




class GlobalVariable(Variable):
    pass

class Struct:

    def __init__(self, name, lib, args={}) -> None:
        self.name = name
        self.lib = lib
        self.items = []
        for arg in args:
            #if arg not in ["containedBy", "typeOf", "items", "comment", "label"]:
            if arg not in ["items", "comment"]:
                raise Exception(f"Struct {name} contains illegal argument '{arg}'")
        
        if 'comment' in args:
            self.comment = args['comment']

        if 'items' in args:
            for item in args['items']:
                self.items.append(item)
        


class Call:
    
    def __init__(self, name, lib, args={}) -> None:
        self.name = name
        self.lib = lib
        check_args("Call", args, 
                   ["calls", "assigns"])
        self.calls = None
        self.assignments = None
        
class IfThen:
    
    def __init__(self, name, lib, args={}) -> None:
        self.name = name
        self.lib = lib
        check_args("IfThen", args, 
                   ["if", "then", "else"])
        self._if = None
        self._then = None
        self._else = None

class Method:

    def __init__(self) -> None:
        pass

class FunctionBlock(Object):
    
    def __init__(self, name, lib, args={}) -> None:
        super().__init__(name, lib)
        check_args("FunctionBlock", args, 
                   ["typeOf", "extends", "comment", "in", "out", "inout"])
        
        self.var_in = {}
        self.var_out = {}
        self.var_inout = {}
        self.var_local = {}
        self.plc_symbol = None
        self.implementation = None

    def get_object(self, name):
        for d in [self.var_in, self.var_out, self.var_inout, self.var_local]:
            if name in d:
                return d[name]
        return self.owner.get_object(name)


class Statemachine(FunctionBlock):

    def __init__(self, name, lib, args={}) -> None:
        super().__init__(name, lib)
        
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
            raise NotImplemented(f"{name}: 'extends' is not implemented yet")

        self.varNames = []
        self.statusNames = []
        self.partNames = []
        self.processNames = []
        self.disabledCallNames = []

        if "actualStatus" not in self.var_out:
            v = Variable("actualStatus", lib)
            v.type = PRIMITIVE_TYPES.t_string
            v.comment = "Current status description"
            v.qualifiers = [QUALIFIERS.OPC_UA_ACTIVATE, QUALIFIERS.OPC_UA_ACCESS_R]
            self.var_out['actualStatus'] = v
        
        if "previousStatus" not in self.var_out:
            v = Variable("previousStatus", lib)
            v.type = PRIMITIVE_TYPES.t_string
            v.comment = "Previous status description"
            self.var_out["previousStatus"] = v

        if "variables" in args:
            for var_name, var in args['variables'].items():
                v = Variable(var_name, lib, var)
                self.varNames.append(var_name)
                if v.qualifiers is None:
                    v.qualifiers = [QUALIFIERS.OPC_UA_ACTIVATE, QUALIFIERS.OPC_UA_ACCESS_R]
                self.var_in[var_name] = v

        if "variables_read_only" in args:
            for var_name, var in args['variables_read_only'].items():
                v = Variable(var_name, lib, var)
                self.varNames.append(var_name)
                if v.qualifiers is None:
                    v.qualifiers = [QUALIFIERS.OPC_UA_ACTIVATE, QUALIFIERS.OPC_UA_ACCESS_R]
                self.var_out[var_name] = v

        if "variables_hidden" in args:
            for var_name, var in args['variables_hidden'].items():
                v = Variable(var_name, lib, var)
                self.varNames.append(var_name)
                if v.qualifiers is None:
                    v.qualifiers = [QUALIFIERS.OPC_UA_DEACTIVATE]
                self.var_in[var_name] = v

        if "references" in args:
            for var_name, var in args['variables'].items():
                v = Variable(var_name, lib, var)
                if v.qualifiers is None:
                    v.qualifiers = [QUALIFIERS.OPC_UA_DEACTIVATE]
                self.var_inout[var_name] = v

        if "statuses" in args:
            raise NotImplementedError()
            for status_name, status in kwargs['statuses']:
                self.statusNames.append(status_name)
            struct = Struct(
                name = f'{name}Statuses',
                lib = lib,
                items = kwargs['statuses'])
            #ns["items"].append(struct)
            lib["StateMachines"]["Statuses"].append(struct)
            self.var_out[status_name] = Variable(
                name='statuses', 
                lib=lib,
                type=struct,
                comment="Statuses of the state machine")
        
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
                c = Call(f"call_var_{call_name}", lib)
                c.calls = resolve_object(call_name, self)
                c.assignments = []
                for k, v in call.items():
                    if k not in self.disabledCallNames:
                        k_obj = resolve_object(k, self)
                        if isinstance(v, str):
                            v_obj = resolve_object(v, self)
                        elif isinstance(v, Expression):
                            v.apply_resolver(resolve_object, self)
                            v_obj = v
                        c.assignments.append(ASSIGN(k_obj, v_obj))
                
                if self.implementation is None:
                    self.implementation = []

                self.implementation.append(c)




