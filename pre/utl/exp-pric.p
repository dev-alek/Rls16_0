block-level on error undo, throw.
define input  parameter parparentproc as handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: exp-pric.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/exp-pric.p $":U .
define variable vss-description as character no-undo init "Экспорт  строк ДНЦ в текстовый файл в формате импорта".
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
define stream txt.
define variable g-log        as logical no-undo.
define variable loc-ref-list as character no-undo .
define variable v-dir-name   as character no-undo .
define variable v-type       as character no-undo .
define variable v-can-write  as logical   no-undo .
define variable num-rec      as integer no-undo.
define variable f-name     as character no-undo.
define variable prtroot    as integer   no-undo .
define variable name-item  as character no-undo .
define variable name-scale as character no-undo .
define variable name-bc    as character no-undo .
define variable name-gtd   as character no-undo .
define variable main-bar-code as integer   no-undo .
define variable pp as character no-undo .
define variable pd as character no-undo .
define buffer buf_gds-prt for ub.gds-prt  .
define buffer buf_price-doc-forming for ub.price-doc-forming  .
define buffer buf_price-doc-forming-gds for ub.price-doc-forming-gds  .
define buffer buf_goods for ub.goods  .
g-log = no.
message "Экспорт главных цен в файл, в формате импорта." skip (2)
        "Продолжать ?"
        view-as alert-box question buttons OK-Cancel update g-log.
if not g-log then return.
find first buf_gds-prt where buf_gds-prt.node-name = '_Пустая шкала':U no-lock no-error.
if available  buf_gds-prt then   prtroot = buf_gds-prt.prt-root.
                          else   prtroot = 0.
run gbl/dir-sel.p
 ( output v-dir-name
  ,output v-type
  ,output v-can-write
  ).
if NOT v-can-write THEN DO:
    message
      "Путь для сохранения файлов не указан."
      view-as alert-box error.
    return no-apply.
END.
run str/docsprls.w
     ( input parParentProc
     , input "all"
     , input ?
     , input ?
     , input "b-sel,b-mark":U
     , input-output loc-ref-list  ).
if loc-ref-list = "" then do:
    message
      "Документы не выбраны"
      view-as alert-box error.
    return no-apply.
END.
do num-rec = 1 to num-entries(loc-ref-list):
   find buf_price-doc-forming where recid ( buf_price-doc-forming) = integer(entry(num-rec, loc-ref-list)) no-lock.
      f-name = v-dir-name + "\" + trim(string( buf_price-doc-forming.pdf-id)) + "bd" + trim(string( buf_price-doc-forming.pdf-db)) + ".adb".
      output stream txt to value (f-name ).
      for each buf_price-doc-forming-gds no-lock  where
               buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id and
               buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and
               buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
               buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db ,
          first buf_goods no-lock
             where buf_goods.artic     = buf_price-doc-forming-gds.artic
               and buf_goods.prod-type = buf_price-doc-forming-gds.prod-type
               AND buf_goods.prod-code = buf_price-doc-forming-gds.prod-code
               break by buf_goods.gds-code
          :
          if first-of ( buf_goods.gds-code) then do:
              display
                buf_goods.artic
                with frame ff view-as dialog-box
              title ": Экспорт ".
              pause 0.
          pp = "" .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output main-bar-code
  )  .
          end.
         if main-bar-code = buf_price-doc-forming-gds.b-code then  pp = trim(string( buf_price-doc-forming-gds.price-sale-doc)) .
          if last-of (buf_goods.gds-code) then do:
              assign
              name-item = "ITEM:"
              name-scale = ""
              name-bc    = string(main-bar-code)
              pd = ""
              .
              put stream txt  unformatted
                  "ITEM:" +
                  buf_goods.artic + ";" +
                  trim(string(buf_goods.prod-code)) + ";;;"+
                  name-bc + ";" +
                  pp + ";;;;" +
                  pd + ";;;;;;" SKIP.
          end.
      END.
      output close.
end.
message "Экспорт ДНЦ в файл закончен."  view-as alert-box information buttons ok.
