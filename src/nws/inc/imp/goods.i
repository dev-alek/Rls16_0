/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Прием товара

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/23/99
Author: Dmitry Ukhanov
Creation date: 03/23/99

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop BuffCopy if g#db-num = 0 and lookup( string( tb-goods.stts ), {&gds-stats-block} ) <> 0 then do: ~
  buffer-copy wt-goods ~
    except wt-goods.stts ~
    to tb-goods. ~
end. ~
else do: ~
  buffer-copy wt-goods to tb-goods. ~
end.

DO counter = 1 TO l-counter
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :

  { nws/imps-nws.i rec-full }

  assign
    rec-name = entry( 1, rec-full, {&delim-nws} )
    .

  {&test-count}

  CASE rec-name :
    when "bar-code" then do:
      create locb-bar-code.
      run nws-impl-without-check in p-imp-handle
        ( input (buffer locb-bar-code:handle)
        ) no-error.
      if error-status :error then do:
        return error return-value .
      end.
    end.
    when "prod-bc" then do:
      create locb-prod-bc.
      run nws-impl-without-check in p-imp-handle
        ( input (buffer locb-prod-bc:handle)
        ) no-error.
      if error-status :error then do:
        return error return-value .
      end.
    end.
    when "tax-rate-gds" then do:
      create locb-tax-rate-gds.
      run nws-impl-without-check in p-imp-handle
        ( input (buffer locb-tax-rate-gds:handle)
        ) no-error.
      if error-status :error then do:
        return error return-value .
      end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе товара."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

assign
  imp-goods = FALSE
  load-tax  = TRUE
  .

do while imp-goods = FALSE
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  find tb-goods where tb-goods.gds-code = wt-goods.gds-code
                exclusive-lock no-error.
  if available tb-goods then do: /* gds-code совпадает */
    if tb-goods.artic = wt-goods.artic
       and tb-goods.prod-type = wt-goods.prod-type
       and tb-goods.prod-code = wt-goods.prod-code
    then do: /* artic, prod-type, prod-code совпадают */
      {&BuffCopy}
      assign imp-goods = TRUE.
      run fill-g-list in  p-imp-handle  ( input tb-goods.gds-code, input '':U, input 0).
    end.
    else do: /* artic, prod-type, prod-code несовпадают */
      run write-to-log in this-procedure (input "Системная ошибка!!! Не совпадает артикул или(и) производитель при совпадении кода товара." ).
      return error.
    end.
  end.
  else do: /* not available tb-goods, gds-code несовпадает */
    find tb-goods where tb-goods.artic     = wt-goods.artic
                    and tb-goods.prod-type = wt-goods.prod-type
                    and tb-goods.prod-code = wt-goods.prod-code
                  no-error.
    if available tb-goods then do:
      find current tb-goods exclusive-lock.
      { nws/chck-gds.i }
      if the-same-goods then do: /* товары одинаковые */
        if g#db-num = 0 then do:

          assign
            v-cmd = string( "command" + {&delim-nws} + "goods" + {&delim-nws} + "ren-gds-code"
                            + {&delim-nws} + string( wt-goods.gds-code )
                            + {&delim-nws} + string( tb-goods.gds-code )
                           )
            .

          run nws/cr-route.p ( input {&send-cmd}, input v-cmd, input ?, input string( g#news-source-db ) ).

          assign
            load-tax = FALSE
          .
          run write-to-log in this-procedure (input "Пришедший товар (gds-code) " + string( wt-goods.gds-code )
                            + " заменен на " + string( tb-goods.gds-code ) + "." ).
        end.
        else do:
          assign
            old-gds-code = tb-goods.gds-code
          .
          run utl/ren-gdsc.p
            ( input old-gds-code
             ,input wt-goods.gds-code
            ) no-error .
          if error-status :error then do:
            run write-to-log in this-procedure
              (input "Не удалось заменить gds-code существовавшего товара " + string( old-gds-code )
                     + " на " + string( wt-goods.gds-code ) + "." + {&new-line}
                     + return-value + {&new-line} + error-status:get-message(1)
              ).
            return error.
          end.
          run write-to-log in this-procedure (input "Существовавший товар (gds-code) " + string( old-gds-code )
                            + " заменен на " + string( wt-goods.gds-code ) + "." ).
          {&BuffCopy}
        end.
        assign imp-goods = TRUE.
      end.
      else do: /* товары разные и их надо развести по artic */
        if g#db-num = 0 then do:
          if g#auto = true then do:
            run write-to-log in this-procedure (input "Коллизия! Дождитесь разбора коллизий в УБД." ).
            return error.
          end.
          else do:
            run write-to-log in this-procedure (input "Коллизия! Дождитесь разбора коллизий в УБД и повторите прием пакета." ).
            return error.
          end.
        end.
        else do:
          run write-to-log in this-procedure (input "Коллизия! Необходимо изменить артикул и(или) производителя у товара." + {&new-line}
                            + tb-goods.gds-name + {&new-line}
                            + tb-goods.artic + " " + tb-goods.prod-type + " " + string( tb-goods.prod-code ) + "." + {&new-line}
                          ).
          if g#auto = true then do:
            run write-to-log in this-procedure (input "Для этого запустите ручной разбор пакета." ).
            return error.
          end.
          else do:
            message "Коллизия! Необходимо изменить артикул и(или) производителя у товара." skip
                    tb-goods.gds-name skip
                    tb-goods.artic + " " + tb-goods.prod-type + " " + string( tb-goods.prod-code ) + "." skip
                    view-as alert-box.
            run utl/new-art.w ( input ? /* parParentProc */
                           ,input tb-goods.artic
                           ,input tb-goods.prod-type
                           ,input tb-goods.prod-code
                          ) no-error.
            if return-value <> "" then do:
              run write-to-log in this-procedure (input "Артикул не изменен " + rec-full ).
              message "Артикул не изменен " + rec-full
                      view-as alert-box.
              return error.
            end.
          end.
        end.
      end.
    end.
    else do:
      create tb-goods.
      buffer-copy wt-goods to tb-goods.
      assign imp-goods = TRUE.
    end.
  end.
end.

for each locb-bar-code where locb-bar-code.gds-code = wt-goods.gds-code
on error  undo, return error
:
  run check-avail-gds-code in p-imp-handle
    ( input-output locb-bar-code.gds-code
    ).
  run create-bar-code in p-imp-handle
    ( input locb-bar-code.b-code
     ,input locb-bar-code.cli-base-rate
     ,input locb-bar-code.gds-code
     ,input locb-bar-code.in-code
     ,input locb-bar-code.node-code
     ,input locb-bar-code.part-code
     ,input locb-bar-code.unit-cli
     ,input locb-bar-code.cr-db-num
    ).

  for each locb-prod-bc where locb-prod-bc.b-code = locb-bar-code.b-code
  on error  undo, return error
  :
    run check-avail-b-code in p-imp-handle
      ( input-output locb-prod-bc.b-code
      ).
    run create-prod-bc in p-imp-handle
      ( input locb-prod-bc.b-code
       ,input locb-prod-bc.b-str
       ,input yes
       ,input locb-prod-bc.cr-db-num
       ,input locb-prod-bc.bc-on-type
      ).
  end.
end.

if load-tax then do:
  /*
  for each buf_tax-rate-gds where buf_tax-rate-gds.gds-code     = wt-goods.gds-code
  on error  undo, return error
  :
    delete buf_tax-rate-gds.
  end.
  */

  for each locb-tax-rate-gds no-lock
    where locb-tax-rate-gds.gds-code     = wt-goods.gds-code
  on error  undo, return error
  :

    find FIRST buf_tax-rate-gds where
              buf_tax-rate-gds.gds-code     = locb-tax-rate-gds.gds-code
          and buf_tax-rate-gds.tax-code  = locb-tax-rate-gds.tax-code
          AND buf_tax-rate-gds.host-code = locb-tax-rate-gds.host-code
          AND buf_tax-rate-gds.obj-type  = locb-tax-rate-gds.obj-type
          AND buf_tax-rate-gds.obj-code  = locb-tax-rate-gds.obj-code
          AND buf_tax-rate-gds.fact-order  = locb-tax-rate-gds.fact-order
                     exclusive-lock no-error.
    if not available buf_tax-rate-gds then do:
      create buf_tax-rate-gds.
    end.
    buffer-copy locb-tax-rate-gds to buf_tax-rate-gds.

  end.
end.

/* ------------------ почистим за собой --------------------------- */
for each locb-bar-code
on error  undo, return error
:
  delete locb-bar-code.
end.
for each locb-prod-bc
on error  undo, return error
:
  delete locb-prod-bc.
end.
for each locb-tax-rate-gds
on error  undo, return error
:
  delete locb-tax-rate-gds.
end.

/* $Workfile$ e n d */