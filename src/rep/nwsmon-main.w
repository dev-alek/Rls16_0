&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------


$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Мониторинг СПН

Автор: Харитонов Владимир Александрович
Дата создания: 2012/09/21
Author: KHaritonov Vladimir 
Creation date: 2012/09/21


------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Мониторинг СПН".

{ cmp/vssrevis.i }
{ cmp/showinf.i }
{ cmp/str-glbl.i }
{ gbl/waitfram.i }
{ gbl/pck-attr.i }

def temp-table tt-db-info no-undo
    field db-num as int /* номер БД */
    field db-name as char /* название БД */
    field db-date as date /* Последняя дата из всех объектов на БД */
    field last-recv-pck-dt as datetime /* последнее время приема пакета */
    field last-sent-pck-dt as datetime /* последнее время отправки пакета */
    field last-recv-pck-dt-str as char
    field last-sent-pck-dt-str as char
    field min-processing-int as int64 /* минимальное время обработки пакета в мс */
    field max-processing-int as int64 /* максимальное время обработки пакета в мс */
    field avg-processing-int as int64 /* среднее время обработки пакета в мс */
    field min-processing-str as char
    field max-processing-str as char
    field avg-processing-str as char
    field pck-rcvd-count as int64 /* кол-во принятых пакетов */
    field pck-sent-count as int64 /* кол-во отправленных пакетов */
    field avg-recs-in-rcvd-pck as int64 /* среднее кол-во записей в пакете */
    field avg-wait-confirm-int as int64 /* среднее время ожидания подтверждения в мс */
    field avg-wait-confirm-str as char
    field pck-not-confirm-count as int64 /* кол-во не подтвержденных пакетов */
    field avg-recs-in-sent-pck as int64 /* среднее кол-во записей в пакете */
    index pi as primary unique db-num
    .

def temp-table tt-stat-info
    field db-num as int /* номер БД */
    field table-name as char /* название таблицы */
    field rec-count as int64 /* кол-во записей в таблице */
    index pi as primary unique db-num table-name
    .

def buffer buf_db for ub.db.
def buffer buf_pck-rcvd for ub.pck-rcvd.
def buffer buf_pck-sent for ub.pck-sent.
def buffer buf_pck-rcvd-attr1 for ub.pck-rcvd-attr.
def buffer buf_pck-rcvd-attr2 for ub.pck-rcvd-attr.
def buffer buf_obj-date for ub.obj-date.
def buffer buf_route for ub.route.
def buffer buf_clients for ub.clients.

def var end-work-dt as int64 no-undo.
def var last-sort-column as char no-undo.
def var last-sort-desc as logical no-undo init false.
def var dt-interval as datetime no-undo.
def var dt-not-conf-interval as datetime no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-dbs

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-db-info tt-stat-info

/* Definitions for BROWSE BROWSE-dbs                                    */
&Scoped-define FIELDS-IN-QUERY-BROWSE-dbs tt-db-info.db-num tt-db-info.db-name tt-db-info.db-date tt-db-info.pck-rcvd-count tt-db-info.pck-sent-count tt-db-info.last-recv-pck-dt-str tt-db-info.last-sent-pck-dt-str tt-db-info.min-processing-str tt-db-info.max-processing-str tt-db-info.avg-processing-str tt-db-info.avg-wait-confirm-str tt-db-info.avg-recs-in-rcvd-pck tt-db-info.pck-not-confirm-count tt-db-info.avg-recs-in-sent-pck   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-dbs   
&Scoped-define SELF-NAME BROWSE-dbs
&Scoped-define QUERY-STRING-BROWSE-dbs FOR EACH tt-db-info NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-dbs OPEN QUERY {&SELF-NAME} FOR EACH tt-db-info NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-dbs tt-db-info
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-dbs tt-db-info


/* Definitions for BROWSE BROWSE-stat                                   */
&Scoped-define FIELDS-IN-QUERY-BROWSE-stat tt-stat-info.table-name tt-stat-info.rec-count   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-stat   
&Scoped-define SELF-NAME BROWSE-stat
&Scoped-define QUERY-STRING-BROWSE-stat FOR EACH tt-stat-info
&Scoped-define OPEN-QUERY-BROWSE-stat OPEN QUERY {&SELF-NAME} FOR EACH tt-stat-info.
&Scoped-define TABLES-IN-QUERY-BROWSE-stat tt-stat-info
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-stat tt-stat-info


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-dbs}~
    ~{&OPEN-QUERY-BROWSE-stat}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 RECT-2 Btn_OK Btn_print BUTTON-start ~
dbs abs-time-pack avail-time period BROWSE-dbs BROWSE-stat 
&Scoped-Define DISPLAYED-OBJECTS dbs abs-time-pack avail-time period 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_OK AUTO-GO 
     LABEL "Выход" 
     SIZE 7 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_print 
     LABEL "Печать" 
     SIZE 7 BY 1
     BGCOLOR 8 .

DEFINE BUTTON BUTTON-start 
     LABEL "Запуск" 
     SIZE 7 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE abs-time-pack AS INTEGER FORMAT ">>>>9":U INITIAL 6 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE avail-time AS INTEGER FORMAT ">>>>9":U INITIAL 6 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE period AS INTEGER FORMAT ">>>>9":U INITIAL 24 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE sel-dbs AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE dbs AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Активные", 1,
"Выборочно", 2
     SIZE 16 BY 1.62 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 36 BY 3.1.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 59 BY 3.1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-dbs FOR 
      tt-db-info SCROLLING.

DEFINE QUERY BROWSE-stat FOR 
      tt-stat-info SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-dbs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-dbs Dialog-Frame _FREEFORM
  QUERY BROWSE-dbs NO-LOCK DISPLAY
      tt-db-info.db-num COLUMN-LABEL "№" FORMAT ">>>>9"
        tt-db-info.db-name COLUMN-LABEL "Название БД" FORMAT "X(25)"
        tt-db-info.db-date COLUMN-LABEL "Дата БД" FORMAT "99/99/9999"
        tt-db-info.pck-rcvd-count COLUMN-LABEL "Принято!пакетов" FORMAT ">>>,>>>,>>9"
        tt-db-info.pck-sent-count COLUMN-LABEL "Отправлено!пакетов" FORMAT ">>>,>>>,>>9"
        tt-db-info.last-recv-pck-dt-str COLUMN-LABEL "Время приема!последнего пакета" FORMAT "X(20)"
        tt-db-info.last-sent-pck-dt-str COLUMN-LABEL "Время отправки!последнего пакета" FORMAT "X(20)"
        tt-db-info.min-processing-str COLUMN-LABEL "Миним. время!обработки пакетов" FORMAT "X(32)"
        tt-db-info.max-processing-str COLUMN-LABEL "Макс. время!обработки пакетов" FORMAT "X(32)"
        tt-db-info.avg-processing-str COLUMN-LABEL "Среднее время!обработки пакетов" FORMAT "X(32)"
        tt-db-info.avg-wait-confirm-str COLUMN-LABEL "Среднее время!ожидания подтверждения" FORMAT "X(32)" 
        tt-db-info.avg-recs-in-rcvd-pck COLUMN-LABEL "Среднее кол-во записей!в полученном пакете" FORMAT ">>>,>>>,>>9"
        tt-db-info.pck-not-confirm-count COLUMN-LABEL "Кол-во не!подтвержденных пакетов" FORMAT ">>>,>>>,>>9"
        tt-db-info.avg-recs-in-sent-pck COLUMN-LABEL "Среднее кол-во записей!в передаваемом пакете" FORMAT ">>>,>>>,>>9"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 109 BY 13.1
         TITLE "Общая информация по работе СПН".

DEFINE BROWSE BROWSE-stat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-stat Dialog-Frame _FREEFORM
  QUERY BROWSE-stat DISPLAY
      tt-stat-info.table-name COLUMN-LABEL "Таблица" FORMAT "X(80)"
        tt-stat-info.rec-count COLUMN-LABEL "Записей" FORMAT ">>>,>>>,>>9"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 109 BY 8.33
         TITLE "Статистика по исходящей информации" FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1 COL 2
     Btn_print AT ROW 1 COL 9 WIDGET-ID 2
     BUTTON-start AT ROW 1 COL 17 WIDGET-ID 12
     dbs AT ROW 2.33 COL 7 NO-LABEL WIDGET-ID 6
     sel-dbs AT ROW 2.43 COL 27 NO-LABEL WIDGET-ID 10
     abs-time-pack AT ROW 2.43 COL 84 COLON-ALIGNED NO-LABEL WIDGET-ID 42
     avail-time AT ROW 3.86 COL 84 COLON-ALIGNED NO-LABEL WIDGET-ID 44
     period AT ROW 3.95 COL 25 COLON-ALIGNED NO-LABEL WIDGET-ID 26
     BROWSE-dbs AT ROW 5.29 COL 2 WIDGET-ID 600
     BROWSE-stat AT ROW 18.38 COL 2 WIDGET-ID 700
     "Допустимое время отсутствия пакетов (в часах)" VIEW-AS TEXT
          SIZE 45 BY 1.1 AT ROW 2.43 COL 39 WIDGET-ID 46
     "БД:" VIEW-AS TEXT
          SIZE 4 BY 1.62 AT ROW 2.33 COL 2.4 WIDGET-ID 20
     "Период анализа в часах:" VIEW-AS TEXT
          SIZE 24 BY .81 AT ROW 4.1 COL 2.4 WIDGET-ID 38
     "Допустимое время цикла (в часах):" VIEW-AS TEXT
          SIZE 38 BY 1.1 AT ROW 3.62 COL 39 WIDGET-ID 48
     RECT-1 AT ROW 2.19 COL 2 WIDGET-ID 50
     RECT-2 AT ROW 2.19 COL 38 WIDGET-ID 52
     SPACE(15.19) SKIP(21.70)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Мониторинг СПН"
         DEFAULT-BUTTON Btn_OK WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-dbs period Dialog-Frame */
/* BROWSE-TAB BROWSE-stat BROWSE-dbs Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       BROWSE-dbs:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1
       BROWSE-dbs:ALLOW-COLUMN-SEARCHING IN FRAME Dialog-Frame = TRUE.

/* SETTINGS FOR FILL-IN sel-dbs IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE ALIGN-L                                         */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-dbs
/* Query rebuild information for BROWSE BROWSE-dbs
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-db-info NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BROWSE-dbs */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-stat
/* Query rebuild information for BROWSE BROWSE-stat
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-stat-info.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-stat */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Мониторинг СПН */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-dbs
&Scoped-define SELF-NAME BROWSE-dbs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-dbs Dialog-Frame
ON ROW-DISPLAY OF BROWSE-dbs IN FRAME Dialog-Frame /* Общая информация по работе СПН */
DO:
    run highlight-dbs-rows.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-dbs Dialog-Frame
ON START-SEARCH OF BROWSE-dbs IN FRAME Dialog-Frame /* Общая информация по работе СПН */
DO:
    run do-sort.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-dbs Dialog-Frame
ON VALUE-CHANGED OF BROWSE-dbs IN FRAME Dialog-Frame /* Общая информация по работе СПН */
DO:
  run refresh-query(2).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_print Dialog-Frame
ON CHOOSE OF Btn_print IN FRAME Dialog-Frame /* Печать */
DO:
  message "Печать пока не предусмотрена!" view-as alert-box. 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-start Dialog-Frame
ON CHOOSE OF BUTTON-start IN FRAME Dialog-Frame /* Запуск */
DO:
    run fill-tables.
    run refresh-query(1).
    apply "VALUE-CHANGED" to BROWSE-dbs.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME dbs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL dbs Dialog-Frame
ON VALUE-CHANGED OF dbs IN FRAME Dialog-Frame
DO:
  assign frame dialog-frame dbs.
  if dbs = 1 then disable sel-dbs with frame dialog-frame.
  else enable sel-dbs with frame dialog-frame.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

{ gbl/diasize.i
  &browse-name="BROWSE-dbs"
}

run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse BROWSE-stat :handle
  ) .
run diasize_init in this-procedure .

  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

procedure do-sort:
    def var h-col as handle no-undo.
    def var h-query as handle no-undo.
    def var qstr as char no-undo.
    
    do with frame dialog-frame:
        h-col = BROWSE-dbs:CURRENT-COLUMN.
        h-query = BROWSE-dbs:QUERY.
        
        qstr = "FOR EACH tt-db-info BY " + h-col:NAME.
        if last-sort-column = h-col:NAME then do:
            if last-sort-desc then
                qstr = qstr + " DESC".
            
            last-sort-desc = not last-sort-desc.
        end.
        else
            last-sort-desc = true.
        
        h-query:QUERY-CLOSE().
        h-query:QUERY-PREPARE(qstr).
        h-query:QUERY-OPEN().
        
        last-sort-column = h-col:NAME.
    end.
end.

function ticks-to-str returns char (ticks as int64):
    
    def var v-hour as int no-undo init 0 format ">9".
    def var v-min as int no-undo init 0 format "99".
    def var v-sec as int no-undo init 0 format "99".
    
    def var str as char no-undo init "".    
    def var tmp as int64 no-undo format ">>9".
    
    tmp = ticks.
    
    def var hour-ticks as int no-undo.
    hour-ticks = 1000 * 60 * 60.
    
    def var min-ticks as int no-undo.
    min-ticks = 1000 * 60.
    
    if tmp >= hour-ticks then do:
        v-hour = tmp / hour-ticks.
        tmp = tmp mod hour-ticks.
    end.
    
    if tmp >= min-ticks then do:
        v-min = tmp / min-ticks.
        tmp = tmp mod min-ticks.
    end.
    
    if tmp >= 1000 then do:
        v-sec = tmp / 1000.
        tmp = tmp mod 1000.
    end.
    
    if tmp = ? then tmp = 0.
    
    return substitute("&1 ч. &2 мин. &3 сек. &4 мс.", v-hour, v-min, v-sec, tmp).
end.

procedure check-before-start:
    def var er-text as char no-undo init "".
    def var i as int no-undo.
    def var num as int no-undo.
    
    assign frame dialog-frame sel-dbs dbs.
    if dbs = 2 then do:            
      
        num = num-entries(sel-dbs).
        if num < 1 then er-text = er-text + chr(10) + "Не указан ни один номер БД".
        else do:
            do i = 1 to num:
                integer(entry(i, sel-dbs)) no-error.
                if error-status:ERROR then er-text = er-text + chr(10) + "Номер БД на позиции " + string(i) + " не является числом".
            end.
        end.
    end.
    
    return er-text.
end.

function prev-send-pck returns logical(fflag as logical):    
    if fflag then do:
        find last buf_pck-sent no-lock
            where buf_pck-sent.db-num = buf_db.db-num
            no-error.
            
        return avail buf_pck-sent.
    end.
    
    find prev buf_pck-sent no-lock
        where buf_pck-sent.db-num = buf_db.db-num
        no-error.
    return avail buf_pck-sent.
end.

function prev-rcvd-pck returns logical(fflag as logical):    
    if fflag then do:
        find last buf_pck-rcvd no-lock
            where buf_pck-rcvd.db-num = buf_db.db-num
            no-error.
        return avail buf_pck-rcvd.
    end.
    
    find prev buf_pck-rcvd no-lock
        where buf_pck-rcvd.db-num = buf_db.db-num
        no-error.
    return avail buf_pck-rcvd.
end.

procedure fill-tables:   
    def var ind as int no-undo.
          
    run check-before-start no-error.
    if return-value <> "" then do:
        message return-value + chr(10) + chr(10) + "Продолжение не возможно!" view-as alert-box.
        return.    
    end.
    
    empty temp-table tt-db-info.
    empty temp-table tt-stat-info.
    
    assign frame dialog-frame period abs-time-pack avail-time.

    /* расчитываем дату и время цикла */
    end-work-dt = avail-time * 60 * 60 * 1000.

    /* расчитываем рабочий интервал, пакеты не вошедшии туда, будут пропускаться */
    dt-interval = add-interval(now, -(period), "hours").
    
    /* расчитываем допустимый интервал отсутствия пакетов */
    dt-not-conf-interval = add-interval(now, -(abs-time-pack), "hours").
    
    if dbs = 1 then
        for each buf_db where buf_db.db-key <> "":
            run fill-record.
        end.
    else do:
        for each buf_db:
            ind = lookup(string(buf_db.db-num), sel-dbs).
            if ind > 0 then
                run fill-record.
        end.
    end.
    
    run waitfram-hide.
    
end.

procedure fill-record:    
    def var i as int no-undo.
    def var num as int no-undo.
    def var flag as logical no-undo.    
    def var beg-imp-dt as datetime no-undo.
    def var end-imp-dt as datetime no-undo.
    def var processing-int as int64 no-undo.
    def var first-flag as logical no-undo init true.
    def var cre-dt as datetime no-undo.
    def var sent-txt-dt as datetime no-undo.
    def var rcvd-dt as datetime no-undo.
    def var wait-confirm-int as int64 no-undo.
    def var atr-type as char no-undo.
    def var atr-val1 as char no-undo.
    def var atr-val2 as char no-undo.

    run waitfram-show("Анализ БД " + string(buf_db.db-num)).
           
    create tt-db-info.
    assign /* номер/название БД */
        tt-db-info.db-num = buf_db.db-num
        tt-db-info.db-name = buf_db.db-name
        .
        
    /* дата БД */   
    for each buf_clients use-index db-num
        where buf_clients.db-num = buf_db.db-num no-lock:
   
            find last buf_obj-date no-lock use-index pi
                where buf_obj-date.obj-code = buf_clients.obj-code
                and buf_obj-date.obj-type = buf_clients.obj-type
                no-error.
                
            if avail buf_obj-date then do:
                if tt-db-info.db-date < buf_obj-date.sys-date or tt-db-info.db-date = ? then
                    tt-db-info.db-date = buf_obj-date.sys-date.
            end.
    end.
    
    first-flag = true.
    tt-db-info.pck-rcvd-count = 0.
    tt-db-info.min-processing-int = ?.
                    
    do while prev-rcvd-pck(first-flag):            
        first-flag = false.
        
        if buf_pck-rcvd.BegImpDate = ? or buf_pck-rcvd.BegImpTime = ? then next.
        
        beg-imp-dt = datetime(string(buf_pck-rcvd.BegImpDate) + " " + buf_pck-rcvd.BegImpTime) no-error.
        if error-status:ERROR then next.
        
        /* последнее время приема пакета */               
        if tt-db-info.last-recv-pck-dt = ?
            or tt-db-info.last-recv-pck-dt < beg-imp-dt
                then
                    tt-db-info.last-recv-pck-dt = beg-imp-dt.
        
        if buf_pck-rcvd.EndImpDate = ? or buf_pck-rcvd.EndImpTime = ? then next.

        end-imp-dt = datetime(string(buf_pck-rcvd.EndImpDate) + " " + buf_pck-rcvd.EndImpTime) no-error.
        if error-status:ERROR then next.
               
        /* если пакет выходит за дату анализа, то выходим из цикла */
        if beg-imp-dt < dt-interval then leave. 
        
        /* время обработки пакета */
        processing-int = end-imp-dt - beg-imp-dt.
        
        /* мин время обработки принятых пакетов */
        if tt-db-info.min-processing-int = ?
            or tt-db-info.min-processing-int > processing-int
                then
                    tt-db-info.min-processing-int = processing-int.
                    
        /* макс время обработки принятых пакетов */
        if tt-db-info.max-processing-int = ?
            or tt-db-info.max-processing-int < processing-int
                then
                    tt-db-info.max-processing-int = processing-int.
        
        /* среднее время - сумма интервалов */
        tt-db-info.avg-processing-int = tt-db-info.avg-processing-int + processing-int.
        
        /* среднее кол-во записей в полученном пакете */
        tt-db-info.avg-recs-in-rcvd-pck = tt-db-info.avg-recs-in-rcvd-pck + buf_pck-rcvd.total-recs.
        
        /* кол-во принятых пакетов */            
        tt-db-info.pck-rcvd-count = tt-db-info.pck-rcvd-count + 1.
        
    end. /* do while prev-rcvd-pck */
    
    tt-db-info.min-processing-str = ticks-to-str(tt-db-info.min-processing-int).
    tt-db-info.max-processing-str = ticks-to-str(tt-db-info.max-processing-int).
    
    tt-db-info.avg-processing-int = tt-db-info.avg-processing-int / tt-db-info.pck-rcvd-count.
    tt-db-info.avg-processing-str = ticks-to-str(tt-db-info.avg-processing-int).
    
    tt-db-info.avg-recs-in-rcvd-pck = tt-db-info.avg-recs-in-rcvd-pck / tt-db-info.pck-rcvd-count.
    if tt-db-info.avg-recs-in-rcvd-pck = ? then tt-db-info.avg-recs-in-rcvd-pck = 0.

    if tt-db-info.last-recv-pck-dt = ? then
        tt-db-info.last-recv-pck-dt-str = "-".
    else
        tt-db-info.last-recv-pck-dt-str = string(tt-db-info.last-recv-pck-dt, "99/99/9999 HH:MM:SS").

    first-flag = true.
    tt-db-info.avg-recs-in-sent-pck = 0.
    
    do while prev-send-pck(first-flag):
                
        first-flag = false.
        
        if buf_pck-sent.SendTxtDate = ? or buf_pck-sent.SendTxtTime = ? then next.
        
        sent-txt-dt = datetime(string(buf_pck-sent.SendTxtDate) + " " + buf_pck-sent.SendTxtTime) no-error.
        if error-status:ERROR then next.

        /* время отправки последнего пакета */            
        if tt-db-info.last-sent-pck-dt = ?
            or tt-db-info.last-sent-pck-dt < sent-txt-dt
                then
                    tt-db-info.last-sent-pck-dt = sent-txt-dt.
        
        if buf_pck-sent.CreDate = ? or buf_pck-sent.CreTime = ? then next.
        
        cre-dt = datetime(string(buf_pck-sent.CreDate) + " " + buf_pck-sent.CreTime) no-error.
        if error-status:ERROR then next.
        
        if buf_pck-sent.RcvdDate = ? or buf_pck-sent.RcvdTime = ? then next.

        /* если пакет выходит за дату анализа, то выходим из цикла */
        if cre-dt < dt-interval then leave.

        rcvd-dt = datetime(string(buf_pck-sent.RcvdDate) + " " + buf_pck-sent.RcvdTime) no-error.
        if error-status:ERROR then next.
         
        /* среднее время ожидания подтверждения */
        wait-confirm-int = rcvd-dt - cre-dt.
        tt-db-info.avg-wait-confirm-int = tt-db-info.avg-wait-confirm-int + wait-confirm-int.
                    
        /* кол-во не подтвержденных пакетов */
        if not buf_pck-sent.rcvd then
            tt-db-info.pck-not-confirm-count = tt-db-info.pck-not-confirm-count + 1.
                
        /* среднее кол-во записей в пакетах */
        tt-db-info.avg-recs-in-sent-pck = tt-db-info.avg-recs-in-sent-pck + buf_pck-sent.total-recs.
        
        /* детализация по выгруженным данным */
        run fill-route-stat(buf_pck-sent.pack-num).
        
        tt-db-info.pck-sent-count = tt-db-info.pck-sent-count + 1.
        
    end. /* do while prev-send-pck */
                
    run fill-route-stat(-1).
    tt-db-info.avg-wait-confirm-int = tt-db-info.avg-wait-confirm-int / tt-db-info.pck-sent-count.
    tt-db-info.avg-wait-confirm-str = ticks-to-str(tt-db-info.avg-wait-confirm-int).
    
    tt-db-info.avg-recs-in-sent-pck = tt-db-info.avg-recs-in-sent-pck / tt-db-info.pck-sent-count.
    if tt-db-info.avg-recs-in-sent-pck = ? then tt-db-info.avg-recs-in-sent-pck = 0.
  
    if tt-db-info.last-sent-pck-dt = ? then
        tt-db-info.last-sent-pck-dt-str = "-".
    else
        tt-db-info.last-sent-pck-dt-str = string(tt-db-info.last-sent-pck-dt, "99/99/9999 HH:MM:SS").
end.

/* детализация по выгруженным данным */
procedure fill-route-stat:
    def input param p-last-pck-num as int.
    def var route-dt as datetime no-undo.
    
    for each buf_route no-lock
        where buf_route.db-num = buf_db.db-num
        and buf_route.last-pack = p-last-pck-num:
            
            route-dt = datetime(string(buf_route.CreDate) + " " + buf_route.CreTime) no-error.
            if error-status:ERROR then next.
                        
            find first tt-stat-info no-lock
                where tt-stat-info.table-name = buf_route.name-rec
                and tt-stat-info.db-num = buf_db.db-num
                no-error.
            if not avail tt-stat-info then do:
                create tt-stat-info.
                assign
                    tt-stat-info.db-num = buf_db.db-num
                    tt-stat-info.table-name = buf_route.name-rec
                    .
            end.
            tt-stat-info.rec-count = tt-stat-info.rec-count + 1.
    end.
end.

procedure highlight-dbs-rows:
    do with frame dialog-frame:
        if tt-db-info.last-recv-pck-dt < dt-not-conf-interval then
            tt-db-info.last-recv-pck-dt-str:FGCOLOR in browse BROWSE-dbs = 12.
               
        if tt-db-info.avg-wait-confirm-int > end-work-dt then
            tt-db-info.avg-wait-confirm-str:FGCOLOR in browse BROWSE-dbs = 12.
    end.
end.

procedure refresh-query:
    def input param p-query-num as int.
    
    do with frame frame-dbs:
        if p-query-num = 1 then
            OPEN QUERY BROWSE-dbs for each tt-db-info.
        if p-query-num = 2 then
            OPEN QUERY BROWSE-stat for each tt-stat-info
                where tt-stat-info.db-num = tt-db-info.db-num.
    end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other 
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY dbs abs-time-pack avail-time period 
      WITH FRAME Dialog-Frame.
  ENABLE RECT-1 RECT-2 Btn_OK Btn_print BUTTON-start dbs abs-time-pack 
         avail-time period BROWSE-dbs BROWSE-stat 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

