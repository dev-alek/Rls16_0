block-level on error undo, throw.
define input parameter parparentproc AS WIDGET-HANDLE        NO-UNDO.
define input parameter pardoc-code   like trn-doc.doc-code   no-undo.
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: raspdelv.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/raspdelv.p $":U .
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
define variable varhost-code  like trn-doc.obj-code no-undo.
define variable v-deliv-rubl  like gds-dtl.price-rubl  no-undo .
define variable v-deliv-base  like gds-dtl.price-rubl no-undo .
define variable v-nac-rubl  like gds-dtl.price-rubl  no-undo .
define variable v-nac-base  like gds-dtl.price-rubl no-undo .
define variable par-sum_deliv like gds-dtl.price-rubl  no-undo .
define variable v-deliv      as character no-undo .
define variable v-sumwrk     as character no-undo .
define variable v-sumsrk     as character no-undo .
define variable v-stop       as character no-undo .
define variable v-type       as character no-undo .
define buffer ready_trn-doc for trn-doc.
find trn-doc where trn-doc.doc-code = pardoc-code no-lock no-error.
find first ready_trn-doc no-lock where ready_trn-doc.doc-code = trn-doc.out-code and
                                       ready_trn-doc.status_ = 'готов':U no-error .
if error-status :error then return.
if trn-doc.status_ <> 'разрешен':U then return .
v-deliv = "" .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input trn-doc.doc-code ,
                        input '5deliv':U ,
                       output v-deliv ,
                       output v-type )  .
v-sumwrk = "" .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input trn-doc.doc-code ,
                        input '6sumwrk':U ,
                       output v-sumwrk ,
                       output v-type )  .
v-sumsrk = "" .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input trn-doc.doc-code ,
                        input '7sumsrk':U ,
                       output v-sumsrk ,
                       output v-type )  .
define variable v-sum  like gds-dtl.price-rubl    no-undo .
define variable v-sss as decimal   no-undo .
define variable v-sum-new-rubl as character no-undo .
define variable i-sum-rubl as decimal   no-undo .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input trn-doc.doc-code ,
                        input 'discnt-stop':U ,
                       output v-sum-new-rubl ,
                       output v-type )  .
      i-sum-rubl = dec (v-sum-new-rubl) .
   if i-sum-rubl = 0 then return error .
   v-sss = decimal (v-deliv) .
if par-sum_deliv = ? then par-sum_deliv = 0.
define variable v-sum-rm as decimal   no-undo .
v-sum-rm =  ( (i-sum-rubl -  v-sss )  * 100 / ( 100 - trn-doc.discnt-pc )) - trn-doc.tot-sale .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  trn-doc.obj-type
  ,input  trn-doc.obj-code
  ,output varhost-code
  )  .
if not available trn-doc then do:
   message "Не найден документ с кодом: " pardoc-code
   view-as alert-box.
   return error.
end.
tr:
do transaction
   ON ERROR   UNDO tr, LEAVE
   ON END-KEY UNDO tr, LEAVE
   ON STOP    UNDO tr , LEAVE :
   for each gds-dtl exclusive-lock where gds-dtl.doc-code = pardoc-code:
      v-deliv-rubl = 0 .
      v-deliv-base = 0 .
      v-nac-rubl = 0 .
      v-nac-base = 0 .
       assign
             v-nac-base = gds-dtl.price-base  * v-sum-rm / ( trn-doc.tot-sale  )
             v-nac-rubl = gds-dtl.price-rubl  * v-sum-rm / ( trn-doc.tot-sale  )
             v-deliv-rubl = gds-dtl.price-rubl  *  gds-dtl.fact-qnty  * v-sss /  trn-doc.tot-sale
             v-deliv-base = v-deliv-rubl  * trn-doc.base-scale / trn-doc.base-rate
             gds-dtl.ov = true
             gds-dtl.price-rubl = gds-dtl.price-rubl + v-nac-rubl
             gds-dtl.price-base = gds-dtl.price-base + v-nac-base
             .
              find first doc-line exclusive-lock where
                         doc-line.doc-code = gds-dtl.doc-code  and
                         doc-line.artic    = gds-dtl.artic     and
                         doc-line.prod-type = gds-dtl.prod-type and
                         doc-line.prod-code = gds-dtl.prod-code no-error .
             if available doc-line then do:
             doc-line.transport-rubl = ( if doc-line.transport-rubl = ? then 0 else doc-line.transport-rubl ) + v-deliv-rubl .
             doc-line.transport-base = ( if doc-line.transport-base = ? then 0 else doc-line.transport-base ) + v-deliv-base .
             end.
             else do:
             message error-status :get-message(1) "error" .
             return error .
             end.
   end.
   assign
      trn-doc.tot-transp = v-deliv-rubl
      no-error .
   if error-status :error then return error .
 end.
