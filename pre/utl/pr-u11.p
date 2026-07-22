block-level on error undo, throw.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define stream out-stream .
output stream out-stream to value ( "pr-u121.txt") .
define stream err-stream .
output stream err-stream to value ( "err-121.txt") .
define variable g#log as logical   no-undo .
define variable g#ok as integer   no-undo  init 0.
define variable v-exist as logical no-undo init false .
define variable bbb as integer   no-undo .
define variable rr as recid     no-undo .
define variable str as character no-undo .
g#log =  session:SET-WAIT-STATE("GENERAL") .
define buffer buf_price-doc for ub.price-doc.
define buffer buf1_price-list for ub.price-list.
define buffer buf2_price-list for ub.price-list.
for each ub.gds-obj no-lock where ub.gds-obj.price-sale  <> 0  break by ub.gds-obj.obj-type by ub.gds-obj.obj-code :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  ub.gds-obj.gds-code
  ,input  ?
  ,output bbb
  ) no-error .
if bbb = ? or bbb = 0 or error-status :error then do:
     export stream err-stream
          bbb
          ub.gds-obj.artic
          ub.gds-obj.prod-code
          ub.gds-obj.prod-type
          ub.gds-obj.obj-code
          ub.gds-obj.obj-type
          ub.gds-obj.price-sale
          error-status :get-message(1)
          return-value
          skip
          .
     bbb = gds-obj.gds-code .
end.
    find first buf1_price-list exclusive-lock  where
               buf1_price-list.obj-type  = gds-obj.obj-type and
               buf1_price-list.obj-code  = gds-obj.obj-code and
               buf1_price-list.b-code    =  bbb and
               buf1_price-list.price-type =  "" and
               buf1_price-list.fact-order > 1   and
               buf1_price-list.artic     = gds-obj.artic    and
               buf1_price-list.prod-type = gds-obj.prod-type and
               buf1_price-list.prod-code = gds-obj.prod-code no-error .
    if not available buf1_price-list then do:
        g#ok = g#ok + 1.
          export stream out-stream
          bbb
          gds-obj.artic
          gds-obj.prod-code
          gds-obj.prod-type
          gds-obj.obj-code
          gds-obj.obj-type
          gds-obj.price-sale
          skip
          .
    end.
end.
output stream out-stream close.
output stream err-stream close.
g#log =  session:SET-WAIT-STATE("") .
message "ВСЕ готово в  pr-u121.txt" skip g#ok view-as alert-box .
