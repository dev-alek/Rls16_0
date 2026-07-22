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

Параметры закрытия ДНЦ

Автор: Чернова Светлана Александровна
Дата создания: 07/17/06
Author: Svetlana Chernova
Creation date: 07/17/06

*/

define input  parameter parParentProc as handle no-undo .
define input  parameter p-recid as recid no-undo .
define output parameter p-mode as character no-undo .
define output parameter p-ask as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Параметры закрытия ДНЦ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ ref/xobjgrp.i  }  /* список объектов  */

/*------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-Quit B-save B-Help RADIO-SET-1 TOGGLE-1
&Scoped-Define DISPLAYED-OBJECTS RADIO-SET-1 TOGGLE-1

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-save AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE RADIO-SET-1 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "ПРИКАЗ", 1,
"АКТ", 2
     SIZE 10.5 BY 2 NO-UNDO.

DEFINE VARIABLE TOGGLE-1 AS LOGICAL INITIAL yes
     LABEL "Диалог во время закрытия"
     VIEW-AS TOGGLE-BOX
     SIZE 27 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-save AT ROW 1 COL 1
     B-Quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 42.5
     RADIO-SET-1 AT ROW 4 COL 6 NO-LABEL
     TOGGLE-1 AT ROW 6.75 COL 6
     "Закрывать переоценки до статуса :" VIEW-AS TEXT
          SIZE 33 BY .67 AT ROW 3.25 COL 3.5
          FGCOLOR 4
     SPACE(16.49) SKIP(6.57)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Как закрыть переоценки при закрытии ДНЦ"
         DEFAULT-BUTTON B-Quit.


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
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Как закрыть ДНЦ */
DO:
  assign radio-set-1 toggle-1 .
  find first ubflt.usr-flt exclusive-lock
          where ubflt.usr-flt.user-name  = v-cntxt-userid
            and ubflt.usr-flt.call-point = "pdf-cask.w"
            no-error.
            if not available ubflt.usr-flt then do :
              create ubflt.usr-flt.
            end.
            assign
              ubflt.usr-flt.user-name  = v-cntxt-userid
              ubflt.usr-flt.call-point = "pdf-cask.w"
              ubflt.usr-flt.list_ = RADIO-SET-1:screen-value + {&delim-par} + TOGGLE-1:screen-value
            .

  if radio-set-1 = 2
      then p-mode = {&fact}  .
      else p-mode = {&order} .

   p-ask =  not ( toggle-1 ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Как закрыть ДНЦ */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-Quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-Quit Dialog-Frame
ON CHOOSE OF B-Quit IN FRAME Dialog-Frame /* Отмена */
DO:
  p-mode = ?.
  p-ask   = ?.

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
  run init-proc in this-procedure .
  RUN enable_UI.
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
  DISPLAY RADIO-SET-1 TOGGLE-1
      WITH FRAME Dialog-Frame .
  ENABLE B-Quit B-save B-Help RADIO-SET-1 TOGGLE-1
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc W-Win
PROCEDURE init-proc :
/* -----------------------------------------------------------
  Purpose: Если есть объекты с других БД то на АКТ переоценки не закрывать , только на приказ
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer buf_price-doc-forming for ub.price-doc-forming  .
define buffer buf_price-list-type for ub.price-list-type  .
define buffer ch_price-list-type  for ub.price-list-type  .
define variable v-obj-db as integer   no-undo .
find first    buf_price-doc-forming no-lock where
              recid (buf_price-doc-forming) = p-recid no-error .

find first buf_price-list-type no-lock where
           buf_price-list-type.plt-id = buf_price-doc-forming.plt-id and
           buf_price-list-type.plt-db-num = buf_price-doc-forming.plt-db-num no-error .
              empty temp-table  x_obj-group.
              run metod-gop-obj in this-procedure ( v-cntxt-db-num,  buf_price-list-type.gop-id , buf_price-list-type.gop-db-num) .
              run metod-delobj-usr in this-procedure (
                  buf_price-doc-forming.pdf-id ,
                  buf_price-doc-forming.pdf-db ,
                  buf_price-doc-forming.plt-id ,
                  buf_price-doc-forming.plt-db-num
                  ) .

              for each x_obj-group :
                 { gbl/objdbnum.i x_obj-group.obj-type x_obj-group.obj-code v-obj-db }
                 if v-obj-db <> v-cntxt-db-num  and v-cntxt-db-num = 0 then do:
                    message "Объект " x_obj-group.obj-type x_obj-group.obj-code "принадлежит другой БД"  skip
                    "Закрыть переоценки можно до ПРИКАЗа !" view-as alert-box information .
                     RADIO-SET-1:DELETE ( entry(3,RADIO-SET-1:radio-buttons ) ) in frame {&frame-name} .
                     run read-ubflt in this-procedure .
                     return.
                 end.
                 if v-obj-db <> v-cntxt-db-num  and v-cntxt-db-num <> 0 then do:
                    delete  x_obj-group.
                 end.
              end.

              if buf_price-list-type.under-type-list = 0 then do:
                for each ch_price-list-type no-lock where
                          ch_price-list-type.stts            = integer({&pdf-new}) and
                          ch_price-list-type.plt-main-id     = buf_price-list-type.plt-id and
                          ch_price-list-type.plt-main-db-num = buf_price-list-type.plt-db-num :
                          empty temp-table  x_obj-group.
                          run metod-gop-obj in this-procedure ( v-cntxt-db-num,  ch_price-list-type.gop-id , ch_price-list-type.gop-db-num) .
                          run metod-delobj-usr in this-procedure (
                              buf_price-doc-forming.pdf-id ,
                              buf_price-doc-forming.pdf-db ,
                              buf_price-doc-forming.plt-id ,
                              buf_price-doc-forming.plt-db-num
                              ) .

                          for each x_obj-group :
                            { gbl/objdbnum.i x_obj-group.obj-type x_obj-group.obj-code v-obj-db }
                            if v-obj-db <> v-cntxt-db-num and v-cntxt-db-num = 0  then do:
                                message "Есть объекты принадлежащие другой БД " skip
                                "Закрыть переоценки можно до ПРИКАЗа !" view-as alert-box information .
                                RADIO-SET-1:DELETE ( entry(3,RADIO-SET-1:radio-buttons ) ) in frame {&frame-name} .
                            run read-ubflt in this-procedure .
                            return.
                            end.
                            if v-obj-db <> v-cntxt-db-num  and v-cntxt-db-num <> 0 then do:
                                delete  x_obj-group.
                            end.

                          end.
                end.
              end.
run read-ubflt in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE read-ubflt W-Win

procedure read-ubflt :

  define variable par-pr-rdc-q as character no-undo. /* Запрос при уменьшении текущей цены */
  define variable par-type     as character no-undo. /* тип параметра конфигурации */

  find first ubflt.usr-flt no-lock
          where ubflt.usr-flt.user-name  = v-cntxt-userid
            and ubflt.usr-flt.call-point = "pdf-cask.w"
            no-error.
            if available ubflt.usr-flt then do: /* уже сохраняли фильтры, берем из них */
              if num-entries(RADIO-SET-1:radio-buttons in frame {&frame-name}) = 2 then do: /* только приказ! */
                assign
                  TOGGLE-1 = logical(entry(2, ubflt.usr-flt.list_, {&delim-par}))
                .
              end.
              else do:
                assign
                  RADIO-SET-1  = integer(entry(1, ubflt.usr-flt.list_, {&delim-par}))
                  TOGGLE-1 = logical(entry(2, ubflt.usr-flt.list_, {&delim-par}))
                .
              end.
            end.
            else do: /* не сохраняли */
              if not (num-entries(RADIO-SET-1:radio-buttons in frame {&frame-name})) = 2 then do: /* только приказ! */
                assign
                  RADIO-SET-1 = 2
                .
              end.
              assign
                TOGGLE-1 = yes
              .
            end.
  { gbl/conf-rd.i "'pr-rdc-q'" v-cntxt-host-code-obj v-cntxt-obj-type v-cntxt-obj-code "''" "''" "''" no   par-pr-rdc-q par-type no-error}.
  if par-pr-rdc-q <> "" and logical(par-pr-rdc-q) then TOGGLE-1 = yes .
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME