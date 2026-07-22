block-level on error undo, throw.
define parameter buffer doc-line for ub.doc-line.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable varinvclcspvalue                    as   character no-undo.
define variable varinvclcsptype                     as   character no-undo.
define variable varinvclcwtol                       as   logical   no-undo.
define variable prtvalue   as character no-undo.
define variable partsvalue as character initial ?   no-undo.
define variable varr-b     as character no-undo.
define variable is-cdinv   as character no-undo .
define variable p-value as character no-undo.
define variable p-type  as character no-undo.
find first trn-doc where trn-doc.doc-code = doc-line.doc-code.
assign
  varinvclcspvalue = "no".
run str/invdcfrd.p (input  trn-doc.doc-code,
                output varinvclcspvalue,
                output prtvalue,
                output varr-b,
                output is-cdinv ).
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input trn-doc.doc-code ,
                        input 'clcaswt':U ,
                       output p-value ,
                       output p-type )  .
assign
  varinvclcwtol = (if p-value = "yes" then yes else no).
run trg/rsrv-del.p
  (input doc-line.doc-code
  ,input doc-line.artic
  ,input doc-line.prod-type
  ,input doc-line.prod-code
  ) .
for each gds-dtl where gds-dtl.doc-code  = doc-line.doc-code  and
                       gds-dtl.artic     = doc-line.artic     and
                       gds-dtl.prod-type = doc-line.prod-type and
                       gds-dtl.prod-code = doc-line.prod-code on error undo, return error return-value :
  delete gds-dtl.
end.
delete doc-line.
if trn-doc.status_ = 'разрешен':U and
   trn-doc.flag_   = no           then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:   run str/lib-trn2.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:     message       "Error starting lib-trn2.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn2_reclctsl in g#lib-trn2
(input trn-doc.doc-code,
 input 'bd':U
)
.
  if varinvclcwtol then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:   run str/lib-trn2.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:     message       "Error starting lib-trn2.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn2_reclctsl in g#lib-trn2
(input trn-doc.doc-code,
 input 'wst':U
)
.
  end.
  if varinvclcspvalue = "yes" then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:   run str/lib-trn2.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:     message       "Error starting lib-trn2.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn2_reclctsl in g#lib-trn2
(input trn-doc.doc-code,
 input 'bcd':U
)
.
    if varinvclcwtol then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:   run str/lib-trn2.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:     message       "Error starting lib-trn2.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn2_reclctsl in g#lib-trn2
(input trn-doc.doc-code,
 input 'wstc':U
)
.
    end.
  end.
end.
