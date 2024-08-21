

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


class IfThen:
    def __init__(self) -> None:
        pass


class Expression:
    def __init__(self, operator) -> None:
        self.operator = operator
    
    def apply_resolver(self, resolver, context):
        pass


class UnaryOperation(Expression):
    def __init__(self, operand, operator) -> None:
        super().__init__(operator)
        self.operand = operand
    
    def apply_resolver(self, resolver, context):
        self.operand = resolver(self.operand, context)


class BinaryOperation(Expression):
    def __init__(self, left, right, operator) -> None:
        super().__init__(operator)
        self.left = left
        self.right = right
    
    def apply_resolver(self, resolver, context):
        if isinstance(self.left, str):
            self.left = resolver(self.left, context)
        if isinstance(self.right, str):
            self.right = resolver(self.right, context)
    

class RecursiveExpression:
    def __init__(self, items, operator) -> None:
        self.items = items
        self.operator = operator


class ASSIGN(BinaryOperation):
    def __init__(self, left, right) -> None:
        super().__init__(left, right, OPERATORS.ASSIGN)



def load_binary_sequence(loader, node):
    """Helper function to load a sequency of exactly 2 items"""
    values = loader.construct_sequence(node)
    if len(values) != 2:
        raise Exception(f"SUM! {str(values)} requires exactly 2 arguments, not {len(values)}!")
    return values

# binary constructors

def ASSIGN_constructor(loader, node):
    values = load_binary_sequence(loader, node)
    return ASSIGN(values[0], values[1])



class Primitive:
    def __init__(self, value) -> None:
        self.value = value


class Double(Primitive):
    def __init__(self, value) -> None:
        super().__init__(value)
        print("DOUBLE " + str(self.value))

def Double_constructor(loader, node):
    value = loader.construct_scalar(node)
    return Double(value)