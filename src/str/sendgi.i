/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

обход веток товаров при пересылке

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/12/05
Author: Bakhtadze Natalya
Creation date: 10/12/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

  /*здесь то что для товара надо определить один раз*/
  if action = "U" then do:
      { gbl/gdsbcode.i {1}.gds-code ? main-b-code no-error }
      find first buf_producer no-lock where
                 buf_producer.obj-type = {1}.prod-type
             AND buf_producer.obj-code = {1}.prod-code no-error .
      assign
      for-producer = (if available buf_producer
                      then buf_producer.obj-name
                      else ({1}.prod-type + string({1}.prod-code)))
      for-producer-int = (if {1}.prod-type = {&cmp} then 1000000 else 0 ) + {1}.prod-code
      .
&if "{&called}" <> "send-codes-only" &then
      run get-o-attr in this-procedure (
                                        input {1}.gds-code
                                        ,input i-obj-code
                                        ,input {&shop}
                                        ,output std-discnt-rule_
                                        ,output temp-discnt-rule_
                                        ,output temp-discnt-method_
                                        ,output for-wd
                                        ,output for-fp
                                        ,output for-grp-code
                                        ,output for-petrol-purse
                                        ,output need-auth
                                        ,output qnty-discnt-rule_
                                        ,output kat-discnt-rule_
                                        ,output kat-discnt-method_
                                        ,output date-discnt-rule_
                                        ,output abs-discnt-rule_
                                        ,output tot-discnt-rule_
                                        ,output for-wgd
                                        ,output for-taracode
                                      ) no-error .
      if error-status:error then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("!!!Ошибка при получении значений атрибутов на объекте товара &1 &2&3"
                                , {1}.artic
                                , {1}.prod-type
                                , {1}.prod-code
                                )
                                  ).
        assign
        v-view-log = yes
        .
        &if "{&called}" = "s-prodbcn" or "{&called}" = "send-bcn"  &then
            return "NEXT":U.
        &else
            return error .
        &endif
      end.
      for-price = ?.
      if v-is-restaurant and
      v-is-null-price then do:
        assign
        for-price = 0
        .
      end.
      else do:
        run tax-val in this-procedure
          ({1}.artic,
                      {1}.prod-type,
                      {1}.prod-code,
                      {1}.unit-base,
                      {2},
                      ub.units.type,
                      ?, /*parrec-id */
                      yes , /*paris-log*/
                      rdtaxcd ,
                      vattaxcd,
                      exctaxcd,
                      no,
                      ub.shop.host-code, /* код фирмы*/
                      {&shop}, /*parobj-type   тип объекта*/
                      i-obj-code,
  &if  "{&called}" = "in-ov" &then
                      ub.price-list.road-tax, /*parroad-tax   дорожный налог*/
                      ub.price-list.excise, /*parexcise     акциз*/
  &else
                      ?, /*parroad-tax   дорожный налог*/
                      ?, /*parexcise     акциз*/
  &endif
                      output prichina,
                      input-output for-price
                      ) no-error  .
        if error-status:error then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("!!!Ошибка при определении налогов на товар &1 &2&3: &4"
                                 , {1}.artic
                                 , {1}.prod-type
                                 , {1}.prod-code
                                 , prichina
                                 )
                                    ).
          assign
          v-view-log = yes
          .
  &if  "{&called}" = "in-ov" &then
            return error.
  &else
            run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input substitute("!!!Ошибка при определении налогов на товар &1 &2&3: &4"
                                  , {1}.artic
                                  , {1}.prod-type
                                  , {1}.prod-code
                                  , prichina
                                  )
                                      ).
            assign
            v-view-log = yes
            .
            if (g#news or g#esys or g#auto) and return-value <> "error" then do:
              return error prichina.
            end.
            else if not (g#news or g#esys or g#auto) then do:
                error-status:error = no.
                return.
            end.
&endif
        end. /*if es*/
        if return-value = "error" then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("!!!Ошибка при определении налогов на товар &1 &2&3: &4"
                                , {1}.artic
                                , {1}.prod-type
                                , {1}.prod-code
                                , prichina
                                )
                                    ).
          assign
          v-view-log = yes
          .
          return "NEXT".
           /*if g#news or g#esys or g#auto then 
           return error prichina.*/
        end.
      end.
      
     
      define VARIABLE v-attr-val    as character no-undo .
      define VARIABLE v-attr-type   as character no-undo .
       
      run clntattr-value in this-procedure  ( input {&shop}
                                            , input ub.shop.obj-code
                                            , input "envd"
                                            , output v-attr-val
                                            , output v-attr-type
                                            ) no-error.

       
      if tax-cass and new-good then do:
          tax-string = "".
          /*сформируем строчку по всем налогам  отправляемым на кассу*/
          _tt-tax:
          FOR EACH tt-tax No-LOCK:
            if NOT tt-tax.to-cashdesk  then NEXT _tt-tax.
            if v-attr-val = "yes" then do:
                find first ub.tax-rate-attr where ub.tax-rate-attr.attr-code = "envd" no-error.
                
                if AVAILABLE ub.tax-rate-attr then do:
                    tax-string = tax-string + " " + (if tt-tax.individual
                                              then (if tt-tax.rate-value <> 0
                                                        then string(ub.tax-rate-attr.rate-code + txfixnum)
                                                        else "")
                                              else string(ub.tax-rate-attr.rate-code)).
                                               
                end.      
                else do:
                    tax-string = tax-string + " " + (if tt-tax.individual
                                              then (if tt-tax.rate-value <> 0
                                                        then string(tt-tax.rate-code + txfixnum)
                                                        else "")
                                              else string(tt-tax.rate-code)).
                end.                  
            end.
            else do:
            tax-string = tax-string + " " + (if tt-tax.individual
                                              then (if tt-tax.rate-value <> 0
                                                        then string(tt-tax.rate-code + txfixnum)
                                                        else "")
                                              else string(tt-tax.rate-code)).
            end.
            if tt-tax.individual and tt-tax.rate-value <> 0 then do:
              FIND FIRST cash-txr where
                        cash-txr.tax-code = tt-tax.tax-code
                    and cash-txr.host-code = ub.shop.host-code
                    and cash-txr.obj-type = {&shop}
                    and cash-txr.obj-code = ub.shop.obj-code
                    and cash-txr.status_  = {&current-status}
                    and cash-txr.rc = recid({1}) no-error.
              if not available cash-txr then do:
                FIND FIRST cash-txr where cash-txr.crf = (cr-txr + 1) No-ERROR.
                start-paket-txr = no.
                if not avail cash-txr then
                create cash-txr.
                cash-txr.crf = cr-txr + 1.
                cr-txr = cr-txr + 1.
                BUFFER-COPY tt-tax USING tax-code rate-code tax-type rate-value
                                    TO  cash-txr
                                    ASSIGN
                                    cash-txr.rc = recid({1})
                                    cash-txr.host-code = ub.shop.host-code
                                    cash-txr.obj-type = {&shop}
                                    cash-txr.obj-code = i-obj-code
                                    cash-txr.status_ = {&current-status}
                                    .
                cash-txr.rate-code = cash-txr.rate-code + txfixnum.
              end.
            end.
          END.
      end.
&endif
  end. /*добавление на кассу*/


  if LOOKUP({&petrolium}, ub.units.type) > 0 and
      LOOKUP({&divisional}, ub.units.type) > 0 AND
      {1}.gds-type = {&gds-goods}
  then do:
        petrol-trk = yes.
  end.
  else petrol-trk = no.

  /*конец блока определения того что для твоара надо узнать один раз на все бар-коды*/

/* $Workfile$ e n d */