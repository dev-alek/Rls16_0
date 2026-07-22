block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Изменение статуса  правила

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/20/04
Author: Bakhtadze Natalya
Creation date: 01/20/04

*/

/*
Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define input parameter p-silent                       as logical no-undo .
define input parameter par-recid as recid no-undo.
define input parameter p-sts as integer no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Изменение статуса правила".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/cur-time.i }

DEFINE VARIABLE glog as logical no-undo .
DEFINE BUFFER buf_rule for ub.rule.
DEFINE VARIABLE choice as logical no-undo .
DEFINE VARIABLE varold-sts like ub.rule.sts no-undo .
define variable v-mess as character no-undo .
define variable v-check-used as logical no-undo .

if lookup(string(p-sts), {&ready-status-int} + {&comma-char} +
                         {&new-status-int} + {&comma-char} +
                         {&req-to-del-int}) = 0 then do:
&scop status-code string(p-sts)
   message
   vss-workfile vss-revision vss-description skip
   "Неверное значение параметра p-sts=" {&rule-status-name}
   view-as alert-box error .
   undo, return error .
end.

/*
статусы бывают
{&new-status-int}
{&used-status-int}
{&ready-status-int}
{&deleted-status-int}
{&to-delete-status-int}
{&req-to-del-int}
*/

main-block:
do
on error undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  FIND FIRST buf_rule exclusive-lock WHERE
            recid(buf_rule) = par-recid No-ERROR.


  if not avail buf_rule then return error.
  if buf_rule.sts = integer({&to-delete-status-int})
  or buf_rule.sts = integer({&req-to-del-int})
  or buf_rule.sts = integer({&used-status-int})

  then do:
&scop status-code string(buf_rule.sts)
    v-mess = substitute("Нельзя изменять статус правила в статусе &1", {&rule-status-int-name}).
    run err-mess in this-procedure ( input-output v-mess).
    undo main-block, return error (if p-silent then v-mess else '':U).
  end.

  varold-sts = buf_rule.sts.
  CASE p-sts:
    WHEN integer({&ready-status-int}) then do:
      case buf_rule.sts:
        when integer({&ready-status-int}) then do:
&scop status-code string(p-sts)
          v-mess = substitute("Правило уже имеет статус &1!", {&rule-status-int-name}).
          run err-mess in this-procedure ( input-output v-mess).
          undo main-block, return error (if p-silent then v-mess else '':U).
        end.
        when integer({&deleted-status-int}) then do:
          if p-silent = no then do:
&scop status-code string(buf_rule.sts)
             message
             substitute("Правило имеет статус &1&2" +
                        "Вы хотите вновь начать использовать его?"
                        , {&rule-status-int-name}
                        , {&new-line}
                        )
             view-as alert-box question buttons yes-no update glog.
             if not glog then return.
          end.
        end.
        when integer({&new-status-int}) then do:
          if p-silent = no then do:
&scop status-code string(buf_rule.sts)
             message
             substitute("Правило имеет статус &1&2" +
                        "Вы хотите закончить его редактирование и начать использовать его?"
                        , {&rule-status-int-name}
                        , {&new-line}
                        )
             view-as alert-box question buttons yes-no update glog.
             if not glog then return.
          end.
        end.
      end case.
    end. /*WHEN integer({&ready-status-int}) then do:*/

    WHEN integer({&new-status-int}) then do:
      case buf_rule.sts:
        when integer({&new-status-int}) then do:
&scop status-code string(p-sts)
          v-mess = substitute("Правило уже имеет статус &1!", {&rule-status-int-name}).
          run err-mess in this-procedure ( input-output v-mess).
          undo main-block, return error (if p-silent then v-mess else '':U).
        end.
        when integer({&deleted-status-int}) then do:
          if p-silent = no then do:
&scop status-code string(buf_rule.sts)
             message
             substitute("Правило имеет статус &1&2" +
                        "Вы хотите начать его редактирование?"
                        , {&rule-status-int-name}
                        , {&new-line}

                        )
             view-as alert-box question buttons yes-no update glog.
             if not glog then return.
          end.
        end.
        when integer({&ready-status-int}) then do:
          if p-silent = no then do:
&scop status-code string(buf_rule.sts)
             message
             substitute("Правило имеет статус &1&2" +
                        "Вы хотите снова начать его редактирование?"
                        , {&rule-status-int-name}
                        , {&new-line}

                        )
             view-as alert-box question buttons yes-no update glog.
             if not glog then return.
          end.
          v-check-used = yes.
        end.
      end case.
    end. /*WHEN integer({&new-status-int}) then do:*/
    WHEN integer({&deleted-status-int}) then do:
      case buf_rule.sts:
        when integer({&deleted-status-int}) then do:
&scop status-code string(p-sts)
          v-mess = substitute("Правило уже имеет статус &1!", {&rule-status-int-name}).
          run err-mess in this-procedure ( input-output v-mess).
          undo main-block, return error (if p-silent then v-mess else '':U).
        end.
        when integer({&new-status-int}) then do:
          if p-silent = no then do:
&scop status-code string(buf_rule.sts)
             message
             substitute("Правило имеет статус &1,не используется и может быть ОКОНЧАТЕЛЬНО удалено из системы" +
                        "Вы все равно хотите пометить его как удаленное?"
                        , {&rule-status-int-name}
                        , {&new-line}
                        )
             view-as alert-box question buttons yes-no update glog.
             if not glog then return.
          end.
        end.
        when integer({&ready-status-int}) then do:
          if p-silent = no then do:
&scop status-code string(buf_rule.sts)
             message
             substitute("Правило имеет статус &1 и может использоваться &2" +
                        "Вы хотите пометить его как удаленное&2" +
                        "(Предварительно будет проведено проверка того, что правило НЕ ИСПОЛЬЗУЕТСЯ)&2?"
                        , {&rule-status-int-name}
                        , {&new-line}
                        )
             view-as alert-box question buttons yes-no update glog.
             if not glog then return.
          end.
          v-check-used = yes.
        end.
      end case.
    end. /*WHEN integer({&new-status-int}) then do:*/
  END CASE.
  if v-check-used then do:
    define variable v-ok as logical no-undo .
    run trg/rule-chk.p ( input {&deletion}
                        ,input buf_rule.rule_id
                        ,output v-ok
                        ,output v-mess
                        ) no-error.
    if error-status:error
    or not v-ok then do:
      v-mess = substitute("Правило используется").
      run err-mess in this-procedure ( input-output v-mess).
      undo main-block, return error (if p-silent then v-mess else '':U).
    end.
  end.
  assign
  buf_rule.sts = p-sts.
end.

PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      p-mess =  substitute("Правило №&1&2&3"
                           , p-mess).
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.