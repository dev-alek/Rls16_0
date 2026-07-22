/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры работы с data-relation

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/05/08
Author: Bakhtadze Natalya
Creation date: 11/05/08

*/


procedure tmpreld2_query :
define  parameter buffer buf_temp-rel-handle for temp-rel-handle.
define input-output parameter p-child-qh as handle no-undo .
define variable glog as logical no-undo .
define variable v-mess as character no-undo .
_main:
do
on error undo, return error
:

  /*должны родить запрос для child буфера*/
  create query p-child-qh .
  glog = p-child-qh:set-buffers( buf_temp-rel-handle.child-buffer-handle) no-error.
  if error-status:error
  or
  not glog then do:
    v-mess = substitute("Ошибка при попытке получить записи &1&2&3"
                        , buf_temp-rel-handle.child-buffer_
                        , {&new-line}
                        , error-status:get-message(1)
                        ).
    delete object p-child-qh no-error.
    undo _main, return error v-mess.
  end.
  glog = p-child-qh:query-prepare( substitute( "for each &1 &2 "
                                            , buf_temp-rel-handle.child-buffer_
                                            , buf_temp-rel-handle.where-string_
                                            )) no-error .
  if error-status:error
  or
  not glog then do:
    v-mess =  substitute("Ошибка при попытке получить записи &1&2&3"
                        , buf_temp-rel-handle.child-buffer_
                        , {&new-line}
                        , error-status:get-message(1)
                        ).
    delete object p-child-qh no-error.
    undo _main, return error v-mess.
  end.
  glog = p-child-qh:query-open no-error .
  if error-status:error
  or
  not glog then do:
    v-mess = substitute("Ошибка при попытке получить записи &1&2&3"
                        , buf_temp-rel-handle.child-buffer_
                        , {&new-line}
                        , error-status:get-message(1)
                        ).
    delete object p-child-qh no-error.
    undo _main, return error v-mess.
  end.
end.

end procedure. /* tmpreld2_query */
