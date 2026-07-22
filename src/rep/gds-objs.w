&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-gds-objs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-gds-objs
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Остатки по признаку по всем объектам текущей фирмы или всех фирм

Автор: Перваков Михаил Сергеевич
Дата создания: 04/12/06
Author: Mikhail Pervakov
Creation date: 04/12/06

*/
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc  as widget-handle no-undo.
define input parameter pp-artic     like ub.prt-obj.artic     no-undo.
define input parameter pp-prod-type like ub.prt-obj.prod-type no-undo.
define input parameter pp-prod-code like ub.prt-obj.prod-code no-undo.
define input parameter pp-host-code like ub.prt-obj.host-code no-undo.
define input parameter pp-node-code like ub.gds-prt.node-code no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Остатки по признаку по всем объектам текущей фирмы или всех фирм".

{ cmp/vssrevis.i    }
{ cmp/trg-def.i     }
{ cmp/showinf.i     }
{ cmp/library.i     }
{ str/lib-trn.i     }
{ rep/temp-prt.i kg }
{ gbl/waitfram.i    }
{ gbl/getcntxt.i def }

define variable v-is-ptrl     as character no-undo.
define variable v-data-type   as character no-undo.
define variable is-petrol     as logical   no-undo initial ?.
define variable is-pieces     as logical   no-undo initial ?.
define variable is-kg-visible as logical   no-undo initial ?.

define buffer buf_temp_prt-obj for temp_prt-obj .
define buffer buf_goods        for ub.goods .
define buffer buf_gds-prt      for ub.gds-prt .
define variable p-need as decimal   no-undo .

function f-on-line return decimal (buffer buf_temp_prt-obj for temp_prt-obj).
define variable v-value      as character no-undo .
define variable v-type       as character no-undo .
define variable v-obj-db-num as integer   no-undo .
define buffer bf_gds-obj for ub.gds-obj  .
define buffer buf_db     for ub.db .

{ gbl/objdbnum.i  buf_temp_prt-obj.obj-type buf_temp_prt-obj.obj-code v-obj-db-num }
find first bf_gds-obj where
          bf_gds-obj.obj-type = buf_temp_prt-obj.obj-type and
          bf_gds-obj.obj-code = buf_temp_prt-obj.obj-code and
          bf_gds-obj.gds-code = buf_goods.gds-code
          no-error .
find first buf_db no-lock where
           buf_db.db-num = v-obj-db-num
           .
if v-obj-db-num = g#db-num then do:
   if available bf_gds-obj then
       return bf_gds-obj.free-qnty .
   else
       return ? .
end.
else do:
   if available bf_gds-obj
     and buf_db.on-line-rest = true
   then
       return bf_gds-obj.on-line-rest .
   else
       return ? .
end.

end function.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME d-gds-objs
&Scoped-define BROWSE-NAME br-prt-obj

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_temp_prt-obj

/* Definitions for BROWSE br-prt-obj                                    */
&Scoped-define FIELDS-IN-QUERY-br-prt-obj (buf_temp_prt-obj.obj-type + " " + string (buf_temp_prt-obj.obj-code, "99999")) buf_temp_prt-obj.obj-name buf_temp_prt-obj.qnty buf_temp_prt-obj.free-qnty buf_temp_prt-obj.price buf_temp_prt-obj.sdate buf_temp_prt-obj.stime buf_temp_prt-obj.db-num buf_temp_prt-obj.db-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-prt-obj
&Scoped-define SELF-NAME br-prt-obj
&Scoped-define OPEN-QUERY-br-prt-obj /* OPEN QUERY {&SELF-NAME} for each buf_temp_prt-obj no-lock. */ run UI-on in this-procedure .
&Scoped-define TABLES-IN-QUERY-br-prt-obj buf_temp_prt-obj
&Scoped-define FIRST-TABLE-IN-QUERY-br-prt-obj buf_temp_prt-obj


/* Definitions for DIALOG-BOX d-gds-objs                                */
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-gds-objs ~
    ~{&OPEN-QUERY-br-prt-obj}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-help RECT-1 rs-firm-global ~
br-prt-obj FI-Filter-Label
&Scoped-Define DISPLAYED-OBJECTS total-fact total-sum rs-firm-global ~
fi-description firm-name FI-Filter-Label

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1 TOOLTIP "Помощь"
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход "
     SIZE 10 BY 1 TOOLTIP "Выход из экрана"
     BGCOLOR 8 .

DEFINE VARIABLE fi-description AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 98 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FI-Filter-Label AS CHARACTER FORMAT "X(256)":U INITIAL "Фильтр:"
      VIEW-AS TEXT
     SIZE 8.5 BY .67 NO-UNDO.

DEFINE VARIABLE firm-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Фирма"
     VIEW-AS FILL-IN
     SIZE 87.5 BY 1 TOOLTIP "Название фирмы, к которой относится объект"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE total-fact AS DECIMAL FORMAT "->>,>>>,>>9.<<<":U INITIAL 0
     LABEL "Количество по объектам"
     VIEW-AS FILL-IN
     SIZE 16.88 BY 1 TOOLTIP "Общее количество на всех объектах фирмы (всех фирм)"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE total-sum AS DECIMAL FORMAT "->>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма по объектам в ценах продажи"
     VIEW-AS FILL-IN
     SIZE 16.88 BY 1 TOOLTIP "Остаток товара по всем объектам фирмы (фирм) в ценах продажи"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE ed_izm AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE total-fact-kg AS DECIMAL FORMAT "->>,>>>,>>9.<<<":U INITIAL 0
     LABEL "Количество по объектам"
     VIEW-AS FILL-IN
     SIZE 16.88 BY 1 TOOLTIP "Общее количество (кг) на всех объектах фирмы (всех фирм)"
     FGCOLOR 4  NO-UNDO.

/* DEFINE VARIABLE total-sum-kg AS DECIMAL FORMAT "->>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма по объектам в ценах продажи"
     VIEW-AS FILL-IN
     SIZE 16.88 BY 1 TOOLTIP "Остаток товара по всем объектам фирмы (фирм) в ценах продажи (за кг)"
     FGCOLOR 4  NO-UNDO. */

DEFINE VARIABLE rs-firm-global AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "&Фирма", "firm",
"&Глобально", "global"
     SIZE 16.5 BY 2.00 TOOLTIP "Остатки по объектам текущей фирмы или по всем фирмам"
     FGCOLOR 4  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 77.50 BY 2.79.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY {&BROWSE-NAME} FOR
      buf_temp_prt-obj SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE {&BROWSE-NAME}
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-prt-obj d-gds-objs _FREEFORM
  QUERY {&BROWSE-NAME} NO-LOCK DISPLAY
      (buf_temp_prt-obj.obj-type + " " + string (buf_temp_prt-obj.obj-code, "99999"))
                                   column-label "Объект"           format "x(9)":U
      buf_temp_prt-obj.obj-name    column-label "Название объекта" format "x(25)":U
      f-on-line( buffer buf_temp_prt-obj ) @ p-need  column-label "On-line Ост."   format "->,>>>,>>9.<<<":U
      buf_temp_prt-obj.qnty        column-label "Количество"
      buf_temp_prt-obj.free-qnty   column-label "Свободно"
      buf_temp_prt-obj.price       column-label "Цена"             format ">,>>>,>>9.99":U
      buf_temp_prt-obj.fact-qty-kg column-label "Кол-во, кг"
      buf_temp_prt-obj.free-qty-kg column-label "Свободно, кг"
      buf_temp_prt-obj.price-kg    column-label "Цена за кг"       format ">,>>>,>>9.99":U
      buf_temp_prt-obj.sdate       column-label "Дата"             format "99/99/9999":U
      buf_temp_prt-obj.stime       column-label "Время"            format "x(8)":U
      buf_temp_prt-obj.db-num                                      format ">>9":U
      buf_temp_prt-obj.db-name                                     format "x(40)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 13.25.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME {&FRAME-NAME}
     b-quit          AT ROW  1.25 COL  1.00
     b-help          AT ROW  1.25 COL 11.00
     total-fact      AT ROW  1.67 COL 56.50 COLON-ALIGNED
     total-fact-kg   AT ROW  1.67 COL 74.50 COLON-ALIGNED NO-LABEL
     ed_izm          AT ROW  1.67 COL 92.00 COLON-ALIGNED NO-LABEL
     total-sum       AT ROW  2.67 COL 56.50 COLON-ALIGNED
     /* total-sum-kg    AT ROW  2.67 COL 74.50 COLON-ALIGNED NO-LABEL */
     rs-firm-global  AT ROW  2.42 COL  2.00               NO-LABEL
     fi-description  AT ROW  5.25 COL  1.00               NO-LABEL
     {&BROWSE-NAME}  AT ROW  6.54 COL  1.00
     firm-name       AT ROW 20.13 COL  7.50 COLON-ALIGNED
     FI-Filter-Label AT ROW  4.50 COL  1.75               NO-LABEL
     RECT-1          AT ROW  1.25 COL 21.38 SPACE( 0.98 ) SKIP( 16.78 )
WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
     TITLE "Остатки по признаку" CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-gds-objs
                                                                        */
/* BROWSE-TAB br-prt-obj fi-description d-gds-objs */
ASSIGN
       FRAME {&FRAME-NAME}:SCROLLABLE       = FALSE
       FRAME {&FRAME-NAME}:HIDDEN           = TRUE.

ASSIGN
       {&BROWSE-NAME}:NUM-LOCKED-COLUMNS IN FRAME {&FRAME-NAME}     = 1.

/* SETTINGS FOR FILL-IN fi-description IN FRAME d-gds-objs
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN FI-Filter-Label IN FRAME d-gds-objs
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN firm-name IN FRAME d-gds-objs
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN total-fact IN FRAME d-gds-objs
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN total-sum IN FRAME d-gds-objs
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-prt-obj
/* Query rebuild information for BROWSE br-prt-obj
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} for each buf_temp_prt-obj no-lock. */
run UI-on in this-procedure .
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _TblOptList       = ",,,"
     _Query            is OPENED
*/  /* BROWSE br-prt-obj */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-gds-objs
/* Query rebuild information for DIALOG-BOX d-gds-objs
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-gds-objs */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-gds-objs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-gds-objs d-gds-objs
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} /* Остатки по признаку */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-prt-obj
&Scoped-define SELF-NAME br-prt-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-prt-obj d-gds-objs
ON VALUE-CHANGED OF {&BROWSE-NAME} IN FRAME {&FRAME-NAME}
DO:
  define buffer host-b for ub.clients.

  if not available buf_temp_prt-obj then do: return no-apply. end.
  if buf_temp_prt-obj.obj-type = {&stock} then do:
    find ub.store no-lock where ub.store.obj-code = buf_temp_prt-obj.obj-code.
    find host-b   no-lock where
         host-b.obj-type = {&cmp} and
         host-b.obj-code = ub.store.host-code.
  end.
  else do:
    find ub.shop no-lock where ub.shop.obj-code = buf_temp_prt-obj.obj-code.
    find host-b  no-lock where
         host-b.obj-type = {&cmp} and
         host-b.obj-code = ub.shop.host-code.
  end.
  assign  firm-name = host-b.obj-name.
  display firm-name with frame {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-firm-global
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-firm-global d-gds-objs
ON VALUE-CHANGED OF rs-firm-global IN FRAME {&FRAME-NAME}
DO:
  define variable is-glob as logical no-undo. /* действие может быть выполнено - g#log */

  assign rs-firm-global.
  if rs-firm-global = "global"
  then do:
    /* проверка прав на просмотр объектов другой фирмы */
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_documents_all':U
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      true
      is-glob
    }
    if is-glob = no then do: assign rs-firm-global = "firm". end.
  end.
  run UI-on in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-gds-objs


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

{ gbl/brwrepos.i
  &line-num=8
}
{ gbl/brwrefre.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

  assign
    v-is-ptrl = ?
    is-petrol = ?
    is-pieces = ?
  .
  { gbl/conf-rd.i "'is-ptrl'" "''" "''" 0 "''" "''" "''" no v-is-ptrl v-data-type no-error }
  if error-status :error or v-data-type <> "L" or lookup( v-is-ptrl, "yes,no" ) = 0 then do: assign v-is-ptrl = "no". end.
  if v-is-ptrl = "yes" then do:
    { str/is-petrl.i pp-artic
                 pp-prod-type
                 pp-prod-code
                 is-petrol
                 is-pieces    no-error }
    if not error-status :error and is-petrol = yes and is-pieces = no then do:
      assign
        is-kg-visible = yes
      .
    end.
  end. /* is-ptrl */
  if is-kg-visible <> yes then do:
    assign
      buf_temp_prt-obj.fact-qty-kg :visible in browse {&BROWSE-NAME} = no
      buf_temp_prt-obj.free-qty-kg :visible in browse {&BROWSE-NAME} = no
      buf_temp_prt-obj.price-kg    :visible in browse {&BROWSE-NAME} = no
    .
    assign
      total-fact-kg :hidden in frame {&frame-name} = no
   /* total-sum-kg  :hidden in frame {&frame-name} = no */
      ed_izm        :hidden in frame {&frame-name} = no
    .
  end. /* not visible */

  find first buf_goods no-lock where
             buf_goods.artic     = pp-artic     and
             buf_goods.prod-type = pp-prod-type and
             buf_goods.prod-code = pp-prod-code .
  if pp-node-code <> -1 then do:
    find first buf_gds-prt no-lock where buf_gds-prt.node-code = pp-node-code.
  end.
  assign
    rs-firm-global = 'firm':u
    ed_izm         = buf_goods.unit-cli
  .

  run UI-on in this-procedure .

  WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS b-quit.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-gds-objs  _DEFAULT-DISABLE
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
  HIDE FRAME {&FRAME-NAME} NO-PAUSE.
END PROCEDURE. /* disable_UI */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-gds-objs  _DEFAULT-ENABLE
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
  DISPLAY total-fact total-sum rs-firm-global fi-description firm-name
          FI-Filter-Label
      WITH FRAME {&FRAME-NAME}.
  ENABLE b-quit b-help RECT-1 rs-firm-global {&BROWSE-NAME} FI-Filter-Label
      WITH FRAME {&FRAME-NAME}.
  VIEW FRAME {&FRAME-NAME}.
  {&OPEN-BROWSERS-IN-QUERY-d-gds-objs}
END PROCEDURE. /* enable_UI */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE UI-on d-gds-objs
PROCEDURE UI-on :
/*------------------------------------------------------------------------------
  Purpose:     instead of enable_ui
------------------------------------------------------------------------------*/

  define variable v-db-num    as integer no-undo.
  define variable v-root-node as integer no-undo.

  define buffer buf_db for ub.db .

  /* определяем корневой признак */
  { gbl/rootnode.i   pp-artic  pp-prod-type  pp-prod-code  v-root-node  no-error  }
  if error-status :error then do:
    message vss-workfile vss-revision vss-description   skip
            "Ошибка при определении корневого признака" skip
    view-as alert-box error .
    undo, return error .
  end.

  { gbl/curdbnum.i
    v-db-num
  }

  if v-db-num <> 0 then do:
    find first buf_db no-lock where buf_db.db-num = v-db-num no-error .
    if not available buf_db then do:
      message vss-workfile vss-revision vss-description skip
              "Ошибка при поиске базы данных" skip
              "База данных" v-db-num skip
      view-as alert-box error .
      undo, return error return-value .
    end.

    p-need:visible in browse {&BROWSE-NAME} = false  .

    if buf_db.remote-stock = true then do:
      assign
        fi-description = "Приём информации об остатках из других БД включён."
      .
    end.
    else do:
      assign
        fi-description = "Приём информации об остатках из других БД выключен. Информация об остатках является устаревшей."
      .
    end.
  end.
  else do:
    p-need:visible in browse {&BROWSE-NAME} = true   .
    assign
      fi-description = "Приём информации об остатках из других БД включён."
    .
  end.

  run waitfram-show     in this-procedure (  input "Считывание остатков" ) .
  run fill-temp_prt-obj in this-procedure (  input pp-artic,
                                             input pp-prod-type,
                                             input pp-prod-code,
                                             input pp-host-code,
                                             input ( if pp-node-code = -1 then v-root-node else pp-node-code ),
                                             input rs-firm-global,
                                             input is-kg-visible,
                                            output total-fact,
                                            output total-sum,
                                            output total-fact-kg /* ,
                                            output total-sum-kg   */                                            ) .
  run waitfram-hide     in this-procedure .

  display
    total-fact
    total-fact-kg  when is-kg-visible = yes
    ed_izm         when is-kg-visible = yes
    rs-firm-global
    total-sum
    /* total-sum-kg   when is-kg-visible = yes */
    fi-description
  with frame {&FRAME-NAME} .
  enable
    b-quit
    b-help
    {&BROWSE-NAME}
    rs-firm-global
  with frame {&FRAME-NAME} .
  view frame {&FRAME-NAME}.

  if rs-firm-global = "firm" then do:
    assign frame {&FRAME-NAME} :title = 'Остатки по объектам текущей фирмы.'.
    OPEN QUERY {&BROWSE-NAME} FOR EACH buf_temp_prt-obj NO-LOCK BY buf_temp_prt-obj.qnty DESCENDING.
  end.
  else do:
    assign frame {&FRAME-NAME} :title = 'Остатки по объектам всех фирм.'.
    OPEN QUERY {&BROWSE-NAME} FOR EACH buf_temp_prt-obj NO-LOCK BY buf_temp_prt-obj.qnty DESCENDING.
  end.

  apply "VALUE-CHANGED":U to browse {&BROWSE-NAME}.

  if pp-node-code = -1 then do:
    assign frame {&FRAME-NAME} :title = frame {&FRAME-NAME} :title + '   Артикул : ' + buf_goods.artic +
                                        '    ' + buf_goods.gds-name.
  end.
  else do:
    assign frame {&FRAME-NAME} :title = frame {&FRAME-NAME} :title + '   Артикул : ' + buf_goods.artic +
                                        '    Признак : ' + buf_gds-prt.f-name + '    ' + buf_goods.gds-name.
  end.
END PROCEDURE. /* UI-on */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME