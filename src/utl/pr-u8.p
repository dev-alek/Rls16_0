block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: pr-u8.p $
$Archive: utl/pr-u8.p $

Проверка простановки налогов по price-list
ЗАПУСКАЕТСЯ ИЗ ТРЕЙД_ХАУСА !!!


Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 06/27/03 12:01

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pr-u8.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/pr-u8.p $":U .
define variable vss-description as character no-undo init "Проверка простановки налогов по price-list".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/r-page1.i   }
define frame a.
define buffer a-price-list for price-list.
define buffer a-doc-line for doc-line.

define variable  p-d-n like    price-doc.doc-num no-undo.
define variable g#ok as logical no-undo .
message "Эта утилита проверяет наличие налогов в переоценке и при отсутствии их ,"
         "проставляет ставки налогов на конец дня , когда документ был закрыт ."

        skip  "Будем запускать утилиту ? "
        view-as alert-box question
        button yes-no
        update g#ok
        .
if g#ok = false then return.



view frame a.
define stream errstream.
define stream liststream.


define variable p-date as date no-undo .
define variable p-hostcode as integer no-undo .

define variable local_vat-pc as decimal no-undo .
define variable local_slt-pc as decimal no-undo .
define buffer buf-goods  for goods.

define variable f-o-1 as decimal no-undo .
define variable f-o-2 as decimal no-undo .
define variable err-file as character no-undo .
define variable list-file as character no-undo .

define variable l-err as integer no-undo .
define variable l-all as integer no-undo .
define variable l-chg as integer no-undo .
l-err = 0 .
l-all = 0 .
l-chg = 0 .


err-file  =  session:temp-directory + "prlist.err"  .
list-file =  session:temp-directory + "prlist.lst"  .

OUTPUT STREAM errstream TO VALUE(err-file).
OUTPUT STREAM liststream TO VALUE(list-file).

run factord-end-day (
   input   x-date-start - 1 ,
   output  f-o-1      )  .
run factord-end-day (
   input   x-date-end ,
   output  f-o-2      )  .




 for each obj-list :
              for each a-price-list  exclusive-lock  where
                                              a-price-list.obj-code = obj-list.obj-code  and
                                              a-price-list.obj-type = obj-list.obj-type  and
                                              a-price-list.fact-order >= f-o-1 and
                                              a-price-list.fact-order <= f-o-2 and
                                            (( a-price-list.vat-pc = ?  or  a-price-list.slt-pc = ? )
                                            ) :
                find first buf-goods no-lock where
                          a-price-list.artic      = buf-goods.artic and
                          a-price-list.prod-type  = buf-goods.prod-type and
                          a-price-list.prod-code  = buf-goods.prod-code  no-error .
                       if error-status :error then do:
                                put STREAM errstream  "Не удается найти товар "
                                a-price-list.artic
                                a-price-list.prod-type
                                a-price-list.prod-code
                                a-price-list.doc-num
                                a-price-list.obj-type
                                a-price-list.obj-code
                                skip.
                          next.
                        end.

                  run factord-to-date  (
                    input  a-price-list.fact-order ,
                    output p-date        ).

              { gbl/hostcode.i    a-price-list.obj-type
                              a-price-list.obj-code
                              p-hostcode
                              no-error }
              if error-status :error then
                put STREAM errstream  "Не удается определить host-code "
                a-price-list.doc-num
                a-price-list.obj-type
                a-price-list.obj-code   skip.


              { gbl/pftxvalg.i    buf-goods.gds-code
                              {&vat-tax-code}
                              p-date
                              p-hostcode
                              a-price-list.obj-type
                              a-price-list.obj-code
                              local_vat-pc
                              no-error }
                if error-status :error then do:
                  local_vat-pc = ?.
                  put STREAM errstream  "Не удается определить налог "
                  {&vat-tax-code}
                  buf-goods.gds-code
                  a-price-list.doc-num
                  a-price-list.obj-type
                  a-price-list.obj-code
                  skip.
                end.

              { gbl/pftxvalg.i    buf-goods.gds-code
                              {&slt-tax-code}
                              p-date
                              p-hostcode
                              a-price-list.obj-type
                              a-price-list.obj-code
                              local_slt-pc
                              no-error }
                if error-status :error then do:
                    local_slt-pc = ?.
                  put STREAM errstream  "Не удается определить налог "
                  {&slt-tax-code}
                  buf-goods.gds-code
                  a-price-list.doc-num
                  a-price-list.obj-type
                  a-price-list.obj-code
                  skip.
                end.
                if local_vat-pc <> ? and local_slt-pc <> ? then do:
                          assign
                                a-price-list.vat-pc    = local_vat-pc
                                a-price-list.slt-pc    = local_slt-pc
                                l-chg = l-chg  + 1.
                          .
                        export STREAM liststream
                            a-price-list.obj-code
                            a-price-list.obj-type
                            buf-goods.gds-code
                            a-price-list.fact-order
                            a-price-list.vat-pc
                            a-price-list.slt-pc
                            .
                end.
                l-all = l-all  + 1.
                              if (local_vat-pc = ? and   local_slt-pc = ? )  then do:
                                l-err = l-err  + 1.
                                export STREAM errstream
                                    a-price-list.obj-code
                                    a-price-list.obj-type
                                    buf-goods.gds-code
                                    a-price-list.fact-order
                                    local_vat-pc
                                    local_slt-pc
                                    .
                              end.

              end.
end.
message "Обработано : " l-all Skip
        "Исправлено : " l-chg  skip
        "Ошибки     : " l-err skip
        "Список исправлений в файле "  list-file skip
        "Список ошибок в файле " err-file skip
        view-as alert-box .
OUTPUT STREAM errstream CLOSE .
OUTPUT STREAM liststream CLOSE .

/*----------------------------------------------------------------------------------------------------------------------*/
{ trg/factord.i }