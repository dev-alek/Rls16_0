DEFINE VARIABLE p-install as logical no-undo init false .
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Импорт групп товаров ".
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
define stream sinp .
define stream slog.
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Ввод"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON r-currency
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE VARIABLE f-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл"
     VIEW-AS FILL-IN
     SIZE 42 BY 1 NO-UNDO.
DEFINE VARIABLE rs-format AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Имя группы", 1,
"Имя группы,код группы,код родительской группы", 2
     SIZE 52 BY 2.5 NO-UNDO.
DEFINE FRAME Dialog-Frame
     rs-format AT ROW 2.21 COL 3.38 NO-LABEL WIDGET-ID 2
     f-name AT ROW 5.04 COL 7.25 COLON-ALIGNED WIDGET-ID 8
     r-currency AT ROW 5.08 COL 51.25 WIDGET-ID 52
     Btn_OK AT ROW 7.21 COL 9
     Btn_Cancel AT ROW 7.25 COL 26.63
     "Выберите формат:" VIEW-AS TEXT
          SIZE 19.5 BY .67 AT ROW 1.25 COL 3.5 WIDGET-ID 6
     SPACE(36.37) SKIP(7.99)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Импорт групп товаров"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       r-currency:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame
DO:
define variable v-ok   as logical   no-undo .
DEFINE VARIABLE v-level-name as character no-undo .
DEFINE VARIABLE v-level-num as integer no-undo .
DEFINE VARIABLE v-full-level-name as character no-undo .
DEFINE VARIABLE v-node-code like ub.gds-grp.node-code no-undo .
DEFINE VARIABLE v-upper-code like ub.gds-grp.upper-code no-undo .
DEFINE VARIABLE v-calc-method like ub.gds-grp.calc-method no-undo .
DEFINE VARIABLE v-increase-pc like ub.gds-grp.increase-pc no-undo .
DEFINE VARIABLE v-print-code  like ub.gds-grp.print-code  no-undo .
DEFINE VARIABLE v-d-pcnt like ub.gds-grp.d-pcnt no-undo .
DEFINE VARIABLE v-new-node-code like ub.gds-grp.node-code no-undo .
DEFINE VARIABLE v-rid as recid no-undo.
DEFINE VARIABLE v-ask as logical no-undo init yes.
DEFINE VARIABLE choice as integer no-undo .
define buffer buf_gds-grp for ub.gds-grp.
do
on error undo, return
:
  assign
    v-ok = false
  .
assign     frame Dialog-Frame f-name  rs-format.
f-name = search(f-name).
if f-name = ? then do:
    message "Не указан файл" view-as alert-box.
    return no-apply.
end.
  input stream sinp from value (f-name).
  define variable v-file-format as character no-undo .
  find first ub.sys-ctrl no-lock .
  if ub.sys-ctrl.db-num <> 0 then do:
    if not p-install then do:
      message
      "Утилиту импорта групп товаров можно запускать только в ГБД"
      view-as alert-box error .
    end.
    return .
  end.
  import stream sinp v-file-format .
  if rs-format = 1 and v-file-format <> "GOODS_GRP_1_0"
     or rs-format = 2 and v-file-format <> "GOODS_GRP_2_0" then do:
    input stream sinp close.
    message
      "Неправильный формат файла" skip
      "Первая строка файла" v-file-format skip
      "Файл" f-name skip
      view-as alert-box error .
    undo, return no-apply .
  end.
  run write-to-log in this-procedure(chr(10) + string(today, "99/99/9999") + chr(32) +
                                     string(time, "HH:MM:SS") + chr(32) +
                                     g#userid) .
  define variable v-full-name as character no-undo .
  repeat
  :
   if rs-format = 1  then import stream sinp unformatted v-full-name.
   else  import stream sinp delimiter ','  v-full-name  v-node-code    v-upper-code.
    assign
      v-ok = true
    .
    v-full-name = trim(v-full-name,'"').
    if v-ask then
    run gbl/d-askw.w (input "Создание групп товаров",
              input "Группа" + chr(10) + v-full-name,
              input "|",
              input "Создать|Не создавать|Создать все|Отмена",
              input "Создать группу (если такой еще нет)|Не создавать группу|Перестать спрашивать и по возможности создать все|Прекратить загрузку групп товаров",
              input 1,
              input 4,
              output choice).
   CASE choice:
    when 1 then do:
      assign
      v-ok = yes.
    end.
    when 2 then do:
      assign
      v-ok = no
      .
    end.
    when 3 then do:
      assign
      v-ok = yes
      v-ask = no
      .
    end.
    when 4 then do:
      leave.
    end.
   END CASE.
   if v-ok = true  and rs-format = 1 then do:
      assign
      v-full-name = trim(v-full-name, chr(47))
      v-full-level-name = "":U
      .
      find first buf_gds-grp no-lock where
                 buf_gds-grp.upper-code = 0 no-error .
      assign
      v-node-code = buf_gds-grp.node-code
      v-calc-method = buf_gds-grp.calc-method
      v-increase-pc = buf_gds-grp.increase-pc
      v-print-code  = buf_gds-grp.print-code
      v-d-pcnt = buf_gds-grp.d-pcnt
      .
      _cycle:
      do v-level-num = 1 to num-entries(v-full-name, chr(47)):
        assign
        v-level-name =  entry(v-level-num, v-full-name, chr(47))
        v-full-level-name = v-full-level-name + v-level-name + chr(47)
        .
        find first buf_gds-grp no-lock where
                   buf_gds-grp.upper-code = v-node-code
               and buf_gds-grp.node-name = v-level-name no-error .
        if not avail buf_gds-grp then do:
         run ref/gdsgrp01.p (
                         input 'ДОБАВЛЕНИЕ':U
                        ,input p-install
                        ,input no
                        ,input yes
                        ,input-output v-new-node-code
                        ,input-output v-node-code
                        ,input v-level-name
                        ,input v-calc-method
                        ,input v-increase-pc
                        ,input v-print-code
                        ,input 'Отключено':U
                        ,input 0
                        ,output v-rid
                        ) no-error.
          if error-status:error then do:
            run write-to-log in this-procedure("error in creating group" + chr(32) + v-full-level-name) .
            next _cycle.
          end.
          if error-status:error then do:
            run write-to-log in this-procedure("error in creating group" + chr(32) + v-full-level-name) .
          end.
          else do:
            run write-to-log in this-procedure("new group" + chr(32) + v-full-level-name) .
          end.
          assign
          v-node-code = v-new-node-code
          .
        end.
        else do:
          run write-to-log in this-procedure("exists group" + chr(32) + v-full-level-name) .
          assign
          v-node-code = buf_gds-grp.node-code
          v-calc-method = buf_gds-grp.calc-method
          v-increase-pc = buf_gds-grp.increase-pc
          v-print-code  = buf_gds-grp.print-code
          v-d-pcnt = buf_gds-grp.d-pcnt
          .
          next _cycle.
        end.
      end.
    end.
    else if v-ok and rs-format = 2 then do:
      assign
      v-full-level-name = "":U
      .
      if num-entries(v-full-name,chr(47)) > 1 then do:
            run write-to-log in this-procedure("Не верно задано имя группы. Следует указывать только имя самой группы, без полного пути" + chr(32) + v-full-name) .
            next .
      end.
      find first buf_gds-grp no-lock where
                 buf_gds-grp.node-code = v-upper-code no-error .
      if not available buf_gds-grp then do:
            run write-to-log in this-procedure("Не найдена родительская группа с кодом" + chr(32) + string(v-upper-code)) .
            next .
      end.
      if can-find (first ub.goods where ub.goods.grp-code = buf_gds-grp.node-code no-lock ) then do:
           run write-to-log in this-procedure("Группа с кодом" + chr(32) + string(v-upper-code) + " содержит товары. Добавление в нее подгрупп запрещено!") .
           next .
      end.
      assign
      v-calc-method = buf_gds-grp.calc-method
      v-increase-pc = buf_gds-grp.increase-pc
      v-print-code  = buf_gds-grp.print-code
      v-d-pcnt = buf_gds-grp.d-pcnt
      .
      find first buf_gds-grp no-lock where
                 buf_gds-grp.node-code = v-node-code no-error .
        if not avail buf_gds-grp then do:
         run ref/gdsgrp01.p (
                         input 'ДОБАВЛЕНИЕ':U
                        ,input p-install
                        ,input yes
                        ,input yes
                        ,input-output v-node-code
                        ,input-output v-upper-code
                        ,input v-full-name
                        ,input v-calc-method
                        ,input v-increase-pc
                        ,input v-print-code
                        ,input 'Отключено':U
                        ,input 0
                        ,output v-rid
                        ) no-error.
          if error-status:error then do:
            run write-to-log in this-procedure("error in creating group" + chr(32) + v-full-level-name) .
            next .
          end.
          if error-status:error then do:
            run write-to-log in this-procedure("error in creating group" + chr(32) + v-full-level-name) .
          end.
          else do:
            run write-to-log in this-procedure("new group" + chr(32) + v-full-level-name) .
          end.
          assign
          v-node-code = v-new-node-code
          .
        end.
        else do:
          run write-to-log in this-procedure("exists group" + chr(32) + v-full-level-name) .
          assign
          v-node-code = buf_gds-grp.node-code
          v-calc-method = buf_gds-grp.calc-method
          v-increase-pc = buf_gds-grp.increase-pc
          v-print-code  = buf_gds-grp.print-code
          v-d-pcnt = buf_gds-grp.d-pcnt
          .
          next .
        end.
      end.
    end.
if session :set-wait-state( "" ) then.
  end.
  input stream sinp close.
message "Импорт завершен".
END.
ON CHOOSE OF r-currency IN FRAME Dialog-Frame
DO:
def var v-ok as log.
      system-dialog get-file f-name
      title "Выберите файл с группами товаров"
      filters "Файлы групп товаров *.ggr" "*.ggr",
                "Все файлы  *.*" "*.*"
      INITIAL-DIR "."
      return-to-start-dir
      must-exist
      update v-ok
      default-extension "ggr".
    if v-ok <> true then do:
      return .
    end.
f-name:screen-value = search(f-name).
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY rs-format f-name
      WITH FRAME Dialog-Frame.
  ENABLE rs-format f-name r-currency Btn_OK Btn_Cancel
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE write-to-log :
define input parameter P-MESSAGE as character no-undo .
  do
  on error undo, return error
  :
    output STREAM SLOG TO imp-ggr.log append.
    put STREAM SLOG unformatted
    P-MESSAGE SKIP.
    OUTPUT STREAM SLOG CLOSE.
  end.
END PROCEDURE.
