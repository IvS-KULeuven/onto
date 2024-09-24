<%namespace name="iec61131" file="_iec61131.mako"/>\
<%
    ## from util.factories import timeNow, Library
    ## if len(M) != 1: raise Exception("Only 1 library definition per file!")
    ## for item_k, item_v in M.items():
    ##     lib = Library(item_k.name, item_v)
    ##     break
    from util.factories import timeNow, Library, LIBRARY
    for item_k, item_v in M.items():
        if isinstance(item_k, LIBRARY):
          lib = Library(item_k.name, item_v)
          break
%>\
${iec61131.xml_project(lib, timeNow)}