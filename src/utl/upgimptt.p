block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: upgimptt.p $
$Archive: utl/upgimptt.p $

Процедура импорта текстового файла в процессе upgrade во ВРЕМЕННЫЕ ТАБЛИЦЫ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/21/07
Author: Bakhtadze Natalya
Creation date: 08/21/07

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: upgimptt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/upgimptt.p $":U .
define variable vss-description as character no-undo init "Процедура импорта текстового файла в процессе upgrade во ВРЕМЕННЫЕ ТАБЛИЦЫ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
define stream Imp-stream.
define variable rec-cnt       as integer   no-undo.
define variable file-pck-name as   character            no-undo. /* файл из которого происходит импорт */
{ utl/upgimptt.i def shared }
{ utl/upgimptt.i proc }
{ gbl/key-rec.i }
&scop wrlf run write-log-and-file in p-log-handle (                 ~
          input 1                                                 ~
        , input log-file-name                                     ~
        , input 1                                                 ~
        , input ~{&my-message~})





if transaction then do:
  message
    vss-workfile vss-revision vss-description skip
    substitute( "Вызов данной процедуры невозможен при наличии транзакции" )
    view-as alert-box error
  .
  return error .
/*  return error substitute( "&1. Вызов данной процедуры невозможен при наличии транзакции", vss-workfile ).*/
end.

main_block:
do
on error  undo, return error substitute("&1. error main_block. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on endkey undo, return error substitute("&1. endkey main_block")
on stop   undo, return error substitute("&1. stop main_block")
:

  define buffer buf_sys-ctrl          for ub.sys-ctrl .
  define variable rec-full      as character no-undo.
  define variable rec-name      as character no-undo.
  define variable rec-num       as integer   no-undo.
  define variable v-uniq-key-rt as character no-undo .
  define variable Ok            as logical   no-undo.
  define variable v-ind         as integer   no-undo.
  define variable sub-rec-cnt   as integer   no-undo.

  define variable v-today       as date      no-undo .
  define variable v-time        as integer   no-undo .
  define variable v-str         as character no-undo .

  define variable v-temp-str    as character no-undo .
  define variable v-temp-all as character extent 1000 no-undo .
  define variable log-file-name as character no-undo init "upg-imp.txt".
  define variable v-return-value as character no-undo .

  /*define buffer buf_temp-tables for temp-tables.*/


   file-pck-name = p-parameter.

  assign
    Ok = FALSE
    .
  input stream imp-stream from value( file-pck-name ).
  &scop my-message substitute("Выполняется импорт  из файла &1....", file-pck-name)
  {&wrlf}.
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
      &scop my-message substitute( "Ошибка приема записи N &1", rec-cnt )
      {&wrlf}.
      undo, return error substitute( "Ошибка приема записи N &1", rec-cnt ) .
    end.
    assign
      rec-name = entry( 1, rec-full, {&delim-nws} )
      .
    run write-counter in p-log-handle ( input substitute("Кол-во считанных записей &1", rec-cnt)).

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
          &scop my-message substitute("Конец импорта файла &1", file-pck-name)
          {&wrlf}.
          leave beg-imp.
        end.
        when 'command':U then do:
          run proc-load-tt-command in this-procedure
                                                  (
                                                    input rec-full
                                                  ,input this-procedure
                                                  ,input sub-rec-cnt
                                                  ) no-error.
          if error-status:error then do:
            v-return-value = return-value .
            &scop my-message (v-return-value + {&new-line} + "запись N" + {&space-char} + string( rec-cnt ))
            {&wrlf}.
            return error (v-return-value + {&new-line} + "запись N" + {&space-char} + string( rec-cnt )) .
          end.
        end.
        otherwise do:
          run proc-load-tt-standart in this-procedure
              ( input rec-name
              ,input this-procedure
              ,input sub-rec-cnt
              ) no-error.
          if error-status:error then do:
             v-return-value = return-value .
            &scop my-message (v-return-value + {&new-line} + "запись N" + {&space-char} + string( rec-cnt ))
            {&wrlf}.
            return error (v-return-value + {&new-line} + "запись N" + {&space-char} + string( rec-cnt ) ).
          end.
        end.
      end case.
    end.
  end.

  input stream imp-stream close.
  hide frame   imp-pck.
end.
return '':U.