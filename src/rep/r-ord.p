block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-ord.p $
$Archive: rep/r-ord.p $

Печать акта и протокола переоценки

Автор: Мергер Оксана Александровна
Дата создания: 11/04/12
Author: Oksana Merger
Creation date: 11/04/12

Input:

Output:

*/

define input parameter parparentproc     as handle           no-undo.
define input parameter rec_id            as recid            no-undo.
define input parameter p-doc-type        as character        no-undo.    /* akt - акт, prik - приказ,                    */
define input parameter p-price-celection as integer          no-undo.
define input parameter p-print-null-qnty as logical          no-undo.
define input parameter p-sort-by-group   as logical          no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-ord.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-ord.p $":U .
define variable vss-description as character no-undo init "Печать акта о переоценке".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/library.i     }
{ gbl/cur-time.i    }
{ cmp/r-pril.i new  }
{ cmp/croslist.i    }
{ str/hvrdtax.i     }
{ gbl/tax-name.i    }
{ gbl/dtm.i         }
{ str/writelog.i def "'r-akt.log'" }
{ rep/r-akt.i def   }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

do
on error undo, return error
:
/*============== Переменные для работы отчета ==============*/
def buffer buf_clients for clients.
def var v-single-line       as char    no-undo. /*строка подчеркивания*/
def var sym1  as char init "|"   no-undo. /*Здесь и далее - символы для границ таблицы*/
def var sym2  as char init "|"   no-undo.
def var sym3  as char init "|"    no-undo.
def var sym4  as char init "|"   no-undo.
def var sym5  as char init "|"    no-undo.
def var sym6  as char init "|"    no-undo.
def var sym7  as char init "|"    no-undo.
def var sym8  as char init "|"    no-undo.
def var sym9  as char init "|"    no-undo.
def var sym10 as char init "|"    no-undo.
def var sym11  as char init "|"    no-undo.
def var sym12  as char init "|"    no-undo.
def var sym13  as char init "|"    no-undo.
def var sym14  as char init "|"    no-undo.
def var sum_before as decimal no-undo. /*Переменная столбца "Сумма" отдела "До переоценки"*/
def var sum_after as decimal no-undo. /*Переменная столбца "Сумма" отдела "После переоценки"*/
def var ucenka as decimal no-undo. /*Переменная столбца "Уценка"*/
def var doocenka as decimal no-undo. /*Переменная столбца "Дооценка"*/
def var comments as char init "" no-undo. /*Переменная столбца "Примечания"*/
def var string_counter as int init 0  no-undo. /*Переменная для подсчета количества товаров и столбца "N п/п"*/
def var serial_num as char init "" no-undo. /*Переменная столбца "Серия"*/
def var end_sum_before as decimal init 0 no-undo. /*Переменная для подсчета поля "Сумма" отдела "До переоценки*/
def var end_sum_after as decimal init 0 no-undo. /*Переменная для подсчета поля "Сумма" отдела "После переоценки"*/
def var end_sum_ucenka as decimal init 0 no-undo. /*Переменная для подсчета суммы уценок*/
def var end_sum_doocenka as decimal init 0 no-undo. /*Переменная для подсчета суммы переоценок*/
def var firm_name as char no-undo. /*Переменная, хранящая название компании*/
def stream AktStr .
def stream moreAtkStr.

/*============== Переменные нужные для инклудников ==============*/
def var Log-Resym1                as logical          no-undo.
def var v-price-doc-doc-num          like price-doc.doc-num     no-undo.
def var v-price-doc-doc-date         like price-doc.doc-date    no-undo.
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
define variable v-rb-is-base        as logical      no-undo.




define frame Akt-Cost  /*Объявление полей таблицы*/
      sym1                            no-label format "X(1)"             space(0)
      string_counter                  no-label format "99999"            space(0) /*Подсчет строк*/
      sym2                            no-label format "X(1)"             space(0)
      goods.okdp                      no-label format "X(9)"             space(0) /*Код ОКДП*/
      sym3                            no-label format "X(1)"             space(0)
      goods.gds-name                  no-label format "X(42)"            space(0) /*Наименование товара*/
      sym4                            no-label format "X(1)"             space(0)
      serial_num                      no-label format "X(6)"             space(0) /*Серия*/
      sym5                            no-label format "X(1)"             space(0)
      goods.unit-base                 no-label format "x(7)"             space(0) /*Единицы измерения*/
      sym6                            no-label format "X(1)"             space(0)
      price-list.doc-qnty             no-label format "->>>>>>>>9.<<"    space(0) /*Количество*/
      sym7                            no-label format "X(1)"             space(0)
      price-list.price-prev           no-label format "->>,>>>,>>9.99"   space(0) /*Цена до переоценки*/
      sym8                            no-label format "X(1)"             space(0)
      sum_before                      no-label format "->>,>>>,>>9.99"   space(0) /*Сумма до переоценки*/
      sym9                            no-label format "X(1)"             space(0)
      price-list.price-sale           no-label format "->>,>>>,>>9.99"   space(0) /*Новая цена*/
      sym10                           no-label format "X(1)"             space(0)
      sum_after                       no-label format "->>,>>>,>>9.99"   space(0) /*Сумма после переоценки*/
      sym11                           no-label format "X(1)"             space(0)
      ucenka                          no-label format "->,>>>,>>9.99"    space(0) /*Разница цен в случае уценки*/
      sym12                           no-label format "X(1)"             space(0)
      doocenka                        no-label format "->>,>>>,>>9.99"   space(0) /*Разница цен в случае дооценки*/
      sym13                           no-label format "X(1)"             space(0)
      comments                        no-label format "X(10)"            space(0) /*Примечания*/
      sym14                           no-label format "X(1)"             space(0)

      header  /*Заголовок таблицы*/
        "+-----+---------+------------------------------------------+------+-------+-----------+-----------------------------------------------------------+----------------------------+----------+" skip
        "|     |         |                                          |      |       |           |               Стоимость, руб. , коп.                      |                            |          |" skip
        "|  N  |   Код   |                                          |      |       |           +-----------------------------+-----------------------------+                            |          |" skip
        "|     |         |            Наименование товара           |Серия |Ед.изм.|Количество |        До переоценки        |       После переоценки      |          Разница           |Примечание|" skip
        "| п/п |   ОКДП  |                                          |      |       |           +--------------+--------------+--------------+--------------+-------------+--------------|          |" skip
        "|     |         |                                          |      |       |           |     Цена     |    Сумма     |     Цена     |    Сумма     |   Уценка    |   Дооценка   |          |" skip
        "+-----+---------+------------------------------------------+------+-------+-----------+--------------+--------------+--------------+--------------+-------------+--------------+----------+" skip
     
      with width 187 down stream-io no-box no-underline no-labels .



{ gbl/working.i }

run get-report-num in parparentproc (
    output g#report-num
).
run get-quest-print in parparentproc (
    output g#quest-print
).
{ gbl/rbisbase.i
    v-rb-is-base
}

find first price-doc no-lock /*Ищем запись по rec_id*/
      where recid(price-doc) = rec_id .
if not available price-doc
then do:
    bell.
    message 'Порушена табличка "price-doc"(r-akt.p).'.
    return error.
end.
assign
    v-price-doc-doc-num  = price-doc.doc-num
    v-price-doc-doc-date = price-doc.doc-date
.

find    clients no-lock 
  where clients.obj-code = price-doc.obj-code
    and clients.obj-type = price-doc.obj-type
.
if not available clients then
do:
    bell.
    message 'Порушена табличка "clients" (r-akt.p).'.
    return error.
end.

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_overvalue-cast_print':U
  {&cntxt-firm}
  v-cntxt-host-code-obj
  '':U
  0
  0
  0
  0
  false
  Log-Resym1
}

assign
    v-single-line = fill("-", 197)
.

{ cmp/open-out.i stream AktStr}

find    buf_clients no-lock  /*Получаем имя фирмы*/
  where buf_clients.obj-type = {&cmp}
    and buf_clients.obj-code = price-doc.host-code
no-error.
if available buf_clients
then do:
    assign  firm_name = buf_clients.obj-name.
end.


                   /*========================Вывод шапки документа========================*/
put stream AktStr    
    "БНФ №ТОРГ-7.1" at 175 skip
    "Наименование организации : " firm_name format "x(42)"   skip
    "Подразделение : " clients.obj-name skip
    skip
.  

put stream AktStr
    "АКТ" at 93 skip
    "О ПЕРЕОЦЕНКЕ ТОВАРОВ" at 84 skip
    "от '__' ____________ 20__ г." at 81 skip
    skip 
.

put stream AktStr 
{&new-line}
{&new-line}
    "Комиссия в составе: председатель ____________________________, члены комиссии _____________________________________________" at 37 skip
    "                                 (должность)       (Ф.И.О)                         (должность)             (Ф.И.О.)        " at 37 skip
    {&new-line}
    "на основании _____________________________ произвела переоценку товара по ___________________ ценам" at 44 skip
.


/*======================== Шапка сформирована ==========================*/

   /*------------------------  Строки  ------------------------------*/
        for each price-list no-lock
           where price-list.doc-num = price-doc.doc-num
          , each goods no-lock
           where goods.artic     = price-list.artic
             and goods.prod-type = price-list.prod-type
             and goods.prod-code = price-list.prod-code
        break by goods.grp-name by goods.artic descending
        :
             string_counter = string_counter + 1. /*Считаем строки*/
             sum_before = price-list.price-prev * price-list.doc-qnty.  /*Высчитываем сумму. Старая цена * Количество*/
             sum_after = price-list.price-sale * price-list.doc-qnty. /*Высчитываем сумму. Текущая цена * Количество */
             if price-list.price-prev > price-list.price-sale then do: /*Проверяем на уценку. Если да - прибавляем к сумме уценок*/
                 ucenka = -(price-list.price-prev - price-list.price-sale).
                 doocenka = 0.
                 end_sum_ucenka = end_sum_ucenka + ucenka.
             end.
             else do:
                 doocenka = price-list.price-sale - price-list.price-prev. /*Проверяем на доценку. Если да - прибавляем к сумме доценок*/
                 end_sum_doocenka = end_sum_doocenka + doocenka.
                 ucenka = 0.
             end.    
             end_sum_before = end_sum_before + sum_before. /*Вычисляем общую сумму до переоценки*/
             end_sum_after = end_sum_after + sum_after. /*Вычисляем общую сумму после переоценки*/     
             display stream AktStr
             sym1 string_counter sym2 goods.okdp sym3 goods.gds-name sym4 serial_num sym5 goods.unit-base sym6 price-list.doc-qnty sym7
             price-list.price-prev sym8 sum_before sym9 price-list.price-sale sym10 sum_after sym11 ucenka sym12 doocenka sym13 comments sym14
             with frame Akt-Cost. /*Выводим таблицу на экран*/
        end.      


    /*---------- Выводим Итого для таблицы ---------------*/
       put stream aktstr 
         "+-----------------------------------------------------------------+-------+-----------+--------------+--------------------------------------------+-------------+--------------+----------+" skip
         "|                                                          Итого :|    X  |     X     |       X      |"  end_sum_before format "->>,>>>,>>9.99"  "|      X       |" end_sum_after format "->>,>>>,>>9.99" "|" end_sum_ucenka format "->,>>>,>>9.99" "|"   end_sum_doocenka format "->>,>>>,>>9.99" "|          |" skip
         "+-----------------------------------------------------------------+-------+-----------+--------------+--------------+--------------+--------------+-------------+--------------+----------+" skip
       .

    /*---------- Выводим подвал таблицы ---------------*/
    put stream AktStr skip(5)
               "  Председатель комиссии :   ___________  _____________  ____________________"skip
               "                            (должность)    (подпись)          (Ф.И.О.)      "skip
               "          Члены комиссии: "skip
               "                            ___________  _____________  ____________________"skip
               "                            (должность)    (подпись)          (Ф.И.О.)      "skip
               skip
               "                            ___________  _____________  ____________________"skip
               "                            (должность)    (подпись)          (Ф.И.О.)      "
               skip
               "                            ___________  _____________  ____________________"skip
               "                            (должность)    (подпись)          (Ф.И.О.)      "
               skip 
               "                            ___________  _____________  ____________________"skip
               "                            (должность)    (подпись)          (Ф.И.О.)      " skip
               "Материально ответственное" skip
               "                   лицо :"skip
               "                            ___________  _____________  ____________________"skip
               "                            (должность)    (подпись)          (Ф.И.О.)      "
               skip .

output stream AktStr close.

{ gbl/stopwork.i }

{ rep/q-print.i 4}

end.
