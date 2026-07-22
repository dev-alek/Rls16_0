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

Выбор колонок для печати в режиме РАСЧЕТ потребности товара

Автор: Комаров Иван Сергеевич
Дата создания: 07/23/10
Author: Ivan Komarov
Creation date: 07/23/10

Автор1: Чернова Светлана Александровна
Дата создания1: 12/17/07

*/

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
define input parameter parParentProc as widget-handle no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор колонок для печати в режиме РАСЧЕТ потребности товара".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/usr-flt.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ str/getctxtp.i def }

&scop line-num 10

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-OK B-Cancel B-Help tog-1 tog-18 tog-2 ~
tog-19 tog-20 tog-4 tog-21 tog-5 tog-22 tog-6 tog-23 tog-7 tog-24 tog-8 ~
tog-9 tog-26 tog-10 tog-27 tog-11 tog-28 tog-12 tog-29 tog-13 tog-30 tog-14 ~
tog-31 tog-15 tog-32 tog-16 tog-33 tog-17 tog-34
&Scoped-Define DISPLAYED-OBJECTS tog-1 tog-18 tog-2 tog-19 tog-3 tog-20 ~
tog-4 tog-21 tog-5 tog-22 tog-6 tog-23 tog-7 tog-24 tog-8 tog-25 tog-9 ~
tog-26 tog-10 tog-27 tog-11 tog-28 tog-12 tog-29 tog-13 tog-30 tog-14 ~
tog-31 tog-15 tog-32 tog-16 tog-33 tog-17 tog-34

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-OK AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE tog-1 AS LOGICAL INITIAL no
     LABEL "Код товара"
     VIEW-AS TOGGLE-BOX
     SIZE 38.5 BY .83 NO-UNDO.

DEFINE VARIABLE tog-10 AS LOGICAL INITIAL no
     LABEL "Срок хранения"
     VIEW-AS TOGGLE-BOX
     SIZE 39 BY .83 NO-UNDO.

DEFINE VARIABLE tog-11 AS LOGICAL INITIAL no
     LABEL "Коэффициент пересчета Ед.Изм."
     VIEW-AS TOGGLE-BOX
     SIZE 39 BY .83 NO-UNDO.

DEFINE VARIABLE tog-12 AS LOGICAL INITIAL no
     LABEL "Кол-во в упаковке"
     VIEW-AS TOGGLE-BOX
     SIZE 39 BY .83 NO-UNDO.

DEFINE VARIABLE tog-13 AS LOGICAL INITIAL no
     LABEL "Темп продаж"
     VIEW-AS TOGGLE-BOX
     SIZE 39.5 BY .83 NO-UNDO.

DEFINE VARIABLE tog-14 AS LOGICAL INITIAL no
     LABEL "Расход"
     VIEW-AS TOGGLE-BOX
     SIZE 39.5 BY .83 NO-UNDO.

DEFINE VARIABLE tog-15 AS LOGICAL INITIAL no
     LABEL "Дней без продаж и остатков"
     VIEW-AS TOGGLE-BOX
     SIZE 39.5 BY .83 NO-UNDO.

DEFINE VARIABLE tog-16 AS LOGICAL INITIAL no
     LABEL "Дней в продаже"
     VIEW-AS TOGGLE-BOX
     SIZE 39.5 BY .83 NO-UNDO.

DEFINE VARIABLE tog-17 AS LOGICAL INITIAL no
     LABEL "Остаток"
     VIEW-AS TOGGLE-BOX
     SIZE 39.5 BY .83 NO-UNDO.

DEFINE VARIABLE tog-18 AS LOGICAL INITIAL no
     LABEL "Приход"
     VIEW-AS TOGGLE-BOX
     SIZE 39.5 BY .83 NO-UNDO.

DEFINE VARIABLE tog-19 AS LOGICAL INITIAL no
     LABEL "MIN остаток"
     VIEW-AS TOGGLE-BOX
     SIZE 39.5 BY .83 NO-UNDO.

DEFINE VARIABLE tog-2 AS LOGICAL INITIAL no
     LABEL "Артикул"
     VIEW-AS TOGGLE-BOX
     SIZE 38.5 BY .83 NO-UNDO.

DEFINE VARIABLE tog-20 AS LOGICAL INITIAL no
     LABEL "Уровень постоянного присутстви"
     VIEW-AS TOGGLE-BOX
     SIZE 39.5 BY .83 NO-UNDO.

DEFINE VARIABLE tog-21 AS LOGICAL INITIAL no
     LABEL "MIN заказ"
     VIEW-AS TOGGLE-BOX
     SIZE 39.5 BY .83 NO-UNDO.

DEFINE VARIABLE tog-22 AS LOGICAL INITIAL no
     LABEL "Код объекта"
     VIEW-AS TOGGLE-BOX
     SIZE 39.5 BY .83 NO-UNDO.

DEFINE VARIABLE tog-23 AS LOGICAL INITIAL no
     LABEL "Разрешены отрицательные остатки"
     VIEW-AS TOGGLE-BOX
     SIZE 39.5 BY .83 NO-UNDO.

DEFINE VARIABLE tog-24 AS LOGICAL INITIAL no
     LABEL "В пути"
     VIEW-AS TOGGLE-BOX
     SIZE 39.5 BY .83 NO-UNDO.

DEFINE VARIABLE tog-25 AS LOGICAL INITIAL yes
     LABEL "Заказ кол-во"
     VIEW-AS TOGGLE-BOX
     SIZE 39.5 BY .83 NO-UNDO.

DEFINE VARIABLE tog-26 AS LOGICAL INITIAL no
     LABEL "Поставщики"
     VIEW-AS TOGGLE-BOX
     SIZE 39.5 BY .83 NO-UNDO.

DEFINE VARIABLE tog-27 AS LOGICAL INITIAL no
     LABEL "Цены поставщиков"
     VIEW-AS TOGGLE-BOX
     SIZE 39.5 BY .83 NO-UNDO.

DEFINE VARIABLE tog-28 AS LOGICAL INITIAL no
     LABEL "Тип Поставщика"
     VIEW-AS TOGGLE-BOX
     SIZE 39.5 BY .83 NO-UNDO.

DEFINE VARIABLE tog-29 AS LOGICAL INITIAL no
     LABEL "Код Поставщика"
     VIEW-AS TOGGLE-BOX
     SIZE 39.5 BY .83 NO-UNDO.

DEFINE VARIABLE tog-3 AS LOGICAL INITIAL yes
     LABEL "Название товара"
     VIEW-AS TOGGLE-BOX
     SIZE 38.5 BY .83 NO-UNDO.

DEFINE VARIABLE tog-30 AS LOGICAL INITIAL no
     LABEL "Артикул Поставщика"
     VIEW-AS TOGGLE-BOX
     SIZE 39.5 BY .83 NO-UNDO.

DEFINE VARIABLE tog-31 AS LOGICAL INITIAL no
     LABEL "Выбор Поставщика"
     VIEW-AS TOGGLE-BOX
     SIZE 39.5 BY .83 NO-UNDO.

DEFINE VARIABLE tog-32 AS LOGICAL INITIAL no
     LABEL "Название Объекта"
     VIEW-AS TOGGLE-BOX
     SIZE 39.5 BY .83 NO-UNDO.

DEFINE VARIABLE tog-33 AS LOGICAL INITIAL no
     LABEL "Расчет кол-во"
     VIEW-AS TOGGLE-BOX
     SIZE 39.5 BY .83 NO-UNDO.

DEFINE VARIABLE tog-34 AS LOGICAL INITIAL no
     LABEL "Штрих-код производителя"
     VIEW-AS TOGGLE-BOX
     SIZE 39.5 BY .83 NO-UNDO.

DEFINE VARIABLE tog-4 AS LOGICAL INITIAL no
     LABEL "Группа"
     VIEW-AS TOGGLE-BOX
     SIZE 38.5 BY .83 NO-UNDO.

DEFINE VARIABLE tog-5 AS LOGICAL INITIAL no
     LABEL "Ед.Изм."
     VIEW-AS TOGGLE-BOX
     SIZE 39 BY .83 NO-UNDO.

DEFINE VARIABLE tog-6 AS LOGICAL INITIAL no
     LABEL "Код производителя"
     VIEW-AS TOGGLE-BOX
     SIZE 38.5 BY .83 NO-UNDO.

DEFINE VARIABLE tog-7 AS LOGICAL INITIAL no
     LABEL "Название производителя"
     VIEW-AS TOGGLE-BOX
     SIZE 39 BY .83 NO-UNDO.

DEFINE VARIABLE tog-8 AS LOGICAL INITIAL no
     LABEL "Артикул контрагента"
     VIEW-AS TOGGLE-BOX
     SIZE 39 BY .83 NO-UNDO.

DEFINE VARIABLE tog-9 AS LOGICAL INITIAL no
     LABEL "ЕдИзм Контрагента"
     VIEW-AS TOGGLE-BOX
     SIZE 39 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-OK AT ROW 1 COL 1
     B-Cancel AT ROW 1 COL 11
     B-Help AT ROW 1 COL 71.5
     tog-1 AT ROW 3 COL 2.5 WIDGET-ID 2
     tog-18 AT ROW 3 COL 41.5 WIDGET-ID 36
     tog-2 AT ROW 4 COL 2.5 WIDGET-ID 4
     tog-19 AT ROW 4 COL 41.5 WIDGET-ID 38
     tog-3 AT ROW 5 COL 2.5 WIDGET-ID 6
     tog-20 AT ROW 5 COL 41.5 WIDGET-ID 40
     tog-4 AT ROW 6 COL 2.5 WIDGET-ID 8
     tog-21 AT ROW 6 COL 41.5 WIDGET-ID 42
     tog-5 AT ROW 7 COL 2.5 WIDGET-ID 10
     tog-22 AT ROW 7 COL 41.5 WIDGET-ID 44
     tog-6 AT ROW 8 COL 2.5 WIDGET-ID 12
     tog-23 AT ROW 8 COL 41.5 WIDGET-ID 46
     tog-7 AT ROW 9 COL 2.5 WIDGET-ID 14
     tog-24 AT ROW 9 COL 41.5 WIDGET-ID 48
     tog-8 AT ROW 10 COL 2.5 WIDGET-ID 16
     tog-25 AT ROW 10 COL 41.5 WIDGET-ID 50
     tog-9 AT ROW 11 COL 2.5 WIDGET-ID 18
     tog-26 AT ROW 11 COL 41.5 WIDGET-ID 52
     tog-10 AT ROW 12 COL 2.5 WIDGET-ID 20
     tog-27 AT ROW 12 COL 41.5 WIDGET-ID 54
     tog-11 AT ROW 13 COL 2.5 WIDGET-ID 22
     tog-28 AT ROW 13 COL 41.5 WIDGET-ID 56
     tog-12 AT ROW 14 COL 2.5 WIDGET-ID 24
     tog-29 AT ROW 14 COL 41.5 WIDGET-ID 58
     tog-13 AT ROW 15 COL 2.5 WIDGET-ID 26
     tog-30 AT ROW 15 COL 41.5 WIDGET-ID 60
     tog-14 AT ROW 16 COL 2.5 WIDGET-ID 28
     tog-31 AT ROW 16 COL 41.5 WIDGET-ID 62
     tog-15 AT ROW 17 COL 2.5 WIDGET-ID 30
     tog-32 AT ROW 17 COL 41.5 WIDGET-ID 64
     tog-16 AT ROW 18 COL 2.5 WIDGET-ID 32
     tog-33 AT ROW 18 COL 41.5 WIDGET-ID 66
     tog-17 AT ROW 19 COL 2.5 WIDGET-ID 34
     tog-34 AT ROW 19 COL 41.5 WIDGET-ID 68
     SPACE(39.62) SKIP(2.08)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выбор колонок для печати в режиме РАСЧЕТ потребности товара"
         DEFAULT-BUTTON B-OK CANCEL-BUTTON B-Cancel.


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

/* SETTINGS FOR TOGGLE-BOX tog-25 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX tog-3 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Выбор колонок для печати в режиме РАСЧЕТ потребности товара */
DO:
  RUN save-proc NO-ERROR.
  if error-status :error then
     return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Выбор колонок для печати в режиме РАСЧЕТ потребности товара */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-Help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-Help Dialog-Frame
ON CHOOSE OF B-Help IN FRAME Dialog-Frame /* Помощь */
OR HELP OF FRAME {&FRAME-NAME}
DO: /* Call Help Function (or a simple message). */

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
    RUN make_tt  .
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
  DISPLAY tog-1 tog-18 tog-2 tog-19 tog-3 tog-20 tog-4 tog-21 tog-5 tog-22 tog-6
          tog-23 tog-7 tog-24 tog-8 tog-25 tog-9 tog-26 tog-10 tog-27 tog-11
          tog-28 tog-12 tog-29 tog-13 tog-30 tog-14 tog-31 tog-15 tog-32 tog-16
          tog-33 tog-17 tog-34
      WITH FRAME Dialog-Frame.
  ENABLE B-OK B-Cancel B-Help tog-1 tog-18 tog-2 tog-19 tog-20 tog-4 tog-21
         tog-5 tog-22 tog-6 tog-23 tog-7 tog-24 tog-8 tog-9 tog-26 tog-10
         tog-27 tog-11 tog-28 tog-12 tog-29 tog-13 tog-30 tog-14 tog-31 tog-15
         tog-32 tog-16 tog-33 tog-17 tog-34
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make_tt Dialog-Frame
PROCEDURE make_tt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-list as character no-undo.
find first ubflt.usr-flt  no-lock where
         ubflt.usr-flt.user-name    = v-cntxt-userid and
         ubflt.usr-flt.call-point   = "selcolallo":U    no-error .
         if available ubflt.usr-flt then do :
            assign v-uf-List_ = ubflt.usr-flt.list_ .
         end.
if v-uf-List_ <> "" then do:
  if entry( 1  , v-uf-List_, {&delim-par}) <> "" then do : assign tog-1  = logical(entry( 1  , v-uf-List_, {&delim-par})). end.
  if entry( 2  , v-uf-List_, {&delim-par}) <> "" then do : assign tog-2  = logical(entry( 2  , v-uf-List_, {&delim-par})). end.
  if entry( 4  , v-uf-List_, {&delim-par}) <> "" then do : assign tog-4  = logical(entry( 4  , v-uf-List_, {&delim-par})). end.
  if entry( 5  , v-uf-List_, {&delim-par}) <> "" then do : assign tog-5  = logical(entry( 5  , v-uf-List_, {&delim-par})). end.
  if entry( 6  , v-uf-List_, {&delim-par}) <> "" then do : assign tog-6  = logical(entry( 6  , v-uf-List_, {&delim-par})). end.
  if entry( 7  , v-uf-List_, {&delim-par}) <> "" then do : assign tog-7  = logical(entry( 7  , v-uf-List_, {&delim-par})). end.
  if entry( 8  , v-uf-List_, {&delim-par}) <> "" then do : assign tog-8  = logical(entry( 8  , v-uf-List_, {&delim-par})). end.
  if entry( 9  , v-uf-List_, {&delim-par}) <> "" then do : assign tog-9  = logical(entry( 9  , v-uf-List_, {&delim-par})). end.
  if entry( 10 , v-uf-List_, {&delim-par}) <> "" then do : assign tog-10 = logical(entry( 10 , v-uf-List_, {&delim-par})). end.
  if entry( 11 , v-uf-List_, {&delim-par}) <> "" then do : assign tog-11 = logical(entry( 11 , v-uf-List_, {&delim-par})). end.
  if entry( 12 , v-uf-List_, {&delim-par}) <> "" then do : assign tog-12 = logical(entry( 12 , v-uf-List_, {&delim-par})). end.
  if entry( 13 , v-uf-List_, {&delim-par}) <> "" then do : assign tog-13 = logical(entry( 13 , v-uf-List_, {&delim-par})). end.
  if entry( 14 , v-uf-List_, {&delim-par}) <> "" then do : assign tog-14 = logical(entry( 14 , v-uf-List_, {&delim-par})). end.
  if entry( 15 , v-uf-List_, {&delim-par}) <> "" then do : assign tog-15 = logical(entry( 15 , v-uf-List_, {&delim-par})). end.
  if entry( 16 , v-uf-List_, {&delim-par}) <> "" then do : assign tog-16 = logical(entry( 16 , v-uf-List_, {&delim-par})). end.
  if entry( 17 , v-uf-List_, {&delim-par}) <> "" then do : assign tog-17 = logical(entry( 17 , v-uf-List_, {&delim-par})). end.
  if entry( 18 , v-uf-List_, {&delim-par}) <> "" then do : assign tog-18 = logical(entry( 18 , v-uf-List_, {&delim-par})). end.
  if entry( 19 , v-uf-List_, {&delim-par}) <> "" then do : assign tog-19 = logical(entry( 19 , v-uf-List_, {&delim-par})). end.
  if entry( 20 , v-uf-List_, {&delim-par}) <> "" then do : assign tog-20 = logical(entry( 20 , v-uf-List_, {&delim-par})). end.
  if entry( 21 , v-uf-List_, {&delim-par}) <> "" then do : assign tog-21 = logical(entry( 21 , v-uf-List_, {&delim-par})). end.
  if entry( 22 , v-uf-List_, {&delim-par}) <> "" then do : assign tog-22 = logical(entry( 22 , v-uf-List_, {&delim-par})). end.
  if entry( 23 , v-uf-List_, {&delim-par}) <> "" then do : assign tog-23 = logical(entry( 23 , v-uf-List_, {&delim-par})). end.
  if entry( 24 , v-uf-List_, {&delim-par}) <> "" then do : assign tog-24 = logical(entry( 24 , v-uf-List_, {&delim-par})). end.
  if entry( 26 , v-uf-List_, {&delim-par}) <> "" then do : assign tog-26 = logical(entry( 26 , v-uf-List_, {&delim-par})). end.
  if entry( 27 , v-uf-List_, {&delim-par}) <> "" then do : assign tog-27 = logical(entry( 27 , v-uf-List_, {&delim-par})). end.
  if entry( 28 , v-uf-List_, {&delim-par}) <> "" then do : assign tog-28 = logical(entry( 28 , v-uf-List_, {&delim-par})). end.
  if entry( 29 , v-uf-List_, {&delim-par}) <> "" then do : assign tog-29 = logical(entry( 29 , v-uf-List_, {&delim-par})). end.
  if entry( 30 , v-uf-List_, {&delim-par}) <> "" then do : assign tog-30 = logical(entry( 30 , v-uf-List_, {&delim-par})). end.
  if entry( 31 , v-uf-List_, {&delim-par}) <> "" then do : assign tog-31 = logical(entry( 31 , v-uf-List_, {&delim-par})). end.
  if entry( 32 , v-uf-List_, {&delim-par}) <> "" then do : assign tog-32 = logical(entry( 32 , v-uf-List_, {&delim-par})). end.
  if entry( 33 , v-uf-List_, {&delim-par}) <> "" then do : assign tog-33 = logical(entry( 33 , v-uf-List_, {&delim-par})). end.
  if entry( 34 , v-uf-List_, {&delim-par}) <> "" then do : assign tog-34 = logical(entry( 34 , v-uf-List_, {&delim-par})). end.

assign
  tog-3  = yes
  tog-25 = yes
no-error .
end.

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
define variable v-str as character no-undo .
define variable v-i   as integer   no-undo .
 do with frame {&frame-name} :
 assign tog-1 tog-2 tog-3 tog-4 tog-5 tog-6 tog-7 tog-8 tog-9 tog-10
        tog-11 tog-12 tog-13 tog-14 tog-15 tog-16 tog-17 tog-18 tog-19 tog-20
        tog-21 tog-22 tog-23 tog-24 tog-25 tog-26 tog-27 tog-28 tog-29 tog-30
        tog-31 tog-32 tog-33 tog-34
        .
 end.
v-str = '' .
v-i = 0 .
v-str = string(tog-1  , "yes/no") + {&delim-par} +
        string(tog-2  , "yes/no") + {&delim-par} +
        string(tog-3  , "yes/no") + {&delim-par} +
        string(tog-4  , "yes/no") + {&delim-par} +
        string(tog-5  , "yes/no") + {&delim-par} +
        string(tog-6  , "yes/no") + {&delim-par} +
        string(tog-7  , "yes/no") + {&delim-par} +
        string(tog-8  , "yes/no") + {&delim-par} +
        string(tog-9  , "yes/no") + {&delim-par} +
        string(tog-10 , "yes/no") + {&delim-par} +
        string(tog-11 , "yes/no") + {&delim-par} +
        string(tog-12 , "yes/no") + {&delim-par} +
        string(tog-13 , "yes/no") + {&delim-par} +
        string(tog-14 , "yes/no") + {&delim-par} +
        string(tog-15 , "yes/no") + {&delim-par} +
        string(tog-16 , "yes/no") + {&delim-par} +
        string(tog-17 , "yes/no") + {&delim-par} +
        string(tog-18 , "yes/no") + {&delim-par} +
        string(tog-19 , "yes/no") + {&delim-par} +
        string(tog-20 , "yes/no") + {&delim-par} +
        string(tog-21 , "yes/no") + {&delim-par} +
        string(tog-22 , "yes/no") + {&delim-par} +
        string(tog-23 , "yes/no") + {&delim-par} +
        string(tog-24 , "yes/no") + {&delim-par} +
        string(tog-25 , "yes/no") + {&delim-par} +
        string(tog-26 , "yes/no") + {&delim-par} +
        string(tog-27 , "yes/no") + {&delim-par} +
        string(tog-28 , "yes/no") + {&delim-par} +
        string(tog-29 , "yes/no") + {&delim-par} +
        string(tog-30 , "yes/no") + {&delim-par} +
        string(tog-31 , "yes/no") + {&delim-par} +
        string(tog-32 , "yes/no") + {&delim-par} +
        string(tog-33 , "yes/no") + {&delim-par} +
        string(tog-34 , "yes/no") + {&delim-par}
  .

find first ubflt.usr-flt where
         ubflt.usr-flt.user-name    = v-cntxt-userid and
         ubflt.usr-flt.call-point   = "selcolallo":U
         no-error .
         if not available ubflt.usr-flt  then do:
              create  ubflt.usr-flt.
              assign
                ubflt.usr-flt.user-name  = v-cntxt-userid
                ubflt.usr-flt.call-point = "selcolallo":U
              .
         end.
         assign
            ubflt.usr-flt.list_ = v-str
         .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
