block-level on error undo, throw.
define input parameter parparentproc AS WIDGET-HANDLE        NO-UNDO.
define input parameter pardoc-code   like ub.trn-doc.doc-code   no-undo.
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: fltransp.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/fltransp.p $":U .
define variable vss-description as character no-undo initial "Размазывание наценки за срочность и работу, стоимость доставки по строкам накладной":U .
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable varhost-code  like ub.trn-doc.obj-code no-undo.
define variable v-deliv-rubl  like ub.gds-dtl.price-rubl  no-undo .
define variable v-deliv-base  like ub.gds-dtl.price-rubl no-undo .
define variable v-nac-rubl  like ub.gds-dtl.price-rubl  no-undo .
define variable v-nac-base  like ub.gds-dtl.price-rubl no-undo .
define variable par-sum_deliv like ub.gds-dtl.price-rubl  no-undo .
define variable v-deliv      as character no-undo .
define variable v-sumwrk     as character no-undo .
define variable v-sumsrk     as character no-undo .
define variable v-stop       as character no-undo .
define variable v-type       as character no-undo .
define buffer ready_trn-doc for ub.trn-doc.
find ub.trn-doc where ub.trn-doc.doc-code = pardoc-code no-lock no-error.
if not available ub.trn-doc then do:
   message "Не найден документ с кодом: " pardoc-code
   view-as alert-box.
   return error.
end.
find first ready_trn-doc no-lock where ready_trn-doc.doc-code = ub.trn-doc.out-code and
                                       ready_trn-doc.status_ = 'готов':U no-error .
if error-status :error then return.
if ub.trn-doc.status_ <> 'разрешен':U then return .
v-deliv = "" . run attr-read in this-procedure (  input ub.trn-doc.doc-code                                 ,  input '5deliv':U                                 , output v-deliv                                 , output v-type ).
define variable v-sss      as decimal   no-undo .
define variable v-sss-base as decimal   no-undo .
v-sss = decimal (v-deliv) .
if v-sss = 0 then return .
tr:
do transaction
   ON ERROR   UNDO tr, LEAVE
   ON END-KEY UNDO tr, LEAVE
   ON STOP    UNDO tr , LEAVE :
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input ub.trn-doc.doc-code ,
                       input 'discnt-other':U ,
                       input 'yes':U )  .
   for each ub.gds-dtl exclusive-lock   where ub.gds-dtl.doc-code = pardoc-code:
      v-deliv-rubl = 0 .
      v-deliv-base = 0 .
       assign
             v-deliv-rubl =  ub.gds-dtl.fact-qnty  * v-sss  /  ub.trn-doc.fact-qnty
             v-deliv-base = v-deliv-rubl  * ub.trn-doc.base-scale / ub.trn-doc.base-rate
             ub.gds-dtl.ov = true
             ub.gds-dtl.price-rubl = ub.gds-dtl.price-rubl + ( v-deliv-rubl / ub.gds-dtl.fact-qnty)
             ub.gds-dtl.price-base = ub.gds-dtl.price-base + ( v-deliv-base / ub.gds-dtl.fact-qnty)
             .
   end.
   assign
      ub.trn-doc.tot-transp = v-sss
      no-error .
   if error-status :error then return error .
 end.
 run gbl/calc-trn.p
     (input parparentproc, input recid(ub.trn-doc)) no-error.
 if error-status :error then return error return-value  .
procedure attr-read :
  define  input parameter p-doc-code like ub.doc-attr.doc-code   no-undo.
  define  input parameter p-code     like ub.doc-attr.attr-code  no-undo.
  define output parameter p-value    like ub.doc-attr.attr-value no-undo.
  define output parameter p-type     as   character              no-undo.
  do on error undo, return error return-value :
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input p-code ,
                       output p-value ,
                       output p-type )  .
  end.
end procedure.
