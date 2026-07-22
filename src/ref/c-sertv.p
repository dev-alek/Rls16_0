block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: c-sertv.p $
$Archive: ref/c-sertv.p $

Заполнение временной таблицы для показа изменений по таблицам истории сертификата

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/10/05
Author: Bakhtadze Natalya
Creation date: 08/10/05

*/

define input parameter p-cli-type like ub.c-sert.cli-type no-undo .
define input parameter p-cli-code like ub.c-sert.cli-code no-undo .
define input parameter p-sert-code like ub.c-sert.sert-code no-undo .
define input parameter p-b-code    like ub.c-sert.b-code no-undo .
define input parameter p-chip-num like ub.c-sert.chip-num no-undo .
define input parameter p-corr-user-db-num like ub.c-sert.corr-user-db-num no-undo .
define input parameter p-subject like ub.c-sert.subject no-undo .
define input parameter p-action   like ub.c-sert.action no-undo .
define input parameter p-silent  as logical no-undo .
define output parameter p-description as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: c-sertv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/c-sertv.p $":U .
define variable vss-description as character no-undo init "Заполнение временной таблицы для показа изменений по таблицам истории сертификата".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }

define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
define variable v-mess as character no-undo .

define buffer buf_c-sert for ub.c-sert.

{ ref/tmpchgs.i "SHARED" " " "with-action"  }


find first buf_c-sert no-lock where
          buf_c-sert.cli-type = p-cli-type
      AND buf_c-sert.cli-code = p-cli-code
      AND buf_c-sert.sert-code = p-sert-code
      AND buf_c-sert.chip-num = p-chip-num
      AND buf_c-sert.corr-user-db-num = p-corr-user-db-num  no-error .
if not available buf_c-sert then do:
  return error .
end.
CASE p-subject:
  when {&table_sert} then do:
    run sert-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_sert-join} then do:
    run sert-join-proc in this-procedure(output p-description) no-error  .
  end.

END CASE.
if error-status:error then do:
  return error .
end.

procedure sert-proc :
define output parameter p-description as character no-undo .
define buffer curr_c-sert for ub.c-sert  .


  do
  on error undo, return error
  :
    find first curr_c-sert no-lock where
               curr_c-sert.cli-type = p-cli-type
           AND curr_c-sert.cli-code = p-cli-code
           AND curr_c-sert.sert-code = buf_c-sert.sert-code
           AND curr_c-sert.chip-num = p-chip-num
           AND curr_c-sert.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail curr_c-sert then do:
      v-mess = "Неверная ссылка на c-sert в таблице c-sert".
      run err-mess in this-procedure ( input-output v-mess ).
      return error v-mess.
    end.

&scop fields-name-list "b-code,cli-code,cli-type,sert-code,first-date,last-date,PS"

define variable v-label-param as character no-undo .

v-label-param =
  "b-code" + {&delim-par} + "Бар-код" + {&delim-par} + "" + {&delim-flf}
 + "cli-code" + {&delim-par} + "Код контрагента" + {&delim-par} + "" + {&delim-flf}
 + "cli-type" + {&delim-par} + "Тип контрагента" + {&delim-par} + "" + {&delim-flf}
 + "sert-code" + {&delim-par} + "№ сертификата" + {&delim-par} + "" + {&delim-flf}
 + "first-date" + {&delim-par} + "Дата начал действия" + {&delim-par} + "" + {&delim-flf}
 + "last-date" + {&delim-par} + "Дата окончаняи действия" + {&delim-par} + "" + {&delim-flf}
 + "PS" + {&delim-par} + "Примечания" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input (curr_c-sert.action = integer({&hn-create}))
                                            ,input (curr_c-sert.action = integer({&hn-delete}))
                                            ,input  buffer curr_c-sert:handle
                                            ,input  {&table_sert}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).




end.

end procedure. /* sert-proc */



procedure sert-join-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define variable v-field-name as character no-undo .
define variable v-field-function as character no-undo .
define variable jj as integer no-undo .
define variable v-field-label as character no-undo .


define buffer curr_sert-join for ub.sert-join  .
define buffer curr_c-sert for ub.c-sert  .
define buffer new_c-sert for ub.c-sert  .


  do
  on error undo, return error
  :
    find first curr_c-sert no-lock where
               curr_c-sert.cli-type = p-cli-type
           AND curr_c-sert.cli-code = p-cli-code
           AND curr_c-sert.sert-code = p-sert-code
           AND curr_c-sert.chip-num = p-chip-num
           AND curr_c-sert.corr-user-db-num = p-corr-user-db-num  no-error .
    if not avail curr_c-sert then do:
      v-mess = "Неверная ссылка на c-sert в таблице c-sert".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    find first new_c-sert no-lock where
               new_c-sert.cli-type = p-cli-type
            AND new_c-sert.cli-code = p-cli-code
            AND new_c-sert.sert-code = buf_c-sert.sert-code
            AND new_c-sert.b-code = p-b-code
            AND new_c-sert.chip-num > p-chip-num
            AND new_c-sert.corr-user-db-num = p-corr-user-db-num
            no-error.
    if not available new_c-sert then do:
        find first curr_sert-join no-lock where
                   curr_sert-join.cli-type = p-cli-type
                AND curr_sert-join.cli-code = p-cli-code
                AND curr_sert-join.sert-code = buf_c-sert.sert-code
                AND curr_sert-join.b-code = buf_c-sert.b-code
                no-error.
        if not available curr_sert-join then do:
            return error.
        end.
        buffer-compare curr_sert-join to curr_c-sert
        case-sensitive
        save result in v-chg-fields.
    end.
    else do:
        buffer-compare new_c-sert except chip-num corr-date corr-time corr-user-name corr-user-db-num to curr_c-sert
        case-sensitive
        save result in v-chg-fields.
    end.

&scop fields-name-list "b-code,cli-code,cli-type,sert-code"

&scop fields-label-list  "Бар-код,Код контрагента,Тип контрагента,№ сертификата"

&scop fields-function-list ",,,"


  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, {&fields-name-list}).
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, {&fields-label-list})
    v-field-function = entry(jj, {&fields-function-list})
    .

    create temp-changes.
    assign
    temp-changes.f_name = v-field-name
    temp-changes.l_name = v-field-label
    temp-changes.v_old = (if curr_c-sert.action = integer({&hn-create})
                          then "":U
                          else string(buffer curr_c-sert:buffer-field(v-field-name):buffer-value))
    temp-changes.v_new =  (if available new_c-sert
                                then string(buffer new_c-sert:buffer-field(v-field-name):buffer-value)
                                else string(buffer curr_sert-join:buffer-field(v-field-name):buffer-value)
                           )
    .
    if v-field-function <> '':U then do:
      assign
      temp-changes.v_old = DYNAMIC-function(v-field-function, temp-changes.v_old)
      temp-changes.v_new = DYNAMIC-function(v-field-function, temp-changes.v_new)
      .
    end.
  end. /*  do ii = 1 to num-entries(v-chg-fields):*/
end. /*doe*/


end procedure. /* sert-proc */


PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      p-mess =
      substitute("История сертификата  &1 на &2&3: щепка &4 БД:&5  Предмет изменений &6&7&8"
                  ,p-sert-code
                  , p-cli-type
                  , p-cli-code
                  , p-chip-num
                  , p-corr-user-db-num
                  , p-subject
                  , {&new-line}
                  , p-mess
                  ).
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.