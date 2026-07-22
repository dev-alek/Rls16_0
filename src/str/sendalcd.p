block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sendalcd.p $
$Archive: str/sendalcd.p $

Отправка на кассу изменений товаров или клиентов, накопленных в результате работы со справочниками

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/27/03
Author: Bakhtadze Natalya
Creation date: 06/27/03

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle as handle no-undo .
define input parameter p-parameter   as character no-undo .

/*
p-parameter включает

define input parameter p-gds as logical no-undo .
define input parameter p-dcard as logical no-undo .
define input parameter p-seller as logical no-undo .
define input parameter p-cashier as logical no-undo .

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sendalcd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/sendalcd.p $":U .
define variable vss-description as character no-undo init "Отправка на кассу изменений товаров или клиентов, накопленных в результате работы со справочниками".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }

define variable p-gds as logical no-undo .
define variable p-dcard as logical no-undo .
define variable p-seller as logical no-undo .
define variable p-cashier as logical no-undo .
define variable p-fgrp as logical no-undo .
define variable v-view-log as logical no-undo .
define variable log-file-name as character no-undo init "send-cd.txt".
define variable v-stop as logical no-undo .


define buffer buf_BatchProcess for ub.batchProcess .


assign
p-gds = (if entry(1, p-parameter, {&delim-par}) = "yes"
        then yes
        else (if entry(1, p-parameter, {&delim-par}) = "no"
              then no
              else ?)
        )
p-dcard = (if entry(2, p-parameter, {&delim-par}) = "yes"
        then yes
        else (if entry(2, p-parameter, {&delim-par}) = "no"
              then no
              else ?)
        )
p-seller = (if entry(3, p-parameter, {&delim-par}) = "yes"
        then yes
        else (if entry(3, p-parameter, {&delim-par}) = "no"
              then no
              else ?)
        )
p-cashier = (if entry(4, p-parameter, {&delim-par}) = "yes"
        then yes
        else (if entry(4, p-parameter, {&delim-par}) = "no"
              then no
              else ?)
        )

p-fgrp   = (if entry(5, p-parameter, {&delim-par}) = "yes"
        then yes
        else (if entry(5, p-parameter, {&delim-par}) = "no"
              then no
              else ?)
        )
no-error
.
if error-status:error
or p-gds = ?
or p-dcard = ?
or p-seller = ?
or p-cashier = ?
then return error.

run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "Пересылка на кассы БД &1 изменений, сделанных в справочнике", g#db-num )
                                      ).




if p-gds and  can-find (first  buf_BatchProcess no-lock
      where buf_BatchProcess.bp_type       = {&btpr-type-gds}
        and buf_BatchProcess.bp_status     = {&btpr-normal}
               ) then do:
    run set-title in p-log-handle (
          input "Отправка товаров на кассу"
                                   ).
  run trg/bt_gds.p (
                parparentproc
               , input p-log-handle
               ,no) no-error .
  if error-status:error or
  return-value = "yes":U then do:
    run set-view-log in p-log-handle(yes).
  end.
end.
run set-counter-value in p-log-handle ( input '':U ).
run hide-counter in p-log-handle.
run get-stop-state in p-log-handle (output v-stop).
if p-dcard
and not  v-stop
and can-find (first  buf_BatchProcess no-lock
      where buf_BatchProcess.bp_type       = {&btpr-type-dcard}
        and buf_BatchProcess.bp_status     = {&btpr-normal}
               ) then do:
    run set-title in p-log-handle (
          input 'Отправка информации по клиентским картам на кассу'
                                    ).
  run trg/bt_dcard.p (
                   input parparentproc
                 , input p-log-handle
                 , input no) no-error .
  if error-status:error or
  return-value = "yes":U then do:
    run set-view-log in p-log-handle(yes).
  end.
end.
run set-counter-value in p-log-handle ( input '':U ).
run hide-counter in p-log-handle.
if p-seller
and not  v-stop
and can-find (first  buf_BatchProcess no-lock
      where buf_BatchProcess.bp_type       = {&btpr-type-seller}
        and buf_BatchProcess.bp_status     = {&btpr-normal}
               ) then do:
    run set-title in p-log-handle (
          input 'Отправка информации по продавцам на кассу'
                                    ).

  run trg/bt_slr.p (
                 input parparentproc
                ,input p-log-handle
                ,input string(no)
                ) no-error .
  if error-status:error or
  return-value = "yes":U then do:
    run set-view-log in p-log-handle(yes).
  end.
end.
run set-counter-value in p-log-handle ( input '':U ).
run hide-counter in p-log-handle.
if p-cashier
and not  v-stop
and can-find (first  buf_BatchProcess no-lock
      where buf_BatchProcess.bp_type       = {&btpr-type-cashier}
        and buf_BatchProcess.bp_status     = {&btpr-normal}
               ) then do:
    run set-title in p-log-handle (
          input 'Отправка информации по кассирам на кассу'
                                    ).

  run trg/bt_cshr.p ( input parparentproc
                ,input p-log-handle
                ,input string(no)
                ) no-error .
  if error-status:error or
  return-value = "yes":U then do:
    run set-view-log in p-log-handle(yes).
  end.
end.
run set-counter-value in p-log-handle ( input '':U ).
run hide-counter in p-log-handle.
if p-fgrp
and not  v-stop
and can-find (first  buf_BatchProcess no-lock
      where buf_BatchProcess.bp_type       = {&btpr-type-fgrp}
        and buf_BatchProcess.bp_status     = {&btpr-normal}
               ) then do:
    run set-title in p-log-handle (
          input 'Отправка информации по группам блюд на кассу'
                                    ).

  run trg/bt_fgrp.p ( input parparentproc
                ,input p-log-handle
                ,input string(no)
                ) no-error .
  if error-status:error or
  return-value = "yes":U then do:
    run set-view-log in p-log-handle(yes).
  end.
end.
run set-counter-value in p-log-handle ( input '':U ).
run hide-counter in p-log-handle.



 run get-view-log in p-log-handle(output v-view-log).
{ str/cdviewlg.i
"'!!!При отсылке информации на кассы произошли ошибки!!!'"
"'send-cd.txt'" }