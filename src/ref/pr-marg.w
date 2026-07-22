&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
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

Границы торговой наценки на группы товаров

Автор: Чернова Светлана Александровна
Дата создания: 06/26/09
Author: Svetlana Chernova
Creation date: 06/26/09


Avtor1 Бахтадзе

Input:
    p-node-code like gds-grp.node-code - код группы товаров

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
&scoped-define br-tab-spaces 2
/* Parameters Definitions ---                                           */
define input parameter parparentproc    as handle           no-undo.
define input parameter p-node-code          like ub.gds-grp.node-code no-undo.

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Границы торговой наценки на группы товаров".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ ref/grpobj.i   }
{ ref/grplibfn.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/ggoattr.i  }

define variable v-obj-list  as character    no-undo.
define variable v-host-name as character    no-undo.
define variable v-margins   as character    no-undo.
define variable v-full-grp-name as character no-undo.
define variable add-option as character no-undo.

define temp-table temp_attr no-undo
    field name            as character
    field host-code       as integer
    field obj-type        as character
    field obj-code        as integer
    field min-marg        as character
    field max-marg        as character
    field increase-pc     as character
    field round-method    as character
    field cli-type        as character
    field cli-code        as integer
    field notcorr         as character
    field alc-min-price   as character
    field marg-pr-paraf   as character
    field level-dis-attr  as character
    index pi is primary unique host-code obj-type obj-code
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-margins-list

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp_attr

/* Definitions for BROWSE br-margins-list                               */
&Scoped-define FIELDS-IN-QUERY-br-margins-list name increase-pc min-marg max-marg round-method cli-type + " " + string( cli-code , ">>>>>" ) notcorr alc-min-price marg-pr-paraf level-dis-attr
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-margins-list
&Scoped-define FIELD-PAIRS-IN-QUERY-br-margins-list
&Scoped-define SELF-NAME br-margins-list
&Scoped-define OPEN-QUERY-br-margins-list OPEN QUERY {&SELF-NAME} FOR EACH temp_attr no-lock by temp_attr.host-code by temp_attr.obj-type by temp_attr.obj-code.
&Scoped-define TABLES-IN-QUERY-br-margins-list temp_attr
&Scoped-define FIRST-TABLE-IN-QUERY-br-margins-list temp_attr


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-margins-list}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit RECT-3 RECT-2 RECT-1 RECT-4 B-Help ~
S-round-method B-add B-chg B-rev B-del br-margins-list
&Scoped-Define DISPLAYED-OBJECTS ed-grp-name fi-range-increase ~
fi-range-rmethod fi-increase-pc S-round-method F-base fi-range-margin ~
fi-marg-min fi-marg-max fi-range-income-cli fi-cli-type fi-cli-code

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-add
       MENU-ITEM m_company      LABEL "Фирма"
       MENU-ITEM m_object       LABEL "Объект"
       MENU-ITEM m_object-list  LABEL "Список объектов".


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-rev
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE ed-grp-name AS CHARACTER
     VIEW-AS EDITOR
     SIZE 54.38 BY 1.08 NO-BOX
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE F-base AS DECIMAL FORMAT "->>>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE fi-cli-code AS INTEGER FORMAT ">>>>>" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 9.88 BY 1
     FGCOLOR 7 .

DEFINE VARIABLE fi-cli-type AS CHARACTER FORMAT "X(3)"
     VIEW-AS FILL-IN
     SIZE 3.75 BY 1
     FGCOLOR 7 .

DEFINE VARIABLE fi-increase-pc AS DECIMAL FORMAT "->>>>9.99" INITIAL 0
     LABEL "Наценка %"
     VIEW-AS FILL-IN
     SIZE 9.88 BY 1
     FGCOLOR 7 .

DEFINE VARIABLE fi-marg-max AS DECIMAL FORMAT "->>>>9.99" INITIAL 0
     LABEL "Максимальная наценка %"
     VIEW-AS FILL-IN
     SIZE 9.88 BY 1
     FGCOLOR 7 .

DEFINE VARIABLE fi-marg-min AS DECIMAL FORMAT "->>>>9.99" INITIAL 0
     LABEL "Минимальная  наценка %"
     VIEW-AS FILL-IN
     SIZE 9.88 BY 1
     FGCOLOR 7 .

DEFINE VARIABLE fi-range-income-cli AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 40.25 BY 1
     FGCOLOR 7  NO-UNDO.

DEFINE VARIABLE fi-range-increase AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 53.88 BY 1
     FGCOLOR 7  NO-UNDO.

DEFINE VARIABLE fi-range-margin AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 53.88 BY 1
     FGCOLOR 7  NO-UNDO.

DEFINE VARIABLE fi-range-rmethod AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 40.25 BY 1
     FGCOLOR 7  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 55 BY 3.25.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 55 BY 4.29.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 42.25 BY 7.88.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 42.25 BY 3.

DEFINE VARIABLE S-round-method AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     SIZE 23.5 BY 5
     BGCOLOR 15  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-margins-list FOR
      temp_attr SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-margins-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-margins-list Dialog-Frame _FREEFORM
  QUERY br-margins-list DISPLAY
      name format "X(30)" COLUMN-LABEL "":U
      increase-pc format "X(8)" COLUMN-LABEL "Наценка"
      min-marg format "X(9)" COLUMN-LABEL "Мин"
      max-marg format "X(8)" COLUMN-LABEL "Макс"
      round-method format "X(22)" COLUMN-LABEL "Метод округления"
      cli-type  + " " +  string( cli-code , ">>>>>" )  format "X(10)" COLUMN-LABEL "Внутр.Поставщик"
      if notcorr = 'yes' then "да" else "" COLUMN-LABEL "Запрет кор. заказа":U
      alc-min-price format "X(30)" COLUMN-LABEL "Правила определения минимальной цены алкоголя"
      level-dis-attr format "X(30)" COLUMN-LABEL "Границы пороговой наценки"
      marg-pr-paraf format "X(30)" COLUMN-LABEL "Наценка к цене внутреннего прихода партии"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 99 BY 6.5.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-Help AT ROW 1.04 COL 90.25
     ed-grp-name AT ROW 2.08 COL 2.25 NO-LABEL
     fi-range-increase AT ROW 4.33 COL 2.75 NO-LABEL
     fi-range-rmethod AT ROW 4.42 COL 58.75 NO-LABEL
     fi-increase-pc AT ROW 5.46 COL 25.38 COLON-ALIGNED
     S-round-method AT ROW 5.63 COL 58.75 NO-LABEL
     F-base AT ROW 5.63 COL 82 COLON-ALIGNED NO-LABEL
     fi-range-margin AT ROW 7.88 COL 2.88 NO-LABEL
     fi-marg-min AT ROW 9.08 COL 25.38 COLON-ALIGNED
     fi-marg-max AT ROW 10.08 COL 25.38 COLON-ALIGNED
     fi-range-income-cli AT ROW 12.04 COL 58.75 NO-LABEL
     fi-cli-type AT ROW 13.04 COL 56.75 COLON-ALIGNED NO-LABEL
     fi-cli-code AT ROW 13.04 COL 61.13 COLON-ALIGNED NO-LABEL
     B-add AT ROW 13.25 COL 1
     B-chg AT ROW 13.25 COL 11
     B-rev AT ROW 13.25 COL 21
     B-del AT ROW 13.25 COL 21
     br-margins-list AT ROW 14.29 COL 1
     RECT-3 AT ROW 3.38 COL 57.88
     "Диапазоны торговых наценок" VIEW-AS TEXT
          SIZE 27.5 BY .58 AT ROW 7.13 COL 2.88
          FGCOLOR 4
     "Внутр.поставщик" VIEW-AS TEXT
          SIZE 16.38 BY .58 AT ROW 11.46 COL 58.75
          FGCOLOR 4
     "Торговая наценка" VIEW-AS TEXT
          SIZE 27.5 BY .58 AT ROW 3.54 COL 2.88
          FGCOLOR 4
     "Метод округления" VIEW-AS TEXT
          SIZE 20 BY .58 AT ROW 3.71 COL 58.75
          FGCOLOR 4
     RECT-2 AT ROW 6.92 COL 2.13
     RECT-1 AT ROW 3.38 COL 2.13
     RECT-4 AT ROW 11.33 COL 57.88
     SPACE(0.12) SKIP(6.46)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры группы на объектах"
         DEFAULT-BUTTON B-exit.


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
/* BROWSE-TAB br-margins-list B-del Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-add:HANDLE.

/* SETTINGS FOR EDITOR ed-grp-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN F-base IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-cli-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-cli-type IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-increase-pc IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-marg-max IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-marg-min IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-range-income-cli IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fi-range-increase IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fi-range-margin IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fi-range-rmethod IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-margins-list
/* Query rebuild information for BROWSE br-margins-list
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp_attr no-lock by temp_attr.host-code by temp_attr.obj-type by temp_attr.obj-code.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-margins-list */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры группы на объектах */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  run proc-b-add in this-procedure no-error.
    if error-status:error then do:
        assign add-option = "":U.
        return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  run proc-b-chg in this-procedure no-error.
    if error-status:error then do:
        assign add-option = "":U.
        return no-apply.
  end.
END.

&Scoped-define SELF-NAME B-rev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-rev Dialog-Frame
ON CHOOSE OF B-rev IN FRAME Dialog-Frame /* Изменить */
DO:
  run proc-b-rev in this-procedure no-error.
    if error-status:error then do:
        assign add-option = "":U.
        return no-apply.
  end.
END.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
define variable v-mess-firm as character no-undo.

if temp_attr.host-code = 0
and temp_attr.obj-type = ""
and temp_attr.obj-code = 0
then do:
    message
    "Нельзя удалить глобальное значение торговой наценки"
    view-as alert-box ERROR.
    return no-apply.
end.

    if temp_attr.host-code <> v-cntxt-host-code-obj
    then do:
        message
            skip "Нельзя удалить значение наценки"
            skip "на объекте, не принадлежащем текущей фирме"
        view-as alert-box error.
        undo, return no-apply .
    end.
    if temp_attr.obj-type = ""
    and temp_attr.obj-code = 0
    then do:
        assign
            v-mess-firm = "по текущей фирме " + v-host-name
        .
    end.
    else do:
        assign
            v-mess-firm = "по объекту " + temp_attr.obj-type + string( temp_attr.obj-code )
        .
    end.
    message
        "Подтвердите удаление торговых наценок для группы "
        skip v-full-grp-name
        skip(1) v-mess-firm
    view-as alert-box buttons yes-no update v-yes-no as logical  .
    if v-yes-no = yes
    then do:
        run delete-attr-by-br-line in this-procedure no-error .
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description
                skip "Ошибка при удалении наценки для группы"
                skip v-full-grp-name
                skip(1) v-mess-firm
                skip return-value
                skip trim(error-status :get-message(1))
                        trim(error-status :get-message(2))
                        trim(error-status :get-message(3))
                        trim(error-status :get-message(4))
                        trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return no-apply .
        end.
        else do:
            run ui-on in this-procedure .
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_company
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_company Dialog-Frame
ON CHOOSE OF MENU-ITEM m_company /* Фирма */
DO:
  assign add-option = {&company}.
  run proc-b-add in this-procedure no-error.
  if error-status:error then do:
    assign
    add-option = "":U.
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_object
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_object Dialog-Frame
ON CHOOSE OF MENU-ITEM m_object /* Объект */
DO:
    assign add-option = {&g___object}.
  run proc-b-add in this-procedure no-error.
  if error-status:error then do:
    assign
    add-option = "":U.
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_object-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_object-list Dialog-Frame
ON CHOOSE OF MENU-ITEM m_object-list /* Список объектов */
DO:
    assign add-option = "object-list":U.
  run proc-b-add in this-procedure no-error.
  if error-status:error then do:
    assign
    add-option = "":U.
    return no-apply.
  end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME S-round-method
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL S-round-method Dialog-Frame
ON VALUE-CHANGED OF S-round-method IN FRAME Dialog-Frame
DO:
  assign
  S-round-method
  .
  if lookup(S-round-method, {&pr-rounds-need-coef}) > 0 then do:
    display
    f-base
    with frame {&frame-name}.
  end.
  else do:
    hide
    f-base
    in frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-margins-list
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
{ gbl/app_help.i }

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    { gbl/getcntxt.i get }

    run get-host-name in this-procedure ( input v-cntxt-host-code-obj, output v-host-name ) no-error.
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Не удалось найти наименование фирмы."
          skip "Код фирмы: " v-cntxt-host-code-obj
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.

    RUN UI-on.
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE delete-attr-by-br-line Dialog-Frame
PROCEDURE delete-attr-by-br-line :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define buffer buf_gds-grp-obj      for ub.gds-grp-obj.
define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr.

find first  buf_gds-grp-obj  exclusive-lock
     where buf_gds-grp-obj.node-code = p-node-code
       and buf_gds-grp-obj.host-code = temp_attr.host-code
       and buf_gds-grp-obj.obj-type = temp_attr.obj-type
       and buf_gds-grp-obj.obj-code = temp_attr.obj-code
no-error .
if not available temp_attr
then do:
    message
        skip "Не найдена запись, соответствующая значению, выбранному в списке"
        skip "наценок для группы товаров."
    view-as alert-box error.
    undo, return error .
end.
else do:
    delete buf_gds-grp-obj.
    for each buf_gds-grp-obj-attr where buf_gds-grp-obj-attr.node-code = p-node-code and buf_gds-grp-obj-attr.host-code = temp_attr.host-code and
                                buf_gds-grp-obj-attr.obj-code = temp_attr.obj-code and buf_gds-grp-obj-attr.obj-type = temp_attr.obj-type exclusive-lock.
      delete buf_gds-grp-obj-attr .
    end.
end.

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
  DISPLAY ed-grp-name fi-range-increase fi-range-rmethod fi-increase-pc
          S-round-method F-base fi-range-margin fi-marg-min fi-marg-max
          fi-range-income-cli fi-cli-type fi-cli-code
      WITH FRAME Dialog-Frame.
 ENABLE B-exit RECT-3 RECT-2 RECT-1 RECT-4 B-Help S-round-method B-add B-chg B-rev
         B-del br-margins-list
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-temp-attr Dialog-Frame
PROCEDURE fill-temp-attr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define buffer buf_gds-grp-obj      for ub.gds-grp-obj.
define variable v-min     as decimal           no-undo.
define variable v-max     as decimal           no-undo.
define variable v-incr    like ub.gds-grp.increase-pc  no-undo.
define variable v-round-method as character no-undo.
define variable v-base         as decimal no-undo .
define variable v-type as character no-undo .


    for each temp_attr
    :
        delete temp_attr.
    end.
    for each buf_gds-grp-obj no-lock
       where buf_gds-grp-obj.node-code = p-node-code
    :
        create temp_attr.
        assign
        v-min = buf_gds-grp-obj.min-increase
        v-max = buf_gds-grp-obj.max-increase
        v-incr = buf_gds-grp-obj.increase-pc
        v-round-method = buf_gds-grp-obj.round-method
        v-base = buf_gds-grp-obj.round-coef
        .
        if  buf_gds-grp-obj.host-code  = 0
        and buf_gds-grp-obj.obj-type   = ""
        and buf_gds-grp-obj.obj-code   = 0
        then do:
            assign
                temp_attr.name = "Глобально"
            .
        end.
        else do:
            if  buf_gds-grp-obj.obj-type   = ""
            and buf_gds-grp-obj.obj-code   = 0
            then do:
                run get-host-name in this-procedure ( input buf_gds-grp-obj.host-code
                                                    , output temp_attr.name
                ).
                assign
                    temp_attr.name = fill( " ", {&br-tab-spaces} ) + temp_attr.name
                .
            end.
            else do:
                assign
                    temp_attr.name = fill( " ", {&br-tab-spaces} * 2 )
                                    + buf_gds-grp-obj.obj-type
                                    + string( buf_gds-grp-obj.obj-code )
                .
            end.
        end.
        assign
            temp_attr.host-code = buf_gds-grp-obj.host-code
            temp_attr.obj-type  = buf_gds-grp-obj.obj-type
            temp_attr.obj-code  = buf_gds-grp-obj.obj-code
            temp_attr.cli-type  = buf_gds-grp-obj.cli-type
            temp_attr.cli-code  = buf_gds-grp-obj.cli-code
            temp_attr.min-marg  = (if v-min <> ? then string(v-min, "->>>>9.99") else "":U)
            temp_attr.max-marg  = (if v-max <> ? then string(v-max, "->>>>9.99") else "":U)
            temp_attr.increase-pc  = (if v-incr <> ? then string(v-incr, "->>>>9.99") else "":U)
            temp_attr.round-method = v-round-method + {&space-char} +
                                   (if lookup(v-round-method, {&pr-rounds-need-coef}) > 0
                                    then string(v-base, "->>>>9.99")
                                    else "":U
                                   )
        .
    run ggoattr-value (
       input   p-node-code
      ,input   buf_gds-grp-obj.host-code
      ,input   buf_gds-grp-obj.obj-type
      ,input   buf_gds-grp-obj.obj-code
      ,input   {&ggoattr-NotCorrOP}
      ,output  temp_attr.notcorr
      ,output  v-type ) no-error .
    run ggoattr-value (
       input   p-node-code
      ,input   buf_gds-grp-obj.host-code
      ,input   buf_gds-grp-obj.obj-type
      ,input   buf_gds-grp-obj.obj-code
      ,input   {&ggoattr-alc-min-price}
      ,output  temp_attr.alc-min-price
      ,output  v-type ) no-error .
    run ggoattr-value (
       input   p-node-code
      ,input   buf_gds-grp-obj.host-code
      ,input   buf_gds-grp-obj.obj-type
      ,input   buf_gds-grp-obj.obj-code
      ,input   {&ggoattr-marg-pr-paraf}
      ,output  temp_attr.marg-pr-paraf
      ,output  v-type ) no-error .
    run ggoattr-value (
       input   p-node-code
      ,input   buf_gds-grp-obj.host-code
      ,input   buf_gds-grp-obj.obj-type
      ,input   buf_gds-grp-obj.obj-code
      ,input   {&ggoattr-level-dis}
      ,output  temp_attr.level-dis-attr
      ,output  v-type ) no-error .
    end.
end.
END PROCEDURE. /* fill-temp-attr */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-host-name Dialog-Frame
PROCEDURE get-host-name :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-host-code  as integer      no-undo.
define output parameter p-host-name as character    no-undo.

define buffer buf_clients   for ub.clients.

    find first buf_clients no-lock
         where buf_clients.obj-type = {&cmp}
           and buf_clients.obj-code = p-host-code
    no-error.
    if not available buf_clients
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Не удалось найти текущую фирму"
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
    else do:
        assign
            p-host-name = buf_clients.obj-name
        .
    end.
end.
END PROCEDURE. /* get-host-name */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable rr as recid no-undo.
if add-option = "":U then do:
    run gbl/pop-up.p (B-add:handle in frame {&frame-name}, no) no-error.
    if error-status:error then do:
        assign add-option = "":U.
        return no-apply.
     end.
end.

 run ref/pr-mchg.w ( input parparentproc, {&add-def}, p-node-code, add-option, v-cntxt-host-code-obj ,v-cntxt-obj-type, v-cntxt-obj-code, output rr).

assign
add-option = "":U.
run ui-on in this-procedure .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-chg Dialog-Frame
PROCEDURE proc-b-chg :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable rr as recid no-undo.
define variable v-option as character no-undo.
define buffer buf_gds-grp-obj for ub.gds-grp-obj.

if not available temp_attr then return error.

find first  buf_gds-grp-obj  exclusive-lock
     where buf_gds-grp-obj.node-code = p-node-code
       and buf_gds-grp-obj.host-code = temp_attr.host-code
       and buf_gds-grp-obj.obj-type = temp_attr.obj-type
       and buf_gds-grp-obj.obj-code = temp_attr.obj-code
no-error .
if not available temp_attr
then do:
    message
        skip "Не найдена запись, соответствующая значению, выбранному в списке"
        skip "наценок для группы товаров."
    view-as alert-box error.
    undo, return error .
end.

assign
v-option = (if buf_gds-grp-obj.obj-type = "":U and
                    buf_gds-grp-obj.obj-code = 0 and
                    buf_gds-grp-obj.host-code = 0
                    then "global":U
                    else (if buf_gds-grp-obj.obj-type = "":U and
                             buf_gds-grp-obj.obj-code = 0
                             then {&company}
                             else {&g___object})
                    )
 .
 run ref/pr-mchg.w ( input parparentproc, {&update}, p-node-code, v-option, buf_gds-grp-obj.host-code , buf_gds-grp-obj.obj-type, buf_gds-grp-obj.obj-code, output rr).

assign
add-option = "":U.
run ui-on in this-procedure .


END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-rev Dialog-Frame
PROCEDURE proc-b-rev :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable rr as recid no-undo.
define variable v-option as character no-undo.
define buffer buf_gds-grp-obj for ub.gds-grp-obj.

if not available temp_attr then return error.

find first  buf_gds-grp-obj  exclusive-lock
     where buf_gds-grp-obj.node-code = p-node-code
       and buf_gds-grp-obj.host-code = temp_attr.host-code
       and buf_gds-grp-obj.obj-type = temp_attr.obj-type
       and buf_gds-grp-obj.obj-code = temp_attr.obj-code
no-error .
if not available temp_attr
then do:
    message
        skip "Не найдена запись, соответствующая значению, выбранному в списке"
        skip "наценок для группы товаров."
    view-as alert-box error.
    undo, return error .
end.

assign
v-option = (if buf_gds-grp-obj.obj-type = "":U and
                    buf_gds-grp-obj.obj-code = 0 and
                    buf_gds-grp-obj.host-code = 0
                    then "global":U
                    else (if buf_gds-grp-obj.obj-type = "":U and
                             buf_gds-grp-obj.obj-code = 0
                             then {&company}
                             else {&g___object})
                    )
 .
 run ref/pr-mchg.w ( input parparentproc, {&lookup}, p-node-code, v-option, buf_gds-grp-obj.host-code , buf_gds-grp-obj.obj-type, buf_gds-grp-obj.obj-code, output rr).

assign
add-option = "":U.
run ui-on in this-procedure .


END PROCEDURE.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE UI-on Dialog-Frame
PROCEDURE UI-on :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define buffer buf_gds-grp       for ub.gds-grp.

define variable v-margins-range     as integer  no-undo.
define variable v-margins-exists    as logical  no-undo.
define variable v-increase-range     as integer  no-undo.
define variable v-increase-exists    as logical  no-undo.
define variable v-min-marg          as decimal  no-undo.
define variable v-max-marg          as decimal  no-undo.
define variable v-increase-pc          as decimal  no-undo.
define variable v-round-method as character  no-undo.
define variable v-base              as decimal no-undo .
define variable v-rmethod-range     as integer  no-undo.
define variable v-rmethod-exists    as logical  no-undo.
define variable v-cli-type as character no-undo .
define variable v-cli-code as integer no-undo .
define variable v-income-cli-range     as integer  no-undo.
define variable v-income-cli-exists    as logical  no-undo.


ASSIGN
B-add:MENU-MOUSE in frame {&frame-name} =  1.
s-round-method:list-items = {&pr-rounds}.
DISPLAY ed-grp-name fi-marg-min fi-marg-max fi-increase-pc S-round-method
    WITH FRAME Dialog-Frame.
ENABLE B-exit B-Help br-margins-list
     B-add B-chg B-rev B-del
    WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
    run fill-temp-attr in this-procedure .
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    run grplib-get-full-name in this-procedure (input p-node-code, output v-full-grp-name) no-error.
    if error-status :error
    then do:
        message
            vss-workfile vss-revision vss-description
            skip "Ошибка вычисления полного имени группы"
            skip return-value
            skip trim(error-status :get-message(1))
                   trim(error-status :get-message(2))
                   trim(error-status :get-message(3))
                   trim(error-status :get-message(4))
                   trim(error-status :get-message(5))
        view-as alert-box error.
        assign
            ed-grp-name :screen-value = ""
        .
    end.
    else do:
        assign
            ed-grp-name :screen-value = v-full-grp-name
        .
    end.

    run grp-obj-margin-value in this-procedure (
                              input p-node-code
                            , input v-cntxt-obj-type
                            , input v-cntxt-obj-code
                            , output v-min-marg
                            , output v-max-marg
                            , output v-increase-pc
                            , output v-round-method
                            , output v-base
                            , output v-margins-range
                            , output v-margins-exists
                            , output v-increase-range
                            , output v-increase-exists
                            , output v-rmethod-range
                            , output v-rmethod-exists

    ) no-error .

    run grp-obj-income-cli-value in this-procedure (
                              input p-node-code
                            , input v-cntxt-obj-type
                            , input v-cntxt-obj-code
                            , output v-cli-type
                            , output v-cli-code
                            , output v-income-cli-range
                            , output v-income-cli-exists

    ) no-error .
    /* Внутренний поставщик */
    if v-income-cli-exists then do:
        assign
        fi-range-income-cli:visible = yes
        fi-range-income-cli:screen-value = if v-income-cli-range = 1
                                            then "Глобальные значения"
                                            else (if v-income-cli-range = 2
                                                     then "Значения по фирме " + v-host-name
                                                     else  "Значения по объекту " + v-cntxt-obj-type + string( v-cntxt-obj-code )
                                                     )
        fi-cli-type:screen-value = string( v-cli-type )
        fi-cli-code:screen-value = string( v-cli-code )
       .
    end.
    else do:
        assign
        fi-range-income-cli:visible = no
        fi-cli-type:visible = no
        fi-cli-code:visible = no
        .
    end.

    if v-margins-exists then do:
        assign
        fi-range-margin:visible = yes
        fi-range-margin:screen-value = if v-margins-range = 1
                                            then "Глобальные значения"
                                            else (if v-margins-range = 2
                                                     then "Значения по фирме " + v-host-name
                                                     else  "Значения по объекту " + v-cntxt-obj-type + string( v-cntxt-obj-code )
                                                     )
        fi-marg-min:screen-value = string( v-min-marg )
        fi-marg-max:screen-value = string( v-max-marg )
       .
    end.
    else do:
        assign
        fi-range-margin:visible = no
        fi-marg-min:visible = no
        fi-marg-max:visible = no
        .
    end.
    if v-increase-exists then do:
        assign
        fi-range-increase:visible = yes
        fi-range-increase:screen-value = if v-increase-range = 1
                                            then "Глобальные значения"
                                            else (if v-increase-range = 2
                                                     then "Значения по фирме " + v-host-name
                                                     else  "Значения по объекту " + v-cntxt-obj-type + string( v-cntxt-obj-code )
                                                     )
        fi-increase-pc:screen-value = string( v-increase-pc )
       .
    end.
    else do:
        assign
        fi-range-increase:visible = no
        fi-increase-pc:visible = no
        .
    end.
    if v-rmethod-exists then do:
        assign
        fi-range-rmethod:visible = yes
        fi-range-rmethod:screen-value = if v-rmethod-range = 1
                                            then "Глобальные значения"
                                            else (if v-increase-range = 2
                                                     then "Значения по фирме " + v-host-name
                                                     else  "Значения по объекту " + v-cntxt-obj-type + string( v-cntxt-obj-code )
                                                     )
        s-round-method:screen-value = string( v-round-method )
        f-base = v-base
       .
       apply "VALUE-CHANGED" to s-round-method.
    end.
    else do:
        assign
        fi-range-increase:visible = no
        fi-increase-pc:visible = no
        .
    end.
/*На удаленной БД недоступны Добавить Изменить Удалить*/
if (g#db-num <> 0) then do:
hide    b-add       in frame {&frame-name}
        b-chg      in frame {&frame-name}
        b-del       in frame {&frame-name}
     .    
end.   

{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}


end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME