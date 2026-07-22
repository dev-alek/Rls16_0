block-level on error undo, throw.
/*

$Revision: f30204f76123, 1351, rls $
$Author: PGridchina $
$Date: Fri May 18 13:28:20 2018 +0300 $
$Workfile: r-ptrlch.p $
$Archive: rep/r-ptrlch.p $

Технологический отчет по АЗК - сбор данных и печать

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/16/05
Author: Bakhtadze Natalya
Creation date: 10/16/05

*/

/*
*** Информация по состоянию файла:
ТН-3359 Доработка технлогического отчета по ТЗ. В настоящий момент "заморожен" пункт ТЗ - о группировке ТРК/Назначение и Назначение/ТРК.
В связи с этим код для работы с группировкой - частично заблокирован в файле rep/e-ptrlch.w (Закладка-2) виджет выбора группировки сделан невидимым,
однако всё можно восстановить убрав комментарии.
В настоящем файле код для группировки - не закомментирован, но не работает, т.к. не получает из rep/e-ptrlch.w параметра p-rs-grp-tech-refuell.
В настоящий момент группировка не доделана. Сделано только: 1-возм выбора типа группировки в параметрах (Закл-2); 2-по выбору параметров - в Excel
меняются местами столбцы ТРК и Назначение. Всё.
Комментировать пока этот код не буду. 13.02.2015г Арн.
*/

define input parameter ParParentProc as logical no-undo.            /* ParParentProc */
define input parameter p-param-list as character no-undo.           /* Список цифровых кодов типов чеков */
define input parameter p-rs-grp-tech-refuell as integer no-undo.    /* Группировка итогов для раздела "ТехПролив" (ТРК/Назначение=1 или Назначение/ТРК=2 */
/*define input parameter p-tog-trans-cancell as logical.  /* 1 – Сброс топливных транзакций */     */
/*define input parameter p-tog-rcpt-overflow as logical.  /* 2 – Перелив */                        */
/*define input parameter p-tog-tech-refuel as logical.    /* 3 – Технологический пролив */         */
/*define input parameter p-tog-trans-transfer as logical. /* 4 – Перевод топливной транзакции */   */
/*define input parameter p-tog-unlock-trans as logical.   /* 5 – Разблокировка транзакций */       */
/*define input parameter p-tog-total-tech-chk as logical. /* 6 – Итоги по технологическим чекам  */*/

define variable vss-revision    as character no-undo init "$Revision: f30204f76123, 1351, rls $":U .
define variable vss-author      as character no-undo init "$Author: PGridchina $":U .
define variable vss-date        as character no-undo init "$Date: Fri May 18 13:28:20 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-ptrlch.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-ptrlch.p $":U .
define variable vss-description as character no-undo init "Технологический отчет по АЗК - сбор данных и печать".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-pril.i new }
{ cmp/r-page1.i }
{ gbl/waitfram.i }
{ gbl/prn-lib.i }
{ gbl/cur-time.i }

define variable Line as character no-undo.
define variable date_string as character no-undo.

define variable multi-obj as logical no-undo.
define variable obj-count as integer no-undo.
define variable jj as integer no-undo.
define variable v-chk-type like ub.chk-doc.chk-type no-undo.
define variable v-type-num as integer no-undo.


define variable accum-pay-desk-doc-qnty as decimal no-undo.
define variable accum-pay-desk-sum-base as decimal no-undo.
define variable accum-pay-desk-trans-number as integer no-undo.
  define variable accum-pay-desk-doc-qnty-ns as decimal no-undo.
  define variable accum-pay-desk-sum-base-ns as decimal no-undo.
  define variable accum-pay-desk-trans-number-ns as integer no-undo.
    define variable accum-doc-qnty-dest as decimal no-undo. /* Для итогов в разрезе "Назначение" (destination) */
    define variable accum-sum-base-dest as decimal no-undo. /* Для итогов в разрезе "Назначение" (destination) */
    define variable accum-trans-number-dest as integer no-undo. /* Для итогов в разрезе "Назначение" (destination) */
define variable accum-gds-code-doc-qnty as decimal no-undo.
define variable accum-gds-code-sum-base as decimal no-undo.
define variable accum-gds-code-trans-number as integer no-undo.
  define variable accum-gds-code-doc-qnty-ns as decimal no-undo.
  define variable accum-gds-code-sum-base-ns as decimal no-undo.
  define variable accum-gds-code-trans-number-ns as integer no-undo.
define variable accum-doc-qnty as decimal no-undo.
define variable accum-sum-base as decimal no-undo.
define variable accum-trans-number as integer no-undo.
  define variable accum-doc-qnty-ns as decimal no-undo.
  define variable accum-sum-base-ns as decimal no-undo.
  define variable accum-trans-number-ns as integer no-undo.

define buffer buf_chk-doc for ub.chk-doc.
define temp-table temp-petrol-chk no-undo
field obj-type like ub.chk-doc.obj-type init '':U
field obj-code like ub.chk-doc.obj-code init 0
field chk-type like ub.chk-doc.chk-type init 0
field pay-desk like ub.chk-doc.pay-desk init 0
field gds-code like ub.goods.gds-code
field pump like ub.chk-gds.pump         init 0
field pump-2 like ub.chk-gds.pump       init 0
field doc-qnty like ub.chk-gds.doc-qnty init 0
field doc-qnty-ns like ub.chk-gds.doc-qnty init 0   /* ТН-3359 Арн. 19.01.2015. Не пролито (ns = no spill) */
field sum-base like ub.chk-gds.sum-base init 0
field sum-base-ns like ub.chk-gds.sum-base init 0   /* ТН-3359 Арн. 19.01.2015. Не пролито (ns = no spill) */
field write-off-code like ub.chk-gds.write-off-code /* ТН-3359 Арн. 19.01.2015. В отчёт добавлено поле "Вид транзакции" для типов чеков "СбросТрнзкц" */
field trans-number as integer
field trans-number-ns as integer                    /* ТН-3359 Арн. 19.01.2015. Не пролито (ns = no spill) */
field pay-code like ub.chk-pay.pay-code          /* ТН-3359 Арн. 19.01.2015. Вид платежа для выборки и получения имени платежа в отчёте. */
field pay-name as character                         /* ТН-3359 Арн. 19.01.2015. Наименование платежа (см. для столбца отчёта "Назначение") */
field prim as logical
index pi is unique primary
obj-type obj-code
chk-type
pay-desk
gds-code
pump
pump-2
pay-code
index ip
prim
.

define buffer buf_temp-petrol-chk for temp-petrol-chk.
define buffer buf_temp2-petrol-chk for temp-petrol-chk.

define temp-table temp-goods no-undo
field gds-code like ub.goods.gds-code
field gds-name like ub.goods.gds-name
index pi is unique primary
gds-code.

define buffer buf_temp-goods for temp-goods.
define buffer buf2_temp-goods for temp-goods.

define stream ScreenStream.

/* Блокируем вывод на экран ТН-3359 10.02.2015 Арн. */
/*
DEFINE FRAME one-pump
buf_temp-petrol-chk.pay-desk column-label "Касса" format ">>>9"
buf_temp-goods.gds-name      column-label "Топливо" format "X(25)"
buf_temp-petrol-chk.pump     column-label "ТРК" format ">>>>9"
buf_temp-petrol-chk.doc-qnty column-label "Кол-во в л" format "->>,>>>,>>9.9999999999"
buf_temp-petrol-chk.sum-base column-label "Сумма" format "->>>,>>>,>>>,>>9.99"
buf_temp-petrol-chk.trans-number column-label "Кол-во чеков" format ">>>,>>>"
HEADER  date_string format "X(50)" AT 5
"Страница " AT 95 PAGE-NUMBER(PrnLibStream) AT 105 FORMAT ">>>9" SKIP
Line format "X(123)"   AT 1
with width  {&A4_CW0} down stream-io use-text.

DEFINE FRAME two-pump
buf_temp-petrol-chk.pay-desk column-label "Касса" format ">>>9"
buf_temp-goods.gds-name      column-label "Топливо" format "X(25)"
buf_temp-petrol-chk.pump     column-label "Откуда:!№ ТРК" format ">>>>9"
buf_temp-petrol-chk.pump-2   column-label "Kуда:!№ ТРК" format ">>>>9"
buf_temp-petrol-chk.doc-qnty column-label "Кол-во в л" format "->>,>>>,>>9.9999999999"
buf_temp-petrol-chk.sum-base column-label "Сумма" format "->>>,>>>,>>>,>>9.99"
buf_temp-petrol-chk.trans-number column-label "Кол-во чеков" format ">>>,>>>"
HEADER  date_string format "X(50)" AT 5
"Страница " AT 95 PAGE-NUMBER(PrnLibStream) AT 105 FORMAT ">>>9" SKIP
Line format "X(123)" AT 1
with width  {&A4_CW0} down stream-io use-text.
*/

FOR EACH temp-petrol-chk:
  delete temp-petrol-chk.
END.

run waitfram-show in this-procedure ("Ждите...").

for each obj-list No-LOCK:
  obj-count = obj-count + 1.
end.
if obj-count > 1 then do:
  multi-obj = yes.
end.


/* **********************  Internal Procedures  *********************** */


procedure fill-temp-table:
define input parameter p-doc-code like ub.chk-doc.doc-code no-undo.
define input parameter p-chk-type like ub.chk-doc.chk-type no-undo.
define variable v-write-off-code like ub.chk-doc.chk-type no-undo. /* ТН-3355 20.01.2015 Арн. Виды транзакций: 0 = не пролито; 1 = пролито. */
define variable v-pump as integer no-undo.
define variable v-pump-2 as integer no-undo.
define variable ii as integer no-undo.
define variable v-qnty like ub.chk-gds.doc-qnty no-undo init 0.
define variable v-sum like ub.chk-gds.sum-base no-undo init 0.
define variable v-pay-code as integer no-undo. /* ТН-3355 20.01.2015 Арн. */

define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_chk-pay for ub.chk-pay.
define buffer buf_cash-pay for ub.cash-pay.

define buffer buf_temp-petrol-chk for temp-petrol-chk.

  do
  on error undo, return error return-value
  :
    for each buf_chk-gds no-lock where
         buf_chk-gds.doc-code = buf_chk-doc.doc-code
      ,
      first buf_bar-code no-lock where buf_bar-code.b-code = buf_chk-gds.b-code
    :
      ii = ii + 1.
      if p-chk-type = integer({&rcpt-trans-transfer}) then /* Если тип чека = "ПеревТранзкц"... */
      do:
        if buf_chk-gds.doc-qnty < 0 then
        assign
          v-write-off-code = buf_chk-gds.write-off-code /* ТН-3355 20.01.2015 Арн. Считываем значения видов транзакций: 0 = не пролито; 1 = пролито. */
          v-pump = buf_chk-gds.pump
          v-qnty = abs(buf_chk-gds.doc-qnty)
          v-sum  = abs(buf_chk-gds.sum-base)
        .
        if buf_chk-gds.doc-qnty > 0 then
        assign
          v-write-off-code = buf_chk-gds.write-off-code /* ТН-3355 20.01.2015 Арн. Считываем значения видов транзакций: 0 = не пролито; 1 = пролито. */
          v-pump-2 = buf_chk-gds.pump
          v-qnty = abs(buf_chk-gds.doc-qnty)
          v-sum  = abs(buf_chk-gds.sum-base)
        .
      end.
      else
      do:
        assign
          v-write-off-code = buf_chk-gds.write-off-code /* ТН-3355 20.01.2015 Арн. Считываем значения видов транзакций: 0 = не пролито; 1 = пролито. */
          v-pump = buf_chk-gds.pump
          v-pump-2 = 0
          v-qnty = buf_chk-gds.doc-qnty
          v-sum  = (if buf_chk-gds.doc-qnty = 0 then 0 else buf_chk-gds.sum-base)
        .
      end.
        /*************************************************/
        if p-chk-type = integer({&rcpt-tech-refuell}) then    /* А */ /* Ветка - Если тип чека "ТехПролив"... */
        do:

          find first buf_chk-pay where
            buf_chk-pay.doc-code = buf_chk-doc.doc-code
          no-error.
          if available buf_chk-pay then
          do:
            v-pay-code = buf_chk-pay.pay-code. /* Код вида оплаты */
          end.
          else
          do:
            v-pay-code = -1.
          end.
          find first buf_temp-petrol-chk where
                buf_temp-petrol-chk.chk-type = buf_chk-doc.chk-type
            AND buf_temp-petrol-chk.obj-type = buf_chk-doc.obj-type
            AND buf_temp-petrol-chk.obj-code = buf_chk-doc.obj-code
            AND buf_temp-petrol-chk.pay-desk = buf_chk-doc.pay-desk
            AND buf_temp-petrol-chk.pay-code = v-pay-code               /* ТН-3355 20.01.2015 Арн. Код вида оплаты */
            AND buf_temp-petrol-chk.gds-code = buf_bar-code.gds-code
            AND buf_temp-petrol-chk.pump     = v-pump
            AND buf_temp-petrol-chk.pump-2   = v-pump-2 no-error.

          if not available buf_temp-petrol-chk then
          do:
            create buf_temp-petrol-chk.
            assign
              buf_temp-petrol-chk.chk-type = buf_chk-doc.chk-type
              buf_temp-petrol-chk.obj-type = buf_chk-doc.obj-type
              buf_temp-petrol-chk.obj-code = buf_chk-doc.obj-code
              buf_temp-petrol-chk.pay-desk = buf_chk-doc.pay-desk
              buf_temp-petrol-chk.write-off-code = v-write-off-code
              buf_temp-petrol-chk.gds-code = buf_bar-code.gds-code
              buf_temp-petrol-chk.pay-code = v-pay-code                 /* ТН-3355 20.01.2015 Арн. Код вида оплаты */
              buf_temp-petrol-chk.pump     = v-pump
              buf_temp-petrol-chk.pump-2   = v-pump-2
              buf_temp-petrol-chk.prim     = yes
           .
            for first buf_cash-pay where
              buf_cash-pay.cdpay-code = v-pay-code
            no-lock:
              assign
                buf_temp-petrol-chk.pay-name = buf_cash-pay.obj-name    /* Наименование "Назначение" (например: "Лаборатория" или "Мерник" и т.п., что задаст пользователь в ТН) */
              .
            end.
          end.
/*          if available buf_temp-petrol-chk then*/
          do:
            assign
              buf_temp-petrol-chk.doc-qnty = buf_temp-petrol-chk.doc-qnty + v-qnty
              buf_temp-petrol-chk.sum-base = buf_temp-petrol-chk.sum-base + v-sum
              buf_temp-petrol-chk.trans-number = buf_temp-petrol-chk.trans-number + 1
            .
          end.
/*message "doc-code" buf_chk-doc.doc-code "v-pay-code" buf_temp-petrol-chk.pay-code "gds" buf_temp-petrol-chk.gds-code  "qnty" buf_temp-petrol-chk.doc-qnty "type " buf_temp-petrol-chk.chk-type view-as alert-box.*/

        end.                                                  /* А */
        /*****************************************************************/
        else
        do:
          if p-chk-type <> integer({&rcpt-trans-transfer})
          or ii = 2 then
          do:
          
            find first buf_temp-petrol-chk where
                  buf_temp-petrol-chk.chk-type = buf_chk-doc.chk-type
              AND buf_temp-petrol-chk.obj-type = buf_chk-doc.obj-type
              AND buf_temp-petrol-chk.obj-code = buf_chk-doc.obj-code
              AND buf_temp-petrol-chk.pay-desk = buf_chk-doc.pay-desk
              AND buf_temp-petrol-chk.gds-code = buf_bar-code.gds-code
              AND buf_temp-petrol-chk.pump     = v-pump
              AND buf_temp-petrol-chk.pump-2   = v-pump-2 no-error.

            if not available buf_temp-petrol-chk then
            do:
              create buf_temp-petrol-chk.
              assign
                buf_temp-petrol-chk.chk-type = buf_chk-doc.chk-type
                buf_temp-petrol-chk.obj-type = buf_chk-doc.obj-type
                buf_temp-petrol-chk.obj-code = buf_chk-doc.obj-code
                buf_temp-petrol-chk.pay-desk = buf_chk-doc.pay-desk
                buf_temp-petrol-chk.write-off-code = v-write-off-code
                buf_temp-petrol-chk.gds-code = buf_bar-code.gds-code
                buf_temp-petrol-chk.pump     = v-pump
                buf_temp-petrol-chk.pump-2   = v-pump-2
                buf_temp-petrol-chk.prim     = yes
             .
            end.
/*             message  buf_temp-petrol-chk.gds-code "al" buf_temp-petrol-chk.chk-type "type" buf_temp-petrol-chk.doc-qnty  "doc-code" buf_chk-gds.doc-code view-as alert-box.*/
/*        assign*/
            if (p-chk-type = integer({&rcpt-trans-cancell}) or p-chk-type = integer({&rcpt-unlock-trans}))
            and v-write-off-code = 0
             then
            do:
                
              assign
                buf_temp-petrol-chk.doc-qnty-ns = buf_temp-petrol-chk.doc-qnty-ns + v-qnty
                buf_temp-petrol-chk.sum-base-ns = buf_temp-petrol-chk.sum-base-ns + v-sum
                buf_temp-petrol-chk.trans-number-ns = buf_temp-petrol-chk.trans-number-ns + 1
              .
            end.
            else
            do:
              assign
                buf_temp-petrol-chk.doc-qnty = buf_temp-petrol-chk.doc-qnty + v-qnty
                buf_temp-petrol-chk.sum-base = buf_temp-petrol-chk.sum-base + v-sum
                buf_temp-petrol-chk.trans-number = buf_temp-petrol-chk.trans-number + 1
              .
            end.
            
/*        .*/
          end. /*if p-chk-type <> integer({&rcpt-trans-transfer})*/
       end. /* else A */
    end. /*for each buf_chk-gds*/
  end. /*doe*/


end procedure. /* fill-temp-table */


procedure fill-sub-totals :
define variable v-write-off-code2 like ub.chk-doc.chk-type no-undo. /* ТН-3355 20.01.2015 Арн. Виды транзакций: 0 = не пролито; 1 = пролито. */

define buffer buf_temp-petrol-chk for temp-petrol-chk.

define buffer gds-obj_temp-petrol-chk for temp-petrol-chk.
/* итоги по товару по объекту pay-desk = 0 pump = 0 */

define buffer pay-desk_temp-petrol-chk for temp-petrol-chk.
/* итоги по всем типам чеков chk-type = 0 */


define buffer gds_temp-petrol-chk for temp-petrol-chk.
/* итоги по всем объектам по товару pay-desk = 0 pump = 0  obj-code = 0 */

define buffer gds-obj0_temp-petrol-chk for temp-petrol-chk.
/* итоги по всем типам чеков по товару по объекту pay-desk = 0 pump = 0 chk-type = 0 */

define buffer gds0_temp-petrol-chk for temp-petrol-chk.
/* итоги по всем типам чеков по товару по всем обектам pay-desk = 0 pump = 0  obj-code = 0 chk-type = 0 */

define buffer dest_temp-petrol-chk for temp-petrol-chk.
/* итоги по столбцу "Назначение" */

define buffer pay-desk2_temp-petrol-chk for temp-petrol-chk.
/* итоги одного товара по "Кассе" */

define buffer pay-desk3_temp-petrol-chk for temp-petrol-chk.
/* итоги все товары по "Кассе" */

define buffer gds2_temp-petrol-chk for temp-petrol-chk.
/* итоги по "Топливо", "Назначение" */

define buffer buf_goods for ub.goods.
define buffer buf_temp-goods for temp-goods.

  do
  on error undo, return error return-value
  :

    for each buf_temp-petrol-chk where buf_temp-petrol-chk.prim = yes:

      find first pay-desk_temp-petrol-chk where
              pay-desk_temp-petrol-chk.chk-type = 0
          AND pay-desk_temp-petrol-chk.obj-type = buf_temp-petrol-chk.obj-type
          AND pay-desk_temp-petrol-chk.obj-code = buf_temp-petrol-chk.obj-code
          AND pay-desk_temp-petrol-chk.pay-desk = buf_temp-petrol-chk.pay-desk
          AND pay-desk_temp-petrol-chk.gds-code = buf_temp-petrol-chk.gds-code
          AND pay-desk_temp-petrol-chk.pump     = buf_temp-petrol-chk.pump
          AND pay-desk_temp-petrol-chk.pump-2   = 0
           and pay-desk_temp-petrol-chk.pay-code = 0
                   
          no-error.
      if not available pay-desk_temp-petrol-chk then
      do:
        create pay-desk_temp-petrol-chk.
        assign
          pay-desk_temp-petrol-chk.chk-type = 0
          pay-desk_temp-petrol-chk.obj-type = buf_temp-petrol-chk.obj-type
          pay-desk_temp-petrol-chk.obj-code = buf_temp-petrol-chk.obj-code
          pay-desk_temp-petrol-chk.pay-desk = buf_temp-petrol-chk.pay-desk
          pay-desk_temp-petrol-chk.gds-code = buf_temp-petrol-chk.gds-code
          pay-desk_temp-petrol-chk.pay-code = 0
          
          pay-desk_temp-petrol-chk.pump     = buf_temp-petrol-chk.pump
          pay-desk_temp-petrol-chk.pump-2   = 0
        .
      end.
      /* Категория "Для всех чеков" - учитывает пролито/не пролито!!! Заполняем тело таблицы ГруппаИтогов-1 и 2 */
      assign
        pay-desk_temp-petrol-chk.doc-qnty        = pay-desk_temp-petrol-chk.doc-qnty        + buf_temp-petrol-chk.doc-qnty      + buf_temp-petrol-chk.doc-qnty-ns
        pay-desk_temp-petrol-chk.sum-base        = pay-desk_temp-petrol-chk.sum-base        + buf_temp-petrol-chk.sum-base      + buf_temp-petrol-chk.sum-base-ns
        pay-desk_temp-petrol-chk.trans-number    = pay-desk_temp-petrol-chk.trans-number    + buf_temp-petrol-chk.trans-number  + buf_temp-petrol-chk.trans-number-ns
      .

      find first gds-obj_temp-petrol-chk where
              gds-obj_temp-petrol-chk.chk-type = buf_temp-petrol-chk.chk-type
          AND gds-obj_temp-petrol-chk.obj-type = buf_temp-petrol-chk.obj-type
          AND gds-obj_temp-petrol-chk.obj-code = buf_temp-petrol-chk.obj-code
          AND gds-obj_temp-petrol-chk.pay-desk = 0
          AND gds-obj_temp-petrol-chk.gds-code = buf_temp-petrol-chk.gds-code
          AND gds-obj_temp-petrol-chk.pump     = 0
          and gds-obj_temp-petrol-chk.pay-code = 0
          AND gds-obj_temp-petrol-chk.pump-2   = 0 no-error.
      if not available gds-obj_temp-petrol-chk then
      do:
        create gds-obj_temp-petrol-chk.
        assign
          gds-obj_temp-petrol-chk.chk-type = buf_temp-petrol-chk.chk-type
          gds-obj_temp-petrol-chk.obj-type = buf_temp-petrol-chk.obj-type
          gds-obj_temp-petrol-chk.obj-code = buf_temp-petrol-chk.obj-code
          gds-obj_temp-petrol-chk.pay-desk = 0
          gds-obj_temp-petrol-chk.gds-code = buf_temp-petrol-chk.gds-code
          gds-obj_temp-petrol-chk.write-off-code = buf_temp-petrol-chk.write-off-code
          gds-obj_temp-petrol-chk.pump     = 0
          gds-obj_temp-petrol-chk.pump-2   = 0
           gds-obj_temp-petrol-chk.pay-code = 0
        .
      end.
      
      
        do:
          assign
            gds-obj_temp-petrol-chk.doc-qnty        = gds-obj_temp-petrol-chk.doc-qnty        + buf_temp-petrol-chk.doc-qnty
            gds-obj_temp-petrol-chk.sum-base        = gds-obj_temp-petrol-chk.sum-base        + buf_temp-petrol-chk.sum-base
            gds-obj_temp-petrol-chk.trans-number    = gds-obj_temp-petrol-chk.trans-number    + buf_temp-petrol-chk.trans-number
            gds-obj_temp-petrol-chk.doc-qnty-ns     = gds-obj_temp-petrol-chk.doc-qnty-ns     + buf_temp-petrol-chk.doc-qnty-ns
            gds-obj_temp-petrol-chk.sum-base-ns     = gds-obj_temp-petrol-chk.sum-base-ns     + buf_temp-petrol-chk.sum-base-ns
            gds-obj_temp-petrol-chk.trans-number-ns = gds-obj_temp-petrol-chk.trans-number-ns + buf_temp-petrol-chk.trans-number-ns
          .
        end.
       
      /* ******* по "НАЗНАЧЕНИЕ" ******* */
      if buf_temp-petrol-chk.chk-type = integer({&rcpt-tech-refuell}) then
      do:
          find first dest_temp-petrol-chk where
                  dest_temp-petrol-chk.chk-type = buf_temp-petrol-chk.chk-type
              AND dest_temp-petrol-chk.obj-type = buf_temp-petrol-chk.obj-type
              AND dest_temp-petrol-chk.obj-code = buf_temp-petrol-chk.obj-code
              AND dest_temp-petrol-chk.pay-desk = 0
              AND dest_temp-petrol-chk.gds-code = buf_temp-petrol-chk.gds-code
              AND dest_temp-petrol-chk.pump     = 0
              AND dest_temp-petrol-chk.pump-2   = 0
              AND dest_temp-petrol-chk.pay-code = buf_temp-petrol-chk.pay-code
              no-error.
          if not available dest_temp-petrol-chk then
          do:
            create dest_temp-petrol-chk.
            assign
              dest_temp-petrol-chk.chk-type = buf_temp-petrol-chk.chk-type
              dest_temp-petrol-chk.obj-type = buf_temp-petrol-chk.obj-type
              dest_temp-petrol-chk.obj-code = buf_temp-petrol-chk.obj-code
              dest_temp-petrol-chk.pay-desk = 0
              dest_temp-petrol-chk.gds-code = buf_temp-petrol-chk.gds-code
              dest_temp-petrol-chk.pump     = 0
              dest_temp-petrol-chk.pump-2   = 0
              dest_temp-petrol-chk.pay-code = buf_temp-petrol-chk.pay-code
              dest_temp-petrol-chk.pay-name = buf_temp-petrol-chk.pay-name
            .
          end.
            do:
              assign
                dest_temp-petrol-chk.doc-qnty        = dest_temp-petrol-chk.doc-qnty        + buf_temp-petrol-chk.doc-qnty
                dest_temp-petrol-chk.sum-base        = dest_temp-petrol-chk.sum-base        + buf_temp-petrol-chk.sum-base
                dest_temp-petrol-chk.trans-number    = dest_temp-petrol-chk.trans-number    + buf_temp-petrol-chk.trans-number
              .
            end.
      end.
      /* ******* по "НАЗНАЧЕНИЕ" ******* */

      /* ******* одного товара по "КАССЕ" ******* */
      if buf_temp-petrol-chk.chk-type = integer({&rcpt-tech-refuell}) then
      do:
          find first pay-desk2_temp-petrol-chk where
                  pay-desk2_temp-petrol-chk.chk-type = buf_temp-petrol-chk.chk-type
              AND pay-desk2_temp-petrol-chk.obj-type = buf_temp-petrol-chk.obj-type
              AND pay-desk2_temp-petrol-chk.obj-code = buf_temp-petrol-chk.obj-code
              AND pay-desk2_temp-petrol-chk.pay-desk = buf_temp-petrol-chk.pay-desk
              AND pay-desk2_temp-petrol-chk.gds-code = buf_temp-petrol-chk.gds-code
              AND pay-desk2_temp-petrol-chk.pump     = 0
              AND pay-desk2_temp-petrol-chk.pump-2   = 0
              AND pay-desk2_temp-petrol-chk.pay-code = buf_temp-petrol-chk.pay-code
              no-error.
          if not available pay-desk2_temp-petrol-chk then
          do:
            create pay-desk2_temp-petrol-chk.
            assign
              pay-desk2_temp-petrol-chk.chk-type = buf_temp-petrol-chk.chk-type
              pay-desk2_temp-petrol-chk.obj-type = buf_temp-petrol-chk.obj-type
              pay-desk2_temp-petrol-chk.obj-code = buf_temp-petrol-chk.obj-code
              pay-desk2_temp-petrol-chk.pay-desk = buf_temp-petrol-chk.pay-desk
              pay-desk2_temp-petrol-chk.gds-code = buf_temp-petrol-chk.gds-code
              pay-desk2_temp-petrol-chk.pump     = 0
              pay-desk2_temp-petrol-chk.pump-2   = 0
              pay-desk2_temp-petrol-chk.pay-code = buf_temp-petrol-chk.pay-code
                pay-desk2_temp-petrol-chk.pay-name = buf_temp-petrol-chk.pay-name
            .
          end.
            do:
              assign
                pay-desk2_temp-petrol-chk.doc-qnty        = pay-desk2_temp-petrol-chk.doc-qnty        + buf_temp-petrol-chk.doc-qnty
                pay-desk2_temp-petrol-chk.sum-base        = pay-desk2_temp-petrol-chk.sum-base        + buf_temp-petrol-chk.sum-base
                pay-desk2_temp-petrol-chk.trans-number    = pay-desk2_temp-petrol-chk.trans-number    + buf_temp-petrol-chk.trans-number
              .
            end.
      end.
      /* ******* одного товара по "КАССЕ" ******* */

      /* ******* всех товаров по "КАССЕ" ******* */
      if buf_temp-petrol-chk.chk-type = integer({&rcpt-tech-refuell}) then
      do:
          find first pay-desk3_temp-petrol-chk where
                  pay-desk3_temp-petrol-chk.chk-type = buf_temp-petrol-chk.chk-type
              AND pay-desk3_temp-petrol-chk.obj-type = buf_temp-petrol-chk.obj-type
              AND pay-desk3_temp-petrol-chk.obj-code = buf_temp-petrol-chk.obj-code
              AND pay-desk3_temp-petrol-chk.pay-desk = buf_temp-petrol-chk.pay-desk
              AND pay-desk3_temp-petrol-chk.gds-code = 0
              AND pay-desk3_temp-petrol-chk.pump     = 0
              AND pay-desk3_temp-petrol-chk.pump-2   = 0
              AND pay-desk3_temp-petrol-chk.pay-code = buf_temp-petrol-chk.pay-code
              no-error.
          if not available pay-desk3_temp-petrol-chk then
          do:
            create pay-desk3_temp-petrol-chk.
            assign
              pay-desk3_temp-petrol-chk.chk-type = buf_temp-petrol-chk.chk-type
              pay-desk3_temp-petrol-chk.obj-type = buf_temp-petrol-chk.obj-type
              pay-desk3_temp-petrol-chk.obj-code = buf_temp-petrol-chk.obj-code
              pay-desk3_temp-petrol-chk.pay-desk = buf_temp-petrol-chk.pay-desk
              pay-desk3_temp-petrol-chk.gds-code = 0
              pay-desk3_temp-petrol-chk.pump     = 0
              pay-desk3_temp-petrol-chk.pump-2   = 0
              pay-desk3_temp-petrol-chk.pay-code = buf_temp-petrol-chk.pay-code
              pay-desk3_temp-petrol-chk.pay-name = buf_temp-petrol-chk.pay-name
            .
          end.
            do:
              assign
                pay-desk3_temp-petrol-chk.doc-qnty        = pay-desk3_temp-petrol-chk.doc-qnty        + buf_temp-petrol-chk.doc-qnty
                pay-desk3_temp-petrol-chk.sum-base        = pay-desk3_temp-petrol-chk.sum-base        + buf_temp-petrol-chk.sum-base
                pay-desk3_temp-petrol-chk.trans-number    = pay-desk3_temp-petrol-chk.trans-number    + buf_temp-petrol-chk.trans-number
              .
            end.
            
      end.
      /* ******* всех товаров по "КАССЕ" ******* */

      /* ******* по "ТОПЛИВО(товар)", "НАЗНАЧЕНИЕ" ******* */
      if buf_temp-petrol-chk.chk-type = integer({&rcpt-tech-refuell}) then
      do:
          find first gds2_temp-petrol-chk where
                  gds2_temp-petrol-chk.chk-type = buf_temp-petrol-chk.chk-type
              AND gds2_temp-petrol-chk.obj-type = buf_temp-petrol-chk.obj-type
              AND gds2_temp-petrol-chk.obj-code = buf_temp-petrol-chk.obj-code
              AND gds2_temp-petrol-chk.pay-desk = 0
              AND gds2_temp-petrol-chk.gds-code = 0 /* Исключаем, т.к. вывод только по товару и назначению. */
              AND gds2_temp-petrol-chk.pump     = 0
              AND gds2_temp-petrol-chk.pump-2   = 0
              AND gds2_temp-petrol-chk.pay-code = buf_temp-petrol-chk.pay-code
              no-error.
          if not available gds2_temp-petrol-chk then
          do:
            create gds2_temp-petrol-chk.
            assign
              gds2_temp-petrol-chk.chk-type = buf_temp-petrol-chk.chk-type
              gds2_temp-petrol-chk.obj-type = buf_temp-petrol-chk.obj-type
              gds2_temp-petrol-chk.obj-code = buf_temp-petrol-chk.obj-code
              gds2_temp-petrol-chk.pay-desk = 0
              gds2_temp-petrol-chk.gds-code = 0 /* Исключаем, т.к. вывод только по товару и назначению. */
              gds2_temp-petrol-chk.pump     = 0
              gds2_temp-petrol-chk.pump-2   = 0
              gds2_temp-petrol-chk.pay-code = buf_temp-petrol-chk.pay-code
              gds2_temp-petrol-chk.pay-name = buf_temp-petrol-chk.pay-name
            .
          end.
            do:
              assign
                gds2_temp-petrol-chk.doc-qnty        = gds2_temp-petrol-chk.doc-qnty        + buf_temp-petrol-chk.doc-qnty
                gds2_temp-petrol-chk.sum-base        = gds2_temp-petrol-chk.sum-base        + buf_temp-petrol-chk.sum-base
                gds2_temp-petrol-chk.trans-number    = gds2_temp-petrol-chk.trans-number    + buf_temp-petrol-chk.trans-number
              .
            end.
      end.
      /* ******* по "ТОПЛИВО(товар)", "НАЗНАЧЕНИЕ" ******* */

      find first gds-obj0_temp-petrol-chk where
              gds-obj0_temp-petrol-chk.chk-type = 0
          AND gds-obj0_temp-petrol-chk.obj-type = buf_temp-petrol-chk.obj-type
          AND gds-obj0_temp-petrol-chk.obj-code = buf_temp-petrol-chk.obj-code
          AND gds-obj0_temp-petrol-chk.pay-desk = 0
          AND gds-obj0_temp-petrol-chk.gds-code = buf_temp-petrol-chk.gds-code
          AND gds-obj0_temp-petrol-chk.pump     = 0
          AND gds-obj0_temp-petrol-chk.pump-2   = 0 no-error.
      if not available gds-obj0_temp-petrol-chk then
      do:
        /*найдем название товара - здесь на это уйдет меньше всего времени*/
        find first buf_goods no-lock where
                  buf_goods.gds-code = buf_temp-petrol-chk.gds-code no-error.
        find first buf_temp-goods no-lock where
                buf_temp-goods.gds-code = buf_temp-petrol-chk.gds-code no-error.
        if not available buf_temp-goods then
        do:
          create buf_temp-goods.
          assign
          buf_temp-goods.gds-code = buf_temp-petrol-chk.gds-code
          buf_temp-goods.gds-name = (if available buf_goods
                                     then buf_goods.gds-name
                                     else substitute("Товар с кодом &1", buf_temp-petrol-chk.gds-code))
          .
        end.
        create gds-obj0_temp-petrol-chk.
        assign
          gds-obj0_temp-petrol-chk.chk-type = 0
          gds-obj0_temp-petrol-chk.obj-type = buf_temp-petrol-chk.obj-type
          gds-obj0_temp-petrol-chk.obj-code = buf_temp-petrol-chk.obj-code
          gds-obj0_temp-petrol-chk.pay-desk = 0
          gds-obj0_temp-petrol-chk.gds-code = buf_temp-petrol-chk.gds-code
          gds-obj0_temp-petrol-chk.pump     = 0
          gds-obj0_temp-petrol-chk.pump-2   = 0
        .
      end.
      do:
        /* Формируем ГруппаИтогов-последняя для "Все виды чеков" */
        assign
/*          gds-obj0_temp-petrol-chk.doc-qnty     = gds-obj0_temp-petrol-chk.doc-qnty     + buf_temp-petrol-chk.doc-qnty    */
/*          gds-obj0_temp-petrol-chk.sum-base     = gds-obj0_temp-petrol-chk.sum-base     + buf_temp-petrol-chk.sum-base    */
/*          gds-obj0_temp-petrol-chk.trans-number = gds-obj0_temp-petrol-chk.trans-number + buf_temp-petrol-chk.trans-number*/
          gds-obj0_temp-petrol-chk.doc-qnty     = gds-obj0_temp-petrol-chk.doc-qnty     + buf_temp-petrol-chk.doc-qnty      + buf_temp-petrol-chk.doc-qnty-ns
          gds-obj0_temp-petrol-chk.sum-base     = gds-obj0_temp-petrol-chk.sum-base     + buf_temp-petrol-chk.sum-base      + buf_temp-petrol-chk.sum-base-ns
          gds-obj0_temp-petrol-chk.trans-number = gds-obj0_temp-petrol-chk.trans-number + buf_temp-petrol-chk.trans-number  + buf_temp-petrol-chk.trans-number-ns
        .
      end.
    end.
    if multi-obj then
    do:
     
      for each buf_temp-petrol-chk where
              buf_temp-petrol-chk.prim = no:
        if buf_temp-petrol-chk.pay-desk <> 0 then NEXT.
        if buf_temp-petrol-chk.gds-code = 0 then NEXT.
        if buf_temp-petrol-chk.obj-code = 0 then NEXT.
        if buf_temp-petrol-chk.pay-code <> 0 then next.
        find first gds_temp-petrol-chk where
                gds_temp-petrol-chk.chk-type = buf_temp-petrol-chk.chk-type
            AND gds_temp-petrol-chk.obj-type = '':U
            AND gds_temp-petrol-chk.obj-code = 0
            AND gds_temp-petrol-chk.pay-desk = 0
            AND gds_temp-petrol-chk.gds-code = buf_temp-petrol-chk.gds-code
            AND gds_temp-petrol-chk.pump     = 0
/*           and gds_temp-petrol-chk.pay-code = 0*/
            AND gds_temp-petrol-chk.pump-2   = 0 no-error.
        if not available gds_temp-petrol-chk then
        do:
          create gds_temp-petrol-chk.
          assign
            gds_temp-petrol-chk.chk-type = buf_temp-petrol-chk.chk-type
            gds_temp-petrol-chk.obj-type = '':U
            gds_temp-petrol-chk.obj-code = 0
            gds_temp-petrol-chk.pay-desk = 0
            gds_temp-petrol-chk.gds-code = buf_temp-petrol-chk.gds-code
            gds_temp-petrol-chk.pump     = 0
            gds_temp-petrol-chk.pump-2   = 0
            v-write-off-code2 = buf_temp-petrol-chk.write-off-code
/*            gds_temp-petrol-chk.pay-code = 0*/
          .
        end.
       
      
          assign
            gds_temp-petrol-chk.doc-qnty     = gds_temp-petrol-chk.doc-qnty     + buf_temp-petrol-chk.doc-qnty
            gds_temp-petrol-chk.sum-base     = gds_temp-petrol-chk.sum-base     + buf_temp-petrol-chk.sum-base
            gds_temp-petrol-chk.trans-number = gds_temp-petrol-chk.trans-number + buf_temp-petrol-chk.trans-number

            gds_temp-petrol-chk.doc-qnty-ns     = gds_temp-petrol-chk.doc-qnty-ns     + buf_temp-petrol-chk.doc-qnty-ns
            gds_temp-petrol-chk.sum-base-ns     = gds_temp-petrol-chk.sum-base-ns     + buf_temp-petrol-chk.sum-base-ns
            gds_temp-petrol-chk.trans-number-ns = gds_temp-petrol-chk.trans-number-ns + buf_temp-petrol-chk.trans-number-ns
          .
      end. /*for each buf0_temp-petrol-chk*/
    end. /*if multi-obj*/
  end. /*doe*/

end procedure. /* fill-sub-totals */


/* ----------- Main block ------------ */

/* ТН-3359 11.02.2015 Арн. Комментирование сущ.кода, т.к запрос построен с использованием в Закладка-1 X-Radio-Task (выбор календарные даты, смены, одна смена и т.д.) */
/*
FOR EACH obj-list no-lock:
  CASE X-Radio-Task > 1 :
    WHEN YES THEN DO:
      _shift-chk:
      FOR EACH buf_chk-doc NO-LOCK WHERE
              buf_chk-doc.obj-type = obj-list.obj-type
          AND buf_chk-doc.obj-code = obj-list.obj-code
          AND ( buf_chk-doc.shift-date >= X-date-start
                AND
                buf_chk-doc.shift-date <= X-date-end):
        IF X-Radio-Task = 3 AND
        ((buf_chk-doc.shift-date = X-date-start AND buf_chk-doc.shift-num < X-shift-Start)
         OR
         (buf_chk-doc.shift-date = X-date-end AND  buf_chk-doc.shift-num > X-shift-End) ) THEN NEXT _shift-chk.
        IF X-Radio-Task = 4
        AND (buf_chk-doc.shift-num <> X-shift-Alone ) THEN NEXT _shift-chk.
        if lookup(string(buf_chk-doc.chk-type), {&petrol-receipt-codes}) = 0
        or buf_chk-doc.office <> {&gds-goods}  then next _shift-chk.
        jj = jj + 1.
        IF jj MODULO 10 = 0 then
        run waitfram-show in this-procedure (substitute("Ждите... Обработано &1 технологических чеков по топливу", jj)).
        run fill-temp-table in this-procedure (input buf_chk-doc.doc-code, input buf_chk-doc.chk-type).
      END.
    END. /*WHEN YES*/
    WHEN NO THEN DO:
     if X-radio-task = 0 then do:
        _no-shift-chk:
        FOR EACH buf_chk-doc NO-LOCK WHERE
                buf_chk-doc.obj-type = obj-list.obj-type
            AND buf_chk-doc.obj-code = obj-list.obj-code
            AND buf_chk-doc.shift-date = X-date-start
            AND buf_chk-doc.shift-num = X-shift-alone:
          if lookup(string(buf_chk-doc.chk-type), {&petrol-receipt-codes}) = 0
          or buf_chk-doc.office <> {&gds-goods} then next _no-shift-chk.
          jj = jj + 1.
          IF jj MODULO 10 = 0 then
          run waitfram-show in this-procedure (substitute("Ждите... Обработано &1 технологических чеков по топливу", jj)).
          run fill-temp-table in this-procedure ( input buf_chk-doc.doc-code, input buf_chk-doc.chk-type).
        END.
      end.
      else do:
        _no-shift-chk:
        FOR EACH buf_chk-doc NO-LOCK WHERE
                buf_chk-doc.obj-type = obj-list.obj-type
            AND buf_chk-doc.obj-code = obj-list.obj-code
            AND buf_chk-doc.chk-date >= X-date-start
            AND buf_chk-doc.chk-date <= X-date-end:
          if lookup(string(buf_chk-doc.chk-type), {&petrol-receipt-codes}) = 0
          or buf_chk-doc.office <> {&gds-goods} then next _no-shift-chk.
          jj = jj + 1.
          IF jj MODULO 10 = 0 then
          run waitfram-show in this-procedure (substitute("Ждите... Обработано &1 технологических чеков по топливу", jj)).
          run fill-temp-table in this-procedure (input buf_chk-doc.doc-code, input buf_chk-doc.chk-type).
        END.
      end.
    END. /*WHEN NO*/
  END CASE.
END. /*for each obj-list*/
*/

/* ТН-3359 11.02.2015 Арн. Вместо закомментаренного кода выше используем следующий код: */
for each obj-list no-lock:
  if x-TOG-Shift = yes then
  do:
    _shift-chk:
    for each buf_chk-doc no-lock where
             buf_chk-doc.obj-type = obj-list.obj-type
         and buf_chk-doc.obj-code = obj-list.obj-code
         and (buf_chk-doc.shift-date >= X-date-start and buf_chk-doc.shift-date <= X-date-end)
         and ((buf_chk-doc.shift-date = X-date-start and buf_chk-doc.shift-num >= X-shift-Start) or
              (buf_chk-doc.shift-date = X-date-end and buf_chk-doc.shift-num <= X-shift-End))
    :
      if lookup(string(buf_chk-doc.chk-type), {&petrol-receipt-codes}) = 0 or
        buf_chk-doc.office <> {&gds-goods} then next _shift-chk.

      jj = jj + 1.
      if jj modulo 10 = 0 then
      do:
        run waitfram-show in this-procedure (substitute("Ждите... Обработано &1 технологических чеков по топливу", jj)).
      end.

      run fill-temp-table in this-procedure (input buf_chk-doc.doc-code, input buf_chk-doc.chk-type).
    end.
  end.
  else
  do:
    _no-shift-chk:
    for each buf_chk-doc no-lock where
             buf_chk-doc.obj-type = obj-list.obj-type
         and buf_chk-doc.obj-code = obj-list.obj-code
         and buf_chk-doc.chk-date >= X-date-start
         and buf_chk-doc.chk-date <= X-date-end
    :
      if lookup(string(buf_chk-doc.chk-type), {&petrol-receipt-codes}) = 0 or
        buf_chk-doc.office <> {&gds-goods} then next _no-shift-chk.

      jj = jj + 1.
      if jj modulo 10 = 0 then
      do:
        run waitfram-show in this-procedure (substitute("Ждите... Обработано &1 технологических чеков по топливу", jj)).
      end.

      run fill-temp-table in this-procedure (input buf_chk-doc.doc-code, input buf_chk-doc.chk-type).
    end.
  end.
end.

run fill-sub-totals in this-procedure.

run waitfram-hide in this-procedure.

/*Line = fill("-", 123).*/
date_string = cur-time-print().

run waitfram-show in this-procedure ("Ждите...").
run prn-lib-open-stream  in this-procedure (
                                            input my-handle
                                            ,input {&CS_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

/* Предупреждение о выводе отчёта только в Excel */
    PUT stream PrnLibStream unformatted
      'Отчёт доступен только в Excel':U
      skip
    .
  output stream PrnLibStream close.

do: /* Закомментарено до задачи ТН-3359 Янв 2015. Арн. */
/*
  if v-chk-type = integer({&rcpt-trans-transfer}) then do:
    FORM with FRAME two-pump .
    view stream PrnLibStream frame two-pump .
  end.
  else do:
    FORM with FRAME one-pump.
    view stream PrnLibStream frame one-pump .
  END.
*/
end. /* Закомментарено до задачи ТН-3359 Янв 2015. Арн. */

/* Заводим количество листов Excel в зависимости от того, сколько страниц отмечено галочкой в параметрах (см. e-ptrlch.w) */
define variable v-ii as integer no-undo.
define variable v-count-sheets as integer no-undo. /* Количество листов в Excel (динамически меняется в зависимости от выбора галочками в Страница-2 парам) */
v-count-sheets = num-entries(p-param-list, {&comma-char}).

do v-ii = 1 to v-count-sheets:
  v-chk-type = integer(entry(v-ii, p-param-list, {&comma-char})).

/*do v-type-num = 1 to 6:*/
/*  case v-type-num:                                */
/*    when 1 then do:                               */
/*      assign                                      */
/*      v-chk-type = integer({&rcpt-trans-cancell}) */
/*      .                                           */
/*    end.                                          */
/*    when 2 then do:                               */
/*      assign                                      */
/*      v-chk-type = integer({&rcpt-overflow})      */
/*      .                                           */
/*    end.                                          */
/*    when 3 then do:                               */
/*      assign                                      */
/*      v-chk-type = integer({&rcpt-tech-refuell})  */
/*      .                                           */
/*    end.                                          */
/*    when 4 then do:                               */
/*      assign                                      */
/*      v-chk-type = integer({&rcpt-trans-transfer})*/
/*      .                                           */
/*    end.                                          */
/*    when 5 then do:                               */
/*      assign                                      */
/*      v-chk-type = 0                              */
/*      .                                           */
/*    end.                                          */
/*    when 6 then do:                               */
/*      assign                                      */
/*      v-chk-type = integer({&rcpt-unlock-trans})  */
/*      .                                           */
/*    end.                                          */
/*  end case.                                       */
/*  if lookup() = 0 then next.*/
  &scop receipt-code string(v-chk-type)
/*  PUT stream PrnLibStream UNFORMATTED*/
/*    'Отчёт доступен только в Excel':U*/
/*    skip (2)                         */
/*  .                                  */

  /* Блокируем вывод на экран ТН-3359 10.02.2015 Арн. */
/*
  skip(1)
  space(20)
  "Технологический отчет по ТРК" skip
  space(23) str1 skip(0)
  space(23) (if v-chk-type = 0 then "По всем типам технологических чеков" else {&receipt-name}) skip(0)
  .
  if v-type-num = 1 then
  do:
    if v-chk-type = integer({&rcpt-trans-transfer}) then
    do:
      form with frame two-pump.
      view stream PrnLibStream frame two-pump.
    end.
    else
    do:
      form with FRAME one-pump.
      view stream PrnLibStream frame one-pump.
    end.
  end.
*/

/*  run print-one-chk-type in this-procedure (input v-type-num, input v-chk-type).*/
  run print-one-chk-type in this-procedure (input v-ii, input v-chk-type).

  /* Блокируем вывод на экран ТН-3359 10.02.2015 Арн. */
/*
  hide stream PrnLibStream frame one-pump.
  hide stream PrnLibStream frame two-pump.
*/

/*  if v-type-num < 6 then*/
  if v-ii < v-count-sheets then
  do:
/*    page stream PrnLibStream.*/
    {&pageExcel}
  end.
/*end. /*do to 5*/*/
end.

assign
  p-param-list = '':U
  v-count-sheets = ?.
  v-chk-type = ?
.

/* Блокируем вывод на экран ТН-3359 10.02.2015 Арн. */
/*
hide stream PrnLibStream frame one-pump.
hide stream PrnLibStream frame one-pump.
*/
/*output STREAM PrnLibStream CLOSE.*/

{&CloseExcel}

run waitfram-hide in this-procedure.

run prn-lib-prn-file in this-procedure (
                                          input my-handle
                                          ,input 0
                                          ).


procedure print-one-chk-type :
define input parameter p-type-num as integer no-undo.
define input parameter p-chk-type like ub.chk-doc.chk-type no-undo.

define variable loc-obj-count as integer no-undo.
define buffer bufo_temp-petrol-chk for temp-petrol-chk.
define buffer bufo2_temp-petrol-chk for temp-petrol-chk. /* Для вывода итогов Б */
define buffer bufo3_temp-petrol-chk for temp-petrol-chk. /* Для вывода итогов E */
define buffer bufo_temp-goods for temp-goods.
define buffer bufo2_temp-goods for temp-goods.
define variable v-first-good as logical no-undo init yes.


  do
  on error undo, return error return-value
  :
  if p-type-num > 1 then
  do:
    FInd first Sheetf where
      Sheetf.sheet-num = p-type-num no-error. /* Вносим в системную таблицу кол-во Листов в Excel */
    if not avail sheetf then
    do:
      create sheetf.
      Sheetf.sheet-num = p-type-num.
    end.
  end.
  &scop receipt-code string(p-chk-type)

/* Попытка объединения ячеек в шапке таблицы Excel - не удалась, т.е. слияние - рушит прорисовку границ таблицы(заливка шапки и границы задаются не на прямую в таблице Sheetf. Отложено на доработку позже. ТН-3359 11.02.2015 Арн. */
/*  if p-chk-type = integer({&rcpt-trans-cancell}) then*/
/*  do:                                                */
/*/*    Sheetf.Excel-Row-Title = 2.*/                  */
/*    Sheetf.MergeCellsV = "1=1:2/2=1:2/3=1:2".        */
/*  end.                                               */

  /* Формат столбцов отчёта (по каждому разделу - листу Excel) в Excel */
  assign
    Sheetf.ColFOrmat = /* '1=@;2=@' */
                       (if p-chk-type = integer({&rcpt-trans-cancell}) then "4=0.00;5=0.00;7=0.00;8=0.00" else  /* Сброс транзакций */
                          if p-chk-type = integer({&rcpt-overflow}) or                                            /* Перелив */
                          p-chk-type = 0 or                                                                       /* Итоги по технологическим чекам */
                          p-chk-type = integer({&rcpt-unlock-trans})                                              /* Разблокировка транзакций */
                          then "4=0.00;5=0.00" else
                            if p-chk-type = integer({&rcpt-tech-refuell}) or                                        /* Техпролив */
                            p-chk-type = integer({&rcpt-trans-transfer})                                            /* Перевод транзакций */
                            then "5=0.00;6=0.00" else '':U
                       )
                       + {&delim-par}
                       + '':U
                       + {&delim-par} +
                       (if p-chk-type = 0 then "Все виды чеков" else {&receipt-name})
  .
  assign
  sheetf.Excel-Column-Lable =
  "Касса" + {&comma-char}
  +
  "Топливо" + {&comma-char}
  +
  (if p-chk-type = integer({&rcpt-trans-transfer})
      then "Откуда: № ТРК" + {&comma-char}
           +
           "Куда: № ТРК" + {&comma-char}
      else (if p-chk-type = integer({&rcpt-tech-refuell}) and p-rs-grp-tech-refuell = 2 then "Назначение" + {&comma-char} else "№ ТРК" + {&comma-char}))
  +
  (if p-chk-type = integer({&rcpt-trans-cancell}) then
    "Пролито Кол-во в л" + {&comma-char}
    +
    "Пролито Сумма в {&abbr_rub}." + {&comma-char}
    +
    "Пролито Кол-во чеков" + {&comma-char}
    +
    "Не пролито Кол-во в л" + {&comma-char}
    +
    "Не пролито Сумма в {&abbr_rub}." + {&comma-char}
    +
    "Не пролито Кол-во чеков"
   else
     (if p-chk-type = integer({&rcpt-unlock-trans}) then
      "Предоплата Кол-во в л" + {&comma-char}
      +
      "Предоплата Сумма в {&abbr_rub}." + {&comma-char}
      +
      "Предоплата Кол-во чеков" + {&comma-char}
      +
      "Постоплата Кол-во в л" + {&comma-char}
      +
      "Постоплата Сумма в {&abbr_rub}." + {&comma-char}
      +
      "Постоплата Кол-во чеков" else
     (if p-chk-type = integer({&rcpt-tech-refuell}) and p-rs-grp-tech-refuell = 1 then "Назначение" + {&comma-char}
      else (if p-chk-type = integer({&rcpt-tech-refuell}) and p-rs-grp-tech-refuell = 2 then "№ ТРК" + {&comma-char} else '':U))
      +
      "Кол-во в л" + {&comma-char}
      +
      "Сумма в {&abbr_rub}." + {&comma-char}
      +
      "Кол-во чеков"))

  sheetf.sizes =
      "5" + {&comma-char}
      +
      "25" + {&comma-char}
      +
      (if p-chk-type = integer({&rcpt-trans-transfer}) then
        "8" + {&comma-char}
        +
        "8" + {&comma-char}
      else
        (if p-chk-type = integer({&rcpt-tech-refuell}) and p-rs-grp-tech-refuell = 2 then "11" + {&comma-char} else "8" + {&comma-char}))
      +
      (if p-chk-type = integer({&rcpt-trans-cancell}) or p-chk-type = integer({&rcpt-unlock-trans}) then
        "10" + {&comma-char}
        +  
        "10" + {&comma-char}
        +
        "10" + {&comma-char}
        +
        "10" + {&comma-char}
        +
        "10" + {&comma-char}
        +
        "10"
       else
         (if p-chk-type = integer({&rcpt-tech-refuell}) then
         (if p-chk-type = integer({&rcpt-tech-refuell}) and p-rs-grp-tech-refuell = 2 then "8" + {&comma-char} else "11" + {&comma-char})
         else '':U)
        +
        "18" + {&comma-char}
        +
        "18" + {&comma-char}
        +
        "10")

/* Закомментировал сущ код, т.к. формат столбцов определён выше (кто-то ошибочно завёл повторый формат. ТН-3359 10.02.2015г Арн. */
/*  sheetf.colformat = (if p-chk-type = integer({&rcpt-trans-transfer})*/
/*/*                      then "5=0.0000000000"*/*/
/*                      then "5=0.00"            */
/*/*                      else "4=0.0000000000"*/*/
/*                      else "4=0.00"            */
/*                      )*/
  str2 =
                     (if p-chk-type = 0
                     then "Все виды чеков"
                     else {&receipt-name})
  .

  run rep/extitle.p (p-type-num). /* Печать шапки отчёта в Excel */

/* Блокируем вывод на экран ТН-3359 10.02.2015 Арн. */
/*
  FORM HEADER
  Line format "X(123)"
  AT 1 SKIP
  string("Продолжение - на следующей странице") FORMAT "X(35)" AT 30 SKIP
  with FRAME BottomFrame width  {&A4_CW0} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW STREAM PrnLibStream FRAME BottomFrame .
  if v-type-num > 1 then do:
    if v-chk-type = integer({&rcpt-trans-transfer}) then do:
      FORM with FRAME two-pump .
      view stream PrnLibStream frame two-pump .

    end.
    else do:
      FORM with FRAME one-pump.
      view stream PrnLibStream frame one-pump .
    END.
  end.
*/

  for each obj-list no-lock:
    loc-obj-count = loc-obj-count + 1.
    if loc-obj-count > 1 then
    do:
/*      Put Stream PrnLibStream UNFORMATTED*/
/*      skip(1).                           */
      {&PutExcel} skip.
    end.
/*    Put Stream PrnLibStream UNFORMATTED              */
/*    substitute("Объект: &1", obj-list.obj-name) skip.*/
    {&PutExcel}
    substitute("Объект: &1", obj-list.obj-name) skip.

      for each buf_temp-petrol-chk where
            buf_temp-petrol-chk.obj-type = obj-list.obj-type
        and buf_temp-petrol-chk.obj-code = obj-list.obj-code
        and buf_temp-petrol-chk.chk-type = p-chk-type
        and (buf_temp-petrol-chk.prim    = yes or p-chk-type = 0)
        ,
          first buf_temp-goods where
                buf_temp-goods.gds-code = buf_temp-petrol-chk.gds-code
      break
      by buf_temp-petrol-chk.pay-desk
      by buf_temp-petrol-chk.gds-code
      by buf_temp-petrol-chk.pump
      :

        if buf_temp-petrol-chk.pay-desk = 0
        or buf_temp-petrol-chk.pump = 0
        then NEXT.

        if first-of(buf_temp-petrol-chk.pay-desk) then
        do:
          assign
            accum-pay-desk-doc-qnty = 0
            accum-pay-desk-sum-base = 0
            accum-pay-desk-trans-number = 0
            accum-pay-desk-doc-qnty-ns = 0
            accum-pay-desk-sum-base-ns = 0
            accum-pay-desk-trans-number-ns = 0
          .
        end.
        if first-of(buf_temp-petrol-chk.gds-code) then
        do:
          assign
            accum-gds-code-doc-qnty = 0
            accum-gds-code-sum-base = 0
            accum-gds-code-trans-number = 0
            accum-gds-code-doc-qnty-ns = 0
            accum-gds-code-sum-base-ns = 0
            accum-gds-code-trans-number-ns = 0
          .
        end.
        if first-of(buf_temp-petrol-chk.gds-code) then
        do:
          assign
            accum-doc-qnty-dest = 0
            accum-sum-base-dest = 0
            accum-trans-number-dest = 0
          .
        end.
        assign
          accum-pay-desk-doc-qnty        = accum-pay-desk-doc-qnty        + buf_temp-petrol-chk.doc-qnty
          accum-pay-desk-sum-base        = accum-pay-desk-sum-base        + buf_temp-petrol-chk.sum-base
          accum-pay-desk-trans-number    = accum-pay-desk-trans-number    + buf_temp-petrol-chk.trans-number

          accum-pay-desk-doc-qnty-ns     = accum-pay-desk-doc-qnty-ns     + buf_temp-petrol-chk.doc-qnty-ns
          accum-pay-desk-sum-base-ns     = accum-pay-desk-sum-base-ns     + buf_temp-petrol-chk.sum-base-ns
          accum-pay-desk-trans-number-ns = accum-pay-desk-trans-number-ns + buf_temp-petrol-chk.trans-number-ns

          accum-gds-code-doc-qnty        = accum-gds-code-doc-qnty        + buf_temp-petrol-chk.doc-qnty
          accum-gds-code-sum-base        = accum-gds-code-sum-base        + buf_temp-petrol-chk.sum-base
          accum-gds-code-trans-number    = accum-gds-code-trans-number    + buf_temp-petrol-chk.trans-number

          accum-gds-code-doc-qnty-ns     = accum-gds-code-doc-qnty-ns     + buf_temp-petrol-chk.doc-qnty-ns
          accum-gds-code-sum-base-ns     = accum-gds-code-sum-base-ns     + buf_temp-petrol-chk.sum-base-ns
          accum-gds-code-trans-number-ns = accum-gds-code-trans-number-ns + buf_temp-petrol-chk.trans-number-ns
        
          accum-doc-qnty-dest            = accum-doc-qnty-dest            + buf_temp-petrol-chk.doc-qnty
          accum-sum-base-dest            = accum-sum-base-dest            + buf_temp-petrol-chk.sum-base
          accum-trans-number-dest        = accum-trans-number-dest        + buf_temp-petrol-chk.trans-number
        .



/* Блокируем вывод на экран ТН-3359 10.02.2015 Арн. */
/*
      if p-chk-type = integer({&rcpt-trans-transfer}) then
      do:
        DOWN 1 STREAM PrnLibStream
        with frame two-pump.
        display stream PrnLibStream
        buf_temp-petrol-chk.pay-desk when first-of(buf_temp-petrol-chk.pay-desk)
        buf_temp-goods.gds-name when first-of(buf_temp-petrol-chk.gds-code)
        buf_temp-petrol-chk.pump
        buf_temp-petrol-chk.pump-2
        buf_temp-petrol-chk.doc-qnty
        buf_temp-petrol-chk.sum-base
        buf_temp-petrol-chk.trans-number
        with frame two-pump.
        if last-of(buf_temp-petrol-chk.gds-code) then do:
          DOWN 1 STREAM PrnLibStream
          with frame two-pump.
          display stream PrnLibStream
          substitute("Итого по &1", buf_temp-goods.gds-name) @ buf_temp-goods.gds-name
          accum-gds-code-doc-qnty       @ buf_temp-petrol-chk.doc-qnty
          accum-gds-code-sum-base       @ buf_temp-petrol-chk.sum-base
          accum-gds-code-trans-number   @ buf_temp-petrol-chk.trans-number
          with frame two-pump.
        end.
        if last-of(buf_temp-petrol-chk.pay-desk) then do:
          DOWN 1 STREAM PrnLibStream
          with frame two-pump.
          display stream PrnLibStream
          substitute("Итого по кассе &1", buf_temp-petrol-chk.pay-desk) @ buf_temp-goods.gds-name
          accum-pay-desk-doc-qnty       @ buf_temp-petrol-chk.doc-qnty
          accum-pay-desk-sum-base       @ buf_temp-petrol-chk.sum-base
          accum-pay-desk-trans-number   @ buf_temp-petrol-chk.trans-number
          with frame two-pump.
        end.
      end.
      else do:
        DOWN 1 STREAM PrnLibStream
        with frame one-pump.
        display stream PrnLibStream
        buf_temp-petrol-chk.pay-desk when first-of(buf_temp-petrol-chk.pay-desk)
        buf_temp-goods.gds-name     when first-of(buf_temp-petrol-chk.gds-code)
        buf_temp-petrol-chk.pump
        buf_temp-petrol-chk.doc-qnty
        buf_temp-petrol-chk.sum-base
        buf_temp-petrol-chk.trans-number
        with frame one-pump.
        if last-of(buf_temp-petrol-chk.gds-code) then do:
          DOWN 1 STREAM PrnLibStream
          with frame one-pump.

          display stream PrnLibStream
          substitute("Итого по &1", buf_temp-goods.gds-name) @ buf_temp-goods.gds-name
          accum-gds-code-doc-qnty       @ buf_temp-petrol-chk.doc-qnty
          accum-gds-code-sum-base       @ buf_temp-petrol-chk.sum-base
          accum-gds-code-trans-number   @ buf_temp-petrol-chk.trans-number
          with frame one-pump.
        end.
        if last-of(buf_temp-petrol-chk.pay-desk) then do:
          DOWN 1 STREAM PrnLibStream
          with frame one-pump.

          display stream PrnLibStream
          substitute("Итого по кассе &1", buf_temp-petrol-chk.pay-desk) @ buf_temp-goods.gds-name
          accum-pay-desk-doc-qnty        @ buf_temp-petrol-chk.doc-qnty
          accum-pay-desk-sum-base        @ buf_temp-petrol-chk.sum-base
          accum-pay-desk-trans-number    @ buf_temp-petrol-chk.trans-number
          with frame one-pump.
        end.
      end.
*/

        /*печатаем в excel*/
        if first-of(buf_temp-petrol-chk.pay-desk)
        or first-of(buf_temp-petrol-chk.gds-code)
        then
        /* Столбец-1 ("Касса" Отчёт Excel) */
        {&PutExcel}
          buf_temp-petrol-chk.pay-desk                      {&tabulation}
        .
        else
        {&PutExcel}
                                                            {&tabulation}
        .

        /* Столбец-2 ("Топливо" Отчёт Excel) */
        if first-of(buf_temp-petrol-chk.gds-code)
        then
        do:
          {&PutExcel}
            buf_temp-goods.gds-name {&tabulation}
          .
        end.
        else
        do:
          {&PutExcel}
                                                            {&tabulation} +
                                                            {&tabulation}
          .
        end.

        /* Столбец-3 ("ТРК"|"Откуда №ТРК" Pump-1 Отчёт Excel) */
        {&PutExcel}
          (if p-chk-type = integer({&rcpt-tech-refuell}) and p-rs-grp-tech-refuell = 2 then buf_temp-petrol-chk.pay-name
                                                                                       else string(buf_temp-petrol-chk.pump)) {&tabulation}
        .

        /* Столбец-3.1 ("ТРК"|"Куда №ТРК" Pump-2 Отчёт Excel) */
        if p-chk-type = integer({&rcpt-trans-transfer})
        then
          {&PutExcel}
            buf_temp-petrol-chk.pump-2                      {&tabulation}
          .

        /* Столбец-3.1.1 "Назначение" Отчёт Excel (Взаимоисключением для Столбец-3.1, и только для чеков "ТехПролив"!) */
        if p-chk-type = integer({&rcpt-tech-refuell}) and p-rs-grp-tech-refuell = 1 then
        do:
          {&PutExcel}
            buf_temp-petrol-chk.pay-name                    {&tabulation} /* "Назначение-1" */
          .
        end.
        else
        do:
          if p-chk-type = integer({&rcpt-tech-refuell}) and p-rs-grp-tech-refuell = 2 then
          do:
            {&PutExcel}
              buf_temp-petrol-chk.pump                      {&tabulation} /* "№ ТРК" */
            .
          end.
        end.

        /* Столбец-4|Столбец-П4 ("Кол-во в л"|"Пролито Кол-во в л" Отчёт Excel) */
        {&PutExcel}
          buf_temp-petrol-chk.doc-qnty                      {&tabulation}
        .

        /* Для категории чеков КРОМЕ "СбросТрнзкц", т.е. когда работаем с 6-ю столбцами отчёта! */
        if p-chk-type <> integer({&rcpt-trans-cancell}) and p-chk-type <> integer({&rcpt-unlock-trans}) then
        do:
          /* Столбец-5|Столбец-П5 ("Сумма в руб."|"Пролито Сумма в руб." Отчёт Excel) */
          {&PutExcel}
            buf_temp-petrol-chk.sum-base                    {&tabulation}

            /* Столбец-6 |Столбец-П6 ("Кол-во чеков"|"Пролито Кол-во чеков" Отчёт Excel) */
            buf_temp-petrol-chk.trans-number
            skip.
        end.
        else /* Иначе - для категории чеков = "СбросТрнзкц", т.е. когда работаем с 9-ю столбцами отчёта! */
        do:
          /* Столбец-5|Столбец-П5 ("Сумма в руб."|"Пролито Сумма в руб." Отчёт Excel) */
          {&PutExcel}
            buf_temp-petrol-chk.sum-base                     {&tabulation}

            /* Столбец-6 |Столбец-П6 ("Кол-во чеков"|"Пролито Кол-во чеков" Отчёт Excel) */
            buf_temp-petrol-chk.trans-number                 {&tabulation}

            /* Столбец-Н7 ("Не пролито Кол-во в л" Отчёт Excel) */
            buf_temp-petrol-chk.doc-qnty-ns                  {&tabulation}

            /* Столбец-Н8 ("Не пролито Сумма в руб." Отчёт Excel) */
            buf_temp-petrol-chk.sum-base-ns                  {&tabulation}

            /* Столбец-Н9 ("Не пролито Кол-во чеков" Отчёт Excel) */
            buf_temp-petrol-chk.trans-number-ns
            skip.
        end.

        /* Строка "Итого по одному товару" */
        define buffer buf2_temp-petrol-chk for temp-petrol-chk.
        define buffer dest2_temp-petrol-chk for temp-petrol-chk.

        if p-chk-type = integer({&rcpt-tech-refuell})
        and last-of(buf_temp-petrol-chk.gds-code) then
        do:
          for each buf2_temp-petrol-chk where
                   buf2_temp-petrol-chk.obj-type = buf_temp-petrol-chk.obj-type
               and buf2_temp-petrol-chk.obj-code = buf_temp-petrol-chk.obj-code
               and buf2_temp-petrol-chk.pay-desk = buf_temp-petrol-chk.pay-desk
               and buf2_temp-petrol-chk.gds-code = buf_temp-petrol-chk.gds-code
               and buf2_temp-petrol-chk.pump = 0
               and buf2_temp-petrol-chk.pay-code <> 0
          no-lock
          :
            {&PutExcel}
                                                                 {&tabulation}
              substitute("Итого по &1", buf_temp-goods.gds-name) {&tabulation} /* Итого по одному товару (1) */
              (if p-chk-type = integer({&rcpt-tech-refuell}) and p-rs-grp-tech-refuell = 2
              then buf2_temp-petrol-chk.pay-name +               {&tabulation} +
                                                                 {&tabulation}
              else
                                                                 {&tabulation} +
              buf2_temp-petrol-chk.pay-name +                    {&tabulation})
              buf2_temp-petrol-chk.doc-qnty                      {&tabulation}
              buf2_temp-petrol-chk.sum-base                      {&tabulation}
              buf2_temp-petrol-chk.trans-number
              skip
            .
          end. /* for each buf2_temp-petrol-chk */
        end.

        /* Строка "Итого по товару по всем назначениям" */
        if last-of(buf_temp-petrol-chk.gds-code) then
        do:
          case p-chk-type:
            /* Вывод Итогов по товару для случая "СбросТрнзкц" (здесь всего шесть итоговых столбцов в отчёте) */
            when integer({&rcpt-trans-cancell}) or when integer({&rcpt-unlock-trans}) /*or when 0*/ then
            do:
              {&PutExcel}
                                                                   {&tabulation}
                substitute("Итого по &1", buf_temp-goods.gds-name) {&tabulation} /* Итого по товару по всем "назначениям" (1) */
                                                                   {&tabulation}
                accum-gds-code-doc-qnty                            {&tabulation}
                accum-gds-code-sum-base                            {&tabulation}
                accum-gds-code-trans-number                        {&tabulation}
                accum-gds-code-doc-qnty-ns                         {&tabulation}
                accum-gds-code-sum-base-ns                         {&tabulation}
                accum-gds-code-trans-number-ns
                skip
              .
            end.

            /* Вывод Итогов по товару для случая "ТехПролив" (здесь всего четыре итоговых столбца в отчёте) */
            when integer({&rcpt-tech-refuell}) then
            do:
              {&PutExcel}
                                                                   {&tabulation}
                substitute("Итого по &1 по всем назначениям", buf_temp-goods.gds-name) {&tabulation} /* Итого по Топливу (товару) по всем "Назначениям" (1) */
                                                                   {&tabulation}
                                                                   {&tabulation}
                accum-gds-code-doc-qnty                            {&tabulation}
                accum-gds-code-sum-base                            {&tabulation}
                accum-gds-code-trans-number
                skip
              .
            end.

            /* Вывод Итогов по товару для случая "НЕ СбросТрнзкц" (здесь всего три итоговых столбца в отчёте) */
            otherwise
            do:
              {&PutExcel}
                                                                   {&tabulation}
                substitute("Итого по &1", buf_temp-goods.gds-name) {&tabulation}
                                                                   {&tabulation}
                (if p-chk-type = integer({&rcpt-trans-transfer}) then {&tabulation}
                 else                                              '':U)
                accum-gds-code-doc-qnty                            {&tabulation}
                accum-gds-code-sum-base                            {&tabulation}
                accum-gds-code-trans-number
                skip
              .
            end.
          end case.
        end.

        /* "Итого по кассе" */
        if last-of(buf_temp-petrol-chk.pay-desk) then
        do:
          /* Вывод Итогов по кассе для случая "НЕ СбросТрнзкц" (здесь всего три итоговых столбца в отчёте) */
          if p-chk-type <> integer({&rcpt-trans-cancell}) and p-chk-type <> integer({&rcpt-unlock-trans}) then
          do:
            /* Итоги C (Собираем итоги из tt с разбивкой по "Назначение") */
            if p-chk-type = integer({&rcpt-tech-refuell}) then
            do: /* Итоги C */
              for each bufo3_temp-petrol-chk where
                       bufo3_temp-petrol-chk.chk-type = p-chk-type
                   and bufo3_temp-petrol-chk.obj-type = obj-list.obj-type
                   and bufo3_temp-petrol-chk.obj-code = obj-list.obj-code
                   and bufo3_temp-petrol-chk.gds-code = 0
                   and bufo3_temp-petrol-chk.pay-desk = buf_temp-petrol-chk.pay-desk
                   and bufo3_temp-petrol-chk.pump = 0
                   and bufo3_temp-petrol-chk.pump-2 = 0
                   and bufo3_temp-petrol-chk.pay-code <> 0 /* "Назначение" (отработка наличия/отсутствия) */
              no-lock:
                do:
                  {&PutExcel}
                                                                   {&tabulation}
                    substitute("Итого по кассе &1", buf_temp-petrol-chk.pay-desk) {&tabulation}  /* C. Итого по товару с разбивкой по "Назначение" */
                    (if p-chk-type = integer({&rcpt-tech-refuell}) and p-rs-grp-tech-refuell = 2
                    then bufo3_temp-petrol-chk.pay-name +          {&tabulation} +
                                                                   {&tabulation}
                    else
                                                                   {&tabulation} +
                    bufo3_temp-petrol-chk.pay-name +               {&tabulation})
                    bufo3_temp-petrol-chk.doc-qnty                 {&tabulation}
                    bufo3_temp-petrol-chk.sum-base                 {&tabulation}
                    bufo3_temp-petrol-chk.trans-number
                    skip
                  .
                end.
              end.
            end. /*** Итоги C ***/

            do:
              {&PutExcel}
                                                                      {&tabulation}
                substitute((if p-chk-type = integer({&rcpt-tech-refuell})
                            then "Итого по кассе &1 по всем назначениям:"
                            else "Итого по кассе &1: "), buf_temp-petrol-chk.pay-desk) {&tabulation}
                (if p-chk-type = integer({&rcpt-tech-refuell}) then   {&tabulation}
                 else                                                         '':U)
                (if p-chk-type = integer({&rcpt-trans-transfer}) then {&tabulation}
                 else                                                         '':U)
                                                                      {&tabulation}
                accum-pay-desk-doc-qnty                               {&tabulation}
                accum-pay-desk-sum-base                               {&tabulation}
                accum-pay-desk-trans-number
                skip
              .
            end.
          end.

          /* Вывод Итогов по кассе для случая "СбросТрнзкц" (здесь всего шесть итоговых столбцов в отчёте) */
          if p-chk-type = integer({&rcpt-trans-cancell}) or p-chk-type = integer({&rcpt-unlock-trans}) then
          do:
            {&PutExcel}
                                                {&tabulation}
              substitute("Итого по кассе &1", buf_temp-petrol-chk.pay-desk) {&tabulation}
                                                {&tabulation}
              accum-pay-desk-doc-qnty           {&tabulation}
              accum-pay-desk-sum-base           {&tabulation}
              accum-pay-desk-trans-number       {&tabulation}
              accum-pay-desk-doc-qnty-ns        {&tabulation}
              accum-pay-desk-sum-base-ns        {&tabulation}
              accum-pay-desk-trans-number-ns
              skip
            .
          end.
        end. /* Итого по кассе */
        /*** "Итого по кассе" ***/

        if last-of(buf_temp-petrol-chk.pay-desk)
          and last(buf_temp-petrol-chk.pay-desk)
        then
        do:
          /*итоги по видам топлива (subtotal)*/
/*          Put Stream PrnLibStream Unformatted*/
/*          "Итоги по видам топлива:"          */
/*          skip(0).                           */

          {&PutExcel}
          "Итоги по видам топлива:"
          skip.

          assign
            accum-doc-qnty = 0
            accum-sum-base = 0
            accum-trans-number = 0
            accum-doc-qnty-ns = 0
            accum-sum-base-ns = 0
            accum-trans-number-ns = 0
          .
          v-first-good = yes.


/* run gbl/inidebug.p.*/

          for each bufo_temp-petrol-chk where
                   bufo_temp-petrol-chk.chk-type = p-chk-type
               and bufo_temp-petrol-chk.obj-type = obj-list.obj-type
               and bufo_temp-petrol-chk.obj-code = obj-list.obj-code
               and bufo_temp-petrol-chk.pay-desk = 0
               and bufo_temp-petrol-chk.pump = 0
               and bufo_temp-petrol-chk.pay-code = 0

               
          ,
             first bufo_temp-goods where
                   bufo_temp-goods.gds-code = bufo_temp-petrol-chk.gds-code
          :
            assign
              accum-doc-qnty        = accum-doc-qnty        + bufo_temp-petrol-chk.doc-qnty
              accum-sum-base        = accum-sum-base        + bufo_temp-petrol-chk.sum-base
              accum-trans-number    = accum-trans-number    + bufo_temp-petrol-chk.trans-number
              accum-doc-qnty-ns     = accum-doc-qnty-ns     + bufo_temp-petrol-chk.doc-qnty-ns
              accum-sum-base-ns     = accum-sum-base-ns     + bufo_temp-petrol-chk.sum-base-ns
              accum-trans-number-ns = accum-trans-number-ns + bufo_temp-petrol-chk.trans-number-ns
            .

            /* Итоги Б (Собираем итоги в tt по "Назначение", т.е. где: temp-petrol-chk.pay-code <> 0)*/
            if p-chk-type = integer({&rcpt-tech-refuell}) then
            do: /* Итоги Б */
              for each bufo2_temp-petrol-chk where
                       bufo2_temp-petrol-chk.chk-type = p-chk-type
                   and bufo2_temp-petrol-chk.obj-type = obj-list.obj-type
                   and bufo2_temp-petrol-chk.obj-code = obj-list.obj-code
                   and bufo2_temp-petrol-chk.gds-code = bufo_temp-petrol-chk.gds-code
                   and bufo2_temp-petrol-chk.pay-desk = 0
                   and bufo2_temp-petrol-chk.pump = 0
                   and bufo2_temp-petrol-chk.pay-code <> 0
              ,
                 first bufo2_temp-goods where
                       bufo2_temp-goods.gds-code = bufo2_temp-petrol-chk.gds-code
                       
              :
                  
       do:
         
                  {&PutExcel}
                                                                     {&tabulation}
                    substitute("ИТОГО &1", bufo_temp-goods.gds-name) {&tabulation}  /* Б. Итого по товару */
                    (if p-chk-type = integer({&rcpt-tech-refuell}) and p-rs-grp-tech-refuell = 2
                    then bufo2_temp-petrol-chk.pay-name +            {&tabulation} +
                                                                     {&tabulation}
                    else
                                                                     {&tabulation} +
                    bufo2_temp-petrol-chk.pay-name +                 {&tabulation})
                    bufo2_temp-petrol-chk.doc-qnty                   {&tabulation}
                    bufo2_temp-petrol-chk.sum-base                   {&tabulation}
                    bufo2_temp-petrol-chk.trans-number
                    skip
                  .
                end.
                             
              end. /* for each bufo2_temp-petrol-chk */
      
            end. /*** Итоги Б (Собираем итоги в tt по "Назначение", т.е. где: temp-petrol-chk.pay-code <> 0) ***/

/* Блокируем вывод на экран ТН-3359 10.02.2015 Арн. */
/*
            if p-chk-type = integer({&rcpt-trans-transfer}) then
            do:
              if not v-first-good then
              do:
                DOWn 1 Stream PrnLibStream
                with frame two-pump.
              end.
              display stream PrnLibStream
              substitute("ИТОГО по &1", bufo_temp-goods.gds-name) @ buf_temp-goods.gds-name
              bufo_temp-petrol-chk.doc-qnty     @ buf_temp-petrol-chk.doc-qnty
              bufo_temp-petrol-chk.sum-base     @ buf_temp-petrol-chk.sum-base
              bufo_temp-petrol-chk.trans-number @ buf_temp-petrol-chk.trans-number
              with frame two-pump.
            end.
            else
            do:
              if not v-first-good then
              do:
                DOWn 1 Stream PrnLibStream
                with frame one-pump.
              end.
              display stream PrnLibStream
              substitute("ИТОГО по &1", bufo_temp-goods.gds-name) @ buf_temp-goods.gds-name
              bufo_temp-petrol-chk.doc-qnty     @ buf_temp-petrol-chk.doc-qnty
              bufo_temp-petrol-chk.sum-base     @ buf_temp-petrol-chk.sum-base
              bufo_temp-petrol-chk.trans-number @ buf_temp-petrol-chk.trans-number
              with frame one-pump.
            end.
*/

            /*печатаем в excel*/
            /* Вывод Итогов (subtotal) по товарам-2 (т.е. топливам) для случая "НЕ СбросТрнзкц" (здесь всего три итоговых столбца в отчёте) */
            if p-chk-type <> integer({&rcpt-trans-cancell}) and p-chk-type <> integer({&rcpt-unlock-trans}) then
            do:
              {&PutExcel}
                                                                  {&tabulation}
                substitute((if p-chk-type = integer({&rcpt-tech-refuell}) then "ИТОГО &1 по всем назначениям:"  /* Только для "ТехПролив" */
                                                                          else "ИТОГО по &1")                   /* Для всех остальных разделов */
                                                                          ,
                                                                          bufo_temp-goods.gds-name) /* A. Итого по товару (2) */
                                                                  {&tabulation}     /* Как минимум - для всех разделов (пропуск одного столбца) */
                                                                  {&tabulation}     /* (к выше сказанному) */
                (if p-chk-type = integer({&rcpt-trans-transfer}) then {&tabulation} /* Для "ПеревТрнзкц" - ещё смещение (т.к. вставится столбец ТРК-2) */
                 else                                             '':U)
                (if p-chk-type = integer({&rcpt-tech-refuell}) then
                                                               (if p-rs-grp-tech-refuell = 1 then bufo_temp-petrol-chk.pay-name + {&tabulation}  /* "Назначение-4" Группировка ТРК/Назначение */
                                                                                             else {&tabulation} + bufo_temp-petrol-chk.pay-name) /* "Назначение-4" Группировка Назначение/ТРК */
                 else                                             '':U)
                bufo_temp-petrol-chk.doc-qnty                     {&tabulation}
                bufo_temp-petrol-chk.sum-base                     {&tabulation}
                bufo_temp-petrol-chk.trans-number
                skip
              .
              v-first-good = no.
                
            end.
            else /* Вывод Итогов по товарам (т.е. топливам) для случая "СбросТрнзкц" (здесь всего шесть итоговых столбца в отчёте) */
            do:
              {&PutExcel}
                                                                    {&tabulation}
                substitute("ИТОГО по &1", bufo_temp-goods.gds-name) {&tabulation} /* B. Итого по товару (2) */
                                                                    {&tabulation}
                bufo_temp-petrol-chk.doc-qnty                       {&tabulation}
                bufo_temp-petrol-chk.sum-base                       {&tabulation}
                bufo_temp-petrol-chk.trans-number                   {&tabulation}
                bufo_temp-petrol-chk.doc-qnty-ns                    {&tabulation}
                bufo_temp-petrol-chk.sum-base-ns                    {&tabulation}
                bufo_temp-petrol-chk.trans-number-ns
                skip
              .
              v-first-good = no.
            end.
          end. /*по всем видам топлива по объекту*/

          &scop receipt-code string(p-chk-type)

/* Блокируем вывод на экран ТН-3359 10.02.2015 Арн. */
/*
          if p-chk-type = integer({&rcpt-trans-transfer}) then
          do:
            DOWn 2 Stream PrnLibStream
            with frame two-pump.
            display stream PrnLibStream
            substitute("ИТОГ по &1"
                    , (if p-chk-type = 0 then "всем типам чеков" else {&receipt-name})
                    ) @ buf_temp-goods.gds-name
            accum-doc-qnty @ buf_temp-petrol-chk.doc-qnty
            accum-sum-base @ buf_temp-petrol-chk.sum-base
            accum-trans-number @ buf_temp-petrol-chk.trans-number
            with frame two-pump.
          end.
          else
          do:
            DOWn 2 Stream PrnLibStream
            with frame one-pump.
            display stream PrnLibStream
            substitute("ИТОГ по &1"
                    , caps((if p-chk-type = 0 then "всем типам чеков" else {&receipt-name}))) @ buf_temp-goods.gds-name
            accum-doc-qnty @ buf_temp-petrol-chk.doc-qnty
            accum-sum-base @ buf_temp-petrol-chk.sum-base
            accum-trans-number @ buf_temp-petrol-chk.trans-number
            with frame one-pump.
          end.
*/

          /*печатаем в excel*/
          /* Вывод Итогов по типам чеков для случая "НЕ СбросТрнзкц" (здесь всего три итоговых столбца в отчёте) */
          if p-chk-type <> integer({&rcpt-trans-cancell}) and p-chk-type <> integer({&rcpt-unlock-trans}) then
          do:
            /* Итоги по ТИПУ ЧЕКА (Например, по ТехПролив */
            /* Итоги Е (Собираем итоги в tt по "Назначение", т.е. где: temp-petrol-chk.pay-code <> 0)*/
            if p-chk-type = integer({&rcpt-tech-refuell}) then
            do: /* Итоги Е */
              for each bufo3_temp-petrol-chk where
                       bufo3_temp-petrol-chk.chk-type = p-chk-type
                   and bufo3_temp-petrol-chk.obj-type = obj-list.obj-type
                   and bufo3_temp-petrol-chk.obj-code = obj-list.obj-code
                   and bufo3_temp-petrol-chk.gds-code = 0
                   and bufo3_temp-petrol-chk.pay-desk = 0
                   and bufo3_temp-petrol-chk.pump = 0
                   and bufo3_temp-petrol-chk.pump-2 = 0
                   and bufo3_temp-petrol-chk.pay-code <> 0
              no-lock:
                do:
                  {&PutExcel}
                                                                     {&tabulation}
                    substitute("ИТОГО по &1", {&receipt-name})       {&tabulation}  /* Е. Итого по разделу (например "ТехПролив" */
                    (if p-chk-type = integer({&rcpt-tech-refuell}) and p-rs-grp-tech-refuell = 2
                    then bufo3_temp-petrol-chk.pay-name +            {&tabulation} +
                                                                     {&tabulation}
                    else
                                                                     {&tabulation} +
                    bufo3_temp-petrol-chk.pay-name +                 {&tabulation})
                    bufo3_temp-petrol-chk.doc-qnty                   {&tabulation}
                    bufo3_temp-petrol-chk.sum-base                   {&tabulation}
                    bufo3_temp-petrol-chk.trans-number
                    skip
                  .
                end.
                    
              end.
     
            end. /*** Итоги Е ***/

            {&PutExcel}
              skip(0)
                                                                  {&tabulation}
              substitute((if p-chk-type = integer({&rcpt-tech-refuell}) then "ИТОГ &1 по всем назначениям" else "ИТОГ &1"), caps((if p-chk-type = 0 then
              "всем типам чеков" else {&receipt-name}))) /* Итог по виду чека (например по "СбросТрнзкц") */
                                                                  {&tabulation}
                                                                  {&tabulation}
              (if p-chk-type = integer({&rcpt-trans-transfer}) or
              p-chk-type = integer({&rcpt-tech-refuell}) then     {&tabulation}
               else                                               '':U)
              accum-doc-qnty                                      {&tabulation}
              accum-sum-base                                      {&tabulation}
              accum-trans-number
              
              skip
            .
           
          end.
          else /* Вывод Итогов по типам чеков для случая "СбросТрнзкц" (здесь всего три итоговых столбца в отчёте) */
          do:
            {&PutExcel}
            skip(0)
                                                                  {&tabulation}
            substitute("ИТОГ по &1", caps((if p-chk-type = 0 then "всем типам чеков" else {&receipt-name}))) /* Итог по виду чека (например по "СбросТрнзкц") */
                                                                  {&tabulation}
                                                                  {&tabulation}
            accum-doc-qnty                                        {&tabulation}
            accum-sum-base                                        {&tabulation}
            accum-trans-number                                    {&tabulation}
            accum-doc-qnty-ns                                     {&tabulation}
            accum-sum-base-ns                                     {&tabulation}
            accum-trans-number-ns
            skip.
          end.

   end. /**if last-of(buf_temp-petrol-chk) and last(buf_temp-pettrol-chk)*/
          end. /*for each buf_temp-petrol-chk*/
          
          
          
          /*по всем объектам в общем*/
          if multi-obj
          and loc-obj-count = obj-count 
          then
          do:

/* Блокируем вывод на экран ТН-3359 10.02.2015 Арн. */
/*
            Put Stream PrnLibStream UNFORMATTED
            skip(1)
            substitute("ПО ВСЕМ ВЫБРАННЫМ ОБЪЕКТАМ") skip.
*/
            {&Putexcel}
              substitute("ПО ВСЕМ ВЫБРАННЫМ ОБЪЕКТАМ")
              skip
            .

            assign
              accum-doc-qnty = 0
              accum-sum-base = 0
              accum-trans-number = 0
               accum-doc-qnty-ns = 0 
               accum-sum-base-ns = 0 
                  accum-trans-number-ns = 0
            .
            for each bufo_temp-petrol-chk where
                     bufo_temp-petrol-chk.obj-type = '':U
                 and bufo_temp-petrol-chk.obj-code = 0
                 and bufo_temp-petrol-chk.chk-type = p-chk-type
                 and bufo_temp-petrol-chk.pump = 0
                 and bufo_temp-petrol-chk.pay-desk = 0
                 and bufo_temp-petrol-chk.pay-code = 0
                  
            ,
               first bufo_temp-goods where
                    bufo_temp-goods.gds-code = bufo_temp-petrol-chk.gds-code
            break
/*            by bufo_temp-petrol-chk.pay-desk*/
            by bufo_temp-petrol-chk.gds-code
            :
              assign
                accum-doc-qnty     = accum-doc-qnty      + bufo_temp-petrol-chk.doc-qnty
                accum-sum-base     = accum-sum-base      + bufo_temp-petrol-chk.sum-base
                accum-trans-number = accum-trans-number  + bufo_temp-petrol-chk.trans-number
                 accum-doc-qnty-ns     = accum-doc-qnty-ns     + bufo_temp-petrol-chk.doc-qnty-ns
              accum-sum-base-ns     = accum-sum-base-ns     + bufo_temp-petrol-chk.sum-base-ns
              accum-trans-number-ns = accum-trans-number-ns + bufo_temp-petrol-chk.trans-number-ns
            
              .
                          /* Блокируем вывод на экран ТН-3359 10.02.2015 Арн. */
                          /*
                                        if p-chk-type = integer({&rcpt-trans-transfer}) then
                                        do:
                                          down 1 stream PrnLibStream
                                          with frame two-pump.
                                          display stream PrnLibStream
                                          bufo_temp-goods.gds-name          @ buf_temp-goods.gds-name
                                          bufo_temp-petrol-chk.doc-qnty     @ buf_temp-petrol-chk.doc-qnty
                                          bufo_temp-petrol-chk.sum-base     @ buf_temp-petrol-chk.sum-base
                                          bufo_temp-petrol-chk.trans-number @ buf_temp-petrol-chk.trans-number
                                          with frame two-pump.
                                        end.
                                        else
                                        do:
                                          down 1 stream PrnLibStream
                                          with frame one-pump.
                                          display stream PrnLibStream
                                          bufo_temp-goods.gds-name          @ buf_temp-goods.gds-name
                                          bufo_temp-petrol-chk.doc-qnty     @ buf_temp-petrol-chk.doc-qnty
                                          bufo_temp-petrol-chk.sum-base     @ buf_temp-petrol-chk.sum-base
                                          bufo_temp-petrol-chk.trans-number @ buf_temp-petrol-chk.trans-number
                                          with frame one-pump.
                                        end.
                          */
                      
                        if p-chk-type <> integer({&rcpt-trans-cancell}) and p-chk-type <> integer({&rcpt-unlock-trans}) then
                      
                          do:
                  
                              {&PutExcel}
                                      {&tabulation}

                                      bufo_temp-goods.gds-name                        {&tabulation}
                                      {&tabulation}
                   
                                      (if p-chk-type = integer({&rcpt-trans-transfer}) or p-chk-type = integer({&rcpt-tech-refuell}) then {&tabulation}
                                      else                                           '':u)
                                                                    
                                      bufo_temp-petrol-chk.doc-qnty                       {&tabulation}
                                      bufo_temp-petrol-chk.sum-base                       {&tabulation}
                                      bufo_temp-petrol-chk.trans-number                   
                                      skip
                                      .
                  
                          end.
                      else
                          do:     
    
                              {&PutExcel}
                                      {&tabulation}
                                      bufo_temp-goods.gds-name                        {&tabulation}
                                      {&tabulation}
                    
                                      (if p-chk-type = integer({&rcpt-trans-transfer}) or p-chk-type = integer({&rcpt-tech-refuell}) then {&tabulation}
                                      else                                           '':u)
                                                                    
                                      bufo_temp-petrol-chk.doc-qnty                       {&tabulation}
                                      bufo_temp-petrol-chk.sum-base                       {&tabulation}
                                      bufo_temp-petrol-chk.trans-number                   {&tabulation}
                                      bufo_temp-petrol-chk.doc-qnty-ns                    {&tabulation}
                                      bufo_temp-petrol-chk.sum-base-ns                    {&tabulation}
                                      bufo_temp-petrol-chk.trans-number-ns
                                      skip
                                      .
                          end.
                      end. /*for each bufo_temp-petrol-chk wh*/

            &scop receipt-code string(p-chk-type)

                      /* Блокируем вывод на экран ТН-3359 10.02.2015 Арн. */
                      /*
                                  Put Stream PrnLibStream UNFORMATTED
                                    skip(1)
                                  .
                                  if p-chk-type = integer({&rcpt-trans-transfer}) then
                                  do:
                                    down 1 stream PrnLibStream
                                    with frame two-pump.
                                    display stream PrnLibStream
                                    substitute("ИТОГ по &1", caps(if p-chk-type = 0 then "всем типам чеков" else {&receipt-name})) @ buf_temp-goods.gds-name
                                    accum-doc-qnty @ buf_temp-petrol-chk.doc-qnty
                                    accum-sum-base @ buf_temp-petrol-chk.sum-base
                                    accum-trans-number @ buf_temp-petrol-chk.trans-number
                                    with frame two-pump.
                                  end.
                                  else
                                  do:
                                    down 1 stream PrnLibStream
                                    with frame one-pump.
                                    display stream PrnLibStream
                                    substitute("ИТОГ по &1", caps(if p-chk-type = 0 then "всем типам чеков" else {&receipt-name})) @ buf_temp-goods.gds-name
                                    accum-doc-qnty @ buf_temp-petrol-chk.doc-qnty
                                    accum-sum-base @ buf_temp-petrol-chk.sum-base
                                    accum-trans-number @ buf_temp-petrol-chk.trans-number
                                    with frame one-pump.
                                  end.
                      */
                    
                     if p-chk-type <> integer({&rcpt-trans-cancell}) and p-chk-type <> integer({&rcpt-unlock-trans}) then
                      do:
                          {&PutExcel}
                                  skip(1)
                                  {&tabulation}
                                  substitute("ИТОГ по &1", caps(if p-chk-type = 0 then "всем типам чеков" else {&receipt-name}))
                                  {&tabulation}
                                  {&tabulation}
                                
                                  (if p-chk-type = integer({&rcpt-trans-transfer}) or p-chk-type = integer({&rcpt-tech-refuell}) then {&tabulation}
                                  else                                           '':u)
                                  accum-doc-qnty                   {&tabulation}
                                  accum-sum-base                   {&tabulation}
                                  accum-trans-number              
                                  skip
                                  .
                      end.
                     else
                      do: 
              
                          {&PutExcel}
                                  skip(1)
                                  {&tabulation}
                                  substitute("ИТОГ по &1", caps(if p-chk-type = 0 then "всем типам чеков" else {&receipt-name}))
                                  {&tabulation}
                                  {&tabulation}
                                
            
                                
                                  (if p-chk-type = integer({&rcpt-trans-transfer}) or p-chk-type = integer({&rcpt-tech-refuell}) then {&tabulation}
                                  else                                           '':u)
                                  accum-doc-qnty                    {&tabulation}
                                  accum-sum-base                    {&tabulation}
                                  accum-trans-number                {&tabulation}
                                  accum-doc-qnty-ns                 {&tabulation}
                                  accum-sum-base-ns                 {&tabulation}
                                  accum-trans-number-ns           
                                  skip
                                  .
                      end.
                  end. /*if multi-obj*/
           
        
        
          
      /*      if obj-count <> loc-obj-count then                    */
      /*      do:                                                   */
      /*/* Блокируем вывод на экран ТН-3359 10.02.2015 Арн. */      */
      /*/*                                                          */
      /*        if p-chk-type = integer({&rcpt-trans-transfer}) then*/
      /*        do:                                                 */
      /*          down 1 stream PrnLibStream                        */
      /*          with frame two-pump.                              */
      /*        end.                                                */
      /*        else                                                */
      /*        do:                                                 */
      /*          down 1 stream PrnLibStream                        */
      /*          with frame one-pump.                              */
      /*        end.                                                */
      /**/                                                          */
      /*                                                            */
      /*        {&PutExcel}                                         */
      /*          skip                                              */
      /*        .                                                   */
      /*                                                            */
      /*      end.                                                  */
      end. /*for each obj-list*/

/* Блокируем вывод на экран ТН-3359 10.02.2015 Арн. */
/*
    clear frame two-pump.
    clear frame one-pump.
    HIDE  STREAM PrnLibStream FRAME BottomFrame.
    /*if p-chk-type = integer({&rcpt-trans-transfer}) then*/
    HIDE  STREAM PrnLibStream FRAME two-pump.
    /*else*/
    HIDE  STREAM PrnLibStream FRAME one-pump.
*/
  end.

end procedure. /* print-one-chk-type */