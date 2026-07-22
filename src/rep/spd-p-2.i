/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет по скорости продаж

Автор: Демин Алексей Сергеевич
Дата создания: 03/23/06
Author: Alexey Demin
Creation date: 03/23/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$".

procedure search-prov :
  do on error undo, return error return-value :
    for each temp-goods :
      for each obj-list :
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
          find first Temp-cli
            where Temp-cli.gds-code = temp-goods.gds-code
              and Temp-cli.cli-type = buf_trn-doc.cli-type
              and Temp-cli.cli-code = buf_trn-doc.cli-code
            no-error .
          if not available Temp-cli then do:
            find first buf_clients no-lock
              where buf_clients.obj-type = buf_trn-doc.cli-type
                and buf_clients.obj-code = buf_trn-doc.cli-code
            no-error .
            if not available buf_clients then next .
            create Temp-cli.
            assign
              Temp-cli.gds-code = temp-goods.gds-code
              Temp-cli.cli-type = buf_trn-doc.cli-type
              Temp-cli.cli-code = buf_trn-doc.cli-code
              Temp-cli.cli      = buf_clients.obj-name
            .
          end.
        end.
      end.
    end.

  end.
end procedure. /* search-prov */


procedure Ostatok :
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

    for each temp-goods  :
      assign Counter1 = Counter1 + 1.
      { rep/repfrm.i disp Counter1 }

      find first Temp-obj1
        where Temp-obj1.gds-code = temp-goods.gds-code
          and Temp-obj1.obj-type = Temp-date.obj-type
          and Temp-obj1.obj-code = Temp-date.obj-code
        no-error .
      if not available Temp-obj1 then do:
        create Temp-obj1 .
        assign
          Temp-obj1.gds-code = temp-goods.gds-code
          Temp-obj1.obj-code = Temp-date.obj-code
          Temp-obj1.obj-type = Temp-date.obj-type
          Temp-obj1.rashod   = 0
          Temp-obj1.speed    = 0
          Temp-obj1.ostat    = 0
        .
      end.
      /* считаем остатки */
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = Temp-date.obj-type
          and buf_stk-line.obj-code  = Temp-date.obj-code
          and buf_stk-line.artic     = temp-goods.artic
          and buf_stk-line.prod-type = temp-goods.prod-type
          and buf_stk-line.prod-code = temp-goods.prod-code
          and buf_stk-line.sum-type  = {&arh-crsa}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < Temp-date.cur-fact-order
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          temp-goods.sum-ostat = temp-goods.sum-ostat + buf_stk-line.fact-qnty
          Temp-obj1.ostat = Temp-obj1.ostat + buf_stk-line.fact-qnty
        .
      end.

      /* теперь расходы и возвраты */
      /* расход на конец */
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = Temp-date.obj-type
          and buf_stk-line.obj-code  = Temp-date.obj-code
          and buf_stk-line.artic     = temp-goods.artic
          and buf_stk-line.prod-type = temp-goods.prod-type
          and buf_stk-line.prod-code = temp-goods.prod-code
          and buf_stk-line.sum-type  = {&arh-csdt} + str-find
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end
      no-error .
      if available buf_stk-line then assign Temp-obj1.rashod = Temp-obj1.rashod - buf_stk-line.fact-qnty .
      /* расход на начало */
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = Temp-date.obj-type
          and buf_stk-line.obj-code  = Temp-date.obj-code
          and buf_stk-line.artic     = temp-goods.artic
          and buf_stk-line.prod-type = temp-goods.prod-type
          and buf_stk-line.prod-code = temp-goods.prod-code
          and buf_stk-line.sum-type  = {&arh-csdt} + str-find
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start
        no-error .
      if available buf_stk-line then assign Temp-obj1.rashod = Temp-obj1.rashod + buf_stk-line.fact-qnty .

      /* возврат на конец */
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = Temp-date.obj-type
          and buf_stk-line.obj-code  = Temp-date.obj-code
          and buf_stk-line.artic     = temp-goods.artic
          and buf_stk-line.prod-type = temp-goods.prod-type
          and buf_stk-line.prod-code = temp-goods.prod-code
          and buf_stk-line.sum-type  = {&arh-csdt} + str-find1
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end
      no-error .
      if available buf_stk-line then assign Temp-obj1.rashod = Temp-obj1.rashod - buf_stk-line.fact-qnty .

      /* возврат на начало */
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = Temp-date.obj-type
          and buf_stk-line.obj-code  = Temp-date.obj-code
          and buf_stk-line.artic     = temp-goods.artic
          and buf_stk-line.prod-type = temp-goods.prod-type
          and buf_stk-line.prod-code = temp-goods.prod-code
          and buf_stk-line.sum-type  = {&arh-csdt} + str-find1
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start
        no-error .
      if available buf_stk-line then assign Temp-obj1.rashod = Temp-obj1.rashod + buf_stk-line.fact-qnty .

      /* теперь надо найти кол-во дней, когда товар был на объекте */
      run CalcDayNal (input temp-goods.artic, input temp-goods.prod-type, input temp-goods.prod-code, input Temp-date.obj-type, input Temp-date.obj-code,output v-day-nal) .

      if v-day-nal > 0 then do:
        assign
          Temp-obj1.speed      = Temp-obj1.rashod * 30 / v-day-nal
          temp-goods.sum-speed = temp-goods.sum-speed + Temp-obj1.speed
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
        or
            buf_trn-doc.obj-type = Temp-date.obj-type
        and buf_trn-doc.obj-code = Temp-date.obj-code
        and buf_trn-doc.internal = yes
        and buf_trn-doc.doc-type = {&income}
        and buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem}
        and buf_trn-doc.status_  = {&wayb}
/*        and buf_trn-doc.flag_    = yes*/
      :
      for each buf1_doc-line no-lock
        where buf1_doc-line.doc-code  = buf_trn-doc.doc-code
        :
        find first temp-goods
          where temp-goods.artic     = buf1_doc-line.artic
            and temp-goods.prod-code = buf1_doc-line.prod-code
            and temp-goods.prod-type = buf1_doc-line.prod-type
          no-error .
        if available  temp-goods then do:
          assign temp-goods.sum-postup = temp-goods.sum-postup + buf1_doc-line.fact-qnty .
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
  end.
end procedure. /* Ostatok */



PROCEDURE CalcDayNal :
  define input parameter  p-artic     as character no-undo .
  define input parameter  p-prod-type as character no-undo .
  define input parameter  p-prod-code as integer   no-undo .
  define input parameter  p-obj-type  as character no-undo .
  define input parameter  p-obj-code  as integer no-undo .
  define output parameter p-day-nal   as integer initial 0 no-undo .

  for each Temp-DayNal :
    assign Temp-DayNal.DayNal = no .
    find first doc-line no-lock
      where doc-line.obj-type  = p-obj-type
        and doc-line.obj-code  = p-obj-code
        and doc-line.prod-code = p-prod-code
        and doc-line.prod-type = p-prod-type
        and doc-line.artic     = p-artic
        and doc-line.status_   = {&fact}
        and doc-line.fact-order >= Temp-DayNal.f-o1
        and doc-line.fact-order <  Temp-DayNal.f-o2
      no-error .
    if available doc-line then assign Temp-DayNal.DayNal = yes .

    if Temp-DayNal.DayNal = no then do:
      find last stk-line no-lock
        where stk-line.obj-type  = p-obj-type
          and stk-line.obj-code  = p-obj-code
          and stk-line.artic     = p-artic
          and stk-line.prod-code = p-prod-code
          and stk-line.prod-type = p-prod-type
/*          and stk-line.fact-order >= Temp-DayNal.f-o1*/
          and stk-line.fact-order < Temp-DayNal.f-o2
          and stk-line.sum-type   = {&arh-crsa}
          and stk-line.cat-id     = {&root-cat-id}
        no-error.
      if available  stk-line then  do:
        if stk-line.fact-qnty > 0 then assign Temp-DayNal.DayNal = yes .
      end.
    end.
    if Temp-DayNal.DayNal = yes then assign p-day-nal = p-day-nal + 1 .
  end.

END PROCEDURE.