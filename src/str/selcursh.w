&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выбор курса чеков, которые будут входить в продажу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/11/00
Author: Bakhtadze Natalya
Creation date: 02/11/00

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.inkas.obj-type no-undo .
define input parameter p-curr-obj-code like ub.inkas.obj-code no-undo .
define input parameter p-base-code like ub.sysconf.base-code no-undo .
DEFINE INPUT PARAMETER inkas-date like ub.inkas.doc-date.
DEFINE INPUT PARAMETER day-only like ub.shop.day-only.
DEFINE INPUT-OUTPUT PARAMETER cursh like ub.curr-shop.exch-rate.
DEFINE OUTPUT PARAMETER cursh-scale like ub.curr-shop.exch-scale.
DEFINE INPUT-OUTPUT PARAMETER cursh-date1 like ub.curr-shop.exch-date.
DEFINE OUTPUT PARAMETER cursh-date2 like ub.curr-shop.exch-date.
DEFINE INPUT-OUTPUT PARAMETER cursh-time1 like ub.curr-shop.exch-time.
DEFINE OUTPUT PARAMETER cursh-time2 like ub.curr-shop.exch-time.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор курса чеков, которые будут входить в продажу".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
DEFINE BUFFER b-cs for ub.curr-shop.
DEFINE VARIABLE yesterday as logical initial no no-undo.
/*откуда были взяты курсы валют из спула или BO*/
define variable cas-curs as logical no-undo init no.
define variable added as logical init no no-undo.
define variable b-added as logical init no no-undo.
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES curr-shop

/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 curr-shop.exch-rate ~
curr-shop.exch-scale curr-shop.exch-date ~
STRING (curr-shop.exch-time,"HH:MM:SS")
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1
&Scoped-define FIELD-PAIRS-IN-QUERY-BROWSE-1
&Scoped-define OPEN-QUERY-BROWSE-1 OPEN QUERY BROWSE-1 FOR EACH ub.curr-shop ~
      WHERE ub.curr-shop.curr-code = p-base-code ~
 AND ub.curr-shop.obj-type = p-curr-obj-type ~
 AND ub.curr-shop.obj-code = p-curr-obj-code ~
 AND (ub.curr-shop.exch-date = inkas-date OR ~
(yesterday AND ub.curr-shop.exch-date <= inkas-date) ~
     ) NO-LOCK ~
    BY ub.curr-shop.exch-date DESCENDING ~
       BY ub.curr-shop.exch-time DESCENDING.
&Scoped-define TABLES-IN-QUERY-BROWSE-1 curr-shop
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 curr-shop


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-Sel B-quit B-help BROWSE-1

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Другой"
     SIZE 10 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON B-Sel AUTO-GO
     LABEL "Вы&бор "
     SIZE 10 BY 1.13
     BGCOLOR 8 .

DEFINE VARIABLE FILL-cursh AS DECIMAL FORMAT ">>,>>9.9999":U INITIAL 0
     LABEL "Укажите другой курс"
     VIEW-AS FILL-IN
     SIZE 18.88 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1 FOR
      ub.curr-shop SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1 Dialog-Frame _STRUCTURED
  QUERY BROWSE-1 DISPLAY
      ub.curr-shop.exch-rate
      ub.curr-shop.exch-scale
      ub.curr-shop.exch-date FORMAT "99/99/9999"
      STRING (ub.curr-shop.exch-time,"HH:MM:SS") COLUMN-LABEL "Время"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SIZE 40.88 BY 9.67.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-Sel AT ROW 1.21 COL 1.88
     B-quit AT ROW 1.21 COL 12.13
     B-help AT ROW 1.21 COL 35.38
     B-add AT ROW 1.25 COL 22.5
     FILL-cursh AT ROW 2.75 COL 23.13 COLON-ALIGNED
     BROWSE-1 AT ROW 4 COL 3.63
     SPACE(2.86) SKIP(0.86)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Курс базовой валюты"
         DEFAULT-BUTTON B-Sel CANCEL-BUTTON B-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BROWSE-1 FILL-cursh Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-add IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-add:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN FILL-cursh IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _TblList          = "ub.curr-shop"
     _OrdList          = "ub.curr-shop.exch-date|no,ub.curr-shop.exch-time|no"
     _Where[1]         = "curr-shop.curr-code = p-base-code
 AND curr-shop.obj-type = p-curr-obj-type
 AND curr-shop.obj-code = p-curr-obj-code
 AND (curr-shop.exch-date = inkas-date OR
(yesterday AND curr-shop.exch-date <= inkas-date)
     )"
     _FldNameList[1]   = ub.curr-shop.exch-rate
     _FldNameList[2]   = ub.curr-shop.exch-scale
     _FldNameList[3]   > ub.curr-shop.exch-date
"curr-shop.exch-date" ? "99/99/9999" "date" ? ? ? ? ? ? no ?
     _FldNameList[4]   > "_<CALC>"
"STRING (curr-shop.exch-time,""HH:MM:SS"")" "Время" ? ? ? ? ? ? ? ? no ?
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Курс базовой валюты */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Другой */
DO:
  ENABLE FILL-cursh with frame {&frame-name}.
  APPLY "ENTRY" to FILL-cursh.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-Sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-Sel Dialog-Frame
ON CHOOSE OF B-Sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if not added then do:
      if not available ub.curr-shop then return no-apply.
      assign
      cursh = ub.curr-shop.exch-rate
      cursh-scale = ub.curr-shop.exch-scale.
      RUN DIAPAZON.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME FILL-cursh
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-cursh Dialog-Frame
ON LEAVE OF FILL-cursh IN FRAME Dialog-Frame /* Укажите другой курс */
DO:
define variable glog as logical no-undo .
  if NOT b-added then dO:
    message "Чтобы подтвердить выбор указанного курса"
            "нажмите ДА, чтобы отказаться нажмите НЕТ"
            view-as alert-box QUESTION buttons YES-NO update glog.
  end.
  if glog then do:
    APPLY "RETURN" to FILL-CURSH.
  end.
  hide FILL-cursh in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-cursh Dialog-Frame
ON RETURN OF FILL-cursh IN FRAME Dialog-Frame /* Укажите другой курс */
DO:
  define variable found as logical init no no-undo.
  define variable glog as logical no-undo .
  assign
  fill-cursh.
  FOR EACH b-cs WHERE b-cs.curr-code = p-base-code
                  AND b-cs.obj-type = p-curr-obj-type
                  AND b-cs.obj-code = p-curr-obj-code
                  AND (b-cs.exch-date = inkas-date OR
                      (yesterday AND b-cs.exch-date <= inkas-date)
                      )
                  AND b-cs.exch-rate / b-cs.exch-scale = fill-cursh
                  NO-LOCK  BY b-cs.exch-date DESCENDING
                           BY b-cs.exch-time DESCENDING:
       found = yes.
       LEAVE.
  end.
  if not found then do:
      message "Вы уверены, что хотите закачивать в продажу чеки с курсом," skip
              "который не был официальным курсом магазина?" view-as alert-box question
              buttons YEs-NO update glog.
    if glog then do:
        assign
        cursh = fill-cursh
        cursh-scale = 1
        added = yes.
    end.
    else return no-apply.
  end.
  else do:
    assign
    cursh = fill-cursh
    cursh-scale = 1
    added = yes.
    find first ub.curr-shop where recid(ub.curr-shop) = recid(b-cs) No-LOCK NO-ERROR.
  end.
  assign
  b-added = yes.
  APPLY "CHOOSE" TO b-sel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/*найдем параметр - откуда были взяты курсы валюты - из спула или из BO*/

/*найдем параметр - использовать смены на кассе или нет*/
run adm/shattri.p (
    input "get":U
    ,input  p-curr-obj-type
    ,input  p-curr-obj-code
    ,input  {&attr-get-chk}
    ,input  {&attr-get-chk_cas-curs} /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
IF not error-status:error then do:
  cas-curs = v-value-logical.
end.
delete object v-tth.

if cursh > 0 then do:
/*в продаже уже есть чеки и надо определить курс и временной диапазон действия этогот курса
для того чтобы засосать друние чеки*/
FIND LAST curr-shop WHERE curr-shop.obj-type = p-curr-obj-type
                                         and curr-shop.obj-code = p-curr-obj-code
                                         and curr-shop.curr-code = p-base-code
                                         and
                                         ( ( curr-shop.exch-date = cursh-date1 AND
                                         curr-shop.exch-time <= cursh-time1 ) OR
                                         curr-shop.exch-date < cursh-date1 )  NO-LOCK no-error.
        if not avail curr-shop then return error.
        RUN DIAPAZON.
        return.

end.
/*продажа еще пуста*/
/*находим последний курс*/
FIND LAST curr-shop WHERE curr-shop.obj-type = p-curr-obj-type
                                         and curr-shop.obj-code = p-curr-obj-code
                                         and curr-shop.curr-code = p-base-code
                                         and curr-shop.exch-date <= inkas-date NO-LOCK no-error.
if not avail curr-shop then return error.
/*последний курс не сегодняшний*/
IF curr-shop.exch-date < inkas-date then do:
    /*в продажу могут попасть только чеки с датой продажи, значит
    последний несегодняшний курс нас устроит - надо только определить диапазон*/
    if day-only then do:
        assign
        cursh = curr-shop.exch-rate
        cursh-scale = curr-shop.exch-scale.
        RUN DIAPAZON.
        return.
    end.
    /* в продажу попадают все чеки с датой меньше даты отчета о продаже*/
    /*надо дать пользователю возможность выбора */
    assign
    yesterday = yes.
end.
/*имеются курсы на дату = дате отчета о продаже*/
else if NOT cas-curs then do:
    /*постраемя выяснить не единственный ли найденный курс за этот день-
    если да то и выбирать не из чего*/
    FIND FIRST b-cs No-LOCK WHERE
                       b-cs.obj-type = p-curr-obj-type AND
                       b-cs.obj-code = p-curr-obj-code AND
                       b-cs.curr-code = p-base-code AND
                       b-cs.exch-date = inkas-date AND
                       recid(b-cs) <> recid(curr-shop) No-ERROR.
    IF NOT AVAIL b-cs then do:
        assign
        cursh = curr-shop.exch-rate
        cursh-scale = curr-shop.exch-scale.
        RUN DIAPAZON.
        return.
    end.
end.
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  if cas-curs then ENABLE b-add with frame {&frame-name}.
  APPLY "ENTRY" TO BROWSE-1.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE DIAPAZON Dialog-Frame
PROCEDURE DIAPAZON :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE b-cs-recid as recid no-undo.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
   b-cs-recid = ?.
  /*найдем временную область действия выбранного курса*/
  FOR EACH    b-cs NO-LOCK WHERE
                       b-cs.obj-type = p-curr-obj-type AND
                       b-cs.obj-code = p-curr-obj-code AND
                       b-cs.curr-code = p-base-code AND
                       (b-cs.exch-date < ub.curr-shop.exch-date
                       OR
                       (b-cs.exch-date = ub.curr-shop.exch-date AND
                       b-cs.exch-time < ub.curr-shop.exch-time))
                       BY b-cs.exch-date descending BY b-cs.exch-time descending:
        IF  b-cs.exch-rate / b-cs.exch-scale <> cursh / cursh-scale then LEAVE.
        b-cs-recid = recid(b-cs).
    END.
   IF b-cs-recid <> ? then do:
   FIND FIRST b-cs where recid(b-cs) = b-cs-recid No-LOCK NO-ERROR.
   assign
   cursh-date1 = b-cs.exch-date
   cursh-time1 = b-cs.exch-time.
   end.
   else do:
    assign
    cursh-date1 = curr-shop.exch-date
    cursh-time1 = curr-shop.exch-time.
   end.


  FIND FIRST b-cs WHERE
                       b-cs.obj-type = p-curr-obj-type AND
                       b-cs.obj-code = p-curr-obj-code AND
                       b-cs.curr-code = p-base-code AND
                       (b-cs.exch-date > curr-shop.exch-date
                       OR
                       (b-cs.exch-date = curr-shop.exch-date AND
                       b-cs.exch-time > curr-shop.exch-time)) AND
                       b-cs.exch-rate / b-cs.exch-scale <> cursh / cursh-scale AND
                       YEAR(b-cs.exch-date) <> 9999
                       USE-INDEX pi   No-LOCK NO-ERROR.
   IF AVAIL b-cs then
   assign
   cursh-date2 = b-cs.exch-date
   cursh-time2 = b-cs.exch-time.
   else do:
    run cur-time in this-procedure(output v-today, output v-time).
    assign
    cursh-date2 = v-today + 365
    cursh-time2 = v-time.
   end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
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
  ENABLE B-Sel B-quit B-help BROWSE-1
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME