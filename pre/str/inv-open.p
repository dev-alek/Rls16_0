block-level on error undo, throw.
define input parameter parrec-doc as recid                no-undo.
define input parameter parstatus  like ub.trn-doc.status_ no-undo.
define input parameter parflag    like ub.trn-doc.flag_   no-undo.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define buffer io_trn-doc     for ub.trn-doc.
define buffer io_trn-doc-sum for ub.trn-doc-sum.
define buffer io_doc-line    for ub.doc-line.
define buffer io_gds-obj     for ub.gds-obj.
define variable varlns-cnt as integer  no-undo.
define variable varvaluewt    as character no-undo.
define variable vartypewt     as character no-undo.
define variable varvalueol    as character no-undo.
define variable vartypeol     as character no-undo.
define variable wastagevalue  as character no-undo.
define variable wastagetype   as character no-undo.
define variable varinvclcspvalue as character no-undo.
define variable varinvclcsptype  as character no-undo.
define variable varcount         as integer   no-undo.
do
on error undo, return error return-value
:
  find first io_trn-doc where recid(io_trn-doc) = parrec-doc.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input io_trn-doc.obj-type
  ,input io_trn-doc.obj-code
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
      if thbjattr_thbj-attr.prop-code = 'invclcsp'  then varinvclcspvalue = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
  end.
  assign
    io_trn-doc.doc-qnty    = 0
    io_trn-doc.fact-qnty   = 0
    io_trn-doc.tot-calc    = 0
    io_trn-doc.discnt-rubl = 0
    io_trn-doc.tot-doc     = 0
    io_trn-doc.tot-rubl    = 0
    io_trn-doc.fact-base   = 0
    io_trn-doc.fact-rubl   = 0
    io_trn-doc.tot-ov      = 0
    io_trn-doc.re-grading-parts-minus = no
  .
  run trg/lock-gds.p
    (input io_trn-doc.doc-code
    ,input no
    ,input no
    ,input 0
    ,input 0
    ,input false
    ,input false
    ) no-error .
  if error-status :error then do:
    undo, return error return-value.
  end.
  assign
    varcount = 0.
  for each io_doc-line
    where io_doc-line.doc-code = io_trn-doc.doc-code
  on error undo, return error return-value
  :
    assign
      varcount = varcount + 1.
    if io_trn-doc.status_ <> 'запрос':U then do:
      run trg/rsrv-del.p
        (input io_doc-line.doc-code
        ,input io_doc-line.artic
        ,input io_doc-line.prod-type
        ,input io_doc-line.prod-code
        ) no-error .
    end.
    if error-status :error then do:
      undo, return error substitute("Ошибка при снятии резервов. Документ &1 Артикул: &2 &3 &4 Открыть инвентаризацию невозможно.",
                                    io_doc-line.doc-code,
                                    io_doc-line.artic,
                                    io_doc-line.prod-type,
                                    io_doc-line.prod-code).
    end.
  end.
  run gbl/conf-rd.p ("wastage":u , io_trn-doc.host-code, io_trn-doc.obj-type, io_trn-doc.obj-code, "", "", "", no,  output wastagevalue, output wastagetype) no-error.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input io_trn-doc.doc-code ,
                        input 'clcaswt':U ,
                       output varvaluewt ,
                       output vartypewt )  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input io_trn-doc.doc-code ,
                        input 'clcasol':U ,
                       output varvalueol ,
                       output vartypeol )  .
      find first io_trn-doc-sum where io_trn-doc-sum.doc-code = io_trn-doc.doc-code  and                                         io_trn-doc-sum.sum-type = 'bd':U no-error.         if available io_trn-doc-sum then do:           run delete-trn  in this-procedure (input io_trn-doc.doc-code,                                               input 'bd':U) no-error.           if error-status:error then do:             undo, return error return-value.           end.         end.
    find first io_trn-doc-sum where io_trn-doc-sum.doc-code = io_trn-doc.doc-code  and                                         io_trn-doc-sum.sum-type = 'bcd':U no-error.         if available io_trn-doc-sum then do:           run delete-trn  in this-procedure (input io_trn-doc.doc-code,                                               input 'bcd':U) no-error.           if error-status:error then do:             undo, return error return-value.           end.         end.
    find first io_trn-doc-sum where io_trn-doc-sum.doc-code = io_trn-doc.doc-code  and                                         io_trn-doc-sum.sum-type = 'wst':U no-error.         if available io_trn-doc-sum then do:           run delete-trn  in this-procedure (input io_trn-doc.doc-code,                                               input 'wst':U) no-error.           if error-status:error then do:             undo, return error return-value.           end.         end.
    find first io_trn-doc-sum where io_trn-doc-sum.doc-code = io_trn-doc.doc-code  and                                         io_trn-doc-sum.sum-type = 'wstc':U no-error.         if available io_trn-doc-sum then do:           run delete-trn  in this-procedure (input io_trn-doc.doc-code,                                               input 'wstc':U) no-error.           if error-status:error then do:             undo, return error return-value.           end.         end.
    find first io_trn-doc-sum where io_trn-doc-sum.doc-code = io_trn-doc.doc-code  and                                         io_trn-doc-sum.sum-type = 'gen':U no-error.         if available io_trn-doc-sum then do:           run delete-trn  in this-procedure (input io_trn-doc.doc-code,                                               input 'gen':U) no-error.           if error-status:error then do:             undo, return error return-value.           end.         end.
    find first io_trn-doc-sum where io_trn-doc-sum.doc-code = io_trn-doc.doc-code  and                                         io_trn-doc-sum.sum-type = 'genc':U no-error.         if available io_trn-doc-sum then do:           run delete-trn  in this-procedure (input io_trn-doc.doc-code,                                               input 'genc':U) no-error.           if error-status:error then do:             undo, return error return-value.           end.         end.
    find first io_trn-doc-sum where io_trn-doc-sum.doc-code = io_trn-doc.doc-code  and                                         io_trn-doc-sum.sum-type = 'ext':U no-error.         if available io_trn-doc-sum then do:           run delete-trn  in this-procedure (input io_trn-doc.doc-code,                                               input 'ext':U) no-error.           if error-status:error then do:             undo, return error return-value.           end.         end.
    find first io_trn-doc-sum where io_trn-doc-sum.doc-code = io_trn-doc.doc-code  and                                         io_trn-doc-sum.sum-type = 'extc':U no-error.         if available io_trn-doc-sum then do:           run delete-trn  in this-procedure (input io_trn-doc.doc-code,                                               input 'extc':U) no-error.           if error-status:error then do:             undo, return error return-value.           end.         end.
    find first io_trn-doc-sum where io_trn-doc-sum.doc-code = io_trn-doc.doc-code  and                                         io_trn-doc-sum.sum-type = 'mis':U no-error.         if available io_trn-doc-sum then do:           run delete-trn  in this-procedure (input io_trn-doc.doc-code,                                               input 'mis':U) no-error.           if error-status:error then do:             undo, return error return-value.           end.         end.
    find first io_trn-doc-sum where io_trn-doc-sum.doc-code = io_trn-doc.doc-code  and                                         io_trn-doc-sum.sum-type = 'misc':U no-error.         if available io_trn-doc-sum then do:           run delete-trn  in this-procedure (input io_trn-doc.doc-code,                                               input 'misc':U) no-error.           if error-status:error then do:             undo, return error return-value.           end.         end.
    find first io_trn-doc-sum where io_trn-doc-sum.doc-code = io_trn-doc.doc-code  and                                         io_trn-doc-sum.sum-type = 'ad':U no-error.         if available io_trn-doc-sum then do:           run delete-trn  in this-procedure (input io_trn-doc.doc-code,                                               input 'ad':U) no-error.           if error-status:error then do:             undo, return error return-value.           end.         end.
    find first io_trn-doc-sum where io_trn-doc-sum.doc-code = io_trn-doc.doc-code  and                                         io_trn-doc-sum.sum-type = 'acd':U no-error.         if available io_trn-doc-sum then do:           run delete-trn  in this-procedure (input io_trn-doc.doc-code,                                               input 'acd':U) no-error.           if error-status:error then do:             undo, return error return-value.           end.         end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input io_trn-doc.doc-code ,
                       input 'addsum':U ,
                       input ' ' ) no-error .
  if error-status :error then do:
    undo, return error substitute( "Ошибка при вызове процедуры tdatr-wrt &1.", return-value ).
  end.
end.
procedure delete-trn :
  define input parameter pardoc-code like ub.trn-doc.doc-code     no-undo.
  define input parameter parsum-type like ub.trn-doc-sum.sum-type no-undo.
  define buffer bf_trn-doc      for ub.trn-doc.
  define buffer bf_trn-doc-sum  for ub.trn-doc-sum.
  define buffer bf_doc-line-sum for ub.doc-line-sum.
  do on error undo, return error return-value :
    find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code.
    for each bf_trn-doc-sum where bf_trn-doc-sum.doc-code = pardoc-code and
                                  bf_trn-doc-sum.sum-type = parsum-type exclusive-lock on error undo, return error return-value :
      for each bf_doc-line-sum where bf_doc-line-sum.doc-code = bf_trn-doc.doc-code and
                                     bf_doc-line-sum.sum-type = parsum-type         exclusive-lock on error undo, return error return-value :
        delete bf_doc-line-sum.
      end.
      delete bf_trn-doc-sum.
    end.
  end.
end procedure.
