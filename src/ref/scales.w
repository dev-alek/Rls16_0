&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник весов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
DEFINE input parameter bttns           as    char                       no-undo.
DEFINE INPUT PARAMETER p-mode AS character NO-UNDO.
DEFINE output parameter rid-list    as  char no-undo . /* список recid'ов выбранных весов */

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник весов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ cmp/showinf.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ cmp/trg-def.i }
/*определение переменных для работы с весами - пересылка*/
{ gbl/waitfram.i }
{ cmp/gds-list.i gds-list def "new shared" }
{ ref/gdsoattr.i }
/*специфические для данного файла переменные*/
define variable ri as recid no-undo .
define variable CmdStr      as char no-undo .
define variable Gds-Option as Char no-undo init "".
define variable PurgOption as Char no-undo init "".
define variable PrintOption as char no-undo init "".
define variable v-doc-rec as recid no-undo .
define variable sendoption as character no-undo .
define variable attr-option as character no-undo .
define variable send-rid-list as character no-undo .
define variable v-rec as recid no-undo .
DEFINE VARIABLE v-mode AS CHARACTER NO-UNDO.
DEFINE VARIABLE rum-option   AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-scallist AS CHARACTER NO-UNDO.
/*процедурки отслылки на весы*/
{ str/get-pr.i def }
{ ref/scale-pr.i }
{ ref/scale-pr.i -db }
{ gbl/getcntxt.i def }

&SCOPED-DEFINE status-code STRING(scales.sts)

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-scales

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.scales

/* Definitions for BROWSE BR-scales                                     */
&Scoped-define FIELDS-IN-QUERY-BR-scales ~
IF ( CAN-DO (rid-list, STRING ( recid( scales ) ) ) ) THEN ("*") ELSE (" ") ~
ub.scales.to-send ub.scales.scales-num ub.scales.master ~
ub.scales.scales-name ub.scales.tot-gds {&status-int-name} ~
ub.scales.max-gds ub.scales.scales-type ub.scales.address ~
ub.scales.unit-base ub.scales.db-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-scales
&Scoped-define QUERY-STRING-BR-scales FOR EACH ub.scales NO-LOCK
&Scoped-define OPEN-QUERY-BR-scales OPEN QUERY BR-scales FOR EACH ub.scales NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-scales ub.scales
&Scoped-define FIRST-TABLE-IN-QUERY-BR-scales ub.scales


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-sel B-mark B-add B-chg B-del B-gds ~
b-price b-scal-grp B-hist B-help B-on B-purg B-send b-ticket B-rum ~
Rs-object B-attr BR-scales mark-num
&Scoped-Define DISPLAYED-OBJECTS Rs-object mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-attr
       MENU-ITEM m_lookup       LABEL "Просмотр"
       MENU-ITEM m_update       LABEL "Изменение"     .

DEFINE MENU MENU-B-gds
       MENU-ITEM m___one        LABEL "Товары на весах"
       MENU-ITEM m___all        LABEL "Товары на всех весах БД".

DEFINE MENU MENU-b-price
       MENU-ITEM m_scalesman    LABEL "Для весовщика"
       MENU-ITEM m_normal       LABEL "Обычный"       .

DEFINE MENU MENU-B-purg
       MENU-ITEM m_all          LABEL "Полностью"
       MENU-ITEM m_selective    LABEL "Выборочно"     .

DEFINE MENU MENU-B-rum
       MENU-ITEM m_xml-file-export LABEL "Экспорт в XML-файл"
       RULE
       MENU-ITEM m_xml-file-import LABEL "Импорт из XML-файла".

DEFINE MENU MENU-B-send
       MENU-ITEM m_send_all     LABEL "Все"
       MENU-ITEM m_send_changed LABEL "Измененные"
       MENU-ITEM m_send_selective LABEL "Выборочно"
       RULE
       MENU-ITEM m_send_resend  LABEL "Повторно"      .


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-attr
     LABEL "&Атрибуты"
     SIZE 10 BY 1.

DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-gds
     LABEL "&Товары"
     SIZE 10 BY 1.

DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON B-on
     LABEL "&Статус"
     SIZE 10 BY 1.

DEFINE BUTTON b-price
     LABEL "Пра&йслист"
     SIZE 10 BY 1.

DEFINE BUTTON B-purg
     LABEL "&Очистить"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-rum
     LABEL "&Операции над весами"
     SIZE 20 BY 1.

DEFINE BUTTON b-scal-grp
     LABEL "&Группы"
     SIZE 10 BY 1.

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE BUTTON B-send
     LABEL "Пере&слать"
     SIZE 10 BY 1.

DEFINE BUTTON b-ticket
     LABEL "&Ценники"
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 10  NO-UNDO.

DEFINE VARIABLE Rs-object AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", "All",
          "БД", "db",
"Объект", "object"
     SIZE 19 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-scales FOR
      ub.scales SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-scales
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-scales Dialog-Frame _STRUCTURED
  QUERY BR-scales DISPLAY
      IF ( CAN-DO (rid-list, STRING ( recid( scales ) ) ) ) THEN ("*") ELSE (" ") COLUMN-LABEL " *" FORMAT "X(1)":U
      ub.scales.to-send COLUMN-LABEL "И" FORMAT "+/":U
      ub.scales.scales-num FORMAT ">>9":U
      ub.scales.master FORMAT ">>9":U
      ub.scales.scales-name FORMAT "X(35)":U
      ub.scales.tot-gds FORMAT ">>,>>9":U
      {&status-int-name} COLUMN-LABEL "Статус" FORMAT "X(8)":U
      ub.scales.max-gds FORMAT ">>,>>9":U
      ub.scales.scales-type FORMAT "X(15)":U
      ub.scales.address FORMAT "X(25)":U
      ub.scales.unit-base COLUMN-LABEL "Ед.изм." FORMAT "X(3)":U
      ub.scales.db-num FORMAT ">>>>9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 18.93.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-sel AT ROW 1 COL 11
     B-mark AT ROW 1 COL 21
     B-add AT ROW 1 COL 24
     B-chg AT ROW 1 COL 34
     B-del AT ROW 1 COL 44
     B-gds AT ROW 1 COL 54
     b-price AT ROW 1 COL 64
     b-scal-grp AT ROW 1 COL 74 WIDGET-ID 2
     B-hist AT ROW 1 COL 92
     B-help AT ROW 1 COL 95
     B-on AT ROW 2 COL 34
     B-purg AT ROW 2 COL 44
     B-send AT ROW 2 COL 54
     b-ticket AT ROW 2 COL 64
     B-rum AT ROW 2 COL 74 WIDGET-ID 4
     Rs-object AT ROW 3 COL 10.5 NO-LABEL WIDGET-ID 6
     B-attr AT ROW 3 COL 74
     BR-scales AT ROW 4.67 COL 1
     mark-num AT ROW 2.13 COL 18.6 COLON-ALIGNED NO-LABEL
     SPACE(72.40) SKIP(20.47)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Справочник весов"
         DEFAULT-BUTTON b-quit.


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
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-scales B-attr Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-attr:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-attr:HANDLE.

ASSIGN
       B-gds:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-gds:HANDLE.

ASSIGN
       b-price:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-price:HANDLE.

ASSIGN
       B-purg:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-purg:HANDLE.

ASSIGN
       B-rum:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-rum:HANDLE.

ASSIGN
       B-send:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-send:HANDLE.

ASSIGN
       scales.address:AUTO-RESIZE IN BROWSE BR-scales = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-scales
/* Query rebuild information for BROWSE BR-scales
     _TblList          = "ub.scales"
     _FldNameList[1]   > "_<CALC>"
"IF ( CAN-DO (rid-list, STRING ( recid( scales ) ) ) ) THEN (""*"") ELSE ("" "")" " *" "X(1)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > ub.scales.to-send
"to-send" "И" "+/" "logical" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   = ub.scales.scales-num
     _FldNameList[4]   = ub.scales.master
     _FldNameList[5]   > ub.scales.scales-name
"scales-name" ? "X(35)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   = ub.scales.tot-gds
     _FldNameList[7]   > "_<CALC>"
"{&status-int-name}" "Статус" "X(8)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[8]   = ub.scales.max-gds
     _FldNameList[9]   > ub.scales.scales-type
"scales-type" ? "X(15)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[10]   > ub.scales.address
"address" ? "X(25)" "character" ? ? ? ? ? ? no ? no no ? yes yes no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[11]   > ub.scales.unit-base
"unit-base" "Ед.изм." ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[12]   = ub.scales.db-num
     _Query            is NOT OPENED
*/  /* BROWSE BR-scales */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Справочник весов */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
 define variable glog as logical no-undo .
 define variable jj as integer no-undo .
 define variable v-rid as recid no-undo .
 
 /* проверка максимального кол-ва включенных весов в базе */    
 def var conf-par as char no-undo.
 def var par-type as char no-undo.
    
 def buffer bf_scales for ub.scales.
    
    { gbl/conf-rd.i
      "'num-scls'"
      "''"
      "''"
      0
      "''"
      "''"
      "''":U
      yes
      conf-par
      par-type
      no-error
    }
    if error-status:error then do:
        message subst("&1~n&2~n&3~n&4", "Ошибка при получении конф. параметра num-scls", return-value, error-status:GET-MESSAGE (1), ERROR-STATUS:GET-MESSAGE (2))
        	view-as alert-box.
        return.
    end.
    
    if conf-par = "0" then do:
        message "Конф. параметр num-scls запрещает использовать весы."
            view-as alert-box.
        return.
    end.
 
    jj = br-scales:FOCUSED-ROW .
    run ref/scalesi.w (
                   input parparentproc
                  ,input p-obj-type
                  ,input p-obj-code
                  ,input {&add-def}
                  ,input v-cntxt-db-num
                  ,input 0
                  ,output v-rid
                  ) no-error .
    if NOT error-status:error
    and v-rid <> ?
    then do:
      Run Openbr in this-procedure .
      REPOSITION br-scales to recid v-rid no-error .
      APPLY "ENTRY" to br-scales.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr Dialog-Frame
ON CHOOSE OF B-attr IN FRAME Dialog-Frame /* Атрибуты */
DO:
    if not available ub.scales THEN return no-apply.
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  if attr-option = "":U then do:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if attr-option = "":U then do:
      return no-apply.
  end.
  IF attr-option = {&UPDATE} THEN DO:
    { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_scales_update':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    glog
    }
    if NOT glog then return no-apply.
  END.
  run ref/scl-atti.w (  input parparentproc
                  ,input attr-option
                  ,input ub.scales.db-num
                  ,input ub.scales.scales-num
                 ) NO-ERROR.
  attr-option = "":U.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
define variable v-doc-rec as recid no-undo .
define variable v-rid as recid no-undo .
  if available ub.scales then do:
    assign
    v-doc-rec = recid(scales)
    v-rid = recid(scales)
    .
    run ref/scalesi.w (
                  input parparentproc
                  ,input p-obj-type
                  ,input p-obj-code
                  ,input {&update}
                  ,input scales.db-num
                  ,input scales.scales-num
                  ,output v-rid
                    ) no-error .
    if NOT error-status:error then do:
      Run Openbr in this-procedure .
      reposition br-scales to recid v-doc-rec no-error .
      apply "entry" to br-scales in frame {&frame-name} .
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
define variable glog as logical no-undo .
define variable v-doc-rec as recid no-undo .
if not available ub.scales then do:
  message "Весы не выбраны.".
  return no-apply.
end.
if can-find ( first ub.scales-gds WHERE
                    ub.scales-gds.db-num = scales.db-num
                AND ub.scales-gds.scales-num = scales.scales-num ) then do:
    message "Есть товары на весах. Удаление невозможно."
    view-as alert-box ERROR .
    return no-apply.
end.
glog = no.
message "Удаление весов. Вы уверены ?"
view-as alert-box question buttons OK-Cancel update glog.
if not glog then return no-apply.
glog = no.
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_scales_deletion':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  true
  glog
}
if not glog then return no-apply.
v-doc-rec = recid (scales).
find scales WHERE recid (scales) = v-doc-rec exclusive.
delete scales.
RUN MyEnable.
apply "entry" to br-scales in frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-gds Dialog-Frame
ON CHOOSE OF B-gds IN FRAME Dialog-Frame /* Товары */
DO:
define variable goods-lst as character no-undo .
   if Gds-Option = "" then
    run gbl/pop-up.p (self:handle, yes) no-error.
    if Gds-Option = "" then return no-apply.

    case Gds-Option:
        when "ONE":U then do:
            if available ub.scales then do:
                if ub.scales.master > 0 then do:
                    message "Просмотр и изменения товаров на подчиненных весах невозможен"
                    view-as alert-box.
                    Gds-Option = "".
                    return no-apply.
                end.
                ri = recid( ub.scales ) .
                run ref/scalelst.w (
                                input parparentproc
                              , input p-obj-type
                              , input p-obj-code
                              , input scales.db-num
                              , input scales.scales-num
                              , input "b-chg"
                              , input {&all}
                              , input-output goods-lst ) .

                RUN MyEnable.
                apply "entry" to br-scales in frame {&frame-name} .
                reposition br-scales to recid ri no-error. 
                /*no-error , чтобы не выскакивало "Не могу репозиционировать выборку 
                BR-scales на указанный(е) recid/rowid(s). (7331) "*/
           end.
        end.
        when "ALL":U then do:
            if available ub.scales AND can-find( first ub.scales-gds ) then
            run ref/scalegds.w (
                            input parparentproc
                          , input p-obj-type
                          , input p-obj-code
                          , input scales.db-num
                          ).

            else
            message "В системе не прописаны ни одни весы." SKIP
                    "или нет товаров на весах"
            view-as alert-box WARNING .
        end.
    END CASE.
     Gds-Option = "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
  define variable rid-list as character no-undo .
    if available ub.scales THEN
    run ref/cscales.w (
                         input parparentproc
                       , INPUT "":U /*bttns*/
                       , INPUT "one":U /*parref-mode*/
                       , OUTPUT  rid-list
                       , INPUT ub.scales.db-num
                       , input ub.scales.scales-num
                       , input "":U /*p-subject*/
                        ).
    apply "entry" to br-scales.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable glog as logical no-undo .
    if available ub.scales then do:
      { gbl/markstrn.i scales rid-list }
      glog = br-scales:refresh() .

      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        glog = br-scales:select-next-row ().
        apply "iteration-changed" to br-scales in frame {&frame-name}.
      end.
      if num-entries( rid-list ) = 0 then
      hide mark-num in frame {&frame-name}.
      else
      disp num-entries( rid-list ) @ mark-num with frame {&frame-name}.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-on
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-on Dialog-Frame
ON CHOOSE OF B-on IN FRAME Dialog-Frame /* Статус */
DO:
  RUN proc-b-on IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-price
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-price Dialog-Frame
ON CHOOSE OF b-price IN FRAME Dialog-Frame /* Прайслист */
DO:
define variable g#report-num as integer no-undo .
define variable glog as logical no-undo .

if not available ub.scales then do:
    message "Весы не выбраны." view-as alert-box WARNING .
    PrintOption = "".
    return no-apply.
end.

if ub.scales.master > 0 then do:
    message "Печать прайс-листа осуществляется только на главныx весах"
    view-as alert-box.
    PrintOption = "".
    return no-apply.
end.


if NOT can-find( first ub.scales-gds where
                       ub.scales-gds.db-num = ub.scales.db-num
                   AND ub.scales-gds.scales-num = ub.scales.scales-num ) then do:
    message
    substitute("НЕТ товаров на весах с номером &1 (БД &2)!"
               ,ub.scales.scales-num
               ,ub.scales.db-num )
    view-as alert-box information .
    PrintOption = "".
    return no-apply.
end.


if PrintOption = "" then do:
   run gbl/pop-up.p (self:handle, yes) no-error.
end.
if PrintOption = "" then return no-apply.
if ub.scales.db-num = v-cntxt-db-num then do:
  RUN ProcPricePrint in this-procedure  ( input PrintOption
                                        ,buffer ub.scales) No-ERROR.
end.
else do:
  RUN ProcPricePrint-db in this-procedure  ( input PrintOption
                                        ,buffer ub.scales) No-ERROR.

end.
IF error-status:error then do:
  PrintOption = "".
  return no-apply.
end.
if PrintOption = "scalesman":U then do:
   run get-report-num  in parParentProc(output g#report-num).
    run adecomm/_osprint.p ( INPUT  ?,
                             INPUT  string( session:temp-directory + {&DF_Name} + string( g#report-num ) ),
                             INPUT  8,
                             INPUT  2,
                             INPUT  0,
                             INPUT  0,
                             OUTPUT glog ).
end.
else do:
  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input 0
                                            ).
end.
PrintOption = "".
apply "entry" to br-scales in frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-purg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-purg Dialog-Frame
ON CHOOSE OF B-purg IN FRAME Dialog-Frame /* Очистить */
DO:
define variable glog as logical no-undo .
    if PurgOption = "" then
    run gbl/pop-up.p (self:handle, yes) no-error.
    if PurgOption = "" then return no-apply.

    if NOT available ub.scales then do:
            message "Весы не выбраны." view-as alert-box ERROR .
            PurgOption = "".
            return no-apply.
    end.
    if ub.scales.master > 0 then do:
        message "Очистка подчиненных весов осуществляется при очистке главных весов"
        view-as alert-box.
        PurgOption = "".
        return no-apply.
    end.
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_scales_sending':U
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      true
      glog
    }
    if NOT glog then dO:
        PurgOption = "".
        return no-apply.
    end.
    run purg-proc in this-procedure ( buffer scales
                                    , input PurgOption) no-error.
    if error-status:error then do:
      PurgOption = "".
      return no-apply.
    end.
    PurgOption = "".
    apply "entry" to br-scales in frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-rum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-rum Dialog-Frame
ON CHOOSE OF B-rum IN FRAME Dialog-Frame /* Операции над весами */
DO:
  if rum-option = "":U then do:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if rum-option = "":U then do:
      return no-apply.
  end.
  RUN proc-b-rum IN THIS-PROCEDURE ( INPUT rum-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      rum-option = "".
      RETURN NO-APPLY.
  END.
  rum-option = "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-scal-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-scal-grp Dialog-Frame
ON CHOOSE OF b-scal-grp IN FRAME Dialog-Frame /* Группы */
DO:
  IF NOT AVAILABLE ub.scales THEN RETURN NO-APPLY.
  RUN proc-b-scal-grp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
      if rid-list = "" then do:
            if available ub.scales then
                rid-list = string( recid( ub.scales ) ) .
      end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-send
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-send Dialog-Frame
ON CHOOSE OF B-send IN FRAME Dialog-Frame /* Переслать */
DO:
define variable scales-rid as recid no-undo.
define variable glog as logical no-undo .
define variable object-option as character no-undo .
define variable choice as integer no-undo .
define variable goods-lst as character no-undo .
define buffer b-scales for ub.scales.

if SendOption = "" then
run gbl/pop-up.p (self:handle, yes) no-error.
if SendOption = "" then return no-apply.
if not available ub.scales then do:
    message "Весы не выбраны.".
    SendOption = "".
    return no-apply.
end.
if ub.scales.master > 0 then do:
    message
    "Пересылка товаров на подчиненные весы осуществляется при пересылке товаров на главные весы"
    view-as alert-box.
    SendOption = "".
    return no-apply.
end.
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_scales_sending':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  true
  glog
}
if NOT glog then do:
    SendOption = "".
    return no-apply.
end.
if SendOption = "SELECTIVE":U then do:
  run ref/scalelst.w ( input parparentproc
                , input p-obj-type
                , input p-obj-code
                , input v-cntxt-db-num
                , input scales.scales-num
                , input "b-sel,b-mark"
                , input {&all}
                , input-output goods-lst ) .
  if goods-lst = '':U then do:
    return no-apply.
  end.
  send-rid-list = goods-lst.
end. /*if SendOption = "SELECTIVE":U then do:*/
else do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_scales_another_obj':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    glog
  }
  if glog then do :
  run gbl/d-askw.w (input "Выбор товаров на весах"
              ,input substitute("Выберите товары на весах №&1 &2"
                                ,scales.scales-num
                                ,scales.scales-name
                                )
              ,input "|"
              ,input substitute("&1&2|Все|Отказ"
                                , p-obj-type
                                , p-obj-code)
              ,input "По текущему объекту|По всем объектам|Отказ"
              ,input 1
              ,input 3
              ,output choice).


  if choice = 3 then do:
    SendOption = "".
    return no-apply.
  end.
  IF choice = 1 THEN OBJECT-option = {&CURRENT}.
  IF choice = 2 THEN OBJECT-option = {&all}.
end.
  else do :
    run gbl/d-askw.w (input "Выбор товаров на весах"
                ,input substitute("Выберите товары на весах №&1 &2"
                                  ,scales.scales-num
                                  ,scales.scales-name
                                  )
                ,input "|"
                ,input substitute("&1&2|Отказ"
                                  , p-obj-type
                                  , p-obj-code)
                ,input "По текущему объекту|Отказ"
                ,input 1
                ,input 2
                ,output choice).


    if choice = 2 then do:
      SendOption = "".
      return no-apply.
    end.
    IF choice = 1 THEN OBJECT-option = {&CURRENT}.
  end.
end.
run str/diallog.w (
      input parparentproc
    , input this-procedure
    , input "ref/sendscal.p":U
    , input (p-obj-type + {&delim-par} + string(p-obj-code) + {&delim-par} + string(recid(scales)) + {&delim-par} +
              sendoption + {&delim-par} + send-rid-list + {&delim-par} + object-option + {&delim-par} +
              string(0)
              )
    , input no /*p-auto-go*/
    , input "":U
    , input substitute("Отсылка данных на весы")
) no-error.
if error-status:error then do:
    Sendoption = "".
    return no-apply.
end.
IF can-find(first b-scales where
                     b-scales.master = scales.scales-num
                 AND b-scales.db-num = scales.db-num) then do:
  scales-rid = recid(scales).
  run openbr in this-procedure .
  reposition br-scales to recid scales-rid NO-ERROR.
end.
else do:
  DISPLAY
  scales.to-send
  scales.tot-gds
  with BROWSE br-scales .
end.
DISPLAY
scales.to-send
with BROWSE br-scales .
SendOption = "".
apply "entry" to br-scales in frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-ticket
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-ticket Dialog-Frame
ON CHOOSE OF b-ticket IN FRAME Dialog-Frame /* Ценники */
DO:
    if available ub.scales
    then do:
      if ub.scales.master > 0 then do:
          message "Печать ценников осуществляется только на главныx весах"
          view-as alert-box.
          return no-apply.
      end.
      if ub.scales.db-num <> v-cntxt-db-num then do:
          message "Печать ценников осуществляется только в БД весов"
          view-as alert-box.
          return no-apply.

      end.
      run rep/tick-scl.p (
                      input parparentproc
                      ,input p-obj-type
                      ,input p-obj-code
                      ,?
                      ,scales.db-num
                      ,scales.scales-num
                      ,"" ) .
    end.
    else
        message "Весы не выбраны." view-as alert-box INFORMATION .
    apply "entry" to br-scales in frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-scales
&Scoped-define SELF-NAME BR-scales
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-scales Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF BR-scales IN FRAME Dialog-Frame
DO:
    if can-do( bttns, "b-sel" ) then
        apply "choose" to b-sel in frame {&frame-name} .
    else
        apply "choose" to b-gds in frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-scales Dialog-Frame
ON RETURN OF BR-scales IN FRAME Dialog-Frame
DO:
    if can-do( bttns, "b-sel" ) then
        apply "choose" to b-sel in frame {&frame-name} .
    else
        apply "choose" to b-gds in frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME MENU-B-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL MENU-B-gds Dialog-Frame
ON MENU-DROP OF MENU MENU-B-gds
DO:
  Gds-Option = "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME MENU-b-price
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL MENU-b-price Dialog-Frame
ON MENU-DROP OF MENU MENU-b-price
DO:
  PrintOption = "".

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME MENU-B-purg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL MENU-B-purg Dialog-Frame
ON MENU-DROP OF MENU MENU-B-purg
DO:
  PurgOption = "".

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME MENU-B-send
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL MENU-B-send Dialog-Frame
ON MENU-DROP OF MENU MENU-B-send
DO:
    SendOption = "".

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_all Dialog-Frame
ON CHOOSE OF MENU-ITEM m_all /* Полностью */
DO:
  assign
  PurgOption = "ALL":U.
  APPLY "CHOOSE" to b-purg in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_lookup Dialog-Frame
ON CHOOSE OF MENU-ITEM m_lookup /* Просмотр */
DO:
      assign
  ATTR-option = {&LOOKUP}
  .
  APPLY "CHOOSE" TO b-attr IN FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_normal
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_normal Dialog-Frame
ON CHOOSE OF MENU-ITEM m_normal /* Обычный */
DO:
  assign
  PRintOption = "NORMAL":U.
  APPLY "CHOOSE" to b-price  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_scalesman
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_scalesman Dialog-Frame
ON CHOOSE OF MENU-ITEM m_scalesman /* Для весовщика */
DO:
  assign
  PrintOption = "scalesman":U.
  APPLY "CHOOSE" to b-price  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_selective
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_selective Dialog-Frame
ON CHOOSE OF MENU-ITEM m_selective /* Выборочно */
DO:
  assign
  PurgOption = "selective":U.
  APPLY "CHOOSE" to b-purg  in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_send_all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_send_all Dialog-Frame
ON CHOOSE OF MENU-ITEM m_send_all /* Все */
DO:
  assign
  SendOption = "ALL":U.
  APPLY "CHOOSE" to b-send  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_send_changed
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_send_changed Dialog-Frame
ON CHOOSE OF MENU-ITEM m_send_changed /* Измененные */
DO:
  assign
  SendOption = "CHANGED":U.
  APPLY "CHOOSE" to b-send  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_send_resend
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_send_resend Dialog-Frame
ON CHOOSE OF MENU-ITEM m_send_resend /* Повторно */
DO:
  assign
  SendOption = "RESEND":U.
  APPLY "CHOOSE" to b-send  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_send_selective
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_send_selective Dialog-Frame
ON CHOOSE OF MENU-ITEM m_send_selective /* Выборочно */
DO:
  assign
  SendOption = "SELECTIVE":U.
  APPLY "CHOOSE" to b-send  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_update
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_update Dialog-Frame
ON CHOOSE OF MENU-ITEM m_update /* Изменение */
DO:
      assign
  ATTR-option = {&UPDATE}
  .
  APPLY "CHOOSE" TO b-attr IN FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_xml-file-export
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_xml-file-export Dialog-Frame
ON CHOOSE OF MENU-ITEM m_xml-file-export /* Экспорт в XML-файл */
DO:
  rum-option = {&thref-proc_batchwork-export}.
  RUN proc-b-rum IN THIS-PROCEDURE ( INPUT rum-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      rum-option = "".
      RETURN NO-APPLY.
  END.
  rum-option = "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_xml-file-import
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_xml-file-import Dialog-Frame
ON CHOOSE OF MENU-ITEM m_xml-file-import /* Импорт из XML-файла */
DO:
  rum-option = {&cli-grp-proc_xml-file-import}.
  RUN proc-b-rum IN THIS-PROCEDURE ( INPUT rum-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      rum-option = "".
      RETURN NO-APPLY.
  END.
  rum-option = "".

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m___all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m___all Dialog-Frame
ON CHOOSE OF MENU-ITEM m___all /* Товары на всех весах БД */
DO:
  assign
  Gds-Option = "ALL":U.
  APPLY "CHOOSE" to b-gds  in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m___one
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m___one Dialog-Frame
ON CHOOSE OF MENU-ITEM m___one /* Товары на весах */
DO:
  assign
  Gds-Option = "ONE":U.
  APPLY "CHOOSE" to b-gds  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Rs-object
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Rs-object Dialog-Frame
ON VALUE-CHANGED OF Rs-object IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE v-rec AS RECID NO-UNDO.
  DEFINE VARIABLE glog  AS LOGICAL NO-UNDO.
  assign
    rs-object
    v-mode = rs-object
  .
  if p-obj-type = {&shop} then do :
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_scales_another_obj':U
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      true
      glog
    }
    if not glog and (rs-object = {&all} or rs-object = 'db') then do :
      assign
        rs-object = {&g___object}
        v-mode = rs-object
      .
    end.
  end.
  display
    rs-object
  WITH FRAME {&FRAME-NAME} .
  IF AVAILABLE scales  THEN DO:
      v-rec = RECID(scales).
  END.
  RUN openbr IN THIS-PROCEDURE  .
  REPOSITION br-scales  TO RECID v-rec NO-ERROR.
  APPLY "entry" TO br-scales.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-del }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/brwrepos.i
  &line-num=5}
{ gbl/brwrefre.i "v-rec = recid(ub.scales). run Openbr in this-procedure. reposition br-scales to recid v-rec NO-ERROR. v-rec = ?. ~
               APPLY 'ENTRY' to br-scales. APPLY 'VALUE-CHANGED' to br-scales. " }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  CASE p-mode:
   WHEN {&all}        THEN DO:
    END.
    when "db":U then do:
    end.
    otherwise do:
            message vss-workfile vss-revision vss-description skip
        "Неверный вызов - p-mode=" p-mode
        view-as alert-box ERROR.
        return.
      end.
    end case.
    v-mode = p-mode.
    RUN MyEnable.
    apply "entry" to br-scales in frame {&frame-name} .
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
  DISPLAY Rs-object mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-sel B-mark B-add B-chg B-del B-gds b-price b-scal-grp B-hist
         B-help B-on B-purg B-send b-ticket B-rum Rs-object B-attr BR-scales
         mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
define variable glog as logical no-undo initial true.
ASSIGN
b-attr:MENU-MOUSE IN frame {&FRAME-NAME} = 1
MENU-ITEM m_update:SENSITIVE IN MENU menu-b-attr = (p-mode = 'db')
b-rum:MENU-MOUSE in frame {&frame-name} =  1
MENU-ITEM m_xml-file-import:SENSITIVE IN MENU menu-b-rum = no
.
if p-obj-type = {&shop} then do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_scales_another_obj':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    false
    glog
  }
    rs-object:RADIO-BUTTONS IN FRAME {&FRAME-NAME} = (IF p-mode = {&ALL} AND v-cntxt-db-num = 0
                                                      THEN ("Все" + {&comma-char} + {&all} + {&comma-char} +
                                                          "БД" + {&comma-char} + 'db':U + {&comma-char} +
                                                            p-obj-type + string(p-obj-code) + {&comma-char} + {&g___object})
                                                      ELSE ("БД" + {&comma-char} + 'db':U + {&comma-char} +
                                                            p-obj-type + string(p-obj-code) + {&comma-char} + {&g___object}))
    .
  if p-mode = {&ALL} then  do :
    v-mode = p-mode .
  end.
  else do :
    v-mode = 'db' .
  end.
  if glog = true and p-mode = {&ALL} AND v-cntxt-db-num = 0 then do :
    assign
      v-mode = {&all}
      rs-object = {&all}
    .
  end.
    else do: 
      if glog = true then do: 
        assign rs-object = {&attr-db}    
               v-mode = {&attr-db}.    
      end.
      else do: 
        assign rs-object = {&g___object}  
               v-mode = {&g___object}.
      end.
    end.
  if not glog then do :
    MENU-ITEM m___all:SENSITIVE in MENU menu-b-gds = no .
  end.
end.
else do:
  rs-object:RADIO-BUTTONS IN FRAME {&FRAME-NAME} = (IF p-mode = {&ALL} AND v-cntxt-db-num = 0
                                                    THEN ("Все" + {&comma-char} + {&all} + {&comma-char} +
                                                        "БД" + {&comma-char} + 'db':U )
                                                    ELSE ("БД" + {&comma-char} + 'db':U + {&comma-char}
                                                          ))
  .
    if p-mode = {&ALL} then  do :
      v-mode = p-mode .
end.
    else do :
      v-mode = 'db' .
    end.
end.



DISPLAY
rs-object
mark-num
WITH FRAME {&frame-name}.
ENABLE
b-mark
b-sel
b-gds
b-send when p-mode = 'db':U
b-quit
b-price
b-help
b-chg  when p-mode = 'db':U
b-purg  when p-mode = 'db':U
b-add   when p-mode = 'db':U
b-del   when p-mode = 'db':U
b-on    when p-mode = 'db':U
b-rum
b-scal-grp
b-hist
br-scales
b-attr
mark-num
b-ticket when p-mode = 'db':U
rs-object
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
RUN Openbr IN THIS-PROCEDURE.
DISABLE
b-mark WHEN NOT can-do( bttns, "b-mark" )
b-sel WHEN NOT can-do( bttns, "b-sel" )
b-send WHEN NOT can-do( bttns, "b-add" )
b-purg WHEN NOT can-do( bttns, "b-add" )
b-chg WHEN NOT can-do( bttns, "b-add" )
b-add WHEN NOT can-do( bttns, "b-add" )
b-del WHEN NOT can-do( bttns, "b-add" )
mark-num WHEN NOT can-do( bttns, "b-mark" )
WITH FRAME {&FRAME-NAME} .
HIDE mark-num in FRAME {&FRAME-NAME} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
 CASE v-mode:
    WHEN {&ALL} THEN DO:
      OPEN QUERY BR-scales FOR EACH ub.scales NO-LOCK.
    END.
    WHEN 'db':U THEN DO:
      OPEN QUERY BR-scales FOR EACH ub.scales NO-LOCK WHERE ub.scales.db-num = v-cntxt-db-num.
    END.
    WHEN {&g___object} THEN DO:
      /*настройка СВОИ ВЕСЫ ДЛЯ объекта*/
      run adm/shattri.p (
          input "get":U
          ,input  p-obj-type
          ,input  p-obj-code
          ,input  {&attr-scale-inf}
          ,input  {&attr-scale-inf_scallist} /*p-param-code*/
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-value-logical
          ,output v-param-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .
      v-scallist = v-value-character.
      delete object v-tth.
/*      IF v-scallist = ''  THEN DO:*/
/*          OPEN QUERY BR-scales FOR EACH*/
/*          ub.scales NO-LOCK WHERE*/
/*          ub.scales.db-num = v-cntxt-db-num.*/
/*      END.*/
/*      ELSE do:*/
          OPEN QUERY BR-scales FOR EACH
          ub.scales NO-LOCK WHERE
          ub.scales.db-num = v-cntxt-db-num
      AND lookup(STRING(ub.scales.scales-num), v-scallist) > 0 .
          .
/*    END. /*g___object*/*/
  END.

END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-on Dialog-Frame
PROCEDURE proc-b-on :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE loc#log AS LOGICAL NO-UNDO.
DEFINE VARIABLE loc-doc-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-sts LIKE ub.scales.sts NO-UNDO.
do
on error undo, return error
on stop undo, return error

:
loc#log = no.
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_scales_deletion':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  true
  loc#log
}
if not loc#log then return error.
  assign
  v-sts = ?
  loc-doc-rec = RECID(ub.scales)
  .
  run ref/scales2.p (
                  input recid(scales)
                  ,input-output v-sts
                 ) no-error .
  if error-status:error then do:
     MESSAGE
     "Ошибка при изменении статуса ВЕСОВ"
     RETURN-VALUE skip
     error-status:get-message(1)
     VIEW-AS ALERT-BOX.
      undo, return error.
  END.
  run openbr in this-procedure.
  REPOSITION br-scales To recid loc-doc-rec No-error.
if available scales then do:
    loc#log = br-scales:select-focused-row( ) IN FRAME {&FRAME-NAME}.
  end.
  apply "ENTRY" to br-scales.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-rum Dialog-Frame
PROCEDURE proc-b-rum :
define input parameter p-rum-option as character no-undo .
define variable v-radio-button-parameter as character no-undo .
if p-rum-option = {&thref-proc_xml-file-import} then do:
  v-radio-button-parameter = {&thref-proc_xml-file-import}.
end.
else do:
  v-radio-button-parameter = {&thref-proc_batchwork-export}  .
end.
run str/diallog.w (
      input parParentProc
    , input this-procedure
    , input "utl/thbjrumr.w":U
    , input {&thref} + {&delim-par} + v-radio-button-parameter /*parameter - второй элемент списка - это radio-buttons rs-ruleset d thbjrumr*/
    , input no /*p-auto-go*/
    , input "&Стоп"
    , input substitute("Операции над весами") ) no-error .
if p-rum-option = {&thref-proc_xml-file-import} then do:
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-scal-grp Dialog-Frame
PROCEDURE proc-b-scal-grp :
run ref/scal-grp.w (
                input parparentproc
              , input (if v-cntxt-db-num = ub.scales.db-num
                       then 'b-add'
                       else '':U)
              , input v-cntxt-obj-type
              , input v-cntxt-obj-code
              , input {&table_scales}
              , input ub.scales.db-num
              , input ub.scales.scales-num
              , input 0 /*p-node-code*/ ) no-error .
if error-status :error
then do:
    undo, return error return-value.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Purg-proc Dialog-Frame
PROCEDURE Purg-proc :
DEFINE parameter buffer loc-scales for ub.scales.
DEFINE INPUT PARAMETER loc-PurgOption as char no-undo.
DEFINE var loc-goods-lst as char no-undo.
define variable qnty-buf as integer no-undo .
define variable for-qnty as character no-undo .
define variable scales-rid as recid no-undo.
define variable glog as logical no-undo .
define buffer b-scales for ub.scales.
glog = FALSE .
if loc-PurgOption = "ALL":U then do:
  message
  substitute("Вы намерены полностью очистить&1"  +
              "весы № &2&1" +
              "Продолжать ?&1"
              ,{&new-line}
              ,loc-scales.scales-num)
  view-as alert-box warning buttons yes-no update glog .
end.
else do:
  if can-find(first ub.scales-gds no-lock where
                   ub.scales-gds.scales-num = loc-scales.scales-num
               AND ub.scales-gds.db-num = loc-scales.db-num ) then do:
    assign
    loc-goods-lst = '':U
    .
    run ref/scalelst.w (
                      input parparentproc
                    , input p-obj-type
                    , input p-obj-code
                    , input loc-scales.db-num
                    , input loc-scales.scales-num
                    , input "b-sel,b-mark"
                    , input {&all}
                    , input-output loc-goods-lst ) .
    if loc-goods-lst <> "" then do:
        message
        "Вы уверены, что хотите удалить с весов выбранные товары!"
        view-as alert-box QUESTION buttons YES-NO update glog.
    end.
    else do:
        message
        "Не найдено товаров, выбранных для очистки!"
        view-as alert-box.
        loc-PurgOption = "".
        return error.
    end.
  end.
end.
if NOT glog then do:
  loc-PurgOption = "".
  return error.
end.
FOR EACH gds-list :
  delete gds-list .
END .
if loc-scales.max-plu = 0 then do:
  if can-find(first ub.scales-gds no-lock where
                    ub.scales-gds.scales-num = loc-scales.scales-num
                AND ub.scales-gds.db-num = loc-scales.db-num) then do:
    message
    substitute("В списке товаров на весах есть товар&1" +
               "но значение поля КОЛИЧЕСТВО ТОВАРА НА ВЕСАХ = 0&1" +
               "вы можете очистить весы, задав количество удаляемых товаров", {&new-line})
    view-as alert-box WARNING.
  end.
  assign
  qnty-buf = loc-scales.max-gds
  for-qnty = string(qnty-buf)
  .
  run gbl/d-prompt.w (
    'title=':u + "Сколько удалить" + '\':u
  + 'text1=':u + " Удалить товаров ( начиная с 1-го )" + '\':u
  + 'format=' + ">>>9" + '\':u
  + 'type=' + {&type-int} + '\':u
  + 'fillin_row=2\':u
  + 'fillin_col=4\':u
  + 'fillin_width=4\':u
  + 'fillin_height=1\':u
  + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
  + 'readonly=no\':u
  , input-output for-qnty
  ).
  if return-value = 'false':u then do:
    loc-PurgOption = "".
    return error.
  end.
  qnty-buf = integer(for-qnty).
  if qnty-buf > loc-scales.max-gds then do:
    glog = FALSE .
    message
    substitute("Превышена величина&1"  +
              "максимально допустимой номенклатуры товаров&1"  +
              "для данной марки весов.&1" +
              "Вас это устраивает ?&1&1"
              , {&new-line})
            view-as alert-box warning buttons yes-no update glog .
    if NOT glog then do:
        loc-PurgOption = "".
        return error.
    end.
  end.
end.
 else qnty-buf = loc-scales.max-plu .
 run str/diallog.w (
        input parparentproc
      , input this-procedure
      , input "ref/sendscal.p":U
      , input (p-obj-type + {&delim-par} + string(p-obj-code) + {&delim-par} + string(recid(ub.scales)) + {&delim-par} +
                "purge-" + loc-purgoption + {&delim-par} + loc-goods-lst + {&delim-par} + '':U + {&delim-par} +
                string(qnty-buf))
      , input no /*p-auto-go*/
      , input "":U
      , input substitute("Очистка весов")
  ) no-error.
IF can-find(first b-scales where
                  b-scales.master = loc-scales.scales-num
              AND b-scales.db-num = loc-scales.db-num) then do:
  scales-rid = recid(b-scales).
  run Openbr in this-procedure .
  reposition br-scales to recid scales-rid NO-ERROR.
end.
else do:
  DISPLAY
  loc-scales.to-send @ scales.to-send
  loc-scales.tot-gds @ scales.tot-gds
  with BROWSE br-scales .
end.
loc-PurgOption = "".
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME