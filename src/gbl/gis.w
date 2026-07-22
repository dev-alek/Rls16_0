&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
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

Редактирование секции Настройки для подключения к ГИС МТ и проверки КМ

Автор: Шкляр Елена Львовна
Дата создания: 15/11/03
Author: Elena Shklyar
Creation date: 15/11/03

This .W file was created with the Progress AppBuilder.

*/

define input parameter parparentproc as widget-handle no-undo.
define input parameter p-mode     as character no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-Workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование секции Настройки для подключения к ГИС МТ и проверки КМ" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/thbjattr.i }
{ gbl/onewin.i   }
{ str/def-thbjattr-list.i "new shared" }  

define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define temp-table x_thbj-attr no-undo like ub.thbj-attr.

define variable v-tth     as handle no-undo .

define variable v-tth-host as handle no-undo .
define variable v-to-create-host as logical no-undo.
define variable str-attr as character no-undo .

assign
v-tth      = buffer temp-thbj-attr:table-handle .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit RECT-1 RECT-2 RECT-3 B-quit B-Help ~
gisAdress cdnTurnOn cdnAdress Copy-cdnAdress registrationKey ~
Copy-registrationKey adressPort Copy-adressPort login password Copy-LogPass ~
dopParam Copy-dopParam OflineAdress Copy-OflineAdress OflineLogin ~
OflinePswd waitTime Copy-waitTime Resp_TH_required Copy-Resp MACC_Timeout ~
Copy-Timeout maxTime timeFalStart banDate cdnTimeUpdate MACC_IP MACC_PORT ~
Copy-THport LMCHzPort Copy-LMCHzPort addTimeoutPIoT Copy-addTimeoutPIoT ~
UpdateRequest crashSituat cdnChange cdnRepeat MaxApiToken Copy-MaxApiToken ~
AgeConfirmBox Copy-AgeConfirm Proxytext 
&Scoped-Define DISPLAYED-OBJECTS gisAdress cdnTurnOn cdnAdress ~
Copy-cdnAdress registrationKey Copy-registrationKey adressPort ~
Copy-adressPort login password Copy-LogPass dopParam Copy-dopParam ~
OflineAdress Copy-OflineAdress OflineLogin OflinePswd waitTime ~
Copy-waitTime Resp_TH_required Copy-Resp MACC_Timeout Copy-Timeout maxTime ~
timeFalStart banDate cdnTimeUpdate MACC_IP MACC_PORT Copy-THport LMCHzPort ~
Copy-LMCHzPort addTimeoutPIoT Copy-addTimeoutPIoT UpdateRequest crashSituat ~
cdnChange cdnRepeat MaxApiToken Copy-MaxApiToken AgeConfirmBox  ~
Copy-AgeConfirm TxtCopy TxtCopy-2 Proxytext 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1.

DEFINE BUTTON B-Help 
     LABEL "&Help" 
     SIZE 10 BY 1.

DEFINE BUTTON B-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1.

DEFINE VARIABLE AgeConfirmBox AS CHARACTER FORMAT "X(256)":U 
     LABEL "Проверка возраста при продаже НП" 
     VIEW-AS COMBO-BOX INNER-LINES 3
     LIST-ITEMS "Проверка отключена","Проверка при помощи соглашения оферты","Проверка при помощи MAX" 
     DROP-DOWN-LIST
     SIZE 40 BY 1 NO-UNDO.

DEFINE VARIABLE Resp_TH_required AS CHARACTER FORMAT "X(256)":U INITIAL "Да" 
     LABEL "Обязательность получения результатов проверки КМ в ТН" 
     VIEW-AS COMBO-BOX INNER-LINES 2
     LIST-ITEMS "Да","Нет" 
     DROP-DOWN-LIST
     SIZE 8 BY 1 NO-UNDO.

DEFINE VARIABLE addTimeoutPIoT AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 1 
     LABEL "Длительность обработки ответа ГИС МТ в ТС ПИоТ (секунды)" 
     VIEW-AS FILL-IN 
     SIZE 8 BY 1 NO-UNDO.

DEFINE VARIABLE adressPort AS CHARACTER FORMAT "X(256)":U 
     LABEL "Адрес и порт" 
     VIEW-AS FILL-IN 
     SIZE 71 BY 1 NO-UNDO.

DEFINE VARIABLE AgeConfirm AS INTEGER FORMAT ">9":U INITIAL 0.

DEFINE VARIABLE banDate AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 5 
     LABEL "Опережение срабатывания запрета по сроку годности в минутах" 
     VIEW-AS FILL-IN 
     SIZE 8 BY 1 NO-UNDO.

DEFINE VARIABLE cdnAdress AS CHARACTER FORMAT "X(256)":U 
     LABEL "Адрес cdn" 
     VIEW-AS FILL-IN 
     SIZE 72 BY 1 NO-UNDO.

DEFINE VARIABLE cdnTimeUpdate AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 24 
     LABEL "Период обновления списка CDN-площадок (часы)" 
     VIEW-AS FILL-IN 
     SIZE 8 BY 1 NO-UNDO.

DEFINE VARIABLE dopParam AS CHARACTER FORMAT "X(256)":U 
     LABEL "Дополнительные параметры запроса" 
     VIEW-AS FILL-IN 
     SIZE 51 BY 1 NO-UNDO.

DEFINE VARIABLE gisAdress AS CHARACTER FORMAT "X(256)":U 
     LABEL "Адрес ГИС МТ" 
     VIEW-AS FILL-IN 
     SIZE 72 BY 1 NO-UNDO.

DEFINE VARIABLE LMCHzPort AS CHARACTER FORMAT "X(256)":U 
     LABEL "Порт ЛМ ЧЗ" 
     VIEW-AS FILL-IN 
     SIZE 8 BY 1 NO-UNDO.

DEFINE VARIABLE login AS CHARACTER FORMAT "X(256)":U 
     LABEL "Логин" 
     VIEW-AS FILL-IN 
     SIZE 27 BY 1 NO-UNDO.

DEFINE VARIABLE MACC_IP AS CHARACTER FORMAT "X(256)":U 
     LABEL "IP адрес ТН" 
     VIEW-AS FILL-IN 
     SIZE 27 BY 1 NO-UNDO.

DEFINE VARIABLE MACC_PORT AS CHARACTER FORMAT "X(256)":U 
     LABEL "Порт проверки КМ в ТН" 
     VIEW-AS FILL-IN 
     SIZE 8 BY 1 NO-UNDO.

DEFINE VARIABLE MACC_Timeout AS DECIMAL FORMAT ">,>>>,>>9.99":U INITIAL 0 
     LABEL "Длительность ожидания ответа ТН (секунды)" 
     VIEW-AS FILL-IN 
     SIZE 8 BY 1 NO-UNDO.

DEFINE VARIABLE MaxApiToken AS CHARACTER FORMAT "X(256)":U 
     LABEL "Токен авторизации MAX" 
     VIEW-AS FILL-IN 
     SIZE 40 BY 1 NO-UNDO.

DEFINE VARIABLE maxTime AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 72 
     LABEL "Макс. допустимое время разрешения продажи при сбое онлайн проверки (часы)" 
     VIEW-AS FILL-IN 
     SIZE 8 BY 1 NO-UNDO.

DEFINE VARIABLE OflineAdress AS CHARACTER FORMAT "X(256)":U 
     LABEL "Адрес ЛМ ЧЗ" 
     VIEW-AS FILL-IN 
     SIZE 71 BY 1 NO-UNDO.

DEFINE VARIABLE OflineLogin AS CHARACTER FORMAT "X(256)":U 
     LABEL "Логин в ЛМ ЧЗ" 
     VIEW-AS FILL-IN 
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE OflinePswd AS CHARACTER FORMAT "X(256)":U 
     LABEL "Пароль" 
     VIEW-AS FILL-IN 
     SIZE 46 BY 1 NO-UNDO.

DEFINE VARIABLE password AS CHARACTER FORMAT "X(256)":U 
     LABEL "Пароль" 
     VIEW-AS FILL-IN 
     SIZE 34 BY 1 NO-UNDO.

DEFINE VARIABLE Proxytext AS CHARACTER FORMAT "x(13)" INITIAL "Прокси-сервер" 
      VIEW-AS TEXT 
     SIZE 17 BY .67.

DEFINE VARIABLE registrationKey AS CHARACTER FORMAT "X(256)":U 
     LABEL "Ключ авторизации" 
     VIEW-AS FILL-IN 
     SIZE 72 BY 1 NO-UNDO.

DEFINE VARIABLE timeFalStart AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 2 
     LABEL "Время с момента сбоя до начала уведомления персонала (часы)" 
     VIEW-AS FILL-IN 
     SIZE 8 BY 1 NO-UNDO.

DEFINE VARIABLE TxtCopy AS CHARACTER FORMAT "X(256)":U INITIAL "Копир." 
      VIEW-AS TEXT 
     SIZE 7 BY .63 NO-UNDO.

DEFINE VARIABLE TxtCopy-2 AS CHARACTER FORMAT "X(256)":U INITIAL "в ЛС" 
      VIEW-AS TEXT 
     SIZE 5 BY .63 NO-UNDO.

DEFINE VARIABLE waitTime AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 1.5 
     LABEL "Длительность ожидания ответа ГИС МТ (секунды)" 
     VIEW-AS FILL-IN 
     SIZE 8 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 108.5 BY 30.04.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 93 BY 3.08.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 9 BY 29.33.

DEFINE VARIABLE cdnChange AS LOGICAL INITIAL no 
     LABEL "Смена площадки" 
     VIEW-AS TOGGLE-BOX
     SIZE 23 BY .79 NO-UNDO.

DEFINE VARIABLE cdnRepeat AS LOGICAL INITIAL no 
     LABEL "Повторный опрос площадки" 
     VIEW-AS TOGGLE-BOX
     SIZE 33 BY .79 NO-UNDO.

DEFINE VARIABLE cdnTurnOn AS LOGICAL INITIAL no 
     LABEL "Работа с cdn-площадками" 
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY .79 NO-UNDO.

DEFINE VARIABLE Copy-addTimeoutPIoT AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .79 NO-UNDO.

DEFINE VARIABLE Copy-adressPort AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .79 NO-UNDO.

DEFINE VARIABLE Copy-AgeConfirm AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .79 NO-UNDO.

DEFINE VARIABLE Copy-cdnAdress AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .79 NO-UNDO.

DEFINE VARIABLE Copy-dopParam AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .79 NO-UNDO.

DEFINE VARIABLE Copy-LMCHzPort AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .79 NO-UNDO.

DEFINE VARIABLE Copy-LogPass AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .79 NO-UNDO.

DEFINE VARIABLE Copy-MaxApiToken AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .79 NO-UNDO.

DEFINE VARIABLE Copy-OflineAdress AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .79 NO-UNDO.

DEFINE VARIABLE Copy-registrationKey AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .79 NO-UNDO.

DEFINE VARIABLE Copy-Resp AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .79 NO-UNDO.

DEFINE VARIABLE Copy-THport AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .79 NO-UNDO.

DEFINE VARIABLE Copy-Timeout AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .79 NO-UNDO.

DEFINE VARIABLE Copy-waitTime AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .79 NO-UNDO.

DEFINE VARIABLE crashSituat AS LOGICAL INITIAL no 
     LABEL "Аварийная ситуация в ГИС МТ" 
     VIEW-AS TOGGLE-BOX
     SIZE 35 BY .79 NO-UNDO.

DEFINE VARIABLE UpdateRequest AS LOGICAL INITIAL no 
     LABEL "Обновление параметров при запросе КМ" 
     VIEW-AS TOGGLE-BOX
     SIZE 47 BY .79 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 92
     gisAdress AT ROW 2.42 COL 21 COLON-ALIGNED WIDGET-ID 118
     cdnTurnOn AT ROW 3.63 COL 23 WIDGET-ID 174
     cdnAdress AT ROW 4.58 COL 21 COLON-ALIGNED WIDGET-ID 118
     Copy-cdnAdress AT ROW 4.58 COL 97 HELP
          "Наследовать изменения на все секции" WIDGET-ID 192
     registrationKey AT ROW 5.75 COL 21 COLON-ALIGNED WIDGET-ID 142
     Copy-registrationKey AT ROW 5.75 COL 97 HELP
          "Наследовать изменения на все секции" WIDGET-ID 194
     adressPort AT ROW 7.79 COL 22 COLON-ALIGNED WIDGET-ID 144
     Copy-adressPort AT ROW 7.92 COL 97 HELP
          "Наследовать изменения на все секции" WIDGET-ID 196
     login AT ROW 9 COL 22 COLON-ALIGNED WIDGET-ID 146
     password AT ROW 9 COL 94 RIGHT-ALIGNED WIDGET-ID 148 PASSWORD-FIELD 
     Copy-LogPass AT ROW 9.08 COL 97 HELP
          "Наследовать изменения на все секции" WIDGET-ID 198
     dopParam AT ROW 10.75 COL 42 COLON-ALIGNED WIDGET-ID 154
     Copy-dopParam AT ROW 10.88 COL 97 HELP
          "Наследовать изменения на все секции" WIDGET-ID 200
     OflineAdress AT ROW 11.96 COL 22 COLON-ALIGNED WIDGET-ID 180
     Copy-OflineAdress AT ROW 12.04 COL 97 HELP
          "Наследовать изменения на все секции" WIDGET-ID 202
     OflineLogin AT ROW 13.13 COL 22 COLON-ALIGNED WIDGET-ID 182
     OflinePswd AT ROW 13.13 COL 94 RIGHT-ALIGNED WIDGET-ID 184
     waitTime AT ROW 14.58 COL 94 RIGHT-ALIGNED WIDGET-ID 156
     Copy-waitTime AT ROW 14.67 COL 97 HELP
          "Наследовать изменения на все секции" WIDGET-ID 206
     Resp_TH_required AT ROW 15.75 COL 94 RIGHT-ALIGNED WIDGET-ID 212
     Copy-Resp AT ROW 15.88 COL 97 HELP
          "Наследовать изменения на все секции" WIDGET-ID 208
     MACC_Timeout AT ROW 16.96 COL 94 RIGHT-ALIGNED WIDGET-ID 186
     Copy-Timeout AT ROW 16.96 COL 97 HELP
          "Наследовать изменения на все секции" WIDGET-ID 210
     maxTime AT ROW 18.13 COL 94 RIGHT-ALIGNED WIDGET-ID 168
     timeFalStart AT ROW 19.33 COL 94 RIGHT-ALIGNED WIDGET-ID 170
     banDate AT ROW 20.5 COL 94 RIGHT-ALIGNED WIDGET-ID 172
     cdnTimeUpdate AT ROW 21.71 COL 94 RIGHT-ALIGNED WIDGET-ID 168
     MACC_IP AT ROW 22.92 COL 22 COLON-ALIGNED WIDGET-ID 214
     MACC_PORT AT ROW 22.92 COL 85 COLON-ALIGNED WIDGET-ID 216
     Copy-THport AT ROW 22.92 COL 97 HELP
          "Наследовать изменения на все секции" WIDGET-ID 226
     LMCHzPort AT ROW 24.08 COL 85 COLON-ALIGNED WIDGET-ID 224
     Copy-LMCHzPort AT ROW 24.08 COL 97 HELP
          "Наследовать изменения на все секции" WIDGET-ID 228
     addTimeoutPIoT AT ROW 25.29 COL 94 RIGHT-ALIGNED WIDGET-ID 230
     Copy-addTimeoutPIoT AT ROW 25.29 COL 97 HELP
          "Наследовать изменения на все секции" WIDGET-ID 232
     UpdateRequest AT ROW 26.71 COL 11 HELP
          "Обновление параметров при запросе КМ" WIDGET-ID 176
     crashSituat AT ROW 26.71 COL 59 WIDGET-ID 174
     cdnChange AT ROW 27.67 COL 11 WIDGET-ID 174
     cdnRepeat AT ROW 27.67 COL 59 WIDGET-ID 174
     MaxApiToken AT ROW 29 COL 94 RIGHT-ALIGNED WIDGET-ID 234  
     Copy-MaxApiToken AT ROW 29 COL 97 HELP
          "Наследовать изменения на все секции" WIDGET-ID 240
     AgeConfirmBox AT ROW 30.25 COL 94 RIGHT-ALIGNED WIDGET-ID 242
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit WIDGET-ID 100.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame     
     Copy-AgeConfirm AT ROW 30.25 COL 97 HELP
          "Наследовать изменения на все секции" WIDGET-ID 236
     TxtCopy AT ROW 2.67 COL 95 COLON-ALIGNED NO-LABEL WIDGET-ID 220
     TxtCopy-2 AT ROW 3.38 COL 95 COLON-ALIGNED NO-LABEL WIDGET-ID 222
     Proxytext AT ROW 6.96 COL 39 COLON-ALIGNED NO-LABEL WIDGET-ID 152
     RECT-1 AT ROW 2.21 COL 1.5 WIDGET-ID 116
     RECT-2 AT ROW 7.21 COL 3 WIDGET-ID 150
     RECT-3 AT ROW 2.42 COL 96 WIDGET-ID 218
     SPACE(5.00) SKIP(0.60)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Настройки для подключения к ГИС МТ и проверки КМ"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN addTimeoutPIoT IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN AgeConfirm IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN banDate IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN cdnTimeUpdate IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN MACC_Timeout IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN MaxApiToken IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN maxTime IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN OflinePswd IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN password IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR COMBO-BOX Resp_TH_required IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN timeFalStart IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN TxtCopy IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN TxtCopy-2 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN waitTime IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Настройки для подключения к ГИС МТ и проверки КМ */
DO:
  run save-proc in this-procedure no-error.
  if error-status :error then return no-apply.
END.

&Scoped-define SELF-NAME B-Help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cdnTurnOn Dialog-Frame
ON VALUE-CHANGED OF cdnTurnOn IN FRAME {&FRAME-NAME}
DO: /* Call Help Function (or a simple message). */
    ASSIGN cdnTurnOn.
    if cdnTurnOn then do:
       disable gisAdress with frame {&frame-name} .
       enable cdnAdress with frame {&frame-name} .
   end.    
   else do:
       enable gisAdress with frame {&frame-name} .
       disable cdnAdress with frame {&frame-name} .
   end.       
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Настройки для подключения к ГИС МТ и проверки КМ */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME OflinePswd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL OflinePswd Dialog-Frame
ON ENTRY OF OflinePswd IN FRAME Dialog-Frame /* Пароль */
DO:
   self:SET-SELECTION(1,length (OflinePswd:screen-value) + 1).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME MaxApiToken
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL MaxApiToken Dialog-Frame
ON ENTRY OF MaxApiToken IN FRAME Dialog-Frame /* Пароль */
DO:
   self:SET-SELECTION(1,length (MaxApiToken:screen-value) + 1).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME AgeConfirmBox
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL AgeConfirmBox Dialog-Frame
ON VALUE-CHANGED OF AgeConfirmBox IN FRAME Dialog-Frame /* Пароль */
DO:
   assign AgeConfirmBox.   
   AgeConfirm = lookup(AgeConfirmBox, AgeConfirmBox:LIST-ITEMS,",") - 1.      
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

    RUN init-tt.
    RUN enable_UI.
    RUN fill-widgets.

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
  if p-obj-type = "" and p-obj-code = 0 
  then do:
      DISPLAY gisAdress cdnTurnOn cdnAdress Copy-cdnAdress registrationKey 
            Copy-registrationKey adressPort Copy-adressPort login password 
            Copy-LogPass dopParam Copy-dopParam OflineAdress Copy-OflineAdress 
            OflineLogin waitTime Copy-waitTime 
            Resp_TH_required Copy-Resp MACC_Timeout Copy-Timeout maxTime 
            timeFalStart banDate cdnTimeUpdate MACC_PORT Copy-THport 
            LMCHzPort Copy-LMCHzPort addTimeoutPIoT Copy-addTimeoutPIoT 
            UpdateRequest crashSituat cdnChange cdnRepeat 
            TxtCopy TxtCopy-2 Proxytext MaxApiToken Copy-MaxApiToken 
            AgeConfirmBox Copy-AgeConfirm
      WITH FRAME Dialog-Frame.
      ENABLE B-exit RECT-1 RECT-2 RECT-3 B-quit B-Help gisAdress cdnTurnOn 
             cdnAdress Copy-cdnAdress registrationKey Copy-registrationKey 
             adressPort Copy-adressPort login password Copy-LogPass dopParam 
             Copy-dopParam OflineAdress Copy-OflineAdress OflineLogin OflinePswd 
             waitTime Copy-waitTime Resp_TH_required Copy-Resp 
             MACC_Timeout Copy-Timeout maxTime timeFalStart banDate cdnTimeUpdate 
             MACC_PORT Copy-THport LMCHzPort Copy-LMCHzPort addTimeoutPIoT Copy-addTimeoutPIoT 
             UpdateRequest crashSituat cdnChange cdnRepeat Proxytext MaxApiToken Copy-MaxApiToken 
             AgeConfirmBox Copy-AgeConfirm
      WITH FRAME Dialog-Frame.                  
      MACC_IP:VISIBLE = false.      
      VIEW FRAME Dialog-Frame.
  end.
  else if p-obj-type = {&region} then do:
     DISPLAY gisAdress cdnTurnOn cdnAdress Copy-cdnAdress registrationKey 
            Copy-registrationKey adressPort Copy-adressPort login password 
            Copy-LogPass dopParam Copy-dopParam OflineAdress Copy-OflineAdress 
            OflineLogin waitTime Copy-waitTime 
            Resp_TH_required Copy-Resp MACC_Timeout Copy-Timeout  
            MACC_PORT Copy-THport LMCHzPort Copy-LMCHzPort addTimeoutPIoT 
            Copy-addTimeoutPIoT crashSituat TxtCopy TxtCopy-2 Proxytext 
            MaxApiToken Copy-MaxApiToken AgeConfirmBox Copy-AgeConfirm
      WITH FRAME Dialog-Frame.
      ENABLE B-exit RECT-1 RECT-2 RECT-3 B-quit B-Help gisAdress cdnTurnOn 
             cdnAdress Copy-cdnAdress registrationKey Copy-registrationKey 
             adressPort Copy-adressPort login password Copy-LogPass dopParam 
             Copy-dopParam OflineAdress Copy-OflineAdress OflineLogin OflinePswd 
             waitTime Copy-waitTime Resp_TH_required Copy-Resp 
             MACC_Timeout Copy-Timeout MACC_PORT Copy-THport LMCHzPort 
             Copy-LMCHzPort addTimeoutPIoT Copy-addTimeoutPIoT 
             crashSituat Proxytext MaxApiToken Copy-MaxApiToken 
             AgeConfirmBox Copy-AgeConfirm
      WITH FRAME Dialog-Frame.
           
      ASSIGN
         maxTime:VISIBLE = false
         timeFalStart:VISIBLE = false 
         banDate:VISIBLE = false 
         cdnTimeUpdate:VISIBLE = false 
         cdnRepeat:VISIBLE = false          
         cdnChange:VISIBLE = false
         UpdateRequest:VISIBLE = false    
         MACC_IP:VISIBLE = false     
      .
      VIEW FRAME Dialog-Frame. 
  end.    
  else do:
      DISPLAY OflineAdress OflineLogin OflinePswd gisAdress cdnTurnOn
              cdnAdress registrationKey adressPort login password
              dopParam waitTime Proxytext crashSituat
              MACC_Timeout Resp_TH_required MACC_IP MACC_PORT LMCHzPort
              addTimeoutPIoT MaxApiToken AgeConfirmBox  
          WITH FRAME Dialog-Frame.
      
      ENABLE B-exit B-quit OflineAdress OflineLogin OflinePswd gisAdress cdnTurnOn
              cdnAdress registrationKey adressPort login password
              dopParam waitTime crashSituat MACC_Timeout Resp_TH_required
              MACC_IP MACC_PORT LMCHzPort addTimeoutPIoT MaxApiToken AgeConfirmBox   
          WITH FRAME Dialog-Frame.      
      ASSIGN
         maxTime:VISIBLE = false
         timeFalStart:VISIBLE = false 
         banDate:VISIBLE = false 
         cdnTimeUpdate:VISIBLE = false 
         cdnRepeat:VISIBLE = false          
         cdnChange:VISIBLE = false
         UpdateRequest:VISIBLE = false
         Copy-cdnAdress:VISIBLE = false 
         Copy-registrationKey:VISIBLE = false 
         Copy-adressPort:VISIBLE = false 
         Copy-LogPass:VISIBLE = false
         Copy-dopParam:VISIBLE = false 
         Copy-OflineAdress:VISIBLE = false          
         Copy-waitTime:VISIBLE = false 
         Copy-Resp:VISIBLE = false 
         Copy-Timeout:VISIBLE = false 
         Copy-THport:VISIBLE = false 
         Copy-LMCHzPort:VISIBLE = false
         Copy-addTimeoutPIoT:VISIBLE = false
         TxtCopy:VISIBLE = false 
         TxtCopy-2:VISIBLE = false
         RECT-3:VISIBLE = false
         Copy-AgeConfirm:VISIBLE = false
         Copy-MaxApiToken:VISIBLE = false
      .
      VIEW FRAME Dialog-Frame.
  end.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}   
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-widgets Dialog-Frame 
PROCEDURE fill-widgets :
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
define variable v-param-value as character no-undo .

for each temp-thbj-attr:
  delete temp-thbj-attr.
end.

run adm/shattri.p (
    input "init":U
  , input p-obj-type
  , input p-obj-code
  , input {&attr-gisMT}
  , input "":U
  , output v-value-character
  , output v-value-date
  , output v-value-decimal
  , output v-value-integer
  , output v-value-logical
  , output v-param-type
  , input-output TABLE-HANDLE v-tth
  ) no-error .
if error-status:error then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.

FOR EACH temp-thbj-attr
  :                                       
    if p-obj-type eq "" and p-obj-code = 0
    then do:
        IF temp-thbj-attr.prop-code = {&attr-gisMT_maxTime} THEN DO:
           maxTime = temp-thbj-attr.property-value-integer.
           display maxTime with frame {&frame-name} .
        END.
        else IF temp-thbj-attr.prop-code = {&attr-gisMT_timeFalStart} THEN DO:
           timeFalStart = temp-thbj-attr.property-value-integer.
           display timeFalStart with frame {&frame-name} .
        END.
        else IF temp-thbj-attr.prop-code = {&attr-gisMT_crashSituat} THEN DO:
           crashSituat = temp-thbj-attr.property-value-logical.
           display crashSituat with frame {&frame-name} .
        END.
        else IF temp-thbj-attr.prop-code = {&attr-gisMT_banDate} THEN DO:
           banDate = temp-thbj-attr.property-value-integer.
           display banDate with frame {&frame-name} .
        END. 
        else IF temp-thbj-attr.prop-code = {&attr-gisMT_cdnRepeat} THEN DO:
           cdnRepeat = temp-thbj-attr.property-value-logical.
           display cdnRepeat with frame {&frame-name} .
        END.
        else IF temp-thbj-attr.prop-code = {&attr-gisMT_cdnChange} THEN DO:
           cdnChange = temp-thbj-attr.property-value-logical.
           display cdnChange with frame {&frame-name} .
        END. 
        else IF temp-thbj-attr.prop-code = {&attr-gisMT_cdnTimeUpdate} THEN DO:
           cdnTimeUpdate = temp-thbj-attr.property-value-integer.
           display cdnTimeUpdate with frame {&frame-name} .
        END.
        else IF temp-thbj-attr.prop-code = {&attr-gisMT_UpdateRequest} THEN DO:
           UpdateRequest = temp-thbj-attr.property-value-logical.
           display UpdateRequest with frame {&frame-name} .
        END.
    end.    
    IF temp-thbj-attr.prop-code = {&attr-gisMT_adressPort} THEN DO:
        adressPort = temp-thbj-attr.property-value-character.
        display adressPort with frame {&frame-name} .
     END.
     else IF temp-thbj-attr.prop-code = {&attr-gisMT_dopParam} THEN DO:
        dopParam = temp-thbj-attr.property-value-character.
        display dopParam with frame {&frame-name} .
     END.
     else IF temp-thbj-attr.prop-code = {&attr-gisMT_gisAdress} THEN DO:
        gisAdress = temp-thbj-attr.property-value-character.
        display gisAdress with frame {&frame-name} .
     END.
     else IF temp-thbj-attr.prop-code = {&attr-gisMT_proxyLogin} THEN DO:
        login = temp-thbj-attr.property-value-character.
        display login with frame {&frame-name} .
     END.
     else IF temp-thbj-attr.prop-code = {&attr-gisMT_proxyPswd} THEN DO:
        password = temp-thbj-attr.property-value-character.
        display password with frame {&frame-name} .
     END.
     else IF temp-thbj-attr.prop-code = {&attr-gisMT_regKey} THEN DO:
        registrationKey = temp-thbj-attr.property-value-character.
        display registrationKey with frame {&frame-name} .
     END.
     else IF temp-thbj-attr.prop-code = {&attr-gisMT_waitTime} THEN DO:
        waitTime = temp-thbj-attr.property-value-decimal.
        display waitTime with frame {&frame-name} .
     END.
     else IF temp-thbj-attr.prop-code = {&attr-gisMT_cdnTurnOn} THEN DO:
        cdnTurnOn = temp-thbj-attr.property-value-logical.
        display cdnTurnOn with frame {&frame-name} .
     END.    
     else IF temp-thbj-attr.prop-code = {&attr-gisMT_cdnAdress} THEN DO:
        cdnAdress = temp-thbj-attr.property-value-character.
        display cdnAdress with frame {&frame-name} .
     END.
    else IF temp-thbj-attr.prop-code = {&attr-gisMT_OflineAdress} THEN DO:
       OflineAdress = temp-thbj-attr.property-value-character.
       display OflineAdress with frame {&frame-name} .
    END.
    else IF temp-thbj-attr.prop-code = {&attr-gisMT_OflineLogin} THEN DO:
       OflineLogin = temp-thbj-attr.property-value-character.
       display OflineLogin with frame {&frame-name} .
    END.
    else IF temp-thbj-attr.prop-code = {&attr-gisMT_OflinePswd} THEN DO:
       OflinePswd = fill("*",length (temp-thbj-attr.property-value-character)).
       display OflinePswd with frame {&frame-name} .
    END.
    else IF temp-thbj-attr.prop-code = {&attr-gisMT_crashSituat} THEN DO:
       crashSituat = temp-thbj-attr.property-value-logical.
       display crashSituat with frame {&frame-name} .
    END.       
    else if temp-thbj-attr.prop-code = {&attr-gisMT_MACC_Timeout} then do:            
       MACC_Timeout = temp-thbj-attr.property-value-decimal.       
       display MACC_Timeout with frame {&frame-name} .
    end.   
    else if temp-thbj-attr.prop-code = {&attr-gisMT_Resp_TH_required} then do:
    if available temp-thbj-attr
    then
       Resp_TH_required = if temp-thbj-attr.property-value-integer = 1 then "Да" else "Нет".
       display Resp_TH_required with frame {&frame-name} .
    end.    
    else if temp-thbj-attr.prop-code = {&attr-gisMT_TH_IP}
            and p-obj-type = {&db} 
    then do:                               
       MACC_IP = temp-thbj-attr.property-value-character.
       display MACC_IP with frame {&frame-name} . 
    end.
    else if temp-thbj-attr.prop-code = {&attr-gisMT_TH_Port} then do:                            
       MACC_PORT = temp-thbj-attr.property-value-character.
       display MACC_PORT with frame {&frame-name} .
    end.
    else if temp-thbj-attr.prop-code = {&attr-gisMT_LmCHzPort} then do:                     
       LMCHzPort = temp-thbj-attr.property-value-character.
       display LMCHzPort with frame {&frame-name} .
    end.
    else if temp-thbj-attr.prop-code = {&attr-gisMT_AddTimeoutPIoT} then do:                     
       AddTimeoutPIoT = temp-thbj-attr.property-value-decimal.
       display AddTimeoutPIoT with frame {&frame-name} .
    end.
    else if temp-thbj-attr.prop-code = {&attr-gisMT_MaxApiToken} then do:
       MaxApiToken = fill("*",length (temp-thbj-attr.property-value-character)).                            
       display MaxApiToken with frame {&frame-name} .
    end.
    else if temp-thbj-attr.prop-code = {&attr-gisMT_AgeConfirm} then do:                     
       AgeConfirm = temp-thbj-attr.property-value-integer.      
    end.
    else if p-obj-type ne ""
    then do:
       delete temp-thbj-attr.
    end.   
END.
   if p-mode NE {&lookup} then do:
       if cdnTurnOn then do:
          disable gisAdress with frame {&frame-name} .
          enable cdnAdress with frame {&frame-name} .
       end.    
       else do:
          enable gisAdress with frame {&frame-name} .
          disable cdnAdress with frame {&frame-name} .
       end.    
   end.   
   AgeConfirmBox =  entry((AgeConfirm + 1), AgeConfirmBox:LIST-ITEMS,",").
   display AgeConfirmBox  with frame {&frame-name} .
   /*disable AgeConfirm  with frame {&frame-name} .*/
   if p-mode = {&lookup} then do:
      disable all WITH FRAME {&frame-name} .
      ENABLE B-quit b-help WITH FRAME {&frame-name}.
      B-quit:label = "Вы&ход"  .
      hide B-exit in frame {&frame-name} .
   end.   
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-tt Dialog-Frame 
PROCEDURE init-tt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-proc Dialog-Frame 
PROCEDURE save-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
define variable v-gds-copy-list as character no-undo .
define variable v-gdsreffi as character no-undo .
define variable wh as widget-handle no-undo .
define variable fh as widget-handle no-undo .
define variable v-same as logical no-undo .

define buffer buf_temp-thbj-attr for temp-thbj-attr .

IF p-mode = {&LOOKUP} THEN RETURN ERROR.

ASSIGN FRAME {&FRAME-NAME}
    adressPort 
    dopParam
    gisAdress
    login
    password
    maxTime
    registrationKey
    timeFalStart
    waitTime
    crashSituat
    banDate
    cdnTurnOn
    cdnAdress
    cdnRepeat
    cdnChange
    cdnTimeUpdate
    UpdateRequest    
    OflineAdress
    OflineLogin
    OflinePswd     
    MACC_Timeout
    Resp_TH_required 
    MACC_IP 
    MACC_PORT 
    LMCHzPort
    AddTimeoutPIoT
    MaxApiToken    
    Copy-cdnAdress 
    Copy-registrationKey 
    Copy-adressPort 
    Copy-LogPass
    Copy-dopParam 
    Copy-OflineAdress    
    Copy-waitTime 
    Copy-Resp 
    Copy-Timeout 
    Copy-THport 
    Copy-LMCHzPort
    Copy-addTimeoutPIoT
    Copy-AgeConfirm
    Copy-MaxApiToken
    .
    for each temp-thbj-attr where 
             temp-thbj-attr.obj-type = p-obj-type and
             temp-thbj-attr.obj-code = p-obj-code:  
       case temp-thbj-attr.prop-code:          
           when {&attr-gisMT_adressPort} 
           then do:
              if temp-thbj-attr.property-value-character <> adressPort
              then do:                  
                 create thbjattr-list.
                 buffer-copy temp-thbj-attr to thbjattr-list.                
              end.   
              temp-thbj-attr.property-value-character = adressPort.
           end.   
           when {&attr-gisMT_dopParam} then
              temp-thbj-attr.property-value-character = dopParam.
           when {&attr-gisMT_gisAdress} then
              temp-thbj-attr.property-value-character = gisAdress.
           when {&attr-gisMT_proxyLogin} 
           then do:
               if temp-thbj-attr.property-value-character <> login
              then do: 
                 create thbjattr-list.
                 buffer-copy temp-thbj-attr to thbjattr-list.
              end.  
              temp-thbj-attr.property-value-character = login.
           end.   
           when  {&attr-gisMT_proxyPswd} 
           then do:
              if temp-thbj-attr.property-value-character <> password
              then do: 
                 create thbjattr-list.
                 buffer-copy temp-thbj-attr to thbjattr-list.
              end.  
              temp-thbj-attr.property-value-character = password.
           end.   
           when {&attr-gisMT_maxTime} 
           then do:
              if temp-thbj-attr.property-value-integer <> maxTime
              then do: 
                 create thbjattr-list.
                 buffer-copy temp-thbj-attr to thbjattr-list.
              end.
              temp-thbj-attr.property-value-integer = maxTime.
           end.   
           when {&attr-gisMT_regKey} then
              temp-thbj-attr.property-value-character = registrationKey.
           when {&attr-gisMT_timeFalStart} 
           then do:
              if temp-thbj-attr.property-value-integer = timeFalStart
              then do: 
                 create thbjattr-list.
                 buffer-copy temp-thbj-attr to thbjattr-list.
              end.
              temp-thbj-attr.property-value-integer = timeFalStart.
           end.   
           when {&attr-gisMT_waitTime} 
           then do:          
               if temp-thbj-attr.property-value-decimal <> waitTime 
               then do:
                  create thbjattr-list.
                  buffer-copy temp-thbj-attr to thbjattr-list.
               end.    
               temp-thbj-attr.property-value-decimal = waitTime.
           end.       
           when {&attr-gisMT_crashSituat} 
           then do:
              if temp-thbj-attr.property-value-logical <> crashSituat
              then do: 
                 create thbjattr-list.
                 buffer-copy temp-thbj-attr to thbjattr-list.
              end.
              temp-thbj-attr.property-value-logical = crashSituat.
           end.   
           when {&attr-gisMT_banDate} 
           then do:
              if temp-thbj-attr.property-value-integer <> banDate
              then do: 
                 create thbjattr-list.
                 buffer-copy temp-thbj-attr to thbjattr-list.
              end.
              temp-thbj-attr.property-value-integer = banDate.
           end.   
           when {&attr-gisMT_cdnTurnOn} then
              temp-thbj-attr.property-value-logical = cdnTurnOn.
           when {&attr-gisMT_cdnAdress} then
              temp-thbj-attr.property-value-character = cdnAdress.
           when {&attr-gisMT_cdnRepeat} then
              temp-thbj-attr.property-value-logical = cdnRepeat.
           when {&attr-gisMT_cdnChange} then
              temp-thbj-attr.property-value-logical = cdnChange.
           when {&attr-gisMT_cdnTimeUpdate} then
              temp-thbj-attr.property-value-integer = cdnTimeUpdate.
           when {&attr-gisMT_UpdateRequest} then 
              temp-thbj-attr.property-value-logical = UpdateRequest.
           when {&attr-gisMT_OflineAdress} then
              temp-thbj-attr.property-value-character = OflineAdress.
           when {&attr-gisMT_OflineLogin} 
           then do:               
              if temp-thbj-attr.property-value-character <> OflineLogin
              then do: 
                 create thbjattr-list.
                 buffer-copy temp-thbj-attr to thbjattr-list.
              end.   
              temp-thbj-attr.property-value-character = OflineLogin.
           end.   
           when {&attr-gisMT_OflinePswd} 
           then do:      
              if (OflinePswd eq "" or (replace(OflinePswd,"*","") ne "" and OflinePswd ne ?)) then
              do:
                 if temp-thbj-attr.property-value-character <> OflinePswd
                 then do:
                    create thbjattr-list.
                    buffer-copy temp-thbj-attr to thbjattr-list. 
                 end.  
                 temp-thbj-attr.property-value-character = OflinePswd.
              end.   
           end.      
           when {&attr-gisMT_MACC_Timeout} 
           then do:        
               if temp-thbj-attr.property-value-decimal <> MACC_Timeout 
               then do:
                  create thbjattr-list.
                  buffer-copy temp-thbj-attr to thbjattr-list.
               end.    
               temp-thbj-attr.property-value-decimal = MACC_Timeout.
           end.   
           when {&attr-gisMT_Resp_TH_required} 
           then do:
               if (temp-thbj-attr.property-value-integer = 0 and Resp_TH_required = "Да") or
                  (temp-thbj-attr.property-value-integer = 1 and Resp_TH_required <> "Да")
               then do:
                  create thbjattr-list.
                  buffer-copy temp-thbj-attr to thbjattr-list.
               end.    
               temp-thbj-attr.property-value-integer = if Resp_TH_required = "Да" then 1 else 0.
           end.
           when {&attr-gisMT_TH_IP} then do:               
              if MACC_IP <> "" and temp-thbj-attr.property-value-character <> MACC_IP
              then do: 
                 create thbjattr-list.
                 buffer-copy temp-thbj-attr to thbjattr-list.
              end.   
              temp-thbj-attr.property-value-character = MACC_IP.
           end.
           when {&attr-gisMT_TH_Port} then do:               
              if temp-thbj-attr.property-value-character <> MACC_PORT
              then do: 
                 create thbjattr-list.
                 buffer-copy temp-thbj-attr to thbjattr-list.
              end.   
              temp-thbj-attr.property-value-character = MACC_PORT.
           end.
           when {&attr-gisMT_LmCHzPort} then do:               
              if temp-thbj-attr.property-value-character <> LMCHzPort
              then do: 
                 create thbjattr-list.
                 buffer-copy temp-thbj-attr to thbjattr-list.
              end.   
              temp-thbj-attr.property-value-character = LMCHzPort.
           end.
           when {&attr-gisMT_AddTimeoutPIoT} then do:               
              if temp-thbj-attr.property-value-decimal <> AddTimeoutPIoT
              then do: 
                 create thbjattr-list.
                 buffer-copy temp-thbj-attr to thbjattr-list.
              end.   
              temp-thbj-attr.property-value-decimal = AddTimeoutPIoT.
           end.
           when {&attr-gisMT_MaxApiToken} then do:   
              if (MaxApiToken eq "" or (replace(MaxApiToken,"*","") ne "" and MaxApiToken ne ?)) then
              do:   
                  if temp-thbj-attr.property-value-character <> MaxApiToken
                  then do: 
                     create thbjattr-list.
                     buffer-copy temp-thbj-attr to thbjattr-list.
                  end.                 
                  temp-thbj-attr.property-value-character = MaxApiToken.
              end.               
           end.
           when {&attr-gisMT_AgeConfirm} then do:
              if temp-thbj-attr.property-value-integer <> AgeConfirm
              then do: 
                 create thbjattr-list.
                 buffer-copy temp-thbj-attr to thbjattr-list.
              end.                        
              temp-thbj-attr.property-value-integer = AgeConfirm.           
           end.
       end. /* case */    
    end. /* for each */              

    do transaction:
        RUN thbjattr_set-section IN THIS-PROCEDURE (
             input p-obj-type
            ,input p-obj-code
            ,input {&attr-gisMT}
            ,INPUT table temp-thbj-attr
        ) NO-ERROR.
        if error-status:error then do:
            message "Не удалось сохранить настройки"
            view-as alert-box.
            undo, return error.
        end.
        /* отсылка изменения параметров на кассы для магазинов */
        if p-obj-type eq {&db} and 
           can-find(first thbjattr-list) then 
        run str/diallog.w (
            input parparentproc
          , input this-procedure
          , input "str/send-all.p":U
          , input ( p-obj-type + {&delim-par} + string(p-obj-code) + {&delim-par} + 'U':U + {&delim-par} + 'gismt':U + {&delim-par} + 'Передача параметров работы с ТСПИоТ':U)
          , input ? /*p-auto-go*/
          , input "":U
          , input substitute("Отсылка параметров работы с ТСПИоТ")
          ) no-error.
        /* копирование в локальные секции параметров при изменении для ТБД */  
        if p-obj-type ne {&db} and 
           (Copy-cdnAdress       or
            Copy-registrationKey or
            Copy-adressPort      or 
            Copy-LogPass         or 
            Copy-dopParam        or
            Copy-OflineAdress    or            
            Copy-waitTime        or
            Copy-Resp            or
            Copy-Timeout         or 
            Copy-THport          or
            Copy-LMCHzPort       or
            Copy-addTimeoutPIoT  or
            Copy-MaxApiToken     or
            Copy-AgeConfirm) 
        then do:                
            MESSAGE "Подтверждаете изменение значений в локальных секциях?" 
                VIEW-AS ALERT-BOX QUESTION 
                BUTTONS YES-NO 
                UPDATE v-copy AS LOGICAL.
            if v-copy then do:
               run ObjCodeCreate.
               if Copy-cdnAdress then run PropCopy({&attr-gisMT_cdnAdress}).
               if Copy-registrationKey then run PropCopy({&attr-gisMT_regKey}).
               if Copy-adressPort then run PropCopy({&attr-gisMT_adressPort}).
               if Copy-LogPass then do:
                  run PropCopy({&attr-gisMT_proxyLogin}).
                  run PropCopy({&attr-gisMT_proxyPswd}).
               end.   
               if Copy-dopParam then run PropCopy({&attr-gisMT_dopParam}).
               if Copy-OflineAdress then run PropCopy({&attr-gisMT_OflineAdress}).                   
               if Copy-waitTime then run PropCopy({&attr-gisMT_waitTime}).
               if Copy-Resp then run PropCopy({&attr-gisMT_Resp_TH_required}).
               if Copy-Timeout then run PropCopy({&attr-gisMT_MACC_Timeout}).
               if Copy-THport then run PropCopy({&attr-gisMT_TH_Port}).
               if Copy-LMCHzPort then run PropCopy({&attr-gisMT_LmCHzPort}).
               if Copy-addTimeoutPIoT then run PropCopy({&attr-gisMT_addTimeoutPIoT}).
               if Copy-MaxApiToken then run PropCopy({&attr-gisMT_MaxApiToken}).
               if Copy-AgeConfirm then run PropCopy({&attr-gisMT_AgeConfirm}).
            end.          
         end.        
    end.


END PROCEDURE.

PROCEDURE ObjCodeCreate:    
   define buffer buf_thbj-attr for ub.thbj-attr.
   define variable v-reg-code as integer no-undo.
   bth:
   for each buf_thbj-attr no-lock where  
           (buf_thbj-attr.obj-type = {&db}    
        and buf_thbj-attr.prop-code       = ''                 
        and buf_thbj-attr.upper-prop-code = {&attr-gisMT}
            )
        or (p-obj-type = "" 
        and buf_thbj-attr.obj-type = {&region}    
        and buf_thbj-attr.prop-code       = ''                 
        and buf_thbj-attr.upper-prop-code = {&attr-gisMT})
        :
            
      /* проверяем, что если копируем с региона, то только на БД этого региона */
      if p-obj-type = {&region} then do:
          { gbl/regcode.i buf_thbj-attr.obj-type buf_thbj-attr.obj-code v-reg-code }
          if v-reg-code <> p-obj-code then next bth.
      end.    
           
      find first x_thbj-attr where
          x_thbj-attr.obj-type = buf_thbj-attr.obj-type and
          x_thbj-attr.obj-code = buf_thbj-attr.obj-code no-error .

      if not available x_thbj-attr then do:
        create  x_thbj-attr.
        buffer-copy buf_thbj-attr to X_thbj-attr.        
      end.    
   end.    
       
END PROCEDURE.    

PROCEDURE PropCopy:   
    define input parameter p-prop-code as character no-undo. 
    define buffer buf_thbj-attr for ub.thbj-attr.
    define buffer thbj-attr for ub.thbj-attr.
    
    find first thbj-attr where 
               thbj-attr.obj-type = p-obj-type 
           and thbj-attr.obj-code = p-obj-code   
           and thbj-attr.upper-prop-code = {&attr-gisMT} 
           and thbj-attr.prop-code = p-prop-code
         no-lock no-error.
    if avail thbj-attr then 
    do transaction:   
        for each x_thbj-attr:                         
           find first buf_thbj-attr exclusive-lock where  
                      buf_thbj-attr.obj-type = x_thbj-attr.obj-type
                  and buf_thbj-attr.obj-code = x_thbj-attr.obj-code          
                  and buf_thbj-attr.upper-prop-code = {&attr-gisMT}
                  and buf_thbj-attr.prop-code = p-prop-code 
           no-wait no-error.
           if not avail buf_thbj-attr 
              and not locked buf_thbj-attr 
           then do:
               create buf_thbj-attr.
               assign
                  buf_thbj-attr.obj-type = {&db}  
                  buf_thbj-attr.obj-code = x_thbj-attr.obj-code
                  .
           end.   
           if avail buf_thbj-attr then         
           buffer-copy  thbj-attr except obj-type obj-code to buf_thbj-attr.      
        end.
    end.            
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

