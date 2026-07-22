/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вызов редактирования параметров  настроек склада

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 11/24/04

требует включения { gbl/clntattr.i }
*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure proc-b-attr{1} :
define input parameter p-mode as character no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define variable v-sts as integer no-undo .
define variable vattr-codes as character no-undo .
define variable vattr-labels as character no-undo .
define variable ii as integer no-undo .
define variable v-attr-code like ub.clients-attr.attr-code no-undo .
define variable attr-type as character no-undo . /*тип атрибута*/
define variable attr-format as character no-undo .  /* формат атрибута*/
define variable attr-label as character no-undo .         /*лабел атрибута */
define variable attr-user-can-edit as logical no-undo .  /*пользователь может изменять в броусе*/
define variable attr-output-display as logical no-undo .  /*виден в броусе*/
define variable attr-other as char no-undo .              /*еще чего - нибудь*/
define variable attr-value as char no-undo .              /*для знач по умолч*/
define variable v-spr as character no-undo .
define variable v-title as character no-undo .
define variable v-ii as integer no-undo .
define variable v-ok as integer no-undo .
define variable v-rid-list as character no-undo .

define buffer buf_clients for ub.clients.
define buffer buf_sysconf for ub.sysconf.
do
on error undo, return error
:

assign
vattr-codes = "":U
vattr-labels = "":U
.
DO ii = 1 to num-entries({&clntattr-list}):
  run clntattr-code (
                      input entry(ii, {&clntattr-list})
                      ,output  attr-type           /* тип атрибута */
                      ,output  attr-format         /* формат атрибута */
                      ,output  attr-label          /* лабел атрибута */
                      ,output  attr-user-can-edit  /* пользователь может изменять в броусе */
                      ,output  attr-output-display /* виден в броусе */
                      ,output  attr-other          /* еще чего - нибудь */
                    ) no-error.
    if NOT error-status:error anD lookup("store":U , attr-other, {&slash-char}) > 0 then do:
        assign
        vattr-codes = vattr-codes + {&comma-char} + entry(ii, {&clntattr-list})
        vattr-labels = vattr-labels + {&comma-char} + attr-label
        .
    end.
end.
CASE p-mode:
  when {&lookup} then do:
    assign
    v-title = "Выберите типы параметров для просмотра".
  end.
  when {&update} then do:
    assign
    v-title = "Выберите типы параметров для редактирования".
  end.
  when  {&add-copy} then do:
    assign
    v-title = "Выберите типы параметров для копирования".
  end.

END CASE.
run gbl/d-list.w (
              INPUT (if p-mode = {&add-copy} then "b-sel,b-mark":U else "b-sel":U)
              ,INPUT v-title
              ,INPUT vattr-codes
              ,INPUT vattr-labels
              ,INPUT {&comma-char}
              ,INPUT "":U
              ,output v-attr-code).
IF v-attr-code = "":u THEN do:
  RETURN error.
end.
if p-mode = {&lookup}
or p-mode = {&update} then do:
  run clntattr-code  in this-procedure (
      input   v-attr-code
      ,output  attr-type           /* тип атрибута */
      ,output  attr-format         /* формат атрибута */
      ,output  attr-label          /* лабел атрибута */
      ,output  attr-user-can-edit  /* пользователь может изменять в броусе */
      ,output  attr-output-display /* виден в броусе */
      ,output  attr-other          /* еще чего - нибудь */
  ).
  do ii = 1 to num-entries(attr-other, {&slash-char}):
    if entry(ii, attr-other, {&slash-char}) begins "spr-ext=":U then do:
      assign
      v-spr = entry(2, entry(ii, attr-other, {&slash-char}), "=").
    end.
  end.
    run value ( v-spr )
              ( input parparentproc
                ,p-mode
                ,p-obj-type
                ,p-obj-code
                ).
end. /*lookup update*/
else do:
   message
   "Выберите Склад для копирования ПАРАМЕТРОВ. С этого склада будем копировать на текущий."
   view-as alert-box WARNING.

    run ref/cli-all.w
                   (  parparentproc
                    ,"b-sel"
                    ,p-obj-type
                    ,{&all}
                    ,{&current}
                    ,?
                    ,",,,,,,NO,,"
                    ,"lock-cli-type"
                    , output v-rid-list ) .
   if v-rid-list = "":U then return.
   find first buf_clients no-lock
                    where recid(buf_clients) = integer(entry(1, v-rid-list)).
   if p-obj-type = buf_clients.obj-type
   AND p-obj-code = buf_clients.obj-cod then do:
     message "Нельзя копировать ПАРАМЕТРЫ самих в себя"
     view-as alert-box error .
     return error .
   end.
   if buf_clients.obj-type <> p-obj-type then do:
     if p-obj-type = {&stock} then
     message
     "Для копирования ПАРАМЕТРОВ можно выбрать только Склад"
     view-as alert-box error .
     if p-obj-type = {&cmp}  then
     message
     "Для копирования ПАРАМЕТРОВ можно выбрать только СВОЮ ФИРМУ"
     view-as alert-box error .
     return error .
   end.
   if p-obj-type = {&cmp} then do:
    find first buf_sysconf no-lock where
              buf_sysconf.host-code = buf_clients.obj-code no-error .
    if not available buf_sysconf then do:
     message
     "Для копирования ПАРАМЕТРОВ можно выбрать только СВОЮ ФИРМУ"
     view-as alert-box error .
     return error .
    end.
   end.
   run waitfram-show in this-procedure ("Ждите..." ).
   DO ii = 1 to num-entries(v-attr-code):
      assign
      v-ii = v-ii + 1.
      run clntattr-value  in this-procedure (
           input   {&stock}
          ,input   buf_clients.obj-code
          ,input   entry(ii, v-attr-code)
          ,output attr-value
          ,output attr-type
                                              ) no-error .

      if not error-status:error then do:
        run clntattr-write in this-procedure (
                                               input p-obj-type
                                              ,input p-obj-code
                                              ,input entry(ii, v-attr-code)
                                              ,input attr-value    ) no-error .
        if not error-status:error then
        assign
        v-ok = v-ok + 1
        .
        if entry(ii, v-attr-code) = {&attr-alias-type-price} then do:
          run clntattr-value  in this-procedure (
               input   {&stock}
              ,input   buf_clients.obj-code
              ,input   {&attr-alias-object-price}
              ,output  attr-value
              ,output  attr-type   ) no-error .
              if not error-status:error then do:
                run clntattr-write in this-procedure (
                     input p-obj-type
                    ,input p-obj-code
                    ,input {&attr-alias-object-price}
                    ,input attr-value    ) no-error .
             end.
        end.
      end.
   end. /*do ii*/
   run waitfram-hide in this-procedure .
   if v-ii = v-ok then do:
      message
      substitute("Скопировано &1 параметров с &4&5  на  &2&3", v-ok, p-obj-type, p-obj-code, p-obj-type, buf_clients.obj-code)
      view-as alert-box .
   end.
   else do:
      message
      substitute("Из &1 параметров удалось скопировать &2 параметров с   &5&6 на &3&4", v-ii, v-ok, p-obj-type, p-obj-code, buf_Clients.obj-type, buf_clients.obj-code)
      view-as alert-box WARNING.
   end.
end.
end. /*doe*/

end procedure. /* proc-b-attr */
/* $Workfile$ e n d */