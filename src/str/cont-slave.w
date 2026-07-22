&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
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

Интерфейс подчиненных договоров

Автор: Носко Игорь Александрович
Дата создания: 03/02/2011
Author: Igor Nosko
Creation date: 03/02/2011

*/


/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* VSS  Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "$Интерфейс подчиненных договоров":U.

/* Parameters Definitions ---                                           */
define input  parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input  parameter bttns          as char      no-undo . /* "" список доступных кнопок */
define input  parameter ref-mode       as character no-undo . /* ""  {&add-def}, {&update}, {&lookup}, "history" */
define input  parameter p-host-code    as integer   no-undo . /* фирма */
DEFINE PARAMETER BUFFER buf_M-Contract FOR ub.Contract.
DEFINE OUTPUT PARAMETER v-cError       as CHARACTER NO-UNDO INITIAL "" . /* */

/* Local Variable Definitions ---                                       */
DEFINE VARIABLE v-db-num  AS INTEGER NO-UNDO.
DEFINE VARIABLE v-ret AS LOGICAL NO-UNDO.

/* */ 
{cmp/vssrevis.i}
{cmp/str-glbl.i}
{cmp/showinf.i}
{gbl/userhsts.i}
{cmp/library.i}
{gbl/getcntxt.i def}
{gbl/getcntxt.i GET}
{str/cont-ms.i}
/* */ 
DEFINE BUFFER buf_S-Contract  FOR ub.Contract.  
DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-Classif.
/* */ 
DEFINE VARIABLE iRecId AS RECID NO-UNDO INITIAL ?.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-Slave

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_Ext-Classif buf_S-contract

/* Definitions for BROWSE BR-Slave                                      */
&Scoped-define FIELDS-IN-QUERY-BR-Slave buf_S-Contract.host-code buf_S-Contract.own-name buf_S-Contract.contract-prn-code buf_S-Contract.contract-name buf_S-Contract.contract-date   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-Slave   
&Scoped-define SELF-NAME BR-Slave
&Scoped-define OPEN-QUERY-BR-Slave RUN Open-Query-Br-Slave IN THIS-PROCEDURE.   /* OPEN QUERY {&SELF-NAME}      FOR EACH buf_Ext-Classif WHERE               buf_Ext-Classif.Classif-name = v-S_CONTRACT          AND  buf_Ext-Classif.CharKey_One  = STRING(buf_M-Contract.Host-code) + v-DELIM_CHR_3 +                                              STRING(buf_M-Contract.contract-code)          AND  buf_Ext-classif.db-num       = v-db-num      NO-LOCK, ~
            EACH buf_S-contract WHERE               buf_S-Contract.Host-code     = INTEGER(ENTRY(1, ~
       buf_Ext-classif.charKey_Two, ~
       v-DELIM_CHR_3 ))          AND  buf_S-Contract.Contract-code = INTEGER(ENTRY(2, ~
       buf_Ext-classif.charKey_Two, ~
       v-DELIM_CHR_3 ))      NO-LOCK      INDEXED-REPOSITION. */.
&Scoped-define TABLES-IN-QUERY-BR-Slave buf_Ext-Classif buf_S-contract
&Scoped-define FIRST-TABLE-IN-QUERY-BR-Slave buf_Ext-Classif
&Scoped-define SECOND-TABLE-IN-QUERY-BR-Slave buf_S-contract


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-Slave}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-Quit b-Add b-Lkp b-Del B-print b-hist ~
B-Help b-Copy BR-Slave iSchNumFirm cSchBegNumCont
&Scoped-Define DISPLAYED-OBJECTS iSchNumFirm cSchBegNumCont 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-Add 
     LABEL "&Добавить" 
     SIZE 11.5 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON b-Del 
     LABEL "&Удалить" 
     SIZE 11.5 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON b-Copy
     LABEL "&Копировать"
     SIZE 11.5 BY 1.13
     BGCOLOR 8
     TOOLTIP "Добавить договоры с копированием списка подчиненных фирм" .

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-hist 
     LABEL "Ис&тория" 
     SIZE 3 BY 1.

DEFINE BUTTON b-Lkp 
     LABEL "&Просмотр" 
     SIZE 11.5 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON B-print 
     LABEL "&Печать" 
     SIZE 3 BY 1.

DEFINE BUTTON b-Quit 
     LABEL "&Выход" 
     SIZE 12.5 BY 1.13
     BGCOLOR 8 .

DEFINE VARIABLE cSchBegNumCont AS CHARACTER FORMAT "X(256)":U 
     LABEL "Начало номера договора" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE iSchNumFirm AS INTEGER FORMAT ">>>>>>9":U INITIAL 0 
     LABEL "Номер фирмы" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-Slave FOR 
      buf_Ext-Classif, 
      buf_S-contract SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-Slave
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-Slave Dialog-Frame _FREEFORM
  QUERY BR-Slave DISPLAY
      buf_S-Contract.host-code            COLUMN-LABEL "Номер!фирмы"     FORMAT ">>>>>>9"
 buf_S-Contract.own-name             COLUMN-LABEL "Название фирмы"  FORMAT "x(30)"
 buf_S-Contract.contract-prn-code    COLUMN-LABEL "Номер!договора"  FORMAT "x(15)"
 buf_S-Contract.contract-name        COLUMN-LABEL "Заголовок"       FORMAT "x(30)"
 buf_S-Contract.contract-date        COLUMN-LABEL "Дата!договора"   FORMAT "99/99/9999"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 99 BY 16.5 ROW-HEIGHT-CHARS .75 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-Quit AT ROW 1 COL 1
     b-Add AT ROW 1 COL 30.5
     b-Lkp AT ROW 1 COL 42.0 WIDGET-ID 8
     b-Del AT ROW 1 COL 53.5
     b-Copy AT ROW 1 COL 65
     B-print AT ROW 1 COL 91.5 WIDGET-ID 2
     b-hist AT ROW 1 COL 94.5 WIDGET-ID 4
     B-Help AT ROW 1 COL 97.5 WIDGET-ID 6
     BR-Slave AT ROW 3.25 COL 2 WIDGET-ID 200
     iSchNumFirm AT ROW 20 COL 24 COLON-ALIGNED WIDGET-ID 12
     cSchBegNumCont AT ROW 20 COL 67 COLON-ALIGNED WIDGET-ID 14
     "Поиск:" VIEW-AS TEXT
          SIZE 8 BY .92 AT ROW 20 COL 2 WIDGET-ID 10
          FGCOLOR 4 
     SPACE(91.24) SKIP(0.32)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Подчиненные договоры"
         DEFAULT-BUTTON b-Quit WIDGET-ID 100.


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
/* BROWSE-TAB BR-Slave B-Help Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-Slave
/* Query rebuild information for BROWSE BR-Slave
     _START_FREEFORM
RUN Open-Query-Br-Slave IN THIS-PROCEDURE.


/*
OPEN QUERY {&SELF-NAME}
     FOR EACH buf_Ext-Classif WHERE
              buf_Ext-Classif.Classif-name = v-S_CONTRACT
         AND  buf_Ext-Classif.CharKey_One  = STRING(buf_M-Contract.Host-code) + v-DELIM_CHR_3 +
                                             STRING(buf_M-Contract.contract-code)
         AND  buf_Ext-classif.db-num       = v-db-num
     NO-LOCK,
     EACH buf_S-contract WHERE
              buf_S-Contract.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3 ))
         AND  buf_S-Contract.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3 ))
     NO-LOCK
     INDEXED-REPOSITION.
*/
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-Slave */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON ENTRY OF FRAME Dialog-Frame /* Подчиненные договоры */
DO:
   /* Гасим кнопки добавить и удалить если договор закрыт !!!  */ 
   IF buf_M-contract.status_ = {&close-contr}  THEN DO:
      ASSIGN 
         b-Add:SENSITIVE = FALSE 
         b-Del:SENSITIVE = FALSE 
         b-Copy:SENSITIVE = FALSE
         .
   END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Подчиненные договоры */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-Add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-Add Dialog-Frame
ON CHOOSE OF b-Add IN FRAME Dialog-Frame /* Добавить */
DO:
  {gbl/stdbtn.i}
  DEFINE VARIABLE v-user-id                AS CHARACTER  NO-UNDO. 
  DEFINE VARIABLE v-curr-host-code         AS INTEGER    NO-UNDO. 
  DEFINE VARIABLE v-user-select            AS LOGICAL    NO-UNDO. 
  DEFINE VARIABLE v-select-host-code       AS INTEGER    NO-UNDO. 
  DEFINE VARIABLE v-List-select-host-code  AS CHARACTER  NO-UNDO INITIAL "". 


run gbl/userhsts.w
      (input  parparentproc          /* parparentproc      */
      ,input  THIS-PROCEDURE:HANDLE /* p-callback-handle  */
      ,input  v-cntxt-db-num         /* v-db-num  */               /* p-db-num           */
      ,input  v-cntxt-userid         /* p-user-id          */
      ,input  v-cntxt-host-code-obj  /* v-curr-host-code  */       /* p-curr-host-code   */
      ,input  "b-sel,b-mark"         /* p-bttns            */
      ,output v-user-select          /* p-user-select      */
      ,output v-select-host-code       /* p-select-host-code */
      ,OUTPUT v-List-select-host-code  /* p-List-select-host-code */
      ) .

  IF v-User-Select <> TRUE THEN DO:
     /* Если ничего не выбрали   */  
     RETURN NO-APPLY. 
  END. ELSE DO:
     /* А здесь выбрали запускаем процедуру добавления   */ 
     RUN str/cont-slave-run.p (
         INPUT parParentProc,
         INPUT THIS-PROCEDURE:HANDLE,  /* p-callback-handle  */
         BUFFER buf_M-Contract, 
         BUFFER buf_S-Contract, 
         "add",
         INPUT v-List-select-host-code, 
         OUTPUT v-cError            
         ).  
     IF v-cError <> "" THEN DO:
        MESSAGE 
            PROGRAM-NAME(1) SKIP 
            v-cError SKIP 
            VIEW-AS ALERT-BOX INFO BUTTONS OK.
        RETURN NO-APPLY.         
     END. ELSE DO:
         RUN Open-Query-Br-Slave IN THIS-PROCEDURE. 
         RETURN NO-APPLY.          
     END.
  END. 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-Copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-Copy Dialog-Frame
ON CHOOSE OF b-Copy IN FRAME Dialog-Frame /* Удалить */
DO:
   define variable p-rid-list as character no-undo.
   define variable iTmp       as integer   no-undo initial 0.
   define variable v-List-select-host-code  as character  no-undo initial "".
   define buffer buf_M1-contract for ub.contract.

   {gbl/stdbtn.i}
   run str/cont-all.w (
      input   parparentproc  ,
      input   v-cntxt-host-code-obj     ,
      input   "b-sel"         ,
      input   "firm-curr|1"      ,
      input   ?               ,
      input   ?               ,
      input   ?               ,
      input   ?               ,
      input   "current"       ,
      input   "all"       ,
      input-output p-rid-list )
      .
      find first buf_M1-contract no-lock where recid(buf_M1-contract) = integer(p-rid-list) no-error.
      if available buf_M1-contract then do :
        iTmp = Is-MS-Contract-Int (BUFFER buf_M1-contract).
        if iTmp <> 1 then do:
           message
           "Выбранный договор не является мастер договором."   skip
           "Копирование списка подчиненных фирм невозможно."
           view-as alert-box information.
        end.
        else do :
          FOR EACH buf_Ext-Classif WHERE
                    buf_Ext-Classif.Classif-name = v-S_CONTRACT
              AND  buf_Ext-Classif.CharKey_One  = STRING(buf_M1-contract.Host-code) + v-DELIM_CHR_3 +
                                                  STRING(buf_M1-contract.contract-code)
              AND  buf_Ext-classif.db-num       = buf_M1-contract.Db-num
          NO-LOCK,
          EACH buf_S-contract WHERE
                    buf_S-Contract.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3 ))
              AND  buf_S-Contract.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3 ))
          NO-LOCK :
             if v-List-select-host-code = "" then v-List-select-host-code = string(buf_S-Contract.Host-code).
                                             else v-List-select-host-code = v-List-select-host-code + "," + string(buf_S-Contract.Host-code).
          END.
          release buf_S-contract.
          RUN str/cont-slave-run.p (
              INPUT parParentProc,
              INPUT THIS-PROCEDURE:HANDLE,  /* p-callback-handle  */
              BUFFER buf_M-Contract,
              BUFFER buf_S-Contract,
              "add",
              INPUT v-List-select-host-code,
              OUTPUT v-cError
              ).
          IF v-cError <> "" THEN DO:
              MESSAGE
                  PROGRAM-NAME(1) SKIP
                  v-cError SKIP
                  VIEW-AS ALERT-BOX INFO BUTTONS OK.
              RETURN NO-APPLY.
          END. ELSE DO:
              RUN Open-Query-Br-Slave IN THIS-PROCEDURE.
              RETURN NO-APPLY.
          END.
        end.
      end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&Scoped-define SELF-NAME b-Del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-Del Dialog-Frame
ON CHOOSE OF b-Del IN FRAME Dialog-Frame /* Удалить */
DO: 
   {gbl/stdbtn.i} 
   /* */ 
    DEFINE VARIABLE v-IsOk AS LOGICAL NO-UNDO INITIAL FALSE. 
   /* */ 
   /* Проверки   */ 
   IF NOT AVAILABLE buf_S-Contract OR NOT AVAILABLE buf_M-Contract THEN DO:
      RETURN NO-APPLY.     
   END.
   /* */ 
   IF buf_S-Contract.STATUS_ = {&close-contr} THEN DO:
      MESSAGE 
          "Договор уже закрыт !" SKIP 
          "Хотя такого быть не может !" SKIP 
          VIEW-AS ALERT-BOX INFO BUTTONS OK.
      RETURN NO-APPLY.     
   END.
   
   /* Право на удаление (отвязку) подчиненного договора 
      проверяем прямо здесь !!!  */ 
   { gbl/chk-actg.i
     v-cntxt-db-num
     v-cntxt-userid
     {&action-head-code-main}
     'actn_fo-mc_slave-add-del':U
     {&cntxt-firm}
     buf_S-Contract.Host-code 
     ''
     0
     0
     0
     0
     true                                                
     v-IsOk 
     no-error
   }
   /* */   
   IF ERROR-STATUS:ERROR THEN DO:
      ASSIGN 
         v-IsOk = FALSE. 
   END.
   /* */ 
   IF NOT v-IsOk THEN DO:
      RETURN NO-APPLY.     
   END.
   
   /* Проверка прав на удадение закончена !!! 
      Запуск процедуры   */ 
   RUN str/cont-slave-run.p (
       INPUT parParentProc,
       INPUT THIS-PROCEDURE:HANDLE,  /* p-callback-handle  */
       BUFFER buf_M-Contract, 
       BUFFER buf_S-Contract, 
       "del":U,
       INPUT "", 
       OUTPUT v-cError            
       ).  
   IF v-cError <> "" THEN DO:
      MESSAGE 
         PROGRAM-NAME(1) SKIP 
         v-cError SKIP 
         VIEW-AS ALERT-BOX INFO BUTTONS OK.
   END. ELSE DO:
      RUN Open-Query-Br-Slave IN THIS-PROCEDURE. 
   END.
   RETURN NO-APPLY. 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-Lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-Lkp Dialog-Frame
ON CHOOSE OF b-Lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  {gbl/stdbtn.i} 
  DEFINE VARIABLE ri AS RECID NO-UNDO. 
  DEFINE VARIABLE v-doc-tp AS CHARACTER NO-UNDO. 
  /* */ 
  IF AVAILABLE buf_S-Contract THEN DO:
     ASSIGN 
        ri = RECID(buf_S-Contract)
        v-doc-tp = buf_S-Contract.Doc-type
        .
     /* Просто просмотр договора  */ 
     RUN str/contr.w ( 
         INPUT parParentProc, 
         INPUT buf_S-Contract.Host-code, 
         INPUT {&lookup}, 
         INPUT v-Doc-tp,  
         INPUT-OUTPUT ri) 
         NO-ERROR.
     /* */ 
     IF ERROR-STATUS:ERROR THEN DO:
        MESSAGE 
            PROGRAM-NAME(1) SKIP 
            ERROR-STATUS:GET-MESSAGE(1) SKIP 
            VIEW-AS ALERT-BOX INFO BUTTONS OK.
     END.
  END.
  RETURN NO-APPLY. 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-Quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-Quit Dialog-Frame
ON CHOOSE OF b-Quit IN FRAME Dialog-Frame /* Выход */
DO:
   {gbl/stdbtn.i} 
   APPLY "GO":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cSchBegNumCont
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cSchBegNumCont Dialog-Frame
ON CTRL-J OF cSchBegNumCont IN FRAME Dialog-Frame /* Начало номера договора */
DO:
  RUN Br-Slave-Reposition IN THIS-PROCEDURE(
      0,
      cSchBegNumCont:SCREEN-VALUE, 
      FALSE,   /*   */ 
      OUTPUT iRecId
      ). 
  RETURN NO-APPLY. 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cSchBegNumCont Dialog-Frame
ON RETURN OF cSchBegNumCont IN FRAME Dialog-Frame /* Начало номера договора */
DO:
  RUN Br-Slave-Reposition IN THIS-PROCEDURE(
      0,
      cSchBegNumCont:SCREEN-VALUE, 
      TRUE,   /* */ 
      OUTPUT iRecId
      ). 
  RETURN NO-APPLY. 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME iSchNumFirm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL iSchNumFirm Dialog-Frame
ON CTRL-J OF iSchNumFirm IN FRAME Dialog-Frame /* Номер фирмы */
DO:
  RUN Br-Slave-Reposition IN THIS-PROCEDURE(
      INTEGER(iSchNumFirm:SCREEN-VALUE),
      "", 
      FALSE,   /* следуюощий номер  */ 
      OUTPUT iRecId
      ). 
  RETURN NO-APPLY. 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL iSchNumFirm Dialog-Frame
ON RETURN OF iSchNumFirm IN FRAME Dialog-Frame /* Номер фирмы */
DO:
  RUN Br-Slave-Reposition IN THIS-PROCEDURE(
      INTEGER(iSchNumFirm:SCREEN-VALUE),
      "", 
      TRUE,
      OUTPUT iRecId
      ). 

  RETURN NO-APPLY. 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-Slave
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Номер текущей БД  */ 
{gbl/curdbnum.i v-db-num}
{gbl/app_help.i}


/* Выводим номер договора и фирму   */ 
ASSIGN 
   FRAME Dialog-Frame:TITLE = 
         "Подчиненные договоры для договора: " + buf_M-Contract.contract-prn-code + " " + 
         "Фирма: " + buf_M-Contract.own-name.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE BR-Slave-Reposition Dialog-Frame 
PROCEDURE BR-Slave-Reposition :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes: Поиск по номеру фирмы или началу номера договора          
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER iNumFirm AS INTEGER NO-UNDO. 
DEFINE INPUT PARAMETER cBegNumContract AS CHARACTER NO-UNDO. 
DEFINE INPUT PARAMETER lFirst AS LOGICAL NO-UNDO. 
DEFINE OUTPUT PARAMETER iRecId AS RECID NO-UNDO INITIAL ?. 
/* */ 
DEFINE VARIABLE lFound AS LOGICAL NO-UNDO INITIAL FALSE. 

/* Контроль входных параметров  */ 
IF iNumFirm = 0 AND cBegNumContract = "" THEN DO:
   MESSAGE 
       "Введите номер фирмы или начало номера договора ! "
       VIEW-AS ALERT-BOX INFO BUTTONS OK.
   RETURN. 
END.

IF lFirst  THEN DO:
   /* Устанавливаем на начало выборки  */ 
   REPEAT:
      GET PREV Br-Slave.     
      IF QUERY-OFF-END("BR-slave") 
         THEN LEAVE.      
   END. 
END. 

GET NEXT Br-Slave.     

Label-repeat: 
REPEAT:
   /* */ 
   IF QUERY-OFF-END("BR-slave") THEN DO: 
      LEAVE LABEL-repeat.     
   END.
   /* */ 
   IF iNumFirm <> 0  THEN DO: /* поиск по номеру фирмы  */ 
      IF iNumFirm = buf_S-Contract.Host-code  THEN DO:
         ASSIGN 
            lFound = TRUE.  
         LEAVE Label-repeat.  
      END.
   END. ELSE DO: /* поиск по номеру договора  */  
      IF buf_S-Contract.Contract-prn-code BEGINS cBegNumContract THEN DO:
         ASSIGN 
            lFound = TRUE.  
         LEAVE Label-repeat.  
      END.
   END.
   GET NEXT Br-slave. 
END.
/* */ 
IF lFound THEN  DO:
   REPOSITION Br-Slave
      TO ROWID 
      ROWID(buf_Ext-Classif), 
      ROWID(buf_S-Contract)
      NO-ERROR. 
   IF ERROR-STATUS:ERROR THEN DO:
      MESSAGE PROGRAM-NAME(1) SKIP 
         ERROR-STATUS:GET-MESSAGE(1) SKIP 
         VIEW-AS ALERT-BOX INFO BUTTONS OK.
   END.
END.
/* */ 
RETURN. 
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
  DISPLAY iSchNumFirm cSchBegNumCont 
      WITH FRAME Dialog-Frame.
  ENABLE b-Quit b-Add b-Lkp b-Del b-Copy B-print b-hist B-Help BR-Slave iSchNumFirm
         cSchBegNumCont 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Open-Query-Br-Slave Dialog-Frame 
PROCEDURE Open-Query-Br-Slave :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
OPEN QUERY Br-Slave
     FOR EACH buf_Ext-Classif WHERE
              buf_Ext-Classif.Classif-name = v-S_CONTRACT
         AND  buf_Ext-Classif.CharKey_One  = STRING(buf_M-Contract.Host-code) + v-DELIM_CHR_3 +
                                             STRING(buf_M-Contract.contract-code)
         AND  buf_Ext-classif.db-num       = buf_M-Contract.Db-num
     NO-LOCK,
     EACH buf_S-contract WHERE
              buf_S-Contract.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3 ))
         AND  buf_S-Contract.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3 ))
     NO-LOCK
     INDEXED-REPOSITION.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

