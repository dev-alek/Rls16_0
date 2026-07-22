block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: mig_0090.p $
$Archive: utl/mig_0090.p $

Модификация таблиц  раздела Диапазоны

Автор: Чернова Светлана Александровна
Дата создания: 12/08/08
Author: Svetlana Chernova
Creation date: 12/08/08

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mig_0090.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/mig_0090.p $":U .
define variable vss-description as character no-undo init "Модификация тфблиц раздела Диапазоны".
{ cmp/vssrevis.i }
{ utl/mig_0001.i }
{ cmp/getmcode.i ub }

run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Диапазоны") ).

on write  of ub.code-range      override do: end .
on delete of ub.code-range      override do: end .

  do
  on error undo, return error return-value
  :
  for each ub.code-range exclusive-lock :
      if ub.code-range.stts = 'a':U and ub.code-range.db-num <> p-db-num  then ub.code-range.stts = 'u':U .
      if ub.code-range.db-num > 0 then ub.code-range.db-num = 0 .
  end.

define variable v-b-code as integer   no-undo .
define variable v-curr-type-cdrg as character no-undo .
define variable i as integer   no-undo .
define variable vrv as character no-undo .

  v-curr-type-cdrg =
        {&gbl-ss-code} + "," +
        {&gbl-ct-code} + "," +
        {&gbl-dc-code} + "," +
        {&gbl-fm-code} + "," +
        {&gbl-pn-code} + "," +
        {&gbl-dr-code} + "," +
        {&gbl-bc-code} + "," +
        {&gbl-sc-code} .

  do i = 1 to num-entries(v-curr-type-cdrg) :
    run get-max-code in this-procedure
      ( input "f-u":U
        ,input 0
        ,input entry (i , v-curr-type-cdrg )
        ,input ?
        ,input ?
        ,input false
        ,output v-b-code
      ) no-error .

      vrv =  return-value .
      if vrv <> "" then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input vrv  ).
     end.

  end.

  end.