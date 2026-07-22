block-level on error undo, throw.
/*

$Revision: f29df1d5f130, 3104, rls $
$Author: DRuban $
$Date: Вт авг 09 09:15:01 2022 +0300 $
$Workfile: imp-bush.p $
$Archive: nws/imp-bush.p $

Прием кустовых команд

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/23/04
Author: Dmitry Ukhanov
Creation date: 09/23/04

*/

define input  parameter p-imp-handle as handle    no-undo .
define input  parameter p-full-cmd   as character no-undo .
define input  parameter p-uniq-gate-rec as character no-undo .
define input  parameter p-counter    as integer   no-undo .
define input  parameter p-db-source  as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: f29df1d5f130, 3104, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: Вт авг 09 09:15:01 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: imp-bush.p $":U .
define variable vss-archive     as character no-undo init "$Archive: nws/imp-bush.p $":U .
define variable vss-description as character no-undo init "Прием кустовых команд".
{ cmp/vssrevis.i "substitute('&1|&2|&3':u,p-full-cmd,p-counter,p-db-source)"}
{ cmp/trg-def.i  }
{ adm/auto-def.i  }
{ str/auto2dia.i auto-window-h }
{ gbl/waitfram.i }
{ rul/tempcxml.i "new shared" }
{ gbl/gate-clb.i }
{ cmp/strcodec.i }

define variable v-obj-type   as character no-undo .
define variable v-obj-code   as integer   no-undo .
define variable v-command    as character no-undo .
define variable v-source-db-num as integer no-undo .
define variable v-mode       as character no-undo .
define variable v-md5-signature as character no-undo .
define variable v-file-num   as integer no-undo .
define variable v-file-name  as character no-undo .
define variable v-path-type as integer no-undo .
/*0 - relative ; 1 absolute ; 2 form ini*/
define variable v-path as character no-undo .
define variable v-table-name as character no-undo .
define variable v-db-num as integer   no-undo .
define variable v-int64-id as int64 no-undo .
define variable v_dataseth as handle no-undo .
define variable v-xmlh as handle no-undo .
define buffer buf_temp-xml-tables for temp-xml-tables.
v-xmlh = buffer buf_temp-xml-tables:handle.


do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:

  assign
    v-command = entry( 1, p-full-cmd, {&delim-cmd} )
  .
  if p-uniq-gate-rec <> '':U then do:
&scop gate-clear if valid-handle(v_dataseth) then do: ~
                   run gate-clear in this-procedure ( input v_dataseth ~
                                                    , input (buffer buf_temp-xml-tables:handle)). ~
                  end
    define variable v-longchar as longchar no-undo .
    v-longchar = ?.
    run get-gate-by-rec in this-procedure ( input p-uniq-gate-rec
                                            ,output v_dataseth
                                            ,input-output v-xmlh
                                            ,input-output v-longchar
                                            ) no-error.
    if error-status:error then do:
        return error substitute( "&1 (imp-bush). Ошибка при создании временных таблиц (1)", vss-workfile ) .
    end.

  end.
  case v-command
  :
    when {&cmd-request-goods}
    then do:
      /* пришел запрос на отправку товаров */
      /* отправить информацию обо всех товарах по указанному объекту */

      assign
        v-obj-type = entry( 2, p-full-cmd, {&delim-cmd} )
        v-obj-code = integer(entry( 3, p-full-cmd, {&delim-cmd} ))
      .

      run nws/cmdsndgd.p
        ( input p-imp-handle /* p-imp-handle */
         ,input p-counter    /* p-counter  */
         ,input v-obj-type   /* p-obj-type */
         ,input v-obj-code   /* p-obj-code */
        ) no-error .
      if error-status :error
      then do:
        {&gate-clear}.
        return error substitute( "&1. ошибка при вызове процедуры cmdsndgd.p! &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message( error-status :num-messages )  ).
      end.
    end.
    when {&cmd-transfer-goods}
    then do:
      /* пришла информация обо всех товарах по указанному объекту */
      /* сравнить пришедшую информацию с текущей свободной зоной */
      assign
        v-obj-type = entry( 2, p-full-cmd, {&delim-cmd} )
        v-obj-code = integer(entry( 3, p-full-cmd, {&delim-cmd} ))
      .

      run nws/cmdcmpgd.p
        ( input p-imp-handle
         ,input p-counter
         ,input v-obj-type
         ,input v-obj-code
        ) no-error .
      if error-status :error
      then do:
        {&gate-clear}.
        return error substitute( "&1. ошибка при вызове процедуры cmdcmpgd.p! &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message( error-status :num-messages )  ).
      end.
    end.
    when {&cmd-parts-split}
    then do:
      run nws/cmdpart.p
        ( input p-imp-handle
         ,input p-counter
        ) no-error .
      if error-status :error
      then do:
        {&gate-clear}.
        return error substitute( "&1. ошибка при вызове процедуры cmdpart.p! &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message( error-status :num-messages )  ).
      end.
    end.
    when {&cmd-imp-rec-without-trg}
    then do:
      run cmd-imp-rec-without-trg in this-procedure
        ( input p-imp-handle
         ,input p-counter
        ) no-error .
      if error-status :error
      then do:
        {&gate-clear}.
        return error substitute( "&1. ошибка при вызове процедуры cmd-imp-rec-without-trg! &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message( error-status :num-messages )  ).
      end.
    end.
    when {&cmd-trn-doc-fact}
    then do:
      define variable v-type-trn as character no-undo .
      define variable v-doc-code-trn as character no-undo .

      assign
        v-type-trn     = entry( 2, p-full-cmd, {&delim-cmd} )
        v-doc-code-trn = entry( 3, p-full-cmd, {&delim-cmd} )
      .

      run nws/cmd-trni.p
        ( input p-imp-handle
         ,input p-counter
         ,input v-type-trn
         ,input v-doc-code-trn
        ) no-error .
      if error-status :error
      then do:
        {&gate-clear}.
        return error substitute( "&1. ошибка при вызове процедуры cmd-trni.p! &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message( error-status :num-messages )  ).
      end.

    end.
    when {&cmd-rcv-doc-rcv}
    then do:
      define variable v-type-rcv as character no-undo .
      define variable v-doc-code-rcv as character no-undo .
      define variable v-rcv-code-rcv as character no-undo .

      assign
        v-type-rcv     = entry( 1, p-full-cmd, {&delim-cmd} )
        v-doc-code-rcv = entry( 2, p-full-cmd, {&delim-cmd} )
        v-rcv-code-rcv = entry( 3, p-full-cmd, {&delim-cmd} )
      .
      run nws/cmd-rcvi.p
        ( input p-imp-handle
         ,input p-counter
         ,input v-type-rcv
         ,input v-doc-code-rcv
         ,input v-rcv-code-rcv
        ) no-error .
      if error-status :error
      then do:
        {&gate-clear}.
        return error substitute( "&1. ошибка при вызове процедуры cmd-rcvi.p! &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message( error-status :num-messages )  ).
      end.

    end.
    when {&cmd-s-f-doc-fact}
    then do:
      define variable v-type-s-f as character no-undo .
      define variable v-doc-code-s-f as character no-undo .
      define variable v-db-num-s-f   as character no-undo .

      assign
        v-type-s-f     = entry( 1, p-full-cmd, {&delim-cmd} )
        v-doc-code-s-f = entry( 2, p-full-cmd, {&delim-cmd} )
        v-db-num-s-f   = entry( 3, p-full-cmd, {&delim-cmd} )
      .
      run nws/cmd-s-fi.p
        ( input p-imp-handle
         ,input p-counter
         ,input v-type-s-f
         ,input v-doc-code-s-f
         ,input v-db-num-s-f
        ) no-error .
      if error-status :error
      then do:
        {&gate-clear}.
        return error substitute( "&1. ошибка при вызове процедуры cmd-s-fi.p! &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message( error-status :num-messages )  ).
      end.
    end.
    when {&cmd-pdf-fact}
    then do:
      define variable v-type-pdf as character no-undo .
      define variable v-1 as integer   no-undo .
      define variable v-2 as integer   no-undo .
      define variable v-3 as integer   no-undo .
      define variable v-4 as integer   no-undo .

      assign
        v-type-pdf     = entry( 2, p-full-cmd, {&delim-cmd} )
        v-1            = int(entry( 3, p-full-cmd, {&delim-cmd} ))
        v-2            = int(entry( 4, p-full-cmd, {&delim-cmd} ))
        v-3            = int(entry( 5, p-full-cmd, {&delim-cmd} ))
        v-4            = int(entry( 6, p-full-cmd, {&delim-cmd} ))
      .

      run nws/cmd-pdfi.p
        ( input p-imp-handle
         ,input p-counter
         ,input v-type-pdf
         ,input v-1
         ,input v-2
         ,input v-3
         ,input v-4
        ) no-error .
      if error-status :error
      then do:
        {&gate-clear}.
        return error substitute( "&1. ошибка при вызове процедуры cmd-trni.p! &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message( error-status :num-messages )  ).
      end.

    end.
    when {&cmd-parts-fact-corr}
    then do:

      assign
        v-type-pdf     = entry( 2, p-full-cmd, {&delim-cmd} )
       /* v-1            = int(entry( 3, p-full-cmd, {&delim-cmd} )) */
      .

      run nws/cmd-cori.p
        ( input p-imp-handle
         ,input p-counter
         ,input v-type-pdf
         ,input 0
        ) no-error .
      if error-status :error
      then do:
        {&gate-clear}.
        return error substitute( "&1. ошибка при вызове процедуры cmd-trni.p! &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message( error-status :num-messages )  ).
      end.

    end.

    when {&cmd-del-rec-without-trg}
    then do:
      run cmd-del-rec-without-trg in this-procedure
        ( input p-imp-handle
         ,input p-counter
        ) no-error .
      if error-status :error
      then do:
        return error substitute( "&1. ошибка при вызове процедуры cmd-del-rec-without-trg! &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message( error-status :num-messages )  ).
      end.
    end.
    when {&cmd-send-binary} then do:
      assign
        v-mode = entry( 2, p-full-cmd, {&delim-cmd} )
        v-file-num = integer(entry( 3, p-full-cmd, {&delim-cmd} ))
        v-file-name = entry( 4, p-full-cmd, {&delim-cmd} )
        v-path-type = integer(entry( 5, p-full-cmd, {&delim-cmd} ))
        v-path = entry( 6, p-full-cmd, {&delim-cmd} )
        v-md5-signature = entry( 7, p-full-cmd, {&delim-cmd} )
      .
      define variable v-ok as logical no-undo .
      run nws/bin-i.p
        ( input auto-window-h
         ,input this-procedure:handle
         ,input auto-window-h
         ,input p-imp-handle
         ,input p-counter
         ,input v-mode
         ,input v-file-num
         ,input v-file-name
         ,input v-path-type
         ,input v-path
         ,input v-md5-signature
         ,output v-ok
        ) no-error.
      if error-status:error then do:
         {&gate-clear}.
         return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
      end.
    end.
    when {&cmd-send-lob} then do:
      assign
        v-table-name = entry( 2, p-full-cmd, {&delim-cmd} )
        v-db-num =   integer(entry( 3, p-full-cmd, {&delim-cmd} ))
        v-int64-id = int64(entry( 4, p-full-cmd, {&delim-cmd} ))
      .
      run nws/lob-i.p
        ( input auto-window-h
         ,input this-procedure:handle
         ,input auto-window-h
         ,input p-imp-handle
         ,input p-counter
         ,input v-table-name
         ,input v-db-num
         ,input v-int64-id
         ,output v-ok
        ) no-error.
      if error-status:error then do:
        {&gate-clear}.
         return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
      end.
    end.
    when {&cmd-process-saledc}
    then do:
      define variable v-step      as integer no-undo .
      define variable v-doc-code as character no-undo .
      define variable v-doc-type as character no-undo .
      define variable v-ext-doc-type as character no-undo .
      define variable v-doc-date as date no-undo .
      define variable v-fact-date as date no-undo .
      define variable v-sign as integer no-undo .
      define variable cre-pay as integer no-undo .

      assign
      v-step          = integer(entry( 2, p-full-cmd, {&delim-cmd} ))
      v-source-db-num = integer(entry( 3, p-full-cmd, {&delim-cmd} ))
      v-obj-type = entry( 4, p-full-cmd, {&delim-cmd} )
      v-obj-code = integer(entry( 5, p-full-cmd, {&delim-cmd} ))
      v-doc-code = entry( 6, p-full-cmd, {&delim-cmd} )
      v-doc-type = entry( 7, p-full-cmd, {&delim-cmd} )
      v-ext-doc-type = entry( 8, p-full-cmd, {&delim-cmd} )
      v-doc-date = date(entry( 9, p-full-cmd, {&delim-cmd} ))
      v-fact-date = date(entry( 10, p-full-cmd, {&delim-cmd} ))
      v-sign =  integer(entry( 11, p-full-cmd, {&delim-cmd} ))
      cre-pay =  integer(entry( 12, p-full-cmd, {&delim-cmd} ))
      .
      run nws/cmdp-dc.p
        ( input auto-window-h
         ,input this-procedure:handle
         ,input this-procedure:handle
         ,input p-imp-handle
         ,input p-counter
         ,input v-step
         ,input v-source-db-num
         ,input v-obj-type
         ,input v-obj-code
         ,input v-doc-code
         ,input v-doc-type
         ,input v-ext-doc-type
         ,input v-doc-date
         ,input v-fact-date
         ,input v-sign
         ,input cre-pay
         ,input v-command
        ) no-error .
      if error-status :error
      then do:
        {&gate-clear}.
        return error substitute( "&1. ошибка при вызове процедуры cmdp-dc.p! &2&3&2&4&2&5"
                                , vss-workfile
                                , {&new-line}
                                , return-value
                                , error-status:get-message(1)
                                , error-status :get-message( error-status :num-messages )  ).
      end.
    end.
    when {&cmd-dct-send}
    then do:
      define variable v-type     as character no-undo .
      define variable v-emitent-host-code as integer no-undo .

      assign
      v-emitent-host-code = integer(entry( 2, p-full-cmd, {&delim-cmd} ))
      v-type              = entry( 3, p-full-cmd, {&delim-cmd} )
      .
      run nws/cmd-dct.p
        ( input auto-window-h
         ,input this-procedure:handle
         ,input this-procedure:handle
         ,input p-imp-handle
         ,input p-counter
         ,input v-emitent-host-code
         ,input v-type
        ) no-error .
      if error-status :error
      then do:
        {&gate-clear}.
        return error substitute( "&1. ошибка при вызове процедуры cmd-dct.p! &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message( error-status :num-messages )  ).
      end.
    end.
    when {&cmd-rum-send}
    then do:
      define variable v-uniq-key-rec as character no-undo .
      v-uniq-key-rec = str-decode(entry(2, p-full-cmd, {&delim-cmd})
                                 ,"").
      run nws/cmd-rum.p
        ( input auto-window-h
         ,input this-procedure:handle
         ,input this-procedure:handle
         ,input p-imp-handle
         ,input v-uniq-key-rec
         ,input p-counter
        ) no-error .
      if error-status :error
      then do:
        {&gate-clear}.
        return error substitute( "&1. ошибка при вызове процедуры cmd-rum.p! &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message( error-status :num-messages )  ).
      end.
    end.
    when {&cmd-nws2esys-general}
    then do:
      define variable v-esys-id as integer no-undo .
      define variable v-db-num-exp as integer no-undo .
      define variable v-esys-uniq-gate-rec as character no-undo .    /*gate маршрутизации в esys*/
      assign
      v-esys-id = integer(entry(2, p-full-cmd, {&delim-cmd}))
      v-db-num-exp = integer(entry(3, p-full-cmd, {&delim-cmd}))
      v-esys-uniq-gate-rec = str-decode(entry(4, p-full-cmd, {&delim-cmd}) , '')
      .
      run nws/cmdnw2es.p
        ( input auto-window-h
         ,input this-procedure:handle
         ,input this-procedure:handle
         ,input p-imp-handle
         ,input v-esys-id
         ,input v-db-num-exp
         ,input p-uniq-gate-rec /*gate СПН*/
         ,input v-esys-uniq-gate-rec /*gate esys*/
         ,input p-counter
        ) no-error .
      if error-status :error
      then do:
        {&gate-clear}.
        return error substitute( "&1. ошибка при вызове процедуры cmdnw2es.p! &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message( error-status :num-messages )  ).
      end.
    end.
    when {&cmd-chg-utd-sts}
    then do:
      define buffer buf_utd for ub.utd.
      define variable v-db-num-utd   as integer   no-undo .
      define variable v-doc-id       as integer   no-undo .
      define variable v-sts          as integer   no-undo .
      define variable v-sts-edi      as integer   no-undo .
      define variable v-trn-doc-code as character no-undo .
      
      { gbl/objsrv.i }
      assign
        v-db-num-utd = integer (entry( 2, p-full-cmd, {&delim-cmd} ))
        v-doc-id     = integer (entry( 3, p-full-cmd, {&delim-cmd} ))
        v-sts        = integer (entry( 4, p-full-cmd, {&delim-cmd} ))
        v-sts-edi    = integer (entry( 5, p-full-cmd, {&delim-cmd} ))
        v-doc-code   = (entry( 6, p-full-cmd, {&delim-cmd} ))
      no-error.
      
      if error-status:error
        then 
      do:
        {&gate-clear}.
        return error substitute( "&1. ошибка при обработке комманды на изменения статуса УТД! &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message( error-status :num-messages )  ).
      end.
  
      find first buf_utd exclusive-lock where buf_utd.db-num = v-db-num-utd
        and buf_utd.doc-id = v-doc-id no-error.
      
      if not available (buf_utd)
        then 
      do:
        {&gate-clear}.
        return error substitute( "&1. ошибка при обработке комманды на изменения статуса УТД! &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message( error-status :num-messages )  ).
      end.
      
      assign
        buf_utd.sts = v-sts
        buf_utd.sts-edi = v-sts-edi
        buf_utd.doc-code = v-trn-doc-code
      .
      
    end.

    otherwise do:
      {&gate-clear}.
      return error substitute( "&1. Нет обработки команды &2", vss-workfile, v-command ).
    end.
  end case.
  {&gate-clear}.
end.

procedure cmd-imp-rec-without-trg :

  define input parameter p-imp-handle as handle    no-undo .
  define input parameter p-counter    as integer   no-undo .

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define variable counter    as integer   no-undo .
    define variable rec-full   as character no-undo .
    define variable v-rec-name as character no-undo .
    define variable v-key-rec  as character no-undo .

    do counter = 1 to p-counter
    on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    on stop   undo, return error substitute( "&1. stop", vss-workfile )
    on endkey undo, return error substitute( "&1. endkey", vss-workfile )
    :
      if counter modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Загрузка записей с отключением триггеров. Получено записей &1", counter)
          ) .
      end.

      run nws-imps in p-imp-handle
        ( input-output counter
         ,output       rec-full
        ) no-error.
      if error-status :error then do:
        return error return-value .
      end.

      assign
        v-rec-name = entry( 1, rec-full, {&delim-nws} )
        v-key-rec  = entry( 3, rec-full, {&delim-nws} )
      .

      run nws/cmd-itrg.p
        ( input p-imp-handle
         ,input this-procedure :handle
         ,input v-key-rec
         ,input v-rec-name
        )
        no-error .
      if error-status :error
      then do:
        return error substitute( "&1. ошибка при вызове процедуры cmdintrg.p! &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message( error-status :num-messages )  ).
      end.
    end.

    run waitfram-hide .

  end.

end procedure. /* cmd-imp-rec-without-trg */


procedure cmd-del-rec-without-trg :

  define input parameter p-imp-handle as handle    no-undo .
  define input parameter p-counter    as integer   no-undo .

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define variable counter    as integer   no-undo .
    define variable rec-full   as character no-undo .
    define variable v-rec-name as character no-undo .
    define variable v-key-rec  as character no-undo .

    do counter = 1 to p-counter
    on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    on stop   undo, return error substitute( "&1. stop", vss-workfile )
    on endkey undo, return error substitute( "&1. endkey", vss-workfile )
    :
      if counter modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Удаление записей с отключением триггеров. Удаляется записей &1", counter)
          ) .
      end.

      run nws-imps in p-imp-handle
        ( input-output counter
         ,output       rec-full
        ) no-error.
      if error-status :error then do:
        return error return-value .
      end.

      assign
        v-rec-name = entry( 1, rec-full, {&delim-nws} )
        v-key-rec  = entry( 3, rec-full, {&delim-nws} )
      .

      run nws/cmd-dtrg.p
        ( input p-imp-handle
         ,input this-procedure :handle
         ,input v-key-rec
         ,input v-rec-name
        )
        no-error .
      if error-status :error
      then do:
        return error substitute( "&1. ошибка при вызове процедуры cmd-dtrg.p! &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message( error-status :num-messages )  ).
      end.
    end.

    run waitfram-hide .

  end.

end procedure. /* cmd-del-rec-without-trg */