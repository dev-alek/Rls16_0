block-level on error undo, throw.
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cuaddsum.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/cuaddsum.p $":U .
define variable vss-description as character no-undo init "Программа по вызову утилиты для расчета дополнительных сумм по документу".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable varinvclcspvalue as character          no-undo.
define variable varinvclcsptype  as character          no-undo.
define variable varcalcasstring  as character          no-undo.
define variable varcalcastype    as character          no-undo.
define variable wastagevalue     as character          no-undo.
define variable wastagetype      as character          no-undo.
define variable varneed-calc     as logical            no-undo.
define buffer bf_trn-doc for ub.trn-doc.
find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock no-error.
if not available bf_trn-doc then do:
  return error substitute ("Не найден документ с номером &1.", pardoc-code).
end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input bf_trn-doc.obj-type
  ,input bf_trn-doc.obj-code
  ,input 'inv-obj':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'invclcsp' then varinvclcspvalue = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
      if thbjattr_thbj-attr.prop-code = 'wastage'  then wastagevalue = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
  end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input bf_trn-doc.doc-code ,
                        input 'addsum':U ,
                       output varcalcasstring ,
                       output varcalcastype ) no-error .
if error-status:error then do:
  return error substitute ("Ошибка при вызове процедуры tdat-val. Документ &1. Параметр &2.", bf_trn-doc.doc-code, 'clcasol':U).
end.
if lookup ('bd':U,  varcalcasstring ) = 0 or
   lookup ('gen':U, varcalcasstring ) = 0 or
   lookup ('ext':U,   varcalcasstring ) = 0 or
   lookup ('mis':U,    varcalcasstring ) = 0 or
   lookup ('ad':U,   varcalcasstring ) = 0 then do:
  assign
    varneed-calc = yes.
end.
if wastagevalue = "yes" then do:
  if lookup ('wst':U, varcalcasstring ) = 0 then do:
    assign
      varneed-calc = yes.
  end.
end.
if varinvclcspvalue = "yes" then do:
  if lookup ('bcd':U,  varcalcasstring ) = 0 or
     lookup ('genc':U, varcalcasstring ) = 0 or
     lookup ('extc':U,   varcalcasstring ) = 0 or
     lookup ('misc':U,    varcalcasstring ) = 0 or
     lookup ('acd':U,   varcalcasstring ) = 0 then do:
    assign
      varneed-calc = yes.
  end.
  if wastagevalue = "yes" then do:
    if lookup ('wstc':U, varcalcasstring ) = 0 then do:
      assign
        varneed-calc = yes.
    end.
  end.
end.
if varneed-calc = yes then do:
  run utl/uaddsum.p
      (input bf_trn-doc.doc-code ,
       input no ,
       input no ,
       input no
      ) no-error.
  if error-status:error then do:
    return error substitute ("Ошибка при вызове процедуры uaddsum.p: &1 &2.", return-value, error-status:get-message(1)).
  end.
end.
