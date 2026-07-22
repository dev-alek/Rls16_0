block-level on error undo, throw.

/*------------------------------------------------------------------------
$Revision: 1f78fe327cdf, 1091, rls $
$Author: ASMorozov $
$Date: Thu Dec 14 02:13:52 2017 +0300 $
$Workfile: r-regbk-alc.p $
$Archive: rep/r-regbk-alc.p $

Журнал учёта объёма розничной продажи алкогольной и спиртосодержащей продукции

Автор: Шутилов Арнольд Валерьевич
Дата создания: 15/10/14
Author: Arnold Shutilov
Creation date: 15/10/14
ТН-16.0
  ----------------------------------------------------------------------*/
define input parameter parParentProc as handle no-undo.

define variable vss-revision    as character no-undo init "$Revision: 1f78fe327cdf, 1091, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:52 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-regbk-alc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-regbk-alc.p $":U .
define variable vss-description as character no-undo init "Журнал учёта розничной продажи алкогольной продукции".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
/*{ cmp/r-pril.i new }*/
{ cmp/r-page1.i  } /* Внутри вложен { cmp/obj-list.i {1}}, в котором формируется таблица obj-list. */
{ str/trdcalib.i }
{ gbl/attr-lib.i }
{ ref/gds-attr.i }
{ trg/factord.i  }
{ gbl/paramls.i  }
{ rep/fmtcli.i   }

/*{ gbl/getcntxt.i def }      /* Получение контекста тек сессии. */*/
/*{ gbl/getcntxt.i get '' parParentProc }                          */

/*{ rep/r-regbk-alc-xl.i } /* ТН-3309. 2014г. Арн. Блок отчёта в Excel */*/
{ cmp/r-pril.i new  } /* ТН-3309. 2014г. Арн. Здесь берём {&DF_Name}*/

/*{ cmp/str-glbl.i   }                                 */
/*{ cmp/library.i    }                                 */
/*{ cmp/r-pril.i new }                                 */
/*{ cmp/r-page1.i    }                                 */
/*{ gbl/waitfram.i   }                                 */
/*{ gbl/prn-lib.i    }                                 */
/*{ rep/r-sym.i      }                                 */
/*{ trg/factord.i    }                                 */
/*{ rep/ost-line.i   }                                 */
/*{ str/clcprtsl.i   }                                 */
/*{ rep/lkp-font.i   }                                 */
/*{ rep/fmtcli.i     }                                 */
/*{ gbl/paramls.i    }                                 */
/*define variable g#report-num  as integer    no-undo .*/
/*{ rep/alc04xl.i    }                                 */

/*define input parameter parparentproc as handle no-undo.*/
define variable v-par-val as character no-undo.
define variable v-par-type as character no-undo.
define variable v-fact-order-start as decimal no-undo.
define variable v-fact-order-end as decimal no-undo.
define variable v-begin-date as date no-undo.
define variable v-end-date as date no-undo.

define variable g#report-num as integer no-undo.
define variable v-user-action as character no-undo.
define variable v-printed as logical no-undo.
define variable v-cnt-line as integer no-undo.
define variable v-cnt-line2 as integer no-undo.
define variable v-alc-type-name as character no-undo.
define variable v-alc-type-code as character no-undo.
define variable v-doc-code as character no-undo.
define variable v-attr-type as character no-undo.
define variable v-attr-value as character no-undo.
define variable v-attr-doc-data as date no-undo.
define variable v-attr-doc-code as character no-undo.
define variable v-name-ext-doc-type as character no-undo.
define variable v-fill-path-RepView as character no-undo.
define variable v-temp-id as integer no-undo.
define variable v-sub-store-on as logical no-undo.

define variable v-file-name-rep-htm as character no-undo.
/*define variable v-shot-file-name-template as character no-undo.*/

/*define variable v-ext-doc-type as character no-undo.*/

define temp-table tt-rep1
    field cnt-line as integer                                               /* 1.  "№ п/п."                                         Поступления. */
    field alc-type-name like ub.alc-type.alc-type-name                      /* 2.  "Вид и наименование продукции"                   Поступления. */ /* По Rлассификатору алк прод. */
    field alc-type-code like ub.alc-type.alc-type-code                      /* 3.  "Код вида продукции"                             Поступления. */
    field cli-obj-name like ub.clients.obj-name                             /* 4.  "Наименование организации" (Поставщика)          Поступления. */
    field inn like ub.firm.inn                                              /* 5.  "ИНН" (Поставщика)                               Поступления. */
    field date-trn as date                                                  /* 6.  "Дата" (Накл. Поставщика)                        Поступления. */ /* Из атрибутов прихода внешнего, если нет, то дата дата факт документа. Дата факт расхода внеш между фирм для межфирм перемещ. */
    field doc-line-code like ub.doc-line.doc-code                           /* -   Служебное поле(не для вывода на экран) */
    field doc-line-fact-order like ub.doc-line.fact-order                   /* -   Служебное поле. */
    field doc-code like ub.doc-line.doc-code                                /* 7.  "Номер" (Накл. Поставщика)                       Поступления. */ /* Из атрибутов прихода внешнего, если нет, то пусто. Номер расхода внеш между фирм для межфирм перемещ. */
    field volume-piece-litres like ub.goods.ms-base /* ">>,>>9,999" */      /* 8.  "Ёмкость тары(упаковки) (л)" (Накл. Поставщика)  Поступления. */ /* Определение: Объём одной минимальной(не делимой) штуки в литрах (ub.goods.ms-base). Т.е. это скажем, бутылка. */
    field fact-qnty like doc-line.fact-qnty /* "->>,>>>,>>9,<<<" */         /* 9.  "Количество тары(упаковки)" (Накл. Поставщика)   Поступления. */ /* Определение: Кол-во минимальной тары(не делимой) по накладной. (doc-line.fact-qnty) Т.е. кол-во скажем, бутылок. */
    field inc-total-quontity like doc-line.fact-qnty                        /* 10. "Итого поступило за отчётный период"             Поступления. */ /* Выводим литры тары: (doc-line.fact-qnty * goods.ms-base (т.е. факт_кол-во * объём_штуки)). Выводим штуки тары: факт_кол-во */
    field exp-categoryes-prod as character                                  /* 11. "Содержание записи"                              Расход.      */ /* Определение: продажа; списание - с указанием основания документа; перемещение - расход внутренний; недостача - инвентаризация; арестованная продукция изъятая из оборота; конфискованная продукция по решению суда. */
    field exp-alc-type-name like ub.alc-type.alc-type-name                  /* 12. "Вид и наименование продукции"                Расход.      */ /* Вид и наимен продукции по Классификатору алк прод по каждой строке пт.11 */
     field exp-alc-type-code like ub.alc-type.alc-type-code                 /* -   Служебное поле(не для вывода на экран) */
     field exp-doc-line-code like ub.doc-line.doc-code                      /* -   Служебное поле(не для вывода на экран) */
     field exp-td-fact-date as date                                         /* -   Служебное поле(не для вывода на экран) */
     field exp-fact-order like ub.doc-line.fact-order                       /* -   Служебное поле. */
    field exp-volume-piece-litres like ub.goods.ms-base /* ">>,>>9,999" */  /* 13. "Ёмкость тары(упаковки) (л)"                     Расход.      */ 
    field exp-fact-qnty like doc-line.fact-qnty /* "->>,>>>,>>9,<<<" */     /* 14. "Количество тары(упаковки)"                      Расход.      */
    field exp-total-quontity like doc-line.fact-qnty                        /* 15. "Итого расход за отчётный период"                Расход.      */ /* Подобно п.10 */

    index pi            is primary alc-type-code doc-line-code volume-piece-litres
    index fact_order    doc-line-fact-order
.

do:  /* Откл. Старый или пробный код */
/*define temp-table tt-expence /* Временная таблица для обработки Расхода */                                                                                                                                                                                                                                                                               */
/*    field exp-doc-line-code like ub.doc-line.doc-code   /*+ -   Служебное поле(не для вывода на экран) */                                                                                                                                                                                                                                                */
/*    field exp-cnt-line as integer                       /*- -   Служебное поле(не для вывода на экран) */                                                                                                                                                                                                                                                */
/*    field exp-td-fact-date as date                      /*+ -   Служебное поле(не для вывода на экран) */                                                                                                                                                                                                                                                */
/*    field exp-fact-order like ub.doc-line.fact-order    /*+ -   Служебное поле. */                                                                                                                                                                                                                                                                       */
/*    field exp-categoryes-prod as character              /* 11. "Содержание записи"                              Расход.      */ /* Определение: продажа; списание - с указанием основания документа; перемещение - расход внутренний; недостача - инвентаризация; арестованная продукция изъятая из оборота; конфискованная продукция по решению суда. */*/
/*    field exp-alc-type-code like ub.alc-type.alc-type-code /*+ -   Служебное поле(не для вывода на экран) */                                                                                                                                                                                                                                             */
/*    field exp-alc-type-name like ub.alc-type.alc-type-name /* 12. "Вид и наименование продукции"                Расход.      */ /* Вид и наимен продукции по Классификатору алк прод по каждой строке пт.11 */                                                                                                                                           */
/*    field exp-volume-piece-litres like ub.goods.ms-base /* 13. "Ёмкость тары(упаковки) (л)"                     Расход.      */                                                                                                                                                                                                                          */
/*    field exp-fact-qnty like doc-line.fact-qnty         /* 14. "Количество тары(упаковки)"                      Расход.      */                                                                                                                                                                                                                          */
/*    field exp-total-quontity like doc-line.fact-qnty    /* 15. "Итого расход за отчётный период"                Расход.      */ /* Подобно п.10 */                                                                                                                                                                                                       */
/*                                                                                                                                                                                                                                                                                                                                                         */
/*    index pi is primary                                                                                                                                                                                                                                                                                                                                  */
/*        exp-alc-type-code exp-doc-line-code exp-volume-piece-litres                                                                                                                                                                                                                                                                                      */
.

/*define temp-table tt-report                                                                                                                                                                                                                                                                                                                              */
/*    field cnt-line as integer                           /* 1.  "№ п/п."                                         Поступления. */                                                                                                                                                                                                                          */
/*    field alc-type-name like ub.alc-type.alc-type-name  /* 2.  "Вид и наименование продукции"                   Поступления. */ /* По Rлассификатору алк прод. */                                                                                                                                                                                        */
/*    field alc-type-code like ub.alc-type.alc-type-code  /* 3.  "Код вида продукции"                             Поступления. */                                                                                                                                                                                                                          */
/*    field cli-obj-name like ub.clients.obj-name         /* 4.  "Наименование организации" (Поставщика)          Поступления. */                                                                                                                                                                                                                          */
/*    field inn like ub.firm.inn                          /* 5.  "ИНН" (Поставщика)                               Поступления. */                                                                                                                                                                                                                          */
/*    field date-trn as date                              /* 6.  "Дата" (Накл. Поставщика)                        Поступления. */ /* Из атрибутов прихода внешнего, если нет, то дата дата факт документа. Дата факт расхода внеш между фирм для межфирм перемещ. */                                                                                       */
/*    field doc-line-code as character                    /* -   Служебное поле(не для вывода на экран) */                                                                                                                                                                                                                                                 */
/*    field doc-code as character                         /* 7.  "Номер" (Накл. Поставщика)                       Поступления. */ /* Из атрибутов прихода внешнего, если нет, то пусто. Номер расхода внеш между фирм для межфирм перемещ. */                                                                                                              */
/*    field volume-piece-litres like ub.goods.ms-base     /* 8.  "Ёмкость тары(упаковки) (л)" (Накл. Поставщика)  Поступления. */ /* Определение: Объём одной минимальной(не делимой) штуки в литрах (ub.goods.ms-base). Т.е. это скажем, бутылка. */                                                                                                      */
/*    field volume-line-liters as decimal                 /* -   Служебное поле(не для вывода на экран) */                                                                                                                                                                                                                                                 */
/*    field fact-qnty like doc-line.fact-qnty             /* 9.  "Количество тары(упаковки)" (Накл. Поставщика)   Поступления. */ /* Определение: Кол-во минимальной тары(не делимой) по накладной. (doc-line.fact-qnty) Т.е. кол-во скажем, бутылок. */                                                                                                   */
/*    field inc-total-quontity as character               /* 10. "Итого поступило за отчётный период"             Поступления. */ /* Выводим литры тары: (doc-line.fact-qnty * goods.ms-base (т.е. факт_кол-во * объём_штуки)). Выводим штуки тары: факт_кол-во */                                                                                         */
/*    field exp-categoryes-prod as character              /* 11. "Содержание записи"                              Расход.      */ /* Определение: продажа; списание - с указанием основания документа; перемещение - расход внутренний; недостача - инвентаризация; арестованная продукция изъятая из оборота; конфискованная продукция по решению суда. */*/
/*    field exp-alc-type-name like ub.alc-type.alc-type-name /* 12. "Вид и наименование продукции"                Расход.      */ /* Вид и наимен продукции по Классификатору алк прод по каждой строке пт.11 */                                                                                                                                           */
/*    field exp-volume-piece-litres like ub.goods.ms-base /* 13. "Ёмкость тары(упаковки) (л)"                     Расход.      */                                                                                                                                                                                                                          */
/*    field exp-fact-qnty like doc-line.fact-qnty         /* 14. "Количество тары(упаковки)"                      Расход.      */                                                                                                                                                                                                                          */
/*    field exp-total-quontity as character               /* 15. "Итого расход за отчётный период"                Расход.      */ /* Подобно п.10 */                                                                                                                                                                                                       */
/*.                                                                                                                                                                                                                                                                                                                                                        */
end. /* Откл. Старый или пробный код */

define buffer buf_tt-rep1 for tt-rep1.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_obj-list for obj-list.
define buffer buf2_obj-list for obj-list.

define stream Out-Stream.
define stream OutStr-html.
define stream MyWatch-strm. /* задать в области определения переменных */

/*message "X-Date-Start = " X-Date-Start view-as alert-box.*/

/*define temp-table tt-alc-log-book no-undo   /* Временная таблица с Отчётом. */                                                                        */
/*    field b-str like ub.prod-bc.b-str       /* Какие нужно удалить доп. Баркоды (здесь данные из пользовательского файла соответствий на удаление). */*/
/*    index pi as primary unique b-str                                                                                                                  */
/* ***************************  Definitions  ************************** */

/* ********************  Preprocessor Definitions  ******************** */

/* ************************  Function Prototypes ********************** */

function fnc-fmt-dec-tc-litres returns character 
(input p-num as decimal) forward.

function fnc-fmt-dec-tc-qnty returns character 
(input p-num as decimal) forward.

/* ***************************  Main Block  *************************** */



/* **********************  Internal Procedures  *********************** */

procedure ConvertStr-ext-doc-type: /* Получение наименования код_вида_расходов по полученному элементу из списка наименований */
/********************************/
    define input parameter p-ext-doc-type as character no-undo.
    define output parameter p-name-ext-doc-type as character no-undo.
    define variable v-num-element as integer no-undo.

        /* Код_вида_расходов. Получение номера элемента в списке кодов */
        v-num-element = lookup(p-ext-doc-type, {&TDEDT_List}).

        /* Получение наименования код_вида_расходов по полученному элементу из списка наименований */
        p-name-ext-doc-type = entry(v-num-element, {&TDEDT_List-full}).
        if p-ext-doc-type <> "" and v-num-element = 0 then
            do:
                message "Ошибка 115." view-as alert-box.
                return.
            end.

end procedure.

procedure prc-create-file:
/* ******************** */
    define input parameter p-rep-num as integer no-undo.
/* Создаём временные файлы. */
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ).
    output close.
    output to value( string( session:temp-directory + {&DF_Name} + string( g#report-num ) ) + ".txl" ).
    output close.
/* ******************** */

/*/* Найти файл */                                                           */
/*define variable v-full-file-name as character no-undo.                     */
/*define variable v-shot-file-name as character no-undo.                     */
/*v-shot-file-name = {&DF_Name} + string(g#report-num).                      */
/*message "Ищем файл v-shot-file-name = " v-shot-file-name view-as alert-box.*/
/*v-full-file-name = search(session:temp-directory + v-shot-file-name).      */
/*message "Ищем файл v-full-file-name = " v-full-file-name view-as alert-box.*/

end procedure.

procedure proc-create-HTML:
/*************************/
    define variable v-volume-piece-litres as character no-undo.
    define variable v-fact-qnty as character no-undo.
    define variable v-inc-total-quontity as character no-undo.
    define variable v-exp-volume-piece-litres as character no-undo.
    define variable v-exp-fact-qnty as character no-undo.
    define variable v-exp-total-quontity as character no-undo.
    
    /* Итоговые данные */
    define input parameter p-inc-qnty-tot as decimal no-undo.
    define input parameter p-inc-litres-tot as decimal no-undo.
    define input parameter p-out-qnty-tot as decimal no-undo.
    define input parameter p-out-litres-tot as decimal no-undo.

    define variable v-inc-litres-tot2 as character no-undo.
    define variable v-out-litres-tot2 as character no-undo.

    define parameter buffer buf_tt for tt-rep1.

    v-inc-litres-tot2 = fnc-fmt-dec-tc-litres(p-inc-litres-tot).
    v-out-litres-tot2 = fnc-fmt-dec-tc-litres(p-out-litres-tot).
/*    run my-watch-table.*/
/*    v-file-name-rep-htm = "r-regbk-alc".*/

/*    v-shot-file-name-template = "r-regbk-alc-tmpl.txt".*/

    /* Найти файл шаблона */
/*    if search(v-shot-file-name-template) = ? then do:                                             */
/*        message "В рабочей директории не найден файл-шаблон: r-regbk-alc-tmpl." view-as alert-box.*/
/*    end.                                                                                          */



    /* Создание файла */
/*    output to value(string(session:temp-directory + string(v-file-name-rep-htm))).*/
/*    output close.                                                                 */
/*    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ).*/
/*    output close.                                                                               */
/*    output to value( string( session:temp-directory + {&DF_Name} + string( g#report-num ) ) + ".txl" ).*/
/*    output close.                                                                                      */

    output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted

        substitute(
            '<!DOCTYPE HTML>
             <html>
             <head>
             <meta charset="utf-8">
             </head>
    
             <style type="text/css">
    
             table &1 border-collapse: collapse; font-size: 9pt; table-layout: fixed; width: 1157px; padding: 14px; &2
    
             td &1 border: 1px black ridge; word-wrap:break-word; &2
             htm
             .rotate &1
              -webkit-transform: rotate(-90deg);
              -moz-transform: rotate(-90deg);
              -ms-transform: rotate(-90deg);
              -o-transform: rotate(-90deg);
              transform: rotate(-90deg);
    
              /* also accepts left, right, top, bottom coordinates; not required, but a good idea for styling */
              -webkit-transform-origin: 50% 50%;
              -moz-transform-origin: 50% 50%;
              -ms-transform-origin: 50% 50%;
              -o-transform-origin: 50% 50%;
              transform-origin: 50% 50%;
            
              /* Should be unset in IE9+ I think. */
              filter: progid:DXImageTransform.Microsoft.BasicImage(rotation=3);
            &2
            
            th &1
                border: 1px black solid;
                word-wrap: break-word;
            &2
            
             </style>
            
            <body>
                <table name="Отчет">
                    <thead>
                        <tr class="set_columns">
                            <td style="width: 32px; border: none;"></td>
                            <td style="width: 98px; border: none;"></td>
                            <td style="width: 45px; border: none;"></td>
                            <td style="width: 157px; border: none;"></td>
                            <td style="width: 77px; border: none;"></td>
                            <td style="width: 59px; border: none;"></td>
                            <td style="width: 60px; border: none;"></td>
                            <td style="width: 70px; border: none;"></td>
                            <td style="width: 76px; border: none;"></td>
                            <td style="width: 68px; border: none;"></td>
                            <td style="width: 85px; border: none;"></td>
                            <td style="width: 100px; border: none;"></td>
                            <td style="width: 71px; border: none;"></td>
                            <td style="width: 76px; border: none;"></td>
                            <td style="width: 63px; border: none;"></td>
                        </tr>
                        <tr>
                            <td style="border: none"></td><td style="border: none"></td><td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none;" colspan="4">Приложение № 1</td>
                        </tr>
                        <tr>
                            <td style="height: 14px; border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none" colspan="4">к приказу Федеральной службы</td>
                        </tr>
                        <tr>
                            <td style="height: 14px; border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none" colspan="4">по регулированию алкогольного рынка</td>
                        </tr>
                        <tr>
                            <td style="height: 14px; border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none" colspan="4">от 23 мая 2014 г. № 153</td>
                        </tr>
                        <tr>
                            <td style="height: 14px; border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td>
                        </tr>
                        <tr>
                            <td style="border: none; font-size: 12pt; text-align: center; font-weight: bold;" colspan="15">Журнал учета объема розничной продажи алкогольной и спиртосодержащей продукции</td>
                        </tr>
                        <tr>
                            <td style="height: 14px; border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td> <td style="border: none"></td>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <th rowspan="3" style="text-align: center;">№ п/п</th> <th colspan="9" style="text-align: center;">Поступления</th> <th colspan="5" height="16" style="text-align: center;">Расход</th>
                        </tr>
                        <tr>
                            <th rowspan="2" style="text-align: center;">Вид и наименование продукции</th> <th  rowspan="2" style="text-align: center;">Код вида продукции</th> <th colspan="2" style="text-align: center;">Поставщик продукции</th> <th  colspan="4" style="text-align: center;">ТТН</th> <th  rowspan="2" style="text-align: center;">Итого поступило за отчетный период (дкл) </th> <th rowspan="2" style="text-align: center;">Содержание записи</th> <th rowspan="2" style="text-align: center;">Вид и наименование продукции</th> <th  rowspan="2" style="text-align: center;">Емкость тары (упаковки) (л)</th> <th  rowspan="2" style="text-align: center;">Количество тары (упаковки)</th> <th  rowspan="2" style="text-align: center;">Итого расход за отчетный период (дкл)</th>
                        </tr>
                        <tr>
                            <th style="text-align: center;">Наименование организации</th> <th style="text-align: center;">ИНН</th> <th  style="text-align: center;">Дата</th> <th  style="text-align: center;">Номер</th>  <th  style="text-align: center;">Емкость тары (упаковки) (л)</th> <th  style="text-align: center;">Количество тары (упаковки)</th>
                        </tr>
                        <tr>
                            <th style="text-align: center;">1</th>
                            <th style="text-align: center;">2</th>
                            <th style="text-align: center;">3</th>
                            <th style="text-align: center;">4</th>
                            <th style="text-align: center;">5</th>
                            <th style="text-align: center;">6</th>
                            <th style="text-align: center;">7</th>
                            <th style="text-align: center;">8</th>
                            <th style="text-align: center;">9</th>
                            <th style="text-align: center;">10</th>
                            <th style="text-align: center;">11</th>
                            <th style="text-align: center;">12</th>
                            <th style="text-align: center;">13</th>
                            <th style="text-align: center;">14</th>
                            <th style="text-align: center;">15</th>
                        </tr>'
            , chr(123), chr(125)
        ).
        .
    output stream OutStr-html close.

    /* Заполнение линий таблицы "*/
    for each buf_tt no-lock by buf_tt.cnt-line:
        assign
            v-volume-piece-litres = if buf_tt.volume-piece-litres = 0 and buf_tt.fact-qnty = 0 then "" else fnc-fmt-dec-tc-litres(buf_tt.volume-piece-litres)
/*            v-fact-qnty = fnc-fmt-dec-tc-qnty(buf_tt.fact-qnty)*/
            v-inc-total-quontity = fnc-fmt-dec-tc-litres(buf_tt.inc-total-quontity)
            v-exp-volume-piece-litres = if buf_tt.exp-volume-piece-litres = 0 and buf_tt.exp-fact-qnty = 0 then "" else fnc-fmt-dec-tc-litres(buf_tt.exp-volume-piece-litres)
/*            v-exp-fact-qnty = fnc-fmt-dec-tc-qnty(buf_tt.exp-fact-qnty)*/
            v-exp-total-quontity = fnc-fmt-dec-tc-litres(buf_tt.exp-total-quontity)
        .
    output stream OutStr-html to value(v-file-name-rep-htm) append convert target 'UTF-8'.
        put stream OutStr-html unformatted

            substitute(
                    '<tr>
                        <td style="height: 14px; border: 1px solid black;">&1</td>
                        <td style="border: 1px solid black; padding: 3px;">&2</td>
                        <td style="border: 1px solid black;">&3</td>
                        <td style="border: 1px solid black; padding: 3px;">&4</td>
                        <td style="border: 1px solid black;">&5</td>
                        <td style="border: 1px solid black;">&6</td>
                        <td style="border: 1px solid black;">&7</td>
                        <td style="border: 1px solid black; text-align: right; padding: 3px;">&8</td>
                        <td style="border: 1px solid black; text-align: right; padding: 3px;">&9</td>'
                ,
                buf_tt.cnt-line,
                buf_tt.alc-type-name,
                buf_tt.alc-type-code,
                buf_tt.cli-obj-name,
                buf_tt.inn,
                if buf_tt.date-trn = ? then "" else string(buf_tt.date-trn),
                buf_tt.doc-code,
                v-volume-piece-litres, /*fnc-fmt-dec-tc-litres(buf_tt.volume-piece-litres),*/
                if buf_tt.fact-qnty = 0 and buf_tt.volume-piece-litres = 0 then "" else string(fnc-fmt-dec-tc-qnty(buf_tt.fact-qnty)) /* Если есть ёмкость, логично ожидать количество и наоборот! :-) */ /*v-fact-qnty*/ /*fnc-fmt-dec-tc-qnty(buf_tt.fact-qnty)*/
            )
            +
            substitute( /* Продолжение столбцов. Так сделано из-за того, что substitute работает только с девятью параметрами &n, а у нас их 15. */
                        '<td style="border-top: none; border-bottom: none; text-align: right; padding: 3px;">&1</td>
                        <td style="border: 1px solid black; padding: 3px;">&2</td>
                        <td style="border: 1px solid black; padding: 3px;">&3</td>
                        <td style="border: 1px solid black; text-align: right;">&4</td>
                        <td style="border: 1px solid black; text-align: right;">&5</td>
                        <td style="border-top: none; border-bottom: none; text-align: right; padding: 3px;">&6</td>
                    </tr>'
                ,
                "", /*v-inc-total-quontity,*/ /*fnc-fmt-dec-tc-litres(buf_tt.inc-total-quontity),*/
                buf_tt.exp-categoryes-prod,
                buf_tt.exp-alc-type-name,
                v-exp-volume-piece-litres, /*fnc-fmt-dec-tc(buf_tt.exp-volume-piece-litres),*/
                if buf_tt.exp-fact-qnty = 0 and buf_tt.exp-volume-piece-litres = 0 then "" else string(fnc-fmt-dec-tc-qnty(buf_tt.exp-fact-qnty)), /* Если есть ёмкость, логично ожидать количество и наоборот! :-) */ /*v-exp-fact-qnty,*/ /*fnc-fmt-dec-tc-qnty(buf_tt.exp-fact-qnty),*/
                "" /*v-exp-total-quontity*/ /*fnc-fmt-dec-tc-litres(buf_tt.exp-total-quontity)*/
                ).
/*        .'*/

    output stream OutStr-html close.
            end.

    /* Строка ИТОГО (суммы) по документу: "*/
    output stream OutStr-html to value(v-file-name-rep-htm) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute (
                        '<tr>
                            <td style="height: 14px; border: 1px solid black"> </td>
                            <td style="height: 14px; border: 1px solid black"> </td>
                            <td style="height: 14px; border: 1px solid black"> </td>
                            <td style="height: 14px; border: 1px solid black"> </td>
                            <td style="height: 14px; border: 1px solid black"> </td>
                            <td style="height: 14px; border: 1px solid black"> </td>
                            <td style="height: 14px; border: 1px solid black"> </td>
                            <td style="height: 14px; border: 1px solid black"> </td>
                            <td style="height: 14px; border: 1px solid black; text-align: right; padding: 3px;">&1</td>
                            <td style="height: 14px; border: 1px solid black; text-align: right; padding: 3px;">&2</td>
                            <td style="height: 14px; border: 1px solid black"> </td>
                            <td style="height: 14px; border: 1px solid black"> </td>
                            <td style="height: 14px; border: 1px solid black"> </td>
                            <td style="height: 14px; border: 1px solid black; text-align: right; padding: 3px;">&3</td>
                            <td style="height: 14px; border: 1px solid black; text-align: right; padding: 3px;">&4</td>
                        </tr>'
            ,
            string(fnc-fmt-dec-tc-qnty(p-inc-qnty-tot)),
            v-inc-litres-tot2,
            string(fnc-fmt-dec-tc-qnty(p-out-qnty-tot)),
            v-out-litres-tot2
            )
        .
        /* '" */
    output stream OutStr-html close.

    /* Вставка "декоративных" надписей "ИТОГО" под таблицей. */

    output stream OutStr-html to value(v-file-name-rep-htm) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
                        '<tr>
                            <td style="height: 14px; border: 1px solid black"> </td>
                            <td style="height: 14px; border: 1px solid black"> </td>
                            <td style="height: 14px; border: 1px solid black"> </td>
                            <td style="height: 14px; border: 1px solid black"> </td>
                            <td style="height: 14px; border: 1px solid black"> </td>
                            <td style="height: 14px; border: 1px solid black"> </td>
                            <td style="height: 14px; border: 1px solid black"> </td>
                            <td style="height: 14px; border: 1px solid black"> </td>
                            <td style="height: 14px; border: 1px solid black; text-align: center;">ИТОГО</td> 
                            <td style="height: 14px; border: 1px solid black; text-align: center;">ИТОГО</td>
                            <td style="height: 14px; border: 1px solid black"> </td>
                            <td style="height: 14px; border: 1px solid black"> </td>
                            <td style="height: 14px; border: 1px solid black"> </td> 
                            <td style="height: 14px; border: 1px solid black; text-align: center;">ИТОГО</td>
                            <td style="height: 14px; border: 1px solid black; text-align: center;">ИТОГО</td>
                        </tr>
                    </tbody>'
        .
        /* " */
    output stream OutStr-html close.


    /* Заполнение подвала таблицы */
    output stream OutStr-html to value(v-file-name-rep-htm) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
                    '</table>
            </body>
        </html>'
        .
        /* '" */
    output stream OutStr-html close.

end procedure.


/* ************************  Function Implementations ***************** */

function fnc-fmt-dec-tc-litres returns character 
(input p-number as decimal):

    define variable result as character no-undo.
    define variable v-str1 as character no-undo.

    v-str1 = trim(replace(string(p-number,'>>>>9.99<'), ".", ",")).

    return v-str1.
		
end function.

function fnc-fmt-dec-tc-qnty returns character
(input p-number as decimal):

    define variable result as character no-undo.
    define variable v-str1 as character no-undo.

	v-str1 = trim(replace(string(p-number,'->>>>>>>9.9<<'), ".", ",")).

    return v-str1.

end function.

do: /* S */

    do:  /* Нач_Иниц */
         /* Начальная инициализация таблицы */
        for each tt-rep1 no-lock:
            delete tt-rep1.
        end.
    
        /* Поиск нач fact-order */
        run day-begin-fact-order in this-procedure ( input X-Date-Start /*v-begin-date*/
                                                    , output v-fact-order-start
                                                    ).
        /* Поиск посл fact-order */
        run factord-end-day in this-procedure ( input X-Date-End /*v-end-date*/
                                                , output v-fact-order-end
                                                ).

/*        { cmp/open-out.i STREAM Out-Stream " " {&LS_PS_A4} }*/

/*        put stream Out-Stream UNFORMATTED             */
/*            "Отчет доступен только в формате EXCEL!!!"*/
/*        .                                             */

/*        run prc-create-file (input g#report-num).*/

        /* Получаем номер отчёта из ТН для вставки его в имя файла Excel при сохранении. */
        run get-report-num in parParentProc (
            output g#report-num
        ).

        v-file-name-rep-htm = session:temp-directory + {&DF_Name} + string(g#report-num) + ".html".
        /* Создаём временные файлы. */
/*            output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ).*/
/*            output close.                                                                               */
/*            output to value( string( session:temp-directory + {&DF_Name} + string( g#report-num ) ) + ".html" /*".txl"*/ ).*/
/*            output close.                                                                                                  */
/*            output to value(string(session:temp-directory + v-file-name-rep-htm)).*/
            output to value(v-file-name-rep-htm).
            output close.
        /* ******************** */

        if search("exe\ReportViewer\reportviewer.exe") <> ? then
            do:
                v-fill-path-RepView = search("exe\ReportViewer\reportviewer.exe").
            end.
        else
            do:
                message "Не найдена программа просмотра отчёта!" view-as alert-box error.
            end.


    end. /* Нач_Иниц */
do:

    for each tt-rep1 no-lock:
        delete tt-rep1.
    end.

    /* ТН-3371 18.02.2015 Арн. Если включена галочка "Текущий объект" в параметрах Закладка-1, то отчёт будет касаться связки Маг + Скл БЕЗ ВНУТРЕННИХ операций по прих/расх/возвр... между ними!!! */
    if x-SelectObject = {&obj-currency} then
    do:
        find first buf_obj-list no-error.
        if available buf_obj-list then
        do:
            /* Для этого во первых - найдём есть ли связка НашТекОбъект + Склад? */
            find first ub.shop where
                       ub.shop.obj-code = buf_obj-list.obj-code and
                       ub.shop.sub-store-on = yes and           /* Включена/выключена подвязка Склада для тек объекта. */
                       ub.shop.sub-store-type <> '':U and       /* Здесь должен храниться тип объекта подвязанного как склад */
                       ub.shop.sub-store-code <> 0              /* Здесь должен храниться код объекта подвязанного как склад, 0 - объект не задан! */
            no-error.
            if available ub.shop then /* Если связка Маг+Скл есть (только для режима "Текущий объект" Закладка-1), то кроме Тек Объекта- добавляем в листинг формируемых для отчёта объектов (а это задаётся в obj-list) - Объект Склад и обрабатываем два объекта: Маг и Скл !!! */
            do:

                /* Для добавления данных в obj-list - обязательно заполняется его поле id. Значит найдём последнее знач id и инкрементируем его. Но попутно, по образцу в сущ коде, заполним obj-list полнее (номер бд, имя объекта) */
                find first ub.clients where
                           ub.clients.obj-type = ub.shop.sub-store-type and
                           ub.clients.obj-code = ub.shop.sub-store-code
                no-lock no-error.
                if available ub.clients then
                do:
                    find last buf_obj-list use-index pi no-error.
                    if available buf_obj-list then
                    do:
                        v-temp-id = buf_obj-list.obj-id + 1.
                    end.
                    else
                    do:
                        v-temp-id = 1.
                    end.

                    create buf_obj-list.

                    assign
                        v-sub-store-on = yes                        /* Флаг уточнённой проверки на предмет того, что есть связка Маг+Скл и она НЕ ПУСТАЯ! Ниже обратимся к объекту Склад для "изъятия" внутренних движений товаров между Маг и Склад */
                        buf_obj-list.obj-type = ub.clients.obj-type
                        buf_obj-list.obj-code = ub.clients.obj-code
                        buf_obj-list.obj-id = v-temp-id
                        buf_obj-list.db-num = ub.clients.db-num
                        buf_obj-list.obj-name = ub.clients.obj-name
                    .
                end.
            end.
        end.
    end.


    for each obj-list no-lock: /* А. Тело_Отчёта */

        { gbl/working.i }
        run gbl/conf-rd.p ( /* Запрашиваем - есть ли в текущей БД в указанном объекте(маг,скл...) параметр "алкоголь"?  */
            "alcohol":U,
            "":U,
            obj-list.obj-type,
            obj-list.obj-code,
            "":U,
            "":U,
            "":U,
            yes,
            output v-par-val,
            output v-par-type
        ) no-error.
        if v-par-val <> "yes" then /* Если в текущей БД в указанном объекте параметр "алкоголь" = no тогда смотрим следующий объект(маг,склад...) */
            do:
                next.
            end.
        else
        do: /* Если в указанном объекте(маг,склад...) найден установленный в yes параметр "алкоголь", то... */
            for each ub.gds-obj where                               /* Смотрим все связки Товар-Объект (Т-О) по известному объекту(obj-type;obj-code) находим КодТовара */
                     ub.gds-obj.obj-type = obj-list.obj-type and
                     ub.gds-obj.obj-code = obj-list.obj-code
            no-lock
            ,
            first goods where
            goods.gds-code = gds-obj.gds-code
            :

                run gds-attr-value(
                    ub.gds-obj.gds-code,
                    {&attr-alcohol-prod},
                    output v-par-val,
                    output v-par-type
                ).

                if v-par-val <> "" and
                v-par-val <> "no" then
                do: /* 1 */
                    v-alc-type-name = "".
                    v-alc-type-code = "".

                    for first ub.alc-type-gds where /* F Подготовка для определения Вид_Алкогольной_Продукции. */
                              ub.alc-type-gds.gds-code = ub.gds-obj.gds-code no-lock
                    :
                        do: /* U */
                            for first ub.alc-type where /* Определение Вид_Алкогольной_Продукции. */
                                      ub.alc-type.alc-type-inner-code = ub.alc-type-gds.alc-type-inner-code no-lock
                            :
                                do: /* M */
                                    assign
                                        v-alc-type-name = ub.alc-type.alc-type-name /* Запись Вид_Алкогольной_Продукции во временную переменную. */
                                        v-alc-type-code = ub.alc-type.alc-type-code /* Запись Код_Вида_Продукции во временную переменную. */
                                    .

                                    for each ub.doc-line where 
                                             ub.doc-line.obj-type = obj-list.obj-type and
                                             ub.doc-line.obj-code = obj-list.obj-code and
                                             ub.doc-line.status_ = {&fact} and
                                             ub.doc-line.fact-order >= v-fact-order-start and
                                             ub.doc-line.fact-order <= v-fact-order-end and
                                             ub.doc-line.prod-type = ub.gds-obj.prod-type and
                                             ub.doc-line.prod-code = ub.gds-obj.prod-code and
                                             ub.doc-line.artic = ub.gds-obj.artic no-lock
                                    ,
                                    first buf_trn-doc where
                                    buf_trn-doc.doc-code = ub.doc-line.doc-code no-lock
                                    :
                                        /* Приход */
                                        if lookup(ub.doc-line.ext-doc-type, {&TDEDT_in_list}) > 0 then /* Если работаем с Приходом (список кодов прихода содержится в TDEDT_in_list) */
                                        do:

                                            if v-sub-store-on = yes then /* Если работаем с гарантированно существующим объектом Склад... */
                                            do:
                                                /* ТН-3371 17.02.2015 Арн. По концепции (и по ТЗ) - не включать в отчёт типы док: "приход/расход/возврат ВНУТРЕННИЕ", т.е. имеющие место ТОЛЬКО МЕЖДУ связанными МАГ и СКЛ (остальные внутр док - учитываются) */
                                                if (can-find(first buf2_obj-list no-lock where
                                                            buf2_obj-list.obj-type = buf_trn-doc.cli-type and
                                                            buf2_obj-list.obj-code = buf_trn-doc.cli-code))
                                                    and
                                                    (ub.doc-line.ext-doc-type = {&TDEDT_Pri_Perem} or       /* Приход внутренний */
                                                     /*ub.doc-line.ext-doc-type = {&TDEDT_Ras_Perem} or*/       /* Расход внутренний - Обработаем в разделе "Расход" (см. ниже)*/
                                                     ub.doc-line.ext-doc-type = {&TDEDT_Vozvrat_Perem})     /* Возврат внутренний */
                                                then next.
                                            end.

                                            find first tt-rep1 where
                                                       tt-rep1.alc-type-code = v-alc-type-code and
                                                       tt-rep1.doc-line-code = doc-line.doc-code and
                                                       tt-rep1.volume-piece-litres = goods.ms-base
                                            no-error.

                                            if not available tt-rep1 then
                                            do:
                                                run fmtcli-get-client in this-procedure (
                                                    input buf_trn-doc.cli-type,
                                                    input buf_trn-doc.cli-code
                                                ).

                                                v-doc-code = doc-line.doc-code.
                                                /* дата документа из атрибутов */
                                                { str/tdat-val.i
                                                  v-doc-code
                                                  {&trdcattr-dids}
                                                  v-attr-value
                                                  v-attr-type
                                                }
                                                v-attr-doc-data = date(v-attr-value).
                                                if v-attr-doc-data = ? then v-attr-doc-data = buf_trn-doc.fact-date.

                                                /* номер документа из атрибутов ********************/
                                                { str/tdat-val.i
                                                  v-doc-code
                                                  {&trdcattr-nids}
                                                  v-attr-value
                                                  v-attr-type
                                                 }
                                                v-attr-doc-code = v-attr-value.
    /*                                          if trim(v-attr-doc-code) = "" then v-attr-doc-code = "" - по умолчанию */
                                                if buf_trn-doc.hold-doc-code-child <> "" and
                                                   buf_trn-doc.hold-doc-code-child <> "no-hold" or
                                                   buf_trn-doc.hold-doc-code-parent <> "" and
                                                   buf_trn-doc.hold-doc-code-parent <> "no-hold" then
                                                do:
                                                    v-attr-doc-code = buf_trn-doc.hold-doc-code-parent.
                                                end.
                                                /******************** номер документа из атрибутов */

                                                create tt-rep1.

                                                assign
                                                    tt-rep1.alc-type-name = v-alc-type-name             /* 02 */
                                                    tt-rep1.alc-type-code = v-alc-type-code             /* 03 */
                                                    tt-rep1.cli-obj-name = v-fmtcli-name                /* 04 */
                                                    tt-rep1.inn = v-fmtcli-inn                          /* 05 */
                                                    tt-rep1.date-trn = v-attr-doc-data                  /* 06 */
                                                    tt-rep1.doc-line-code = doc-line.doc-code           /* - Служебное поле (не на экран) */
                                                    tt-rep1.doc-line-fact-order = doc-line.fact-order   /* - Служебное поле (не на экран) */
                                                    tt-rep1.doc-code = v-attr-doc-code                  /* 07 */
                                                    tt-rep1.volume-piece-litres =
                                                        if (goods.ms-base * doc-line.cli-base-rate) = ? then 0
                                                        else (goods.ms-base * doc-line.cli-base-rate)   /* 08 */ /* ЕСЛИ в приходе ед.изм поставщика(doc-line.unit-cli) <> учётной ед.изм(goods.unit-base), ТОГДА объём_штуки_в_литрах(doc-line.unit-cli) * коэфициент_в_приходе(doc-line.cli-base-rate). Теперь изюминка - IF...THEN применять не будем! т.к. как правило, если описанное ранее условие выполняется, то нужно перемножать на коэф. cli-base-rate, если условие НЕ ВЫПОЛНЯЕТСЯ(т.е. коэф-т не нужен), всё-же можно в этом случае продолжать тупо умножать на cli-base-rate потому, что оно будет всегда(при невыполнения условия) иметь значение "ЕДИНИЦА"! и не внесёт некорректных изменений при перемножении, а мы избалвяемся от проверки условия! */
                                                .
                                            end.

                                            tt-rep1.fact-qnty = tt-rep1.fact-qnty +
                                                if (doc-line.fact-qnty / doc-line.cli-base-rate) = ? then 0
                                                else (doc-line.fact-qnty / doc-line.cli-base-rate). /* 09 (Запись новой или добавление к сущ записи tt-rep1) */

                                        end.

                                        /* Расход */
                                        else
                                        if lookup(ub.doc-line.ext-doc-type, {&TDEDT_out_list}) > 0 then /* Если работаем с Расходом (список кодов расхода содержится в TDEDT_out_list) */
                                        do:
                                            do: /* СМД-Р */
/*
                                                do:
                                                    find first tt-expence where
                                                               tt-expence.exp-alc-type-code = v-alc-type-code and
                                                               tt-expence.exp-doc-line-code = doc-line.doc-code and
                                                               tt-expence.exp-volume-piece-litres = goods.ms-base
                                                    no-error.

                                                    if not available tt-expence then
                                                    do:
                                                        create tt-expence.
                                                        v-cnt-line2 = v-cnt-line2 + 1.

                                                        run ConvertStr-ext-doc-type (input ub.doc-line.ext-doc-type, output v-name-ext-doc-type).

                                                        assign
                                                            tt-expence.exp-cnt-line = v-cnt-line2                   /* Служебное поле (не на экран) */
                                                            tt-expence.exp-doc-line-code = doc-line.doc-code        /* Служебное поле (не на экран) */
                                                            tt-expence.exp-alc-type-code = v-alc-type-code          /* Служебное поле (не на экран) */
                                                            tt-expence.exp-td-fact-date = buf_trn-doc.fact-date     /* Служебное поле (не на экран) */
                                                            tt-expence.exp-fact-order = doc-line.fact-order         /* Служебное поле (не на экран) */
                                                            tt-expence.exp-categoryes-prod = v-name-ext-doc-type    /* 11 */
                                                            tt-expence.exp-alc-type-name = v-alc-type-name          /* 12 */
                                                            tt-expence.exp-volume-piece-litres = goods.ms-base      /* 13 */
                                                        .
                                                    end.

                                                    tt-expence.exp-fact-qnty = tt-expence.exp-fact-qnty + doc-line.fact-qnty. /* 14 (Запись новой или добавление к сущ записи tt-expence) */

                                                end.
        */
                                            end. /* СМД-Р */

                                            if v-sub-store-on = yes then /* Если работаем с гарантированно существующим объектом Склад... */
                                            do:
                                                /* ТН-3371 17.02.2015 Арн. По концепции (и по ТЗ) - не включать в отчёт типы док: "приход/расход/возврат ВНУТРЕННИЕ", т.е. имеющие место ТОЛЬКО МЕЖДУ связанными МАГ и СКЛ (остальные внутр док - учитываются) */
                                                if (can-find(first buf2_obj-list no-lock where
                                                            buf2_obj-list.obj-type = buf_trn-doc.cli-type and
                                                            buf2_obj-list.obj-code = buf_trn-doc.cli-code))
                                                    and
                                                    (/*ub.doc-line.ext-doc-type = {&TDEDT_Pri_Perem} or*/       /* Приход внутренний - обрабатываем в разделе "Приход" (см. выше) */
                                                     ub.doc-line.ext-doc-type = {&TDEDT_Ras_Perem}         /* Расход внутренний */
                                                     /*ub.doc-line.ext-doc-type = {&TDEDT_Vozvrat_Perem}*/)     /* Возврат внутренний - обрабатываем в разделе "Приход" (см. выше) */
                                                then
                                                next.
                                            end.

                                            create tt-rep1.
    /*                                  v-cnt-line = v-cnt-line + 1.*/
                                            run ConvertStr-ext-doc-type (input ub.doc-line.ext-doc-type, output v-name-ext-doc-type).
                                            assign
                                                tt-rep1.exp-doc-line-code = doc-line.doc-code           /* Служебное поле (не на экран) */
                                                tt-rep1.exp-alc-type-code = v-alc-type-code             /* Служебное поле (не на экран) */
                                                tt-rep1.exp-td-fact-date = buf_trn-doc.fact-date        /* Служебное поле (не на экран) */
                                                tt-rep1.doc-line-fact-order = doc-line.fact-order       /* Служебное поле (не на экран) */
                                                tt-rep1.exp-categoryes-prod = v-name-ext-doc-type       /* 11 */
                                                tt-rep1.exp-alc-type-name = v-alc-type-name             /* 12 */
                                                tt-rep1.exp-volume-piece-litres = goods.ms-base         /* 13 */
                                                tt-rep1.exp-fact-qnty = tt-rep1.exp-fact-qnty +
                                                    (if doc-line.fact-qnty = ? then 0 else doc-line.fact-qnty). /* 14 (Запись новой или добавление к сущ записи tt-expence) */
                                            .

                                        end.
                                    end.
                                end. /* M */
                            end.
                        end. /* U */
                    end. /* F */
                end. /* 1 */
            end.
        end.
    end. /* А. Тело_Отчёта */

    do:  /* B Присвоение в поля таблицы="№ п/п" номеров по порядку, так будет выглядеть порядок в отчёте. */

        /*FF*****************************************************************************/
        define variable v-inc-litres-line as decimal initial 0 no-undo. 
        define variable v-out-litres-line as decimal initial 0 no-undo.
        define variable v-inc-litres-tot as decimal initial 0 no-undo.
        define variable v-out-litres-tot as decimal initial 0 no-undo.
        define variable v-inc-qnty-tot as decimal initial 0 no-undo.
        define variable v-out-qnty-tot as decimal initial 0 no-undo.
define variable v-dec as character no-undo.
        v-cnt-line = 0.

        for each tt-rep1 no-lock
/*        by tt-rep1.alc-type-code*/
/*        by tt-rep1.date-trn*/
        by tt-rep1.doc-line-fact-order
/*        by tt-rep1.exp-alc-type-code*/
/*        by tt-rep1.exp-td-fact-date */
        :
            /* Для ПРИХОДА */
            v-cnt-line = v-cnt-line + 1.
            tt-rep1.cnt-line = v-cnt-line.
            v-inc-litres-line =
                if ((decimal(tt-rep1.volume-piece-litres) * decimal(tt-rep1.fact-qnty)) / 10) = ? then 0
                else ((decimal(tt-rep1.volume-piece-litres) * decimal(tt-rep1.fact-qnty)) / 10). /*v-dec = string(v-dec) + ',' + string(decimal(tt-rep1.fact-qnty)).*/
            v-inc-litres-tot = v-inc-litres-tot + v-inc-litres-line. /* 10/1 */
            v-inc-qnty-tot = v-inc-qnty-tot +
                (if decimal(tt-rep1.fact-qnty) = ? then 0 else decimal(tt-rep1.fact-qnty)). /* 10/2 */

            /* Для РАСХОДА */
            v-out-litres-line =
                if ((tt-rep1.exp-volume-piece-litres * tt-rep1.exp-fact-qnty) / 10) = ? then 0
                else ((tt-rep1.exp-volume-piece-litres * tt-rep1.exp-fact-qnty) / 10).
            v-out-litres-tot =
                (if v-out-litres-tot = ? then 0 else v-out-litres-tot) +
                (if v-out-litres-line = ? then 0 else v-out-litres-line). /* 15/1 */
            v-out-qnty-tot =
                (if v-out-qnty-tot = ? then 0 else v-out-qnty-tot) +
                (if tt-rep1.exp-fact-qnty = ? then 0 else tt-rep1.exp-fact-qnty). /* 15/2 */

/*
        /* Сортировка таблицы tt-rep1 по датам и запись порядковых номеров линий (№ п/п) */
        for each tt-rep1 no-lock
        by tt-rep1.alc-type-code
        by tt-rep1.date-trn:
            v-cnt-line = v-cnt-line + 1.
            tt-rep1.cnt-line = v-cnt-line.
            v-inc-litres-line = (decimal(tt-rep1.volume-piece-litres) * decimal(tt-rep1.fact-qnty)) / 10.
            v-inc-litres-tot = v-inc-litres-tot + v-inc-litres-line. /* 10/1 */
            v-inc-qnty-tot = v-inc-qnty-tot + decimal(tt-rep1.fact-qnty). /* 10/2 */
/*            tt-rep1.inc-total-quontity = string(v-inc-litres-tot) + ",,, " + string(v-inc-qnty-tot). /* 10 */*/

            /* Сброс перед следующей итерацией линии */
            v-inc-litres-line = 0.
        end.
*/
/*
        /*Теперь итоговую строку вывожу не здесь в таблицу, а при формировании в HTML через run proc-create-HTML (buffer tt-rep1).*/
        /* Выводим итоговую сумму для ПРИХОДА (столбец-10)*/
/*        find first tt-rep1 where                       */
/*        tt-rep1.cnt-line = v-cnt-line no-lock no-error.*/
/*        if not available tt-rep1 then                  */
        do:
            create tt-rep1.
            tt-rep1.cnt-line = v-cnt-line + 1.
/*                tt-rep1.inc-total-quontity = string(v-inc-litres-tot) + " шт, " + string(v-inc-qnty-tot). /* 10 */*/
        end.
        assign
            tt-rep1.fact-qnty = v-inc-qnty-tot
            tt-rep1.inc-total-quontity = v-inc-litres-tot
        .
*/
        end.
        v-cnt-line = 0.

/*
        /* Сортировка таблицы tt-expence по датам и запись в tt-rep1 по порядку номеров линий (№ п/п). Если в tt-rep1 не хватит записей, то добавлять новые. */
        v-cnt-line2 = 0.
        for each tt-expence no-lock /* J */
        by tt-expence.exp-alc-type-code
        by tt-expence.exp-td-fact-date:
            v-cnt-line2 = v-cnt-line2 + 1.
            v-out-litres-line = (tt-expence.exp-volume-piece-litres * tt-expence.exp-fact-qnty) / 10.
            v-out-litres-tot = v-out-litres-tot + v-out-litres-line. /* 15/1 */
            v-out-qnty-tot = v-out-qnty-tot + tt-expence.exp-fact-qnty. /* 15/2 */
/*            tt-expence.exp-total-quontity = string(v-out-litres-tot) + " шт, " + string(v-out-qnty-tot). /* 15 */*/

            find first tt-rep1 where
            tt-rep1.cnt-line = v-cnt-line2
            no-lock no-error.

            if not available tt-rep1 then
                do:
                    create tt-rep1.
                    tt-rep1.cnt-line = v-cnt-line2.
                end.
            assign
                tt-rep1.exp-categoryes-prod = tt-expence.exp-categoryes-prod                    /* 11 */
                tt-rep1.exp-alc-type-name = tt-expence.exp-alc-type-name                        /* 12 */
                tt-rep1.exp-volume-piece-litres = tt-expence.exp-volume-piece-litres            /* 13 */
                tt-rep1.exp-fact-qnty = tt-expence.exp-fact-qnty                                /* 14 */
            .

        end. /* J */
*/
/*
        /*Теперь итоговую строку вывожу не здесь в таблицу, а при формировании в HTML через run proc-create-HTML (buffer tt-rep1).*/
        /* Выводим итоговую строку с суммами (шт, л) для РАСХОДА (столбец-15)*/
        find first tt-rep1 where
        tt-rep1.cnt-line = v-cnt-line2 + 1 no-lock no-error.
        if not available tt-rep1 then
            do:
                create tt-rep1.
                tt-rep1.cnt-line = v-cnt-line2 + 1.
/*                tt-rep1.exp-total-quontity = string(v-out-qnty-tot) + " шт, " + string(v-out-litres-tot). /* 15 */*/
            end.
        assign
/*            tt-rep1.exp-volume-piece-litres = "Итого:"*/
            tt-rep1.exp-fact-qnty = v-out-qnty-tot
            tt-rep1.exp-total-quontity = v-out-litres-tot
        .
*/
/*
        v-cnt-line2 = 0.
*/

    end. /* B */

    find first tt-rep1 no-lock no-error.
    if error-status:error then
        do:
            message "Для установленных параметров отчета" skip "- данные отсутствуют!" view-as alert-box warning.
        end.

    run proc-create-HTML (input v-inc-qnty-tot, input v-inc-litres-tot, input v-out-qnty-tot, input v-out-litres-tot, buffer tt-rep1).

/*    message "Отчет сохранен в рабочую директорию " skip "(файл: " + v-file-name-rep-htm + ")." view-as alert-box information.*/

    if search(v-file-name-rep-htm) = ? then
        do:
            message "Не найден файл отчёта: " v-file-name-rep-htm view-as alert-box error.
        end.
    else
        do:
            v-file-name-rep-htm = search(v-file-name-rep-htm).
        end.

    os-command no-wait value(v-fill-path-RepView + " " + search(v-file-name-rep-htm)).

    do: /* CMD-1 */
    /*
        for each buf_tt-rep1 no-lock:
            delete buf_tt-rep1.
        end.
    
        for each tt-rep1 no-lock:
            delete tt-rep1.
        end.
    
    
        define variable v-i as integer no-undo.
        define variable v-ii as integer initial 0 no-undo.
        define variable v-alc-type-name as character no-undo.
    
        do v-ii = 1 to 4:
            v-alc-type-name = v-alc-type-name + "f+".
            v-i = v-i + 1.
            create tt-rep1.
            assign
                tt-rep1.cnt-line = v-ii /*tt-rep1.cnt-line + 1*/
                tt-rep1.alc-type-name = v-alc-type-name
                tt-rep1.alc-type-code = tt-rep1.alc-type-code + "fdf"
                tt-rep1.cli-obj-name = "rte"
                tt-rep1.inn = "fws"
                tt-rep1.date-trn = ?
                tt-rep1.doc-code = "ieb"
                tt-rep1.volume-piece-litres = 31
                tt-rep1.fact-qnty = 9 
                tt-rep1.exp-categoryes-prod = "ff09"
                tt-rep1.exp-alc-type-name = "fffds"
                tt-rep1.inc-total-quontity = "p0oi"
                tt-rep1.exp-volume-piece-litres = v-i
                tt-rep1.exp-fact-qnty = 55
                tt-rep1.exp-total-quontity = "ddd"
            .
        end.
    */
    end. /* CMD-1 */
end.


    do: /* Выв_Excel */
/*
/*        /* ********************************************************************************************* */*/
/*        /* Создаём временные файлы. */                                                                     */
/*        output to value(string(session:temp-directory + "$" + string(g#report-num)) + ".txl").             */
/*        output close.                                                                                      */
/*        output to value(string(session:temp-directory + {&DF_Name} + string(g#report-num)) + ".txl").      */
/*        output close.                                                                                      */
/*        /* ********************************************************************************************* */*/

/*        define variable v-01 as character initial "fffff" no-undo.*/
/*        define variable v-02 as character no-undo.                */
/*        define variable v-03 as character no-undo.                */
/*        define variable v-04 as character no-undo.                */
/*        define variable v-05 as character no-undo.                */
/*        define variable v-06 as character no-undo.                */
/*        define variable v-07 as character no-undo.                */
/*        define variable v-08 as character no-undo.                */
/*        define variable v-09 as character no-undo.                */
/*        define variable v-10 as character no-undo.                */
/*        define variable v-11 as character no-undo.                */
/*        define variable v-12 as character no-undo.                */
/*        define variable v-13 as character no-undo.                */
/*        define variable v-14 as character no-undo.                */
/*        define variable v-15 as character no-undo.                */

        { rep/r-regbk-alc-xl.i } /* ТН-3309. 2014г. Арн. Блок для работы с шаблоном Excel */
        run r-regbk-alc-init in this-procedure.

        run r-regbk-alc-sheet1-write-line(
            buffer tt-rep1
/*            input v-01,*/
/*            input v-02,*/
/*            input v-03,*/
/*            input v-04,*/
/*            input v-05,*/
/*            input v-06,*/
/*            input v-07,*/
/*            input v-08,*/
/*            input v-09,*/
/*            input v-10,*/
/*            input v-11,*/
/*            input v-12,*/
/*            input v-13,*/
/*            input v-14,*/
/*            input v-15 */
        ).

        run r-regbk-alc-close in this-procedure.
/*        output stream Out-Stream close.*/

        /* Сохранение данных в файлы. */
        os-rename
            value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
            value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
        .

message "dbg-435 g#report-num = " g#report-num view-as alert-box.
        /* Диалог вывода на печать (экран, в файлы txt, Excel) */
        run gbl/prnfilen.w (
              input "":U
            , input 8
            , input string( session:temp-directory )
                                + {&DF_Name}
                                + string( g#report-num )
            , input 7
            , output v-user-action
            , output v-printed
            ).
*/
    end. /* Выв_Excel */

end. /* S */

procedure my-watch-table: /* Процедура для моей ОТЛАДКИ! Арн. */
/* Запись наблюдаемых таблиц в файл */
&scope tt-table tt-rep1
/*&scope tt-table gds-list*/
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
/*    v-full-file-name = "C:\work15_0\my-watch-table.txt".*/
    v-full-file-name = "C:\work15_0\my-watch2-{&tt-table}.txt".

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
