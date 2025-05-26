class CodeGenVersion:
    MTCS = "MTCS"
    MARVEL = "MARVEL"

# evil global
global CODEGEN_VERSION
CODEGEN_VERSION = CodeGenVersion.MTCS

def is_marvel():
    return CODEGEN_VERSION == CodeGenVersion.MARVEL

def is_mtcs():
    return CODEGEN_VERSION == CodeGenVersion.MTCS

def statuses() -> str:
    if is_mtcs():
        return "statuses"
    elif is_marvel():
        return "stat"
    else:
        raise Exception("Invalid version")

def processes() -> str:
    if is_mtcs():
        return "processes"
    elif is_marvel():
        return "proc"
    else:
        raise Exception("Invalid version")