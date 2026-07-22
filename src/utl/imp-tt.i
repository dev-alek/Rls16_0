/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/21/07
Author: Bakhtadze Natalya
Creation date: 08/21/07

*/



&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure import-in-tt :
define input parameter p-pck-name as character no-undo .

do
on error undo, return error
:

define buffer buf_sys-ctrl          for ub.sys-ctrl .
define variable rec-cnt as integer no-undo .
define variable rec-full      as character no-undo.
define variable rec-name      as character no-undo.
define variable rec-num       as integer   no-undo.
define variable Ok            as logical   no-undo.
define variable sub-rec-cnt   as integer   no-undo.
define variable v-str         as character no-undo .

define variable v-temp-str    as character no-undo .
define variable v-temp-all as character extent 1000 no-undo .

define frame imp-pck
p-pck-name    label "Имя файла" format "x(50)" skip
rec-cnt       label "Записей" skip
v-str         label "" format "x(50)" skip
with view-as dialog-box side-labels 1 columns three-d title "** Разбор файла"
.

assign
  Ok = FALSE
  .
view frame imp-pck.
hide v-str in frame imp-pck.

input stream imp-stream from value( p-pck-name ).

do with frame imp-pck
:
  assign
    p-pck-name :screen-value = string( p-pck-name, p-pck-name :format)
  .
end.

assign
rec-cnt = 0
.

beg-imp:
repeat
on error  undo, return error substitute("&1. error beg-imp. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on endkey undo, return error substitute("&1. endkey beg-imp")
on stop   undo, return error substitute("&1. stop beg-imp")
:

  import stream imp-stream rec-full .
  assign rec-cnt = rec-cnt + 1.
  if rec-full = ? then do:
    undo, return error substitute( "Ошибка приема записи N &1", rec-cnt ) .
  end.
  assign
    rec-name = entry( 1, rec-full, {&delim-nws} )
    .
  do with frame imp-pck
  :
    assign
    p-pck-name :screen-value = string( p-pck-name, p-pck-name :format)
    rec-cnt :screen-value   = string( rec-cnt, rec-cnt :format)
    .
  end.

  transaction_block_otherwise:
  do transaction
  on error  undo, return error substitute("&1. error transaction_block_otherwise &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on endkey undo, return error substitute("&1. endkey transaction_block_otherwise")
  on stop   undo, return error substitute("&1. stop transaction_block_otherwise")
  :
    CASE rec-name:
      when '**END OF PACKET**':U then do:
        assign
          rec-cnt = rec-cnt - 1
          OK = yes
          .
        leave beg-imp.
      end.
      when 'command':U then do:
        assign
        OK = yes
        .
      end.
      otherwise do:
        run proc-load-tt-standart in this-procedure
            ( input rec-name
            ,input this-procedure
            ,input sub-rec-cnt
            ) no-error.
        if error-status:error then do:
          return error return-value + {&new-line} + "запись N" + {&space-char} + string( rec-cnt ) .
        end.
      end. /*otherwise do:*/
    end case.
  end.
end.

input stream imp-stream close.
hide frame imp-pck.

end.

end procedure. /* import-in-tt */





/* $Workfile$ e n d */