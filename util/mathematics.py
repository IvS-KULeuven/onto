from util.expressions import UnaryOperation, BinaryOperation, \
                            OPERATORS, \
                            load_binary_sequence, load_unary_sequence


PIVALUE =3.1415926535897932384626433



class ABS(UnaryOperation):
    def __init__(self, operand) -> None:
        super().__init__(operand, OPERATORS.ABS)

class SUM(BinaryOperation):
    def __init__(self, left, right) -> None:
        super().__init__(left, right, OPERATORS.SUM)

class SUB(BinaryOperation):
    def __init__(self, left, right) -> None:
        super().__init__(left, right, OPERATORS.SUB)

class MUL(BinaryOperation):
    def __init__(self, left, right) -> None:
        super().__init__(left, right, OPERATORS.MUL)

class DIV(BinaryOperation):
    def __init__(self, left, right) -> None:
        super().__init__(left, right, OPERATORS.DIV)

class POW(BinaryOperation):
    def __init__(self, left, right) -> None:
        super().__init__(left, right, OPERATORS.POW)
    
class NEG(UnaryOperation):
    def __init__(self, operand) -> None:
        super().__init__(operand, OPERATORS.NEG)



# binary constructors

def SUM_constructor(loader, node):
    values = load_binary_sequence(loader, node)
    return SUM(values[0], values[1])

def SUB_constructor(loader, node):
    values = load_binary_sequence(loader, node)
    return SUB(values[0], values[1])

def MUL_constructor(loader, node):
    values = load_binary_sequence(loader, node)
    return MUL(values[0], values[1])

def DIV_constructor(loader, node):
    values = load_binary_sequence(loader, node)
    return DIV(values[0], values[1])

def POW_constructor(loader, node):
    values = load_binary_sequence(loader, node)
    return POW(values[0], values[1])

# unary constructors


def ABS_constructor(loader, node):
    values = load_unary_sequence(loader, node)
    return ABS(values[0])

def NEG_constructor(loader, node):
    values = load_unary_sequence(loader, node)
    return NEG(values[0])

