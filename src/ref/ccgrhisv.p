block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ccgrhisv.p $
$Archive: ref/ccgrhisv.p $

Заполнение временной таблицы для показа изменений по таблицам истории групп клиентов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/25/04
Author: Bakhtadze Natalya
Creation date: 08/25/04

*/

define input parameter p-node-code  like ub.c-cli-grp.node-code no-undo .
define input parameter p-corr-user-db-num  like ub.c-cli-grp.corr-user-db-num no-undo .
define input parameter p-chip-num  like ub.c-cli-grp.chip-num no-undo .
define input parameter p-subject as character no-undo .
define input parameter p-silent  as logical no-undo .
define output parameter p-description as character no-undo .
define output parameter p-full-name-old as character no-undo case-sensitive.
define output parameter p-full-name-new as character no-undo case-sensitive.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ccgrhisv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/ccgrhisv.p $":U .
define variable vss-description as character no-undo init "Заполнение временной таблицы для показа изменений по таблицам истории групп клиентов".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
define variable v-mess as character no-undo .

define buffer buf_c-cli-grp for ub.c-cli-grp.

{ ref/tmpchgs.i "SHARED" " " "with-action" }


find first buf_c-cli-grp no-lock where
          buf_c-cli-grp.node-code = p-node-code
      AND buf_c-cli-grp.chip-num = p-chip-num
      AND buf_c-cli-grp.corr-user-db-num = p-corr-user-db-num no-error .
if not available buf_c-cli-grp then do:
  return error .
end.
CASE p-subject:
  when {&table_cli-grp} then do:
    run cli-grp-proc in this-procedure(output p-description) no-error .
  end.
  when {&table_dis-grp-rule} then do:
    run dis-grp-rule-proc in this-procedure(output p-description) no-error .
  end.
 end case.
if error-status:error then do:
  return error .
end.


procedure cli-grp-proc :
define output parameter p-description as character no-undo .

define variable v-is-created as logical no-undo .
define variable v-is-deleted as logical no-undo .
define variable v-field-name as character no-undo .
define variable v-field-function as character no-undo .
define variable jj as integer no-undo .
define variable v-field-label  as character no-undo .
define variable v-field-list as character no-undo .

define buffer current_cli-grp for ub.cli-grp  .
define buffer current_c-cli-grp for ub.c-cli-grp  .
define buffer new_c-cli-grp for ub.c-cli-grp  .

  do
  on error undo, return error
  :
    find first current_c-cli-grp no-lock where
               current_c-cli-grp.node-code = p-node-code
           AND current_c-cli-grp.chip-num = p-chip-num
           AND current_c-cli-grp.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-cli-grp then do:
       v-mess = "Неверная ссылка на c-cli-grp в таблице c-cli-grp".
       run err-mess in this-procedure ( input-output v-mess).
       return error (if p-silent then v-mess else '':U).
    end.
    find first new_c-cli-grp no-lock where
               new_c-cli-grp.node-code = p-node-code
           AND new_c-cli-grp.chip-num > p-chip-num
           AND new_c-cli-grp.corr-user-db-num = p-corr-user-db-num
            no-error .
    if not available new_c-cli-grp then do:
        find first current_cli-grp no-lock where
               current_cli-grp.node-code = p-node-code no-error .
        if not available current_cli-grp then do:
           assign
           v-is-deleted = yes.
        end.
        if available current_cli-grp then
        buffer-compare current_cli-grp to current_c-cli-grp
        case-sensitive
        save result in v-chg-fields.
    end.
    else do:
        buffer-compare new_c-cli-grp except chip-num corr-date corr-user-name corr-user-db-num to current_c-cli-grp
        case-sensitive
        save result in v-chg-fields.
    end.
    if buf_c-cli-grp.upper-code = 0
    /*это эквивалентно buf_c-cli-grp.upper-code = integer({&hn-create}) */
    then do:
      assign
      v-is-created = yes
      v-chg-fields = get-all-fields ("cli-grp")
      .
    end.
    if not avail new_c-cli-grp
    and not available current_cli-grp
    /*это эквивалентно  buf_c-cli-grp.action = integer({&hn-delete}) */
    then do:
      assign
      v-is-deleted = yes
      v-chg-fields = get-all-fields ("cli-grp")
      .
    end.
    if lookup("node-code", v-chg-fields ) > 0
    or lookup("upper-code", v-chg-fields ) > 0 then do:
       if not v-is-created then
       run c-get-full-name  in this-procedure (
                                                  input  yes /* p-c */
                                                 ,input p-node-code
                                                 ,input p-chip-num
                                                 ,input p-corr-user-db-num
                                                 ,output p-full-name-old
                                                ) no-error .
       if not v-is-deleted then
       run c-get-full-name  in this-procedure (
                                                  input  (if available new_c-cli-grp
                                                          then yes
                                                          else no) /* p-c */
                                                 ,input p-node-code
                                                 ,input (if available new_c-cli-grp
                                                         then new_c-cli-grp.chip-num
                                                         else 0)
                                                 ,input p-corr-user-db-num
                                                 ,output p-full-name-new
                                                ) no-error .
    end.

&scop fields-name-list "is-term,lvl-num,node-code,node-name,upper-code"

define variable v-label-param as character no-undo .

v-label-param =
   "is-term" + {&delim-par} + "Терминальная" + {&delim-par} + "" + {&delim-flf}
 + "lvl-num" + {&delim-par} + "Уровень" + {&delim-par} + "" + {&delim-flf}
 + "node-code" + {&delim-par} + "Вн №" + {&delim-par} + "" + {&delim-flf}
 + "node-name" + {&delim-par} + "Наименование" + {&delim-par} + "" + {&delim-flf}
 + "upper-code" + {&delim-par} + "Вн № выш.группы" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input v-is-created
                                            ,input v-is-deleted
                                            ,input  buffer current_c-cli-grp:handle
                                            ,input  {&table_cli-grp}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).


end.
end procedure. /* cli-grp-proc */

procedure dis-grp-rule-proc :
define output parameter p-description as character no-undo .
define variable v-label-param as character no-undo .
define buffer buf_c-dis-grp-rule for ub.c-dis-grp-rule.
    &scop fields-name-list "rule-num,pos-type,templ-rl-root,discnt-role"
    find first buf_c-dis-grp-rule no-lock where
              buf_c-dis-grp-rule.classif-type = {&table_cli-grp}
         and  buf_c-dis-grp-rule.node-code = p-node-code
        and  buf_c-dis-grp-rule.corr-user-db-num = p-corr-user-db-num
        and  buf_c-dis-grp-rule.chip-num = p-chip-num no-error.
   if not available buf_c-dis-grp-rule then do:
     message
     "Неверная ссылка на c-dis-grp-rule в таблице c-cli-grp"
     view-as alert-box error.
   end.
v-label-param =
  "rule-num" + {&delim-par} + "Номер правила скидки" + {&delim-par} + "" + {&delim-flf}
 + "pos-type" + {&delim-par} + "Место использ." + {&delim-par} + "" + {&delim-flf}
 + "templ-rl-root" + {&delim-par} + "Тип шаблона" + {&delim-par} + "disgrpru-get-disc-label"  + {&delim-flf}
 + "discnt-role" + {&delim-par} + "Тип скидки" + {&delim-par} + "disgrpru-get-disc-role-label"
 .
run proc-full-temp-changes in this-procedure (
                                              input  (buf_c-cli-grp.action = integer({&hn-create}))
                                            ,input  (buf_c-cli-grp.action = integer({&hn-delete}))
                                            ,input  buffer buf_c-dis-grp-rule:handle
                                            ,input  {&table_dis-grp-rule}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).

end procedure .


procedure c-get-full-name :
/*получение полного имени группы с учетом изменений во времени*/
do
on error undo, return error
:
define input parameter p-c          as logical no-undo .
define input parameter p-node-code  as integer      no-undo.
define input parameter p-chip-num  as integer no-undo .
define input parameter p-corr-user-db-num as integer no-undo .
define output parameter p-full-name as character    no-undo.
    define variable v-upper-code    as integer           no-undo.
    define variable v-c as logical no-undo .

    define buffer buf_cli-grp       for ub.cli-grp.
    define buffer buf_upper_cli-grp for ub.cli-grp.

    define buffer buf_c-cli-grp       for ub.c-cli-grp.
    define buffer buf_c-upper_cli-grp for ub.c-cli-grp.

    if p-c then do:
      find first buf_c-cli-grp no-lock
          where buf_c-cli-grp.node-code = p-node-code
            AND buf_c-cli-grp.chip-num  = p-chip-num
            AND buf_c-cli-grp.corr-user-db-num  = p-corr-user-db-num
      no-error.
      if not available buf_c-cli-grp
      then do:
          undo, return error substitute("Не найдена запись истории для групп клиентов: вн № &1, chip-num &2, БД-корректор &3"
                                        , p-node-code
                                        , p-chip-num
                                        , p-corr-user-db-num
                                        ).
      end.
    end.
    else do:
      find first buf_cli-grp no-lock
          where buf_cli-grp.node-code = p-node-code
      no-error.
      if not available buf_cli-grp
      then do:
          undo, return error substitute("Не найдена запись группы клиентов: вн № &1"
                                        , p-node-code
                                        ).
      end.
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
        v-c = p-c
    .
    do while
    ( v-c = no and buf_cli-grp.upper-code <> 0)
    or ( v-c = yes and  buf_c-cli-grp.upper-code <> 0)
    on error undo, return error "Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = (if v-c = yes
                            then buf_c-cli-grp.node-name
                            else buf_cli-grp.node-name)
                         + (if p-full-name <> "" then {&delim-grp} else "")
                         + p-full-name
            v-upper-code = (if v-c
                            then buf_c-cli-grp.upper-code
                            else buf_cli-grp.upper-code)
        .
        find first buf_c-cli-grp no-lock
             where buf_c-cli-grp.node-code = v-upper-code
               AND buf_c-cli-grp.chip-num  > p-chip-num
               AND buf_c-cli-grp.corr-user-db-num  > p-corr-user-db-num no-error .
        if not available buf_c-cli-grp then do:
          assign
          v-c = no
          .
          find first buf_cli-grp no-lock
              where buf_cli-grp.node-code = v-upper-code
          no-error.
          if not available buf_cli-grp
          then do:
              undo, return error substitute("Не найдена группа клиентов с кодом &1" +
                                             ". Ошибка ссылки в дереве клиентов для записи истории групп клиентов:" +
                                             "вн № &2, chip-num &3, БД-корректор &4"
                                            ,  v-upper-code
                                            ,  p-node-code
                                            , p-chip-num
                                            , p-corr-user-db-num).
          end.
        end.
        else do:
          assign
          v-c = yes
          .
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else {&delim-grp})
    .
end.
end procedure. /* grplib-get-full-name */

PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("История групп клиентов&1" +
                          "Вн Код группы: &2&1" +
                          "щепка &3 БД:&4&1&5"
                          ,{&new-line}
                          ,p-node-code
                          ,p-chip-num
                          ,p-corr-user-db-num
                          ,p-mess).

    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.