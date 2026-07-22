block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dis-tim3.p $
$Archive: ref/dis-tim3.p $

Физическое удаление РАСПИСАНИЯ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/15/04
Author: Bakhtadze Natalya
Creation date: 09/15/04

*/

define parameter buffer buf_dis-time-rule for ub.dis-time-rule .
define input parameter p-sts-mode as logical no-undo .
/*p-sts-mode no - физическое удаление записи*/
/*p-sts-mode yes - проверка возможности ЛОГИЧЕСКОГО удаления записи*/
define input parameter p-silent                       as logical no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dis-tim3.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dis-tim3.p $":U .
define variable vss-description as character no-undo init "Физическое удаление РАСПИСАНИЯ".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/distruls.i "work" }
{ gbl/waitfram.i }

define variable  v-des               like ub.dis-time-rule.des               no-undo .
define variable v-upper-time-rule-num    like ub.dis-time-rule.upper-time-rule-num    no-undo .
define variable v-value-type        like ub.dis-time-rule.value-type        no-undo .
define variable vt-level-1 as character no-undo .
define variable vt-level-2 as character no-undo .
define variable v-output-display    as logical   no-undo . /* виден в броусе */
define variable v-tree              as character no-undo .
define variable v-other             as character no-undo . /* еще чего - нибудь */
define variable v-entry             as character no-undo .
define variable ii as integer no-undo .
define variable v-found as logical no-undo .
define variable v-db-num like ub.db.db-num  no-undo .
define variable v-ret-mess as character no-undo .
define buffer buf_db for ub.db.
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf2_dis-time-rule for ub.dis-time-rule.



do
on error undo, return error
:
  if not p-sts-mode and buf_dis-time-rule.time-rule-num <= {&max-num-dr-template}
  then do:
    run err-mess(substitute("Нельзя удалять запись ШАБЛОНОВ РАСПИСАНИЙ"), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "time-rule-num":U).
  end.
  if buf_dis-time-rule.upper-time-rule-num > {&max-num-dr-template} then do:
    run err-mess(substitute("Нельзя удалять или выключать детализированную запись РАСИСАНИЯ"), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "rule-num":U).
  end.

  if g#db-num <> 0
  then do:
    run err-mess(substitute("Нельзя удалять или выключать запись РАСПИСАНИЯ в УБД:&1" +
                            "номер текущей БД &2"
                            , {&new-line}
                            , g#db-num), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "host-code":U).
  end.

  run dtr-code  in this-procedure (
      input  buf_dis-time-rule.templ-rl-root
      ,output v-des
      ,output v-upper-time-rule-num
      ,output v-value-type
      ,output vt-level-1
      ,output vt-level-2
      ,output v-output-display
      ,output v-tree
      ,output v-other
                                ) no-error .
  if error-status:error then do:
      run err-mess(substitute("Неверный номер шаблона для распиисания: &1, &2", buf_dis-time-rule.templ-rl-root, return-value), output v-ret-mess ).
      undo, return error (if p-silent then v-ret-mess else "rule-num":U).
  end.

  /*проверим что есть УБД*/
  if not p-sts-mode then do:
    find first buf_db no-lock where
              buf_db.db-num > 0 no-error.
    if available buf_db then do:
      run err-mess(substitute("Нельзя удалять глобальную запись ПРАВИЛА СКИДКИ или запись по фирме в системе с УБД"), output v-ret-mess).
      undo, return error (if p-silent then v-ret-mess else "":U).
    end.
  end.

  if p-sts-mode then return.
  /*если система без УБД или объект текущей БД проверим что нет связанных dis-rule*/
  run waitfram-show in this-procedure ("Ждите .. Проводится проверка возможности удаления правила" ).
    _dis-rule:
  for each buf_dis-rule no-lock where
          buf_dis-rule.time-rule-num = buf_dis-time-rule.time-rule-num:
    assign
    v-found = yes
    .
    leave _dis-rule.

  end.
  if v-found then do:
    run waitfram-hide in this-procedure .
    run err-mess(substitute("Нельзя удалять запись РАСПИСАНИЯ: &1" +
                            "с ней связано ПРАВИЛО СКИДОК №&2 &3"
                            , {&new-line}
                            , buf_dis-rule.rule-num
                            , buf_dis-rule.des
                           )
                            , output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "":U).
  end.
  run waitfram-hide in this-procedure .
  for each buf2_dis-time-rule where
          buf2_dis-time-rule.upper-time-rule-num = buf_dis-time-rule.time-rule-num
  on error undo, return error :
    delete buf2_dis-time-rule no-error .
    if error-status:error then do:
      run err-mess(substitute("Ошибка при удалении РАСПИСАНИЯ №&1: &2 &3", buf2_dis-time-rule.time-rule-num, error-status:get-message(1), return-value  ), output v-ret-mess).
      undo, return error (if p-silent then v-ret-mess else "":U).
    end.
  end.
  delete buf_dis-time-rule no-error.
  if error-status:error then do:
    run err-mess(substitute("Ошибка при удалении РАСПИСАНИЯ: &1 &2", error-status:get-message(1), return-value), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "":U).
  end.

end. /*doe*/

PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
  define output parameter p-ret-mess as character no-undo .
  CASE p-silent:
    when yes then do:
      p-ret-mess = substitute("РАСПИСАНИЕ№&1:&2&3", buf_dis-time-rule.time-rule-num, {&new-line}, p-mess).
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.

