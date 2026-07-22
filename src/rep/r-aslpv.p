block-level on error undo, throw.
/*

$Revision: a8e2cf75ddf6, 2506, rls $
$Author: EShklyar $
$Date: Ср июл 08 17:09:06 2020 +0300 $
$Workfile: r-asLPV.p $
$Archive: rep/r-asLPV.p $

Отчет об отчислениях в ЛПВ

Автор: Шутилов Арнольд Валерьевич
Дата создания: 23/05/15
Author: Shutilov Arnold
Creation date: 23/05/15

*/

/* ***************************  Definitions  ************************** */
define input parameter parparentproc as handle no-undo.

define variable vss-revision    as character no-undo init "$Revision: a8e2cf75ddf6, 2506, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Ср июл 08 17:09:06 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-asLPV.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-asLPV.p $":U .
define variable vss-description as character no-undo init "Отчет об отчислениях в ЛПВ".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ gbl/getcntxt.i def }
{ cmp/r-page1.i }
{ cmp/r-pril.i }    /* Для использования {&DF_Name} */
{ gbl/attr-lib.i }  /* для run gds-attr-value */
{ ref/gds-attr.i }  /* для run gds-attr-value */
{ ref/cp-attr.i }   /* для использования {&cp-attr-bal_malina} и вызова процедур работы с аттрибутами платежа */

define variable v-full-path-RepView as character no-undo.   /* Полный путь к файлу Просмотровщика (отчётов) */
define variable v-file-name-rep-htm as character no-undo.   /* Полный путь к файлу отчёта */
define variable g#report-num as integer no-undo.            /* Номер отчёта (получим стандартной процедурой ТН) */
define variable v-report-name as character no-undo.         /* Наименование отчёта */
define variable v-period as character no-undo.              /* Период за который формируется отчёт */
define variable v-short-obj-list as character no-undo.      /* Перечень выбранных объектов "в одну строку" */
define variable v-chk-sum as decimal no-undo.               /* п4.   Сумма чека (по Чеку) */
define variable v-obj-sum as decimal no-undo.               /* п4.1. Сумма чека (по Объекту) */
define variable v-rep-sum as decimal no-undo.               /* п4.2. Сумма чека (по Отчёту) */
define variable v-con-chk-sum as decimal no-undo.           /* п5.   Сумма отчислений (гр.4*1%) (contribution) (по Чеку) */
define variable v-con-obj-sum as decimal no-undo.           /* п5.1. Сумма отчислений (гр.4*1%) (contribution) (по Объекту) */
define variable v-con-rep-sum as decimal no-undo.           /* п5.2. Сумма отчислений (гр.4*1%) (contribution) (по Отчёту) */
define variable v-ban-bonus as decimal no-undo.             /* Суммы товаров с "Запрет на участие в бонусных ПРГ" по Чеку (для искл их из отч по ТЗ) */
define variable v-bonus-malina as decimal no-undo.          /* Суммы товаров с типом платежа "Оплата баллами Малина" по Чеку (для искл их из отч по ТЗ) */
define variable v-ban-bonus-local as decimal no-undo.       /* Локальная переменная (вспомогательная) */
/*define variable v-base-code like ub.currency.curr-code no-undo. /* Для использования в определении "Оплата бонусами Малина" по цепочке: */*/
define variable v-last-of-condition as logical no-undo.     /* Служ. флаг для расчёта сумм в Условии-1 (УМУКО) */
define variable v-last-of-condition2 as logical no-undo.  /* Служ. флаг для расчёта сумм в Условии-2 (Итоговые суммы по Объекту) */
define variable v-sum_ as decimal no-undo.                      /* Локальная переменная для chk-calc */
define variable v-sum-contribution_ as decimal no-undo.         /* Локальная переменная для chk-calc */
define variable v-calc-ban-bonus as logical no-undo.
define variable v-pay-codes-bonus-malina as character no-undo.
define variable v-accur-13 as character initial "->>>>>>>>>>>>9.99" no-undo.   /* Формат числа с плавающей точкой на 15 разрядов до и 2 разряда после десятичной запятой. ТРИЛЛИОН. */

/* Переменные для функции last-of-condition (функция смены условий-вх.данных) (УМУКО) */
define variable v-doc-code1   like ub.chk-doc.doc-code no-undo.
define variable v-obj-type1   like ub.chk-doc.obj-type no-undo.
define variable v-obj-code1   like ub.chk-doc.obj-code no-undo.
define variable v-chk-date1   like ub.chk-doc.chk-date no-undo.
define variable v-shift-date1 like ub.chk-doc.shift-date no-undo.

/* Переменные для функции last-of-condition2 (функция смены условий-вх.данных) (Итоги по Объету) */
define variable v-obj-type2   like ub.chk-doc.obj-type no-undo.
define variable v-obj-code2   like ub.chk-doc.obj-code no-undo.
define variable v-note2       as character no-undo.

define variable v-ii as integer no-undo.
define variable v-iii as integer no-undo.
define variable v-my-var as character no-undo.
define variable v-iiii as integer no-undo.

define temp-table tt-chk no-undo
    field doc-code          like ub.chk-doc.doc-code
    field obj-type          like ub.chk-doc.obj-type
    field obj-code          like ub.chk-doc.obj-code
    /*field chk-num           like ub.chk-doc.chk-num*/
    field chk-type          like ub.chk-doc.chk-type
    field chk-date          like ub.chk-doc.chk-date
    field shift-date        like ub.chk-doc.shift-date
    /*field shift-num         like ub.chk-doc.shift-num*/
    /*field chk-time          like ub.chk-doc.chk-time*/
    /*field pay-desk          like ub.chk-doc.pay-desk*/
    field discnt            like ub.chk-doc.discnt
    field out-code          like ub.chk-doc.out-code
    field office            like ub.chk-doc.office
    field d-card            like ub.chk-doc.d-card
    field netto             like ub.chk-doc.netto
    field sub-discnt        like ub.chk-doc.sub-discnt
    field d-pcnt            like ub.chk-doc.d-pcnt
    /*field src-d-pcnt        like ub.chk-doc.src-d-pcnt*/
    /*field doc-num           like ub.chk-doc.doc-num*/
    /*field doc-qnty          like ub.chk-doc.doc-qnty*/
    field ban-bonus_        as logical                  /* where goods-attr.attr-code = "ban-bonus" and goods-attr.attr-value = "yes/no" */
    field obj-name_         as character                /* Наименование объекта */
    field sum-netto         as decimal                  /* Моя служебная сумма. Сумма по netto. */
    field sum_              as decimal
    field note_             as character
    field b-code_           like ub.bar-code.b-code
    field sale-price_       like ub.chk-gds.price-base
    field sum-gds-ban-bonus_ as decimal                 /* Сумма по товарам с глобальным атрибутом "Запрет на участие в бонусных программах\участие в скидке на итог»". */
    field sum-bonus-malina_ as decimal                  /* Моя служебная сумма. Сумма по типу платежа: "Оплата баллами Малина". */
    field sum-contribution_ as decimal                  /* 5. Сумма отчислений. */

    index pi    is primary obj-type obj-code
    index dates chk-date shift-date
    index note  note_
.

define temp-table my-table no-undo
    field obj-type as character /* obj-type */
    field obj-code as character /* obj-code */
    field sum-netto as character
    field sum-gds-ban-bonus_ as character
    field list-ban-bonus as character
    field sum_ as character  /* sum */
    field list-v-sum_ as character
    field list-sum-netto as character
    field list-tot-r-b as character
    field sum-contribution_ as character
    field doc-code as character /* doc-code */
    field list-doc-code as character
    field list-chk-gds-pay as character
    field list-b-code as character
    field list-chk-date as character /* chk-date */
    field list-shift-date as character /* shift-date */
    field sum-bonus-malina_ as character
    field list-bonus-malina as character
    field list-sum_ as character
.

define temp-table my-table2 no-undo
    field obj-type as character /* obj-type */
    field obj-code as character /* obj-code */
    field doc-code as character /* doc-code */
    field chk-date as character /* chk-date */
    field sum_ as character  /* sum */
    field sum-contribution_ as character
.

define buffer buf1_tt-chk for tt-chk.
define buffer buf2_tt-chk for tt-chk.

define stream OutStr-html.
define stream MyWatch-strm. /* задать в области определения переменных */
/* ********************  Preprocessor Definitions  ******************** */

/* ************************  Function Implementations ***************** */
function fnc-ban-bonus returns logical 
(input p-gds-code as integer) forward.

function fnc-DD-MM-YYYY returns character 
(input p-dat-date as date) forward.

function fnc-convert-dot-to-colon returns character 
(input p-data as decimal, input p-accur as character) forward.

function last-of-condition returns logical
(/*input doc-code   as character,*/
 input obj-type   as character,
 input obj-code   as integer,
 input chk-date   as date,
 input shift-date as date) forward.

function last-of-condition2 returns logical
(input obj-type   as character,
 input obj-code   as integer
 /*input note       as character*/) forward.
/* ************************  Function Implementations ***************** */


/* ***************************  Main Block  *************************** */

run My-Rep.

procedure My-Rep:

    run get-full-path-RepViewer(output v-full-path-RepView).    /* Перед работой с "Просмотровщиком отчёта" (main.exe) - убедимся, что он существует и получим полный путь к нему. */

    run get-report-num in parParentProc(output g#report-num).   /* Получим СТАНДАРТНЫМ МЕТОДОМ ТН номер файла отчёта. */

    run define-full-path-Report(input g#report-num, output v-file-name-rep-htm).   /* Сформируем стандартизованное в ТН имя файла отчёта. */

    run create-file(v-file-name-rep-htm).   /* Создадим на диске пустой файл со сформированным по стандарту именем файла. */

    v-report-name = "Отчет об отчислениях в ЛПВ". /* Наименование отчёта */

    v-period = str1. /* Период, за который формируется отчёт */

    run get-pay-codes-bonus-malina. /* Получаем все типы оплаты, которым пользователь присвоил атрибут "Оплата баллами Малина" (в переменную). */

    run create-fill-tt-chk. /* Создание и заполнение таблицы отчёта */ /*run my-watch-table2.*/ /*run my-watch-table3.*/

    /* Печать в ReportView(Excel) */
    run proc-create-HTML(
                             input v-file-name-rep-htm
                            ,input v-report-name
                            ,input v-period
                            ,input v-short-obj-list
                        ).

    run search-full-path-Report(input v-file-name-rep-htm). /* Проверка на наличие файла-отчёта, перед использованием его в RepViewer */

    run Report-Viewer(input v-full-path-RepView, input v-file-name-rep-htm). /* Запуск просмотровщика отчёта RepViewer */

    /*run my-watch-table.*/
end procedure. /* My-Rep: */
/* *******************************************************  Main Block */

procedure create-fill-tt-chk:
/* *********************** */
/*    { gbl/basecode.i 0 v-base-code no-error } /* Определение кода базовой валюты по коду фирмы (будет использоваться для пызова проц в chk-calc ниже) Не приемлемо - если не задана базовая валюта в настройках фирмы - здесь выдаётся message из инклудника, который не блокируется no-error */*/

    for each obj-list
    :
        if x-TOG-Shift = yes then
        do:  /* if x-TOG-Shift = yes */
            _c-d: for each ub.chk-doc where
                           ub.chk-doc.obj-type = obj-list.obj-type and
                           ub.chk-doc.obj-code = obj-list.obj-code and
                           (ub.chk-doc.shift-date > X-date-Start or (ub.chk-doc.shift-date = X-date-Start and ub.chk-doc.shift-num >= x-Shift-Start)) and
                           (ub.chk-doc.shift-date < X-date-End or (ub.chk-doc.shift-date = X-date-End and ub.chk-doc.shift-num <= x-Shift-End)) and
                           ub.chk-doc.out-code <> ? and                 /* учтённые чеки */
                           (ub.chk-doc.chk-type = integer({&rcpt-sale}) or ub.chk-doc.chk-type = integer({&rcpt-return})) and /* учитываем все типы продаж и возвратов */
                           (string(ub.chk-doc.d-card) begins "639300" or ub.chk-doc.d-card begins "275")
            :
                run chk-calc.
            end. /* for each chk-doc */
        end. /* if x-TOG-Shift = yes */
        else
        do:  /* else if x-TOG-Shift = no */
            _c-d: for each ub.chk-doc where
                           ub.chk-doc.obj-type = obj-list.obj-type and
                           ub.chk-doc.obj-code = obj-list.obj-code and
                           ub.chk-doc.chk-date >= X-date-Start and
                           ub.chk-doc.chk-date <= X-date-End and
                           ub.chk-doc.out-code <> ? and                    /* учтённые чеки */
                           (ub.chk-doc.chk-type = integer({&rcpt-sale}) or ub.chk-doc.chk-type = integer({&rcpt-return})) and
                           (string(ub.chk-doc.d-card) begins "639300" or ub.chk-doc.d-card begins "275")
            :
                run chk-calc.
            end.
        end. /* else if x-TOG-Shift = no */
    end. /* for each obj-list */
end procedure. /* create-fill-tt-chk */

procedure chk-calc:
/*****************/
    find first tt-chk where
               /*tt-chk.doc-code      = ub.chk-doc.doc-code and*/
               tt-chk.obj-type      = ub.chk-doc.obj-type and
               tt-chk.obj-code      = ub.chk-doc.obj-code and
               tt-chk.chk-date      = ub.chk-doc.chk-date and
               tt-chk.shift-date    = ub.chk-doc.shift-date 
              
     no-error.



    if not available tt-chk then
    do:  /* if not available tt-chk */
        create tt-chk.
        assign
            tt-chk.doc-code     = ub.chk-doc.doc-code   /* My */
            tt-chk.obj-type     = ub.chk-doc.obj-type
            tt-chk.obj-code     = ub.chk-doc.obj-code   /* 1.1. Код объекта (часть поля) */
            /* tt-chk.chk-type     = ub.chk-doc.chk-type */
            tt-chk.obj-name_    = obj-list.obj-name     /* 1.2. Наименование объекта (часть поля) */
            tt-chk.shift-date   = ub.chk-doc.shift-date /* 2. Смена (дата) */
            tt-chk.chk-date     = ub.chk-doc.chk-date   /* 3. Дата (чека) */
            /* tt-chk.doc-qnty     = ub.chk-doc.doc-qnty */
            tt-chk.d-card       = ub.chk-doc.d-card
            /* tt-chk.sale-price_  = ub.chk-gds.price-base */
        .
/*/* Служебный */  create my-table.                                                         */
/*/* Служебный */ my-table.doc-code = string(ub.chk-doc.doc-code).                          */
/*/* Служебный */ my-table.list-doc-code = string(ub.chk-doc.doc-code).                     */
/*/* Служебный */ my-table.list-chk-date = string(ub.chk-doc.chk-date). /* chk-date */      */
/*/* Служебный */ my-table.list-shift-date = string(ub.chk-doc.shift-date). /* shift-date */*/
/*/* Служебный */ my-table.obj-type = string(ub.chk-doc.obj-type).                          */
/*/* Служебный */ my-table.obj-code = string(ub.chk-doc.obj-code).                          */
    end. /* if not available tt-chk */

    do:  /* Вычисления и запись данных в tt_chk по "Уровню Минимального Ункального Ключа Отчёта(УМУКО)". */

            v-ban-bonus = 0.
            v-bonus-malina = 0.

            v-sum_ = 0.
          
            v-sum-contribution_ = 0.
      
          

        /* Нач. Любая выборка в контексте УМУКО */
        /*A**************************************/
        do:  /* Пробежим по иниям оплаты товаров в Чеке (в ub.chk-gds-pay) и: 1) найдём товар с глобальным атрибутом «Запрет на участие в бонусных программах\участие в скидке на итог», сохраним его в v-ban-bonus; 2) найдём тип платежа: "Оплата баллами Малина", сохраним его в v-bonus-malina; чтобы по ТЗ исключить их ниже из суммы чека в этом отчёте */

                for each ub.chk-gds-pay no-lock where
                          ub.chk-gds-pay.doc-code = ub.chk-doc.doc-code  /* В этой Таблице отдельно doc-code не уникален! - есть строки с одинаковыми значениями tot-r-b и разными line-type и algo-num. Чтобы не задваивать суммы, я беру "FIND-FIRST ub.chk-gds-pay ... по doc-code и b-code" и вообще, надеясь что НЕТ РАЗНИЦЫ по какой строке в ub.chk-gds-pay делать выборку tot-r-b. Может быть это моё ошибочное мнение(ошибка?), но я надеюсь, что нет */                       
                          /* Отбросил эту вариацию, т.к. попались чеки, у которых данные условия не совпадали и было ещё одно состояние условия. Зачем вешать здесь кучу проверок, когда выше я просто выявил уник_b-code и иду по ним FIRST-ом.                   (ub.chk-gds-pay.line-type = {&gds-goods} or /* Смотрим линии Чека с типом "Товар" или с типом "Услуга" */*/
                          /*                     ub.chk-gds-pay.line-type = {&gds-office})                                                                */
                :
                    v-calc-ban-bonus = no. 
/*                    /* Служебный */ message "dbg-Оплата баллами Малина" skip                         */
/*                    /* Служебный */ "ub.chk-gds-pay.doc-code = " ub.chk-gds-pay.doc-code skip        */
/*                    /* Служебный */ "ub.cash-pay-attr.attr-code = " ub.cash-pay-attr.attr-code skip  */
/*                    /* Служебный */ "ub.cash-pay-attr.attr-value = " ub.cash-pay-attr.attr-value skip*/
/*                    /* Служебный */ "ub.chk-gds-pay.tot-r-b = " ub.chk-gds-pay.tot-r-b               */
/*                    /* Служебный */ view-as alert-box.                                               */
                    /* Нач. Найдём тип платежа: "Оплата баллами Малина". Хотел для нахождения этого типа платежа исп проц инклудника, но для этого не получилось выбрать curr-code, по этому делаю определение вручную :-( */

                    do v-iiii = 1 to num-entries(v-pay-codes-bonus-malina, ","):
                        if ub.chk-gds-pay.pay-code = integer(entry(v-iiii, v-pay-codes-bonus-malina, ",")) then
                        do:
                            v-bonus-malina = v-bonus-malina + ub.chk-gds-pay.tot-r-b.
                            v-calc-ban-bonus = yes. /* Признак учёта суммы "забаненных" товаров в переменной "оплата баллами Малина". Если Чек будет ОДНОВРЕМЕННО содержать два признака: и с оплатой баллами Малина (см. строку выше) и с аттрибутом товара "Запрет на участие в бонысных программах", то обе эти суммы учтём здесь, в "оплате баллами(бонусами) Малина" */
/*                                /* Служебный */ message "dbg-Оплата баллами Малина" skip                 */
/*                                /* Служебный */ "ub.chk-gds-pay.doc-code = " ub.chk-gds-pay.doc-code skip*/
/*                                /* Служебный */ "ub.cash-pay-attr.attr-code = " ub.cash-pay-attr.attr-code skip  */
/*                                /* Служебный */ "ub.cash-pay-attr.attr-value = " ub.cash-pay-attr.attr-value skip*/
/*                                /* Служебный */ "ub.chk-gds-pay.tot-r-b = " ub.chk-gds-pay.tot-r-b               */
/*                                /* Служебный */ view-as alert-box.*/
                        end.
                    end.

                    /* КНЦ. Найдём тип платежа: "Оплата баллами Малина". */

                    /* Нач. Найдём товар с глобальным атрибутом «Запрет на участие в бонусных программах\участие в скидке на итог». */
                    for first ub.bar-code where
                              ub.bar-code.b-code = ub.chk-gds-pay.b-code no-lock
                    :
                        /* Нач. Найдём товар с глобальным атрибутом «Запрет на участие в бонусных программах\участие в скидке на итог». */
                        if fnc-ban-bonus(ub.bar-code.gds-code /*ub.chk-gds-pay.b-code*/) = yes then
                        do:
                            if v-calc-ban-bonus = no then /* учтём товары с атрибутом «Запрет на участие в бонусных программах\участие в скидке на итог», только если они не учтены в проверке выше (см "Оплата баллами Малина") */
                            do:
                                v-ban-bonus = v-ban-bonus + ub.chk-gds-pay.tot-r-b. /* Служебный */ /*my-table.list-ban-bonus = my-table.list-ban-bonus + "; " + string(v-ban-bonus)*/.
                            end.
                        end.
                        /* v-ban-bonus учтён правильно и готовимся к следующей итерации по строкам продаж в чеке (ub.chk-gds-pay) */
/*/* Служебный */ my-table.list-ban-bonus = my-table.list-ban-bonus + "; " + string(v-ban-bonus).                                        */
/*/* Служебный */ my-table.list-chk-gds-pay = my-table.list-chk-gds-pay + "; " + string(ub.chk-gds-pay.doc-code).                        */
/*/* Служебный */ my-table.list-b-code = my-table.list-b-code + "; " + string(ub.chk-gds-pay.b-code).                                    */
/*/* Служебный */ my-table.list-sum-netto = my-table.list-sum-netto + "; " + string(ub.chk-doc.netto /*- v-ban-bonus - v-bonus-malina*/).*/
/*/* Служебный */ my-table.list-tot-r-b = my-table.list-tot-r-b + "; " + string(ub.chk-gds-pay.tot-r-b).                                 */
/*/* Служебный */ my-table.list-bonus-malina = my-table.list-bonus-malina + "; " + string(v-bonus-malina).                               */
                        /* КНЦ. Найдём товар с глобальным атрибутом «Запрет на участие в бонусных программах\участие в скидке на итог». */

                    end. /* for first ub.bar-code */
                    /* КНЦ. Найдём товар с глобальным атрибутом «Запрет на участие в бонусных программах\участие в скидке на итог». */

                end. /* for each ub.chk-gds-pay */
/*/* Служебный */ v-ban-bonus = 0.   */
/*/* Служебный */ v-bonus-malina = 0.*/
          
        end. /* tt-chk.sum-gds-ban-bonus_ = ... */
        /*A***************************************/
        /* КНЦ. Любая выборка в контексте УМУКО */

/*/* Служебный */ my-table.list-ban-bonus = my-table.list-ban-bonus + "; " + string(v-ban-bonus).*/
/*/* Служебный */ my-table.list-chk-gds-pay = my-table.list-chk-gds-pay + "; " + string(ub.chk-gds-pay.doc-code).                        */
/*/* Служебный */ my-table.list-b-code = my-table.list-b-code + "; " + string(ub.chk-gds-pay.b-code).                                    */
/*/* Служебный */ my-table.list-sum-netto = my-table.list-sum-netto + "; " + string(ub.chk-doc.netto /*- v-ban-bonus - v-bonus-malina*/).*/
/*/* Служебный */ my-table.list-tot-r-b = my-table.list-tot-r-b + "; " + string(ub.chk-gds-pay.tot-r-b).                                 */
/*/* Служебный */ my-table.list-bonus-malina = my-table.list-bonus-malina + "; " + string(v-bonus-malina).                               */

        /* Любые вычисления по УМУКО */
        /*B***************************************/
        tt-chk.sum-netto = tt-chk.sum-netto + ub.chk-doc.netto.                 /* Служебная Контрольная сумма sum-netto по УМУКО */
/*/* Служебный */ my-table.sum-netto = string(tt-chk.sum-netto).*/
/*/* Служебный */ my-table.sum-netto =  my-table.sum-netto + "; " + string(ub.chk-doc.netto).*/
        tt-chk.sum-gds-ban-bonus_ = tt-chk.sum-gds-ban-bonus_ + v-ban-bonus.    /* Служебная Контрольная сумма sum-gds-ban-bonus_ по УМУКО */
/*/* Служебный */ my-table.sum-gds-ban-bonus_ = string(tt-chk.sum-gds-ban-bonus_).*/
/*/* Служебный */ my-table.sum-gds-ban-bonus_ = my-table.sum-gds-ban-bonus_ + "; " + string(v-ban-bonus).*/
        v-sum_ = ub.chk-doc.netto - v-ban-bonus - v-bonus-malina.               /* Сумма по УМУКО согласно ТЗ. Частица для п.4 */
        tt-chk.sum_ = tt-chk.sum_ + v-sum_.                                     /* Отчёт п.4 Сумма Чека (сумма чеков, как итога по одному УМУКО). */
/*/* Служебный */ my-table.list-v-sum_ = my-table.list-v-sum_ + "; " + string(ub.chk-doc.netto) + "--" + string(v-ban-bonus) + "--" + string(v-bonus-malina).*/
/*/* Служебный */ my-table.sum_ = string(tt-chk.sum_).*/
/*/* Служебный */ my-table.list-sum_ = my-table.list-sum_ + "; " + string(v-sum_).*/
        v-sum-contribution_ = round(((v-sum_) * 0.01), 2).                      /* "Сумма отчислений" по УМУКО согласно ТЗ. Частица для п.4 */
        tt-chk.sum-contribution_ = tt-chk.sum-contribution_ + v-sum-contribution_. /* Служебная Контрольная сумма sum-contribution_ по УМУКО */
/*/* Служебный */ my-table.sum-contribution_ = string(round(tt-chk.sum-contribution_, 2)).*/
/*/* Служебный */ my-table.sum-contribution_ = my-table.sum-contribution_ + "; " + string(round(((v-sum_) * 0.01), 2)).*/
        tt-chk.sum-bonus-malina_ = tt-chk.sum-bonus-malina_ + v-bonus-malina.   /* Служебная Контрольная сумма sum-bonus-malina_ по УМУКО */
/*/* Служебный */ my-table.sum-bonus-malina_ = string(tt-chk.sum-bonus-malina_).*/

        /*B***************************************/
    end. /* Вычисления и запись данных в tt_chk по "Уровню Минимального Ункального Ключа Отчёта(УМУКО)". */

    /* Итоги по Объекту */
    /*C***************************************/
    find first buf1_tt-chk where
           buf1_tt-chk.obj-type      = ub.chk-doc.obj-type and
           buf1_tt-chk.obj-code      = ub.chk-doc.obj-code and
           buf1_tt-chk.note_         = "sum-object"
    no-lock no-error.

   

    if not available buf1_tt-chk then
    do:
        create buf1_tt-chk.
        buf1_tt-chk.obj-type      = ub.chk-doc.obj-type.
        buf1_tt-chk.obj-code      = ub.chk-doc.obj-code.
        buf1_tt-chk.obj-name_     = obj-list.obj-name.
        buf1_tt-chk.note_         = "sum-object".
/*/* Служебный */ create my-table2.                                */
/*/* Служебный */ my-table2.obj-type = ub.chk-doc.obj-type.        */
/*/* Служебный */ my-table2.obj-code = string(ub.chk-doc.obj-code).*/
    end.

   
        buf1_tt-chk.sum_ = buf1_tt-chk.sum_ + v-sum_.
        buf1_tt-chk.sum-contribution_ = buf1_tt-chk.sum-contribution_ + v-sum-contribution_.
/*/* Служебный */ my-table2.sum_ = my-table2.sum_ + "+" + string(ub.chk-doc.netto - v-ban-bonus).*/
/*/* Служебный */ my-table2.sum_ = string(decimal(my-table2.sum_) + (ub.chk-doc.netto - v-ban-bonus)).*/
    /*C***************************************/

    /* Итоги по Отчёту */
    /*D***************************************/
    find first buf2_tt-chk where
        buf2_tt-chk.note_ = "sum-report"
    no-lock no-error.
    if not available buf2_tt-chk then
    do:  /* if not available buf2_tt-chk */
        create buf2_tt-chk.
        buf2_tt-chk.obj-type = ub.chk-doc.obj-type.
        buf2_tt-chk.obj-code = ub.chk-doc.obj-code.
        buf2_tt-chk.obj-name_ = obj-list.obj-name.
        buf2_tt-chk.note_ = "sum-report".
    end. /* if not available buf2_tt-chk */
        buf2_tt-chk.sum_ = buf2_tt-chk.sum_ + v-sum_.
        buf2_tt-chk.sum-contribution_ = buf2_tt-chk.sum-contribution_ + v-sum-contribution_.
    /*D***************************************/

/*        v-ban-bonus = 0.   */
/*        v-bonus-malina = 0.*/
/*        v-sum_ = 0.        */

end procedure.

procedure proc-create-HTML:         /* Запись даннах в файл отчёта HTML (на HDD) */
/* Вывод отчёта в файл html и через ReportView в Excel */

    define input parameter p-file-name-rep-htm as character no-undo.
    define input parameter p-report-name as character no-undo.
    define input parameter p-period as character no-undo.
    define input parameter p-short-obj-list as character no-undo.

    define variable v-message as character no-undo. 

    define buffer buf-html_clients for ub.clients.

    /* Системная шапка HTML */
    do:  /* Системная шапка HTML */
        output stream OutStr-html to value(p-file-name-rep-htm) append convert target 'UTF-8'.
            put stream OutStr-html unformatted
                "<!DOCTYPE HTML>" skip
                ' <html>' skip
                '  <head>' skip
                '   <meta charset="utf-8">' skip
                '    <style type="text/css">' skip
                '      table ' + chr(123) + ' border-collapse: collapse; font-size: 9pt; table-layout: fixed; width: 1157px; padding: 14px; ' + chr(125) skip
                '      td ' + chr(123) ' border: 1px black ridge; word-wrap:break-word; ' + chr(125) skip
                '      htm' skip
                '      .rotate ' + chr(123) skip
                '        -webkit-transform: rotate(-90deg);' skip
                '        -moz-transform: rotate(-90deg);' skip
                '        -ms-transform: rotate(-90deg);' skip
                '        -o-transform: rotate(-90deg);' skip
                '        transform: rotate(-90deg);' skip

                /* also accepts left, right, top, bottom coordinates; not required, but a good idea for styling */
                '        -webkit-transform-origin: 50% 50%;' skip
                '        -moz-transform-origin: 50% 50%;' skip
                '        -ms-transform-origin: 50% 50%;' skip
                '        -o-transform-origin: 50% 50%;' skip
                '        transform-origin: 50% 50%;' skip

                /* Should be unset in IE9+ I think.*/
                '        filter: progid:DXImageTransform.Microsoft.BasicImage(rotation=3);' skip
                '          ' + chr(125) skip
                '            th' + ' ' + chr(123) skip
                '            border: 1px black solid;' skip
                '            word-wrap: break-word;' skip
                '          ' + chr(125) skip
                '   </style>' skip
                '  </head>' skip
            . /* Точка для закрытия Put */
    end. /* Системная шапка HTML */

    /* Установка системных параметров "глобальной" таблицы всего отчёта (кол-во и размерность колонок) */
    do:  /* Параметры "глобальной" таблицы отчёта */
            put stream OutStr-html unformatted
                ' <body>' skip
                '   <table name="Лист1" outline_below="false">' skip
                '     <thead>' skip
                '       <tr class="set_columns">' skip                          /* Ниже - условная привязка-ориентир к разграфлённой таблице!!! */
                '         <td style="width: 220px; border: none;"></td>' skip   /* 1. Станция */
                '         <td style="width: 68px; border: none;"></td>' skip    /* 2. Смена (Дата) */
                '         <td style="width: 68px; border: none;"></td>' skip    /* 3. Дата (Чека) */
                '         <td style="width: 80px; border: none;"></td>' skip    /* 4. Сумма чека */
                '         <td style="width: 80px; border: none;"></td>' skip    /* 5. Сумма отчислений (гр.4*1%) */
                '       </tr>' skip
            .
    end. /* Параметры "глобальной" таблицы отчёта */

    /* Заполнение "глобальной" таблицы - блок шапки отчёта (часть отчёта, видимая как "не таблица") */
    do:  /* Шапка отчёта (видимого, как не таблица) */
            put stream OutStr-html unformatted
                '       <tr>' skip /* Строчный пункт-1. Пустая строка */
                '         <td style="border: none; height: 14px"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '       </tr>' skip
                '       <tr>' skip /* Строчный пункт-2. Наименование отчёта */
                '         <td colspan="5" style="border: none; height: 14px; font-weight: bold; text-align: center">' + p-report-name + '</td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '       </tr>' skip
                '       <tr>' skip /* Строчный пункт-3. Период */
                '         <td colspan="5" style="border: none; height: 14px; font-weight: bold; text-align: center">' + p-period + '</td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '       </tr>' skip
                '       <tr>' skip /* Строчный пункт-4. Пустая строка */
                '         <td style="border: none; height: 14px; font-weight: bold"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '       </tr>' skip
            .

            /* Вывод сокращённого списка Объектов "в одну строку" */
/*            put stream OutStr-html unformatted                                                                  */
/*                '       <tr>' skip /* Строчный пункт-5. По объектам */                                          */
/*                '         <td colspan="5" style="border: none; height: 14px">' + p-short-obj-list + '</td>' skip*/
/*                '         <td style="border: none"></td>' skip                                                  */
/*                '         <td style="border: none"></td>' skip                                                  */
/*                '         <td style="border: none"></td>' skip                                                  */
/*                '         <td style="border: none"></td>' skip                                                  */
/*                '       </tr>' skip                                                                             */
/*            .                                                                                                   */
/*                                                                                                                */
/*            put stream OutStr-html unformatted                                                                  */
/*                '       <tr>' skip /* Строчный пункт-7. Пустая строка */                                        */
/*                '         <td style="border: none; height: 14px"></td>' skip                                    */
/*                '         <td style="border: none"></td>' skip                                                  */
/*                '         <td style="border: none"></td>' skip                                                  */
/*                '         <td style="border: none"></td>' skip                                                  */
/*                '         <td style="border: none"></td>' skip                                                  */
/*                '       </tr>' skip                                                                             */
/*            .                                                                                                   */
    end. /* Шапка отчёта (видимого, как не таблица) */

    /* Заполнение "глобальной" таблицы - блок Шапки таблицы отчёта (часть отчёта, видимая как "шапка таблицы") */
    do:  /* Шапка таблицы отчёта (видимой, как таблица) */
            put stream OutStr-html unformatted
                '     <tbody>' skip
                '       <tr>' skip
                '         <th style="text-align: center; height: 30px">Станция</th>' skip
                '         <th style="text-align: center;">Смена (дата)</th>' skip
                '         <th style="text-align: center;">Дата (чека)</th>' skip
                '         <th style="text-align: center;">Сумма чека</th>' skip
                '         <th style="text-align: center;">Сумма отчислений (гр.4*1%)</th>' skip
                '       </tr>' skip
                '       <tr>' skip
                '         <th num="" style="text-align: center">1</th>' skip
                '         <th num="" style="text-align: center">2</th>' skip
                '         <th num="" style="text-align: center">3</th>' skip
                '         <th num="" style="text-align: center">4</th>' skip
                '         <th num="" style="text-align: center">5</th>' skip
                '       </tr>' skip
            . /* Точка для закрытия Put */
/*            run tt-print-line (input buf2_tt-line.obj-type, input buf2_tt-line.obj-code, input 1, input 2). /* Доформирование групп */*/
        output stream OutStr-html close.
    end. /* Шапка таблицы отчёта (видимой, как таблица) */

    /* Заполнение ТЕЛА таблицы отчёта */
    do:  /* Заполнение тела таблицы отчёта */
        output stream OutStr-html to value(p-file-name-rep-htm) append convert target 'UTF-8'.
        for first tt-chk where
                 tt-chk.note_ = "sum-report"
        no-lock:
            do:  /* Вывод подзаголовка(жирным шрифтом) строки по Отчёту (все Объекты) */
                put stream OutStr-html unformatted
                    '       <tr level="1">' skip
                    '         <td style="display: yes; text-align: left; height: 20px; font-weight: bold; padding-left: 0px">' +
                                "Итого по всем Объектам:" + '</td>' skip
                    '         <td style="display: yes; text-align: center; font-weight: bold">' +
                                if tt-chk.shift-date <> ? then fnc-DD-MM-YYYY(tt-chk.shift-date) + '</td>' else "" + '</td>' skip
                    '         <td style="display: yes; text-align: center; font-weight: bold">' +
                                if tt-chk.chk-date <> ? then fnc-DD-MM-YYYY(tt-chk.chk-date) + '</td>' else "" + '</td>' skip
                    '         <td num="0.00" style="display: yes; text-align: right; font-weight: bold" val="' + string(tt-chk.sum_) + '"' + '>' +
                                fnc-convert-dot-to-colon(tt-chk.sum_, v-accur-13) + '</td>' skip
                    '         <td num="0.00" style="display: yes; text-align: right; font-weight: bold" val="' + string(tt-chk.sum-contribution_) + '"' + '>' +
                                fnc-convert-dot-to-colon(tt-chk.sum-contribution_, v-accur-13) + '</td>' skip
                    '       </tr>' skip
                .
            end. /* Вывод подзаголовка(жирным шрифтом) строки по Отчёту (все Объекты) */

            for each buf1_tt-chk no-lock where
                     buf1_tt-chk.note_ = "sum-object"
                by buf1_tt-chk.obj-code
            :
                do:  /* Вывод подзаголовка(жирным шрифтом) строки "по Объекту" */
                    put stream OutStr-html unformatted
                        '       <tr level="2">' skip
                        '         <td style="display: yes; text-align: left; height: 20px; font-weight: bold; padding-left: 10px">' +
                                    "Итого по Объекту:" + string(buf1_tt-chk.obj-code) + " " + buf1_tt-chk.obj-name_  + '</td>' skip
                        '         <td style="display: yes; text-align: center; font-weight: bold">' +
                                    if buf1_tt-chk.shift-date <> ? then fnc-DD-MM-YYYY(buf1_tt-chk.shift-date) + '</td>' else "" + '</td>' skip
                        '         <td style="display: yes; text-align: center; font-weight: bold">' +
                                    if buf1_tt-chk.chk-date <> ? then fnc-DD-MM-YYYY(buf1_tt-chk.chk-date) + '</td>' else "" + '</td>' skip
                        '         <td num="0.00" style="display: yes; text-align: right; font-weight: bold" val="' + string(buf1_tt-chk.sum_) + '"' + '>' +
                                    fnc-convert-dot-to-colon(buf1_tt-chk.sum_, v-accur-13) + '</td>' skip
                        '         <td num="0.00" style="display: yes; text-align: right; font-weight: bold" val="' + string(buf1_tt-chk.sum-contribution_) + '"' + '>' +
                                    fnc-convert-dot-to-colon(buf1_tt-chk.sum-contribution_, v-accur-13) + '</td>' skip
                        '       </tr>' skip
                    .
                end. /* Вывод подзаголовка(жирным шрифтом) строки "по Объекту" */

                for each buf2_tt-chk no-lock where
                         buf2_tt-chk.obj-type = buf1_tt-chk.obj-type and
                         buf2_tt-chk.obj-code = buf1_tt-chk.obj-code and
                         buf2_tt-chk.note_ <> "sum-report" and
                         buf2_tt-chk.note_ <> "sum-object"
                    by buf2_tt-chk.obj-type
                    by buf2_tt-chk.obj-code
                    by buf2_tt-chk.shift-date
                    by buf2_tt-chk.chk-date
                :
                    do:  /* Вывод элементарных линий - содержание "по Объекту" */
                        put stream OutStr-html unformatted
                            '       <tr level="3">' skip
                            '         <td style="display: none; text-align: left; height: 20px; font-weight: normal; padding-left: 20px">' +
                                        string(buf2_tt-chk.obj-code) + " " + buf2_tt-chk.obj-name_ + '</td>' skip
                            '         <td style="display: none; text-align: center; font-weight: normal">' +
                                        if buf2_tt-chk.shift-date <> ? then fnc-DD-MM-YYYY(buf2_tt-chk.shift-date) + '</td>' else "?" + '</td>' skip
                            '         <td style="display: none; text-align: center; font-weight: normal">' +
                                        if buf2_tt-chk.chk-date <> ? then fnc-DD-MM-YYYY(buf2_tt-chk.chk-date) + '</td>' else "?" + '</td>' skip
                            '         <td num="0.00" style="display: none; text-align: right; font-weight: normal" val="' + string(buf2_tt-chk.sum_) + '"' + '>' + 
                                        fnc-convert-dot-to-colon(buf2_tt-chk.sum_, v-accur-13) + '</td>' skip
                            '         <td num="0.00" style="display: none; text-align: right; font-weight: normal" val="' + string(buf2_tt-chk.sum-contribution_) + '"' + '>' +
                                        fnc-convert-dot-to-colon(buf2_tt-chk.sum-contribution_, v-accur-13) + '</td>' skip
                            '       </tr>' skip
                        .
                    end. /* Вывод элементарных линий - содержание "по Объекту" */
                end.
            end.
        end.

    end. /* Заполнение тела таблицы отчёта */

    /* Заполнение подвала отчёта */
    do:  /* b6 */
                put stream OutStr-html unformatted
                '     </tbody>' skip
                '   </table>' skip
                '  </body>' skip
                ' </html>' skip
                . /* Точка для закрытия Put */
        output stream OutStr-html close.
    end. /* b6 */
end procedure.

procedure get-full-path-RepViewer:  /* Получение полного пути к исполняемому файлу RV.exe (output Полный_путь_имя_файла_RV.exe) */
/* Получение полного пути к exe-файлу просмотровщика отчётов */
    define output parameter p-fill-path-RepView as character no-undo.

    if search("exe\ReportViewer\reportviewer.exe") <> ? then
    do:
        p-fill-path-RepView = search("exe\ReportViewer\reportviewer.exe").
    end.
    else
    do:
        message "Не найдена программа просмотра отчёта!" view-as alert-box error.
    end.
end procedure.

procedure define-full-path-Report:  /* Получение полного пути к отчёту html (input №Отчёта, output Полный_путь_имя_файла_отчHTML) */
/* Получение полного пути к отчёту html */
    define input parameter p-rep-num as integer no-undo.
    define output parameter p-file-name-rep-htm as character no-undo.

    p-file-name-rep-htm = session:temp-directory + {&DF_Name} + string(p-rep-num) + ".html".

end procedure.

procedure search-full-path-Report:  /* Только проверка, есть файл отчёта HTML или нет(тогда вывод сбщ-ош) */
/* Поиск файла */
    define input parameter p-file-name as character no-undo.

    if search(p-file-name) = ? then
        do:
            message "Не найден файл отчёта: " p-file-name view-as alert-box error.
        end.
    else
        do:
            p-file-name = search(p-file-name).
        end.

end procedure.

procedure Report-Viewer:            /* Запуск на выполнение RV (input Полный_путь_имя_файла_RV, input Полный_путь_имя_файла_отчHTML) */
/* Запуск программы "Просмотровщик Отчётов" - ReportViewer. */
    define input parameter p-full-path-RepView as character no-undo.
    define input parameter p-file-name-rep-htm as character no-undo.

    os-command no-wait value(p-full-path-RepView + " true " + search(p-file-name-rep-htm)).

end procedure.

procedure create-file:              /* СоздЛюбогоФайлаНаДиске(input полный_путь_с_именем) */
/* Создание пустого файла (во входном параметре: полный путь и имя файла) */
    define input parameter p-file-name as character no-undo.
    output to value(string(p-file-name)).
    output close.

end procedure.

procedure get-pay-codes-bonus-malina:   /* Получаем все типы оплаты, которым пользователь присвоил атрибут "Оплата баллами Малина" (в переменную). */
define buffer buf_cash-pay-attr for ub.cash-pay-attr.
define buffer buf_chk-gds for ub.chk-gds.

    for each buf_cash-pay-attr no-lock where
/*             buf_cash-pay-attr.cdpay-code   = ub.chk-gds-pay.pay-code and*/
             buf_cash-pay-attr.attr-code    = {&cp-attr-bal_malina} and
             buf_cash-pay-attr.attr-value   = "yes"
    :
        v-pay-codes-bonus-malina = (if v-pay-codes-bonus-malina = "" then v-pay-codes-bonus-malina else v-pay-codes-bonus-malina + ",") + string(buf_cash-pay-attr.cdpay-code).
    end.
end procedure.

procedure my-watch-table:           /* Процедура для моей ОТЛАДКИ! Арн. */
/* Запись наблюдаемых таблиц в файл */
/*&scope tt-table dcards*/
/*&scope tt-table obj-list*/
&scope tt-table tt-chk
/*&scope tt-table X_dis-card*/
/*    define input parameter p-str1 as character no-undo.*/
/*    define input parameter p-table-name as character no-undo.*/

    define variable v-full-file-name as character no-undo.
    define variable v-message as character no-undo.
    define variable v-table-handle as handle no-undo.
    define variable v-cnt-field as integer no-undo.
    define variable v-list-field-name as character no-undo.
    define variable v-list-field-label as character no-undo.
    define variable v-list-field-type as character no-undo.
    define variable v-ii as integer no-undo.

    define buffer {&tt-table} for {&tt-table}.
/*    define buffer buf5_dcards for {&tt-table}.*/
/*    define variable tt-handle as handle no-undo.*/

    /* Получаем:
       спискок полей таблицы - name;
       спискок полей таблицы - label;
       спискок типов полей таблицы - type. */
    v-table-handle = buffer {&tt-table}:handle.
    v-cnt-field = v-table-handle:num-fields.
    do v-ii = 1 to v-cnt-field:
        v-list-field-name =
            (if v-list-field-name <> "" then
               v-list-field-name + "$" + v-table-handle:buffer-field(v-ii):name
            else
                v-table-handle:buffer-field(v-ii):name).
        v-list-field-label =
            (if v-list-field-label <> "" then
               v-list-field-label + "$" + v-table-handle:buffer-field(v-ii):label
            else
                v-table-handle:buffer-field(v-ii):label).
        v-list-field-type =
            (if v-list-field-type <> "" then
               v-list-field-type + "$" + v-table-handle:buffer-field(v-ii):data-type
            else
                v-table-handle:buffer-field(v-ii):data-type).
    end.

/*    tt-handle:name = p-table-name.*/
/*    tt-handle = handle(p-table-name).*/
/*    tt-handle = handle(p-table-name).*/
/*    tt-handle = buffer dc-list:handle.*/
/*    tt-handle = buf_tt.a:get-buffer-handle(p-table-name).*/
/*    tt-handle = tt-handle:get-buffer-handle(p-table-name):handle.*/
/*    tt-handle = tt-handle:get-buffer-handle(p-table-name).*/
/*    tt-table = dc-list:get-buffer-handle(p-table-name).*/
/*    tt-handle = buffer tt-table:handle.*/
/*{ Zadachi+Test_Arn/my-include-001.i point-A p-table-name }*/

    /* Задаём жёстко имя файла и полный путь */
    v-full-file-name = "C:\work15_0\my-watch-table.txt".

    if search(v-full-file-name) = ? then
        do:
            message "Не найден файл отчёта: " v-full-file-name view-as alert-box error.
        end.

    /* Сохранение потока в созданный файл my-watch-table.txt */
    output stream MyWatch-strm to value(v-full-file-name) /*append*/ /*no-convert*/ convert target "utf-8".
        put stream MyWatch-strm unformatted
            today format "99.99.9999" " " string(time, "HH:MM") " " "Исследуемая таблица: " "{&tt-table}" "." skip /* Для вывода текста, отдельных слов - только пробел, не ставить "+" */
            v-list-field-label skip
            v-list-field-name skip
            v-list-field-type skip
        .
        if not can-find(first {&tt-table}) then
        do:
            v-message = "Исследуемая таблица {&tt-table} пуста!".
            put stream MyWatch-strm unformatted
                v-message
            .
            message "My-watch-table: " v-message view-as alert-box information.
        end.

            for each /*buf5_dcards*/ {&tt-table} no-lock:
                export stream MyWatch-strm delimiter "$" /*buf5_dcards*/ {&tt-table}. /* Вставляем сюда вручную свою таблицу!!! */
            end.
    output stream MyWatch-strm close.
end procedure.

procedure my-watch-table2:           /* Процедура для моей ОТЛАДКИ! Арн. */
/* Запись наблюдаемых таблиц в файл */
/*&scope tt-table dcards*/
/*&scope tt-table obj-list*/
/*&scope tt-table tt-chk*/
&scope tt-table my-table
/*&scope tt-table X_dis-card*/
/*    define input parameter p-str1 as character no-undo.*/
/*    define input parameter p-table-name as character no-undo.*/

    define variable v-full-file-name as character no-undo.
    define variable v-message as character no-undo.
    define variable v-table-handle as handle no-undo.
    define variable v-cnt-field as integer no-undo.
    define variable v-list-field-name as character no-undo.
    define variable v-list-field-label as character no-undo.
    define variable v-list-field-type as character no-undo.
    define variable v-ii as integer no-undo.

    define buffer {&tt-table} for {&tt-table}.
/*    define buffer buf5_dcards for {&tt-table}.*/
/*    define variable tt-handle as handle no-undo.*/

    /* Получаем:
       спискок полей таблицы - name;
       спискок полей таблицы - label;
       спискок типов полей таблицы - type. */
    v-table-handle = buffer {&tt-table}:handle.
    v-cnt-field = v-table-handle:num-fields.
    do v-ii = 1 to v-cnt-field:
        v-list-field-name =
            (if v-list-field-name <> "" then
               v-list-field-name + "$" + v-table-handle:buffer-field(v-ii):name
            else
                v-table-handle:buffer-field(v-ii):name).
        v-list-field-label =
            (if v-list-field-label <> "" then
               v-list-field-label + "$" + v-table-handle:buffer-field(v-ii):label
            else
                v-table-handle:buffer-field(v-ii):label).
        v-list-field-type =
            (if v-list-field-type <> "" then
               v-list-field-type + "$" + v-table-handle:buffer-field(v-ii):data-type
            else
                v-table-handle:buffer-field(v-ii):data-type).
    end.

/*    tt-handle:name = p-table-name.*/
/*    tt-handle = handle(p-table-name).*/
/*    tt-handle = handle(p-table-name).*/
/*    tt-handle = buffer dc-list:handle.*/
/*    tt-handle = buf_tt.a:get-buffer-handle(p-table-name).*/
/*    tt-handle = tt-handle:get-buffer-handle(p-table-name):handle.*/
/*    tt-handle = tt-handle:get-buffer-handle(p-table-name).*/
/*    tt-table = dc-list:get-buffer-handle(p-table-name).*/
/*    tt-handle = buffer tt-table:handle.*/
/*{ Zadachi+Test_Arn/my-include-001.i point-A p-table-name }*/

    /* Задаём жёстко имя файла и полный путь */
    v-full-file-name = "C:\work15_0\my-watch-table2.txt".

    if search(v-full-file-name) = ? then
        do:
            message "Не найден файл отчёта: " v-full-file-name view-as alert-box error.
        end.

    /* Сохранение потока в созданный файл my-watch-table.txt */
    output stream MyWatch-strm to value(v-full-file-name) /*append*/ /*no-convert*/ convert target "utf-8".
        put stream MyWatch-strm unformatted
            today format "99.99.9999" " " string(time, "HH:MM") " " "Исследуемая таблица: " "{&tt-table}" "." skip /* Для вывода текста, отдельных слов - только пробел, не ставить "+" */
            v-list-field-label skip
            v-list-field-name skip
            v-list-field-type skip
        .
        if not can-find(first {&tt-table}) then
        do:
            v-message = "Исследуемая таблица {&tt-table} пуста!".
            put stream MyWatch-strm unformatted
                v-message
            .
            message "My-watch-table: " v-message view-as alert-box information.
        end.

            for each /*buf5_dcards*/ {&tt-table} no-lock:
                export stream MyWatch-strm delimiter "$" /*buf5_dcards*/ {&tt-table}. /* Вставляем сюда вручную свою таблицу!!! */
            end.
    output stream MyWatch-strm close.
end procedure.

procedure my-watch-table3:           /* Процедура для моей ОТЛАДКИ! Арн. */
/* Запись наблюдаемых таблиц в файл */
/*&scope tt-table dcards*/
/*&scope tt-table obj-list*/
/*&scope tt-table tt-chk*/
&scope tt-table my-table2
/*&scope tt-table X_dis-card*/
/*    define input parameter p-str1 as character no-undo.*/
/*    define input parameter p-table-name as character no-undo.*/

    define variable v-full-file-name as character no-undo.
    define variable v-message as character no-undo.
    define variable v-table-handle as handle no-undo.
    define variable v-cnt-field as integer no-undo.
    define variable v-list-field-name as character no-undo.
    define variable v-list-field-label as character no-undo.
    define variable v-list-field-type as character no-undo.
    define variable v-ii as integer no-undo.

    define buffer {&tt-table} for {&tt-table}.
/*    define buffer buf5_dcards for {&tt-table}.*/
/*    define variable tt-handle as handle no-undo.*/

    /* Получаем:
       спискок полей таблицы - name;
       спискок полей таблицы - label;
       спискок типов полей таблицы - type. */
    v-table-handle = buffer {&tt-table}:handle.
    v-cnt-field = v-table-handle:num-fields.
    do v-ii = 1 to v-cnt-field:
        v-list-field-name =
            (if v-list-field-name <> "" then
               v-list-field-name + "$" + v-table-handle:buffer-field(v-ii):name
            else
                v-table-handle:buffer-field(v-ii):name).
        v-list-field-label =
            (if v-list-field-label <> "" then
               v-list-field-label + "$" + v-table-handle:buffer-field(v-ii):label
            else
                v-table-handle:buffer-field(v-ii):label).
        v-list-field-type =
            (if v-list-field-type <> "" then
               v-list-field-type + "$" + v-table-handle:buffer-field(v-ii):data-type
            else
                v-table-handle:buffer-field(v-ii):data-type).
    end.

/*    tt-handle:name = p-table-name.*/
/*    tt-handle = handle(p-table-name).*/
/*    tt-handle = handle(p-table-name).*/
/*    tt-handle = buffer dc-list:handle.*/
/*    tt-handle = buf_tt.a:get-buffer-handle(p-table-name).*/
/*    tt-handle = tt-handle:get-buffer-handle(p-table-name):handle.*/
/*    tt-handle = tt-handle:get-buffer-handle(p-table-name).*/
/*    tt-table = dc-list:get-buffer-handle(p-table-name).*/
/*    tt-handle = buffer tt-table:handle.*/
/*{ Zadachi+Test_Arn/my-include-001.i point-A p-table-name }*/

    /* Задаём жёстко имя файла и полный путь */
    v-full-file-name = "C:\work15_0\my-watch-table2a.txt".

    if search(v-full-file-name) = ? then
        do:
            message "Не найден файл отчёта: " v-full-file-name view-as alert-box error.
        end.

    /* Сохранение потока в созданный файл my-watch-table.txt */
    output stream MyWatch-strm to value(v-full-file-name) /*append*/ /*no-convert*/ convert target "utf-8".
        put stream MyWatch-strm unformatted
            today format "99.99.9999" " " string(time, "HH:MM") " " "Исследуемая таблица: " "{&tt-table}" "." skip /* Для вывода текста, отдельных слов - только пробел, не ставить "+" */
            v-list-field-label skip
            v-list-field-name skip
            v-list-field-type skip
        .
        if not can-find(first {&tt-table}) then
        do:
            v-message = "Исследуемая таблица {&tt-table} пуста!".
            put stream MyWatch-strm unformatted
                v-message
            .
            message "My-watch-table: " v-message view-as alert-box information.
        end.

            for each /*buf5_dcards*/ {&tt-table} no-lock:
                export stream MyWatch-strm delimiter "$" /*buf5_dcards*/ {&tt-table}. /* Вставляем сюда вручную свою таблицу!!! */
            end.
    output stream MyWatch-strm close.
end procedure.

function fnc-ban-bonus returns logical /* "Запрет на участие товара в бонусных программах" = yes/no (input gds-code) */
(input p-gds-code as integer):
/* Возвращает значение "Запрет на участие товара в бонусных программах" = yes/no */

    define variable result as logical no-undo.
    define variable v-ban-bonus as logical no-undo.
    define variable v-attr-value as character no-undo.
    define variable v-attr-type as character no-undo.

    run gds-attr-value (input p-gds-code, /*in this-procedure*/ /* ub.goods-attr.gds-code */
                        input  {&attr-ban-bonus},
                        output v-attr-value,
                        output v-attr-type).

    return logical(v-attr-value).

end function.

function fnc-DD-MM-YYYY returns character 
(input p-dat-date as date):
/* Преобразование даты в формат: "01.01.2014" */

    define variable result as character no-undo.
    define variable p-str-date as character no-undo.

    p-str-date = replace(string(p-dat-date,'99.99.9999'), "/", ".").

        return p-str-date.

end function.

function fnc-convert-dot-to-colon returns character 
(input p-data as decimal, input p-accur as character):
/* Конвертация десятичной точки в запятую с передачей параметра форматирования числа (accuracy - выводим разряды после запятой). */
/* Возвращает: а)число с запятой, б)ноль, в)вопрос, в зависимости от того, что содержится во входном decimal. */

    define variable result as character no-undo.
    define variable v-str-result as character no-undo.
/*message "dbg-p-data = " p-data skip "p-accur = " p-accur view-as alert-box.*/
    if p-data = ? then
    do:
        v-str-result = "?".
    end.
    else
    do:
        p-data = round(p-data, 2). /* Чтобы не выйти случайно за рамки формата числа при выводе (несоотвесвие формата результата и формата отображения - приводит к ош) */
        v-str-result = trim(replace(string(p-data, p-accur), ".", ",")).
    end.

    return v-str-result.

end function.

function last-of-condition returns logical
(/*input doc-code   as character,*/
 input obj-type   as character,
 input obj-code   as integer,
 input chk-date   as date,
 input shift-date as date):

    define variable v-log-result as logical no-undo.

    if /*doc-code = "" and*/
       v-obj-type1 = "" and /* Что соответствует первому старту */
       v-obj-code1 = 0 and
       v-chk-date1 = ? and
       v-shift-date1 = ? then
    do:  /* Только для первого вхождения в функцию */
        v-log-result = no.  /* Перехода на новое условие нет (входные данные - первые поступившие в функцию (запомненного предыдущего состоянию нет и сравнивать не с чем) */
    end. /* Только для первого вхождения в функцию */
    else
    do:  /* Цикл очередной проверки на ИЗМЕНЕНИЕ к новому УСЛОВИЮ(набору вход. данных) */
        if /*doc-code = v-doc-code1 and*/
           obj-type = v-obj-type1 and
           obj-code = v-obj-code1 and
           chk-date = v-chk-date1 and
           shift-date = v-shift-date1 then
        do:
            v-log-result = no.  /* Перехода на новое условие нет (входные данные = запомненному предыдущему состоянию) */
        end.
        else
        do:
            v-log-result = yes.  /* Перехода на новое условие нет (входные данные = запомненному предыдущему состоянию) */
        end.
    end. /* Цикл очередной проверки на ИЗМЕНЕНИЕ к новому УСЛОВИЮ(набору вход. данных) */

    /*v-doc-code1 = doc-code.*/
    v-obj-type1 = obj-type.
    v-obj-code1 = obj-code.
    v-chk-date1 = chk-date.
    v-shift-date1 = shift-date.

    return v-log-result.

end function.

function last-of-condition2 returns logical
(input obj-type   as character,
 input obj-code   as integer
 /*input note       as character*/):

    define variable v-log-result as logical no-undo.

    if
       v-obj-type2 = "" and /* Что соответствует первому старту */
       v-obj-code2 = 0 /*and
       v-note2 = "":U*/
    then
    do:  /* Только для первого вхождения в функцию */
        v-log-result = no.  /* Перехода на новое условие нет (входные данные - первые поступившие в функцию (запомненного предыдущего состоянию нет и сравнивать не с чем) */
    end. /* Только для первого вхождения в функцию */
    else
    do:  /* Цикл очередной проверки на ИЗМЕНЕНИЕ к новому УСЛОВИЮ(набору вход. данных) */
        if
           obj-type = v-obj-type2 and
           obj-code = v-obj-code2 /*and
           note = v-note2*/
        then
        do:
            v-log-result = no.  /* Перехода на новое условие нет (входные данные = запомненному предыдущему состоянию) */
        end.
        else
        do:
            v-log-result = yes.  /* Перехода на новое условие нет (входные данные = запомненному предыдущему состоянию) */
        end.
    end. /* Цикл очередной проверки на ИЗМЕНЕНИЕ к новому УСЛОВИЮ(набору вход. данных) */

    /*v-doc-code1 = doc-code.*/
    v-obj-type2 = obj-type.
    v-obj-code2 = obj-code.
    /*v-note2 = note.*/

    return v-log-result.

end function.
