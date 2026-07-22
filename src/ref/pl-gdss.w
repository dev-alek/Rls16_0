&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_goods  FOR goods.
DEFINE BUFFER X_pl-gds FOR pl-gds.
DEFINE BUFFER X_place  FOR place.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Товары на складских местах

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

/*----------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
/*перед вызовом надо установить шареные переменные*/
define input  parameter parparentproc  as widget-handle no-undo .
define input  parameter bttns      as   character           no-undo .
define input  parameter p-obj-type like ub.clients.obj-type no-undo .
define input  parameter p-obj-code like ub.clients.obj-code no-undo .
define input  parameter p-mode     as character no-undo .
define input  parameter p-gds-rec   as recid      no-undo .
define input  parameter p-doc-rec   as recid      no-undo .
/*p-mode - возможные значения {&g___object} {&goods} {&place} {&petrolium}*/
/*если p-mode = {&goods} или {&petrolium} то p-gds-rec = recid(goods)
если p-mode = {&place} то p-define variable  = recid(place)*/
define output parameter p-rid-list   as   character           no-undo . /* список recid'ов выбранных ТРК */


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Товары на складских местах" .
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/flt-def.i }
{ gbl/color.i   }
{ gbl/fltfield.i }
{ gbl/waitfram.i }
{ cmp/mrk-strf.i }
{ gbl/getcntxt.i def }
{ gbl/fltopend.i defproc }
define variable filter-point  as character no-undo init "pl-gdss" .
define variable filter-point0 as character no-undo init "pl-gdss" .
define variable filter-label  as character no-undo init "Товар-Склд. место" .
define variable filter-label0 as character no-undo init "Товар-Склд. место" .
define buffer b-goods for goods.
define buffer b-place for place.
define VARIABLE shop-type           as char      no-undo .
define VARIABLE shop-code           as integer   no-undo .
define VARIABLE gdscode             as integer   no-undo .
define VARIABLE plcode              as integer   no-undo .
define variable sort-column-name    as character no-undo .
define variable v-rid-list          as character no-undo .
define variable v-ok-mode           as character no-undo .
define variable v-chk-act-host-code as integer   no-undo .
define variable glog                as logical   no-undo .
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-pl-gds

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_pl-gds X_goods X_place

/* Definitions for BROWSE BR-pl-gds                                     */
&Scoped-define FIELDS-IN-QUERY-BR-pl-gds mark-string(RECID(X_pl-gds), v-rid-list) X_pl-gds.pl-code X_place.pl-name X_place.loc1 X_place.loc2 X_place.loc3 X_place.loc4 X_pl-gds.gds-code X_goods.artic X_goods.gds-name X_goods.prod-type X_goods.prod-code X_pl-gds.free-qnty X_pl-gds.fact-qnty X_pl-gds.cli-free-qnty X_pl-gds.cli-fact-qnty X_pl-gds.tolerance X_pl-gds.status_
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-pl-gds X_pl-gds.tolerance
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-pl-gds X_pl-gds
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-pl-gds X_pl-gds
&Scoped-define SELF-NAME BR-pl-gds
&Scoped-define QUERY-STRING-BR-pl-gds FOR EACH X_pl-gds NO-LOCK, ~
             EACH X_goods WHERE X_goods.gds-code = X_pl-gds.gds-code NO-LOCK, ~
             EACH X_place WHERE X_place.obj-code = X_pl-gds.obj-code   AND X_place.obj-type = X_pl-gds.obj-type   AND X_place.pl-code = X_pl-gds.pl-code NO-LOCK
&Scoped-define OPEN-QUERY-BR-pl-gds OPEN QUERY {&SELF-NAME} FOR EACH X_pl-gds NO-LOCK, ~
             EACH X_goods WHERE X_goods.gds-code = X_pl-gds.gds-code NO-LOCK, ~
             EACH X_place WHERE X_place.obj-code = X_pl-gds.obj-code   AND X_place.obj-type = X_pl-gds.obj-type   AND X_place.pl-code = X_pl-gds.pl-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-pl-gds X_pl-gds X_goods X_place
&Scoped-define FIRST-TABLE-IN-QUERY-BR-pl-gds X_pl-gds
&Scoped-define SECOND-TABLE-IN-QUERY-BR-pl-gds X_goods
&Scoped-define THIRD-TABLE-IN-QUERY-BR-pl-gds X_place


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-sel B-mark B-add B-chg B-del B-hist ~
B-sch B-Help RECT-tolerance BR-pl-gds mark-num
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
  LABEL "&Добавить"
  SIZE 10 BY 1.

DEFINE BUTTON B-chg
  LABEL "&Изменить"
  SIZE 10 BY 1.

DEFINE BUTTON B-del
  LABEL "&Удалить"
  SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO
  LABEL "&Выход"
  SIZE 10 BY 1
  BGCOLOR 8 .

DEFINE BUTTON B-Help
  LABEL "Помо&щь"
  SIZE 3 BY 1
  BGCOLOR 8 .

DEFINE BUTTON B-hist
  LABEL "Ис&тория"
  SIZE 3 BY 1.

DEFINE BUTTON B-mark
  LABEL "*"
  SIZE 3 BY 1.

DEFINE BUTTON B-sch
  LABEL "&Фильтр"
  SIZE 3 BY 1.

DEFINE BUTTON B-sel AUTO-GO
  LABEL "Вы&бор"
  SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>9":U INITIAL 0
  VIEW-AS TEXT
  SIZE 6.25 BY .67
  FGCOLOR 4 NO-UNDO.

DEFINE RECTANGLE RECT-tolerance
  EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
  SIZE 10.13 BY 1.13
  BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-pl-gds FOR
  X_pl-gds,
  X_goods,
  X_place SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-pl-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-pl-gds Dialog-Frame _FREEFORM
  QUERY BR-pl-gds NO-LOCK DISPLAY
  mark-string(RECID(X_pl-gds), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
  X_pl-gds.pl-code COLUMN-LABEL "Склд.место" FORMAT ">>>>>>>>>>9":U
  X_place.pl-name FORMAT "X(40)":U
  X_place.loc1 FORMAT "X(8)":U
  X_place.loc2 FORMAT "X(8)":U
  X_place.loc3 FORMAT "X(8)":U
  X_place.loc4 FORMAT "X(8)":U
  X_pl-gds.gds-code FORMAT "99999999999":U
  X_goods.artic FORMAT "X(16)":U
  X_goods.gds-name FORMAT "X(48)":U
  X_goods.prod-type FORMAT "X(3)":U
  X_goods.prod-code FORMAT ">>>>>>>>9":U
  X_pl-gds.free-qnty FORMAT "->>,>>>,>>9.999":U
  X_pl-gds.fact-qnty FORMAT "->>,>>>,>>9.999":U
  X_pl-gds.cli-free-qnty FORMAT "->>,>>>,>>9.999":U
  X_pl-gds.cli-fact-qnty FORMAT "->>,>>>,>>9.999":U
  X_pl-gds.tolerance COLUMN-LABEL "Допуст.отклонение" FORMAT "->>,>>>,>>9.<<<":U
  X_pl-gds.status_ FORMAT "X(8)":U
ENABLE
X_pl-gds.tolerance
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 18.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
  B-exit AT ROW 1 COL 1.13
  B-sel AT ROW 1 COL 11
  B-mark AT ROW 1 COL 21
  B-add AT ROW 1 COL 31
  B-chg AT ROW 1 COL 41
  B-del AT ROW 1 COL 51
  B-hist AT ROW 1 COL 89
  B-sch AT ROW 1 COL 92
  B-Help AT ROW 1 COL 95
  BR-pl-gds AT ROW 3.96 COL 1
  mark-num AT ROW 1.17 COL 22.5 COLON-ALIGNED NO-LABEL
  RECT-tolerance AT ROW 1 COL 41
  SPACE(47.87) SKIP(19.99)
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
  TITLE "Товары на складских местах"
  DEFAULT-BUTTON B-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_goods B "?" ? ub goods
      TABLE: X_pl-gds B "?" ? ub pl-gds
      TABLE: X_place B "?" ? ub place
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-pl-gds RECT-tolerance Dialog-Frame */
ASSIGN
  FRAME Dialog-Frame:SCROLLABLE = FALSE
  FRAME Dialog-Frame:HIDDEN     = TRUE.

ASSIGN
  BR-pl-gds:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame = 1.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-pl-gds
/* Query rebuild information for BROWSE BR-pl-gds
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_pl-gds NO-LOCK,
      EACH X_goods WHERE X_goods.gds-code = X_pl-gds.gds-code NO-LOCK,
      EACH X_place WHERE X_place.obj-code = X_pl-gds.obj-code
  AND X_place.obj-type = X_pl-gds.obj-type
  AND X_place.pl-code = X_pl-gds.pl-code NO-LOCK.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY BR-pl-gds FOR
      X_pl-gds,
      X_goods,
      X_place SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* BROWSE BR-pl-gds */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Товары на складских местах */
  DO:
    p-rid-list = v-rid-list.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Товары на складских местах */
  DO:
    APPLY "END-ERROR":U TO SELF.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Выход */
  DO:
    if v-ok-mode <> "" then 
    do:
      case v-ok-mode:
        when {&add-def} then 
          do:
            run trg/userlog.p (
              input {&nwsdochs_action_create}
              , input {&table_pl-gds}
              , input ( buffer X_pl-gds :handle )
              , input ?
              , input ""
              ) no-error.
            if error-status :error
              then
            do:
              undo, return substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                , {&new-line}
                , vss-workfile
                , return-value
                , error-status :get-message ( 1 ) ).
            end.

          end.
        when {&update} then 
          do:
            run trg/userlog.p (
              input {&nwsdochs_action_update}
              , input {&table_pl-gds}
              , input ( buffer X_pl-gds :handle )
              , input ?
              , input ""
              ) no-error.
            if error-status :error
              then
            do:
              undo, return substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                , {&new-line}
                , vss-workfile
                , return-value
                , error-status :get-message ( 1 ) ).
            end.
          end.
      end case.
    end.  

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
  DO:
    define variable loc-rid-list as char    no-undo.
    define variable ii           as integer no-undo.
    define variable kk           as integer no-undo.
    define variable glog         as logical no-undo .
    /*характеристика скл места по бензину - нельзя два бензина в один бак*/
    define variable individ      as logical no-undo.
    define buffer buf_pl-gds for ub.pl-gds .
    define buffer buf_goods  for ub.goods.
    define buffer buf_units  for ub.units.
    { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_place-reference_work':U
  {&cntxt-object}
  v-chk-act-host-code
  p-obj-type
  p-obj-code
  0
  0
  0
  true
  glog
}
    if NOT glog then return no-apply.
    run ref/gds-ref.p (
      input parparentproc
      ,input "b-sel,b-add"
      ,input ?             /*p-stat */
      ,input ?             /*p-list  */
      ,input ?             /*p-cond  */
      ,input ?             /*p-rec   */
      ,input ?             /*p-grp   */
      ,input ?             /*p-cli-type */
      ,input ?             /*p-cli-code  */
      ,input p-obj-type    /*p-obj-type  */
      ,input p-obj-code    /*p-obj-code  */
      ,input ?             /*p-other     */
      ,output loc-rID-list).
    apply "entry" to br-pl-gds in frame {&frame-name}.
    if loc-rid-list = "" then
      return no-apply.
    /* выбран товар */
    run waitfram-show in this-procedure ( input "Ждите...").
    _ii:
    do ii = 1 to num-entries(loc-rid-list):
      find buf_goods where recid (buf_goods) = integer (ENTRY(ii, loc-rid-list)) no-lock.
      if avail buf_goods then 
      do:
        /*если бензин то заливать в один бак два бензина нельзя!*/
        FIND FIRST buf_units No-LOCK where
          buf_units.unit-name = buf_goods.unit-base No-ERROR.
        if not avail buf_units then NEXT.
        if LOOKUP({&petrolium}, buf_units.type) > 0  and lookup({&divisional}, buf_units.type) > 0
          then
          assign
            individ = yes.
        else
          assign
            individ = no.
        do transaction on error undo, next :
          find first buf_pl-gds no-lock
            where buf_pl-gds.obj-type = shop-type
            and buf_pl-gds.obj-code = shop-code
            and buf_pl-gds.pl-code  = plcode
            and buf_pl-gds.gds-code = buf_goods.gds-code no-error.
          if not available buf_pl-gds then 
          do:
            /*нет еще такой связки товар-место*/
            if lookup({&petrolium}, buf_units.type) > 0
              and lookup({&divisional}, buf_units.type) > 0 then 
            do:
              /*топливо*/
              run trg/plgdpmvc.p (
                input  shop-type,
                input  shop-code,
                input  plcode,
                input  buf_goods.gds-code,
                output glog) no-error.
              if error-status:error then 
              do:
                message
                  "Ошибка при привязке товара к резервуару." skip
                  return-value skip
                  error-status:get-message(1)
                  view-as alert-box error.
                undo, next.
              end.
              if not glog then 
              do:
                if return-value <> "" then
                  message return-value view-as alert-box ERROR.
                undo , next .
              end.
              if glog then kk = kk + 1.
            END.
            else 
            do:
              /*нетопливо*/
              run trg/plgdpmv0.p (
                input shop-type,
                input shop-code,
                input plcode,
                input buf_goods.gds-code,
                output glog) no-error.
              if error-status:error then 
              do:
                undo, next.
              end.
              if not glog then 
              do:
                if return-value <> "" then
                  message return-value view-as alert-box ERROR.
                undo , next .
              end.
              if glog then kk = kk + 1.
            end.
          end.
          else 
          do:
            message
              "Уже есть привязка резервуара " buf_pl-gds.pl-code
              " с товаром " buf_goods.artic " " buf_goods.prod-type " " buf_goods.prod-code " " buf_goods.gds-name " ."
              view-as alert-box error.
            next.
          end.
        end. /*fo transact*/
      end. /*avail goods*/
    end. /*do ii = 1 to */
    run waitfram-hide in this-procedure .
    if kk < num-entries(loc-rid-list) then 
    do:
      message
        "Из выбранных " num-entries(loc-rid-list) " товаров " skip
        "к данному складскому месту удалось привязать "
        kk " товаров " view-as alert-box
        WARNING.
    end.
    v-ok-mode = {&add-def} .
    run OpenBr in this-procedure ( input yes, input no, input '':U).
    APPLY "ENTRY" to br-pl-gds.

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
  DO:
        { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_place-reference_work':U
  {&cntxt-object}
  v-chk-act-host-code
  p-obj-type
  p-obj-code
  0
  0
  0
  true
  glog
}
    if NOT glog then return no-apply.
    assign
      X_pl-gds.tolerance :read-only in browse {&BROWSE-NAME} = NOT
  X_pl-gds.tolerance :read-only in browse {&BROWSE-NAME} .
    APPLY "ENTRY" to browse {&BROWSE-NAME}.
    IF  X_pl-gds.tolerance :read-only in browse {&BROWSE-NAME} = FALSE THEN 
    do:
      RECT-tolerance:BGCOLOR = GREEN_COLOR.
      APPLY "ENTRY" to X_pl-gds.tolerance in browse {&BROWSE-NAME}.
    end.
    else 
    do:
      RECT-tolerance:BGCOLOR = GREY_COLOR.
    end.
    v-ok-mode = {&update} .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
  DO:
    define buffer b-pl-gds for pl-gds.
  { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_place-reference_work':U
  {&cntxt-object}
  v-chk-act-host-code
  p-obj-type
  p-obj-code
  0
  0
  0
  true
  glog
  }
    if NOT glog then return no-apply.
    if available X_pl-gds then 
    do:
      _tr:
      do transaction
        on error undo, return no-apply :
        find first b-pl-gds exclusive-lock
          where rowid(b-pl-gds) = rowid(X_pl-gds) .
        delete b-pl-gds no-error.
        if error-status :error then 
        do:
          message
            substitute("Ошибка при удалении привязки товара") skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          return no-apply.
        end.
      end. /*transaction*/

      v-ok-mode = {&deleted} .
      run openbr in this-procedure ( input yes, input no, input '':U).
      apply "entry" to br-pl-gds.
            
    end.
  end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
  DO:
    DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
    IF AVAILABLE X_pl-gds  THEN 
    DO:

      run ref/cplchist.w (
        INPUT parParentProc
        , input p-obj-type
        , input p-obj-code
        , input "":U /*bttns  */
        , input "subject":U /*p-mode*/
        , input X_pl-gds.obj-type
        , input X_pl-gds.obj-code
        , input X_pl-gds.pl-code
        , input X_pl-gds.gds-code /*p-gds-code*/
        , input 0 /*p-pump-code*/
        , input 0 /*p-nozzle-code*/
        , input {&table_pl-gds} /*p-subject*/
        , input-output v-rid-list
        ) no-error .

    END.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
  DO:
    define variable glog as logical no-undo .
    if available X_pl-gds then 
    do:
      { gbl/markstrn.i X_pl-gds v-rid-list }
      br-pl-gds:refresh().
      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then  
      do:
        glog = br-pl-gds:select-next-row ().
        apply "iteration-changed" to br-pl-gds in frame {&frame-name}.
      end.
      if num-entries( v-rid-list ) = 0 then
        hide mark-num in frame {&frame-name}.
      else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
    end.
    apply "entry" to br-pl-gds in frame {&frame-name}.

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
  DO:
    assign
      tbl      = 'pl-gds':U
      join-tbl = 'X_pl-gds':U
      fld      = '':U
      lab      = '':U
      spr      = '':U
      dim      = '0':U
      .

    run fltfield-add in this-procedure('gds-code', '', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('obj-code', '', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('obj-type', '', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('pl-code', '', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('status_', '', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('fact-qnty', '', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('free-qnty', '', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('cli-fact-qnty', '', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('cli-free-qnty', '', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    DO on stop undo, leave:
      run gbl/filter.w ( input parparentproc
        ,input (filter-point + {&delim-par} + filter-label)
        ,input tbl
        ,input join-tbl
        ,input fld
        ,input lab
        ,input spr
        ,input dim).
      RUN OpenBr in this-procedure ( input yes, input no, input '':U).
    END .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
  DO:
    if ( available X_pl-gds AND v-rid-list = "" ) then
      v-rid-list = string( recid( X_pl-gds ) ) .

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-pl-gds
&Scoped-define SELF-NAME BR-pl-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-pl-gds Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF BR-pl-gds IN FRAME Dialog-Frame
  DO:
    if lookup("b-sel", bttns) > 0 then APPLY "CHOOSE" to b-sel.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-pl-gds Dialog-Frame
ON RETURN OF BR-pl-gds IN FRAME Dialog-Frame
  DO:
    if lookup("b-sel", bttns) > 0 then APPLY "CHOOSE" to b-sel.
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

{ gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "X_pl-gds.pl-code"
  &sort-clmn_2    = "X_pl-gds.gds-code"
  &sort-clmn_3    = "X_pl-gds.fact-qnty"
  &sort-clmn_4    = "X_pl-gds.free-qnty"
  &sort-clmn_5    = "X_pl-gds.cli-fact-qnty"
  &sort-clmn_6    = "X_pl-gds.cli-free-qnty"

  &open-query     = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}

{ gbl/setfltnm.i }
{ gbl/getcntxt.i get }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  v-rid-list = p-rid-list.
  assign
    X_pl-gds.tolerance:read-only in browse {&BROWSE-NAME} = true.

  RUN MyENable.
  RUN OpenBR in this-procedure  ( input yes, input no, input '':U).
  { gbl/mv-clmn.i
&browse-name = "br-pl-gds"
&frame-name = "{&frame-name}"
  &start-column = "br-pl-gds:num-locked-columns in frame {&frame-name} "
  &prev-order-column_1 = "'1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18'"
  &prev-order-column-condition_1 = " p-mode = {&g___object} "
  &prev-order-column_2 = "'1,2,3,4,13,14,15,16,17,18,8,9,10,11,12,5,6,7'"
  &prev-order-column-condition_2 = " p-mode = {&petrolium} "
  &prev-order-column_3 = "'1,8,9,10,13,14,15,16,11,12,17,18,2,3,4,5,6,7'"
  &prev-order-column-condition_3 = " p-mode = {&place} "
  &prev-order-column_4 = "'1,2,3,4,13,14,15,16,5,6,7,17,18,8,9,10,11,12'"
  &prev-order-column-condition_4 = " p-mode = {&goods} "
  &ext-col = 18

}
  APPLY "ENTRY" to br-pl-gds.
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
  DISPLAY mark-num
    WITH FRAME Dialog-Frame.
  ENABLE B-exit B-sel B-mark B-add B-chg B-del B-hist B-sch B-Help
    RECT-tolerance BR-pl-gds mark-num
    WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Myenable Dialog-Frame
PROCEDURE Myenable :
  /*------------------------------------------------------------------------------
    Purpose:
    Parameters:  <none>
    Notes:
  ------------------------------------------------------------------------------*/
  ASSIGN
    br-pl-gds:NUM-LOCKED-COLUMNS IN FRAME {&frame-name} = 1.

  DISPLAY
    mark-num
    WITH FRAME Dialog-Frame.
  ENABLE
    B-exit
    B-sel 
    when lookup("b-sel", bttns) > 0
    B-mark 
    when lookup("b-mark", bttns) > 0
    b-add 
    when lookup("b-add", bttns) > 0 and p-mode = {&place}
    b-del 
    when lookup("b-add", bttns) > 0 and p-mode = {&place}
    b-chg 
    when lookup("b-add", bttns) > 0 and p-mode = {&place}
    B-sch
    B-Help
    b-hist
    BR-pl-gds
    WITH FRAME {&frame-name} .
  VIEW FRAME {&frame-name} .
  HIDE mark-num IN FRAME {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .
  define variable sort-column-phrase as character no-undo .
  define variable l-query-was-opened as logical   no-undo .
  define buffer buf_clients for ub.clients.

  run waitfram-show in this-procedure ( input "Ждите...").

  case sort-column-name :
    when "" then 
      do:
        assign
          sort-column-phrase = ""
          .
      end.
    otherwise 
    do:
      assign
        sort-column-phrase = "by " + sort-column-name
        .
    end.
  end case.



&scop flt-open-debug-file

&scop flt-open-open-query OPEN QUERY br-pl-gds FOR EACH X_pl-gds

&scop flt-open-dyn_open-query FOR EACH X_pl-gds

&scop flt-open-query-handle QUERY br-pl-gds:handle

&scop flt-open-open-query-tail  , EACH X_goods WHERE X_goods.gds-code = X_pl-gds.gds-code NO-LOCK, ~
      EACH X_place WHERE X_place.obj-code = X_pl-gds.obj-code ~
  AND X_place.obj-type = X_pl-gds.obj-type ~
  AND X_place.pl-code = X_pl-gds.pl-code ~
  and X_place.status_ <>  {&deleted-status} NO-LOCK
   

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-waitfram yes

  CASE p-mode:
    when {&g___object} then 
      do:
        FIND FIRST buf_clients NO-LOCK WHERE
          BUF_clients.obj-type = p-obj-type
          AND BUF_clients.obj-code = p-obj-code NO-ERROR.
        ASSIGN 
          frame
        {&frame-name}:TITLE = substitute("Товары на складских местах &1", BUF_clients.obj-name)
          filter-point                       = filter-point0  + p-mode
          filter-label                       = substitute("&1", filter-label0)
          shop-type                          = p-obj-type
          shop-code                          = p-obj-code
          .
        { gbl/fltopend.i
            &where-cond = " x_pl-gds.obj-type = shop-type AND X_pl-gds.obj-code = shop-code "
            &dyn_where-cond = " substitute('x_pl-gds.obj-type = &1&2&1 AND X_pl-gds.obj-code = &3 ', ~{&double-quote~}, shop-type, shop-code)"
            &use-ind = "  "
            &by = "  "
          }
      end.
    when {&goods} or 
    when {&petrolium} then 
      do:
        FIND FIRST b-goods NO-LOCK WHERE recid(b-goods) = p-gds-rec No-ERROR.
        ASSIGN
          frame {&frame-name}:TITLE = (if p-mode = {&goods}
                                                                      then ("Товар "   +
                                                                               b-goods.artic + " " + b-goods.prod-type +
                                                                                " " + string(b-goods.prod-code) +
                                                                                " на складских местах: "
                                                                                )
                                                                      else ("Топливо " +
                                                                               b-goods.artic + " " + b-goods.prod-type +
                                                                                " " + string(b-goods.prod-code)  +
                                                                                " в танках:"
                                                                              )
                                                                      )
          filter-point              = filter-point0 + p-mode
          filter-label              = substitute("&1", filter-label0)
          shop-type                 = p-obj-type
          shop-code                 = p-obj-code
          gdscode                   = b-goods.gds-code.
        { gbl/fltopend.i
           &where-cond = " X_pl-gds.obj-type = shop-type AND X_pl-gds.obj-code = shop-code AND X_pl-gds.gds-code = gdscode "
           &dyn_where-cond = " substitute('X_pl-gds.obj-type = &1&2&1 AND X_pl-gds.obj-code = &3 AND X_pl-gds.gds-code = &4 ', ~{&double-quote~}, shop-type, shop-code, gdscode)"
           &use-ind = "  "
           &by = "  "
          }
      end.
    when {&place} then 
      do:
        FIND FIRST b-place NO-LOCK WHERE recid(b-place) = p-doc-rec No-ERROR.
        ASSIGN
          frame {&frame-name}:TITLE = "Товары на складском месте " +
                                            string(b-place.pl-code) + " " +
                                            b-place.pl-name
          filter-point              = "Товар-Склд. место " + p-mode
          filter-label              = substitute("&1", filter-label0)
          shop-type                 = p-obj-type
          shop-code                 = p-obj-code
          plcode                    = b-place.pl-code.
        { gbl/fltopend.i
           &where-cond = " X_pl-gds.obj-type = shop-type AND X_pl-gds.obj-code = shop-code AND X_pl-gds.pl-code = plcode "
           &dyn_where-cond = " substitute('X_pl-gds.obj-type = &1&2&1 AND X_pl-gds.obj-code = &3 AND X_pl-gds.pl-code = &4 ', ~{&double-quote~}, shop-type, shop-code, plcode)"
           &use-ind = "  "
           &by = "  "
          }
      end.
  END CASE.

  if avail X_pl-gds then
    APPLY "VALUE-CHANGED":U to br-pl-gds.
  run waitfram-hide in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME