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

Диалог выбора товара

Автор: Гридчина Полина Дмитриевна
Дата создания: 04/17/07
Author: Polina Gridchina
Creation date: 04/17/07

*/

/* Диалог выбора предусматривает развитие программы для работы со списком товаров, но на данном этапе реализван выбор
только одного товара*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEF TEMP-TABLE tt-gds NO-UNDO
    FIELD gds-code LIKE ub.goods.gds-code.

DEFINE INPUT parameter parparentproc as widget-handle no-undo .
DEFINE INPUT-OUTPUT PARAMETER TABLE FOR tt-gds .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Диалог выбора товара".
{ cmp/vssrevis.i }


/* Local Variable Definitions --- */
{ cmp/str-glbl.i }
{ cmp/gds-list.i gds-list def "new shared" }
{ cmp/library.i  }
{ cmp/showinf.i  }
/* { gbl/usr-flt.i  } */
{ ref/grp-attr.i }
{ gbl/getcntxt.i def }


DEFINE BUFFER gds-b FOR ub.goods.
DEFINE BUFFER g-producer FOR ub.clients.
DEF VAR ref-list AS CHAR.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Fartic B-gds B-list Fprod-code Fprod-type ~
b-sel b-quit b-help
&Scoped-Define DISPLAYED-OBJECTS Fartic Fprod-code Fprod-type

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-gds
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3.13 BY 1.04 TOOLTIP "Выбор товара из справочника"
     BGCOLOR 8 FGCOLOR 0 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-list
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3.13 BY 1.04 TOOLTIP "Выбор товара из списка"
     BGCOLOR 8 FGCOLOR 0 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sel AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE Fartic AS CHARACTER FORMAT "X(256)":U
     LABEL "Артикул"
     VIEW-AS FILL-IN
     SIZE 22 BY 1 NO-UNDO.

DEFINE VARIABLE Fprod-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "Производитель"
     VIEW-AS FILL-IN
     SIZE 14.5 BY 1 NO-UNDO.

DEFINE VARIABLE Fprod-type AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 5.5 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Fartic AT ROW 1.5 COL 16 COLON-ALIGNED WIDGET-ID 2
     B-gds AT ROW 1.5 COL 40.5 WIDGET-ID 8
     B-list AT ROW 1.5 COL 43.5 WIDGET-ID 10
     Fprod-code AT ROW 2.5 COL 16 COLON-ALIGNED WIDGET-ID 4
     Fprod-type AT ROW 2.5 COL 32.5 COLON-ALIGNED NO-LABEL WIDGET-ID 6
     b-sel AT ROW 4.75 COL 14
     b-quit AT ROW 4.75 COL 28.5
     b-help AT ROW 5 COL 39
     SPACE(0.37) SKIP(0.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выбор товара"
         DEFAULT-BUTTON b-sel CANCEL-BUTTON b-quit WIDGET-ID 100.


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

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Выбор товара */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-gds Dialog-Frame
ON CHOOSE OF B-gds IN FRAME Dialog-Frame
DO:
define variable v-stat as character no-undo init ?.
define variable v-list as character no-undo init ?.
define variable v-prod-type like ub.clients.obj-type no-undo .
define variable v-prod-code like ub.clients.obj-code no-undo .

if can-find (ub.clients where ub.clients.obj-type = input frame {&frame-name}  Fprod-type
                                 and ub.clients.obj-code = input frame {&frame-name} Fprod-code no-lock) then do:
  /* товар не найден, но производитель задан правильно - вызываем справочник по производителю */
  find g-producer where
       g-producer.obj-type = input frame {&frame-name} Fprod-type
   and g-producer.obj-code = input frame {&frame-name} Fprod-code no-lock.
  v-list = "производитель".
end.
else
v-list = {&all}.
v-stat = {&current}.
run ref/gds-ref.p
  ( input parparentproc
    ,input "b-sel,b-mark,b-add"
    ,input v-stat
    ,input v-list
    ,INPUT ?
  ,input ?
  ,input ?
  ,input (if available g-producer then g-producer.obj-type else ?)
  ,input (if available g-producer then g-producer.obj-code else ?)
  ,input ?
  ,input ?
  ,input ?
  ,output ref-list).
/* MESSAGE FRAME Dialog-Frame:VISIBLE VIEW-AS ALERT-BOX. */
IF ref-list > "" THEN FOR FIRST ub.goods WHERE recid(ub.goods) = INTEGER(ENTRY(1,ref-list)) NO-LOCK:
    Fartic:SCREEN-VALUE = ub.goods.artic.
    Fprod-code:SCREEN-VALUE = string(ub.goods.prod-code).
    Fprod-type:SCREEN-VALUE = ub.goods.prod-type.
END.

/* define variable new-ref-list as character no-undo init "" .                             */
/* define variable i as integer   no-undo .                                                */
/* define variable v-erase-ass as logical   no-undo .                                      */
/*                                                                                         */
/* repeat i = 1 to num-entries (ref-list) :                                                */
/*   find first goods where recid (goods) = integer (entry (i, ref-list)) no-lock  .       */
/*     run ver-gds (goods.gds-code, output v-erase) .                                      */
/*     run creat-tt (goods.gds-code , (if v-erase = true then return-value else "") ) .    */
/*     run ver-assort-polit (goods.gds-code, output v-erase-ass)  .                        */
/*     run creat-tt (goods.gds-code , (if v-erase-ass = true then return-value else "")) . */
/*     if v-erase = false and v-erase-ass = false then do:                                 */
/*        new-ref-list = new-ref-list + min (",", new-ref-list) + string (recid (goods)).  */
/*     end.                                                                                */
/*                                                                                         */
/* end.                                                                                    */
/*                                                                                         */
/* if num-entries (ref-list) <> num-entries (new-ref-list) then run view-exept-gds  .      */
/* ref-list = new-ref-list .                                                               */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-help Dialog-Frame
ON CHOOSE OF b-help IN FRAME Dialog-Frame /* Помощь */
OR HELP OF FRAME {&FRAME-NAME}
DO: /* Call Help Function (or a simple message). */
  MESSAGE "Help for File: {&FILE-NAME}" VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-list Dialog-Frame
ON CHOOSE OF B-list IN FRAME Dialog-Frame
DO:
define variable v-f as logical   no-undo init false .
define variable v-erase-ass as logical   no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
DEF VAR ref-list AS CHAR.

run str/gds-list.w (
                     input parparentproc
                   , input ?
                   , input ?
                   , input ?).
ref-list = ''.
v-f = false  .
FOR FIRST gds-list NO-LOCK:
    Fartic:SCREEN-VALUE = gds-list.artic.
    Fprod-code:SCREEN-VALUE = string(gds-list.prod-code).
    Fprod-type:SCREEN-VALUE = gds-list.prod-type.
END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:
  EMPTY TEMP-TABLE tt-gds.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Ввод */
DO:
ASSIGN FRAME {&frame-name} Fartic Fprod-code Fprod-type.
IF Fartic > '' THEN.
ELSE DO:
    MESSAGE 'Не указан Артикул!' VIEW-AS ALERT-BOX.
    apply "entry" to Fartic.
    RETURN NO-APPLY.
END.
find first ub.goods where ub.goods.artic  = Fartic no-lock no-error.
if not available ub.goods then do:
  message "Неправильный Артикул - такого товара нет." VIEW-AS ALERT-BOX.
  apply "entry" to Fartic.
  RETURN NO-APPLY.
end.
find first gds-b where gds-b.artic  = Fartic
                   and recid (gds-b) <> recid (goods)
                   and gds-b.stts = 0 no-lock no-error.
if Fprod-code <> 0 then do:
  find first ub.goods where ub.goods.prod-code   = Fprod-code
                     and  ub.goods.artic      = Fartic no-lock no-error.
  if not available ub.goods then do:
    message "Неправильный Код производителя - такого товара нет." VIEW-AS ALERT-BOX.
    apply "entry" to Fprod-code in frame {&frame-name}.
    RETURN  NO-APPLY.
  end.
  find first gds-b where gds-b.artic     = Fartic
                     and gds-b.prod-code = Fprod-code
                     and recid (gds-b) <> recid (ub.goods)
                     and gds-b.stts = 0 no-lock no-error.
end.
else do:
  if available gds-b then do:
    if available g-producer then
      find ub.goods where ub.goods.prod-type = g-producer.obj-type
                           and  ub.goods.prod-code = g-producer.obj-code
                           and  ub.goods.artic          = Fartic no-lock no-error.
    if not available g-producer or (available g-producer and not available ub.goods) then do:
      message "С артикулом :" Fartic
                      "несколько товаров." skip (2)
                      "Укажите Производителя или выберите товар из справочника." VIEW-AS ALERT-BOX.
      apply "entry" to Fprod-code in frame {&frame-name}.
      RETURN  NO-APPLY.
    end.
  end.
end.
if Fprod-code <> 0  and
   Fprod-type <> "" then do:
   find goods where goods.prod-type = Fprod-type and
                   goods.prod-code = Fprod-code and
                   goods.artic     = Fartic no-lock no-error.
   if not available goods then do:
    message "Неправильный Тип производителя - такого товара нет." VIEW-AS ALERT-BOX.
    apply "entry" to Fprod-type in frame {&frame-name}.
    RETURN  NO-APPLY.
   end.
end.
else do:
  if available gds-b then do:
    if available g-producer then
      find goods where goods.prod-type = g-producer.obj-type and
                       goods.prod-code = g-producer.obj-code and
                       goods.artic     = Fartic no-lock no-error.
    if not available g-producer or (available g-producer and not available goods) then do:
      message "С артикулом :" Fartic
                      "несколько товаров." skip (2)
                      "Укажите Производителя или выберите товар из справочника." VIEW-AS ALERT-BOX.
      apply "entry" to Fprod-type in frame {&frame-name}.
      RETURN  NO-APPLY.
    end.
  end.
end.
IF NOT AVAILABLE goods THEN DO:
    MESSAGE 'Не выбран товар!'VIEW-AS ALERT-BOX.
    APPLY 'entry':U TO Fartic.
    RETURN  NO-APPLY.
END.
/*Заполнение вр. таблицы - output param*/
EMPTY TEMP-TABLE tt-gds.
CREATE tt-gds.
tt-gds.gds-code = goods.gds-code.

RELEASE tt-gds.

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
   ON ENDKEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  RUN MyEnable.
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
PROCEDURE enable_UI PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY Fartic Fprod-code Fprod-type
      WITH FRAME Dialog-Frame.
  ENABLE Fartic B-gds B-list Fprod-code Fprod-type b-sel b-quit b-help
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  FOR FIRST tt-gds, FIRST ub.goods NO-LOCK WHERE ub.goods.gds-code = tt-gds.gds-CODE:
      DISP
          ub.goods.artic @ fArtic
          ub.goods.prod-code @ fprod-code
          ub.goods.prod-type @ fprod-type
      WITH FRAME {&FRAME-NAME}.
  END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
