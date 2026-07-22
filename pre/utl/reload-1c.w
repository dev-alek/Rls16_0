DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Ручной режим работы OpenXML".
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define new shared stream vProtTest.
define new shared variable testId as rowid no-undo.
define temp-table ttMess
  field fCheck as logical init no
  field fMess  as character
  field fCount as integer
.
define temp-table ttLoaded no-undo
  field fMess as character
  field fKey as character
  index pi fMess fKey
.
output stream vProtTest to terminal.
DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "Выход"
     SIZE 13 BY 1.14.
DEFINE BUTTON b-load
     LABEL "Перевыгрузить"
     SIZE 18 BY 1.14.
DEFINE BUTTON b-mark
     LABEL "*"
     SIZE 4 BY 1.19.
DEFINE BUTTON b-mark-all
     LABEL "Все *"
     SIZE 8 BY 1.19.
DEFINE QUERY BROWSE-mess FOR
      ttMess SCROLLING.
DEFINE BROWSE BROWSE-mess
  QUERY BROWSE-mess DISPLAY
      ttMess.fCheck column-label "*" format "*/"
ttMess.fMess  column-label "Сообщение"  format "X(20)" width 40
ttMess.fCount column-label "Количество" format ">>>,>>9"
    WITH SEPARATORS SIZE 66 BY 10.48 ROW-HEIGHT-CHARS .57 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-mark AT ROW 1.43 COL 16.8 WIDGET-ID 2
     b-mark-all AT ROW 1.43 COL 21.6 WIDGET-ID 4
     b-exit AT ROW 1.48 COL 3.2 WIDGET-ID 8
     b-load AT ROW 1.48 COL 51 WIDGET-ID 6
     BROWSE-mess AT ROW 3.38 COL 3 WIDGET-ID 200
     SPACE(2.19) SKIP(1.13)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Перевыгрузка в 1С" WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-load IN FRAME Dialog-Frame
DO:
  define variable vCnt  as int64     no-undo.
  define variable vMess as character no-undo.
  define buffer b-ttMess for ttMess.
  for each b-ttMess where b-ttMess.fCheck:
    vMess = substitute("&1,&2", vMess, b-ttMess.fMess).
  end.
  if vMess = "" then
  do:
    message "Не выбраны сообщения для перевыгрузки." view-as alert-box.
    return no-apply.
  end.
  vMess = substring(vMess,2).
  message
    "Сейчас из не подтвержденных пакетов будут удалены сообщения "
    vMess " и перевыгружены в 1С." skip
    "Вы уверены?"
    view-as alert-box question buttons yes-no update vLog as logical.
  if not vLog then
    return no-apply.
  run reLoad in this-procedure (output vCnt).
  if vCnt > 0 then
  do:
    message "Перевыгружено" vCnt "сообщений." view-as alert-box.
    run reopen in this-procedure.
  end.
END.
ON CHOOSE OF b-mark IN FRAME Dialog-Frame
DO:
  if available ttMess then
  do:
    ttMess.fCheck = not ttMess.fCheck.
    reposition BROWSE-mess forwards 0.
    BROWSE-mess:refresh() .
    apply "entry" to BROWSE-mess in frame Dialog-Frame.
  end.
END.
ON CHOOSE OF b-mark-all IN FRAME Dialog-Frame
DO:
  define buffer b-ttMess for ttMess.
  if not can-find(first b-ttMess where not ttMess.fCheck) then
  do:
    for each b-ttMess:
      b-ttMess.fCheck = no.
    end.
  end.
  else
  do:
    for each b-ttMess:
      b-ttMess.fCheck = yes.
    end.
  end.
  BROWSE-mess:refresh().
  reposition BROWSE-mess to row 1.
  apply "entry" to BROWSE-mess in frame Dialog-Frame.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run createTT in this-procedure.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE CreateTT :
define buffer buf_esys-pck-sent   for ub.esys-pck-sent.
define buffer buf_esys-route      for ub.esys-route.
define buffer buf_esys-route-dump for ub.esys-route-dump.
for each buf_esys-pck-sent where
         buf_esys-pck-sent.esps-rcvd = no
    no-lock,
    each buf_esys-route where
         buf_esys-route.esys-id       = buf_esys-pck-sent.esys-id
     and buf_esys-route.db-num        = buf_esys-pck-sent.db-num
     and buf_esys-route.esr-last-pack = buf_esys-pck-sent.esps-pack-num
    no-lock,
    first buf_esys-route-dump where
          buf_esys-route-dump.esrd-dump-ord = buf_esys-route.esr-dump-ord
      and buf_esys-route-dump.esrd-dump-name <> "sales-p-shifts"
      and buf_esys-route-dump.esrd-uniq-key-rec <> ""
      and num-entries(buf_esys-route-dump.esrd-uniq-key-rec,chr(3)) > 1
    no-lock
    break by buf_esys-route-dump.esrd-dump-name:
  accum esys-route-dump.esrd-dump-ord (count by buf_esys-route-dump.esrd-dump-name).
  if last-of(buf_esys-route-dump.esrd-dump-name) then
  do:
    create ttMess.
    assign
      ttMess.fMess  = buf_esys-route-dump.esrd-dump-name
      ttMess.fCount = accum count by buf_esys-route-dump.esrd-dump-name esys-route-dump.esrd-dump-ord
    .
  end.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE b-mark b-mark-all b-exit b-load BROWSE-mess
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BROWSE-mess FOR EACH ttMess.
END PROCEDURE.
PROCEDURE reLoad :
  define output parameter oCnt as int64 no-undo.
  define variable vTable   as character no-undo.
  define variable vUtil    as character no-undo.
  define variable vMess    as character no-undo.
  define variable vBuf     as handle    no-undo.
  define variable vLoad    as logical   no-undo.
  define buffer buf_esys-pck-sent    for ub.esys-pck-sent.
  define buffer buf_esys-route       for ub.esys-route.
  define buffer buf1_esys-route      for ub.esys-route.
  define buffer buf_esys-route-dump  for ub.esys-route-dump.
  define buffer buf1_esys-route-dump for ub.esys-route-dump.
  define buffer b-ttMess for ttMess.
  empty temp-table ttLoaded.
  for each buf_esys-pck-sent where
         buf_esys-pck-sent.esps-rcvd = no
    exclusive-lock,
    each buf_esys-route where
         buf_esys-route.esys-id       = buf_esys-pck-sent.esys-id
     and buf_esys-route.db-num        = buf_esys-pck-sent.db-num
     and buf_esys-route.esr-last-pack = buf_esys-pck-sent.esps-pack-num
    exclusive-lock,
    first buf_esys-route-dump where
          buf_esys-route-dump.esrd-dump-ord = buf_esys-route.esr-dump-ord
      and buf_esys-route-dump.esrd-uniq-key-rec  <> ""
      and num-entries(buf_esys-route-dump.esrd-uniq-key-rec,chr(3)) > 1
    exclusive-lock:
    vLoad = false.
    if can-find(first b-ttMess where
                      b-ttMess.fMess = buf_esys-route-dump.esrd-dump-name
                  and b-ttMess.fCheck) then
    do:
      find first ttLoaded no-lock where
                 ttLoaded.fMess = buf_esys-route-dump.esrd-dump-name
             and ttLoaded.fKey  = buf_esys-route-dump.esrd-uniq-key-rec
           no-error.
      if not avail ttLoaded then
      do:
          assign
            vTable    = entry(1,buf_esys-route-dump.esrd-uniq-key-rec,chr(3))
            testId = to-rowid(entry(2,buf_esys-route-dump.esrd-uniq-key-rec,chr(3)))
            vUtil = ""
            vMess = ""
            vLoad = true.
          .
          case buf_esys-route-dump.esrd-dump-name:
          when "trn-gd-docs" or
          when "trn-fuel-docs" or
          when "inv-gd-docs" or
          when "peres-gd-docs" then
            if vTable = "fbr-doc" then
              vUtil = "send6c.p".
            else
              vUtil = "send1c.p".
          when "shifts" or
          when "sales-p-shifts" then
            vUtil = "send2c.p".
          when "check-fuel-docs" then
            vUtil = "send3c.p".
          when "price-docs" then
            vUtil = "send4c.p".
          when "cash" then
            vUtil = "send5c.p".
          when "edi-docs" then
            vUtil = "send7c.p".
          when "tanks" then
            vUtil = "send9c.p".
          when "shift-periods" then
            vUtil = "send10c.p".
          end case.
          if vUtil <> "" then
          do:
            run value("utl/" + vUtil) no-error.
          end.
          else
          do:
            case buf_esys-route-dump.esrd-dump-name:
            when "DT-seasons" then
              vMess = "DTSeasons".
            end case.
            if vMess <> "" then do:
                create buffer vBuf for table vTable.
                vBuf:find-by-rowid(testId,no-lock).
                run bge\send1cerp.p (?,
                  this-procedure,
                  this-procedure,
                  vMess,
                  vBuf,
                  ?,
                  ?) no-error.
            end.
            else
              message "Сообщение" buf_esys-route-dump.esrd-dump-name "не может быть отправлено повторно" skip
                      "Не определена процедура отправки." view-as alert-box.
          end.
      end.
      if not error-status:error then
      do:
        if not avail ttLoaded then
        do:
          create ttLoaded.
          assign
            ttLoaded.fMess = buf_esys-route-dump.esrd-dump-name
            ttLoaded.fKey  = buf_esys-route-dump.esrd-uniq-key-rec
          .
        end.
        if buf_esys-route-dump.esrd-dump-name = "shifts" then do:
          for each buf1_esys-route where
                   buf1_esys-route.esys-id       = buf_esys-pck-sent.esys-id
               and buf1_esys-route.db-num        = buf_esys-pck-sent.db-num
               and buf1_esys-route.esr-last-pack = buf_esys-pck-sent.esps-pack-num
              exclusive-lock,
              first buf1_esys-route-dump where
                    buf1_esys-route-dump.esrd-dump-ord = buf1_esys-route.esr-dump-ord
                and buf1_esys-route-dump.esrd-dump-name = "sales-p-shifts"
                and buf1_esys-route-dump.esrd-uniq-key-rec = buf_esys-route-dump.esrd-uniq-key-rec
              exclusive-lock:
            oCnt = oCnt + if vLoad then 1 else 0.
            delete buf1_esys-route-dump.
            delete buf1_esys-route.
            buf_esys-pck-sent.esps-total-recs = buf_esys-pck-sent.esps-total-recs - 1.
          end.
        end.
        oCnt = oCnt + if vLoad then 1 else 0.
        delete buf_esys-route-dump.
        delete buf_esys-route.
        assign
          buf_esys-pck-sent.esps-total-recs = buf_esys-pck-sent.esps-total-recs - 1
          buf_esys-pck-sent.esps-SendTxtDate = ?
          buf_esys-pck-sent.esps-SendTxtTime = ""
          buf_esys-pck-sent.esps-SendTxtTimeInt = 0
        .
        if not can-find (first buf1_esys-route where
                               buf1_esys-route.esys-id       = buf_esys-pck-sent.esys-id
                           and buf1_esys-route.db-num        = buf_esys-pck-sent.db-num
                           and buf1_esys-route.esr-last-pack = buf_esys-pck-sent.esps-pack-num
                        ) then
        do:
          delete buf_esys-pck-sent.
        end.
      end.
      else do:
        message "Ошибка при отправке сообщения" buf_esys-route-dump.esrd-dump-name " процедурой " vUtil skip
                 error-status:get-message(1) view-as alert-box.
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE reopen :
close query BROWSE-mess.
empty temp-table ttMess.
run createTT in this-procedure.
OPEN QUERY BROWSE-mess FOR EACH ttMess.
reposition BROWSE-mess to row 1.
apply "entry" to BROWSE-mess in frame Dialog-Frame.
END PROCEDURE.
