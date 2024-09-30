
from util.objects import Object, resolve

class Operator:
    def __init__(self, name, plc_symbol=None) -> None:
        self.name = name
        self.plc_symbol = plc_symbol

class OPERATORS:
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


class Expression(Object):
    def __init__(self, operator) -> None:
        super().__init__(None, None)
        self.operator = operator
    
class IfThen(Object):
    def __init__(self, name: str, parent: Object, if_: Expression, then_: list[Expression], else_: list[Expression] = None) -> None:
        super().__init__(name, parent)
        self.if_ = if_
        self.then_ = then_
        self.else_ = else_
        self.register_child("if", if_)
        # for i, expr in enumerate(then_):
        #     self.register_child(f"then_{i}", expr)
        # if else_ is not None:
        #     for i, expr in enumerate(else_):
        #         self.register_child(f"else_{i}", expr)
        
    # def resolve_children(self, context):
    #     super().resolve_children(context)
    #     self.if_ = self.children["if"]




class UnaryOperation(Expression):
    def __init__(self, operand, operator) -> None:
        super().__init__(operator)
        self.operand = operand
        self.register_child("operand", operand)
    
    def resolve_children(self, context):
        super().resolve_children(context)
        self.operand = self.children["operand"]


class BinaryOperation(Expression):
    def __init__(self, operands, operator) -> None:
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

class RecursiveExpression:
    def __init__(self, items, operator) -> None:
        self.items = items
        self.operator = operator


class ASSIGN(BinaryOperation):
    def __init__(self, operands) -> None:
        super().__init__(operands, OPERATORS.ASSIGN)


class AND(BinaryOperation):
    def __init__(self, operands) -> None:
        super().__init__(operands, OPERATORS.AND)

class OR(BinaryOperation):
    def __init__(self, operands) -> None:
        super().__init__(operands, OPERATORS.OR)

class EQ(BinaryOperation):
    def __init__(self, operands) -> None:
        super().__init__(operands, OPERATORS.EQ)

class LT(BinaryOperation):
    def __init__(self, operands) -> None:
        super().__init__(operands, OPERATORS.LT)

class GT(BinaryOperation):
    def __init__(self, operands) -> None:
        super().__init__(operands, OPERATORS.GT)

class GE(BinaryOperation):
    def __init__(self, operands) -> None:
        super().__init__(operands, OPERATORS.GE)

class LE(BinaryOperation):
    def __init__(self, operands) -> None:
        super().__init__(operands, OPERATORS.LE)

class NOT(UnaryOperation):
    def __init__(self, operand) -> None:
        super().__init__(operand, OPERATORS.NOT)

class ADR(UnaryOperation):
    def __init__(self, operand) -> None:
        super().__init__(operand, OPERATORS.ADR)

class PLC_DEREF(UnaryOperation):
    def __init__(self, operand) -> None:
        super().__init__(operand, OPERATORS.PLC_DEREF)


def load_unary_sequence(loader, node):
    """Helper function to load a sequency of exactly 1 item"""
    values = loader.construct_sequence(node)
    if len(values) != 1:
        raise Exception(f"Unary operation {str(values)} requires exactly 1 argument, not {len(values)}!")
    return values

def load_binary_sequence(loader, node):
    """Helper function to load a sequence of minimum 2 items"""
    values = loader.construct_sequence(node)
    if len(values) < 2:
        raise Exception(f"Binary operation {str(values)} requires at least 2 arguments, not {len(values)}!")
    return values

# unary constructors
def NOT_constructor(loader, node):
    values = load_unary_sequence(loader, node)
    return NOT(values[0])
def ADR_constructor(loader, node):
    values = load_unary_sequence(loader, node)
    return ADR(values[0])

# binary constructors

def ASSIGN_constructor(loader, node):
    values = load_binary_sequence(loader, node)
    return ASSIGN(values)
def AND_constructor(loader, node):
    values = load_binary_sequence(loader, node)
    return AND(values)
def OR_constructor(loader, node):
    values = load_binary_sequence(loader, node)
    return OR(values)
def EQ_constructor(loader, node):
    values = load_binary_sequence(loader, node)
    return EQ(values)
def GT_constructor(loader, node):
    values = load_binary_sequence(loader, node)
    return GT(values)
def LT_constructor(loader, node):
    values = load_binary_sequence(loader, node)
    return LT(values)
def GE_constructor(loader, node):
    values = load_binary_sequence(loader, node)
    return GE(values)
def LE_constructor(loader, node):
    values = load_binary_sequence(loader, node)
    return LE(values)



class Primitive(Object):
    def __init__(self, value) -> None:
        super().__init__(None, None)
        self.value = value


class Double(Primitive):
    def __init__(self, value: str) -> None:
        super().__init__(float(value))

def Double_constructor(loader, node):
    value = loader.construct_scalar(node)
    return Double(value)

class UInt16(Primitive):
    def __init__(self, value: str) -> None:
        super().__init__(int(value))

class Int16(Primitive):
    def __init__(self, value: str) -> None:
        super().__init__(int(value))

def UInt16_constructor(loader, node):
    value = loader.construct_scalar(node)
    return UInt16(value)

class UInt8(Primitive):
    def __init__(self, value: str) -> None:
        super().__init__(int(value))

def UInt8_constructor(loader, node):
    value = loader.construct_scalar(node)
    return UInt8(value)

def Int16_constructor(loader, node):
    value = loader.construct_scalar(node)
    return Int16(value)

class String(Primitive):
    def __init__(self, value: str) -> None:
        super().__init__(str(value))

def String_constructor(loader, node):
    value = loader.construct_scalar(node)
    return String(value)

class Bool(Primitive):
    def __init__(self, value: str) -> None:
        if str(value).upper() == "TRUE":
            v = True
        elif str(value).upper() == "FALSE":
            v = False
        else:
            raise Exception(f"Invalid argument '{str(value)}' for BOOL, must be either TRUE or FALSE (case insensitive)")
        super().__init__(v)

def Bool_constructor(loader, node):
    value = loader.construct_scalar(node)
    return Bool(value)

class MTCS_SUMMARIZE_BUSY(BinaryOperation):
    def __init__(self, operands) -> None:
        new_operands = []
        for operand in operands:
            new_operands.append(operand + ".statuses.busyStatus.busy")
        super().__init__(new_operands, OPERATORS.OR)

class MTCS_SUMMARIZE_GOOD(BinaryOperation):
    def __init__(self, operands) -> None:
        new_operands = []
        for operand in operands:
            new_operands.append(operand + ".statuses.healthStatus.isGood")
        super().__init__(new_operands, OPERATORS.AND)

class MTCS_SUMMARIZE_WARN(BinaryOperation):
    def __init__(self, operands) -> None:
        new_operands = []
        for operand in operands:
            new_operands.append(operand + ".statuses.healthStatus.hasWarning")
        super().__init__(new_operands, OPERATORS.OR)

class MTCS_SUMMARIZE_GOOD_OR_DISABLED(BinaryOperation):
    def __init__(self, operands) -> None:
        new_operands = []
        for operand in operands:
            new_operands.append(OR([operand + ".statuses.healthStatus.isGood", 
                                     operand + ".statuses.enabledStatus.disabled"]))
        super().__init__(new_operands, OPERATORS.AND)

def MTCS_SUMMARIZE_BUSY_constructor(loader, node):
    values = load_binary_sequence(loader, node)
    return MTCS_SUMMARIZE_BUSY(values)

def MTCS_SUMMARIZE_GOOD_constructor(loader, node):
    values = load_binary_sequence(loader, node)
    return MTCS_SUMMARIZE_GOOD(values)

def MTCS_SUMMARIZE_WARN_constructor(loader, node):
    values = load_binary_sequence(loader, node)
    return MTCS_SUMMARIZE_WARN(values)

def MTCS_SUMMARIZE_GOOD_OR_DISABLED_constructor(loader, node):
    values = load_binary_sequence(loader, node)
    return MTCS_SUMMARIZE_GOOD_OR_DISABLED(values)

