/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

процедуры используемые при импорте пакета новостей (файл imp-pck.p)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 07/13/06
Author: Dmitry Ukhanov
Creation date: 07/13/06

*/

&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ cmp/str-glbl.i       }

{ gbl/check-av.i "nws" } /* используется в load-rec.p и imp-pck.p */

{ ref/gdsoattr.i } /* используется в load-rec.p */
{ gbl/clntattr.i } /* используется в load-rec.p */

{ str/bc-gnrt.i new bc } /* используется в процедуре create-bar-code */

{ utl/rbc-tbl.i }

PROCEDURE create-bar-code:
  define input parameter loc-b-code        like ub.bar-code.b-code        no-undo .
  define input parameter loc-cli-base-rate like ub.bar-code.cli-base-rate no-undo .
  define input parameter loc-gds-code      like ub.bar-code.gds-code      no-undo .
  define input parameter loc-in-code       like ub.bar-code.in-code       no-undo .
  define input parameter loc-node-code     like ub.bar-code.node-code     no-undo .
  define input parameter loc-part-code     like ub.bar-code.part-code     no-undo .
  define input parameter loc-unit-cli      like ub.bar-code.unit-cli      no-undo .
  define input parameter loc-cr-db-num     like ub.bar-code.cr-db-num     no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
  :

    define buffer buf_bar-code   for ub.bar-code .
    define buffer buf_goods      for ub.goods .
    define buffer buf_prod-bc    for ub.prod-bc .
    define buffer buf_price-list for ub.price-list.
    define buffer buf_db         for ub.db.
    define buffer buf_clients    for ub.clients.

    define variable src-b-code       like ub.bar-code.b-code no-undo .
    define variable attach-to-b-code like ub.bar-code.b-code no-undo .
    define variable bar_code         like ub.prod-bc.b-str   no-undo .
    define variable load-bc          as   logical            no-undo .
    define variable cre-prod-bc      as   logical            no-undo .
    DEFINE VARIABLE var-rate-value   like ub.tax-rate-value.rate-value no-undo .
    define variable prod_bc_cr-db-num like ub.prod-bc.cr-db-num no-undo .

    find buf_bar-code exclusive-lock
      where buf_bar-code.b-code = loc-b-code
      no-error.

    if available buf_bar-code
       and buf_bar-code.b-code        = loc-b-code
       and buf_bar-code.gds-code      = loc-gds-code
       and buf_bar-code.node-code     = loc-node-code
       and buf_bar-code.part-code     = loc-part-code
       and buf_bar-code.in-code       = loc-in-code
       and buf_bar-code.unit-cli      = loc-unit-cli
       and buf_bar-code.cli-base-rate = loc-cli-base-rate
    then do:
      return. /* зачем чего-то делать, если у нас ничего не меняется */
    end.

    if available buf_bar-code
      and ( buf_bar-code.gds-code     <> loc-gds-code
            or buf_bar-code.node-code <> loc-node-code
            or buf_bar-code.part-code <> loc-part-code
            or buf_bar-code.in-code   <> loc-in-code
            or buf_bar-code.unit-cli  <> loc-unit-cli
          )
    then do:
      run write-to-log( "ОШИБКА! Принимается ошибочный бар-код " + string( loc-b-code )
                        + " для товара " + string( loc-gds-code ) + "." ).
      return error.
    end.

    find buf_bar-code exclusive-lock
      where buf_bar-code.gds-code  = loc-gds-code
        and buf_bar-code.node-code = loc-node-code
        and buf_bar-code.part-code = loc-part-code
        and buf_bar-code.in-code   = loc-in-code
        and buf_bar-code.unit-cli  = loc-unit-cli
    no-error.

    find buf_goods no-lock
      where buf_goods.gds-code = buf_bar-code.gds-code
      no-error.

    assign
      load-bc      = TRUE
      cre-prod-bc  = FALSE
      .
    if available buf_bar-code and buf_bar-code.b-code <> loc-b-code then do:
      if g#db-num = 0 then do:
        assign
          src-b-code       = loc-b-code
          attach-to-b-code = buf_bar-code.b-code
          load-bc          = FALSE
          .
      end.
      else do: /* g#db-num <> 0 */
        assign
          src-b-code       = buf_bar-code.b-code
          attach-to-b-code = loc-b-code
          load-bc          = TRUE
          .
        run ren-b-code in this-procedure
          ( input src-b-code
           ,input attach-to-b-code
          ) no-error .
        if error-status :error then do:
          run write-to-log ( substitute("Ошибка при переименовании бар-кода &1.&2&3&2&4", src-b-code, {&new-line}, return-value, error-status :get-message(1) ) ).
          return error.
        end.
        run write-to-log ( "Существовавший бар-код" + {&space-char} + string( src-b-code ) + {&space-char}
                           + "заменен на пришедший" + {&space-char} + string( loc-b-code )
                         ).
      end.
      assign
        cre-prod-bc = TRUE
        prod_bc_cr-db-num = buf_bar-code.cr-db-num
        .
    end.

    if load-bc then do:
      if not available buf_bar-code then do:
        create buf_bar-code.
      end.
      else do:
        /* если bar-code был, то его надо удалить с кассы */
        find first bc-list where bc-list.b-code = buf_bar-code.b-code no-error.
        if not available bc-list then do:
          create bc-list.
          buffer-copy buf_bar-code to bc-list
            assign
              bc-list.del = yes
          .
        end.
        else do:
          for each bc-list
            where bc-list.b-code = buf_bar-code.b-code
          on error undo, return error
          :
            assign
              bc-list.del = yes
            .
          end.
        end.
      end.
      assign
        buf_bar-code.b-code        = loc-b-code
        buf_bar-code.cli-base-rate = loc-cli-base-rate
        buf_bar-code.gds-code      = loc-gds-code
        buf_bar-code.in-code       = loc-in-code
        buf_bar-code.node-code     = loc-node-code
        buf_bar-code.part-code     = loc-part-code
        buf_bar-code.unit-cli      = loc-unit-cli
        buf_bar-code.cr-db-num     = loc-cr-db-num
        .

      if not can-find(gds-list where gds-list.gds-code = buf_bar-code.gds-code no-lock) then do:
          find first bc-list where bc-list.b-code = buf_bar-code.b-code no-error.
          if not available bc-list then do:
            create bc-list.
            buffer-copy buf_bar-code to bc-list
              assign
                bc-list.del = no
              .
          end.
      end.
    end.

    if cre-prod-bc = true then do:
      run gen-bc in this-procedure
        ( input src-b-code
         ,output bar_code
        ).
      if can-find( first buf_prod-bc where buf_prod-bc.b-str = bar_code no-lock ) then do:
        run write-to-log ( "Системная ошибка!!! При перемещении собственного кода в Доп.БК обнаружен повторный Доп.БК код" ).
        return error.
      end.
      run create-prod-bc in this-procedure
        ( input attach-to-b-code
         ,input bar_code
         ,input yes
         ,input prod_bc_cr-db-num
         ,input ''  /*bc-on-type*/
        ).
      run write-to-log ( substitute( "Вместо бар-кода &1 создан Доп.БК &2", src-b-code, bar_code ) ).
    end.
  end.
END PROCEDURE.

PROCEDURE create-prod-bc:
  define input parameter loc-b-code like ub.prod-bc.b-code no-undo.
  define input parameter loc-b-str  like ub.prod-bc.b-str  no-undo.
  define input parameter loc-bc-on  like ub.prod-bc.bc-on  no-undo.
  define input parameter loc-cr-db-num like ub.prod-bc.cr-db-num no-undo .
  define input parameter loc-bc-on-type like ub.prod-bc.bc-on-type no-undo .

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
  :

    define variable v-param-type                as character                no-undo.
    define variable v-value-character           as character                no-undo.
    define variable v-value-date                as date                     no-undo.
    define variable v-value-decimal             as decimal                  no-undo.
    define variable v-value-integer             as INTEGER                  no-undo.
    define variable v-value-logical             AS LOGICAL                  no-undo.
    define variable v-tth                       as handle                   no-undo.
    define variable dpl-off as logical no-undo .

    define buffer buf_bar-code for ub.bar-code .
    define buffer buf_prod-bc  for ub.prod-bc .
    define buffer buf_goods    for ub.goods .
    define buffer cre_prod-bc  for ub.prod-bc.

    find cre_prod-bc where cre_prod-bc.b-code = loc-b-code
                       and cre_prod-bc.b-str  = loc-b-str
                    exclusive-lock no-error.
    if available cre_prod-bc
       and cre_prod-bc.b-code = loc-b-code
       and cre_prod-bc.b-str  = loc-b-str
       and cre_prod-bc.bc-on  = loc-bc-on
    then do:
      return. /* зачем чего-то делать, если у нас ничего не меняется */
    end.

    find buf_bar-code where buf_bar-code.b-code = loc-b-code no-lock no-error.
    if not available buf_bar-code then do:
      /*
      message "".
      */
      return error.
    end.
    find buf_goods where buf_goods.gds-code = buf_bar-code.gds-code no-lock no-error.
    if not available buf_goods then do:
      /*
      message "".
      */
      return error.
    end.
    if loc-bc-on = yes
      and can-find(first buf_prod-bc where buf_prod-bc.b-str   = loc-b-str
                                       and buf_prod-bc.b-code <> loc-b-code
                                       and buf_prod-bc.bc-on   = yes no-lock ) then do:
      run adm/shattri.p (
          input "get":U
          ,input  '':U /*p-obj-type*/
          ,input  0 /*p-obj-code*/
          ,input  {&attr-gds-ref}
          ,input  {&attr-gds-ref_dpl-off} /*p-param-code*/
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output dpl-off
          ,output v-param-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error.
      delete object v-tth.
      if dpl-off = yes then do:
        for each buf_prod-bc exclusive-lock
          where buf_prod-bc.b-str   = loc-b-str
            and buf_prod-bc.b-code <> loc-b-code
            and buf_prod-bc.bc-on   = yes
        on error undo, return error return-value
        :
          assign buf_prod-bc.bc-on = no.
          if not can-find(gds-list where gds-list.artic     = buf_goods.artic
                                     and gds-list.prod-type = buf_goods.prod-type
                                     and gds-list.prod-code = buf_goods.prod-code
                                   no-lock ) then do:
            find first pbc-list where pbc-list.rc = recid(buf_prod-bc) no-error.
            if not available pbc-list then do:
              create pbc-list.
            end.
            buffer-copy buf_prod-bc to pbc-list
              assign
                pbc-list.rc = recid( buf_prod-bc )
              .
            release pbc-list .
          end.
          run write-to-log( "Исходя из настроек, выключен существующий доп. бар-код" + {&space-char} + buf_prod-bc.b-str
                            + {&space-char} + "для кода" + {&space-char} + string( buf_prod-bc.b-code ) ).
        end.
      end.
      assign loc-bc-on = no.
      run write-to-log( "Выключен пришедший доп. бар-код" + {&space-char} + loc-b-str
                        + {&space-char} + "для кода" + {&space-char} + string( loc-b-code ) ).
    end.

    if not available cre_prod-bc then do:
      create cre_prod-bc.
    end.
    assign
      cre_prod-bc.b-code = loc-b-code
      cre_prod-bc.b-str  = loc-b-str
      cre_prod-bc.bc-on  = loc-bc-on
      cre_prod-bc.cr-db-num = loc-cr-db-num
      cre_prod-bc.bc-on-type = loc-bc-on-type
      .

    if not can-find(gds-list where gds-list.artic     = buf_goods.artic
                               and gds-list.prod-type = buf_goods.prod-type
                               and gds-list.prod-code = buf_goods.prod-code
                             no-lock ) then do:
      find first pbc-list where pbc-list.rc = recid(cre_prod-bc) no-error.
      if not available pbc-list then do:
        create pbc-list.
      end.
      buffer-copy cre_prod-bc to pbc-list
        assign
          pbc-list.rc = recid( cre_prod-bc )
        .
      release pbc-list .
    end.
  end.
END PROCEDURE.

procedure ren-b-code :
  define input parameter p-old-b-code as integer no-undo .
  define input parameter p-new-b-code as integer no-undo .
  do
  on error  undo, return error substitute( "ren-b-code. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "ren-b-code. stop" )
  on endkey undo, return error substitute( "ren-b-code. endkey" )
  :

    define variable v-ind         as integer   no-undo .
    define variable v-num-entries as integer   no-undo .
    define variable v-tbl-name    as character no-undo .
    define variable fh            as handle    no-undo .
    define variable bh            as handle    no-undo .
    define variable qh            as handle    no-undo .
    define variable v-query       as character no-undo .

    define buffer buf-ren_bar-code        for ub.bar-code .
    define buffer buf-ren_goods           for ub.goods .
    define buffer buf-ren_prod-bc         for ub.prod-bc .
    define buffer buf-ren_db              for ub.db .
    define buffer buf-ren_clients         for ub.clients .
    define buffer buf-ren_price-list      for ub.price-list .
    define buffer buf-ren_price-list-attr for ub.price-list-attr .

    run valid-ren-bcod-tbl-list in this-procedure
      no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при проверке списка таблиц для обработки." skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    do transaction
    on error  undo, return error substitute( "ren-b-code (1.err). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    on stop   undo, return error substitute( "ren-b-code (1.stop). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    on quit   undo, return error substitute( "ren-b-code (1.quit). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    on endkey undo, return error substitute( "ren-b-code (1.endkey). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :

      /* здесь ведется спец. обработка таблиц */
      find first buf-ren_bar-code exclusive-lock
        where buf-ren_bar-code.b-code  = p-old-b-code
        .
      find first buf-ren_goods no-lock
        where buf-ren_goods.gds-code = buf-ren_bar-code.gds-code
        .
      assign
        buf-ren_bar-code.b-code  = p-new-b-code
      .

      for each buf-ren_prod-bc exclusive-lock
          where buf-ren_prod-bc.b-code = p-old-b-code
      on error undo, return error substitute( "ren-b-code. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        assign
          buf-ren_prod-bc.b-code = p-new-b-code
          .
        if not can-find(gds-list where gds-list.artic     = buf-ren_goods.artic
                                  and gds-list.prod-type = buf-ren_goods.prod-type
                                  and gds-list.prod-code = buf-ren_goods.prod-code
                                  no-lock ) then do:
          find first pbc-list where pbc-list.rc = recid( buf-ren_prod-bc ) no-error.
          if not available pbc-list then do:
            create pbc-list.
          end.
          buffer-copy buf-ren_prod-bc to pbc-list
            assign
              pbc-list.rc = recid( buf-ren_prod-bc )
              pbc-list.del = no
            .
          release pbc-list .
        end.
      end.

      for each buf-ren_db no-lock
      on error undo, return error substitute( "ren-b-code. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        for each buf-ren_clients no-lock
          where buf-ren_clients.db-num = buf-ren_db.db-num
        on error undo, return error substitute( "ren-b-code. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          for each buf-ren_price-list exclusive-lock
            where buf-ren_price-list.obj-type = buf-ren_clients.obj-type
              and buf-ren_price-list.obj-code = buf-ren_clients.obj-code
              and buf-ren_price-list.b-code   = p-old-b-code
          on error undo, return error substitute( "ren-b-code. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            assign
              buf-ren_price-list.b-code = p-new-b-code
              .
            for each buf-ren_price-list-attr exclusive-lock
              where buf-ren_price-list-attr.doc-num    = buf-ren_price-list.doc-num
                and buf-ren_price-list-attr.price-type = buf-ren_price-list.price-type
                and buf-ren_price-list-attr.b-code     = buf-ren_price-list.b-code
              on error undo, return error substitute( "ren-b-code. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
              :
                assign
                  buf-ren_price-list-attr.b-code = p-new-b-code
                  .
              end.
          end.
        end.
      end.

      /* здесь обрабатываются таблицы из списка TABLE-RBC_LIST */
      assign
        v-num-entries = num-entries( {&TABLE-RBC_LIST} )
      .
      do v-ind = 1 to v-num-entries
      on error undo, return error substitute( "ren-b-code. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        assign
          v-tbl-name = substitute( "ub.&1":U, trim( entry( v-ind, {&TABLE-RBC_LIST} ) ) )
          v-query    = substitute( "for each &1 where &1.b-code = &2":U, v-tbl-name, p-old-b-code )
        .
        create buffer bh for table v-tbl-name .
        create query qh .

        qh:set-buffers( bh ).
        qh:query-prepare( v-query ).
        qh:query-open() .

  /*      MESSAGE qh:NUM-RESULTS VIEW-AS ALERT-BOX.
  */
        qh:get-first( exclusive-lock ).

        do while qh:query-off-end <> true
        on error  undo, return error substitute( "ren-b-code (2.err). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        on stop   undo, return error substitute( "ren-b-code (2.stop). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        on quit   undo, return error substitute( "ren-b-code (2.quit). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        on endkey undo, return error substitute( "ren-b-code (2.endkey). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          assign
            fh = bh:buffer-field( "b-code":U )
            fh:buffer-value = p-new-b-code .
          .

          bh:buffer-release() no-error .

          qh:get-next( exclusive-lock ).
        END.

        qh:query-close() .

        delete object qh.
        delete object bh.
      end.

    END.

  end.
  return.
end procedure. /* ren-b-code */