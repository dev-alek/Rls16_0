define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экспорт результатов продаж".
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
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
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
define temp-table mapobj no-undo
field obj-type as character
field obj-code as integer
field kan-code as character
index pi is unique primary obj-type obj-code.
define variable map-str as character no-undo.
define variable c_obj-type as character no-undo.
define variable i_obj-code as integer no-undo.
define variable c_kan-code as character no-undo.
input from value(search('mapobj.txt')).
repeat:
  import unformatted map-str.
  assign
  c_obj-type = entry(1, entry(1, map-str, ';'), ',')
  i_obj-code = integer(entry(2, entry(1, map-str, ';'), ','))
  c_kan-code = entry(2, map-str, ';') no-error.
  if error-status:error then do:
      message "Ошибка при чтении файла mapobj.txt" view-as alert-box error.
      return.
  end.
  create mapobj.
  assign
  mapobj.obj-type = c_obj-type
  mapobj.obj-code = i_obj-code
  mapobj.kan-code = c_kan-code.
end.
input close.
define stream txt.
define variable v_os-file as char no-undo.
define variable prt-name as char no-undo.
define variable t1 as char no-undo.
define variable nal as logical no-undo.
define variable beznal as logical no-undo.
define variable ToP as char no-undo.
define variable dcrd as char no-undo.
define variable v-obj as character no-undo.
define variable VAT-p like ub.tax-rate-value.rate-value no-undo .
define variable SLT-p like ub.tax-rate-value.rate-value no-undo .
DEFINE BUTTON B-file
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Cancel"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "OK"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE VARIABLE date-beg AS DATE FORMAT "99/99/9999":U
     LABEL "Даты С"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.
DEFINE VARIABLE date-End AS DATE FORMAT "99/99/9999":U
     LABEL "По"
     VIEW-AS FILL-IN
     SIZE 11.5 BY 1 NO-UNDO.
DEFINE VARIABLE file-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл"
     VIEW-AS FILL-IN
     SIZE 39 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     date-beg AT ROW 1.5 COL 9 COLON-ALIGNED
     date-End AT ROW 1.5 COL 28.5 COLON-ALIGNED
     file-name AT ROW 3 COL 1.5
     B-file AT ROW 3 COL 47
     Btn_OK AT ROW 4.5 COL 9.5
     Btn_Cancel AT ROW 4.5 COL 29
     SPACE(6.12) SKIP(0.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Экспорт чеков в файл"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-file IN FRAME Dialog-Frame
DO:
    DEF VAR ll_commit AS LOG    NO-UNDO INIT NO.
    SYSTEM-DIALOG GET-FILE v_os-file
        TITLE "Выберите файл для экспорта"
        FILTERS
          " Текстовые файлы (*.txt) " "*.txt",
          " Все файлы (*.*) "                      "*.*"
        ask-overwrite
        save-as
        use-filename
        update ll_commit
        default-extension "txt"
        .
    IF ll_commit <> YES THEN do:
       RETURN NO-APPLY.
    end.
    IF v_os-file = PROGRAM-NAME( 1 ) THEN DO:
        BELL.
        MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    ASSIGN file-name = ( IF SEARCH( v_os-file ) = ? THEN v_os-file ELSE SEARCH( v_os-file ) ).
    DISP file-name WITH FRAME Dialog-Frame.
END.
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame
DO:
  assign
        date-beg
        date-end
        .
  if date-beg > date-end then do:
         message "Дата начала периода должна быть меньше даты конца". pause.
  end.
  else if date-beg = ? then do:
         message "Не задана дата C". pause  .
  end.
  else if date-end = ? then do:
         message "Не задана дата По". pause.
  end.
  else do:
        if trim(v_os-file) = "" then do:
             message "Не задан файл для экспорта". pause.
        end.
        else do:
              output stream txt to value (v_os-file) no-echo.
              put stream txt  unformatted
                 "SHOP ID; CASH REGISTER ID; CASSIER ID; ID NUMBER OF DOCUMENT; DATE; TIME; INDEX-COLOR-SIZE; QUANTITY; PRICE WITHOUT DISCOUNT OF ONE ITEM; VAT IN %; SALES IN %; AMOUNT OF DISCOUNT OF ONE ITEM; TYPE OF PAYMENT; FIDELITY CARD NUMBER"
              skip.
              _chk-doc:
              FOR EACH chk-doc NO-LOCK where
                     chk-doc.obj-type = v-cntxt-obj-type  and
                     chk-doc.obj-code = v-cntxt-obj-code  and
                     chk-doc.chk-date >= date-beg   and
                     chk-doc.chk-date <= date-end
                   by chk-doc.chk-date
                   by chk-doc.chk-time
                   by chk-doc.pay-desk
                   :
                   if lookup(string(chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) > 0 then next _chk-doc.
                   display
                            chk-doc.doc-code
                            chk-doc.chk-date
                         with frame ff view-as dialog-box
                         title ": Экспорт чеков в файл".
                   pause 0.
                   find first mapobj no-lock where mapobj.obj-type = chk-doc.obj-type
                                               and mapobj.obj-code = chk-doc.obj-code no-error.
                   if available mapobj then v-obj = mapobj.kan-code.
                   else v-obj = 'R' + string(chk-doc.obj-code, "99").
                   assign
                      nal = FALSE
                      beznal = FALSE
                      .
                   for each chk-pay no-lock where
                                  chk-pay.doc-code = chk-doc.doc-code:
                          if chk-pay.pay-code = 1 then    nal = TRUE.
                          else  beznal = TRUE.
                   end.
                   if nal and beznal then ToP = "MX".
                   else if nal then ToP = "GO".
                   else if beznal then ToP = "KK".
                   for each chk-gds no-lock where
                                chk-gds.doc-code = chk-doc.doc-code and
                                chk-gds.doc-qnty <> 0 ,
                        FIRST bar-code No-LOCK WHERE
                                  bar-code.b-code = chk-gds.b-code :
                        FIND FIRSt goods WHERE
                                        goods.gds-code = bar-code.gds-code NO-LOCK.
                        FIND FIRST gds-prt WHERE
                                          gds-prt.node-code = bar-code.node-code NO-LOCK.
                        assign
                            vat-p = ?
                            SLT-p = ?
                            .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output vat-p
  ) no-error .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output slt-p
  ) no-error .
                        prt-name =( if gds-prt.node-name = '_Пустая шкала':U then "-"
                                           else ( if gds-prt.upper-code = goods.prt-root
                                                       then "-------------------" else gds-prt.f-name ) ) .
                        t1  = "-".
                        if r-index(prt-name, "/") > 0 then overlay ( prt-name, r-index(prt-name, "/"), 1) = t1.
                        if chk-doc.d-card = ? or chk-doc.d-card = "" then dcrd = "0".
                        else dcrd = chk-doc.d-card.
                        put stream txt  unformatted
                               trim(string(v-obj)) + ";" +
                               trim(string(chk-doc.pay-desk,">999"))  + ";" +
                               trim(string(chk-doc.cashier,">999"))  + ";" +
                               trim(string(chk-doc.chk-num)) + ";" +
                               trim(string(year(chk-doc.chk-date), "9999")) + "-" +
                               trim(string(month(chk-doc.chk-date), "99")) + "-" +
                               trim(string(DAY(chk-doc.chk-date), "99")) + ";" +
                               trim(string(chk-doc.chk-time, "HH:MM:SS")) + ";" +
                               trim(string(goods.artic)) + "-" +
                               trim(string(prt-name)) + ";" +
                               trim(string(chk-gds.doc-qnty)) + ";" +
                               trim(string(chk-gds.price-base)) + ";" +
                               trim(string(vat-p)) + ";" +
                               trim(string(slt-p)) + ";" +
                               trim(string(chk-gds.discnt)) + ";" +
                               trim(string(ToP)) + ";" +
                               trim(string(dcrd))
                        skip.
                   end.
              end.
              output close.
              message "Экспорт в файл закончен.".
        end.
  end.
END.
ON LEAVE OF file-name IN FRAME Dialog-Frame
DO:
    ASSIGN file-name.
    IF SEARCH( file-name ) <> ? AND SEARCH( file-name ) <> "":U THEN DO:
        ASSIGN FILE-INFO:FILE-NAME = file-name.
        IF FILE-INFO:FULL-PATHNAME <> ? THEN ASSIGN file-name = FILE-INFO:FULL-PATHNAME.
        DISP file-name WITH FRAME Dialog-Frame.
    END.
    APPLY "TAB":U TO file-name IN FRAME Dialog-Frame.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if v-cntxt-obj-type <> 'маг':U then do:
    message "Текущий объект не МАГАЗИН!"
    view-as alert-box ERROR.
    BELL.
    return error.
  end.
  date-beg = today.
  date-end = today.
  assign
  date-beg
  date-end.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY date-beg date-End file-name
      WITH FRAME Dialog-Frame.
  ENABLE date-beg date-End file-name B-file Btn_OK Btn_Cancel
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
