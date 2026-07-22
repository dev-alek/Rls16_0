&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Пользователь системы

Автор: Белоусов Илья Александрович
Дата создания: 07/26/07
Author: Ilia Belousov
Creation date: 07/26/07

Input:

Output:

*/
/* ***************************  Definitions  ************************** */
/**/
/* Parameters Definitions ---                                           */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Пользователь системы".

{ cmp\trg-def.i }
{ adm\userpro.i }

/* Parameters Definitions ---                                           */
define input parameter parparentproc                as widget-handle    no-undo .
define input parameter p-parent-handle              as handle           no-undo.
define input parameter p-mode                       as character        no-undo.
define input parameter p-in-user-id                 as character        no-undo.
define input parameter p-in-last-name               as character        no-undo.
define input parameter p-in-first-name              as character        no-undo.
define input parameter p-in-second-name             as character        no-undo.
define input parameter p-in-nik                     as character        no-undo.
define input parameter p-in-phone-number            as character        no-undo.
define input parameter p-in-mobile-phone-number     as character        no-undo.
define input parameter p-in-company                 as character        no-undo.
define input parameter p-in-department              as character        no-undo.
define input parameter p-in-position                as character        no-undo.
define input parameter p-in-room                    as character        no-undo.
define input parameter p-in-e-mail                  as character        no-undo.
define input parameter p-in-internal-phone-number   as character        no-undo.
define input parameter p-in-PS                      as character        no-undo.
define input parameter p-in-psn-code                as integer          no-undo.
define input parameter i-adm-gbd                    as logical          no-undo.
define input parameter i-superAdm                   as logical          no-undo.
define input parameter i-adm-Ubd                    as logical          no-undo.
define input-output parameter table for UserDbAdm .
define output parameter p-out-last-name             as character        no-undo.
define output parameter p-out-first-name            as character        no-undo.
define output parameter p-out-second-name           as character        no-undo.
define output parameter p-out-nik                   as character        no-undo.
define output parameter p-out-phone-number          as character        no-undo.
define output parameter p-out-mobile-phone-number   as character        no-undo.
define output parameter p-out-company               as character        no-undo.
define output parameter p-out-department            as character        no-undo.
define output parameter p-out-position              as character        no-undo.
define output parameter p-out-room                  as character        no-undo.
define output parameter p-out-e-mail                as character        no-undo.
define output parameter p-out-internal-phone-number as character        no-undo.
define output parameter p-out-PS                    as character        no-undo.
define output parameter p-out-psn-code              as integer          no-undo.
define output parameter O-adm-gbd                    as logical          no-undo.
define output parameter o-superAdm                   as logical          no-undo.
define output parameter O-adm-Ubd                    as logical          no-undo.
define output parameter p-accepted                  as logical          no-undo.

/* Local Variable Definitions ---                                       */
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/color.i    }
{ gbl/getcntxt.i def }
{ cmp/showinf.i }


/*DEFINE BUFFER bufUserDbAdm FOR UserDbAdm.*/


define variable v-user-exit-enabled     as logical      no-undo.
define variable v-user-nik-autofill     as logical      no-undo.
define variable mSyperAdm               as logical      no-undo.
define variable mchenglistubd           as logical no-undo.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BRUserUbd

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES UserDbAdm

/* Definitions for BROWSE BRUserUbd                                      */
&Scoped-define FIELDS-IN-QUERY-BRUserUbd UserDbAdm.db-num getadm() 
&Scoped-define ENABLED-FIELDS-IN-QUERY-BRUserUbd 
&Scoped-define QUERY-STRING-BRUserUbd FOR EACH UserDbAdm NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BRUserUbd OPEN QUERY BRUserUbd FOR EACH UserDbAdm NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BRUserUbd UserDbAdm
&Scoped-define FIRST-TABLE-IN-QUERY-BRUserUbd UserDbAdm


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BRUserUbd}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-close b-help fi-last-name ~
fi-first-name fi-second-name fi-nik fi-phone-number fi-mobile-phone-number ~
fi-company fi-department fi-position fi-room fi-e-mail ~
fi-internal-phone-number ed-PS ~
b-psn fi-psn-code v-psn-name ~
RAD-adm-gbd TOG-superAdm  RAD-adm-Ubd BRUserUbd btnAdm BtnDel
&Scoped-Define DISPLAYED-OBJECTS fi-last-name fi-first-name fi-second-name ~
fi-PS-label-2 fi-nik fi-phone-number fi-mobile-phone-number fi-company ~
fi-department fi-position fi-room fi-e-mail fi-internal-phone-number ~
fi-PS-label ed-PS fi-user-id fi-psn-code v-psn-name ~
RAD-adm-gbd TOG-superAdm RAD-adm-Ubd 
/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD GetAdm Dialog-Frame 
FUNCTION GetAdm RETURNS CHARACTER
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-close AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help 
     LABEL "Помо&щь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-psn 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Button 1" 
     SIZE 3 BY 1.

DEFINE BUTTON btnAdm 
     LABEL "Админ/Пользователь" 
     SIZE 20 BY 1.

DEFINE BUTTON BtnDel 
     LABEL "Удалить" 
     SIZE 10 BY 1.

DEFINE VARIABLE ed-PS AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 32.5 BY 2.25 NO-UNDO.

DEFINE VARIABLE fi-company AS CHARACTER FORMAT "X(256)":U 
     LABEL "Организация" 
     VIEW-AS FILL-IN 
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE fi-department AS CHARACTER FORMAT "X(256)":U 
     LABEL "Отдел" 
     VIEW-AS FILL-IN 
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE fi-e-mail AS CHARACTER FORMAT "X(256)":U 
     LABEL "E-Mail" 
     VIEW-AS FILL-IN 
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE fi-first-name AS CHARACTER FORMAT "X(256)":U 
     LABEL "Имя" 
     VIEW-AS FILL-IN 
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE fi-internal-phone-number AS CHARACTER FORMAT "X(256)":U 
     LABEL "Раб.телефон" 
     VIEW-AS FILL-IN 
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE fi-last-name AS CHARACTER FORMAT "X(256)":U 
     LABEL "Фамилия" 
     VIEW-AS FILL-IN 
     SIZE 32.5 BY 1 NO-UNDO.

DEFINE VARIABLE fi-mobile-phone-number AS CHARACTER FORMAT "X(256)":U 
     LABEL "Моб.Телефон" 
     VIEW-AS FILL-IN 
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE fi-nik AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 32.5 BY 1
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE fi-phone-number AS CHARACTER FORMAT "X(256)":U 
     LABEL "Телефон" 
     VIEW-AS FILL-IN 
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE fi-position AS CHARACTER FORMAT "X(256)":U 
     LABEL "Должность" 
     VIEW-AS FILL-IN 
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE fi-PS-label AS CHARACTER FORMAT "X(256)":U INITIAL "Примечание:" 
     VIEW-AS FILL-IN 
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE fi-PS-label-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Псевдоним:" 
     VIEW-AS FILL-IN 
     SIZE 11 BY 1
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE fi-psn-code AS INTEGER FORMAT "->>>>>>>>9":U INITIAL 0 
     LABEL "Физ. лицо" 
     VIEW-AS FILL-IN 
     SIZE 11.5 BY 1 NO-UNDO.

DEFINE VARIABLE fi-room AS CHARACTER FORMAT "X(256)":U 
     LABEL "Комната" 
     VIEW-AS FILL-IN 
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE fi-second-name AS CHARACTER FORMAT "X(256)":U 
     LABEL "Отчество" 
     VIEW-AS FILL-IN 
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE fi-user-id AS CHARACTER FORMAT "X(256)":U 
     LABEL "ID" 
      VIEW-AS TEXT 
     SIZE 15 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-psn-name AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE RAD-adm-gbd AS INTEGER INITIAL 2 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Администратор ГБД", 1,
"Пользователь ГБД", 3,
"Отсутствует ", 2

     SIZE 28.5 BY 3 NO-UNDO.

DEFINE VARIABLE RAD-adm-Ubd AS INTEGER INITIAL 2 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Администратор всех Убд", 1,
"Пользователь всех УБД", 3,
"Выборочно ", 2
     SIZE 40.5 BY 3 NO-UNDO.

DEFINE VARIABLE TOG-superAdm AS LOGICAL INITIAL no 
     LABEL "Супер Администратор" 
     VIEW-AS TOGGLE-BOX
     SIZE 22.5 BY .83 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BRUserUbd FOR 
      UserDbAdm SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BRUserUbd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BRUserUbd Dialog-Frame _STRUCTURED
  QUERY BRUserUbd NO-LOCK DISPLAY
      UserDbAdm.db-num COLUMN-LABEL "УБД"
      getadm() COLUMN-LABEL "Роль" format "x(15)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 35.5 BY 7.75 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-close AT ROW 1 COL 11
     b-help AT ROW 1 COL 36.5
     fi-last-name AT ROW 3.5 COL 5.63 WIDGET-ID 2
     RAD-adm-gbd AT ROW 3.5 COL 50 NO-LABEL WIDGET-ID 36
     fi-first-name AT ROW 4.75 COL 9.63 WIDGET-ID 4
     fi-second-name AT ROW 6 COL 4.5 WIDGET-ID 6
     TOG-superAdm AT ROW 6.5 COL 50 WIDGET-ID 38
     fi-PS-label-2 AT ROW 7.25 COL 3 NO-LABEL WIDGET-ID 34
     fi-nik AT ROW 7.25 COL 14.5 NO-LABEL WIDGET-ID 32
     RAD-adm-Ubd AT ROW 7.25 COL 50 NO-LABEL WIDGET-ID 42
     fi-phone-number AT ROW 8.5 COL 5.5 WIDGET-ID 8
     fi-mobile-phone-number AT ROW 9.75 COL 1.5 WIDGET-ID 10
     fi-company AT ROW 11 COL 1.63 WIDGET-ID 12
     BRUserUbd AT ROW 11 COL 51 WIDGET-ID 200
     fi-department AT ROW 12.25 COL 7.5 WIDGET-ID 14
     fi-position AT ROW 13.5 COL 3.5 WIDGET-ID 28
     fi-room AT ROW 14.75 COL 5.5 WIDGET-ID 16
     fi-e-mail AT ROW 16 COL 6.5 WIDGET-ID 18
     fi-internal-phone-number AT ROW 17.25 COL 1.5 WIDGET-ID 22
     fi-psn-code AT ROW 18.5 COL 12.5 COLON-ALIGNED WIDGET-ID 36
     b-psn AT ROW 18.5 COL 26.5 WIDGET-ID 38
     v-psn-name AT ROW 18.5 COL 28 COLON-ALIGNED NO-LABEL WIDGET-ID 40
     fi-PS-label AT ROW 19.75 COL 1.5 NO-LABEL WIDGET-ID 26
     ed-PS AT ROW 19.75 COL 14.5 NO-LABEL WIDGET-ID 24
     btnAdm AT ROW 19 COL 51 WIDGET-ID 46
     BtnDel AT ROW 19 COL 71.5 WIDGET-ID 48
     
     fi-user-id AT ROW 2.5 COL 10.5 WIDGET-ID 30
     SPACE(61.00) SKIP(19.07)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Пользователь системы"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-close WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: UserDbAdm B "?" ? Temp-Table UserDbAdm
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BRUserUbd fi-company Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN fi-company IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-department IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-e-mail IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-first-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-internal-phone-number IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-last-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-mobile-phone-number IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-nik IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-phone-number IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-position IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-PS-label IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fi-PS-label-2 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fi-room IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-second-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-user-id IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
ASSIGN 
       v-psn-name:READ-ONLY IN FRAME Dialog-Frame          = TRUE
       TOG-superAdm:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BRUserUbd
/* Query rebuild information for BROWSE BRUserUbd
     _TblList          = "UserDbAdm"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > Temp-Tables.UserDbAdm.db-num
"UserDbAdm.db-num" "УБД" ? "" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > "_<CALC>"
"getadm()" "Роль" ? ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE BRUserUbd */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Пользователь системы */
DO:
/* Действия после нажатия кнопки Выбор */
    define variable v-have-error     as logical      no-undo.
    define variable v-error-desc     as character    no-undo.
    define variable v-focus-widget   as handle       no-undo.

    run check-user in this-procedure (
          output v-have-error
        , output v-error-desc
        , output v-focus-widget
    ).
    if v-have-error = yes
    then do:
        if valid-handle( v-focus-widget )
        then do:
            apply "entry" to v-focus-widget.
        end.
        message
            "Ошибка ввода параметров пользователя."
            skip (1)
            skip v-error-desc
        view-as alert-box.
        undo, return no-apply.
    end.
    assign
        v-user-exit-enabled = yes
    .
    if v-user-exit-enabled = yes
    then do:
        assign
            fi-last-name
            fi-first-name
            fi-second-name
            fi-phone-number
            fi-mobile-phone-number
            fi-company
            fi-department
            fi-position
            fi-room
            fi-e-mail
            fi-internal-phone-number
            fi-psn-code
            ed-PS
            rad-adm-gbd
            TOG-superAdm
            RAD-adm-Ubd
        .
        assign
            p-out-last-name             = fi-last-name
            p-out-first-name            = fi-first-name
            p-out-second-name           = fi-second-name
            p-out-nik                   = fi-nik
            p-out-phone-number          = fi-phone-number
            p-out-mobile-phone-number   = fi-mobile-phone-number
            p-out-company               = fi-company
            p-out-department            = fi-department
            p-out-position              = fi-position
            p-out-room                  = fi-room
            p-out-e-mail                = fi-e-mail
            p-out-internal-phone-number = fi-internal-phone-number
            p-out-PS                    = ed-PS
            p-out-psn-code              = fi-psn-code
            o-adm-gbd                   = if rad-adm-gbd eq 1
                                          then yes
                                          else if rad-adm-gbd eq 3
                                          then no
                                          else ?
            o-superAdm                  = TOG-superAdm
            o-adm-Ubd                   = if RAD-adm-Ubd eq 1
                                          then yes
                                          else if RAD-adm-Ubd eq 3
                                          then no
                                          else ?
            
        .
/*        if o-adm-gbd eq i-adm-gbd*/
/*        then                     */
/*           o-adm-gbd = ?.        */
        if o-adm-ubd eq i-adm-ubd
           and not mchenglistubd
        then
           o-adm-ubd = ?.
        if p-out-last-name              <> p-in-last-name
        or p-out-first-name             <> p-in-first-name
        or p-out-second-name            <> p-in-second-name
        or p-out-nik                    <> p-in-nik
        or p-out-phone-number           <> p-in-phone-number
        or p-out-mobile-phone-number    <> p-in-mobile-phone-number
        or p-out-company                <> p-in-company
        or p-out-department             <> p-in-department
        or p-out-position               <> p-in-position
        or p-out-room                   <> p-in-room
        or p-out-e-mail                 <> p-in-e-mail
        or p-out-internal-phone-number  <> p-in-internal-phone-number
        or p-out-PS                     <> p-in-PS
        or p-out-psn-code               <> p-in-psn-code
        or (o-adm-gbd                   <> i-adm-gbd)
        or o-superAdm                   <> i-superAdm
        or (    o-adm-Ubd ne ?
            and o-adm-Ubd               <> i-adm-Ubd)
        or mchenglistubd    
        then do:
            assign
                p-accepted = yes
            .
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Пользователь системы */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-close
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-close Dialog-Frame
ON CHOOSE OF b-close IN FRAME Dialog-Frame /* Отмена */
DO:
{ gbl/stdbtn.i }
    assign
        v-user-exit-enabled     = yes
        p-accepted              = no
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
{ gbl/stdbtn.i }

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME btnAdm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnAdm Dialog-Frame
ON CHOOSE OF btnAdm IN FRAME Dialog-Frame /* Админ */
DO:
   define variable vrowid as rowid no-undo.
   if available UserDbAdm
   then do:
      if UserDbAdm.db-usr
      then
         if UserDbAdm.db-block
         then do:
            UserDbAdm.db-adm = yes.
            UserDbAdm.db-block = no.
          end.
          else if UserDbAdm.db-adm
          then 
             UserDbAdm.db-adm = no.
          else
             UserDbAdm.db-block = yes.
      else
         UserDbAdm.db-usr = yes.
      vrowid = rowid(UserDbAdm).
      BRUserUbd:refresh () no-error.
      reposition BRUserUbd to rowid vrowid no-error .
      mchenglistubd = yes.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BtnDel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BtnDel Dialog-Frame
ON CHOOSE OF BtnDel IN FRAME Dialog-Frame /* Удалить */
DO:
   define variable vrowid as rowid no-undo.
   if available UserDbAdm
   then do:
      assign
         UserDbAdm.db-adm = no
         UserDbAdm.db-usr = no
         UserDbAdm.db-block = no.
         vrowid = rowid(UserDbAdm)
      .
      BRUserUbd:refresh () no-error.
      reposition BRUserUbd to rowid vrowid no-error .
      mchenglistubd = yes.
   end.
   
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-psn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-psn Dialog-Frame
ON CHOOSE OF b-psn IN FRAME Dialog-Frame /* Button 1 */
DO:
   RUN person-user IN THIS-PROCEDURE ( INPUT-OUTPUT fi-psn-code, INPUT-OUTPUT v-psn-name ).
   display
      fi-psn-code
      v-psn-name
   with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-last-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-last-name Dialog-Frame
ON ANY-PRINTABLE OF fi-last-name IN FRAME Dialog-Frame /* Фамилия */
or DELETE-CHARACTER OF fi-last-name IN FRAME Dialog-Frame
or BACKSPACE OF fi-last-name IN FRAME Dialog-Frame
or ANY-PRINTABLE OF fi-first-name IN FRAME Dialog-Frame
or DELETE-CHARACTER OF fi-first-name IN FRAME Dialog-Frame
or BACKSPACE OF fi-first-name IN FRAME Dialog-Frame
or ANY-PRINTABLE OF fi-second-name IN FRAME Dialog-Frame
or DELETE-CHARACTER OF fi-second-name IN FRAME Dialog-Frame
or BACKSPACE OF fi-second-name IN FRAME Dialog-Frame
DO:
    if v-user-nik-autofill = yes
    then do:
        assign
            fi-last-name
            fi-first-name
            fi-second-name
        .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-last-name Dialog-Frame
ON VALUE-CHANGED OF fi-last-name IN FRAME Dialog-Frame /* Фамилия */
or VALUE-CHANGED OF fi-first-name   IN FRAME Dialog-Frame
or VALUE-CHANGED OF fi-second-name  IN FRAME Dialog-Frame
DO:
    if v-user-nik-autofill = yes
    then do:
        assign
            fi-last-name
            fi-first-name
            fi-second-name
        .
        assign
            fi-nik = trim( substitute( "&1 &2 &3", fi-last-name, fi-first-name, fi-second-name ) )
        .
        display
            fi-nik
        with frame {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-nik
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-nik Dialog-Frame
ON LEAVE OF fi-nik IN FRAME Dialog-Frame
DO:
    assign
        fi-last-name
        fi-first-name
        fi-second-name
        fi-nik
    .
    run get-nik-autofill in this-procedure (
          input fi-last-name
        , input fi-first-name
        , input fi-second-name
        , input fi-nik
        , output v-user-nik-autofill
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-psn-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-psn-code Dialog-Frame
ON LEAVE OF fi-psn-code IN FRAME Dialog-Frame /* Физ. лицо */
DO:
   define buffer buf_clients     for ub.clients .

   assign
      fi-psn-code
   .

   FIND FIRST buf_clients
        WHERE buf_clients.obj-code = fi-psn-code
          and buf_clients.obj-type = {&prs}
        no-lock
        no-error
        .
   IF AVAILABLE buf_clients
   THEN DO:
      ASSIGN
         v-psn-name = buf_clients.obj-name
      .
   END.
   ELSE DO:
      assign
         fi-psn-code = ?
         v-psn-name  = "":U
      .
   END.

   display
      fi-psn-code
      v-psn-name
   with frame {&frame-name}.

END.

&Scoped-define SELF-NAME RAD-adm-gbd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RAD-adm-gbd Dialog-Frame
ON VALUE-CHANGED OF RAD-adm-gbd IN FRAME Dialog-Frame
DO:
   tog-superadm:visible = rad-adm-gbd:screen-value eq "1".
   if not tog-superadm:visible
   then
      tog-superadm:screen-value = "no".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME RAD-adm-Ubd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RAD-adm-Ubd Dialog-Frame
ON VALUE-CHANGED OF RAD-adm-Ubd IN FRAME Dialog-Frame
DO:
   btnAdm:visible   = RAD-adm-Ubd:screen-value eq "2" and mSyperAdm.
   BtnDel:visible   = RAD-adm-Ubd:screen-value eq "2" and mSyperAdm.
   BRUserUbd:visible = RAD-adm-Ubd:screen-value eq "2" or g#db-num ne 0.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BRUserUbd
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */
{ gbl/hot-key.i b-exit  }
{ gbl/hot-key.i b-close }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    { gbl/getcntxt.i get }
    run init-fields in this-procedure .
    RUN enable_UI.
    
    find first user-account-attr where user-account-attr.user-id    eq g#userid
                                   and user-account-attr.attr-code  eq "superadm"
    no-lock no-error.
    if     available user-account-attr
       and logical(user-account-attr.attr-value) eq yes
    then
       mSyperAdm = yes.  
    apply "VALUE-CHANGED" to rad-adm-gbd.
    apply "VALUE-CHANGED" to rad-adm-ubd.
    TOG-superAdm:sensitive = mSyperAdm.
    RAD-adm-gbd:sensitive = mSyperAdm.
    RAD-adm-Ubd:sensitive = mSyperAdm.
    RAD-adm-gbd:visible = g#db-num eq 0.
    RAD-adm-Ubd:visible = g#db-num eq 0.
    
    if p-mode = {&lookup}
    then do:
        disable
            all
        except
            b-help
            b-close
        with frame {&frame-name} .
        apply "entry":U to b-close.
    end.
    else do:
        apply "entry":U to fi-last-name.
    end.
    
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-user Dialog-Frame 
PROCEDURE check-user :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter p-have-error    as logical          no-undo.
    define output parameter p-error-desc    as character        no-undo.
    define output parameter p-focus-widget  as handle           no-undo.
do
with frame {&frame-name}
on error undo, return error
:
    if fi-nik :screen-value = "":U
    then do:
        assign
            p-have-error = yes
            p-error-desc = substitute( "Не задан псевдоним пользователя.&1&1Для корректного отображения пользователя в системе&1необходимо определить псевдоним.&1&1Определите псевдоним пользователя.", {&new-line} )
            p-focus-widget = fi-nik :handle
        .
    end.
    if fi-last-name :screen-value = "":U
    then do:
        if p-have-error = no
        then do:
            assign
                p-focus-widget = fi-last-name :handle
            .
        end.
        assign
            p-have-error = yes
            p-error-desc = substitute( "&2Не задана фамилия пользователя.&1&1Для корректного отображения пользователя в системе&1необходимо ввести фамилию.&1&1Введите фамилию пользователя."
                                , {&new-line}
                                , ( if p-error-desc = "":U then "":U else p-error-desc + {&new-line} + {&new-line} )
                                )
        .
    end.
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
  DISPLAY fi-last-name fi-first-name fi-second-name fi-PS-label-2 fi-nik 
          fi-phone-number fi-mobile-phone-number fi-company fi-department 
          fi-position fi-room fi-e-mail fi-internal-phone-number 
          fi-PS-label ed-PS fi-user-id 
          fi-psn-code v-psn-name 
          RAD-adm-gbd TOG-superAdm RAD-adm-Ubd
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-close b-help fi-last-name fi-first-name fi-second-name fi-nik 
         fi-phone-number fi-mobile-phone-number fi-company fi-department 
         fi-position fi-room fi-e-mail fi-internal-phone-number ed-PS
         fi-psn-code b-psn v-psn-name 
         btnAdm BtnDel 
         RAD-adm-gbd TOG-superAdm  RAD-adm-Ubd BRUserUbd 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-nik-autofill Dialog-Frame 
PROCEDURE get-nik-autofill :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input parameter p-last-name      as character        no-undo.
    define input parameter p-first-name     as character        no-undo.
    define input parameter p-second-name    as character        no-undo.
    define input parameter p-nik            as character        no-undo.
    define output parameter p-nik-autofill  as logical          no-undo.
do
on error undo, return error
:
    if p-nik = trim( substitute( "&1 &2 &3", p-last-name, p-first-name, p-second-name ) )
    then do:
        assign
            p-nik-autofill = yes
        .
    end.
    else do:
        assign
            p-nik-autofill = no
        .
    end.
end.
END PROCEDURE. /* get-nik-autofill */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-fields Dialog-Frame 
PROCEDURE init-fields :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    define buffer buf_clients     for ub.clients .

    assign
        v-user-exit-enabled = no
        p-accepted          = no
    .
    IF p-in-psn-code <> 0
    OR p-in-psn-code <> ?
    THEN DO:
      FIND FIRST buf_clients
           WHERE buf_clients.obj-code = p-in-psn-code
             and buf_clients.obj-type = {&prs}
           no-lock
           no-error
           .
    END.
    assign
        fi-user-id                  = p-in-user-id
        fi-last-name                = p-in-last-name
        fi-first-name               = p-in-first-name
        fi-second-name              = p-in-second-name
        fi-nik                      = p-in-nik
        fi-phone-number             = p-in-phone-number
        fi-mobile-phone-number      = p-in-mobile-phone-number
        fi-company                  = p-in-company
        fi-department               = p-in-department
        fi-position                 = p-in-position
        fi-room                     = p-in-room
        fi-e-mail                   = p-in-e-mail
        fi-internal-phone-number    = p-in-internal-phone-number
        ed-PS                       = p-in-PS
        fi-psn-code                 = p-in-psn-code
        v-psn-name                  = IF AVAILABLE buf_clients THEN buf_clients.obj-name ELSE "Не найден"
        rad-adm-gbd                 = if i-adm-gbd eq yes
                                      then 1
                                      else if i-adm-gbd eq no
                                      then 3
                                      else 2
        tog-superAdm                = i-superAdm
        rad-adm-Ubd                 = if i-adm-Ubd eq yes
                                      then 1
                                      else if i-adm-Ubd eq no
                                      then 3
                                      else 2
            
    .
    run get-nik-autofill in this-procedure (
          input fi-last-name
        , input fi-first-name
        , input fi-second-name
        , input fi-nik
        , output v-user-nik-autofill
    ).
end.
END PROCEDURE. /* init-fields */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE person-user Dialog-Frame 
PROCEDURE person-user :
/*------------------------------------------------------------------------------
Purpose:
Parameters:  <none>
Notes:
------------------------------------------------------------------------------*/
define input-output parameter p-code               as integer          no-undo.
define input-output parameter p-name               as character        no-undo.

do
on error undo, return error
:
   define buffer buf_clients     for ub.clients .

   define variable v-recid-person as character no-undo.

   /*
   IF p-code <> 0
   OR p-code <> ?
   THEN DO:
      FIND FIRST buf_clients
           WHERE buf_clients.obj-code = p-code
             and buf_clients.obj-type = {&prs}
           no-lock
           no-error
           .
      IF AVAILABLE buf_clients
      THEN DO:
         ASSIGN
           v-recid-person = string( recid( buf_clients ) )
         .
      END.
   END.
   */

   run ref/cli-all.w ( input parparentproc
                     , input "b-sel"
                     , input {&prs}
                     , input {&all}
                     , input {&current}
                     , input ?
                     , input ",,,,,,NO,,"
                     , input "lock-cli-type":U
                     , output v-recid-person
                     ) .
   IF v-recid-person <> "":U
   THEN DO:
      FIND FIRST buf_clients
           WHERE RECID(buf_clients) = INTEGER(ENTRY(1, v-recid-person))
           no-lock
           no-error
           .
      IF AVAILABLE buf_clients
      THEN DO:
         ASSIGN
            p-code = buf_clients.obj-code
            p-name = buf_clients.obj-name
         .
      END.  /* TRANSACTION */
      ELSE DO:
         assign
            p-code = ?
            p-name = "":U
         .
      END.
   END.
   /*
   ELSE DO:
      assign
         p-code = ?
         p-name = "":U
      .
   END.
   */
end.  /* do on error */
END PROCEDURE. /* person-user */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION GetAdm Dialog-Frame 
FUNCTION GetAdm RETURNS CHARACTER
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
  
  RETURN if UserDbAdm.db-adm 
         then "Администратор"
         else if UserDbAdm.db-block
         then "Заблокирована"
         else if UserDbAdm.db-usr
         then "Пользователь"
         else "Отсутствует"
           .   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


