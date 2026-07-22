DEFINE SHARED TEMP-TABLE tt-fin-doc NO-UNDO LIKE ub.fin-doc.
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo.
define input parameter p-mode as character no-undo.
define input parameter p-host-code like ub.fin-doc.host-code no-undo.
define input parameter p-fin-doc-code like ub.fin-doc.fin-doc-code no-undo.
define input parameter p-fin-ext-doc-type like ub.fin-doc.fin-ext-doc-type no-undo.
define input-output parameter p-doc-rec as recid no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка редактирования платежного поручения-дополнительные поля".
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
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE F-stat-pl AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 51.75 BY 1
     BGCOLOR 15  NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      tt-fin-doc SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.88
     tt-fin-doc.vid-opl AT ROW 2.25 COL 18 COLON-ALIGNED
          LABEL "Вид операции"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
          BGCOLOR 15 FGCOLOR 4
     tt-fin-doc.srok-pl AT ROW 2.25 COL 45.63 COLON-ALIGNED
          LABEL "Срок платежа"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
          BGCOLOR 15 FGCOLOR 4
     tt-fin-doc.nazn-pl AT ROW 3.5 COL 18 COLON-ALIGNED
          LABEL "Назн.платежа(код)"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
          BGCOLOR 15 FGCOLOR 4
     tt-fin-doc.ocher-pl AT ROW 3.5 COL 45.63 COLON-ALIGNED
          LABEL "Очер. платежа"
          VIEW-AS COMBO-BOX INNER-LINES 6
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 12 BY 1
          BGCOLOR 15 FGCOLOR 4
     tt-fin-doc.f22 AT ROW 4.75 COL 18 COLON-ALIGNED
          LABEL "Код"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
          BGCOLOR 15 FGCOLOR 4
     tt-fin-doc.f23 AT ROW 4.75 COL 45.63 COLON-ALIGNED
          LABEL "Резервн. поле"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
          BGCOLOR 15 FGCOLOR 4
     tt-fin-doc.stat-pl AT ROW 6 COL 21.25 COLON-ALIGNED
          LABEL "Статус плательщика"
          VIEW-AS COMBO-BOX INNER-LINES 8
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 7.63 BY 1
          BGCOLOR 15 FGCOLOR 4
     F-stat-pl AT ROW 6 COL 31 COLON-ALIGNED NO-LABEL
     tt-fin-doc.f104 AT ROW 7.25 COL 5.88 COLON-ALIGNED
          LABEL "КБК" FORMAT "X(20)"
          VIEW-AS FILL-IN
          SIZE 23 BY 1
          BGCOLOR 15 FGCOLOR 4
     tt-fin-doc.f105 AT ROW 7.25 COL 56.88 COLON-ALIGNED
          LABEL "ОКАТО муниц.образования"
          VIEW-AS FILL-IN
          SIZE 15 BY 1
          BGCOLOR 15 FGCOLOR 4
     tt-fin-doc.f106 AT ROW 8.5 COL 27 COLON-ALIGNED
          LABEL "Показат. основания платежа"
          VIEW-AS COMBO-BOX INNER-LINES 11
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 6.38 BY 1
          BGCOLOR 15 FGCOLOR 4
     tt-fin-doc.f107 AT ROW 9.75 COL 27 COLON-ALIGNED
          LABEL "Показат. налог. периода"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
          BGCOLOR 15 FGCOLOR 4
     tt-fin-doc.f108 AT ROW 11 COL 27 COLON-ALIGNED
          LABEL "Показат. № документа"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
          BGCOLOR 15 FGCOLOR 4
     tt-fin-doc.f109 AT ROW 12.25 COL 27 COLON-ALIGNED
          LABEL "Показат. даты документа"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
          BGCOLOR 15 FGCOLOR 4
     tt-fin-doc.f110 AT ROW 13.5 COL 27.13 COLON-ALIGNED
          LABEL "Показат. типа платежа"
          VIEW-AS COMBO-BOX INNER-LINES 8
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 12 BY 1
     SPACE(58.11) SKIP(1.34)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Остальные поля платежа"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
    run proc-save in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON VALUE-CHANGED OF tt-fin-doc.stat-pl IN FRAME Dialog-Frame
DO:
    assign
  F-stat-pl = entry (lookup (tt-fin-doc.stat-pl:screen-value, '01,02,03,04,05,06,07,08':U), 'налогоплательщик,налоговый агент,сборщик налогов и сборов,налоговый орган,служба судебных приставов МинЮста Рф,участник внешнеэкономической деятельности,таможенный орган,плательщик иных обязательных платежей':U) no-error .
  if error-status:error then do:
    assign
    f-stat-pl = ?
    .
  end.
  display
  f-stat-pl
  with frame Dialog-Frame.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN Myenable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-fin-doc SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY F-stat-pl
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-fin-doc THEN
    DISPLAY tt-fin-doc.vid-opl tt-fin-doc.srok-pl tt-fin-doc.nazn-pl
          tt-fin-doc.ocher-pl tt-fin-doc.f22 tt-fin-doc.f23 tt-fin-doc.stat-pl
          tt-fin-doc.f104 tt-fin-doc.f105 tt-fin-doc.f106 tt-fin-doc.f107
          tt-fin-doc.f108 tt-fin-doc.f109 tt-fin-doc.f110
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help tt-fin-doc.ocher-pl tt-fin-doc.stat-pl
         tt-fin-doc.f104 tt-fin-doc.f105 tt-fin-doc.f106 tt-fin-doc.f107
         tt-fin-doc.f108 tt-fin-doc.f109 tt-fin-doc.f110
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
find first tt-fin-doc.
assign
tt-fin-doc.stat-pl:list-items in frame Dialog-Frame = "":U + chr(44) + '01,02,03,04,05,06,07,08':U
tt-fin-doc.f106:list-items in frame Dialog-Frame = 'ТП,ЗД,ТР,РС,ОТ,РТ,ВУ,ПР,АП,АР,0':U
tt-fin-doc.f110:list-items in frame Dialog-Frame = 'НС,АВ,ПЕ,ПЦ,СА,АШ,ИШ,0':U
tt-fin-doc.ocher-pl:list-items in frame Dialog-Frame = "1,2,3,4,5,6"
.
CASE tt-fin-doc.fin-doc-type:
  when 'ппп':U then do:
    IF AVAILABLE tt-fin-doc THEN
    DISPLAY
    tt-fin-doc.vid-opl
    tt-fin-doc.srok-pl
    tt-fin-doc.nazn-pl
    tt-fin-doc.ocher-pl
    tt-fin-doc.f22
    tt-fin-doc.f23
    WITH FRAME Dialog-Frame.
    if p-mode <> 'ПРОСМОТР':U then do:
      ENABLE
      B-exit
      B-Help
      tt-fin-doc.ocher-pl
      WITH FRAME Dialog-Frame.
    end.
    APPLY "VALUE-CHANGED" to tt-fin-doc.stat-pl.
  end.
  when 'рпп':U  then do:
    DISPLAY
    F-stat-pl
    WITH FRAME Dialog-Frame.
    IF AVAILABLE tt-fin-doc THEN
    DISPLAY
    tt-fin-doc.vid-opl
    tt-fin-doc.srok-pl
    tt-fin-doc.nazn-pl
    tt-fin-doc.ocher-pl
    tt-fin-doc.f22
    tt-fin-doc.f23
    tt-fin-doc.stat-pl
    tt-fin-doc.f104
    tt-fin-doc.f105
    tt-fin-doc.f106
    tt-fin-doc.f107
    tt-fin-doc.f108
    tt-fin-doc.f109
    tt-fin-doc.f110
    WITH FRAME Dialog-Frame.
    if p-mode <> 'ПРОСМОТР':U then do:
      ENABLE
      B-exit
      B-Help
      tt-fin-doc.ocher-pl
      tt-fin-doc.stat-pl
      tt-fin-doc.f104
      tt-fin-doc.f105
      tt-fin-doc.f106
      tt-fin-doc.f107
      tt-fin-doc.f108
      tt-fin-doc.f109
      tt-fin-doc.f110
      WITH FRAME Dialog-Frame.
    end.
    APPLY "VALUE-CHANGED" to tt-fin-doc.stat-pl.
  end.
END CASE.
ENABLE
B-quit
B-Help
WITH FRAME Dialog-Frame.
if p-mode = 'ПРОСМОТР':U then do:
  hide b-exit in frame Dialog-Frame.
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1
  .
end.
VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-save :
CASE tt-fin-doc.fin-doc-type:
  when 'ппп':U then do:
    assign
    tt-fin-doc.vid-opl frame Dialog-Frame
    tt-fin-doc.srok-pl
    tt-fin-doc.nazn-pl
    tt-fin-doc.ocher-pl
    tt-fin-doc.f22
    tt-fin-doc.f23
    .
  end.
  when 'рпп':U then do:
    assign
    tt-fin-doc.vid-opl frame Dialog-Frame
    tt-fin-doc.srok-pl
    tt-fin-doc.nazn-pl
    tt-fin-doc.ocher-pl
    tt-fin-doc.f22
    tt-fin-doc.f23
    tt-fin-doc.stat-pl
    tt-fin-doc.f104
    tt-fin-doc.f105
    tt-fin-doc.f106
    tt-fin-doc.f107
    tt-fin-doc.f108
    tt-fin-doc.f109
    tt-fin-doc.f110
    .
  end.
END CASE.
END PROCEDURE.
