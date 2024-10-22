from util.expressions import UnaryOperation, BinaryOperation, \
                            OPERATORS, \
                            load_binary_sequence, load_unary_sequence


# constant PI value
PIVALUE =3.1415926535897932384626433


# classes representing unary and binary operations

class ABS(UnaryOperation):
    def __init__(self, operand) -> None:
        super().__init__(operand, OPERATORS.ABS)

class SUM(BinaryOperation):
    def __init__(self, operands) -> None:
        super().__init__(operands, OPERATORS.SUM)

class SUB(BinaryOperation):
    def __init__(self, operands) -> None:
        super().__init__(operands, OPERATORS.SUB)

class MUL(BinaryOperation):
    def __init__(self, operands) -> None:
        super().__init__(operands, OPERATORS.MUL)

class DIV(BinaryOperation):
    def __init__(self, operands) -> None:
        super().__init__(operands, OPERATORS.DIV)

class POW(BinaryOperation):
    def __init__(self, operands) -> None:
        super().__init__(operands, OPERATORS.POW)
    
class NEG(UnaryOperation):
    def __init__(self, operand) -> None:
        super().__init__(operand, OPERATORS.NEG)


# binary constructors

def SUM_constructor(loader, node):
    values = load_binary_sequence(loader, node)
    return SUM(values)

def SUB_constructor(loader, node):
    values = load_binary_sequence(loader, node)
    return SUB(values)

def MUL_constructor(loader, node):
    values = load_binary_sequence(loader, node)
    return MUL(values)

def DIV_constructor(loader, node):
    values = load_binary_sequence(loader, node)
    return DIV(values)

def POW_constructor(loader, node):
    values = load_binary_sequence(loader, node)
    return POW(values)


# unary constructors


def ABS_constructor(loader, node):
    values = load_unary_sequence(loader, node)
    return ABS(values[0])

def NEG_constructor(loader, node):
    values = load_unary_sequence(loader, node)
    return NEG(values[0])

