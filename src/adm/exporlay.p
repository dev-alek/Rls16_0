block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: exporlay.p $
$Archive: adm/exporlay.p $

Экспорт конфигурации раскладок в формате СПН

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/26/08
Author: Bakhtadze Natalya
Creation date: 09/26/08

*/

define input parameter p-file-name as character no-undo .
define input parameter p-old-file-name as character no-undo .
define input parameter p-mode as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: exporlay.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/exporlay.p $":U .
define variable vss-description as character no-undo init "Экспорт конфигурации раскладок в формате СПН".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/tblfname.i }


define variable v-layout-exp-tables as character no-undo .
define variable v-layout-exp-table-names as character no-undo .
define variable err-count as integer no-undo .
define variable rec-count as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-prepare-phrase as character no-undo .
define variable num-rec as integer no-undo .
define variable num-err as integer no-undo .

assign
v-layout-exp-tables =   {&table_ruleset} +
                    ";" + {&table_rule} +
                    ";" + {&table_rule-by-set} +
                    ";" + {&table_wi-mode} +
                    ";" + {&table_layout-elem} +
                    ";" + {&table_layout} +
                    ";" + {&table_layout} + {&comma-char} + {&table_layout-elem-rule} +
                    ";" + {&table_layout} + {&comma-char} + {&table_layout-elem-rule} + {&comma-char} + {&table_rule-by-call} +
                    ";" + {&table_layout} + {&comma-char} + {&table_layout-elem-rule} + {&comma-char} + {&table_rule-call-param} +
                    ";" + ({&table_layout} + {&comma-char} + {&table_layout})
                    .
assign
v-layout-exp-table-names =  {&table_ruleset-full} +
                        ";" + {&table_rule-full} +
                        ";" + {&table_rule-by-set-full} +
                        ";" + {&table_wi-mode-full} +
                        ";" + {&table_layout-elem-full} +
                        ";" + {&table_layout-full} +
                        ";" + {&table_layout-elem-rule-full} +
                        ";" + {&table_rule-by-call-full} +
                        ";" + {&table_rule-call-param-full} +
                        ";" + {&table_layout-full}
                        .

 /*пока не будем проверять на dynamic и тд.*/
do v-ii = 1 to num-entries( v-layout-exp-tables, ";"):
  CASE entry(v-ii, v-layout-exp-tables, ";"):
    when {&table_ruleset} then do:
      v-prepare-phrase = substitute(' for each &1 where &1.codex_id = 19'
                                    ,entry(v-ii, v-layout-exp-tables, ";")
                                   ).
    end.
    when {&table_rule-by-set} then do:
      v-prepare-phrase = substitute(' for each &1 where &1.codex_id = 19'
                                   ,entry(v-ii, v-layout-exp-tables, ";")
                                   ).
    end.
    when {&table_rule} then do:
      v-prepare-phrase = substitute(' for each &1 where &1.codex_id = 19 by &1.rule_id'
                                     ,entry(v-ii, v-layout-exp-tables, ";")
                                   ).
    end.
    when {&table_layout} then do:
      v-prepare-phrase = substitute(' for each &1 where &1.layout-id <> "_" and (&1.is-default = &2 or &1.is-default = &3)'
                                   , entry(v-ii, v-layout-exp-tables, ";")
                                   , integer({&layout-default})
                                   , integer({&layout-mandatory})
                                   ).
    end.
    when ({&table_layout} + {&comma-char} + {&table_layout-elem-rule}) then do:
      v-prepare-phrase = substitute(' for each layout where layout.layout-id <> "_" and (layout.is-default = &2 or layout.is-default = &3), ' +
                                    ' each &1 where &1.layout-id = layout.layout-id '
                                   , entry(2, entry(v-ii, v-layout-exp-tables, ";"))
                                   , integer({&layout-default})
                                   , integer({&layout-mandatory})
                                   ).
    end.
    when ({&table_layout} + {&comma-char} + {&table_layout-elem-rule}  + {&comma-char} + {&table_rule-by-call}) then do:
      v-prepare-phrase = substitute(' for each layout where layout.layout-id <> "_" and (layout.is-default = &2 or layout.is-default = &3), ' +
                                    ' each layout-elem-rule where layout-elem-rule.layout-id = layout.layout-id ,' +
                                    ' each &1 where &1.call_id = layout-elem-rule.uniq-key-rec '
                                   , entry(3, entry(v-ii, v-layout-exp-tables, ";"))
                                   , integer({&layout-default})
                                   , integer({&layout-mandatory})
                                   ).
    end.
    when ({&table_layout} + {&comma-char} + {&table_layout-elem-rule} + {&comma-char} + {&table_rule-call-param}) then do:
      v-prepare-phrase = substitute(' for each layout where layout.layout-id <> "_" and (layout.is-default = &2 or layout.is-default = &3), ' +
                                    ' each layout-elem-rule where layout-elem-rule.layout-id = layout.layout-id , ' +
                                    ' each &1 where &1.call_id = layout-elem-rule.uniq-key-rec '
                                   , entry(3, entry(v-ii, v-layout-exp-tables, ";"))
                                   , integer({&layout-default})
                                   , integer({&layout-mandatory})
                                   ).
    end.


    when ({&table_layout} + {&comma-char} + {&table_layout}) then do:
      v-prepare-phrase = substitute(' for each &1 where &1.layout-id = "_"'
                                   , entry(1, entry(v-ii, v-layout-exp-tables, ";"))
                                   ).
      entry(v-ii, v-layout-exp-tables, ";") = entry(1, entry(v-ii, v-layout-exp-tables, ";")).
    end.
    otherwise do:
      v-prepare-phrase = substitute(" for each &1 ", entry(v-ii, v-layout-exp-tables, ";")).
    end.
 END CASE.
  rec-count = num-rec.
  err-count = num-err.
  run utl/upg-exp.p ( input p-file-name
                     ,input p-old-file-name
                     ,input p-mode
                     ,input (if v-ii = 1 then no else yes) /*p-append*/
                     ,input (if v-ii = 1 then yes else no) /*p-first*/
                     ,input ( if v-ii = num-entries(v-layout-exp-tables, ";") then yes else no)
                     ,input entry(v-ii, v-layout-exp-tables, ";")
                     ,input (if num-entries(entry(v-ii, v-layout-exp-tables, ";")) > 1
                             then num-entries(entry(v-ii, v-layout-exp-tables, ";"))
                             else 1)
                     ,input v-prepare-phrase /*p-prepare-phrase*/
                     ,input-output rec-count
                     ,input-output err-count

                     ) no-error.
  if not error-status:error then do:
    num-rec = rec-count.
    num-err = err-count.
  end.
end.