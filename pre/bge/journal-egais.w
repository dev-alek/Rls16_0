using ibs.th.bge.egais.*.
define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Журнал запросов ЕГАИС".
define variable th-journal-egais     as handle  no-undo.
define variable bh-journal-egais     as handle  no-undo.
define variable gh-journal-egais     as handle  no-undo.
define variable browse-hdl-journal-egais as handle no-undo.
define variable bcol                  as handle no-undo.
define variable bcol1                 as handle no-undo.
define variable bcol2                 as handle no-undo.
define variable bcol3                 as handle no-undo.
define variable bcol4                 as handle no-undo.
define variable bcol5                 as handle no-undo.
define variable egais                as class EGAIS   no-undo.
define variable journal              as class Journal no-undo.
define variable v-db-num             as integer   no-undo .
define variable v-user-id            as character no-undo .
define variable glog                 as logical   no-undo .
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
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
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Выход"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON Btn_del
     LABEL "Удалить"
     tooltip "Удалить из журнала. Дает возможность отправить повторно запрос."
     SIZE 15 BY 1.13.
DEFINE VARIABLE RADIO-SET-1 AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 1,
"Новые", 2,
"Закрытые", 3
     SIZE 50 BY 1.25 NO-UNDO.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
DEFINE BROWSE BROWSE-Journal-egais
    WITH NO-ROW-MARKERS SEPARATORS SIZE 135 BY 25.
DEFINE FRAME Dialog-Frame
     Btn_Cancel AT ROW 1 COL 1
     Btn_del AT ROW 1 COL 16.63 WIDGET-ID 6
     RADIO-SET-1 AT ROW 1.04 COL 32.88 NO-LABEL WIDGET-ID 2
     BROWSE-Journal-egais AT ROW 3 COL 1 WIDGET-ID 200
     SPACE(0.50) SKIP(0.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Журнал запросов ЕГАИС"
         CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON VALUE-CHANGED OF RADIO-SET-1 IN FRAME Dialog-Frame
DO:
  assign RADIO-SET-1 .
   RUN enable_UI.
END.
ON choose OF Btn_del IN FRAME Dialog-Frame
DO:
  find first ub.esys-all-attr where (table-name + string (key1) + string (key2) + string (key3) + string (key4) + string (key5) + string (key6) +
        string (key7) + string (key8) + attr-code) = bh-journal-egais:buffer-field ('piIndex'):buffer-value () no-error.
  if available (ub.esys-all-attr)
    then delete ub.esys-all-attr.
  if bh-journal-egais:available
    then bh-journal-egais:buffer-delete ().
  BROWSE-Journal-egais:refresh ().
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
       def var ii as int no-undo.
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run getcurus in g#library2
  (output v-db-num
  ,output v-user-id
  ) no-error .
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_egais-adm':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
  if not glog then  return .
  egais = new EGAIS(v-db-num, v-user-id).
  journal = new Journal().
  egais:EGAISImpl = journal.
  bh-journal-egais = egais:GetHndlTable().
    create query gh-journal-egais.
    gh-journal-egais:SET-BUFFERS (bh-journal-egais ).
    gh-journal-egais:query-prepare ("for each tt_journal-egais").
    gh-journal-egais:QUERY-OPEN.
    BROWSE-Journal-egais:QUERY = gh-journal-egais.
  do ii = 1 to bh-journal-egais:num-fields - 1:
     bcol = browse-journal-egais:add-like-column('tt_journal-egais' + '.' + bh-journal-egais:buffer-field (ii):name, 0, 'FILL-IN').
  end.
          bcol1 = browse-journal-egais:get-browse-column(1).
          bcol2 = browse-journal-egais:get-browse-column(2).
          bcol3 = browse-journal-egais:get-browse-column(3).
          bcol4 = browse-journal-egais:get-browse-column(4).
          bcol5 = browse-journal-egais:get-browse-column(5).
on row-display of browse-journal-egais IN FRAME Dialog-Frame
DO:
    if bh-journal-egais:buffer-field ("jou-status"):buffer-value  = "Запрос отправлен" then do:
        bcol1:bgcolor = YELLOW_COLOR.
        bcol2:bgcolor = YELLOW_COLOR.
        bcol3:bgcolor = YELLOW_COLOR.
        bcol4:bgcolor = YELLOW_COLOR.
        bcol:bgcolor  = YELLOW_COLOR .
        bcol5:bgcolor = YELLOW_COLOR .
    end.
end.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY RADIO-SET-1
      WITH FRAME Dialog-Frame.
  ENABLE Btn_Cancel Btn_del RADIO-SET-1
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  ENABLE BROWSE-journal-egais
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
   case RADIO-SET-1 :
      when 1  then do:
            gh-journal-egais:SET-BUFFERS (bh-journal-egais).
            gh-journal-egais:query-prepare ("for each tt_journal-egais by tt_journal-egais.jou-time desc").
            gh-journal-egais:QUERY-OPEN.
      end.
      when 2  then do:
            gh-journal-egais:SET-BUFFERS (bh-journal-egais).
            gh-journal-egais:query-prepare ("for each tt_journal-egais where tt_journal-egais.jou-status = 'Запрос отправлен'  by tt_journal-egais.jou-time desc").
            gh-journal-egais:QUERY-OPEN.
      end.
      when 3 then do:
            gh-journal-egais:SET-BUFFERS (bh-journal-egais).
            gh-journal-egais:query-prepare ("for each tt_journal-egais where tt_journal-egais.jou-status = 'Ответ получен'  by tt_journal-egais.jou-time desc").
            gh-journal-egais:QUERY-OPEN.
      end.
    end.
END PROCEDURE.
