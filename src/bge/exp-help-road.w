&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DECLARATIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Параметры выгрузки реализации банковских продуктов

Автор: Белоусов Илья Александрович
Дата создания: 04/16/09
Author: Ilia Belousov
Creation date: 04/16/09

*/


/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/
{ rep/exp-help-road.i       }

/* ***************************  Definitions  ************************** */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Параметры выгрузки реализации банковских продуктов".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ cmp/gds-list.i gds-list def "new shared" }
{ ref/shd-attr.i }
{ ref/extclass.i }

/* Parameters Definitions ---                                           */

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .
define input PARAMETER p-mode           AS CHARACTER NO-UNDO.
/*вызывается для задания параметров или перед непосредственнно выполнением*/
/*может быть 'shd' или 'run' */
define input parameter p-db-num-char    as character    no-undo.
define input parameter p-task-type      as character    no-undo.
define input parameter p-task-num       as integer      no-undo.

/*при p-mode = 'run'*/
define input parameter p-action         as character    no-undo.
/**/
define output parameter p-cancel        as logical      no-undo.
define output parameter p-params        as character    no-undo.

define variable v-text         as character no-undo .
define variable v-text-oss     as character no-undo .
define variable v-text-gds     as character no-undo .
define variable v-today        as date      no-undo .

/* Local Variable Definitions ---                                       */
define variable v-rid-list     as character no-undo.
define variable v-rid-list-oss as character no-undo.
define variable v-rid-list-gds as character no-undo.


define variable pList as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 28/12/18 -  1:23 pm

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define variable c-dir          as character no-undo. /* Директория для сохранения файла */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 RECT-8 RECT-2 RECT-3 b-exit b-quit ~
num-days EDITOR-1 RADIO-SET-1 EDITOR-2 RADIO-SET-2 EDITOR-3 RADIO-SET-3 ~
v-folder b-dir v-file 
&Scoped-Define DISPLAYED-OBJECTS num-days EDITOR-1 RADIO-SET-1 EDITOR-2 ~
RADIO-SET-2 EDITOR-3 RADIO-SET-3 v-folder v-file 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-dir 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY .88.

DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE EDITOR-1 AS CHARACTER 
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 40.63 BY 4 NO-UNDO.

DEFINE VARIABLE EDITOR-2 AS CHARACTER INITIAL "Все" 
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 40.63 BY 3.71 NO-UNDO.

DEFINE VARIABLE EDITOR-3 AS CHARACTER INITIAL "Все" 
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 40.63 BY 3.71 NO-UNDO.

DEFINE VARIABLE num-days AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0 
     LABEL "За последние" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE v-file AS CHARACTER FORMAT "X(25)":U 
     LABEL "Имя файла" 
     VIEW-AS FILL-IN 
     SIZE 30.63 BY 1 NO-UNDO.

DEFINE VARIABLE v-folder AS CHARACTER FORMAT "X(25)":U 
     LABEL "Путь для выгрузки файла" 
     VIEW-AS FILL-IN 
     SIZE 27.5 BY 1 NO-UNDO.

DEFINE VARIABLE RADIO-SET-1 AS INTEGER INITIAL 2 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Текущий", 2,
"Все по фирме", 1,
"Выборочно", 3,
"Все", 4
     SIZE 15 BY 3 NO-UNDO.

DEFINE VARIABLE RADIO-SET-2 AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Все", 1,
"Выборочно", 2
     SIZE 15 BY 1.71 NO-UNDO.

DEFINE VARIABLE RADIO-SET-3 AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Все", 1,
"Выборочно", 2
     SIZE 15 BY 1.71 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 60 BY 4.71.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 60 BY 4.71.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 60 BY 4.71.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 60 BY 2.79.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 2.63
     b-quit AT ROW 1 COL 12.63
     num-days AT ROW 2.5 COL 19.5 COLON-ALIGNED WIDGET-ID 22
     EDITOR-1 AT ROW 4.5 COL 21.25 NO-LABEL
     RADIO-SET-1 AT ROW 5.08 COL 4 NO-LABEL
     EDITOR-2 AT ROW 9.75 COL 21.13 NO-LABEL WIDGET-ID 2
     RADIO-SET-2 AT ROW 10.04 COL 3.88 NO-LABEL WIDGET-ID 4
     EDITOR-3 AT ROW 14.75 COL 21.13 NO-LABEL WIDGET-ID 12
     RADIO-SET-3 AT ROW 15.04 COL 3.88 NO-LABEL WIDGET-ID 14
     v-folder AT ROW 19.63 COL 29 COLON-ALIGNED
     b-dir AT ROW 19.67 COL 58.63 WIDGET-ID 30
     v-file AT ROW 20.75 COL 29 COLON-ALIGNED
     "дней" VIEW-AS TEXT
          SIZE 8 BY 1 AT ROW 2.5 COL 36 WIDGET-ID 32
     " Выбор платежных агентов/операторов:" VIEW-AS TEXT
          SIZE 37.63 BY .67 AT ROW 9 COL 3.38 WIDGET-ID 26
          FGCOLOR 4 
     " Выгрузка в:" VIEW-AS TEXT
          SIZE 13.63 BY .67 AT ROW 18.75 COL 4.88
          FGCOLOR 4 
     " Выбор объектов:" VIEW-AS TEXT
          SIZE 17 BY .67 AT ROW 4.04 COL 3.38
          FGCOLOR 4 
     " Выбор товаров платежного агента/оператора:" VIEW-AS TEXT
          SIZE 43.63 BY .67 AT ROW 14 COL 3.38 WIDGET-ID 28
          FGCOLOR 4 
     RECT-1 AT ROW 4.29 COL 2.63
     RECT-8 AT ROW 19.17 COL 2.5
     RECT-2 AT ROW 9.25 COL 2.5 WIDGET-ID 10
     RECT-3 AT ROW 14.25 COL 2.5 WIDGET-ID 20
     SPACE(1.49) SKIP(3.95)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Параметры выгрузки банковских продуктов"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.


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
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       EDITOR-1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN 
       EDITOR-2:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN 
       EDITOR-3:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры выгрузки банковских продуктов */
DO:
    APPLY "END-ERROR":U TO SELF.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-dir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-dir Dialog-Frame
ON CHOOSE OF b-dir IN FRAME Dialog-Frame
DO:
    /* Выбор директории */
    system-dialog get-dir c-dir.
    v-folder:screen-value in frame Dialog-Frame = c-dir.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
    RUN proc-save IN THIS-PROCEDURE .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-SET-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-SET-1 Dialog-Frame
ON VALUE-CHANGED OF RADIO-SET-1 IN FRAME Dialog-Frame
DO:
    ASSIGN
      Radio-set-1
      .
    CASE RADIO-SET-1:
      /*Все по фирме*/
      WHEN 1 THEN 
        DO:
          EDITOR-1 = "":U.
          EMPTY TEMP-TABLE tt-obj.
          FOR EACH ub.clients NO-LOCK
            WHERE ub.clients.obj-type = {&shop}
            :
            CREATE tt-obj.
            ASSIGN
              tt-obj.obj-code  = ub.clients.obj-code
              tt-obj.obj-type  = ub.clients.obj-type
              tt-obj.obj-name  = ub.clients.obj-name
              tt-obj.host-code = ub.clients.host-code
              .
            ASSIGN
              v-text = v-text + {&new-line} + ub.clients.obj-name
              .
          END.
          ASSIGN
            v-text   = TRIM(v-text, {&new-line})
            EDITOR-1 = v-text
            .
        END.    
      /*текущий*/
      WHEN 2 THEN 
        DO:
          EMPTY TEMP-TABLE tt-obj.
          FIND FIRST ub.clients
            WHERE ub.clients.obj-type = v-cntxt-obj-type
            AND ub.clients.obj-code = v-cntxt-obj-code
            NO-LOCK
            .
          CREATE tt-obj.
          ASSIGN
            tt-obj.obj-code  = ub.clients.obj-code
            tt-obj.obj-type  = ub.clients.obj-type
            tt-obj.obj-name  = ub.clients.obj-name
            tt-obj.host-code = ub.clients.host-code
            .
          ASSIGN
            EDITOR-1 = ub.clients.obj-name
            .
        END.
      /*выборочно*/
      WHEN 3
      THEN 
        DO:
          run ref/cli-all.w ( parParentProc
            , input "b-sel,b-mark"
            , {&shop}
            , ?
            , ?
            , ?
            , ?
            , ?
            , output  v-rid-list
            ) .
          IF  v-rid-list <> "":U
            AND v-rid-list <> ?
            THEN 
          DO:
            EDITOR-1 = "":U.
            define variable v-ii1  as integer   no-undo.
            define variable v-text as character no-undo.

            EMPTY TEMP-TABLE tt-obj.
            DO v-ii1 = 1 to num-entries(v-rid-list):
              FIND FIRST ub.clients
                WHERE RECID( ub.clients ) = integer(entry(v-ii1, v-rid-list))
                NO-LOCK
                .
              ASSIGN
                v-text = v-text + {&new-line} + ub.clients.obj-name
                .
              CREATE tt-obj.
              ASSIGN
                tt-obj.obj-code  = ub.clients.obj-code
                tt-obj.obj-type  = ub.clients.obj-type
                tt-obj.obj-name  = ub.clients.obj-name
                tt-obj.host-code = ub.clients.host-code
                .

            END.
            ASSIGN
              v-text   = TRIM(v-text, {&new-line})
              EDITOR-1 = v-text
              .
          END.
        END.

      /*Все*/
      WHEN 4 THEN 
        DO:
          EDITOR-1 = "Все":U.
          EMPTY TEMP-TABLE tt-obj.
          FOR EACH ub.clients
            WHERE ub.clients.obj-type = {&shop}
            NO-LOCK
            :
            CREATE tt-obj.
            ASSIGN
              tt-obj.obj-code  = ub.clients.obj-code
              tt-obj.obj-type  = ub.clients.obj-type
              tt-obj.obj-name  = ub.clients.obj-name
              tt-obj.host-code = ub.clients.host-code
              .
            ASSIGN
              v-text = v-text + {&new-line} + ub.clients.obj-name
              .
          END.
        END.
      OTHERWISE 
      DO:
      END.
    END case.
    DISPLAY
      EDITOR-1
      WITH FRAME Dialog-Frame.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-SET-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-SET-2 Dialog-Frame
ON VALUE-CHANGED OF RADIO-SET-2 IN FRAME Dialog-Frame
DO:

    ASSIGN
      Radio-set-2
      .
    CASE RADIO-SET-2:
      /*выборочно*/
      WHEN 2
      THEN 
        DO:
          run ref/bpa.p(INPUT parparentproc,INPUT {&SELECT},OUTPUT pList) no-error.

          if pList <> ? or pList <> ""
            THEN 
          DO:
            EDITOR-2 = "":U.
            define variable v-ii1 as integer no-undo.

            EMPTY TEMP-TABLE tt-oss-ref.
            v-text-oss = "" .
            trim (pList,{&delim-cmd}) .
            DO v-ii1 = 1 to num-entries (pList,{&delim-cmd}):
              
              FIND FIRST ub.OperServ no-lock 
                WHERE ub.OperServ.id = integer(entry(v-ii1,pList,{&delim-cmd}))
                no-error
                .
                if available (ub.OperServ) then do:
              ASSIGN
                v-text-oss = v-text-oss + {&new-line} + ub.OperServ.ext-code.
              .
              buffer-copy ub.OperServ to tt-oss-ref .
              end.
            END.
            ASSIGN
              v-text-oss = TRIM(v-text-oss, {&new-line})
              EDITOR-2   = v-text-oss
              .
          END.
          else do:
            assign
            RADIO-SET-2 = 1 .
            DISPLAY RADIO-SET-2 WITH FRAME Dialog-Frame.       
          end.  
        END.
      /*Все*/
      WHEN 1 THEN 
        DO:
          EDITOR-2 = "Все":U.
          EMPTY TEMP-TABLE tt-oss-ref.
          FOR EACH ub.OperServ
            NO-LOCK
            :
           CREATE tt-oss-ref.
           buffer-copy ub.OperServ to tt-oss-ref .
            ASSIGN
              v-text-oss = v-text-oss + {&new-line} + ub.OperServ.ext-code
              .
          END.
        END.
      OTHERWISE 
      DO:
      END.
    END case.
    DISPLAY
      EDITOR-2
      WITH FRAME Dialog-Frame.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-SET-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-SET-3 Dialog-Frame
ON VALUE-CHANGED OF RADIO-SET-3 IN FRAME Dialog-Frame
DO:

    ASSIGN
      Radio-set-3
      .
    CASE RADIO-SET-3:
      /*выборочно*/
      WHEN 2
      THEN 
        DO:
          run str/gds-list.w ( input parparentproc
            , input v-cntxt-host-code-obj
            , input v-cntxt-obj-type
            , input v-cntxt-obj-code).
                      
          if can-find(first gds-list no-lock) then 
          do:
            EDITOR-3 = "":U.
            define variable v-ii1 as integer no-undo.

            EMPTY TEMP-TABLE tt-gds-list.
            v-text-gds = "" .
            for each gds-list no-lock, first ub.goods-attr
              where ub.goods-attr.attr-code  = {&attr-oper-serv-id} 
              and ub.goods-attr.gds-code  = gds-list.gds-code
              NO-LOCK:
              ASSIGN
                v-text-gds = v-text-gds + {&new-line} + gds-list.gds-name.
              .
              CREATE tt-gds-list.
              ASSIGN
                tt-gds-list.artic     = gds-list.artic
                tt-gds-list.gds-code  = gds-list.gds-code
                tt-gds-list.gds-name  = gds-list.gds-name
                tt-gds-list.prod-code = gds-list.prod-code
                tt-gds-list.prod-type = gds-list.prod-type
                .
            END.
            ASSIGN
              v-text-gds = TRIM(v-text-gds, {&new-line})
              EDITOR-3   = v-text-gds
              .
          END.
          else do:
            assign
            RADIO-SET-3 = 1 .
            DISPLAY RADIO-SET-3 WITH FRAME Dialog-Frame.         
          end.  
        END.

      /*Все*/
      WHEN 1 THEN 
        DO:
          EDITOR-3 = "Все":U.
          EMPTY TEMP-TABLE tt-gds-list.
          FOR EACH ub.goods-attr
            where ub.goods-attr.attr-code  = {&attr-oper-serv-id} no-lock,
            each ub.goods where ub.goods-attr.gds-code  = ub.goods.gds-code
            NO-LOCK
            :
            CREATE tt-gds-list.
            ASSIGN
              tt-gds-list.artic     = ub.goods.artic
              tt-gds-list.gds-code  = ub.goods.gds-code
              tt-gds-list.gds-name  = ub.goods.gds-name
              tt-gds-list.prod-code = ub.goods.prod-code
              tt-gds-list.prod-type = ub.goods.prod-type
              .
            ASSIGN
              v-text-gds = v-text-gds + {&new-line} + ub.goods.gds-name
              .
          END.
        END.
      OTHERWISE 
      DO:
      END.
    END case.
    DISPLAY
      EDITOR-3
      WITH FRAME Dialog-Frame.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
  THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

{ gbl/getcntxt.i get }

  
if p-mode = 'shd':U then 
do:
  assign
    frame {&frame-name} :title = frame {&frame-name} :title +
                        substitute(". &1: БД &2, Задача номер &3"
                        , p-task-type
                        , p-db-num-char
                        , p-task-num )
    .
end.
run init-param-values in this-procedure ( input p-task-type
  , input p-db-num-char
  , input p-task-num
  /*                                          , OUTPUT v-dir-name*/
  ) .

RUN enable_UI.

WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE attach-attr-to-schedule-line Dialog-Frame 
PROCEDURE attach-attr-to-schedule-line :
/*------------------------------------------------------------------------------
            Purpose:
            Parameters:  <none>
            Notes:
          ------------------------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-param-list AS CHARACTER NO-UNDO.
  define input  parameter p-obj-list as character no-undo .
  define input  parameter p-oss-list as character no-undo .
  define input  parameter p-gds-list as character no-undo .
  define buffer buf_schedule      for schedule.
  define buffer buf_schedule-attr for schedule-attr.
  define buffer lock-batchprocess for ub.batchprocess.

  CASE p-mode:
    when 'shd':U then 
      do:
        /*данная конкретная задача может быть ТОЛЬКО ОДНА в одной БД - отследим*/
        /*заблокируем*/
        run gbl/lock-prc.p
          (input {&lock-prc-schd-free}
          ,input 'help-road':U
          ,input 0
          ,input 0
          ,input '':U
          ,input ""
          ,input ""
          ,input (
          "выгрузка реализации банковских продуктов"
          )
          ,input yes
          ,buffer lock-batchprocess
          ) no-error .

        FIND FIRST buf_schedule-attr NO-LOCK WHERE
          buf_schedule-attr.task-type   = p-task-type
          and buf_schedule-attr.cre-db-num = INTEGER(p-db-num-char)
          and buf_schedule-attr.attr-code = ({&attr-schd-free-id} + {&delim-par} + 'help-road') NO-ERROR.
        IF AVAILABLE  buf_schedule-attr
          AND buf_schedule-attr.task-num <> p-task-num
          AND buf_schedule-attr.task-num <> - 1
          and p-task-num <> - 1
          THEN 
        DO:
          MESSAGE
            substitute("Уже есть расписание выгрузки реализации банковских продуктов для БД &1&2" +
            "номер расписания &3"
            ,buf_schedule-attr.cre-db-num
            ,{&NEW-LINE}
            ,buf_schedule-attr.task-num)
            VIEW-AS ALERT-BOX ERROR.
          UNDO, RETURN ERROR.
        END.
        find first buf_schedule no-lock
          where buf_schedule.task-type   = p-task-type
          and buf_schedule.cre-db-num  = INTEGER(p-db-num-char)
          and buf_schedule.task-num    = p-task-num
          no-error.
        if not available buf_schedule
          and (  p-task-type   <> {&btpr-type-autofree}
          or p-db-num-char <> p-db-num-char
          or p-task-num    <> -1 )
          then 
        do:
          message
            vss-workfile vss-revision vss-description
            skip 
            "Не найдена строка расписания."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            view-as alert-box error.
          undo, return error .
        end.

        run schedule-attr-write in this-procedure (
          input INTEGER(p-db-num-char)
          , input p-task-type
          , input p-task-num
          , input {&attr-schedule-param-list-h}
          , input p-param-list
          ).
        run schedule-attr-write in this-procedure (
          input INTEGER(p-db-num-char)
          , input p-task-type
          , input p-task-num
          , input {&attr-schedule-obj-list-h}
          , input p-obj-list
          ).
        run schedule-attr-write in this-procedure (
          input INTEGER(p-db-num-char)
          , input p-task-type
          , input p-task-num
          , input {&attr-schedule-oss-list-h}
          , input p-oss-list
          ).
        run schedule-attr-write in this-procedure (
          input INTEGER(p-db-num-char)
          , input p-task-type
          , input p-task-num
          , input {&attr-schedule-gds-list-h}
          , input p-gds-list
          ).          
      end.
    when 'run':U then 
      do:
        p-params = p-param-list.
      end.
  END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-host-list Dialog-Frame 
PROCEDURE check-host-list :
/* -----------------------------------------------------------
            Purpose:
            Parameters:  <none>
            Notes:
          -------------------------------------------------------------*/
  define input-output parameter pHost-code-list as character no-undo.

  define variable iCount        as integer   no-undo.
  define variable cTemp         as character no-undo.
  define variable iTempHostCode as integer   no-undo.
  define variable cNewHostList  as character no-undo.
  define variable lOk           as logical   no-undo.

  do iCount = 1 to num-entries( pHost-code-list ):
    cTemp = entry( iCount, pHost-code-list ).
    assign
      iTempHostCode = integer( cTemp ) no-error
      .
    run validate-host( iTempHostCode, no, no, output lOk ).
    if lOk and lookup( string( iTempHostCode ), cNewHostList ) = 0
      then 
    do:
      assign
        cNewHostList = cNewHostList + ',' + string( iTempHostCode )
        .
    end.
  end.
  pHost-code-list = trim( cNewHostList, ',' ).

  return.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE convert Dialog-Frame 
PROCEDURE convert :
/*------------------------------------------------------------------------------
            Purpose:
            Parameters:  <none>
            Notes:
          ------------------------------------------------------------------------------*/
  define input-output parameter v-rid-list as character no-undo.

  define variable v-list as character no-undo .
  define variable v-ind  as integer   no-undo .

  define buffer buf_sysconf for ub.sysconf.

  do
    on error undo, return error return-value
    :
    do v-ind = 1 to num-entries(v-rid-list)
      :
      find first buf_sysconf no-lock
        where recid(buf_sysconf) = integer(entry(v-ind, v-rid-list))
        no-error .
      if available buf_sysconf
        then 
      do:
        assign
          v-list = v-list
                  + (if v-list = '':U
                    then '':U
                    else {&comma-char}
                    )
                  + string(buf_sysconf.host-code)
          .
      end.
    end.
    assign
      v-rid-list = v-list
      .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  DISPLAY num-days EDITOR-1 RADIO-SET-1 EDITOR-2 RADIO-SET-2 EDITOR-3 
          RADIO-SET-3 v-folder v-file 
      WITH FRAME Dialog-Frame.
  ENABLE RECT-1 RECT-8 RECT-2 RECT-3 b-exit b-quit num-days EDITOR-1 
         RADIO-SET-1 EDITOR-2 RADIO-SET-2 EDITOR-3 RADIO-SET-3 v-folder b-dir 
         v-file 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-param-values Dialog-Frame 
PROCEDURE init-param-values :
/*------------------------------------------------------------------------------
            Purpose:
            Parameters:  <none>
            Notes:
          ------------------------------------------------------------------------------*/
  do
    on error undo, return error
    :
    define input parameter p-task-type              as character    no-undo.
    define input parameter p-db-num-char            as character    no-undo.
    define input parameter p-task-num               as integer      no-undo.
    /*define output parameter p-dir                   as character    no-undo.*/
  
    define variable v-param-list as character no-undo.
    define variable v-param-type as character no-undo.
    define variable v-obj-list   as character no-undo .
    define variable v-gds-list   as character no-undo .
    define variable v-oss-list   as character no-undo .
    define variable ii           as integer   no-undo .
    define variable v-entry-1    as character no-undo .
    define variable v-entry-2    as character no-undo .
    define variable v-entry-3    as character no-undo .
    define variable v-task-num   as integer   no-undo .
    define variable v-ii1        as integer   no-undo.
    define variable v-text       as character no-undo.
    define variable v-ii2        as integer   no-undo.
  
    define buffer buf_tt-obj        for tt-obj.
    define buffer buf_tt-oss-ref    for tt-oss-ref.
    define buffer buf_tt-gds-list   for tt-gds-list.
  
    define buffer buf_schedule      for ub.schedule.
    define buffer buf_schedule-attr for ub.schedule-attr.
    
    DO WITH FRAME Dialog-Frame:
      CASE p-mode:
        when 'shd':U then 
          do:
  
            if p-task-num > 0
              then 
            do:
              v-task-num = p-task-num.
            end.
            else 
            do:
              for each buf_schedule
                where buf_schedule.task-type     = p-task-type
                AND buf_schedule.cre-db-num    = INTEGER(p-db-num-char)
                no-lock
                ,
                first buf_schedule-attr
                where buf_schedule-attr.task-type   = p-task-type
                AND buf_schedule-attr.cre-db-num  = INTEGER(p-db-num-char)
                AND buf_schedule-attr.task-num    = buf_schedule.task-num
                AND buf_schedule-attr.attr-code   = ({&attr-schd-free-id} + {&delim-par} + 'help-road')
                no-lock
                :
                ASSIGN
                  v-task-num = buf_schedule.task-num
                  .
                leave .
              end.
            end.
            if v-task-num > 0
              then 
            do:
              run schedule-attr-value in this-procedure  ( input p-db-num-char
                , input p-task-type
                , input v-task-num
                , input {&attr-schedule-param-list-h}
                , output v-param-list
                , output v-param-type
                ) .
              run schedule-attr-value in this-procedure  ( input p-db-num-char
                , input p-task-type
                , input v-task-num
                , input {&attr-schedule-obj-list-h}
                , output v-obj-list
                , output v-param-type
                ) .
              run schedule-attr-value in this-procedure  ( input p-db-num-char
                , input p-task-type
                , input v-task-num
                , input {&attr-schedule-oss-list-h}
                , output v-oss-list
                , output v-param-type
                ) .
              run schedule-attr-value in this-procedure  ( input p-db-num-char
                , input p-task-type
                , input v-task-num
                , input {&attr-schedule-gds-list-h}
                , output v-gds-list
                , output v-param-type
                ) .                                                                                                          
            end.
            v-ii2 = num-entries( v-param-list, {&delim-par} ).
            if v-ii2 < 7 THEN 
            do:
              do v-ii1 = v-ii2 to 6:
                v-param-list = v-param-list
                  + '':U
                  + {&delim-par}.
              end.
            end.
              
            ASSIGN
              v-folder    = ENTRY(1, v-param-list, {&delim-par})
              v-file      = ENTRY(2, v-param-list, {&delim-par})
              RADIO-SET-1 = INTEGER( ENTRY(3, v-param-list, {&delim-par}) )
              RADIO-SET-2 = INTEGER( ENTRY(4, v-param-list, {&delim-par}) )
              RADIO-SET-3 = INTEGER( ENTRY(5, v-param-list, {&delim-par}) )
              num-days    = INTEGER( ENTRY(6, v-param-list, {&delim-par}) )
              .
            if RADIO-SET-1 = 0 then RADIO-SET-1 = 2 .
            if RADIO-SET-2 = 0 then RADIO-SET-2 = 1 .
            if RADIO-SET-3 = 0 then RADIO-SET-3 = 1 .
            DISPLAY
              v-folder
              v-file
              RADIO-SET-1
              RADIO-SET-2
              RADIO-SET-3
              num-days
              .
  
            EMPTY TEMP-TABLE buf_tt-obj.
            IF v-obj-list <> "":U
              and RADIO-SET-1 = 3
              THEN
            do ii = 1 to num-entries(v-obj-list, {&delim-par})
              on error undo, next
              :
              assign
                v-entry-1 = entry(ii, v-obj-list, {&delim-par})
                .
              FIND FIRST ub.clients
                WHERE ub.clients.obj-type = ENTRY(1, v-entry-1, {&comma-char})
                AND ub.clients.obj-code = INTEGER(ENTRY(2, v-entry-1, {&comma-char}))
                NO-LOCK
                NO-ERROR
                .
              IF AVAILABLE ub.clients
                THEN 
              DO:
                create tt-obj.
                ASSIGN
                  tt-obj.obj-code  = ub.clients.obj-code
                  tt-obj.obj-type  = ub.clients.obj-type
                  tt-obj.obj-name  = ub.clients.obj-name
                  tt-obj.host-code = ub.clients.host-code
                  v-text           = v-text + {&new-line} + ub.clients.obj-name
                  .
              END.
              ASSIGN
                v-text   = TRIM(v-text, {&new-line})
                EDITOR-1 = v-text
                .
            end.
            ELSE 
            DO:
              if RADIO-SET-1 = 4 then 
              do:
                EDITOR-1 = "Все":U.
                FOR EACH ub.clients
                  WHERE ub.clients.obj-type = {&shop}
                  NO-LOCK
                  :
                  CREATE tt-obj.
                  ASSIGN
                    tt-obj.obj-code  = ub.clients.obj-code
                    tt-obj.obj-type  = ub.clients.obj-type
                    tt-obj.obj-name  = ub.clients.obj-name
                    tt-obj.host-code = ub.clients.host-code
                    .
                END.
              end.
              else 
              do:
                apply "VALUE-CHANGED" TO RADIO-SET-1.
              end.
            END.
            DISPLAY
              EDITOR-1
              WITH FRAME Dialog-Frame.
        
            EMPTY TEMP-TABLE buf_tt-oss-ref.
            IF v-oss-list <> "":U
              and RADIO-SET-2 = 2
              THEN
            do ii = 1 to num-entries(v-oss-list, {&delim-par})
              on error undo, next
              :
              assign
                v-entry-2 = entry(ii, v-oss-list, {&delim-par})
                .
              Find first ub.OperServ
                WHERE ub.OperServ.id = INTEGER(ENTRY(1, v-entry-2, {&comma-char}))
                NO-LOCK no-error .
              if available (ub.OperServ) then 
              do:              
                CREATE tt-oss-ref.
                buffer-copy ub.OperServ to tt-oss-ref .
                  v-text-oss                   = v-text-oss + {&new-line} + ub.OperServ.ext-code
                  .
              END.
              ASSIGN
                v-text-oss = TRIM(v-text-oss, {&new-line})
                EDITOR-2   = v-text-oss
                .
            end.
            ELSE 
            DO:
              if RADIO-SET-2 = 1 then 
              do:
                EDITOR-2 = "Все":U.
                FOR EACH ub.OperServ
                  NO-LOCK
                  :
                  if available (ub.OperServ) then 
                  do:              
                    CREATE tt-oss-ref.
                    buffer-copy ub.OperServ to tt-oss-ref .
                  END.
                end.
              END.
            end.
            DISPLAY
              EDITOR-2
              WITH FRAME Dialog-Frame.
          
          
            EMPTY TEMP-TABLE buf_tt-gds-list.
            IF v-gds-list <> "":U
              and RADIO-SET-3 = 2
              THEN
            do ii = 1 to num-entries(v-gds-list, {&delim-par})
              on error undo, next
              :
              assign
                v-entry-3 = entry(ii, v-gds-list, {&delim-par})
                .
              find first ub.goods-attr no-lock
                where ub.goods-attr.attr-code  = {&attr-oper-serv-id} 
                and ub.goods-attr.gds-code = INTEGER(ENTRY(1, v-entry-3, {&comma-char})) 
                no-error . 
              if available (ub.goods-attr) then 
              do:
                find first ub.goods no-lock where ub.goods-attr.gds-code = ub.goods.gds-code no-error .
                if available (ub.goods) then 
                do:
                  CREATE tt-gds-list.
                  ASSIGN
                    tt-gds-list.artic     = ub.goods.artic
                    tt-gds-list.gds-code  = ub.goods.gds-code
                    tt-gds-list.gds-name  = ub.goods.gds-name
                    tt-gds-list.prod-code = ub.goods.prod-code
                    tt-gds-list.prod-type = ub.goods.prod-type
                    v-text-gds            = v-text-gds + {&new-line} + ub.goods.gds-name
                    .
                end.
              end.
              ASSIGN
                v-text-gds = TRIM(v-text-gds, {&new-line})
                EDITOR-3   = v-text-gds
                .
            end.
            ELSE 
            DO:
              if RADIO-SET-3 = 1 then 
              do:
                EDITOR-3 = "Все":U.
                for each ub.goods-attr no-lock
                  where ub.goods-attr.attr-code  = {&attr-oper-serv-id},
                  each ub.goods no-lock where ub.goods.gds-code = ub.goods-attr.gds-code
                  :
                  CREATE tt-gds-list.
                  ASSIGN
                    tt-gds-list.artic     = ub.goods.artic
                    tt-gds-list.gds-code  = ub.goods.gds-code
                    tt-gds-list.gds-name  = ub.goods.gds-name
                    tt-gds-list.prod-code = ub.goods.prod-code
                    tt-gds-list.prod-type = ub.goods.prod-type
                    .
                end.
              END.
            end.
            
            DISPLAY
              EDITOR-3
              WITH FRAME Dialog-Frame.          
          END.
        WHEN 'run'
        THEN 
          DO:
            v-param-list = '':U
              + {&delim-par}
              + '':U
              + {&delim-par}
              + '':U
              + {&delim-par}
              + '':U
              + {&delim-par}
              + '':U
              + {&delim-par}.
          END.
  
      END CASE.
    END. /*DO WITH FRAME Dialog-Frame*/ 
  END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
/*------------------------------------------------------------------------------
            Purpose:
            Parameters:  <none>
            Notes:
          ------------------------------------------------------------------------------*/
  DEFINE VARIABLE glog             AS LOGICAL   NO-UNDO.
  DEFINE VARIABLE v-param-list     AS CHARACTER NO-UNDO.
  define variable v-obj-list       as character no-undo .
  define variable v-list           as character no-undo .
  define variable v-oss-list       as character no-undo .
  define variable v-gds-list       as character no-undo .
  define variable ii               as integer   no-undo .
  define variable v-exists         as logical   no-undo .
  define variable v-date-file-name as character no-undo.
  define variable v-time-file      as char      no-undo.
  
  define buffer buf_tt-obj      for tt-obj .
  define buffer buf_tt-oss-ref  for tt-oss-ref .
  define buffer buf_tt-gds-list for tt-gds-list .
  define variable v-file-name as character no-undo .

  ASSIGN
    FRAME {&frame-name}
    RADIO-SET-1
    RADIO-SET-2
    RADIO-SET-3
    EDITOR-1
    EDITOR-2
    EDITOR-3
    v-folder
    v-file
    num-days
    .
  if num-days < 0 then 
  do:
    message
      "Кол-во дней задан неверно. "
      skip "Задайте интервал правильно или отмените экспорт."
      view-as alert-box information.
    apply "entry" to num-days.
    undo, return no-apply.
  end.    
  if not can-find( first buf_tt-obj ) then 
  do:
    message
      "Не заданы объекты для выгрузки"
      view-as alert-box error .
    return error.
  end.
  v-obj-list = ''.

  for each buf_tt-obj :
    assign
      v-obj-list = v-obj-list
                 + buf_tt-obj.obj-type + {&comma-char}
                 + string(buf_tt-obj.obj-code) + {&delim-par}
      .
  end.
  if not can-find( first buf_tt-oss-ref ) then
  do:
    message
      "Не заданы платежные агенты/операторы для выгрузки"
      view-as alert-box error .
    return error.
  end.
  v-oss-list = ''.

  for each buf_tt-oss-ref :
    assign
      v-oss-list = v-oss-list + string (buf_tt-oss-ref.id) + {&delim-par}
      .
  end.

  if not can-find( first buf_tt-gds-list ) then
  do:
    message
      "Не заданы товары платежного агента/оператора для выгрузки"
      view-as alert-box error .
    return error.
  end.
  v-gds-list = ''.

  for each buf_tt-gds-list :
    assign
      v-gds-list = v-gds-list
                 + string (buf_tt-gds-list.gds-code)  + {&delim-par}
      .
  end.
   
  if v-file = "" then 
  do:
    assign
      v-time-file      = replace(  string(time,"HH:MM:SS"),  ":",  ""  )
      v-today          = today
      v-date-file-name = STRING(YEAR(v-today), "9999") +  STRING(DAY(v-today), "99") + STRING(MONTH(v-today), "99")
      v-file           = substitute( "rep_PA_&1_&2"
                                , v-date-file-name, v-time-file )
      .
  end.
  
  ASSIGN
    v-obj-list = TRIM(v-obj-list, {&delim-par}).
  v-oss-list = TRIM(v-oss-list, {&delim-par}).
  v-gds-list = TRIM(v-gds-list, {&delim-par}).
  
  v-param-list = v-folder + {&delim-par} +
    v-file   + {&delim-par} +
    STRING( RADIO-SET-1 ) + {&delim-par} +
    STRING( RADIO-SET-2 ) + {&delim-par} +
    STRING( RADIO-SET-3 ) + {&delim-par} +
    string(if num-days <> ? then string(num-days) else "") + {&delim-par}
    .
    
  IF p-mode = 'shd' THEN 
  DO:
    run attach-attr-to-schedule-line in this-procedure ( INPUT v-param-list
      , INPUT v-obj-list
      , input v-oss-list
      , input v-gds-list
      ) .
  END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

