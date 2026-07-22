/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получение параметров для работы с весами

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/21/05
Author: Bakhtadze Natalya
Creation date: 11/21/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/thbj-def.i }

procedure iniscals :
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define output parameter ini-types as character no-undo .
define output parameter ini-progs as character no-undo .
define output parameter rnd-znak as integer no-undo init 2.
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
v-tth = buffer thbjattr_thbj-attr:table-handle .

do
on error undo, return error return-value
:

{ str/sclspref.i varscales-pref varpgscales-pref }


conf-par = ?.
for each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
run adm/shattri.p (
    input "get":U
  ,input  p-obj-type
  ,input  p-obj-code
  ,input  {&attr-scale-inf}
  ,input  "":U /*p-param-code*/
  , output v-value-character
  , output v-value-date
  , output v-value-decimal
  , output v-value-integer
  , output v-value-logical
  , output v-param-type
  , INPUT-OUTPUT table-handle v-tth
  ) no-error .
IF error-status:error then do:
    message
    substitute("Ошибка при получении настроек, необъодимых для работы весов НА ОБЪЕКТЕ &1&2:&3&4 &5"
            , p-obj-type
            , p-obj-code
            , {&new-line}
            , error-status:get-message(1)
            , return-value )
    view-as alert-box error .
    undo, return error .
end.
assign
ini-progs = ?
ini-types = ?
.
for each thbjattr_thbj-attr where
        thbjattr_thbj-attr.obj-type = p-obj-type
    and thbjattr_thbj-attr.obj-code = p-obj-code
    and thbjattr_thbj-attr.upper-prop-code = {&attr-scale-inf}
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:
  case thbjattr_thbj-attr.prop-code:
    when {&attr-scale-inf_scales-type} then do:
      ini-types = thbjattr_thbj-attr.property-value-character.
    end.
    when {&attr-scale-inf_scales-pr} then do:
      ini-progs = thbjattr_thbj-attr.property-value-character.
    end.
  end case.
end.
if ini-types = ? then do:
  run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Ошибка! Не определены типы весов&1" +
                           "АРМ Администратор, Список фирм (Справочник магазинов), Измен. параметры, Параметры работы с весами"
                           , {&new-line}
                          )
                                          ).
  assign
  v-view-log = yes.
  return error .
end.
if ini-progs = ? then do:
  run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Ошибка! Не определены программы для работы с весами&1" +
                           "АРМ Администратор, Список фирм (Справочник магазинов), Измен. параметры, Параметры работы с весами"
                           , {&new-line}
                          )
                                          ).
  assign
  v-view-log = yes.
  return error .
end.

IF NUm-ENTRIES(ini-types) > NUm-ENTRIES(ini-progs) then do:
  run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Ошибка! Не определены программы для работы с весами для некоторых типов весов&1" +
                           "АРМ Администратор, Список фирм (Справочник магазинов), Измен. параметры, Параметры работы с весами"
                           , {&new-line}
                          )
                                          ).
  assign
  v-view-log = yes.
  return error .
end.
  { gbl/getsect.i run "''" 0 {&attr-nakl-glob} }
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = {&attr-nakl-glob_rnd-znk} then rnd-znak = thbjattr_thbj-attr.property-value-integer .
  end.
end.
end procedure. /* iniscals */

/* $Workfile$ e n d */