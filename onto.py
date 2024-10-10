import argparse, os, sys, fnmatch, glob, os, pathlib, time
from mako.template import Template
from mako.lookup import TemplateLookup

from mako import exceptions
from pathlib import Path
import yaml
try:
    from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
    from yaml import Loader, Dumper
from util import expressions, mathematics, factories

# declare VERBOSE as an evil global
VERBOSE = False


class ImportNeeded(Exception):
    def __init__(self, name) -> None:
        super().__init__()
        self.name = name


IMPORTED = []

def IMPORT_constructor(loader: Loader, node):
    filename = str(Path(loader.construct_scalar(node)))
    if filename in IMPORTED:
        return
    else:
        raise ImportNeeded(filename)



def get_loader():
    """Return a yaml loader."""
    loader = yaml.SafeLoader
    loader.add_constructor('!IMPORT', IMPORT_constructor)
    loader.add_constructor('!ASSIGN', expressions.ASSIGN_constructor)
    loader.add_constructor('!ADR', expressions.ADR_constructor)
    loader.add_constructor('!SUM', mathematics.SUM_constructor)
    loader.add_constructor('!SUB', mathematics.SUB_constructor)
    loader.add_constructor('!MUL', mathematics.MUL_constructor)
    loader.add_constructor('!DIV', mathematics.DIV_constructor)
    loader.add_constructor('!ABS', mathematics.ABS_constructor)
    loader.add_constructor('!NEG', mathematics.NEG_constructor)
    loader.add_constructor('!DOUBLE', expressions.Double_constructor)
    loader.add_constructor('!BOOL', expressions.Bool_constructor)
    loader.add_constructor('!UINT8', expressions.UInt8_constructor)
    loader.add_constructor('!INT16', expressions.Int16_constructor)
    loader.add_constructor('!UINT16', expressions.UInt16_constructor)
    loader.add_constructor('!STRING', expressions.String_constructor)
    loader.add_constructor('!LIBRARY', factories.LIBRARY_constructor)
    loader.add_constructor('!ENUM', factories.ENUM_constructor)
    loader.add_constructor('!ENUMERATION', factories.ENUMERATION_constructor)
    loader.add_constructor('!STATEMACHINE', factories.STATEMACHINE_constructor)
    loader.add_constructor('!STATUS', factories.STATUS_constructor)
    loader.add_constructor('!CONFIG', factories.CONFIG_constructor)
    loader.add_constructor('!FB', factories.FB_constructor)
    loader.add_constructor('!STRUCT', factories.STRUCT_constructor)
    loader.add_constructor('!PROCESS', factories.PROCESS_constructor)
    loader.add_constructor('!AND', expressions.AND_constructor)
    loader.add_constructor('!OR', expressions.OR_constructor)
    loader.add_constructor('!NOT', expressions.NOT_constructor)
    loader.add_constructor('!EQ', expressions.EQ_constructor)
    loader.add_constructor('!GT', expressions.GT_constructor)
    loader.add_constructor('!LT', expressions.LT_constructor)
    loader.add_constructor('!GE', expressions.GE_constructor)
    loader.add_constructor('!LE', expressions.LE_constructor)
    loader.add_constructor('!MTCS_SUMMARIZE_BUSY', expressions.MTCS_SUMMARIZE_BUSY_constructor)
    loader.add_constructor('!MTCS_SUMMARIZE_GOOD', expressions.MTCS_SUMMARIZE_GOOD_constructor)
    loader.add_constructor('!MTCS_SUMMARIZE_WARN', expressions.MTCS_SUMMARIZE_WARN_constructor)
    loader.add_constructor('!MTCS_SUMMARIZE_GOOD_OR_DISABLED', expressions.MTCS_SUMMARIZE_GOOD_OR_DISABLED_constructor)
    return loader



# a simple function to log verbose info
def LOG(msg):
    if VERBOSE:
        print(msg)

def render(input_file: Path, template_fps: list[Path]) -> str:
    LOG(f"render {input_file}")
    model = {}
    with open(input_file, 'r') as file:
        
        try:
            model = yaml.load(file, Loader=get_loader())
            global IMPORTED
            IMPORTED.append(str(input_file))
            print(f"======= {str(IMPORTED)}")
        except ImportNeeded as e:
            render(Path(e.name), template_fps)
            render(input_file, template_fps)
            
        if len(model) > 0: # TODO: find out why sometimes the yaml load returns empty models
            print(f"Model: {model} from file: {file}")

            for template_fp in template_fps:
                template = Template(filename=str(template_fp), 
                                    lookup=TemplateLookup(directories=""))
                output = template.render(M=model)
                
                filepath_key = str(input_fp).replace('.yaml', '').replace(str(inputdir_fp), '')

                output_fp = Path(args.OUTPUTDIR) \
                            / Path('./' + str(template_fp)[len('templates/'):-len('.mako')] \
                                .replace('{filepath}', filepath_key))

                output_fp.parent.mkdir(parents=True, exist_ok=True)
                LOG("  Writing output file '%s'" %output_fp)
                output_fp.write_text(output, newline='\n')


# a function that returns the script description as a string
def description():
    return """
Convert one or more yaml files to PLCopen XML files.
    """


# a function that returns additional help as a string
def epilog():
    return ""


if __name__ == "__main__":
    
    parser = argparse.ArgumentParser(formatter_class = argparse.RawDescriptionHelpFormatter,
                                     description     = description(),
                                     epilog          = epilog())
    
    parser.add_argument("-i",
                        dest="INPUTDIR",
                        action="store",
                        default='./models/in',
                        help="The directory to read the yaml input files from. By default it " \
                             "will just use the ./models/in directory in this repo.")
    
    parser.add_argument("-o",
                        dest="OUTPUTDIR", 
                        action="store", 
                        default='./models/out', 
                        help="The directory to write the output files. By default it " \
                             "will just use the ./models/out directory in this repo.")
    
    parser.add_argument("-v", "--verbose",
                        dest="verbose", 
                        action="store_const", 
                        const=True,
                        default=True, 
                        help="Verbosely print some debugging info.")
    
    args = parser.parse_args()
    
    VERBOSE = args.verbose

    # normalize the arguments by removing a trailing slash if needed
    if args.INPUTDIR.endswith(os.path.sep):
        args.INPUTDIR = args.INPUTDIR[:-1]
    if args.OUTPUTDIR.endswith(os.path.sep):
        args.OUTPUTDIR = args.OUTPUTDIR[:-1]
    
    # terminology:
    #  fp = file path (relative or absolute!) as a Path, e.g. Path('./a/b/c.txt')
    #  fn = file name as a string, e.g. 'c.txt'
    #  relfp = relative fp
    #  absfp = absolute fp
    
    inputdir_fp = Path(args.INPUTDIR)
    if not inputdir_fp.exists():
        LOG(f"FATAL: Input directory {args.INPUTDIR} does not exist!")
        sys.exit(1)
    
    t_start = time.time()
    # process each input file sequentially:
    for input_fp in inputdir_fp.rglob('*.yaml'):
        
        LOG("Processing input file '%s'" %input_fp)
        
        template_fps = []
        for template_fp in Path('./templates').rglob('*.mako'):
            if not template_fp.stem.startswith('_'):
                template_fps.append(template_fp)

        render(input_fp, template_fps)
        LOG("%4.0f Model %s was rendered" % ((time.time() - t_start), input_fp))
                
