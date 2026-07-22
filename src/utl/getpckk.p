block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: getpckk.p $
$Archive: utl/getpckk.p $

Вывод в файл ключей принятых пакетов

Автор: Уханов Дмитрий Юрьевич
Дата создания: 05/14/08
Author: Dmitry Ukhanov
Creation date: 05/14/08

*/

define input  parameter parparentproc as handle    no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: getpckk.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/getpckk.p $":U .
define variable vss-description as character no-undo init "Вывод в файл ключей принятых пакетов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:

  define variable v-db-num   as integer   no-undo .
  define variable v-pck-cnt  as integer   no-undo .
  define variable v-ri       as recid     no-undo .
  define variable v-txt-name as character no-undo .

  define frame inf
    v-db-num    label "для БД" format ">>>>>>>>9"
    v-pck-cnt   label "Всего пакетов"
    with view-as dialog-box side-labels 1 columns three-d title "Сбор информации о пакетах".

  define stream OutStream.

  define buffer buf_sys-ctrl for ub.sys-ctrl .
  define buffer buf_db       for ub.db .

  find first buf_sys-ctrl no-lock .
  find first buf_db no-lock
    where buf_db.db-num = buf_sys-ctrl.db-num
    .
  assign
    v-txt-name = substitute("getpck&1.txt", buf_sys-ctrl.db-num )
  .

  output stream OutStream to value( v-txt-name ) append.
  put stream OutStream unformatted
    skip(1)
    substitute( "&1 &2 Текущая БД: &3 (&4) Ключ БД: &5", string( today, "99/99/9999" ), string( time, "HH:MM:SS" ), buf_sys-ctrl.db-num, buf_db.db-name, buf_db.db-key )
    skip(1)
    .
  output stream OutStream close.

  assign
    v-pck-cnt = 0
  .
  view frame inf.

  if buf_sys-ctrl.db-num = 0 then do:
    run adm/dbs.w
      ( input parparentproc
       ,input {&lookup}
       ,output v-ri
      ).
    if v-ri <> ? then do:

      find first buf_db no-lock
        where recid( buf_db ) = v-ri
      .
      run unload-send in this-procedure
        ( input buf_db.db-num
        ) .
      run unload-rcvd in this-procedure
        ( input buf_db.db-num
        ) .
    end.
  end.
  else do:
    run unload-send in this-procedure
      ( input 0
      ) .
    run unload-rcvd in this-procedure
      ( input 0
      ) .
  end.

  hide frame inf.

  message
    "Сбор информации завершен."
    view-as alert-box information.

  return .
end.

procedure unload-send :

  define input  parameter p-db-num as integer   no-undo .

  do
  on error  undo, return error substitute( "&1 (unload-send). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (unload-send). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (unload-send). endkey", vss-workfile )
  :
    define buffer buf_pck-sent for ub.pck-sent .

    output stream OutStream to value( v-txt-name ) append.
    put stream OutStream unformatted
      substitute( "Отправленные пакеты для БД &1:", p-db-num ) skip
      .
    output stream OutStream close.

    for each buf_pck-sent no-lock
      where buf_pck-sent.db-num = p-db-num
      by buf_pck-sent.pack-num
    on error undo, return error return-value
    :
      output stream OutStream to value( v-txt-name ) append.
      put stream OutStream unformatted
        substitute( "--> пакет &1, ключ &2, подготовлен &3 &4, отправлен &5 &6, подтвержден &7 &8."
                   ,buf_pck-sent.pack-num
                   ,buf_pck-sent.CRC-pack
                   ,buf_pck-sent.CreDate
                   ,string( buf_pck-sent.CreTime, "HH:MM:SS" )
                   ,buf_pck-sent.SendTxtDate
                   ,string( buf_pck-sent.SendTxtTime, "HH:MM:SS" )
                   ,buf_pck-sent.RcvdDate
                   ,string( buf_pck-sent.RcvdTime, "HH:MM:SS" )
                  )
        skip
        .
      output stream OutStream close.
      assign
        v-pck-cnt = v-pck-cnt + 1
      .
      do with frame inf
      :
        assign
          v-db-num  :screen-value = string( p-db-num, v-db-num :format)
          v-pck-cnt :screen-value = string( v-pck-cnt, v-pck-cnt :format)
        .
      end.
    end.
  end.
end procedure. /* unload-send */

procedure unload-rcvd :

  define input  parameter p-db-num as integer   no-undo .

  do
  on error  undo, return error substitute( "&1 (unload-rcvd). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (unload-rcvd). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (unload-rcvd). endkey", vss-workfile )
  :
    define buffer buf_pck-rcvd for ub.pck-rcvd .

    output stream OutStream to value( v-txt-name ) append.
    put stream OutStream unformatted
      substitute( "Принятые пакеты из БД &1:", p-db-num ) skip
      .
    output stream OutStream close.

    for each buf_pck-rcvd no-lock
      where buf_pck-rcvd.db-num = p-db-num
      by buf_pck-rcvd.pack-num
    on error undo, return error return-value
    :
      output stream OutStream to value( v-txt-name ) append.
      put stream OutStream unformatted
        substitute( "<-- пакет &1, ключ &2, подготовлен &3 &4, отправлен &5 &6, подтвержден &7 &8."
                   ,buf_pck-rcvd.pack-num
                   ,buf_pck-rcvd.CRC-pack
                   ,buf_pck-rcvd.CreDate
                   ,string( buf_pck-rcvd.CreTime, "HH:MM:SS" )
                   ,buf_pck-rcvd.SendTxtDate
                   ,string( buf_pck-rcvd.SendTxtTime, "HH:MM:SS" )
                   ,buf_pck-rcvd.RcvdDate
                   ,string( buf_pck-rcvd.RcvdTime, "HH:MM:SS" )
                  )
        skip
        .
      output stream OutStream close.
      assign
        v-pck-cnt = v-pck-cnt + 1
      .
      do with frame inf
      :
        assign
          v-db-num  :screen-value = string( p-db-num, v-db-num :format)
          v-pck-cnt :screen-value = string( v-pck-cnt, v-pck-cnt :format)
        .
      end.
    end.
  end.
end procedure. /* unload-rcvd */