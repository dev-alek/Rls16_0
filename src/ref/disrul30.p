block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: disrul30.p $
$Archive: ref/disrul30.p $

Запуск удаления правил скидок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/02/06
Author: Bakhtadze Natalya
Creation date: 04/02/06

*/

define parameter buffer bufp_dis-rule for ub.dis-rule.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: disrul30.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/disrul30.p $":U .
define variable vss-description as character no-undo init "Запуск удаления правил скидок".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

{ nws/db-rec.i   }
{ gbl/key-rec.i  }
{ gbl/waitfram.i }

define variable v-ii as integer no-undo .
define variable v-is as logical no-undo .
define variable v-ext-prg-handle as handle    no-undo .
define variable l-is-used as logical no-undo .
define variable v-is-remote-dbs as logical no-undo .
define variable v-obj-db-num like ub.clients.db-num no-undo .
define variable v-key-rec as character no-undo .
define variable v-param as character no-undo .
define variable v-list-db as character no-undo .
define variable v-sts-do as integer no-undo .
define variable v-sts-po as integer no-undo .
define variable v-can as logical no-undo .

define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_dis-thbj-rule for ub.dis-thbj-rule.

_main:
do
on error undo, return error return-value
:
  if bufp_dis-rule.obj-code > 0 then do:
    { gbl/objdbnum.i bufp_dis-rule.obj-type bufp_dis-rule.obj-code v-obj-db-num }
  end.
  if not can-find(first ub.db no-lock where ub.db.db-num > 0)
  or (g#db-num = 0 and v-obj-db-num = g#db-num )
  then do:
    run value( "trg/dis-rult.p":U ) persistent set v-ext-prg-handle .
  end.
  else do:
    assign
    v-is-remote-dbs = yes
    .
  end.
  _buf_dis-rule:
  for each buf_dis-rule where
          buf_dis-rule.rule-num = bufp_dis-rule.rule-num
  on error undo _main, return error:
    if v-is-remote-dbs then do:
      if buf_dis-rule.obj-code > 0
      and v-obj-db-num  > 0 then do:
        run ref/dis-rul3.p (
                      buffer buf_dis-rule
                      ,input yes
                      ,input yes /*p-silent*/
                      ,output v-can
                      ) no-error.
        if error-status:error then do:
          undo _main, return error  substitute("ПРАВИЛО СКИДОК №&1 не может быть удалено &2&3&2&4"
                                , buf_dis-rule.rule-num
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value ).
        end.
        if not v-can then do:
          undo _main, return error  substitute("ПРАВИЛО СКИДОК №&1 не может быть удалено &2&3"
                                , buf_dis-rule.rule-num
                                , {&new-line}
                                , return-value ).
        end.
      end.
      run gen-key-rec(
                       input {&table_dis-rule}
                      ,input (buffer buf_dis-rule:handle )
                      ,output v-key-rec
                    ) no-error.
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при генерации уникального ключа для правила скидок" skip
          substitute( "номер правила &1", buf_dis-rule.rule-num ) skip
          return-value
          view-as alert-box error .
        undo _main, return error.
      end.
      run get-db-list in this-procedure ( buffer buf_dis-rule, output v-list-db).
      assign
      v-param = string(buf_dis-rule.rule-num) + {&delim-par} +
                string(buf_dis-rule.sts) + {&delim-par} +
                v-list-db
      .
      assign
      v-sts-do = buf_dis-rule.sts.
      if g#db-num > 0 then do:
        define buffer buf_route for ub.route.
        /*на всякий случай проверим нет ли уже команды на запуск two-commit*/
        find first buf_route no-lock where
                  buf_route.name-rec = ("command":U + {&delim-nws}
                                        + "inquiry-two-commit":U + {&delim-nws}
                                        + {&delete_nu-dis-rule} + {&delim-nws}
                                        + v-key-rec + {&delim-nws}
                                        + v-param) no-error.
        if available buf_route then do:
          message
          substitute("Команда <Запуск удаления правила &1 из ГБД> уже отослана", buf_Dis-rule.rule-num)
          view-as alert-box warning.
          return no-apply.
        end.
      end.

      run nws/db-rec.p (
                          input {&delete_nu-dis-rule}
                          ,input v-key-rec
                          ,input v-param
                        ) no-error .
      assign
      v-sts-po = buf_dis-rule.sts.
      if v-sts-po = v-sts-do
      and not error-status:error
      and not (buf_dis-rule.obj-code > 0
          and v-obj-db-num  > 0 )
      then do:
        message
        return-value skip
        view-as alert-box error .
        undo _main, return error.
      end.
      if g#db-num > 0 then do:
        message
        substitute("Отослана команда <Запуск удаления правила &1 из ГБД>", buf_Dis-rule.rule-num)
        view-as alert-box.
      end.
    end. /*для системы с удаленками        */
    else do:
      run value( "proc-is-used-dis-rule" ) in v-ext-prg-handle (buffer buf_dis-rule, input g#db-num, output l-is-used) no-error .
      if not error-status:error
      and not l-is-used then do:
        run ref/dis-rul3.p (
                         buffer buf_dis-rule
                        ,input no /*p-sts-mode удаление а не проверка*/
                        ,input yes /*p-silent*/
                        ,output v-can
                        ) no-error .
      end.
      if not error-status:error
      and l-is-used then do:
        message
        return-value skip
        view-as alert-box error .
        undo _main, return error.
      end.
    end.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при удалении правила скидок" skip
        substitute( "номер правила &1", buf_dis-rule.rule-num ) skip
        return-value skip
        error-status :get-message(1)
        view-as alert-box error .
      undo _main, return error.
    end.
  end.
  if v-is-remote-dbs = no then
  delete procedure v-ext-prg-handle .
  run waitfram-hide in this-procedure .
end. /*doe*/

procedure get-db-list :
define parameter buffer buf_dis-rule for ub.dis-rule.
define output parameter p-list-db as character no-undo .
define buffer buf_clients for ub.clients.

  do
  on error undo, return error
  :

    if not (buf_dis-rule.obj-type = '':U
            and
            buf_dis-rule.obj-code = 0) then do:
      find first buf_clients no-lock where
                buf_clients.obj-type = buf_dis-rule.obj-type
            and buf_clients.obj-code = buf_dis-rule.obj-code no-error .
      if not available buf_clients then do:
        return error substitute("&1 Не найден объект &2&3 для правила скидки № &4"
                                ,vss-workfile
                                ,buf_dis-rule.obj-type
                                ,buf_dis-rule.obj-code
                                ,buf_dis-rule.rule-num ).
      end.
      if buf_clients.db-num = ? then do:
        return error substitute("&1 Неверный номер БД &2 для объекта &3&4 правила скидки № &5"
                                ,vss-workfile
                                ,{&question-mark}
                                ,buf_dis-rule.obj-type
                                ,buf_dis-rule.obj-code
                                ,buf_dis-rule.rule-num ).
      end.
      if buf_clients.db-num > 0 then
      assign
        p-list-db = string(0) + {&comma-char} + string(buf_Clients.db-num)
      .
    end.
    else do:
      assign
      p-list-db = {&question-mark}.
    end.
  end.

end procedure. /* get-db-list */