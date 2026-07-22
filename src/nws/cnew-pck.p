block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cnew-pck.p $
$Archive: nws/cnew-pck.p $

Нарезка новых пакетов

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/23/04
Author: Dmitry Ukhanov
Creation date: 03/23/04

*/

define input  parameter p-db-list  as character no-undo . /* если возможно, то формируем пакеты только для этих БД */
define output parameter p-err-code as integer no-undo .   /* 0 - без ошибок, 1 - ошибка подготовки пакетов, 2 - ошибка backup */

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: cnew-pck.p $":U .
def var vss-archive     as character no-undo init "$Archive: nws/cnew-pck.p $":U .
def var vss-description as character no-undo init "Нарезка новых пакетов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ adm/auto-def.i }
{ adm/onlinbkp.i }

define temp-table tt-db-pck-cr no-undo
  field db-num      as integer
  field cre-all-pck as logical
  index pi as unique primary db-num
  index cr cre-all-pck
  .

do
on error undo, return error
:
  define variable v-ind                    as integer   no-undo .
  define variable num-entries-pres-db-list as integer   no-undo .
  define variable v-pres-db-list           as character no-undo .
  define variable v-err-gen-pack           as integer   no-undo .
  define variable v-message                as character no-undo .
  define variable v-msg                    as character no-undo .

  define variable v-need-bkp               as logical   no-undo .
  define variable v-db-num                 as integer   no-undo .
  define variable v-all-pck-cre            as logical   no-undo .

  define buffer buf_sys-ctrl for ub.sys-ctrl .

  find first buf_sys-ctrl no-lock .

  assign
    p-err-code = 0
  .

  if p-db-list <> ?
    and trim( p-db-list ) <> "":U
  then do:
    run check-need-onlinebkp in this-procedure
      ( output v-need-bkp
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении необходимости проведения onlinebkp" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
  end.
  else do:
    assign
      v-need-bkp = true
    .
  end.

  if buf_sys-ctrl.db-num = 0 then do:
    run nws/pres-db.p
      ( output v-pres-db-list
       ,output v-msg
      ) no-error .
    if error-status :error then do:
      assign
        v-pres-db-list = "":U
        p-err-code     = 1
      .
      return error substitute( "&1. Ошибка при подготовке списка действующих УБД &2&3&4"
                               ,vss-workfile
                               ,{&new-line}
                               ,error-status:get-message(error-status:num-messages)
                               ,{&new-line}
                               ,return-value
                             ) .
    end.
    if v-msg <> "":U  then do:
      if v-message = "":U then do:
        assign
          v-message = v-msg
        .
      end.
      else do:
        assign
          v-message = v-message + {&new-line} + v-msg
        .
      end.
    end.
  end.
  else do:
    assign
      v-pres-db-list = "0":U
    .
  end.

  for each tt-db-pck-cr
  on error undo, return error return-value
  :
    delete tt-db-pck-cr.
  end.
  assign
    num-entries-pres-db-list = num-entries( v-pres-db-list )
  .
  do v-ind = 1 to num-entries-pres-db-list
  on error undo, return error
  :
    assign
      v-db-num = integer( entry( v-ind, v-pres-db-list ) )
    .
    if v-need-bkp = true
      or ( v-need-bkp = false
           and lookup( string( v-db-num ), p-db-list ) > 0
         )
    then do:
      find first tt-db-pck-cr
        where tt-db-pck-cr.db-num = v-db-num
        no-error .
      if not available tt-db-pck-cr then do:
        create tt-db-pck-cr.
        assign
          tt-db-pck-cr.db-num      = v-db-num
          tt-db-pck-cr.cre-all-pck = false
          .

      end.
    end.
  end.
  assign
    v-all-pck-cre = false
  .

  /* формирование пакетов для всех БД */
  do while v-all-pck-cre <> true
  on error undo, return error
  :

    for each tt-db-pck-cr
      where tt-db-pck-cr.cre-all-pck = false
    on error undo, return error
    :
      if tt-db-pck-cr.cre-all-pck = false then do:
        if buf_sys-ctrl.db-num = 0 then do:
          assign
            add-log-file-name = substring( log-file-name, 1, r-index( log-file-name, '.':u) - 1 ) + substitute( "-&1.log", tt-db-pck-cr.db-num )
          .
        end.
        run nws/cre-pck.p
          ( input  tt-db-pck-cr.db-num
           ,output v-err-gen-pack
           ,output tt-db-pck-cr.cre-all-pck
          ) no-error .
        if error-status :error
          or v-err-gen-pack = 2
        then do:
          assign
            add-log-file-name = ?
            p-err-code = 1
          .
          return error substitute( "&1. Ошибка при подготовке нового(ых) пакета(ов) для БД &2&3&4&5&6"
                                  ,vss-workfile
                                  ,tt-db-pck-cr.db-num
                                  ,{&new-line}
                                  ,error-status:get-message(error-status:num-messages)
                                  ,{&new-line}
                                  ,return-value
                                ) .
        end.
        assign
          add-log-file-name = ?
        .
      end.
    end.
    run adm/onlinbkp.p
      ( output v-msg )
      no-error .
    if error-status :error then do:
      assign
        p-err-code = 2
      .
      return error substitute( "&1. Ошибка при проведении backup &2&3&4&5"
                                ,vss-workfile
                                ,{&new-line}
                                ,error-status:get-message(error-status:num-messages)
                                ,{&new-line}
                                ,return-value
                              ) .
    end.
    if v-msg <> "":U then do:
      if v-message = "":U then do:
        assign
          v-message = v-msg
        .
      end.
      else do:
        assign
          v-message = v-message + {&new-line} + v-msg
        .
      end.
    end.
    find first tt-db-pck-cr
      where tt-db-pck-cr.cre-all-pck = false
      no-error .
    if not available tt-db-pck-cr then do:
      assign
        v-all-pck-cre = true
      .
    end.
  end.
  return v-message .

end.

/* $Workfile: cnew-pck.p $ end */