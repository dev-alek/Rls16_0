/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вызов редактирования параметров  настроек магазина (фирмы)

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/04/04
Author: Bakhtadze Natalya
Creation date: 10/04/04

требует включения { gbl/thbjattr.i }

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
define variable attr-label as character no-undo .         /*лабел атрибута */
define variable attr-user-can-edit as logical no-undo .  /*пользователь может изменять в броусе*/
define variable attr-output-display as logical no-undo .  /*виден в броусе*/
define variable attr-other as char no-undo .              /*еще чего - нибудь*/
define variable v-prop-list as character no-undo .
define variable v-prop-type-list as character no-undo .
define variable v-prop-label-list as character no-undo .
define variable v-global as logical no-undo .
define variable v-host as logical no-undo .
define variable v-shop as logical no-undo .
define variable v-store as logical no-undo .
define variable v-db as logical   no-undo .
define variable attr-value as char no-undo .              /*для знач по умолч*/
define variable v-spr as character no-undo .
define variable v-title as character no-undo .
define variable v-ii as integer no-undo .
define variable v-ok as integer no-undo .
define variable v-rid-list as character no-undo .
define variable v-rec as recid no-undo .
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-firm-code as integer   no-undo .
define variable v-from-obj-code  as integer no-undo .
define variable v-found as decimal no-undo .

define buffer buf_clients for ub.clients.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_shop for ub.shop.
define buffer buf_store for ub.store.
define buffer buf_db for ub.db.
do
on error undo, return error
:

assign
vattr-codes = "":U
vattr-labels = "":U
.
_II:
DO ii = 1 to num-entries({&thbjattr-list}):
  run thbjattr_code (
                       input entry(ii, {&thbjattr-list})
                      ,input   '':U
                      ,output  attr-label          /* лабел атрибута */
                      ,output  attr-user-can-edit  /* пользователь может изменять в броусе */
                      ,output  attr-output-display /* виден в броусе */
                      ,output  attr-other          /* еще чего - нибудь */
                      ,output v-prop-list
                      ,output v-prop-type-list
                      ,output v-prop-label-list
                      ,output v-global
                      ,output v-host
                      ,output v-shop
                      ,output v-store
                      ,output v-db
                    ) no-error.
    .
    if NOT error-status:error
    and attr-user-can-edit
    and index(attr-other, "spr-ext=") > 0
    anD (if p-obj-type = {&shop}
         then v-shop
         else (if p-obj-type = {&stock}
               then v-store
               else (if p-obj-type = {&cmp}
                     then v-host
                     else (if p-obj-type = {&db}
                          then v-db
                          else v-global)
                    )
               )
         ) then do:
      if entry(ii, {&thbjattr-list}) = {&attr-alias-tpsi} then do:
        { gbl/conf-rd.i
        "'tpsi'"
        0
        "''"
        0
        "''"
        "''"
        "''"
        no
        conf-par
        par-type
        no-error
        }
        if error-status:error
        or (conf-par <> "yes") then next _ii.
      end.
      assign
      vattr-codes = vattr-codes + {&comma-char} + entry(ii, {&thbjattr-list})
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
  RETURN ''.
end.
if p-mode = {&lookup}
or p-mode = {&update} then do:
  run thbjattr_code  in this-procedure (
       input   v-attr-code
      ,input   '':U
      ,output  attr-label          /* лабел атрибута */
      ,output  attr-user-can-edit  /* пользователь может изменять в броусе */
      ,output  attr-output-display /* виден в броусе */
      ,output  attr-other          /* еще чего - нибудь */
      ,output v-prop-list
      ,output v-prop-type-list
      ,output v-prop-label-list
      ,output v-global
      ,output v-host
      ,output v-shop
      ,output v-store
      ,output v-db
  ).
  do ii = 1 to num-entries(attr-other, {&slash-char}):
    if entry(ii, attr-other, {&slash-char}) begins "spr-ext=":U then do:
      assign
      v-spr = entry(2, entry(ii, attr-other, {&slash-char}), "=").
    end.
  end.
  run value(v-spr) (
                   input parparentproc
                  ,input p-mode
                  ,input p-obj-type
                  ,input p-obj-code
                  ).
end. /*lookup update*/
else do:
   if p-obj-type = {&shop} then do:
    message
    "Выберите магазин для копирования ПАРАМЕТРОВ"
    view-as alert-box WARNING.
      run adm/shops.w ( input parparentproc
                       ,input "b-sel"
                       ,input-output v-rid-list
                       ,no ).
     if v-rid-list = "":U then return.
     find first buf_shop no-lock where
              recid(buf_shop) = integer(v-rid-list) .
     v-from-obj-code = buf_shop.obj-code.
   end.
   if p-obj-type = {&cmp} then do:
      message
      "Выберите ФИРМУ для копирования ПАРАМЕТРОВ"
      view-as alert-box WARNING.
      run adm/sconfs.w (
            input parParentProc
          , input "b-sel":U
          , input no
          , input 0
          , output v-firm-code
          , input-output v-rid-list
      ) no-error.
      if v-rid-list = "":U then return.
    find first buf_sysconf no-lock
                      where recid(buf_sysconf) = integer(entry(1, v-rid-list)).
    v-from-obj-code = buf_sysconf.host-code.
   end.
   if p-obj-type = {&stock} then do:
    message
    "Выберите склад для копирования ПАРАМЕТРОВ"
    view-as alert-box WARNING.
      run adm/stores.w ( input parparentproc
                        ,input "b-sel"
                        ,input-output v-rid-list
                        ,input no ).
     if v-rid-list = "":U then return.
     find first buf_store no-lock where
              recid(buf_store) = integer(v-rid-list) .
     v-from-obj-code = buf_store.obj-code.
   end.
   if p-obj-type = {&db} then do:
      message
      "Выберите БД для копирования ПАРАМЕТРОВ"
      view-as alert-box WARNING.
      run adm/dbs.w (
            input parParentProc
          , input {&lookup}
          , output v-rec
      ) no-error.
      if v-rec = ? then return.
    find first buf_db no-lock
                      where recid(buf_db) = v-rec.
    v-from-obj-code = buf_db.db-num.
   end.

   if (p-obj-type = {&shop}
   AND p-obj-code = buf_shop.obj-code )
   or (p-obj-type = {&stock}
   AND p-obj-code = buf_store.obj-code )
   or (p-obj-type = {&cmp}
   AND p-obj-code = buf_sysconf.host-code )
   or (p-obj-type = {&db}
   AND p-obj-code = buf_db.db-num )
   or (p-obj-type = '':U
   AND p-obj-code = 0 )

   then do:
     message "Нельзя копировать ПАРАМЕТРЫ самих в себя"
     view-as alert-box error .
     return error .
   end.
   run waitfram-show in this-procedure ( input "Ждите..." ).
   DO ii = 1 to num-entries(v-attr-code):
      for each thbjattr_thbj-attr:
        delete thbjattr_thbj-attr.
      end.
      assign
      v-ii = v-ii + 1.
      run thbjattr_get-section  in this-procedure (
           input  p-obj-type
          ,input  v-from-obj-code
          ,input  entry(ii, v-attr-code)
          ,input '':U /*p-mode*/
          ,input-output table thbjattr_thbj-attr
          ,output v-found
                                              ) no-error .
      if not error-status:error then do:
        run thbjattr_set-section in this-procedure (
                                               input p-obj-type
                                              ,input p-obj-code
                                              ,input entry(ii, v-attr-code)
                                              ,input table thbjattr_thbj-attr ) no-error .
        if not error-status:error then
        assign
        v-ok = v-ok + 1
        .
      end.
   end. /*do ii*/
   run waitfram-hide in this-procedure .
   if v-ii = v-ok then do:
      message
      substitute("Скопировано &1 параметров с &4&5 на &2&3"
                 , v-ok
                 , p-obj-type
                 , p-obj-code
                 , p-obj-type
                 , v-from-obj-code
                 )
      view-as alert-box .
   end.
   else do:
      message
      substitute("Из &1 параметров удалось скопировать &2 параметров с &3&4 на &5&6"
                 , v-ii
                 , v-ok
                 , p-obj-type
                 , p-obj-code
                 , p-obj-type
                 , v-from-obj-code
                 )
      view-as alert-box WARNING.
   end.
end.
end. /*doe*/

end procedure. /* proc-b-attr */

/* $Workfile$ e n d */