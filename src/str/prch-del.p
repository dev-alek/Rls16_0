block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: prch-del.p $
$Archive: str/prch-del.p $

Выплевывание файлов в прайс-чекер на удаление информации

Автор: Чернова Светлана Александровна
Дата создания: 06/16/08
Author: Svetlana Chernova
Creation date: 06/16/08

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: prch-del.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/prch-del.p $":U .
define variable vss-description as character no-undo init "Выплевывание файлов в прайс-чекер на удаление информации".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable  out                  as character no-undo .
define variable out2                  as character      no-undo .
DEFINE VARIABLE in_                   as character      no-undo .
DEFINE VARIABLE spl                   as character      no-undo .
DEFINE VARIABLE sav                   as character      no-undo .
DEFINE VARIABLE v-remote              as character      no-undo .

define variable  vv-full-path         as character no-undo .
define variable  vv-path              as character no-undo .
define variable  vv-file-name         as character no-undo .
define variable  vv-file-name2        as character no-undo .
define variable  vv-file-name-no-ext as character no-undo .
define variable  vv-file-name-ext    as character no-undo .
define stream cash-non.
  do
  on error undo, return error return-value
  :
  find first ub.cash-desk no-lock where
             ub.cash-desk.pos-type = {&cd-type-pricecheck-Servispl} no-error .
if error-status :error then do:
   message "Нет прайс-чекеров Сервис+" view-as alert-box .
   return .
end.
    run str/get-inis.p (
        input {&shop}
      , input ub.cash-desk.obj-code
      , input {&cd-type-pricecheck-Servispl}
      , input ub.cash-desk.remote
      , input "send":U /*некий параметр который говорит для чего нам настройки*/
      , output out /*куда выгружаем*/
      , output out2
      , output in_  /*откуда загружаем*/
      , output spl  /*традиционно*/
      , output sav  /*традиционно*/
      , output v-remote /*файлы Addin.exe*/
      ) no-error .
    run str/waitp.w (
         input (out + 'cash.upd')
        ,input ( 'Не считана предыдущая информация' )
        ,input ' Подождите 15 сек '
        ,input 'Прайс-чекер не ответил. Если Вы уверены, что с ним нет связи нажмите кнопку!'
        ,input 15
        )
        no-error.
  if  error-status :error then do:
    message  "Прайс-чекер не обработал предыдущую информацию... "  view-as alert-box .
    return .
  end.
  else do:
  /* файла-флага нет можно выплевывать */
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

  run gbl/filename.p (
       input  (out + 'plucash.dat')
      ,output vv-full-path
      ,output vv-path
      ,output vv-file-name
      ,output vv-file-name-no-ext
      ,output vv-file-name-ext    ) no-error .
      if vv-file-name = "" then do:
          output stream cash-non to value (out + 'plucash.dat') .
          put stream cash-non unformatted
          "0,0,0,1,,1,,0,0,0,NOSIZE,,,,,,100,0,,18,1,,0,0"
          skip.
          output stream cash-non close.
      end.
  run gbl/filename.p (
       input  (out + 'bar.dat')
      ,output vv-full-path
      ,output vv-path
      ,output vv-file-name
      ,output vv-file-name-no-ext
      ,output vv-file-name-ext    ) no-error .
      if vv-file-name = "" then do:
          output stream cash-non to value (out + 'bar.dat') .
          put stream cash-non unformatted
          "0,0,NOSIZE,1"
          skip.
          output stream cash-non close.
      end.

  os-rename value( out + 'cash.non') value( out + 'cash.cng').
  message "Файл с заданием cash.cng выложен" view-as alert-box information .
end.
  end.