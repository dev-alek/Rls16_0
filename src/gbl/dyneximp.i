/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Испорт-экспорт данных чере динамический буфер

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/15/10
Author: Bakhtadze Natalya
Creation date: 07/15/10

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

FUNCTION dyneximp_export returns character (
                                              INPUT p-bh  AS HANDLE
                                             ,INPUT p-delim   AS CHARACTER
                                             ,input p-order as character
                                             ,input p-except-field-list as character
                                             ):
/*если p-delim = {&space-char}  тогда в виде progress dump в противном случае строковые поля неокавычены */
/*получившееся character значение выводить в stream через put unformatted */
define variable v-fh    AS HANDLE no-undo .
define variable v-ii    AS INTEGER no-undo .
define variable iextnt  as integer no-undo .
define variable v-char   as character no-undo .
define variable carray  as character no-undo .
define variable v-result as character no-undo .
define variable v-num-fields as integer no-undo .
if p-bh:type <> "buffer" then do:
  return ?.
end.
if p-order = '' then do:
  v-num-fields = p-bh:num-fields.
end.
else do:
  v-num-fields = num-entries(p-order).
  if v-num-fields > p-bh:num-fields then do:
    return ?.
  end.
end.

_do:
do v-ii = 1 to v-num-fields:
  if p-order = '' then do:
    assign
    v-fh = p-bh:buffer-field(v-ii)
    no-error
    .
  end.
  else do:
    assign
    v-fh = p-bh:buffer-field(entry(v-ii, p-order))
    no-error
    .
  end.
  if error-status:error
  or not valid-handle(v-fh) then do:
  return ?.
  end.
  if lookup(v-fh:name, p-except-field-list) > 0 then next _do.
  if v-fh:extent = 0 then do:
    assign
    v-char = (if v-fh:buffer-value = ?
              then {&question-mark}
              else (if v-fh:data-type = {&abl-datatype-character}
                    then (if p-delim = {&space-char}
                          then quoter(v-fh:buffer-value)
                          else string(v-fh:buffer-value))
                    else (if v-fh:data-type = {&abl-datatype-raw}
                          then ( if p-delim = {&space-char}
                                 then ({&double-quote} + string(v-fh:buffer-value) + {&double-quote})
                                 else string(v-fh:buffer-value) )
                          else string(v-fh:buffer-value)
                          )
                   )
              )
     v-result = (if v-ii = 1
                 then v-char
                 else v-result + p-delim + v-char)
     .
  end.
  else do:
    do iextnt = 1 to v-fh:extent:
      assign
      v-char = (if v-fh:buffer-value(iextnt) = ?
                then {&question-mark}
                else (if v-fh:data-type = {&abl-datatype-character}
                      then (if p-delim = {&space-char}
                            then quoter(v-fh:buffer-value(iextnt))
                            else string(v-fh:buffer-value(iextnt))
                            )
                      else (if v-fh:data-type = {&abl-datatype-raw}
                           then (if p-delim = {&space-char}
                                 then ({&double-quote} + string(v-fh:buffer-value(iextnt)) + {&double-quote})
                                 else string(v-fh:buffer-value(iextnt)))
                           else string(v-fh:buffer-value(iextnt))
                           )
                      )
               )
      carray = (if iextnt = 1
                then v-char
               else carray + p-delim + v-char)
      .
    end.
    assign
    v-result = (if v-ii = 1
                then carray
               else v-result + p-delim + carray)
    .
  end.
end.
return v-result.
end FUNCTION.


/*чтение обычного прогрессового dump - строковые поля окавычены разделитель пробел*/
/*открытие и закрытие stream пердполагается в основной процедуре*/
procedure dyneximp_dump-import  :
define input parameter p-bh as handle no-undo .
define input parameter p-order as character no-undo .
define input parameter p-except-field-list as character no-undo .
define input parameter p-line-num-field as character no-undo .
define input parameter p-call-handle as handle no-undo .
define input parameter p-err-proc as character no-undo .
define output parameter p-num-rec as integer no-undo .
define output parameter p-num-rec-ok as integer no-undo .

define variable v-import  as character   no-undo extent 512.
define variable v-iimp    as integer     no-undo .
define variable v-ii      as integer     no-undo .
define variable v-iextnt    as integer     no-undo .
define variable v-fh      as handle      no-undo .
define variable v-result  as logical no-undo .
define variable v-line-num as integer no-undo .
define variable v-lnfh as handle no-undo .
define variable glog as logical no-undo .
define variable v-num-fields as integer no-undo .

if p-bh:type <> "buffer" then do:
  return error substitute("Неверный тип handle передан процедуре").
end.
if p-line-num-field <> '' then do:
  assign
  v-lnfh = p-bh:buffer-field(p-line-num-field)
  no-error .
  if not valid-handle(v-lnfh) then do:
    return error substitute("Нет поля &1 в таблице &2, буфер которой передан", p-line-num-field, p-bh:name).
  end.
end.
if p-order = '' then do:
  v-num-fields = p-bh:num-fields.
end.
else do:
  v-num-fields = num-entries(p-order).
end.

if v-num-fields > p-bh:num-fields then do:
  return error substitute("В переданной последовательности полей &1 число полей больше, чем в таблице &2, буффер которой передан"
                           , p-order
                           , p-bh:name
                           ).
end.
_repeat:
repeat:
  assign
  v-import = ""
  v-iimp = 0
  v-line-num = v-line-num + 1
  .
  import stream {1} v-import.
  p-num-rec = p-num-rec + 1.
  p-bh:buffer-create().
  if valid-handle(v-lnfh) then do:
    v-lnfh:buffer-value = v-line-num.
  end.

  _do:
  do v-ii = 1 to v-num-fields:
    if p-order = '' then do:
      assign
      v-fh = p-bh:buffer-field(v-ii)
      no-error
      .
    end.
    else do:
      assign
      v-fh = p-bh:buffer-field(entry(v-ii, p-order))
      no-error
      .
    end.
    if error-status:error
    or not valid-handle(v-fh) then do:
      return error substitute("В переданной последовательности полей &1 указано несуществующее в таблице &2 поле &3"
                              , p-order
                              , p-bh:name
                              , entry(v-ii, p-order)
                              ).
    end.
    if lookup(v-fh:name, p-except-field-list) > 0 then next _do.
    if v-fh:extent = 0 then do:
      assign
      v-iimp = v-iimp + 1
      v-fh:buffer-value = v-import[v-iimp]
      no-error
      .
      if error-status:error then do:
        p-bh:buffer-delete().
        run value(p-err-proc) in p-call-handle ( input substitute("Ошибка при импорте поля &1 (&5) записи из строки &2&3&4"
                                                                , v-fh:column-label
                                                                , v-line-num
                                                                , {&new-line}
                                                                , error-status:get-message(1)
                                                                , v-fh:name
                                                                )
                                                                )
                                                                .
        next _repeat.
      end.
    end.
    else do:
      do v-iextnt = 1 to v-fh:extent:
        assign
        v-iimp = v-iimp + 1
        v-fh:buffer-value(v-iextnt) = v-import[v-iimp]
        no-error
        .
        if error-status:error then do:
          p-bh:buffer-delete().
          run value(p-err-proc) in p-call-handle ( input substitute("Ошибка при импорте поля &1 (&5) записи из строки &2&3&4"
                                                                  , v-fh:column-label
                                                                  , v-line-num
                                                                  , {&new-line}
                                                                  , error-status:get-message(1)
                                                                  , v-fh:name
                                                                  )
                                                                  )
                                                                .
          next _repeat.
        end.
      end.
    end.
  end.
  assign
  glog = p-bh:buffer-validate()
  no-error
  .
  if error-status:error then do:
    p-bh:buffer-delete().
    run value(p-err-proc) in p-call-handle ( substitute("Ошибка при импорте записи из строки &1&2&3"
                                                , v-line-num
                                                , {&new-line}
                                                , error-status:get-message(1) )) no-error .
    next _repeat.
  end.
  p-num-rec-ok = p-num-rec-ok + 1.
end.
end procedure.

/*чтение строки с разделителями - строковые поля не окавычены*/
function dyneximp_import returns logical (
                                           input p-bh as handle
                                          ,input p-delim as character
                                          ,input p-str as character
                                          ,input p-order as character
                                          ,input p-except-field-list as character
                                          ,output p-mes as character
                                          ):
define variable v-entries as integer no-undo .
define variable v-num-fields as integer no-undo .
define variable v-except-fields as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-fh as handle no-undo .
define variable v-iimp as integer no-undo .
define variable v-iextnt as integer no-undo .
define variable v-created as logical no-undo .
if p-bh:type <> "buffer" then do:
  p-mes = "Для импорта передан handle неверного типа".
  return no.
end.
if p-order = '' then do:
  v-num-fields = p-bh:num-fields.
end.
else do:
  v-num-fields = num-entries(p-order) .
  if v-num-fields > p-bh:num-fields then do:
    p-mes =  substitute("В переданной последовательности полей &1 число полей больше, чем в таблице &2, буффер которой передан"
                            , p-order
                            , p-bh:name
                            ).
    return no.
  end.
end.
v-entries = num-entries(p-str, p-delim).
v-except-fields = (if p-except-field-list = '' then 0 else num-entries(p-except-field-list)).
if v-entries < v-num-fields - v-except-fields then do:
  p-mes = substitute("Количество полей в строке импорта (&1) с учетом разделителя (&2) меньше количества выбранных полей (&3)"
                     , num-entries(p-str, p-delim)
                     , p-delim
                     , v-num-fields
                    )
                   .
  return no.
end.

if p-bh:available = no then do:
  v-created = yes.
  p-bh:buffer-create().
end.
do v-ii = 1 to v-num-fields:
  if p-order = '' then do:
    assign
    v-fh = p-bh:buffer-field(v-ii)
    no-error
    .
  end.
  else do:
    assign
    v-fh = p-bh:buffer-field(entry(v-ii, p-order))
    no-error
    .
  end.
  if error-status:error
  or not valid-handle(v-fh) then do:
    p-mes = substitute("В переданной последовательности полей &1 указано несуществующее в таблице &2 поле &3"
                            , p-order
                            , p-bh:name
                            , entry(v-ii, p-order)
                            ).
    if v-created then do:
      p-bh:buffer-delete().
    end.
    return no.
  end.
  if v-fh:extent = 0 then do:
    assign
    v-iimp = v-iimp + 1
    .
    if v-iimp > v-entries - v-except-fields then do:
      p-mes = substitute("Количество полей в строке импорта (&1) с учетом разделителя (&2) меньше количества выбранных полей (&3) "
                        , num-entries(p-str, p-delim)
                        , p-delim
                        , v-num-fields
                        )
                          .
      if v-created then do:
        p-bh:buffer-delete().
      end.
      return no.
    end. /*if v-iimp + 1 < v-entries then d*/
    assign
    v-fh:buffer-value = entry(v-iimp, p-str, p-delim)
    no-error
    .
    if error-status:error then do:
      if v-created then do:
        p-bh:buffer-delete().
      end.
      p-mes = substitute("Ошибка при импорте поля номер &1:&2&3"
                         , v-iimp
                         ,{&new-line}
                         , error-status:get-message(1) ).
      return no.
    end. /*if error-status:error then do:*/
  end. /*if v-fh:extent = 0 then do:*/
  else do:
    do v-iextnt = 1 to v-fh:extent:
      assign
      v-iimp = v-iimp + 1
      .
      if v-iimp > v-entries - v-except-fields then do:
        p-mes = substitute("Количество полей в строке импорта (&1) с учетом разделителя (&2) меньше количества выбранных полей (&3) "
                          , num-entries(p-str, p-delim)
                          , p-delim
                          , v-num-fields
                          )
                            .
        if v-created then do:
          p-bh:buffer-delete().
        end.
        return no.
      end. /*if v-iimp + 1 < v-entries then d*/
      assign
      v-fh:buffer-value(v-iextnt) = entry(v-iimp, p-str, p-delim)
      no-error
      .
      if error-status:error then do:
        if v-created then do:
          p-bh:buffer-delete().
        end.
        p-mes = substitute("Ошибка при импорте поля номер &1:&2&3"
                          , v-iimp
                          ,{&new-line}
                          , error-status:get-message(1) ).
        return no.
      end. /*if error-status:error then do:*/
    end. /*do v-iextnt = 1 to v-fh:extent:*/
  end. /*else if v-fh:extent = 0 then do:*/
end. /*do v-ii = 1 to v-num-fields:*/
return yes.
end function.

function dyneximp_excel-col-name returns character ( input p-col as integer):
define variable v-str as character no-undo init "ABCDEFGHIJKLMNOPQRSTUVWZYX".
return substring(v-str, p-col, 1).
end.

procedure dyneximp_export-excel :
define input parameter p-filename as character no-undo .
define input parameter p-start-row as integer no-undo .
define input parameter p-bh as handle no-undo .
define input parameter p-order as character no-undo .
define input parameter p-except-field-list as character no-undo .
define input parameter p-call-handle as handle no-undo .
define input parameter p-err-proc as character no-undo .
define output parameter p-num-rec as integer no-undo .
define output parameter p-num-rec-ok as integer no-undo .

define variable chExcelApplication as com-handle no-undo .
define variable chWorkbook         as com-handle no-undo .
define variable chWorksheet        as com-handle no-undo .
define variable chRange            as com-handle no-undo .
define variable v-last-row as integer no-undo .
define variable v-last-column as integer no-undo .
define variable v-row as integer no-undo .
define variable v-head-row as integer no-undo .
define variable v-num-fields as integer no-undo .
define variable v-ii as integer no-undo .
DEFINE VARIABLE v-dec-separ      as character no-undo .
DEFINE VARIABLE v-th-separ       as character no-undo .
define variable v-line-num as integer no-undo .
define variable v-lnfh as handle no-undo .
define variable v-fh as handle no-undo .
define variable v-text as character no-undo .
define variable v-dop as character no-undo .
define variable v-excel-general-format as character no-undo .
define variable v-excel-short-date as character no-undo .
define variable v-excel-dec-separ as character no-undo .
define variable v-excel-th-separ as character no-undo .
define variable v-excel-date-separ as character no-undo .
define variable v-qh as handle no-undo .
define variable v-print as logical no-undo .

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if p-bh:type <> "buffer" then do:
    return error "Для экспорта передан handle неверного типа".
  end.
  if p-order = '' then do:
    v-num-fields = p-bh:num-fields.
  end.
  else do:
    v-num-fields = num-entries(p-order) .
    if v-num-fields > p-bh:num-fields then do:
      return error  substitute("В переданной последовательности полей &1 число полей больше, чем в таблице &2, буффер которой передан"
                              , p-order
                              , p-bh:name
                              ).
    end.
  end.
  create "Excel.Application" chExcelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.  
  assign
  chExcelApplication:interactive     = false
  chExcelApplication:ScreenUpdating  = false
  chExcelApplication:visible         = false
  chExcelApplication:DisplayAlerts   = false
  .
  assign
  v-excel-general-format =  chExcelApplication:International(26 /*xlGeneralFormatName*/ )
  v-excel-short-date =  chExcelApplication:International(32 /*xlDateOrder*/ )
  v-excel-dec-separ = chExcelApplication:International(3 /*xlDecimalSeparator*/ )
  v-excel-th-separ = chExcelApplication:International(4 /*xlThousandsSeparator*/ )
  v-excel-date-separ = chExcelApplication:International(17 /*xlDateSeparator*/ )
  /*
  0 = month-day-year
  1 = day-month-year
  2 = year-month-day
  */
  no-error
  .
  v-head-row = maximum(p-start-row - 1, 0).
  v-row = v-head-row - 1.
  chExcelApplication:WorkBooks:Add().
  chWorkbook = chExcelApplication:WorkBooks:Item(1).
  chWorksheet = chWorkbook:ActiveSheet.
  if v-head-row > 0 then do:
    chWorkSheet:Rows(substitute("&1:&1", v-head-row)):Select.
    chExcelApplication:Selection:Font:Bold = True.
  end.
  _row:
  do while true
  on error  undo _row, retry
  on stop   undo _row, retry
  on endkey undo _row, retry
  :
    if retry then do:
      { cmp/relescom.i chWorkSheet }
      { cmp/relescom.i chWorkBook }
      chExcelApplication:Quit() no-error.
      { cmp/relescom.i chExcelApplication }
      delete object v-qh no-error.
      return error substitute("Ошибка при экспорте в файл &1:&2&3"
                              , p-filename
                              , {&new-line}
                              , error-status:get-message(1)
                              ).

    end.

    v-row = v-row + 1.
    if v-row > v-head-row then do:
      p-num-rec = p-num-rec + 1.
    end.
    do v-ii = 1 to v-num-fields:
      v-text = ''.
      if p-order = '' then do:
        assign
        v-fh = p-bh:buffer-field(v-ii)
        no-error
        .
      end.
      else do:
        assign
        v-fh = p-bh:buffer-field(entry(v-ii, p-order))
        no-error
        .
      end.
      if error-status:error
      or not valid-handle(v-fh) then do:
        { cmp/relescom.i chWorkSheet }
        { cmp/relescom.i chWorkBook }
        chExcelApplication:Quit() no-error.
        { cmp/relescom.i chExcelApplication }
        delete object v-qh.
        return error substitute("В переданной последовательности полей &1 указано несуществующее в таблице &2 поле &3"
                                , p-order
                                , p-bh:name
                                , entry(v-ii, p-order)
                                ).
      end. /*if error-status:error*/
      if v-row = v-head-row then do:
        if v-ii = 1 then do:
          create query v-qh.
          v-qh:set-buffers(p-bh).
          v-qh:query-prepare( substitute(" for each &1 ", p-bh:name )) .
          v-qh:query-open().
        end. /*if v-ii = 1 then do:*/
        if v-head-row > 0 then do:
          assign
          chWorkSheet:range( substitute("&1&2", dyneximp_excel-col-name(v-ii), v-head-row)):value = v-fh:column-label
          no-error
          .
        end.
        chWorkSheet:Columns( substitute("&1:&1", dyneximp_excel-col-name(v-ii), dyneximp_excel-col-name(v-ii))):Select.
        case v-fh:data-type:
          when {&abl-datatype-character} then do:
            chExcelApplication:Selection:NumberFormat = "@".
          end.
          when {&abl-datatype-date} then do:
            case v-excel-short-date:
              when string(0) then do: /*month-day-year*/
                chExcelApplication:Selection:NumberFormat = substitute("mm&1dd&1yyyy", v-excel-date-separ).
              end.
              when string(1) then do: /*day-month-year*/
                chExcelApplication:Selection:NumberFormat = substitute("dd&1mm&1yyyy", v-excel-date-separ).
              end.
              when string(2) then do: /*year-month-day*/
                chExcelApplication:Selection:NumberFormat = substitute("yyyy&1mm&1dddd", v-excel-date-separ).
              end.
            end case.
          end.
          when {&abl-datatype-decimal} then do:
            chExcelApplication:Selection:NumberFormat = replace(substitute("0.&1"
                                                                          , fill(string(0), length(entry(2, v-fh:format, ".")))
                                                                          ), ".", v-excel-dec-separ).
          end.
          when {&abl-datatype-integer} then do:
            chExcelApplication:Selection:NumberFormat = "0".
          end.
          when {&abl-datatype-logical} then do:
            chExcelApplication:Selection:NumberFormat = "@".
          end.
        end case.
      end. /*if v-row = v-head-row then do:*/
      else do:
        if v-ii = 1 then do:
          v-qh:get-next() no-error.
          if v-qh:query-off-end then do:
            p-num-rec = p-num-rec - 1.
            leave _row.
          end.
        end.
        v-print = yes.
        case v-fh:data-type:
          when {&abl-datatype-character} then do:
            if v-fh:buffer-value = ? then do:
              v-text = {&question-mark}.
            end.
            else do:
              assign
              v-text = v-fh:buffer-value
              .
            end.
          end.
          when {&abl-datatype-date} then do:
            if v-fh:buffer-value = ? then do:
              v-print = no.
            end.
            else do:
              assign
              v-dop = string(v-fh:buffer-value, "99/99/9999")
              .
              case v-excel-short-date:
                when string(0) then do: /*month-day-year*/
                  /*ничего*/
                  assign
                  v-text = v-dop.
                end.
                when string(1) then do: /*day-month-year*/
                  assign
                  v-text = entry(2, v-dop, {&slash-char}) + {&slash-char} +
                          entry(1, v-dop, {&slash-char}) + {&slash-char} +
                          entry(3, v-dop, {&slash-char})
                  no-error
                  .
                end.
                when string(2) then do: /*year-month-day*/
                  assign
                  v-text = entry(3, v-dop, {&slash-char}) + {&slash-char} +
                          entry(1, v-dop, {&slash-char}) + {&slash-char} +
                          entry(2, v-dop, {&slash-char})
                  no-error
                  .
                end.
              end case.
            end. /*else if v-fh:buffer-value = ? then do:*/
          end.
          when {&abl-datatype-decimal} then do:
            if v-fh:buffer-value = ? then do:
              v-print = no.
            end.
            else do:
              assign
              v-dop = string(v-fh:buffer-value)
              v-text = replace(v-dop, ".", chr(1))
              v-text = replace(v-dop, ",", chr(2))
              v-text = replace(v-dop, chr(1), v-excel-dec-separ)
              v-text = replace(v-dop, chr(2), v-excel-th-separ)
              .
            end.
          end.
          when {&abl-datatype-integer} then do:
            if v-fh:buffer-value = ? then do:
              v-print = no.
            end.
            else do:
              assign
              v-text = string(v-fh:buffer-value)
              .
            end.
          end.
          when {&abl-datatype-logical} then do:
            if v-fh:buffer-value = ? then do:
              v-print = no.
            end.
            assign
            v-text = string(v-fh:buffer-value, "true/false")
            no-error
            .
          end.
        end case.
      end. /*if v-row = v-head-row then do:*/
      if v-print then do:
        assign
        chWorkSheet:range( substitute("&1&2", dyneximp_excel-col-name(v-ii), v-row)):value = v-text
        no-error
        .
        if error-status:error then do:
          run value(p-err-proc) in p-call-handle ( input substitute("Ошибка при импорте поля &1 (&5) из строки &2:&3&4"
                                          , v-fh:column-label
                                          , v-row
                                          , {&new-line}
                                          , error-status:get-message(1)
                                          , v-fh:name
                                          )) no-error .
          next _row.
        end. /*if error-status:error then do:*/
      end.
    end. /*    do v-ii = 1 to v-num-fields:*/
    if v-row > v-head-row then do:
    p-num-rec-ok = p-num-rec-ok + 1.
    end.
  end. /*do v-row = p-start-row to v-last-row*/
  delete object v-qh no-error.
  /* автоподбор ширины колонок */
  chWorkSheet:Columns("A:Z"):Select.
  /*chExcelApplication:Selection:WrapText = true.*/
  chExcelApplication:Selection:Columns:AutoFit.



  /* Сохраняем */
  chWorkbook:SaveAs(p-filename , -4143 , "" , "", false, false , 1).
  /* Закрываем книгу */
  chWorkbook:Close().

  { cmp/relescom.i chWorkSheet }
  { cmp/relescom.i chWorkBook }
  chExcelApplication:Quit() no-error.
  { cmp/relescom.i chExcelApplication }
end. /*doe*/
end procedure. /* dyneximp_export-excel */


procedure dyneximp_import-excel:
define input parameter p-filename as character no-undo .
define input parameter p-start-row as integer no-undo .
define input parameter p-bh as handle no-undo .
define input parameter p-order as character no-undo .
define input parameter p-except-field-list as character no-undo .
define input parameter p-line-num-field as character no-undo .
define input parameter p-call-handle as handle no-undo .
define input parameter p-err-proc as character no-undo .
define output parameter p-num-rec as integer no-undo .
define output parameter p-num-rec-ok as integer no-undo .

define variable chExcelApplication as com-handle no-undo .
define variable chWorkbook         as com-handle no-undo .
define variable chWorksheet        as com-handle no-undo .
define variable chRange            as com-handle no-undo .
define variable v-last-row as integer no-undo .
define variable v-last-column as integer no-undo .
define variable v-row as integer no-undo .
define variable v-num-fields as integer no-undo .
define variable v-ii as integer no-undo .
DEFINE VARIABLE v-dec-separ      as character no-undo .
DEFINE VARIABLE v-th-separ       as character no-undo .
define variable v-line-num as integer no-undo .
define variable v-lnfh as handle no-undo .
define variable v-fh as handle no-undo .
define variable v-text as character no-undo .
define variable v-dop as character no-undo .
define variable v-excel-general-format as character no-undo .
define variable v-excel-short-date as character no-undo .
define variable v-excel-dec-separ as character no-undo .
define variable v-excel-th-separ as character no-undo .
define variable v-excel-date-separ as character no-undo .



main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if p-bh:type <> "buffer" then do:
    return error "Для импорта передан handle неверного типа".
  end.
  if p-order = '' then do:
    v-num-fields = p-bh:num-fields.
  end.
  else do:
    v-num-fields = num-entries(p-order) .
    if v-num-fields > p-bh:num-fields then do:
      return error  substitute("В переданной последовательности полей &1 число полей больше, чем в таблице &2, буффер которой передан"
                              , p-order
                              , p-bh:name
                              ).
    end.
  end.
  if p-line-num-field <> '' then do:
    assign
    v-lnfh = p-bh:buffer-field(p-line-num-field)
    no-error .
    if not valid-handle(v-lnfh) then do:
      return error substitute("Нет поля &1 в таблице &2, буфер которой передан", p-line-num-field, p-bh:name).
    end.
  end.
  create "Excel.Application" chExcelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.  
  assign
  chExcelApplication:interactive     = false
  chExcelApplication:ScreenUpdating  = false
  chExcelApplication:visible         = false
  chExcelApplication:DisplayAlerts   = false
  .
  assign
  v-excel-general-format =  chExcelApplication:International(26 /*xlGeneralFormatName*/ )
  v-excel-short-date =  chExcelApplication:International(32 /*xlDateOrder*/ )
  v-excel-dec-separ = chExcelApplication:International(3 /*xlDecimalSeparator*/ )
  v-excel-th-separ = chExcelApplication:International(4 /*xlThousandsSeparator*/ )
  v-excel-date-separ = chExcelApplication:International(17 /*xlDateSeparator*/ )
  /*
  0 = month-day-year
  1 = day-month-year
  2 = year-month-day
  */
  no-error
  .

  chWorkBook   = chExcelApplication:WorkBooks:open( p-filename ).
  chWorkSheet  = chExcelApplication:Sheets:item (1).

  /*
  Номер последней строки с данными
  ActiveSheet.Cells.SpecialCells(xlCellTypeLastCell).Row
  xlCellTypeLastCell = 11
  */
  assign
  v-last-row = chWorkSheet:Cells:SpecialCells(11):Row
  v-last-column = chWorkSheet:Cells:SpecialCells(11):Column
  no-error .

  if v-last-row = ? or v-last-row = 0
  then do:
    { cmp/relescom.i chWorkSheet }
    { cmp/relescom.i chWorkBook }
     chExcelApplication:Quit() no-error.
    { cmp/relescom.i chExcelApplication }
    return error substitute("В файле не удалось определить диапазон данных по строке крайней используемой ячейки."
                            , p-filename
                            ).
  end.
  if v-last-row <= p-start-row - 1
  then do:
    { cmp/relescom.i chWorkSheet }
    { cmp/relescom.i chWorkBook }
    chExcelApplication:Quit() no-error.
    { cmp/relescom.i chExcelApplication }
    return error substitute("Количества строк в шапке файла &1 задано равным &2, номер последней строки в листе=&3,&4диапазон данных на листе задан неверно или данных нет."
                            , p-filename
                            , p-start-row - 1
                            , v-last-row
                            , {&new-line}
                            ).
  end.

  if v-last-column = ? or v-last-column = 0
  then do:
    { cmp/relescom.i chWorkSheet }
    { cmp/relescom.i chWorkBook }
    chExcelApplication:Quit() no-error.
    { cmp/relescom.i chExcelApplication }
    return error substitute("В файле &1 не удалось определить диапазон данных по столбцу крайней используемой ячейки."
                            , p-filename
                            ).
  end.
  if v-last-column < v-num-fields then do:
    { cmp/relescom.i chWorkSheet }
    { cmp/relescom.i chWorkBook }
    chExcelApplication:Quit() no-error.
    { cmp/relescom.i chExcelApplication }
    return error substitute("В файле &1 количество используемых столбцов = &2, а количество заданных для импорта полей =&3."
                            , p-filename
                            , v-last-column
                            , v-num-fields
                            ).
  end.

  /* автоподбор ширины колонок */
  chWorkSheet:Columns("A:Z"):Select.
  chExcelApplication:Selection:Columns:AutoFit.


  _row:
  do v-row = p-start-row to v-last-row
  on error  undo _row, retry
  on stop   undo _row, retry
  on endkey undo _row, retry
  :
    if retry then do:
      { cmp/relescom.i chWorkSheet }
      { cmp/relescom.i chWorkBook }
      chExcelApplication:Quit() no-error.
      { cmp/relescom.i chExcelApplication }
      return error substitute("Ошибка при импорте из файла &1:&2&3"
                              , p-filename
                              , {&new-line}
                              , error-status:get-message(1)
                              ).

    end.
    v-line-num = v-line-num + 1.
    p-num-rec = p-num-rec + 1.
    p-bh:buffer-create().
    if valid-handle(v-lnfh) then do:
      v-lnfh:buffer-value = v-line-num.
    end.

    do v-ii = 1 to v-num-fields:
      v-text = ''.
      assign
      v-text = chWorkSheet:range( substitute("&1&2", dyneximp_excel-col-name(v-ii), v-row)):text
      .
      if p-order = '' then do:
        assign
        v-fh = p-bh:buffer-field(v-ii)
        no-error
        .
      end.
      else do:
        assign
        v-fh = p-bh:buffer-field(entry(v-ii, p-order))
        no-error
        .
      end.
      if error-status:error
      or not valid-handle(v-fh) then do:
        { cmp/relescom.i chWorkSheet }
        { cmp/relescom.i chWorkBook }
        chExcelApplication:Quit() no-error.
        { cmp/relescom.i chExcelApplication }
        return error substitute("В переданной последовательности полей &1 указано несуществующее в таблице &2 поле &3"
                                , p-order
                                , p-bh:name
                                , entry(v-ii, p-order)
                                ).
      end.
      case v-fh:data-type:
        when {&abl-datatype-character} then do:
          assign
          v-fh:buffer-value =  v-text
          no-error
          .
        end.
        when {&abl-datatype-date} then do:
          assign
          v-dop = replace(v-text, v-excel-date-separ, {&slash-char})
          no-error
          .
          case v-excel-short-date:
            when string(0) then do: /*month-day-year*/
              assign
              v-fh:buffer-value =  date(integer(entry(1, v-dop, {&slash-char}))
                                       ,integer(entry(2, v-dop, {&slash-char}))
                                       ,integer(entry(3, v-dop, {&slash-char}))
                                       )
              no-error
              .
            end.
            when string(1) then do: /*day-month-year*/
              assign
              v-fh:buffer-value =  date(integer(entry(2, v-dop, {&slash-char}))
                                       ,integer(entry(1, v-dop, {&slash-char}))
                                       ,integer(entry(3, v-dop, {&slash-char}))
                                       )
              no-error
              .

            end.
            when string(2) then do: /*year-month-day*/
              assign
              v-fh:buffer-value =  date(integer(entry(2, v-dop, {&slash-char}))
                                       ,integer(entry(3, v-dop, {&slash-char}))
                                       ,integer(entry(1, v-dop, {&slash-char}))
                                       )
              no-error
              .
            end.
          end case.
        end.
        when {&abl-datatype-decimal} then do:
          v-dop = replace(v-text, v-excel-th-separ, "").
          v-dop = replace(v-dop, v-excel-dec-separ, ".").
          assign
          v-fh:buffer-value = decimal(v-dop)
          no-error
          .
        end.
        when {&abl-datatype-integer} then do:
          assign
          v-dop = replace(v-text, v-excel-th-separ, "").
          v-fh:buffer-value = integer(v-dop)
          no-error
          .
        end.
        when {&abl-datatype-logical} then do:
          assign
          v-fh:buffer-value = logical(v-dop)
          no-error
          .
        end.
      end case.
      if error-status:error then do:
         p-bh:buffer-delete().
         run value(p-err-proc) in p-call-handle ( input substitute("Ошибка при импорте поля &1 (&5) из строки &2:&3&4"
                                        , v-fh:column-label
                                        , v-row
                                        , {&new-line}
                                        , error-status:get-message(1)
                                        , v-fh:name
                                        )) no-error .
        next _row.
      end.
    end. /* _read-loop: */
    p-num-rec-ok = p-num-rec-ok + 1.
  end. /*do v-row = p-start-row to v-last-row*/
  { cmp/relescom.i chWorkSheet }
  { cmp/relescom.i chWorkBook }
  chExcelApplication:Quit() no-error.
  { cmp/relescom.i chExcelApplication }


end. /*doe*/
end procedure. /* dyneximp.i */



/* $workfile: asc-gds.i $ e n d */