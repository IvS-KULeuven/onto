from util.objects import Object
from util.versions import is_marvel, is_mtcs, statuses, processes

class Operator:
    """
    Operator of an expression.
    """
    def __init__(self, name, plc_symbol=None) -> None:
        self.name = name
        self.plc_symbol = plc_symbol


class Expression(Object):
    """
    Base class for UnaryExpression and BinaryExpression.
    """
    def __init__(self, operator: Operator) -> None:
        super().__init__(None, None)
        self.operator = operator


class UnaryOperation(Expression):
    """
    Base class for unary operations like NOT, ADR, ...
    """

    def __init__(self, operand: Object, operator: Operator) -> None:
        super().__init__(operator)
        self.operand = operand
        self.register_child("operand", operand)
    
    def resolve_children(self, context):
        super().resolve_children(context)
        self.operand = self.children["operand"]


class BinaryOperation(Expression):
    """
    Base class for binary operations like AND, SUM, ...
    """

    def __init__(self, operands: list[Object], operator: Operator) -> None:
        super().__init__(operator)
        self.left = operands[0]
        if len(operands) > 2:
            self.right = BinaryOperation(operands[1:], operator)
        else:
            self.right = operands[1]
        self.register_child("left", self.left)
        self.register_child("right", self.right)
    
    def resolve_children(self, context):
        super().resolve_children(context)
        self.left = self.children["left"]
        self.right = self.children["right"]


class IfThen(Object):
    """
    If-then-else construct (holding if/then/else expressions).
    """

    def __init__(self, 
                 name: str, 
                 parent: Object, 
                 if_: Expression, 
                 then_: list[Expression],
                 elif_expr : list[list[Expression]] = None,
                 elif_then : list[list[Expression]] = None,
                 else_: list[Expression] = None) -> None:
        super().__init__(name, parent)
        # the _ suffix is just to avoid Python literals
        self.if_ = if_
        self.then_ = then_
        self.elif_expr = elif_expr
        self.elif_then = elif_then
        self.else_ = else_


#####################################################################################
## OPERATOR instances
#####################################################################################


class OPERATORS:
    """
    This class defines a list of operators.
    """
    ASSIGN = Operator("ASSIGN", ":=")
    ABS = Operator("ABS", "ABS")
    SUM = Operator("SUM", "+")
    SUB = Operator("SUB", "-")
    MUL = Operator("MUL", "*")
    DIV = Operator("DIV", "/")
    POW = Operator("POW", "POW")
    NEG = Operator("NEG", "-")
    AND = Operator("AND", "AND")
    OR  = Operator("OR", "OR")
    NOT = Operator("NOT", "NOT")
    ADR = Operator("ADR", "ADR")
    EQ = Operator("EQ", "=")
    GT = Operator("GT", ">")
    LT = Operator("LT", "<")
    GE = Operator("GE", ">=")
    LE = Operator("LE", "<=")
    PLC_DEREF = Operator("PLC_DEREF", "^")


#####################################################################################
## Operation classes
#####################################################################################


class ASSIGN(BinaryOperation):
    """Operation :="""
    def __init__(self, operands) -> None:
        super().__init__(operands, OPERATORS.ASSIGN)


class AND(BinaryOperation):
    """Operation AND"""
    def __init__(self, operands) -> None:
        super().__init__(operands, OPERATORS.AND)

class OR(BinaryOperation):
    """Operation OR"""
    def __init__(self, operands) -> None:
        super().__init__(operands, OPERATORS.OR)

class EQ(BinaryOperation):
    """Operation ="""
    def __init__(self, operands) -> None:
        super().__init__(operands, OPERATORS.EQ)

class LT(BinaryOperation):
    """Operation <"""
    def __init__(self, operands) -> None:
        super().__init__(operands, OPERATORS.LT)

class GT(BinaryOperation):
    """Operation >"""
    def __init__(self, operands) -> None:
        super().__init__(operands, OPERATORS.GT)

class GE(BinaryOperation):
    """Operation >="""
    def __init__(self, operands) -> None:
        super().__init__(operands, OPERATORS.GE)

class LE(BinaryOperation):
    """Operation <="""
    def __init__(self, operands) -> None:
        super().__init__(operands, OPERATORS.LE)

class NOT(UnaryOperation):
    """Operation NOT"""
    def __init__(self, operand) -> None:
        super().__init__(operand, OPERATORS.NOT)

class ADR(UnaryOperation):
    """Operation ADR"""
    def __init__(self, operand) -> None:
        super().__init__(operand, OPERATORS.ADR)

class PLC_DEREF(UnaryOperation):
    """Operation ^"""
    def __init__(self, operand) -> None:
        super().__init__(operand, OPERATORS.PLC_DEREF)


#####################################################################################
## Helper classes to create custom pyyaml constructors (such as !AND)
#####################################################################################


def load_unary_sequence(name, loader, node):
    """Helper function to load a sequency of exactly 1 item"""
    values = loader.construct_sequence(node)
    if len(values) != 1:
        raise Exception(f"Unary operation {name} {str(values)} requires " \
                        f"exactly 1 argument, not {len(values)}!")
    return values

def load_binary_sequence(name, loader, node):
    """Helper function to load a sequence of minimum 2 items"""
    values = loader.construct_sequence(node)
    if len(values) < 2:
        raise Exception(f"Binary operation {name} {str(values)} requires at " \
                        f"least 2 arguments, not {len(values)}!")
    return values


#####################################################################################
## Custom pyyaml constructors (such as !AND)
#####################################################################################

# unary constructors

def NOT_constructor(loader, node):
    values = load_unary_sequence("NOT", loader, node)
    return NOT(values[0])
def ADR_constructor(loader, node):
    values = load_unary_sequence("ADR", loader, node)
    return ADR(values[0])

# binary constructors

def ASSIGN_constructor(loader, node):
    values = load_binary_sequence("ASSIGN", loader, node)
    return ASSIGN(values)
def AND_constructor(loader, node):
    values = load_binary_sequence("AND", loader, node)
    return AND(values)
def OR_constructor(loader, node):
    values = load_binary_sequence("OR", loader, node)
    return OR(values)
def EQ_constructor(loader, node):
    values = load_binary_sequence("EQ", loader, node)
    return EQ(values)
def GT_constructor(loader, node):
    values = load_binary_sequence("GT", loader, node)
    return GT(values)
def LT_constructor(loader, node):
    values = load_binary_sequence("LT", loader, node)
    return LT(values)
def GE_constructor(loader, node):
    values = load_binary_sequence("GE", loader, node)
    return GE(values)
def LE_constructor(loader, node):
    values = load_binary_sequence("LE", loader, node)
    return LE(values)


#####################################################################################
## Primitive classes
#####################################################################################


class Primitive(Object):
    def __init__(self, value) -> None:
        super().__init__(None, None)
        self.value = value


class Bool(Primitive):
    def __init__(self, value: str) -> None:
        if str(value).upper() == "TRUE":
            v = True
        elif str(value).upper() == "FALSE":
            v = False
        else:
            raise Exception(f"Invalid argument '{str(value)}' for BOOL, must be either TRUE or FALSE (case insensitive)")
        super().__init__(v)

class Bit(Primitive):
    def __init__(self, value: str) -> None:
        if str(value).upper() == "TRUE":
            v = True
        elif str(value).upper() == "FALSE":
            v = False
        else:
            raise Exception(f"Invalid argument '{str(value)}' for BIT, must be either TRUE or FALSE (case insensitive)")
        super().__init__(v)

class UInt8(Primitive):
    def __init__(self, value: str) -> None:
        try:
            v = int(value)
        except:
            v = eval(value)
        super().__init__(v)

class Double(Primitive):
    def __init__(self, value: str) -> None:
        try:
            v = float(value)
        except:
            v = float(eval(value))
        super().__init__(v)

class UInt16(Primitive):
    def __init__(self, value: str) -> None:
        try:
            v = int(value)
        except:
            v = eval(value)
        super().__init__(v)

class Int16(Primitive):
    def __init__(self, value: str) -> None:
        try:
            v = int(value)
        except:
            v = eval(value)
        super().__init__(v)

class String(Primitive):
    def __init__(self, value: str) -> None:
        super().__init__(str(value))


#####################################################################################
## Custom pyyaml constructors (such as !DOUBLE)
#####################################################################################

def Bool_constructor(loader, node):
    value = loader.construct_scalar(node)
    return Bool(value)

def Bit_constructor(loader, node):
    value = loader.construct_scalar(node)
    return Bit(value)

def UInt8_constructor(loader, node):
    value = loader.construct_scalar(node)
    return UInt8(value)

def UInt16_constructor(loader, node):
    value = loader.construct_scalar(node)
    return UInt16(value)

def Int16_constructor(loader, node):
    value = loader.construct_scalar(node)
    return Int16(value)

def Double_constructor(loader, node):
    value = loader.construct_scalar(node)
    return Double(value)

def String_constructor(loader, node):
    value = loader.construct_scalar(node)
    return String(value)


#####################################################################################
## MTCS_SUMMARIZE_... operations
#####################################################################################


class MTCS_SUMMARIZE_BUSY(BinaryOperation):
    def __init__(self, operands) -> None:
        new_operands = []
        if is_mtcs():
            for operand in operands:
                new_operands.append(f"{operand}.{statuses()}.busyStatus.busy")
        elif is_marvel():
            for operand in operands:
                new_operands.append(EQ([f"{operand}.{statuses()}.busy", "marvel_common.BusyStatus.busy"]))
        else:
            raise Exception("Invalid version")

        super().__init__(new_operands, OPERATORS.OR)

class MTCS_SUMMARIZE_GOOD(BinaryOperation):
    def __init__(self, operands) -> None:
        new_operands = []
        if is_mtcs():
            for operand in operands:
                new_operands.append(f"{operand}.{statuses()}.healthStatus.isGood")
        elif is_marvel():
            for operand in operands:
                new_operands.append(OR([EQ([f"{operand}.{statuses()}.health", "marvel_common.HealthStatus.good"]),
                                        EQ([f"{operand}.{statuses()}.health", "marvel_common.HealthStatus.warning"])]))
        else:
            raise Exception("Invalid version")

        super().__init__(new_operands, OPERATORS.AND)

class MTCS_SUMMARIZE_WARN(BinaryOperation):
    def __init__(self, operands) -> None:
        new_operands = []
        if is_mtcs():
            for operand in operands:
                new_operands.append(f"{operand}.{statuses()}.healthStatus.hasWarning")
        elif is_marvel():
            for operand in operands:
                new_operands.append(EQ([f"{operand}.{statuses()}.health", "marvel_common.HealthStatus.warning"]))
        else:
            raise Exception("Invalid version")
        super().__init__(new_operands, OPERATORS.OR)

class MTCS_SUMMARIZE_GOOD_OR_DISABLED(BinaryOperation):
    def __init__(self, operands) -> None:
        new_operands = []
        if is_mtcs():
            for operand in operands:
                new_operands.append(OR([f"{operand}.{statuses()}.healthStatus.isGood", 
                                        f"{operand}.{statuses()}.enabledStatus.disabled"]))
        elif is_marvel():
            for operand in operands:
                new_operands.append(OR([NOT( EQ([f"{operand}.{statuses()}.health", "marvel_common.HealthStatus.bad"]) ), 
                                        EQ([f"{operand}.{statuses()}.enabled", "marvel_common.EnabledStatus.disabled"])]))
        else:
            raise Exception("Invalid version")
        
        super().__init__(new_operands, OPERATORS.AND)


#####################################################################################
## Custom pyyaml constructors (such as !MTCS_SUMMARIZE_BUSY)
#####################################################################################


def MTCS_SUMMARIZE_BUSY_constructor(loader, node):
    values = load_binary_sequence("MTCS_SUMMARIZE_BUSY", loader, node)
    return MTCS_SUMMARIZE_BUSY(values)

def MTCS_SUMMARIZE_GOOD_constructor(loader, node):
    values = load_binary_sequence("MTCS_SUMMARIZE_GOOD", loader, node)
    return MTCS_SUMMARIZE_GOOD(values)

def MTCS_SUMMARIZE_WARN_constructor(loader, node):
    values = load_binary_sequence("MTCS_SUMMARIZE_WARN", loader, node)
    return MTCS_SUMMARIZE_WARN(values)

def MTCS_SUMMARIZE_GOOD_OR_DISABLED_constructor(loader, node):
    values = load_binary_sequence("MTCS_SUMMARIZE_GOOD_OR_DISABLED", loader, node)
    return MTCS_SUMMARIZE_GOOD_OR_DISABLED(values)







class Array(Object):
    """
    Representation of arrays.
    """
    def __init__(self, lower, upper, type, type_len=None) -> None:
        super().__init__(None, None)
        self.lower = lower
        self.upper = upper
        self.type = type
        self.len = type_len
        self.type_len = type_len
        self.register_child("type", type)
    
    def resolve_children(self, context):
        super().resolve_children(context)
        self.type = self.children["type"]
        self.type.len = self.type_len

def ARRAY_constructor(loader, node):
    values = loader.construct_sequence(node)
    if len(values) == 3:
        return Array(values[0], values[1], values[2])
    elif len(values) == 4:
        return Array(values[0], values[1], values[2], values[3])
    else:
        raise Exception(f"Array [{str(values)}] requires exactly 3 or 4 " \
                        f"arguments (lower, upper, type [,type_len]), not {len(values)}!")
