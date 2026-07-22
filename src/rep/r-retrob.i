/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Расчет ретро-бонусов

Автор: Сливенко Сергей Андреевич
Дата создания: 09/14/11
Author: Sergey Slivenko
Creation date: 09/14/11

*/
    v-temp-sum  = 0 .
    v-temp-vozv = 0 .

    find first buf2_clients where buf2_clients.obj-type = obj-list.obj-type and
                                  buf2_clients.obj-code = obj-list.obj-code no-lock.

    for each   buf_contract where buf_contract.contract-date-beg <= x-date-start          and
                                 (buf_contract.contract-date-end >= x-date-start or
                                  buf_contract.contract-date-end = ?)                     and
                                  buf_contract.status_            = {&current-contr}      and
                                  buf_contract.host-code          = buf2_clients.host-code    and
                                  buf_contract.doc-type           = {&income}     and
                                  buf_contract.cli-type           = {1}.obj-type  and
                                  buf_contract.cli-code           = {1}.obj-code  no-lock :
      find last  buf_contract-specif where buf_contract-specif.host-code    = buf_contract.host-code    and
                                           buf_contract-specif.contract-num = buf_contract.contract-code and
                                           buf_contract-specif.gds-code     = buf_gds-obj.gds-code      no-lock no-error.
      if available buf_contract-specif then do :
        find first tt-gds where tt-gds.supp-type    = {1}.obj-type  and
                                tt-gds.supp-code    = {1}.obj-code  and
                                tt-gds.prod-type    = buf_gds-obj.prod-type and
                                tt-gds.prod-code    = buf_gds-obj.prod-code and
                                tt-gds.code         = buf_gds-obj.gds-code  no-lock no-error.
        if not available tt-gds then do :
          find first buf_goods where buf_goods.gds-code = buf_gds-obj.gds-code no-lock.
          create tt-gds.
          assign  tt-gds.supp-type    = {1}.obj-type
                  tt-gds.supp-code    = {1}.obj-code
                  tt-gds.prod-type    = buf_gds-obj.prod-type
                  tt-gds.prod-code    = buf_gds-obj.prod-code
                  tt-gds.code         = buf_gds-obj.gds-code
                  tt-gds.name         = buf_goods.gds-name
                  tt-gds.artic        = buf_gds-obj.artic
                  tt-gds.sum          = 0
                  tt-gds.sum-vat      = 0
                  tt-gds.sum-bonus    = 0
          .
          find first buf_contract-specif-attr where buf_contract-specif-attr.host-code    = buf_contract-specif.host-code     and
                                                    buf_contract-specif-attr.contract-num = buf_contract-specif.contract-num  and
                                                    buf_contract-specif-attr.gds-code     = buf_contract-specif.gds-code      and
                                                    buf_contract-specif-attr.attr-code    = "retro-bonus"                     no-lock no-error.
          if available buf_contract-specif-attr then do :

            do i = 1 to num-entries(buf_contract-specif-attr.attr-value, ';') - 1 :
              if date(entry(1, entry(i, buf_contract-specif-attr.attr-value, ';')))  <= x-date-start and
                 date(entry(2, entry(i, buf_contract-specif-attr.attr-value, ';')))  >= x-date-start then do :
                assign  tt-gds.pct-rate = decimal (entry(3, entry(i, buf_contract-specif-attr.attr-value, ';')))
                        tt-gds.sum-rate = decimal (entry(4, entry(i, buf_contract-specif-attr.attr-value, ';')))
                        tt-gds.method   =         (entry(5, entry(i, buf_contract-specif-attr.attr-value, ';')))
                        tt-gds.vozvrat  = logical (entry(6, entry(i, buf_contract-specif-attr.attr-value, ';')))
                .
                leave.
              end.
            end.
            if tt-gds.pct-rate = ? then tt-gds.pct-rate = 0.
            if tt-gds.sum-rate = ? then tt-gds.sum-rate = 0.
            if tt-gds.method   = ? then tt-gds.method = "-".
          end.
          else assign tt-gds.pct-rate = 0
                      tt-gds.sum-rate = 0
                      tt-gds.method   = "-"
          .
        end.

        find first tt-prod where tt-prod.type       = tt-gds.prod-type and
                                 tt-prod.code       = tt-gds.prod-code and
                                 tt-prod.supp-type  = tt-gds.supp-type and
                                 tt-prod.supp-code  = tt-gds.supp-code no-lock no-error.
        if not available tt-prod then do :
          find first buf2_clients where buf2_clients.obj-type = tt-gds.prod-type and
                                        buf2_clients.obj-code = tt-gds.prod-code no-lock.
          create tt-prod.
          assign  tt-prod.type       = tt-gds.prod-type
                  tt-prod.code       = tt-gds.prod-code
                  tt-prod.supp-type  = tt-gds.supp-type
                  tt-prod.supp-code  = tt-gds.supp-code
                  tt-prod.name       = buf2_clients.obj-name
                  tt-prod.sum        = 0
                  tt-prod.sum-vat    = 0
                  tt-prod.sum-bonus  = 0
          .
        end.

        find first tt-supp where tt-supp.type = {1}.obj-type and
                                 tt-supp.code = {1}.obj-code no-lock no-error.
        if not available tt-supp then do :
          create tt-supp.
          assign  tt-supp.type      = {1}.obj-type
                  tt-supp.code      = {1}.obj-code
                  tt-supp.name      = {1}.obj-name
                  tt-supp.sum       = 0
                  tt-supp.sum-vat   = 0
                  tt-supp.sum-bonus = 0
          .
        end.

        for last buf_stk-supp-line where buf_stk-supp-line.artic        = buf_gds-obj.artic                 and
                                         buf_stk-supp-line.prod-type    = buf_gds-obj.prod-type             and
                                         buf_stk-supp-line.prod-code    = buf_gds-obj.prod-code             and
                                         buf_stk-supp-line.obj-type     = obj-list.obj-type                 and
                                         buf_stk-supp-line.obj-code     = obj-list.obj-code                 and
                                         buf_stk-supp-line.cli-type     = {1}.obj-type              and
                                         buf_stk-supp-line.cli-code     = {1}.obj-code              and
                                         buf_stk-supp-line.sum-type     = {&arh-sadt} + {&TDEDT_Pri_Vnesh}  and
                                         buf_stk-supp-line.fact-order  <= v-end-fact-order                  no-lock :
          assign tt-gds.sum       = tt-gds.sum + buf_stk-supp-line.sum-rubl
                 tt-gds.sum-vat   = tt-gds.sum-vat + buf_stk-supp-line.sum-rubl - buf_stk-supp-line.vat-rubl
                 tt-prod.sum      = tt-prod.sum + buf_stk-supp-line.sum-rubl
                 tt-prod.sum-vat  = tt-prod.sum-vat + buf_stk-supp-line.sum-rubl - buf_stk-supp-line.vat-rubl
                 tt-supp.sum      = tt-supp.sum + buf_stk-supp-line.sum-rubl
                 tt-supp.sum-vat  = tt-supp.sum-vat + buf_stk-supp-line.sum-rubl - buf_stk-supp-line.vat-rubl
                 v-temp-sum = v-temp-sum + buf_stk-supp-line.sum-rubl
          .
        end.

        for last buf_stk-supp-line where buf_stk-supp-line.artic        = buf_gds-obj.artic                 and
                                         buf_stk-supp-line.prod-type    = buf_gds-obj.prod-type             and
                                         buf_stk-supp-line.prod-code    = buf_gds-obj.prod-code             and
                                         buf_stk-supp-line.obj-type     = obj-list.obj-type                 and
                                         buf_stk-supp-line.obj-code     = obj-list.obj-code                 and
                                         buf_stk-supp-line.cli-type     = {1}.obj-type              and
                                         buf_stk-supp-line.cli-code     = {1}.obj-code              and
                                         buf_stk-supp-line.sum-type     = {&arh-sadt} + {&TDEDT_Ras_Vnesh_VP}  and
                                         buf_stk-supp-line.fact-order  <= v-end-fact-order                  no-lock :
          assign tt-gds.sum       = tt-gds.sum + buf_stk-supp-line.sum-rubl
                 tt-gds.sum-vat   = tt-gds.sum-vat + buf_stk-supp-line.sum-rubl - buf_stk-supp-line.vat-rubl
                 tt-prod.sum      = tt-prod.sum + buf_stk-supp-line.sum-rubl
                 tt-prod.sum-vat  = tt-prod.sum-vat + buf_stk-supp-line.sum-rubl - buf_stk-supp-line.vat-rubl
                 tt-supp.sum      = tt-supp.sum + buf_stk-supp-line.sum-rubl
                 tt-supp.sum-vat  = tt-supp.sum-vat + buf_stk-supp-line.sum-rubl - buf_stk-supp-line.vat-rubl
                 v-temp-vozv = buf_stk-supp-line.sum-rubl
                 v-temp-sum = v-temp-sum + buf_stk-supp-line.sum-rubl
          .
        end.

        for last buf_stk-supp-line where buf_stk-supp-line.artic        = buf_gds-obj.artic                 and
                                         buf_stk-supp-line.prod-type    = buf_gds-obj.prod-type             and
                                         buf_stk-supp-line.prod-code    = buf_gds-obj.prod-code             and
                                         buf_stk-supp-line.obj-type     = obj-list.obj-type                 and
                                         buf_stk-supp-line.obj-code     = obj-list.obj-code                 and
                                         buf_stk-supp-line.cli-type     = {1}.obj-type              and
                                         buf_stk-supp-line.cli-code     = {1}.obj-code              and
                                         buf_stk-supp-line.sum-type     = {&arh-sadt} + {&TDEDT_Pri_Vnesh}  and
                                         buf_stk-supp-line.fact-order  <= v-start-fact-order                no-lock :
          assign tt-gds.sum       = tt-gds.sum - buf_stk-supp-line.sum-rubl
                 tt-gds.sum-vat   = tt-gds.sum-vat - (buf_stk-supp-line.sum-rubl - buf_stk-supp-line.vat-rubl)
                 tt-prod.sum      = tt-prod.sum - buf_stk-supp-line.sum-rubl
                 tt-prod.sum-vat  = tt-prod.sum-vat - (buf_stk-supp-line.sum-rubl - buf_stk-supp-line.vat-rubl)
                 tt-supp.sum      = tt-supp.sum - buf_stk-supp-line.sum-rubl
                 tt-supp.sum-vat  = tt-supp.sum-vat - (buf_stk-supp-line.sum-rubl - buf_stk-supp-line.vat-rubl)
                 v-temp-sum = v-temp-sum - buf_stk-supp-line.sum-rubl
          .
        end.

        for last buf_stk-supp-line where buf_stk-supp-line.artic        = buf_gds-obj.artic                 and
                                         buf_stk-supp-line.prod-type    = buf_gds-obj.prod-type             and
                                         buf_stk-supp-line.prod-code    = buf_gds-obj.prod-code             and
                                         buf_stk-supp-line.obj-type     = obj-list.obj-type                 and
                                         buf_stk-supp-line.obj-code     = obj-list.obj-code                 and
                                         buf_stk-supp-line.cli-type     = {1}.obj-type              and
                                         buf_stk-supp-line.cli-code     = {1}.obj-code              and
                                         buf_stk-supp-line.sum-type     = {&arh-sadt} + {&TDEDT_Ras_Vnesh_VP}  and
                                         buf_stk-supp-line.fact-order  <= v-start-fact-order                no-lock :
          assign tt-gds.sum       = tt-gds.sum - buf_stk-supp-line.sum-rubl
                 tt-gds.sum-vat   = tt-gds.sum-vat - (buf_stk-supp-line.sum-rubl - buf_stk-supp-line.vat-rubl)
                 tt-prod.sum      = tt-prod.sum - buf_stk-supp-line.sum-rubl
                 tt-prod.sum-vat  = tt-prod.sum-vat - (buf_stk-supp-line.sum-rubl - buf_stk-supp-line.vat-rubl)
                 tt-supp.sum      = tt-supp.sum - buf_stk-supp-line.sum-rubl
                 tt-supp.sum-vat  = tt-supp.sum-vat - (buf_stk-supp-line.sum-rubl - buf_stk-supp-line.vat-rubl)
                 v-temp-vozv = v-temp-vozv - buf_stk-supp-line.sum-rubl
                 v-temp-sum = v-temp-sum - buf_stk-supp-line.sum-rubl
          .
        end.

        if tt-gds.sum <> 0 then do :
          if v-temp-sum <> 0 then do :
            if tt-gds.method = "vat-yes" then
              tt-gds.sum-bonus = tt-gds.sum * (tt-gds.pct-rate / 100) + tt-gds.sum-rate.
            else
              tt-gds.sum-bonus = tt-gds.sum-vat * (tt-gds.pct-rate / 100) + tt-gds.sum-rate.
            if v-temp-vozv <> 0 and tt-gds.vozvrat then tt-gds.sum-bonus = 0.
            assign tt-prod.sum-bonus = tt-prod.sum-bonus + tt-gds.sum-bonus
                  tt-supp.sum-bonus = tt-supp.sum-bonus + tt-gds.sum-bonus
            .
          end.
        end.
        else do :
          delete tt-gds.
        end.

        if tt-prod.sum = 0 then delete tt-prod.

        leave.
      end.
    end.