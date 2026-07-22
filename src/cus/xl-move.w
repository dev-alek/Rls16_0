&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME xl-ob
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS xl-ob
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет в Excel Движение по товарам

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

1Author: Исаков
Creation date: 06/29/04 1:12

*/
/*------------------------------------------------------------------------
  File:

  Description:

  Input Parameters:
      <none>

  Output Parameters:
      <none>

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter parParentProc  as widget-handle no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Движение по товарам".
{ cmp/vssrevis.i   }
{ cmp/str-glbl.i   }
{ cmp/showinf.i    }
{ cmp/r-pril.i new }
{ cmp/library.i    }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/getsect.i def }

define variable g#report-num as integer   no-undo .
run get-report-num  in parParentProc ( output g#report-num ).
define variable g#log as logical   no-undo .
define variable type-par1 as character no-undo .
define variable tmp-var1  as character no-undo .
define variable p-XL-delim as character no-undo .

{ gbl/getsect.i run v-cntxt-obj-type  v-cntxt-obj-code {&attr-report-firm} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'XL-delim'  then tmp-var1   = thbjattr_thbj-attr.property-value-character.
end.
IF tmp-var1 = "" then p-XL-delim = ";".
else p-XL-delim = tmp-var1.


define temp-table temp_result no-undo
       field cli-type       like ub.trn-doc.cli-type
       field cli-code       like ub.trn-doc.cli-code
       field cli-name       like ub.trn-doc.cli-name
       field rem-beg        as decimal     /********  ОСТАТКИ      *********/
       field rem-beg-sum    as decimal
       field rem-end        as decimal
       field rem-end-sum    as decimal
       field inp            as decimal      /********   ДВИЖЕНИЕ   *******/
       field sum-in         as decimal
       field outp           as decimal
       field sum-out        as decimal
       field rac            as decimal
       field sum-rac        as decimal

       index code is unique primary
           cli-type
           cli-code
       index name
           cli-name
       .


define temp-table gds-tbl no-undo
       field artic          like ub.doc-line.artic
       field prod-type  like ub.goods.prod-type
       field prod-code like ub.goods.prod-code
       field price as dec
   index art is unique primary
       artic
       prod-type
       prod-code
       .

define variable beg-date    as date     no-undo.
define variable end-date    as date     no-undo.
define variable var-date    as date     no-undo.
define variable v-counter   as integer  no-undo.

define stream out-stream.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME xl-ob

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-entry b-help startdate enddate
&Scoped-Define DISPLAYED-OBJECTS startdate enddate

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-entry DEFAULT
     LABEL "&Сбор данных"
     SIZE 12.5 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE enddate AS DATE FORMAT "99/99/9999":U
     LABEL "По"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE fi-counter AS INTEGER FORMAT "->>>>>>>>9":U INITIAL 0
     LABEL "Обработано товаров"
     VIEW-AS FILL-IN
     SIZE 14 BY 1
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE startdate AS DATE FORMAT "99/99/9999":U
     LABEL "С"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME xl-ob
     b-quit AT ROW 1 COL 1
     b-entry AT ROW 1 COL 11
     b-help AT ROW 1 COL 27.5
     startdate AT ROW 2.75 COL 4 COLON-ALIGNED
     enddate AT ROW 2.75 COL 22.25 COLON-ALIGNED
     fi-counter AT ROW 4.29 COL 20.88 COLON-ALIGNED
     SPACE(0.74) SKIP(2.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Движение по товарам"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX xl-ob
                                                                        */
ASSIGN
       FRAME xl-ob:SCROLLABLE       = FALSE.

/* SETTINGS FOR FILL-IN fi-counter IN FRAME xl-ob
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       fi-counter:HIDDEN IN FRAME xl-ob           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-entry
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-entry xl-ob
ON CHOOSE OF b-entry IN FRAME xl-ob /* Сбор данных */
DO:
    assign
        startdate
        enddate
    .
    if (startdate <> ? and enddate <> ?)
    and startdate <= enddate
    then do:
        assign
            beg-date = startdate
            end-date = enddate
        .
        run calc-oborot in this-procedure no-error.
        if error-status :error
        then do:
            message
              vss-workfile vss-revision vss-description
              skip "Ошибка при расчете оборотов."
              skip return-value
              skip trim(error-status :get-message(1))
                   trim(error-status :get-message(2))
                   trim(error-status :get-message(3))
                   trim(error-status :get-message(4))
                   trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return no-apply .
        end.
        run print-result in this-procedure no-error.
        if error-status :error
        then do:
            message
              vss-workfile vss-revision vss-description
              skip "Ошибка при выводе в файл."
              skip return-value
              skip trim(error-status :get-message(1))
                   trim(error-status :get-message(2))
                   trim(error-status :get-message(3))
                   trim(error-status :get-message(4))
                   trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return no-apply .
        end.
        message " Отчет завершен " view-as alert-box information buttons ok.
        hide fi-counter in frame {&frame-name}.
     end.
     else if startdate = ? then do:
         message "Не задана дата C". pause.
     end.
     else if enddate = ? then do:
         message "Не задана дата По". pause.
     end.
     else if startdate > enddate then do:
         message "Дата начала периода должна быть меньше даты конца". pause.
     end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME enddate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL enddate xl-ob
ON RETURN OF enddate IN FRAME xl-ob /* По */
DO:
    APPLY "ENTRY" TO b-entry IN FRAME {&FRAME-NAME}.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME startdate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL startdate xl-ob
ON RETURN OF startdate IN FRAME xl-ob /* С */
DO:
    APPLY "ENTRY" TO enddate IN FRAME {&FRAME-NAME}.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK xl-ob


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

assign
    startdate = date( month( today ), 1, year( today ) )
    enddate = today .

/*
здесь была проверка прав "отчет движение по товарам"
*/


{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  if session:set-wait-state("COMPILER") then.

  run enable_ui.

/*  IF rep-ok = no THEN
    DISABLE b-prn WITH FRAME {&FRAME-NAME} .

*/
  if session:set-wait-state("") then.

  APPLY "ENTRY" TO startdate IN FRAME {&FRAME-NAME}.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.

END.

run disable_ui.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-oborot xl-ob
PROCEDURE calc-oborot :
/*------------------------------------------------------------------------------
  Purpose:     Заполнение Temp-table для оборотов по клиентам
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define variable v-ext-doc-type-list  as char format "X(25)" extent 36 init
  [
       "приход внешний",                                   {&TDEDT_Pri_Vnesh},
       "расход внешний",                                   {&TDEDT_Ras_Vnesh},
       "расход внешний возврат поставщику",                {&TDEDT_Ras_Vnesh_VP},
       "расход внешний продажа через кассу",               {&TDEDT_Ras_Vnesh_Kass},
       "возврат внешний",                                  {&TDEDT_Vozvrat_Vnesh},
       "возврат внешний через кассу",                      {&TDEDT_Vozvrat_Vnesh_Kass},
       "списание внешнее",                                 {&TDEDT_Spi_Vnesh},
       "инвентаризация",                                   {&TDEDT_Inv},
       "коррекция учетных цен",                            {&TDEDT_Corr_Acc_Price},
       "смена типа приобретения",                          {&TDEDT_Chg_Purch_Code},
       "корретировка отрицательных партий",                {&TDEDT_Corr_Minus_Parts},
       "приход перемещение",                               {&TDEDT_Pri_Perem},
       "расход перемещение",                               {&TDEDT_Ras_Perem},
       "возврат перемещение",                              {&TDEDT_Vozvrat_Perem},
       "списание производство",                            {&TDEDT_Spi_Prvo},
       "приход производство",                              {&TDEDT_Pri_Prvo},
       "документ переоценки",                              {&TDEDT_Overturn},
       "пересортица",                                      {&TDEDT_Peresort}
  ]
no-undo.
define variable v-fact-order-from like ub.ot-line.fact-order      no-undo.
define variable v-fact-order-to   like ub.ot-line.fact-order      no-undo.
define variable v-oper-num        as integer                      no-undo.
define variable v-docs-exists     as logical           no-undo.
define variable v-ext-doc-type    as character         no-undo.
define variable v-counter         as integer           no-undo.

define variable v-stk-start      as decimal      no-undo.
define variable v-sum-start      as decimal      no-undo.
define variable v-stk-end        as decimal      no-undo.
define variable v-sum-end        as decimal      no-undo.
define variable v-income         as decimal      no-undo.
define variable v-sum-income     as decimal      no-undo.
define variable v-expense        as decimal      no-undo.
define variable v-sum-expence    as decimal      no-undo.
define variable v-kass           as decimal      no-undo.
define variable v-sum-kass       as decimal      no-undo.

define buffer buf_stk-line       for ub.stk-line.

run rep/get-fo.p (
               input v-cntxt-obj-type
             , input v-cntxt-obj-code
             , input beg-date
             , input end-date
             , output v-fact-order-from
             , output v-fact-order-to
             , output v-docs-exists
             ).

for each ub.gds-obj no-lock
   where ub.gds-obj.obj-type      = v-cntxt-obj-type
     and ub.gds-obj.obj-code      = v-cntxt-obj-code
break   by ub.gds-obj.artic
        by ub.gds-obj.prod-type
        by ub.gds-obj.prod-code
:
if first-of( ub.gds-obj.prod-code )
then do:
    assign
        v-counter = v-counter + 1
    .
    if ( v-counter modulo 25 ) = 0
    then do:
        view fi-counter in frame {&frame-name}.
        assign
            fi-counter :screen-value in frame {&frame-name} = string( v-counter )
        .
    end.
    find last buf_stk-line no-lock
        where buf_stk-line.obj-type      = ub.gds-obj.obj-type
          and buf_stk-line.obj-code      = ub.gds-obj.obj-code
          and buf_stk-line.artic         = ub.gds-obj.artic
          and buf_stk-line.prod-type     = ub.gds-obj.prod-type
          and buf_stk-line.prod-code     = ub.gds-obj.prod-code
          and buf_stk-line.sum-type      = {&arh-crsa}
          and buf_stk-line.cat-id        = {&root-cat-id}
          and buf_stk-line.fact-order    <=  v-fact-order-from
    no-error.
    if not available buf_stk-line
    then do:
        assign
            v-stk-start = 0
            v-sum-start = 0
        .
    end.
    else do:
        assign
            v-stk-start = buf_stk-line.fact-qnty
            v-sum-start = buf_stk-line.sum-base
        .
    end.
    find last buf_stk-line no-lock
        where buf_stk-line.obj-type      = ub.gds-obj.obj-type
          and buf_stk-line.obj-code      = ub.gds-obj.obj-code
          and buf_stk-line.artic         = ub.gds-obj.artic
          and buf_stk-line.prod-type     = ub.gds-obj.prod-type
          and buf_stk-line.prod-code     = ub.gds-obj.prod-code
          and buf_stk-line.sum-type      = {&arh-crsa}
          and buf_stk-line.cat-id        = {&root-cat-id}
          and buf_stk-line.fact-order    <=  v-fact-order-to
    no-error.
    if not available buf_stk-line
    then do:
        assign
            v-stk-end = v-stk-start
            v-sum-end = v-sum-start
        .
    end.
    else do:
        assign
            v-stk-end = buf_stk-line.fact-qnty
            v-sum-end = buf_stk-line.sum-base
        .
    end.
    run update-temp-result in this-procedure (
              input ub.gds-obj.obj-type
            , input ub.gds-obj.obj-code
            , input v-stk-start
            , input v-sum-start
            , input v-stk-end
            , input v-sum-end
            , input 0
            , input 0
            , input 0
            , input 0
            , input 0
            , input 0
    ).

    do v-oper-num = 1 to 14
    :
        assign
            v-ext-doc-type = v-ext-doc-type-list [v-oper-num * 2]
        .
        for each buf_stk-line no-lock
           where buf_stk-line.obj-type      = ub.gds-obj.obj-type
             and buf_stk-line.obj-code      = ub.gds-obj.obj-code
             and buf_stk-line.artic         = ub.gds-obj.artic
             and buf_stk-line.prod-type     = ub.gds-obj.prod-type
             and buf_stk-line.prod-code     = ub.gds-obj.prod-code
             and ( buf_stk-line.sum-type      = {&arh-cgdt}         + v-ext-doc-type
                or buf_stk-line.sum-type      = {&arh-cgdt-service} + v-ext-doc-type
                 )
             and buf_stk-line.cat-id        = {&root-cat-id}
             and buf_stk-line.fact-order    >  v-fact-order-from
             and buf_stk-line.fact-order    <= v-fact-order-to
        :
            case v-ext-doc-type
            :
            when {&TDEDT_Pri_Vnesh} or when {&TDEDT_Pri_Perem} or when {&TDEDT_Pri_Prvo}
            then do:
                assign
                    v-income      = buf_stk-line.fact-qnty
                    v-sum-income  = buf_stk-line.sum-base
                    v-expense     = 0
                    v-sum-expence = 0
                    v-kass        = 0
                    v-sum-kass    = 0
                .
            end.
            when {&TDEDT_Ras_Vnesh} or when {&TDEDT_Ras_Vnesh_VP} or when {&TDEDT_Vozvrat_Vnesh}
            or when {&TDEDT_Spi_Vnesh} or when {&TDEDT_Ras_Perem} or when {&TDEDT_Vozvrat_Perem}
            or when {&TDEDT_Spi_Prvo}
            then do:
                assign
                    v-income      = 0
                    v-sum-income  = 0
                    v-expense     = buf_stk-line.fact-qnty
                    v-sum-expence = buf_stk-line.sum-base
                    v-kass        = 0
                    v-sum-kass    = 0
                .
            end.
            when {&TDEDT_Ras_Vnesh_Kass} or when {&TDEDT_Vozvrat_Vnesh_Kass}
            then do:
                assign
                    v-income      = 0
                    v-sum-income  = 0
                    v-expense     = 0
                    v-sum-expence = 0
                    v-kass        = buf_stk-line.fact-qnty
                    v-sum-kass    = buf_stk-line.sum-base
                .
            end.
            when {&TDEDT_Inv} or when {&TDEDT_Overturn} or when {&TDEDT_Peresort}
            then do:
                if buf_stk-line.sum-base > 0
                then do:
                    assign
                        v-income      = buf_stk-line.fact-qnty
                        v-sum-income  = buf_stk-line.sum-base
                        v-expense     = 0
                        v-sum-expence = 0
                    .
                end.
                else do:
                    assign
                        v-income      = 0
                        v-sum-income  = 0
                        v-expense     = buf_stk-line.fact-qnty
                        v-sum-expence = buf_stk-line.sum-base
                    .
                end.
                assign
                    v-kass        = 0
                    v-sum-kass    = 0
                .
            end.
            end case.
            run update-temp-result in this-procedure (
                    input buf_stk-line.prod-type
                  , input buf_stk-line.prod-code
                  , input 0
                  , input 0
                  , input 0
                  , input 0
                  , input v-income
                  , input v-sum-income
                  , input v-expense
                  , input v-sum-expence
                  , input v-kass
                  , input v-sum-kass
            ).
        end.        /* for each buf_stk-line */
    end.        /* do v-oper-num = 1 to 14 */
end.        /* first-of( ub.gds-obj.prod-code ) */
end.        /* for each ub.gds-obj */




end.
END PROCEDURE. /* calc-oborot */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI xl-ob
PROCEDURE disable_UI :
/* --------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
   -------------------------------------------------------------------- */
  /* Hide all frames. */
  HIDE FRAME xl-ob.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI xl-ob  _DEFAULT-ENABLE
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
  DISPLAY startdate enddate
      WITH FRAME xl-ob.
  ENABLE b-quit b-entry b-help startdate enddate
      WITH FRAME xl-ob.
  {&OPEN-BROWSERS-IN-QUERY-xl-ob}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print-result xl-ob
PROCEDURE print-result :
/*------------------------------------------------------------------------------
  Purpose:     Вывод собранной информации в файл
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    { cmp/open-exp.i stream out-stream }
    { gbl/working.i }
    export stream out-stream
        p-xl-delim "" "Отчет по движению товаров"
    .
    put stream out-stream unformatted " " skip.
    find first ub.clients no-lock
            where ub.clients.obj-type  = v-cntxt-obj-type
            and ub.clients.obj-code  = v-cntxt-obj-code
    no-error.
    if not available ub.clients
    then do:
        message
            vss-workfile vss-revision vss-description
            skip "Ошибка поиска объекта."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
                trim(error-status :get-message(4))
                trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
    export stream out-stream p-xl-delim
        "Магазин/Склад   "
        string(v-cntxt-obj-code, ">>>>>>>>9")
        ub.clients.obj-name
    .
    export stream out-stream p-xl-delim
        "Отчетный период"
        "С:" string(startdate, "99/99/9999")
        "По:" string(enddate, "99/99/9999")
    .
    put stream out-stream unformatted " " skip.
    export stream out-stream p-xl-delim
        "Фирма"
        "Остаток на " string(startdate - 1, "99/99/9999")
        "Приход"                                         " "
        "Расход"                                          " "
        "Реализация"                                   " "
        "Остаток на " string(enddate, "99/99/9999")
    .
    export stream out-stream p-xl-delim
        " "
        "шт"  "Сумма, {&abbr_rub}"
        "шт"  "Сумма, {&abbr_rub}"
        "шт"  "Сумма, {&abbr_rub}"
        "шт"  "Сумма, {&abbr_rub}"
        "шт"  "Сумма, {&abbr_rub}"
    .
    assign
        v-counter = 0
    .
    for each temp_result
    use-index  name
    :
        assign
            v-counter = v-counter + 1
        .
        EXPORT stream out-stream p-xl-delim
            temp_result.cli-name
            temp_result.rem-beg
            temp_result.rem-beg-sum
            temp_result.inp
            temp_result.sum-in
            temp_result.outp
            temp_result.sum-out
            temp_result.rac
            temp_result.sum-rac
            temp_result.rem-end
            temp_result.rem-end-sum
        .
        ACCUMULATE temp_result.rem-beg     ( TOTAL ).
        ACCUMULATE temp_result.rem-beg-sum ( TOTAL ).
        ACCUMULATE temp_result.inp         ( TOTAL ).
        ACCUMULATE temp_result.sum-in      ( TOTAL ).
        ACCUMULATE temp_result.outp        ( TOTAL ).
        ACCUMULATE temp_result.sum-out     ( TOTAL ).
        ACCUMULATE temp_result.rac         ( TOTAL ).
        ACCUMULATE temp_result.sum-rac     ( TOTAL ).
        ACCUMULATE temp_result.rem-end     ( TOTAL ).
        ACCUMULATE temp_result.rem-end-sum ( TOTAL ).
    end.   /*  for each temp_result  */
    export stream out-stream p-xl-delim
        "ИТОГО  "
        ACCUM TOTAL temp_result.rem-beg
        ACCUM TOTAL temp_result.rem-beg-sum
        ACCUM TOTAL temp_result.inp
        ACCUM TOTAL temp_result.sum-in
        ACCUM TOTAL temp_result.outp
        ACCUM TOTAL temp_result.sum-out
        ACCUM TOTAL temp_result.rac
        ACCUM TOTAL temp_result.sum-rac
        ACCUM TOTAL temp_result.rem-end
        ACCUM TOTAL temp_result.rem-end-sum
    .
    put stream out-stream unformatted " " skip.
    export stream out-stream p-xl-delim
        "Директор Магазина/Склада "    " "  " "  " "  " "
        "Дата составления отчета "
            string( today , "99/99/9999")
    .
    export stream out-stream p-xl-delim
        "Управляющий салоном/Старший товаровед"
    .
    { gbl/stopwork.i }
    { cmp/cls-exp.i stream out-stream}
end.
END PROCEDURE. /* print-result */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE update-temp-result xl-ob
PROCEDURE update-temp-result :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-prod-type      as character    no-undo.
define input parameter p-prod-code      as integer      no-undo.
define input parameter p-stk-start      as decimal      no-undo.
define input parameter p-sum-start      as decimal      no-undo.
define input parameter p-stk-end        as decimal      no-undo.
define input parameter p-sum-end        as decimal      no-undo.
define input parameter p-income         as decimal      no-undo.
define input parameter p-sum-income     as decimal      no-undo.
define input parameter p-expense        as decimal      no-undo.
define input parameter p-sum-expence    as decimal      no-undo.
define input parameter p-kass           as decimal      no-undo.
define input parameter p-sum-kass       as decimal      no-undo.

define variable v-cli-name as character    no-undo.

define buffer buf_clients        for ub.clients.

    find first temp_result
            where temp_result.cli-type = p-prod-type
              and temp_result.cli-code = p-prod-code
    no-error.
    if not available temp_result
    then do:
        create temp_result.
        find first buf_clients no-lock
             where buf_clients.obj-type = p-prod-type
               and buf_clients.obj-code = p-prod-code
        no-error.
        if not available buf_clients
        then do:
                message
                vss-workfile vss-revision vss-description
                skip "Не найден производитель."
                skip "Тип производителя:" p-prod-type
                skip "Код производителя:" p-prod-code
                skip(1) "Имя производителя будет образовано"
                skip "из типа и кода:" p-prod-type + string( p-prod-code )
                skip(1) return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
                    trim(error-status :get-message(4))
                    trim(error-status :get-message(5))
                view-as alert-box warning.
                assign
                    v-cli-name = p-prod-type + string( p-prod-code )
                .
        end.
        else do:
            assign
                v-cli-name = buf_clients.obj-name
            .
        end.
        assign
            temp_result.cli-type    = p-prod-type
            temp_result.cli-code    = p-prod-code
            temp_result.cli-name    = v-cli-name
            temp_result.rem-beg     = 0
            temp_result.rem-beg-sum = 0
            temp_result.rem-end     = 0
            temp_result.rem-end-sum = 0
            temp_result.inp         = 0
            temp_result.sum-in      = 0
            temp_result.outp        = 0
            temp_result.sum-out     = 0
            temp_result.rac         = 0
            temp_result.sum-rac     = 0
        .
    end.        /* not available temp_result */
    assign
        temp_result.rem-beg     = temp_result.rem-beg       + p-stk-start
        temp_result.rem-beg-sum = temp_result.rem-beg-sum   + p-sum-start
        temp_result.rem-end     = temp_result.rem-end       + p-stk-end
        temp_result.rem-end-sum = temp_result.rem-end-sum   + p-sum-end
        temp_result.inp         = temp_result.inp           + p-income
        temp_result.sum-in      = temp_result.sum-in        + p-sum-income
        temp_result.outp        = temp_result.outp          + p-expense
        temp_result.sum-out     = temp_result.sum-out       + p-sum-expence
        temp_result.rac         = temp_result.rac           + p-kass
        temp_result.sum-rac     = temp_result.sum-rac       + p-sum-kass
    .

end.
END PROCEDURE. /* create-temp-result */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME