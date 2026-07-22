/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

ќтчет по скорости продаж

јвтор: ƒемин јлексей —ергеевич
ƒата создани€: 03/23/06
Author: Alexey Demin
Creation date: 03/23/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$".

procedure search-prov1 :

  do
  on error undo, return error return-value
  :
    for each temp-goods :
      for each obj-list :
        /* по всем парти€м свободной зоны - ищем резерв */
        run partslib-init-temp-parts ( input obj-list.obj-type, input obj-list.obj-code, input temp-goods.artic, input temp-goods.prod-type, input temp-goods.prod-code) .

        for each buf1_doc-line no-lock
          where buf1_doc-line.obj-type     = obj-list.obj-type
            and buf1_doc-line.obj-code     = obj-list.obj-code
            and buf1_doc-line.prod-type    = temp-goods.prod-type
            and buf1_doc-line.prod-code    = temp-goods.prod-code
            and buf1_doc-line.artic        = temp-goods.artic
            and buf1_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh}
            and buf1_doc-line.status_      = {&fact}
          :
          find first buf_trn-doc no-lock
            where buf_trn-doc.doc-code = buf1_doc-line.doc-code
            no-error .
          find first temp-goods-cli
            where temp-goods-cli.gds-code = temp-goods.gds-code
              and temp-goods-cli.cli-type = buf_trn-doc.cli-type
              and temp-goods-cli.cli-code = buf_trn-doc.cli-code
            no-error .
          if not available temp-goods-cli then do:
            find first buf_clients no-lock
              where buf_clients.obj-type = buf_trn-doc.cli-type
                and buf_clients.obj-code = buf_trn-doc.cli-code
            no-error .
            if not available buf_clients then next .
            create temp-goods-cli.
            assign
              temp-goods-cli.gds-code  = temp-goods.gds-code
              temp-goods-cli.artic     = temp-goods.artic
              temp-goods-cli.prod-code = temp-goods.prod-code
              temp-goods-cli.prod-type = temp-goods.prod-type
              temp-goods-cli.gds-name  = temp-goods.gds-name
              temp-goods-cli.grp-name  = temp-goods.grp-name
              temp-goods-cli.cli-type  = buf_clients.obj-type
              temp-goods-cli.cli-code  = buf_clients.obj-code
              temp-goods-cli.cli       = buf_clients.obj-name
            .
            find first temp-parts
              where temp-parts.supp-type = buf_trn-doc.cli-type
                and temp-parts.supp-code = buf_trn-doc.cli-code
              no-error .
            if available temp-parts then do:
              assign temp-goods-cli.sum-reserv = temp-parts.fact-qnty - temp-parts.free-qnty .
  /* *********************************************************** */
              find first Temp-obj1
                where Temp-obj1.gds-code = temp-goods-cli.gds-code
                  and Temp-obj1.cli-type = temp-goods-cli.cli-type
                  and Temp-obj1.cli-code = temp-goods-cli.cli-code
                  and Temp-obj1.obj-type = Temp-date.obj-type
                  and Temp-obj1.obj-code = Temp-date.obj-code
              no-error .
              if not available Temp-obj1 then do:
                create Temp-obj1 .
                assign
                  Temp-obj1.gds-code = temp-goods.gds-code
                  Temp-obj1.cli-type = temp-goods-cli.cli-type
                  Temp-obj1.cli-code = temp-goods-cli.cli-code
                  Temp-obj1.obj-code = obj-list.obj-code
                  Temp-obj1.obj-type = obj-list.obj-type
                .
              end.
              assign Temp-obj1.reserv = Temp-obj1.reserv + buf_gds-obj.fact-qnty - buf_gds-obj.free-qnty .
  /* *********************************************************** */
            end.
          end.
        end.
      end.
    end.
    for each temp-goods : delete temp-goods . end.

  end.

end procedure. /* search-prov1 */


procedure Ostatok1 :
  do
  on error undo, return error return-value
  :
  for each Temp-date :
    if Temp-date.obj-type = {&shop} then
      assign
        str-find = {&TDEDT_Ras_Vnesh_Kass}
        str-find1 = {&TDEDT_Vozvrat_Vnesh_Kass}
      .
    else
      assign
        str-find = {&TDEDT_Ras_Vnesh}
        str-find1 = {&TDEDT_Vozvrat_Vnesh}
      .

    for each temp-goods-cli :

      assign Counter1 = Counter1 + 1.
     { rep/repfrm.i disp Counter1 }

      find first Temp-obj1
        where Temp-obj1.gds-code = temp-goods-cli.gds-code
          and Temp-obj1.cli-type = temp-goods-cli.cli-type
          and Temp-obj1.cli-code = temp-goods-cli.cli-code
          and Temp-obj1.obj-type = Temp-date.obj-type
          and Temp-obj1.obj-code = Temp-date.obj-code
        no-error .
      if not available Temp-obj1 then do:
        create Temp-obj1 .
        assign
          Temp-obj1.gds-code = temp-goods-cli.gds-code
          Temp-obj1.cli-type = temp-goods-cli.cli-type
          Temp-obj1.cli-code = temp-goods-cli.cli-code
          Temp-obj1.obj-code = Temp-date.obj-code
          Temp-obj1.obj-type = Temp-date.obj-type
          Temp-obj1.rashod   = 0
          Temp-obj1.speed    = 0
          Temp-obj1.ostat    = 0
        .
      end.
      /* считаем остатки */
      find last buf_stk-supp-line no-lock
        where buf_stk-supp-line.obj-type  = Temp-date.obj-type
          and buf_stk-supp-line.obj-code  = Temp-date.obj-code
          and buf_stk-supp-line.cli-type  = temp-goods-cli.cli-type
          and buf_stk-supp-line.cli-code  = temp-goods-cli.cli-code
          and buf_stk-supp-line.artic     = temp-goods-cli.artic
          and buf_stk-supp-line.prod-type = temp-goods-cli.prod-type
          and buf_stk-supp-line.prod-code = temp-goods-cli.prod-code
          and buf_stk-supp-line.fact-order < Temp-date.cur-fact-order
          and buf_stk-supp-line.sum-type  = {&arh-cost}
/*          and buf_stk-supp-line.cat-id    = '##,##'*/
        no-error .
      if available buf_stk-supp-line then do:
        assign
          temp-goods-cli.sum-ostat = temp-goods-cli.sum-ostat + buf_stk-supp-line.fact-qnty
          Temp-obj1.ostat = Temp-obj1.ostat + buf_stk-supp-line.fact-qnty
        .
      end.

      /* теперь расходы и возвраты */
      /* расход на конец */
      find last buf_stk-supp-line no-lock
        where buf_stk-supp-line.obj-type  = Temp-date.obj-type
          and buf_stk-supp-line.obj-code  = Temp-date.obj-code
          and buf_stk-supp-line.cli-type  = temp-goods-cli.cli-type
          and buf_stk-supp-line.cli-code  = temp-goods-cli.cli-code
          and buf_stk-supp-line.artic     = temp-goods-cli.artic
          and buf_stk-supp-line.prod-type = temp-goods-cli.prod-type
          and buf_stk-supp-line.prod-code = temp-goods-cli.prod-code
          and buf_stk-supp-line.sum-type  = {&arh-sadt} + str-find
/*          and buf_stk-supp-line.cat-id    = '##,##'*/
          and buf_stk-supp-line.fact-order < v-fact-order-end
      no-error .
      if available buf_stk-supp-line then assign Temp-obj1.rashod = Temp-obj1.rashod - buf_stk-supp-line.fact-qnty .

      /* расход на начало */
      find last buf_stk-supp-line no-lock
        where buf_stk-supp-line.obj-type  = Temp-date.obj-type
          and buf_stk-supp-line.obj-code  = Temp-date.obj-code
          and buf_stk-supp-line.cli-type  = temp-goods-cli.cli-type
          and buf_stk-supp-line.cli-code  = temp-goods-cli.cli-code
          and buf_stk-supp-line.artic     = temp-goods-cli.artic
          and buf_stk-supp-line.prod-type = temp-goods-cli.prod-type
          and buf_stk-supp-line.prod-code = temp-goods-cli.prod-code
          and buf_stk-supp-line.sum-type  = {&arh-sadt} + str-find
/*          and buf_stk-supp-line.cat-id    = '##,##'*/
          and buf_stk-supp-line.fact-order <= v-fact-order-start
        no-error .
      if available buf_stk-supp-line then assign Temp-obj1.rashod = Temp-obj1.rashod + buf_stk-supp-line.fact-qnty .

      /* возврат на конец */
      find last buf_stk-supp-line no-lock
        where buf_stk-supp-line.obj-type  = Temp-date.obj-type
          and buf_stk-supp-line.obj-code  = Temp-date.obj-code
          and buf_stk-supp-line.cli-type  = temp-goods-cli.cli-type
          and buf_stk-supp-line.cli-code  = temp-goods-cli.cli-code
          and buf_stk-supp-line.artic     = temp-goods-cli.artic
          and buf_stk-supp-line.prod-type = temp-goods-cli.prod-type
          and buf_stk-supp-line.prod-code = temp-goods-cli.prod-code
          and buf_stk-supp-line.sum-type  = {&arh-sadt} + str-find1
/*          and buf_stk-supp-line.cat-id    = '##,##'*/
          and buf_stk-supp-line.fact-order < v-fact-order-end
      no-error .
      if available buf_stk-supp-line then assign Temp-obj1.rashod = Temp-obj1.rashod - buf_stk-supp-line.fact-qnty .

      /* возврат на начало */
      find last buf_stk-supp-line no-lock
        where buf_stk-supp-line.obj-type  = Temp-date.obj-type
          and buf_stk-supp-line.obj-code  = Temp-date.obj-code
          and buf_stk-supp-line.cli-type  = temp-goods-cli.cli-type
          and buf_stk-supp-line.cli-code  = temp-goods-cli.cli-code
          and buf_stk-supp-line.artic     = temp-goods-cli.artic
          and buf_stk-supp-line.prod-type = temp-goods-cli.prod-type
          and buf_stk-supp-line.prod-code = temp-goods-cli.prod-code
          and buf_stk-supp-line.sum-type  = {&arh-sadt} + str-find1
/*          and buf_stk-supp-line.cat-id    = '##,##'*/
          and buf_stk-supp-line.fact-order <= v-fact-order-start
        no-error .
      if available buf_stk-supp-line then assign Temp-obj1.rashod = Temp-obj1.rashod + buf_stk-supp-line.fact-qnty .

      /* теперь надо найти кол-во дней, когда товар был на объекте */
      run CalcDayNal1 (input temp-goods-cli.artic,    input temp-goods-cli.prod-type, input temp-goods-cli.prod-code,
                       input Temp-date.obj-type,      input Temp-date.obj-code,
                       input temp-goods-cli.cli-type, input temp-goods-cli.cli-code,  output v-day-nal) .

      if v-day-nal > 0 then do:
        assign
          Temp-obj1.speed      = Temp-obj1.rashod * 30 / v-day-nal
          temp-goods-cli.sum-speed = temp-goods-cli.sum-speed + Temp-obj1.speed
        .
      end.

    end.

    /* перебираем накладные прихода в статусе накл+ - это ожидаемое поступление */
    for each  buf_trn-doc no-lock
      where buf_trn-doc.obj-type = Temp-date.obj-type
        and buf_trn-doc.obj-code = Temp-date.obj-code
        and buf_trn-doc.internal = no
        and buf_trn-doc.doc-type = {&income}
        and buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
        and buf_trn-doc.status_  = {&wayb}
/*        and buf_trn-doc.flag_    = yes*/
/*        or*/
/*            buf_trn-doc.obj-type = Temp-date.obj-type*/
/*        and buf_trn-doc.obj-code = Temp-date.obj-code*/
/*        and buf_trn-doc.internal = no*/
/*        and buf_trn-doc.doc-type = {&income}*/
/*        and buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem}*/
/*        and buf_trn-doc.status_  = {&wayb}*/
/*        and buf_trn-doc.flag_    = yes*/
      :
      for each buf1_doc-line no-lock
        where buf1_doc-line.doc-code  = buf_trn-doc.doc-code
        :
        find first temp-goods-cli
          where temp-goods-cli.artic     = buf1_doc-line.artic
            and temp-goods-cli.prod-code = buf1_doc-line.prod-code
            and temp-goods-cli.prod-type = buf1_doc-line.prod-type
            and temp-goods-cli.cli-code  = buf_trn-doc.cli-code
            and temp-goods-cli.cli-type  = buf_trn-doc.cli-type
          no-error .
        if available  temp-goods-cli then do:
          assign temp-goods-cli.sum-postup = temp-goods-cli.sum-postup + buf1_doc-line.fact-qnty .
          find first Temp-obj1
            where Temp-obj1.gds-code = temp-goods.gds-code
              and Temp-obj1.obj-type = Temp-date.obj-type
              and Temp-obj1.obj-code = Temp-date.obj-code
            no-error .
          if available  Temp-obj1 then assign Temp-obj1.postup = Temp-obj1.postup + buf1_doc-line.fact-qnty .
        end.
      end.
    end.

  end.

  if p-null = no then do: /* удал€ем 0 */
    for each temp-goods-cli :
      if temp-goods-cli.sum-reserv = 0 and temp-goods-cli.sum-postup = 0 and temp-goods-cli.sum-ostat = 0 and temp-goods-cli.sum-speed = 0 then do:
        assign ii = 0 .
        for each obj-list :
          for each Temp-obj1
            where Temp-obj1.gds-code = temp-goods-cli.gds-code
              and Temp-obj1.cli-type = temp-goods-cli.cli-type
              and Temp-obj1.cli-code = temp-goods-cli.cli-code
              and Temp-obj1.obj-type = obj-list.obj-type
              and Temp-obj1.obj-code = obj-list.obj-code
          :
            if Temp-obj1.rashod <> 0 or Temp-obj1.speed <> 0 or Temp-obj1.ostat <> 0 then do:
              assign ii = 1 .
              leave.
            end.
          end.
        end.
        if ii = 0 then do: /* все 0, удал€ем */
          for each  Temp-obj1
            where Temp-obj1.gds-code = temp-goods-cli.gds-code
              and Temp-obj1.cli-code = temp-goods-cli.cli-code
              and Temp-obj1.cli-type = temp-goods-cli.cli-type
            :
              delete Temp-obj1 .
          end.
          delete temp-goods-cli .
        end.
      end.
    end.
  end.

  end.
end procedure. /* Ostatok */




PROCEDURE CalcDayNal1 :
  define input parameter  p-artic     as character no-undo .
  define input parameter  p-prod-type as character no-undo .
  define input parameter  p-prod-code as integer   no-undo .
  define input parameter  p-obj-type  as character no-undo .
  define input parameter  p-obj-code  as integer no-undo .
  define input parameter  p-cli-type  as character no-undo .
  define input parameter  p-cli-code  as integer no-undo .
  define output parameter p-day-nal   as integer initial 0 no-undo .

  define variable cur-fo as decimal   no-undo .
  define variable is-null as logical initial yes no-undo .

  for each Temp-DayNal :
    assign Temp-DayNal.DayNal = no .

    find last buf_stk-supp-line no-lock
        where buf_stk-supp-line.obj-type  = p-obj-type
          and buf_stk-supp-line.obj-code  = p-obj-code
          and buf_stk-supp-line.cli-type  = p-cli-type
          and buf_stk-supp-line.cli-code  = p-cli-code
          and buf_stk-supp-line.artic     = p-artic
          and buf_stk-supp-line.prod-type = p-prod-type
          and buf_stk-supp-line.prod-code = p-prod-code
          and buf_stk-supp-line.fact-order < Temp-DayNal.f-o2
          and buf_stk-supp-line.sum-type   = {&arh-cost}
/*          and buf_stk-supp-line.cat-id     = {&root-cat-id}*/
        no-error.
    if available  buf_stk-supp-line then  do:
      if buf_stk-supp-line.fact-qnty <> 0 then assign Temp-DayNal.DayNal = yes .
      else if buf_stk-supp-line.fact-order > Temp-DayNal.f-o1 then do:
        find prev buf_stk-supp-line no-lock no-error .
        if available  buf_stk-supp-line then  do:
          if buf_stk-supp-line.fact-qnty <> 0 then assign Temp-DayNal.DayNal = yes .
        end.
      end.
    end.
    if Temp-DayNal.DayNal = yes then assign p-day-nal = p-day-nal + 1 .
  end.

END PROCEDURE.