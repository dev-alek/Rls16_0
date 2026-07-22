/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка уникальности объектной АМ

Автор: Чернова Светлана Александровна
Дата создания: 03/20/07
Author: Svetlana Chernova
Creation date: 03/20/07

tb-assortment-matrix   /*в БД */
wt-assortment-matrix  /* в пакете */

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

 /* проверим что кустом не ходит*/
  if l-counter <> 0 then do:
  return error vss-workfile + {&space-char}
              + vss-revision + {&space-char}
              + vss-description + {&new-line}
              + "Ошибка обработки записи" + {&space-char}
              + {&table_assortment-matrix} + {&new-line}
              + "Есть привязанные записи, а обработка идет для одной".
  end.

  if g#news then do:    /* прием  */
     /* если не шаблон надо проверить наличие такого же на объекте */
     if wt-assortment-matrix.asmt-type = {&type-assmatr-obj} and wt-assortment-matrix.asmt-status = 0  then do:
        find first buf_old_assortment-matrix no-lock where
                   buf_old_assortment-matrix.asmt-status = 0 and
                   not
                  ( buf_old_assortment-matrix.asmt-id    = wt-assortment-matrix.asmt-id  and
                    buf_old_assortment-matrix.db-num     = wt-assortment-matrix.db-num )
                    and
                   buf_old_assortment-matrix.obj-type    = wt-assortment-matrix.obj-type and
                   buf_old_assortment-matrix.obj-code    = wt-assortment-matrix.obj-code and
                   buf_old_assortment-matrix.asmt-type    = wt-assortment-matrix.asmt-type no-error .
        if available buf_old_assortment-matrix then do:
        if g#db-num = 0  then
           run write-to-log in p-imp-handle (
           substitute(">> Пришедшая АМ: &1 по объекту &2&3 противоречит существующей АМ: &4 , АМ УБД будет принята в статусе УДАЛЕНа <<" ,
           wt-assortment-matrix.asmt-id,
           wt-assortment-matrix.obj-type,
           wt-assortment-matrix.obj-code,
           buf_old_assortment-matrix.asmt-id )) .
         else
           run write-to-log in p-imp-handle (
           substitute(">> Пришедшая АМ: &1 по объекту &2&3 противоречит существующей АМ: &4 , статус АМ УБД в следующем сеансе связи будет изменен на УДАЛЕН <<" ,
           wt-assortment-matrix.asmt-id,
           wt-assortment-matrix.obj-type,
           wt-assortment-matrix.obj-code,
           buf_old_assortment-matrix.asmt-id )) .

       end.
     end.
  end.
/*-----------------------------------------------------------------------------------------------------------------------*/
  if not available tb-assortment-matrix then do:
    create tb-assortment-matrix.
    assign compare-log = no.
  end.
  else do:
    buffer-compare tb-assortment-matrix TO wt-assortment-matrix case-sensitive save result in compare-log no-error.
  end.
  if not compare-log then do:
    buffer-copy wt-assortment-matrix TO tb-assortment-matrix.
  end.
/* $Workfile$ e n d */