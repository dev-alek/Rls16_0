block-level on error undo, throw.
define input  parameter parparentproc as handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: exp-doc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/exp-doc.p $":U .
define variable vss-description as character no-undo init "Ёкспорт строк документа в текстовый файл в формате импорта".
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable g-log        as logical no-undo.
define variable loc-ref-list as character no-undo .
define variable v-dir-name   as character no-undo .
define variable v-type       as character no-undo .
define variable v-can-write  as logical   no-undo .
define variable num-rec as integer no-undo.
define stream txt.
define variable f-name as character no-undo.
define variable prtroot as integer   no-undo .
define variable name-item  as character no-undo .
define variable name-scale as character no-undo .
define variable name-bc    as character no-undo .
define variable name-gtd as character no-undo .
define variable srok-god as character no-undo .
define buffer buf_gds-prt for ub.gds-prt  .
define buffer buf_goods for ub.goods  .
define buffer buf_bar-code for ub.bar-code  .
define buffer buf_trn-doc for ub.trn-doc  .
define buffer buf_doc-line for ub.doc-line  .
define buffer buf_parts for ub.parts  .
define buffer buf_gds-dtl for ub.gds-dtl  .
g-log = no.
message "Ёкспорт документов в файл, в формате импорта." skip (2)
        "ѕродолжать ?"
        view-as alert-box question buttons OK-Cancel update g-log.
if not g-log then return.
find first buf_gds-prt where buf_gds-prt.node-name = '_ѕуста€ шкала':U no-lock no-error.
if available  buf_gds-prt then   prtroot = buf_gds-prt.prt-root.
                      else   prtroot = 0.
run gbl/dir-sel.p
     ( output v-dir-name
      ,output v-type
      ,output v-can-write
      ).
if NOT v-can-write THEN DO:
    message
      "ѕуть дл€ сохранени€ файлов не указан."
      view-as alert-box error.
    return no-apply.
END.
define variable ref-list as char no-undo.
  run str/all-docs.w
    (  input parparentproc
      ,input v-cntxt-host-code-obj
      ,input ?
      ,input ?
      ,input 'фирма':U
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input "b-sel,b-mark":U
      ,input ?
      ,input ?
      ,input ?
      ,output loc-ref-list ).
if loc-ref-list = "" then do:
    message
     "ƒокументы не выбраны"
      view-as alert-box error.
    return no-apply.
END.
do num-rec = 1 to num-entries(loc-ref-list):
   find buf_trn-doc where recid ( buf_trn-doc) = integer(entry(num-rec, loc-ref-list)) no-lock no-error .
    f-name = v-dir-name + "\" + trim( buf_trn-doc.doc-code) + ".adb".
    output stream txt to value (f-name ).
    name-gtd = "" .
    srok-god = "" .
    for each buf_doc-line  no-lock where
             buf_doc-line.doc-code = buf_trn-doc.doc-code,
         first buf_goods no-lock where
               buf_goods.artic     = buf_doc-line.artic   and
               buf_goods.prod-type = buf_doc-line.prod-type  and
               buf_goods.prod-code = buf_doc-line.prod-code
                :
                display
                  buf_goods.artic
                  with frame ff view-as dialog-box
                  title ": Ёкспорт ".
                  pause 0.
                  for each buf_parts no-lock where
                          buf_parts.out-code = buf_trn-doc.doc-code and
                          buf_parts.obj-type = buf_trn-doc.obj-type and
                          buf_parts.obj-code = buf_trn-doc.obj-code and
                          buf_parts.artic    = buf_doc-line.artic and
                          buf_parts.prod-type = buf_doc-line.prod-type and
                          buf_parts.prod-code = buf_doc-line.prod-code
                  :
                         name-gtd = trim(string(buf_parts.cst-code)) .
                         srok-god = trim(string(buf_parts.last-date, "99/99/9999")) .
                         if srok-god = ? then srok-god = "" .
                  end.
      for each buf_gds-dtl no-lock where
               buf_gds-dtl.doc-code  = buf_trn-doc.doc-code  and
               buf_gds-dtl.artic     = buf_doc-line.artic    and
               buf_gds-dtl.prod-type = buf_doc-line.prod-type and
               buf_gds-dtl.prod-code = buf_doc-line.prod-code
      :
        find first buf_bar-code no-lock where
                   buf_bar-code.node-code = buf_gds-dtl.prt-code and
                   buf_bar-code.gds-code  = buf_goods.gds-code    and
                   buf_bar-code.unit-cli  = buf_goods.unit-base   and
                   buf_bar-code.part-code = ""   and
                   buf_bar-code.in-code = ""   .
        IF buf_goods.prt-root <> prtroot then do:
           find first buf_gds-prt no-lock where
                      buf_gds-prt.node-code = buf_gds-dtl.prt-code no-error.
          assign
            name-item  = "SCALE:"
            name-scale = trim(string(buf_gds-prt.f-name))
            name-bc    = trim(string(buf_bar-code.b-code))
            .
        end.
        else do:
          assign
           name-item = "ITEM:"
           name-scale = ""
           name-bc    = trim(string(buf_bar-code.b-code))
           .
        end.
          put stream txt  unformatted
              name-item +
              buf_goods.artic + ";" +
              trim(string(buf_goods.prod-code)) + ";" +
              name-scale + ";;" +
              name-bc    + ";" +
              trim(string(buf_gds-dtl.price-base)) + ";" +
              trim(string(buf_gds-dtl.fact-qnty)) + ";;;;;;;" +
              name-gtd + ";;;" +
              srok-god
              SKIP.
      END.
      end.
      output close.
end.
message "Ёкспорт закончен."  view-as alert-box information buttons ok.
