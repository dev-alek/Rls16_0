define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Отчет по покупателям товаров (выкуп)" .
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
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  stream PrnLibStream.
procedure prn-lib-prn-file :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-DIsabledoptions as integer no-undo .
  define variable v-report-name as character no-undo .
  define variable v-user-action as character no-undo .
  define variable v-printed     as logical   no-undo .
  define variable v-exist       as logical   no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run filenmln in g#library
  (input  v-report-name
  ,input  2
  ,output v-exist
  )  .
    if NOT v-exist then
    DO:
      Message
        "Нет заданий на печать ! "
        view-as alert-box .
      Return  .
    End.
    run gbl/prnfilen.w
      (input  ""
      ,input  p-DisabledOptions
      ,input  string(v-report-name )
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .
    if v-printed then
    do:
      return "YES" .
    end.
    else
    do:
      return "NO" .
    end.
  end.
end procedure.
procedure prn-lib-open-stream :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-page-size    as integer no-undo .
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-append       as logical no-undo .
  define variable v-report-name as character no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
    if p-is-stream then
    do:
      if p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
    if not p-is-stream then
    do:
      if p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
  end.
end procedure.
procedure prn-lib-open-exp :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-is-append    as logical no-undo .
  define output parameter p-ReportFileName as char init "report" no-undo.
  define output parameter p-process as logical no-undo .
  define variable glog as logical no-undo .
  do
    on error undo, return error
    :
    SYSTEM-DIALOG GET-FILE p-ReportFileName
      TITLE      "Укажите путь"
      FILTERS "Текстовый файл (*.txt)"   "*.txt"
      ASK-OVERWRITE
      CREATE-TEST-FILE
      SAVE-AS
      USE-FILENAME
      DEFAULT-EXTENSION "txt"
      UPDATE glog
      .
    if not glog then  return.
    p-ReportFileName = trim( string( p-ReportFileName ) ) .
    if p-is-stream then
    do:
      if p-is-append then
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    else
    do:
      if p-is-append then
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    p-process = yes.
  end.
end procedure.
procedure prn-lib-get-report-name :
  define input parameter parParentProc  as widget-handle no-undo.
  define output parameter p-report-name as character no-undo .
  p-report-name = ibs.th.gbl.gbl-inipar:prn-lib-get-report-name("rpt").
end procedure.
procedure prn-lib-reportviewer-report-name :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer-report-name(p-report-name-html) no-error.
end procedure.
procedure prn-lib-reportviewer :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  define input parameter p-param        as character no-undo .
  define variable v-excel           as character no-undo init 'TRUE' .
  define variable v-value-character as character no-undo .
  define variable v-value-integer   as character no-undo .
  define variable v-value-date      as date      no-undo .
  define variable v-value-decimal   as decimal   no-undo .
  define variable rep-excel         as logical   no-undo .
  define variable excel-string      as character no-undo .
  define variable v-param-type      as character no-undo .
  define variable v-tth             as handle    no-undo .
  run adm/shattri.p (
    input "get":U
    ,input  ""
    ,input  0
    ,input  'report-glob':U
    ,input  'rep-excel':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output rep-excel
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    )  .
  if rep-excel then v-excel = "TRUE" .
  else v-excel = "FALSE" .
  if p-param eq ""
  then
     p-param = "EXCEL:" + v-excel.
  else
     p-param = p-param + chr(4) + "EXCEL:" + v-excel .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer(p-report-name-html, p-param).
end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cli-grplib-get-full-name :
   define input parameter  p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_cli-grp       for ub.cli-grp.
    define buffer buf_upper_cli-grp for ub.cli-grp.
    find first buf_cli-grp no-lock
         where buf_cli-grp.node-code = p-node-code
    no-error.
    if not available buf_cli-grp
    then do:
        undo, return error "cli-grplib-get-full-name: Не найдена группа клиентов с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_cli-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_cli-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_cli-grp.upper-code
        .
        find first buf_cli-grp no-lock
             where buf_cli-grp.node-code = v-upper-code
        no-error.
        if not available buf_cli-grp
        then do:
            undo, return error "cli-grplib-get-full-name: Не найдена группа клиентов с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure cgrplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_cli-grp       for ub.cli-grp.
do
on error undo, return error
:
  find first buf_cli-grp no-lock
      where buf_cli-grp.upper-code = 0
  no-error .
  if not available buf_cli-grp
  then do:
      undo, return error substitute("Не найдена корневая группа клиентов (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_cli-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_cli-grp no-lock where
              buf_cli-grp.node-name = v-entry
          and buf_cli-grp.upper-code = v-upper-code
          no-error.
    if not available buf_cli-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_cli-grp.node-code.
      v-upper-code = buf_cli-grp.node-code.
    end.
  end.
end.
end .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable     buygrp_recids  as      char    no-undo.
define variable     LifeStartDate  as character    no-undo.
define variable     stat           as  logical     no-undo.
define variable     FineDate       as  logical     no-undo.
define variable     Sale-LogRes    as  log         no-undo.
define variable     Cost-LogRes    as  log         no-undo.
define variable     ii             as   integer no-undo.
define variable     EffValue       as  decimal        no-undo.
define variable     StartPoint     as   date    no-undo.
define variable     EndPoint       as   date    no-undo.
define variable is-name as logical   no-undo .
define variable str-find as character no-undo .
define buffer        cli-buy              for     clients .
DEFINE temp-table buy-data no-undo
field obj-type      like clients.obj-type
field obj-code      like clients.obj-code
field Name          as  char
field Sum-zak       as decimal
field Sum-prod      as decimal
field Sum-skid      as decimal
field EffValue      as decimal
index pi IS PRIMARY obj-type obj-code
index pi1  Name
index pi2  Sum-zak
index pi3  Sum-prod
index pi4  EffValue
.
DEFINE temp-table buy-data-dt no-undo
field obj-type      like clients.obj-type
field obj-code      like clients.obj-code
field cur-date1      as date
field cur-date2      as date
field Sum-zak       as decimal
field Sum-prod      as decimal
field Sum-skid      as decimal
field EffValue      as decimal
index pi IS PRIMARY obj-type obj-code cur-date1 cur-date2
.
DEFINE BUTTON B-Help
     LABEL "&Помощь":L
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_Print
     LABEL "&Ввод ":L
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE SelectBuyers AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "1", "1",
"2", "2"
     SIZE 12 BY 3 NO-UNDO.
DEFINE VARIABLE Sort_Type AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "По алфавиту", "По алфавиту",
"По возрастанию учетной суммы", "По возрастанию учетной суммы",
"По возрастанию суммы продаж", "По возрастанию суммы продаж",
"По возрастанию эффективности", "По возрастанию эффективности",
"По убыванию учетной суммы", "По убыванию учетной суммы",
"По убыванию суммы продаж", "По убыванию суммы продаж ",
"По убыванию эффективности", "По убыванию эффективности"
     SIZE 34.5 BY 10 NO-UNDO.
DEFINE VARIABLE WhatShow AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", "1",
"Только продажные", "Только продажные",
"Только учетные", "Только учетные"
     SIZE 19 BY 4 NO-UNDO.
DEFINE RECTANGLE RECT-14
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 20 BY 12.25.
DEFINE RECTANGLE RECT-18
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 57 BY 12.25.
DEFINE VARIABLE TimePeriod AS CHARACTER
     VIEW-AS SELECTION-LIST MULTIPLE SCROLLBAR-VERTICAL
     SIZE 15 BY 9.75
     BGCOLOR 15  NO-UNDO.
DEFINE FRAME DLGOKCAN
     Btn_Print AT ROW 1 COL 1
     Btn_OK AT ROW 1 COL 11
     B-Help AT ROW 1 COL 61
     TimePeriod AT ROW 4.5 COL 3.5 NO-LABEL
     SelectBuyers AT ROW 4.5 COL 25.5 NO-LABEL
     Sort_Type AT ROW 4.5 COL 42.5 NO-LABEL
     WhatShow AT ROW 10.5 COL 22.5 NO-LABEL
     "Показать данные :" VIEW-AS TEXT
          SIZE 18 BY .75 AT ROW 9.5 COL 22.5
          FGCOLOR 4
     "Период :" VIEW-AS TEXT
          SIZE 8.5 BY .75 AT ROW 3.25 COL 7
          FGCOLOR 4
     "Выбор покупателей :" VIEW-AS TEXT
          SIZE 19 BY .75 AT ROW 3.25 COL 22.5
          FGCOLOR 4
     "Сортировка :" VIEW-AS TEXT
          SIZE 12.5 BY .75 AT ROW 3.25 COL 51.5
          FGCOLOR 4
     RECT-14 AT ROW 2.75 COL 1
     RECT-18 AT ROW 2.75 COL 21
     SPACE(0.87) SKIP(0.49)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS THREE-D  SCROLLABLE
         BGCOLOR 8 FGCOLOR 0
         TITLE BGCOLOR 8 FGCOLOR 0 "Отчет по покупателям":L.
ASSIGN
       FRAME DLGOKCAN:SCROLLABLE       = FALSE
       FRAME DLGOKCAN:PRIVATE-DATA     =
                "DLGCLOSE".
ON CHOOSE OF B-Help IN FRAME DLGOKCAN
OR HELP OF FRAME DLGOKCAN
DO:
  MESSAGE  VIEW-AS ALERT-BOX INFORMATION.
END.
ON CHOOSE OF Btn_OK IN FRAME DLGOKCAN
DO:
    return "NO" .
END.
ON CHOOSE OF Btn_Print IN FRAME DLGOKCAN
DO:
  if FineDate then do:
    if session:set-wait-state("COMPILER") then.
    run prn-lib-open-stream  in this-procedure (
                                                input parParentProc
                                                ,input 62
                                                ,input yes
                                                ,input no
                                                ).
    PUT stream PrnLibStream SPACE(20) string ( "Продажи " + " c  " + string ( StartPoint ) + "  по  " + string ( EndPoint ) +
            ( if buygrp_recids <> ? AND buygrp_recids <> "" then "  по группам организаций ( регионам )" else "  по организациям" ) + "." ) format "x(100)" SKIP(1).
    PUT stream PrnLibStream SPACE(20) string( "Сортировка : " + lc( Sort_Type:screen-value ) + "." ) format "x(100)" SKIP.
    RUN main_proc .
    PUT stream PrnLibStream " " SKIP.
    output stream PrnLibStream CLOSE.
    FOR EACH buy-data :     delete buy-data.     END.
    FOR EACH buy-data-dt :  delete buy-data-dt.  END.
    run prn-lib-prn-file in this-procedure (
                                              input parParentProc
                                              ,input 0
                                              ).
    if session:set-wait-state("") then.
    APPLY "ENTRY" TO Btn_OK .
  end.
  else message "Вы забыли указать требуемый период времени." view-as alert-box ERROR.
END.
ON VALUE-CHANGED OF SelectBuyers IN FRAME DLGOKCAN
DO:
  assign SelectBuyers .
  if SelectBuyers = 'группа':U then do:
    run ref/cli-grps.w ( input parparentproc
                        ,input "b-sel"
                        ,input-output buygrp_recids ) .
    if buygrp_recids = "" then  do:
      assign SelectBuyers = 'все':U .
      DISPLAY SelectBuyers with FRAME DLGOKCAN .
    end.
  end.
  if SelectBuyers = 'все':U then buygrp_recids = "" .
END.
ON VALUE-CHANGED OF TimePeriod IN FRAME DLGOKCAN
DO:
  def var StrBuf              as char         no-undo.
  def var PrevMonth       as  integer     no-undo.
  def var CurrMonth       as  integer     no-undo.
  def var EndLastDay  as  integer     no-undo.
  def var ii                  as  integer     no-undo.
    StrBuf  = TimePeriod:screen-value .
    if num-entries ( StrBuf ) = 1 then
        FineDate = TRUE .
    else
        CheckStrBuf:
            DO ii = 2 to num-entries ( StrBuf ) :
                assign
                    PrevMonth = integer ( substring ( entry ( ii - 1, StrBuf ), 1, 2 ) )
                    CurrMonth = integer ( substring ( entry ( ii, StrBuf ), 1, 2 ) ) .
                if PrevMonth = 12 then
                    do:
                        if ( CurrMonth = 1 ) AND
                           ( integer ( trim ( substring ( entry ( ii - 1, StrBuf ), 3 ) ) ) =
                             ( integer ( trim ( substring ( entry ( ii, StrBuf ), 3 ) ) ) - 1 ) ) then
                            FineDate = TRUE .
                        else
                            do:
                                FineDate = FALSE .
                                LEAVE CheckStrBuf.
                            end.
                    end.
                else
                    do:
                        if PrevMonth = ( CurrMonth - 1 ) then
                            FineDate = TRUE .
                        else
                            do:
                                FineDate = FALSE .
                                LEAVE CheckStrBuf.
                            end.
                    end.
            END.
    if FineDate then
        do:
            assign
                StartPoint = date ( integer ( substring ( entry ( 1, StrBuf ), 1, 2) ),
                                              integer ( "01" ) ,
                                              integer ( trim ( substring ( entry ( 1, StrBuf ), 3 ) ) ) )
                EndPoint = date ( integer ( substring ( entry ( num-entries ( StrBuf ), StrBuf ), 1, 2) ),
                               integer ( "01" ) ,
                               integer ( trim ( substring ( entry ( num-entries ( StrBuf ), StrBuf ), 3 ) ) ) ) .
            run gbl/lastday.p ( input EndPoint, output EndLastDay ) .
            EndPoint = date ( integer ( substring ( entry ( num-entries ( StrBuf ), StrBuf ), 1, 2) ),
                               EndLastDay,
                               integer ( trim ( substring ( entry ( num-entries ( StrBuf ), StrBuf ), 3 ) ) ) ) .
        end.
    else
        do:
            message "Вы ошиблись : укажите НЕПРЕРЫВНЫЙ период времени."
                view-as alert-box ERROR.
            stat = TimePeriod:scroll-to-item( TimePeriod:num-items ) .
            TimePeriod:screen-value = "".
        end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME DLGOKCAN:PARENT eq ?
THEN FRAME DLGOKCAN:PARENT = ACTIVE-WINDOW.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame DLGOKCAN
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
on choose of b-help in frame DLGOKCAN
do:
  apply "help":u to frame DLGOKCAN .
end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame DLGOKCAN:width - 0.3
                fh            = frame DLGOKCAN:first-child
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
ON WINDOW-CLOSE OF FRAME DLGOKCAN APPLY "END-ERROR":U TO SELF.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
        ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  assign
  SelectBuyers:radio-buttons =  'все':U + chr(44) + 'все':U + chr(44) +
                                'группа':U + chr(44) + 'группа':U
  WhatShow:radio-buttons =      'все':U + chr(44) + 'все':U + chr(44) +
                                "Только продажные" + chr(44) + "Только продажные" + chr(44) +
                                "Только учетные"  + chr(44) +  "Только учетные"
  .
  RUN enable_UI.
  RUN StartProc .
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_document-reports-sale_print':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output Sale-LogRes
    )  .
end.
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_document-reports-cost_print':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output Cost-LogRes
    )  .
end.
  if NOT ( Sale-LogRes OR Cost-LogRes ) then do:
    message "У Вас недостаточно прав для" skip "выполнения данного действия:" skip
            "Обратитесь к администратору" skip "системы." view-as alert-box error.
    LEAVE MAIN-BLOCK .
  end.
  if NOT Cost-LogRes then do:
    stat = Sort_Type:disable( "По возрастанию учетной суммы" ) .
    stat = Sort_Type:disable( "По возрастанию эффективности" ) .
    stat = Sort_Type:disable( "По убыванию учетной суммы" ) .
    stat = Sort_Type:disable( "По убыванию эффективности" ) .
    stat = WhatShow:disable( "Только учетные" ) .
    stat = WhatShow:disable( "Все" ) .
  end.
  if NOT Sale-LogRes then do:
    stat = Sort_Type:disable( "По возрастанию суммы продаж" ) .
    stat = Sort_Type:disable( "По возрастанию эффективности" ) .
    stat = Sort_Type:disable( "По возрастанию поступления денег" ) .
    stat = Sort_Type:disable( "По убыванию суммы продаж" ) .
    stat = Sort_Type:disable( "По убыванию эффективности" ) .
    stat = Sort_Type:disable( "По убыванию поступления денег" ) .
    stat = WhatShow:disable( "Только продажные" ) .
    stat = WhatShow:disable( "Все" ) .
  end.
  WAIT-FOR GO OF FRAME DLGOKCAN.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME DLGOKCAN.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY TimePeriod SelectBuyers Sort_Type WhatShow
      WITH FRAME DLGOKCAN.
  ENABLE Btn_Print Btn_OK B-Help RECT-14 RECT-18 TimePeriod SelectBuyers
         Sort_Type WhatShow
      WITH FRAME DLGOKCAN.
END PROCEDURE.
PROCEDURE main_proc :
define variable grp-path like clients.grp-name no-undo.
define variable Line                as      char     no-undo.
define variable CliRegName   as      char    no-undo.
define variable CliRegCode   as      char    no-undo.
define variable DebBasePcnt  as      char     no-undo.
define variable TOT-DebBaseSum      as  decimal     no-undo.
define variable sym1 as char init ":"   no-undo.
define variable sym2 as char init ":"   no-undo.
define variable sym3 as char init ":"   no-undo.
define variable sym4 as char init ":"   no-undo.
define variable sym5 as char init ":"   no-undo.
define variable sym6 as char init ":"   no-undo.
define variable sym7 as char init ":"   no-undo.
define variable sym8 as char init ":"   no-undo.
define variable sym9 as char init ":"   no-undo.
define variable sym10 as char init ":"   no-undo.
define variable m-y as char init ":"   no-undo.
define variable OneMonth as log no-undo .
define variable v-rb-is-base            as logical      no-undo.
define buffer buf_trn-doc for trn-doc .
define variable sum-zak  as decimal   no-undo .
define variable sum-prod as decimal   no-undo .
define variable sum-skid as decimal   no-undo .
define variable Counter1 as integer   no-undo .
define variable v-account as integer init 0 no-undo .
define variable v-account-lavel as character no-undo .
define variable v-button-stop as logical no-undo .
define variable v-kol-spice as integer no-undo .
define variable v-kol-spice2 as integer no-undo .
define variable v-kol-spice3 as integer no-undo .
DEFINE VARIABLE StopProcessing AS LOGICAL NO-UNDO.
DEFINE BUTTON StopBtn AUTO-END-KEY
     LABEL "Стоп"
     SIZE 10 BY 1.
DEFINE VARIABLE RecordsDone AS INTEGER FORMAT ">,>>>,>>>,>>9":U INITIAL 0
     LABEL "Обработано записей"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.
DEFINE VARIABLE RecordsString AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE RecordsString2 AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE RecordsString3 AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 55.13 BY 4.46.
DEFINE FRAME InfoFrame
     StopBtn AT ROW 4.25 COL 21.75
     RecordsString AT ROW 1.21 COL 2 NO-LABEL
     RecordsString2 AT ROW 1.96 COL 2 NO-LABEL
     RecordsString3 AT ROW 2.58 COL 2 NO-LABEL
     RecordsDone AT ROW 3.42 COL 24.88 COLON-ALIGNED
     RECT-1 AT ROW 1 COL 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Процесс"
         DEFAULT-BUTTON StopBtn CANCEL-BUTTON StopBtn.
define variable mFrameView      as logical   no-undo init yes.
  define variable mFramHandle as handle no-undo.
  mFramHandle = frame InfoFrame:handle.
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramHandle:visible), "frameRepError").
  end.
  mFrameView = not session:batch-mode and mFramHandle:visible.
  if mFrameView
  then do:
    ASSIGN
       FRAME InfoFrame:HIDDEN                           = TRUE
       StopBtn:sensitive IN FRAME InfoFrame             = TRUE.
  end.
ON CHOOSE OF StopBtn IN FRAME InfoFrame
DO:
  IF not StopProcessing THEN
    Message "Вы действительно хотите прервать" SKIP
            "процесс проверки?" view-as alert-box QUESTION BUTTONS yes-no
              UPDATE StopProcessing.
  IF StopProcessing THEN do:
     if mFrameView
     then do:
        HIDE FRAME InfoFrame.
     end.
  End.
END.
assign v-account = ( if integer( 10 ) = 0 then 100 else integer( 10 ) ).
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("ON mFrameView=" + string(mFrameView), "frameRepError").
  end.
  if not session:batch-mode then
  do:
    VIEW FRAME InfoFrame.
    mFrameView = true.
  end.
   v-button-stop = false .
      if mFrameView
      then do:
      if v-button-stop then view STOPBTN in frame InfoFrame.
                       else Hide STOPBTN in frame InfoFrame.
      end.
  define variable all-Sum-zak  as decimal initial 0  no-undo .
  define variable all-Sum-prod as decimal initial 0  no-undo .
  define variable all-Sum-skid as decimal initial 0  no-undo .
  define variable all-EffValue as decimal initial 0  no-undo .
    define variable mon  as integer   no-undo .
    define variable yer  as integer   no-undo .
    define variable dte  as date      no-undo .
  DEFINE FRAME Firm-SaleRpt
    sym1       column-label ":!:!:"            format "x(1)" space(0)
    CliRegCode column-label "Код! ! "          format "x(6)" space(0)
    sym2       column-label ":!:!:"            format "x(1)"
    CliRegName column-label "Наименование! ! " format "x(40)"
    sym3       column-label ":!:!:"            format "x(1)"
    m-y        column-label "Месяц!/ Год! "    format "x(7)"
    sym4       column-label ":!:!:"            format "x(1)"
    sum-zak    column-label "Сумма продаж!в учетных!ценах"    format "->>>>>>>>>9.99"
    sum-prod   column-label "Сумма продаж!в ценах!реализации" format "->>>>>>>>>>9.99"
    sym5       column-label ":!:!:" format "x(1)"
    sum-skid   column-label "Сумма скидок! ! " format "->>>>>>>9.99"
    sym6       column-label ":!:!:" format "x(1)"
    EffValue   column-label "Эффективность! ! "  format "->>>>>>>>9.99"
    sym7       column-label ":!:!:" format "x(1)"
    HEADER
        string("Дата печати : ") AT 5 format "x(15)" TODAY format "99.99.9999" string(", ") format "X(2)"
        string(TIME, "HH:MM")
        space(5) ( if v-rb-is-base = yes then "Суммы в базовой валюте" else "Суммы в рублях" ) format "X(22)"
        string( "Страница " + string (PAGE-NUMBER( PrnLibStream ) , ">>9") ) AT 114 format "X(15)" SKIP
        Line format "x(125)" AT 1
  with width 235 down stream-io use-text .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-rb-is-base
  )  .
  TOT-DebBaseSum = 0 .
  if ( year( StartPoint ) = year( EndPoint ) ) AND ( month( StartPoint ) = month( EndPoint ) ) then OneMonth = TRUE .
  else  OneMonth = FALSE .
  if SelectBuyers:screen-value in FRAME DLGOKCAN = 'все':U then do:
    for each cli-buy where cli-buy.obj-type = 'орг':U no-lock :
define variable vss-include-info11 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  for each buf_trn-doc no-lock
    where buf_trn-doc.host-code = p-curr-host-code
      and buf_trn-doc.cli-type  = cli-buy.obj-type
      and buf_trn-doc.cli-code  = cli-buy.obj-code
      and buf_trn-doc.fact-date >= StartPoint
      and buf_trn-doc.fact-date <= EndPoint
    :
    if    buf_trn-doc.ext-doc-type <> 'ee':U
      and buf_trn-doc.ext-doc-type <> 'es':U
      and buf_trn-doc.ext-doc-type <> 're':U
      and buf_trn-doc.ext-doc-type <> 'rs':U then next .
    if    buf_trn-doc.status_ <> 'факт':U then next .
    assign Counter1 = Counter1 + 1.
IF ( Counter1 modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              Counter1 @ RecordsDone
              WITH FRAME InfoFrame.
           end.
End.
   if v-button-stop then  DO:
         if mFrameView
         then
            PROCESS EVENTS.
         IF StopProcessing THEN DO:
         RETURN error.
         End.
   end.
    find first buy-data
      where buy-data.obj-type  = cli-buy.obj-type
        and buy-data.obj-code  = cli-buy.obj-code
      no-error .
    if not available buy-data then do:
      create buy-data .
      assign
        buy-data.obj-type = cli-buy.obj-type
        buy-data.obj-code = cli-buy.obj-code
        buy-data.Name     = cli-buy.obj-name
        buy-data.Sum-zak  = 0
        buy-data.Sum-prod = 0
        buy-data.Sum-skid = 0
        buy-data.EffValue = 0
      .
    end.
    find first buy-data-dt
      where buy-data-dt.obj-type  = cli-buy.obj-type
        and buy-data-dt.obj-code  = cli-buy.obj-code
        and buy-data-dt.cur-date1 <= buf_trn-doc.fact-date
        and buy-data-dt.cur-date2  > buf_trn-doc.fact-date
      no-error .
    if not available buy-data-dt then do:
      create buy-data-dt .
      assign
        buy-data-dt.obj-type = cli-buy.obj-type
        buy-data-dt.obj-code = cli-buy.obj-code
        buy-data-dt.Sum-zak  = 0
        buy-data-dt.Sum-prod = 0
        buy-data-dt.Sum-skid = 0
        buy-data-dt.EffValue = 0
        mon = month( buf_trn-doc.fact-date )
        yer = year ( buf_trn-doc.fact-date )
        buy-data-dt.cur-date1 = date(mon,1,yer)
      .
      if mon < 12 then assign buy-data-dt.cur-date2 = date(mon + 1,1,yer) .
      else             assign buy-data-dt.cur-date2 = date(1,1,yer + 1) .
    end.
    if buf_trn-doc.ext-doc-type = 're':U or
       buf_trn-doc.ext-doc-type = 'rs':U then do:
      if v-rb-is-base = yes then
        assign
          buy-data-dt.Sum-zak  = buy-data-dt.Sum-zak  - buf_trn-doc.fact-base
          buy-data-dt.Sum-skid = buy-data-dt.Sum-skid - buf_trn-doc.tot-calc
          buy-data-dt.Sum-prod = buy-data-dt.Sum-prod - buf_trn-doc.tot-doc + buf_trn-doc.tot-calc
          buy-data.Sum-zak     = buy-data.Sum-zak     - buf_trn-doc.fact-base
          buy-data.Sum-skid    = buy-data.Sum-skid    - buf_trn-doc.tot-calc
          buy-data.Sum-prod    = buy-data.Sum-prod    - buf_trn-doc.tot-doc
        .
      else
        assign
          buy-data-dt.Sum-zak  = buy-data-dt.Sum-zak  - buf_trn-doc.fact-rubl
          buy-data-dt.Sum-skid = buy-data-dt.Sum-skid - buf_trn-doc.discnt-rubl
          buy-data-dt.Sum-prod = buy-data-dt.Sum-prod - buf_trn-doc.tot-rubl + buf_trn-doc.discnt-rubl
          buy-data.Sum-zak     = buy-data.Sum-zak     - buf_trn-doc.fact-rubl
          buy-data.Sum-skid    = buy-data.Sum-skid    - buf_trn-doc.discnt-rubl
          buy-data.Sum-prod    = buy-data.Sum-prod    - buf_trn-doc.tot-rubl
        .
    end.
    else do:
      if v-rb-is-base = yes then
        assign
          buy-data-dt.Sum-zak  = buy-data-dt.Sum-zak  + buf_trn-doc.fact-base
          buy-data-dt.Sum-skid = buy-data-dt.Sum-skid + buf_trn-doc.tot-calc
          buy-data-dt.Sum-prod = buy-data-dt.Sum-prod + buf_trn-doc.tot-doc - buf_trn-doc.tot-calc
          buy-data.Sum-zak     = buy-data.Sum-zak     + buf_trn-doc.fact-base
          buy-data.Sum-skid    = buy-data.Sum-skid    + buf_trn-doc.tot-calc
          buy-data.Sum-prod    = buy-data.Sum-prod    + buf_trn-doc.tot-doc
        .
      else
        assign
          buy-data-dt.Sum-zak  = buy-data-dt.Sum-zak  + buf_trn-doc.fact-rubl
          buy-data-dt.Sum-skid = buy-data-dt.Sum-skid + buf_trn-doc.discnt-rubl
          buy-data-dt.Sum-prod = buy-data-dt.Sum-prod + buf_trn-doc.tot-rubl - buf_trn-doc.discnt-rubl
          buy-data.Sum-zak     = buy-data.Sum-zak     + buf_trn-doc.fact-rubl
          buy-data.Sum-skid    = buy-data.Sum-skid    + buf_trn-doc.discnt-rubl
          buy-data.Sum-prod    = buy-data.Sum-prod    + buf_trn-doc.tot-rubl
        .
    end.
  end.
    end.
    for each cli-buy where cli-buy.obj-type = 'чел':U no-lock :
define variable vss-include-info12 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  for each buf_trn-doc no-lock
    where buf_trn-doc.host-code = p-curr-host-code
      and buf_trn-doc.cli-type  = cli-buy.obj-type
      and buf_trn-doc.cli-code  = cli-buy.obj-code
      and buf_trn-doc.fact-date >= StartPoint
      and buf_trn-doc.fact-date <= EndPoint
    :
    if    buf_trn-doc.ext-doc-type <> 'ee':U
      and buf_trn-doc.ext-doc-type <> 'es':U
      and buf_trn-doc.ext-doc-type <> 're':U
      and buf_trn-doc.ext-doc-type <> 'rs':U then next .
    if    buf_trn-doc.status_ <> 'факт':U then next .
    assign Counter1 = Counter1 + 1.
IF ( Counter1 modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              Counter1 @ RecordsDone
              WITH FRAME InfoFrame.
           end.
End.
   if v-button-stop then  DO:
         if mFrameView
         then
            PROCESS EVENTS.
         IF StopProcessing THEN DO:
         RETURN error.
         End.
   end.
    find first buy-data
      where buy-data.obj-type  = cli-buy.obj-type
        and buy-data.obj-code  = cli-buy.obj-code
      no-error .
    if not available buy-data then do:
      create buy-data .
      assign
        buy-data.obj-type = cli-buy.obj-type
        buy-data.obj-code = cli-buy.obj-code
        buy-data.Name     = cli-buy.obj-name
        buy-data.Sum-zak  = 0
        buy-data.Sum-prod = 0
        buy-data.Sum-skid = 0
        buy-data.EffValue = 0
      .
    end.
    find first buy-data-dt
      where buy-data-dt.obj-type  = cli-buy.obj-type
        and buy-data-dt.obj-code  = cli-buy.obj-code
        and buy-data-dt.cur-date1 <= buf_trn-doc.fact-date
        and buy-data-dt.cur-date2  > buf_trn-doc.fact-date
      no-error .
    if not available buy-data-dt then do:
      create buy-data-dt .
      assign
        buy-data-dt.obj-type = cli-buy.obj-type
        buy-data-dt.obj-code = cli-buy.obj-code
        buy-data-dt.Sum-zak  = 0
        buy-data-dt.Sum-prod = 0
        buy-data-dt.Sum-skid = 0
        buy-data-dt.EffValue = 0
        mon = month( buf_trn-doc.fact-date )
        yer = year ( buf_trn-doc.fact-date )
        buy-data-dt.cur-date1 = date(mon,1,yer)
      .
      if mon < 12 then assign buy-data-dt.cur-date2 = date(mon + 1,1,yer) .
      else             assign buy-data-dt.cur-date2 = date(1,1,yer + 1) .
    end.
    if buf_trn-doc.ext-doc-type = 're':U or
       buf_trn-doc.ext-doc-type = 'rs':U then do:
      if v-rb-is-base = yes then
        assign
          buy-data-dt.Sum-zak  = buy-data-dt.Sum-zak  - buf_trn-doc.fact-base
          buy-data-dt.Sum-skid = buy-data-dt.Sum-skid - buf_trn-doc.tot-calc
          buy-data-dt.Sum-prod = buy-data-dt.Sum-prod - buf_trn-doc.tot-doc + buf_trn-doc.tot-calc
          buy-data.Sum-zak     = buy-data.Sum-zak     - buf_trn-doc.fact-base
          buy-data.Sum-skid    = buy-data.Sum-skid    - buf_trn-doc.tot-calc
          buy-data.Sum-prod    = buy-data.Sum-prod    - buf_trn-doc.tot-doc
        .
      else
        assign
          buy-data-dt.Sum-zak  = buy-data-dt.Sum-zak  - buf_trn-doc.fact-rubl
          buy-data-dt.Sum-skid = buy-data-dt.Sum-skid - buf_trn-doc.discnt-rubl
          buy-data-dt.Sum-prod = buy-data-dt.Sum-prod - buf_trn-doc.tot-rubl + buf_trn-doc.discnt-rubl
          buy-data.Sum-zak     = buy-data.Sum-zak     - buf_trn-doc.fact-rubl
          buy-data.Sum-skid    = buy-data.Sum-skid    - buf_trn-doc.discnt-rubl
          buy-data.Sum-prod    = buy-data.Sum-prod    - buf_trn-doc.tot-rubl
        .
    end.
    else do:
      if v-rb-is-base = yes then
        assign
          buy-data-dt.Sum-zak  = buy-data-dt.Sum-zak  + buf_trn-doc.fact-base
          buy-data-dt.Sum-skid = buy-data-dt.Sum-skid + buf_trn-doc.tot-calc
          buy-data-dt.Sum-prod = buy-data-dt.Sum-prod + buf_trn-doc.tot-doc - buf_trn-doc.tot-calc
          buy-data.Sum-zak     = buy-data.Sum-zak     + buf_trn-doc.fact-base
          buy-data.Sum-skid    = buy-data.Sum-skid    + buf_trn-doc.tot-calc
          buy-data.Sum-prod    = buy-data.Sum-prod    + buf_trn-doc.tot-doc
        .
      else
        assign
          buy-data-dt.Sum-zak  = buy-data-dt.Sum-zak  + buf_trn-doc.fact-rubl
          buy-data-dt.Sum-skid = buy-data-dt.Sum-skid + buf_trn-doc.discnt-rubl
          buy-data-dt.Sum-prod = buy-data-dt.Sum-prod + buf_trn-doc.tot-rubl - buf_trn-doc.discnt-rubl
          buy-data.Sum-zak     = buy-data.Sum-zak     + buf_trn-doc.fact-rubl
          buy-data.Sum-skid    = buy-data.Sum-skid    + buf_trn-doc.discnt-rubl
          buy-data.Sum-prod    = buy-data.Sum-prod    + buf_trn-doc.tot-rubl
        .
    end.
  end.
    end.
  end.
  else do:
    if buygrp_recids <> "" then do:
      find first cli-grp NO-LOCK WHERE recid( cli-grp ) = integer( buygrp_recids ) .
      RUN cli-grplib-get-full-name in this-procedure( cli-grp.node-code, output grp-path ).
      for each cli-buy no-lock
        where cli-buy.obj-type = 'орг':U
          and cli-buy.grp-name begins grp-path
        :
define variable vss-include-info13 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  for each buf_trn-doc no-lock
    where buf_trn-doc.host-code = p-curr-host-code
      and buf_trn-doc.cli-type  = cli-buy.obj-type
      and buf_trn-doc.cli-code  = cli-buy.obj-code
      and buf_trn-doc.fact-date >= StartPoint
      and buf_trn-doc.fact-date <= EndPoint
    :
    if    buf_trn-doc.ext-doc-type <> 'ee':U
      and buf_trn-doc.ext-doc-type <> 'es':U
      and buf_trn-doc.ext-doc-type <> 're':U
      and buf_trn-doc.ext-doc-type <> 'rs':U then next .
    if    buf_trn-doc.status_ <> 'факт':U then next .
    assign Counter1 = Counter1 + 1.
IF ( Counter1 modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              Counter1 @ RecordsDone
              WITH FRAME InfoFrame.
           end.
End.
   if v-button-stop then  DO:
         if mFrameView
         then
            PROCESS EVENTS.
         IF StopProcessing THEN DO:
         RETURN error.
         End.
   end.
    find first buy-data
      where buy-data.obj-type  = cli-buy.obj-type
        and buy-data.obj-code  = cli-buy.obj-code
      no-error .
    if not available buy-data then do:
      create buy-data .
      assign
        buy-data.obj-type = cli-buy.obj-type
        buy-data.obj-code = cli-buy.obj-code
        buy-data.Name     = cli-buy.obj-name
        buy-data.Sum-zak  = 0
        buy-data.Sum-prod = 0
        buy-data.Sum-skid = 0
        buy-data.EffValue = 0
      .
    end.
    find first buy-data-dt
      where buy-data-dt.obj-type  = cli-buy.obj-type
        and buy-data-dt.obj-code  = cli-buy.obj-code
        and buy-data-dt.cur-date1 <= buf_trn-doc.fact-date
        and buy-data-dt.cur-date2  > buf_trn-doc.fact-date
      no-error .
    if not available buy-data-dt then do:
      create buy-data-dt .
      assign
        buy-data-dt.obj-type = cli-buy.obj-type
        buy-data-dt.obj-code = cli-buy.obj-code
        buy-data-dt.Sum-zak  = 0
        buy-data-dt.Sum-prod = 0
        buy-data-dt.Sum-skid = 0
        buy-data-dt.EffValue = 0
        mon = month( buf_trn-doc.fact-date )
        yer = year ( buf_trn-doc.fact-date )
        buy-data-dt.cur-date1 = date(mon,1,yer)
      .
      if mon < 12 then assign buy-data-dt.cur-date2 = date(mon + 1,1,yer) .
      else             assign buy-data-dt.cur-date2 = date(1,1,yer + 1) .
    end.
    if buf_trn-doc.ext-doc-type = 're':U or
       buf_trn-doc.ext-doc-type = 'rs':U then do:
      if v-rb-is-base = yes then
        assign
          buy-data-dt.Sum-zak  = buy-data-dt.Sum-zak  - buf_trn-doc.fact-base
          buy-data-dt.Sum-skid = buy-data-dt.Sum-skid - buf_trn-doc.tot-calc
          buy-data-dt.Sum-prod = buy-data-dt.Sum-prod - buf_trn-doc.tot-doc + buf_trn-doc.tot-calc
          buy-data.Sum-zak     = buy-data.Sum-zak     - buf_trn-doc.fact-base
          buy-data.Sum-skid    = buy-data.Sum-skid    - buf_trn-doc.tot-calc
          buy-data.Sum-prod    = buy-data.Sum-prod    - buf_trn-doc.tot-doc
        .
      else
        assign
          buy-data-dt.Sum-zak  = buy-data-dt.Sum-zak  - buf_trn-doc.fact-rubl
          buy-data-dt.Sum-skid = buy-data-dt.Sum-skid - buf_trn-doc.discnt-rubl
          buy-data-dt.Sum-prod = buy-data-dt.Sum-prod - buf_trn-doc.tot-rubl + buf_trn-doc.discnt-rubl
          buy-data.Sum-zak     = buy-data.Sum-zak     - buf_trn-doc.fact-rubl
          buy-data.Sum-skid    = buy-data.Sum-skid    - buf_trn-doc.discnt-rubl
          buy-data.Sum-prod    = buy-data.Sum-prod    - buf_trn-doc.tot-rubl
        .
    end.
    else do:
      if v-rb-is-base = yes then
        assign
          buy-data-dt.Sum-zak  = buy-data-dt.Sum-zak  + buf_trn-doc.fact-base
          buy-data-dt.Sum-skid = buy-data-dt.Sum-skid + buf_trn-doc.tot-calc
          buy-data-dt.Sum-prod = buy-data-dt.Sum-prod + buf_trn-doc.tot-doc - buf_trn-doc.tot-calc
          buy-data.Sum-zak     = buy-data.Sum-zak     + buf_trn-doc.fact-base
          buy-data.Sum-skid    = buy-data.Sum-skid    + buf_trn-doc.tot-calc
          buy-data.Sum-prod    = buy-data.Sum-prod    + buf_trn-doc.tot-doc
        .
      else
        assign
          buy-data-dt.Sum-zak  = buy-data-dt.Sum-zak  + buf_trn-doc.fact-rubl
          buy-data-dt.Sum-skid = buy-data-dt.Sum-skid + buf_trn-doc.discnt-rubl
          buy-data-dt.Sum-prod = buy-data-dt.Sum-prod + buf_trn-doc.tot-rubl - buf_trn-doc.discnt-rubl
          buy-data.Sum-zak     = buy-data.Sum-zak     + buf_trn-doc.fact-rubl
          buy-data.Sum-skid    = buy-data.Sum-skid    + buf_trn-doc.discnt-rubl
          buy-data.Sum-prod    = buy-data.Sum-prod    + buf_trn-doc.tot-rubl
        .
    end.
  end.
      end.
      for each cli-buy no-lock
        where cli-buy.obj-type = 'чел':U
          and cli-buy.grp-name begins grp-path
        :
define variable vss-include-info14 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  for each buf_trn-doc no-lock
    where buf_trn-doc.host-code = p-curr-host-code
      and buf_trn-doc.cli-type  = cli-buy.obj-type
      and buf_trn-doc.cli-code  = cli-buy.obj-code
      and buf_trn-doc.fact-date >= StartPoint
      and buf_trn-doc.fact-date <= EndPoint
    :
    if    buf_trn-doc.ext-doc-type <> 'ee':U
      and buf_trn-doc.ext-doc-type <> 'es':U
      and buf_trn-doc.ext-doc-type <> 're':U
      and buf_trn-doc.ext-doc-type <> 'rs':U then next .
    if    buf_trn-doc.status_ <> 'факт':U then next .
    assign Counter1 = Counter1 + 1.
IF ( Counter1 modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              Counter1 @ RecordsDone
              WITH FRAME InfoFrame.
           end.
End.
   if v-button-stop then  DO:
         if mFrameView
         then
            PROCESS EVENTS.
         IF StopProcessing THEN DO:
         RETURN error.
         End.
   end.
    find first buy-data
      where buy-data.obj-type  = cli-buy.obj-type
        and buy-data.obj-code  = cli-buy.obj-code
      no-error .
    if not available buy-data then do:
      create buy-data .
      assign
        buy-data.obj-type = cli-buy.obj-type
        buy-data.obj-code = cli-buy.obj-code
        buy-data.Name     = cli-buy.obj-name
        buy-data.Sum-zak  = 0
        buy-data.Sum-prod = 0
        buy-data.Sum-skid = 0
        buy-data.EffValue = 0
      .
    end.
    find first buy-data-dt
      where buy-data-dt.obj-type  = cli-buy.obj-type
        and buy-data-dt.obj-code  = cli-buy.obj-code
        and buy-data-dt.cur-date1 <= buf_trn-doc.fact-date
        and buy-data-dt.cur-date2  > buf_trn-doc.fact-date
      no-error .
    if not available buy-data-dt then do:
      create buy-data-dt .
      assign
        buy-data-dt.obj-type = cli-buy.obj-type
        buy-data-dt.obj-code = cli-buy.obj-code
        buy-data-dt.Sum-zak  = 0
        buy-data-dt.Sum-prod = 0
        buy-data-dt.Sum-skid = 0
        buy-data-dt.EffValue = 0
        mon = month( buf_trn-doc.fact-date )
        yer = year ( buf_trn-doc.fact-date )
        buy-data-dt.cur-date1 = date(mon,1,yer)
      .
      if mon < 12 then assign buy-data-dt.cur-date2 = date(mon + 1,1,yer) .
      else             assign buy-data-dt.cur-date2 = date(1,1,yer + 1) .
    end.
    if buf_trn-doc.ext-doc-type = 're':U or
       buf_trn-doc.ext-doc-type = 'rs':U then do:
      if v-rb-is-base = yes then
        assign
          buy-data-dt.Sum-zak  = buy-data-dt.Sum-zak  - buf_trn-doc.fact-base
          buy-data-dt.Sum-skid = buy-data-dt.Sum-skid - buf_trn-doc.tot-calc
          buy-data-dt.Sum-prod = buy-data-dt.Sum-prod - buf_trn-doc.tot-doc + buf_trn-doc.tot-calc
          buy-data.Sum-zak     = buy-data.Sum-zak     - buf_trn-doc.fact-base
          buy-data.Sum-skid    = buy-data.Sum-skid    - buf_trn-doc.tot-calc
          buy-data.Sum-prod    = buy-data.Sum-prod    - buf_trn-doc.tot-doc
        .
      else
        assign
          buy-data-dt.Sum-zak  = buy-data-dt.Sum-zak  - buf_trn-doc.fact-rubl
          buy-data-dt.Sum-skid = buy-data-dt.Sum-skid - buf_trn-doc.discnt-rubl
          buy-data-dt.Sum-prod = buy-data-dt.Sum-prod - buf_trn-doc.tot-rubl + buf_trn-doc.discnt-rubl
          buy-data.Sum-zak     = buy-data.Sum-zak     - buf_trn-doc.fact-rubl
          buy-data.Sum-skid    = buy-data.Sum-skid    - buf_trn-doc.discnt-rubl
          buy-data.Sum-prod    = buy-data.Sum-prod    - buf_trn-doc.tot-rubl
        .
    end.
    else do:
      if v-rb-is-base = yes then
        assign
          buy-data-dt.Sum-zak  = buy-data-dt.Sum-zak  + buf_trn-doc.fact-base
          buy-data-dt.Sum-skid = buy-data-dt.Sum-skid + buf_trn-doc.tot-calc
          buy-data-dt.Sum-prod = buy-data-dt.Sum-prod + buf_trn-doc.tot-doc - buf_trn-doc.tot-calc
          buy-data.Sum-zak     = buy-data.Sum-zak     + buf_trn-doc.fact-base
          buy-data.Sum-skid    = buy-data.Sum-skid    + buf_trn-doc.tot-calc
          buy-data.Sum-prod    = buy-data.Sum-prod    + buf_trn-doc.tot-doc
        .
      else
        assign
          buy-data-dt.Sum-zak  = buy-data-dt.Sum-zak  + buf_trn-doc.fact-rubl
          buy-data-dt.Sum-skid = buy-data-dt.Sum-skid + buf_trn-doc.discnt-rubl
          buy-data-dt.Sum-prod = buy-data-dt.Sum-prod + buf_trn-doc.tot-rubl - buf_trn-doc.discnt-rubl
          buy-data.Sum-zak     = buy-data.Sum-zak     + buf_trn-doc.fact-rubl
          buy-data.Sum-skid    = buy-data.Sum-skid    + buf_trn-doc.discnt-rubl
          buy-data.Sum-prod    = buy-data.Sum-prod    + buf_trn-doc.tot-rubl
        .
    end.
  end.
      end.
    end.
    else MESSAGE "Ошибка: эта ветвь алгоритма не должна была сработать (buyers.w)." VIEW-AS ALERT-BOX ERROR .
  end.
  Line = fill ( "-", 232 ) .
  FORM HEADER
    Line format "X(125)" SKIP
    "Продолжение - на следующей странице" AT 30 SKIP
    with FRAME FirmBottomFrame width 235 PAGE-BOTTOM NO-LABELS no-box.
  VIEW stream PrnLibStream FRAME FirmBottomFrame .
  FORM with FRAME Firm-SaleRpt .
  for each buy-data :
    for each buy-data-dt
      where buy-data-dt.obj-type = buy-data.obj-type
        and buy-data-dt.obj-code = buy-data.obj-code
      :
      assign
        all-Sum-zak  = all-Sum-zak  + buy-data-dt.Sum-zak
        all-Sum-skid = all-Sum-skid + buy-data-dt.Sum-skid
        all-Sum-prod = all-Sum-prod + buy-data-dt.Sum-prod
        buy-data.EffValue    = buy-data.Sum-prod    - buy-data.Sum-zak
        buy-data-dt.EffValue = buy-data-dt.Sum-prod - buy-data-dt.Sum-zak
      .
    end.
  end.
  CASE Sort_Type:screen-value in FRAME DLGOKCAN :
    when "По алфавиту" then do:
define variable vss-include-info15 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  for each buy-data by Name :
    assign
      is-name = yes
      Counter1 = 0
    .
    for each buy-data-dt
      where buy-data-dt.obj-type = buy-data.obj-type
        and buy-data-dt.obj-code = buy-data.obj-code
      :
      display stream PrnLibStream
            sym1 string( buy-data.obj-code ) when (is-name = yes) @ cliregcode
            sym2 buy-data.name               when (is-name = yes) @ cliregname
            sym3 string( string( month(buy-data-dt.cur-date1) ) + "/" + string( year((buy-data-dt.cur-date1)) ) ) @ m-y
            sym4 buy-data-dt.sum-zak         when whatshow:screen-value <> "Только продажные" @ sum-zak
            sym5 buy-data-dt.sum-prod        when whatshow:screen-value <> "Только учетные"   @ sum-prod
            sym6 buy-data-dt.sum-skid        when whatshow:screen-value <> "Только учетные"   @ sum-skid
            sym7 buy-data-dt.EffValue        when whatshow:screen-value = 'все':U              @ effvalue
            with frame firm-salerpt .
         down stream PrnLibStream 1 with frame firm-salerpt .
      if is-name = yes then assign is-name = no .
      assign Counter1 = Counter1 + 1 .
    end.
    if onemonth = no and Counter1 > 1 then do:
      underline stream PrnLibStream cliregname sum-zak sum-prod sum-skid effvalue with frame firm-salerpt .
      display stream PrnLibStream
        sym1 "ИТОГО" @ cliregname
        buy-data.sum-zak  when whatshow:screen-value <> "Только продажные"  @ sum-zak
        buy-data.sum-prod when whatshow:screen-value <> "Только учетные"    @ sum-prod
        buy-data.sum-skid when whatshow:screen-value <> "Только учетные"    @ sum-skid
        buy-data.EffValue when whatshow:screen-value = 'все':U               @ effvalue
        sym4     with frame firm-salerpt .
      down stream PrnLibStream 1 with frame firm-salerpt .
      underline stream PrnLibStream cliregname sum-zak sum-prod sum-skid effvalue with frame firm-salerpt .
      down stream PrnLibStream 2 with frame firm-salerpt .
    end.
    else underline stream PrnLibStream cliregname sum-zak sum-prod sum-skid effvalue with frame firm-salerpt .
  end.
  assign  all-EffValue = all-Sum-prod - all-Sum-zak - all-Sum-skid .
  display stream PrnLibStream
    sym1 "ВСЕГО" @ cliregname
    sym4 all-Sum-zak  when whatshow:screen-value <> "Только продажные" @ sum-zak
    sym5 all-Sum-prod when whatshow:screen-value <> "Только учетные"   @ sum-prod
    sym6 all-Sum-skid when whatshow:screen-value <> "Только учетные"   @ sum-skid
    sym7 all-EffValue when whatshow:screen-value = 'все':U              @ effvalue
     with frame firm-salerpt .
  down stream PrnLibStream 1 with frame firm-salerpt .
          end.
    when "По возрастанию учетной суммы" then do:
define variable vss-include-info16 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  for each buy-data by Sum-zak :
    assign
      is-name = yes
      Counter1 = 0
    .
    for each buy-data-dt
      where buy-data-dt.obj-type = buy-data.obj-type
        and buy-data-dt.obj-code = buy-data.obj-code
      :
      display stream PrnLibStream
            sym1 string( buy-data.obj-code ) when (is-name = yes) @ cliregcode
            sym2 buy-data.name               when (is-name = yes) @ cliregname
            sym3 string( string( month(buy-data-dt.cur-date1) ) + "/" + string( year((buy-data-dt.cur-date1)) ) ) @ m-y
            sym4 buy-data-dt.sum-zak         when whatshow:screen-value <> "Только продажные" @ sum-zak
            sym5 buy-data-dt.sum-prod        when whatshow:screen-value <> "Только учетные"   @ sum-prod
            sym6 buy-data-dt.sum-skid        when whatshow:screen-value <> "Только учетные"   @ sum-skid
            sym7 buy-data-dt.EffValue        when whatshow:screen-value = 'все':U              @ effvalue
            with frame firm-salerpt .
         down stream PrnLibStream 1 with frame firm-salerpt .
      if is-name = yes then assign is-name = no .
      assign Counter1 = Counter1 + 1 .
    end.
    if onemonth = no and Counter1 > 1 then do:
      underline stream PrnLibStream cliregname sum-zak sum-prod sum-skid effvalue with frame firm-salerpt .
      display stream PrnLibStream
        sym1 "ИТОГО" @ cliregname
        buy-data.sum-zak  when whatshow:screen-value <> "Только продажные"  @ sum-zak
        buy-data.sum-prod when whatshow:screen-value <> "Только учетные"    @ sum-prod
        buy-data.sum-skid when whatshow:screen-value <> "Только учетные"    @ sum-skid
        buy-data.EffValue when whatshow:screen-value = 'все':U               @ effvalue
        sym4     with frame firm-salerpt .
      down stream PrnLibStream 1 with frame firm-salerpt .
      underline stream PrnLibStream cliregname sum-zak sum-prod sum-skid effvalue with frame firm-salerpt .
      down stream PrnLibStream 2 with frame firm-salerpt .
    end.
    else underline stream PrnLibStream cliregname sum-zak sum-prod sum-skid effvalue with frame firm-salerpt .
  end.
  assign  all-EffValue = all-Sum-prod - all-Sum-zak - all-Sum-skid .
  display stream PrnLibStream
    sym1 "ВСЕГО" @ cliregname
    sym4 all-Sum-zak  when whatshow:screen-value <> "Только продажные" @ sum-zak
    sym5 all-Sum-prod when whatshow:screen-value <> "Только учетные"   @ sum-prod
    sym6 all-Sum-skid when whatshow:screen-value <> "Только учетные"   @ sum-skid
    sym7 all-EffValue when whatshow:screen-value = 'все':U              @ effvalue
     with frame firm-salerpt .
  down stream PrnLibStream 1 with frame firm-salerpt .
          end.
    when "По возрастанию суммы продаж" then do:
define variable vss-include-info17 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  for each buy-data by Sum-prod :
    assign
      is-name = yes
      Counter1 = 0
    .
    for each buy-data-dt
      where buy-data-dt.obj-type = buy-data.obj-type
        and buy-data-dt.obj-code = buy-data.obj-code
      :
      display stream PrnLibStream
            sym1 string( buy-data.obj-code ) when (is-name = yes) @ cliregcode
            sym2 buy-data.name               when (is-name = yes) @ cliregname
            sym3 string( string( month(buy-data-dt.cur-date1) ) + "/" + string( year((buy-data-dt.cur-date1)) ) ) @ m-y
            sym4 buy-data-dt.sum-zak         when whatshow:screen-value <> "Только продажные" @ sum-zak
            sym5 buy-data-dt.sum-prod        when whatshow:screen-value <> "Только учетные"   @ sum-prod
            sym6 buy-data-dt.sum-skid        when whatshow:screen-value <> "Только учетные"   @ sum-skid
            sym7 buy-data-dt.EffValue        when whatshow:screen-value = 'все':U              @ effvalue
            with frame firm-salerpt .
         down stream PrnLibStream 1 with frame firm-salerpt .
      if is-name = yes then assign is-name = no .
      assign Counter1 = Counter1 + 1 .
    end.
    if onemonth = no and Counter1 > 1 then do:
      underline stream PrnLibStream cliregname sum-zak sum-prod sum-skid effvalue with frame firm-salerpt .
      display stream PrnLibStream
        sym1 "ИТОГО" @ cliregname
        buy-data.sum-zak  when whatshow:screen-value <> "Только продажные"  @ sum-zak
        buy-data.sum-prod when whatshow:screen-value <> "Только учетные"    @ sum-prod
        buy-data.sum-skid when whatshow:screen-value <> "Только учетные"    @ sum-skid
        buy-data.EffValue when whatshow:screen-value = 'все':U               @ effvalue
        sym4     with frame firm-salerpt .
      down stream PrnLibStream 1 with frame firm-salerpt .
      underline stream PrnLibStream cliregname sum-zak sum-prod sum-skid effvalue with frame firm-salerpt .
      down stream PrnLibStream 2 with frame firm-salerpt .
    end.
    else underline stream PrnLibStream cliregname sum-zak sum-prod sum-skid effvalue with frame firm-salerpt .
  end.
  assign  all-EffValue = all-Sum-prod - all-Sum-zak - all-Sum-skid .
  display stream PrnLibStream
    sym1 "ВСЕГО" @ cliregname
    sym4 all-Sum-zak  when whatshow:screen-value <> "Только продажные" @ sum-zak
    sym5 all-Sum-prod when whatshow:screen-value <> "Только учетные"   @ sum-prod
    sym6 all-Sum-skid when whatshow:screen-value <> "Только учетные"   @ sum-skid
    sym7 all-EffValue when whatshow:screen-value = 'все':U              @ effvalue
     with frame firm-salerpt .
  down stream PrnLibStream 1 with frame firm-salerpt .
          end.
    when "По возрастанию эффективности" then  do:
define variable vss-include-info18 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  for each buy-data by EffValue :
    assign
      is-name = yes
      Counter1 = 0
    .
    for each buy-data-dt
      where buy-data-dt.obj-type = buy-data.obj-type
        and buy-data-dt.obj-code = buy-data.obj-code
      :
      display stream PrnLibStream
            sym1 string( buy-data.obj-code ) when (is-name = yes) @ cliregcode
            sym2 buy-data.name               when (is-name = yes) @ cliregname
            sym3 string( string( month(buy-data-dt.cur-date1) ) + "/" + string( year((buy-data-dt.cur-date1)) ) ) @ m-y
            sym4 buy-data-dt.sum-zak         when whatshow:screen-value <> "Только продажные" @ sum-zak
            sym5 buy-data-dt.sum-prod        when whatshow:screen-value <> "Только учетные"   @ sum-prod
            sym6 buy-data-dt.sum-skid        when whatshow:screen-value <> "Только учетные"   @ sum-skid
            sym7 buy-data-dt.EffValue        when whatshow:screen-value = 'все':U              @ effvalue
            with frame firm-salerpt .
         down stream PrnLibStream 1 with frame firm-salerpt .
      if is-name = yes then assign is-name = no .
      assign Counter1 = Counter1 + 1 .
    end.
    if onemonth = no and Counter1 > 1 then do:
      underline stream PrnLibStream cliregname sum-zak sum-prod sum-skid effvalue with frame firm-salerpt .
      display stream PrnLibStream
        sym1 "ИТОГО" @ cliregname
        buy-data.sum-zak  when whatshow:screen-value <> "Только продажные"  @ sum-zak
        buy-data.sum-prod when whatshow:screen-value <> "Только учетные"    @ sum-prod
        buy-data.sum-skid when whatshow:screen-value <> "Только учетные"    @ sum-skid
        buy-data.EffValue when whatshow:screen-value = 'все':U               @ effvalue
        sym4     with frame firm-salerpt .
      down stream PrnLibStream 1 with frame firm-salerpt .
      underline stream PrnLibStream cliregname sum-zak sum-prod sum-skid effvalue with frame firm-salerpt .
      down stream PrnLibStream 2 with frame firm-salerpt .
    end.
    else underline stream PrnLibStream cliregname sum-zak sum-prod sum-skid effvalue with frame firm-salerpt .
  end.
  assign  all-EffValue = all-Sum-prod - all-Sum-zak - all-Sum-skid .
  display stream PrnLibStream
    sym1 "ВСЕГО" @ cliregname
    sym4 all-Sum-zak  when whatshow:screen-value <> "Только продажные" @ sum-zak
    sym5 all-Sum-prod when whatshow:screen-value <> "Только учетные"   @ sum-prod
    sym6 all-Sum-skid when whatshow:screen-value <> "Только учетные"   @ sum-skid
    sym7 all-EffValue when whatshow:screen-value = 'все':U              @ effvalue
     with frame firm-salerpt .
  down stream PrnLibStream 1 with frame firm-salerpt .
          end.
    when "По убыванию учетной суммы" then do:
define variable vss-include-info19 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  for each buy-data by Sum-zak DESCENDING :
    assign
      is-name = yes
      Counter1 = 0
    .
    for each buy-data-dt
      where buy-data-dt.obj-type = buy-data.obj-type
        and buy-data-dt.obj-code = buy-data.obj-code
      :
      display stream PrnLibStream
            sym1 string( buy-data.obj-code ) when (is-name = yes) @ cliregcode
            sym2 buy-data.name               when (is-name = yes) @ cliregname
            sym3 string( string( month(buy-data-dt.cur-date1) ) + "/" + string( year((buy-data-dt.cur-date1)) ) ) @ m-y
            sym4 buy-data-dt.sum-zak         when whatshow:screen-value <> "Только продажные" @ sum-zak
            sym5 buy-data-dt.sum-prod        when whatshow:screen-value <> "Только учетные"   @ sum-prod
            sym6 buy-data-dt.sum-skid        when whatshow:screen-value <> "Только учетные"   @ sum-skid
            sym7 buy-data-dt.EffValue        when whatshow:screen-value = 'все':U              @ effvalue
            with frame firm-salerpt .
         down stream PrnLibStream 1 with frame firm-salerpt .
      if is-name = yes then assign is-name = no .
      assign Counter1 = Counter1 + 1 .
    end.
    if onemonth = no and Counter1 > 1 then do:
      underline stream PrnLibStream cliregname sum-zak sum-prod sum-skid effvalue with frame firm-salerpt .
      display stream PrnLibStream
        sym1 "ИТОГО" @ cliregname
        buy-data.sum-zak  when whatshow:screen-value <> "Только продажные"  @ sum-zak
        buy-data.sum-prod when whatshow:screen-value <> "Только учетные"    @ sum-prod
        buy-data.sum-skid when whatshow:screen-value <> "Только учетные"    @ sum-skid
        buy-data.EffValue when whatshow:screen-value = 'все':U               @ effvalue
        sym4     with frame firm-salerpt .
      down stream PrnLibStream 1 with frame firm-salerpt .
      underline stream PrnLibStream cliregname sum-zak sum-prod sum-skid effvalue with frame firm-salerpt .
      down stream PrnLibStream 2 with frame firm-salerpt .
    end.
    else underline stream PrnLibStream cliregname sum-zak sum-prod sum-skid effvalue with frame firm-salerpt .
  end.
  assign  all-EffValue = all-Sum-prod - all-Sum-zak - all-Sum-skid .
  display stream PrnLibStream
    sym1 "ВСЕГО" @ cliregname
    sym4 all-Sum-zak  when whatshow:screen-value <> "Только продажные" @ sum-zak
    sym5 all-Sum-prod when whatshow:screen-value <> "Только учетные"   @ sum-prod
    sym6 all-Sum-skid when whatshow:screen-value <> "Только учетные"   @ sum-skid
    sym7 all-EffValue when whatshow:screen-value = 'все':U              @ effvalue
     with frame firm-salerpt .
  down stream PrnLibStream 1 with frame firm-salerpt .
          end.
    when "По убыванию суммы продаж" then do:
define variable vss-include-info20 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  for each buy-data by Sum-prod DESCENDING :
    assign
      is-name = yes
      Counter1 = 0
    .
    for each buy-data-dt
      where buy-data-dt.obj-type = buy-data.obj-type
        and buy-data-dt.obj-code = buy-data.obj-code
      :
      display stream PrnLibStream
            sym1 string( buy-data.obj-code ) when (is-name = yes) @ cliregcode
            sym2 buy-data.name               when (is-name = yes) @ cliregname
            sym3 string( string( month(buy-data-dt.cur-date1) ) + "/" + string( year((buy-data-dt.cur-date1)) ) ) @ m-y
            sym4 buy-data-dt.sum-zak         when whatshow:screen-value <> "Только продажные" @ sum-zak
            sym5 buy-data-dt.sum-prod        when whatshow:screen-value <> "Только учетные"   @ sum-prod
            sym6 buy-data-dt.sum-skid        when whatshow:screen-value <> "Только учетные"   @ sum-skid
            sym7 buy-data-dt.EffValue        when whatshow:screen-value = 'все':U              @ effvalue
            with frame firm-salerpt .
         down stream PrnLibStream 1 with frame firm-salerpt .
      if is-name = yes then assign is-name = no .
      assign Counter1 = Counter1 + 1 .
    end.
    if onemonth = no and Counter1 > 1 then do:
      underline stream PrnLibStream cliregname sum-zak sum-prod sum-skid effvalue with frame firm-salerpt .
      display stream PrnLibStream
        sym1 "ИТОГО" @ cliregname
        buy-data.sum-zak  when whatshow:screen-value <> "Только продажные"  @ sum-zak
        buy-data.sum-prod when whatshow:screen-value <> "Только учетные"    @ sum-prod
        buy-data.sum-skid when whatshow:screen-value <> "Только учетные"    @ sum-skid
        buy-data.EffValue when whatshow:screen-value = 'все':U               @ effvalue
        sym4     with frame firm-salerpt .
      down stream PrnLibStream 1 with frame firm-salerpt .
      underline stream PrnLibStream cliregname sum-zak sum-prod sum-skid effvalue with frame firm-salerpt .
      down stream PrnLibStream 2 with frame firm-salerpt .
    end.
    else underline stream PrnLibStream cliregname sum-zak sum-prod sum-skid effvalue with frame firm-salerpt .
  end.
  assign  all-EffValue = all-Sum-prod - all-Sum-zak - all-Sum-skid .
  display stream PrnLibStream
    sym1 "ВСЕГО" @ cliregname
    sym4 all-Sum-zak  when whatshow:screen-value <> "Только продажные" @ sum-zak
    sym5 all-Sum-prod when whatshow:screen-value <> "Только учетные"   @ sum-prod
    sym6 all-Sum-skid when whatshow:screen-value <> "Только учетные"   @ sum-skid
    sym7 all-EffValue when whatshow:screen-value = 'все':U              @ effvalue
     with frame firm-salerpt .
  down stream PrnLibStream 1 with frame firm-salerpt .
          end.
    when "По убыванию эффективности" then do:
define variable vss-include-info21 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  for each buy-data by EffValue DESCENDING :
    assign
      is-name = yes
      Counter1 = 0
    .
    for each buy-data-dt
      where buy-data-dt.obj-type = buy-data.obj-type
        and buy-data-dt.obj-code = buy-data.obj-code
      :
      display stream PrnLibStream
            sym1 string( buy-data.obj-code ) when (is-name = yes) @ cliregcode
            sym2 buy-data.name               when (is-name = yes) @ cliregname
            sym3 string( string( month(buy-data-dt.cur-date1) ) + "/" + string( year((buy-data-dt.cur-date1)) ) ) @ m-y
            sym4 buy-data-dt.sum-zak         when whatshow:screen-value <> "Только продажные" @ sum-zak
            sym5 buy-data-dt.sum-prod        when whatshow:screen-value <> "Только учетные"   @ sum-prod
            sym6 buy-data-dt.sum-skid        when whatshow:screen-value <> "Только учетные"   @ sum-skid
            sym7 buy-data-dt.EffValue        when whatshow:screen-value = 'все':U              @ effvalue
            with frame firm-salerpt .
         down stream PrnLibStream 1 with frame firm-salerpt .
      if is-name = yes then assign is-name = no .
      assign Counter1 = Counter1 + 1 .
    end.
    if onemonth = no and Counter1 > 1 then do:
      underline stream PrnLibStream cliregname sum-zak sum-prod sum-skid effvalue with frame firm-salerpt .
      display stream PrnLibStream
        sym1 "ИТОГО" @ cliregname
        buy-data.sum-zak  when whatshow:screen-value <> "Только продажные"  @ sum-zak
        buy-data.sum-prod when whatshow:screen-value <> "Только учетные"    @ sum-prod
        buy-data.sum-skid when whatshow:screen-value <> "Только учетные"    @ sum-skid
        buy-data.EffValue when whatshow:screen-value = 'все':U               @ effvalue
        sym4     with frame firm-salerpt .
      down stream PrnLibStream 1 with frame firm-salerpt .
      underline stream PrnLibStream cliregname sum-zak sum-prod sum-skid effvalue with frame firm-salerpt .
      down stream PrnLibStream 2 with frame firm-salerpt .
    end.
    else underline stream PrnLibStream cliregname sum-zak sum-prod sum-skid effvalue with frame firm-salerpt .
  end.
  assign  all-EffValue = all-Sum-prod - all-Sum-zak - all-Sum-skid .
  display stream PrnLibStream
    sym1 "ВСЕГО" @ cliregname
    sym4 all-Sum-zak  when whatshow:screen-value <> "Только продажные" @ sum-zak
    sym5 all-Sum-prod when whatshow:screen-value <> "Только учетные"   @ sum-prod
    sym6 all-Sum-skid when whatshow:screen-value <> "Только учетные"   @ sum-skid
    sym7 all-EffValue when whatshow:screen-value = 'все':U              @ effvalue
     with frame firm-salerpt .
  down stream PrnLibStream 1 with frame firm-salerpt .
          end.
  END CASE.
  DOWN stream PrnLibStream 1 with FRAME Firm-SaleRpt .
  PUT stream PrnLibStream Line format "X(125)" SKIP.
  HIDE stream PrnLibStream FRAME FirmBottomFrame .
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
END PROCEDURE.
PROCEDURE StartProc :
define variable CurrMonth  as       integer    no-undo.
define variable CurrYear   as      integer    no-undo.
define variable DatasBuf   as      character  no-undo.
    get-key-value section "REP-SETS" key "StartDate" value LifeStartDate.
    assign
        CurrMonth = month ( date ( LifeStartDate ) )
        CurrYear = year ( date ( LifeStartDate ) ) .
    do while CurrYear < year ( today ) :
        do while CurrMonth <= 12 :
            DatasBuf = DatasBuf +
                string ( CurrMonth, "99" ) + fill( " ", 5 ) + string ( CurrYear, "9999" ) + "," .
            CurrMonth = CurrMonth + 1 .
        end.
        assign
            CurrMonth = 1
            CurrYear = CurrYear + 1 .
    end.
    do CurrMonth = 1 to month ( today ) :
        DatasBuf = DatasBuf +
                            string ( CurrMonth, "99" ) + fill( " ", 5 ) + string ( CurrYear, "9999" ) + "," .
    end.
    TimePeriod:list-items in frame DLGOKCAN = right-trim ( datasbuf, "," ) .
    stat = TimePeriod:scroll-to-item( TimePeriod:num-items in frame DLGOKCAN )
        in frame DLGOKCAN .
  APPLY "value-changed" to SelectBuyers in FRAME DLGOKCAN .
END PROCEDURE.
