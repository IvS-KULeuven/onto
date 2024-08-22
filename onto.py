import argparse, os, sys, fnmatch, glob, os, pathlib
from mako.template import Template
from mako.lookup import TemplateLookup

from mako import exceptions
from pathlib import Path
import yaml
try:
    from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
    from yaml import Loader, Dumper
from util import expressions, mathematics

# declare VERBOSE as an evil global
VERBOSE = False




def get_loader():
    """Return a yaml loader."""
    loader = yaml.SafeLoader
    loader.add_constructor('!ASSIGN', expressions.ASSIGN_constructor)
    loader.add_constructor('!SUM', mathematics.SUM_constructor)
    loader.add_constructor('!SUB', mathematics.SUB_constructor)
    loader.add_constructor('!MUL', mathematics.MUL_constructor)
    loader.add_constructor('!DIV', mathematics.DIV_constructor)
    loader.add_constructor('!ABS', mathematics.ABS_constructor)
    loader.add_constructor('!NEG', mathematics.NEG_constructor)
    loader.add_constructor('!DOUBLE', expressions.Double_constructor)
    return loader



# a simple function to log verbose info
def LOG(msg):
    if VERBOSE:
        print(msg)

def render(input_file: Path, template_file: Path) -> str:
    template = Template(filename=str(template_file), 
                        lookup=TemplateLookup(directories=""))
    model = {}
    with open(input_file, 'r') as file:
        #model = yaml.safe_load(file)
        model = yaml.load(file, Loader=get_loader())
        
    return template.render(M=model)


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
    
    # process each input file sequentially:
    for input_fp in inputdir_fp.rglob('*.yaml'):
        
        LOG("Processing input file '%s'" %input_fp)
        
        for template_fp in Path('./templates').rglob('*.mako'):
            if not template_fp.stem.startswith('_'):
                LOG(f"  Rendering '{template_fp}'")
                output = render(input_fp, template_fp)                
                
                filepath_key = str(input_fp).replace('.yaml', '').replace(str(inputdir_fp), '')

                output_fp = Path(args.OUTPUTDIR) \
                            / Path('./' + str(template_fp)[len('templates/'):-len('.mako')] \
                                .replace('{filepath}', filepath_key))

                output_fp.parent.mkdir(parents=True, exist_ok=True)
                LOG("  Writing output file '%s'" %output_fp)
                output_fp.write_text(output, newline='\n')
