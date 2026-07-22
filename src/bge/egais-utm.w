&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Содержимое УТМ.

  Author: 
    Автор: Морозов Александр Сергеевич
    Дата создания: 15/11/03
    Author: Alexandr Morozov
    Creation date: 15/11/03
 
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
using ibs.th.bge.egais.*.
/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision               as character no-undo init "$Revision$":U .
define variable vss-author                 as character no-undo init "$Author$":U .
define variable vss-date                   as character no-undo init "$Date$":U .
define variable vss-workfile               as character no-undo init "$Workfile$":U .
define variable vss-archive                as character no-undo init "$Archive$":U .
define variable vss-description            as character no-undo init "Содержимое УТМ.".

define variable bh-wb-analiz       as handle    no-undo.
define variable browse-hdl-analiz  as handle    no-undo.
define variable qh-analiz          as handle    no-undo.
define variable bcolmark           as handle    no-undo.
define variable bcolnn             as handle    no-undo.
define variable bcol               as handle    no-undo. 
define variable v-db-num           as integer   no-undo .
define variable v-user-id          as character no-undo .
define variable v-user-select      as character no-undo .
define variable v-select-obj-type  as character no-undo .
define variable v-select-obj-code  as integer   no-undo .
define variable v-obj-uniq-key-rec as character no-undo .
define variable v-gds-uniq-key-rec as character no-undo .
define variable v-ext-sys          as integer   no-undo .
define variable v-fs-rar           as character no-undo. 
define variable v-rid              as recid     no-undo .
define variable v-uniq-key-rec     as character no-undo .
define variable url_               as character no-undo .
define variable AdmUtmObj          as class     admutm no-undo .
define variable v-value-character  as character no-undo .
define variable v-value-decimal    as decimal   no-undo .
define variable v-value-integer    as integer   no-undo .
define variable v-value-logical    as logical   no-undo .
define variable v-value-type       as character no-undo .
define variable v-value-date       as date      no-undo .
define variable select-list        as character no-undo .
define variable v-rec-list         as character no-undo .
define variable isMarkALL          as logical   no-undo init ?.
define variable isSave             as logical   no-undo.

define buffer buf_clients   for ub.clients .
define buffer x_ext-classif for ub.ext-classif.
define buffer buf_goods     for ub.goods .

{cmp/str-glbl.i}
{ gbl/color.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ ref/extclass.i }
{ gbl/key-rec.i  }
{ gbl/thbjattr.i }
{ ref/gds-attr.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_Cancel btn_refresh btn_del btn_dwl ~
btn_look Btn_reqwb Btn_chg-xsd Btn_mark Btn_markall Btn_desmark f_date ~
RADIO-SET-1 tb_no_date CB_typedoc 
&Scoped-Define DISPLAYED-OBJECTS f_date RADIO-SET-1 tb_no_date CB_typedoc 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_Cancel AUTO-END-KEY 
     LABEL "Выход" 
     SIZE 10 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON Btn_chg-xsd 
     LABEL "Смена вер. XSD" 
     SIZE 15 BY 1.13.

DEFINE BUTTON btn_del 
     LABEL "Удалить" 
     SIZE 15 BY 1.13 TOOLTIP "Безвозвратное удаления записи с УТМ".

DEFINE BUTTON Btn_desmark 
     LABEL "-" 
     SIZE 3.5 BY 1.13.

DEFINE BUTTON btn_dwl 
     LABEL "Загрузка/анализ" 
     SIZE 16.75 BY 1.13.

DEFINE BUTTON btn_look 
     LABEL "Просмотр" 
     SIZE 15 BY 1.13.

DEFINE BUTTON Btn_mark 
     LABEL "*" 
     SIZE 3.5 BY 1.13.

DEFINE BUTTON Btn_markall 
     LABEL "+" 
     SIZE 3.5 BY 1.13.

DEFINE BUTTON btn_refresh 
     LABEL "Обновить" 
     SIZE 15 BY 1.13.

DEFINE BUTTON Btn_reqwb 
     LABEL "Запрос накл." 
     SIZE 15 BY 1.13 TOOLTIP "Повторный запрос накладной".

DEFINE VARIABLE CB_typedoc AS CHARACTER FORMAT "X(256)":U 
     LABEL "Тип" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Все,ReplyRests,INVENTORYREGINFO,ReplyAP,ReplyPartner,Ticket,FORMBREGINFO,WAYBILL,WayBillAct,WayBillTicket" 
     DROP-DOWN-LIST
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE f_date AS DATE FORMAT "99/99/99":U 
     LABEL "До даты" 
     VIEW-AS FILL-IN 
     SIZE 9 BY 1.13 NO-UNDO.

DEFINE VARIABLE RADIO-SET-1 AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "out", 1,
"in", 2
     SIZE 12 BY 1.13 NO-UNDO.

DEFINE VARIABLE tb_no_date AS LOGICAL INITIAL no 
     LABEL "Без даты" 
     VIEW-AS TOGGLE-BOX
     SIZE 11.13 BY 1.13 NO-UNDO.

DEFINE MENU popup-menu-ver-xsd
       MENU-ITEM m_ver-xsd-1 LABEL "Изменить версия XSD схем на 1"     ACCELERATOR "ALT-1"
       MENU-ITEM m_ver-xsd-2 LABEL "Изменить версия XSD схем на 2" ACCELERATOR "ALT-2"
       MENU-ITEM m_look-resp-ver-xsd LABEL "Просмотреть ответ" ACCELERATOR "ALT-3"
.

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_Cancel AT ROW 1.25 COL 2
     btn_refresh AT ROW 1.25 COL 12.5 WIDGET-ID 18
     btn_del AT ROW 1.25 COL 28
     btn_dwl AT ROW 1.25 COL 43.38 WIDGET-ID 2
     btn_look AT ROW 1.25 COL 60.75 WIDGET-ID 14
     Btn_reqwb AT ROW 1.25 COL 76.13 WIDGET-ID 16
     Btn_chg-xsd AT ROW 1.25 COL 91.5 WIDGET-ID 28
     Btn_mark AT ROW 2.63 COL 2.5 WIDGET-ID 4
     Btn_markall AT ROW 2.63 COL 6.75 WIDGET-ID 6
     Btn_desmark AT ROW 2.63 COL 11 WIDGET-ID 8
     f_date AT ROW 2.63 COL 22.5 COLON-ALIGNED WIDGET-ID 12
     RADIO-SET-1 AT ROW 2.63 COL 34.25 NO-LABEL WIDGET-ID 20
     tb_no_date AT ROW 2.63 COL 46.63 WIDGET-ID 24
     CB_typedoc AT ROW 2.67 COL 61 COLON-ALIGNED WIDGET-ID 26
     SPACE(26.99) SKIP(22.23)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Содержимое УТМ"
         CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
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
ON window-close OF FRAME Dialog-Frame /* Содержимое УТМ */
do:
    apply "END-ERROR":U to self.
  end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m_ver-xsd-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_ver-xsd-1 Dialog-Frame
on choose of menu-item m_ver-xsd-1 in menu popup-menu-ver-xsd /* Смена вер. XSD */
DO:
  
  if AdmUtmObj:IsSent
  then do:
    message "Запрос уже был отправлен. Дождитесь ответа." view-as alert-box error.
    return no-apply.
  end.
  
  AdmUtmObj:SendInfoVer("WayBill").
  if AdmUtmObj:StatusErr
  then do:
    message AdmUtmObj:Msg view-as alert-box error.
  end.
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m_ver-xsd-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_ver-xsd-2 Dialog-Frame
on choose of menu-item m_ver-xsd-2 in menu popup-menu-ver-xsd /* Смена вер. XSD */
DO:

  if AdmUtmObj:IsSent
  then do:
    message "Запрос уже был отправлен. Дождитесь ответа." view-as alert-box error.
    return no-apply.
  end.

  AdmUtmObj:SendInfoVer("WayBill_v2").
  if AdmUtmObj:StatusErr
  then do:
    message AdmUtmObj:Msg view-as alert-box error.
  end.
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m_look-resp-ver-xsd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_look-resp-ver-xsd Dialog-Frame
on choose of menu-item m_look-resp-ver-xsd in menu popup-menu-ver-xsd /* */
DO:

  if not AdmUtmObj:IsSent
  then do:
    message "Запрос еще не был отправлен" view-as alert-box error.
    return no-apply.
  end.

  AdmUtmObj:GetSubjectOfRequestUTM ().
  
  if AdmUtmObj:StatusErr
  then do:
    message AdmUtmObj:Msg view-as alert-box error.
    return no-apply.
  end.

  url_ = AdmUtmObj:urlResp.
  AdmUtmObj:LookRec(url_).
  AdmUtmObj:WriteDbStatusTrue().
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME btn_del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_del Dialog-Frame
ON choose OF btn_del IN FRAME Dialog-Frame /* Удалить */
do:

  def var cmd as char no-undo.
  def var qh-del as handle no-undo.

  create query qh-del.
  qh-del:set-buffers (bh-wb-analiz).
  qh-del:query-prepare ("for each tt-alldoc where tt-alldoc.mark = '*' ").
  qh-del:query-open.

  if not qh-del:get-first () 
  then do:
    message "Отметьте записи для удаления." view-as alert-box information.
    return no-apply.
  end.
  
  /*if not isSave
  then do:
    message "Перед удалением нужно выполнить загрузку. Для загрузки нажмите загрузить и дождитесь окончания." view-as alert-box information.
    return no-apply.
  end.*/
  
  message "Вы уверены что хотите удалить запись/и?" view-as alert-box question buttons yes-no update isChoise as log.
  
  if isChoise
  then do:
    if qh-del:get-first ()
    then do:
      url_ = bh-wb-analiz:buffer-field ('url_'):buffer-value ().
      AdmUtmObj:SaveRecord(url_).
      AdmUtmObj:DelRecord(url_).
      bh-wb-analiz:buffer-delete ().
    end.
    do while qh-del:get-next ():
      url_ = bh-wb-analiz:buffer-field ('url_'):buffer-value ().
      AdmUtmObj:SaveRecord(url_).
      AdmUtmObj:DelRecord(url_).
      bh-wb-analiz:buffer-delete ().
    end.
  end.
  else do:
    return no-apply.
  end.
  run refresh-view.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_desmark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_desmark Dialog-Frame
ON choose OF Btn_desmark IN FRAME Dialog-Frame /* - */
do:
  
  if qh-analiz:get-first ()
    then bh-wb-analiz:buffer-field (1):buffer-value () = "".
  do while qh-analiz:get-next ():
    bh-wb-analiz:buffer-field (1):buffer-value () = "".
  end.
  
  if qh-analiz:get-first () 
    then browse-hdl-analiz:refresh ().

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn_dwl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_dwl Dialog-Frame
ON choose OF btn_dwl IN FRAME Dialog-Frame /* Загрузка/анализ */
do:
  AdmUtmObj:SaveRecords().
  if AdmUtmObj:StatusErr 
    then do:
      message AdmUtmObj:Msg view-as alert-box.
      isSave = false.
    end.
    else isSave = true.
  run refresh-view.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn_look
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_look Dialog-Frame
ON choose OF btn_look IN FRAME Dialog-Frame /* Просмотр */
do:

  if not bh-wb-analiz:available 
    then return no-apply.
  url_ = bh-wb-analiz:buffer-field ('url_'):buffer-value ().
  AdmUtmObj:LookRec(url_).
  run refresh-view.
  bh-wb-analiz:find-first ('where url_ = "' + url_ + '"').
  if bh-wb-analiz:available
    then qh-analiz:reposition-to-rowid ( bh-wb-analiz:rowid ).
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_mark Dialog-Frame
ON choose OF Btn_mark IN FRAME Dialog-Frame /* * */
do:

  if bh-wb-analiz:available
  then do:
    if bcolmark:screen-value = "*"
      then do:
        assign 
          bh-wb-analiz:buffer-field (1):buffer-value () = ""
          bcolmark:screen-value = ""
          .
      end.
      else do:
        assign 
          bh-wb-analiz:buffer-field (1):buffer-value () = "*"
          bcolmark:screen-value = "*"
          .

     end.
     browse-hdl-analiz:select-next-row( ).
  end.


end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_markall
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_markall Dialog-Frame
ON choose OF Btn_markall IN FRAME Dialog-Frame /* + */
do:
  
  if qh-analiz:get-first ()
    then bh-wb-analiz:buffer-field (1):buffer-value () = "*".
  do while qh-analiz:get-next ():
    bh-wb-analiz:buffer-field (1):buffer-value () = "*".
  end.
  
  if qh-analiz:get-first () 
    then browse-hdl-analiz:refresh ().
  
  /*isMarkALL = true.
  if qh-analiz:get-first () 
    then browse-hdl-analiz:refresh ().
  isMarkALL = ?.  */
   
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn_refresh
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_refresh Dialog-Frame
ON CHOOSE OF btn_refresh IN FRAME Dialog-Frame /* Обновить */
DO:
  bh-wb-analiz = AdmUtmObj:GetHndlTable().
  run refresh-view.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_reqwb
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_reqwb Dialog-Frame
ON CHOOSE OF Btn_reqwb IN FRAME Dialog-Frame /* Запрос накл. */
DO:

  def var v-WBREGID as char no-undo.
  
  run gbl/d-prompt.w (
      'title=Введите WBREGID накладной\'
    + 'text1=Введите WBREGID накладной\'
    + 'format=x(40)\'
    + 'type=char\'
    ,input-output v-WBREGID
    ).
  if return-value = 'false':u then do:
    return no-apply . /* --->>>--- */
  end.
  AdmUtmObj:QueryResendDoc(v-WBREGID).
  if AdmUtmObj:StatusErr
  then do:
    message AdmUtmObj:Msg view-as alert-box error.
  end.
  
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME CB_typedoc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CB_typedoc Dialog-Frame
ON VALUE-CHANGED OF CB_typedoc IN FRAME Dialog-Frame /* Тип */
DO:
  apply "choose" to Btn_desmark in frame {&FRAME-NAME}.
  run refresh-view.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f_date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f_date Dialog-Frame
ON leave OF f_date IN FRAME Dialog-Frame /* До даты */
do:
  run refresh-view.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f_date Dialog-Frame
ON return OF f_date IN FRAME Dialog-Frame /* До даты */
do:
  apply "choose" to Btn_desmark in frame {&FRAME-NAME}.
  run refresh-view.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-SET-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-SET-1 Dialog-Frame
ON VALUE-CHANGED OF RADIO-SET-1 IN FRAME Dialog-Frame
DO:
  apply "choose" to Btn_desmark in frame {&FRAME-NAME}.  
  assign
    RADIO-SET-1.
  CB_typedoc = "Все".
  assign
    CB_typedoc:screen-value = "Все".
  if RADIO-SET-1 = 1
  then do:
    assign
    CB_typedoc:hidden = false.
  end.
  else do:
    assign
    CB_typedoc:hidden = true.
  end.
  run refresh-view.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tb_no_date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tb_no_date Dialog-Frame
ON VALUE-CHANGED OF tb_no_date IN FRAME Dialog-Frame /* Без даты */
DO:
  apply "choose" to Btn_desmark in frame {&FRAME-NAME}.
  run refresh-view.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
if valid-handle(active-window) and frame {&FRAME-NAME}:PARENT eq ?
  then frame {&FRAME-NAME}:PARENT = active-window.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
do on error   undo MAIN-BLOCK, leave MAIN-BLOCK
  on end-key undo MAIN-BLOCK, leave MAIN-BLOCK:

  def var ii as int no-undo.

  { gbl/getcurus.i
    v-db-num
    v-user-id
    no-error
  }
  { gbl/getcntxt.i get }


  empty temp-table thbjattr_thbj-attr .
  run adm/shattri.p (
       input "get":U
      ,input v-cntxt-obj-type
      ,input v-cntxt-obj-code
      ,input {&attr-egais-host}
      ,input {&attr-egais-host_egais-fsrar}
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,input-output TABLE thbjattr_thbj-attr
      ) no-error .
  assign 
    v-fs-rar = v-value-character 
  .

  run adm/shattri.p (
       input "get":U
      ,input '':U
      ,input 0
      ,input {&attr-egais-host}
      ,input {&attr-egais-host_egais-exsys}
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,input-output TABLE thbjattr_thbj-attr
      ) no-error .
  assign v-ext-sys = v-value-integer.   
  
  create browse browse-hdl-analiz
    assign 
    title     = 'Записи'
    frame     = frame {&FRAME-NAME}:handle
    query     = qh-analiz
    x         = 10
    y         = 70
    width     = 100
    height    = 21
    visible   = true
    read-only = true
    sensitive = true
    separators = true
    column-resizable = true
    triggers:
      on mouse-move-dblclick persistent run msdblcl.
      on row-display persistent run proc-row-disp.
    end triggers
    .

  AdmUtmObj = new admutm (v-cntxt-obj-type, v-cntxt-obj-code, v-fs-rar, v-ext-sys).

  AdmUtmObj:DbNum = v-db-num.
  AdmUtmObj:User_Id = v-user-id.

  bh-wb-analiz = AdmUtmObj:GetHndlTable().
  create query qh-analiz.
  qh-analiz:set-buffers (bh-wb-analiz).
  /*qh-analiz:query-prepare ("for each tt-alldoc").
  qh-analiz:query-open.*/

  browse-hdl-analiz:query = qh-analiz.
  
/*  bcolmark = browse-hdl-analiz:add-calc-column('char', 'x(1)', "", "*", 0, 'FILL-IN').*/
  
  do ii = 1 to bh-wb-analiz:num-fields:
    if ii = 1 
      then bcolmark = browse-hdl-analiz:add-like-column('tt-alldoc' + '.' + bh-wb-analiz:buffer-field (ii):name, 0, 'FILL-IN').
      else bcol = browse-hdl-analiz:add-like-column('tt-alldoc' + '.' + bh-wb-analiz:buffer-field (ii):name, 0, 'FILL-IN').
    if ii = 2 
      then bcol:width = 50.
  end.
  { gbl/diasize.i &br-hndl=browse-hdl-analiz }
  run diasize_init in this-procedure .
  assign
  CB_typedoc:list-items = "Все,ReplyRests,INVENTORYREGINFO,ReplyAP,ReplyPartner,Ticket,FORMBREGINFO,WAYBILL,WayBillAct,WayBillTicket"
  CB_typedoc = "Все".
  assign 
    btn_chg-xsd :popup-menu in frame {&frame-name} = menu popup-menu-ver-xsd:handle
    btn_chg-xsd:menu-mouse = 1.
  run enable_UI.
  run refresh-view.
  bh-wb-analiz:find-first ("", no-lock) no-error.
  wait-for go of frame {&FRAME-NAME}.
  
end.
run disable_UI.

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
  DISPLAY f_date RADIO-SET-1 tb_no_date CB_typedoc 
      WITH FRAME Dialog-Frame.
  ENABLE Btn_Cancel btn_refresh btn_del btn_dwl btn_look Btn_reqwb Btn_chg-xsd 
         Btn_mark Btn_markall Btn_desmark f_date RADIO-SET-1 tb_no_date 
         CB_typedoc 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE msdblcl Dialog-Frame 
PROCEDURE msdblcl :
/*if cb-1 <> 1 and cb-1 <> 3 and cb-1 <> 2 and cb-1 <> 4      */
/*    then apply "choose" to Btn_Save in frame {&frame-name} .*/
/*    else apply "choose" to Btn_Sel in frame {&frame-name} . */

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-row-disp Dialog-Frame 
PROCEDURE proc-row-disp :
/*if valid-handle (bcolmark) and isMarkALL <> ?
  then do: 
    bcolmark:buffer-value () = if isMarkALL then "*" else "".
  end.*/
  
  /*if valid-handle (browse-hdl-analiz:buffer-field) and valid-handle (bcolmark) and bcolmark:screen-value = "*"
    then v-nn-list = v-nn-list + "," + browse-hdl-analiz:buffer-field ("nnOrder"):buffer-value ().*/
  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE refresh-view Dialog-Frame 
PROCEDURE refresh-view :
def var v-proposition  as char no-undo.
  
  assign input frame {&FRAME-NAME}
    f_date
    RADIO-SET-1
    CB_typedoc
    tb_no_date
  .
  
  if tb_no_date
  then
    assign
    f_date:hidden = true.
  else 
    assign
    f_date:hidden = false.
  if tb_no_date = true
  then do:
    v-proposition = "tt-alldoc.date_ = ?".
  end.
  else do:
    if f_date <> ? then v-proposition = "(tt-alldoc.date_ < " + string (f_date) + " and tt-alldoc.date_ <> ?)".
  end.

  case RADIO-SET-1:
    when 1 then do:
      v-proposition = v-proposition + " and tt-alldoc.url_ matches '*opt/out*' ".
    end.
    when 2 then do:
      v-proposition = v-proposition + "and tt-alldoc.url_ matches '*opt/in*' ".
    end.
  end.
  
  if CB_typedoc <> "Все"
  then do:
    v-proposition = v-proposition + "and tt-alldoc.typeDoc = '" + CB_typedoc + "'".    
  end.
  
  v-proposition = left-trim (v-proposition, " and").
  if v-proposition <> "" then v-proposition = "where " + v-proposition.
  
  display Btn_Cancel with frame Dialog-Frame.
  enable Btn_Cancel btn_del
    with frame Dialog-Frame.
  view frame Dialog-Frame.
  qh-analiz:query-close.
  qh-analiz:query-prepare ("for each tt-alldoc " + v-proposition).
  qh-analiz:query-open.
  if qh-analiz:get-first () 
    then browse-hdl-analiz:refresh ().
  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

