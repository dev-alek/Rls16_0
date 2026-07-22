/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список документов производства

Автор: Белоусов Илья Александрович
Дата создания: 09/09/05
Author: Ilia Belousov
Creation date: 09/09/05

Input:
    p-status-available - то, что передавалось через g#stat

Output:

*/

define input parameter parparentproc    as widget-handle    no-undo.
define input parameter p-status-available   as character        no-undo.
define input parameter p-list-mode          as character        no-undo.
define input-output    parameter p-rid-list as character         no-undo.

/* ***************************  Definitions  ************************** */
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Список документов производства":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ gbl/cur-time.i }
{ str/writelog.i def "'fbr.log'" no-create}
{ str/fbrcode.i }
{ str/fbrhist.i main }
{ str/fbrlib.i   }
{ str/trdcalib.i }
{ str/fbrattr.i  }
{ gbl/getcntxt.i def }
{ gbl/waitfram.i }
{ gbl/fltopend.i defproc }
{ cmp/showinf.i  }
{ str/fbr-log.i clear }

define variable doc-rec                 as recid        no-undo.
define variable v-yesno                 as logical      no-undo.
define variable gds-rec                 as recid        no-undo.
define variable v-fbr-docs-nik          as character    no-undo.
define variable v-fbr-docs-oper-nik     as character    no-undo.
define variable v-fbr-docs-where-cond   as character    no-undo.
define variable v-user-action           as character    no-undo .
define variable v-printed               as logical      no-undo .

&scoped-define FRAME-NAME d-fbr-docs

&scoped-define if-not-true ~
if not v-yesno then do: ~
  find first f-doc where recid (f-doc) = doc-rec no-lock. ~
  return no-apply. ~
end.

&scoped-define net-proc ~
if not available f-doc then do: ~
  message "Неправильно выбран документ." view-as alert-box error. ~
  return no-apply. ~
end. ~
doc-rec = recid (f-doc). ~
do on stop undo, return no-apply : ~
  find f-doc where recid (f-doc) = doc-rec exclusive.  /* сетевая проверка */ ~
end.

define new shared variable br-handle as handle no-undo.
define new shared buffer f-doc for fbr-doc.
define buffer f-d-b for fbr-doc.                     /* для поиска по номеру, дате, факт */
define variable sch-field as character no-undo.

define variable chg-qnty as dec no-undo.
define variable cost-base as dec no-undo.
define variable cost-rubl as dec no-undo.

DEFINE new shared QUERY br-docs FOR f-doc SCROLLING.
{ gbl/flt-def.i  }
{ gbl/fltfield.i }

define variable old-list        as character no-undo.
define variable old-stat        as character no-undo.
define variable flt-rec         as recid        no-undo.
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
define variable v-host-code     as integer      no-undo.
define variable v-host-name     as character    no-undo.

define variable cStsMark  as class ibs.th.str.marking.sts.mark no-undo.

/* ***********************  Control Definitions  ********************** */

DEFINE BUTTON b-add
     LABEL "&Добавить"
     size 10.00 by 1.00 TOOLTIP "Добавление нового документа".

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     size 10.00 by 1.00 TOOLTIP "Коррекция текущего документа".

DEFINE BUTTON b-close
     LABEL "&Закрыть"
     size 10.00 by 1.00 TOOLTIP "Установка следующего статуса для текущего документа".

DEFINE BUTTON b-open
     LABEL "&Открыть"
     size 10.00 by 1.00 TOOLTIP "Установка предыдущего статуса для текущего документа".

DEFINE BUTTON b-del
     LABEL "&Удалить"
     size 10.00 by 1.00 TOOLTIP "Удаление текущего документа".

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход "
     size 10.00 by 1.00 TOOLTIP "Выход из списка документов".

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     size 10.00 by 1.00 TOOLTIP "Помощь".

DEFINE BUTTON b-hist
     LABEL "Ис&тория"
     size 10.00 by 1.00 TOOLTIP "История действий пользователей для документа".

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     size 10.00 by 1.00 TOOLTIP "Просмотр текущего документа".

DEFINE BUTTON b-print
     LABEL "Пе&чать"
     size 10.00 by 1.00 TOOLTIP "Печать текущего документа".

DEFINE BUTTON b-sch
     LABEL "&Фильтр"
     size 10.00 by 1.00 TOOLTIP "Работа со списком фильтров, установка или отмена фильтра в списке документов".

DEFINE BUTTON b-sel
     LABEL "Вы&бор "
     size 10.00 by 1.00 TOOLTIP "Выбор (запоминание) текущего документа".

DEFINE BUTTON b-gds
     LABEL "Товар&ы "
     size 10.00 by 1.00 TOOLTIP "Просмотр документа производства по товарам".

DEFINE VARIABLE ed-notes AS CHARACTER
     VIEW-AS EDITOR
     size 96.5 by 1.58 TOOLTIP "Примечание текущего документа, при редактировании удалите @"
     NO-UNDO.

DEFINE NEW SHARED VARIABLE sch-code AS CHARACTER FORMAT "X(12)":U INITIAL ?
     LABEL "&Начало номера"
     VIEW-AS FILL-IN
     size 15 by 1 TOOLTIP "Поиск по началу номера документа"
     NO-UNDO.

DEFINE NEW SHARED VARIABLE sch-date AS DATE FORMAT "99/99/99":U
     LABEL "Д&ата"
     VIEW-AS FILL-IN
     size 9.38 by 1 TOOLTIP "Поиск по дате документа"
     NO-UNDO.

DEFINE NEW SHARED VARIABLE sch-fact AS DATE FORMAT "99/99/99":U
     LABEL "Фа&кт"
     VIEW-AS FILL-IN
     size 9.38 by 1 TOOLTIP "Поиск по факт дате документа"
     NO-UNDO.

DEFINE NEW SHARED VARIABLE sch-num AS INTEGER FORMAT ">9":U INITIAL ?
     LABEL "Найдено"
     VIEW-AS FILL-IN
     size 3.75 by 1
     TOOLTIP "Порядковый номер найденного документа"
     FGCOLOR 12 NO-UNDO.

DEFINE NEW SHARED BROWSE br-docs
  QUERY br-docs DISPLAY
      f-doc.status_ COLUMN-LABEL "Статус" format "x(8)"
      f-doc.doc-code format "x(12)"
      (substring ((string (f-doc.doc-date)), 1, 5)) format "x(5)" column-label "Дата"
      f-doc.fact-date COLUMN-LABEL "Факт"
      (trim (f-doc.obj-type) + " " + string (f-doc.obj-code, ">>>>9")) COLUMN-LABEL "Объект" FORMAT "x(9)"
      f-doc.in-qnty COLUMN-LABEL "Приход"
      f-doc.out-qnty COLUMN-LABEL "Списано"
      f-doc.in-sale COLUMN-LABEL "Прих. цены прод."
      f-doc.out-sale COLUMN-LABEL "Спис. цены прод."
      f-doc.in-base COLUMN-LABEL "Cумма учет (б.в.)"
      f-doc.in-rubl COLUMN-LABEL "Cумма учет ({&abbr_rub}.)"
      f-doc.in-vat-base COLUMN-LABEL "Cумма уч. НДС (баз)"
      f-doc.in-vat-rubl COLUMN-LABEL "Cумма уч. НДС ({&abbr_rub})"
      f-doc.shift-date COLUMN-LABEL "Смена"
      (if f-doc.shift-num = 0 then ? else f-doc.shift-num) COLUMN-LABEL "№" format ">9"
/*
      f-doc.out-base COLUMN-LABEL "Cумма спис.(б.в.)"
      f-doc.out-rubl COLUMN-LABEL "Cумма спис.({&abbr_rub}.)"
*/
    WITH NO-ROW-MARKERS SEPARATORS size 96.5 by 14.08.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-fbr-docs
     b-quit   at row 1.08 col 1.63
     b-sel    at row 1.08 col 11.63
     b-gds    at row 1.08 col 21.63
     b-sch    at row 1.08 col 31.63
     b-hist   at row 1.08 col 41.63
     b-help   at row 1.08 col 51.63
     b-add    at row 2.25 col 1.63
     b-lkp    at row 2.25 col 11.63
     b-chg    at row 2.25 col 21.63
     b-del    at row 2.25 col 31.63
     b-close  at row 2.25 col 51.63
     b-open   at row 2.25 col 61.63
     b-print  at row 2.25 col 71.63
     br-docs  at row 3.57 col 1.63
     ed-notes at row 17.7 col 1.5 NO-LABEL      bgcolor 8 fgcolor 4
     sch-code at row 19.66 col 14.13 COLON-ALIGNED
     sch-date at row 19.66 col 35.88 COLON-ALIGNED
     sch-fact at row 19.66 col 51.88 COLON-ALIGNED
     sch-num  at row 19.66 col 74.75 COLON-ALIGNED fgcolor 12
     v-fbr-docs-nik         at row 20.83 col 1.13  format "X(17)" label "Имя" fgcolor 4
     f-doc.sys-date         at row 20.83 col 24.75 label "Дата изм." fgcolor 4
     f-doc.sys-time         at row 20.83 col 48 label "Время изм." fgcolor 4
     v-fbr-docs-oper-nik    at row 20.83 col 71 format "X(17)" label "Опер." fgcolor 4
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
         size 98.88 by 22.63.

/* ***************  Runtime Attributes and UIB Settings  ************** */

ASSIGN
       FRAME d-fbr-docs:SCROLLABLE = FALSE
       br-docs:NUM-LOCKED-COLUMNS IN FRAME {&frame-name} = 3
       .

/* ************************  Control Triggers  ************************ */

/*&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL D-FBR-DOC D-FBR-DOC*/
ON Shift-Alt-F6 of frame {&frame-name} anywhere
do:
    define variable v-message-text      as character    no-undo.
    define variable v-should-replace    as logical      no-undo.
    assign
        v-message-text = "Запись событий в файл fbr.log. "
    .
    if search("fbr.log") <> ?
    then do:
        assign
            v-message-text = v-message-text + " Удалить старый файл?"
                        + {&new-line} + {&new-line} + "Yes - удалить старый LOG-файл, начать запись в новый"
                        + {&new-line} + "No - переименовать старый LOG-файл, начать запись в новый"
                        + {&new-line} + "Cancel - переименовать LOG-файл, остановить запись"
        .
        message
            v-message-text
        view-as alert-box buttons yes-no-cancel title "Журнал событий"
        update v-should-replace.
        if v-should-replace = ?
        then do:
                os-delete "fbr-old.log".
                os-rename "fbr.log" "fbr-old.log".
        end.
        else do:
            if v-should-replace = yes
            then do:
                os-delete "fbr.log".
            end.
            else do:
                os-delete "fbr-old.log".
                os-rename "fbr.log" "fbr-old.log".
            end.
            output to "fbr.log".
            output close.
        end.
    end.
    else do:
        message
            v-message-text
        view-as alert-box.
        output to "fbr.log".
        output close.
    end.

end.
/* _UIB-CODE-BLOCK-END */
/*&ANALYZE-RESUME*/


ON CHOOSE OF b-hist IN FRAME {&frame-name} /* История */
DO:
{ gbl/stdbtn.i }
if not available f-doc then do:
  message "Неправильно выбран документ."
          view-as alert-box error.
  return no-apply.
end.
doc-rec = recid (f-doc).
run str/fbrdocsh.w (
      input parparentproc
    , input f-doc.doc-code
).
END.

ON CHOOSE OF b-close IN FRAME {&frame-name} DO:

define variable same-sale   like fbr-line.price-sale    no-undo.    /* цена первого товара из одниковых */
define variable is-waste    as logical                  no-undo.    /* первая строка с этим товаром - строка отходов */
define variable fix-price   like fbr-line.is-calc       no-undo.    /* фиксированная цена */
define variable v-reserved  as logical                  no-undo.
define variable varchip-code like ub.c-trn-doc.chip-num no-undo.
define variable varchip-code2 like ub.c-trn-doc.chip-num no-undo.
{ gbl/stdbtn.i }
{&net-proc}
if f-doc.status_ = {&doc-froze}
then do:
    find first f-doc no-lock
         where recid (f-doc) = doc-rec
    .
    message
        "Документ в статусе 'Нередактируемый' не может быть закрыт."
    view-as alert-box error.
    return no-apply.
end.

if f-doc.status_ = {&fact}
then do:
  find first f-doc no-lock
       where recid (f-doc) = doc-rec
  .
  message "Документ уже закрыт."
          view-as alert-box error.
  return no-apply.
end.
if f-doc.status_ = {&g___new}
then do:    /* новый -> разрешен */
    assign
        v-yesno = no
    .
    message "Документ :" f-doc.status_ "№" f-doc.doc-code
        skip "Завершить ввод и редактирование?"
    view-as alert-box question
    buttons OK-Cancel
    update v-yesno.
    {&if-not-true}
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_manufacturing_preparation':U
      {&cntxt-object}
      f-doc.host-code
      f-doc.obj-type
      f-doc.obj-code
      0
      0
      0
      true
      v-yesno
    }
    {&if-not-true}
    run fbrlib_check-before-close in this-procedure ( input f-doc.doc-code) no-error.
    if error-status:error then do:
      message
      "Ошибки в строках документа пр-ва" skip(0)
      error-status:get-message(1)
      return-value
      view-as alert-box error .
      return no-apply.
    end.
    /* закрытие всего на разрешен */
    run str/fbr-rsrv.p (
          input parparentproc
        , input ?
        , input recid( f-doc )
        , input no /*p-silent*/
        , input no /* autofbr */
        , input no
        , input no
        , output v-reserved ) no-error.
    if error-status:error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка резервирования товара."
          skip return-value
          skip trim(error-status :get-message(1))
        view-as alert-box error.
        if search ({&fbr-rsrv-tt-log-file-name}) <> ? then do:
          input stream stm from value({&fbr-rsrv-tt-log-file-name}).
          repeat .
            create tt-rsrv-err.
            import stream stm tt-rsrv-err no-error.
            if error-status:error 
              then delete tt-rsrv-err.
          END.
          output stream stm to value (v-fbr-tt-log-file-name).
          for each tt-rsrv-err no-lock break by tt-rsrv-err.artic:  
            if last-of (tt-rsrv-err.artic) and tt-rsrv-err.artic <> "" then do:
              put stream stm unformatted substitute("Ошибка при резервировании товара артикул &1 &5: требуемое кол-во &2 зарезервировано &3&4"
                                  , tt-rsrv-err.artic
                                  , tt-rsrv-err.req-qnty
                                  , tt-rsrv-err.rsrv-qnty
                                  , {&new-line}
                                  , tt-rsrv-err.gds-name
                                  ).
            end.
          end.
          output stream stm close.
          if search ({&fbr-rsrv-tt-log-file-name}) <> ? then do:
            run gbl/prnfilen.w (
                  input "Список не зарезервированных товаров при производстве":U
                , input 8
                , input search({&fbr-rsrv-tt-log-file-name})
                , input 7
                , output v-user-action
                , output v-printed
            ).
          end.
        end.
        return no-apply.
     end.
     if v-reserved = yes
     then do:
        assign
            f-doc.status_ = {&permitted}
        .
     end.
     else do:
            run fbrlib-del-trn-doc in this-procedure (
                  input parparentproc
                , input f-doc.doc-code
                , input {&expense}
                , input ?
                , output varchip-code
            ) no-error.
            if error-status:error then do:
              message
              substitute("Ошибка при удалении складского документа, созданного по документу производства &1&2&3&2&4"
                         , f-doc.doc-code
                         , {&new-line}
                         , error-status:get-message(1)
                         , return-value
                         )
              view-as alert-box error .
            end.
            run fbrlib-del-trn-doc in this-procedure (
                  input parparentproc
                , input f-doc.doc-code
                , input {&write-off}
                , input varchip-code
                , output varchip-code2
            ) no-error.
            if error-status:error then do:
              message
              substitute("Ошибка при удалении складского документа, созданного по документу производства &1&2&3&2&4"
                         , f-doc.doc-code
                         , {&new-line}
                         , error-status:get-message(1)
                         , return-value
                         )
              view-as alert-box error .
            end.

     end.
end.
else do:
  /* разрешен -> факт */
  v-yesno = no.
  message "Документ :" f-doc.status_ "№" f-doc.doc-code skip
          "Вы уверены, что хотите закрыть его на ФАКТ ?"
          view-as alert-box question buttons OK-Cancel update v-yesno.
  {&if-not-true}
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_manufacturing_fact':U
    {&cntxt-object}
    f-doc.host-code
    f-doc.obj-type
    f-doc.obj-code
    0
    0
    0
    true
    v-yesno
  }
  {&if-not-true}
  /* закрытие всего по факту */
/*  /*Проверка на маркированность*/                                                         */
/*  define variable varvalue as character no-undo .                                         */
/*  varvalue = "" .                                                                         */
/*   define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .                         */
/*  EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(f-doc.obj-type, f-doc.obj-code).*/
/*                                                                                          */
/*  RUN gds-attr-value (                                                                    */
/*                      INPUT bf_goods.gds-code,                                            */
/*                      INPUT {&attr-mark-type},                                            */
/*                      OUTPUT varvalue,                                                    */
/*                      OUTPUT vartype                                                      */
/*                      ).                                                                  */
/*  if varvalue > "" then do:                                                               */
/*        if EDOParSec:GetIsMarkingForTypeArtic(varvalue)                                   */
/*  then do :                                                                               */
/*  end .                                                                                   */
/*  end.                                                                                    */

  
    run str/fbr-fact.p ( input parparentproc
                       , input recid( f-doc )
                       , no                   /* p-silent */
                       ) no-error.
   if error-status:error then do:
     message
     substitute("Ошибка при закрытии документа производства &1&2&3&2&4"
                 , f-doc.doc-code
                 , {&new-line}
                 , error-status:get-message(1)
                 , return-value
                 )
     view-as alert-box error .
     undo, return no-apply.
   end.
end.
run UI-on in this-procedure ( input yes ).
END.

ON CHOOSE OF b-open IN FRAME {&frame-name} DO:

    define variable unrv-qnty   like gds-dtl.doc-qnty   no-undo.
    { gbl/stdbtn.i }
    {&net-proc}

    if f-doc.status_ = {&doc-froze}
    then do:
        find first f-doc no-lock
            where recid (f-doc) = doc-rec
        .
        message
            "Документ в статусе 'Нередактируемый' не может быть открыт."
        view-as alert-box error.
        return no-apply.
    end.
    if f-doc.status_ = {&fact}
    then do:
        find first f-doc no-lock
            where recid (f-doc) = doc-rec
        .
        message
            "Документ уже закрыт."
        view-as alert-box error.
        return no-apply.
    end.
    if f-doc.status_ = {&g___new}
    then do:
        find first f-doc no-lock
             where recid (f-doc) = doc-rec
        .
        message
            "Документ уже открыт."
        view-as alert-box error.
        return no-apply.
    end.
    assign
        v-yesno = no
    .
    message
        "Документ :" f-doc.status_ "№" f-doc.doc-code
        skip "Вы уверены, что хотите открыть его ?"
    view-as alert-box question
    buttons yes-no
    update v-yesno.
    {&if-not-true}
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_manufacturing_preparation':U
      {&cntxt-object}
      f-doc.host-code
      f-doc.obj-type
      f-doc.obj-code
      0
      0
      0
      true
      v-yesno
    }
    {&if-not-true}

    { gbl/working.i }
    /* снимаем резервы, удаляем НС, открываем производство */
    run open-fbr-doc in this-procedure (
        input f-doc.doc-code
    ) no-error.
    if error-status :error
    then do:
        message
            vss-workfile vss-revision vss-description
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            trim(error-status :get-message(4))
            trim(error-status :get-message(5))
            view-as alert-box error.
        undo, return no-apply .
    end.
    { gbl/stopwork.i }
    run UI-on in this-procedure ( input yes ).
END.

ON CHOOSE OF b-quit IN FRAME {&frame-name} /* Выход */
DO:
{ gbl/stdbtn.i }
doc-rec = ?.
END.

ON WINDOW-CLOSE OF FRAME d-fbr-docs /* <insert dialog title> */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* для устранения подвисания при неправильных нажатиях */
on any-printable of br-docs in frame {&frame-name} do:
  apply "entry" to sch-code in frame {&frame-name}.
end.

ON CHOOSE OF b-add IN FRAME {&frame-name} DO:
{ gbl/stdbtn.i }

    define variable v-fbr-doc-next-prev     as logical      no-undo.
    define variable v-dead-doc              as character initial no     no-undo.
    define variable v-type                  as character initial ?      no-undo.
    define variable v-new-fbr-doc-recid     as recid                    no-undo.
    { gbl/conf-rd.i
    "'dead-doc'"
    "''"
    "''"
    0
    "''"
    "''"
    "''"
    no
    v-dead-doc
    v-type
    no-error
    }
    if  error-status :error  = false then do:
        if v-dead-doc = "yes"  then  do:
        message "В системе установлен запрет на ввод документов!"
        view-as alert-box error .
        return no-apply  .
        end.
    end.
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_manufacturing_preparation':U
      {&cntxt-object}
      v-cntxt-host-code-obj
      v-cntxt-obj-type
      v-cntxt-obj-code
      0
      0
      0
      true
      v-yesno
    }
    if not v-yesno
    then do:
        return no-apply.
    end.
    if lookup( {&fact_permitted}, p-status-available ) <> 0
    and not p-list-mode = {&g___object}
    then do:
        message
            "Добавление нового документа не работает в этом списке,"
            skip "т.к. в нем нет документов со статусом НОВЫЙ."
        view-as alert-box error.
        return no-apply.
    end.
    run str/fbr-doc.w (
          input parparentproc
        , input this-procedure
        , input {&add-def}
        , input ?
        , output v-new-fbr-doc-recid
        , input-output v-fbr-doc-next-prev
    ).
    if v-new-fbr-doc-recid = ? then
    return no-apply.
    assign
        doc-rec = v-new-fbr-doc-recid
    .
    run UI-on in this-procedure ( input yes ).
END.

ON CHOOSE OF b-chg IN FRAME {&frame-name} DO:
{ gbl/stdbtn.i }
define variable v-fbr-doc-next-prev    as logical      no-undo.
{&net-proc}
define variable doc-rec    as recid        no-undo.
if f-doc.status_ = {&fact}
then do:     
    message "Закрытый документ не может быть изменен."
            view-as alert-box error.
    return no-apply.
end.
if f-doc.status_ = {&doc-froze}
then do:
    message
        "Документ в статусе 'Нередактируемый' не может быть изменен."
    view-as alert-box error.
    return no-apply.
end.
/* проверка прав стоит в fbr-doc.w */
run str/fbr-doc.w (
      input parparentproc
    , input this-procedure
    , input {&update}
    , input recid( f-doc )
    , output doc-rec
    , input-output v-fbr-doc-next-prev
) no-error.
if error-status:error
then do:
  find f-doc where recid (f-doc) = doc-rec no-lock.
  return no-apply.
end.
run UI-on in this-procedure ( input yes ).

END.

ON CHOOSE OF b-del IN FRAME {&frame-name} /* Удал */ DO:
define variable del-rec as recid no-undo.
define buffer buf_marking-lines     for ub.marking-lines.
define buffer buf_del_marking-lines for ub.marking-lines.
define buffer buf_marking           for ub.marking.
{ gbl/stdbtn.i }
{&net-proc}

if f-doc.status_ = {&doc-froze}
then do:
    find first f-doc no-lock
         where recid (f-doc) = doc-rec
    .
    message
        "Документ в статусе 'Нередактируемый' не может быть удален."
    view-as alert-box error.
    return no-apply.
end.

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_manufacturing_preparation':U
  {&cntxt-object}
  f-doc.host-code
  f-doc.obj-type
  f-doc.obj-code
  0
  0
  0
  true
  v-yesno
}
{&if-not-true}
assign v-yesno = no.

if lookup( f-doc.status_, {&fact_permitted} ) <> 0
then do:
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_manufacturing_del-manuf-fact':U
      {&cntxt-object}
      f-doc.host-code
      f-doc.obj-type
      f-doc.obj-code
      0
      0
      0
      true
      v-yesno
    }
    {&if-not-true}
end.

message "Удалить документ № " f-doc.doc-code
        " ?   Вы уверены ?"
view-as alert-box question buttons OK-Cancel update v-yesno.
{&if-not-true}
{ gbl/working.i }
br-handle = br-docs:handle.
if valid-handle (br-handle) then do:
  v-yesno = br-handle:select-next-row().
  if not v-yesno then v-yesno = br-handle:select-prev-row().
  del-rec = recid (f-doc).
end.
find first f-doc no-lock
        where recid (f-doc) = doc-rec
no-error.
if not available f-doc
then do:
    message "Неправильно выбран документ."
    view-as alert-box error.
    { gbl/stopwork.i }
    undo, return no-apply.
end.

if lookup( f-doc.status_, {&fact_permitted} ) <> 0
then do:
    run fbrlib-delete-fact-fbr-doc in this-procedure (
        input parparentproc
       ,input f-doc.doc-code
       ,input ? /*p-chip-num*/
    ) no-error.
    if error-status :error
    then do:
        run fbrlib-print-del-error-message in this-procedure .
        { gbl/stopwork.i }
        return no-apply.
    end.
    else do:
        assign
            v-yesno = br-handle:select-prev-row().
        .
        del-rec = recid (f-doc).
    end.
end.        /* f-doc.status_ = {&fact_permitted} */
else do:
    do transaction
    on stop undo, return no-apply:
        define buffer buf_del_fbr-line          for fbr-line.
        define buffer buf_del_fbr-doc           for fbr-doc.
        define buffer buf_del_fbr-recipe        for fbr-recipe.
        define buffer buf_del_fbr-recipe-gds    for fbr-recipe-gds.
        define buffer buf_fbr-recipe            for fbr-recipe.
        define buffer buf_fbr-recipe-gds        for fbr-recipe-gds.
        define buffer buf_goods                 for goods.
        
        for each buf_fbr-recipe-gds no-lock
           where buf_fbr-recipe-gds.doc-code      = f-doc.doc-code
        :
            find first buf_del_fbr-recipe-gds exclusive-lock
                 where recid( buf_del_fbr-recipe-gds ) = recid( buf_fbr-recipe-gds )
            .
            delete buf_del_fbr-recipe-gds.
        end.
        for each buf_fbr-recipe no-lock
           where buf_fbr-recipe.doc-code      = f-doc.doc-code
        :
            find first buf_del_fbr-recipe exclusive-lock
                 where recid( buf_del_fbr-recipe ) = recid( buf_fbr-recipe )
            .
            delete buf_del_fbr-recipe.
        end.
        for each fbr-line no-lock
           where fbr-line.doc-code = f-doc.doc-code
        :
            /* удаляем марки, привязанные к док-ту */
            for first buf_goods no-lock where buf_goods.artic     = fbr-line.artic
                                          and buf_goods.prod-type = fbr-line.prod-type
                                          and buf_goods.prod-code = fbr-line.prod-code,
            each buf_marking-lines no-lock where buf_marking-lines.gds-code = buf_goods.gds-code
                                             and buf_marking-lines.obj-code = f-doc.obj-code
                                             and buf_marking-lines.obj-type = f-doc.obj-type
                                             and buf_marking-lines.in-code  = "manufacturing"
                                             and buf_marking-lines.out-code = f-doc.doc-code
                                             and buf_marking-lines.part-code = fbr-line.recipe-code
                                             and buf_marking-lines.prt-code = 0
            :
              /* меняем статус марки на Свободную Зону */
              find first buf_marking exclusive-lock
                   where buf_marking.mark = buf_marking-lines.mark 
              no-error.
              if available buf_marking
              then
              assign
                buf_marking.sts = cStsMark:FreeZone:KeyIntDB when not fbr-line.is-comp
                buf_marking.sts = cStsMark:UsedInProduction:KeyIntDB when fbr-line.is-comp
              .
              find first buf_del_marking-lines exclusive-lock
                   where recid( buf_del_marking-lines ) = recid( buf_marking-lines )
              .
              delete buf_del_marking-lines.
            end .  
            find first buf_del_fbr-line exclusive-lock
                 where recid( buf_del_fbr-line ) = recid( fbr-line )
            .
            delete buf_del_fbr-line.
        end.
        find first buf_del_fbr-doc exclusive-lock
             where recid( buf_del_fbr-doc ) = recid( f-doc )
        .
        delete f-doc.
    end.
end.        /* f-doc.status_ <> {&fact_permitted} */
assign
    doc-rec = del-rec
.
{ gbl/stopwork.i }
run UI-on in this-procedure ( input yes ).
END.

ON CHOOSE OF b-lkp IN FRAME {&frame-name} DO:
  if not available f-doc then do:
    message "Неправильный выбор документа."
            view-as alert-box error.
            return no-apply.
  end.
    
{ gbl/stdbtn.i }
define variable v-fbr-doc-next-prev    as logical      no-undo.
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_manufacturing_lookup':U
  {&cntxt-object}
  f-doc.host-code
  f-doc.obj-type
  f-doc.obj-code
  0
  0
  0
  true
  v-yesno
}
if not v-yesno then
  return no-apply.
v-fbr-doc-next-prev = yes.
br-handle = br-docs:handle.
do while v-fbr-doc-next-prev <> ?:
  if not available f-doc then do:
    message "Неправильный выбор документа."
            view-as alert-box error.
    return no-apply.
  end.
  assign
    doc-rec = recid (f-doc)
  .
  run str/fbr-doc.w (
      input parparentproc
    , input this-procedure
    , input {&lookup}
    , input doc-rec
    , output doc-rec
    , input-output v-fbr-doc-next-prev
  ).
end.
if br-handle = ? then
  reposition br-docs to recid doc-rec no-error.
apply "entry" to br-docs in frame {&frame-name}.
apply "value-changed" to br-docs in frame {&frame-name}.
END.

ON CHOOSE OF b-gds IN FRAME {&frame-name} DO:
{ gbl/stdbtn.i }
if not available f-doc then do:
  message "Неправильно выбран документ."
          view-as alert-box error.
  return no-apply.
end.
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_manufacturing_lookup':U
  {&cntxt-object}
  f-doc.host-code
  f-doc.obj-type
  f-doc.obj-code
  0
  0
  0
  true
  v-yesno
}
if not v-yesno then
  return no-apply.
assign
    doc-rec = recid (f-doc)
    gds-rec   = ?
.
run str/fbr-igds.w (
      input parparentproc
    , input doc-rec
    , input-output gds-rec
).
apply "entry" to br-docs in frame {&frame-name}.
END.

ON CHOOSE OF b-print IN FRAME {&frame-name} DO:
{ gbl/stdbtn.i }
if not available f-doc then do:
  message "Неправильно выбран документ."
          view-as alert-box error.
  return no-apply.
end.
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_manufacturing_print':U
  {&cntxt-object}
  f-doc.host-code
  f-doc.obj-type
  f-doc.obj-code
  0
  0
  0
  true
  v-yesno
}
if not v-yesno then
  return no-apply.
doc-rec = recid (f-doc).
run str/fbr-dprn.w ( input parparentproc, input doc-rec ).
apply "entry" to br-docs.
END.

ON entry OF ed-notes IN FRAME {&frame-name} DO:
if not available f-doc then do:
  message "Неправильно выбран документ."
          view-as alert-box error.
  return no-apply.
end.
doc-rec = recid (f-doc).
if f-doc.status_ <> {&fact} and
   substring (f-doc.PS, 1, 1) = "@" then
  message "Чтобы программа не могла заново переписать Ваше примечание, удалите знак @."
          view-as alert-box information.
END.

ON leave OF ed-notes IN FRAME {&frame-name} DO:
do on stop undo, return no-apply:
  find f-d-b where recid (f-d-b) = doc-rec exclusive.
  f-d-b.PS = input frame {&frame-name} ed-notes.
end.
END.

ON RETURN, MOUSE-SELECT-DBLCLICK OF ed-notes IN FRAME {&frame-name} DO:
apply "entry" to br-docs in frame {&frame-name}.
return no-apply.
END.

ON RETURN, MOUSE-SELECT-DBLCLICK OF br-docs IN FRAME {&frame-name} DO:
if p-list-mode = {&choose} then
  apply "choose" to b-sel in frame {&frame-name}.
else
  apply "choose" to b-lkp in frame {&frame-name}.
END.

ON value-changed OF br-docs do:
    if available f-doc
    then do:
        { gbl/usrnick.i
            f-doc.user-name
            v-fbr-docs-nik
        }
        { gbl/usrnick.i
            f-doc.creid
            v-fbr-docs-oper-nik
        }
        assign
            ed-notes = f-doc.PS
        .
        display
            ed-notes
        with frame {&frame-name}.
        display
            f-doc.sys-date
            f-doc.sys-time
        with frame {&frame-name}.
        /* doc-rec = recid (f-doc) - это сюда ставить нельзя, неправ. будет работать leave ed-notes */
        if doc-rec <> recid (f-doc)
        then do:
            assign
                sch-num = 0
            .
            hide
                sch-num
            in frame {&frame-name}.
        end.
    end.
    else do:
        assign
            v-fbr-docs-nik      = "":U
            v-fbr-docs-oper-nik = "":U
        .
    end.
    display
        v-fbr-docs-nik
        v-fbr-docs-oper-nik
    with frame {&frame-name} .
end.

/*{ g b l / f l t - s c h . i trig code doc-code }*/
/*{ g b l / f l t - s c h . i trig date doc-date }*/
/*{ g b l / f l t - s c h . i trig fact fact-date }*/

{ gbl/hot-key.i b-print }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-close }
{ gbl/hot-key.i b-open }
{ gbl/hot-key.i b-del }

ON CHOOSE OF b-sel IN FRAME {&frame-name} DO:
{ gbl/stdbtn.i }
if available f-doc
then do:
    assign
        p-rid-list = string(recid( f-doc ))
    .
end.
apply "go" to frame {&frame-name}.
END.

on choose of b-sch in frame {&frame-name} do:
{ gbl/stdbtn.i }
do on stop undo, leave:
    run init-flt in this-procedure .
    run gbl/filter.w (
          input parparentproc
        , input c-point
        , input tbl
        , input join-tbl
        , input fld
        , input lab
        , input spr
        , input dim
    ).
    run UI-on in this-procedure ( input yes ).
end.
end.


ON RETURN, MOUSE-SELECT-DBLCLICK, ctrl-j OF sch-code IN FRAME d-fbr-docs DO:

    define variable v-reposition-recid      as recid        no-undo.
    define variable v-prepare-string        as character    no-undo.

    if sch-code <> input frame d-fbr-docs sch-code
    or sch-field <> "doc-code"
    then do:
        assign
            sch-num = 0
        .
        hide sch-num in frame d-fbr-docs.
    end.
    assign
        sch-field   = "doc-code":U
        sch-code    = input frame d-fbr-docs sch-code
        sch-date    = ?
        sch-fact    = ?
    .
    if browse br-docs :query :dynamic = yes
    then do:
        assign
            v-prepare-string = browse br-docs :query :prepare-string
        .
    end.
    else do:
        assign
            v-prepare-string = substitute( "for each f-doc where &1 ", v-fbr-docs-where-cond )
        .
    end.
    if sch-code <> ?
    and trim( sch-code ) <> "":U
    then do:
        run get-recid in this-procedure (
              input v-prepare-string
            , input sch-num
            , input "doc-code":U
            , input trim( sch-code )
            , output v-reposition-recid
        ) no-error.
        if not error-status :error
        and v-reposition-recid <> ?
        and v-reposition-recid <> 0
        then do:
            assign
                sch-num = sch-num + 1
                doc-rec = v-reposition-recid
            .
            reposition br-docs to recid v-reposition-recid no-error.
            display
                sch-num
                sch-date
                sch-fact
            with frame {&frame-name} .
        end.
    end.        /* if sch-code <> "":U  */

END.



ON RETURN, MOUSE-SELECT-DBLCLICK, ctrl-j OF sch-date IN FRAME d-fbr-docs DO:

    define variable v-reposition-recid      as recid        no-undo.
    define variable v-prepare-string        as character    no-undo.

    if sch-date <> input frame d-fbr-docs sch-date
    or sch-field <> "doc-date"
    then do:
        assign
            sch-num = 0
        .
        hide sch-num in frame d-fbr-docs.
    end.
    assign
        sch-field   = "doc-date":U
        sch-date    = input frame d-fbr-docs sch-date
        sch-code    = "":U
        sch-fact    = ?
    .
    if browse br-docs :query :dynamic = yes
    then do:
        assign
            v-prepare-string = browse br-docs :query :prepare-string
        .
    end.
    else do:
        assign
            v-prepare-string = substitute( "for each f-doc where &1 ", v-fbr-docs-where-cond )
        .
    end.
    if sch-date <> ?
    then do:
        run get-recid in this-procedure (
              input v-prepare-string
            , input sch-num
            , input "doc-date":U
            , input substitute( "&1/&2/&3", day( sch-date ), month( sch-date ), year( sch-date ) )
            , output v-reposition-recid
        ) no-error.
        if not error-status :error
        and v-reposition-recid <> ?
        and v-reposition-recid <> 0
        then do:
            assign
                sch-num = sch-num + 1
                doc-rec = v-reposition-recid
            .
            reposition br-docs to recid v-reposition-recid no-error.
        end.
        display
            sch-num
            sch-code
            sch-fact
        with frame {&frame-name} .
    end.        /* if sch-code <> "":U  */


END.

ON RETURN, MOUSE-SELECT-DBLCLICK, ctrl-j  OF sch-fact IN FRAME d-fbr-docs DO:

    define variable v-reposition-recid      as recid        no-undo.
    define variable v-prepare-string        as character    no-undo.

    if sch-fact <> input frame d-fbr-docs sch-fact
    or sch-field <> "fact-date"
    then do:
        assign
            sch-num = 0
        .
        hide sch-num in frame d-fbr-docs.
    end.
    assign
        sch-field   = "fact-date":U
        sch-fact    = input frame d-fbr-docs sch-fact
        sch-code    = "":U
        sch-date    = ?
    .
    if browse br-docs :query :dynamic = yes
    then do:
        assign
            v-prepare-string = browse br-docs :query :prepare-string
        .
    end.
    else do:
        assign
            v-prepare-string = substitute( "for each f-doc where &1 ", v-fbr-docs-where-cond )
        .
    end.
    if sch-fact <> ?
    then do:
        run get-recid in this-procedure (
              input v-prepare-string
            , input sch-num
            , input "fact-date":U
            , input substitute( "&1/&2/&3", day( sch-fact ), month( sch-fact ), year( sch-fact ) )
            , output v-reposition-recid
        ) no-error.
        if not error-status :error
        and v-reposition-recid <> ?
        and v-reposition-recid <> 0
        then do:
            assign
                sch-num = sch-num + 1
                doc-rec = v-reposition-recid
            .
            reposition br-docs to recid v-reposition-recid no-error.
        end.
        display
            sch-num
            sch-code
            sch-date
        with frame {&frame-name} .
    end.        /* if sch-code <> "":U  */


END.


/* ***************************  Main Block  *************************** */

IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i &browse-name="br-docs" }
{ gbl/setfltnm.i }
{ gbl/brwrefre.i "if available f-doc then doc-rec = recid(f-doc). run UI-on in this-procedure ( input yes ) ." }

cStsMark = ObjSrv:Env:Marking:Sts:Mark.

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

    { gbl/getcntxt.i get " " parparentproc }
    run get-report-num in parparentproc (
        output g#report-num
    ).
    run get-quest-print in parparentproc (
        output g#quest-print
    ).
    { gbl/hostname.i
        v-cntxt-obj-type
        v-cntxt-obj-code
        v-host-code
        v-host-name
    }
    if p-rid-list <> '':U then do:
      assign
      doc-rec = integer(entry(1, p-rid-list)).
    end.
    enable
        b-quit
        b-lkp
        b-print
        b-sch
        b-help
        b-hist
        br-docs
        sch-code
        sch-date
        sch-fact
        ed-notes
        b-sel
        b-gds
    with frame {&frame-name}.
  run UI-on in this-procedure ( input yes ).
  
  if not( v-cntxt-db-num-obj = v-cntxt-db-num )
    and ( v-cntxt-db-num-obj <> 0 )
    then do:        /* Если объект не активный и удалённый */
        /*message
            "Производство возможно только на активном объекте."
            view-as alert-box error.*/
        disable
            b-add
            b-del
            b-chg
            b-open
            b-close
            b-sel
            with frame {&frame-name}.
    end.
  
  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus br-docs.
END.
RUN disable_UI.

/* **********************  Internal Procedures  *********************** */

PROCEDURE disable_UI :
  HIDE FRAME d-fbr-docs.
END PROCEDURE.

PROCEDURE UI-on :
define input  parameter p-open-query     as logical   no-undo .

/* ------------------------------------------------------------------------------------------------------------ */
if p-open-query = yes
then do:
    frame {&frame-name}:title = "ВСЕ  АКТЫ ПРОИЗВОДСТВА".
    assign
        sch-num = 0
    .
    hide sch-num in frame {&frame-name}.
end.
else do:
    assign
        doc-rec = ?
    .
end.
define variable v-query-was-opened as logical no-undo .
assign
  v-query-was-opened = false
.
/* определяем здесь общие параметры для процедуры открытия query fltopend.i */

&scop flt-open-open-query open query br-docs for each f-doc no-lock

&scop flt-open-query-handle query br-docs:handle

&scop flt-open-dyn_open-query for each f-doc

&scop flt-open-query-was-opened  v-query-was-opened

&scop flt-open-call-point c-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-debug-file

&scop flt-open-find-next

&scop flt-open-find-recid

&scop flt-open-query

&scop flt-open-table-name

&scop flt-open-search-option

&scop flt-open-find-recid

&scop flt-open-waitfram true

case p-list-mode
:
    when {&work}
    then do:
        if p-open-query = yes
        then do:
            /* ENABLE b-add b-chg b-del b-close WITH FRAME {&frame-name}. */
            assign
                v-fbr-docs-where-cond = " true ":U
            .
            assign
                c-point = "пр-во " + p-list-mode
            .
            { gbl/fltopend.i
                &where-cond=" true"
                &use-ind=" "
                &by=" "
            }
        end.
    end.        /* when {&work} */
/*    &scop where-cond true*/
/*    &scop use-ind*/
/*    { s t r / f l t - f b r . i }*/
    when {&company}
    then do:
        if p-open-query = yes
        then do:
            frame {&frame-name} :title = substitute( "Документы производства. Фирма : &1", v-host-name ).
            /* ENABLE b-add b-chg b-del b-close WITH FRAME {&frame-name}. */
            assign
                v-fbr-docs-where-cond = substitute(' f-doc.host-code = &1', v-cntxt-host-code-obj )
            .
            assign
                c-point = "пр-во " + {&work}
            .
            { gbl/fltopend.i
                &where-cond=" f-doc.host-code = v-cntxt-host-code-obj"
                &dyn_where-cond=" substitute(' f-doc.host-code = &1', v-cntxt-host-code-obj ) "
                &use-ind=" use-index host-date"
                &by=" "
            }
        end.
    end.        /* when {&company} */
/*    &scop where-cond ~{&buf}.host-code = v-cntxt-host-code-obj*/
/*    &scop use-ind use-index host-date*/
/*    { s t r / f l t - f b r . i }*/
    when {&g___object}
    then do:
        if p-open-query = yes
        then do:
            frame {&frame-name} :title = substitute( "Документы производства. Объект : &1 &2", v-cntxt-obj-type, v-cntxt-obj-code ).
            enable
                b-add
                b-chg
                b-del
                b-close
                b-open
            with frame {&frame-name}.
            assign
                v-fbr-docs-where-cond = substitute('f-doc.host-code = &1 and f-doc.obj-type = "&2" and f-doc.obj-code = &3', v-cntxt-host-code-obj, v-cntxt-obj-type, v-cntxt-obj-code )
            .
            assign
                c-point = "пр-во " + p-list-mode
            .
            { gbl/fltopend.i
                &where-cond=" f-doc.host-code = v-cntxt-host-code-obj and f-doc.obj-type = v-cntxt-obj-type and f-doc.obj-code = v-cntxt-obj-code"
                &dyn_where-cond=" substitute('f-doc.host-code = &2 and f-doc.obj-type = &1&3&1 and f-doc.obj-code = &4', ~{&double-quote~}, v-cntxt-host-code-obj, v-cntxt-obj-type, v-cntxt-obj-code )"
                &use-ind="use-index host-date"
                &by=" "
            }
        end.
/*    &scop where-cond ~{&buf}.obj-type = v-cntxt-obj-type ~*/
/*                and ~{&buf}.obj-code = v-cntxt-obj-code*/
/*    &scop use-ind use-index obj-date*/
/*    { s t r / f l t - f b r . i }*/
    end.        /* when {&g___object} */
    when {&choose}
    then do:
        if p-open-query = yes
        then do:
            frame {&frame-name} :title = substitute( "Документы производства. Объект : &1 &2"
                                                    , v-cntxt-obj-type
                                                    , v-cntxt-obj-code ).
            assign
                v-fbr-docs-where-cond = substitute('f-doc.obj-type = "&1" and f-doc.obj-code = &2', v-cntxt-obj-type, v-cntxt-obj-code)
            .
            assign
                c-point = "пр-во " + {&g___object}
            .
            { gbl/fltopend.i
                &where-cond=" f-doc.obj-type = v-cntxt-obj-type and f-doc.obj-code = v-cntxt-obj-code"
                &dyn_where-cond=" substitute('f-doc.obj-type = &1&2&1 and f-doc.obj-code = &3', ~{&double-quote~}, v-cntxt-obj-type, v-cntxt-obj-code)"
                &use-ind="use-index obj-date"
                &by=" "
            }
        end.
    end.        /* when {&choose} */
/*    &scop where-cond ~{&buf}.obj-type = v-cntxt-obj-type ~*/
/*                and ~{&buf}.obj-code = v-cntxt-obj-code*/
/*    &scop use-ind use-index obj-date*/
/*  { s t r / f l t - f b r . i }*/
    when {&status}
    then do:
        if p-open-query = yes
        then do:
            frame {&frame-name}:title = substitute( "Документы производства. Объект : &1 &2  Статус : &3"
                                                    , v-cntxt-obj-type
                                                    , v-cntxt-obj-code
                                                    , p-status-available ).
            enable
                b-add
                b-chg
                b-del
                b-close
                b-open
            with frame {&frame-name}.
            assign
                v-fbr-docs-where-cond = substitute('f-doc.obj-type = "&1" and f-doc.obj-code = &2 and f-doc.doc-type = "&3" and f-doc.status_ = "&4"', v-cntxt-obj-type, v-cntxt-obj-code, {&manufacturing}, p-status-available)
            .
            assign
                c-point = {&all} + "пр-во " /* + g#type */
            .
            { gbl/fltopend.i
                &where-cond=" f-doc.obj-type = v-cntxt-obj-type and f-doc.obj-code = v-cntxt-obj-code and f-doc.doc-type = {&manufacturing} and f-doc.status_ = p-status-available"
                &dyn_where-cond=" substitute('f-doc.obj-type = &1&2&1 and f-doc.obj-code = &3 and f-doc.doc-type = &1&4&1 and f-doc.status_ = &1&5&1', ~{&double-quote~}, v-cntxt-obj-type, v-cntxt-obj-code, {&manufacturing}, p-status-available)"
                &use-ind="use-index stat-date"
                &by=" "
            }
        end.
/*    &scop where-cond ~{&buf}.obj-type = v-cntxt-obj-type ~*/
/*                and ~{&buf}.obj-code = v-cntxt-obj-code ~*/
/*                and ~{&buf}.doc-type = {&manufacturing} ~*/
/*                and ~{&buf}.status_ = p-status-available*/
/*    &scop use-ind use-index stat-date*/
/*  { s t r / f l t - f b r . i }*/
    end.        /* when {&status} */
end case.
if v-query-was-opened = false
then do:
    assign
        frame {&frame-name}:title = substitute( "Документы производства. Недопустимое сочетание параметров отбора документов производства" )
    .
    run UI-on-empty in this-procedure (
          input  p-open-query
    ).
end.
if p-open-query <> yes
and available f-d-b
then do:
    assign
        doc-rec = recid (f-d-b)
    .
end.
/* при поиске doc-rec = ? либо как выставлено в начале UI-on, либо заново сброшено в pr-sch.p */
if doc-rec <> ?
then do:
    if p-open-query <> yes
    then do:
        assign
            sch-num = sch-num + 1
        .
        disp sch-num with frame {&frame-name}.
    end.
    reposition br-docs to recid doc-rec no-error.
end.
else
  if p-open-query <> yes
  then do:
    message "Акт производства не найден." view-as alert-box error.
    sch-num = 0.
  end.
apply "entry" to br-docs in frame {&frame-name}.
apply "value-changed" to br-docs in frame {&frame-name}.

if available f-doc
then do:
    { gbl/usrnick.i
        f-doc.user-name
        v-fbr-docs-nik
    }
    { gbl/usrnick.i
        f-doc.creid
        v-fbr-docs-oper-nik
    }
end.
else do:
    assign
        v-fbr-docs-nik      = "":U
        v-fbr-docs-oper-nik = "":U
    .
end.
display
    v-fbr-docs-nik
    v-fbr-docs-oper-nik
with frame {&frame-name} .
END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE open-fbr-doc {&FRAME-NAME}
PROCEDURE open-fbr-doc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-fbr-doc-doc-code as character    no-undo.

    define variable v-fbroperator-string    as character    no-undo.
    define variable v-par-type              as character    no-undo.
    define variable varchip-code like ub.c-trn-doc.chip-num no-undo .
    define variable varchip-code2 like ub.c-trn-doc.chip-num no-undo .

    define buffer buf_fbr-line      for fbr-line.
    define buffer buf_del_fbr-line  for fbr-line.
    define buffer buf_fbr-doc       for fbr-doc.
do
for buf_fbr-line
  , buf_del_fbr-line
  , buf_fbr-doc
on error undo, return error
:
    run fbrattr-value in this-procedure (
          input {&fbrattr-type-fbr-doc}
        , input p-fbr-doc-doc-code
        , input {&trdcattr-fbroperator}
        , output v-fbroperator-string
    ).
    run fbrlib-del-trn-doc in this-procedure (
          input parparentproc
        , input p-fbr-doc-doc-code
        , input {&expense}
        , input ?
        , output varchip-code
    ) no-error.
    if error-status:error then do:
      message
      substitute("Ошибка при удалении складского документа, созданного по документу производства &1&2&3&2&4"
                  , f-doc.doc-code
                  , {&new-line}
                  , error-status:get-message(1)
                  , return-value
                  )
      view-as alert-box error .
    end.
    run fbrlib-del-trn-doc in this-procedure (
          input parparentproc
        , input p-fbr-doc-doc-code
        , input {&write-off}
        , input varchip-code
        , output varchip-code2

    ) no-error.
    if error-status:error then do:
      message
      substitute("Ошибка при удалении складского документа, созданного по документу производства &1&2&3&2&4"
                  , f-doc.doc-code
                  , {&new-line}
                  , error-status:get-message(1)
                  , return-value
                  )
      view-as alert-box error .
    end.
    do transaction
    on error undo, return error
    :
        for each buf_fbr-line no-lock
           where buf_fbr-line.doc-code = p-fbr-doc-doc-code
        on error undo, return error
        :
            find first buf_del_fbr-line exclusive-lock
                where recid( buf_del_fbr-line ) = recid( buf_fbr-line )
            .
            if buf_del_fbr-line.rsrv-qnty <> ?
            then do:
                assign
                    buf_del_fbr-line.rsrv-qnty = 0
                .
            end.
            assign
                buf_del_fbr-line.price-base = ?
                buf_del_fbr-line.price-rubl = ?
                buf_del_fbr-line.price-sum-base = ?
                buf_del_fbr-line.price-sum-rubl = ?
                buf_del_fbr-line.price-sum-vat-base = ?
                buf_del_fbr-line.price-sum-vat-rubl = ?
                buf_del_fbr-line.fix-cost = no
            .
        end.
        find first buf_fbr-doc exclusive-lock
            where buf_fbr-doc.doc-code = p-fbr-doc-doc-code
        .
        assign
            buf_fbr-doc.status_     = {&g___new}
            buf_fbr-doc.in-qnty     = 0
            buf_fbr-doc.out-qnty    = 0
            buf_fbr-doc.in-sale     = ?
            buf_fbr-doc.out-sale    = ?
            buf_fbr-doc.in-base     = 0
            buf_fbr-doc.in-rubl     = 0
            buf_fbr-doc.in-vat-base = 0
            buf_fbr-doc.in-vat-rubl = 0
        .
    end.        /* do transaction */
    /* Восстановить информацию об операторе производства (если она была) */
    if v-fbroperator-string <> "":U
    and v-fbroperator-string <> ?
    and v-fbroperator-string <> "0":U
    then do:
        run fbrattr-write in this-procedure (
              input {&fbrattr-type-fbr-doc}
            , input p-fbr-doc-doc-code
            , input {&trdcattr-fbroperator}
            , input v-fbroperator-string
        ) no-error.
        if error-status :error
        then do:
            message
                    vss-workfile vss-revision vss-description
                skip(1)
                skip "Не удалось создать запись оператора производства."
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
            view-as alert-box warning.
        end.
    end.
end.
END PROCEDURE. /* open-fbr-doc */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-flt {&FRAME-NAME}
PROCEDURE init-flt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    assign
        tbl         = "fbr-doc":U
        join-tbl    = "f-doc":U
        fld         = "status_,doc-code,doc-date,fact-date,obj-type{&delim-flt}obj-code,creid":U
        lab         = "Статус,,Дата,Факт,Объект,":U
        spr         = "fbr-stat,,,,cli,":U
        dim         = "6":U
    .
    run fltfield-clear in this-procedure (
          output fld
        , output lab
        , output spr
        , output dim
    )  no-error.
    run fltfield-add in this-procedure ( 'out-code'                       , 'Номер план-меню/продажи'   , ''        , input-output fld, input-output lab, input-output spr, input-output dim )  no-error.
/*    run fltfield-add in this-procedure ( 'obj-type{&delim-flt}obj-code'   , 'Объект'                  , 'cli'     , input-output fld, input-output lab, input-output spr, input-output dim )  no-error.*/
    run fltfield-add in this-procedure ( 'doc-code'                       , 'Номер'                     , ''        , input-output fld, input-output lab, input-output spr, input-output dim )  no-error.
    run fltfield-add in this-procedure ( 'status_'                        , 'Статус'                    , ''        , input-output fld, input-output lab, input-output spr, input-output dim )  no-error.
    run fltfield-add in this-procedure ( 'in-qnty'                        , 'Кол.при'                   , ''        , input-output fld, input-output lab, input-output spr, input-output dim )  no-error.
    run fltfield-add in this-procedure ( 'out-qnty'                       , 'Кол.рас'                   , ''        , input-output fld, input-output lab, input-output spr, input-output dim )  no-error.
    run fltfield-add in this-procedure ( 'fact-date'                      , 'Дата факт'                 , ''        , input-output fld, input-output lab, input-output spr, input-output dim )  no-error.
/*    run fltfield-add in this-procedure ( 'in-base'                     , 'Цена (вал)'                 , ''        , input-output fld, input-output lab, input-output spr, input-output dim )  no-error.*/
/*    run fltfield-add in this-procedure ( 'in-rubl'                     , 'Цена ({&abbr_rub})'         , ''        , input-output fld, input-output lab, input-output spr, input-output dim )  no-error.*/
end.
END PROCEDURE. /* init-flt */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE UI-on-empty {&FRAME-NAME}
PROCEDURE UI-on-empty :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
  define input  parameter p-open-query     as logical   no-undo .

  define variable v-query-was-opened as logical no-undo .

  define buffer buf_goods for ub.goods .

  assign
      v-fbr-docs-where-cond = " false ":U
  .

  { gbl/fltopend.i
    &where-cond = " false"
    &use-ind=" "
    &by=" "
  }

end.
END PROCEDURE. /* UI-on-empty */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-recid {&FRAME-NAME}
PROCEDURE get-recid :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-query-string           as character        no-undo.
define input parameter p-num-rec                as integer          no-undo.
define input parameter p-field-name             as character        no-undo.
define input parameter p-field-value            as character        no-undo.
define output parameter p-reposition-recid      as recid            no-undo.


    define variable v-query-handle          as handle       no-undo.
    define variable v-buffer-handle         as handle       no-undo.
    define variable v-query-string          as character    no-undo.
    define variable v-by-position           as integer      no-undo.
    define variable v-use-index-position    as integer      no-undo.
    define variable v-by-string             as character    no-undo.
    define variable v-sch-counter           as integer      no-undo.
do
on error undo, return error
:
    assign
        v-query-string = replace( p-query-string, "indexed-reposition", "" )
    .
    assign
        v-use-index-position    = index( v-query-string, " use-index ":U )
        v-by-position           = index( v-query-string, " by ":U )
    .
    assign
        v-by-position = minimum( v-use-index-position, v-by-position )
    .
    if v-by-position > 0
    then do:
        assign
            v-by-string     = substring( v-query-string, v-by-position )
            v-query-string  = substring( v-query-string, 1, v-by-position - 1 )
        .
    end.
    else do:
        assign
            v-by-string = "":U
        .
    end.
    if p-field-name = "doc-code":U
    then do:
        assign
            v-query-string = substitute( " &1 and f-doc.&2 begins '&3' &4"
                                    , v-query-string
                                    , p-field-name
                                    , p-field-value
                                    , v-by-string           )
        .
    end.
    else do:
        assign
            v-query-string = substitute( " &1 and f-doc.&2 <= &3 &4 by f-doc.&2 descending"
                                    , v-query-string
                                    , p-field-name
                                    , p-field-value
                                    , v-by-string           )
        .

    end.
    assign
        v-query-string = replace( v-query-string , "f-doc":U, "buf_code_fbr-doc":U )
    .
    create buffer v-buffer-handle   for table "fbr-doc":U buffer-name "buf_code_fbr-doc":U .
    create query v-query-handle .
    v-query-handle :set-buffers( v-buffer-handle ).
    v-query-handle :query-prepare( v-query-string ) .
    v-query-handle :query-open().
    v-query-handle :get-first().
    if not v-query-handle :query-off-end
    then do:
        v-query-handle :get-first().
        go-next-rec:
        do v-sch-counter = 1 to p-num-rec
        :
            v-query-handle :get-next().
            if v-query-handle :query-off-end
            then do:
                assign
                   sch-num = v-sch-counter
                .
                leave go-next-rec.
            end.
        end.
        if not v-query-handle :query-off-end
        then do:
            assign
                p-reposition-recid = v-buffer-handle :recid
            .
        end.
    end.
/*    message*/
/*        "X"*/
/*        skip v-query-handle :num-results*/
/*        skip p-reposition-recid*/
/*        skip v-buffer-handle :buffer-field( "doc-code":U ) :buffer-value*/
/*    view-as alert-box information.*/
    delete object v-query-handle.
    delete object v-buffer-handle.
end.
END PROCEDURE. /* get-recid */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME