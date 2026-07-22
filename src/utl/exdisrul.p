block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: exdisrul.p $
$Archive: utl/exdisrul.p $

Экспорт конфигурации rule-машины в формате СПН

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/16/07
Author: Bakhtadze Natalya
Creation date: 02/16/07

*/

define input parameter p-file-name as character no-undo .
define input parameter p-old-file-name as character no-undo .
define input parameter p-mode as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: exdisrul.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/exdisrul.p $":U .
define variable vss-description as character no-undo init "Экспорт конфигурации rule-машины в формате СПН".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/tblfname.i }
{ gbl/disrules.i create }


define variable v-dis-exp-tables as character no-undo .
define variable v-dis-exp-table-names as character no-undo .
define variable err-count as integer no-undo .
define variable rec-count as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-prepare-phrase as character no-undo .
define variable num-rec as integer no-undo .
define variable num-err as integer no-undo .

assign
v-dis-exp-tables =  {&table_dis-rule} + /*только < 100000*/
                    {&comma-char} + {&table_dis-cfg-rule} +
                    {&comma-char} + {&table_dis-time-rule} +  /*толкьо < 100000*/
                    {&comma-char} + {&table_drt-prop}
                    .
assign
v-dis-exp-table-names = {&table_dis-rule-full} +
                        {&comma-char} + {&table_dis-cfg-rule-full} +
                        {&comma-char} + {&table_dis-time-rule-full} +
                        {&comma-char} + {&table_drt-prop-full}
                        .

 /*пок ане будем проверять на dynamic и тд.*/
do v-ii = 1 to num-entries( v-dis-exp-tables):
  CASE entry(v-ii, v-dis-exp-tables):
    when {&table_dis-rule}
    then do:
      v-prepare-phrase = substitute(" for each &1 where &1.rule-num <= &2 "
                                    , entry(v-ii, v-dis-exp-tables)
                                    , {&max-num-dr-template}
                                    ).
    end.
    when {&table_dis-time-rule} then do:
      v-prepare-phrase = substitute(" for each &1 where &1.time-rule-num <= &2 "
                                    , entry(v-ii, v-dis-exp-tables)
                                    , {&max-num-dr-template}
                                    ).
    end.
    otherwise do:
      v-prepare-phrase = substitute(" for each &1 ", entry(v-ii, v-dis-exp-tables)).
    end.
  end case.
  rec-count = num-rec.
  err-count = num-err.
  run utl/upg-exp.p ( input p-file-name
                     ,input p-old-file-name
                     ,input p-mode
                     ,input (if v-ii = 1 then no else yes) /*p-append*/
                     ,input (if v-ii = 1 then yes else no) /*p-first*/
                     ,input ( if v-ii = num-entries(v-dis-exp-tables) then yes else no)
                     ,input entry(v-ii, v-dis-exp-tables)
                     ,input 1
                     ,input v-prepare-phrase /*p-prepare-phrase*/
                     ,input-output rec-count
                     ,input-output err-count

                     ) no-error.
  if not error-status:error then do:
    num-rec = rec-count.
    num-err = err-count.
  end.
end.