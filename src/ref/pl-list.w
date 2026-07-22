&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-pl-list


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_place FOR ub.place.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-pl-list
/*

$Revision: 34480d5fe7d9, 3332, rls $
$Author: SSlivenko $
$Date: 2023/05/19 13:37:09 $
$Workfile: pl-list.w $
$Archive: ref/pl-list.w $

Справочник складских мест

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input param bttns as character no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-mode as character no-undo .
define input-output parameter p-rid-list as character no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision: 34480d5fe7d9, 3332, rls $":u .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":u .
define variable vss-date        as character no-undo init "$Date: 2023/05/19 13:37:09 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: pl-list.w $":u .
define variable vss-archive     as character no-undo init "$Archive: ref/pl-list.w $":u .
define variable vss-description as character no-undo init "справочник складских мест" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ ref/gds-attr.i }
{ cmp/showinf.i  }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ cmp/mrk-strf.i }
{ gbl/fltopend.i defproc }
{ str/placelib.i }


define variable filter-label        as character no-undo init "Складские_места" .
define variable filter-label0       as character no-undo init "Складские_места" .
define variable filter-point        as character no-undo init "pl-list".
define variable filter-point0       as character no-undo init "pl-list".
define variable sort-column-name    as character no-undo .
define variable ri                  as recid     no-undo init ? .
define variable choice              as log       no-undo.
define variable del-choice          as logical   no-undo.
define variable mark                as char      no-undo.
define variable v-doc-rec           as recid     no-undo .
define variable v-rid-list          as character no-undo .
define variable ii                  as integer   no-undo.
define variable v-code              as character no-undo.
define variable v-value             as character no-undo.
define variable v-ok                as logical   no-undo.
define variable v_is-ptrl           as character no-undo.
define variable par-type            as character no-undo.
define variable v-chk-act-host-code as integer   no-undo .
define variable glog                as logical   no-undo .
define variable v-is-only-np        as logical   no-undo init no .
define variable v-is-np-list        as logical   no-undo init no .

define buffer buf_pl-gds for ub.pl-gds .
define buffer list_place for ub.place .

define temp-table tt-pl-list no-undo
  field pl-code like ub.place.pl-code
.

define temp-table tt-place-attr
  field pl-code         like place.pl-code
  field place-type      as character
  field place-Si        as integer
  field place-diameter  as decimal
  field dead-balance    as decimal
  field place-rel-error as decimal
  field pl-twice-code   like place.loc1
  field place-dens-prov as decimal
  field asi-sertif      as logical
  index pi as primary unique
  pl-code
  .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-pl-list
&Scoped-define BROWSE-NAME br-pl

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_place tt-place-attr

/* Definitions for BROWSE br-pl                                         */
&Scoped-define FIELDS-IN-QUERY-br-pl mark-string(recid(X_place), v-rid-list) X_place.pl-code X_place.pl-name x_place.status_ X_place.loc1 X_place.loc2 X_place.loc3 X_place.loc4 X_place.obj-type X_place.obj-code X_place.is-meas X_place.max-qnty X_place.add-qnty tt-place-attr.place-type tt-place-attr.place-Si tt-place-attr.place-diameter tt-place-attr.dead-balance tt-place-attr.place-rel-error tt-place-attr.place-dens-prov
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-pl X_place.pl-name
&Scoped-define ENABLED-TABLES-IN-QUERY-br-pl X_place
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-pl X_place
&Scoped-define SELF-NAME br-pl
&Scoped-define QUERY-STRING-br-pl FOR EACH X_place       WHERE X_place.obj-type = p-obj-type         and X_place.obj-code = p-obj-code NO-LOCK , first tt-place-attr where tt-place-attr.pl-code = X_place.pl-code no-lock
&Scoped-define OPEN-QUERY-br-pl OPEN QUERY {&SELF-NAME} FOR EACH X_place       WHERE X_place.obj-type = p-obj-type         and X_place.obj-code = p-obj-code NO-LOCK , first tt-place-attr where tt-place-attr.pl-code = X_place.pl-code no-lock.
&Scoped-define TABLES-IN-QUERY-br-pl X_place
&Scoped-define FIRST-TABLE-IN-QUERY-br-pl X_place


/* Definitions for DIALOG-BOX d-pl-list                                 */
&Scoped-define BUFFER-FIELDS-IN-QUERY-d-pl-list X_place.PS
&Scoped-define ENABLED-BUFFER-FIELDS-IN-QUERY-d-pl-list X_place.PS
&Scoped-define QUERY-STRING-d-pl-list FOR EACH X_place SHARE-LOCK
&Scoped-define OPEN-QUERY-d-pl-list OPEN QUERY d-pl-list FOR EACH X_place SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-d-pl-list X_place
&Scoped-define FIRST-TABLE-IN-QUERY-d-pl-list X_place


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS X_place.PS
&Scoped-define ENABLED-TABLES X_place
&Scoped-define FIRST-ENABLED-TABLE X_place
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel b-add b-chg b-del b-rest ~
b-level b-print B-hist B-sch b-help br-pl mark-num b-ATD
&Scoped-Define DISPLAYED-FIELDS X_place.PS
&Scoped-define DISPLAYED-TABLES X_place
&Scoped-define FIRST-DISPLAYED-TABLE X_place
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE MENU MENU-B-ATD 
       MENU-ITEM m_obj-sched LABEL "Управление расписанием сообщений"      
       MENU-ITEM m_pl-alarm  LABEL "Отключение повторных сообщений"     .

DEFINE BUTTON b-ATD
     LABEL "&АТД"
     SIZE 7 BY 1.
     
DEFINE BUTTON b-add
  LABEL "&Добавить"
  SIZE 10 BY 1.

DEFINE BUTTON b-chg
  LABEL "&Изменить"
  SIZE 10 BY 1.

DEFINE BUTTON b-del
  LABEL "&Удалить"
  SIZE 10 BY 1.

DEFINE BUTTON b-help
  LABEL "&Помощь"
  SIZE 3 BY 1.

DEFINE BUTTON B-hist
  LABEL "Ис&тория"
  SIZE 3 BY 1.

DEFINE BUTTON b-level
  LABEL "Градуир."
  SIZE 10 BY 1 TOOLTIP "Градуировочные таблицы".

DEFINE BUTTON B-mark
  LABEL "*"
  SIZE 3 BY 1.

DEFINE BUTTON b-print
  LABEL "Пе&чать"
  SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
  LABEL "&Выход "
  SIZE 10 BY 1.

DEFINE BUTTON b-rest
  LABEL "&Товары"
  SIZE 10 BY 1.

DEFINE BUTTON B-sch
  LABEL "&Фильтр"
  SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO
  LABEL "Вы&бор "  
  SIZE 10 BY 1.

DEFINE VARIABLE rs-stat  AS CHARACTER VIEW-AS RADIO-SET HORIZONTAL RADIO-BUTTONS
"Текущие&+",   {&current},
"Все&!",       {&all},
"Удаленные", {&deleted}
     SIZE 30 BY 1   FGCOLOR 0 /* BGCOLOR 8 */  NO-UNDO.


DEFINE VARIABLE mark-num AS INTEGER   FORMAT ">>>9":U INITIAL 0
  VIEW-AS TEXT
  SIZE 4.63 BY .67
  FGCOLOR 4 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-pl FOR
  X_place ,
  tt-place-attr SCROLLING.

DEFINE QUERY d-pl-list FOR
  X_place ,
  tt-place-attr SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-pl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-pl d-pl-list _FREEFORM
  QUERY br-pl NO-LOCK DISPLAY
  mark-string(recid(X_place), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
  X_place.pl-code FORMAT "99999999999":U
  X_place.pl-name FORMAT "X(40)":U
  X_place.status_ format "X(8)":U
  X_place.loc1 FORMAT "X(8)":U
  X_place.loc2 FORMAT "X(8)":U
  X_place.loc3 FORMAT "X(8)":U
  X_place.loc4 FORMAT "X(8)":U
  X_place.obj-type FORMAT "X(3)":U
  X_place.obj-code FORMAT "99999":U
  X_place.is-meas COLUMN-LABEL "Измер." FORMAT "+/-":U
  tt-place-attr.asi-sertif COLUMN-LABEL "Сертификация!АСИ" FORMAT "+/-":U
  X_place.max-qnty FORMAT "->>,>>>,>>9.<<<":U
  X_place.add-qnty COLUMN-LABEL "Доп. кол-во" FORMAT "->>,>>>,>>9.<<<":U
  tt-place-attr.pl-twice-code column-label "Код сдвоенного резервуара" format "X(8)":U
  tt-place-attr.place-type      COLUMN-LABEL "Тип резервуара" FORMAT "X(14)":U
  tt-place-attr.place-Si        COLUMN-LABEL "Средство!измерения" Format ">>>,>>9":U
  tt-place-attr.place-diameter  COLUMN-LABEL "Диаметр резервуара (мм)" format ">,>>>,>>9":U
  tt-place-attr.dead-balance  COLUMN-LABEL "Мертвый остаток" format "->>,>>>,>>9.<<<":U
  /*tt-place-attr.place-rel-error COLUMN-LABEL "Относительная погрешность!составлениия калибровочной таблицы " FORMAT "9.99":U*/
  tt-place-attr.place-dens-prov COLUMN-LABEL "Плотность при! поверке резервуара" FORMAT "9.999999999"
ENABLE
X_place.pl-name
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ASSIGN NO-ROW-MARKERS SEPARATORS SIZE 98 BY 16.75.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-pl-list
  b-quit AT ROW 1 COL 1
  B-mark AT ROW 1 COL 11
  b-sel AT ROW 1 COL 19
  b-add AT ROW 1 COL 29
  b-chg AT ROW 1 COL 39
  b-del AT ROW 1 COL 49
  b-rest AT ROW 1 COL 59
  b-level AT ROW 1 COL 69 WIDGET-ID 2
  b-ATD at row 1 col 79
  b-print AT ROW 1 COL 86
  B-hist AT ROW 1 COL 89
  B-sch AT ROW 1 COL 92
  b-help AT ROW 1 COL 95
  br-pl AT ROW 5 COL 1
  rs-stat at row 3 col 10.5 no-label
  "Статус :" VIEW-AS TEXT SIZE 9 BY 1 fgcolor 4 AT ROW 3 COL 1.5
  X_place.PS AT ROW 22 COL 1 NO-LABEL
  VIEW-AS EDITOR
  SIZE 98 BY 1.75
  mark-num AT ROW 1.17 COL 12.13 COLON-ALIGNED NO-LABEL
  SPACE(80.43) SKIP(20.25)
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
  TITLE "Складские места".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Temp-Tables and Buffers:
      TABLE: X_place B "?" ? ub place
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-pl-list
   FRAME-NAME                                                           */
/* BROWSE-TAB br-pl b-help d-pl-list */
ASSIGN
  FRAME d-pl-list:SCROLLABLE = FALSE.
ASSIGN 
       b-ATD:POPUP-MENU IN FRAME d-pl-list       = MENU MENU-B-ATD:HANDLE
       b-ATD:menu-mouse = 1
.
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-pl
/* Query rebuild information for BROWSE br-pl
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_place
      WHERE X_place.obj-type = p-obj-type
        and X_place.obj-code = p-obj-code NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Where[1]         = "X_place.obj-type = p-obj-type and X_place.obj-code = p-obj-code"
     _Query            is NOT OPENED
*/  /* BROWSE br-pl */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-pl-list
/* Query rebuild information for DIALOG-BOX d-pl-list
     _TblList          = "Temp-Tables.X_place"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX d-pl-list */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-pl-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-pl-list d-pl-list
ON GO OF FRAME d-pl-list /* Складские места */
  DO:
    p-rid-list = v-rid-list.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add d-pl-list
ON CHOOSE OF b-add IN FRAME d-pl-list /* Добавить */
  DO:

    define variable v-rep-rec as recid no-undo .
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
    run ref/pl-form.w (
      input parparentproc
      ,input {&add-def}
      ,input p-obj-type
      ,input p-obj-code
      ,input 0
      ,input-output v-rep-rec).
    if v-rep-rec <> ? then 
    do:
      v-doc-rec = v-rep-rec.
      RUn OpenBr in this-procedure ( input yes, input no, input '':U).
      apply "entry" to br-pl in frame {&frame-name}.
    end.
    else 
    do:
      apply "entry" to br-pl in frame {&frame-name}.
      return no-apply.
    end.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-stat d-pl-list
ON value-changed OF rs-stat in frame {&FRAME-NAME}
  DO:
    run proc-rs-stat in this-procedure no-error.
    if error-status :error then 
    do: 
      return no-apply. 
    end.
  END.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg d-pl-list
ON CHOOSE OF b-chg IN FRAME d-pl-list /* Изменить */
  DO:
    define variable v-rep-rec as recid no-undo .

    if not AVAILABLE X_place then 
    do:
      message "Неправильно выбрана строка.".
      return no-apply.
    end.
    v-rep-rec = recid (X_place).
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
    run ref/pl-form.w (
      input parparentproc
      ,input {&update}
      ,input X_place.obj-type
      ,input X_place.obj-code
      ,input X_place.pl-code
      ,input-output v-rep-rec).
    if v-rep-rec <> ? then 
    do:
      v-doc-rec = v-rep-rec.
      RUn OpenBr in this-procedure (  input yes, input no, input '':U).
      apply "entry" to br-pl in frame {&frame-name}.
    end.
    else 
    do:
      apply "entry" to br-pl in frame {&frame-name}.
      return no-apply.
    end.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del d-pl-list
ON CHOOSE OF b-del IN FRAME d-pl-list /* Удалить */
  DO:

    define variable placelog as logical no-undo.
    define variable new-rec  as recid   no-undo.
    define buffer buf_place for ub.place.
    assign rs-stat.
    if not available X_place then 
    do:
      message "Неправильно выбрана строка." view-as alert-box .
      return no-apply.
    end.
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
    if not glog then 
    do:
      return no-apply.
    end.
    v-doc-rec = recid (X_place).
    assign
      glog = no
      .
   
    find buf_place exclusive-lock
      where recid(buf_place) = v-doc-rec
      .

    _deletion:
    do on stop undo _deletion, return no-apply:
      assign
        glog = no
        .

      find first pl-gds-pump where pl-gds-pump.obj-type = buf_place.obj-type and 
        pl-gds-pump.obj-code = buf_place.obj-code and
        pl-gds-pump.pl-code = buf_place.pl-code
        no-error.
          
      if available pl-gds-pump then 
      do:
        message "К резервуару привязан товар!" skip
          "Для удаления данного резервуара удалите данную связку!"
          view-as alert-box ERROR.
        return no-apply.
      end.
            
      if  buf_place.status_ <> {&deleted-status} then 
      do: 
        message  "Удалить складское место?" skip(0)
          view-as alert-box QUestion buttons yes-no update del-choice.

        if del-choice = yes then 
        do:
          run trg/placedv.p
            ( input buf_place.obj-type
            ,input buf_place.obj-code
            ,input buf_place.pl-code
            ,output glog
            ) no-error.      
                        
          if glog = yes then 
          do:
            buf_place.status_ = "".
            delete buf_place.
            {&browse-name}:delete-current-row().
          end.
          else 
          do:
            buf_place.status_ = {&deleted-status}.

            { gbl/rum-runa.i
                            ?
                            this-procedure:handle
                            ?
                            {&thref-proc_ref-event}
                            " buffer buf_place:handle "
                            ''
                            ''
                            ''
                            no-error
                          }
            if error-status :error
              then
            do:
              return NO-APPLY substitute( "&2&1Ошибка маршрутизации записи в машину правил&1&3&1&4"
                , {&new-line}
                , vss-workfile
                , return-value
                , error-status :get-message ( 1 ) ).
            end.
  
          end.
                      
        end.
        else
        do:                    
          return no-apply.
        end.              
      end.        
      else 
      do: 
        message
          "Восстановить складское место?" skip(0)
          view-as alert-box QUestion buttons yes-no update del-choice.
         
        if del-choice = yes then 
        do:
          buf_place.status_ = "".
                       { gbl/rum-runa.i
                            ?
                            this-procedure:handle
                            ?
                            {&thref-proc_ref-event}
                            " buffer buf_place:handle "
                            ''
                            ''
                            ''
                            no-error
                          }
          if error-status :error
            then
          do:
            return NO-APPLY substitute( "&2&1Ошибка маршрутизации записи в машину правил&1&3&1&4"
              , {&new-line}
              , vss-workfile
              , return-value
              , error-status :get-message ( 1 ) ).
          end.
        /*                    {&current-status}.*/
                  
        end.
        else 
        do:      
          return no-apply.
        end.
      end.
  
    end.
    {&browse-name}:refresh().
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist d-pl-list
ON CHOOSE OF B-hist IN FRAME d-pl-list /* История */
  DO:
    define variable loc-rid-list as character no-undo .
    if available X_place THEN
      run ref/cplchist.w (
        INPUT parParentProc
        , input p-obj-type
        , input p-obj-code
        , input "":U /*bttns  */
        , input "one":U /*p-mode*/
        , input X_place.obj-type
        , input X_place.obj-code
        , input X_place.pl-code
        , input 0 /*p-gds-code*/
        , input 0 /*p-pump-code*/
        , input 0 /*p-nozzle-code*/
        , input '':U /*p-subject*/
        , input-output loc-rid-list
        ) no-error .
    apply "entry" to br-pl.

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-level
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-level d-pl-list
ON CHOOSE OF b-level IN FRAME d-pl-list /* Градуир. */
  DO:
    define variable v-recid as recid no-undo .
    if not avail X_place then return no-apply.
    run ref/pl-lvls.w   ( input parparentproc
      , input p-obj-type
      , input p-obj-code
      , input X_place.pl-code
      ) no-error.
    IF ERROR-STATUS:ERROR THEN 
    DO:
      message
        error-status:get-message(1) skip
        return-value
        view-as alert-box error .

      return no-apply .
    end.

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark d-pl-list
ON CHOOSE OF B-mark IN FRAME d-pl-list /* * */
  DO:
    define variable glog as logical no-undo .
    if available X_place then 
    do:
      { gbl/markstrn.i X_place v-rid-list }
      br-pl:refresh().
      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then 
      do:
        glog = br-pl:select-next-row ().
        apply "iteration-changed" to br-pl in frame {&frame-name}.
      end.
      if num-entries( v-rid-list ) = 0 then
        hide mark-num in frame {&frame-name}.
      else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
    end.
    apply "entry" to br-pl in frame {&frame-name}.

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME br-pl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-pl d-pl-list
ON MOUSE-SELECT-DBLCLICK OF br-pl IN FRAME d-pl-list
  DO:
    if (lookup("b-sel", bttns) > 0 and lookup("b-mark", bttns) = 0) then APPLY "CHOOSE" to b-sel.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print d-pl-list
ON CHOOSE OF b-print IN FRAME d-pl-list /* Печать */
  DO:
    if available X_place then 
    do:
      message "Еще не реализовано!" view-as alert-box.
      return no-apply.
    end.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-rest
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-rest d-pl-list
ON CHOOSE OF b-rest IN FRAME d-pl-list /* Товары */
  DO:
    if not avail X_place then return no-apply.
    define variable loc-rid-list as character no-undo .
    run ref/pl-gdss.w (
      input parparentproc
      ,input (if lookup("b-add", bttns) > 0 then "b-add" else "")
      ,input p-obj-type
      ,input p-obj-code
      ,input {&place}
      ,input ?
      ,input recid(X_place)
      ,output loc-rid-list).
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch d-pl-list
ON CHOOSE OF B-sch IN FRAME d-pl-list /* Фильтр */
  DO:

    assign
      tbl      = 'place'
      join-tbl = 'X_pLACE'
      fld      = "":U
      lab      = '':U
      spr      = '':U
      dim      = '0':U
      .
    run fltfield-add in this-procedure('obj-code', 'Код объекта', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('obj-type', 'Тип объекта', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('pl-code', 'Код места', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('pl-name', 'Название места', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('loc1', 'Коорд1', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('loc2', 'Коорд2', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('loc3', 'Коорд3', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('loc4', 'Коорд4', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('PS', 'Примечание', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    DO on stop undo, leave:
      run gbl/filter.w (
        input parparentproc
        ,input (filter-point + {&delim-par} + filter-label)
        ,input tbl
        ,input join-tbl
        ,input fld
        ,input lab
        ,input spr
        ,input dim).
      RUN OpenBr in this-procedure (  input yes, input no, input '':U).
    END .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel d-pl-list
ON CHOOSE OF b-sel IN FRAME d-pl-list /* Выбор  */
  DO:
    if ( available X_place
      AND (v-rid-list = ""
      or b-mark:sensitive = no
      ) ) then
      v-rid-list = string( recid( X_place ) ) .

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit d-pl-list
ON CHOOSE OF b-quit IN FRAME d-pl-list /* Выход */
  DO:
    
      p-rid-list = "cancel" .

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m_obj-sched
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_obj-sched d-pl-list
ON CHOOSE OF menu-item m_obj-sched in menu menu-b-atd /* - */
DO:
  define variable varlog as logical no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_atd-obj-sched':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    varlog
  }
  
  if varlog <> yes then return no-apply .
  
  run ref/atd-obj-sched.w (input parparentproc,
                           input p-obj-type,
                           input p-obj-code)
                           .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m_pl-alarm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_pl-alarm d-pl-list
ON CHOOSE OF menu-item m_pl-alarm in menu menu-b-atd /* - */
DO:
  define variable v-pl-rowid as rowid no-undo .
  define variable varlog as logical no-undo .
  
  if not AVAILABLE X_place then 
  do:
    message "Неправильно выбрана строка." view-as alert-box .
    return no-apply.
  end.
  
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_atd-pl-alarm':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    varlog
  }
  
  if varlog <> yes then return no-apply .
  
  v-pl-rowid = rowid (X_place).
  
  run ref/atd-pl-alarm.w (input parparentproc,
                          input p-obj-type,
                          input p-obj-code,
                          input v-pl-rowid)
                          .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define BROWSE-NAME br-pl
&Scoped-define SELF-NAME br-pl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-pl d-pl-list
ON VALUE-CHANGED OF br-pl IN FRAME d-pl-list
  DO:
    if available X_place then 
    do:
      display
        X_place.PS with frame {&frame-name}.
    end.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME place.PS
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL X_place.PS d-pl-list
ON ENTRY OF X_place.PS IN FRAME d-pl-list /* Описание */
  DO:
    v-doc-rec = recid (X_place).
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL X_place.PS d-pl-list
ON LEAVE OF X_place.PS IN FRAME d-pl-list /* Описание */
  DO:
    define buffer buf_place for ub.place.
    find buf_place where recid (buf_place) = recid(X_place) no-error.
    if available buf_place and input frame {&frame-name} X_place.PS <> buf_place.PS then 
    do:
      assign X_place.PS.
    end.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-pl-list


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
  THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/setfltnm.i }
{ gbl/brwrefre.i "v-doc-rec = recid(X_place). run openbr in this-procedure (  input yes, input no, input '':U). reposition br-pl to recid(v-doc-rec). v-doc-rec = ? . " }
{ gbl/brwrepos.i
&line-num=5 }
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-del }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/hot-key.i b-print }


{ gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "X_place.pl-code"
  &sort-clmn_2    = "X_place.pl-name"
  &sort-clmn_3    = "X_place.loc1"
  &sort-clmn_4    = "X_place.loc2"
  &sort-clmn_5    = "X_place.loc3"
  &sort-clmn_6    = "X_place.loc4"
  &open-query     = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &open-query-otherwise = "run OpenBr in this-procedure (  input yes, input no, input '':U)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}
{ gbl/hostcode.i
  p-obj-type
  p-obj-code
  v-chk-act-host-code
}
/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} 
  APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  if num-entries(p-mode, {&delim-par}) = 2
  then do :
    assign
      v-is-only-np = (entry(2, p-mode, {&delim-par}) = "only-np")
      v-is-np-list = (entry(2, p-mode, {&delim-par}) = "np-list")
      p-mode = entry(1, p-mode, {&delim-par})
    .
  end .
  { gbl/getcntxt.i get }

  { gbl/conf-rd.i "'is-ptrl':U"
              "'':U"
              "'':U"
              0
              "'':U"
              "'':U"
              "'':U"
              no
              v_is-ptrl
              par-type      no-error }
  if error-status :error or par-type  <> {&type-log} or v_is-ptrl <> 'yes':U then 
  do: 
    assign 
      v_is-ptrl = 'no':U. 
  end.
  if v-is-np-list
  then do :
    do ii = 1 to num-entries(p-rid-list) :
      for first list_place no-lock where recid(list_place) = integer(entry(ii, p-rid-list)) :
        create tt-pl-list .
        assign tt-pl-list.pl-code = list_place.pl-code .
      end .
    end .
  end .
  p-rid-list = v-rid-list.
  if v-rid-list <> "":U then 
  do:
    assign
      v-doc-rec = integer(entry(1, v-rid-list)).
  end.
  display rs-stat with frame {&FRAME-NAME}.
  enable rs-stat with frame {&FRAME-NAME}.
  RUN enable_UI in this-procedure .
  RUN OpenBR in this-procedure (  input yes, input no, input '':U).
  { gbl/mv-clmn.i
&browse-name = "br-pl"
&frame-name = "{&frame-name}"
  &start-column = "1 "
  &prev-order-column_1 = "'1,2,3,4,5,6,7,10,11,12,8,9'"
  &prev-order-column-condition_1 = " p-mode = {&g___object} "
  &prev-order-column_2 = "'1,8,9,2,3,4,5,6,7,10,11,12'"
  &prev-order-column-condition_2 = " p-mode = {&all} "
  &ext-col = 12

}
  APPLY "ENTRY" to br-pl.

  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus br-pl.
END.
RUN disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-pl-list  _DEFAULT-DISABLE
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
  HIDE FRAME d-pl-list.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-pl-list
PROCEDURE enable_UI :
  assign
    X_place.pl-name:read-only in browse {&BROWSE-NAME} = true.

  ENABLE
    b-quit
    b-rest 
    when lookup("b-add", bttns) > 0
    b-print
    b-help
    br-pl
    X_place.PS
    b-sel 
    when lookup ("b-sel", bttns) > 0
    b-mark 
    when lookup ("b-mark", bttns) > 0
    b-add 
    when lookup ("b-add", bttns) > 0
    b-chg 
    when lookup ("b-add", bttns) > 0
    b-del 
    when lookup ("b-add", bttns) > 0
    b-ATD
    when lookup ("b-sel", bttns) = 0
    b-level 
    when lookup ("b-add", bttns) > 0
    b-sch
    b-hist
    with frame {&frame-name}.
  HIDE
    b-print
    in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-rs-stat d-pl-list
PROCEDURE proc-rs-stat:
  ASSIGN
    FRAME {&FRAME-NAME}
    rs-stat.

  RUN openbr IN THIS-PROCEDURE (   input yes, input no, input '':U ).


END PROCEDURE.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr d-pl-list
PROCEDURE OpenBr :

  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .

  define variable l-query-was-opened as logical no-undo .
  define buffer buf_place for ub.place.


  assign FRAME {&FRAME-NAME}   rs-stat.
  run waitfram-show in this-procedure ( input "Ждите...").

  define variable sort-column-phrase as character no-undo .


  for each tt-place-attr :
    delete tt-place-attr.
  end.

  if p-mode = {&g___object}  then 
  do:
    
    for each buf_place where buf_place.obj-code = p-obj-code and buf_place.obj-type = p-obj-type and (if rs-stat = {&all} then true else  buf_place.status_ = (if rs-stat =  {&current} then "" else {&deleted-status})) no-lock :
        
      find first tt-place-attr exclusive-lock where tt-place-attr.pl-code = buf_place.pl-code no-error.
      if not available tt-place-attr then 
      do :
        create tt-place-attr.
        tt-place-attr.pl-code = buf_place.pl-code.
        ii = 0.
        do ii = 1 to num-entries({&list-place-attr}):
          v-code = entry(ii,{&list-place-attr}) .
          run placelib_get-attr in this-procedure  (
            input v-code
            ,input buf_place.obj-code
            ,input buf_place.obj-type
            ,input buf_place.pl-code
            ,output v-value
            ,output v-ok      ) no-error.
          case v-code :
            when {&place-type} then 
              do :
                if v-ok then 
                do :
                  if integer(v-value) = 1 then tt-place-attr.place-type = "Вертикальный"  .
                  if integer(v-value) = 2 then tt-place-attr.place-type = "Горизонтальный"  .
                end.
              end.
            when {&place-SI} then 
              do :
                if v-ok then tt-place-attr.place-Si = integer(v-value) .
              end.
            when {&place-diameter} then 
              do :
                if v-ok then tt-place-attr.place-diameter = decimal(v-value) .
              end.
            when {&dead-balance} then 
              do :
                if v-ok then tt-place-attr.dead-balance = decimal(v-value) .
              end.
            /*when {&place-ratio-error} then 
              do :
                if v-ok then tt-place-attr.place-rel-error = decimal(v-value) .
              end.*/
            when {&place-dens-prov} then 
              do :
                if v-ok then tt-place-attr.place-dens-prov = decimal(v-value) .
              end.
            when {&place-twice-code} then 
              do:
                if v-ok then tt-place-attr.pl-twice-code = v-value .
              end.
            when {&place-asi-sertif} then 
              do:
                if v-ok then tt-place-attr.asi-sertif = logical(v-value) .
              end.
          end case.
        end.
        
        if v-is-only-np
        then do :
          find first buf_pl-gds no-lock where buf_pl-gds.pl-code = tt-place-attr.pl-code no-error .
          if not available buf_pl-gds
          then do :
            delete tt-place-attr .
          end .
          else do :
            &scop proc-name gds-attr-value
            {&run_proc_attr-lib}
              (input  buf_pl-gds.gds-code
              ,input  {&attr-fuel-type}
              ,output v-value
              ,output par-type) no-error.
            if v-value = "lgas"
            or v-value = "metan"
            or v-value = "propan"
            then do :
              delete tt-place-attr .
            end .
          end .
        end . /* v-is-only-np */
        if v-is-np-list
        then do :
          find first tt-pl-list where tt-pl-list.pl-code = tt-place-attr.pl-code no-error .
          if not available tt-pl-list
          then do :
            delete tt-place-attr .
          end .
        end . /* v-is-np-list */
      end.
    end.
  end.
  else 
  do: 
    for each buf_place where  (if rs-stat = {&all} then true else  buf_place.status_ = (if rs-stat =  {&current} then "" else {&deleted-status})) no-lock :      
    
      find first tt-place-attr exclusive-lock where tt-place-attr.pl-code = buf_place.pl-code no-error.
      if not available tt-place-attr then 
      do :
        create tt-place-attr.
        tt-place-attr.pl-code = buf_place.pl-code.
        ii = 0.
        do ii = 1 to num-entries({&list-place-attr}):
          v-code = entry(ii,{&list-place-attr}) .
          run placelib_get-attr in this-procedure  (
            input v-code
            ,input p-obj-code
            ,input p-obj-type
            ,input buf_place.pl-code
            ,output v-value
            ,output v-ok      ) no-error.
          case v-code :
            when {&place-type} then 
              do :
                if v-ok then 
                do :
                  if integer(v-value) = 1 then tt-place-attr.place-type = "Вертикальный"  .
                  if integer(v-value) = 2 then tt-place-attr.place-type = "Горизонтальный"  .
                end.
              end.
            when {&place-SI} then 
              do :
                if v-ok then tt-place-attr.place-Si = integer(v-value) .
              end.
            when {&place-diameter} then 
              do :
                if v-ok then tt-place-attr.place-diameter = decimal(v-value) .
              end.
            when {&dead-balance} then 
              do :
                if v-ok then tt-place-attr.dead-balance = decimal(v-value) .
              end.
            /*when {&place-ratio-error} then 
              do :
                if v-ok then tt-place-attr.place-rel-error = decimal(v-value) .
              end.*/
            when {&place-dens-prov} then 
              do :
                if v-ok then tt-place-attr.place-dens-prov = decimal(v-value) .
              end.
            when {&place-twice-code} then 
              do:
                if v-ok then tt-place-attr.pl-twice-code = v-value .
              end.
            when {&place-asi-sertif} then 
              do:
                if v-ok then tt-place-attr.asi-sertif = logical(v-value) .
              end.
          end case.
        end.
        
        if v-is-only-np
        then do :
          find first buf_pl-gds no-lock where buf_pl-gds.pl-code = tt-place-attr.pl-code no-error .
          if not available buf_pl-gds
          then do :
            delete tt-place-attr .
          end .
          else do :
            &scop proc-name gds-attr-value
            {&run_proc_attr-lib}
              (input  buf_pl-gds.gds-code
              ,input  {&attr-fuel-type}
              ,output v-value
              ,output par-type) no-error.
            if v-value = "lgas"
            or v-value = "metan"
            or v-value = "propan"
            then do :
              delete tt-place-attr .
            end .
          end .
        end . /* v-is-only-np */
      end.
    end.
  end.

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

&scop flt-open-open-query OPEN QUERY br-pl FOR EACH X_place

&scop flt-open-dyn_open-query FOR EACH X_place

&scop flt-open-query-handle QUERY br-pl:handle

&scop flt-open-open-query-tail  , first tt-place-attr no-lock where tt-place-attr.pl-code = X_place.pl-code

&scop flt-open-dyn_open-query-tail  substitute(', first tt-place-attr no-lock where tt-place-attr.pl-code = X_place.pl-code' )

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-waitfram yes

  CASE p-mode:
    when {&g___object} then 
      do:
        FIND FIRST clients NO-LOCK WHERE clients.obj-type = p-obj-type AND
          clients.obj-code = p-obj-code NO-ERROR.
        ASSIGN 
          frame {&frame-name}:TITLE = "Складские места " + clients.obj-name
          filter-point              = filter-point0 + p-mode
          filter-label              = substitute("&1", filter-label0)
          .
        { gbl/fltopend.i
            &where-cond = " X_place.obj-type = p-obj-type AND X_place.obj-code = p-obj-code "
            &dyn_where-cond = " substitute('X_place.obj-type = &1&2&1 AND X_place.obj-code = &3 ', ~{&double-quote~}, p-obj-type, p-obj-code)"
            &use-ind = "  "
            &by = "  "
          }
      end.
    when {&all} then 
      do:
        ASSIGN
          frame {&frame-name}:TITLE = "Складские места "
          filter-point              = filter-point0 + p-mode
          filter-label              = substitute("&1", filter-label0)
          .
        { gbl/fltopend.i
            &where-cond = " TRUE "
            &use-ind = "  "
            &by = "  "
          }
      end.

  END CASE.

  if v-doc-rec <> ? then reposition br-pl to recid v-doc-rec no-error.
  if not p-open-query and v-fltopend-rowid[1] <> ? then
    query br-pl:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
  apply "entry" to br-pl in frame {&frame-name}.
  if avail X_place then
    APPLY "VALUE-CHANGED":U to br-pl.
  run waitfram-hide in this-procedure .
  apply "value-changed" to br-pl in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME