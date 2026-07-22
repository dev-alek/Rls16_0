&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME frm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS frm
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание ДНЦ(переоценки) при изменении налога на товар

Автор: Чернова Светлана Александровна
Дата создания: 12/11/08
Author: Svetlana Chernova
Creation date: 12/11/08

Avtor1 Гюнтнер

*/
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc            as widget-handle    no-undo .
define input parameter p-tax-rate-value-recid   as recid            no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Создание переоценки при изменении налога на товар".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/getsect.i def}
{ cmp/library.i  }
{ gbl/temphsts.i }
{ trg/factord.i  }
{ str/doc-code.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/waitfram.i }
{ ref/xobjgrp.i  }
{ str/hvrdtax.i  }
{ str/lib-trn.i  }
define buffer buf_price-doc-forming for ub.price-doc-forming  .
{ str/alt-calc.i "func"  }
{ str/alt-calc.i "proc" "''"  "''"  }
{ str/mpl-lib.i  }
{ str/mpl-lib3.i }
{ trg/check-bc.i }
{ str/lastincs.i }
{ ref/gdsoattr.i }

define variable v-host-code  as integer   no-undo .
define variable l-ok as logical   no-undo .

define temp-table gds-list no-undo
    field gds-code      like ub.gds-obj.gds-code
    field obj-type      like ub.gds-obj.obj-type
    field obj-code      like ub.gds-obj.obj-code
    field price-sale    like ub.price-list.price-sale
    index gc is primary unique obj-type obj-code gds-code
.

define temp-table obj-list no-undo
    field obj-type like ub.gds-obj.obj-type
    field obj-code like ub.gds-obj.obj-code
    field obj-name like ub.clients.obj-name
    index oc is primary unique obj-type obj-code
.

define buffer buf_goods                for ub.goods.
define buffer buf_gds-obj              for ub.gds-obj.
define buffer buf_clients              for ub.clients.
define buffer buf_tax-rate-value       for ub.tax-rate-value.
define buffer buf_host_tax-rate-value  for ub.tax-rate-value.
define buffer buf_obj_tax-rate-value   for ub.tax-rate-value.



define variable  v-obj-current-date  like ub.tax-rate-value.fact-date       no-undo.
define variable  v-display-frame     as logical                          no-undo.
define variable  v-save-option       as char                             no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frm
&Scoped-define BROWSE-NAME br-goods

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES gds-list buf_goods obj-list

/* Definitions for BROWSE br-goods                                      */
&Scoped-define FIELDS-IN-QUERY-br-goods buf_goods.gds-code buf_goods.artic buf_goods.gds-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-goods
&Scoped-define SELF-NAME br-goods
&Scoped-define QUERY-STRING-br-goods FOR EACH gds-list, ~
       first buf_goods where buf_goods.gds-code = gds-list.gds-code
&Scoped-define OPEN-QUERY-br-goods OPEN QUERY {&SELF-NAME} FOR EACH gds-list, ~
       first buf_goods where buf_goods.gds-code = gds-list.gds-code.
&Scoped-define TABLES-IN-QUERY-br-goods gds-list buf_goods
&Scoped-define FIRST-TABLE-IN-QUERY-br-goods gds-list
&Scoped-define SECOND-TABLE-IN-QUERY-br-goods buf_goods


/* Definitions for BROWSE br-objects                                    */
&Scoped-define FIELDS-IN-QUERY-br-objects obj-list.obj-type obj-list.obj-code " " + obj-list.obj-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-objects
&Scoped-define SELF-NAME br-objects
&Scoped-define QUERY-STRING-br-objects FOR EACH obj-list
&Scoped-define OPEN-QUERY-br-objects OPEN QUERY {&SELF-NAME} FOR EACH obj-list.
&Scoped-define TABLES-IN-QUERY-br-objects obj-list
&Scoped-define FIRST-TABLE-IN-QUERY-br-objects obj-list


/* Definitions for DIALOG-BOX frm                                       */
&Scoped-define OPEN-BROWSERS-IN-QUERY-frm ~
    ~{&OPEN-QUERY-br-goods}~
    ~{&OPEN-QUERY-br-objects}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS bt-close bt-form-goods-list bt-form-ovr-obj ~
bt-form-ovr-obj-2 b-help br-objects br-goods

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU POPUP-MENU-bt-export
       MENU-ITEM m_obj-list     LABEL "Список объектов"
       MENU-ITEM m_gds-list     LABEL "Список товаров".


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 3 BY 1.

DEFINE BUTTON bt-close AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1.

DEFINE BUTTON bt-export
     LABEL "Экспорт..."
     SIZE 11 BY 1.

DEFINE BUTTON bt-form-goods-list
     LABEL "Товары"
     SIZE 10 BY 1 TOOLTIP "Добавить товары для переоценивания".

DEFINE BUTTON bt-form-ovr-obj
     LABEL "По Объекту"
     SIZE 12 BY 1 TOOLTIP "Сформировать ДНЦ по выбранному объекту".

DEFINE BUTTON bt-form-ovr-obj-2
     LABEL "По списку"
     SIZE 12 BY 1 TOOLTIP "Сформировать ДНЦ по списку объектов".

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-goods FOR
      gds-list,
      buf_goods SCROLLING.

DEFINE QUERY br-objects FOR
      obj-list SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-goods frm _FREEFORM
  QUERY br-goods DISPLAY
      buf_goods.gds-code
      buf_goods.artic
      buf_goods.gds-name
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 65.88 BY 19.58.

DEFINE BROWSE br-objects
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-objects frm _FREEFORM
  QUERY br-objects DISPLAY
      obj-list.obj-type format "X(3)"
    obj-list.obj-code format ">>>>9"
    " " + obj-list.obj-name format "X(18)" column-label "Наименование"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 31 BY 19.58.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frm
     bt-close AT ROW 1 COL 1.63
     bt-export AT ROW 1 COL 20.5
     bt-form-goods-list AT ROW 1 COL 32
     bt-form-ovr-obj AT ROW 1 COL 67.88
     bt-form-ovr-obj-2 AT ROW 1 COL 79.88
     b-help AT ROW 1 COL 96
     br-objects AT ROW 2.38 COL 1.5
     br-goods AT ROW 2.38 COL 33.13
     "Сформировать ДНЦ:" VIEW-AS TEXT
          SIZE 17.5 BY 1 AT ROW 1 COL 50
     SPACE(31.87) SKIP(20.12)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список товаров по объекту"
         DEFAULT-BUTTON bt-close.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX frm
   FRAME-NAME                                                           */
/* BROWSE-TAB br-objects b-help frm */
/* BROWSE-TAB br-goods br-objects frm */
ASSIGN
       FRAME frm:SCROLLABLE       = FALSE
       FRAME frm:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON bt-export IN FRAME frm
   NO-ENABLE                                                            */
ASSIGN
       bt-export:HIDDEN IN FRAME frm           = TRUE
       bt-export:POPUP-MENU IN FRAME frm       = MENU POPUP-MENU-bt-export:HANDLE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-goods
/* Query rebuild information for BROWSE br-goods
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH gds-list, first buf_goods where buf_goods.gds-code = gds-list.gds-code.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-goods */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-objects
/* Query rebuild information for BROWSE br-objects
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH obj-list.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-objects */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME frm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL frm frm
ON WINDOW-CLOSE OF FRAME frm /* Список товаров по объекту */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-objects
&Scoped-define SELF-NAME br-objects
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-objects frm
ON MOUSE-SELECT-DBLCLICK OF br-objects IN FRAME frm
DO:
  apply "choose" to bt-form-goods-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-close
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-close frm
ON CHOOSE OF bt-close IN FRAME frm /* Выход */
DO:
/*  apply "window-close":U to frm.*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-export
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-export frm
ON CHOOSE OF bt-export IN FRAME frm /* Экспорт... */
DO:
   if v-save-option = "" then do:
       run gbl/pop-up.p (self:handle, no) no-error.
   end.
   run process-bt-export (v-save-option) no-error.
   if error-status:error then do:
        assign
                v-save-option = ""
        .
        return no-apply.
   end.
   assign
        v-save-option = ""
   .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-form-goods-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-form-goods-list frm
ON CHOOSE OF bt-form-goods-list IN FRAME frm /* Товары */
DO:
    if not available obj-list then do:
      message "Не выбран объект в списке" view-as alert-box.
      return no-apply.
    end.

    run form-goods-list in this-procedure ( input obj-list.obj-type,
                                            input obj-list.obj-code,
                                            input ""
                                          ).
    {&OPEN-QUERY-br-goods}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-form-ovr-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-form-ovr-obj frm
ON CHOOSE OF bt-form-ovr-obj IN FRAME frm /* По Объекту */
DO:
    if not available obj-list then do:
      message "Не выбран объект в списке" view-as alert-box.
      return no-apply.
    end.
    message
        "Создать ДНЦ на объекте " + string(obj-list.obj-type) + string(obj-list.obj-code) + " ?"
    view-as alert-box buttons ok-cancel title "Создание ДНЦ"
    update v-1 as logical.
    if v-1 = no then do: return no-apply. end.
    run form-ovr-obj in this-procedure no-error.
    if error-status :error
    then do:
        return no-apply.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-form-ovr-obj-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-form-ovr-obj-2 frm
ON CHOOSE OF bt-form-ovr-obj-2 IN FRAME frm /* По списку */
DO:
    message
        "Создать ДНЦ на всех объектах ?"
    view-as alert-box buttons ok-cancel title "Создание ДНЦ"
    update v-1 as logical.
    if v-1 = no then do: undo, return. end.
    run form-ovr-obj-2 in this-procedure no-error.
    if error-status :error
    then do:
        return no-apply.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_gds-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_gds-list frm
ON CHOOSE OF MENU-ITEM m_gds-list /* Список товаров */
DO:
  assign
    v-save-option = "gds-list":U
  .
  apply "choose" to bt-export in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_obj-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_obj-list frm
ON CHOOSE OF MENU-ITEM m_obj-list /* Список объектов */
DO:
  assign
    v-save-option = "obj-list":U
  .
  apply "choose" to bt-export in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-goods
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK frm


/* ***************************  Main Block  *************************** */
{ gbl/app_help.i }
/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 { gbl/getcntxt.i get }
  find first buf_tax-rate-value no-lock
     where recid( buf_tax-rate-value ) = p-tax-rate-value-recid
  .
  run create-obj-list in this-procedure ( output v-display-frame ).
  if v-display-frame = yes
  then do:
        ASSIGN bt-export:MENU-MOUSE = 1.
        RUN enable_UI.
        WAIT-FOR GO OF FRAME {&FRAME-NAME}.
  end.
END.
if v-display-frame = yes
then do:
    RUN disable_UI.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-obj-list frm
PROCEDURE create-obj-list :
define output parameter p-display-frame as logical no-undo.

do
on error undo, return error
:

assign
    p-display-frame = yes
.

if buf_tax-rate-value.host-code = 0
    and buf_tax-rate-value.obj-type = ""
    and buf_tax-rate-value.obj-code = 0
then do:        /* глобально */
    run init-temphost.
    for each temp-host on error undo, return error
    :
        find first buf_host_tax-rate-value no-lock
             where buf_host_tax-rate-value.tax-code     = buf_tax-rate-value.tax-code
               and buf_host_tax-rate-value.rate-code    = buf_tax-rate-value.rate-code
               and buf_host_tax-rate-value.host-code    = temp-host.host-code
               and buf_host_tax-rate-value.obj-type     = ""
               and buf_host_tax-rate-value.obj-code     = 0
               and buf_host_tax-rate-value.fact-order   < buf_tax-rate-value.fact-order
        no-error.
        if not available buf_host_tax-rate-value
        then do:                        /* для фирмы temp-host.host-code в целом эта ставка не была определена */
            for each temp-obj no-lock
            where temp-obj.host-code = temp-host.host-code on error undo, return error
            :
                { gbl/curobjdt.i temp-obj.obj-type temp-obj.obj-code v-obj-current-date }
                if buf_tax-rate-value.fact-date = v-obj-current-date
                then do:
                    find first buf_obj_tax-rate-value no-lock
                        where buf_obj_tax-rate-value.tax-code     = buf_tax-rate-value.tax-code
                          and buf_obj_tax-rate-value.rate-code    = buf_tax-rate-value.rate-code
                          and buf_obj_tax-rate-value.host-code    = temp-host.host-code
                          and buf_obj_tax-rate-value.obj-type     = temp-obj.obj-type
                          and buf_obj_tax-rate-value.obj-code     = temp-obj.obj-code
                          and buf_obj_tax-rate-value.fact-order   < buf_tax-rate-value.fact-order
                    no-error.
                    if not available buf_obj_tax-rate-value
                    then do:        /* для объекта temp-obj.obj-type temp-obj.obj-code эта ставка не была определена */
                        create obj-list.
                        find first buf_clients
                             where buf_clients.obj-type = temp-obj.obj-type
                               and buf_clients.obj-code = temp-obj.obj-code
                        .
                        assign
                            obj-list.obj-type   = temp-obj.obj-type
                            obj-list.obj-code   = temp-obj.obj-code
                            obj-list.obj-name   = buf_clients.obj-name
                        .
                    end.       /* if not available buf_obj_tax-rate-value */
                end.        /* if buf_tax-rate-value.fact-date = v-obj-current-date */
            end.        /* for each temp-obj */
        end.        /* if not available buf_host_tax-rate-value */
    end.        /* for each temp-host */
    return.
end.
if buf_tax-rate-value.obj-type = ""
    and buf_tax-rate-value.obj-code = 0
then do:        /* для фирмы  buf_tax-rate-value.host-code */
    run init-temphost.
    for each temp-obj no-lock
    where temp-obj.host-code = buf_tax-rate-value.host-code on error undo, return error
    :
        { gbl/curobjdt.i temp-obj.obj-type temp-obj.obj-code v-obj-current-date }

        if buf_tax-rate-value.fact-date = v-obj-current-date
        then do:
            find first buf_obj_tax-rate-value no-lock
                where buf_obj_tax-rate-value.tax-code     = buf_tax-rate-value.tax-code
                    and buf_obj_tax-rate-value.rate-code    = buf_tax-rate-value.rate-code
                    and buf_obj_tax-rate-value.host-code    = buf_tax-rate-value.host-code
                    and buf_obj_tax-rate-value.obj-type     = temp-obj.obj-type
                    and buf_obj_tax-rate-value.obj-code     = temp-obj.obj-code
                    and buf_obj_tax-rate-value.fact-order   < buf_tax-rate-value.fact-order
            no-error.
            if not available buf_obj_tax-rate-value
            then do:        /* для объекта temp-obj.obj-type temp-obj.obj-code эта ставка не была определена */
                create obj-list.
                find first buf_clients
                        where buf_clients.obj-type = temp-obj.obj-type
                        and buf_clients.obj-code = temp-obj.obj-code
                .
                assign
                    obj-list.obj-type   = temp-obj.obj-type
                    obj-list.obj-code   = temp-obj.obj-code
                    obj-list.obj-name   = buf_clients.obj-name
                .
/*                run create-gds-list in this-procedure  (    input temp-obj.obj-type*/
/*                                                        ,   input temp-obj.obj-code*/
/*                                                       ).*/
/*                run create-overvalue in this-procedure (    input temp-obj.obj-type*/
/*                                                        ,   input temp-obj.obj-code*/
/*                                                       ).*/
            end.
        end.        /* if buf_tax-rate-value.fact-date = v-obj-current-date */
    end.        /* for each temp-obj */
    return.
end.

{ gbl/curobjdt.i buf_tax-rate-value.obj-type buf_tax-rate-value.obj-code v-obj-current-date }

if buf_tax-rate-value.fact-date = v-obj-current-date
then do:
    create obj-list.
    find first buf_clients
            where buf_clients.obj-type = buf_tax-rate-value.obj-type
              and buf_clients.obj-code = buf_tax-rate-value.obj-code
    .
    assign
        obj-list.obj-type   = buf_tax-rate-value.obj-type
        obj-list.obj-code   = buf_tax-rate-value.obj-code
        obj-list.obj-name   = buf_clients.obj-name
    .
/*    run create-gds-list in this-procedure  (    input buf_tax-rate-value.obj-type*/
/*                                            ,   input buf_tax-rate-value.obj-code*/
/*                                            ).*/
/*    run create-overvalue in this-procedure (    input buf_tax-rate-value.obj-type*/
/*                                            ,   input buf_tax-rate-value.obj-code*/
/*                                            ).*/
end.
else do:
    message
    skip "Переоценку при изменении значения налога можно сформировать"
    skip "только в день, когда новая ставка начнет действовать. "
    skip(1) "Текущая дата на объекте:" {&tabulation} {&tabulation} {&tabulation} string( v-obj-current-date, "99/99/9999" )
    skip    "Дата начала действия ставки налога:" {&tabulation} string( buf_tax-rate-value.fact-date, "99/99/9999" )
    view-as alert-box information title "Невозможно сформировать ДНЦ  на объекте "
                                    + buf_tax-rate-value.obj-type
                                    + string(buf_tax-rate-value.obj-code)
    .
    assign
        p-display-frame = no
    .
end.

end.
end procedure. /* create-obj-list */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI frm  _DEFAULT-DISABLE
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
  HIDE FRAME frm.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI frm  _DEFAULT-ENABLE
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
  ENABLE bt-close bt-form-goods-list bt-form-ovr-obj bt-form-ovr-obj-2 b-help
         br-objects br-goods
      WITH FRAME frm.
  VIEW FRAME frm.
  {&OPEN-BROWSERS-IN-QUERY-frm}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE form-goods-list frm
PROCEDURE form-goods-list :
define input parameter p-obj-type       like ub.gds-obj.obj-type   no-undo.
define input parameter p-obj-code       like ub.gds-obj.obj-code   no-undo.
define input parameter p-empty-gds-list as char                 no-undo .

do
on error undo, return error
:

define variable v-today             as date                         no-undo .
define variable v-time              as integer                      no-undo .
define variable v-fact-order        like ub.tax-rate-gds.fact-order no-undo.

define buffer buf_tax-rate-gds       for ub.tax-rate-gds.
define buffer buf_new_tax-rate-gds   for ub.tax-rate-gds.

run waitfram-show ("Ждите подбор товаров...") .
    if p-empty-gds-list <> "no-empty"
    then do:
        for each gds-list
        :
            delete gds-list.
        end.
    end.

    { gbl/curobjdt.i p-obj-type p-obj-code v-today }
    run factord-end-day in this-procedure ( input v-today, output v-fact-order ).

    define buffer LAST_tax-rate-gds for ub.tax-rate-gds  .
    define buffer x_tax-rate-gds for ub.tax-rate-gds  .

    gds-obj-list-create:
    for each buf_gds-obj no-lock
       where buf_gds-obj.obj-type   = p-obj-type
         and buf_gds-obj.obj-code   = p-obj-code
         and buf_gds-obj.price-sale > 0 ,
             first buf_goods no-lock where
                    buf_goods.gds-code = buf_gds-obj.gds-code and
                    buf_goods.stts = 0 ,
            LAST X_tax-rate-gds NO-LOCK where
                    X_tax-rate-gds.gds-code = buf_gds-obj.gds-code AND
                    X_tax-rate-gds.tax-code = buf_tax-rate-value.tax-code AND
                    X_tax-rate-gds.fact-order <= v-fact-order,
                    first last_tax-rate-gds no-lock where
                          recid(last_tax-rate-gds) = recid(x_tax-rate-gds) and
                          last_tax-rate-gds.rate-code = buf_tax-rate-value.rate-code
                          :

        if buf_gds-obj.price-sale = ? or buf_gds-obj.price-sale = 0
        then do:
            next gds-obj-list-create.
        end.

        create gds-list.
        assign
            gds-list.gds-code   = buf_gds-obj.gds-code
            gds-list.obj-type   = p-obj-type
            gds-list.obj-code   = p-obj-code
            gds-list.price-sale = buf_gds-obj.price-sale
        .
    end.
run waitfram-hide.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE form-ovr-obj frm
PROCEDURE form-ovr-obj :
/* Подготовка незакрытой ДНЦ по выбранному объекту */
do
on error undo, return error
:

define variable  v-price-doc-recid   as recid                            no-undo.
define variable  v-update            as logical                          no-undo.
define variable  v-price-sale        like ub.price-list.price-sale       no-undo.
define variable  v-counter           as integer                          no-undo.


define buffer buf_price-doc        for ub.price-doc.

run form-goods-list in this-procedure (   input obj-list.obj-type
                                        , input obj-list.obj-code
                                        , input ""
                                      ).
find first gds-list no-error.
if not available gds-list
then do:
    message
        "Нет товаров для ДНЦ на объекте"
        skip obj-list.obj-type obj-list.obj-code
    view-as alert-box.
    undo, return error .
end.

for each x_obj-group : delete x_obj-group . end.
create x_obj-group.
buffer-copy obj-list to x_obj-group .
{ gbl/hostcode.i
  obj-list.obj-type
  obj-list.obj-code
  v-host-code
  }

  run chec-par in this-procedure (output l-ok , input v-host-code, input obj-list.obj-type,input obj-list.obj-code ) no-error .
  If l-ok <> true or error-status :error
  then do:
      undo,return error return-value .
  end.

run prcreate-new-price-doc in this-procedure ( input v-cntxt-db-num
                                             , input obj-list.obj-type
                                             , input obj-list.obj-code
                                             , input ?
                                             , input ?
                                             , input ?
                                             , input ?
                                             , output v-price-doc-recid
                                             ) no-error.
if error-status:error
then do:
    return no-apply.
end.
else do:
    find first buf_price-doc exclusive-lock
         where recid( buf_price-doc ) = v-price-doc-recid
    .
        find first buf_price-doc-forming no-lock where
              buf_price-doc-forming.plt-id     = buf_price-doc.plt-id      and
              buf_price-doc-forming.plt-db-num = buf_price-doc.plt-db-num  and
              buf_price-doc-forming.pdf-id     = buf_price-doc.pdf-id      and
              buf_price-doc-forming.pdf-db     = buf_price-doc.pdf-db      no-error .

end.
assign
    v-counter = 0
.
gds-list-line-create:
for each gds-list
:
        assign
            v-counter = v-counter + 1
        .

        /* сделаем для ВСЕХ имеющихся цен */
        run prcreate-new-price-doc-forming-gds in this-procedure (
            input recid ( buf_price-doc-forming )
          , input obj-list.obj-type
          , input obj-list.obj-code
          , input true
          , input true /*par-pr-altex*/
          , input true /*par-pr-sclex*/
          , input v-counter
          , input gds-list.gds-code
          , input gds-list.price-sale
          ) no-error.
    if error-status:error
    then do:
            assign
              v-counter = v-counter - 1
            .

        message
            "Не удалось включить в ДНЦ товар:"
            skip string(gds-list.gds-code)
        view-as alert-box.
        next gds-list-line-create.
    end.
end.
if available buf_price-doc then do:
   delete buf_price-doc.
end.
message
    "Создан ДНЦ " string(buf_price-doc-forming.pdf-id)
    skip "на объектe " obj-list.obj-type obj-list.obj-code
    skip "Количество товаров в документе:"
    skip string(v-counter)
view-as alert-box.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE form-ovr-obj-2 frm
PROCEDURE form-ovr-obj-2 :
/* Подготовка незакрытой переоценки по всем объектам */
do
on error undo, return error
:
define variable  v-price-doc-recid   as recid                            no-undo.
define variable  v-update            as logical                          no-undo.
define variable  v-price-sale        like ub.price-list.price-sale       no-undo.
define variable  v-counter           as integer                          no-undo.
define variable  v-end-message       as char       init ""               no-undo.

define buffer buf_price-doc        for ub.price-doc.
define buffer buf_obj-list         for obj-list.

run waitfram-show ("Ждите...") .
create-on-object:
for each buf_obj-list
:

    for each x_obj-group : delete x_obj-group . end.

    create x_obj-group.
    buffer-copy buf_obj-list to x_obj-group .
    { gbl/hostcode.i
      buf_obj-list.obj-type
      buf_obj-list.obj-code
      v-host-code
      }
    run chec-par in this-procedure (output l-ok , input v-host-code, input obj-list.obj-type,input obj-list.obj-code ) no-error .
    If l-ok <> true or error-status :error
    then do:
        undo,return error return-value .
    end.

    run form-goods-list in this-procedure (   input buf_obj-list.obj-type
                                            , input buf_obj-list.obj-code
                                            , input ""
                                          ) no-error .
                                          if error-status :error then message
                                            vss-workfile vss-revision vss-description skip
                                            error-status :get-message(1) skip
                                            return-value skip
                                            ""
                                            view-as alert-box error
                                          .
    find first gds-list no-error.
    if not available gds-list
    then do:
        assign
            v-end-message = v-end-message + {&new-line} + string(buf_obj-list.obj-type) + string(buf_obj-list.obj-code)
            + {&tabulation} + "Нет товаров для ДНЦ"
        .
        next create-on-object.
    end.
    run waitfram-show  ( substitute("Создание ДНЦ для объекта  &1&2 " , buf_obj-list.obj-type ,buf_obj-list.obj-code)) .
    run prcreate-new-price-doc in this-procedure
        ( input v-cntxt-db-num
        , input buf_obj-list.obj-type
        , input buf_obj-list.obj-code
        , input ?
        , input ?
        , input ?
        , input ?
        , output v-price-doc-recid
        ) no-error.
    if error-status:error
    then do:
        assign
            v-end-message = v-end-message + {&new-line} + string(buf_obj-list.obj-type) + string(buf_obj-list.obj-code)
            + {&tabulation} + "Ошибка при создании документа"
        .
        next create-on-object.
    end.
    else do:
        find first buf_price-doc exclusive-lock
             where recid( buf_price-doc ) = v-price-doc-recid
        .
        find first buf_price-doc-forming no-lock where
              buf_price-doc-forming.plt-id     = buf_price-doc.plt-id      and
              buf_price-doc-forming.plt-db-num = buf_price-doc.plt-db-num  and
              buf_price-doc-forming.pdf-id     = buf_price-doc.pdf-id      and
              buf_price-doc-forming.pdf-db     = buf_price-doc.pdf-db      no-error .
    end.
    assign
        v-counter = 0
    .
    gds-list-line-create:
    for each gds-list
    :
        assign
            v-counter = v-counter + 1
        .
        run prcreate-new-price-doc-forming-gds in this-procedure (
            input recid ( buf_price-doc-forming )
          , input buf_obj-list.obj-type
          , input buf_obj-list.obj-code
          , input par-pr-notls
          , input par-pr-altex
          , input par-pr-sclex
          , input v-counter
          , input gds-list.gds-code
          , input gds-list.price-sale
          ) no-error.
        if error-status:error
        then do:
           message
             vss-workfile vss-revision vss-description skip
             error-status :get-message(1) skip
             return-value skip
             "1"
             view-as alert-box error
           .
            assign
              v-counter = v-counter - 1
            .
            message
                "Не удалось включить в ДНЦ товар: "
                skip string(gds-list.gds-code)
            view-as alert-box title "ДНЦ № " + string(buf_price-doc-forming.pdf-id)  + " на объекте "
                                                  + string(buf_obj-list.obj-type) + string(buf_obj-list.obj-code)
            .
            next gds-list-line-create.
        end.
    end.

    if available buf_price-doc then do:
       delete buf_price-doc.
    end.

    assign
        v-end-message = v-end-message + {&new-line} + string(buf_obj-list.obj-type) + string(buf_obj-list.obj-code)
        + {&tabulation} + string(buf_price-doc-forming.pdf-id) + {&tabulation} + string(v-counter) + " товаров" + {&new-line}
    .
end.
run waitfram-hide .
message
    "Созданы новые ДНЦ: "
    skip v-end-message
view-as alert-box title "ДНЦ на объектах".

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE process-bt-export frm
PROCEDURE process-bt-export :
/* Формирование файлов экспорта списка объектов или списка товаров по фирме */
do
on error undo, return error
:
define input parameter p-save-option as character no-undo. /* Может быть 'obj-list' или 'gds-list'*/

define variable  v-log       as logical no-undo.
define variable  v-file-name as char no-undo.

case p-save-option:
    when "obj-list":U
    then do:
        assign
          v-file-name = "objects.txt"
          v-log = yes
        .
        system-dialog get-file v-file-name
          filters "Список объектов *.txt" "*.txt"
          ask-overwrite
          save-as
          use-filename
          update v-log
          default-extension "txt".
        if not v-log then do:
/*          apply "entry" to br-list in frame {&frame-name}.*/
          return no-apply.
        end.
        output to value (v-file-name).
        for each obj-list:
            export obj-list.
        end.
        output close.
    end.
    when "gds-list":U
    then do:
        assign
          v-file-name = "goods.txt"
          v-log = yes
        .
        system-dialog get-file v-file-name
          filters "Список товаров *.txt" "*.txt"
          ask-overwrite
          save-as
          use-filename
          update v-log
          default-extension "txt".
        if not v-log then do:
/*          apply "entry" to br-list in frame {&frame-name}.*/
          return no-apply.
        end.
        output to value (v-file-name).
        for each obj-list
        break by obj-list.obj-type
              by obj-list.obj-code
        :
            if first ( obj-list.obj-code )
            then do:
                run form-goods-list in this-procedure ( input obj-list.obj-type,
                                                        input obj-list.obj-code,
                                                        input ""
                                                    ).
            end.
            else do:
                run form-goods-list in this-procedure ( input obj-list.obj-type,
                                                        input obj-list.obj-code,
                                                        input "no-empty"
                                                    ).
            end.
        end.
        for each gds-list
        break by gds-list.gds-code
        :
            if first-of ( gds-list.gds-code )
            then do:
                find first buf_goods no-lock
                     where buf_goods.gds-code = gds-list.gds-code
                .
                display gds-list.gds-code buf_goods.gds-name.
            end.
        end.
    end.
end case.
output close.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
