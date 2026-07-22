block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cfggrhiv.p $
$Archive: ref/cfggrhiv.p $

Заполнение временной таблицы для показа изменений по таблицам истории групп блюд

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/25/04
Author: Bakhtadze Natalya
Creation date: 08/25/04

*/

define input parameter p-obj-type like ub.c-fbr-gds-grp-hist.obj-type no-undo .
define input parameter p-obj-code like ub.c-fbr-gds-grp-hist.obj-code no-undo .
define input parameter p-node-code  like ub.c-fbr-gds-grp-hist.node-code no-undo .
define input parameter p-corr-user-db-num  like ub.c-fbr-gds-grp-hist.corr-user-db-num no-undo .
define input parameter p-chip-num  like ub.c-fbr-gds-grp-hist.chip-num no-undo .
define input parameter p-subject like ub.c-fbr-gds-grp-hist.subject no-undo .
define input parameter p-action   like ub.c-fbr-gds-grp-hist.action no-undo .
define input parameter p-silent  as logical no-undo .
define output parameter p-description as character no-undo .
define output parameter p-full-name-old as character no-undo .
define output parameter p-full-name-new as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cfggrhiv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cfggrhiv.p $":U .
define variable vss-description as character no-undo init "Заполнение временной таблицы для показа изменений по таблицам истории групп блюд".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ ref/fgrpattr.i }
define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
define variable v-mess as character no-undo .

define buffer buf_c-fbr-gds-grp-hist for ub.c-fbr-gds-grp-hist.

{ ref/tmpchgs.i "SHARED" " " "with-action" }


find first buf_c-fbr-gds-grp-hist no-lock where
         buf_c-fbr-gds-grp-hist.obj-type = p-obj-type
      AND buf_c-fbr-gds-grp-hist.obj-code = p-obj-code
      AND buf_c-fbr-gds-grp-hist.node-code = p-node-code
      AND buf_c-fbr-gds-grp-hist.chip-num = p-chip-num
      AND buf_c-fbr-gds-grp-hist.corr-user-db-num = p-corr-user-db-num
      AND buf_c-fbr-gds-grp-hist.subject  = p-subject no-error .
if not available buf_c-fbr-gds-grp-hist then do:
  return error .
end.

CASE p-subject:
  when {&table_fbr-gds-grp} then do:
    run fbr-gds-grp-proc in this-procedure(output p-description) no-error .
  end.
  when {&table_fbr-gds-grp-attr} then do:
    run fbr-gds-grp-attr-proc in this-procedure(output p-description) no-error .
  end.
END CASE.
if error-status:error then do:
  return error .
end.


procedure fbr-gds-grp-proc :
define output parameter p-description as character no-undo .

define variable v-is-created as logical no-undo .
define variable v-is-deleted as logical no-undo .
define variable v-field-name as character no-undo .
define variable v-field-label as character no-undo .
define variable jj as integer no-undo.


define buffer current_fbr-gds-grp for ub.fbr-gds-grp  .
define buffer current_c-fbr-gds-grp for ub.c-fbr-gds-grp  .
define buffer new_c-fbr-gds-grp for ub.c-fbr-gds-grp  .

  do
  on error undo, return error
  :
    find first current_c-fbr-gds-grp no-lock where
               current_c-fbr-gds-grp.obj-type = p-obj-type
           AND current_c-fbr-gds-grp.obj-code = p-obj-code
           AND current_c-fbr-gds-grp.node-code = p-node-code
           AND current_c-fbr-gds-grp.chip-num = p-chip-num
           AND current_c-fbr-gds-grp.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-fbr-gds-grp then do:
       v-mess = "Неверная ссылка на c-fbr-gds-grp в таблице c-fbr-gds-grp-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error v-mess.
    end.
    if buf_c-fbr-gds-grp-hist.action = integer({&hn-create}) then do:
      assign
      v-is-created = yes
      v-chg-fields = get-all-fields ("fbr-gds-grp")
      .
    end.
    if buf_c-fbr-gds-grp-hist.action = integer({&hn-delete}) then do:
      assign
      v-is-deleted = yes
      v-chg-fields = get-all-fields ("fbr-gds-grp")
      .
    end.


    find first new_c-fbr-gds-grp no-lock where
              new_c-fbr-gds-grp.obj-type = p-obj-type
           AND new_c-fbr-gds-grp.obj-code = p-obj-code
           AND new_c-fbr-gds-grp.node-code = p-node-code
           AND new_c-fbr-gds-grp.chip-num > p-chip-num
           AND new_c-fbr-gds-grp.corr-user-db-num = p-corr-user-db-num
            no-error .
    if not available new_c-fbr-gds-grp then do:
        find first current_fbr-gds-grp no-lock where
               current_fbr-gds-grp.node-code = p-node-code no-error .
        if not available current_fbr-gds-grp
        and not  v-is-deleted
        then do:
            return error.
        end.
        if available current_fbr-gds-grp then
        buffer-compare current_fbr-gds-grp to current_c-fbr-gds-grp
        case-sensitive
        save result in v-chg-fields.
    end.
    else do:
        buffer-compare new_c-fbr-gds-grp
        except chip-num corr-date corr-time corr-user-name corr-user-db-num
        to current_c-fbr-gds-grp
        case-sensitive
        save result in v-chg-fields.
    end.
    if lookup("node-code", v-chg-fields ) > 0
    or lookup("upper-code", v-chg-fields ) > 0 then do:
       if not v-is-created then
       run c-get-full-name  in this-procedure (
                                                  input  yes /* p-c */
                                                 ,input p-obj-type
                                                 ,input p-obj-code
                                                 ,input p-node-code
                                                 ,input p-chip-num
                                                 ,input p-corr-user-db-num
                                                 ,output p-full-name-old
                                                ) no-error .
       if not v-is-deleted then
       run c-get-full-name  in this-procedure (
                                                  input  (if available new_c-fbr-gds-grp
                                                          then yes
                                                          else no) /* p-c */
                                                 ,input p-obj-type
                                                 ,input p-obj-code
                                                 ,input p-node-code
                                                 ,input (if available new_c-fbr-gds-grp
                                                         then new_c-fbr-gds-grp.chip-num
                                                         else 0)
                                                 ,input p-corr-user-db-num
                                                 ,output p-full-name-new
                                                ) no-error .
    end.

&scop fields-name-list "global-code,host-code,is-modificator,is-term,lvl-num,node-code,node-name,obj-code,~
obj-type,out-code,upper-code"
&scop fields-label-list "Код Рубрикатора,Код фирмы,Модификаторы блюд,Терминальная группа,Уровень,Код,Наименование,~
Код объекта,Тип объекта,Код на кассе,Вн № выш.группы"

  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, {&fields-name-list}).
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, {&fields-label-list})
    .

    create temp-changes.
    assign
    temp-changes.f_name = v-field-name
    temp-changes.l_name = v-field-label
    temp-changes.v_old =  (if v-is-created
                          then "":U
                          else string(buffer current_c-fbr-gds-grp:buffer-field(v-field-name):buffer-value))
    temp-changes.v_new = (if available new_c-fbr-gds-grp
                          then string(buffer new_c-fbr-gds-grp:buffer-field(v-field-name):buffer-value)
                          else  (if v-is-deleted
                                then '':U
                                else  string(buffer current_fbr-gds-grp:buffer-field(v-field-name):buffer-value))
                          )
    .
  end.
end.
end procedure. /* fbr-gds-grp-proc */


procedure fbr-gds-grp-attr-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-fbr-gds-grp-attr for ub.c-fbr-gds-grp-attr  .

  do
  on error undo, return error
  :
    find first current_c-fbr-gds-grp-attr no-lock where
              current_c-fbr-gds-grp-attr.obj-type  = p-obj-type
           AND current_c-fbr-gds-grp-attr.obj-code = p-obj-code
           AND current_c-fbr-gds-grp-attr.node-code = p-node-code
           AND current_c-fbr-gds-grp-attr.chip-num = p-chip-num
           AND current_c-fbr-gds-grp-attr.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-fbr-gds-grp-attr then do:
      v-mess = "Неверная ссылка на c-fbr-gds-grp-attr в таблице c-fbr-gds-grp-attr-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    run fbr-grp-attr-tooltip in this-procedure (
                input  string(current_c-fbr-gds-grp-attr.attr-code)
                ,output v-tooltip
                ,output v-label
                ) no-error .
    assign
    p-description = "Атрибут" + {&space-char} + v-label
    .

&scop fields-name-list "attr-code,attr-value,node-code,obj-code,obj-type"

define variable v-label-param as character no-undo .

v-label-param =
  "attr-code" + {&delim-par} + "Атрибут" + {&delim-par} + "" + {&delim-flf}
 + "attr-value" + {&delim-par} + "Значение" + {&delim-par} + "" + {&delim-flf}
 + "node-code" + {&delim-par} + "Вн Код" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input (buf_c-fbr-gds-grp-hist.action = integer({&hn-create}))
                                            ,input (buf_c-fbr-gds-grp-hist.action = integer({&hn-delete}))
                                            ,input  buffer current_c-fbr-gds-grp-attr:handle
                                            ,input  {&table_fbr-gds-grp-attr}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).


end.
end procedure. /* fbr-gds-grp-attr-proc */

procedure c-get-full-name :
/*получение полного имени группы с учетом изменений во времени*/
do
on error undo, return error
:
define input parameter p-c          as logical no-undo .
define input parameter p-obj-type  as character no-undo .
define input parameter p-obj-code  as integer no-undo .
define input parameter p-node-code  as integer      no-undo.
define input parameter p-chip-num  as integer no-undo .
define input parameter p-corr-user-db-num as integer no-undo .
define output parameter p-full-name as character    no-undo.
    define variable v-upper-code    as integer           no-undo.
    define variable v-c as logical no-undo .

    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    define buffer buf_upper_gds-grp for ub.fbr-gds-grp.

    define buffer buf_c-fbr-gds-grp       for ub.c-fbr-gds-grp.
    define buffer buf_c-upper_gds-grp for ub.c-fbr-gds-grp.

    if p-c then do:
      find first buf_c-fbr-gds-grp no-lock
          where buf_c-fbr-gds-grp.obj-type = p-obj-type
            AND buf_c-fbr-gds-grp.obj-code = p-obj-code
            AND buf_c-fbr-gds-grp.node-code = p-node-code
            AND buf_c-fbr-gds-grp.chip-num  = p-chip-num
            AND buf_c-fbr-gds-grp.corr-user-db-num  = p-corr-user-db-num
      no-error.
      if not available buf_c-fbr-gds-grp
      then do:
          undo, return error substitute("Не найдена запись истории для группы блюд: объеккт &1&2, вн № &3, chip-num &4, БД-корректор &5"
                                        , p-obj-type
                                        , p-obj-code
                                        , p-node-code
                                        , p-chip-num
                                        , p-corr-user-db-num
                                        ).
      end.
    end.
    else do:
      find first buf_fbr-gds-grp no-lock
          where buf_fbr-gds-grp.obj-type = p-obj-type
             AND buf_fbr-gds-grp.obj-code = p-obj-code
             AND buf_fbr-gds-grp.node-code = p-node-code
      no-error.
      if not available buf_fbr-gds-grp
      then do:
          undo, return error substitute("Не найдена запись группы блюд: объект &1&2 вн № &1"
                                        , p-obj-type
                                        , p-obj-code
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
    ( v-c = no and buf_fbr-gds-grp.upper-code <> 0)
    or ( v-c = yes and  buf_c-fbr-gds-grp.upper-code <> 0)
    on error undo, return error "Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = (if v-c = yes
                            then buf_c-fbr-gds-grp.node-name
                            else buf_fbr-gds-grp.node-name)
                         + (if p-full-name <> "" then {&delim-grp} else "")
                         + p-full-name
            v-upper-code = (if v-c
                            then buf_c-fbr-gds-grp.upper-code
                            else buf_fbr-gds-grp.upper-code)
        .
        find first buf_c-fbr-gds-grp no-lock
             where buf_c-fbr-gds-grp.obj-type  = p-obj-type
               AND buf_c-fbr-gds-grp.obj-code = p-obj-code
               AND buf_c-fbr-gds-grp.node-code = v-upper-code
               AND buf_c-fbr-gds-grp.chip-num  > p-chip-num
               AND buf_c-fbr-gds-grp.corr-user-db-num  = p-corr-user-db-num no-error .
        if not available buf_c-fbr-gds-grp then do:
          assign
          v-c = no
          .
          find first buf_fbr-gds-grp no-lock
              where buf_fbr-gds-grp.obj-type = p-obj-type
              AND buf_fbr-gds-grp.obj-code = p-obj-code
              AND buf_fbr-gds-grp.node-code = v-upper-code
          no-error.
          if not available buf_fbr-gds-grp
          then do:
              undo, return error substitute("Не найдена группа блюд с кодом &1 на объекте &2&3" +
                                             ". Ошибка ссылки в дереве товаров для записи истории групп товаров:" +
                                             "вн № &4, chip-num &5, БД-корректор &6"
                                            ,  v-upper-code
                                            , p-obj-type
                                            , p-obj-code
                                            , p-node-code
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
      p-mess =
      substitute("История группы блюд  с вн кодом &1 &2&3: щепка &4 БД:&5 Предмет изменений &6&7&8"
                  ,p-node-code, p-obj-type, p-obj-code, p-chip-num, p-corr-user-db-num, p-subject
                  ,{&new-line}
                  ,p-mess
                  ).
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.