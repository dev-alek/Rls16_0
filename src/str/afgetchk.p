block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: afgetchk.p $
$Archive: str/afgetchk.p $

Закачка чеков в продажу и резервирование после приема чеков (пробития чеков на кассе)

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/28/09
Author: Bakhtadze Natalya
Creation date: 10/28/09

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: afgetchk.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/afgetchk.p $":U .
define variable vss-description as character no-undo init "Закачка чеков в продажу и резервирование после приема чеков (пробития чеков на кассе)".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ str/lib-def.i }
{ str/trdcalib.i }
{ str/tpsidoc.i "NEW SHARED"  proc }
{ str/dtlrestm.i "NEW SHARED" }
{ gbl/thbj-def.i }
{ gbl/cur-time.i }

&scop display-message ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~)


define variable p-obj-type as character no-undo .
define variable p-obj-code as integer no-undo .
define variable p-doc-code as character no-undo .


define variable log-file-name as character no-undo .
define variable v-inkas-code as character no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-start as logical no-undo .
define variable v-rid-list as character no-undo .
define variable v-len as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-obj-db-num as integer no-undo .
define variable l-shift-on as logical no-undo .
define variable v-ok as logical no-undo .
define variable v-parameter as character no-undo .


log-file-name = "ext-sale.log".


define new shared temp-table temp-inkas no-undo like ub.inkas.

{ str/sal-shd.i parparentproc p-log-handle }

define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_inkas for ub.inkas.
define buffer buf_shop for ub.shop.
DEFINE NEW SHARED BUFFER X_chk-doc FOR ub.chk-doc.

if num-entries(p-parameter, {&delim-par} ) <> 3 then do:
  &scop my-message substitute("&1 &2 &3&4Неверное кол-во entry в составном параметре p-parameter = &5, должно быть 3" ~
                              ,vss-workfile ~
                              ,vss-revision ~
                              ,vss-description ~
                              ,~{&new-line~} ~
                              , num-entries(p-parameter, {&delim-par} ) ~
                              )
  {&display-message}.
  {&set-error}.
  return.
end.
assign
p-obj-type = entry(1, p-parameter, {&delim-par})
p-obj-code = integer(entry(2, p-parameter, {&delim-par}))
p-doc-code = entry(3, p-parameter, {&delim-par})
no-error
.

if error-status:error then do:
  &scop my-message substitute("&1 &2 &3&4Ошибка при получении значение из составного параметра p-parameter:&4&5" ~
                              ,vss-workfile ~
                              ,vss-revision ~
                              ,vss-description ~
                              ,~{&new-line~} ~
                              , error-status:get-message(1) ~
                              )
  {&display-message}.
  {&set-error}.
  return.
end.


{ gbl/objdbnum.i p-obj-type p-obj-code v-obj-db-num no-error }
if error-status:error then do:
  {&set-error}.
  return.
end.

if v-obj-db-num <> g#db-num then do:
  &scop my-message substitute("&1 &2 &3&4Закачку и резервирование чеков можно сделать только в текущей БД" ~
                              ,vss-workfile ~
                              ,vss-revision ~
                              ,vss-description ~
                              ,~{&new-line~} ~
                              )
  {&display-message}.
  {&set-error}.
  return.
end.


{ gbl/curr-r-b.i
  v-curr-r-b
}
find first buf_shop no-lock where
          buf_shop.obj-code = p-obj-code no-error.
assign
l-shift-on = buf_shop.shift-on.

if l-shift-on then do:
define variable v-shift-date as date no-undo .
define variable v-shift-num as integer no-undo .
define variable v-shift-name as character no-undo .
  { gbl/curshift.i p-obj-type p-obj-code v-shift-date v-shift-num v-shift-name no-error }
  if not error-status:error then do:
    find first buf_inkas no-lock where
              buf_inkas.obj-type = p-obj-type
          and buf_inkas.obj-code = p-obj-code
          and buf_inkas.status_ = {&g___new}
          and buf_inkas.shift-date = v-shift-date
          and buf_inkas.shift-num = v-shift-num
          no-error.
  end.
end.
else do:
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
  run cur-time in this-procedure ( output v-today, output v-time).
    find first buf_inkas no-lock where
              buf_inkas.obj-type = p-obj-type
          and buf_inkas.obj-code = p-obj-code
          and buf_inkas.status_ = {&g___new}
          and buf_inkas.shift-date = v-today
          no-error.
end.
if not available buf_inkas then do:
  &scop my-message  substitute( "Создание нового документа продажи в &1&2..........." ~
                        , p-obj-type   ~
                        , p-obj-code  )
  {&display-message}.
  run str/cre-sale.p (
                      INPUT parparentproc
                    , INPUT p-obj-type
                    , INPUT p-obj-code
                    , INPUT {&add-def}
                    , input 'silent':U /*silent*/
                    , input '' /*p-shift-mode*/
                    , INPUT-output v-inkas-code
                    , INPUT {&cash-desk} ) no-error .
  if error-status:error then do:
    &scop my-message  substitute( "!!!Ошибка при создании документа продажи в &1&2&3" + ~
                            "&4 &5" ~
                          , p-obj-type  ~
                          , p-obj-code   ~
                          , ~{&new-line~} ~
                          , error-status:get-message(1) ~
                          , return-value )
    {&display-message}.
    return ''.
  end.
end.



run proc-step-100 in this-procedure (
                                        input  p-obj-type
                                      ,input  p-obj-code
                                      ,input  no /*p-process-only-new */
                                      ,input  no /*p-finalize   */
                                      ) no-error.
if error-status:error then do:
  &scop my-message substitute("&1 &2 &3&4ошибка при закачке чеков в продажу с &5 на &6&7:&4&8&4&9 " ~
                              ,vss-workfile ~
                              ,vss-revision ~
                              ,vss-description ~
                              ,~{&new-line~} ~
                              ,p-doc-code ~
                              ,p-obj-type ~
                              ,p-obj-code  ~
                              , error-status:get-message(1) ~
                              , return-value ~
                              )
  {&display-message}.
  return.
end.
if error-status:error then do:
&scop my-message substitute("&1 &2 &3&4ошибка при закачке чеков в продажу с &5 на &6&7:&4&8&4&9 " ~
                            ,vss-workfile ~
                            ,vss-revision ~
                            ,vss-description ~
                            ,~{&new-line~} ~
                            ,p-doc-code ~
                            ,p-obj-type ~
                            ,p-obj-code  ~
                            , error-status:get-message(1) ~
                            , return-value ~
                            )
  {&display-message}.
  return.
end.
/*теперь резервируем*/

&scop my-message  substitute( "Резервирование документа продажи в &1&2..........." ~
                      , p-obj-type ~
                      , p-obj-code ~
                      )
{&display-message}.

run proc-step-200 in this-procedure(
                                    input p-obj-type
                                    ,input p-obj-code
                                    ,input no /*p-process-only-new*/
                                    ,input no /*v-finalize-200*/ )  no-error .
if error-status:error then do:
  &scop my-message substitute( "!!!Ошибка при резервировании документа продажи &1&2&3&4 &5" ~
                        , p-obj-type ~
                        , p-obj-code ~
                        , ~{&new-line~} ~
                        , error-status:get-message(1) ~
                        , return-value ~
                        )
  {&display-message}.
  return.
end.