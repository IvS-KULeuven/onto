<%namespace name="iec61131" file="_iec61131.mako"/>\
<%! 
    import pprint
    from util.expressions import IfThen, BinaryOperation, UnaryOperation, Primitive
    from util.factories import Variable, Method, Call, EnumItem, FunctionBlock, GlobalVariable
    from xml.sax.saxutils import escape as sax_escape


    def escape(s):
        return sax_escape(s, entities={
            "'": "&#39;",
            "\"": "&quot;",
            "<": "&lt;",
            ">": "&gt;"
        })

    def getPrefixAndPath(dest, scope = []):
        #print(f" --- getPrefixAndPath({dest.name})")
        e = None
        for head in scope:
            if isinstance(dest, EnumItem):
                return None, [ dest.parent, dest ]

            if hasattr(head, "extends") and hasattr(dest, "points_to_type"):

                if head.extends is not None and dest.points_to_type is not None:
                    if head.extends.name == dest.points_to_type.name:
                        return "SUPER", []

            try:
                if isinstance(head, FunctionBlock):
                    ## only explicitely mention THIS^ if there can be confusion (i.e. when the scope is > 1)
                    if len(scope) > 1:
                        return "THIS^", getPathToSubVariable(dest, head)
                    else:
                        return None, getPathToSubVariable(dest, head)
                elif isinstance(head, Method):
                    ## within the scope of a IEC61131-3 Method, the method itself is reachable via the method name
                    if id(dest) == id(head):
                        return dest.name, []
                    else:
                        return None, getPathToSubVariable(dest, head)

            except EOFError as eof:
                e = eof

        if e is not None:
            raise e

    def getPathToSubVariable(dest, head):

        if isinstance(dest, GlobalVariable):
            return [dest]

        #if id(dest) == id(head):
        if dest.name == head.name:
            return []

        if dest.parent is None:
            raise EOFError()

        p = None
        ## for owner in dest.get_members():
        ##     try:
        ##         p =  getPathToSubVariable(owner, head) + [ dest ]
        ##         break
        ##     except EOFError:
        ##         pass

        #if id(dest.get_child(head.name)) == id(head):
        #    return [ dest ]

        # check parent of superclasses too!
        all_heads = []

        try:

            def get_heads_recursively(head):
                ret = [head]
                if hasattr(head, 'extends'):
                    if head.extends is not None:
                        ret += get_heads_recursively(head.extends)
                return ret

            all_heads = get_heads_recursively(head)

            for any_head in all_heads:
                try:
                    p = getPathToSubVariable(dest.parent, any_head) + [ dest ]
                    break
                except EOFError:
                    pass

        except EOFError:
            pass

        if p is not None:
            return p

        if 'parent' in dest.__dict__:
            dest_parent = dest.__dict__['parent'].name
        else:
            dest_parent = ''

        raise EOFError( "Destination %s (%s) was not found as a subvariable of %s (%s)" %(dest.name, type(dest).__name__, head.name, type(head).__name__)
                        + "\n\n"
                        + "Destination " + dest.name + " (child of parent " + dest_parent + "):\n"
                        + pprint.pformat(dest.__dict__)
                        + "\n\n"
                        + "Head " + head.name + ":\n"
                        + pprint.pformat(head.__dict__)
                        + "\n\n"
                        + str(all_heads))


%>\

<%def name="xml_project(lib, timeNow)">\
<?xml version="1.0" encoding="utf-8"?>
<project xmlns="http://www.plcopen.org/xml/tc6_0200">
  <fileHeader companyName="Institute of Astronomy" productName="Onto" productVersion="0.0.1" creationDateTime="${timeNow}" />
  <contentHeader name="${lib.name}" modificationDateTime="${timeNow}">
    <coordinateInfo>
      <fbd>
        <scaling x="1" y="1" />
      </fbd>
      <ld>
        <scaling x="1" y="1" />
      </ld>
      <sfc>
        <scaling x="1" y="1" />
      </sfc>
    </coordinateInfo>
    <addData>
      <data name="http://www.3s-software.com/plcopenxml/projectinformation" handleUnknown="implementation">
        <ProjectInformation />
      </data>
    </addData>
  </contentHeader>
  <types>
    <dataTypes>
    % for enum in lib.enums.children.values():
      ${xml_enum(enum, '      ')}
    % endfor
    % for struct in lib.get_all_structs().values(): # lib.structs.children.values():
      ${xml_struct(struct, '      ')}
    % endfor
    </dataTypes>
    <pous>
    % for fb in lib.functionblocks.children.values():
      ${xml_pou_functionBlock(fb, '      ')}
    % endfor
    </pous>
  </types>
  <instances>
    <configurations />
  </instances>
  <addData>
    <data name="http://www.3s-software.com/plcopenxml/projectstructure" handleUnknown="discard">
      <ProjectStructure>
        ## ${xml_folder(node, '        ')}
      </ProjectStructure>
    </data>
  </addData>
</project>\
</%def>



<%def name="xml_enum(enum, indent='')">\
<dataType name="${enum.name}">
${indent}  <baseType>
${indent}    <enum>
${indent}      <values>
                % for i, item in enumerate(enum.items):
${indent}        <value name="${item.name}" value="${item.number}" />
                 %endfor
${indent}      </values>
${indent}    </enum>
${indent}  </baseType>
${indent}</dataType>\
</%def>


<%def name="xml_pou_functionBlock(fb, indent='')">\
<pou name="${fb.name}" pouType="functionBlock">
${indent}  <interface>
${indent}    ${xml_variables("input" , fb.var_in.values()    , indent+'    ')}
${indent}    ${xml_variables("output", fb.var_out.values()   , indent+'    ')}
${indent}    ${xml_variables("inOut" , fb.var_inout.values() , indent+'    ')}
${indent}    ${xml_variables("local" , fb.var_local.values() , indent+'    ')}
% if fb.extends is not None:
${indent}    ${xml_pou_extends(fb.extends, indent+'    ')}
% endif
${indent}  </interface>
${indent}  <body>
${indent}    <ST>
% if fb.implementation is not None:
${indent}      ${xml_implementation(fb.implementation, [ fb ], indent+'      ')}
% endif
${indent}    </ST>
${indent}  </body>
${indent}  <addData>
% if len(fb.methods) > 0:
${indent}    ${xml_methods(fb.methods.values(), fb, indent+'    ')}
% endif
${indent}  </addData>
${indent}</pou>\
</%def>

<%def name="xml_pou_extends(node, indent='')">\
<addData>
${indent}  <data name="http://www.3s-software.com/plcopenxml/pouinheritance" handleUnknown="implementation">
${indent}    <Inheritance>
${indent}      <Extends>${node.name}</Extends>
${indent}    </Inheritance>
${indent}  </data>
${indent}</addData>\
</%def>

<%def name="xml_methods(methods, owner, indent='')">\
    %for method in methods:
        % if not loop.first:
${indent}\
        % endif
${xml_method(method, owner, indent)}\
        % if not loop.last:

        % endif
    %endfor
</%def>

<%def name="xml_method(node, owner, indent='')">\
<% print(f"+++ xml_method({node.name})") %>\
<data name="http://www.3s-software.com/plcopenxml/method" handleUnknown="implementation">
${indent}  <Method name="${node.name}">
${indent}    <interface>
% if node.return_type is not None:
${indent}      ${xml_return_type(node.return_type)}
% endif
${indent}      ${xml_variables("input" , node.var_in.values()     , indent+'      ')}
${indent}      ${xml_variables("output", node.var_out.values()    , indent+'      ')}
${indent}      ${xml_variables("inOut" , node.var_inout.values()  , indent+'      ')}
${indent}      ${xml_variables("local" , node.var_local.values()  , indent+'      ')}
${indent}      <addData>
${indent}        <data name="http://www.3s-software.com/plcopenxml/attributes" handleUnknown="implementation">
${indent}          <Attributes>
##${indent}            <Attribute Name="object_name" Value="${label}" />
${indent}            <Attribute Name="TcRpcEnable" Value="1" />
${indent}          </Attributes>
${indent}        </data>
${indent}      </addData>
${indent}    </interface>
${indent}    <body>
${indent}      <ST>
% if node.implementation is not None:
${indent}        ${xml_implementation(node.implementation, [ node, owner ], indent+'        ')}
% endif
${indent}      </ST>
${indent}    </body>
${indent}  </Method>
${indent}</data>\
</%def>

<%def name="xml_return_type(node)">\
<% print(f"+++ xml_return_type {node}") %>\
<returnType>${xml_type_element(node)}</returnType>\
</%def>

<%def name="xml_implementation(implementation, scope, indent='')">\
<xhtml xmlns="http://www.w3.org/1999/xhtml">${render_implementation(implementation, scope)}</xhtml>\
</%def>

## <%def name="render_implementation(node, scope, indent='', more='    ')">\
## ${layoutExpressions(node["expressions"], scope, indent=indent)}\
## </%def>

<%def name="render_implementation(node, scope, indent='', more='    ')">\
${layoutExpressions(node, scope, indent=indent)}\
</%def>

<%def name="layoutExpressions(expressions, scope, indent='', more='    ')">\
    %if isinstance(expressions, list):
        %for e in expressions:
            % if not loop.first:
${indent}\
            % endif
${layoutExpressions(e, scope, indent=indent)};
        %endfor
    %else:
${layoutExpression(expressions, scope, indent=indent)}\
    %endif
</%def>


<%def name="xml_variables(kind, variables, indent='')">\
<${kind}Vars>
           % for v in variables:
${indent}  ${xml_variable(v, indent+'  ')}
           % endfor
${indent}</${kind}Vars>\
</%def>


<%def name="layoutExpression(e, scope, indent='', more='    ')">\
<%
    print(f"layoutExpression({e} ({type(e)}), {scope})")
    if e is None or scope is None:
        raise Exception("layoutExpression with None argument!")
%>\
    %if isinstance(e, IfThen):
${layoutIfThen(e, scope, indent=indent)}\
    %elif isinstance(e, BinaryOperation):
${layoutBinaryOperation(e, scope, indent=indent)}\
    %elif isinstance(e, UnaryOperation):
${layoutUnaryOperation(e, scope, indent=indent)}\
    %elif isinstance(e, Variable):
${layoutVariable(e, scope, indent=indent)}\
    %elif isinstance(e, Method):
${layoutMethod(e, scope, indent=indent)}\
    %elif isinstance(e, Primitive):
${render_value(e, scope, indent=indent)}\
    %elif isinstance(e, Call):
${layoutCall(e, scope, indent=indent)}\
    %elif isinstance(e, list):
${render_implementation(e, scope, indent=indent)}\
##    %elif isinstance(e, Implementation):
##${render_implementation(e, scope, indent=indent)}\
    %else:
<%
    raise Exception("ERROR in layoutExpression(%s)" %(e.name))
%>
    %endif
</%def>

<%def name="layoutMethod(m, scope,indent='',more='    ')">\
<% print("+++ layoutMethod") %>\
${render_path(m, scope)}\
</%def>


<%def name="layoutIfThen(node, scope, indent='', more='    ')">\
<% print("+++ layoutIfThen START") %>\
IF ${layoutExpression(node.if_, scope)} THEN
${indent+more}${layoutExpressions(node.then_, scope, indent=indent+more)}\
    %if node.else_ is not None:
${indent}ELSE
${indent+more}${layoutExpressions(node.else_, scope, indent=indent+more)}\
    %endif
${indent}END_IF\
<% print("+++ layoutIfThen END") %>\
</%def>

<%def name="render_value(node, scope, indent='')">\
<%
    print(f" +++ render_value({node}, {scope})")
%>\
${node.value}\
</%def>


<%def name="layoutVariable(v,scope,indent='',more='    ')">\
<% print(f" +++ layoutVariable({v}, {scope})") %>\
${render_path(v, scope)}\
</%def>

<%def name="layoutBinaryOperation(node, scope, indent='', more='    ')">\
<%
    print("+++ layoutBinaryOperation")
    useBracketsForLeft  = not (isinstance(node.left, Variable) or isinstance(node.left, Primitive))
    useBracketsForRight = not (isinstance(node.right, Variable) or isinstance(node.right, Primitive))
    if node.operator.plc_symbol is None:
        raise Exception("Unknown symbol in layoutBinaryOperation(%s) for operator %s" %(node, node.operator))
%>\
    %if node.operator.plc_symbol in [":="]:
${layoutExpression(node.left, scope)} ${node.operator.plc_symbol} ${layoutExpression(node.right, scope)}\
    %else:
        %if useBracketsForLeft:
(${layoutExpression(node.left, scope)})\
        %else:
${layoutExpression(node.left, scope)}\
        %endif
 ${escape(node.operator.plc_symbol)} \
        %if useBracketsForRight:
(${layoutExpression(node.right, scope)})\
        %else:
${layoutExpression(node.right, scope)}\
        %endif
    %endif
</%def>



<%def name="render_path(dest, scope)">\
<% 
    prefix, path = getPrefixAndPath(dest, scope) 
    print(f" +++ prefix: {prefix}  +++  {str(path)}")
%>\
    %if prefix is not None:
${prefix}\
        % if len(path) > 0:
.\
        % endif
    %endif
    %for item in path:
        % if not loop.first:
.\
        % endif
${item.name}\
    %endfor
</%def>


<%def name="render_assignment(node, scope)">\
<% print(f"+++ render_assignment(node={node.name}, scope={[item.name for item in scope]}) START") %>\
${node.left.name} := ${layoutExpression(node.right, scope=scope)}\
</%def>

<%def name="layoutCall(node, scope, indent='', more='    ')">\
<%
    print(f"+++ layoutCall(node={node.name}, scope={[item.name for item in scope]}) START")
%>\
% if isinstance(node.calls, UnaryOperation):
${layoutUnaryOperation(node.calls, scope, indent=indent)}\
% else:
${render_path(node.calls, scope)}\
% endif
(\
    % if len(node.assignments) == 0:
)\
    % elif len(node.assignments) == 1:
 ${render_assignment(node.assignments[0], scope)} )\
    % else:

        % for assignment in node.assignments:
${indent+more}${render_assignment(assignment, scope)}\
            % if loop.last:
)\
            % else:
,
            % endif
        % endfor
    % endif
<% print(f"layoutCall END") %>\
</%def>




<%def name="layoutUnaryOperation(node, scope, indent='', more='    ')">\
<%
    print(f"+++ layoutUnaryOperation({node})")
    if node.operator.plc_symbol is None:
        raise Exception("Unknown symbol in layoutUnaryOperation(%s) for operator %s" %(node.name), operator.name)
%>\
    %if node.operator.plc_symbol == '^':
${layoutExpression(node.operand, scope)}^\
    %else:
${node.operator.plc_symbol}(${layoutExpression(node.operand, scope)})\
    %endif
</%def>




<%def name="xml_variable(node, indent='')">\
\
% if node.address is not None:
<variable name="${node.name}" address="${node.address}">
% else:
<variable name="${node.name}">
% endif
${indent}  ${xml_type(node)}
        % if node.initial is not None:
${indent}  <initialValue><simpleValue value="${str(node.initial.value).upper()}" /></initialValue>
        % endif
        % if node.qualifiers is not None:
${indent}  <addData>
${indent}    <data name="http://www.3s-software.com/plcopenxml/attributes" handleUnknown="implementation">
${indent}      <Attributes>
               % for qualifier in node.qualifiers:
${indent}        <Attribute Name="${qualifier.plc_symbol}" Value="${qualifier.value}" />
               % endfor
${indent}      </Attributes>
${indent}    </data>
${indent}  </addData>
        % endif
        % if node.comment is not None:
${indent}  <documentation>
${indent}    <xhtml xmlns="http://www.w3.org/1999/xhtml">${escape(node.comment)}</xhtml>
${indent}  </documentation>
        % endif
${indent}</variable>\
</%def>


<%def name="xml_type(node)">\
<% print(f"+++ xml_type({node})") %>\
<type>${xml_type_contents(node)}</type>\
</%def>


<%def name="xml_type_element(node)">\
<% print(f"xml_type_element({node})") %>\
  %if node.plc_symbol is not None:
##for some reason, STRING must be rendered lowercase, otherwise you cannot import the file in TwinCAT !!!
    % if node.plc_symbol == 'STRING':
<string />\
    % else:
<${node.plc_symbol} />\
    % endif
  %else:
<derived name="${node.name}" />\
  % endif
</%def>

<%def name="xml_type_contents(node)">\
<% print(f"+++ xml_type_contents {node}") %>\
    %if node.type is not None:
${xml_type_element(node.type)}\
    %elif node.points_to_type is not None:
<pointer><baseType>${xml_type_element(node.points_to_type)}</baseType></pointer>\
    %endif
</%def>


<%def name="xml_struct(node,indent='')">\
<dataType name="${node.name}">
${indent}  <baseType>
${indent}    <struct>
             %for item in node.items.values():
${indent}      ${xml_variable(item, indent+'      ')}
             %endfor
${indent}    </struct>
${indent}  </baseType>
${indent}</dataType>\
</%def>