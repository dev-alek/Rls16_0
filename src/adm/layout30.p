block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: layout30.p $
$Archive: adm/layout30.p $

Запуск удаления раскладок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/27/08
Author: Bakhtadze Natalya
Creation date: 10/27/08

*/

define parameter buffer bufp_layout for ub.layout.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: layout30.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/layout30.p $":U .
define variable vss-description as character no-undo init "Запуск удаления раскладок".
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
define variable v-key-rec as character no-undo .
define variable v-param as character no-undo .
define variable v-list-db as character no-undo .
define variable v-sts-do as integer no-undo .
define variable v-sts-po as integer no-undo .
define variable v-can as logical no-undo .

define buffer buf_layout for ub.layout.
define buffer buf_dis-thbj-rule for ub.dis-thbj-rule.

_main:
do
on error undo, return error return-value
:
  if not can-find(first ub.db no-lock where ub.db.db-num > 0)
  then do:
  end.
  else do:
    assign
    v-is-remote-dbs = yes
    .
  end.
  _buf_layout:
  for each buf_layout where
          buf_layout.layout-id = bufp_layout.layout-id
  on error undo _main, return error:
    if v-is-remote-dbs then do:
      run gen-key-rec(
                       input {&table_layout}
                      ,input (buffer buf_layout:handle )
                      ,output v-key-rec
                    ) no-error.
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при генерации уникального ключа для РАСКЛАДКИ" skip
          substitute( "ID РАСКЛАДКИ &1", buf_layout.layout-id ) skip
          return-value
          view-as alert-box error .
        undo _main, return error.
      end.
      run get-db-list in this-procedure ( buffer buf_layout, output v-list-db).
      assign
      v-param = string(buf_layout.layout-id) + {&delim-par} +
                string(buf_layout.sts) + {&delim-par} +
                v-list-db
      .
      assign
      v-sts-do = buf_layout.sts
      .
      if g#db-num > 0 then do:
        define buffer buf_route for ub.route.
        /*на всякий случай проверим нет ли уже команды на запуск two-commit*/
        find first buf_route no-lock where
                  buf_route.name-rec = ("command":U + {&delim-nws}
                                        + "inquiry-two-commit":U + {&delim-nws}
                                        + {&delete_nu-layout} + {&delim-nws}
                                        + v-key-rec + {&delim-nws}
                                        + v-param) no-error.
        if available buf_route then do:
          message
          substitute("Команда <Запуск удаления РАСКЛАДКИ &1 из ГБД> уже отослана", buf_layout.layout-id)
          view-as alert-box warning.
          return no-apply.
        end.
      end.
      run nws/db-rec.p (
                          input {&delete_nu-layout}
                          ,input v-key-rec
                          ,input v-param
                        ) no-error .
      if v-sts-po = v-sts-do
      and not error-status:error
      then do:
        message
        return-value skip
        view-as alert-box error .
        undo _main, return error.
      end.
      if g#db-num > 0 then do:
        message
        substitute("Отослана команда <Запуск удаления РАСКЛАДКИ &1 из ГБД>", buf_layout.layout-id)
        view-as alert-box.
      end.
    end. /*для системы с удаленками        */
    else do:
      run adm/layout3.p (
                       input yes /*p-silent*/
                      ,recid(buf_layout)
                      ) no-error .
    end.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при удалении РАСКЛАДКИ" skip
        substitute( "ID РАСКЛАДКИ &1", buf_layout.layout-id ) skip
        return-value skip
        error-status :get-message(1)
        view-as alert-box error .
      undo _main, return error.
    end.
  end.
  run waitfram-hide in this-procedure .
end. /*doe*/

procedure get-db-list :
define parameter buffer buf_layout for ub.layout.
define output parameter p-list-db as character no-undo .

  do
  on error undo, return error
  :
    assign
    p-list-db = {&question-mark}.

  end.

end procedure. /* get-db-list */