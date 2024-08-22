<%namespace name="iec61131" file="_iec61131.mako"/>\
<%
    import json
    from util.factories import timeNow, Library
    lib = Library(M)
%>\
${render_object(lib)}



<%def name="render_object(obj, indent='')">\
${indent}${obj.name} (${type(obj).__name__}):
    % for child in obj.children.values():
${render_object(child, indent+'    ')}\
    %endfor
</%def>