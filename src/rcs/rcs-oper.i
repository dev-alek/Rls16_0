/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Экспорт документов по архивам.

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 03/31/06
Author: Victor Guntner
Creation date: 03/31/06

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

for each  buf_ot-tot-sale no-lock
    where buf_ot-tot-sale.obj-type     = p-obj-type
      and buf_ot-tot-sale.obj-code     = p-obj-code
      and buf_ot-tot-sale.ext-doc-type = p-ext-doc-type
      and buf_ot-tot-sale.fact-order   > p-fact-order-from
      and buf_ot-tot-sale.fact-order  <= p-fact-order-to
    &if "{1}" = "Overturn" &then
      and buf_ot-tot-sale.sum-type     = {&arh-crsa}
    &else
      and (     buf_ot-tot-sale.sum-type = {&arh-sale}
            or  buf_ot-tot-sale.sum-type = {&arh-sale-service}
          )
    &endif
:
  if not l-exist-operation
  then do:
      run wp-XMLWriteEDT( hEDT, 4, "Операция " + string(p-oper-name) ).
      run wp-XMLWriteLog(sLogFile, 0, "&Line").
      run wp-XMLWriteLog(sLogFile, 1, "XML - Вывод операции " + string(p-oper-name) + " (" + p-ext-doc-type + ")").
      assign
            l-exist-operation = yes
      .
  end.

  &if "{1}" <> "Overturn" &then
        find first trn-doc no-lock
             where trn-doc.doc-code = buf_ot-tot-sale.doc-code
        no-error.
        if not available trn-doc
        then do:
            message
                "В архивах найден несуществующий документ N "
                + string(buf_ot-tot-sale.doc-code)
                view-as alert-box.
            run wp-XMLWriteLog(  sLogFile,
                                        1,
                                "*** ERR: *** Не удалось найти документ N "
                                + string(buf_ot-tot-sale.doc-code)
            ).
            undo, leave.
        end.
        else do:
            assign
                v-doc-date  = trn-doc.doc-date
                v-fact-date = trn-doc.fact-date
                v-doc-PS    = trn-doc.ps
            .
        end.
        find first buf_rcs-retail1bill no-lock
             where buf_rcs-retail1bill.doc-code = buf_ot-tot-sale.doc-code
        no-error.
        if available buf_rcs-retail1bill
        then do:
            assign
                v-rcs-doc-id = buf_rcs-retail1bill.id
            .
        end.
        else do:
            assign
                v-rcs-doc-id = ""
            .
        end.
  &else
        find first price-doc no-lock
             where price-doc.doc-num = buf_ot-tot-sale.doc-code
        no-error.
        if not available price-doc
        then do:
            message
                "В архивах найден несуществующий документ переоценки N "
                + string(buf_ot-tot-sale.doc-code)
                view-as alert-box.
            run wp-XMLWriteLog(  sLogFile,
                                        1,
                                "*** ERR: *** Не удалось найти документ переоценки N "
                                + string(buf_ot-tot-sale.doc-code)
                            ).
            undo, leave.
        end.
        else do:
            assign
                v-doc-date  = price-doc.doc-date
                v-fact-date  = price-doc.fact-date
                v-doc-PS    = price-doc.ps
            .
        end.
        find first buf_rcs-retail1price no-lock
             where buf_rcs-retail1price.doc-num = buf_ot-tot-sale.doc-code
        no-error.
        if available buf_rcs-retail1price
        then do:
            assign
                v-rcs-doc-id = buf_rcs-retail1price.price_id
            .
        end.
        else do:
            assign
                v-rcs-doc-id = ""
            .
        end.
  &endif
  /*----------------------------------------------*/
      run wp-XMLWriteCnt(
            hcnt,
            "   " + string(buf_ot-tot-sale.doc-code) + " от " + string(v-fact-date))
      .
      process events.

        find first buf_rcs-shops no-lock
             where buf_rcs-shops.obj-type = buf_ot-tot-sale.obj-type
               and buf_rcs-shops.obj-code = buf_ot-tot-sale.obj-code
        no-error.
        if not available buf_rcs-shops
        then do:
            undo, return error "rcs-oper: Не найден ID объекта."
                    + {&new-line} + "Тип объекта: " + buf_ot-tot-sale.obj-type
                    + {&new-line} + "Код объекта: " + string( buf_ot-tot-sale.obj-code )
            .
        end.
        run wp-xmltagopen( 1, 1, "ROW","").
        run wp-xmltagput( 1, 2, "ID",             buf_ot-tot-sale.doc-code, 0).
        run wp-xmltagput( 1, 2, "RCS_ID",         v-rcs-doc-id,             0).
        run wp-xmltagput( 1, 2, "DDAT",           string( year( v-doc-date ) ) + string( month( v-doc-date ), "99" ) + string( day( v-doc-date ), "99" ) + string( "000000" ), 0).
        run wp-xmltagput( 1, 2, "FDAT",           string( year( v-fact-date ) ) + string( month( v-fact-date ), "99" ) + string( day( v-fact-date ), "99" ) + string( "000000" ), 0).
        run wp-xmltagput( 1, 2, "DNOM",           buf_ot-tot-sale.doc-code, 0).
        run wp-xmltagput( 1, 2, "DTYPE",          string( p-rcs-doc-type ), 0).
        run wp-xmltagput( 1, 2, "STAD",           "1", 0).
        run wp-xmltagput( 1, 2, "DMODE",          ( if p-ext-doc-type = {&TDEDT_Pri_Vnesh} or p-ext-doc-type = {&TDEDT_Overturn} then "-1" else "0" ), 0).
        run wp-xmltagput( 1, 2, "SITE",           string( buf_rcs-shops.id ), 0).

  &if "{1}" <> "Overturn" &then
        find first buf_rcs-retail1subject no-lock
             where buf_rcs-retail1subject.obj-type = trn-doc.cli-type
               and buf_rcs-retail1subject.obj-code = trn-doc.cli-code
        no-error.
        if not available buf_rcs-retail1subject
        then do:
            run wp-XMLWriteEDT( hEDT, 4, "Не удалось найти SUBJECT для документа " + string( trn-doc.doc-code ) ).
        end.
        else do:
            run wp-xmltagput( 1, 2, "CORR", string( buf_rcs-retail1subject.id ), 0).
        end.
        run wp-xmltagput( 1, 2, "cliType", string( trn-doc.cli-type  ), 0).
        run wp-xmltagput( 1, 2, "cliCode", string( trn-doc.cli-code  ), 0).
  &endif
        run wp-xmltagput( 1, 2, "MESS",  v-doc-PS, 0).

/* Учетные цены */
      &if "{1}" <> "Overturn" &then
          find first buf_ot-tot-cost no-lock
               where buf_ot-tot-cost.doc-code = buf_ot-tot-sale.doc-code
                 and (  buf_ot-tot-cost.sum-type     = {&arh-cost}
                     or buf_ot-tot-cost.sum-type     = {&arh-cost-service}
                     )
                 and buf_ot-tot-cost.cat-id = {&root-cat-id}
          no-error.
          if not available buf_ot-tot-cost
          then do:
                /* TODO Обработка ошибки: не найден buf_ot-tot-cost */
          end.      /* NOT available buf_ot-tot-cost  */
          find first buf_ot-tot-crsa no-lock
               where buf_ot-tot-crsa.doc-code = buf_ot-tot-sale.doc-code
                 and (  buf_ot-tot-crsa.sum-type     = {&arh-crsa}
                     or buf_ot-tot-crsa.sum-type     = {&arh-crsa-service}
                     )
/*                 and buf_ot-tot-crsa.cat-id = {&single-cat-id}*/
          no-error.
          if not available buf_ot-tot-crsa
          then do:
                /* TODO Обработка ошибки: не найден buf_ot-tot-crsa */
          end.      /* NOT available buf_ot-tot-crsa */

      &endif.
/* Обработка строк документа */
      for each buf_ot-line-sale no-lock
          where buf_ot-line-sale.doc-code = buf_ot-tot-sale.doc-code
            and buf_ot-line-sale.sum-type = buf_ot-tot-sale.sum-type
      :

          run wp-xmltagopen( 2, 1, "ROW","").
          run wp-xmltagput( 2, 2, "DOC_HEAD_ID",  buf_ot-tot-sale.doc-code, 0).
          find first goods no-lock
               where goods.artic      = buf_ot-line-sale.artic
                 and goods.prod-type  = buf_ot-line-sale.prod-type
                 and goods.prod-code  = buf_ot-line-sale.prod-code
          no-error.
          if available goods
          then do:
                find first buf_rcs-retail1product no-lock
                     where buf_rcs-retail1product.gds-code = goods.gds-code
                no-error.
                if not available buf_rcs-retail1product
                then do:
                    run wp-XMLWriteEDT( hEDT, 4, "Не удалось найти PRODUCT для товара с кодом " + string( goods.gds-code ) ).
                    run wp-xmltagput( 2, 2, "gdsCode",    string( goods.gds-code ),   0).
                end.
                else do:
                    run wp-xmltagput( 2, 2, "TOV",        string( buf_rcs-retail1product.id ),         0).
                    run wp-xmltagput( 2, 2, "gdsCode",    string( buf_rcs-retail1product.gds-code ),   0).
                end.
          end.      /* available goods  */
          else do:
                run wp-xmltagput( 2, 2, "TOV",       "",         0).
          end.      /* NOT available goods  */
  &if "{1}" <> "Overturn" &then
          find first buf_doc-line no-lock
               where buf_doc-line.doc-code   = buf_ot-line-sale.doc-code
                 and buf_doc-line.artic      = buf_ot-line-sale.artic
                 and buf_doc-line.prod-type  = buf_ot-line-sale.prod-type
                 and buf_doc-line.prod-code  = buf_ot-line-sale.prod-code
          no-error.
          if not available buf_doc-line
          then do:
            /* TODO */
          end.      /* NOT ( available buf_doc-line  ) */
  &endif

 assign
       v-qnty = buf_ot-line-sale.fact-qnty
 .

/*--S------- Для всех кроме переоценки выводим количество ----------*/
          &if "{1}" <> "Overturn" &then
            if p-ext-doc-type <> {&TDEDT_Inv}      and
               p-ext-doc-type <> {&TDEDT_Peresort}
            then do:
                run wp-xmltagput( 2, 2, "KOL02",   string(v-qnty), 0).
            end.
          &endif.
/*--E------- Для всех кроме переоценки выводим количество ----------*/
/* Цены документа */
          &if "{1}" = "Overturn" &then
                run wp-xmltagput( 2, 2, "CEN01", string( buf_ot-line-sale.sum-rubl ), 2).
          &endif
/*          &if "{1}" <> "Overturn" &then*/
/*                run wp-xmltagput( 2, 2, "CEN01",       string(abs(buf_ot-line-sale.sum-rubl)), 2).*/
/*          &endif*/
/* Учетные цены */
          &if "{1}" <> "Overturn" &then
              find first buf_ot-line-cost no-lock
                  where buf_ot-line-cost.doc-code = buf_ot-tot-sale.doc-code
                    and  buf_ot-line-cost.artic      = buf_ot-line-sale.artic
                    and  buf_ot-line-cost.prod-type  = buf_ot-line-sale.prod-type
                    and  buf_ot-line-cost.prod-code  = buf_ot-line-sale.prod-code
                    and (buf_ot-line-cost.sum-type   = {&arh-cost}
                      or buf_ot-line-cost.sum-type   = {&arh-cost-service}
                        )
              .
              if available buf_ot-line-cost
              then do:
                    if buf_ot-line-cost.fact-qnty <> 0
                    then do:
                        run wp-xmltagput( 2, 2, "CEN01", string(abs(buf_ot-line-cost.sum-rubl / buf_ot-line-cost.fact-qnty ) ), 2).
                    end.
              end.      /* available buf_ot-line-cost */
              else do:
                /* TODO */
              end.      /* NOT ( available buf_ot-line-cost ) */
              find first buf_ot-line-crsa no-lock
                  where buf_ot-line-crsa.doc-code = buf_ot-tot-sale.doc-code
                    and  buf_ot-line-crsa.artic      = buf_ot-line-sale.artic
                    and  buf_ot-line-crsa.prod-type  = buf_ot-line-sale.prod-type
                    and  buf_ot-line-crsa.prod-code  = buf_ot-line-sale.prod-code
                    and (buf_ot-line-crsa.sum-type   = {&arh-crsa}
                      or buf_ot-line-crsa.sum-type   = {&arh-crsa-service}
                        )
/*                    and buf_ot-line-crsa.cat-id = {&root-cat-id}*/
              .
              if available buf_ot-line-crsa
              then do:
                    if buf_ot-line-crsa.fact-qnty <> 0
                    then do:
                        run wp-xmltagput( 2, 2, "CEN02", string(abs(buf_ot-line-crsa.sum-rubl / buf_ot-line-crsa.fact-qnty )), 2).
                    end.
              end.      /* available buf_ot-line-crsa */
              else do:
                /* TODO */
              end.      /* NOT ( available buf_ot-line-crsa ) */

          &endif.
          run wp-xmltagclose( 2, 1, "ROW").
      end.
      run wp-xmltagclose( 1, 1, "ROW").
end.

/* $Workfile$ e n d */