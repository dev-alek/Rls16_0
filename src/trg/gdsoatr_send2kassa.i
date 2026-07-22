&if "{1}" = "getPromoIds" &then
   /* проверим, не участвут ли товар в акции */
   if v-dop1 = "send2kassa" and can-do(v-dop2,"promoAction") then 
   do:
    run get-db-num in this-procedure (output dbNum).
    for each PromoGoods where 
             (PromoGoods.gds-code = ub.gds-obj-attr.gds-code and PromoGoods.db-num   = dbNum)
          or (PromoGoods.gds-code = ub.gds-obj-attr.gds-code and PromoGoods.db-num   = 0) 
        no-lock,
        each PromoAction where
             PromoAction.id = PromoGoods.idAction 
         and (PromoAction.end-date = ? or PromoAction.end-date >= today)
         and PromoAction.Status_ = 1
        no-lock:
      listPromoIds = substitute("&1,&2", listPromoIds, string(recid(PromoAction))).
    end.
    if listPromoIds <> "" then
      listPromoIds = substring(listPromoIds,2).
   end.
&endif

&if "{1}" = "send2kassa" &then
  if sendGoods2Kassa and 
     not g#news and not g#esys and g#db-num > 0 then
  do:
    run str/diallog.w ( this-procedure
                  , this-procedure
                  , 'str/sendalcd.p':U
                  , ('yes' + {&delim-par} +
                     'no' + {&delim-par} +
                     'no' + {&delim-par} +
                     'no' + {&delim-par}  +
                     'no' + {&delim-par}
                       )
                  , no /*p-auto-go*/
                  , 'Прервать':U
                  , 'Отправка информации на кассу') no-error .
  end.
  if listPromoIds <> "" and 
     not g#news and not g#esys and g#db-num > 0 then 
  do:
    run str/diallog.w (
          input this-procedure
        , input this-procedure
        , input "str/promosend.p":U
        , input ({&cd-type-IBm-XML} + {&delim-par} + ub.gds-obj-attr.obj-type + {&delim-par} + string(ub.gds-obj-attr.obj-code) + {&delim-par} + "U":U + {&delim-par} + listPromoIds)
        , input no /*p-auto-go*/
        , input "":U
        , input "Отправка промоакций на кассу"
    ) no-error.
  end.
&endif
