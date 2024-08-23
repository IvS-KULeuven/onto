<%namespace name="iec61131" file="_iec61131.mako"/>\
<%
    import json
    from util.factories import timeNow, Library
    if len(M) != 1: raise Exception("Only 1 library definition per file!")
    for item_k, item_v in M.items():
        lib = Library(item_k.name, item_v)
        break
%>\
${render_object(lib)}



<%def name="render_object(obj, indent='')">\
${indent}${obj.name} (${type(obj).__name__}):
    % for child in obj.children.values():
${render_object(child, indent+'    ')}\
    %endfor
</%def>