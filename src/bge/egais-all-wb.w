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

Список накладных ЕГАИС

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
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Журнал запросов ЕГАИС".

define variable th-wb-egais         as handle    no-undo.
define variable bh-wb-egais         as handle    no-undo.
define variable qh-wb-egais         as handle    no-undo.
define variable browse-hdl-wb-egais as handle    no-undo.
define variable bcol                as handle    extent no-undo.
define variable egais               as class     EGAIS   no-undo.
define variable egaisWBAdv          as class     WayBill no-undo.
define variable v-db-num            as integer   no-undo .
define variable v-user-id           as character no-undo .
define variable qh-wb-gds-EG-header as handle    no-undo.
define variable qh-wb-gds-EG        as handle    no-undo.
define variable bh-wb-gds-EG-header as handle    no-undo.
define variable bh-wb-gds-EG        as handle    no-undo.
define variable bh-analiz           as handle    no-undo.
define variable bh-act-header       as handle    no-undo.
define variable nn                  as integer   no-undo.
define variable ii                  as integer   no-undo.

define variable v-value-character   as character no-undo .
define variable v-value-decimal     as decimal   no-undo .
define variable v-value-integer     as integer   no-undo .
define variable v-value-logical     as logical   no-undo .
define variable v-value-type        as character no-undo .
define variable v-value-date        as date      no-undo .
define variable v-ext-sys           as integer   no-undo .
define variable glog                as logical   no-undo.
define variable actnEGAISAdm        as logical   no-undo.
define variable actnEGAISSts        as logical   no-undo.
define variable v-uniq-key-rec      as character no-undo.
define variable v-trn-doc           as character no-undo.
define variable v-width             as decimal   no-undo.
define variable v-height            as decimal   no-undo.
define variable v-windth            as integer no-undo.
define variable v-isDisp            as character no-undo.
define variable par-alcohol         as character no-undo .
define variable par-type            as character no-undo .
define variable v-gds-uniq-key-rec  as character no-undo .


define stream strlog.
define stream str-FormF1.

define buffer buf_goods          for ub.goods.
define buffer buf_parts          for ub.parts .
define buffer buf_trn-doc        for ub.trn-doc .
define buffer buf_doc-line       for ub.doc-line .
define buffer x_ext-classif      for ub.ext-classif .
define buffer x_ext-classif-attr for ub.ext-classif-attr .
define buffer buf_clob-bind      for ub.clob-bind .
define buffer buf_clob-data      for ub.clob-data .


define variable v-fs-rar as character no-undo view-as text format "X(15)" label "Код ФС РАР (FSRAR ID)" .

{ gbl/color.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/thbjattr.i }
{ibs/th/bge/egais/wb-egais.i}
{ str/trdcalib.i }
{ gbl/waitfram.i }
{ cmp/showinf.i  }
{ibs/th/bge/egais/tts-egais.i proc }
{ ref/extclass.i }
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
&Scoped-Define ENABLED-OBJECTS Btn_OK Btn_Sel Btn_Save Btn_dnlw Btn_conn ~
Btn_Del btn_ticket Btn_accept Btn_delclob cb-1 f-date f-date-2 f-cli-name ~
f-cli-code f-type TOGGLE_NotConn 
&Scoped-Define DISPLAYED-OBJECTS cb-1 f-date f-date-2 f-cli-name f-cli-code ~
f-type TOGGLE_NotConn 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_accept 
     LABEL "Подтв." 
     SIZE 10 BY 1.21.

DEFINE BUTTON Btn_conn 
     LABEL "Связать" 
     SIZE 10 BY 1.21.

DEFINE BUTTON Btn_Del 
     LABEL "Отказ" 
     SIZE 10 BY 1.21.

DEFINE BUTTON Btn_delclob 
     LABEL "Удалить" 
     SIZE 10 BY 1.21 TOOLTIP "Удаляет из базы TH. Если данные в УТМ остались, то будет загружено повторно.".

DEFINE BUTTON Btn_dnlw 
     LABEL "Загрузить" 
     SIZE 10 BY 1.21.

DEFINE BUTTON Btn_OK 
     LABEL "Выход" 
     SIZE 10 BY 1.21
     BGCOLOR 8 .

DEFINE BUTTON Btn_Save 
     LABEL "Сохранить" 
     SIZE 10 BY 1.21
     BGCOLOR 8 .

DEFINE BUTTON Btn_Sel 
     LABEL "Изменить" 
     SIZE 10 BY 1.21
     BGCOLOR 8 .

DEFINE BUTTON btn_ticket 
     LABEL "Просмотр" 
     SIZE 10 BY 1.21.

DEFINE VARIABLE cb-1 AS INTEGER FORMAT "->,>>>,>>9" INITIAL 1 
     VIEW-AS COMBO-BOX 
     LIST-ITEM-PAIRS "Полученные",1,
                     "Закрытые на факт",2,
                     "Акты",3,
                     "Расход",4
     DROP-DOWN-LIST
     SIZE 19.88 BY 1 NO-UNDO.

DEFINE VARIABLE f-type AS CHARACTER FORMAT "X(256)":U INITIAL "Все" 
     LABEL "Тип" 
     VIEW-AS COMBO-BOX 
     LIST-ITEMS "Все","приход вн.","возврат пост.","расход внутренний","расход внешний" 
     DROP-DOWN-LIST
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-cli-code AS INTEGER FORMAT "->>>>>>9":U INITIAL 0 
     LABEL "Код" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-cli-name AS CHARACTER FORMAT "x(256)":U 
     LABEL "Контрагент" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-date AS DATE FORMAT "99/99/99":U 
     LABEL "Дата с" 
     VIEW-AS FILL-IN 
     SIZE 9.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-date-2 AS DATE FORMAT "99/99/99":U 
     LABEL "по" 
     VIEW-AS FILL-IN 
     SIZE 9.5 BY 1 NO-UNDO.

DEFINE VARIABLE TOGGLE_NotConn AS LOGICAL INITIAL no 
     LABEL "Не связ." 
     VIEW-AS TOGGLE-BOX
     SIZE 11.13 BY 1 NO-UNDO.

DEFINE MENU popup-menu-reject
       MENU-ITEM m_reject LABEL "Отправить акт отказа" ACCELERATOR "ALT-1"
       MENU-ITEM m_reqRepealWB LABEL "Отправить запрос на отмену проведения накладной" ACCELERATOR "ALT-2"
.

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.21 COL 2.63
     Btn_Sel AT ROW 1.21 COL 13.25 WIDGET-ID 6
     Btn_Save AT ROW 1.21 COL 24 WIDGET-ID 10
     Btn_dnlw AT ROW 1.21 COL 34.63 WIDGET-ID 12
     Btn_conn AT ROW 1.21 COL 45 WIDGET-ID 16
     Btn_Del AT ROW 1.21 COL 55.63 WIDGET-ID 14
     btn_ticket AT ROW 1.21 COL 66 WIDGET-ID 36
     Btn_accept AT ROW 1.21 COL 76.63 WIDGET-ID 32
     Btn_delclob AT ROW 1.21 COL 86.88 WIDGET-ID 38
     cb-1 AT ROW 1.21 COL 98.5 COLON-ALIGNED NO-LABEL WIDGET-ID 2
     f-date AT ROW 2.5 COL 8.63 COLON-ALIGNED WIDGET-ID 22
     f-date-2 AT ROW 2.5 COL 22.75 COLON-ALIGNED WIDGET-ID 26
     f-cli-name AT ROW 2.5 COL 45.25 COLON-ALIGNED WIDGET-ID 24
     f-cli-code AT ROW 2.5 COL 65.25 COLON-ALIGNED WIDGET-ID 30
     f-type AT ROW 2.5 COL 85 COLON-ALIGNED WIDGET-ID 28
     TOGGLE_NotConn AT ROW 2.5 COL 101.75 WIDGET-ID 34
     SPACE(8.74) SKIP(25.23)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Накладные/акты ЕГАИС" WIDGET-ID 100.


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
ON window-close OF FRAME Dialog-Frame /* Накладные/акты ЕГАИС */
do:
  apply "END-ERROR":U to self.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_accept
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_accept Dialog-Frame
ON CHOOSE OF Btn_accept IN FRAME Dialog-Frame /* Подтв. */
DO:
  
  if not bh-wb-egais:available 
    then return no-apply.
  
  if actnEGAISAdm then do:
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_egais-accept':U
      {&cntxt-object}
      v-cntxt-host-code-obj
      v-cntxt-obj-type
      v-cntxt-obj-code
      0
      0
      0
      true
      glog
    }
    
    if not glog then  return .
    
    message  substitute ("Вы уверены, что хотите подтвердить накладную &1/&2 без проверок?", bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value, entry (1, bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value, {&delim-cmd}) ) view-as alert-box question buttons yes-no
      title "" update isChoise as logical.
    
    if not isChoise
      then return no-apply.
    
    bh-wb-gds-EG = ?.
    bh-wb-gds-EG-header = ?.
    bh-wb-gds-EG-header = egais:GetHndlTable({&wb-header}, bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value).
    v-uniq-key-rec = bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value.
    if egais:StatusErr
    then do:
      message egais:Msg view-as alert-box error.
      return no-apply.
    end.
    egaisWBAdv:SendForceAccept().
    if egaisWBAdv:StatusErr
      then message egaisWBAdv:Msg view-as alert-box error.
      else do:
        { str/tdat-wrt.i
          bh-wb-egais:buffer-field('trn-doc-code'):buffer-value
          {&trdcattr-egais}
          {&egais-act-send}
          no-error
        }
        message "Отправлен акт на накладную" view-as alert-box.
      end.
    run f-query.
  end.
  else do:
    message "Отсутсвуют права для данной операции." view-as alert-box.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_conn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_conn Dialog-Frame
ON choose OF Btn_conn IN FRAME Dialog-Frame /* Связать */
do:

  def var loc-ref-list as character no-undo.
  def var v-negais     as character no-undo.
  def var v-date       as character no-undo.
  
  define variable v-part-num    as integer   no-undo.
  define variable v-clob-db-num as integer   no-undo.
  define variable v-int64-id    as int64     no-undo.
  define variable v-info        as character no-undo.
  
  if not bh-wb-egais:available 
    then return no-apply.
  
  v-uniq-key-rec = bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value.
  
  case cb-1: 
  when 1 then do: 
    bh-wb-gds-EG = ?.
    bh-wb-gds-EG-header = ?.
    bh-wb-gds-EG-header = egais:GetHndlTable(1, bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value).
    if egais:StatusErr
    then do:
      message egais:Msg view-as alert-box error.
      return no-apply.
    end.
    
    run str/all-docs.w
      (  input parparentproc,
          input v-cntxt-host-code-obj ,
          input v-cntxt-obj-type ,
          input v-cntxt-obj-code ,
          input {&choose},
          input ?,
          input {&income},
          input ?,
          input ?,
          input "b-sel":U,
          input {&TDEDT_Pri_Vnesh},
          input no,
          input ?,
          output loc-ref-list ).
  
    find first ub.trn-doc no-lock where recid (ub.trn-doc) = integer (loc-ref-list) no-error.
    
    if not available (ub.trn-doc) 
      then return.
    
    bh-wb-gds-EG = ?.
    bh-wb-gds-EG-header = ?.
    bh-wb-gds-EG-header = egais:GetHndlTable(1, bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value).
    bh-wb-gds-EG = egais:GetHndlTable(2, bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value).  
    find first ub.clients 
      where ub.clients.obj-type = bh-wb-gds-EG-header:buffer-field ("cli-type"):buffer-value
        and ub.clients.obj-code = integer (bh-wb-gds-EG-header:buffer-field ("cli-code"):buffer-value) no-error.
    if not available (ub.clients)
    then do:
      message "Не найден клиент TH для EGAIS контрагентa regID: " + bh-wb-gds-EG-header:buffer-field ('regId-Ship'):buffer-value view-as alert-box.
      return no-apply.
    end.
    find first ub.clients 
      where ub.clients.obj-type = bh-wb-gds-EG-header:buffer-field ("obj-type"):buffer-value
        and ub.clients.obj-code = integer (bh-wb-gds-EG-header:buffer-field ("obj-code"):buffer-value) no-error.
    if not available (ub.clients)
    then do:
      message "Не найден объект TH для EGAIS получателя regID: " + bh-wb-gds-EG-header:buffer-field ('regId-Cons'):buffer-value view-as alert-box.
      return no-apply.
    end.
    bh-wb-gds-EG:find-first ("where tt-wb-gds-EG.gds-code = ?", no-lock) no-error.
    if bh-wb-gds-EG:available then do:
      message "Не найден товар TH для EGAIS товара AlcCode: " + bh-wb-gds-EG:buffer-field ('alc-code'):buffer-value view-as alert-box.
      return no-apply.
    end.
    
    egais:ConnWB(bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value, ub.trn-doc.doc-code).
    
    if egais:StatusErr
      then message egais:Msg view-as alert-box error.
    else do:
      message "Накладная связана" view-as alert-box.
    end.
    output stream strlog to value ("egaislog.txt") append. 
    export stream strlog egais:Msg.
    output stream strlog close.
  end.
  when 2 then do:
    
    if bh-wb-egais:buffer-field ("EGAISSts"):buffer-value () <> "Accepted"
    then do:
      message 'Aкт передачи в торговый зал возможно сформировать только для накладной в статусе "Accepted"!' view-as alert-box information title "Информация".
      undo, return.
    end.
    
    find first buf_trn-doc no-lock where buf_trn-doc.doc-code = bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value no-error .
    if error-status :error then return .
    
    v-date = substitute ("&1&2&3", string (day (now), "99"), string (month (now), "99"),substring (string(year (now)), 3,2)).
    
    create tt-act-header .
    assign
        tt-act-header.num = "TTS-" + v-date + '-' + substring(v-cntxt-obj-type,1,1) + string(v-cntxt-obj-code) + '-' + buf_trn-doc.doc-code
        tt-act-header.date_ = TODAY
        tt-act-header.is-sent = no
    .
    
    for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code :
        find first buf_goods no-lock where buf_goods.artic      = buf_doc-line.artic
                                       and buf_goods.prod-type  = buf_doc-line.prod-type 
                                       and buf_goods.prod-code  = buf_doc-line.prod-code .
        run gds-attr-value(
          buf_goods.gds-code,
          {&attr-alcohol-prod},
          output par-alcohol,
          output par-type
        ).
        if par-alcohol = "" or par-alcohol = "no" then next .
        
        for each buf_parts no-lock where buf_parts.artic        = buf_doc-line.artic
                                     and buf_parts.prod-type    = buf_doc-line.prod-type 
                                     and buf_parts.prod-code    = buf_doc-line.prod-code
                                     and buf_parts.obj-type     = buf_doc-line.obj-type 
                                     and buf_parts.obj-code     = buf_doc-line.obj-code 
                                     and buf_parts.out-code     = buf_doc-line.doc-code :
             assign nn = nn + 1 .
             create tt-gds-act .
             assign
                tt-gds-act.num          = tt-act-header.num
                tt-gds-act.gds-code     = buf_goods.gds-code
                tt-gds-act.gds-name     = buf_goods.gds-name    
                tt-gds-act.position_    = nn
                tt-gds-act.qnty         = buf_parts.fact-qnty / buf_parts.cli-base-rate
             .    
             if num-entries(buf_parts.alc-ref-ab-path) = 4 and entry(3, buf_parts.alc-ref-ab-path) <> "" then do :
                 tt-gds-act.alc-code = entry(3, buf_parts.alc-ref-ab-path) .
             end.
             else do :
                 run gen-key-rec IN THIS-PROCEDURE ( input {&table_goods}
                                                    ,input (buffer buf_goods:handle)
                                                    ,output v-gds-uniq-key-rec).
                 find first X_ext-classif no-lock where X_ext-classif.classif-subject = {&table_goods} 
                                                   and X_ext-classif.classif-name = {&extclass_goods_esys} 
                                                   AND X_ext-classif.db-num = 0  
                                                   and X_ext-classif.key#_one = buf_goods.gds-code
                                                   and X_ext-classif.key#_two = v-ext-sys 
                                                   and X_ext-classif.key#_three = 0
                                                   and X_eXt-classif.uniq-key-rec = v-gds-uniq-key-rec
                                                   and X_eXt-classif.charkey_two = ""
                                                   and X_eXt-classif.charkey_three = ""
                                                   and X_eXt-classif.nonunique = 0
                                                   no-error .
                 if available X_ext-classif then tt-gds-act.alc-code = X_eXt-classif.charkey_one .
             end. 
             if num-entries(buf_parts.alc-ref-ab-path) = 4 and entry(2, buf_parts.alc-ref-ab-path) <> "" then do : 
                 tt-gds-act.inform-B = trim(entry(2, buf_parts.alc-ref-ab-path)) .
             end.                 
        end .                              
    end .
    
    find first tt-gds-act no-error .
    if not available tt-gds-act then do :
        message "В акте нет строк. Сохранение невозможно" view-as alert-box .
        return no-apply.
    end.
    if can-find(tt-gds-act where tt-gds-act.qnty < 1)
    or can-find(tt-gds-act where trim(tt-gds-act.inform-B) = "")
    then do :
        message "Строки, в которых не указана справка Б, и строки, в которых количество меньше 1, не будут учтены при отправке в ЕГАИС!" skip "Продолжить?"
        view-as alert-box question buttons yes-no update glog .
        if not glog then return no-apply.
    end.
    run makeXML in this-procedure no-error.
    if error-status:error then return return-value .
    assign
        v-clob-db-num = ?
        v-int64-id = 0
        v-info = tt-act-header.num + {&delim-par} + string(tt-act-header.date_) + {&delim-par} + string(tt-act-header.is-sent) + {&delim-par} + tt-act-header.answer_
    .
    find first buf_clob-bind exclusive-lock where buf_clob-bind.field-name_  = {&lob-egais-tts} 
      and buf_clob-bind.uniq-key-rec matches substitute ("*&1*", buf_trn-doc.doc-code) no-error .
    if available buf_clob-bind 
    then do :
      message "Акт с таким номером уже существует!" view-as alert-box information
        title "Информация".
        release buf_clob-bind.
        return no-apply .
    end.
    run gbl/file2clb.p ( input {&add-def}
              ,input ",yes"
              ,input ? /*p-bh*/
              ,input tt-act-header.num /*p-uniq-key-rec*/
              ,input {&lob-egais-tts} /*p-field-*/
              ,input v-info /*p-descr*/
              ,input-output v-part-num
              ,input {&lob-egais-tts}
              ,input-output v-clob-db-num
              ,input-output v-int64-id
              ,input search (v-file)
              ,input '' /*p-src-encoding*/
              ) no-error .  
    if error-status:error then message return-value view-as alert-box.   
    
    bh-wb-egais:buffer-field ("tts"):buffer-value () = tt-act-header.num.
    bh-wb-egais:buffer-field ("tts-status_"):buffer-value () = "Новый".
    
    message substitute ("Создан акт № &1 перемещения в торговый зал", buf_trn-doc.doc-code) view-as alert-box title "Сообщение".
    release buf_clob-bind.
    empty temp-table tt-act-header.
    empty temp-table tt-gds-act.
    
  end.
  end case.

  run f-query.
  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_Del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Del Dialog-Frame
ON choose OF Btn_Del IN FRAME Dialog-Frame /* Отказ */
do:
  run rejectWB.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m_reject
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_reject Dialog-Frame
ON choose of menu-item m_reject IN menu popup-menu-reject /* Отказ */
do:
  
  run rejectWB.
  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m_reqRepealWB
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_reqRepealWB Dialog-Frame
ON choose of menu-item m_reqRepealWB IN menu popup-menu-reject /* Отказ */
do:
  
  run ReqRepealWB.
  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_delclob
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_delclob Dialog-Frame
ON CHOOSE OF Btn_delclob IN FRAME Dialog-Frame /* Удалить */
DO:
  if not bh-wb-egais:available 
    then return no-apply.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_egais-adm':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    false
    glog
  }
  
  if not glog then return no-apply.
  
  if bh-wb-egais:buffer-field ('DbNum'):buffer-value () <>  v-cntxt-db-num
  then do:
    message "Нельзя удалять накладную полученную в другой БД " + bh-wb-egais:buffer-field ('DbNum'):buffer-value ().
    return no-apply.
  end.
  
  message "Вы уверены что хотите удалить накладную - " bh-wb-egais:buffer-field ('num'):buffer-value () "?" view-as alert-box buttons yes-no update isChoise as logical.
  
  if not isChoise then return no-apply.
  
  do trans:
  
    for each ub.clob-bind exclusive-lock where ub.clob-bind.uniq-key-rec = bh-wb-egais:buffer-field ('uniq-key-rec'):buffer-value () and ub.clob-bind.db-num = bh-wb-egais:buffer-field ('DbNum'):buffer-value ():
      
      delete ub.clob-bind.
      
    end.
  
  end.
  
  run reopen-browse.
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_dnlw
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_dnlw Dialog-Frame
ON choose OF Btn_dnlw IN FRAME Dialog-Frame /* Загрузить */
do:
  
  if not search ( v-FS-RAR + '_ReceiptListOfQuery.xml' ) = ?
  then do:
  
    message "Выполнить полную загрузка (переодически рекомендуется выполнять полную загрузку)?" view-as alert-box question buttons yes-no update isChoise as logical.
    if isChoise 
      then egaisWBAdv:FastDwnl = false.
      else egaisWBAdv:FastDwnl = true.
    
  end. 
  
  egaisWBAdv:GetDocUTM().
  if egaisWBAdv:StatusErr 
  then do:
    message "Ошибка: " egaisWBAdv:Msg view-as alert-box error.
  end.
  
  bh-analiz = egaisWBAdv:HndlAnaliz.
  if bh-analiz <> ? 
  then do: 
    bh-analiz:find-first ("where isMany") no-error.
    if bh-analiz:available
    then do:
      message "Имеются накладные с одинаковыми номерами. Посмотреть?" view-as alert-box question buttons yes-no update isChoise.
      if isChoise 
        then run bge/egais-analiz.w (input parparentproc, input egaisWBAdv).
    end.
  end.
  
  def var egaisJournal        as class  Journal        no-undo.
  def var ExtFormF1ValueObj      as class  ExtFormF1Value no-undo.
  def var ExtFormF1ValueObjDB    as class  ExtFormF1Value no-undo.
  define variable ExtFormF1Obj           as class     ExtFormF1 no-undo .
  def var egaisFormF1        as class  FormF1         no-undo.
  def var bh-journal-egais    as handle no-undo.
  def var qh-journal-egais    as handle no-undo.
  def var bh-gds-egais-gotten as handle no-undo.
  def var msg                 as character no-undo.
  def var ii                  as integer   no-undo.
  def var jj                  as integer   no-undo.

  
  output stream str-FormF1 to "logWBDnlFormF1.txt" append.
  
  egaisJournal = new Journal ().
  ExtFormF1Obj = new ExtFormF1 (yes).
  bh-journal-egais = egaisJournal:GetHndlTable().

  create query qh-journal-egais.
  
  qh-journal-egais:set-buffers (bh-journal-egais) .

  qh-journal-egais:query-prepare ( substitute ("for each tt_journal-egais where jou-subject = '&1' and jou-status = 'Запрос отправлен' ", 'Справочник справок 1')).
  qh-journal-egais:query-open.
  
  run waitfram-show in this-procedure ("Ждите... Идет загрузка справок 1.") .
  
  journal_:
  do while qh-journal-egais:get-next ():
    
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
        output stream str-FormF1 close.
        if valid-object (ExtFormF1Obj) 
          then delete object ExtFormF1Obj.
        if valid-handle (qh-journal-egais) 
          then delete object qh-journal-egais.
        if valid-object (egaisJournal) 
          then delete object egaisJournal.
        run reopen-browse.
        return.
      end. 
      if bh-gds-egais-gotten = ? or not bh-gds-egais-gotten:find-first () 
      then do:
        put stream str-FormF1 unformatted {&new-line} + egaisFormF1:Msg.
        delete object egaisFormF1.
        next journal_.
      end.
      ExtFormF1ValueObj = cast (bh-gds-egais-gotten:buffer-field("extFormF1ValueObj"):buffer-value, ibs.th.bge.egais.ExtFormF1Value).
      ExtFormF1Obj:OpenQueryExtFormF1 (bh-gds-egais-gotten:buffer-field("formF1code"):buffer-value).
      do ii = 1 to ExtFormF1Obj:NumBundles:
        ExtFormF1ValueObjDB = ExtFormF1Obj:GetExtFormF1Value(ii).
        assign
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
        put stream str-FormF1 unformatted {&new-line} substitute ('Запись &1/&2 обновлена', ExtFormF1ValueObjDB:AlcCode, ExtFormF1ValueObj:FormF1Code ).
        jj = jj + 1.
        
      end.
      
    end.


    delete object egaisFormF1.
  end.
  
  run waitfram-hide in this-procedure.
  
  output stream str-FormF1 close.

  if valid-object (ExtFormF1Obj) 
    then delete object ExtFormF1Obj.
  if valid-handle (qh-journal-egais) 
    then delete object qh-journal-egais.
  if valid-object (egaisJournal) 
    then delete object egaisJournal.
  
  run reopen-browse.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON choose OF Btn_OK IN FRAME Dialog-Frame /* Выход */
do:
  if valid-object (egais)
    then delete object egais.
  if valid-object (egaisWBAdv)
    then delete object egaisWBAdv.
  apply "go" to frame {&FRAME-NAME}.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_Save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Save Dialog-Frame
ON choose OF Btn_Save IN FRAME Dialog-Frame /* Сохранить */
do:
  
  def var v-doc-code as character no-undo.
  
  if not bh-wb-egais:available 
    then return no-apply.
  
  case cb-1: 
  when 1 then do:
    if can-find (first ub.trn-doc where ub.trn-doc.doc-code = bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value)
    then do:
      message substitute ( "Накладная с № &1 уже сформирована", bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value)
      view-as alert-box.
      return no-apply.
    end.
    if bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value = 'отказ'
    then do:
      message "Накладная в статусе отказ. Нельзя сохранить."
      view-as alert-box.
      return no-apply.
    end.
    bh-wb-gds-EG = ?.
    bh-wb-gds-EG-header = ?.
    bh-wb-gds-EG-header = egais:GetHndlTable(1, bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value).
    bh-wb-gds-EG = egais:GetHndlTable(2, bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value).
    v-uniq-key-rec = bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value.
    find first ub.clients no-lock 
      where ub.clients.obj-type = bh-wb-gds-EG-header:buffer-field ("cli-type"):buffer-value
        and ub.clients.obj-code = integer (bh-wb-gds-EG-header:buffer-field ("cli-code"):buffer-value) no-error.
    if not available (ub.clients)
    then do:
      message "Не найден клиент TH для EGAIS контрагентa regID: " + bh-wb-gds-EG-header:buffer-field ('regId-Ship'):buffer-value view-as alert-box.
      return no-apply.
    end.
    find first ub.clients no-lock
      where ub.clients.obj-type = bh-wb-gds-EG-header:buffer-field ("obj-type"):buffer-value
        and ub.clients.obj-code = integer (bh-wb-gds-EG-header:buffer-field ("obj-code"):buffer-value) no-error.
    if not available (ub.clients)
    then do:
      message "Не найден объект TH для EGAIS получателя regID: " + bh-wb-gds-EG-header:buffer-field ('regId-Cons'):buffer-value view-as alert-box.
      return no-apply.
    end.
    bh-wb-gds-EG:find-first ("where tt-wb-gds-EG.gds-code = ? or tt-wb-gds-EG.gds-code = 0", no-lock) no-error.
    if bh-wb-gds-EG:available then do:
      message "Не найден товар TH для EGAIS товара AlcCode: " + bh-wb-gds-EG:buffer-field ('alc-code'):buffer-value view-as alert-box.
      return no-apply.
    end.
    
    egais:SaveWB(bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value).
    if egais:StatusErr
      then message egais:Msg view-as alert-box error.
      else message "Создание накладной завершено" view-as alert-box.
    run f-query.
    run proc-row-disp.
  end.
  when 2 then do:
    
    
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_egais-accept':U
      {&cntxt-object}
      v-cntxt-host-code-obj
      v-cntxt-obj-type
      v-cntxt-obj-code
      0
      0
      0
      true
      glog
    }
    
    if not glog then  return .
    
    bh-wb-gds-EG = ?.
    bh-wb-gds-EG-header = ?.
    bh-wb-gds-EG-header = egais:GetHndlTable({&wb-header}, bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value).
    v-uniq-key-rec = bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value.
    if egais:StatusErr
    then do:
      message egais:Msg view-as alert-box error.
      return no-apply.
    end.
    egais:SendRequestUTM().
    if egais:StatusErr
      then message egais:Msg view-as alert-box error.
      else do:
        { str/tdat-wrt.i
          bh-wb-egais:buffer-field('trn-doc-code'):buffer-value
          {&trdcattr-egais}
          {&egais-act-send}
          no-error
        }
        message "Отправлен акт на накладную" view-as alert-box.
      end.
    
  end.
  when 4 then do:
    
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_egais-send-doc':U
      {&cntxt-object}
      v-cntxt-host-code-obj
      v-cntxt-obj-type
      v-cntxt-obj-code
      0
      0
      0
      true
      glog
    }
    
    if not glog then  return .

    if bh-wb-egais:buffer-field ("status_"):buffer-value begins {&fact}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_egais-adm':U
        {&cntxt-object}
        v-cntxt-host-code-obj
        v-cntxt-obj-type
        v-cntxt-obj-code
        0
        0
        0
        true
        glog
      }      
      if not glog then  return .
    end.
    
    bh-wb-gds-EG = ?.
    bh-wb-gds-EG-header = ?.
    v-doc-code = bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value.
    bh-wb-gds-EG-header = egais:GetHndlTable({&wb-ras-header}, bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value).
    v-uniq-key-rec = bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value.
    if egais:StatusErr
    then do:
      message egais:Msg view-as alert-box error.
      return no-apply.
    end.
    egais:SendRequestUTM().
    if egais:StatusErr
      then message egais:Msg view-as alert-box error.
      else do:
        { str/tdat-wrt.i
          v-doc-code
          {&trdcattr-egais}
          {&egais-wb-send}
          no-error
        }
        message "Накладная отправлена" view-as alert-box.
      end.
  end.
  end case.
  run f-query.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_Sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Sel Dialog-Frame
ON choose OF Btn_Sel IN FRAME Dialog-Frame /* Изменить */
do:
  if not bh-wb-egais:available 
    then return no-apply.
  case cb-1: 
    when 1 then do:
      run bge/egais-wb.w (parparentproc, egais, bh-wb-egais:handle).
      v-uniq-key-rec = bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value.
    end.
    when 2 then do:
      run bge/egais-ticket.w (parparentproc, egais, bh-wb-egais:handle).
      v-uniq-key-rec = bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value.
    end.
    when 3 then do:
      run bge/egais-wb-act.w (parparentproc, egais, bh-wb-egais:handle).
    end.
    when 4 then do:
      run bge/egais-ticket.w (parparentproc, egais, bh-wb-egais:handle).
      v-trn-doc = bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value.
    end.
  end case.
  run proc-row-disp.
  run f-query.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn_ticket
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_ticket Dialog-Frame
ON CHOOSE OF btn_ticket IN FRAME Dialog-Frame /* Просмотр */
DO:
  if not bh-wb-egais:available 
    then return no-apply.
  run bge/egais-ticket.w (parparentproc, egais, bh-wb-egais).
  v-uniq-key-rec = bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value.
  run proc-row-disp.
  run f-query.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cb-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cb-1 Dialog-Frame
ON value-changed OF cb-1 IN FRAME Dialog-Frame
do:
  assign cb-1 .
  run proc-hide-disp.
  run reopen-browse.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-cli-code Dialog-Frame
ON return OF f-cli-code IN FRAME Dialog-Frame /* Код */
do:
  run f-query.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-cli-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-cli-name Dialog-Frame
ON leave OF f-cli-name IN FRAME Dialog-Frame /* Контрагент */
do:
  run f-query.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-cli-name Dialog-Frame
ON return OF f-cli-name IN FRAME Dialog-Frame /* Контрагент */
do:
  run f-query.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-date Dialog-Frame
ON leave OF f-date IN FRAME Dialog-Frame /* Дата с */
do:
  run f-query.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-date Dialog-Frame
ON return OF f-date IN FRAME Dialog-Frame /* Дата с */
do:
  run f-query.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-date-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-date-2 Dialog-Frame
ON leave OF f-date-2 IN FRAME Dialog-Frame /* по */
do:
  run f-query.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-date-2 Dialog-Frame
ON return OF f-date-2 IN FRAME Dialog-Frame /* по */
do:
  run f-query.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-type Dialog-Frame
ON leave OF f-type IN FRAME Dialog-Frame /* Тип */
do:
  run f-query.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-type Dialog-Frame
ON return OF f-type IN FRAME Dialog-Frame /* Тип */
do:
  run f-query.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-type Dialog-Frame
ON value-changed OF f-type IN FRAME Dialog-Frame /* Тип */
do:
  run f-query.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME TOGGLE_NotConn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL TOGGLE_NotConn Dialog-Frame
ON VALUE-CHANGED OF TOGGLE_NotConn IN FRAME Dialog-Frame /* Не связ. */
DO:
  run f-query.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
if valid-handle(active-window) and frame {&FRAME-NAME}:PARENT eq ?
then frame {&FRAME-NAME}:PARENT = active-window.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
do on error   undo MAIN-BLOCK, leave MAIN-BLOCK
   on end-key undo MAIN-BLOCK, leave MAIN-BLOCK:

  { gbl/getcurus.i
    v-db-num
    v-user-id
    no-error
  }
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_egais-doc':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    glog
  }
  
  if not glog then  return .

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_egais-adm':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    false
    glog
  }
  actnEGAISAdm = if glog then true else false.

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_egais-chg-sts-doc':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    false
    glog
  }
  actnEGAISSts = if glog then true else false.

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
  assign v-ext-sys = v-value-integer .  
  
  egais = new EGAIS(v-db-num, v-user-id).
  
  egais:EGAISImpl = new WayBill (v-cntxt-obj-type, v-cntxt-obj-code, v-fs-rar, v-ext-sys).
  
  egaisWBAdv = cast (egais:EGAISImpl, ibs.th.bge.egais.WayBill).
  egaisWBAdv:ActnEGAISAdm = actnEGAISAdm.
  egaisWBAdv:ActnEGAISSts = actnEGAISSts.
  
  create query qh-wb-egais.
  create browse browse-hdl-wb-egais
    assign 
      title     = 'Накладные ЕГАИС'
      frame     = frame {&FRAME-NAME}:handle
      query     = qh-wb-egais
      x         = 10
      y         = 70
      width     = 119
      height    = 24
      visible   = true
      read-only = true
      sensitive = true
      separators = true
      column-resizable = true
      column-scrolling = true
      triggers:
        on mouse-move-dblclick persistent run msdblcl.
        on row-display persistent run proc-row-disp.
      end triggers
  .
  bh-wb-egais = egais:GetHndlTable({&wb-clob}, "").
  qh-wb-egais:set-buffers (bh-wb-egais).
  qh-wb-egais:query-prepare ("for each tt-wb-hndls by tt-wb-hndls.wb-date descending").
  qh-wb-egais:query-open.
  if not bh-wb-egais = ? 
  then do:
    extent (bcol) = bh-wb-egais:num-fields.
    do ii = 1 to bh-wb-egais:num-fields:
      bcol[ii] = browse-hdl-wb-egais:add-like-column('tt-wb-hndls' + '.' + bh-wb-egais:buffer-field (ii):name, 0, 'FILL-IN').
      if entry (ii, egaisWBAdv:SettingsTTList, ';') <> ""
      then do:
        v-windth = integer (entry (1, entry (ii, egaisWBAdv:SettingsTTList, ';'))).
        v-isDisp = entry (2, entry (ii, egaisWBAdv:SettingsTTList, ';')).
        assign
          bcol[ii]:width = v-windth when v-windth > 0
          bcol[ii]:visible = false when v-isDisp = "no"
        .
      end.
    end.
  end.
  f-date = date (now) - 31.
  f-date-2 = ?.
  run f-query.
  { gbl/diasize.i &br-hndl=browse-hdl-wb-egais }
  run diasize_init in this-procedure .
  run enable_UI.
  run proc-hide-disp.
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
  DISPLAY cb-1 f-date f-date-2 f-cli-name f-cli-code f-type TOGGLE_NotConn 
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK Btn_Sel Btn_Save Btn_dnlw Btn_conn Btn_Del btn_ticket 
         Btn_accept Btn_delclob cb-1 f-date f-date-2 f-cli-name f-cli-code 
         f-type TOGGLE_NotConn 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE f-query Dialog-Frame 
PROCEDURE f-query :
  
  def var v-proposition  as char no-undo.
  def var v-proposition1 as char no-undo.
  def var v-rowid as rowid no-undo.
  
  assign input frame {&FRAME-NAME}
    f-cli-name
    f-cli-code
    f-date
    f-date-2
    f-type
    TOGGLE_NotConn
  .
  
  v-proposition = 
    (if f-date <> ? then "tt-wb-hndls.wb-date >= " + string (f-date) else "") +
    (if f-date-2 <> ? then " and tt-wb-hndls.wb-date <= " + string (f-date-2) else "") + 
    (if f-cli-name <> "" then " and tt-wb-hndls.cliname matches '*" + string (f-cli-name) + "*'" else "") + 
    (if f-type <> "" and f-type <> "Все" then " and tt-wb-hndls.wb-type matches '" + string (f-type) + "'" else "") +
    (if f-cli-code <> 0 and f-cli-code <> ? then " and tt-wb-hndls.cli matches '*" + string (f-cli-code) + "*'" else "") +
    (if logical (TOGGLE_NotConn) then " and not tt-wb-hndls.isWB" else  "") 
    .
    
  v-proposition = left-trim (v-proposition, " and").
  v-proposition1 = v-proposition.
  v-proposition = "where " + v-proposition.

  case cb-1 :
    when 1 then 
    do:
      qh-wb-egais:query-close.
      qh-wb-egais:query-prepare ( substitute ("for each tt-wb-hndls &1 by tt-wb-hndls.wb-date descending", v-proposition) ).
      qh-wb-egais:query-open.
      bh-wb-egais:find-first ( "where (" + v-proposition1 + ")" + "and tt-wb-hndls.uniq-key-rec = " + "'" + v-uniq-key-rec + "'") no-error.
    end.
    when 2 then
    do:
      qh-wb-egais:query-close.
      qh-wb-egais:query-prepare ( substitute ("for each tt-wb-hndls &1 by tt-wb-hndls.wb-date descending", v-proposition) ).
      qh-wb-egais:query-open.
      bh-wb-egais:find-first ( "where (" + v-proposition1 + ")" + "and tt-wb-hndls.uniq-key-rec = " + "'" + v-uniq-key-rec + "'") no-error.
    end.
    when 3 then
    do:
      qh-wb-egais:query-close.
      qh-wb-egais:query-prepare ("for each tt-wb-act-hndls").
      qh-wb-egais:query-open.
    end.
    when 4 then
    do:
      qh-wb-egais:query-close.
      qh-wb-egais:query-prepare ( substitute ("for each tt-wb-hndls &1 by tt-wb-hndls.wb-date descending", v-proposition) ).
      qh-wb-egais:query-open.
      bh-wb-egais:find-first ( "where (" + v-proposition1 + ")" + "and tt-wb-hndls.trn-doc-code = " + "'" + v-trn-doc + "'") no-error.
    end.
  end case.
  if bh-wb-egais:available
    then qh-wb-egais:reposition-to-rowid ( bh-wb-egais:rowid ).
  egaisWBAdv:ReleaseTable_().
  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE msdblcl Dialog-Frame 
PROCEDURE msdblcl :
if cb-1 <> 1 and cb-1 <> 3 and cb-1 <> 2 and cb-1 <> 4
    then apply "choose" to Btn_Save in frame {&frame-name} .
    else apply "choose" to Btn_Sel in frame {&frame-name} .

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-row-disp Dialog-Frame 
PROCEDURE proc-row-disp :
def var ii as int no-undo.
  
  if cb-1 = 1 or cb-1 = 2 then do:
    do ii = 1 to extent (bcol).  
      if valid-handle (bcol[ii]) 
        then do: 
        assign
          bcol[ii]:bgcolor = DARK_GRAY_COLOR when not bh-wb-egais:buffer-field ("isWb"):buffer-value and not cb-1 = 2
          bcol[ii]:bgcolor = WHITE_COLOR when bh-wb-egais:buffer-field ("isWb"):buffer-value and not cb-1 = 2
          bcol[ii]:bgcolor = RED_COLOR when bh-wb-egais:buffer-field ("EGAISSts"):buffer-value = 'Rejected' or bh-wb-egais:buffer-field ("EGAISSts"):buffer-value = 'Распроведена'
          bcol[ii]:bgcolor = CYAN_COLOR when bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value = 'отказ'
        .
        if bh-wb-egais:buffer-field (ii) = bh-wb-egais:buffer-field ("tts-status_")
        then do:
          assign
            bcol[ii]:bgcolor = GREEN_COLOR when bh-wb-egais:buffer-field ("tts-status_"):buffer-value = "Принят"
            bcol[ii]:bgcolor = RED_COLOR when bh-wb-egais:buffer-field ("tts-status_"):buffer-value = "Отклонен"
          .
        end.
      end.
    end.
  end.
  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reopen-browse Dialog-Frame 
PROCEDURE reopen-browse :

  if bh-wb-egais = ? 
      then return .

  if valid-handle (browse-hdl-wb-egais) then do: /*для правильной работы изменения размеров окна и browse.*/
    v-width  = browse-hdl-wb-egais:width-chars.
    v-height = browse-hdl-wb-egais:height-chars.
  end.

  case cb-1 :
    when 1 then 
    do:
      delete object browse-hdl-wb-egais.
      create browse browse-hdl-wb-egais
        assign 
          title     = 'Накладные ЕГАИС'
          frame     = frame {&FRAME-NAME}:handle
          query     = qh-wb-egais
          x         = 10
          y         = 70
          width     = if v-width <> 0 then v-width else 119
          height    = if v-height <> 0 then v-height else 24
          visible   = true
          read-only = true
          sensitive = true
          separators = true
          column-resizable = true
          column-scrolling = true
          triggers:
            on mouse-move-dblclick persistent run msdblcl.
            on row-display persistent run proc-row-disp.
          end triggers
      .
      bh-wb-egais = egais:GetHndlTable({&wb-clob}, "").
      qh-wb-egais:set-buffers (bh-wb-egais).
      qh-wb-egais:query-prepare ("for each tt-wb-hndls by tt-wb-hndls.wb-date descending").
      qh-wb-egais:query-open.
      if not bh-wb-egais = ? 
      then do:
        do ii = 1 to bh-wb-egais:num-fields:
          bcol[ii] = browse-hdl-wb-egais:add-like-column('tt-wb-hndls' + '.' + bh-wb-egais:buffer-field (ii):name, 0, 'FILL-IN').
          if entry (ii, egaisWBAdv:SettingsTTList, ';') <> ""
          then do:
            v-windth = integer (entry (1, entry (ii, egaisWBAdv:SettingsTTList, ';'))).
            v-isDisp = entry (2, entry (ii, egaisWBAdv:SettingsTTList, ';')).
            assign
              bcol[ii]:width = v-windth when v-windth > 0
              bcol[ii]:visible = false when v-isDisp = "no"
            .
          end.
        end.
      end.
      Btn_Sel:label = "Изменить".
      enable Btn_Sel with frame {&FRAME-NAME}.
      v-diasize-browse-handle = browse-hdl-wb-egais.
    end.
    when 2  then 
    do:
      delete object browse-hdl-wb-egais.
      create browse browse-hdl-wb-egais
        assign 
          title     = 'Накладные TH'
          frame     = frame {&FRAME-NAME}:handle
          query     = qh-wb-egais
          x         = 10
          y         = 70
          width     = if v-width <> 0 then v-width else 119
          height    = if v-height <> 0 then v-height else 24
          visible   = true
          read-only = true
          sensitive = true
          separators = true
          column-resizable = true
          column-scrolling = true
          triggers:
            on row-display persistent run proc-row-disp.
            on mouse-move-dblclick persistent run msdblcl.
          end triggers
      .
      bh-wb-egais = egais:GetHndlTable({&wb-fact}, "").
      qh-wb-egais:set-buffers (bh-wb-egais).
      qh-wb-egais:query-prepare ("for each tt-wb-hndls by tt-wb-hndls.wb-date descending").
      qh-wb-egais:query-open.
      if not bh-wb-egais = ? 
      then do:
        do ii = 1 to bh-wb-egais:num-fields:
          bcol[ii] = browse-hdl-wb-egais:add-like-column('tt-wb-hndls' + '.' + bh-wb-egais:buffer-field (ii):name, 0, 'FILL-IN').
          if entry (ii, egaisWBAdv:SettingsTTList, ';') <> ""
          then do:
            v-windth = integer (entry (1, entry (ii, egaisWBAdv:SettingsTTList, ';'))).
            v-isDisp = entry (2, entry (ii, egaisWBAdv:SettingsTTList, ';')).
            assign
              bcol[ii]:width = v-windth when v-windth > 0
              bcol[ii]:visible = false when v-isDisp = "no"
            .
          end.
        end.
      end.
      Btn_Sel:label = "Просмотр".
      v-diasize-browse-handle = browse-hdl-wb-egais.
    end.
    when 3  then 
    do:
      delete object browse-hdl-wb-egais.
      create browse browse-hdl-wb-egais
        assign 
          title     = 'Акты ЕГАИС'
          frame     = frame {&FRAME-NAME}:handle
          query     = qh-wb-egais
          x         = 10
          y         = 70
          width     = if v-width <> 0 then v-width else 119
          height    = if v-height <> 0 then v-height else 24
          visible   = true
          read-only = true
          sensitive = true
          separators = true
          column-resizable = true
          column-scrolling = true
          triggers:
            on mouse-move-dblclick persistent run msdblcl.
          end triggers
      .
      bh-wb-egais = egais:GetHndlTable({&wb-clob-act}, "").
      qh-wb-egais:set-buffers (bh-wb-egais).
      qh-wb-egais:query-prepare ("for each tt-wb-act-hndls").
      qh-wb-egais:query-open.
      if not bh-wb-egais = ? 
      then do:
        do ii = 1 to bh-wb-egais:num-fields:
          bcol[ii] = browse-hdl-wb-egais:add-like-column('tt-wb-act-hndls' + '.' + bh-wb-egais:buffer-field (ii):name, 0, 'FILL-IN').
          if entry (ii, egaisWBAdv:SettingsTTList, ';') <> ""
          then do:
            v-windth = integer (entry (1, entry (ii, egaisWBAdv:SettingsTTList, ';'))).
            v-isDisp = entry (2, entry (ii, egaisWBAdv:SettingsTTList, ';')).
            assign
              bcol[ii]:width = v-windth when v-windth > 0
              bcol[ii]:visible = false when v-isDisp = "no"
            .
          end.
        end.
      end.
      Btn_Sel:label = "Просмотр". 
      enable Btn_Sel with frame {&FRAME-NAME}.
      v-diasize-browse-handle = browse-hdl-wb-egais.
    end.
    when 4  then 
    do:
      delete object browse-hdl-wb-egais.
      create browse browse-hdl-wb-egais
        assign 
          title     = 'Расходные накладные'
          frame     = frame {&FRAME-NAME}:handle
          query     = qh-wb-egais
          x         = 10
          y         = 70
          width     = if v-width <> 0 then v-width else 119
          height    = if v-height <> 0 then v-height else 24
          visible   = true
          read-only = true
          sensitive = true
          separators = true
          column-resizable = true
          column-scrolling = true
          triggers:
            on mouse-move-dblclick persistent run msdblcl.
          end triggers
      .
      bh-wb-egais = egais:GetHndlTable({&wb-ras}, "").
      qh-wb-egais:set-buffers (bh-wb-egais).
      qh-wb-egais:query-prepare ("for each tt-wb-hndls by tt-wb-hndls.wb-date descending").
      qh-wb-egais:query-open.
      if not bh-wb-egais = ? 
      then do:
        do ii = 1 to bh-wb-egais:num-fields:
          bcol[ii] = browse-hdl-wb-egais:add-like-column('tt-wb-hndls' + '.' + bh-wb-egais:buffer-field (ii):name, 0, 'FILL-IN').
          if entry (ii, egaisWBAdv:SettingsTTList, ';') <> ""
          then do:
            v-windth = integer (entry (1, entry (ii, egaisWBAdv:SettingsTTList, ';'))).
            v-isDisp = entry (2, entry (ii, egaisWBAdv:SettingsTTList, ';')).
            assign
              bcol[ii]:width = v-windth when v-windth > 0
              bcol[ii]:visible = false when v-isDisp = "no"
            .
          end.
        end.
      end.
      Btn_Sel:label = "Просмотр".
      enable Btn_Sel with frame {&FRAME-NAME}.
      v-diasize-browse-handle = browse-hdl-wb-egais.
    end.
  end.
  
  if f-date-2 <> ? or f-date <> ? or f-cli-name <> "" or f-type <> ""
    then run f-query.
  
  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE rejectWB Dialog-Frame 
PROCEDURE rejectWB :

  def var v-doc-code as character no-undo.
  def var ticketRasObj as class WayBill no-undo.
  def var bh-TicketHndl as handle no-undo.
  def var qh-TicketHndl as handle no-undo.
  
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_egais-reject':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    glog
  }
  
  if not glog then  return .

  if not bh-wb-egais:available 
    then return no-apply.
  
  case cb-1: 
  when 1
  then do:
    bh-wb-gds-EG-header = egais:GetHndlTable(1, bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value).
    if egais:StatusErr
    then do:
      message egais:Msg view-as alert-box error.
      return no-apply.
    end.
    if can-find (first ub.trn-doc where ub.trn-doc.doc-code = bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value)
    then do:
      message substitute ( "Накладная с № &1 уже сформирована, все равно отправить отказ", bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value)
      view-as alert-box question buttons yes-no update isChoise as logical.
      if not isChoise 
        then return no-apply.
    end.
    else do:
      message "Отправить отказ?" view-as alert-box question buttons yes-no update isChoise.
      if not isChoise 
        then return no-apply.
    end.
    egais:RejectWB(bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value).
    if egais:StatusErr
    then do:
      message egais:Msg view-as alert-box error.
      return no-apply.
    end.
    else run f-query.
  end.
  when 4
  then do:
    ticketRasObj = new WayBill (v-cntxt-obj-type, v-cntxt-obj-code, v-fs-rar, v-ext-sys).
    bh-wb-gds-EG = ?.
    bh-wb-gds-EG-header = ?.
    v-doc-code = bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value.
    
    bh-TicketHndl = ticketRasObj:GetHndlTable({&ticket-ras}, bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value).
    
    create query qh-TicketHndl.
    qh-TicketHndl:set-buffers (bh-TicketHndl).
    
    qh-TicketHndl:query-close ().
    qh-TicketHndl:query-prepare ("for each tt-ticket where tt-ticket.regid <> '' and tt-ticket.doc = 'WayBill' by tt-ticket.regid descending").
    qh-TicketHndl:query-open ().

    if not qh-TicketHndl:is-open or not qh-TicketHndl:get-first ()
    then do:
      message "Не найдена накладная ЕГАИС, на которую можно послать отказ.".
      delete object ticketRasObj.
      return.
    end.
    bh-wb-gds-EG-header = egais:GetHndlTable({&wb-ras-header}, bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value).
    v-uniq-key-rec = bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value.
    egaisWBAdv:SendWBActRejUTM(bh-TicketHndl:buffer-field ("regid"):buffer-value).
    message "Отправлен отказ на накладную ЕГАИС - " + bh-TicketHndl:buffer-field ("regid"):buffer-value view-as alert-box information title "Информация".
    delete object ticketRasObj.
  end.
  end case.
  
end procedure.
  
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ReqRepealWB Dialog-Frame 
PROCEDURE ReqRepealWB :

  def var v-doc-code as character no-undo.
  def var ticketRasObj as class WayBill no-undo.
  def var bh-TicketHndl as handle no-undo.
  def var qh-TicketHndl as handle no-undo.
  
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_egais-reject':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    glog
  }
  
  if not glog then  return .

  if not bh-wb-egais:available 
    then return no-apply.
  
  case cb-1: 
  when 1
  then do:
    bh-wb-gds-EG-header = egais:GetHndlTable(1, bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value).
    if egais:StatusErr
    then do:
      message egais:Msg view-as alert-box error.
      return no-apply.
    end.
    if can-find (first ub.trn-doc where ub.trn-doc.doc-code = bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value)
    then do:
      message substitute ( "Накладная с № &1 уже сформирована, все равно отправить запрос на отмену проведения накладной.", bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value)
      view-as alert-box question buttons yes-no update isChoise as logical.
      if not isChoise 
        then return no-apply.
    end.
    else do:
      message "Отправить запрос на отмену проведения накладной?" view-as alert-box question buttons yes-no update isChoise.
      if not isChoise 
        then return no-apply.
    end.
    egaisWBAdv:SendReqRepealWBUTM(bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value).
    if egaisWBAdv:StatusErr
    then do:
      message egaisWBAdv:Msg view-as alert-box error.
      return no-apply.
    end.
    else run f-query.
  end.
  end case.
  
end procedure.
  
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-hide-disp Dialog-Frame 
procedure proc-hide-disp:

  if (cb-1:screen-value in frame {&frame-name} = "2" or cb-1:screen-value  in frame {&frame-name} = "1") and actnEGAISAdm 
    then Btn_accept:hidden in frame {&frame-name} = false.
    else Btn_accept:hidden in frame {&frame-name} = true.
  case cb-1: 
  when 1
  then do:
    enable Btn_Save with frame {&FRAME-NAME}.
    Btn_Save:label = "Сохранить".
    Btn_Del:hidden = false.
    Btn_conn:label = "Связать".
    Btn_conn:tooltip = 'Связать накладную ЕГАИС с накладной TH'.
    Btn_conn:hidden = false.
    btn_ticket:hidden = false.
    Btn_delclob:hidden = false.
    Btn_Del:popup-menu in frame {&frame-name} = menu popup-menu-reject:handle.
    Btn_Del:menu-mouse = 1.
  end.
  when 2 then do:
    enable Btn_Save with frame {&FRAME-NAME}.
    Btn_Save:label = "Отправить".
    Btn_Del:hidden = true.
    Btn_conn:label = "Акт торг.".
    Btn_conn:tooltip = 'Передача продукции в торговый зал ЕГАИС'.
    Btn_conn:hidden = false.
    btn_ticket:hidden = true.
    Btn_delclob:hidden = true.
  end.
  when 3
  then do:
    disable Btn_Save with frame {&FRAME-NAME}.
    Btn_Save:label = "Отправить".
    Btn_Del:hidden = true.
    Btn_conn:hidden = true.
    btn_ticket:hidden = true.
    Btn_delclob:hidden = true.    
  end.
  when 4
  then do:
    enable Btn_Save with frame {&FRAME-NAME}.
    Btn_Save:label = "Отправить".
    Btn_Del:hidden = false.
    Btn_conn:hidden = true.
    btn_ticket:hidden = true.
    Btn_delclob:hidden = true.
    Btn_Del:popup-menu in frame {&frame-name} = ?.
    Btn_Del:menu-mouse = ?.
  end.
  end case.
  
end.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME f-cli-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-cli-code Dialog-Frame
ON leave OF f-cli-code IN FRAME Dialog-Frame /* Код */
do:
  run f-query.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME