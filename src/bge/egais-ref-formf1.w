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

Справочник справок 1 ЕГАИС.

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
define variable vss-description            as character no-undo init "Справочник справок 1 ЕГАИС.".

define variable bh-egais-goods         as handle    no-undo.
define variable browse-hdl-egais-goods as handle    no-undo.
define variable qh-egais-goods         as handle    no-undo.
define variable bcol                   as handle    no-undo extent. 
define variable v-db-num               as integer   no-undo .
define variable v-user-id              as character no-undo .
define variable v-user-select          as character no-undo .
define variable v-select-obj-type      as character no-undo .
define variable v-select-obj-code      as integer   no-undo .
define variable v-obj-uniq-key-rec     as character no-undo .
define variable v-gds-uniq-key-rec     as character no-undo .
define variable v-ext-sys              as integer   no-undo .
define variable v-fs-rar               as character no-undo. 
define variable ExtFormF1Obj           as class     ExtFormF1 no-undo .
define variable v-value-character      as character no-undo .
define variable v-value-decimal        as decimal   no-undo .
define variable v-value-integer        as integer   no-undo .
define variable v-value-logical        as logical   no-undo .
define variable v-value-type           as character no-undo .
define variable v-value-date           as date      no-undo .
define variable select-list            as character no-undo .
define variable v-rec-list             as character no-undo .
define variable isMarkALL              as logical   no-undo init ?.
define variable isSave                 as logical   no-undo.
define variable glog                   as logical   no-undo.
define variable v-user-action          as character no-undo .
define variable v-printed              as logical   no-undo .

define buffer buf_clients   for ub.clients .
define buffer x_ext-classif for ub.ext-classif.
define buffer buf_goods     for ub.goods .
define stream str1.

{cmp/str-glbl.i}
{ gbl/color.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ ref/extclass.i }
{ gbl/key-rec.i  }
{ gbl/thbjattr.i }
{ ref/gds-attr.i }
{ gbl/waitfram.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_Cancel Btn_mark Btn_markall Btn_desmark ~
btn_look btn_refresh btn_req btn_asw btn_del f-gds f-alcgds f-gdsname ~
t-incorr 
&Scoped-Define DISPLAYED-OBJECTS f-gds f-alcgds f-gdsname t-incorr 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON btn_asw 
     LABEL "Получить ответ и сохр." 
     SIZE 22.5 BY 1.13.

DEFINE BUTTON Btn_Cancel AUTO-END-KEY 
     LABEL "Выход" 
     SIZE 8.5 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON btn_del 
     LABEL "Удалить" 
     SIZE 9 BY 1.13.

DEFINE BUTTON Btn_desmark 
     LABEL "-" 
     SIZE 3.5 BY 1.13.

DEFINE BUTTON btn_look 
     LABEL "Просмотр" 
     SIZE 9 BY 1.13.

DEFINE BUTTON Btn_mark 
     LABEL "*" 
     SIZE 3.5 BY 1.13.

DEFINE BUTTON Btn_markall 
     LABEL "+" 
     SIZE 3.5 BY 1.13.

DEFINE BUTTON btn_refresh 
     LABEL "Обновить" 
     SIZE 9 BY 1.13.

DEFINE BUTTON btn_req 
     LABEL "Запрос" 
     SIZE 9 BY 1.13.

DEFINE VARIABLE f-alcgds AS CHARACTER FORMAT "X(256)":U 
     LABEL "Алк. код товара" 
     VIEW-AS FILL-IN 
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE f-gds AS CHARACTER FORMAT "X(256)":U 
     LABEL "Справка 1" 
     VIEW-AS FILL-IN 
     SIZE 15.13 BY 1 NO-UNDO.

DEFINE VARIABLE f-gdsname AS CHARACTER FORMAT "X(256)":U 
     LABEL "Назв. товара" 
     VIEW-AS FILL-IN 
     SIZE 17.63 BY 1 NO-UNDO.

DEFINE VARIABLE t-incorr AS LOGICAL INITIAL no 
     LABEL "Некорр." 
     VIEW-AS TOGGLE-BOX
     SIZE 11.13 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_Cancel AT ROW 1.25 COL 2
     Btn_mark AT ROW 1.25 COL 12.5 WIDGET-ID 4
     Btn_markall AT ROW 1.25 COL 16.75 WIDGET-ID 6
     Btn_desmark AT ROW 1.25 COL 21 WIDGET-ID 8
     btn_look AT ROW 1.25 COL 25.25 WIDGET-ID 14
     btn_refresh AT ROW 1.25 COL 34.88 WIDGET-ID 18
     btn_req AT ROW 1.25 COL 44.38 WIDGET-ID 36
     btn_asw AT ROW 1.25 COL 54 WIDGET-ID 38
     btn_del AT ROW 1.25 COL 77
     f-gds AT ROW 2.75 COL 12.38 COLON-ALIGNED WIDGET-ID 20
     f-alcgds AT ROW 2.75 COL 45.13 COLON-ALIGNED WIDGET-ID 22
     f-gdsname AT ROW 2.75 COL 75.25 COLON-ALIGNED WIDGET-ID 24
     t-incorr AT ROW 2.75 COL 95.75 WIDGET-ID 28
     SPACE(2.36) SKIP(22.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Справочник справок 1 ЕГАИС"
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

ASSIGN 
       btn_del:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
do:
    apply "END-ERROR":U to self.
  end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn_asw
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_asw Dialog-Frame
ON CHOOSE OF btn_asw IN FRAME Dialog-Frame /* Получить ответ и сохр. */
DO:

  def var egaisJournal        as class  Journal        no-undo.
  def var ExtFormF1ValueObj      as class  ExtFormF1Value no-undo.
  def var ExtFormF1ValueObjDB    as class  ExtFormF1Value no-undo.
  def var egaisFormF1        as class  FormF1         no-undo.
  def var bh-journal-egais    as handle no-undo.
  def var qh-journal-egais    as handle no-undo.
  def var bh-gds-egais-gotten as handle no-undo.
  def var msg                 as character no-undo.
  def var ii                  as integer   no-undo.
  def var jj                  as integer   no-undo.
  def var isQHEmpty           as logical no-undo init true.

  os-delete value (search ("logFormF1.txt")).
  
  output stream str1 to "logFormF1.txt".
  
  egaisJournal = new Journal ().
  bh-journal-egais = egaisJournal:GetHndlTable().

  create query qh-journal-egais.
  
  qh-journal-egais:set-buffers (bh-journal-egais) .

  qh-journal-egais:query-prepare ( substitute ("for each tt_journal-egais where jou-subject = '&1' and jou-status = 'Запрос отправлен' ", 'Справочник справок 1')).
  qh-journal-egais:query-open.
  
  run waitfram-show in this-procedure ("Ждите... Идет обработка ответов.") .
  
  journal_:
  do while qh-journal-egais:get-next ():
    
    isQHEmpty = false.
    
    egaisFormF1 = new FormF1 (v-cntxt-obj-type, v-cntxt-obj-code, v-fs-rar, entry (2, bh-journal-egais:buffer-field ("jou-param"):buffer-value, '|')).
    egaisFormF1:DbNum = v-db-num.
    egaisFormF1:User_Id = v-user-id.

    glog = egaisFormF1:StatusErr .
    if glog then do :
        msg = msg + {&new-line} + egaisFormF1:Msg.
    end.
    else do:
      bh-gds-egais-gotten = egaisFormF1:GetHndlTable() .
      if egaisFormF1:Msg = 'Не удалось получить данные от UTM'
      then do:
        message egaisFormF1:Msg + ". Проверьте соединение с УТМ." view-as alert-box error.
        run waitfram-hide in this-procedure.
        return.
      end.
      if bh-gds-egais-gotten = ? or not bh-gds-egais-gotten:find-first () 
      then do:
        put stream str1 unformatted {&new-line} + egaisFormF1:Msg.
        delete object egaisFormF1.
        next journal_.
      end.
      ExtFormF1ValueObj = cast (bh-gds-egais-gotten:buffer-field("extFormF1ValueObj"):buffer-value, ibs.th.bge.egais.ExtFormF1Value).
      ExtFormF1Obj:OpenQueryExtFormF1 (bh-gds-egais-gotten:buffer-field("formF1code"):buffer-value).
      do ii = 1 to ExtFormF1Obj:NumBundles:
        ExtFormF1ValueObjDB = ExtFormF1Obj:GetExtFormF1Value(ii).
        assign
          ExtFormF1ValueObjDB:BottlingDate = ExtFormF1ValueObj:BottlingDate
          ExtFormF1ValueObjDB:CliRegIdOrigCli = ExtFormF1ValueObj:CliRegIdOrigCli
          ExtFormF1ValueObjDB:CliEgaisTypeOrigCli = ExtFormF1ValueObj:CliEgaisTypeOrigCli
          ExtFormF1ValueObjDB:INNOrigCli = ExtFormF1ValueObj:INNOrigCli
          ExtFormF1ValueObjDB:KPPOrigCli = ExtFormF1ValueObj:KPPOrigCli
          ExtFormF1ValueObjDB:FullNameOrigCli = ExtFormF1ValueObj:FullNameOrigCli
          ExtFormF1ValueObjDB:CountryOrigCli = ExtFormF1ValueObj:CountryOrigCli
          ExtFormF1ValueObjDB:RegionOrigCli = ExtFormF1ValueObj:RegionOrigCli
          ExtFormF1ValueObjDB:DescrOrigCli = ExtFormF1ValueObj:DescrOrigCli
        .
        ExtFormF1Obj:SaveEGAISInfo(ExtFormF1ValueObjDB).
        bh-egais-goods:find-first (substitute ("where alcCode = '&1' and formF1Code = '&2'", ExtFormF1ValueObjDB:AlcCode, ExtFormF1ValueObjDB:FormF1Code )).
        bh-egais-goods:buffer-field ('ColorNum'):buffer-value () = YELLOW_COLOR .
        put stream str1 unformatted {&new-line} substitute ('Запись &1/&2 обновлена', bh-egais-goods:buffer-field ('alcCode'):buffer-value (), bh-egais-goods:buffer-field ('formF1Code'):buffer-value () ).
        jj = jj + 1.
        
      end.
      
    end.


    delete object egaisFormF1.
  end.
  
  run waitfram-hide in this-procedure.
  
  output stream str1 close.
  
  file-info:file-name = search ("logFormF1.txt").

  
  if search ("logFormF1.txt") <> ? and file-info:file-size > 0
  then do:
    run gbl/prnfilen.w
    (input  "Отчёт о запросах"
    ,input  0
    ,input  search ("logFormF1.txt")
    ,input  7
    ,output v-user-action
    ,output v-printed
    ) .
  end. 
  
  if isQHEmpty
  then do:
    delete object qh-journal-egais.
    delete object egaisJournal.
    message "Нет открытых запросов." view-as alert-box information title "Сообщение".
    return.
  end.
  else message substitute ("Завершено. Получено &1 записей. Сохраненные записи подсвечены желтым.", jj) view-as alert-box information title "Сообщение". 
  delete object qh-journal-egais.
  delete object egaisJournal.
  run refresh-view.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn_del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_del Dialog-Frame
ON choose OF btn_del IN FRAME Dialog-Frame /* Удалить */
do:

  def var cmd as char no-undo.
  def var qh-del as handle no-undo.
  run refresh-view.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_desmark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_desmark Dialog-Frame
ON choose OF Btn_desmark IN FRAME Dialog-Frame /* - */
do:
  
  if not qh-egais-goods:is-open
    then return no-apply.
  
  if qh-egais-goods:get-first ()
    then bh-egais-goods:buffer-field (1):buffer-value () = "".
  do while qh-egais-goods:get-next ():
    bh-egais-goods:buffer-field (1):buffer-value () = "".
  end.
  
  if qh-egais-goods:get-first () 
    then browse-hdl-egais-goods:refresh ().

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn_look
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_look Dialog-Frame
ON choose OF btn_look IN FRAME Dialog-Frame /* Просмотр */
do:

  run msdblcl.
    
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_mark Dialog-Frame
ON choose OF Btn_mark IN FRAME Dialog-Frame /* * */
do:

  if bh-egais-goods:available
  then do:
    if bcol[1]:screen-value = "*"
      then do:
        assign 
          bh-egais-goods:buffer-field (1):buffer-value () = ""
          bcol[1]:screen-value = ""
          .
      end.
      else do:
        assign 
          bh-egais-goods:buffer-field (1):buffer-value () = "*"
          bcol[1]:screen-value = "*"
          .

     end.
     browse-hdl-egais-goods:select-next-row( ).
  end.


end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_markall
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_markall Dialog-Frame
ON choose OF Btn_markall IN FRAME Dialog-Frame /* + */
do:
  
  if qh-egais-goods:get-first ()
    then bh-egais-goods:buffer-field (1):buffer-value () = "*".
  do while qh-egais-goods:get-next ():
    bh-egais-goods:buffer-field (1):buffer-value () = "*".
  end.
  
  if qh-egais-goods:get-first () 
    then browse-hdl-egais-goods:refresh ().
  
  /*isMarkALL = true.
  if qh-egais-goods:get-first () 
    then browse-hdl-egais-goods:refresh ().
  isMarkALL = ?.  */
   
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn_refresh
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_refresh Dialog-Frame
ON CHOOSE OF btn_refresh IN FRAME Dialog-Frame /* Обновить */
DO:
  ExtFormF1Obj:GetHndlTable("", "", input-output bh-egais-goods).
  run refresh-view.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn_req
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_req Dialog-Frame
ON CHOOSE OF btn_req IN FRAME Dialog-Frame /* Запрос */
DO:
  def var egaisFormF1 as class FormF1 no-undo.
  def var qh-egais-goods-mark as handle no-undo.
  def var isQHEmpty as logical no-undo init true.

  create query qh-egais-goods-mark.
  qh-egais-goods-mark:set-buffers (bh-egais-goods).
  qh-egais-goods-mark:query-prepare ("for each tt-egaisformf1-hndls where mark = '*' ").
  qh-egais-goods-mark:query-open.

  run waitfram-show in this-procedure ("Ждите... Идет отправка запросов.") .

  do while qh-egais-goods-mark:get-next ():
    isQHEmpty = false.
    egaisFormF1 = new FormF1 (v-cntxt-obj-type, v-cntxt-obj-code, v-fs-rar, bh-egais-goods:buffer-field ("formF1Code"):buffer-value).
    egaisFormF1:DbNum = v-db-num.
    egaisFormF1:User_Id = v-user-id.
    egaisFormF1:SendRequestUTM() .
    glog = egaisFormF1:StatusErr .
    if glog then do :
        message egaisFormF1:Msg view-as alert-box.
        run waitfram-hide in this-procedure.
        return no-apply.
    end.
    delete object egaisFormF1.
  end.
  delete object qh-egais-goods-mark.
  run waitfram-hide in this-procedure .
  if isQHEmpty
  then do:
    message "Для отправки запросов отметьте справки 1." view-as alert-box information title "Информация".
    return.
  end.
  apply "choose" to Btn_desmark in frame {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-alcgds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-alcgds Dialog-Frame
ON leave OF f-alcgds IN FRAME Dialog-Frame /* Алк. код товара */
do:
  if f-alcgds:screen-value = f-alcgds
    then return.
  run refresh-view.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-alcgds Dialog-Frame
ON return OF f-alcgds IN FRAME Dialog-Frame /* Алк. код товара */
do:
  run refresh-view.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-gds Dialog-Frame
ON leave OF f-gds IN FRAME Dialog-Frame /* Код товара */
do:
  if f-gds:screen-value = f-gds
    then return.
  run refresh-view.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-gds Dialog-Frame
ON return OF f-gds IN FRAME Dialog-Frame /* Код товара */
do:
  run refresh-view.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-gdsname
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-gdsname Dialog-Frame
ON leave OF f-gdsname IN FRAME Dialog-Frame /* Назв. товара */
do:
  if f-gdsname:screen-value = f-gdsname
    then return.
  run refresh-view.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-gdsname Dialog-Frame
ON return OF f-gdsname IN FRAME Dialog-Frame /* Назв. товара */
do:
  run refresh-view.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-incorr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-incorr Dialog-Frame
ON VALUE-CHANGED OF t-incorr IN FRAME Dialog-Frame /* Некорр. */
DO:
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
  def var v-windth as integer no-undo.
  def var v-isDisp as character no-undo. 

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
  
  create browse browse-hdl-egais-goods
    assign 
    title     = 'Товары'
    frame     = frame {&FRAME-NAME}:handle
    query     = qh-egais-goods
    x         = 10
    y         = 70
    width     = 107
    height    = 21.5
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

  ExtFormF1Obj = new ExtFormF1 (yes).

  ExtFormF1Obj:DbNum = v-db-num.
/*  ExtFormF1Obj:User_Id = v-user-id.*/

  ExtFormF1Obj:GetHndlTable("", "", input-output bh-egais-goods).
  
  create query qh-egais-goods.
  qh-egais-goods:set-buffers (bh-egais-goods).

  browse-hdl-egais-goods:query = qh-egais-goods.

  extent (bcol) = bh-egais-goods:num-fields.
  do ii = 1 to bh-egais-goods:num-fields:
    bcol[ii] = browse-hdl-egais-goods:add-like-column('tt-egaisformf1-hndls' + '.' + bh-egais-goods:buffer-field (ii):name, 0, 'FILL-IN').
    if entry (ii, ExtFormF1Obj:SettingsTTList, ';') <> ""
    then do:
      v-windth = integer (entry (1, entry (ii, ExtFormF1Obj:SettingsTTList, ';'))).
      v-isDisp = entry (2, entry (ii, ExtFormF1Obj:SettingsTTList, ';')).
      assign
        bcol[ii]:width = v-windth when v-windth > 0
        bcol[ii]:visible = false when v-isDisp = "no"
      .
    end.
  end.
  { gbl/diasize.i &br-hndl=browse-hdl-egais-goods }
  run diasize_init in this-procedure .
  run enable_UI.
  run refresh-view.
  bh-egais-goods:find-first ("", no-lock) no-error.
  assign 
       btn_del:hidden in frame dialog-frame = true
       f-gdsname:hidden in frame dialog-frame = true
       btn_look:hidden in frame dialog-frame = true.
  wait-for go of frame {&FRAME-NAME}.
  
end.
if valid-object (ExtFormF1Obj)
  then delete object ExtFormF1Obj.
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
  DISPLAY f-gds f-alcgds f-gdsname t-incorr 
      WITH FRAME Dialog-Frame.
  ENABLE Btn_Cancel Btn_mark Btn_markall Btn_desmark btn_look btn_refresh 
         btn_req btn_asw btn_del f-gds f-alcgds f-gdsname t-incorr 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE msdblcl Dialog-Frame 
PROCEDURE msdblcl :


end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-row-disp Dialog-Frame 
PROCEDURE proc-row-disp :
def var ii as int no-undo.
  
  do ii = 1 to extent (bcol).  
    if valid-handle (bcol[ii]) 
      then 
        assign
          bcol[ii]:bgcolor = bh-egais-goods:buffer-field ("ColorNum"):buffer-value
        .
  end.
  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE refresh-view Dialog-Frame 
PROCEDURE refresh-view :
def var v-proposition  as char no-undo.
  
  assign input frame {&FRAME-NAME}
    f-gds
    f-gdsname
    f-alcgds
    t-incorr
  .
 
  if f-gds <> ""
  then do:
    v-proposition = substitute ("string(formF1Code) matches '*&1*' and ", f-gds).
  end. 

  if f-alcgds <> ""
  then do:
    v-proposition = v-proposition + substitute ("alcCode matches '*&1*' and ", f-alcgds).
  end. 

  if f-gdsname <> ""
  then do:
    v-proposition = v-proposition + substitute ("gdsName matches '*&1*' and ", f-gdsname).
  end. 

  if t-incorr = true
  then do:
    v-proposition = v-proposition + substitute ("ColorNum = &1", RED_COLOR).
  end. 

  v-proposition = right-trim (v-proposition, " and ").
  if v-proposition <> "" then v-proposition = "where " + v-proposition.
  
  display Btn_Cancel with frame Dialog-Frame.
  enable Btn_Cancel
    with frame Dialog-Frame.
  view frame Dialog-Frame.
  qh-egais-goods:query-close.
  qh-egais-goods:query-prepare ("for each tt-egaisformf1-hndls " + v-proposition).
  qh-egais-goods:query-open.
  if qh-egais-goods:get-first () 
    then browse-hdl-egais-goods:refresh ().
  apply "choose" to Btn_desmark in frame {&FRAME-NAME}.
  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

