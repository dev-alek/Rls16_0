&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
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

Экспорт данных в АИС 'Движение н/п в ТПС'

Автор: Уханов Дмитрий Юрьевич
Дата создания: 12/28/07
Author: Dmitry Ukhanov
Creation date: 12/28/07


*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter parparentproc as widget-handle no-undo .

/* Local Variable Definitions ---                                       */
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Экспорт данных в АИС 'Движение н/п в ТПС'".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/clntattr.i }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }

&scop calc-data-order ~
  assign ~
    DateSales ~
  no-error . ~
  if error-status :error then do: ~
    message ~
      error-status :get-message (1) ~
      view-as alert-box error ~
    . ~
    return no-apply . ~
  end. ~
  assign ~
    DateOrder = DateSales + 2 ~
  . ~
  display ~
    DateOrder ~
    with frame ~{&frame-name~} ~
  .

define stream ExpStream .
define stream LogStream .

define temp-table t-obj-list no-undo
  field obj-type  as character
  field obj-code  as integer
  field host-code as integer
  index pi is unique primary obj-type obj-code
  index firm host-code
.

define temp-table t-goods no-undo
  field obj-type        as character
  field obj-code        as integer
  field artic           as character
  field prod-type       as character
  field prod-code       as integer
  field b-code          as integer
  field gds-name        as character
  field SalesVolCounter as decimal
  field SalesVolume     as decimal
  field SalesWeight     as decimal
  field OrderQnty       as decimal
  index pi is unique obj-type obj-code artic prod-type prod-code
  index goods artic prod-type prod-code
.

define temp-table t-goods-tank no-undo
  field obj-type        as character
  field obj-code        as integer
  field artic           as character
  field prod-type       as character
  field prod-code       as integer
  field TankNum         as character
  field StkTank         as decimal
  index pi obj-type obj-code artic prod-type prod-code TankNum
  index goods artic prod-type prod-code
  index tank TankNum
.

define variable v-exp-file-name    as character no-undo .
define variable v-log-file-name    as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help RECT-1 RECT-2 DateSales ~
e-obj-list SelObj DateOrder
&Scoped-Define DISPLAYED-OBJECTS DateSales SelObj DateOrder

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-obj DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 2.5 BY 1.08.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE e-obj-list AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL LARGE
     SIZE 15.75 BY 3.42 NO-UNDO.

DEFINE VARIABLE DateOrder AS DATE FORMAT "99/99/9999":U
     LABEL "прогноза продаж"
      VIEW-AS TEXT
     SIZE 11 BY .67 NO-UNDO.

DEFINE VARIABLE DateSales AS DATE FORMAT "99/99/9999":U
     LABEL "объема продаж"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE SelObj AS CHARACTER INITIAL "Глобально"
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Глобально", "Глобально",
"По фирме", "По фирме",
"Выборочно", "Выборочно"
     SIZE 13.25 BY 2.17 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 35.25 BY 4.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 35.25 BY 4.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.17 COL 2
     b-quit AT ROW 1.17 COL 12
     b-help AT ROW 1.17 COL 27
     DateSales AT ROW 4 COL 20 COLON-ALIGNED
     e-obj-list AT ROW 6.79 COL 20.63 NO-LABEL
     SelObj AT ROW 7.96 COL 3.5 NO-LABEL
     b-obj AT ROW 9.25 COL 17.38
     DateOrder AT ROW 5.29 COL 20 COLON-ALIGNED
     "Дата выгрузки:" VIEW-AS TEXT
          SIZE 15.75 BY .83 AT ROW 2.79 COL 3
     "Выбор объектов:" VIEW-AS TEXT
          SIZE 17.25 BY .83 AT ROW 6.79 COL 3
     RECT-1 AT ROW 2.46 COL 2
     RECT-2 AT ROW 6.46 COL 2
     SPACE(1.12) SKIP(0.41)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Экспорт данных для АИС ТПС"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
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

/* SETTINGS FOR BUTTON b-obj IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR EDITOR e-obj-list IN FRAME Dialog-Frame
   NO-DISPLAY                                                           */
ASSIGN
       e-obj-list:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Экспорт данных для АИС ТПС */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  assign
    DateSales
    DateOrder
  .
  if DateSales = ? then do:
    message
      substitute( "Не задана дата выгрузки" )
      view-as alert-box error
    .
    apply "entry" to DateSales in frame {&frame-name} .
    return no-apply.
  end.

  if SelObj = 'Выборочно' then do:
    find first t-obj-list no-lock
      no-error
    .
    if not available t-obj-list then do:
      message
        substitute( "Не задано ни одного объекта." )
        view-as alert-box error
      .
      apply "entry" to SelObj in frame {&frame-name} .
      return no-apply.
    end.
  end.

  run exp-ais in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-obj Dialog-Frame
ON CHOOSE OF b-obj IN FRAME Dialog-Frame
DO: /* выбрать объект */
  define variable v-user-select as logical   no-undo .

  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

  { gbl/uobjsman.i
    parparentproc
    v-cntxt-db-num
    v-cntxt-userid
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-user-select
  }
  if v-user-select = true
  then do:
    for each t-obj-list
    on error undo, return no-apply
    :
      delete t-obj-list .
    end.
    assign
      e-obj-list    = "":U
    .

    for each buf_userobjs_temp-user-obj
    on error undo, return no-apply
    :
      create t-obj-list .
      assign
        t-obj-list.obj-type = buf_userobjs_temp-user-obj.obj-type
        t-obj-list.obj-code = buf_userobjs_temp-user-obj.obj-code
        e-obj-list = e-obj-list + t-obj-list.obj-type + string( t-obj-list.obj-code ) + " ":U
      .
    end.
    display
      e-obj-list
      with frame {&frame-name}
    .

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME DateSales
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL DateSales Dialog-Frame
ON LEAVE OF DateSales IN FRAME Dialog-Frame /* объема продаж */
DO:
  {&calc-data-order}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL DateSales Dialog-Frame
ON RETURN OF DateSales IN FRAME Dialog-Frame /* объема продаж */
DO:
  {&calc-data-order}
  apply "entry" to SelObj in frame {&frame-name} .
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME SelObj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SelObj Dialog-Frame
ON RETURN OF SelObj IN FRAME Dialog-Frame
DO:
  apply "choose" to b-exit in frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SelObj Dialog-Frame
ON VALUE-CHANGED OF SelObj IN FRAME Dialog-Frame
DO:
  define buffer buf_db      for ub.db  .
  define buffer buf_clients for ub.clients .

  define variable v-object-available as logical   no-undo .

  assign
    SelObj
  .
  for each t-obj-list
  on error undo, return no-apply
  :
    delete t-obj-list .
  end.
  assign
    e-obj-list = "":U
  .
  case SelObj :
    when "Выборочно" then do:
      enable b-obj with frame {&frame-name} .
    end.
    when "По фирме" then do:
      disable b-obj with frame {&frame-name} .

      for each buf_clients no-lock
        where buf_clients.host-code = v-cntxt-host-code-obj
      on error undo, return no-apply
      :
        { gbl/usobjava.i
          v-cntxt-db-num
          {&action-head-code-main}
          v-cntxt-userid
          buf_clients.obj-type
          buf_clients.obj-code
          v-object-available
          no-error
        }
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры gbl/usobjava.i" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return no-apply .
        end.

        if v-object-available = true
        then do:
          create t-obj-list .
          assign
            t-obj-list.obj-type = buf_clients.obj-type
            t-obj-list.obj-code = buf_clients.obj-code
            e-obj-list = e-obj-list + t-obj-list.obj-type + string( t-obj-list.obj-code ) + " ":U
          .
        end.
      end.
    end.
    when "Глобально" then do:
      disable b-obj with frame {&frame-name} .

      for each buf_db no-lock
      on error undo, return no-apply
      :
        for each buf_clients no-lock
          where buf_clients.db-num = buf_db.db-num
        on error undo, return no-apply
        :
          { gbl/usobjava.i
            v-cntxt-db-num
            {&action-head-code-main}
            v-cntxt-userid
            buf_clients.obj-type
            buf_clients.obj-code
            v-object-available
            no-error
          }
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при вызове процедуры gbl/usobjava.i" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return no-apply .
          end.

          if v-object-available = true
          then do:
            create t-obj-list .
            assign
              t-obj-list.obj-type = buf_clients.obj-type
              t-obj-list.obj-code = buf_clients.obj-code
              e-obj-list = e-obj-list + t-obj-list.obj-type + string( t-obj-list.obj-code ) + " ":U
            .
          end.
        end.
      end.
    end.
  end case.
  display
    e-obj-list
    with frame {&frame-name}
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

{ gbl/app_help.i }
{ gbl/ed_date.i DateSales }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  RUN enable_UI.

  apply "value-changed" to SelObj in frame {&frame-name} .
  apply "entry" to DateSales in frame {&frame-name} .

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
  DISPLAY DateSales SelObj DateOrder
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help RECT-1 RECT-2 DateSales e-obj-list SelObj
         DateOrder
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE exp-ais Dialog-Frame
PROCEDURE exp-ais :
do
  on error undo, return error
  :
    define buffer buf_sys-ctrl      for ub.sys-ctrl .
    define buffer buf_rvs-doc       for ub.rvs-doc .
    define buffer prev_rvs-doc      for ub.rvs-doc .
    define buffer buf_rvs-line      for ub.rvs-line .
    define buffer buf_rvs-line-pump for ub.rvs-line-pump .
    define buffer buf_goods         for ub.goods .
    define buffer buf_trn-doc       for ub.trn-doc .
    define buffer buf_doc-line      for ub.doc-line .
    define buffer buf_place         for ub.place .
    define buffer buf_ord-doc       for ub.ord-doc .
    define buffer buf_ord-line      for ub.ord-line .

    define variable v-curr-db          as integer   no-undo .
    define variable v-delim            as character no-undo .
    define variable v-str-obj-list     as character no-undo .
    define variable v-attr-type        as character no-undo .
    define variable v-attr-delivery    as character no-undo .
    define variable v-attr-notdelivery as character no-undo .
    define variable v-coeff            as decimal   no-undo .

    define variable v-obj              as character no-undo .
    define variable v-action           as character no-undo .
    define variable v-cnt              as integer   no-undo .

    def frame inf
      v-obj    label "Объект" format "x(11)" skip
      v-action label "":U format "x(40)" skip
      v-cnt    label "Записей"
      with view-as dialog-box side-labels 1 columns three-d title "** Разбор пакета".


    find first buf_sys-ctrl no-lock .
    assign
      v-curr-db = buf_sys-ctrl.db-num
    .

    assign
      v-exp-file-name = ".":U + {&back-slash-char} + "ais.xml":U
      v-log-file-name = ".":U + {&back-slash-char} + "ais.log":U
    .

    output stream ExpStream to value( v-exp-file-name ) .
    output stream LogStream to value( v-log-file-name ) append.

    assign
      file-info :file-name = v-exp-file-name
      v-exp-file-name = file-info :full-pathname
      file-info :file-name = v-log-file-name
      v-log-file-name = file-info :full-pathname
    .
    output stream LogStream close .

    put stream ExpStream unformatted
      space(0) '<?xml version="1.0" encoding="windows-1251"?>':U skip
      space(0) '<root>':U skip
      space(2) '<Header>':U skip
      space(4) '<Manifest>':U skip
      space(6) '<Name>':U v-exp-file-name '</Name>':U skip
      space(6) '<Version> 14.1':U replace( vss-revision + vss-date, '$':U, ' ':U ) '</Version>':U skip
      space(6) '</Manifest>':U skip
      space(2) '</Header>':U skip
      space(2) '<Options>':U skip
      space(4) '<ExportDate>':U cur-time-date() '</ExportDate>':U skip
      space(4) '<ExportTime>':U string( time, 'HH:MM:SS' ) '</ExportTime>':U skip
      space(4) '<DbNum>':U v-curr-db '</DbNum>':U skip
      space(4) '<DateSales>':U string( DateSales, "99/99/9999" ) '</DateSales>':U skip
      space(4) '<DateOrder>':U string( DateOrder, "99/99/9999" ) '</DateOrder>':U skip
      space(4) '<ObjList>':U
    .
    run write-to-log( 'Экспорт данных для АИС ТПС' ) .
    run write-to-log( substitute( 'Версия 14.1 &1', replace( vss-revision + vss-date, '$':U, ' ':U ) )  ) .
    run write-to-log( substitute( 'Начало выгрузки: &1', cur-time-string-sec() ) ) .
    run write-to-log( substitute( 'Текущая БД: &1', v-curr-db ) ) .
    run write-to-log( substitute( 'Дата объема продаж: &1', string( DateSales, "99/99/9999" ) ) ) .
    run write-to-log( substitute( 'Дата прогноза продаж: &1', string( DateOrder, "99/99/9999" ) ) ) .
    assign
      v-delim = '':U
    .
    for each t-obj-list
    on error undo, return error
    :
      assign
        v-str-obj-list = v-str-obj-list + substitute( "&1&2 &3", v-delim, t-obj-list.obj-type, t-obj-list.obj-code )
      .
      if v-delim = '':U then do:
        assign
          v-delim = ',':U
        .
      end.
    end.
    run write-to-log( substitute( 'Объекты (&1): &2', SelObj, v-str-obj-list ) ).

    assign
      v-delim = '':U
    .
    for each t-obj-list
    on error undo, return error
    :
      find first buf_rvs-doc no-lock
        where buf_rvs-doc.obj-type = t-obj-list.obj-type
          and buf_rvs-doc.obj-code = t-obj-list.obj-code
          and buf_rvs-doc.shift-date = DateSales
          and buf_rvs-doc.rvs-type = {&rvs-shift}
        no-error
      .
      if not available buf_rvs-doc then do:
        run write-to-log( substitute( "На объекте &1 &2 нет сменных сверок за дату &3. Расчет по этому объекту невозможен."
                                      ,t-obj-list.obj-type
                                      ,t-obj-list.obj-code
                                      ,DateSales
                                     )
                        ) .
        delete t-obj-list.
      end.
      else do:
        find first buf_rvs-doc no-lock
          where buf_rvs-doc.obj-type = t-obj-list.obj-type
            and buf_rvs-doc.obj-code = t-obj-list.obj-code
            and buf_rvs-doc.shift-date = DateSales
            and buf_rvs-doc.rvs-type = {&rvs-shift}
            and buf_rvs-doc.status_ <> {&fact}
          no-error
        .
        if available buf_rvs-doc then do:
          run write-to-log( substitute( "На объекте &1 &2 есть незакрытая сверка. Расчет по этому объекту невозможен."
                                        ,t-obj-list.obj-type
                                        ,t-obj-list.obj-code
                                      )
                          ) .
          delete t-obj-list.
        end.
        else do:
          put stream ExpStream unformatted
            v-delim t-obj-list.obj-type ',' t-obj-list.obj-code
          .
          if v-delim = '':U then do:
            assign
              v-delim = ',':U
            .
          end.
        end.
      end.
    end.
    put stream ExpStream unformatted
      '</ObjList>':U skip
      space(2) '</Options>':U skip
      space(2) '<Body>':U skip
    .


    view frame inf.

    for each t-obj-list no-lock
    on error undo, return error
    :
      assign
        v-obj = t-obj-list.obj-type + " ":U + string( t-obj-list.obj-code )
      .
      run clntattr-value( input t-obj-list.obj-type
                         ,input t-obj-list.obj-code
                         ,input {&attr-delivery}
                         ,output v-attr-delivery
                         ,output v-attr-type
                        ) no-error.
      if error-status :error then do:
        run write-to-log( substitute( 'Ошибка при чтении атрибута атрибута "Временной интервал возможности доставки" для объекта &1 &2'
                                      ,t-obj-list.obj-type
                                      ,t-obj-list.obj-code
                                    )
                          + {&new-line}
                          + return-value + {&new-line}
                          + error-status :get-message ( error-status :num-messages ) + {&new-line}
                        ) .
      end.
      else do:
        if v-attr-delivery = "":U then do:
          run write-to-log( substitute( 'Для объекта &1 &2 не задан временной интервал возможности доставки'
                                        ,t-obj-list.obj-type
                                        ,t-obj-list.obj-code
                                       )
                          ) .
        end.
      end.
      run clntattr-value( input t-obj-list.obj-type
                         ,input t-obj-list.obj-code
                         ,input {&attr-notdelivery}
                         ,output v-attr-notdelivery
                         ,output v-attr-type
                        ) no-error.
      if error-status :error then do:
        run write-to-log( substitute( 'Ошибка при чтении атрибута атрибута "Временной интервал, запрещенный к доставке" для объекта &1 &2'
                                      ,t-obj-list.obj-type
                                      ,t-obj-list.obj-code
                                    )
                          + {&new-line}
                          + return-value + {&new-line}
                          + error-status :get-message ( error-status :num-messages ) + {&new-line}
                        ) .
      end.
      else do:
        if v-attr-notdelivery = "":U then do:
          run write-to-log( substitute( 'Для объекта &1 &2 не задан временной интервал, запрещенный к доставке'
                                        ,t-obj-list.obj-type
                                        ,t-obj-list.obj-code
                                       )
                          ) .
        end.
      end.

      put stream ExpStream unformatted
        space(4) '<ObjInfo>':U skip
        space(6) '<ObjType>':U t-obj-list.obj-type '</ObjType>':U skip
        space(6) '<ObjCode>':U t-obj-list.obj-code '</ObjCode>':U skip
        space(6) '<TimeDelivery>':U v-attr-delivery '</TimeDelivery>':U skip
        space(6) '<TimeNotDelivery>':U v-attr-notdelivery '</TimeNotDelivery>':U skip
        space(4) '</ObjInfo>':U skip
      .

      find first buf_rvs-doc no-lock
        where buf_rvs-doc.obj-type = t-obj-list.obj-type
          and buf_rvs-doc.obj-code = t-obj-list.obj-code
          and buf_rvs-doc.shift-date = DateSales
          and buf_rvs-doc.rvs-type = {&rvs-shift}
      .
      for each buf_rvs-line-pump no-lock
        where buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
      on error undo, return error
      :
        find first buf_goods no-lock
          where buf_goods.gds-code = buf_rvs-line-pump.gds-code
        .

        find first t-goods
          where t-goods.obj-type  = buf_rvs-line-pump.obj-type
            and t-goods.obj-code  = buf_rvs-line-pump.obj-code
            and t-goods.artic     = buf_goods.artic
            and t-goods.prod-type = buf_goods.prod-type
            and t-goods.prod-code = buf_goods.prod-code
          no-error
        .
        if not available t-goods then do:
          create t-goods .
          assign
            t-goods.obj-type  = buf_rvs-line-pump.obj-type
            t-goods.obj-code  = buf_rvs-line-pump.obj-code
            t-goods.artic     = buf_goods.artic
            t-goods.prod-type = buf_goods.prod-type
            t-goods.prod-code = buf_goods.prod-code
            t-goods.gds-name  = buf_goods.gds-name
          .
          { gbl/gdsbcode.i
              buf_goods.gds-code
              ?
              t-goods.b-code
          }
          assign
            v-action = "Расчет объема продаж"
            v-cnt    = 0
          .
          for each buf_trn-doc no-lock
            where buf_trn-doc.obj-type     = buf_rvs-doc.obj-type
              and buf_trn-doc.obj-code     = buf_rvs-doc.obj-code
              and buf_trn-doc.shift-date   = DateSales
          on error undo, return error
          :
            if buf_trn-doc.status_ = {&fact}
              and ( buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
                    or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
                    or buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
                    or buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}
                  )
            then do:
              if buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
                 or buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}
              then do:
                assign
                  v-coeff = -1
                .
              end.
              else do:
                assign
                  v-coeff = 1
                .
              end.
              for each buf_doc-line no-lock
                where buf_doc-line.doc-code  = buf_trn-doc.doc-code
                  and buf_doc-line.prod-type = buf_goods.prod-type
                  and buf_doc-line.prod-code = buf_goods.prod-code
                  and buf_doc-line.artic     = buf_goods.artic
              on error undo, return error
              :
                assign
                  t-goods.SalesVolume = t-goods.SalesVolume + v-coeff * buf_doc-line.fact-qnty
                  t-goods.SalesWeight = t-goods.SalesVolume * buf_doc-line.fact-density
                .
                assign
                  v-cnt = v-cnt + 1
                .
                display
                  v-obj
                  v-action
                  v-cnt
                  with frame inf .
              end.
            end.
          end.

          assign
            v-action = "Просмотр заказов"
            v-cnt    = 0
          .

          for each buf_ord-doc no-lock
            where buf_ord-doc.obj-type   = buf_rvs-doc.obj-type
              and buf_ord-doc.obj-code   = buf_rvs-doc.obj-code
              and buf_ord-doc.ship-date  = DateOrder
              and buf_ord-doc.doc-type   = {&o-f}
              and buf_ord-doc.status_   <> {&g___new}
              and buf_ord-doc.status_   <> {&ord-rejection}
            ,each buf_ord-line no-lock
            where buf_ord-line.doc-code  = buf_ord-doc.doc-code
              and buf_ord-line.artic     = buf_goods.artic
              and buf_ord-line.prod-type = buf_goods.prod-type
              and buf_ord-line.prod-code = buf_goods.prod-code
          on error undo, return error
          :
            assign
              t-goods.OrderQnty = t-goods.OrderQnty + buf_ord-line.qnty
            .
            assign
              v-cnt = v-cnt + 1
            .
            display
              v-obj
              v-action
              v-cnt
              with frame inf .
          end.
          if v-cnt = 0 then do:
            run write-to-log( substitute( 'На объекте &1 &2 нет ни одной заявки на &3 по товару &4 &5 &6'
                                          ,t-obj-list.obj-type
                                          ,t-obj-list.obj-code
                                          ,string( DateOrder, "99/99/9999":U )
                                          ,buf_goods.artic
                                          ,buf_goods.prod-type
                                          ,buf_goods.prod-code
                                        )
                            ) .
          end.

          assign
            v-action = "Сбор информации по танкам"
            v-cnt    = 0
          .

          for each buf_rvs-line no-lock
            where buf_rvs-line.gds-code = buf_goods.gds-code
              and buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
          on error undo, return error
          :
            find first buf_place no-lock
              where buf_place.obj-type = buf_rvs-line.obj-type
                and buf_place.obj-code = buf_rvs-line.obj-code
                and buf_place.pl-code  = buf_rvs-line.pl-code
            .
            create t-goods-tank .
            assign
              t-goods-tank.obj-type  = buf_rvs-line-pump.obj-type
              t-goods-tank.obj-code  = buf_rvs-line-pump.obj-code
              t-goods-tank.artic     = buf_goods.artic
              t-goods-tank.prod-type = buf_goods.prod-type
              t-goods-tank.prod-code = buf_goods.prod-code
              t-goods-tank.TankNum   = buf_place.loc1
              t-goods-tank.StkTank   = buf_rvs-line.state-measure-qnty
            .
            assign
              v-cnt = v-cnt + 1
            .
            display
              v-obj
              v-action
              v-cnt
              with frame inf .
          end.
        end.
        assign
          t-goods.SalesVolCounter = t-goods.SalesVolCounter + buf_rvs-line-pump.state-el-cnt
        .

      end.
      find first prev_rvs-doc no-lock
        where prev_rvs-doc.obj-type = t-obj-list.obj-type
          and prev_rvs-doc.obj-code = t-obj-list.obj-code
          and prev_rvs-doc.shift-date < DateSales
          and prev_rvs-doc.rvs-type = {&rvs-shift}
        no-error
      .
      for each buf_rvs-line-pump no-lock
        where buf_rvs-line-pump.rvs-code = prev_rvs-doc.rvs-code
      on error undo, return error
      :
        find first buf_goods no-lock
          where buf_goods.gds-code = buf_rvs-line-pump.gds-code
        .
        find first t-goods
          where t-goods.obj-type  = buf_rvs-line-pump.obj-type
            and t-goods.obj-code  = buf_rvs-line-pump.obj-code
            and t-goods.artic     = buf_goods.artic
            and t-goods.prod-type = buf_goods.prod-type
            and t-goods.prod-code = buf_goods.prod-code
          no-error
        .
        if available t-goods then do:
          assign
            t-goods.SalesVolCounter = t-goods.SalesVolCounter - buf_rvs-line-pump.state-el-cnt
          .
        end.
      end.

      assign
        v-action = "Вывод информации в файл"
        v-cnt    = ?
      .
      display
        v-obj
        v-action
        v-cnt
        with frame inf .

      for each t-goods no-lock
      on error undo, return error
      :
        put stream ExpStream unformatted
          space(4) '<Good>':U skip
          space(6) '<ObjType>':U t-goods.obj-type '</ObjType>':U skip
          space(6) '<ObjCode>':U t-goods.obj-code '</ObjCode>':U skip
          space(6) '<Artic>':U t-goods.artic '</Artic>':U skip
          space(6) '<ProdType>':U t-goods.prod-type '</ProdType>':U skip
          space(6) '<ProdCode>':U t-goods.prod-code '</ProdCode>':U skip
          space(6) '<BarCode>':U t-goods.b-code '</BarCode>':U skip
          space(6) '<GdsName>':U t-goods.gds-name '</GdsName>':U skip
          space(6) '<SalesVolCounter>':U t-goods.SalesVolCounter '</SalesVolCounter>':U skip
          space(6) '<SalesVolume>':U t-goods.SalesVolume '</SalesVolume>':U skip
          space(6) '<SalesWeight>':U t-goods.SalesWeight '</SalesWeight>':U skip
          space(6) '<OrderQty>':U t-goods.OrderQnty '</OrderQty>':U skip
          space(4) '</Good>':U skip
        .
        for each t-goods-tank no-lock
          where t-goods-tank.obj-type  = t-goods.obj-type
            and t-goods-tank.obj-code  = t-goods.obj-code
            and t-goods-tank.artic     = t-goods.artic
            and t-goods-tank.prod-type = t-goods.prod-type
            and t-goods-tank.prod-code = t-goods.prod-code
        on error undo, return error
        :
          put stream ExpStream unformatted
            space(4) '<Tank>':U skip
            space(6) '<ObjType>':U t-goods-tank.obj-type '</ObjType>':U skip
            space(6) '<ObjCode>':U t-goods-tank.obj-code '</ObjCode>':U skip
            space(6) '<Artic>':U t-goods-tank.artic '</Artic>':U skip
            space(6) '<ProdType>':U t-goods-tank.prod-type '</ProdType>':U skip
            space(6) '<ProdCode>':U t-goods-tank.prod-code '</ProdCode>':U skip
            space(6) '<TankNum>':U t-goods-tank.TankNum '</TankNum>':U skip
            space(6) '<StkTank>':U t-goods-tank.StkTank '</StkTank>':U skip
            space(4) '</Tank>':U skip
          .
        end.
      end.

    end.

    hide frame inf .

    put stream ExpStream unformatted
      space(2) '</Body>':U skip
      space(0) '</root>':U skip
    .

    run write-to-log( substitute( 'Окончание выгрузки: &1', cur-time-string-sec() ) ) .

    output stream ExpStream close.

    message
      "Отчет выведен в файл" v-exp-file-name skip
      "Создан log файл" v-log-file-name
      view-as alert-box information.

  end.
  return .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-to-log Dialog-Frame
PROCEDURE write-to-log :
define input parameter v-message as character no-undo .
  do
  on error undo, return error
  :
    output stream LogStream to value( v-log-file-name ) append.
    put stream LogStream unformatted
      cur-time-string-sec() {&space-char} v-cntxt-userid {&space-char} {&space-char} v-message skip
    .
    output stream LogStream close.
  end.
  return .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME