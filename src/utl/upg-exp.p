block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: upg-exp.p $
$Archive: utl/upg-exp.p $

Экспорт в формате пакета новостей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/31/07
Author: Bakhtadze Natalya
Creation date: 01/31/07

может использоватеься в upgrade

*/

define input  parameter file-pck-name as   character            no-undo . /* файл в который происходит экспорт                     */
define input  parameter old-pck-name  as   character            no-undo . /* файл на который накатывается delta                   */

define input  parameter p-mode        as   character            no-undo .
define input  parameter p-append      as   logical              no-undo .
define input  parameter p-first       as   logical              no-undo .
define input  parameter p-last        as   logical              no-undo .
define input  parameter p-tbl-names   as   character            no-undo .
/*список из названий таблиц - до 4 штук выгружается только по таблице p-buffer-num*/
define input  parameter p-buffer-num  as integer no-undo .
define input  parameter p-prepare-phrase as character no-undo .
define input-output parameter num-exp-rec   as   integer              no-undo . /* кол-во export*/
define input-output parameter err-gen-pack  as   integer              no-undo . /* 0 - нет ошибок */


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: upg-exp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/upg-exp.p $":U .
define variable vss-description as character no-undo init "Экспорт в формате пакета новостей".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
define stream ddl .
{ utl/upg-exp.i "'def'" new }
{ gbl/findlock.i }
{ gbl/key-rec.i }
define stream Imp-stream.
define stream Imp2-stream.
{ utl/upgimptt.i  def }
{ utl/upgimptt.i  proc }
{ utl/imp-tt.i }


define variable rec-cnt as integer no-undo .

define variable v-today    as date    no-undo .
define variable v-time     as integer no-undo .

define variable v-uniq-key-rt    as character no-undo .

define variable tt-name         as character no-undo .
define variable tth             as handle    no-undo .
define variable bh_tt           as handle    no-undo .
define variable v-ok            as logical   no-undo .
define variable buf_h           as handle    no-undo extent 4.
define variable q_h             as handle    no-undo .
define variable v-uniq-key-rec  as character no-undo .
define variable v-tbl-name      as character no-undo extent 4.
define variable v-ii            as integer   no-undo .
define variable v-inform         as character no-undo .
define variable v-idx-field-qnty as integer   no-undo .
define variable v-field-name     as character no-undo .
define variable v-field-val      as character no-undo .
define variable v-word-link      as character no-undo .
define variable v-where          as character no-undo .
define variable fh_tbl-name      as handle    no-undo .
define variable fh_tt           as handle    no-undo .
define variable v-to-export as logical no-undo .
define variable compare-log     as logical   no-undo.
define variable v-tbl-row        as rowid     no-undo .
define variable v-full-tbl-name as character no-undo .
define variable bh_tbl-name     as handle no-undo .
define variable v-ind         as integer   no-undo.
define variable ss as character no-undo .


define frame exp-pck
  file-pck-name label "Файл" format "x(40)" skip
  rec-cnt       label "Записей в файле"
  with view-as dialog-box side-labels 1 columns three-d title "** Экспорт пакета".

if transaction then do:
  message
    vss-workfile vss-revision vss-description skip
    substitute( "Вызов данной процедуры невозможен при наличии транзакции" )
    view-as alert-box error
  .
  return error .
/*  return error substitute( "&1. Вызов данной процедуры невозможен при наличии транзакции", vss-workfile ).*/
end.

if old-pck-name <> '':U then do:
  run import-in-tt in this-procedure ( input old-pck-name) no-error.
  if error-status:error then do :
    return error substitute("Ошибка при чтении файла &1", old-pck-name).
  end.
end.

rec-cnt = num-exp-rec.

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:

  view frame exp-pck.
  if not p-append then
  assign
    err-gen-pack = 0
  .
  display
    file-pck-name
    with frame exp-pck.

  if p-append then do:
    { utl/upg-exp.i "'open'" file-pck-name  append entry(p-buffer-num,p-tbl-names) }
  end.
  else do:
    { utl/upg-exp.i "'open'" file-pck-name  " "     entry(p-buffer-num,p-tbl-names)  }
  end.
  if p-tbl-names = "fixing" then do:
    /*надо открыть файл и переложить все записи только переписывая у них номер*/
    input stream imp2-stream from value(p-prepare-phrase).
    repeat:
      import stream imp2-stream unformatted ss.
      if index(ss, {&delim-nws}) > 1 then do:
        assign
        rec-cnt = rec-cnt + 1
        .
        { utl/upg-exp.i "'transfer-replace'" ss  rec-cnt  }
      end.
      else do:
        { utl/upg-exp.i "'transfer'" ss }
      end.
      if rec-cnt modulo 100 = 0 then do:
        display
        rec-cnt
        file-pck-name
        with frame exp-pck.
      end.
    end.
    input stream imp2-stream close.
  end. /*  if p-tbl-names = "fixing" then do:*/
  else do:
  assign
  v-uniq-key-rt = "":U
  .
  create query q_h .
  do v-ii = 1 to min(4, num-entries( p-tbl-names)):
    v-tbl-name[v-ii] = entry(v-ii, p-tbl-names).
    create buffer buf_h[v-ii] for table v-tbl-name[v-ii].
  end.
  if num-entries( p-tbl-names) = 1 then do:
    q_h:SET-BUFFERS( buf_h[1]).
  end.
  if num-entries( p-tbl-names) = 2 then do:
    q_h:SET-BUFFERS( buf_h[1], buf_h[2]).
  end.
  if num-entries( p-tbl-names) = 3 then do:
    q_h:SET-BUFFERS( buf_h[1], buf_h[2], buf_h[3]).
  end.
  if num-entries( p-tbl-names) = 4 then do:
    q_h:SET-BUFFERS( buf_h[1], buf_h[2], buf_h[3], buf_h[4]).
  end.
  v-ok = q_h:QUERY-PREPARE(p-prepare-phrase) no-error.
  if error-status:error
  or not v-ok
  then do:
    return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  end.
  q_h:QUERY-OPEN.

  REPEAT WITH FRAME exp-pck:
    q_h:GET-NEXT().
    IF q_h:QUERY-OFF-END THEN LEAVE.
    run gen-key-rec In this-procedure ( input v-tbl-name[p-buffer-num]
                                       ,input buf_h[p-buffer-num]
                                       ,output v-uniq-key-rec).
    create temp-table tth.
    assign
      tt-name       = "tt_":U + v-tbl-name[p-buffer-num]
      tth:undo = no
    .
    assign
      v-ok = tth:create-like( "ub.":U + v-tbl-name[p-buffer-num] ) no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1. Ошибка при создании временной таблицы &2 (1)", vss-workfile, tt-name ) .
    end.

    assign
      v-ok = tth:temp-table-prepare( tt-name ) no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1. Ошибка при создании временной таблицы &2 (2)", vss-workfile, tt-name ) .
    end.

    assign
      bh_tt = tth:default-buffer-handle
    .

    assign
      v-ok = bh_tt:buffer-create no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1. Ошибка при создании буфера временной таблицы.", vss-workfile, tt-name ).
    end.

    assign
      v-ok = bh_tt:buffer-copy ( buf_h[p-buffer-num]) no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1. buffer-copy не прошел для таблицы &2", vss-workfile, tt-name ).
    end.
    v-to-export = no.
    find first buf_temp-tables where
              buf_temp-tables.tbl-name = v-tbl-name[p-buffer-num] no-error.
    if available buf_temp-tables then do:
      /*проверим есть ли запись во временной таблице и изменилась ли она*/
      define variable v-tbl-name-dop as character no-undo .
      define variable v-tbl-row2 as rowid no-undo .
      /*найдем - есть ли такой в нашей БД*/
      run gen-row-keyr in this-procedure
        ( input  v-uniq-key-rec
        ,input ?
        ,input "":U /*этот параметр для врем таблицы не играет знач*/
        ,input buf_temp-tables.buf-handle
        ,input no-lock
        ,output v-tbl-row2
        ,output v-tbl-name-dop
        ) no-error .
      if error-status :error then do:
        return error  ( substitute( "&1. Ошибка при поиске записи по уникальному ключу &2 во врем таблице.&3&4&3&5"
                                      ,vss-workfile
                                      ,v-uniq-key-rec
                                      ,{&new-line}
                                      ,return-value
                                      ,error-status :get-message ( error-status :num-messages )
                                    )
                        ).
      end.



      buf_temp-tables.buf-handle:find-by-rowid( v-tbl-row2, no-lock ) no-error .
      if not buf_temp-tables.buf-handle:available then do:
        assign
          v-to-export = yes
        .
      end.
      else do:
        assign
          compare-log = buf_temp-tables.buf-handle:buffer-compare( bh_tt )
        .
      end.
      if compare-log = false then do:
        assign
          v-to-export = yes.
        .
      end.
    end. /*if available buf_temp-tables then do:*/
    else do:
      v-to-export = yes.
    end.
    if v-to-export then do:
      assign
      rec-cnt = rec-cnt + 1
      .
      { utl/upg-exp.i
        "'exp-tbl'"
        v-tbl-name[p-buffer-num]
        bh_tt
        v-uniq-key-rec
        rec-cnt
      }
        if rec-cnt modulo 100 = 0 then do:
          display
          rec-cnt
          file-pck-name
          with frame exp-pck.
        end.
    end.
    assign
      v-ok = tth:clear() no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1. Ошибка при очистке временной таблицы &2", vss-workfile, tt-name ) .
    end.

    delete object tth no-error .
    if error-status:error then do:
      return error substitute( "&1. Ошибка при удалении временной таблицы для &2", vss-workfile, tt-name ).
    end.

  end. /* repeat with frame */

  assign
    v-uniq-key-rt = "":U
  .
  do v-ii = 1 to 4:
    if valid-handle(buf_h[v-ii]) then do:
      delete widget buf_h[v-ii] .
    end.
  end.

  delete widget q_h.
  /*здесь кончили выгружать новые записи  */
  /*теперь надо удалить старые*/
  for each buf_temp-tables
  where buf_temp-tables.tbl-name = entry(p-buffer-num,p-tbl-names)
  :
    /*надо создaть query*/
    create query q_h .
    q_h:SET-BUFFERS( buf_temp-tables.buf-handle).
    v-ok = q_h:QUERY-PREPARE(replace(p-prepare-phrase, buf_temp-tables.tbl-name, "wt-" + buf_temp-tables.tbl-name)) no-error.
    if error-status:error
    or not v-ok
    then do:
      return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
    end.
    q_h:QUERY-OPEN.
    REPEAT WITH FRAME exp-pck:
      q_h:GET-NEXT().
      IF q_h:QUERY-OFF-END THEN LEAVE.
      run gen-key-rec In this-procedure ( input buf_temp-tables.tbl-name
                                        ,input buf_temp-tables.buf-handle
                                        ,output v-uniq-key-rec).
      /*найдем - есть ли такой в нашей БД*/
      run gen-row-keyr in this-procedure
        ( input  v-uniq-key-rec
        ,input ?
        ,input "ub":U
        ,input ?
        ,input no-lock
        ,output v-tbl-row
        ,output v-tbl-name[1]
        ) no-error .
      if error-status :error then do:
        return error  ( substitute( "&1. Ошибка при поиске записи по уникальному ключу &2.&3&4&3&5"
                                      ,vss-workfile
                                      ,v-uniq-key-rec
                                      ,{&new-line}
                                      ,return-value
                                      ,error-status :get-message ( error-status :num-messages )
                                    )
                        ).
      end.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, "ub", v-tbl-name[1] )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
      bh_tbl-name:find-by-rowid(v-tbl-row, no-lock ) no-error .
      if bh_tbl-name:available then do:
      end.
      else do:
        assign
          rec-cnt = rec-cnt + 1
          .
        { utl/upg-exp.i
          "'exp-cmd'"
          "'delete'"
          v-uniq-key-rec
          rec-cnt
        }
          if rec-cnt modulo 100 = 0 then do:
            display
            rec-cnt
            file-pck-name
            with frame exp-pck.
          end.
      end.
      delete object bh_tbl-name.
    end.
    delete widget q_h.
  end.
  for each buf_temp-tables:
    delete object buf_temp-tables.tbl-handle.
  end.
  end. /*if p-tbl-names = "delete" then do: else do:*/
  if p-append then do:
    if p-last then do:
      { utl/upg-exp.i "'close'" }
    end.
    else do:
      { utl/upg-exp.i "'close-no-end-pck'" }
    end.
  end.
  else do:
    if p-first and not p-last then do:
      { utl/upg-exp.i "'close-no-end-pck'" }
    end.
    else do:
      { utl/upg-exp.i "'close'" }
    end.
  end.
  num-exp-rec = rec-cnt.
end.  /* do transaction */

hide frame exp-pck.