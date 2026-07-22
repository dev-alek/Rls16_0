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
define input parameter egais        as class ActBalance_shop no-undo .
define input parameter v-ext-sys    as integer no-undo .
define input parameter v-fs-rar     as character no-undo .
define input parameter bh-act-header  as handle no-undo .
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "ЕГАИС Акт постановки на баланс".

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
define variable v-RegID             as character no-undo .

define variable glog        as logical no-undo .

define variable v-obj-uniq-key-rec as character no-undo .

define variable sw as handle no-undo .

define variable v-file              as character no-undo initial "ActChargeOnShop1.xml".

define variable qh-gds-act          as handle no-undo .
define variable bh-gds-act          as handle no-undo .
define variable brh-gds-act         as handle no-undo .

define variable v-gds-uniq-key-rec as character no-undo .

define variable v-part-num    as integer   no-undo .
define variable v-clob-db-num as integer   no-undo .
define variable v-int64-id    as int64     no-undo .
define variable v-info        as character no-undo .

DEFINE VARIABLE hDoc AS HANDLE NO-UNDO.
DEFINE VARIABLE hRoot AS HANDLE NO-UNDO.
DEFINE VARIABLE good AS LOGICAL NO-UNDO.

define variable v-longchar      as memptr no-undo .

define buffer buf_goods         for ub.goods .
define buffer buf_parts         for ub.parts .
define buffer buf_trn-doc       for ub.trn-doc .
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
{ibs/th/bge/egais/ab-egais_shop.i }

define new shared temp-table tt-marks
    field num                 as character            label "№ акта"
    field gds-part-position_  as integer
    field mark                as character            label "Марка"          format "X(100)"
    field new_                as logical
    field gds-code            like ub.goods.gds-code  LABEL "Код товара"                 
    field gds-name            as character            LABEL "Наименование"   FORMAT "X(30)" 
    field alc-code            as character            LABEL "Алк. код"       FORMAT "X(20)"     
    field impor-full-name     as character            LABEL "Импортер"       FORMAT "X(130)" 
    field prod-full-name      as character            LABEL "Производитель"  FORMAT "X(130)" 
    field flag                as logical              label "T"
    field reserv              as integer              label "R"
    field parts               as character            label "Партия"         format "X(130)"
    index pi as primary unique
        mark
.

define buffer buf_tt-marks for tt-marks .

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
    menu-item m-goods   label "товары по свободной зоне"
    menu-item m-marks   label "по акцизным маркам"
    menu-item m-file    label "из файла"
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
    tt-gds-act.doc-code
/*    tt-gds-act.part-code*/
    tt-gds-act.gds-code
    tt-gds-act.alc-code
    tt-gds-act.gds-name
    tt-gds-act.qnty
  ENABLE
    tt-gds-act.qnty
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 107 BY 20.2 FIT-LAST-COLUMN.  

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
    b-cancel at row 1.2 col 2
    b-good at row 1.2 col 32
/*    b-marks at row 1.2 col 47*/
    b-alc-code at row 1.2 col 47
    b-del at row 1.2 col 67
    b-save at row 1.2 col 17
    tt-act-header.num at row 2.5 col 2 format "X(22)"
    tt-act-header.date_ at row 2.5 col 34
    tt-act-header.type_ at row 2.5 col 57
        view-as combo-box inner-lines 7
        list-items "Пересортица"
        DROP-DOWN-LIST
    b-mark AT ROW 4 COL 2
    b-sel-all AT ROW 4 COL 5
    b-unmark AT ROW 4 COL 8
    br-gds-act at row 5.2 col 2
     SPACE(0.5) SKIP(0.5)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Акт постановки товаров на баланс в торговом зале" WIDGET-ID 100.


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

&Scoped-define SELF-NAME tt-act-header.type_
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-act-header.type_ Dialog-Frame
ON VALUE-CHANGED OF tt-act-header.type_ IN FRAME Dialog-Frame /* cli-type */
DO:
  assign tt-act-header.type_.
  if tt-act-header.type_ = "Пересортица" then do :
      message "Выберите соответствующий акт о списании" view-as alert-box.
      run bge/egais-all-act-writeOff_shop.w (input parparentproc, input yes, output v-RegID ) .
      if v-RegID = ? or v-RegID = "" then do :
        tt-act-header.type_ = "Продукция полученная до 01.01.2016" .
        display tt-act-header.type_  with frame {&FRAME-NAME}.
        message "Акт постановки на баланс с типом 'Пересортица' невозможно отправить без указания соответствующего акта о списании!" view-as alert-box.
      end.
  end.
END.

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


&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save Dialog-Frame
ON CHOOSE OF b-save IN FRAME Dialog-Frame /* Создать */
DO:
    assign
        tt-act-header.num
        tt-act-header.date_
        tt-act-header.type_
    .
    find first tt-gds-act no-error .
    if not available tt-gds-act then do :
        message "В акте нет строк. Сохранение невозможно" view-as alert-box .
        return no-apply.
    end.
    run makeXML_v2 in this-procedure no-error.
    if error-status:error then return return-value .
    assign
        v-clob-db-num = ?
        v-int64-id = 0
        v-info = tt-act-header.num + {&delim-par} + string(tt-act-header.date_) + {&delim-par}
               + string(tt-act-header.is-sent) + {&delim-par} + tt-act-header.answer_ + {&delim-par} + tt-act-header.type_
    .
    find first buf_clob-bind exclusive-lock where buf_clob-bind.uniq-key-rec = tt-act-header.num
                                              and buf_clob-bind.field-name_  = {&lob-egais-ab_shop} no-error .
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
                  ,input {&lob-egais-ab_shop} /*p-field-*/
                  ,input v-info /*p-descr*/
                  ,input-output v-part-num
                  ,input {&lob-egais-ab_shop}
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
                  ,input {&lob-egais-ab_shop} /*p-field-*/
                  ,input v-info /*p-descr*/
                  ,input-output v-part-num
                  ,input {&lob-egais-ab_shop}
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
    output stream str-log to value("act-bal-shop_log.txt") append .
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
                                    and buf_parts.out-code = {&free-code} ,
        first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_parts.in-code :
            if buf_parts.qnty <= 0 then next _parts_ .
            assign nn = nn + 1 .                            
            create tt-gds-act.
            assign
                tt-gds-act.gds-code         = buf_goods.gds-code
                tt-gds-act.alc-code         = X_ext-classif.charkey_one
                tt-gds-act.gds-name         = buf_goods.gds-name
                tt-gds-act.doc-code         = buf_trn-doc.doc-code
                tt-gds-act.doc-date         = buf_trn-doc.fact-date
                tt-gds-act.num              = tt-act-header.num
                tt-gds-act.part-code        = buf_parts.part-code
                tt-gds-act.position_        = nn
                tt-gds-act.qnty             = buf_parts.qnty
            .
            find first X_ext-classif-attr no-lock where X_ext-classif-attr.classif-subject = X_ext-classif.classif-subject
                                                   and X_ext-classif-attr.classif-name = X_ext-classif.classif-name
                                                   and X_ext-classif-attr.db-num = X_ext-classif.db-num
                                                   and X_ext-classif-attr.Key#_One = X_ext-classif.key#_one
                                                   and X_ext-classif-attr.Key#_two = X_ext-classif.key#_two
                                                   and X_ext-classif-attr.Key#_three = X_ext-classif.key#_three
                                                   and X_ext-classif-attr.CharKey_One = X_eXt-classif.charkey_one
                                                   and X_ext-classif-attr.CharKey_two = X_eXt-classif.charkey_two
                                                   and X_ext-classif-attr.CharKey_three = X_eXt-classif.charkey_three
                                                   and X_ext-classif-attr.nonunique = X_eXt-classif.nonunique
                                                   and X_ext-classif-attr.attr-code = 'egais-info'
                                                   no-error .
            if available X_ext-classif-attr then assign tt-gds-act.egais-name = entry(3, X_ext-classif-attr.attr-value, CHR(4)) no-error.
        end.
    end.
    output stream str-log close .
    
    if err-good then do :
        message "Не все выбранные товары добавлены в акт. Смотрите лог-файл act-bal-shop_log.txt в рабочей директории" view-as alert-box .
    end.
    open QUERY br-gds-act FOR each tt-gds-act exclusive-lock .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m-marks
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-marks Dialog-Frame
on choose of menu-item m-marks in menu m-add 
DO:
    run bge/egais-ab-marks.w (parparentproc, tt-act-header.num, ?, "", 0, {&update}, input-output table tt-marks) .
    for each tt-marks exclusive-lock where tt-marks.gds-part-position_ = ? and tt-marks.num = tt-act-header.num :
        find first tt-gds-act exclusive-lock where tt-gds-act.alc-code = tt-marks.alc-code no-error .
        if not available tt-gds-act then do :
            find first X_ext-classif no-lock where X_ext-classif.classif-subject = {&table_goods} 
                                               and X_ext-classif.classif-name = {&extclass_goods_esys} 
                                               AND X_ext-classif.db-num = 0  
                                               and X_ext-classif.key#_two = v-ext-sys 
                                               and X_ext-classif.key#_three = 0
                                               and X_ext-classif.charkey_one = tt-marks.alc-code
                                               and X_eXt-classif.charkey_two = ""
                                               and X_eXt-classif.charkey_three = ""
                                               and X_eXt-classif.nonunique = 0
                                               .
            find first buf_goods no-lock where buf_goods.gds-code = X_ext-classif.key#_one .                                   
            nn = nn + 1 .
            create tt-gds-act .
            assign
                tt-gds-act.gds-code         = buf_goods.gds-code
                tt-gds-act.alc-code         = X_ext-classif.charkey_one
                tt-gds-act.gds-name         = buf_goods.gds-name
                tt-gds-act.num              = tt-act-header.num
                tt-gds-act.position_        = nn
            .
            find first X_ext-classif-attr no-lock where X_ext-classif-attr.classif-subject = X_ext-classif.classif-subject
                                                   and X_ext-classif-attr.classif-name = X_ext-classif.classif-name
                                                   and X_ext-classif-attr.db-num = X_ext-classif.db-num
                                                   and X_ext-classif-attr.Key#_One = X_ext-classif.key#_one
                                                   and X_ext-classif-attr.Key#_two = X_ext-classif.key#_two
                                                   and X_ext-classif-attr.Key#_three = X_ext-classif.key#_three
                                                   and X_ext-classif-attr.CharKey_One = X_eXt-classif.charkey_one
                                                   and X_ext-classif-attr.CharKey_two = X_eXt-classif.charkey_two
                                                   and X_ext-classif-attr.CharKey_three = X_eXt-classif.charkey_three
                                                   and X_ext-classif-attr.nonunique = X_eXt-classif.nonunique
                                                   and X_ext-classif-attr.attr-code = 'egais-info'
                                                   no-error .
            if available X_ext-classif-attr then assign tt-gds-act.egais-name = entry(3, X_ext-classif-attr.attr-value, CHR(4)) no-error.
        end.
        if not can-find(buf_tt-marks where buf_tt-marks.mark = tt-marks.mark 
                                       and buf_tt-marks.gds-part-position_ <> ?)
        then
        assign
            tt-marks.gds-part-position_ = tt-gds-act.position_   
            tt-gds-act.qnty             = tt-gds-act.qnty + 1
        . 
    end.
/*    if err-good then do :                                                                                                            */
/*        message "Не все выбранные товары добавлены в акт. Смотрите лог-файл act-bal_log.txt в рабочей директории" view-as alert-box .*/
/*    end.                                                                                                                             */
    open QUERY br-gds-act FOR each tt-gds-act exclusive-lock .
    apply "value-changed" to br-gds-act IN FRAME Dialog-Frame .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m-file
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-file Dialog-Frame
on choose of menu-item m-file in menu m-add 
DO:
    define variable ll_commit AS LOG    NO-UNDO INIT NO.
    define variable v-init-dir as character no-undo .
    DEFINE variable v_os-file   AS CHAR NO-UNDO INIT "".
    define variable v-line as character no-undo .
    define variable v-err AS LOG    NO-UNDO INIT NO.
    define variable v-user-action    as character no-undo.
    define variable v-printed        as logical   no-undo.
    
    SYSTEM-DIALOG GET-FILE v_os-file
        TITLE "Выберите файл для импорта"
        FILTERS
          " Текстовые файлы (*.csv) " "*.csv",
          " Текстовые файлы (*.txt) " "*.txt",
          " Все файлы (*.*) "                      "*.*"
        INITIAL-DIR v-init-dir
        /*return-to-start-dir*/
        must-exist
        update ll_commit
        default-extension "csv"
        .
    IF ll_commit <> YES THEN do:
       RETURN NO-APPLY.
    end.
    IF v_os-file = PROGRAM-NAME( 1 ) THEN DO:
        BELL.
        MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    
    input from value(v_os-file) .
        repeat :
            import unformatted v-line .
            nn = nn + 1 .  
            create tt-gds-act .
            assign
/*                tt-gds-act.gds-code         = buf_goods.gds-code*/
                tt-gds-act.alc-code         = entry(1, v-line, ";")
/*                tt-gds-act.gds-name         = buf_goods.gds-name*/
                tt-gds-act.num              = tt-act-header.num
                tt-gds-act.qnty             = integer(entry(2, v-line, ";"))
                tt-gds-act.position_        = nn
            .
            find first X_ext-classif no-lock where X_ext-classif.classif-subject = {&table_goods} 
                                               and X_ext-classif.classif-name = {&extclass_goods_esys} 
                                               AND X_ext-classif.db-num = 0  
                                               and X_ext-classif.key#_two = v-ext-sys 
                                               and X_ext-classif.key#_three = 0
                                               and X_eXt-classif.charkey_one = tt-gds-act.alc-code
                                               and X_eXt-classif.charkey_two = ""
                                               and X_eXt-classif.charkey_three = ""
                                               and X_eXt-classif.nonunique = 0 no-error .
            if available X_ext-classif
            then do :
                assign tt-gds-act.gds-code = X_ext-classif.key#_one .
                find first X_ext-classif-attr no-lock where X_ext-classif-attr.classif-subject = X_ext-classif.classif-subject
                                                       and X_ext-classif-attr.classif-name = X_ext-classif.classif-name
                                                       and X_ext-classif-attr.db-num = X_ext-classif.db-num
                                                       and X_ext-classif-attr.Key#_One = X_ext-classif.key#_one
                                                       and X_ext-classif-attr.Key#_two = X_ext-classif.key#_two
                                                       and X_ext-classif-attr.Key#_three = X_ext-classif.key#_three
                                                       and X_ext-classif-attr.CharKey_One = X_eXt-classif.charkey_one
                                                       and X_ext-classif-attr.CharKey_two = X_eXt-classif.charkey_two
                                                       and X_ext-classif-attr.CharKey_three = X_eXt-classif.charkey_three
                                                       and X_ext-classif-attr.nonunique = X_eXt-classif.nonunique
                                                       and X_ext-classif-attr.attr-code = 'egais-info'
                                                       no-error .
                if available X_ext-classif-attr then
                assign tt-gds-act.gds-name = entry(3, X_ext-classif-attr.attr-value, CHR(4)) no-error.
            end.
        end.
    input close .    
    
    output to value("alccodes-imp_log.txt") .
    for each tt-gds-act exclusive-lock where tt-gds-act.gds-code = 0 or tt-gds-act.gds-code = ? :
        v-err = true .
        put unformatted tt-gds-act.alc-code " - не найдено соответствие с товаром TH" skip .
        delete tt-gds-act .
    end.
    output close .
    
    if v-err then do :
        message "Не все строки добавлены в акт!" view-as alert-box .
        run gbl/prnfilen.w
           (input  "Ошибки при добавлении товаров"
           ,input  0
           ,input  "alccodes-imp_log.txt"
           ,input  7
           ,output v-user-action
           ,output v-printed
           ).
    end.
        
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
        tt-gds-act.alc-code         = X_ext-classif.charkey_one
        tt-gds-act.gds-name         = buf_goods.gds-name
        tt-gds-act.num              = tt-act-header.num
        tt-gds-act.position_        = nn
    .
    find first X_ext-classif-attr no-lock where X_ext-classif-attr.classif-subject = X_ext-classif.classif-subject
                                           and X_ext-classif-attr.classif-name = X_ext-classif.classif-name
                                           and X_ext-classif-attr.db-num = X_ext-classif.db-num
                                           and X_ext-classif-attr.Key#_One = X_ext-classif.key#_one
                                           and X_ext-classif-attr.Key#_two = X_ext-classif.key#_two
                                           and X_ext-classif-attr.Key#_three = X_ext-classif.key#_three
                                           and X_ext-classif-attr.CharKey_One = X_eXt-classif.charkey_one
                                           and X_ext-classif-attr.CharKey_two = X_eXt-classif.charkey_two
                                           and X_ext-classif-attr.CharKey_three = X_eXt-classif.charkey_three
                                           and X_ext-classif-attr.nonunique = X_eXt-classif.nonunique
                                           and X_ext-classif-attr.attr-code = 'egais-info'
                                           no-error .
    if available X_ext-classif-attr then assign tt-gds-act.egais-name = entry(3, X_ext-classif-attr.attr-value, CHR(4)) no-error.
    open QUERY br-gds-act FOR each tt-gds-act exclusive-lock .
    
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
    find first X_ext-classif-attr no-lock where X_ext-classif-attr.classif-subject = X_ext-classif.classif-subject
                                           and X_ext-classif-attr.classif-name = X_ext-classif.classif-name
                                           and X_ext-classif-attr.db-num = X_ext-classif.db-num
                                           and X_ext-classif-attr.Key#_One = X_ext-classif.key#_one
                                           and X_ext-classif-attr.Key#_two = X_ext-classif.key#_two
                                           and X_ext-classif-attr.Key#_three = X_ext-classif.key#_three
                                           and X_ext-classif-attr.CharKey_One = X_eXt-classif.charkey_one
                                           and X_ext-classif-attr.CharKey_two = X_eXt-classif.charkey_two
                                           and X_ext-classif-attr.CharKey_three = X_eXt-classif.charkey_three
                                           and X_ext-classif-attr.nonunique = X_eXt-classif.nonunique
                                           and X_ext-classif-attr.attr-code = 'egais-info'
                                           no-error .
    if available X_ext-classif-attr then assign tt-gds-act.egais-name = entry(3, X_ext-classif-attr.attr-value, CHR(4)) no-error.
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
    if exts > 1
    and not can-find(tt-marks where tt-marks.alc-code = tt-gds-act.alc-code)
    then enable b-alc-code WITH FRAME Dialog-Frame.
    else disable b-alc-code WITH FRAME Dialog-Frame.
end.
end.

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
        tt-act-header.type_:list-items = "Пересортица"
    .
    empty temp-table tt-exts .
    
    if p-mode = {&add-def} then do :
        v-date = substitute ("&1&2&3", string (day (now), "99"), string (month (now), "99"),substring (string(year (now)), 3,2)).        
        create tt-act-header .
        assign
            tt-act-header.num = "ACOS-" + v-date + '-' + substring(v-cntxt-obj-type,1,1) + string(v-cntxt-obj-code) + '-' + string(int(TIME))
            tt-act-header.date_ = TODAY
            tt-act-header.is-sent = no
            tt-act-header.type_ = "Пересортица"
        .
        display tt-act-header.num tt-act-header.date_ tt-act-header.type_ with frame {&FRAME-NAME}.
        enable  tt-act-header.date_ tt-act-header.type_ b-good with frame {&FRAME-NAME}.
/*        if egais:VerXSD = "2" then do :                          */
/*            display tt-act-header.type_ with frame {&FRAME-NAME}.*/
/*            enable  tt-act-header.type_ with frame {&FRAME-NAME}.*/
/*        end.                                                     */
/*        else hide tt-act-header.type_ in frame {&FRAME-NAME}.    */
    end.
    
    if p-mode = {&update} or p-mode = {&lookup} then do :
        find last buf_clob-bind where buf_clob-bind.uniq-key-rec = bh-act-header:buffer-field ("num"):buffer-value
                                  and buf_clob-bind.field-name_ = {&lob-egais-ab_shop} 
                                  and buf_clob-bind.part-num = 1  .
        find first buf_clob-data no-lock where buf_clob-data.db-num = buf_clob-bind.db-num and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
        copy-lob
        from  object buf_clob-data.cdata
        to  file 'temp.xml'
        no-convert
        no-error .
        empty temp-table tt-marks no-error .
        run parseXML in this-procedure .
        display tt-act-header.num tt-act-header.date_ tt-act-header.type_ with frame {&FRAME-NAME}.
        if p-mode = {&update} then enable  tt-act-header.type_ with frame {&FRAME-NAME}.
/*        if egais:VerXSD = "2" then do :                                                     */
/*            display tt-act-header.type_ with frame {&FRAME-NAME}.                           */
/*            if p-mode = {&update} then enable  tt-act-header.type_ with frame {&FRAME-NAME}.*/
/*        end.                                                                                */
/*        enable  tt-act-header.num tt-act-header.date_ with frame {&FRAME-NAME}.*/
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


procedure makeXML_v2 :
    create sax-writer sw .
    
    sw:formatted = true.
    sw:set-output-destination ("file", v-file).
    sw:encoding = "UTF-8".
    sw:start-document () .
    sw:start-element ("ns:Documents") .
    sw:insert-attribute ("Version", "2.0") .
    sw:insert-attribute ("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") .
    sw:insert-attribute ("xmlns:ns", "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01") .
    sw:insert-attribute ("xmlns:oref", "http://fsrar.ru/WEGAIS/ClientRef_v2") .
    sw:insert-attribute ("xmlns:pref", "http://fsrar.ru/WEGAIS/ProductRef_v2") .
    sw:insert-attribute ("xmlns:ainp", "http://fsrar.ru/WEGAIS/ActChargeOnShop_v2") .
    sw:insert-attribute ("xmlns:ce", "http://fsrar.ru/WEGAIS/CommonEnum") .
        sw:start-element ("ns:Owner") . 
            sw:write-data-element ("ns:FSRAR_ID", v-fs-rar) .
        sw:end-element ("ns:Owner") . 
        sw:start-element ("ns:Document") .
            sw:start-element ("ns:ActChargeOnShop_v2") .
                sw:write-data-element ("ainp:Identity", tt-act-header.num) .
                sw:start-element ("ainp:Header") .
                    sw:write-data-element ("ainp:Number", tt-act-header.num) .
                    sw:write-data-element ("ainp:ActDate", string(iso-date(tt-act-header.date_))) no-error .
                    sw:write-data-element ("ainp:Note", "Необходимо поставить товарные позиции на баланс") .
                    if tt-act-header.type_ <> "Продукция полученная до 01.01.2016"
                    then
                      sw:write-data-element ("ainp:TypeChargeOn", tt-act-header.type_) .
                    else
                      sw:write-data-element ("ainp:TypeChargeOn", "Продукция, полученная до 01.01.2016") .
                    if tt-act-header.type_ = "Пересортица" and v-RegID <> "" and v-RegID <> ? then do :
                      sw:write-data-element ("ainp:ActWriteOff", v-RegID) .  
                    end.
                sw:end-element ("ainp:Header") .
                sw:start-element ("ainp:Content") .
    for each tt-gds-act no-lock where tt-gds-act.num = tt-act-header.num :
        if tt-gds-act.qnty <= 0 then next. 
                    find first buf_goods no-lock where buf_goods.gds-code = tt-gds-act.gds-code .
                    sw:start-element ("ainp:Position") .
                        sw:write-data-element ("ainp:Identity", string(tt-gds-act.position_)) .
                        sw:start-element ("ainp:Product") .
                            sw:write-data-element ("pref:UnitType", (if buf_goods.unit-base <> buf_goods.unit-cli and buf_goods.cli-base-rate <> 1 then "Unpacked" else "Packed")) . 
                            sw:write-data-element ("pref:FullName", tt-gds-act.egais-name) no-error .
                            sw:write-data-element ("pref:ShortName", "") . 
                            sw:write-data-element ("pref:AlcCode", tt-gds-act.alc-code) .
                            if not (buf_goods.unit-base <> buf_goods.unit-cli and buf_goods.cli-base-rate <> 1)
                            then sw:write-data-element ("pref:Capacity", string(buf_goods.ms-base)) . 
                            sw:write-data-element ("pref:AlcVolume", string(buf_goods.proof)) . 
                            
                        for first ub.alc-type-gds where ub.alc-type-gds.gds-code = buf_goods.gds-code no-lock,
                            first ub.alc-type where ub.alc-type.alc-type-inner-code = ub.alc-type-gds.alc-type-inner-code no-lock :
                            sw:write-data-element ("pref:ProductVCode", string(ub.alc-type.alc-type-code)) .
                        end.
                        
                        find first X_ext-classif-attr no-lock where X_ext-classif-attr.classif-subject = {&table_goods}
                                                               and X_ext-classif-attr.classif-name = {&extclass_goods_esys}
                                                               and X_ext-classif-attr.db-num = 0
                                                               and X_ext-classif-attr.Key#_One = tt-gds-act.gds-code
                                                               and X_ext-classif-attr.Key#_two = v-ext-sys
                                                               and X_ext-classif-attr.Key#_three = 0
                                                               and X_ext-classif-attr.CharKey_One = tt-gds-act.alc-code
                                                               and X_ext-classif-attr.CharKey_two = ""
                                                               and X_ext-classif-attr.CharKey_three = ""
                                                               and X_ext-classif-attr.nonunique = 0
                                                               and X_ext-classif-attr.attr-code = 'egais-info'
                                                               no-error .                
                        if available X_ext-classif-attr and num-entries(X_ext-classif-attr.attr-value, CHR(4)) >= 3 then do : 
                          def var v-prod as char no-undo.
                          def var v-impor as char no-undo.
                          def var v-msg as char no-undo.
                          def var v-err as logical no-undo.
                          def var v-err-impor as logical no-undo.
                          v-err = false .
                          v-prod = ''.
                          v-impor = ''.
                          
                          
                          v-prod = entry (1, X_ext-classif-attr.attr-value, chr(4)) no-error.
                          if v-prod = ?
                          or v-prod = chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5)
                          or v-prod = ""
                          or num-entries (v-prod, chr (5)) < 8
                          or entry (7, v-prod, chr(5)) = "" 
                          then do:
                            message "У товара неизвестен производитель (или его тип) из ЕГАИС - " + string (tt-gds-act.gds-code) + ". Выполните синхронизацию товаров во второй версии XSD и  заново сохраните акт." view-as alert-box.
                            v-err = true .
                          end.
                          
/*                          v-impor = entry (2, X_ext-classif-attr.attr-value, chr(4)) no-error.                                                                                                                          */
/*                          if (num-entries (v-impor, chr (5)) > 0 and num-entries (v-impor, chr (5)) < 8)                                                                                                                */
/*                              or (trim(v-impor) <> "" and entry (7, v-impor, chr(5)) = "")                                                                                                                              */
/*                            then                                                                                                                                                                                        */
/*                          do:                                                                                                                                                                                           */
/*                            message "У товара неверно указан импортер из ЕГАИС - " + string (tt-gds-act.gds-code) + ". Выполните синхронизацию товаров во второй версии XSD и  заново сохраните акт." view-as alert-box.*/
/*                            v-err-impor = true .                                                                                                                                                                        */
/*                          end.                                                                                                                                                                                          */
                          
                          if not v-err then do :
                            sw:start-element ("pref:Producer") .
                             sw:start-element ("oref:" + entry (7, v-prod, chr(5))) .
                              if entry (7, v-prod, chr(5)) <> "TS" then do :
                                  if entry (2, v-prod, chr(5)) <> "" then sw:write-data-element ("oref:INN", entry (2, v-prod, chr(5)) ).
                                  if entry (3, v-prod, chr(5)) <> "" then sw:write-data-element ("oref:KPP", entry (3, v-prod, chr(5)) ).
                              end.
                              else if entry (2, v-prod, chr(5)) <> "" then sw:write-data-element ("oref:TSNUM", entry (2, v-prod, chr(5)) ).
                              sw:write-data-element ("oref:ClientRegId", entry (1, v-prod, chr(5)) ).
                              sw:write-data-element ("oref:FullName", entry (4, v-prod, chr(5)) ).
                              sw:start-element ("oref:address").
                                sw:write-data-element ("oref:Country", entry (5, v-prod, chr(5)) ).
                                if entry (8, v-prod, chr(5)) <> "" then sw:write-data-element ("oref:RegionCode", entry (8, v-prod, chr(5)) ).
                                sw:write-data-element ("oref:description", entry (6, v-prod, chr(5)) ).
                              sw:end-element ("oref:address").
                             sw:end-element ("oref:" + entry (7, v-prod, chr(5))) .
                            sw:end-element ("pref:Producer") .
                          end.
                          
/*                          if not v-err-impor then do :                                                                                            */
/*                            if trim(v-impor) <> ""                                                                                                */
/*                            and v-impor <> ?                                                                                                      */
/*                            and v-impor <> chr(5) + chr(5) + chr(5) + chr(5) + chr(5)                                                             */
/*                            and v-impor <> chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) then do:                                  */
/*                              sw:start-element ("pref:Importer") .                                                                                */
/*                               sw:start-element ("oref:" + entry (7, v-impor, chr(5))) .                                                          */
/*                                if entry (2, v-impor, chr(5)) <> "" then sw:write-data-element ("oref:INN", entry (2, v-impor, chr(5)) ).         */
/*                                if entry (3, v-impor, chr(5)) <> "" then sw:write-data-element ("oref:KPP", entry (3, v-impor, chr(5)) ).         */
/*                                sw:write-data-element ("oref:ClientRegId", entry (1, v-impor, chr(5)) ).                                          */
/*                                sw:write-data-element ("oref:FullName", entry (4, v-impor, chr(5)) ).                                             */
/*                                sw:start-element ("oref:address").                                                                                */
/*                                  sw:write-data-element ("oref:Country", entry (5, v-impor, chr(5)) ).                                            */
/*                                  if entry (8, v-impor, chr(5)) <> "" then sw:write-data-element ("oref:RegionCode", entry (8, v-impor, chr(5)) ).*/
/*                                  sw:write-data-element ("oref:description", entry (6, v-impor, chr(5)) ).                                        */
/*                                sw:end-element ("oref:address").                                                                                  */
/*                               sw:end-element ("oref:" + entry (7, v-impor, chr(5))) .                                                            */
/*                              sw:end-element ("pref:Importer") .                                                                                  */
/*                            end.                                                                                                                  */
/*                          end.                                                                                                                    */

                        end.
                        else do:
                          message "У товара неизвестен производитель из ЕГАИС - " + string (tt-gds-act.gds-code) + ". Выполните синхронизацию товаров и  заново сохраните акт." view-as alert-box.
                        end.
                        
                        sw:end-element ("ainp:Product") .
                        sw:write-data-element ("ainp:Quantity", string(tt-gds-act.qnty)) .
                    sw:end-element ("ainp:Position") .                
    end. 
                sw:end-element ("ainp:Content") .
            sw:end-element ("ns:ActChargeOnShop_v2") .
        sw:end-element ("ns:Document") .
    sw:end-element ("ns:Documents") .
    sw:end-document () .
    delete object sw.
    
end procedure .

procedure parseXML :
    empty temp-table tt-act-header .
    empty temp-table tt-gds-act .
    
    CREATE X-DOCUMENT hDoc.
    CREATE X-NODEREF hRoot.
   
    hDoc:encoding = 'utf-8'.
    hDoc:LOAD("file", search("temp.xml"),FALSE).
   
    hDoc:GET-DOCUMENT-ELEMENT(hRoot).
    
    RUN GetChildren(hRoot, 1).

    DELETE OBJECT hDoc.
    DELETE OBJECT hRoot.    
end procedure .

procedure GetChildren :
    DEFINE INPUT PARAMETER hParent AS HANDLE NO-UNDO.
    DEFINE INPUT PARAMETER level AS INTEGER NO-UNDO.
        
    DEFINE VARIABLE i AS INTEGER NO-UNDO.
    DEFINE VARIABLE hNoderef AS HANDLE NO-UNDO.
    DEFINE VARIABLE hText AS HANDLE NO-UNDO.
    
    CREATE X-NODEREF hNoderef.
    CREATE X-NODEREF hText .
    
    
    REPEAT i = 1 TO hParent:NUM-CHILDREN:
        good = hParent:GET-CHILD(hNoderef,i).
        IF NOT good THEN 
            LEAVE.
        IF hNoderef:SUBTYPE <> "element" THEN
            NEXT.
        
        hNoderef:GET-CHILD(hText, 1) no-error .    
        
/*        IF hNoderef:NAME = "ns:FSRAR_ID" THEN   */
/*            assign v-FS-RAR = hText:node-value .*/
        IF hNoderef:NAME = "ain:Header" or hNoderef:NAME = "ainp:Header" THEN do :
            create tt-act-header .
            assign tt-act-header.is-sent = bh-act-header:buffer-field("is-sent"):buffer-value .
        end .
        .
        IF hNoderef:NAME = "ain:Number"
        OR hNoderef:NAME = "ainp:Number" THEN assign tt-act-header.num    = hText:node-value no-error .
        IF hNoderef:NAME = "ain:ActDate"
        OR hNoderef:NAME = "ainp:ActDate" THEN 
            assign tt-act-header.date_ = date(substring(hText:node-value, 9, 2) + "/" + substring(hText:node-value, 6, 2) + "/" + substring(hText:node-value, 1, 4)) no-error .    
        
        IF hNoderef:NAME = "ainp:TypeChargeOn" THEN do :
            assign tt-act-header.type_    = hText:node-value no-error .
            if tt-act-header.type_ = "Продукция, полученная до 01.01.2016" then tt-act-header.type_ = "Продукция полученная до 01.01.2016" .
        end.
        
        IF hNoderef:NAME = "ainp:ActWriteOff" THEN assign v-RegID    = hText:node-value no-error .
            
        IF hNoderef:NAME = "ain:Position"
        OR hNoderef:NAME = "ainp:Position" THEN do :
            assign ii = 0 .
            create tt-gds-act .
            assign tt-gds-act.num = tt-act-header.num .
        end.
        IF hNoderef:NAME = "ain:Identity"
        OR hNoderef:NAME = "ainp:Identity" THEN assign tt-gds-act.position_ = integer(hText:node-value) no-error .
        IF hNoderef:NAME = "pref:FullName" THEN assign tt-gds-act.egais-name = hText:node-value no-error .   
        IF hNoderef:NAME = "pref:AlcCode" THEN do :
            assign tt-gds-act.alc-code = hText:node-value no-error .
            find first X_ext-classif no-lock where X_ext-classif.classif-subject = {&table_goods} 
                                               and X_ext-classif.classif-name = {&extclass_goods_esys} 
                                               AND X_ext-classif.db-num = 0  
                                               and X_ext-classif.key#_two = v-ext-sys 
                                               and X_ext-classif.key#_three = 0
                                               and X_ext-classif.charkey_one = tt-gds-act.alc-code
                                               and X_eXt-classif.charkey_two = ""
                                               and X_eXt-classif.charkey_three = ""
                                               and X_eXt-classif.nonunique = 0
                                               no-error. 
            if available X_ext-classif then do :
                find first buf_goods no-lock where buf_goods.gds-code = X_ext-classif.key#_one .
                assign
                    tt-gds-act.gds-code = buf_goods.gds-code
                    tt-gds-act.gds-name = buf_goods.gds-name
                .
                find first X_ext-classif-attr no-lock where X_ext-classif-attr.classif-subject = X_ext-classif.classif-subject
                                                       and X_ext-classif-attr.classif-name = X_ext-classif.classif-name
                                                       and X_ext-classif-attr.db-num = X_ext-classif.db-num
                                                       and X_ext-classif-attr.Key#_One = X_ext-classif.key#_one
                                                       and X_ext-classif-attr.Key#_two = X_ext-classif.key#_two
                                                       and X_ext-classif-attr.Key#_three = X_ext-classif.key#_three
                                                       and X_ext-classif-attr.CharKey_One = X_eXt-classif.charkey_one
                                                       and X_ext-classif-attr.CharKey_two = X_eXt-classif.charkey_two
                                                       and X_ext-classif-attr.CharKey_three = X_eXt-classif.charkey_three
                                                       and X_ext-classif-attr.nonunique = X_eXt-classif.nonunique
                                                       and X_ext-classif-attr.attr-code = 'egais-info'
                                                       no-error .
                if available X_ext-classif-attr then assign tt-gds-act.egais-name = entry(3, X_ext-classif-attr.attr-value, CHR(4)) no-error.    
            end.
                        

        end. 
        IF hNoderef:NAME = "ain:Quantity"
        OR hNoderef:NAME = "ainp:Quantity" THEN assign tt-gds-act.qnty = decimal(hText:node-value) no-error . 
        
        run GetChildren (hNoderef, (level + 1)).
        
    END.
    
    DELETE OBJECT hNoderef.
    DELETE OBJECT hText.
END procedure.

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
        disable  tt-act-header.num tt-act-header.date_ tt-act-header.type_ with frame {&FRAME-NAME}.
        define variable hCol as handle no-undo .
        define variable hBr  as handle no-undo .
        hBr = browse br-gds-act:handle .
        hCol = hBr:GET-BROWSE-COLUMN(7). 
        hCol:read-only = true .   
        
        hide b-good  b-save b-del b-alc-code in FRAME {&FRAME-NAME}.
    end.
    
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

