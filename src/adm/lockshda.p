block-level on error undo, throw.
/*

$Revision: aeb9a0c708e2, 18, test $
$Author: SKiryxin $
$Date: Wed Mar 05 12:57:20 2014 +0300 $
$Workfile: lockshda.p $
$Archive: adm/lockshda.p $

Блокировка атрибутов расписаниЯ

Автор: Хныкин Павел Андреевич
Дата создания: 06/23/09
Author: Pavel Khnykin
Creation date: 06/23/09

*/
define input parameter  p-db-num         as integer    no-undo .
define input parameter  p-task-type      as character  no-undo.
define input parameter  p-task-num       as integer    no-undo.
define input parameter  p-code           as character  no-undo.
define parameter buffer pbuf_schedule-attr for ub.schedule-attr.


def var vss-revision    as character no-undo init "$Revision: aeb9a0c708e2, 18, test $":U .
def var vss-author      as character no-undo init "$Author: SKiryxin $":U .
def var vss-date        as character no-undo init "$Date: Wed Mar 05 12:57:20 2014 +0300 $":U .
def var vss-workfile    as character no-undo init "$Workfile: lockshda.p $":U .
def var vss-archive     as character no-undo init "$Archive: adm/lockshda.p $":U .
def var vss-description as character no-undo init "Блокировка атрибутов расписаниЯ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4':u,p-db-num,p-task-type,p-task-num,p-code )" }
{ cmp/str-glbl.i }
{ ref/shd-attr.i }

define variable v-incr as logical no-undo. /* для инкрементальной выгрузки */
define variable v-param-list as character no-undo.
define variable v-param-type as character no-undo.

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  /* Ищем атрибут */
  find first pbuf_schedule-attr exclusive-lock
    where pbuf_schedule-attr.cre-db-num  = p-db-num
      and pbuf_schedule-attr.task-type   = p-task-type
      and pbuf_schedule-attr.task-num    = p-task-num
      and pbuf_schedule-attr.attr-code   = p-code
  no-wait
  no-error .
  if not available pbuf_schedule-attr
  then do:
    if locked pbuf_schedule-attr
    then do:
      
      /* Если это инкрементальная выгрузка, то всё нормально */
      
      run schedule-attr-value in this-procedure ( input p-db-num
                                                , input p-task-type
                                                , input p-task-num
                                                , input p-code
                                                , output v-param-list
                                                , output v-param-type
                                                ).
      run schedule-attr-extract-logical in this-procedure ( input 17
                                                          , input v-param-list
                                                          , output v-incr
                                                          ).
      if not v-incr then do: /* Если не инкрементальная - ругаемся */
      return error substitute( "&1. Другой пользователь работает с параметрами расписания. Параметры расписания &2|&3|&4|&5"
                             , vss-workfile
                             , p-db-num
                             , p-task-type
                             , p-task-num
                             , p-code
                             ) .
      end.
      else return.
    end.
    else do:
      return error substitute( "&1. Параметры расписания не найдены. &2|&3|&4|&5"
                             , vss-workfile
                             , p-db-num
                             , p-task-type
                             , p-task-num
                             , p-code
                             ) .
    end.
  end.

  find current pbuf_schedule-attr share-lock.
  return.
end.