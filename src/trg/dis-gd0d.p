block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление таблицы dis-gds-rule-attr

Автор: Белоусов Илья Александрович
Дата создания: 01/11/07
Author: Ilia Belousov
Creation date: 01/11/07

*/

TRIGGER PROCEDURE FOR DELETE OF ub.dis-gds-rule-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление таблицы dis-gds-rule-attr".

define variable out       as character no-undo .
define variable out2      as character no-undo .
define variable in_       as character no-undo .
define variable spl       as character no-undo .
define variable sav       as character no-undo .
define variable v-remote  as character no-undo .
define variable v-obj-lst as character no-undo init ''.

def buffer buf_dis-gds-rule      for ub.dis-gds-rule .
def buffer buf_dis-rule          for ub.dis-rule .
def buffer buf_cash-desk         for ub.cash-desk .
def buffer buf_clients           for ub.clients .

{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/cur-time.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    run nws/cmd-del.p
      ( input {&table_dis-gds-rule-attr}
      ,input (buffer ub.dis-gds-rule-attr:handle)
      ,input "":U
      ) no-error .
    if error-status :error then do:
      return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
  end.

  /*передача данных на кассу*/
  find first buf_dis-gds-rule no-lock
  where buf_dis-gds-rule.gds-code    = ub.dis-gds-rule-attr.gds-code
    and buf_dis-gds-rule.obj-type    = ub.dis-gds-rule-attr.obj-type
    and buf_dis-gds-rule.obj-code    = ub.dis-gds-rule-attr.obj-code
    and buf_dis-gds-rule.pos-type    = ub.dis-gds-rule-attr.pos-type
    and buf_dis-gds-rule.discnt-role = ub.dis-gds-rule-attr.discnt-role
    and buf_dis-gds-rule.nonunique   = ub.dis-gds-rule-attr.nonunique no-error.
  if avail buf_dis-gds-rule then do:
      /*Удаление с кассы бонусов 91*/
      if buf_dis-gds-rule.templ-rl-root = 91 and buf_dis-gds-rule.pos-type = {&cd-type-ncr-as-r} then do:
          /*если правило на фирму или глобальное*/
          if buf_dis-gds-rule.obj-type = {&cmp} or buf_dis-gds-rule.obj-type = '' then do:
              for each buf_clients no-lock
              where buf_clients.db-num = g#db-num
                and ( buf_clients.obj-type = {&shop} or buf_clients.obj-type = {&stock} )
                and ( if buf_dis-gds-rule.obj-type = {&cmp} then buf_clients.host-code = buf_dis-gds-rule.obj-code else true )
              :
                  assign v-obj-lst = v-obj-lst + ( if v-obj-lst = '' then '' else {&delim-par} ) + string(buf_clients.obj-code) .
              end. /*for each buf_clients*/
          end.
          else  assign v-obj-lst = string(buf_dis-gds-rule.obj-code) .

          for each buf_cash-desk no-lock
          where lookup( string(buf_cash-desk.obj-code), v-obj-lst, {&delim-par} ) > 0  /*buf_cash-desk.obj-code = buf_dis-gds-rule.obj-code*/
            and buf_cash-desk.db-num   = g#db-num
            and buf_cash-desk.pos-type = {&cd-type-ncr-as-r}
            and buf_cash-desk.cash-on
          break by buf_cash-desk.obj-code
          :
              if first-of(buf_cash-desk.obj-code) then do:
                   run str/get-inis.p (
                                   input {&shop}
                                 , input buf_cash-desk.obj-code
                                 , input buf_cash-desk.pos-type
                                 , input buf_cash-desk.remote
                                 , input "send":U /*некий параметр который говорит для чего нам настройки*/
                                 , output out
                                 , output out2
                                 , output in_
                                 , output spl
                                 , output sav
                                 , output v-remote
                                 )  no-error .
                   if not error-status:error then do:
                       run str/ncr-bnsd.p (
                            string( recid(buf_dis-gds-rule) ) + {&delim-par} +
                            out + {&delim-par} +
                            ub.dis-gds-rule-attr.attr-code + {&delim-par} +
                            ub.dis-gds-rule-attr.attr-value
                            ) no-error.
                   end.
              end.
          end. /*for each buf_cash-desk*/
      end. /*правило 91*/
  end. /*if avail buf_dis-gds-rule*/
  else assign error-status:error = true.

  if error-status :error then do:
      return error substitute( "&1. Ошибка при передачи данных об удалении записи на кассу. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
  end.

end. /* main-block */
