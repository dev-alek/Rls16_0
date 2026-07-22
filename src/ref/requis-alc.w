&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_clients-attr FOR clients-attr.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование реквизитов для алкогольной декларации

Автор: Шальнев Иван Сергеевич
Дата создания: 07/10/10
Author: Shalnev Ivan
Creation date: 07/10/10

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input-output parameter p-value as character no-undo .

define buffer buf_firm for ub.firm.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_person for ub.person.
define buffer buf_clients for ub.clients.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование реквизитов для алкогольной декларации".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/clntattr.i }

define variable v-tab-order  as character no-undo.
define variable v-dop        as character no-undo.
define variable v-attr-value as character no-undo .
define variable v-attr-type  as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help f-post f-sobstv ~
f-country f-index f-region-code btn-region-code f-area f-city2 f-city ~
f-street f-house f-litera f-case f-apartment f-f-direcotr f-i-direcotr ~
f-o-direcotr f-f-accountant f-i-accountant f-o-accountant 
&Scoped-Define DISPLAYED-OBJECTS f-post f-sobstv f-country f-index ~
f-region-code f-area f-city2 f-city f-street f-house f-litera f-case ~
f-apartment f-f-direcotr f-i-direcotr f-o-direcotr f-f-accountant ~
f-i-accountant f-o-accountant region-code-name 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
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

DEFINE BUTTON btn-region-code 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY .88.

DEFINE VARIABLE f-apartment AS INTEGER FORMAT ">>>>9":U INITIAL 0 
     LABEL "Квартира" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-area AS CHARACTER FORMAT "X(250)":U 
     LABEL "Район" 
     VIEW-AS FILL-IN 
     SIZE 62.63 BY 1 NO-UNDO.

DEFINE VARIABLE f-case AS CHARACTER FORMAT "X(256)":U 
     LABEL "Корпус" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-city AS CHARACTER FORMAT "X(256)":U 
     LABEL "Город" 
     VIEW-AS FILL-IN 
     SIZE 33 BY 1 NO-UNDO.

DEFINE VARIABLE f-city2 AS CHARACTER FORMAT "X(250)":U 
     LABEL "Населенный пункт" 
     VIEW-AS FILL-IN 
     SIZE 35.63 BY 1 NO-UNDO.

DEFINE VARIABLE f-country AS INTEGER FORMAT "999":U INITIAL 0 
     LABEL "Код страны" 
     VIEW-AS FILL-IN 
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE f-f-accountant AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 25 BY .96 NO-UNDO.

DEFINE VARIABLE f-f-direcotr AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 25 BY .96 NO-UNDO.

DEFINE VARIABLE f-house AS CHARACTER FORMAT "X(256)":U 
     LABEL "Дом" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-i-accountant AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 25 BY .96 NO-UNDO.

DEFINE VARIABLE f-i-direcotr AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 25 BY .96 NO-UNDO.

DEFINE VARIABLE f-index AS INTEGER FORMAT "999999":U INITIAL 0 
     LABEL "Индекс" 
     VIEW-AS FILL-IN 
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-litera AS CHARACTER FORMAT "X(256)":U 
     LABEL "Литера" 
     VIEW-AS FILL-IN 
     SIZE 14 BY .96 NO-UNDO.

DEFINE VARIABLE f-o-accountant AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 25 BY .96 NO-UNDO.

DEFINE VARIABLE f-o-direcotr AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 25 BY .96 NO-UNDO.

DEFINE VARIABLE f-post AS CHARACTER FORMAT "X(250)":U 
     VIEW-AS FILL-IN 
     SIZE 69 BY 1 NO-UNDO.

DEFINE VARIABLE f-region-code AS INTEGER FORMAT "99":U INITIAL 0 
     LABEL "Код региона" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-sobstv AS CHARACTER FORMAT "X(25)":U 
     LABEL "Вид собственности" 
     VIEW-AS FILL-IN 
     SIZE 26.25 BY 1 NO-UNDO.

DEFINE VARIABLE f-street AS CHARACTER FORMAT "X(256)":U 
     LABEL "Улица" 
     VIEW-AS FILL-IN 
     SIZE 61.75 BY 1 NO-UNDO.

DEFINE VARIABLE region-code-name AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 44.5 BY .67 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 91
     f-post AT ROW 3.13 COL 2 NO-LABEL WIDGET-ID 22
     f-sobstv AT ROW 4.5 COL 1.38 WIDGET-ID 24
     f-country AT ROW 4.5 COL 50.25 WIDGET-ID 2
     f-index AT ROW 4.5 COL 76.25 WIDGET-ID 4
     f-region-code AT ROW 5.96 COL 1.25 WIDGET-ID 6
     btn-region-code AT ROW 6.04 COL 28.5 WIDGET-ID 50
     f-area AT ROW 7.33 COL 1.5 WIDGET-ID 8
     f-city2 AT ROW 8.88 COL 47.75 WIDGET-ID 12
     f-city AT ROW 8.92 COL 1.38 WIDGET-ID 10
     f-street AT ROW 10.38 COL 1 WIDGET-ID 14
     f-house AT ROW 11.92 COL 2.13 WIDGET-ID 16
     f-litera AT ROW 11.92 COL 29 COLON-ALIGNED WIDGET-ID 28
     f-case AT ROW 11.92 COL 47.88 WIDGET-ID 18
     f-apartment AT ROW 11.92 COL 73.25 WIDGET-ID 20
     f-f-direcotr AT ROW 13.38 COL 24 COLON-ALIGNED NO-LABEL WIDGET-ID 38
     f-i-direcotr AT ROW 13.38 COL 50 COLON-ALIGNED NO-LABEL WIDGET-ID 40
     f-o-direcotr AT ROW 13.38 COL 76 COLON-ALIGNED NO-LABEL WIDGET-ID 42
     f-f-accountant AT ROW 14.54 COL 24 COLON-ALIGNED NO-LABEL WIDGET-ID 44
     f-i-accountant AT ROW 14.54 COL 50 COLON-ALIGNED NO-LABEL WIDGET-ID 46
     f-o-accountant AT ROW 14.54 COL 76 COLON-ALIGNED NO-LABEL WIDGET-ID 48
     region-code-name AT ROW 6.21 COL 30.88 COLON-ALIGNED NO-LABEL WIDGET-ID 52
     "Наименование объекта/организации" VIEW-AS TEXT
          SIZE 51 BY .63 AT ROW 2.33 COL 2 WIDGET-ID 26
     "Ф.И.О. Руководителя" VIEW-AS TEXT
          SIZE 22 BY .96 AT ROW 13.38 COL 2 WIDGET-ID 36
     "Ф.И.О. Бухгалтера" VIEW-AS TEXT
          SIZE 22 BY .96 AT ROW 14.54 COL 2 WIDGET-ID 30
     SPACE(83.79) SKIP(0.68)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Реквизиты для алкогольной декларации"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_clients-attr B "?" ? ub clients-attr
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN f-apartment IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-area IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-case IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-city IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-city2 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-country IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-house IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-index IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-post IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-region-code IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-sobstv IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-street IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN region-code-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Реквизиты для алкогольной декларации */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
    ASSIGN
        f-post
        f-sobstv
        f-country
        f-index
        f-region-code
                region-code-name
        f-area
        f-city
        f-city2
        f-street
        f-house
        f-case
        f-apartment
        f-litera
        f-f-direcotr
        f-i-direcotr
        f-o-direcotr
        f-f-accountant
        f-i-accountant
        f-o-accountant.

    p-value = f-post + "|" + f-sobstv + "|" .
    
    if f-country <> 0 then p-value = p-value + string (f-country, "999") + "|" .
    else p-value = p-value + "|" .
    
    if f-index <> 0 then p-value = p-value + string (f-index, "999999") + "|" .
    else p-value = p-value + "|" .
    
    if f-region-code <> 0 then p-value = p-value + string (f-region-code, "99") + "|" .
    else p-value = p-value + "|" .
    
    p-value = p-value + f-area + "|" + f-city + "|" + f-city2 + "|" + f-street + "|" + f-house  + "|" + f-case + "|" .
    
    if f-apartment <> 0 then p-value = p-value + string (f-apartment) + "|".
    else p-value = p-value + "|" .
    
    p-value = p-value + f-litera + "|".
    p-value = p-value + f-f-direcotr + "|" + f-i-direcotr + "|" + f-o-direcotr 
                      + "|" + f-f-accountant + "|" + f-i-accountant + "|" + f-o-accountant.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-region-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-region-code Dialog-Frame
ON CHOOSE OF btn-region-code IN FRAME Dialog-Frame
do:
  RUN proc-btn-region-code IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ ref/tabhndmv.i v-tab-order underline-tb }
{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-exit in frame {&frame-name}." }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    
    if p-value = "" or p-value = ? then do: /* Если атрибута нет - заполняем. что можем */
        
        find first buf_clients no-lock where buf_clients.obj-code = p-obj-code
                                       and   buf_clients.obj-type = p-obj-type no-error.
        assign
            f-post = buf_clients.obj-name.        
        
        run clntattr-value in this-procedure ( input p-obj-type, input p-obj-code, input {&attr-region-code}, output v-attr-value, output v-attr-type ) .
        assign
            f-region-code = integer (v-attr-value).
        FIND ub.regions WHERE ub.regions.reg-code = f-region-code no-error.
        if f-region-code <> 0 then do:
            DISPLAY ub.regions.reg-name @ region-code-name with frame {&frame-name}.
            assign 
                region-code-name
            .
        end.

        if p-obj-type = {&cmp} then do:
            find first buf_firm no-lock where buf_firm.firm-code = p-obj-code no-error.
            assign
                f-index = buf_firm.ind
                f-f-direcotr = entry(1,buf_firm.director," ")
                f-i-direcotr = entry(2,buf_firm.director," ")
                f-o-direcotr = entry(3,buf_firm.director," ") no-error.
        end. /* if p-obj-type = {&cmp} */
         
        if p-obj-type = {&cmp} then do:
            find first buf_sysconf no-lock where buf_sysconf.host-code = p-obj-code no-error.
            assign
                f-f-accountant = entry(1,buf_sysconf.snr-accnt," ")
                f-i-accountant = entry(2,buf_sysconf.snr-accnt," ")
                f-o-accountant = entry(3,buf_sysconf.snr-accnt," ") no-error.
        end. /* if p-obj-type = {&cmp} */         
         
        if p-obj-type = {&prs} then do:
            find first buf_person no-lock where buf_person.psn-code = p-obj-code no-error.
            assign
                f-index = buf_person.ind.
        end. /* if p-obj-type = {&prs} */
    
    end. /* if p-value <> "" then do: */
    
    else do: /* Если есть атрибут - берём всё из него */
        assign
            f-post         = entry (1,p-value,"|")
            f-sobstv       = entry (2,p-value,"|")
            f-country      = integer (entry (3,p-value,"|"))
            f-index        = integer (entry (4,p-value,"|"))
            f-region-code  = integer (entry (5,p-value,"|"))
            f-area         = entry (6,p-value,"|")
            f-city         = entry (7,p-value,"|")
            f-city2        = entry (8,p-value,"|")
            f-street       = entry (9,p-value,"|")
            f-house        = entry (10,p-value,"|")
            f-case         = entry (11,p-value,"|")
            f-apartment    = integer (entry (12,p-value,"|"))
            f-litera       = entry (13,p-value,"|")
            f-f-direcotr   = entry (14,p-value,"|")
            f-i-direcotr   = entry (15,p-value,"|")
            f-o-direcotr   = entry (16,p-value,"|")
            f-f-accountant = entry (17,p-value,"|")
            f-i-accountant = entry (18,p-value,"|")
            f-o-accountant = entry (19,p-value,"|") no-error.

        FIND ub.regions WHERE ub.regions.reg-code = f-region-code no-error.
        if f-region-code <> 0 then do:
            DISPLAY ub.regions.reg-name @ region-code-name with frame {&frame-name}.
            assign 
                region-code-name
            .
        end.
           
    end.
    RUN enable_ui.
    run my_enable.
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

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
  DISPLAY f-post f-sobstv f-country f-index f-region-code f-area f-city2 f-city 
          f-street f-house f-litera f-case f-apartment f-f-direcotr f-i-direcotr 
          f-o-direcotr f-f-accountant f-i-accountant f-o-accountant 
          region-code-name 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help f-post f-sobstv f-country f-index f-region-code 
         btn-region-code f-area f-city2 f-city f-street f-house f-litera f-case 
         f-apartment f-f-direcotr f-i-direcotr f-o-direcotr f-f-accountant 
         f-i-accountant f-o-accountant 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my_enable Dialog-Frame 
PROCEDURE my_enable :
/*------------------------------------------------------------------------------
                        Purpose: Скроем поля в зависимости от типа объекта                                                                                                                                        
                        Notes:                                                                                                                                            
        ------------------------------------------------------------------------------*/
if p-obj-type <> {&cmp} then do:
      
      disable
      f-f-direcotr
      f-i-direcotr
      f-o-direcotr
      f-f-accountant
      f-i-accountant 
      f-o-accountant 
      with frame Dialog-Frame.


end. /*if p-obj-type  */

end procedure.
        

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my_enable Dialog-Frame 
PROCEDURE proc-btn-region-code :        /*вызов справочника региона РФ*/
define variable parparentproc as widget-handle no-undo .
define variable v-reg-code as integer no-undo .

run ref/regions.w (
          input parparentproc
         ,input {&choose}
         ,output v-reg-code).
          
if v-reg-code = ? then  do:
  apply "entry" to f-region-code in frame {&frame-name}.
  return error.
end.
FIND ub.regions WHERE ub.regions.reg-code = v-reg-code no-error.
if available ub.regions then do:
    DISPLAY ub.regions.reg-code @ f-region-code with frame {&frame-name}.
    DISPLAY ub.regions.reg-name @ region-code-name with frame {&frame-name}.
    assign 
        f-region-code
        region-code-name
    .
    
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

