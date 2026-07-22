&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
using ibs.th.bge.egais.*.
/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode       as character no-undo .
define input parameter egais        as class TransferToShop no-undo .
define input parameter v-ext-sys    as integer no-undo .
define input parameter v-fs-rar     as character no-undo .
define input parameter bh-act-header  as handle no-undo .
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "ЕГАИС Акт передачи продукции в магазин".

{ cmp/vssrevis.i }
{ cmp/showinf.i  }

define variable ii                  as integer no-undo .
define variable jj                  as integer no-undo .
define variable nn                  as integer no-undo .
define variable exts                as integer no-undo .
define variable v-position_         as integer no-undo .
define variable v-date              as character no-undo .
define variable v-rid-list          as character no-undo .
define variable par-alcohol         as character no-undo .
define variable par-egais-name      as character no-undo .
define variable par-type            as character no-undo .
define variable v-attr-value        as character            no-undo .
define variable v-attr-type         as character            no-undo .
define variable err-good            as logical no-undo .
define variable p-ext-rec           as recid no-undo .

define variable glog        as logical no-undo .

define variable v-obj-uniq-key-rec as character no-undo .



define variable qh-gds-act          as handle no-undo .
define variable bh-gds-act          as handle no-undo .
define variable brh-gds-act         as handle no-undo .

define variable v-gds-uniq-key-rec as character no-undo .

define variable v-part-num    as integer   no-undo .
define variable v-clob-db-num as integer   no-undo .
define variable v-int64-id    as int64     no-undo .
define variable v-info        as character no-undo .



define variable v-longchar      as memptr no-undo .

define buffer buf_goods         for ub.goods .
define buffer buf_parts         for ub.parts .
define buffer buf_trn-doc       for ub.trn-doc .
define buffer buf_doc-line      for ub.doc-line .
define buffer x_ext-classif     for ub.ext-classif .
define buffer x_ext-classif-attr     for ub.ext-classif-attr .
define buffer buf_clob-bind     for ub.clob-bind .
define buffer buf_clob-data     for ub.clob-data .

define stream str-log .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

{cmp/str-glbl.i}
{ gbl/color.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ ref/extclass.i }
{ gbl/key-rec.i  }
{ gbl/thbjattr.i }
{ ref/gds-attr.i }
{ str/trdcalib.i   }
{ gbl/color.i    }
{ gbl/waitfram.i }
{ibs/th/bge/egais/tts-egais.i proc }

define new shared temp-table tt-exts
    field ext-rec as recid
    field gds-code as integer
    index pi as primary unique
        ext-rec gds-code
.

define variable select-list as longchar no-undo .

FUNCTION get-mark RETURNS CHARACTER
(buffer local-gds for tt-gds-act ):
if lookup (string (recid (local-gds)), select-list) > 0  then return "*".
                                                           else return "".
end function.

/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

define menu m-add
    menu-item m-goods   label "по складскому документу"
    menu-item m-free    label "товары по свободной зоне"
    menu-item m-one-good label "один товар"
.

DEFINE BUTTON b-cancel AUTO-END-KEY 
     LABEL "Выход" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .
     
DEFINE BUTTON b-good
     LABEL "Добавить" 
     SIZE 15 BY 1.14
     BGCOLOR 8 . 
     
DEFINE BUTTON b-alc-code
     LABEL "Выбор алк. кода" 
     SIZE 20 BY 1.14 TOOLTIP "Выбрать алкогольный код"
     BGCOLOR 8 .
     
DEFINE BUTTON b-del
     LABEL "Удалить строку" 
     SIZE 15 BY 1.14 TOOLTIP "Удалить строку акта"
     BGCOLOR 8 .  
     
DEFINE BUTTON b-save
     LABEL "Сохранить" 
     SIZE 15 BY 1.14 TOOLTIP "Сохранить в БД"
     BGCOLOR 8 . 
     
DEFINE BUTTON b-mark 
     LABEL "&*" 
     SIZE 3 BY 1.14 .
     
DEFINE BUTTON b-sel-all
     LABEL "&+":L
     SIZE 3 BY 1.14 TOOLTIP "Отметить все объекты".

DEFINE BUTTON b-unmark
     LABEL "&-":L
     SIZE 3 BY 1.14 TOOLTIP "Снять все отметки".
     
/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-gds-act FOR 
      tt-gds-act SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-gds-act
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-gds-act Dialog-Frame _FREEFORM
  QUERY br-gds-act  DISPLAY
    get-mark(BUFFER tt-gds-act) COLUMN-LABEL "*"  FORMAT "X(1)":U
    tt-gds-act.position_
    tt-gds-act.gds-code
    tt-gds-act.alc-code
    tt-gds-act.gds-name
    tt-gds-act.qnty
    tt-gds-act.inform-B 
  ENABLE
    tt-gds-act.qnty
    tt-gds-act.inform-B
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 107 BY 20.2 FIT-LAST-COLUMN.  

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
    b-cancel at row 1.2 col 2
    b-good at row 1.2 col 32
    b-del at row 1.2 col 47
    b-save at row 1.2 col 17
    b-alc-code at row 1.2 col 62
    tt-act-header.num at row 2.5 col 2 format "X(30)"
    tt-act-header.date_ at row 2.5 col 42
    b-mark AT ROW 4 COL 2
    b-sel-all AT ROW 4 COL 5
    b-unmark AT ROW 4 COL 8
    br-gds-act at row 5.2 col 2
     SPACE(0.5) SKIP(0.5)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Акт о передаче продукции в торговый зал" WIDGET-ID 100.


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
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* <insert dialog title> */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
/*  {&stdbtn}*/
  run proc-b-mark in this-procedure no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-sel-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-all Dialog-Frame
ON CHOOSE OF b-sel-all IN FRAME Dialog-Frame /* + */
DO:
  assign select-list = "".
  if not available tt-gds-act then return.
  for each tt-gds-act no-lock :
    { gbl/markstrn.i tt-gds-act select-list }
  end.
  br-gds-act:refresh() in frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-unmark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-unmark Dialog-Frame
ON CHOOSE OF b-unmark IN FRAME Dialog-Frame /* - */
DO:
  if not available tt-gds-act then return.
  select-list  = "".
  br-gds-act:refresh() in frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cancel Dialog-Frame
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame /* - */
DO:
    if p-mode <> {&lookup} then do :
        message "Все несохранённые данные будут потеряны. Вы уверены, что хотите выйти?"
        view-as alert-box question buttons yes-no update glog.
        if not glog then return no-apply . 
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* - */
DO:
    define variable v-tt-rec as recid.
    if available tt-gds-act  AND select-list = ""
    then
    select-list = string( recid( tt-gds-act ) ) .
    
    if not available tt-gds-act and select-list = "" then do :
        message "Выберите строку" view-as alert-box .
        return no-apply.
    end.
    else
    do ii = 1 to num-entries (select-list) :
      v-tt-rec = integer(entry(ii, select-list)) . 
      for first tt-gds-act exclusive-lock where recid(tt-gds-act) = v-tt-rec :  
        delete tt-gds-act .
      end.  
    end.
    nn = 0 .
    for each tt-gds-act exclusive-lock :
        nn = nn + 1 .
        tt-gds-act.position_ = nn .
    end.
    select-list = "" .
    open QUERY br-gds-act FOR each tt-gds-act exclusive-lock .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-act-header.num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-act-header.num Dialog-Frame
ON "leave" of tt-act-header.num in FRAME Dialog-Frame /* <insert dialog title> */
/*or ON return of tt-act-header.num in FRAME Dialog-Frame*/
DO:
    define variable prev-num as character no-undo .
    prev-num = tt-act-header.num .
    assign tt-act-header.num .
    for each tt-gds-act exclusive-lock where tt-gds-act.num = prev-num :
        assign tt-gds-act.num = tt-act-header.num .    
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

on choose of b-alc-code IN FRAME Dialog-Frame
do :
    if not available tt-gds-act then return no-apply .
    run bge/egais-select-alc-code.w (input tt-gds-act.gds-code, output p-ext-rec) .
    find first X_ext-classif no-lock where recid(X_ext-classif) = p-ext-rec no-error .
    if not available X_ext-classif then return no-apply.
    assign tt-gds-act.alc-code = X_ext-classif.charkey_one .
    br-gds-act:refresh() .
end.

on row-display of br-gds-act in FRAME Dialog-Frame
DO :
    exts = 0 .
    for each tt-exts no-lock where tt-exts.gds-code = tt-gds-act.gds-code :
        exts = exts + 1 .
    end.
    if exts > 1 then tt-gds-act.alc-code:bgcolor in browse br-gds-act = yellow_color .
end.

on value-changed of br-gds-act IN FRAME Dialog-Frame
DO :
if available tt-gds-act then do :
    exts = 0 .
    for each tt-exts no-lock where tt-exts.gds-code = tt-gds-act.gds-code :
        exts = exts + 1 .
    end.
    if exts > 1 then enable b-alc-code WITH FRAME Dialog-Frame.
    else disable b-alc-code WITH FRAME Dialog-Frame.
end.
end.

&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save Dialog-Frame
ON CHOOSE OF b-save IN FRAME Dialog-Frame /* Создать */
DO:
    assign
        tt-act-header.num
        tt-act-header.date_
    .
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
    find first buf_clob-bind exclusive-lock where buf_clob-bind.uniq-key-rec = tt-act-header.num
                                              and buf_clob-bind.field-name_  = {&lob-egais-tts} no-error .
    if available buf_clob-bind then do :
        if p-mode = {&add-def} then do :
            message "Акт с таким номером уже существует!" view-as alert-box .
            return no-apply .
        end.
        assign
            v-clob-db-num = buf_clob-bind.db-num
            v-int64-id = buf_clob-bind.int64-id
            v-part-num = buf_clob-bind.part-num
        .
        run gbl/file2clb.p ( input {&update}
                  ,input "add-new,yes"
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
    end.
    else do :
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
    end.
        
    message "Сохранение завершено" view-as alert-box.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME    

&Scoped-define SELF-NAME m-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-goods Dialog-Frame
on choose of menu-item m-goods in menu m-add 
DO:
    run str/all-docs.w
    ( input  parparentproc
     ,input  v-cntxt-host-code-obj /*host-code*/
     ,input  v-cntxt-obj-type  /*obj-type*/
     ,input  v-cntxt-obj-code  /*obj-code*/
     ,input  {&g___object}
     ,input  {&fact}
     ,input  '?'
     ,input  ?
     ,input  ?
     ,input  "b-sel":U
     ,input  {&TDEDT_Vozvrat_Perem}
     ,input  false
     ,input  ?
     ,output v-rid-list
    ).
    if v-rid-list = "" or v-rid-list = ? 
    then return no-apply.
    
    find first   buf_trn-doc no-lock where recid(buf_trn-doc) = int(v-rid-list) no-error .
    if error-status :error then return .
    
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
    
    
    open QUERY br-gds-act FOR each tt-gds-act exclusive-lock .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-goods Dialog-Frame
on choose of menu-item m-free in menu m-add 
DO:
    define variable v-user-action    as character no-undo.
    define variable v-printed        as logical   no-undo.
    
    run ref/gds-ref.p
    ( parparentproc
    ,'b-sel,b-mark,b-add'
    ,?             /*p-stat */
    ,?             /*p-list  */
    ,{&free}             /*p-cond  */
    ,?             /*p-rec   */
    ,?             /*p-grp   */
    ,?             /*p-cli-type */
    ,?             /*p-cli-code  */
    ,v-cntxt-obj-type    /*p-obj-type  */
    ,v-cntxt-obj-code     /*p-obj-code  */
    ,?             /*p-other     */
    , output v-rid-list) no-error.
    if v-rid-list = "" or v-rid-list = ? 
    then return no-apply.
    if search ("act-TTS_log.err") <> ? then do:
      os-delete value("act-TTS_log.err").
    end.
    output stream str-log to value("act-TTS_log.err") append .
    err-good = false .
    _goods_ :
    do jj = 1 to num-entries(v-rid-list) :
        find buf_goods where recid (buf_goods) = integer(entry(jj, v-rid-list)) no-lock.
        run gds-attr-value(
          buf_goods.gds-code,
          {&attr-alcohol-prod},
          output par-alcohol,
          output par-type
        ).
        if par-alcohol = "" or par-alcohol = "no" then 
        do :
            put stream str-log unformatted
                string(today) + "   " + string(time, "hh:mm:ss") + " :  товар " + string(buf_goods.gds-code) + "  " + buf_goods.gds-name + "  не является алкогольной продукцией" skip.
/*            message "Выбранный товар не является алкогольной продукцией." view-as alert-box.*/
            err-good = true .
            next _goods_ .
        end.
        run gen-key-rec IN THIS-PROCEDURE ( input {&table_goods}
                                            ,input (buffer buf_goods:handle)
                                            ,output v-gds-uniq-key-rec).
                                            
        exts = 0 .                                    
        for each X_ext-classif no-lock where X_ext-classif.classif-subject = {&table_goods} 
                                       and X_ext-classif.classif-name = {&extclass_goods_esys} 
                                       AND X_ext-classif.db-num = 0  
                                       and X_ext-classif.key#_one = buf_goods.gds-code
                                       and X_ext-classif.key#_two = v-ext-sys 
                                       and X_ext-classif.key#_three = 0
                                       and X_eXt-classif.uniq-key-rec = v-gds-uniq-key-rec
                                       and X_eXt-classif.charkey_two = ""
                                       and X_eXt-classif.charkey_three = ""
                                       and X_eXt-classif.nonunique = 0 :
            find first tt-exts no-lock where tt-exts.ext-rec = recid(x_ext-classif)
                                         and tt-exts.gds-code = buf_goods.gds-code no-error.
            if not available tt-exts then do :
                create tt-exts .
                assign
                    tt-exts.ext-rec = recid(x_ext-classif)
                    tt-exts.gds-code = buf_goods.gds-code
                .
            end.
            exts = exts + 1 .    
        end.                                    
        if exts = 0 then do :
            put stream str-log unformatted
                string(today) + "   " + string(time, "hh:mm:ss") + " :  товар " + string(buf_goods.gds-code) + "  " + buf_goods.gds-name + "  не синхронизирован с ЕГАИС" skip.  
/*            message "Выбранный товар не синхронизирован с ЕГАИС. (Нет алкогольного кода)" view-as alert-box.*/
            err-good = true .
            next _goods_ .  
        end.
        else do :
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
                                               .
        end.
        
        find first buf_parts no-lock where buf_parts.artic = buf_goods.artic 
                                    and buf_parts.prod-type = buf_goods.prod-type 
                                    and buf_parts.prod-code = buf_goods.prod-code 
                                    and buf_parts.obj-type = v-cntxt-obj-type 
                                    and buf_parts.obj-code = v-cntxt-obj-code 
                                    and buf_parts.out-code = {&free-code} no-error .
        if not available buf_parts /* or buf_parts.qnty < 1 */ then do :
            put stream str-log unformatted
                string(today) + "   " + string(time, "hh:mm:ss") + " :  у товара " + string(buf_goods.gds-code) + "  " + buf_goods.gds-name + "  нет партий свободной зоны" skip.  
            err-good = true .
            next _goods_ .
        end.
          
        _parts_ :  
        for each buf_parts no-lock where buf_parts.artic = buf_goods.artic 
                                    and buf_parts.prod-type = buf_goods.prod-type 
                                    and buf_parts.prod-code = buf_goods.prod-code 
                                    and buf_parts.obj-type = v-cntxt-obj-type 
                                    and buf_parts.obj-code = v-cntxt-obj-code 
                                    and buf_parts.out-code = {&free-code} :
            if buf_parts.qnty < 1 then next _parts_ .
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
        end.
    end.
    output stream str-log close .
    
    if err-good then do :
        message "Не все выбранные товары добавлены в акт!" view-as alert-box .
        run gbl/prnfilen.w
           (input  "Ошибки при добавлении товаров"
           ,input  0
           ,input  "act-TTS_log.err"
           ,input  7
           ,output v-user-action
           ,output v-printed
           ).    end.
    open QUERY br-gds-act FOR each tt-gds-act exclusive-lock .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m-one-good
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-one-good Dialog-Frame
on choose of menu-item m-one-good in menu m-add 
DO:
    run ref/gds-ref.p
    ( parparentproc
    ,'b-sel,b-add'
    ,?             /*p-stat */
    ,?             /*p-list  */
    ,{&all}             /*p-cond  */
    ,?             /*p-rec   */
    ,?             /*p-grp   */
    ,?             /*p-cli-type */
    ,?             /*p-cli-code  */
    ,v-cntxt-obj-type    /*p-obj-type  */
    ,v-cntxt-obj-code     /*p-obj-code  */
    ,?             /*p-other     */
    , output v-rid-list) no-error.
    if v-rid-list = "" or v-rid-list = ? 
    then return no-apply.
        
    find buf_goods where recid (buf_goods) = integer(v-rid-list) no-lock.
    run gds-attr-value(
      buf_goods.gds-code,
      {&attr-alcohol-prod},
      output par-alcohol,
      output par-type
    ).
    if par-alcohol = "" or par-alcohol = "no" then 
    do :
        message "Выбранный товар не является алкогольной продукцией." view-as alert-box.
        return no-apply .
    end.
    run gen-key-rec IN THIS-PROCEDURE ( input {&table_goods}
                                        ,input (buffer buf_goods:handle)
                                        ,output v-gds-uniq-key-rec).
    exts = 0 . 
    for each X_ext-classif no-lock where X_ext-classif.classif-subject = {&table_goods} 
                                       and X_ext-classif.classif-name = {&extclass_goods_esys} 
                                       AND X_ext-classif.db-num = 0  
                                       and X_ext-classif.key#_one = buf_goods.gds-code
                                       and X_ext-classif.key#_two = v-ext-sys 
                                       and X_ext-classif.key#_three = 0
                                       and X_eXt-classif.uniq-key-rec = v-gds-uniq-key-rec
                                       and X_eXt-classif.charkey_two = ""
                                       and X_eXt-classif.charkey_three = ""
                                       and X_eXt-classif.nonunique = 0 :
        find first tt-exts no-lock where tt-exts.ext-rec = recid(x_ext-classif)
                                         and tt-exts.gds-code = buf_goods.gds-code no-error.
        if not available tt-exts then do :                                   
            create tt-exts .
            assign
                tt-exts.ext-rec = recid(X_ext-classif)
                tt-exts.gds-code = buf_goods.gds-code 
            .                                  
        end.
        exts = exts + 1 .
    end. 
    if exts = 0 then do :                                  
        message "Выбранный товар не синхронизирован с ЕГАИС. (Нет алкогольного кода)" view-as alert-box.
        return no-apply.  
    end.
    else if exts = 1 then do :
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
                                           .
    end.
    else do :
        run bge/egais-select-alc-code.w (input buf_goods.gds-code, output p-ext-rec) .
        find first X_ext-classif no-lock where recid(X_ext-classif) = p-ext-rec no-error .
        if not available X_ext-classif then return no-apply.
    end.
    
    nn = nn + 1 .  
    create tt-gds-act .
    assign
        tt-gds-act.gds-code         = buf_goods.gds-code
        tt-gds-act.alc-code         = if available X_ext-classif then X_ext-classif.charkey_one else ""
        tt-gds-act.gds-name         = buf_goods.gds-name
        tt-gds-act.num              = tt-act-header.num
        tt-gds-act.position_        = nn
        tt-gds-act.qnty       = 0
    .
    open QUERY br-gds-act FOR each tt-gds-act exclusive-lock .
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    
/*    { gbl/ed_date.i tt-gds-act.A-bottleDate 'in browse br-gds-act' }*/
/*    { gbl/ed_date.i tt-gds-act.A-ttnDate 'in browse br-gds-act' }   */
/*    { gbl/ed_date.i tt-gds-act.A-fixDate 'in browse br-gds-act' }   */
    assign
        b-good:popup-menu in frame {&FRAME-NAME} = menu m-add:handle
        b-good:menu-mouse = 1
        nn = 0
    .
    empty temp-table tt-exts .
    
    if p-mode = {&add-def} then do :
        v-date = substitute ("&1&2&3", string (day (now), "99"), string (month (now), "99"),substring (string(year (now)), 3,2)).        
        create tt-act-header .
        assign
            tt-act-header.num = "TTS-" + v-date + '-' + substring(v-cntxt-obj-type,1,1) + string(v-cntxt-obj-code) + '-' + string(int(TIME))
            tt-act-header.date_ = TODAY
            tt-act-header.is-sent = no
        .
        display tt-act-header.num tt-act-header.date_ with frame {&FRAME-NAME}.
        enable  tt-act-header.date_ b-good with frame {&FRAME-NAME}.     
    end.
    
    if p-mode = {&update} or p-mode = {&lookup} then do :
        find last buf_clob-bind where buf_clob-bind.uniq-key-rec = bh-act-header:buffer-field ("num"):buffer-value
                                  and buf_clob-bind.field-name_ = {&lob-egais-tts} 
                                  and buf_clob-bind.part-num = 1  .
        find first buf_clob-data no-lock where buf_clob-data.db-num = buf_clob-bind.db-num and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
        copy-lob
        from  object buf_clob-data.cdata
        to  file 'temp-tts.xml'
        no-convert
        no-error .
        run waitfram-show in this-procedure ("Ждите...") .
        run parseXML in this-procedure (input "temp-tts.xml") .
        run waitfram-hide in this-procedure .
        display tt-act-header.num tt-act-header.date_ with frame {&FRAME-NAME}.
        if p-mode = {&update} then
        for each tt-gds-act no-lock :
            nn = nn + 1 .
            find first buf_goods no-lock where buf_goods.gds-code = tt-gds-act.gds-code no-error .
            if not available buf_goods then do :
                message "По алкогольному коду " tt-gds-act.alc-code " не найден товар из TH. Вероятно, кто-то удалил связку." view-as alert-box.
                next. 
            end.
            run gen-key-rec IN THIS-PROCEDURE ( input {&table_goods}
                                            ,input (buffer buf_goods:handle)
                                            ,output v-gds-uniq-key-rec).
            for each X_ext-classif no-lock where X_ext-classif.classif-subject = {&table_goods} 
                                           and X_ext-classif.classif-name = {&extclass_goods_esys} 
                                           AND X_ext-classif.db-num = 0  
                                           and X_ext-classif.key#_one = buf_goods.gds-code
                                           and X_ext-classif.key#_two = v-ext-sys 
                                           and X_ext-classif.key#_three = 0
                                           and X_eXt-classif.uniq-key-rec = v-gds-uniq-key-rec
                                           and X_eXt-classif.charkey_two = ""
                                           and X_eXt-classif.charkey_three = ""
                                           and X_eXt-classif.nonunique = 0 :
                find first tt-exts no-lock where tt-exts.ext-rec = recid(x_ext-classif)
                                         and tt-exts.gds-code = buf_goods.gds-code no-error.
                if not available tt-exts then do :
                    create tt-exts .
                    assign
                        tt-exts.ext-rec = recid(X_ext-classif)
                        tt-exts.gds-code = tt-gds-act.gds-code 
                    . 
                end.                                 
            end.
        end .
        
        open QUERY br-gds-act FOR each tt-gds-act exclusive-lock .
        
        if p-mode = {&lookup} then disable b-good with frame {&FRAME-NAME}.
        else enable b-good with frame {&FRAME-NAME}. 
/*        if available buf_goods then enable b-add with frame {&FRAME-NAME}.*/
/*        if p-mode = {&lookup} then hide b-add in frame {&FRAME-NAME}.     */
    end.
    
/*    create query qh-gds-act .*/
/*    qh-gds-act:set-buffers ()*/
    { gbl/diasize.i &browse-name=br-gds-act }
    run diasize_init in this-procedure .
    RUN enable_UI.
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-mark Dialog-Frame
PROCEDURE proc-b-mark :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable varlog as logical   no-undo .
  if not available tt-gds-act then return.
  run local-mark in this-procedure.
  assign varlog = br-gds-act :select-next-row( ) in frame {&frame-name}.
  apply "ENTRY":U to br-gds-act in frame {&frame-name}.
  br-gds-act:refresh() in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-mark Dialog-Frame
PROCEDURE local-mark :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  if not available tt-gds-act then do:
    message "Неправильный выбор строки.".
    return no-apply.
  end.
  { gbl/markstrn.i tt-gds-act select-list }
  br-gds-act:refresh() in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
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
/*  DISPLAY                     */
/*      WITH FRAME Dialog-Frame.*/
  ENABLE b-cancel  b-save br-gds-act b-del b-mark b-sel-all b-unmark 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  
    if p-mode = {&lookup} then do :
        disable  tt-act-header.num tt-act-header.date_ with frame {&FRAME-NAME}.
        define variable hCol as handle no-undo .
        define variable hBr  as handle no-undo .
        define variable i    as integer no-undo .
        hBr = browse br-gds-act:handle .
        do i = 6 to 7 :
            hCol = hBr:GET-BROWSE-COLUMN(i). 
            hCol:read-only = true .   
        end.
        
        hide b-good b-save b-del b-alc-code in FRAME {&FRAME-NAME}.
    end.
    
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

