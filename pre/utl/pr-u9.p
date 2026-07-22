block-level on error undo, throw.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pr-u9.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/pr-u9.p $":U .
define variable vss-description as character no-undo init "".
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
define variable g#log as logical   no-undo .
define variable g#ok as integer   no-undo .
define variable v-exist as logical no-undo init false .
define variable bbb as integer   no-undo .
define variable rr as recid     no-undo .
define variable str as character no-undo .
g#log =  session:SET-WAIT-STATE("GENERAL") .
define buffer buf_price-doc for price-doc.
define buffer buf1_price-list for price-list.
on WRITE of price-list override do: end.
for each gds-obj no-lock where gds-obj.price-sale  <> 0
    break by gds-obj.obj-type by gds-obj.obj-code :
    if first-of (gds-obj.obj-code) then do:
        g#ok = 0.
       find first buf_price-doc no-lock where buf_price-doc.doc-num = "2-"+ gds-obj.obj-type + string(gds-obj.obj-code) no-error .
       if error-status :error then find first buf_price-doc no-lock where buf_price-doc.obj-type =  gds-obj.obj-type and buf_price-doc.obj-code = gds-obj.obj-code no-error .
       create price-doc.
       BUFFER-COPY buf_price-doc TO price-doc
       assign
         price-doc.doc-num = "3-"+ gds-obj.obj-type + string(gds-obj.obj-code)
         price-doc.status_  = 'новый':U
         price-doc.fact-num = 0
         price-doc.fact-order = 0
         price-doc.fact-date  = ?
         price-doc.creid  = "TradeHouse"
         price-doc.cr-db-num  =  0
         price-doc.ps  =  "Дополнение к обрезанию"
       .
    end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  gds-obj.gds-code
  ,input  ?
  ,output bbb
  ) no-error .
    find first buf1_price-list exclusive-lock  where
               buf1_price-list.obj-type  = gds-obj.obj-type and
               buf1_price-list.obj-code  = gds-obj.obj-code and
               buf1_price-list.b-code    =  bbb and
               buf1_price-list.price-type =  "" and
               buf1_price-list.fact-order > 1  and
               buf1_price-list.artic     = gds-obj.artic    and
               buf1_price-list.prod-type = gds-obj.prod-type and
               buf1_price-list.prod-code = gds-obj.prod-code no-error .
    if not available buf1_price-list then do:
        g#ok = g#ok + 1.
        find first price-doc no-lock where price-doc.doc-num = "3-"+ gds-obj.obj-type + string(gds-obj.obj-code) no-error .
        if error-status :error then message error-status :get-message(1) 123 view-as alert-box .
        create price-list.
        assign
          price-list.doc-num       =  price-doc.doc-num
          price-list.b-code        =  bbb
          price-list.calc-method   =  ""
          price-list.artic         =  gds-obj.artic
          price-list.prod-code     =  gds-obj.prod-code
          price-list.prod-type     =  gds-obj.prod-type
          price-list.d-pcnt        =  0
          price-list.doc-qnty      =  0
          price-list.excise        =  0
          price-list.fact-order    =  0
          price-list.line-num      =  g#ok
          price-list.main-price    =  true
          price-list.obj-code      =  gds-obj.obj-code
          price-list.obj-type      =  gds-obj.obj-type
          price-list.price-calc    =  0
          price-list.price-prev    =  0
          price-list.price-sale    =  gds-obj.price-sale
          price-list.price-type    =  ""
          price-list.road-tax      =  0
          no-error .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  gds-obj.gds-code
  ,input  '1':U
  ,input  ?
  ,input  price-doc.host-code
  ,input  price-doc.obj-type
  ,input  price-doc.obj-code
  ,output price-list.vat-pc
  ) no-error .
                if error-status :error
                then do:
                 message error-status :get-message(1) 33
                 view-as alert-box .
                end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  gds-obj.gds-code
  ,input  '2':U
  ,input  ?
  ,input  price-doc.host-code
  ,input  price-doc.obj-type
  ,input  price-doc.obj-code
  ,output price-list.slt-pc
  ) no-error .
                if error-status :error
                then do:
                 message error-status :get-message(1) 444
                 view-as alert-box .
                end.
    end.
    if last-of (gds-obj.obj-code) then do:
       if g#ok = 0 then do:
       end.
       else str = str + price-doc.doc-num  + " " .
       g#ok = 0 .
    end.
g#log =  session:SET-WAIT-STATE("") .
end.
message "ВСЕ готово" str view-as alert-box .
