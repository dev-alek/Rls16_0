block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: export-current-gate.p $
$Archive: utl/export-current-gate.p $

Экспорт конфигурации gate в формате СПН

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/02/08
Author: Bakhtadze Natalya
Creation date: 02/02/08

*/

define input parameter p-file-name as character no-undo .
define input parameter p-old-file-name as character no-undo .
define input parameter p-mode as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: export-current-gate.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/export-current-gate.p $":U .
define variable vss-description as character no-undo init "Экспорт конфигурации gate в формате СПН".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/tblfname.i }


define variable v-gate-exp-tables as character no-undo .
define variable v-gate-exp-table-names as character no-undo .
define variable err-count as integer no-undo .
define variable rec-count as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-prepare-phrase as character no-undo .
define variable num-rec as integer no-undo .
define variable num-err as integer no-undo .

assign
v-gate-exp-tables =  {&table_clob-bind} +
                    ";" + ({&table_clob-bind} + {&comma-char} + {&table_clob-data}) +
                    ";" + ({&table_clob-bind} + {&comma-char} + {&table_clob-bind})
                    .
assign
v-gate-exp-table-names = {&table_clob-bind-full} +
                        ";" + {&table_clob-data-full} +
                        ";" + {&table_clob-bind-full}
                        .

do v-ii = 1 to num-entries( v-gate-exp-tables, ";"):
  CASE entry(v-ii, v-gate-exp-tables, ";"):
    when {&table_clob-bind} then do:
      v-prepare-phrase = substitute(" for each &1 where &1.resource-type = '&2' and &1.db-num = 0 and &1.int64-id > 0 by &1.field-name_"
                                    , entry(v-ii, v-gate-exp-tables, ";")
                                    , {&lob-res-gate}).
    end.
    when ({&table_clob-bind} + {&comma-char} + {&table_clob-data}) then do:
      v-prepare-phrase = substitute(" for each clob-bind where clob-bind.resource-type = '&1', first &2 where " +
                                    " &2.db-num = clob-bind.db-num   and &2.int64-id = clob-bind.int64-id  by clob-bind.uniq-key-rec"
                                    , {&lob-res-gate}
                                    ,entry(2, entry(v-ii, v-gate-exp-tables, ";"))).
    end.
    when ({&table_clob-bind} + {&comma-char} + {&table_clob-bind}) then do:
      v-prepare-phrase = substitute(" for each &1 where &1.db-num = 0 and &1.int64-id = 0 ", entry(1, entry(v-ii, v-gate-exp-tables, ";"))).
      entry(v-ii, v-gate-exp-tables, ";") = entry(1, entry(v-ii, v-gate-exp-tables, ";")).
    end.
    otherwise do:
      v-prepare-phrase = substitute(" for each &1 ", entry(v-ii, v-gate-exp-tables, ";")).
    end.
 END CASE.
  rec-count = num-rec.
  err-count = num-err.
  run utl/upg-exp.p ( input p-file-name
                     ,input p-old-file-name
                     ,input p-mode
                     ,input (if v-ii = 1 then no else yes) /*p-append*/
                     ,input (if v-ii = 1 then yes else no) /*p-first*/
                     ,input ( if v-ii = num-entries(v-gate-exp-tables, ";") then yes else no)
                     ,input entry(v-ii, v-gate-exp-tables, ";")
                     ,input (if num-entries(entry(v-ii, v-gate-exp-tables, ";")) > 1
                             then num-entries(entry(v-ii, v-gate-exp-tables, ";"))
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