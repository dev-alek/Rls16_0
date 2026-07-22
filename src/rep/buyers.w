&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v7r11 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME DLGOKCAN
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS DLGOKCAN
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет по покупателям товаров (выкуп)

Автор: Демин Алексей Сергеевич
Дата создания: 04/12/06
Author: Alexey Demin
Creation date: 04/12/06

 Author: Черных В.Г. Created: 12/01/96 -  5:03 pm

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .

define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Отчет по покупателям товаров (выкуп)" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ ref/cgrplbfn.i }
{ gbl/getcntxt.i def }

/* Local Variable Definitions ---                                       */

define variable     buygrp_recids  as      char    no-undo.
/*
define variable     buy_recids      as      char    no-undo.
*/
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

/*  DEFINE work-table obj-data*/
/*    field obj-type      like clients.obj-type*/
/*    field obj-code      like clients.obj-code*/
/*  .*/

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

/*  define temp-table Temp-date no-undo  /* для дат на объектах */*/
/*    field cur-date1  as date*/
/*    field cur-date2  as date*/
/*    field fo-1       as decimal*/
/*    field fo-2       as decimal*/
/*  .*/

DEFINE temp-table buy-data-dt no-undo
field obj-type      like clients.obj-type
field obj-code      like clients.obj-code
field cur-date1      as date
field cur-date2      as date
/*    field fo-1          as decimal*/
/*    field fo-2          as decimal*/
field Sum-zak       as decimal
field Sum-prod      as decimal
field Sum-skid      as decimal
field EffValue      as decimal
index pi IS PRIMARY obj-type obj-code cur-date1 cur-date2
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME DLGOKCAN

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_Print Btn_OK B-Help RECT-14 RECT-18 ~
TimePeriod SelectBuyers Sort_Type WhatShow
&Scoped-Define DISPLAYED-OBJECTS TimePeriod SelectBuyers Sort_Type WhatShow

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
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


/* ************************  Frame Definitions  *********************** */

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


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX DLGOKCAN
   UNDERLINE                                                            */
ASSIGN
       FRAME DLGOKCAN:SCROLLABLE       = FALSE
       FRAME DLGOKCAN:PRIVATE-DATA     =
                "DLGCLOSE".

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME B-Help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-Help DLGOKCAN
ON CHOOSE OF B-Help IN FRAME DLGOKCAN /* Помощь */
OR HELP OF FRAME {&FRAME-NAME}
DO:
  /* Call Help Function (or a simple message). */
  MESSAGE {&TmpHelpMess} VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK DLGOKCAN
ON CHOOSE OF Btn_OK IN FRAME DLGOKCAN /* Отмена */
DO:
    return "NO" .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_Print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Print DLGOKCAN
ON CHOOSE OF Btn_Print IN FRAME DLGOKCAN /* Ввод  */
DO:
  if FineDate then do:
    if session:set-wait-state("COMPILER") then.

    run prn-lib-open-stream  in this-procedure (
                                                input parParentProc
                                                ,input {&CS_PS}
                                                ,input yes /*p-is-stream*/
                                                ,input no /*p-append*/
                                                ).
    PUT stream PrnLibStream SPACE(20) string ( "Продажи " + " c  " + string ( StartPoint ) + "  по  " + string ( EndPoint ) +
            ( if buygrp_recids <> ? AND buygrp_recids <> "" then "  по группам организаций ( регионам )" else "  по организациям" ) + "." ) format "x(100)" SKIP(1).
    PUT stream PrnLibStream SPACE(20) string( "Сортировка : " + lc( Sort_Type:screen-value ) + "." ) format "x(100)" SKIP.

    RUN main_proc .

    PUT stream PrnLibStream " " SKIP.
    output stream PrnLibStream CLOSE.
    FOR EACH buy-data :     delete buy-data.     END.
    FOR EACH buy-data-dt :  delete buy-data-dt.  END.
    /*
    assign
      g#rep-tblname = ""
      g#rep-tblrid = -109
      g#rep-updflds = "Отчет по покупателям|" + string( StartPoint ) + ".." + string( EndPoint ) + "|" + lc( Sort_Type:screen-value )
    .
    */
    run prn-lib-prn-file in this-procedure (
                                              input parParentProc
                                              ,input 0
                                              ).

    if session:set-wait-state("") then.
    APPLY "ENTRY" TO Btn_OK .
  end.
  else message "Вы забыли указать требуемый период времени." view-as alert-box ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME SelectBuyers
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SelectBuyers DLGOKCAN
ON VALUE-CHANGED OF SelectBuyers IN FRAME DLGOKCAN
DO:
  assign SelectBuyers .
  if SelectBuyers = {&group} then do:
    run ref/cli-grps.w ( input parparentproc
                        ,input "b-sel"
                        ,input-output buygrp_recids ) .
    if buygrp_recids = "" then  do:
      assign SelectBuyers = {&all} .
      DISPLAY SelectBuyers with FRAME DLGOKCAN .
    end.
  end.
  if SelectBuyers = {&all} then buygrp_recids = "" .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME TimePeriod
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL TimePeriod DLGOKCAN
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
                            /* далее - проверка года : следующий ли он ? */
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

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK DLGOKCAN


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
        ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

  assign
  SelectBuyers:radio-buttons =  {&all} + {&comma-char} + {&all} + {&comma-char} +
                                {&group} + {&comma-char} + {&group}
  WhatShow:radio-buttons =      {&all} + {&comma-char} + {&all} + {&comma-char} +
                                "Только продажные" + {&comma-char} + "Только продажные" + {&comma-char} +
                                "Только учетные"  + {&comma-char} +  "Только учетные"
  .
  RUN enable_UI.
  RUN StartProc .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_document-reports-sale_print':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    false
    Sale-LogRes
  }
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_document-reports-cost_print':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    false
    Cost-LogRes
  }

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

/*  define buffer buf_db      for db .*/
/*  define buffer buf_clients for clients .*/
/*  define buffer buf_store   for store .*/
/*  define buffer buf_shop    for shop .*/

/*  for each buf_db no-lock,*/
/*      each buf_clients no-lock*/
/*    where buf_clients.db-num = buf_db.db-num*/
/*    :*/
/*    if buf_clients.obj-type = {&stock} then do:*/
/*      find first buf_store no-lock*/
/*        where buf_store.obj-code = buf_clients.obj-code*/
/*      no-error .*/
/*      if available buf_store and buf_store.host-code = g#host-code then do:*/
/*        create obj-data .*/
/*        assign*/
/*          obj-data.obj-type = {&stock}*/
/*          obj-data.obj-code = buf_store.obj-code*/
/*        .*/
/*      end.*/
/*    end.*/
/*    else if buf_clients.obj-type = {&shop} then do:*/
/*      find first buf_shop no-lock*/
/*        where buf_shop.obj-code = buf_clients.obj-code*/
/*      no-error .*/
/*      if available buf_shop and buf_shop.host-code = g#host-code then do:*/
/*        create obj-data .*/
/*        assign*/
/*          obj-data.obj-type = {&shop}*/
/*          obj-data.obj-code = buf_shop.obj-code*/
/*        .*/
/*      end.*/
/*    end.*/
/*  end.*/

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI DLGOKCAN  _DEFAULT-DISABLE
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
  HIDE FRAME DLGOKCAN.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI DLGOKCAN  _DEFAULT-ENABLE
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
  DISPLAY TimePeriod SelectBuyers Sort_Type WhatShow
      WITH FRAME DLGOKCAN.
  ENABLE Btn_Print Btn_OK B-Help RECT-14 RECT-18 TimePeriod SelectBuyers
         Sort_Type WhatShow
      WITH FRAME DLGOKCAN.
  {&OPEN-BROWSERS-IN-QUERY-DLGOKCAN}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE main_proc DLGOKCAN
PROCEDURE main_proc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable grp-path like clients.grp-name no-undo.

define variable Line                as      char     no-undo.
define variable CliRegName   as      char    no-undo.  /* Clients or Region (cli-grp) Name */
define variable CliRegCode   as      char    no-undo.  /* Clients or Region (cli-grp) Code */
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

/*define buffer buf_stk-supp-tot for stk-supp-tot .*/
define buffer buf_trn-doc for trn-doc .

define variable sum-zak  as decimal   no-undo .
define variable sum-prod as decimal   no-undo .
define variable sum-skid as decimal   no-undo .
define variable Counter1 as integer   no-undo .

/*  define variable    v-fact-order-start     as decimal   no-undo .*/
/*  define variable    v-fact-order-end       as decimal   no-undo .*/
/*  run day-begin-fact-order in this-procedure ( input StartPoint, output v-fact-order-start ). /*Поиск нач fact-order*/*/
/*  run day-begin-fact-order in this-procedure ( input ( EndPoint + 1 ),   output v-fact-order-end ). /*Поиск посл fact-order*/*/

  &SCOPED-DEFINE     Firm-SaleRptWidth    125

  { rep/repfrm.i def   } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 10 } /* Показать окно информации о текущем процессе */

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
/*    cli-month.out0-{&rb} column-label "Сумма продаж!в учетных!ценах" format ">>>>>>>>>>9.99"*/
/*    cli-month.out-{&rb} column-label "Сумма продаж!в ценах!реализации" format ">>>>>>>>>>>9.99"*/
    sym5       column-label ":!:!:" format "x(1)"
    sum-skid   column-label "Сумма скидок! ! " format "->>>>>>>9.99"
/*    cli-month.discnt-{&rb} column-label "Сумма скидок! ! " format "->>>>>>>9.99"*/
    sym6       column-label ":!:!:" format "x(1)"
    EffValue   column-label "Эффективность! ! "  format "->>>>>>>>9.99"
    sym7       column-label ":!:!:" format "x(1)"
    HEADER
        string("Дата печати : ") AT 5 format "x(15)" TODAY format "99.99.9999" string(", ") format "X(2)"
        string(TIME, "HH:MM")
        space(5) ( if v-rb-is-base = yes then "Суммы в базовой валюте" else "Суммы в {&abbr_rublyah}" ) format "X(22)"
        string( "Страница " + string (PAGE-NUMBER( PrnLibStream ) , ">>9") ) AT 114 format "X(15)" SKIP
        Line format "x({&Firm-SaleRptWidth})" AT 1
  with width {&DOS_CW} down stream-io use-text .

    { gbl/rbisbase.i
        v-rb-is-base
    }
  TOT-DebBaseSum = 0 .
  if ( year( StartPoint ) = year( EndPoint ) ) AND ( month( StartPoint ) = month( EndPoint ) ) then OneMonth = TRUE .
  else  OneMonth = FALSE .

  if SelectBuyers:screen-value in FRAME {&FRAME-NAME} = {&all} then do:
    for each cli-buy where cli-buy.obj-type = {&cmp} no-lock :
      { rep/buy-data.i }
    end.
    for each cli-buy where cli-buy.obj-type = {&prs} no-lock :
      { rep/buy-data.i }
    end.
  end.
  else do:
    if buygrp_recids <> "" then do:  /* По группам организаций-покупателей */
      find first cli-grp NO-LOCK WHERE recid( cli-grp ) = integer( buygrp_recids ) .
      RUN cli-grplib-get-full-name in this-procedure( cli-grp.node-code, output grp-path ).

      for each cli-buy no-lock
        where cli-buy.obj-type = {&cmp}
          and cli-buy.grp-name begins grp-path
        :
        { rep/buy-data.i }
      end.
      for each cli-buy no-lock
        where cli-buy.obj-type = {&prs}
          and cli-buy.grp-name begins grp-path
        :
        { rep/buy-data.i }
      end.
    end.
    else MESSAGE "Ошибка: эта ветвь алгоритма не должна была сработать (buyers.w)." VIEW-AS ALERT-BOX ERROR .
  end.

  Line = fill ( "-", {&DOS_CW_2} ) .

  FORM HEADER
    Line format "X({&Firm-SaleRptWidth})" SKIP
    "Продолжение - на следующей странице" AT 30 SKIP
    with FRAME FirmBottomFrame width {&DOS_CW} PAGE-BOTTOM NO-LABELS no-box.
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
        buy-data.EffValue    = buy-data.Sum-prod    - buy-data.Sum-zak   /* - buy-data.sum-skid    */
        buy-data-dt.EffValue = buy-data-dt.Sum-prod - buy-data-dt.Sum-zak /*- buy-data-dt.Sum-skid */
      .
    end.
  end.

  CASE Sort_Type:screen-value in FRAME {&FRAME-NAME} :
    when "По алфавиту" then do:
      &SCOPED-DEFINE      by-if    Name
      { rep/buy-rep.i }
      &UNDEFINE   by-if
    end.
    when "По возрастанию учетной суммы" then do:
      &SCOPED-DEFINE      by-if    Sum-zak
      { rep/buy-rep.i }
      &UNDEFINE   by-if
    end.
    when "По возрастанию суммы продаж" then do:
      &SCOPED-DEFINE      by-if    Sum-prod
      { rep/buy-rep.i }
      &UNDEFINE   by-if
    end.
    when "По возрастанию эффективности" then  do:
      &SCOPED-DEFINE      by-if    EffValue
      { rep/buy-rep.i }
      &UNDEFINE   by-if
    end.
    when "По убыванию учетной суммы" then do:
      &SCOPED-DEFINE      by-if    Sum-zak DESCENDING
      { rep/buy-rep.i }
      &UNDEFINE   by-if
    end.
    when "По убыванию суммы продаж" then do:
      &SCOPED-DEFINE      by-if    Sum-prod DESCENDING
      { rep/buy-rep.i }
      &UNDEFINE   by-if
    end.
    when "По убыванию эффективности" then do:
      &SCOPED-DEFINE      by-if    EffValue DESCENDING
      { rep/buy-rep.i }
      &UNDEFINE   by-if
    end.
  END CASE.

  DOWN stream PrnLibStream 1 with FRAME Firm-SaleRpt .
  PUT stream PrnLibStream Line format "X({&Firm-SaleRptWidth})" SKIP.
  HIDE stream PrnLibStream FRAME FirmBottomFrame .

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE StartProc DLGOKCAN
PROCEDURE StartProc :
{ rep/date-prd.i StartDate}
  APPLY "value-changed" to SelectBuyers in FRAME {&FRAME-NAME} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME