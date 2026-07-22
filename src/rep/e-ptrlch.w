&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-grp NO-UNDO LIKE gds-grp.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS s-object 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Технологический отчёт по ТРК.

Автор: Шутилов Арнольд Валерьевич
Дата создания: 03/02/15
Author: Shutilov Arnold
Creation date: 03/02/15
Note: е-Отчёт. Печать отчёта в процедуре my-report.
*/

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Технологический отчёт по ТРК.".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ cmp/r-page1.i }
{ cmp/operlist.i }
{ rep/e-xldbj.i "NEW SHARED" }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ cmp/dc-list.i dc-list def "new shared" }
{ gbl/getcntxt.i def }
{ rep/lhstprex.i dc-list-hist }

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable ParParentProc as widget-handle no-undo.
define variable v-param-list as character no-undo.
/*define variable v-list-page as character no-undo. */
/*define variable loc-ref-list as character no-undo.*/
/*define variable doc-list as character no-undo.    */
/*define variable ii as integer no-undo.            */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartViewer
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-5 RECT-6 RECT-7 tog-trans-cancell ~
tog-rcpt-overflow tog-tech-refuel rs-grp-tech-refuell tog-trans-transfer ~
tog-unlock-trans tog-total-tech-chk v-header v-grp-tech-refuell 
&Scoped-Define DISPLAYED-OBJECTS tog-trans-cancell tog-rcpt-overflow ~
tog-tech-refuel rs-grp-tech-refuell tog-trans-transfer tog-unlock-trans ~
tog-total-tech-chk v-header v-grp-tech-refuell 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE v-grp-tech-refuell AS CHARACTER FORMAT "X(20)":U INITIAL "Группировка столбцов:" 
      VIEW-AS TEXT 
     SIZE 24 BY .62
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-header AS CHARACTER FORMAT "X(20)":U INITIAL "Страницы отчета" 
      VIEW-AS TEXT 
     SIZE 16 BY .62
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE rs-grp-tech-refuell AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "ТРК / Назначение", 1,
"Назначение / ТРК", 2
     SIZE 24 BY 2.43 NO-UNDO.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 43 BY 11.43.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 39 BY 3.81.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 45 BY 12.62.

DEFINE VARIABLE tog-rcpt-overflow AS LOGICAL INITIAL yes 
     LABEL "Перелив" 
     VIEW-AS TOGGLE-BOX
     SIZE 36 BY .81 NO-UNDO.

DEFINE VARIABLE tog-tech-refuel AS LOGICAL INITIAL yes 
     LABEL "Технологический пролив" 
     VIEW-AS TOGGLE-BOX
     SIZE 26 BY .81 NO-UNDO.

DEFINE VARIABLE tog-total-tech-chk AS LOGICAL INITIAL yes 
     LABEL "Итог по технологическим чекам" 
     VIEW-AS TOGGLE-BOX
     SIZE 36 BY .81 NO-UNDO.

DEFINE VARIABLE tog-trans-cancell AS LOGICAL INITIAL yes 
     LABEL "Сброс топливных транзакций" 
     VIEW-AS TOGGLE-BOX
     SIZE 36 BY .81 NO-UNDO.

DEFINE VARIABLE tog-trans-transfer AS LOGICAL INITIAL yes 
     LABEL "Перевод топливной транзакции" 
     VIEW-AS TOGGLE-BOX
     SIZE 36 BY .81 NO-UNDO.

DEFINE VARIABLE tog-unlock-trans AS LOGICAL INITIAL yes 
     LABEL "Разблокировка транзакций" 
     VIEW-AS TOGGLE-BOX
     SIZE 36 BY .81 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     tog-trans-cancell AT ROW 2.52 COL 5 WIDGET-ID 8
     tog-rcpt-overflow AT ROW 3.76 COL 5 WIDGET-ID 10
     tog-tech-refuel AT ROW 5.05 COL 5 WIDGET-ID 12
     rs-grp-tech-refuell AT ROW 6.76 COL 12 NO-LABEL WIDGET-ID 20
     tog-trans-transfer AT ROW 9.62 COL 5 WIDGET-ID 14
     tog-unlock-trans AT ROW 10.86 COL 5 WIDGET-ID 16
     tog-total-tech-chk AT ROW 12.1 COL 5 WIDGET-ID 18
     v-header AT ROW 1.67 COL 3 COLON-ALIGNED NO-LABEL WIDGET-ID 6
     v-grp-tech-refuell AT ROW 6.05 COL 9.8 COLON-ALIGNED NO-LABEL WIDGET-ID 24
     RECT-5 AT ROW 1.95 COL 2 WIDGET-ID 4
     RECT-6 AT ROW 5.52 COL 4 WIDGET-ID 26
     RECT-7 AT ROW 1 COL 1 WIDGET-ID 28
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartViewer
   Allow: Basic,DB-Fields
   Frames: 1
   Add Fields to: EXTERNAL-TABLES
   Other Settings: PERSISTENT-ONLY
   Temp-Tables and Buffers:
      TABLE: tt-grp T "?" NO-UNDO ub gds-grp
   END-TABLES.
 */

/* This procedure should always be RUN PERSISTENT.  Report the error,  */
/* then cleanup and return.                                            */
IF NOT THIS-PROCEDURE:PERSISTENT THEN DO:
  MESSAGE "{&FILE-NAME} should only be RUN PERSISTENT.":U
          VIEW-AS ALERT-BOX ERROR BUTTONS OK.
  RETURN.
END.

&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW s-object ASSIGN
         HEIGHT             = 12.67
         WIDTH              = 45.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB s-object 
/* ************************* Included-Libraries *********************** */

{src/adm/method/viewer.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW s-object
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME Size-to-Fit                                   */
ASSIGN 
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME rs-grp-tech-refuell
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-grp-tech-refuell s-object
ON VALUE-CHANGED OF rs-grp-tech-refuell IN FRAME F-Main
DO:
    assign
        rs-grp-tech-refuell
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tog-rcpt-overflow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tog-rcpt-overflow s-object
ON VALUE-CHANGED OF tog-rcpt-overflow IN FRAME F-Main /* Перелив */
DO:
    assign
        tog-rcpt-overflow
    .
    run sensitive-tog-total-tech-chk.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tog-tech-refuel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tog-tech-refuel s-object
ON VALUE-CHANGED OF tog-tech-refuel IN FRAME F-Main /* Технологический пролив */
DO:
    assign
        tog-tech-refuel
    .
/*    run sensitive-rs-grp-tech-refuell.*/
    run sensitive-tog-total-tech-chk.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tog-total-tech-chk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tog-total-tech-chk s-object
ON VALUE-CHANGED OF tog-total-tech-chk IN FRAME F-Main /* Итог по технологическим чекам */
DO:
    assign
        tog-total-tech-chk
    .
    run sensitive-tog-total-tech-chk.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tog-trans-cancell
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tog-trans-cancell s-object
ON VALUE-CHANGED OF tog-trans-cancell IN FRAME F-Main /* Сброс топливных транзакций */
DO:
    assign
        tog-trans-cancell
    .
    run sensitive-tog-total-tech-chk.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tog-trans-transfer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tog-trans-transfer s-object
ON VALUE-CHANGED OF tog-trans-transfer IN FRAME F-Main /* Перевод топливной транзакции */
DO:
    assign
        tog-trans-transfer
    .
    run sensitive-tog-total-tech-chk.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tog-unlock-trans
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tog-unlock-trans s-object
ON VALUE-CHANGED OF tog-unlock-trans IN FRAME F-Main /* Разблокировка транзакций */
DO:
    assign
        tog-unlock-trans
    .
    run sensitive-tog-total-tech-chk.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object 


/* ***************************  Main Block  *************************** */

/* If testing in the UIB, initialize the SmartObject. */
    ParParentProc = my-handle.
    { gbl/getcntxt.i get }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI s-object  _DEFAULT-DISABLE
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
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-apply-layout s-object 
PROCEDURE local-apply-layout :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'apply-layout':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize s-object 
PROCEDURE local-initialize :
define variable v-list as character no-undo.
    define variable v-tmp as character no-undo.

    RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ).

    display v-header with frame {&frame-name}.
/*    display v-grp-tech-refuell with frame {&frame-name}.*/

    assign
        tog-trans-cancell = yes
        tog-rcpt-overflow = yes
        tog-tech-refuel = yes
        tog-trans-transfer = yes
        tog-unlock-trans = yes
        tog-total-tech-chk = yes
        rs-grp-tech-refuell = 1
    .

        rs-grp-tech-refuell:visible = false.
        RECT-6:visible = false.

    assign
        tog-trans-cancell:screen-value in frame {&frame-name} = string(tog-trans-cancell)       /* 1 – Сброс топливных транзакций */
        tog-rcpt-overflow:screen-value in frame {&frame-name} = string(tog-rcpt-overflow)       /* 2 – Перелив */
        tog-tech-refuel:screen-value in frame {&frame-name} = string(tog-tech-refuel)           /* 3 – Технологический пролив */
        tog-trans-transfer:screen-value in frame {&frame-name} = string(tog-trans-transfer)     /* 4 – Перевод топливной транзакции */
        tog-unlock-trans:screen-value in frame {&frame-name} = string(tog-unlock-trans)         /* 5 – Разблокировка транзакций */
        tog-total-tech-chk:screen-value in frame {&frame-name} = string(tog-total-tech-chk)     /* 6 – Итоги по технологическим чекам */
        rs-grp-tech-refuell:screen-value in frame {&frame-name} = string(rs-grp-tech-refuell)   /* Дочерний виджет (Группировка столбцов) для основного виджета (ТехПролив) */
    .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object 
PROCEDURE my-report :
/******************/

    /* Кодировка и сбор параметров отчёта в один параметр для передачи между процедурами. В список входят значимые данные, разделённые запятой. num-entries не фиксирован и может быть различным! */
    if tog-trans-cancell = yes then     /* 1 – Сброс топливных транзакций (14) */
    do:
        v-param-list = v-param-list + string(integer({&rcpt-trans-cancell})).   
    end.

    if tog-rcpt-overflow = yes then     /* 2 – Перелив (15) */
    do:
        if v-param-list <> "" then
        do:
            v-param-list = v-param-list + {&comma-char} + string(integer({&rcpt-overflow})).
        end.
        else
        do:
            v-param-list = v-param-list + string(integer({&rcpt-overflow})).
        end.
    end.

    if tog-tech-refuel = yes then       /* 3 – Технологический пролив (17) */
    do:
        if v-param-list <> "" then
        do:
            v-param-list = v-param-list + {&comma-char} + string(integer({&rcpt-tech-refuell})).
        end.
        else
        do:
            v-param-list = v-param-list + string(integer({&rcpt-tech-refuell})).
        end.
    end.

    if tog-trans-transfer = yes then    /* 4 – Перевод топливной транзакции (16) */
    do:
        if v-param-list <> "" then
        do:
            v-param-list = v-param-list + {&comma-char} + string(integer({&rcpt-trans-transfer})).
        end.
        else
        do:
            v-param-list = v-param-list + string(integer({&rcpt-trans-transfer})).
        end.
    end.
/*
    if tog-unlock-trans = yes then      /* 5 – Разблокировка транзакций (36) */
    do:
        if v-param-list <> "" then
        do:
            v-param-list = v-param-list + {&comma-char} + string(integer({&rcpt-unlock-trans})).
        end.
        else
        do:
            v-param-list = v-param-list + string(integer({&rcpt-unlock-trans})).
        end.
    end.
*/
    if tog-total-tech-chk = yes then    /* 6 – Итоги по технологическим чекам (условно = 99) */
    do:
        if v-param-list <> "" then
        do:
            v-param-list = v-param-list + {&comma-char} + '0':U.
        end.
        else
        do:
            v-param-list = v-param-list + '0':U.
        end.
    end.


    run rep/r-ptrlch.p (
        input parParentProc,        /* parParentProc */
        input v-param-list,         /* Список цифровых кодов типов чеков */
        input rs-grp-tech-refuell   /* Группировка итогов для раздела "ТехПролив" (ТРК/Назначение=1 или Назначение/ТРК=2 */
        ).

    v-param-list = '':U. 

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object 
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/
    assign frame {&frame-name}
        tog-trans-cancell       /* 1 – Сброс топливных транзакций */
        tog-rcpt-overflow       /* 2 – Перелив */
        tog-tech-refuel         /* 3 – Технологический пролив */
        tog-trans-transfer      /* 4 – Перевод топливной транзакции */
        tog-unlock-trans        /* 5 – Разблокировка транзакций */
        tog-total-tech-chk      /* 6 – Итоги по технологическим чекам  */
        rs-grp-tech-refuell     /* Дочерний виджет(Группировка столбцов) для основного виджета tog-tech-refuel(ТехПролив) */
    .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE sensitive-tog-total-tech-chk s-object 
PROCEDURE sensitive-tog-total-tech-chk :
/* Проверка выбрана-ли хоть одна страница отчёта, если нет - галочка печать "Итого" - делается нередактируемая. */
    if 
    tog-trans-cancell  = no     /* 1 – Сброс топливных транзакций */
    and
    tog-rcpt-overflow  = no     /* 2 – Перелив */
    and
    tog-tech-refuel    = no     /* 3 – Технологический пролив */
    and
    tog-trans-transfer = no     /* 4 – Перевод топливной транзакции */
    and
    tog-unlock-trans   = no     /* 5 – Разблокировка транзакций */
    then
        do:
            tog-total-tech-chk:screen-value in frame {&frame-name} = 'no':U.
            disable
                tog-total-tech-chk  /* 6 – Итоги по технологическим чекам  */
            with frame {&frame-name}.
        end.
    else
        do:
            tog-total-tech-chk:screen-value in frame {&frame-name} = string(tog-total-tech-chk). /* Восстановление состояни toggl-box до его сброса выше */
            enable
                tog-total-tech-chk  /* 6 – Итоги по технологическим чекам  */
            with frame {&frame-name}.
        end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE sensitive-rs-grp-tech-refuell s-object 
PROCEDURE sensitive-rs-grp-tech-refuell :
/* Если в окне параметров Закладка-2
галочка на родительском виджете tog-tech-refuel ("ТехПролив") = yes,
то делаем доступным и дочерний виджет rs-grp-tech-refuell ("Группировка столбцов") */
    if tog-tech-refuel = no then    /* 3 – Технологический пролив */
        do:
/*            rs-grp-tech-refuell:screen-value in frame {&frame-name} = '':U.*/
            disable
                rs-grp-tech-refuell     /* "Группировка столбцов" */
            with frame {&frame-name}.
        end.
        else
        do:
            rs-grp-tech-refuell:screen-value in frame {&frame-name} = string(rs-grp-tech-refuell). /* Восстановление состояни rs-grp-tech-refuell до его сброса выше */
            enable
                rs-grp-tech-refuell     /* "Группировка столбцов" */
            with frame {&frame-name}.
        end.
end procedure.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed s-object 
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:     Receive and process 'state-changed' methods
               (issued by 'new-state' event).
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.


  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
      /* link-changed */
  END CASE.
  END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

