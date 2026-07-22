block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: e-sndreq.p $
$Archive: utl/e-sndreq.p $

Отправить запрос для распределённой проверки целостности остатков по товарам

Автор: Перваков Михаил Сергеевич
Дата создания: 03/21/05
Author: Mikhail Pervakov
Creation date: 03/21/05

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: e-sndreq.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/e-sndreq.p $":U .
define variable vss-description as character no-undo init "Отправить запрос для распределённой проверки целостности остатков по товарам".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/r-page1.i  }
{ gbl/waitfram.i }

define variable v-total-count  as integer   no-undo .
define variable v-select-count as integer   no-undo .
define variable v-db-num       as integer   no-undo .
define variable v-ok           as logical   no-undo .

define temp-table temp-object no-undo
  field obj-type as character
  field obj-code as integer

  index xpk is primary unique obj-type obj-code
  .

define buffer buf_obj-list for obj-list .
define buffer buf_temp-object for temp-object .

do
on error undo, return error return-value
:
  assign
    v-total-count  = 0
    v-select-count = 0
  .

  for each buf_obj-list
  on error undo, return error return-value
  :
    assign
      v-total-count = v-total-count + 1
    .
    { gbl/objdbnum.i
      buf_obj-list.obj-type
      buf_obj-list.obj-code
      v-db-num
    }
    if v-db-num <> 0
    then do:
      assign
        v-select-count = v-select-count + 1
      .
      create buf_temp-object .
      assign
        buf_temp-object.obj-type = buf_obj-list.obj-type
        buf_temp-object.obj-code = buf_obj-list.obj-code
      .
    end.
  end.


  if v-total-count = 0
  then do:
    message
      "Не выбрано ни одного объекта" skip
      "Запрос распределённой проверки целостности не может быть сформирован" skip
      view-as alert-box error .
    undo, return error return-value .
  end.


  if v-select-count = 0
  then do:
    message
      "Было выбрано объектов" v-total-count skip
      "Запрос распределённой проверки целостности может быть сформирован" skip
      "только для объектов из УБД" skip
      "Объектов из УБД - " v-select-count skip
      "Запрос распределённой проверки целостности не может быть сформирован" skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  assign
    v-ok = false
  .

  message
    "Было выбрано объектов" v-total-count skip
    "Запрос распределённой проверки целостности может быть сформирован" skip
    "только для объектов из УБД" skip
    "Объектов из УБД - " v-select-count skip
    "Отправить запрос распеределённой проверки целостности для объектов УБД?" skip
    view-as alert-box question buttons yes-no update v-ok .

  if v-ok = true
  then do:
    for each buf_temp-object
    on error undo, return error return-value
    :
      run waitfram-show in this-procedure
        (input  substitute("Отправка запроса информации о текущих остатках товара на объекте &1 &2"
                          ,buf_temp-object.obj-type
                          ,buf_temp-object.obj-code
                          )
        ) .
      run nws/cmdreqgd.p
        (input  buf_temp-object.obj-type
        ,input  buf_temp-object.obj-code
        ) .
    end.

    run waitfram-hide in this-procedure .

    message
      "Завершена отправка запроса распределённой проверки целостности для объектов УБД" skip
      "Объектов из УБД - " v-select-count skip
      "По завершении обмена новостями информацию о результатах проверки" skip
      "можно будет посмотреть в файлах" 'cmdcmpgd.err':u 'cmdcmpgd.log':u skip
      "в текущей директории системы обмена новостями" skip
      view-as alert-box information .
  end.

end.