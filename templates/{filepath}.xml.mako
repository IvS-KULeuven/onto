<%namespace name="iec61131" file="_iec61131.mako"/>\
<%
    from util.factories import timeNow, Library
    lib = Library(M)
%>\
${iec61131.xml_project(lib, timeNow)}