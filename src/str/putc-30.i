/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вывод в поток информации о подразделения - пока только MAGIA

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/04/03
Author: Bakhtadze Natalya
Creation date: 12/04/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


PROCEDURE putc-dept.
define input parameter pos-type as char no-undo.

define variable v-upper-out-code like ub.fbr-gds-grp.out-code no-undo .
define variable v-r-b-curr-magia like ub.currency.curr-code no-undo .
define variable v-first-cycle as integer no-undo .
define buffer buf_shop for ub.shop.
define buffer buf_clients for ub.clients.
define buffer buf_cash-desk for ub.cash-desk.
define buffer buf_fbr-gds-grp for ub.fbr-gds-grp.
define buffer upper_fbr-gds-grp for ub.fbr-gds-grp.
define buffer buf_currency for ub.currency.

CASE pos-type:
  when {&cd-type-MAGIA-XML} then do:
    _for:
    for each buf_fbr-gds-grp no-lock where
            buf_fbr-gds-grp.obj-type = "":U
         AND buf_fbr-gds-grp.obj-code = 0
      by buf_fbr-gds-grp.obj-type
      by buf_fbr-gds-grp.obj-code
      by buf_fbr-gds-grp.lvl-num:
      if buf_fbr-gds-grp.node-code = 1 then NEXT _for.
      find first upper_fbr-gds-grp no-lock where
                upper_fbr-gds-grp.obj-type = "":U
            AND upper_fbr-gds-grp.obj-code = 0
            AND upper_fbr-gds-grp.node-code = buf_fbr-gds-grp.upper-code no-error .
      if avail upper_fbr-gds-grp
      and upper_fbr-gds-grp.out-code <> 0
      then do:
        assign
        v-upper-out-code = upper_fbr-gds-grp.out-code
        .
      end.
      else do:
        assign
        v-upper-out-code = 1
        .
      end.
      run bgelib-tag-open in this-procedure ( input 2, input "Group"
                                            , input substitute("ctrl='&1' tms='&2' code='&3'", 'ADD':U, OS2-time, buf_fbr-gds-grp.out-code)).
      run bgelib-tag-put in this-procedure ( input 3, input "GroupName"
                                          , input trim(buf_fbr-gds-grp.node-name, {&space-char}), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "GroupParent":U
                                          , input (string(v-upper-out-code)), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "GroupLock"
                                          , input string(if action = "U":U then 0 else 1), input 1 ).
      run bgelib-tag-close in this-procedure ( input 2, input "Group").
    end.

    _for:
    for each buf_clients no-lock where
             buf_clients.db-num = g#db-num
          AND buf_clients.obj-type = {&shop}:
      find first buf_shop no-lock where
                 buf_shop.obj-code = buf_clients.obj-code no-error .
      if not available buf_shop then next _for.
      if buf_shop.is-catering = no
      AND buf_shop.is-kitchen = no
      AND buf_shop.is-kitchen-store = no  then next _for.
      v-first-cycle = 0.
      run bgelib-tag-open in this-procedure ( input 2, input "Depart"
                                            , input substitute("ctrl='&1' tms='&2' code='&3'", (if action = "U"
                                                                                                then "ADD":U
                                                                                                else "DEL":U),
                                                                OS2-time, buf_shop.obj-code)).
      run bgelib-tag-put in this-procedure ( input 3, input "DepartName"
                                           , input trim(buf_clients.obj-name, {&space-char}), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "DepartShortName":U
                                           , input ({&shop} + string(buf_shop.obj-code)), input 1 ).
      run bgelib-tag-close in this-procedure ( input 2, input "Depart").

      { gbl/r-b-curr.i buf_shop.host-code v-r-b-curr-magia }
      find first buf_currency no-lock where
                buf_currency.curr-code = v-r-b-curr-magia no-error .
      if v-r-b-curr-magia = 0 then do:
        assign
        v-r-b-curr-magia = 1
        .
      end.
      else do:
        if not available buf_currency or
        buf_currency.okv-code = 0 then do:
          return error
          substitute("Маг &1:не удалось определить код валюты продажи"
                    ,  buf_shop.obj-code
                    ).
        end.
        assign
        v-r-b-curr-magia = buf_Currency.okv-code
        .
      end.
      for each buf_cash-desk no-lock where
                 buf_cash-desk.db-num = g#db-num
             AND buf_cash-desk.obj-code = buf_shop.obj-code
             AND buf_cash-desk.pos-type = {&cd-type-magia-xml}
             AND buf_cash-desk.autonomy <> integer({&cd-manager})
             :
        if v-first-cycle = 0 then do:
          run bgelib-tag-open in this-procedure ( input 2, input "PriceList"
                                                , input substitute("ctrl='&1' tms='&2' code='&3'", (if action = "U"
                                                                                                    then "ADD":U
                                                                                                    else "DEL":U),
                                                OS2-time, buf_shop.obj-code)).
          run bgelib-tag-put in this-procedure ( input 3, input "PriceListName"
                                              , input trim(buf_clients.obj-name, {&space-char}), input 1 ).
          run bgelib-tag-close in this-procedure ( input 2, input "PriceList").
          _fbr-gds-grp:
          for each buf_fbr-gds-grp no-lock where
                  buf_fbr-gds-grp.obj-type = {&shop}
              AND buf_fbr-gds-grp.obj-code = buf_shop.obj-code
          by buf_fbr-gds-grp.obj-type
          by buf_fbr-gds-grp.obj-code
          by buf_fbr-gds-grp.lvl-num:
            if buf_fbr-gds-grp.out-code = 0 then NEXT  _fbr-gds-grp.

            find first upper_fbr-gds-grp no-lock where
                      upper_fbr-gds-grp.obj-type = {&shop}
                  AND upper_fbr-gds-grp.obj-code = buf_fbr-gds-grp.obj-code
                  AND upper_fbr-gds-grp.node-code = buf_fbr-gds-grp.upper-code no-error .
            if avail upper_fbr-gds-grp then do:
              assign
              v-upper-out-code = upper_fbr-gds-grp.out-code
              .
            end.
            else do:
              assign
              v-upper-out-code = 1
              .
            end.
            run bgelib-tag-open in this-procedure ( input 2, input "PriceGroup"
                                                  , input substitute("ctrl='&1' tms='&2' code='&3'", 'ADD':U, OS2-time, buf_fbr-gds-grp.out-code)).
            run bgelib-tag-put in this-procedure ( input 3, input "PriceGroupName"
                                                , input trim(buf_fbr-gds-grp.node-name, {&space-char}), input 1 ).
            run bgelib-tag-put in this-procedure ( input 3, input "PriceParentGroupID":U
                                                , input (string(v-upper-out-code)), input 1 ).
            run bgelib-tag-put in this-procedure ( input 3, input "PriceListID":U
                                                , input (string(buf_shop.obj-code)), input 1 ).
            run bgelib-tag-put in this-procedure ( input 3, input "ImageIndex":U
                                                , input (string(0)), input 1 ).
            run bgelib-tag-put in this-procedure ( input 3, input "PriceGroupLock"
                                                , input string(if action = "U":U then 0 else 1), input 1 ).
            run bgelib-tag-close in this-procedure ( input 2, input "PriceGroup").
          end. /*for each buf_fbr-gds-grp no-lock where*/
          v-first-cycle = v-first-cycle + 1.
        end.

        run bgelib-tag-open in this-procedure ( input 2, input "Station"
                                              , input substitute("ctrl='&1' tms='&2' code='&3'", (if action = "U"
                                                                                                  then "ADD":U
                                                                                                  else "DEL":U),
                                              OS2-time, buf_cash-desk.cash-num)).
        run bgelib-tag-put in this-procedure ( input 3, input "StationName"
                                            , input trim(buf_cash-desk.addr-path, {&space-char}), input 1 ).
        run bgelib-tag-put in this-procedure ( input 3, input "StationType"
                                            , input string(0), input 1 ).
        run bgelib-tag-put in this-procedure ( input 3, input "StationPrLId"
                                            , input string(buf_shop.obj-code), input 1 ).
        run bgelib-tag-put in this-procedure ( input 3, input "StationCurrency"
                                            , input string(v-r-b-curr-magia), input 1 ).
        run bgelib-tag-put in this-procedure ( input 3, input "StationAccuracy"
                                            , input string(3), input 1 ).


        run bgelib-tag-close in this-procedure ( input 2, input "Station").

      end. /*if available buf_cash-desk then do:*/
    end.
  end.
END CASE .
END PROCEDURE .


/* $Workfile$ e n d */