block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-otcstr.p $
$Archive: cus/r-otcstr.p $

Таможенная оборотка - формирование временных таблиц

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/21/06
Author: Bakhtadze Natalya
Creation date: 03/21/06

*/

define input parameter x-date-start as date no-undo .
define input parameter x-date-end   as date no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-otcstr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-otcstr.p $":U .
define variable vss-description as character no-undo init "Таможенная оборотка - формирование временных таблиц".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ cus/r-otcst.i }
{ cmp/obj-list.i new }
{ trg/factord.i }
{ trg/partslib.i }
{ gbl/waitfram.i }


DEFINE VARIABLE v_os-file   AS CHAR NO-UNDO INIT "".
DEFINE VARIABLE ll_commit AS LOG    NO-UNDO INIT NO.
DEFINE VARIABLE file-name as character no-undo .
define variable varexport-line as integer no-undo.
DEFINE VARIABLE doc-num like ub.trn-doc.doc-code no-undo.
DEFINE VARIABLE is-out as decimal no-undo.
DEFINE VARIABLE is-sale as logical no-undo.
DEFINE VARIABLE is-ext_expense as logical no-undo.
DEFINE VARIABLE is-other_expense as logical no-undo.
DEFINE VARIABLE prt-qnty as decimal no-undo.
DEFINE VARIABLE my-accum as integer no-undo .
DEFINE VARIABLE for-part-code like ub.parts.part-code no-undo.
DEFINE VARIABLE is-twounit as logical no-undo .
DEFINE VARIABLE first-find as logical no-undo.
DEFINE VARIABLE v-end-fact-order as decimal no-undo .
DEFINE VARIABLE v-shift-end-fact-order as decimal no-undo .
DEFINE VARIABLE v-day-end-fact-order as decimal no-undo .
DEFINE VARIABLE v-start-fact-order as decimal no-undo .
DEFINE VARIABLE is-zero as logical no-undo.

define stream str-file.
define buffer for-doc for ub.trn-doc.
define buffer for-line for ub.doc-line.
define buffer in-parts for ub.parts.
define buffer b-tt-cst for tt-cst.
define buffer tt-cst-zero-year for tt-cst-year.

define temp-table tt-file-ignore no-undo
field doc-code  like ub.trn-doc.doc-code
field artic     like ub.goods.artic
field prod-type like ub.goods.prod-type
field prod-code like ub.goods.prod-code
index pi is primary unique
doc-code
artic
prod-type
prod-code
.

&scoped-define INT-DOCS 'iv,rv,ev':U
&scoped-define PLUS-DOCS 'ie,re,rs,vt,im':U
/*приход внешний,возврат внешний,касса возврат,инвентаризация,приход производство*/
&scoped-define SALE-DOCS 'es,rs':U

/*согласно тех заданию должно быть так*/
&scoped-define EXT_EXPENSE-DOCS 'ee':U

/*но мы же умные люди и должны все предусмотреть*/
&scoped-define OTHER_EXPENSE-DOCS 'ep,re,we,vt,em,wm,im':U
/*возврат постащику возврат внешний списание инвентаризация расход пр-во спис пр-во приход пр-во*/
/*во общем все кроме внешнего прихода*/
&scoped-define NOT_EXPENSE-DOCS 'ie,es,rs':U

&scoped-define NOT_OTHER_EXPENSE-DOCS ~{&EXT_EXPENSE-DOCS~} + ~{&comma-char~} + ~{&NOT_EXPENSE-DOCS~}
/*все кроме этого но не INT-DOCS мы положим в поле которое НИКОМУ НЕ ПОКАЖЕМ но считать будем!!!*/


file-name = search("ignore.txt").
if file-name = ? then do:

   message "Не найден файл ignore.txt" skip
           "Попробуйте вручную задать путь к нему"
   view-as alert-box ERROR.

    SYSTEM-DIALOG GET-FILE v_os-file
        TITLE "Выберите файл для импорта ошибочных товаров"
        FILTERS
        " Все текстовые файлы (*.txt) " "*.txt",
        " Все файлы (*.*) "                      "*.*"
        INITIAL-FILTER 1
        DEFAULT-EXTENSION ".txt"
        USE-FILENAME
        MUST-EXIST
        UPDATE ll_commit
        .

    IF ll_commit <> YES THEN do:
       RETURN NO-APPLY.
    end.
    IF v_os-file = PROGRAM-NAME( 1 ) THEN DO:
        BELL.
        MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    ASSIGN
    file-name = ( IF SEARCH( v_os-file ) = ? THEN v_os-file ELSE SEARCH( v_os-file ) )
    .
end.

run waitfram-show in this-procedure ("Чтение файла ignore.txt...") .

input stream str-file from value(file-name).

repeat :
  assign varexport-line = varexport-line + 1.
  CREATE tt-file-ignore.
  import stream str-file tt-file-ignore.
  if TRIM(tt-file-ignore.doc-code) = ""
  then delete tt-file-ignore.
  find first ub.trn-doc where
             ub.trn-doc.doc-code = tt-file-ignore.doc-code no-lock no-error.
  if not available ub.trn-doc then do:
     message "В строке № " varexport-line " файла ignore.txt указан номер документа " tt-file-ignore.doc-code " ." skip
             "Данного документа нет в базе данных." skip
             "Исправьте файл ignore.txt."
     view-as alert-box.
     return error.
  end.
  find first ub.goods where
            ub.goods.artic     = tt-file-ignore.artic     and
            ub.goods.prod-type = tt-file-ignore.prod-type and
            ub.goods.prod-code = tt-file-ignore.prod-code no-lock no-error.
  if not available ub.goods then do:
     message "В строке № " varexport-line " файла ignore.txt указан товар: " skip
             "Артикул "           tt-file-ignore.artic     skip
             "Тип производителя " tt-file-ignore.prod-type skip
             "Код производителя " tt-file-ignore.prod-code skip
             "Данного товара нет в базе данных."
             "Исправьте файл ignore.txt."
     view-as alert-box.
     return error.
  end.
end.

for each obj-list:
  delete obj-list.
end.

FOR EACH tt-cst:
  delete tt-cst.
END.

FOR EACH tt-cst-ext:
  delete tt-cst-ext.
END.

FOR EACH tt-cst-year:
  delete tt-cst-year.
END.

for each ub.shop no-lock where
         ub.shop.host-code = p-host-code:
    { cmp/cr-objls.i "{&shop}" ub.shop.obj-code}
end.

for each ub.store no-lock where
         ub.store.host-code = p-host-code:
    { cmp/cr-objls.i "{&stock}" ub.store.obj-code}

end.

/*определение fact-order на конец отчетного периода*/

run factord in this-procedure
  (input  X-date-end              /* p-fact-date            */
  ,input  1                       /* p-fact-time            */
  ,input  1                       /* p-fact-num             */
  ,input  ?                       /* p-shift-date           */
  ,input  0                       /* p-shift-num            */
  ,input  false                   /* p-shift-on             */
  ,output v-end-fact-order        /* p-fact-order           */
  ,output v-shift-end-fact-order  /* p-shift-end-fact-order */
  ,output v-day-end-fact-order    /* p-day-end-fact-order   */
  ) no-error .
if error-status:error then return error.


run factord in this-procedure
  (input  (X-date-start - 1)      /* p-fact-date            */
  ,input  1                       /* p-fact-time            */
  ,input  1                       /* p-fact-num             */
  ,input  ?                       /* p-shift-date           */
  ,input  0                       /* p-shift-num            */
  ,input  false                   /* p-shift-on             */
  ,output v-end-fact-order        /* p-fact-order           */
  ,output v-shift-end-fact-order  /* p-shift-end-fact-order */
  ,output v-start-fact-order      /* p-day-end-fact-order   */
  ) no-error .
if error-status:error then return error.



/* придется пройти по всем gds-obj*/

&global-define wmess "Остатки по товарам на объектах фирмы..."

run waitfram-show in this-procedure ({&wmess}).
my-accum = 0.
_gds-obj:
FOR EACH obj-list NO-LOCK,
    EACH ub.gds-obj No-LOCK WHERE
         ub.gds-obj.obj-type = obj-list.obj-type AND
         ub.gds-obj.obj-code = obj-list.obj-code:
  /*по архивам ищем было ли уже движение по этому объекте по этому товару до конца отчетного периода*/
  find first ub.STK-LINE NO-LOCK where
             ub.STK-LINE.OBJ-TYPE = obj-list.OBJ-TYPE and
             ub.STK-LINE.OBJ-CODE = obj-list.OBJ-CODE and
             ub.stk-line.artic = ub.gds-obj.artic AND
             ub.stk-line.prod-type = ub.gds-obj.prod-type AND
             ub.stk-line.prod-code = ub.gds-obj.prod-code AND
             ub.stk-line.fact-order <= v-day-end-fact-order AND
             ub.stk-line.sum-type = {&arh-crsa} AND
             ub.stk-line.cat-id = {&root-cat-id} No-ERROR.
  /* если этот товарчик родился позже отчетного периода то хрен с ним*/
  if not avail ub.stk-line then next _gds-obj.
  /* а если он уже достаточно старый то придется собирать остатки по партиям и звать Мишу*/

  run partslib-init-temp-parts-by-factord in this-procedure(
                                                        input obj-list.obj-type,
                                                        input obj-list.obj-code,
                                                        input ub.gds-obj.artic,
                                                        input ub.gds-obj.prod-type,
                                                        input ub.gds-obj.prod-code,
                                                        input v-day-end-fact-order,
                                                        input false
                                                        ) .
  /* Миша чего-то нашел !!! */

  { cus/r-otcstr.i rest }

  run partslib-update-by-factord in this-procedure(
                                                        input obj-list.obj-type,
                                                        input obj-list.obj-code,
                                                        input ub.gds-obj.artic,
                                                        input ub.gds-obj.prod-type,
                                                        input ub.gds-obj.prod-code,
                                                        input v-start-fact-order,
                                                        input v-day-end-fact-order,
                                                        input true
                                                        ) .

  { cus/r-otcstr.i start }

end.

/*на данный момент мы знаем все остатки на конец*/
/*теперь собираем движение*/

&undefine wmess
&global-define wmess "Получение информации по расходам..."

run waitfram-show in this-procedure ({&wmess}).

my-accum = 0.

FOR EACH obj-list NO-LOCK:

  FOR EACH for-doc No-LOCK WHERE
          for-doc.obj-type = obj-list.obj-type AND
          for-doc.obj-code = obj-list.obj-code AND
          for-doc.fact-date >= X-date-start AND
          for-doc.fact-date <= X-date-end AND
          for-doc.status_ = {&fact}:
          /*не можем ограничиться только внешними документами потому что производство - внутренний*/
    if for-doc.office then NEXT.
    /*отсекаем внутренний приход расход и возврат*/
    if LOOKUP(for-doc.ext-doc-type, {&INT-DOCS}) > 0 then NEXT.
    /*оставляем только*/
    assign
    doc-num = for-doc.doc-code
    is-out = if LOOKUP(for-doc.ext-doc-type, {&PLUS-docs}) > 0  then 1 else -1
    is-sale = if lookup(for-doc.ext-doc-type, {&SALE-DOCS}) > 0
              then yes else no
    is-ext_expense = if lookup(for-doc.ext-doc-type, {&ext_expense-docs}) > 0
                     then yes else no
    is-other_expense = if lookup(for-doc.ext-doc-type, {&NOT_OTHER_EXPENSE-DOCS}) = 0
                     then yes else no
    .
    { cus/r-otcstr.i moving }
  END.
END. /*FOR EACH obj-list*/

&undefine wmess
&global-define wmess "Список ГТД, исключенных из отчета..."

run waitfram-show in this-procedure ({&wmess}).
my-accum = 0.
for each obj-list No-LOCK:
_zero:
  for each for-doc No-LOCK WHERE
           for-doc.obj-type = obj-list.obj-type AND
           for-doc.obj-code = obj-list.obj-code AND
           for-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} AND
           for-doc.status_ = {&fact},
      each for-line No-LOCK WHERE
           for-line.doc-code = for-doc.doc-code,
      each ub.parts No-LOCK WHERE
           ub.parts.artic = for-line.artic AND
           ub.parts.prod-type = for-line.prod-type AND
           ub.parts.prod-code = for-line.prod-code AND
           ub.parts.out-code = for-doc.doc-code AND
           ub.parts.obj-type = for-line.obj-type AND
           ub.parts.obj-code = for-line.obj-code:

    if ub.parts.is-supp = no then next _zero.
    if ub.parts.cst-code = "" then next _zero.
    my-accum = my-accum + 1.

    IF my-accum MODULO 50  = 0 then do:
      run waitfram-show in this-procedure ({&wmess} + " Обработано " + string(my-accum) + " приходных партий ").
    end.


    /*найдем количества изначального прихода*/
    find first tt-cst where
               tt-cst.cst-code = ub.parts.cst-code AND
               tt-cst.artic = ub.parts.artic AND
               tt-cst.prod-type = ub.parts.prod-type AND
               tt-cst.prod-code = ub.parts.prod-code NO-ERROR.
    /*товар в ошибочных tt-file-ignore либо с нулевыми остатками на конец отчетного периода и без движения*/
    if not avail tt-cst then do:
      /*он в tt-file-ignore ?*/
      if can-FIND(FIRST tt-file-ignore No-LOCK WHERE
                        tt-file-ignore.doc-code = for-doc.doc-code AND
                        tt-file-ignore.artic = for-line.artic AND
                        tt-file-ignore.prod-type = for-line.prod-type AND
                        tt-file-ignore.prod-code = for-line.prod-code) then next _zero.
      assign
      is-zero = yes.
    end.
    else do:
      /*проставим количества первоначального прихода*/
      assign
      tt-cst.qnty-income = tt-cst.qnty-income + ub.parts.fact-qnty
      tt-cst.num-place = tt-cst.num-place + for-line.num-place * ub.parts.fact-qnty / for-line.fact-qnty
      tt-cst.brutto = tt-cst.brutto + for-line.wt-brutto * ub.parts.fact-qnty / for-line.fact-qnty
      is-zero = no
      .
    end.
    find first tt-cst-year WHERE
               tt-cst-year.cst-code = ub.parts.cst-code No-ERROR.
    if not avail tt-cst-year then do:
      create tt-cst-year.
      assign
      tt-cst-year.cst-code = ub.parts.cst-code
      tt-cst-year.in-year = year(for-doc.fact-date)
      tt-cst-year.zero = is-zero
      .
    end.
    else do:
      tt-cst-year.zero = is-zero.
      /*нашлась более строчка по более ранней накладной с таким ГТД*/
      if tt-cst-year.in-year > year(for-doc.fact-date) then
      tt-cst-year.in-year = year(for-doc.fact-date)
      .
    end.
  end. /*for each for-doc*/
end. /*obj-list*/

run waitfram-hide in this-procedure .