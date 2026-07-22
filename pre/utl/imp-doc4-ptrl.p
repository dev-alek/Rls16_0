block-level on error undo, throw.
using ibs.th.gbl.gbl-var.
define input parameter parparentproc    as handle no-undo .
define input parameter p-parent-handle  as handle no-undo . // 24/IX-2018 - не используется
define input parameter p-log-handle     as handle no-undo .
define input parameter p-parameter      as character no-undo .
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
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
  // &delim-par
define variable local-trace-on as logical no-undo .
define variable log-file-name as character no-undo .
local-trace-on = false .
define variable v-input-error as logical no-undo .
define variable v-view-log    as logical no-undo .
define variable v-esm         as character no-undo .
define variable v-num-params  as integer no-undo initial 4 .
log-file-name = substitute("impdoc4.log", ibs.th.gbl.gbl-inipar:logDir) .
if num-entries(p-parameter, chr(4)) = v-num-params then do:
  assign
     p-in-file  =          entry(1, p-parameter, chr(4))
     p-obj-code = integer( entry(2, p-parameter, chr(4)) )
     p-obj-type =          entry(3, p-parameter, chr(4))
     p-is-close = logical( entry(4, p-parameter, chr(4)) )
  no-error .
  v-input-error = error-status:error .
  if v-input-error then v-esm = error-status:get-message(1) .
end.
else do:
  assign
    v-input-error = yes
    v-esm         = substitute("Неверное количество ENTRY в составном параметре - &1, должно быть &2"
                             , num-entries(p-parameter, chr(4))
                             , v-num-params)
  .
end.
if v-input-error = yes then do:
    run write-log-and-file in p-log-handle ( 1, log-file-name, 1, substitute("Ошибка входных параметров:&2&1&2&3", p-parameter, chr(10), v-esm) ).
  v-view-log = yes.
  return.
end.
define temp-table tt-imp-parts-ptrl no-undo // скопировано из utl/imp-doc4.p
   field artic         as character
           field f02           as character
   field part-code     as character
   field in-code       like ub.parts.in-code
   field gds-code      as integer
   field price-rubl    like ub.parts.price-rubl
   field fact-qnty     like ub.parts.fact-qnty
           field f08           as character
           field f09           as character
           field f10           as character
   field vat-tax-value as decimal
           field f12           as character
           field f13           as character
   field name-gtd      as character
           field f15           as character
           field f16           as character
   field srok-god      as character
           field f18           as character
           field f19           as character
   field supp-code     as integer
   field supp-type     as character
   field cont-prn-code like ub.contract.contract-prn-code
   field pl-loc1       as character
   field cli-qnty      as decimal
           field imp-row       as character // исходая строка из файла импорта
.
define variable v-count-all   as integer no-undo .
define variable v-count-err   as integer no-undo .
define variable v-count-err1  as integer no-undo .
define variable v-count-err2  as integer no-undo .
run import_file in this-procedure (p-in-file, output v-count-all) .
run write-log-and-file in p-log-handle ( 1, log-file-name, 1, substitute("Всего прочитано &1 записей", v-count-all) ).
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
run utl/imp-doc4cr-ptrl.p ( parparentproc
                         , p-log-handle  // хронометраж через write-log-and-file()
                         , log-file-name // имя лог-файла, в который выводится хронометраж
                         , p-obj-code
                         , p-obj-type
                         , p-is-close
                         , v-osn-fname // список соответствия поставщиков
                         , v-art-fname // список соответствия товаров
                         , v-err-file-name // файл для повторного импорта
                         , input table tt-imp-parts-ptrl
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
define buffer buf_tt-parts for tt-imp-parts-ptrl .
  empty temp-table tt-imp-parts-ptrl .
  p-count-all = 0 .
  v-err-msg = "" .
  file-info:file-name = p-file-name .
  if file-info:file-type = ? then do :
    v-err-msg = substitute("Отсутствует файл для импорта &1", p-file-name) .
    run write-log-and-file in p-log-handle ( 1, log-file-name, 1, v-err-msg ).
    undo, throw new Progress.Lang.AppError (v-err-msg) .
  end .
do on error undo, throw:
  input stream f-inp from value(p-file-name) no-echo .
  repeat on endkey undo, leave:
    // import stream f-inp DELIMITER '` tt-imp-parts2 .

    v-imp-row = "" .
    import stream f-inp unformatted v-imp-row .
    p-count-all = p-count-all + 1 .
    if v-imp-row > "" then do:
      if num-entries(v-imp-row, ';') <> 25 then do :
        v-err-msg = "количество полей отличается от 25" .
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
        buf_tt-parts.pl-loc1       =             entry(23, v-imp-row, ';')
        buf_tt-parts.cli-qnty      =   decimal(  entry(24, v-imp-row, ';')  )
        buf_tt-parts.imp-row       =                       v-imp-row
      .
      
    end . // end_of v-imp-row > ""

  end. // end_of repeat

  
  catch exAppErrors as class Progress.Lang.AppError :
    v-err-msg = exAppErrors:ReturnValue .
    if v-err-msg > "" then . else do :
      v-err-msg = exAppErrors:GetMessage(1) . 
      if v-err-msg > "" then . else v-err-msg = "AppError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\utl\imp-doc4-ptrl.p" .
    end .
  end catch .
  catch exProErrors as class Progress.Lang.ProError :
    v-err-msg = exProErrors:GetMessage(1) . 
    if v-err-msg > "" then . else v-err-msg = "ProError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\utl\imp-doc4-ptrl.p" .
  end catch .
  catch exAnyErrors as class Progress.Lang.Error:
    v-err-msg = "Unexpected error в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\utl\imp-doc4-ptrl.p " + exAnyErrors:GetMessage(1).
  end catch .
  finally: 
    input stream f-inp close.
    if v-err-msg > "" then do :
      v-err-msg = substitute ("Ошибка в строке &1 файла &2: &3 [&4]", p-count-all, p-file-name, v-err-msg, v-imp-row) .
      run write-log-and-file in p-log-handle ( 1, log-file-name, 1, v-err-msg ).
      undo, throw new Progress.Lang.AppError (v-err-msg) .
    end .
  end finally.
end .
  

    if local-trace-on then do:
      define variable dsXmlFileName as character no-undo .
      dsXmlFileName = substitute("&1.xml", entry(1, p-file-name, ".")).
      temp-table tt-imp-parts-ptrl:WRITE-XML ( "FILE", dsXmlFileName, true, "UTF-8").
    end .
end procedure . /* import_file */
