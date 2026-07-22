&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

  File: bge/egais-obj.w

  Description: Настройки объектов ЕГАИС

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: Slivenko Sergey

  Created: 03.11.2015
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
{ gbl/thbjattr.i }
{ gbl/clntattr.i }
{ gbl/color.i    }
{ ref/extclass.i }
{ gbl/key-rec.i  }

define temp-table tt-objs no-undo
    field obj-type          like ub.clients.obj-type
    field obj-code          like ub.clients.obj-code
    field obj-name-th       as character label "Наименование в TH"
    field obj-name-egais    as character label "Наименование ЕГАИС"
    field regID             as character label "Регистрационный номер"
    field inn               as character label "ИНН"
    field kpp               as character label "КПП"
    field country           as character label "Код страны"
    field regionCode        as character label "Код региона"
    field district          as character label "Район"
    field city              as character label "Город"
    field settlement        as character label "Населенный пункт"
    field street            as character label "Улица"
    field house-number      as character label "Номер дома"
    field house-case        as character label "Корпус"
    field house-apartment   as character label "Номер квартиры"
    field house-litera      as character label "Литера"
    field postIndex         as character label "Почтовый индекс"
    field description_      as character label "Адрес"
    field fromEgais         as logical 
    field connected_        as logical
    field versionWB         as character format "X(10)"
    field typeEgais         as character format "X(2)"
    index pi as primary
        obj-type obj-code
    index egais
        inn kpp    
.    

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/*def var egais as class EGAIS.                    */
/*def var requestDictOrg as class  RequestDictOrg .*/
/*def var responseDictOrg as class ResponseDictOrg.*/

def var egais as class EGAIS.

def var bh-obj-egais as handle no-undo .
def var qh-obj-egais as handle no-undo .


define buffer buf_firm for ub.firm .
define buffer buf_clients for ub.clients .
define buffer buf_clients-attr for ub.clients-attr .
DEFINE BUFFER X_ext-classif FOR ub.ext-classif.
DEFINE BUFFER X_ext-classif-attr FOR ub.ext-classif-attr .

define variable select-list as character no-undo .
define variable ii          as integer   no-undo .
define variable v-rid       as recid     no-undo .
define variable par-alcohol as character no-undo .
define variable par-type    as character no-undo .
define variable v-kpp       as character no-undo .
define variable v-org-inn   as character no-undo .
define variable v-isSent    as logical   no-undo .
define variable v-outId     as character no-undo .
define variable v-ext-sys   as integer   no-undo .
define variable v-replyId   as character no-undo .
define variable v-regID     as character no-undo .

define variable v-obj-uniq-key-rec as character no-undo .

define variable glog        as logical no-undo .

define variable v-value-character  as character no-undo .
define variable v-value-decimal    as decimal   no-undo .
define variable v-value-integer    as integer   no-undo .
define variable v-value-logical    as logical   no-undo .
define variable v-value-type       as character no-undo .
define variable v-value-date       as date      no-undo .

FUNCTION get-mark RETURNS CHARACTER
(buffer local-obj for tt-objs ):
if lookup (string (recid (local-obj)), select-list) > 0  then return "*".
                                                           else return "".
end function.

FUNCTION get-obj RETURNS CHARACTER
(buffer local-obj for tt-objs ):
    return (local-obj.obj-type + string(local-obj.obj-code)) .
end function.


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-objects

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-objs

/* Definitions for BROWSE br-objects                                    */
&Scoped-define SELF-NAME br-objects
&Scoped-define QUERY-STRING-br-objects FOR EACH tt-objs
&Scoped-define OPEN-QUERY-br-objects OPEN QUERY {&SELF-NAME} FOR EACH tt-objs.
&Scoped-define TABLES-IN-QUERY-br-objects tt-objs
&Scoped-define FIRST-TABLE-IN-QUERY-br-objects tt-objs


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-objects}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-load b-cancel br-objects 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */

define variable v-org as character no-undo view-as text format "X(50)" label "Организация" .
define variable v-fs-rar as character no-undo view-as text format "X(15)" label "Код ФС РАР (FSRAR ID)" .

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
     
DEFINE BUTTON b-connect 
     LABEL "Связать" 
     SIZE 15 BY 1.14
     BGCOLOR 8 . 
     
DEFINE BUTTON b-sel-all
     LABEL "&+":L
     SIZE 3 BY 1.14 TOOLTIP "Отметить все объекты".

DEFINE BUTTON b-unmark
     LABEL "&-":L
     SIZE 3 BY 1.14 TOOLTIP "Снять все отметки".                

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-objects FOR 
      tt-objs SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-objects
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-objects Dialog-Frame _FREEFORM
  QUERY br-objects DISPLAY
    get-mark(BUFFER tt-objs) COLUMN-LABEL "*"  FORMAT "X(1)":U
    tt-objs.regID COLUMN-LABEL "Регистрационный номер" FORMAT "X(21)":U 
    get-obj(buffer tt-objs) COLUMN-LABEL "Объект" FORMAT "X(6)":U 
    tt-objs.inn COLUMN-LABEL "ИНН" FORMAT "X(12)":U
    tt-objs.kpp COLUMN-LABEL "КПП" FORMAT "X(9)":U 
    tt-objs.obj-name-th COLUMN-LABEL "Наименование в TH" FORMAT "X(100)":U width 25
    tt-objs.obj-name-egais COLUMN-LABEL "Наименование ЕГАИС" FORMAT "X(100)":U width 25
    tt-objs.country COLUMN-LABEL "Страна" FORMAT "X(6)":U
    tt-objs.regionCode COLUMN-LABEL "Регион" FORMAT "X(6)":U
    tt-objs.description_ COLUMN-LABEL "Адрес" FORMAT "X(100)":U width 87
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 105 BY 21.5 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-mark AT ROW 2.5 COL 2
     b-sel-all AT ROW 2.5 COL 5
     b-unmark AT ROW 2.5 COL 8
     b-load AT ROW 1.24 COL 32
     b-answer AT ROW 1.24 COL 47
     b-save AT ROW 1.24 COL 17
     b-lkp AT ROW 1.24 COL 62
     b-cancel AT ROW 1.24 COL 2
     v-org AT ROW 2.7 COL 13
     v-fs-rar AT ROW 2.7 COL 65
     b-connect AT ROW 1.24 COL 77
     br-objects AT ROW 3.86 COL 2 WIDGET-ID 200
     SPACE(1) SKIP(0.32)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Объекты ЕГАИС"
         DEFAULT-BUTTON b-load CANCEL-BUTTON b-cancel WIDGET-ID 100.

assign br-objects:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame = 1 .

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
/* BROWSE-TAB br-objects b-cancel Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-objects
/* Query rebuild information for BROWSE br-objects
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-objs.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-objects */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

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
  if not available tt-objs then return.
  for each tt-objs no-lock :
    { gbl/markstrn.i tt-objs select-list }
  end.
  {&browse-name}:refresh() in frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-unmark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-unmark Dialog-Frame
ON CHOOSE OF b-unmark IN FRAME Dialog-Frame /* - */
DO:
  if not available tt-objs then return.
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

&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save Dialog-Frame
ON CHOOSE OF b-save IN FRAME Dialog-Frame /* - */
DO:
    if select-list = "" then do :
        message "Не выбрано ни одной строки" view-as alert-box .
        return no-apply.
    end.   
    if bh-obj-egais = ? then do :
        message "Сначала сделайте запрос в ЕГАИС и получите актуальную информацию" view-as alert-box .
        return no-apply.
    end.
    do ii = 1 to num-entries(select-list) :
        for first tt-objs exclusive-lock where recid(tt-objs) = integer(entry(ii, select-list)) and tt-objs.obj-code > 0 :
            if tt-objs.connected_ then do :
                bh-obj-egais:find-unique (substitute("where tt-objs-EG.regID = '&1'", trim(tt-objs.regID)), no-lock) no-error.
            end.
            else do :    
                bh-obj-egais:find-unique (substitute("where tt-objs-EG.inn = '&1' and tt-objs-EG.kpp = '&2'", trim(tt-objs.inn), trim(tt-objs.kpp)), no-lock) no-error.
            end.
            if bh-obj-egais:available and not bh-obj-egais:ambiguous then do :
                buffer tt-objs:handle:buffer-copy (bh-obj-egais, "obj-type,obj-code,obj-name-th") .
/*                assign                                                                                                                                            */
/*                    tt-objs.description_ = (if tt-objs.postIndex       <> ? and tt-objs.postIndex       <> "" then (tt-objs.postIndex + ", ")           else "")  */
/*                                         + (if tt-objs.district        <> ? and tt-objs.district        <> "" then (tt-objs.district + ", ")            else "")  */
/*                                         + (if tt-objs.city            <> ? and tt-objs.city            <> "" then (tt-objs.city + ", ")                else "")  */
/*                                         + (if tt-objs.settlement      <> ? and tt-objs.settlement      <> "" then (tt-objs.settlement + ", ")          else "")  */
/*                                         + (if tt-objs.street          <> ? and tt-objs.street          <> "" then (tt-objs.street + ", ")              else "")  */
/*                                         + (if tt-objs.house-number    <> ? and tt-objs.house-number    <> "" then ("д." + tt-objs.house-number)        else "")  */
/*                                         + (if tt-objs.house-litera    <> ? and tt-objs.house-litera    <> "" then (tt-objs.house-litera + ", ")        else ", ")*/
/*                                         + (if tt-objs.house-case      <> ? and tt-objs.house-case      <> "" then ("кор." + tt-objs.house-case + ", ") else "")  */
/*                                         + (if tt-objs.house-apartment <> ? and tt-objs.house-apartment <> "" then ("кв." + tt-objs.house-apartment)    else "")  */
/*                    tt-objs.description_ = trim(trim(tt-objs.description_), ",")                                                                                  */
/*                .                                                                                                                                                 */
                find first buf_clients-attr exclusive-lock  where buf_clients-attr.obj-type = tt-objs.obj-type 
                                                            and   buf_clients-attr.obj-code = tt-objs.obj-code
                                                            and   buf_clients-attr.attr-code = {&attr-requisite-alc-decl}
                                                            no-error.
                if not available buf_clients-attr then do :
                    create buf_clients-attr .
                    assign
                        buf_clients-attr.obj-type = tt-objs.obj-type 
                        buf_clients-attr.obj-code = tt-objs.obj-code
                        buf_clients-attr.attr-code = {&attr-requisite-alc-decl}
                    .                                     
                end.
                buf_clients-attr.attr-value = tt-objs.obj-name-egais + "||"     
                                            + tt-objs.country + "|" 
                                            + tt-objs.postIndex + "|" 
                                            + tt-objs.regionCode + "|" 
                                            + tt-objs.district + "|"
                                            + tt-objs.city + "|"
                                            + tt-objs.settlement + "|"
                                            + tt-objs.street + "|"
                                            + tt-objs.house-number + "|"
                                            + tt-objs.house-case + "|"
                                            + tt-objs.house-apartment + "|"
                                            + tt-objs.house-litera + "|||||||" 
                                            + replace(tt-objs.description_, "|", CHR(5))
                .
                
                if tt-objs.regID <> "" then do :
                    find first buf_clients no-lock where buf_clients.obj-type = tt-objs.obj-type and buf_clients.obj-code = tt-objs.obj-code .
                    run gen-key-rec in this-procedure   ( input {&table_clients}
                                                         ,input buffer buf_clients:handle
                                                         ,output v-obj-uniq-key-rec).
                    find first X_ext-classif exclusive-lock  where X_ext-classif.classif-subject = {&table_clients}
                                                               and X_ext-classif.classif-name = {&extclass_clients_esys}
                                                               AND X_ext-classif.db-num = 0
                                                               and X_ext-classif.key#_one = v-ext-sys
                                                               and X_ext-classif.key#_two = 0
                                                               and X_ext-classif.key#_three = 0
                                                               and X_eXt-classif.uniq-key-rec = v-obj-uniq-key-rec
                                                               and X_eXt-classif.CharKey_One = ''
                                                               and X_eXt-classif.CharKey_two = (tt-objs.obj-type + string(tt-objs.obj-code))
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
                                                                       and X_ext-classif-attr.attr-code = 'egais-cli-info'
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
                                X_ext-classif-attr.attr-code = 'egais-cli-info' 
                            .       
                        end.
                        assign
                            X_ext-classif.charkey_three = tt-objs.regID
                            X_ext-classif-attr.charkey_three = tt-objs.regID
                        .
                        assign X_ext-classif-attr.attr-value = tt-objs.versionWB + CHR(4) + tt-objs.typeEgais .
                    end.
                    else do :
                        run ref/extclas1.p ( INPUT {&add-def}
                                            ,INPUT yes /*p-silent*/
                                            ,INPUT-OUTPUT v-rid
                                            ,INPUT {&table_clients} /*p-classif-subject*/
                                            ,INPUT {&extclass_clients_esys} /*p-classif-name*/
                                            ,input 0 /*p-db-num*/
                                            ,input v-ext-sys  /*p-key#_one*/
                                            ,input 0 /*p-Key#_Two*/
                                            ,input 0 /*p-key#_Three*/
                                            ,input '':U  /*p-CharKey_One */
                                            ,input (tt-objs.obj-type + string(tt-objs.obj-code)) /*p-CharKey_two */
                                            ,input tt-objs.regID /*p-CharKey_three */
                                            ,input 0 /*p-nonunique */
                                            ,input v-obj-uniq-key-rec ) no-error.
                        if error-status:error then do:
                          message return-value skip error-status:get-message(1) view-as alert-box .
                          undo, return no-apply .
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
                                                                       and X_ext-classif-attr.attr-code = 'egais-cli-info'
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
                                X_ext-classif-attr.attr-code = 'egais-cli-info' 
                            .       
                        end.
                        assign X_ext-classif-attr.attr-value = tt-objs.versionWB + CHR(4) + tt-objs.typeEgais .
                    end.    
                end. /* if tt-objs.regID <> "" */
            end. /* if bh-obj-egais:available and not bh-obj-egais:ambiguous */
        end. /* for first tt-objs exclusive-lock */
    end. /* do ii = 1 to num-entries(select-list) */
    message "Сохранение завершено" view-as alert-box.
    disable b-connect WITH FRAME Dialog-Frame.
    {&browse-name}:refresh() in frame {&frame-name} .
/*    {&OPEN-QUERY-br-objects}*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* - */
DO:
    if available tt-objs and tt-objs.obj-code <> 0 and valid-handle(bh-obj-egais) then do :
        if tt-objs.connected_ then do :
            bh-obj-egais:find-unique (substitute("where tt-objs-EG.regID = '&1'", trim(tt-objs.regID)), no-lock) no-error.
        end.
        else do :
            bh-obj-egais:find-unique (substitute("where tt-objs-EG.inn = '&1' and tt-objs-EG.kpp = '&2'", trim(tt-objs.inn), trim(tt-objs.kpp)), no-lock) no-error.
        end.
        if bh-obj-egais:ambiguous then do :
            message "В ЕГАИС более одного объекта с таким ИНН и КПП. Сначала свяжите объект" view-as alert-box.
            return no-apply .
        end.
        if bh-obj-egais:available then do :
            run bge/egais-obj-diff.w (input rowid(tt-objs), input buffer tt-objs:handle, input bh-obj-egais:handle).
        end.
        else do :
            message "Нет различий по данному объекту" view-as alert-box.
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
    
    egais:SendRequestUTM() .
    if egais:IsSent then enable b-answer WITH FRAME Dialog-Frame.
    else disable b-answer WITH FRAME Dialog-Frame .
    if egais:StatusErr then do :
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

&Scoped-define SELF-NAME b-connect
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-connect Dialog-Frame
ON CHOOSE OF b-connect IN FRAME Dialog-Frame /* - */
DO:
    if not available tt-objs then return no-apply .
    if tt-objs.connected_ then do :
        bh-obj-egais:find-unique (substitute("where tt-objs-EG.regID = '&1'", trim(tt-objs.regID)), no-lock) no-error.
        assign
            tt-objs.regID = ""
            tt-objs.connected_ = false
            b-connect:label = "Связать"
        .
        if bh-obj-egais:available then
        assign
            bh-obj-egais:buffer-field ("connected_"):buffer-value = false
        .
    end.
    else do :
        run bge/egais-select-obj.w (tt-objs.inn ,
                                    tt-objs.kpp ,
                                    bh-obj-egais:handle ,
                                    output v-regID ) .
        if v-regID <> "" and v-regID <> ? then do :
            assign
                tt-objs.regID = v-regID
                tt-objs.connected_ = true
            .
        end.        
    end.
    {&browse-name}:refresh() in frame {&frame-name} .
/*    {&OPEN-QUERY-br-objects}*/
    apply "value-changed" to br-objects IN FRAME Dialog-Frame .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-answer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-answer Dialog-Frame
ON CHOOSE OF b-answer IN FRAME Dialog-Frame /* - */
DO:
/*     run gbl/inidebug.p .*/
    bh-obj-egais = egais:GetHndlTable() .
/*    bh-obj-egais = responseDictOrg:ParseResponse("ReceiptQueryPartner1.xml").*/
/*    if egais:StatusErr then do :            */
/*        message egais:Msg view-as alert-box.*/
/*        return no-apply.                    */
/*    end.                                    */
    if egais:StatusErr then do :
        message egais:Msg view-as alert-box.
        return no-apply.
    end.
    if not valid-handle(bh-obj-egais) then do :
        message "Ошибка при получении ответа от ЕГАИС" view-as alert-box error .
        return no-apply .
    end.
/*    create query qh-obj-egais .                                                                          */
/*    qh-obj-egais:set-buffers (bh-obj-egais) .                                                            */
/*    qh-obj-egais:query-prepare ("for each tt-objs-eg").                                                  */
/*    qh-obj-egais:query-open.                                                                             */
/*    _repeat:                                                                                             */
/*    repeat:                                                                                              */
/*        qh-obj-egais:get-next ().                                                                        */
/*        if qh-obj-egais:query-off-end then leave _repeat.                                                */
/*        find first tt-objs no-lock where tt-objs.inn = bh-obj-egais:buffer-field ("inn"):buffer-value    */
/*                                     and tt-objs.kpp = bh-obj-egais:buffer-field ("kpp"):buffer-value    */
/*                                     and tt-objs.regID = bh-obj-egais:buffer-field ("regID"):buffer-value*/
/*                                     and not tt-objs.fromEgais                                           */
/*                                     no-error.                                                           */
/*        if not available tt-objs then do :                                                               */
/*            create tt-objs.                                                                              */
/*            buffer tt-objs:handle:buffer-copy (bh-obj-egais) .                                           */
/*        end.                                                                                             */
/*    end.                                                                                                 */
    {&OPEN-QUERY-br-objects}
    apply "value-changed" to br-objects IN FRAME Dialog-Frame .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define BROWSE-NAME br-objects
&UNDEFINE SELF-NAME

on row-display of br-objects IN FRAME Dialog-Frame /* - */
DO:
    if tt-objs.obj-code = 0 then tt-objs.regID:bgcolor in browse br-objects = yellow_color .
    if valid-handle(bh-obj-egais) then do :
        if tt-objs.regID <> ? and tt-objs.regID <> "" then do :
            bh-obj-egais:find-unique (substitute("where tt-objs-EG.regID = '&1'", trim(tt-objs.regID)), no-lock) no-error.
            if bh-obj-egais:available then
            assign
                tt-objs.connected_ = true
                bh-obj-egais:buffer-field ("connected_"):buffer-value = true
            . 
        end.
        else do :
            bh-obj-egais:find-unique (substitute("where tt-objs-EG.inn = '&1' and tt-objs-EG.kpp = '&2'", trim(tt-objs.inn), trim(tt-objs.kpp)), no-lock) no-error.
        end.
        if bh-obj-egais:available then do :
            if bh-obj-egais:buffer-field ("obj-name-egais"):buffer-value <> tt-objs.obj-name-egais then tt-objs.obj-name-egais:bgcolor in browse br-objects = red_color .
            if bh-obj-egais:buffer-field ("regID"):buffer-value <> tt-objs.regID then tt-objs.regID:bgcolor in browse br-objects = red_color .
            if bh-obj-egais:buffer-field ("country"):buffer-value <> tt-objs.country then tt-objs.country:bgcolor in browse br-objects = red_color .
            if bh-obj-egais:buffer-field ("description_"):buffer-value <> tt-objs.description_ then do :
                tt-objs.description_:bgcolor in browse br-objects = red_color .
                if tt-objs.regID <> ? and tt-objs.regID <> "" then tt-objs.regID:bgcolor in browse br-objects = yellow_color .
            end.
            if bh-obj-egais:buffer-field ("regionCode"):buffer-value <> tt-objs.regionCode then tt-objs.regionCode:bgcolor in browse br-objects = red_color .
        end.
    end.    
end.   

on value-changed of br-objects IN FRAME Dialog-Frame /* - */
DO:
    if available tt-objs and valid-handle(bh-obj-egais) then do :
        if tt-objs.connected_ then do :
            enable b-connect WITH FRAME Dialog-Frame.
            b-connect:label = "Отвязать" .
        end.
        else do :    
            create query qh-obj-egais .
            qh-obj-egais:set-buffers (bh-obj-egais) .
            qh-obj-egais:query-prepare (substitute("for each tt-objs-eg where tt-objs-EG.inn = '&1' and tt-objs-EG.kpp = '&2'", trim(tt-objs.inn), trim(tt-objs.kpp)) ).
            qh-obj-egais:query-open.
            ii = 0 .
            _repeat:
            repeat:
                qh-obj-egais:get-next ().
                if qh-obj-egais:query-off-end then leave _repeat.
                ii = ii + 1 .
            end.
            b-connect:label = "Связать" .
            if ii > 0 then enable b-connect WITH FRAME Dialog-Frame.
            else do :
                qh-obj-egais:query-prepare (substitute("for each tt-objs-eg where tt-objs-EG.inn = '&1'", trim(tt-objs.inn)) ).
                qh-obj-egais:query-open.
                ii = 0 .
                _repeat:
                repeat:
                    qh-obj-egais:get-next ().
                    if qh-obj-egais:query-off-end then leave _repeat.
                    ii = ii + 1 .
                end.
                if ii > 0 then enable b-connect WITH FRAME Dialog-Frame.
                else disable b-connect WITH FRAME Dialog-Frame.
            end.
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
  { gbl/getcntxt.i get } 
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_egais-obj':U
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
  find first buf_clients no-lock where buf_clients.obj-type = {&cmp} and buf_clients.obj-code = v-cntxt-host-code-obj.
  find first buf_firm no-lock where buf_firm.firm-code = v-cntxt-host-code-obj.
  if valid-handle(bh-obj-egais) then do :
      delete object bh-obj-egais .
  end.
  if valid-handle(qh-obj-egais) then do :
      delete object qh-obj-egais .
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
  egais:EGAISImpl = new DictOrg(v-cntxt-obj-type, v-cntxt-obj-code, v-fs-rar, v-org-inn) .
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
/*  egais:EGAISImpl = new RequestDictOrg(v-fs-rar, v-org-inn).  */
/*  responseDictOrg = new ResponseDictOrg(v-fs-rar, v-org-inn) .*/
  run fill-tt.
  { gbl/diasize.i &browse-name=br-objects }
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
  if not available tt-objs then return.
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
  if not available tt-objs then do:
    message "Неправильный выбор строки.".
    return no-apply.
  end.
  { gbl/markstrn.i tt-objs select-list }
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
    for each tt-objs :
        delete tt-objs .
    end. 
    for each buf_clients no-lock
       where buf_clients.host-code = v-cntxt-host-code-obj :
        { gbl/conf-rd.i "'alcohol'" buf_clients.host-code buf_clients.obj-type buf_clients.obj-code "''" "''" "''" no par-alcohol par-type no-error}.
        if par-alcohol = "yes" then do :
            find first buf_firm no-lock where buf_firm.firm-code = buf_clients.host-code no-error .
            RUN clntattr-value IN THIS-PROCEDURE
                (INPUT buf_clients.obj-type,
                 INPUT buf_clients.obj-code,
                 input {&attr-kpp},
                 OUTPUT v-kpp,
                 OUTPUT par-type).
            
            create tt-objs.
            assign
                tt-objs.obj-type            = buf_clients.obj-type
                tt-objs.obj-code            = buf_clients.obj-code
                tt-objs.obj-name-th         = buf_clients.obj-name
                tt-objs.inn                 = if available buf_firm then buf_firm.inn else ""
                tt-objs.kpp                 = v-kpp
            .
            run gen-key-rec in this-procedure   ( input {&table_clients}
                                                 ,input buffer buf_clients:handle
                                                 ,output v-obj-uniq-key-rec).
            find first X_ext-classif no-lock where X_ext-classif.classif-subject = {&table_clients}
                                               and X_ext-classif.classif-name = {&extclass_clients_esys}
                                               AND X_ext-classif.db-num = 0
                                               and X_ext-classif.key#_one = v-ext-sys
                                               and X_ext-classif.key#_two = 0
                                               and X_ext-classif.key#_three = 0
                                               and X_eXt-classif.uniq-key-rec = v-obj-uniq-key-rec
                                               and X_eXt-classif.CharKey_One = ''
                                               and X_eXt-classif.CharKey_two = (tt-objs.obj-type + string(tt-objs.obj-code))
                                               and X_eXt-classif.nonunique = 0
                                               no-error.
            if available X_ext-classif then do :
                assign tt-objs.regID = X_ext-classif.charkey_three .
            end.
            find first buf_clients-attr no-lock where buf_clients-attr.obj-type = buf_clients.obj-type 
                                                and   buf_clients-attr.obj-code = buf_clients.obj-code
                                                and   buf_clients-attr.attr-code = {&attr-requisite-alc-decl} no-error.
            if available buf_clients-attr then do :
                assign
                    tt-objs.obj-name-egais      = entry( 1, buf_clients-attr.attr-value, "|")
                    tt-objs.country             = entry( 3, buf_clients-attr.attr-value, "|")
                    tt-objs.postIndex           = entry( 4, buf_clients-attr.attr-value, "|")
                    tt-objs.regionCode          = entry( 5, buf_clients-attr.attr-value, "|") 
                    tt-objs.district            = entry( 6, buf_clients-attr.attr-value, "|")
                    tt-objs.city                = entry( 7, buf_clients-attr.attr-value, "|")  
                    tt-objs.settlement          = entry( 8, buf_clients-attr.attr-value, "|")
                    tt-objs.street              = entry( 9, buf_clients-attr.attr-value, "|")
                    tt-objs.house-number        = entry(10, buf_clients-attr.attr-value, "|")
                    tt-objs.house-case          = entry(11, buf_clients-attr.attr-value, "|")
                    tt-objs.house-apartment     = entry(12, buf_clients-attr.attr-value, "|")
                    tt-objs.house-litera        = entry(13, buf_clients-attr.attr-value, "|")
                    no-error
                .
                assign tt-objs.description_ = replace(entry(20, buf_clients-attr.attr-value, "|"), CHR(5), "|") no-error .
/*                assign                                                                                                                                            */
/*                    tt-objs.description_ = (if tt-objs.postIndex       <> ? and tt-objs.postIndex       <> "" then (tt-objs.postIndex + ", ")           else "")  */
/*                                         + (if tt-objs.district        <> ? and tt-objs.district        <> "" then (tt-objs.district + ", ")            else "")  */
/*                                         + (if tt-objs.city            <> ? and tt-objs.city            <> "" then (tt-objs.city + ", ")                else "")  */
/*                                         + (if tt-objs.settlement      <> ? and tt-objs.settlement      <> "" then (tt-objs.settlement + ", ")          else "")  */
/*                                         + (if tt-objs.street          <> ? and tt-objs.street          <> "" then (tt-objs.street + ", ")              else "")  */
/*                                         + (if tt-objs.house-number    <> ? and tt-objs.house-number    <> "" then ("д." + tt-objs.house-number)        else "")  */
/*                                         + (if tt-objs.house-litera    <> ? and tt-objs.house-litera    <> "" then (tt-objs.house-litera + ", ")        else ", ")*/
/*                                         + (if tt-objs.house-case      <> ? and tt-objs.house-case      <> "" then ("кор." + tt-objs.house-case + ", ") else "")  */
/*                                         + (if tt-objs.house-apartment <> ? and tt-objs.house-apartment <> "" then ("кв." + tt-objs.house-apartment)    else "")  */
/*                    tt-objs.description_ = trim(trim(tt-objs.description_), ",")                                                                                  */
/*                .                                                                                                                                                 */
            end.       
        end.    
    end.      

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
    
  display v-org v-fs-rar with frame Dialog-Frame.
  ENABLE b-mark b-sel-all b-unmark b-load b-answer b-save b-lkp b-cancel br-objects 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  br-objects:column-resizable in frame Dialog-Frame = true .
  if egais:IsSent then enable b-answer WITH FRAME Dialog-Frame.
  else disable b-answer WITH FRAME Dialog-Frame .
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

