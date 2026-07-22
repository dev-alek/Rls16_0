block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: clo-prcp.p $
$Archive: str/clo-prcp.p $

Процедура окончательной переброски файлов для прайс-чекера

Автор: Чернова Светлана Александровна
Дата создания: 10/25/06
Author: Svetlana Chernova
Creation date: 10/25/06

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: clo-prcp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/clo-prcp.p $":U .
define variable vss-description as character no-undo init "Процедура окончательной переброски файлов для прайс-чекера".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
define input  parameter out            as character no-undo .
define input  parameter var-report-num as integer   no-undo .
define variable  vv-full-path        as character no-undo .
define variable  vv-path             as character no-undo .
define variable  vv-file-name        as character no-undo .
define variable  vv-file-name2        as character no-undo .
define variable  vv-file-name-no-ext as character no-undo .
define variable  vv-file-name-ext    as character no-undo .
define stream cash-non.
  do
  on error undo, return error return-value
  :
   run str/waitp.w (
         input (out + 'cash.upd')
        ,input 'Не считана предыдущая информация'
        ,input ' Подождите 15 сек '
        ,input 'Прайс-чекер не ответил. Если Вы уверены, что с ним нет связи нажмите кнопку!'
        ,input 15
        )
        no-error.
if  error-status :error then do:
    return error "Прайс-чекер не обработал предыдущую информацию... " .
end.
else do:
  run gbl/filename.p (
       input  (out + 'cash.non')
      ,output vv-full-path
      ,output vv-path
      ,output vv-file-name
      ,output vv-file-name-no-ext
      ,output vv-file-name-ext    ) no-error .
if vv-file-name = "" then do:
    output stream cash-non to value (out + 'cash.non') .
    put stream cash-non unformatted skip.
    output stream cash-non close.
end.
  os-copy
  value( string( session:temp-directory + "plu" + string( var-report-num ) ) + '.plu' )
  value( out + 'plucash.dat').
  os-copy
  value( string( session:temp-directory + "bar" + string( var-report-num ) ) + '.bar' )
  value( out + 'bar.dat').
  os-delete value( string( session:temp-directory + "plu" + string( var-report-num ) ) + '.plu' ) .
  os-delete value( string( session:temp-directory + "bar" + string( var-report-num ) ) + '.bar' ).
  os-rename value( out + 'cash.non') value( out + 'cash.upd').
end.
  end.