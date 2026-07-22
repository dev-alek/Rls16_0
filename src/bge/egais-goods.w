&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

  File: bge/egais-goods.w

  Description: Настройки объектов ЕГАИС

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: Slivenko Sergey

  Created: 16.11.2015
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
define variable vss-description as character no-undo init "Настройки объектов ЕГАИС".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/thbjattr.i }
{ gbl/clntattr.i }
{ gbl/color.i    }
{ ref/extclass.i }
{ gbl/key-rec.i  }
{ gbl/attr-lib.i }
{ ref/gds-attr.i }

define temp-table tt-gds no-undo
    field gds-code          like ub.goods.gds-code          label "Код товара в TH"
    field gds-name          like ub.goods.gds-name          label "Полное наименование" format "X(100)"
    field alc-code          as character                    label "Алкогольный код"
    field ms-base           like ub.goods.ms-base           label "Объем"               format ">>>9.9<<"
    field alc-type-code     like ub.alc-type.alc-type-code  label "Код АП"
    field proof             like ub.goods.proof             label "Крепость"            format ">9.9"    
    field fromEgais         as logical
    field egais-name        as character                    label "Наименование ЕГАИС"  format "X(100)"
    field prod-info         as character
    field imp-info          as character
    field old-gds-code      like ub.goods.gds-code
    field old-alc-code      as character
    index pi as primary
        gds-code
    index name_ as word-index
        gds-name
    index alc
        alc-code    
.    

define buffer old_tt-gds for tt-gds .
define buffer buf_tt-gds for tt-gds .
define buffer buf2_tt-gds for tt-gds .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

def var egais as class EGAIS.
def var extGdsObj as class ExtGds.
def var numBundles as integer no-undo .

def var bh-gds-egais as handle no-undo .
def var qh-gds-egais as handle no-undo .


define buffer buf_firm for ub.firm .
define buffer buf_clients for ub.clients .
define buffer buf_clients-attr for ub.clients-attr .
define buffer buf_goods for ub.goods .
define buffer buf_goods-attr for ub.goods-attr .
DEFINE BUFFER X_ext-classif FOR ub.ext-classif.
DEFINE BUFFER XX_ext-classif FOR ub.ext-classif.
DEFINE BUFFER X_ext-classif-attr FOR ub.ext-classif-attr.
DEFINE BUFFER XX_ext-classif-attr FOR ub.ext-classif-attr.

define variable select-list as longchar no-undo .
define variable ref-list    as character no-undo .
define variable ii          as integer   no-undo .
define variable v-rid       as recid     no-undo .
define variable par-alcohol as character no-undo .
define variable par-egais-name as character no-undo .
define variable par-type    as character no-undo .
define variable v-kpp       as character no-undo .
define variable v-org-inn   as character no-undo .
define variable v-isSent    as logical   no-undo .
define variable v-outId     as character no-undo .
define variable v-ext-sys   as integer   no-undo .
define variable v-replyId   as character no-undo .
define variable v-alc-code  as character no-undo .
define variable entry7      as character no-undo .
define variable entry8      as character no-undo .

define variable glog        as logical no-undo .

define variable v-gds-uniq-key-rec as character no-undo .

define variable saved as logical no-undo initial no .

define variable gds-rec as recid no-undo .

define variable v-value-character  as character no-undo .
define variable v-value-decimal    as decimal   no-undo .
define variable v-value-integer    as integer   no-undo .
define variable v-value-logical    as logical   no-undo .
define variable v-value-type       as character no-undo .
define variable v-value-date       as date      no-undo .

define variable v-org as character no-undo .
define variable v-fs-rar as character no-undo .

FUNCTION get-mark RETURNS CHARACTER
(buffer local-gds for tt-gds ):
if lookup (string (recid (local-gds)), select-list) > 0  then return "*".
                                                           else return "".
end function.



&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-goods

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-objs

/* Definitions for BROWSE br-goods                                    */
&Scoped-define SELF-NAME br-goods
&Scoped-define QUERY-STRING-br-goods FOR EACH tt-gds
&Scoped-define OPEN-QUERY-br-goods OPEN QUERY {&SELF-NAME} FOR EACH tt-gds.
&Scoped-define TABLES-IN-QUERY-br-goods tt-gds
&Scoped-define FIRST-TABLE-IN-QUERY-br-goods tt-gds


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-goods}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-load b-cancel br-goods 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */

define variable v-prod as character no-undo view-as text format "X(11)" label "Производитель" .
define variable v-prod-name as character no-undo view-as text format "X(30)" .

define variable letter as character no-undo .
Define variable NameContext as character view-as fill-in size 30 by 1 fgcolor 12 no-undo .
Define variable NameContext2 as character no-undo initial "" .

DEFINE BUTTON b-mark 
     LABEL "&*" 
     SIZE 3 BY 1.14 .
     
DEFINE BUTTON b-cancel AUTO-END-KEY 
     LABEL "Выход" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .

DEFINE BUTTON b-load 
     LABEL "Запрос" 
     tooltip "Отправить запрос в ЕГАИС"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
     
DEFINE BUTTON b-save 
     LABEL "Сохранить" 
     tooltip "Записать данные в справочник"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
     
DEFINE BUTTON b-answer 
     LABEL "Получить ответ" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .   
     
DEFINE BUTTON b-lkp 
     LABEL "Просмотр" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .
     
DEFINE BUTTON b-good 
     LABEL "Товар" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .
     
DEFINE BUTTON b-connect 
     LABEL "Связать" 
     SIZE 13 BY 1.14
     BGCOLOR 8 . 
     
DEFINE BUTTON b-sel-all
     LABEL "&+":L
     SIZE 3 BY 1.14 TOOLTIP "Отметить все объекты".

DEFINE BUTTON b-unmark
     LABEL "&-":L
     SIZE 3 BY 1.14 TOOLTIP "Снять все отметки". 
     
DEFINE BUTTON b-prod
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY 1.14 TOOLTIP "Выбор производителя".               

DEFINE VARIABLE rs-sort AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
        "&названию", 1,
        "&коду в TH", 2,
        "&алк. коду", 3
     SIZE 40 BY 1.14 NO-UNDO.
     
DEFINE VARIABLE rs-mode AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
        "&изменить", 1,
        "&добавить", 2
     SIZE 10 BY 2 TOOLTIP "ИЗМЕНЕНИЕ - если есть алкогольный код, заменяет его на новый, если нет - создает. ДОБАВЛЕНИЕ - добавляет алкогольный код к уже существующим" NO-UNDO .
 
 
 define rectangle rect1 edge-pixels 3 graphic-edge no-fill size-chars 13.3 by 3.5 .
     
/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-goods FOR 
      tt-gds SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-goods Dialog-Frame _FREEFORM
  QUERY br-goods  DISPLAY
    get-mark(BUFFER tt-gds) COLUMN-LABEL "*"  FORMAT "X(1)":U
    tt-gds.gds-code COLUMN-LABEL "Код товара в TH" FORMAT ">>>>>>>>9"
    tt-gds.gds-name COLUMN-LABEL "Наименование товара" FORMAT "X(100)":U width 38
    tt-gds.alc-code COLUMN-LABEL "Алкогольный код" FORMAT "X(25)":U 
    tt-gds.ms-base  COLUMN-LABEL "Объем" FORMAT ">>>9.9<<"
    tt-gds.proof    COLUMN-LABEL "Крепость" FORMAT ">9.9"
    tt-gds.alc-type-code COLUMN-LABEL "Код АП" FORMAT "X(4)":U
    tt-gds.egais-name COLUMN-LABEL "Наименование в ЕГАИС" FORMAT "X(100)":U width 39
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 105 BY 20.2 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-mark AT ROW 2.5 COL 2
     b-sel-all AT ROW 2.5 COL 5
     b-unmark AT ROW 2.5 COL 8
     b-load AT ROW 1.24 COL 32
     b-answer AT ROW 1.24 COL 47
     b-save AT ROW 1.24 COL 17
     b-lkp AT ROW 1.24 COL 62
     b-good AT ROW 1.24 COL 77
     b-cancel AT ROW 1.24 COL 2
     v-prod AT ROW 2.7 COL 13
     b-prod AT ROW 2.5 COL 40
     v-prod-name AT ROW 2.7 COL 45 no-label
     "Сортировать по:" VIEW-AS TEXT
          SIZE 15 BY 1.14 AT ROW 3.6 COL 2 WIDGET-ID 18
     rs-sort AT ROW 3.6 COL 18 no-label 
     rs-mode at row 2.5 col 93 no-label 
     rect1 at row 1.2 col 91.9
     b-connect AT ROW 1.24 COL 92
     NameContext at row 4.6 col 2 label "Нач. слова"
     br-goods AT ROW 5.8 COL 2 WIDGET-ID 200
     SPACE(1) SKIP(0.32)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Алкогольная продукция ЕГАИС"
         DEFAULT-BUTTON b-load CANCEL-BUTTON b-cancel WIDGET-ID 100.

assign br-goods:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame = 1 .

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
/* BROWSE-TAB br-goods b-cancel Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-goods
/* Query rebuild information for BROWSE br-goods
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-gds.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-goods */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

ON return OF NameContext IN FRAME {&frame-name} do:
    assign NameContext.
    if NameContext = "" then NameContext2 = "" .
    else do :
        letter = substring(NameContext, length(NameContext), 1) .
        if letter = 'н'
        or letter = 'о'
        or letter = 'э'
        or letter = 'ю'
        or letter = 'я'
        then NameContext2 = trim(NameContext).
        else NameContext2 = trim(NameContext) + "*" .
    end.    
    run refresh-query in this-procedure.
end.

on F9 of frame {&frame-name} anywhere do:
  if not available tt-gds then  return no-apply.
  if tt-gds.gds-code = 0  then  return no-apply.
  find first goods no-lock where goods.gds-code = tt-gds.gds-code .
  gds-rec = recid(goods) .
  run ref/gds-form.w
    (input  parParentProc
    ,input  {&update}
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input ? /*p-call-handle*/
    ,input-output gds-rec
    ).

/*  apply "entry" to spec-List in frame {&frame-name}.*/
/*  return no-apply.                                  */
end.

&Scoped-define SELF-NAME b-good
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-good Dialog-Frame
ON CHOOSE OF b-good IN FRAME Dialog-Frame /* * */
DO:
    apply "F9" to frame Dialog-Frame .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Объекты ЕГАИС */
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
  if not available tt-gds then return.
  for each tt-gds no-lock :
    { gbl/markstrn.i tt-gds select-list }
  end.
  {&browse-name}:refresh() in frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-unmark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-unmark Dialog-Frame
ON CHOOSE OF b-unmark IN FRAME Dialog-Frame /* - */
DO:
  if not available tt-gds then return.
  select-list  = "".
  {&browse-name}:refresh() in frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cancel Dialog-Frame
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame /* - */
DO:
    message "Все несохранённые данные будут потеряны. Вы уверены, что хотите выйти?"
    view-as alert-box question buttons yes-no update glog.
    if not glog then return no-apply . 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-prod
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prod Dialog-Frame
ON CHOOSE OF b-prod IN FRAME Dialog-Frame /* - */
DO:
    run sel-prod in this-procedure .
    assign
      rs-sort
    .
    run refresh-query in this-procedure.   
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME rs-sort
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-sort Dialog-Frame
ON VALUE-CHANGED OF rs-sort IN FRAME Dialog-Frame
DO:
  assign
    rs-sort
  .
  run refresh-query in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME rs-mode
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-mode Dialog-Frame
ON VALUE-CHANGED OF rs-mode IN FRAME Dialog-Frame
DO:
  assign
    rs-mode
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-connect
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-connect Dialog-Frame
ON CHOOSE OF b-connect IN FRAME Dialog-Frame /* - */
DO:
    if not available tt-gds then return no-apply.
    assign v-rid = recid(tt-gds) .
/*    if tt-gds.gds-code = ? or tt-gds.gds-code = 0 then do :*/
    if tt-gds.fromEgais then do :
        run ref/gds-ref.p (parparentproc, 'b-sel,b-add', ?, ?, ?, ?, ?, ?, ?, v-cntxt-obj-type, v-cntxt-obj-code, ?, output ref-list) no-error.
        if error-status:error or ref-list = ? or ref-list = "" then 
        do:
            message "Ошибка при выборе товара." view-as alert-box.
            return no-apply.
        end.
        find first buf_goods where recid(buf_goods) = integer(ref-list) no-error.
        if tt-gds.gds-code = 0 or tt-gds.gds-code = ? or rs-mode = 1 then do :
            assign
                tt-gds.gds-code = buf_goods.gds-code
                tt-gds.gds-name = buf_goods.gds-name
                tt-gds.ms-base  = buf_goods.ms-base
                tt-gds.proof    = buf_goods.proof
            .
        end.
        else do : /* rs-mode = 2 */
            find first buf_tt-gds no-lock where buf_tt-gds.gds-code = buf_goods.gds-code
                                            and buf_tt-gds.alc-code = tt-gds.alc-code
                                            and recid(buf_tt-gds) <> recid(tt-gds) no-error .
            if not available buf_tt-gds then do :
                create buf2_tt-gds .
                buffer-copy tt-gds except gds-code gds-name ms-base proof old-gds-code to buf2_tt-gds
                    assign
                        buf2_tt-gds.gds-code = buf_goods.gds-code
                        buf2_tt-gds.gds-name = buf_goods.gds-name
                        buf2_tt-gds.ms-base  = buf_goods.ms-base
                        buf2_tt-gds.proof    = buf_goods.proof
                .
            end. 
        end.
    end.
    else do :
        run bge/egais-select-good.w (input tt-gds.ms-base
                                    ,input tt-gds.proof
                                    ,input tt-gds.alc-type-code
                                    ,input bh-gds-egais:handle
                                    ,output v-alc-code) .
        if v-alc-code <> "" and v-alc-code <> ? then do :
            if tt-gds.alc-code = "" or tt-gds.alc-code = ? then assign tt-gds.alc-code = v-alc-code .
            else do :
                if rs-mode = 1 then assign tt-gds.alc-code = v-alc-code .
                if rs-mode = 2 then do :
                    find first buf_tt-gds no-lock where buf_tt-gds.gds-code = tt-gds.gds-code
                                                    and buf_tt-gds.alc-code = v-alc-code
                                                    and recid(buf_tt-gds) <> recid(tt-gds) no-error .
                    if not available buf_tt-gds then do :
                        create buf2_tt-gds .
                        buffer-copy tt-gds except alc-code old-alc-code to buf2_tt-gds
                            assign buf2_tt-gds.alc-code = v-alc-code
                        .
                    end.     
                end.
            end.    
        end.
    end.
    run refresh-query in this-procedure.
    reposition br-goods to recid v-rid .  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save Dialog-Frame
ON CHOOSE OF b-save IN FRAME Dialog-Frame /* - */
DO:
    if select-list = "" then do :
        message "Не выбрано ни одной строки" view-as alert-box .
        return no-apply.
    end. 
    if not valid-handle(bh-gds-egais)
    then do :
        message "Сначала получите ответ из ЕГАИС" view-as alert-box .
        return no-apply.
    end.
    if valid-handle(bh-gds-egais)
    then do :
        bh-gds-egais:find-first () no-error.
        if not bh-gds-egais:available
        then do :
            message "По данному производителю (ИНН) ответ из ЕГАИС не содержит позиций" view-as alert-box .
            return no-apply.
        end.
    end.
    _ii_ :  
    do ii = 1 to num-entries(select-list) :
        def var v-i-element as character no-undo.
        v-i-element = (entry(ii, select-list)).
        for first tt-gds exclusive-lock where recid(tt-gds) = integer(v-i-element) and tt-gds.gds-code > 0 :
            if tt-gds.alc-code <> "" and tt-gds.alc-code <> ? then do :
                bh-gds-egais:find-unique (substitute("where trim(tt-gds-EG.alc-code) = '&1'", trim(tt-gds.alc-code)), no-lock) no-error.
            end.
            else do :
                bh-gds-egais:find-unique (substitute("where trim(tt-gds-EG.gds-name) = '&1'", trim(tt-gds.gds-name)), no-lock) no-error.
            end.
            if bh-gds-egais:available and not bh-gds-egais:ambiguous and tt-gds.alc-code <> "" then do transaction :
                if tt-gds.alc-type-code <> bh-gds-egais:buffer-field("alc-type-code"):buffer-value then do :                        
                    find first ub.alc-type no-lock
                         where ub.alc-type.alc-type-code = trim(bh-gds-egais:buffer-field("alc-type-code"):buffer-value) no-error .
                    if available ub.alc-type then do :
                        find first ub.alc-type-gds 
                             where ub.alc-type-gds.gds-code = tt-gds.gds-code
                               and ub.alc-type-gds.create-user-db-num = 0 EXCLUSIVE-LOCK no-error. 
                        if not available ub.alc-type-gds then do :
                            create ub.alc-type-gds.       
                        end.
                        assign
                            ub.alc-type-gds.gds-code            = tt-gds.gds-code
                            ub.alc-type-gds.alc-type-inner-code = ub.alc-type.alc-type-inner-code
                            ub.alc-type-gds.create-user-db-num  = 0
                        .
                    end.
                end.    
/*                buffer tt-gds:handle:buffer-copy (bh-gds-egais, "gds-code, gds-name, ms-base, proof") .*/
                assign
                    tt-gds.egais-name = bh-gds-egais:buffer-field("gds-name"):buffer-value
                    tt-gds.imp-info   = bh-gds-egais:buffer-field("imp-info"):buffer-value
                    tt-gds.prod-info   = bh-gds-egais:buffer-field("prod-info"):buffer-value
                .
                if tt-gds.old-gds-code = 0 or tt-gds.old-gds-code = ? then tt-gds.old-gds-code = tt-gds.gds-code .
                if tt-gds.old-alc-code = "" or tt-gds.old-alc-code = ? then tt-gds.old-alc-code = tt-gds.alc-code .
                for first buf_goods no-lock where buf_goods.gds-code = tt-gds.gds-code :
/*                    run gds-attr-write(    */
/*                        buf_goods.gds-code,*/
/*                        {&attr-egais-name},*/
/*                        tt-gds.egais-name  */
/*                    ).                     */
/*                    assign                                  */
/*                        buf_goods.gds-name = tt-gds.gds-name*/
/*                        buf_goods.ms-base  = tt-gds.ms-base */
/*                        buf_goods.proof    = tt-gds.proof   */
/*                    .                                       */
                    
                    run gen-key-rec IN THIS-PROCEDURE (  input {&table_goods}
                                                        ,input (buffer buf_goods:handle)
                                                        ,output v-gds-uniq-key-rec).
                    find first X_ext-classif exclusive-lock  where X_ext-classif.classif-subject = {&table_goods} 
                                                               and X_ext-classif.classif-name = {&extclass_goods_esys} 
                                                               AND X_ext-classif.db-num = 0  
                                                               and X_ext-classif.key#_one = tt-gds.old-gds-code
                                                               and X_ext-classif.key#_two = v-ext-sys 
                                                               and X_ext-classif.key#_three = 0
/*                                                               and X_eXt-classif.uniq-key-rec = v-gds-uniq-key-rec*/
                                                               and X_eXt-classif.charkey_one = tt-gds.old-alc-code
                                                               and X_eXt-classif.charkey_two = ""
                                                               and X_eXt-classif.charkey_three = ""
                                                               and X_eXt-classif.nonunique = 0
                                                               no-error. 
                    if available X_ext-classif then do :    
                        find first X_ext-classif-attr exclusive-lock where X_ext-classif-attr.classif-subject = X_ext-classif.classif-subject
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
                        if not available X_ext-classif-attr then do :
                            create X_ext-classif-attr .
                            assign
                                X_ext-classif-attr.classif-subject = X_ext-classif.classif-subject
                                X_ext-classif-attr.classif-name = X_ext-classif.classif-name
                                X_ext-classif-attr.db-num = X_ext-classif.db-num
                                X_ext-classif-attr.Key#_One = X_ext-classif.key#_one
                                X_ext-classif-attr.Key#_two = X_ext-classif.key#_two
                                X_ext-classif-attr.Key#_three = X_ext-classif.key#_three
                                X_ext-classif-attr.CharKey_One = X_eXt-classif.charkey_one
                                X_ext-classif-attr.CharKey_two = X_eXt-classif.charkey_two
                                X_ext-classif-attr.CharKey_three = X_eXt-classif.charkey_three
                                X_ext-classif-attr.nonunique = X_eXt-classif.nonunique
                                X_ext-classif-attr.attr-code = 'egais-info' 
                            .       
                        end.
                        else do :
                            if tt-gds.imp-info = ? or tt-gds.imp-info = ""
                            or tt-gds.imp-info = chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5)
                            or tt-gds.imp-info = chr(5) + chr(5) + chr(5) + chr(5) + chr(5)
                            then
                            tt-gds.imp-info = entry(2, X_ext-classif-attr.attr-value, CHR(4)) no-error .
                            
                            if tt-gds.imp-info = ? or tt-gds.imp-info = ""
                            then tt-gds.imp-info = chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) .
                            
                            if num-entries(tt-gds.imp-info, CHR(5)) = 6
                            then tt-gds.imp-info = tt-gds.imp-info + chr(5) + chr(5) .
                            
                            if num-entries(entry(2, X_ext-classif-attr.attr-value, CHR(4)), CHR(5)) > 6
                            then entry7 = entry (7, entry(2, X_ext-classif-attr.attr-value, CHR(4)), chr(5)) no-error .
                            else entry7 = "" .
                            
                            if entry (7, tt-gds.imp-info, chr(5)) = ? or entry (7, tt-gds.imp-info, chr(5)) = ""
                            then entry (7, tt-gds.imp-info, chr(5)) = entry7 no-error.
                            
                            if num-entries(entry(1, X_ext-classif-attr.attr-value, CHR(4)), CHR(5)) > 6
                            then entry7 = entry (7, entry(1, X_ext-classif-attr.attr-value, CHR(4)), chr(5)) no-error .
                            else entry7 = "" .
                            
                            if entry (7, tt-gds.prod-info, chr(5)) = ? or entry (7, tt-gds.prod-info, chr(5)) = ""
                            then entry (7, tt-gds.prod-info, chr(5)) = entry7 no-error.
                            
                            if num-entries(entry(1, X_ext-classif-attr.attr-value, CHR(4)), CHR(5)) > 6
                            then entry8 = entry (8, entry(1, X_ext-classif-attr.attr-value, CHR(4)), chr(5)) no-error .
                            else entry8 = "" .
                            
                            if entry (8, tt-gds.prod-info, chr(5)) = ? or entry (8, tt-gds.prod-info, chr(5)) = ""
                            then entry (8, tt-gds.prod-info, chr(5)) = entry8 no-error.
                        end.
                        
                        assign
                            X_ext-classif.key#_one = tt-gds.gds-code
                            X_ext-classif.charkey_one = tt-gds.alc-code
                            X_ext-classif.uniq-key-rec = v-gds-uniq-key-rec
                        no-error .
                        if error-status:error then do :
                            message "Уже есть связка, где код товара в TH " string(tt-gds.gds-code) " - алк. код " tt-gds.alc-code view-as alert-box .
                            next _ii_ .
                        end.
                        assign
                            X_ext-classif-attr.key#_one = tt-gds.gds-code
                            X_ext-classif-attr.charkey_one = tt-gds.alc-code
                        no-error.
                        
                        assign X_ext-classif-attr.attr-value = (tt-gds.prod-info + CHR(4) + tt-gds.imp-info + CHR(4) + tt-gds.egais-name) .
                    end.                                    
                    else do :                                    
                        run ref/extclas1.p ( 
                            INPUT {&add-def}
                            ,INPUT yes /*p-silent*/
                            ,INPUT-OUTPUT v-rid
                            ,INPUT {&table_goods} /*p-classif-subject*/
                            ,INPUT {&extclass_goods_esys} /*p-classif-name*/
                            ,input 0  /*p-db-num*/
                            ,input buf_goods.gds-code  /*p-key#_one*/
                            ,input v-ext-sys /*p-Key#_Two*/
                            ,input 0 /*p-key#_Three*/
                            ,input tt-gds.alc-code  /*p-CharKey_One */
                            ,input "" /*p-CharKey_two */
                            ,input "" /*p-CharKey_three */
                            ,input 0 /*p-nonunique */
                            ,input v-gds-uniq-key-rec ) no-error.
                        if error-status:error then
                        do:
                            if error-status:get-message(1) = "" and (return-value = '' or return-value = ?) then
                                message "Ошибка добавления записи в справочник!" skip
                                        "Скорее всего, уже есть связка, где код товара в TH " string(tt-gds.gds-code) " - алк. код " tt-gds.alc-code  view-as alert-box .
                            else
                                message return-value skip error-status:get-message(1) view-as alert-box .
                            next _ii_ .
                        end.
                        find first X_ext-classif no-lock where recid(X_ext-classif) = v-rid.
                        find first X_ext-classif-attr exclusive-lock where X_ext-classif-attr.classif-subject = X_ext-classif.classif-subject
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
                        if not available X_ext-classif-attr then do :
                            create X_ext-classif-attr .
                            assign
                                X_ext-classif-attr.classif-subject = X_ext-classif.classif-subject
                                X_ext-classif-attr.classif-name = X_ext-classif.classif-name
                                X_ext-classif-attr.db-num = X_ext-classif.db-num
                                X_ext-classif-attr.Key#_One = X_ext-classif.key#_one
                                X_ext-classif-attr.Key#_two = X_ext-classif.key#_two
                                X_ext-classif-attr.Key#_three = X_ext-classif.key#_three
                                X_ext-classif-attr.CharKey_One = X_eXt-classif.charkey_one
                                X_ext-classif-attr.CharKey_two = X_eXt-classif.charkey_two
                                X_ext-classif-attr.CharKey_three = X_eXt-classif.charkey_three
                                X_ext-classif-attr.nonunique = X_eXt-classif.nonunique
                                X_ext-classif-attr.attr-code = 'egais-info' 
                            .       
                        end.
                        else do :
                            if tt-gds.imp-info = ? or tt-gds.imp-info = ""
                            or tt-gds.imp-info = chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5)
                            or tt-gds.imp-info = chr(5) + chr(5) + chr(5) + chr(5) + chr(5)
                            then
                            tt-gds.imp-info = entry(2, X_ext-classif-attr.attr-value, CHR(4)) no-error .
                            
                            if tt-gds.imp-info = ? or tt-gds.imp-info = ""
                            then tt-gds.imp-info = chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) .
                            
                            if num-entries(tt-gds.imp-info, CHR(5)) = 6
                            then tt-gds.imp-info = tt-gds.imp-info + chr(5) + chr(5) .
                            
                            if num-entries(entry(2, X_ext-classif-attr.attr-value, CHR(4)), CHR(5)) > 6
                            then entry7 = entry (7, entry(2, X_ext-classif-attr.attr-value, CHR(4)), chr(5)) no-error .
                            else entry7 = "" .
                            
                            if entry (7, tt-gds.imp-info, chr(5)) = ? or entry (7, tt-gds.imp-info, chr(5)) = ""
                            then entry (7, tt-gds.imp-info, chr(5)) = entry7 no-error.
                            
                            if num-entries(entry(1, X_ext-classif-attr.attr-value, CHR(4)), CHR(5)) > 6
                            then entry7 = entry (7, entry(1, X_ext-classif-attr.attr-value, CHR(4)), chr(5)) no-error .
                            else entry7 = "" .
                            
                            if entry (7, tt-gds.prod-info, chr(5)) = ? or entry (7, tt-gds.prod-info, chr(5)) = ""
                            then entry (7, tt-gds.prod-info, chr(5)) = entry7 no-error.
                            
                            if num-entries(entry(1, X_ext-classif-attr.attr-value, CHR(4)), CHR(5)) > 6
                            then entry8 = entry (8, entry(1, X_ext-classif-attr.attr-value, CHR(4)), chr(5)) no-error .
                            else entry8 = "" .
                            
                            if entry (8, tt-gds.prod-info, chr(5)) = ? or entry (8, tt-gds.prod-info, chr(5)) = ""
                            then entry (8, tt-gds.prod-info, chr(5)) = entry8 no-error.
                        end.
                        
                        assign X_ext-classif-attr.attr-value = (tt-gds.prod-info + CHR(4) + tt-gds.imp-info + CHR(4) + tt-gds.egais-name) .
                    end.    
                    
                end. /* for first buf_goods */
                find first old_tt-gds exclusive-lock where old_tt-gds.gds-code = tt-gds.gds-code
                                                       and old_tt-gds.alc-code = tt-gds.alc-code
                                                       and recid(old_tt-gds) <> recid(tt-gds) no-error.
                if available old_tt-gds then do :
                    delete old_tt-gds .
                end. 
            end. /* if bh-gds-egais:available */
        end. /* for first tt-gds */
    end. /* do ii = 1 to num-entries(select-list) */
    message "Сохранение завершено" view-as alert-box.
    run refresh-query in this-procedure.     
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* - */
DO:
    if available tt-gds and tt-gds.gds-code <> 0 and valid-handle(bh-gds-egais) then do :
        if tt-gds.alc-code <> ? and tt-gds.alc-code <> "" then do :
            bh-gds-egais:find-unique (substitute("where tt-gds-EG.alc-code = '&1'", tt-gds.alc-code), no-lock) no-error.
        end.
        else do :
            bh-gds-egais:find-unique (substitute("where tt-gds-EG.gds-name = '&1'", tt-gds.gds-name), no-lock) no-error.
        end.
        if bh-gds-egais:ambiguous then do :
            message "В ЕГАИС более одного товара с точно таким же наименованием. Сначала свяжите товар" view-as alert-box .
            return no-apply .
        end.
        if bh-gds-egais:available then do :
            run bge/egais-gds-diff.w (input rowid(tt-gds), input buffer tt-gds:handle, input bh-gds-egais:handle).
        end.
        else do :
            message "Нет различий по данному товару" view-as alert-box.
            return no-apply.
        end.
    end.            
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-load
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-load Dialog-Frame
ON CHOOSE OF b-load IN FRAME Dialog-Frame /* - */
DO:
    if not available buf_clients then do :
        message "Сначала выберите производителя" view-as alert-box.
        return no-apply.
    end.
    egais:SendRequestUTM() .
    glog = egais:IsSent .
    if glog then enable b-answer WITH FRAME Dialog-Frame.
    else disable b-answer WITH FRAME Dialog-Frame .
    glog = egais:StatusErr .
    if glog then do :
        message egais:Msg view-as alert-box.
        return no-apply.
    end.
    else do :
        v-replyId = egais:ReplyId.
    end.
        
/*    if not requestDictOrg:SendRequestUTM() then message requestDictOrg:Msg view-as alert-box.*/
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-answer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-answer Dialog-Frame
ON CHOOSE OF b-answer IN FRAME Dialog-Frame /* - */
DO:
       
    
    bh-gds-egais = egais:GetHndlTable() .
    glog = egais:StatusErr .
    if glog then do :
        message egais:Msg view-as alert-box.
        return no-apply.
    end.
    if not valid-handle(bh-gds-egais) then do :
        message "Ошибка при получении ответа от ЕГАИС" view-as alert-box error .
        return no-apply .
    end.
    create query qh-gds-egais .
    extGdsObj = new ExtGds(yes).
    qh-gds-egais:set-buffers (bh-gds-egais) .
    qh-gds-egais:query-prepare ("for each tt-gds-eg").
    qh-gds-egais:query-open.
    _repeat:
    repeat:
        qh-gds-egais:get-next ().
        if qh-gds-egais:query-off-end then leave _repeat.
        find first tt-gds no-lock where trim(tt-gds.gds-name) = trim(bh-gds-egais:buffer-field ("gds-name"):buffer-value) and not tt-gds.fromEgais no-error.
        if not available tt-gds then do :
            create tt-gds.
            buffer tt-gds:handle:buffer-copy (bh-gds-egais) .
            assign tt-gds.fromEgais = yes .
            extGdsObj:OpenQueryExtGds(0, tt-gds.alc-code).
            if extGdsObj:NumBundles = 1 then do :
                tt-gds.gds-code = extGdsObj:GetExtGdsValue(1):GdsCode no-error .
            end.
        end.                               
    end.
    run refresh-query in this-procedure.
    delete object extGdsObj no-error .
    apply "value-changed" to br-goods .
    if valid-handle(bh-gds-egais)
    then do :
        bh-gds-egais:find-first () no-error.
        if not bh-gds-egais:available
        then do :
            message "По данному производителю (ИНН) ответ из ЕГАИС не содержит позиций" view-as alert-box .
            return no-apply.
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define BROWSE-NAME br-goods
&UNDEFINE SELF-NAME

on row-display of br-goods IN FRAME Dialog-Frame /* - */
DO:
    if tt-gds.gds-code = 0 then tt-gds.gds-code:bgcolor in browse br-goods = yellow_color .
    if valid-handle(bh-gds-egais) then do :
        if tt-gds.alc-code <> ? and tt-gds.alc-code <> "" then do :
            bh-gds-egais:find-unique (substitute("where tt-gds-EG.alc-code = '&1'", tt-gds.alc-code), no-lock) no-error.
        end.
        else do :
            bh-gds-egais:find-unique (substitute("where tt-gds-EG.gds-name = '&1'", tt-gds.gds-name), no-lock) no-error.
        end.
        if bh-gds-egais:available and not bh-gds-egais:ambiguous and not tt-gds.fromEgais then do :
            if bh-gds-egais:buffer-field ("gds-name"):buffer-value <> tt-gds.gds-name then tt-gds.gds-name:bgcolor in browse br-goods = red_color .
            if bh-gds-egais:buffer-field ("ms-base"):buffer-value <> tt-gds.ms-base then tt-gds.ms-base:bgcolor in browse br-goods = red_color .
            if bh-gds-egais:buffer-field ("proof"):buffer-value <> tt-gds.proof then tt-gds.proof:bgcolor in browse br-goods = red_color .
            if bh-gds-egais:buffer-field ("alc-code"):buffer-value <> tt-gds.alc-code then tt-gds.alc-code:bgcolor in browse br-goods = red_color .
            if bh-gds-egais:buffer-field ("alc-type-code"):buffer-value <> tt-gds.alc-type-code then tt-gds.alc-type-code:bgcolor in browse br-goods = red_color .
        end.
    end.    
end.

on value-changed of br-goods IN FRAME Dialog-Frame /* - */
DO:
    if available tt-gds then do :
        if tt-gds.gds-code = ? or tt-gds.gds-code = 0 then do :
            disable b-good with frame Dialog-Frame .
            if tt-gds.fromEgais then enable b-connect rs-mode with frame Dialog-Frame .
            else disable b-connect rs-mode with frame Dialog-Frame .
        end.
        else do :
            enable b-good with frame Dialog-Frame .
            if valid-handle(bh-gds-egais) then enable b-connect rs-mode with frame Dialog-Frame .
            else disable b-connect rs-mode with frame Dialog-Frame .
        end.            
    end.
end.    

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
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_egais-ref':U
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
  assign
      rs-sort = 1
      rs-mode = 1
  .
  find first buf_clients no-lock where buf_clients.obj-type = {&cmp} and buf_clients.obj-code = v-cntxt-host-code-obj.
  find first buf_firm no-lock where buf_firm.firm-code = v-cntxt-host-code-obj.
  if valid-handle(bh-gds-egais) then do :
      delete object bh-gds-egais .
  end.
  if valid-handle(qh-gds-egais) then do :
      delete object qh-gds-egais .
  end.
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
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
  assign
    v-org = buf_clients.obj-name
    v-fs-rar = v-value-character
    v-org-inn = buf_firm.inn
  .
  egais = new EGAIS(v-cntxt-db-num, v-cntxt-userid).
  
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
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
  assign v-ext-sys = v-value-integer .
  release buf_clients .
/*  run fill-tt.*/
  { gbl/diasize.i &browse-name=br-goods }
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
  if not available tt-gds then return.
  run local-mark in this-procedure.
  assign varlog = {&browse-name} :select-next-row( ) in frame {&frame-name}.
  apply "ENTRY":U to {&browse-name} in frame {&frame-name}.
  {&browse-name}:refresh() in frame {&frame-name} .

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
  if not available tt-gds then do:
    message "Неправильный выбор строки.".
    return no-apply.
  end.
  { gbl/markstrn.i tt-gds select-list }
  {&browse-name}:refresh() in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tt Dialog-Frame
PROCEDURE fill-tt :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
    define variable v-alc-type-code as character no-undo .

    extGdsObj = new ExtGds(yes).
    for each tt-gds :
        delete tt-gds .
    end. 
    if not available buf_clients then return.
    for each buf_goods no-lock where buf_goods.prod-code = buf_clients.obj-code
                                 and buf_goods.prod-type = buf_clients.obj-type :
        run gds-attr-value(
            buf_goods.gds-code,
            {&attr-alcohol-prod},
            output par-alcohol,
            output par-type
        ).
        if par-alcohol <> "" and par-alcohol <> "no" then do :
            extGdsObj:OpenQueryExtGds(buf_goods.gds-code, "").
            v-alc-type-code = "" . 
            for first ub.alc-type-gds where ub.alc-type-gds.gds-code = buf_goods.gds-code no-lock,
                first ub.alc-type where ub.alc-type.alc-type-inner-code = ub.alc-type-gds.alc-type-inner-code no-lock :
                assign v-alc-type-code = ub.alc-type.alc-type-code .    
            end.
            if extGdsObj:NumBundles = 0 then do :
                create tt-gds .
                assign
                    tt-gds.gds-code = buf_goods.gds-code
                    tt-gds.gds-name = buf_goods.gds-name
                    tt-gds.ms-base  = buf_goods.ms-base
                    tt-gds.proof    = buf_goods.proof
                    tt-gds.old-gds-code = buf_goods.gds-code
                    tt-gds.alc-type-code = v-alc-type-code
                .
            end.
            else
            do numBundles = 1 to extGdsObj:NumBundles :
                create tt-gds .
                assign
                    tt-gds.gds-code = buf_goods.gds-code
                    tt-gds.gds-name = buf_goods.gds-name
                    tt-gds.ms-base  = buf_goods.ms-base
                    tt-gds.proof    = buf_goods.proof
                    tt-gds.old-gds-code = buf_goods.gds-code
                    tt-gds.alc-type-code = v-alc-type-code
                .
                assign
                    tt-gds.alc-code = extGdsObj:GetExtGdsValue(numBundles):AlcCode
                    tt-gds.old-alc-code = extGdsObj:GetExtGdsValue(numBundles):AlcCode
                    tt-gds.egais-name = extGdsObj:GetExtGdsValue(numBundles):FullNameGds
                .
            end.
        end.                             
    end.
    delete object extGdsObj no-error .
END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE refresh-query Dialog-Frame
PROCEDURE refresh-query :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  if NameContext2 = "" then do :
      case rs-sort :
        when 1 then do:
          OPEN QUERY {&browse-name} FOR EACH tt-gds
                     by tt-gds.gds-name
                     indexed-reposition .
        end.
        when 2 then do:
          OPEN QUERY {&browse-name} FOR EACH tt-gds
                     by tt-gds.gds-code
                     indexed-reposition .
        end.
        OTHERWISE do:
          OPEN QUERY {&browse-name} FOR EACH tt-gds
                     by tt-gds.alc-code
                     indexed-reposition .
        end.
      end case.
  end.
  else do :
      case rs-sort :
        when 1 then do:
          OPEN QUERY {&browse-name} FOR EACH tt-gds where tt-gds.gds-name contains NameContext2
                     by tt-gds.gds-name
                     indexed-reposition .
        end.
        when 2 then do:
          OPEN QUERY {&browse-name} FOR EACH tt-gds where tt-gds.gds-name contains NameContext2
                     by tt-gds.gds-code
                     indexed-reposition .
        end.
        OTHERWISE do:
          OPEN QUERY {&browse-name} FOR EACH tt-gds where tt-gds.gds-name contains NameContext2
                     by tt-gds.alc-code
                     indexed-reposition .
        end.
      end case.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

procedure sel-prod :
    assign
        ref-list = "":U
    .
    run ref/cli-all.w (
                       input parparentproc
                    ,  input "b-sel"
                    ,  input {&all}
                    ,  input {&all}
                    ,  input {&current}
                    ,  input ?
                    ,  input ",,,,,,NO,,,"
                    ,  input ?
                    , output ref-list
                    ) .
    if ref-list = "":U then do:       
        RUN enable_UI IN THIS-PROCEDURE.
        return no-apply.
    end.
    find first buf_clients no-lock where recid(buf_clients) = integer(ref-list) . 
/*    if available buf_clients then do :                                                                            */
/*        find first buf_clients-attr no-lock where buf_clients-attr.obj-type  = buf_clients.obj-type               */
/*                                            and   buf_clients-attr.obj-code  = buf_clients.obj-code               */
/*                                            and   buf_clients-attr.attr-code = {&attr-cli-alc-producer} no-error. */
/*        if not available buf_clients-attr then do :                                                               */
/*            message 'У производителя должен быть атрибут "Производитель алкогольной продукции"' view-as alert-box.*/
/*            release buf_clients .                                                                                 */
/*            run sel-prod .                                                                                        */
/*/*            apply "choose":U to b-prod IN FRAME Dialog-Frame .*/                                                */
/*        end.                                                                                                      */
/*    end.                                                                                                          */
    if available buf_clients then do :
        assign
            v-prod = buf_clients.obj-type + string(buf_clients.obj-code)
            v-prod-name = buf_clients.obj-name
        . 
        find first buf_firm no-lock where buf_firm.firm-code = buf_clients.obj-code no-error .
        if available buf_firm then do :
            if trim(buf_firm.inn) = "" or buf_firm.inn = ? then do :
                message "У производителя не заполнен ИНН. Для отправки запроса в ЕГАИС необходим корректный ИНН" view-as alert-box.
                return error.
            end.
            egais:EGAISImpl = new DictGds(v-cntxt-obj-type, v-cntxt-obj-code, v-fs-rar, buf_firm.inn) .
        end.
    end.     
    display v-prod v-prod-name with frame Dialog-Frame.
    run fill-tt.
    run refresh-query in this-procedure .  
    apply "value-changed" to br-goods IN FRAME Dialog-Frame .
end procedure.    

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
    
  DISPLAY rs-sort
      WITH FRAME Dialog-Frame.
  ENABLE b-mark b-sel-all b-unmark b-load rs-sort b-save b-lkp b-cancel b-prod br-goods NameContext
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  br-goods:column-resizable in FRAME Dialog-Frame = true .
/*  if egais:IsSent then enable b-answer WITH FRAME Dialog-Frame.*/
/*  else disable b-answer WITH FRAME Dialog-Frame .              */
  run refresh-query in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

