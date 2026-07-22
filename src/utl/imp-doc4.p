/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Импорт накладных

Автор: Молотков Сергей
Дата создания: 10/04/18
Author: Molotkov Sergey
Creation date: 10/04/18

Из имеющегося файла с партиями сформировать накладные по указанным поставщикам и договорам.
В параметрах утилиты должны задаваться:
Имя файла импорта и код ВС, относительно которой внесены соответствия кодов контрагентов.
*/
block-level on error undo, throw.
using ibs.th.gbl.gbl-var.

define input parameter parparentproc    as handle no-undo .
define input parameter p-parent-handle  as handle no-undo . // 24/IX-2018 - не используется
define input parameter p-log-handle     as handle no-undo .
define input parameter p-parameter      as character no-undo .
/*p-parameter включает в себя */
define variable p-in-file     as character no-undo .
define variable p-obj-code    as integer no-undo .
define variable p-obj-type    as character no-undo .
define variable p-is-close    as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Импорт накладных".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i } // &delim-par

define variable local-trace-on as logical no-undo .
define variable log-file-name as character no-undo .

&glob display-message  run write-log-and-file in p-log-handle ( 1, log-file-name, 1, ~{&my-message~} )
/*
&glob display-count-message  run write-counter in p-log-handle (input ~{&my-count-message~})
&glob hide-count-message  run hide-counter in p-log-handle
*/
local-trace-on = false .


/* ----- разбор и проверка входных параметров ----- */
define variable v-input-error as logical no-undo .
define variable v-view-log    as logical no-undo .
define variable v-esm         as character no-undo .
define variable v-num-params  as integer no-undo initial 4 .
/* 20/IV-2018  внутри diallog.w проверяется имя лог-файла.
               Если имя файла задано со слэшом - оно заменяется на имя текущей процедуры.
               Если имя файла задано без слэша - оно пишется в текущую директорию.
               Выбираем второй вариант, как наименьшее зло.
*/
log-file-name = substitute("impdoc4.log", ibs.th.gbl.gbl-inipar:logDir) .
if num-entries(p-parameter, {&delim-par}) = v-num-params then do:
  assign
     p-in-file  =          entry(1, p-parameter, {&delim-par})
     p-obj-code = integer( entry(2, p-parameter, {&delim-par}) )
     p-obj-type =          entry(3, p-parameter, {&delim-par})
     p-is-close = logical( entry(4, p-parameter, {&delim-par}) )
  no-error .
  v-input-error = error-status:error .
  if v-input-error then v-esm = error-status:get-message(1) .
end.
else do:
  assign
    v-input-error = yes
    v-esm         = substitute("Неверное количество ENTRY в составном параметре - &1, должно быть &2"
                             , num-entries(p-parameter, {&delim-par})
                             , v-num-params)
  .
end.
if v-input-error = yes then do:
  &scop my-message substitute("Ошибка входных параметров:&2&1&2&3", p-parameter, {&new-line}, v-esm)
  {&display-message}.
  v-view-log = yes.
  return.
end.


/* ----- загрузка входного файла во временную таблицу ----- */
{utl/imp-parts.i }

define variable v-count-all   as integer no-undo .
define variable v-count-err   as integer no-undo .
/* 12/XII-2018 Если при переносе остатков не нашлось мэппинга для товаров или поставщиков,
               то считать ошибки отдельно и в конце вывести 3 счетчика по ошибкам:
               нет соответствий по товарам, нет соответствий по поставщикам, прочие ошибки.
*/
define variable v-count-err1  as integer no-undo . /* нет соответствий по товарам */
define variable v-count-err2  as integer no-undo . /* нет соответствий по поставщикам */


run import_file in this-procedure (p-in-file, output v-count-all) .
&scop my-message substitute("Всего прочитано &1 записей", v-count-all)
{&display-message}.

/* ----- компоновка принятых строк в партии ----- */
/* есть:
  1. куда = obj-type + obj-code
  2. что  = tt-imp-parts
  3. имена файлов со списками соответствия
  4. имя файла для повторного импорта
   что делает загрузка:
  1. хронометраж через write-log-and-file in p-log-handle
  3. читает списки соответствия
  2. создаёт файл для повторного импорта в формате импорта из файла
*/

/* ----- перекодировка их xxx-15_0 в наш xxx_16_0 ----- */
define variable v-osn-fname as character no-undo .
define variable v-art-fname as character no-undo .
v-osn-fname = substitute("&1_supp.txt", p-obj-code) .
v-art-fname = substitute("&1_gds.txt",  p-obj-code) .

define variable v-err-file-name as character no-undo .
define variable v-str           as character no-undo .
  v-str = entry(1, p-in-file, ".") .
  v-err-file-name = substitute("&2.err"
    , ibs.th.gbl.gbl-inipar:logDir
    , substring(  v-str,  r-index(v-str, "\") + 1  )
  ) .

run utl/imp-doc4cr.p ( parparentproc 
                     , p-log-handle  // хронометраж через write-log-and-file()
                     , log-file-name // имя лог-файла, в который выводится хронометраж
                     , p-obj-code
                     , p-obj-type
                     , p-is-close
                     , v-osn-fname // список соответствия поставщиков
                     , v-art-fname // список соответствия товаров
                     , v-err-file-name // файл для повторного импорта
                     , input table tt-imp-parts
                     , output v-count-err
                     , output v-count-err1
                     , output v-count-err2
                     ) .  


define stream f-inp .
procedure import_file private:
define input  parameter p-file-name as character no-undo .
define output parameter p-count-all as integer no-undo .
define variable v-imp-row as character no-undo .
define variable v-err-msg as character no-undo .
define buffer buf_tt-parts for tt-imp-parts .

  &scop my-message v-err-msg
      
  empty temp-table tt-imp-parts .
  p-count-all = 0 .
  v-err-msg = "" .

  file-info:file-name = p-file-name .
  if file-info:file-type = ? then do :
    v-err-msg = substitute("Отсутствует файл для импорта &1", p-file-name) .
    {&display-message}.
    undo, throw new Progress.Lang.AppError (v-err-msg) .
  end .
    
do on error undo, throw:
  
  input stream f-inp from value(p-file-name) no-echo .
  repeat on endkey undo, leave:
    /* строки импортируемого файла, содержащие ошибки, сохранить в отдельном файле того же формата;
       поэтому каждую прочитанную строку необходимо разбирать поэнтриво и хранить в текстовом виде
       вместе с записью, которая по ней создалась во временной таблице */
    // import stream f-inp DELIMITER ';' tt-imp-parts2 .
    v-imp-row = "" .
    import stream f-inp unformatted v-imp-row .
    p-count-all = p-count-all + 1 .
    if v-imp-row > "" then do:
      if num-entries(v-imp-row, ';') <> 22 then do :
        v-err-msg = "количество полей отличается от 22" .
        leave .
      end .
      
      create buf_tt-parts .
      assign
        buf_tt-parts.artic         = substring(  entry( 1, v-imp-row, ';'),  7  ) // отрезаем начальное "PART: &1;"
        buf_tt-parts.part-code     =      trim(  entry( 3, v-imp-row, ';')  )
        buf_tt-parts.in-code       =      trim(  entry( 4, v-imp-row, ';')  )
        buf_tt-parts.gds-code      =     int64(  entry( 5, v-imp-row, ';')  )
        buf_tt-parts.price-rubl    =   decimal(  entry( 6, v-imp-row, ';')  )
        buf_tt-parts.fact-qnty     =   decimal(  entry( 7, v-imp-row, ';')  )
        buf_tt-parts.vat-tax-value =   decimal(  entry(11, v-imp-row, ';')  )
        buf_tt-parts.name-gtd      =             entry(14, v-imp-row, ';')
        buf_tt-parts.srok-god      =             entry(17, v-imp-row, ';')
        buf_tt-parts.supp-code     =   integer(  entry(20, v-imp-row, ';')  )
        buf_tt-parts.supp-type     =             entry(21, v-imp-row, ';')
        buf_tt-parts.cont-prn-code =             entry(22, v-imp-row, ';')
        buf_tt-parts.imp-row       =                       v-imp-row
      .
      
    end . // end_of v-imp-row > ""
  end. // end_of repeat
  
  catch exAppErrors as class Progress.Lang.AppError :
    v-err-msg = exAppErrors:ReturnValue .
    if v-err-msg > "" then . else do :
      v-err-msg = exAppErrors:GetMessage(1) . 
      if v-err-msg > "" then . else v-err-msg = "AppError в модуле {&FILE-NAME}" .
    end .
  end catch .
  catch exProErrors as class Progress.Lang.ProError :
    v-err-msg = exProErrors:GetMessage(1) . 
    if v-err-msg > "" then . else v-err-msg = "ProError в модуле {&FILE-NAME}" .
  end catch .
  catch exAnyErrors as class Progress.Lang.Error:
    v-err-msg = "Unexpected error в модуле {&FILE-NAME} " + exAnyErrors:GetMessage(1).
  end catch .
  finally: 
    input stream f-inp close.
    if v-err-msg > "" then do :
      v-err-msg = substitute ("Ошибка в строке &1 файла &2: &3 [&4]", p-count-all, p-file-name, v-err-msg, v-imp-row) .
      {&display-message}.
      undo, throw new Progress.Lang.AppError (v-err-msg) .
    end .
  end finally.
end .
  

    if local-trace-on then do:
      define variable dsXmlFileName as character no-undo .
      dsXmlFileName = substitute("&1.xml", entry(1, p-file-name, ".")).
      temp-table tt-imp-parts:WRITE-XML ( "FILE", dsXmlFileName, true, "UTF-8").
    end .
end procedure . /* import_file */
