block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Экспорт конфигурации rule-машины в формате СПН

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/16/07
Author: Bakhtadze Natalya
Creation date: 02/16/07

*/

define input parameter p-file-name as character no-undo .
define input parameter p-old-file-name as character no-undo .
define input parameter p-mode as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экспорт конфигурации rule-машины в формате СПН".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/tblfname.i }


define variable v-rum-exp-tables as character no-undo .
define variable v-rum-exp-table-names as character no-undo .
define variable err-count as integer no-undo .
define variable rec-count as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-prepare-phrase as character no-undo .
define variable num-rec as integer no-undo .
define variable num-err as integer no-undo .
define variable v-fix-file-name as character no-undo .

if num-entries(p-file-name, ".") > 1 then do:
  v-fix-file-name = entry(num-entries(p-file-name, ".") - 1 , p-file-name, ".") + ".fix".
end.
else do:
  v-fix-file-name = entry(num-entries(p-file-name, ".") , p-file-name, ".") + ".fix".
end.
if search(v-fix-file-name) = ? then do:
  message
  substitute("Не найден ПОПРАВОЧНЫЙ файл &1", v-fix-file-name)
  view-as alert-box error .
  return error .
end.


assign
v-rum-exp-tables =  {&table_rule-process} +
                    ";" + {&table_ruleset} +
                    ";" + {&table_prop-head} +
                    ";" + {&table_prop-ruleset} +
                    ";" + {&table_prop-map} +
                    ";" + {&table_prop-script} +
                    ";" + {&table_pscript-ruleset} +
                    ";" + {&table_ruledict} +
                    ";" + {&table_ruledict-param} +
                    ";" + {&table_rule-script}  +         /*тольк not is_dynamic*/
                    ";" + {&table_rule-i-script}  +         /*тольк not is_dynamic*/
                    ";" + {&table_rule}  +         /*тольк not is_dynamic*/
                    ";" + {&table_rule-by-set} +   /*тольк not is_dynamic*/
                    ";" + {&table_prop-ref}  +  /*тольк dt-code = 0*/
                    ";" + {&table_rule-profile} +
                    ";" + {&table_profile-by-profile} +  /*тольк not is_dynamic*/
                    ";" + {&table_rule-by-profile} +  /*тольк not is_dynamic*/
                    ";" + {&table_rp-rule-param} +   /**/
                    ";" + "fixing" +
                    ";" + ({&table_ruledict} + {&comma-char} + {&table_ruledict})
                    .
assign
v-rum-exp-table-names = {&table_rule-process-full} +
                        ";" + {&table_ruleset-full} +
                        ";" + {&table_prop-head-full} +
                        ";" + {&table_prop-ruleset-full} +
                        ";" + {&table_prop-map-full} +
                        ";" + {&table_prop-script-full} +
                        ";" + {&table_pscript-ruleset-full} +
                        ";" + {&table_ruledict-full} +
                        ";" + {&table_ruledict-param-full} +
                        ";" + {&table_rule-script-full}  +         /*тольк not is_dynamic*/
                        ";" + {&table_rule-i-script-full}  +         /*тольк not is_dynamic*/
                        ";" + {&table_rule-full}      +  /*тольк not is_dynamic*/
                        ";" + {&table_rule-by-set-full} +   /*тольк not is_dynamic*/
                        ";" + {&table_prop-ref-full}  +  /*тольк dt-code = 0*/
                        ";" + {&table_rule-profile-full} +
                        ";" + {&table_profile-by-profile-full} +
                        ";" + {&table_rule-by-profile} +       /*тольк not is_dynamic*/
                        ";" + {&table_rp-rule-param-full} +   /**/
                        ";" + "fixing" +
                        ";" + {&table_ruledict-full}
                        .

 /*пока не будем проверять на dynamic и тд.*/
do v-ii = 1 to num-entries( v-rum-exp-tables, ";"):
  CASE entry(v-ii, v-rum-exp-tables, ";"):
    when {&table_prop-ref} then do:
      v-prepare-phrase = substitute(" for each &1 where &1.dt-code = 0 ", entry(v-ii, v-rum-exp-tables, ";")).
    end.
    when {&table_ruledict} then do:

      v-prepare-phrase = substitute(' for each &1 where &1.entry-id > 0 and ((&1.entry-type > "&2") or (&1.entry-type < "&2")) use-index imain'
                                   , entry(v-ii, v-rum-exp-tables, ";")
                                   , {&rdict-etype-sum-id}
                                   ).
    end.
    when ({&table_ruledict} + {&comma-char} + {&table_ruledict}) then do:
      v-prepare-phrase = substitute(' for each &1 where &1.entry-id = 0'
                                   , entry(1, entry(v-ii, v-rum-exp-tables, ";"))
                                   ).
      entry(v-ii, v-rum-exp-tables, ";") = entry(1, entry(v-ii, v-rum-exp-tables, ";")).
    end.
    when "fixing" then do:
      v-prepare-phrase = v-fix-file-name.
    end.
    otherwise do:
      v-prepare-phrase = substitute(" for each &1 ", entry(v-ii, v-rum-exp-tables, ";")).
    end.
 END CASE.
  rec-count = num-rec.
  err-count = num-err.
  run utl/upg-exp.p ( input p-file-name
                     ,input p-old-file-name
                     ,input p-mode
                     ,input (if v-ii = 1 then no else yes) /*p-append*/
                     ,input (if v-ii = 1 then yes else no) /*p-first*/
                     ,input ( if v-ii = num-entries(v-rum-exp-tables, ";") then yes else no)
                     ,input entry(v-ii, v-rum-exp-tables, ";")
                     ,input (if num-entries(entry(v-ii, v-rum-exp-tables, ";")) > 1
                             then num-entries(entry(v-ii, v-rum-exp-tables, ";"))
                             else 1)
                     ,input v-prepare-phrase /*p-prepare-phrase*/
                     ,input-output rec-count
                     ,input-output err-count

                     ) no-error.
  if not error-status:error then do:
    num-rec = rec-count.
    num-err = err-count.
  end.
  else do:
    message
    substitute("Ошибка при экспорте &1", entry(v-ii, v-rum-exp-tables, ";"))
    view-as alert-box error .
    return.
  end.
end.
message
"Экспорт конфигурации завершен"
view-as alert-box .