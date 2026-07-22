/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Общие определения для динамика движения товара

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/29/03
Author: Bakhtadze Natalya
Creation date: 05/29/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define {1} temp-table t-month0 no-undo
field month_ as integer
field year_ as integer
field ym as integer
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index pi is unique primary
ym
.


define {1} temp-table t-dinamo no-undo
field month_ as integer
field year_ as integer
field ym as integer
field idoc-type as integer
field sign_ as integer
field doc-type like ub.trn-doc.doc-type
field ext-doc-type like ub.ot-line.ext-doc-type
field doc-type-full as character format "X(18)"
field ext-doc-type-full as character format "X(18)"
field fact-qnty like ub.stk-line.fact-qnty
field sale-sum-rubl like ub.stk-line.sum-rubl
field sale-sum-base like ub.stk-line.sum-base
field cost-sum-rubl like ub.stk-line.sum-rubl
field cost-sum-base like ub.stk-line.sum-base
field doc-sum-rubl like ub.stk-line.sum-rubl
field doc-sum-base like ub.stk-line.sum-base
field is-zuka as logical
index pi is unique primary
ym
idoc-type
ext-doc-type
/*для показа*/
index iext-doc-type
ym
ext-doc-type
sign_
/*для поиска уже имеющихся при создании*/
index izuka
ym
ext-doc-type
/*дял создания zuki*/
.

define {1} temp-table t-stk-obj no-undo
field month_ as integer
field year_ as integer
field ym as integer
field b-a as integer
/* 0 - начало месяца */
/*1 - конец месяца */
field b-a-full as character
field fact-qnty like ub.stk-line.fact-qnty
field sale-sum-rubl like ub.stk-line.sum-rubl
field sale-sum-base like ub.stk-line.sum-base
field cost-sum-rubl like ub.stk-line.sum-rubl
field cost-sum-base like ub.stk-line.sum-base
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index pi is unique primary
ym
b-a
obj-type
obj-code
index iobj
obj-type
obj-code
ym descending
b-a descending
.

define {1} temp-table t-stk no-undo
field month_ as integer
field year_ as integer
field ym as integer
field b-a as integer
/* 0 - начало месяца */
/*1 - конец месяца */
field b-a-full as character
field fact-qnty like ub.stk-line.fact-qnty
field sale-sum-rubl like ub.stk-line.sum-rubl
field sale-sum-base like ub.stk-line.sum-base
field cost-sum-rubl like ub.stk-line.sum-rubl
field cost-sum-base like ub.stk-line.sum-base
index pi is unique primary
ym
b-a
.

define {1} temp-table t-fo0 no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
field fact-order like ub.stk-line.fact-order
field cfact-date as date
field ym as integer
index pi is unique primary
obj-type
obj-code
fact-order
.

&glob f-qnty "->>,>>>,>>9.999"
&glob f-sum  "->>,>>>,>>>,>>>,>>9.99"
&glob f-pcnt "->>,>>9.99%"
&glob f-sqnty "X(15)"
&glob f-ssum  "X(22)"
&glob doc-ext-doc-type-list  (~{&TDEDT_Ras_Vnesh~} + ~{&comma-char~} + ~
                              ~{&TDEDT_Ras_Vnesh_Kass~} + ~{&comma-char~} + ~
                              ~{&TDEDT_Vozvrat_Vnesh~} + ~{&comma-char~} + ~
                              ~{&TDEDT_Vozvrat_Vnesh_Kass~})

&GLOB frame-title       ("код товара:" + ~{&space-char~} + ~
             string(buf_goods.gds-code) + ~{&space-char~} + "артикул:" + ~{&space-char~} + ~
             buf_goods.artic + ~{&space-char~} + ~
             buf_goods.prod-type + string(buf_goods.prod-code) + ~{&space-char~} + ~
             string(buf_goods.gds-name, "X(20)") + ~{&space-char~} + ~
             (if avail t-month then ~
             ("Динамика за":U + ~{&space-char~} + v-month-name + ~
             ~{&space-char~} + string(t-month.year_)) ~
             else "":U))


FUNCTION get-doc-type RETURNS CHARACTER
  ( input p-ii as integer, input-output p-ext-doc-type as character, input-output p-sign as character, output p-ext-doc-type-full as character, output p-doc-type-full as character, output p-idoc-type as character ) :

/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE v-doc-type as character no-undo .

assign
p-ext-doc-type-full = entry(p-ii, {&TDEDT_List-full})
.
  CASE p-ext-doc-type:
    when {&TDEDT_Pri_Vnesh}
 or when {&TDEDT_Pri_Perem}
 or when {&TDEDT_Pri_Prvo}
 then do:
      assign
      v-doc-type = {&income}
      p-doc-type-full = "Приход"
      p-idoc-type = string(1)
      p-sign = string(0)
      .
    end.
    when {&TDEDT_Ras_Vnesh}
 or when {&TDEDT_Ras_Vnesh_Kass}
 or when {&TDEDT_Spi_Vnesh}
 or when {&TDEDT_Ras_Vnesh_VP}
 or when {&TDEDT_Ras_Perem}
 or when {&TDEDT_Spi_Prvo} then do:
      assign
      v-doc-type = {&expense}
      p-doc-type-full = "Расход"
      p-idoc-type  = string(2)
      p-sign = string(0)
      .
    end.
    when {&TDEDT_Vozvrat_Vnesh}
 or when {&TDEDT_Vozvrat_Vnesh_Kass}
 or when {&TDEDT_Vozvrat_Perem} then do:
      assign
      v-doc-type = {&return}
      p-doc-type-full = "Возврат"
      p-idoc-type = string(3)
      p-sign = string(0)
      .
    end.
    when {&TDEDT_Corr_Acc_Price} then do:
      assign
      v-doc-type = {&TDEDT_Corr_Acc_Price}
      p-doc-type-full = "Переоц.уч.цен"
      p-idoc-type = string(6)
      p-sign = string(0)
      .
    end.
    when {&TDEDT_Chg_Purch_Code} then do:
      assign
      v-doc-type = {&TDEDT_Chg_Purch_Code}
      p-doc-type-full = "Смена типа приобр."
      p-idoc-type = string( 5)
      p-sign = string(0)
      .
    end.
    when {&TDEDT_Overturn} then do:
      assign
      v-doc-type = {&TDEDT_Overturn}
      p-doc-type-full = "Переоценка"
      p-idoc-type = string(4)
      p-sign = string(0)
     .
    end.
    when {&TDEDT_Inv}      or
    when {&TDEDT_Peresort} then do:
      CASE p-sign:
        when string(0) then do:
          assign
          p-ext-doc-type = p-ext-doc-type + {&comma-char} + p-ext-doc-type
          v-doc-type = {&expense} + {&comma-char} + {&income}
          p-doc-type-full = "Расход" + {&comma-char} + "Приход"
          p-ext-doc-type-full = p-ext-doc-type-full + "(-)":U + {&comma-char} + p-ext-doc-type-full + "(+)":U
          p-idoc-type = string(2) + {&comma-char} + string(1)
          p-sign = string(-1) + {&comma-char} + string( 1)
          .
        end.
        when string(- 1) then do:
          assign
          v-doc-type = {&expense}
          p-doc-type-full = "Расход"
          p-ext-doc-type-full = p-ext-doc-type-full + "(-)":U
          p-idoc-type = string(2)
          p-sign = string( - 1)
          .
        end.
        when string(1) then do:
          assign
          v-doc-type = {&income}
          p-doc-type-full = "Приход"
          p-ext-doc-type-full = p-ext-doc-type-full + "(+)":U
          p-idoc-type =  string(1)
          p-sign = string(1)
          .

        end.
      END CASE.
    end.
    when {&TDEDT_Ras_Prvo} then do:
      assign
      v-doc-type = "":U
      p-doc-type-full = ""
      p-idoc-type = string( 0)
      p-sign = string(0)
      .
    end.
  END CASE.


  RETURN v-doc-type.   /* Function return value. */

END FUNCTION.

procedure proc-view-objects :
DEFINE VARIABLE v-attr-codes as character no-undo .
DEFINE VARIABLE v-attr-labels as character no-undo .
DEFINE VARIABLE v-output as character no-undo .

  do
  on error undo, return error
  :

    for each obj-list no-lock,
        first t-fo0 no-lock where
             t-fo0.obj-type = obj-list.obj-type
         AND t-fo0.obj-code = obj-list.obj-code
        :
      assign
      v-attr-codes = v-attr-codes + obj-list.obj-type + string(obj-list.obj-code) + {&comma-char}
      v-attr-labels = v-attr-labels + obj-list.obj-type + string(obj-list.obj-code) + fill( {&space-char}, 5) +
                      "Данные c" + {&space-char} + string(t-fo0.cfact-date, "99/99/9999") + {&comma-char}
      .
    end.
    assign
    v-attr-codes = right-trim(v-attr-codes, {&comma-char})
    v-attr-labels = right-trim(v-attr-labels, {&comma-char})
    .
    run gbl/d-list.w (
                  input "":U
                 ,input "Объекты, выбранные для показа динамики товара"
                 ,input v-attr-codes
                 ,input v-attr-labels
                 ,input {&comma-char}
                 ,input "":U
                 ,output v-output).
  end.

end procedure. /* proc-view-objects */

procedure proc-print-oborot :
define input parameter p-artic like ub.goods.artic no-undo .
define input parameter p-prod-type like ub.goods.prod-type no-undo .
define input parameter p-prod-code like ub.goods.prod-code no-undo .
define input parameter p-date-start as date no-undo .
define input parameter p-date-end as date no-undo .

DEFINE VARIABLE v-attr-codes as character no-undo .
DEFINE VARIABLE v-attr-labels as character no-undo .
DEFINE VARIABLE v-output as character no-undo .
DEFINE VARIABLE v-obj-type like ub.clients.obj-type no-undo .
DEFINE VARIABLE v-obj-code like ub.clients.obj-code no-undo .

  do
  on error undo, return error
  :

    for each obj-list no-lock:
      assign
      v-attr-codes = v-attr-codes + obj-list.obj-type + string(obj-list.obj-code) + {&comma-char}.
    end.
    assign
    v-attr-codes = right-trim(v-attr-codes, {&comma-char})
    .
    if num-entries(v-attr-codes) <> 1 then do:
      run gbl/d-list.w (
                    input "b-sel":U
                  ,input "Выберите объект для печати оборотной ведомости"
                  ,input v-attr-codes
                  ,input v-attr-codes
                  ,input {&comma-char}
                  ,input "":U
                  ,output v-output).
      if v-output = "":U then return.
      assign
      v-obj-type = substr(v-output, 1, 3)
      v-obj-code = integer(substr(v-output, 4))
      .
    end.
    else do:
      assign
      v-obj-type = substr(v-attr-codes, 1, 3)
      v-obj-code = integer(substr(v-attr-codes, 4))
      .
    end.
    run rep/e-good2.w (parParentProc,
                  p-artic,
                  p-prod-type,
                  p-prod-code,
                  p-date-start,
                  p-date-end,
                  v-obj-type,
                  v-obj-code
                    ) no-error.

  end.

end procedure. /* proc-print-oborot */


procedure proc-print-crd :
define input parameter p-artic like ub.goods.artic no-undo .
define input parameter p-prod-type like ub.goods.prod-type no-undo .
define input parameter p-prod-code like ub.goods.prod-code no-undo .
define input parameter p-date-start as date no-undo .
define input parameter p-date-end as date no-undo .

DEFINE VARIABLE v-attr-codes as character no-undo .
DEFINE VARIABLE v-attr-labels as character no-undo .
DEFINE VARIABLE v-output as character no-undo .
DEFINE VARIABLE v-obj-type like ub.clients.obj-type no-undo .
DEFINE VARIABLE v-obj-code like ub.clients.obj-code no-undo .

  do
  on error undo, return error
  :

    for each obj-list no-lock:
      assign
      v-attr-codes = v-attr-codes + obj-list.obj-type + string(obj-list.obj-code) + {&comma-char}.
    end.
    assign
    v-attr-codes = right-trim(v-attr-codes, {&comma-char})
    .
    if num-entries(v-attr-codes) <> 1 then do:
      run gbl/d-list.w (
                   input "b-sel":U
                  ,input "Выберите объект для печати карточки товара"
                  ,input v-attr-codes
                  ,input v-attr-codes
                  ,input {&comma-char}
                  ,input "":U
                  ,output v-output).
      if v-output = "":U then return.
      assign
      v-obj-type = substr(v-output, 1, 3)
      v-obj-code = integer(substr(v-output, 4))
      .
    end.
    else do:
      assign
      v-obj-type = substr(v-attr-codes, 1, 3)
      v-obj-code = integer(substr(v-attr-codes, 4))
      .
    end.
    run rep/g-gdscrd.p (parParentProc,
                  p-artic,
                  p-prod-type,
                  p-prod-code,
                  p-date-start,
                  p-date-end,
                  v-obj-type,
                  v-obj-code
                    ) no-error.

  end.

end procedure. /* proc-print-crd */


/* $Workfile$ e n d */