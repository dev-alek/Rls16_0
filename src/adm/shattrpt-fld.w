&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME D-Dialog


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_thbj-attr FOR thbj-attr.
DEFINE NEW SHARED TEMP-TABLE temp-thbj-attr NO-UNDO LIKE thbj-attr.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS D-Dialog 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр документов

Автор: Суслов Алексей Юрьевич
Дата создания: 04/11/06
Author: Alexey Suslov
Creation date: 04/11/06

*/

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE       NO-UNDO.
DEFINE INPUT PARAMETER p-mode        AS CHARACTER           NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type  LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code  LIKE ub.shop.obj-code    NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision: 8482156d642d, 3444, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2023/10/16 15:13:33 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: shattrpt.w $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/shattrpt.w $":U .
define variable vss-description as character no-undo init "Экран настроек работы с топливном".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/clntattr.i }
{ gbl/thbjattr.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/color.i    }
{ gbl/twowin.i   }
{ str/trdcalib.i }
{ gbl/cur-time.i }
{ gbl/sys-time.i }
{ cmp/trg-def.i  }

define variable v-tth           as   handle       no-undo .
define variable v-tempth        as   handle       no-undo .
define variable v-to-create     as   logical      no-undo .
DEFINE VARIABLE v-db-num        like ub.db.db-num no-undo.

define variable v-list-dop-info-full as character    no-undo.
define variable v-list-dop-info      as character    no-undo.

define temp-table temp_twowin_itemsSelected_col no-undo
    field its-key   as integer
    field itm-key   as integer
    field itmExtKey as character

    index pi is primary unique
      its-key
    index im
      itm-key
.

define variable v-list-sec-fields-full as character    no-undo.
define variable v-list-sec-fields      as character    no-undo.

define temp-table sect_twowin_itemsSelected_col no-undo
    field its-key   as integer
    field itm-key   as integer
    field itmExtKey as character

    index pi is primary unique
      its-key
    index im
      itm-key
.

define variable mChkPart1 as logical no-undo.
define variable mChkPart2 as logical no-undo. 

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartDialog
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER DIALOG-BOX

&Scoped-define ADM-SUPPORTED-LINKS Record-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME D-Dialog

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of handles for SmartObjects                              */
DEFINE VARIABLE h_folder AS HANDLE NO-UNDO.
DEFINE VARIABLE h_part1 AS HANDLE NO-UNDO.
DEFINE VARIABLE h_part2 AS HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME D-Dialog
     B-exit AT ROW 1 COL 1 WIDGET-ID 2
     b-quit AT ROW 1 COL 11 WIDGET-ID 6
     B-Help AT ROW 1 COL 116 WIDGET-ID 4
     SPACE(2.00) SKIP(29.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Просмотр информации по документам".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartDialog
   Allow: Basic,Browse,DB-Fields,Query,Smart
   Design Page: 3
   Temp-Tables and Buffers:
      TABLE: locked_thbj-attr B "?" ? ub thbj-attr
      TABLE: temp-thbj-attr T "NEW SHARED" NO-UNDO ub thbj-attr
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB D-Dialog 
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX D-Dialog
   FRAME-NAME                                                           */
ASSIGN 
       FRAME D-Dialog:SCROLLABLE       = FALSE
       FRAME D-Dialog:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX D-Dialog
/* Query rebuild information for DIALOG-BOX D-Dialog
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX D-Dialog */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME D-Dialog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL D-Dialog D-Dialog
ON WINDOW-CLOSE OF FRAME D-Dialog /* Просмотр информации по документам */
DO:
  /* Add Trigger to equate WINDOW-CLOSE to END-ERROR. */
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit D-Dialog
ON CHOOSE OF B-exit IN FRAME D-Dialog /* Ввод */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK D-Dialog 


/* ***************************  Main Block  *************************** */
{ gbl/app_help.i }
{src/adm/template/dialogmn.i}
run fill-widgets in this-procedure no-error.
if error-status:error then undo, return error.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects D-Dialog  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/
  DEFINE VARIABLE adm-current-page  AS INTEGER NO-UNDO.

  RUN get-attribute IN THIS-PROCEDURE ('Current-Page':U).
  ASSIGN adm-current-page = INTEGER(RETURN-VALUE).

  CASE adm-current-page: 

    WHEN 0 THEN DO:
       RUN init-object IN THIS-PROCEDURE (
             INPUT  'adm/objects/folder.w':U ,
             INPUT  FRAME D-Dialog:HANDLE ,
             INPUT  'FOLDER-LABELS = ':U + 'Часть1|Часть2' + ',
                     FOLDER-TAB-TYPE = 1':U ,
             OUTPUT h_folder ).
       RUN set-position IN h_folder ( 2.25 , 1.00 ) NO-ERROR.
       RUN set-size IN h_folder ( 28.75 , 120.00 ) NO-ERROR.

       /* Links to SmartFolder h_folder. */
       RUN add-link IN adm-broker-hdl ( h_folder , 'Page':U , THIS-PROCEDURE ).

       /* Adjust the tab order of the smart objects. */
       RUN adjust-tab-order IN adm-broker-hdl ( h_folder ,
             B-Help:HANDLE , 'AFTER':U ).
    END. /* Page 0 */
    WHEN 1 THEN DO:
       RUN init-object IN THIS-PROCEDURE (
             INPUT  'adm/shattrpt-pt1.w':U ,
             INPUT  FRAME D-Dialog:HANDLE ,
             INPUT  'Layout = ':U ,
             OUTPUT h_part1 ).
       RUN set-position IN h_part1 ( 3.50 , 1.50 ) NO-ERROR.
       /* Size in UIB:  ( 27.25 , 118.50 ) */

       /* Links to SmartObject h_part1. */
       RUN add-link IN adm-broker-hdl ( THIS-PROCEDURE , 'Record':U , h_part1 ).

       /* Adjust the tab order of the smart objects. */
       RUN adjust-tab-order IN adm-broker-hdl ( h_part1 ,
             h_folder , 'AFTER':U ).
          
       mChkPart1 = yes.
       RUN PartOne-Init in h_part1 (parparentproc, p-mode, p-obj-type, p-obj-code, input table-handle v-tempth).
    END. /* Page 1 */
    WHEN 2 THEN DO:
       RUN init-object IN THIS-PROCEDURE (
             INPUT  'adm/shattrpt-pt2.w':U ,
             INPUT  FRAME D-Dialog:HANDLE ,
             INPUT  'Layout = ':U ,
             OUTPUT h_part2 ).
       RUN set-position IN h_part2 ( 3.50 , 1.50 ) NO-ERROR.
       /* Size in UIB:  ( 27.25 , 118.50 ) */

       /* Links to SmartObject h_part2. */
       RUN add-link IN adm-broker-hdl ( THIS-PROCEDURE , 'Record':U , h_part2 ).

       /* Adjust the tab order of the smart objects. */
       RUN adjust-tab-order IN adm-broker-hdl ( h_part2 ,
             h_folder , 'AFTER':U ).
       
       mChkPart2 = yes.    
       RUN PartTwo-Init in h_part2 (parparentproc, p-mode, p-obj-type, p-obj-code, input table-handle v-tempth).  
    END. /* Page 2 */

  END CASE.
  /* Select a Startup page. */
  IF adm-current-page eq 0 
  THEN do:
     run fill-temp-thbj-attr in this-procedure no-error. 
     run proc-open in this-procedure no-error.    
     RUN select-page IN THIS-PROCEDURE ( 1 ).
  END. 
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available D-Dialog  _ADM-ROW-AVAILABLE
PROCEDURE adm-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Dispatched to this procedure when the Record-
               Source has a new row available.  This procedure
               tries to get the new row (or foriegn keys) from
               the Record-Source and process it.
  Parameters:  <none>
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.             */
  {src/adm/template/row-head.i}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI D-Dialog  _DEFAULT-DISABLE
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
  HIDE FRAME D-Dialog.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI D-Dialog  _DEFAULT-ENABLE
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
  if p-mode = {&lookup} then do:
    disable
      B-exit
      with frame {&frame-name} .
    run disable-all in h_part1.              
  end.
  else
  ENABLE B-exit b-quit B-Help 
      WITH FRAME D-Dialog.
  VIEW FRAME D-Dialog.
  {&OPEN-BROWSERS-IN-QUERY-D-Dialog}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-temp-thbj-attr D-Dialog 
PROCEDURE fill-temp-thbj-attr :
define variable v-param-type      as character  no-undo .
define variable v-value-character as character  no-undo .
define variable v-value-date      as date       no-undo .
define variable v-value-decimal   as decimal    no-undo .
define variable v-value-integer   as integer    no-undo .
define variable v-value-logical   as logical    no-undo .
define variable v-entry           as character  no-undo .


do
on error undo, return error return-value
:
  assign
    v-tth = buffer thbjattr_thbj-attr:table-handle
    v-tempth = buffer temp-thbj-attr:table-handle
  .
  for each thbjattr_thbj-attr
  :
    delete thbjattr_thbj-attr .
  end.
  for each temp-thbj-attr
  :
    delete temp-thbj-attr .
  end.
  run adm/shattri.p
    ( input "init":U
    , input p-obj-type
    , input p-obj-code
    , input {&attr-petrol}
    , input "":U
    , output v-value-character
    , output v-value-date
    , output v-value-decimal
    , output v-value-integer
    , output v-value-logical
    , output v-param-type
    , input-output table-handle v-tth
    ) no-error .
    
  if error-status:error
    and not available locked_thbj-attr
  then do:
    message
    "Не удалось получить начальные значения настроек" skip
    error-status:get-message(1) return-value
    view-as alert-box error .
    undo, return error .
  end.

  for each thbjattr_thbj-attr:  
    create temp-thbj-attr.
    buffer-copy thbjattr_thbj-attr to temp-thbj-attr.
  end.

end.
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-widgets D-Dialog 
PROCEDURE fill-widgets :
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-open D-Dialog 
PROCEDURE proc-open :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define buffer buf_shop    for ub.shop .
  define buffer buf_store   for ub.store .
  define buffer buf_sysconf for ub.sysconf .
  define buffer buf_clients for ub.clients .

  { gbl/getcntxt.i get }

  if p-mode <> {&lookup}
    and p-mode <> {&update}
  then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра p-mode" p-mode
    view-as alert-box error.
    undo, return error.
  end.
     
  if p-obj-type <> {&shop}
    and p-obj-type <> {&stock}
    and p-obj-type <> {&cmp}
    and p-obj-type <> '':U
  then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-obj-type" p-obj-type
        view-as alert-box error.
      undo, return error.
  end.

  case p-obj-type :
    when {&shop} then do:
      find first buf_shop no-lock
        where buf_shop.obj-code = p-obj-code
        no-error.
      if not available buf_shop then do:
        message
          vss-workfile vss-revision vss-description skip
          substitute( "Неверное значение параметра p-obj-code" ) skip
          substitute( "Магазин с кодом &1 не найден", p-obj-code ) skip
          view-as alert-box error.
        undo, return error.
      end.
    end.
    when {&stock} then do:
      find first buf_store no-lock
        where buf_store.obj-code = p-obj-code
        no-error.
      if not available buf_store then do:
        message
          vss-workfile vss-revision vss-description skip
          substitute( "Неверное значение параметра p-obj-code" ) skip
          substitute( "Склад с кодом &1 не найден", p-obj-code ) skip
          view-as alert-box error.
        undo, return error.
      end.
    end.
    when {&cmp} then do:
      find first buf_sysconf no-lock
        where buf_sysconf.host-code = p-obj-code
        no-error.
      if not available buf_sysconf then do:
        message
          vss-workfile vss-revision vss-description skip
          substitute( "Неверное значение параметра p-obj-code" ) skip
          substitute( "Фирма с кодом &1 не найдена", p-obj-code ) skip
          view-as alert-box error.
        undo, return error.
      end.
    end.
  end case.

  if p-mode <> {&lookup}
    and v-cntxt-db-num <> 0
  then do:
    case trim( p-obj-type ) :
      when '':U then do:
        message
          "Нельзя менять ГЛОБАЛЬНЫЕ параметры в УБД" Skip
          view-as alert-box error.
        undo, return error.
      end.
      when {&shop}
      or when {&stock}
      then do:
        { gbl/objdbnum.i p-obj-type p-obj-code v-db-num }
        if v-db-num <> v-cntxt-db-num then do:
          message
            "Нельзя менять параметры объекта в чужой БД" skip
            "объект принадлежит БД" v-db-num "текущая БД" v-cntxt-db-num
            view-as alert-box error.
          undo, return error.
        end.
      end.
      when {&cmp} then do:
        message
          "Нельзя менять параметры ФИРМЫ в УБД" Skip
          view-as alert-box error.
        undo, return error.
      end.
    end case.
  end.

/*  if p-obj-type = {&db} then*/
/*   frame {&frame-name}:title = substitute( "&1. БД &2", frame {&frame-name}:title,  p-obj-code) .*/

  if p-mode = {&update} then do:
    find first locked_thbj-attr exclusive-lock
      where locked_thbj-attr.obj-type = p-obj-type
        and locked_thbj-attr.obj-code = p-obj-code
        and locked_thbj-attr.upper-prop-code = {&attr-petrol}
        and locked_thbj-attr.prop-code = "":u
    no-wait no-error.
    if locked locked_thbj-attr then do:
      message
        vss-workfile vss-revision vss-description skip
        "Запись ПАРАМЕТРЫ(АТРИБУТЫ) занята"
      view-as alert-box error .
      undo, return error.
    end.
  end.
  else do:
    find first locked_thbj-attr no-lock
      where locked_thbj-attr.obj-type = p-obj-type
        and locked_thbj-attr.obj-code = p-obj-code
        and locked_thbj-attr.upper-prop-code = {&attr-petrol}
        and locked_thbj-attr.prop-code = '':u
      no-error.
  end.
  if not available locked_thbj-attr then do:
    assign
      v-to-create  = yes
    .
    message
      substitute ("Внимание!!!&1Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ", {&new-line} )
    view-as alert-box WARNING.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save D-Dialog 
PROCEDURE proc-save :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-value-character as character      no-undo .
define variable v-value-date      as date           no-undo .
define variable v-value-decimal   as decimal        no-undo .
define variable v-value-integer   as integer        no-undo .
define variable v-value-logical   as logical        no-undo .
define variable v-sale-add        as character      no-undo .
define variable v-param-type      as character      no-undo .
define variable wh                as widget-handle  no-undo .
define variable fh                as widget-handle  no-undo .
define variable v-same            as logical        no-undo .

define variable v-change-temp     as logical        no-undo .
define variable v-change-volume   as logical        no-undo .
define variable v-change-density  as logical        no-undo .
define variable v-change-water    as logical        no-undo .
define variable v-change-param    as character      no-undo .
define variable v-vid-param       as longchar       no-undo .
define variable v-vid-action           as integer   no-undo .

define variable v-computer-name        as character no-undo .
define variable v-computer-tcp-name    as character no-undo .
define variable v-computer-ip-addr     as character no-undo .
define variable v-computer-login-name  as character no-undo .
define variable v-computer-process-pid as integer   no-undo .

define variable v-date                 as character no-undo .
define variable v-time                 as character no-undo .

define buffer buf_clients for ub.clients .
    
do
on error undo, return error return-value
:

  if p-mode = {&lookup} then do:
    return error.
  end.
  
  for each temp-thbj-attr:   
      delete temp-thbj-attr.
  end.
  
  if mChkPart1 then 
     RUN PartOne-Get in h_part1 (output table-handle v-tempth).
        
  if mChkPart2 then do:  
     RUN PartTwo-Get in h_part2 (input-output table-handle v-tempth).
      
  end.            

  assign
    v-same = yes
  .

  for each thbjattr_thbj-attr,
      first temp-thbj-attr
        where temp-thbj-attr.obj-type         = thbjattr_thbj-attr.obj-type
          and temp-thbj-attr.obj-code         = thbjattr_thbj-attr.obj-code
          and temp-thbj-attr.upper-prop-code  = thbjattr_thbj-attr.upper-prop-code
          and temp-thbj-attr.prop-code        = thbjattr_thbj-attr.prop-code
  :
    buffer-compare thbjattr_thbj-attr to temp-thbj-attr save result in v-same.
    
    if v-same = false then do:
      leave.
    end.
  end.

/*  if v-same = false                            */
/*    and v-to-create = true                     */
/*    and p-obj-type <> '':U                     */
/*  then do:                                     */
/*    message                                    */
/*      "вы действительно хотите сохранить набор"*/
/*      view-as alert-box.                       */
/*    assign                                     */
/*      v-same = true                            */
/*    .                                          */
/*  end.                                         */

  if v-same = true
    and v-to-create = false
  then do:
    return.
  end.
  
  /* если какую-то из вкладок не открывали, то возьмем значения полей из настройки без изменений */
  for each thbjattr_thbj-attr:
    find first temp-thbj-attr
        where temp-thbj-attr.obj-type         = thbjattr_thbj-attr.obj-type
          and temp-thbj-attr.obj-code         = thbjattr_thbj-attr.obj-code
          and temp-thbj-attr.upper-prop-code  = thbjattr_thbj-attr.upper-prop-code
          and temp-thbj-attr.prop-code        = thbjattr_thbj-attr.prop-code
    no-error.
    if not avail temp-thbj-attr then 
    do:
        create temp-thbj-attr.
        buffer-copy thbjattr_thbj-attr to temp-thbj-attr.
    end.
    
  end.
  
  /*проверим корректность*/
  run adm/shattri.p
    ( input "check":U
    , input p-obj-type
    , input p-obj-code
    , input {&attr-petrol}
    , INPUT '':U
    , output v-value-character
    , output v-value-date
    , output v-value-decimal
    , output v-value-integer
    , output v-value-logical
    , output v-param-type  
    , input-output table-handle v-tempth
    ) no-error .


  if error-status :error then do:
    message
      "Некорректное значение ПАРАМЕТРОВ"  skip
      error-status:get-message(1)         skip
      return-value
    view-as alert-box error .
    undo, return error .
  end.
  
  run thbjattr_set-section in this-procedure
    ( input p-obj-type
    , input p-obj-code
    , input {&attr-petrol}
    , input table temp-thbj-attr
    ) no-error.
  if error-status:error then do:
    message
      error-status:get-message(1)  skip
      return-value
    view-as alert-box.
    undo, return error.
  end.
  
  /* тут проверка отличается от той, что в shattrpt.w, так как в temp-thbj-attr данные уже ПОСЛЕ изменений, 
  ** а в thbjattr_thbj-attr - данные ДО изменений */   
  
  for each thbjattr_thbj-attr no-lock,
     first temp-thbj-attr
        where temp-thbj-attr.obj-type         = thbjattr_thbj-attr.obj-type
          and temp-thbj-attr.obj-code         = thbjattr_thbj-attr.obj-code
          and temp-thbj-attr.upper-prop-code  = thbjattr_thbj-attr.upper-prop-code
          and temp-thbj-attr.prop-code        = thbjattr_thbj-attr.prop-code:
    v-change-param = "" .
    case thbjattr_thbj-attr.prop-code:
      when {&attr-petrol_otkl-fact-volue} then 
        do:             
          if temp-thbj-attr.property-value-decimal <> thbjattr_thbj-attr.property-value-decimal then 
          do:
            v-change-param = "IDParam="  + "otkl-fact-volume" + {&delim-par} +
              "NameParam=" + "Макс.допустимое значение фактического объема" + {&delim-par} +
              "ParamBefore=" + string(thbjattr_thbj-attr.property-value-decimal) + {&delim-par} + 
              "ParamAfter=" + string(temp-thbj-attr.property-value-decimal) no-error.
          end.  
        end.
      when {&attr-petrol_otkl-temp} then 
        do: 
          if temp-thbj-attr.property-value-decimal <> thbjattr_thbj-attr.property-value-decimal then 
          do:
            v-change-param = "IDParam="  + "otkl-temp" + {&delim-par} +
              "NameParam=" + "Макс.допустимое значение температуры" + {&delim-par} +
              "ParamBefore=" + string(thbjattr_thbj-attr.property-value-decimal) + {&delim-par} + 
              "ParamAfter=" + string(temp-thbj-attr.property-value-decimal) no-error.
      
          end.  
        end.          
      when {&attr-petrol_otkl-density} then 
        do: 
          if temp-thbj-attr.property-value-character <> thbjattr_thbj-attr.property-value-character then 
          do:
            v-change-param = "IDParam="  + "otkl-density" + {&delim-par} +
              "NameParam=" + "Макс.допустимое значение плотности" + {&delim-par} +
              "ParamBefore=" + string(thbjattr_thbj-attr.property-value-character) + {&delim-par} + 
              "ParamAfter=" + string(temp-thbj-attr.property-value-character) no-error.
          end.  
        end.          
      when {&attr-petrol_otkl-water} then 
        do: 
          if temp-thbj-attr.property-value-decimal <> thbjattr_thbj-attr.property-value-decimal then 
          do:
            v-change-param = "IDParam="  + "otkl-water" + {&delim-par} +
              "NameParam=" + "Макс.допустимое значение воды" + {&delim-par} +
              "ParamBefore=" + string(thbjattr_thbj-attr.property-value-decimal) + {&delim-par} + 
              "ParamAfter=" + string(temp-thbj-attr.property-value-decimal) no-error.
          end.                             
        end.
    end.
   
    if v-change-param <> "" then 
    do:  
    
      define variable v-time-hour    as integer   no-undo .
      define variable v-time-min     as integer   no-undo .
      define variable v-nik          as character no-undo .
      define variable v-name         as character no-undo .

      define variable v-cntxt-userid as character no-undo . /* текущий пользователь  */
   
      run get-userid in parparentproc ( output v-cntxt-userid) .      
  
      find first ub.user-account no-lock where ub.user-account.user-id = v-cntxt-userid no-error .
      if available (ub.user-account) then 
      do:
        assign
          v-nik  = ub.user-account.nik
          v-name = ub.user-account.last-name + " " + ub.user-account.first-name 
          .
      end.  
  
      run cur-time in this-procedure ( output v-date, output v-time).
      v-time-hour = truncate(integer(v-time) / 3600, 0).
      v-time-min  = (integer(v-time) - (v-time-hour * 3600)) / 60 .
  
      run sys-time_get-comp-user-name in this-procedure
        (output v-computer-name
        ,output v-computer-login-name
        ,output v-computer-process-pid
        ) .
    
      v-vid-action = 66 .
  
      { str/initiator.i }  
  
      v-vid-param = 
        "UniqueIdRecordARM=" + v-initiator + {&delim-par} +
        "UserName=" + v-name + {&delim-par} +
        "UserNik=" + v-nik + {&delim-par} + 
        "NumShop=" + string(temp-thbj-attr.obj-code) + {&delim-par} + v-change-param 
        no-error.

      run trg/userlog.p (
        input {&nwsdochs_action_update}
        , input {&table_thbj-attr}
        , input ( buffer thbjattr_thbj-attr :handle ) /*!! проверить, может и temp тут правильней */
        , input v-vid-action
        , input v-vid-param
        ) no-error.
      if error-status :error
        then
      do:
        return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
          , {&new-line}
          , vss-workfile
          , return-value
          , error-status :get-message ( 1 ) ).
      end.
    end.  
  end.
  
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records D-Dialog  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* SEND-RECORDS does nothing because there are no External
     Tables specified for this SmartDialog, and there are no
     tables specified in any contained Browse, Query, or Frame. */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed D-Dialog 
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

