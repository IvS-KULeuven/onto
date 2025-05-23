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