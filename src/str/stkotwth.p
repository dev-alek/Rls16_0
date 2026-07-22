block-level on error undo, throw.
/*

$Revision: 24d6fc541c24, 417, rls $
$Author: PGridchina $
$Date: Mon Jan 18 18:07:08 2016 +0400 $
$Workfile: stkotwth.p $
$Archive: str/stkotwth.p $

Процедура заполнения остатков и оборотов по документу материальных ценностей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/12/06
Author: Bakhtadze Natalya
Creation date: 04/12/06

На основе текущих остатков на объекте-субобъекте, и установка текущих остатков на объекте

*/

define input parameter parrec_wth-doc as recid   no-undo.
define input parameter parrecalc-doc  as logical no-undo. /*Будем перерассчитывать документ*/
define input parameter p-wth-doc-close as logical   no-undo .
define input parameter p-wth-code like ub.wealth.wth-code   no-undo .  /*Используется только для пересчете линий при закрытии задним числом*/

define variable vss-revision    as character no-undo init "$Revision: 24d6fc541c24, 417, rls $":U .
define variable vss-author      as character no-undo init "$Author: PGridchina $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 18 18:07:08 2016 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: stkotwth.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/stkotwth.p $":U .
define variable vss-description as character no-undo init "Триггер на запись документа".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/clntattr.i }
{ cmp/library.i }
{ trg/cwthobjh.i }
{ trg/cwthpbjh.i }
{ str/wthparts.i }
{ str/wth-arh.i }

define buffer bf_wth-doc      for ub.wth-doc.
define buffer bf_wth-line     for ub.wth-line.
define buffer prev_wth-doc    for ub.wth-doc.
define buffer bf_wth-obj      for ub.wth-obj.
define buffer bf_wth-pobj     for ub.wth-pobj.
define buffer bf_clients      for ub.clients.
define buffer bf_wth-parts    for ub.wth-parts.
define buffer bf_wth-dtl      for ub.wth-dtl.
define variable varattr-value as character no-undo.
define variable varattr-type  as character no-undo.
/*переменные для определения цены*/
define variable v-bar-code    as character no-undo.
define variable v-doc-num     as character  no-undo.
define variable v-price-sale  as decimal no-undo.
define variable v-road-tax    as decimal   no-undo.
define variable v-excise      as decimal     no-undo.
define variable v-curr-r-b    as character    no-undo.
define variable v-base-rate   as decimal no-undo.
define variable v-base-scale  as decimal no-undo.
define variable v-sum-line-rubl    as decimal      no-undo.
define variable v-sum-line-base    as decimal      no-undo.
define variable v-sum-dtl-rubl    as decimal      no-undo.
define variable v-sum-dtl-base    as decimal      no-undo.
define variable v-gds-price-rubl    as decimal      no-undo.
define variable v-gds-price-base    as decimal      no-undo.

define temp-table temp-wth-line no-undo like ub.wth-line.
/* run gbl\inidebug.p. */ 
find first bf_wth-doc where recid(bf_wth-doc) = parrec_wth-doc no-error.
if not available bf_wth-doc then do:
   return error
   "Неправильные входные параметры файла stkotwth.p. Указан record id документа материальных ценностей: " +
   string(parrec_wth-doc).
end.
if p-wth-code > 0 and   p-wth-doc-close = true  then do:
  return error "Ошибка задания входных параметров. Закрытие документа для одной линии запрещено. Указан код МЦ:" +  string(p-wth-code).
end.

tr:
do transaction
on error undo, return error "Ошибка при подсчете оборотов и остатков в файле stkotwth.p."
on stop  undo, return error "Ошибка при подсчете оборотов и остатков в файле stkotwth.p."
on quit  undo, return error "Ошибка при подсчете оборотов и остатков в файле stkotwth.p."
:

  if p-wth-doc-close = true
/*    and ( not g#news
        or (g#news and  g#db-num  = 0) )    */
        then do:
    /* Локирование архивов */
    run wth-arh-calctt-loc(input bf_wth-doc.doc-code
                          ,input yes) no-error.
        if error-status:error then undo tr, return error return-value + error-status:get-message(1).
  end.
  empty temp-table temp-wth-line.
  for each bf_wth-line exclusive where
          bf_wth-line.doc-code = bf_wth-doc.doc-code
  by bf_wth-line.wth-code
  on error undo, return error "Ошибка при подсчете оборотов и остатков в файле stkotwth.p."
  on stop  undo, return error "Ошибка при подсчете оборотов и остатков в файле stkotwth.p."
  on quit  undo, return error "Ошибка при подсчете оборотов и остатков в файле stkotwth.p."
  :

    find first temp-wth-line where
              temp-wth-line.wth-code = bf_wth-line.wth-code no-error.
    if not available temp-wth-line then do:
      create temp-wth-line.
      assign
      temp-wth-line.wth-code = bf_wth-line.wth-code
      .
    end.
    assign
    temp-wth-line.fact-sum = temp-wth-line.fact-sum + bf_wth-line.fact-sum
    temp-wth-line.doc-sum = temp-wth-line.doc-sum + bf_wth-line.doc-sum
    temp-wth-line.aft-sum = temp-wth-line.aft-sum + bf_wth-line.aft-sum
    .
    release temp-wth-line.
  end.
  for each bf_wth-line exclusive where
          bf_wth-line.doc-code = bf_wth-doc.doc-code
  and (if p-wth-code > 0 then bf_wth-line.wth-code = p-wth-code else true)
  break
  by bf_wth-line.wth-code
  on error undo, return error "Ошибка при подсчете оборотов и остатков в файле stkotwth.p."
  on stop  undo, return error "Ошибка при подсчете оборотов и остатков в файле stkotwth.p."
  on quit  undo, return error "Ошибка при подсчете оборотов и остатков в файле stkotwth.p."
  :
    find first temp-wth-line where temp-wth-line.wth-code = bf_wth-line.wth-code.
   v-sum-line-rubl = 0.
   v-sum-line-base = 0.
   /* остатки и обороты не меняются, если это новости пришедшие в УБД*/

   if  (not g#news
       or (g#news and  g#db-num  = 0))
       and bf_wth-doc.ext-doc-type <> {&WDEDT_Dst_Cli}
   then do:
             /*Ищем мат. ценность на объекте*/
      /*Создаем мат. ценность на объекте*/
      { gbl/wthobjcr.i bf_wth-doc.obj-type bf_wth-doc.obj-code bf_wth-line.wth-code bf_wth-obj }
      find current bf_wth-obj exclusive.

        /*Ищем мат ценность на месте хранения объекта*/
      { gbl/wthpobjc.i bf_wth-doc.obj-type bf_wth-doc.obj-code bf_wth-line.wth-code bf_wth-line.w-p-code bf_wth-pobj }
      find current bf_wth-pobj exclusive.

      if parrecalc-doc = yes then do:
         /*Если это внутреннее перемещение внутри объекта,
           то оно не изменяет оборотов по объекту. В связи стем, что внутриобъеетное перемещение ходит по новостям отдельно,
           в документах такого типа обороты по объекту меняем тоже */
         if lookup (bf_wth-doc.ext-doc-type, {&WDEDT_Obj}) = 0 and
         bf_wth-doc.ext-doc-type <> {&WDEDT_Dec}
         then do:
            /*записываем в историю старое значение остатков*/
            /*Устанавливаем новые обороты по строке документа*/
            /*
          {1} - буффер куда пишем
          {2} - откуда берем прошлые остатки
          {3} - буфер линии документа
          {4} - суффикс полей
            */
            { str/stkotwth.i bf_wth-line. bf_wth-obj. temp-wth-line.}
         end.
         else do:
            assign
            bf_wth-line.incass       = bf_wth-obj.incass
            bf_wth-line.income       = bf_wth-obj.income
            bf_wth-line.incass-bank  = bf_wth-obj.incass-bank
            bf_wth-line.incass-other = bf_wth-obj.incass-other
            bf_wth-line.incass-cassa = bf_wth-obj.incass-cassa
            bf_wth-line.income-cassa = bf_wth-obj.income-cassa
            bf_wth-line.income-other = bf_wth-obj.income-other .
         end.
         if bf_wth-doc.ext-doc-type = {&WDEDT_Dec} then do:
            assign
            bf_wth-line.incass-pl       = bf_wth-pobj.incass-pl
            bf_wth-line.income-pl       = bf_wth-pobj.income-pl
            bf_wth-line.incass-bank-pl  = bf_wth-pobj.incass-bank-pl
            bf_wth-line.incass-other-pl = bf_wth-pobj.incass-other-pl
            bf_wth-line.incass-cassa-pl = bf_wth-pobj.incass-cassa-pl
            bf_wth-line.income-cassa-pl = bf_wth-pobj.income-cassa-pl
            bf_wth-line.income-other-pl = bf_wth-pobj.income-other-pl .

         end.
         else do:
          /*Устанавливаем новые обороты складского места по строке документа*/
          { str/stkotwth.i bf_wth-line. bf_wth-pobj. bf_wth-line. -pl}
        end.
      end.

      /*записываем в историю старое значение остатков*/
      if p-wth-doc-close = true
      then do:
       /*    
        /* для действия удаления мы пишем историю в процедуре болеее выского уровня - reclcwth.p */
        run wth-pobj-hist in this-procedure (
                                              buffer bf_wth-pobj
                                            ,input bf_wth-pobj.obj-type
                                            ,input bf_wth-pobj.obj-code
                                            ,input bf_wth-pobj.wth-code
                                            ,input bf_wth-pobj.w-p-code
                                            ,input {&c-wth-obj_close}
                                            ,input {&table_wth-doc}
                                            ,input bf_wth-doc.doc-code
                                            ,input bf_wth-doc.fact-date
                                            ,input bf_wth-doc.user-db-num
                                            ,input bf_wth-doc.user-name
                                            ,input bf_wth-doc.sys-date
                                            ,input bf_wth-doc.sys-time-int
                                            ,input bf_wth-doc.sys-time
                                            ).

        run wth-obj-hist in this-procedure (
                                              buffer bf_wth-obj
                                            ,input bf_wth-obj.obj-type
                                            ,input bf_wth-obj.obj-code
                                            ,input bf_wth-obj.wth-code
                                            ,input {&c-wth-obj_close}
                                            ,input {&table_wth-doc}
                                            ,input bf_wth-doc.doc-code
                                            ,input bf_wth-doc.fact-date
                                            ,input bf_wth-doc.user-db-num
                                            ,input bf_wth-doc.user-name
                                            ,input bf_wth-doc.sys-date
                                            ,input bf_wth-doc.sys-time-int
                                            ,input bf_wth-doc.sys-time
                                            ).
                                            */
      end.
      /*Считаем их текущими на объекте*/
      if last-of(bf_wth-line.wth-code) then do:
        assign
        bf_wth-obj.incass           = bf_wth-line.incass
        bf_wth-obj.income           = bf_wth-line.income
        bf_wth-obj.incass-bank      = bf_wth-line.incass-bank
        bf_wth-obj.incass-other     = bf_wth-line.incass-other
        bf_wth-obj.incass-cassa     = bf_wth-line.incass-cassa
        bf_wth-obj.income-cassa     = bf_wth-line.income-cassa
        bf_wth-obj.income-other     = bf_wth-line.income-other
        .  
      end.
      assign
      bf_wth-pobj.incass-pl       = bf_wth-line.incass-pl
      bf_wth-pobj.income-pl       = bf_wth-line.income-pl
      bf_wth-pobj.incass-bank-pl  = bf_wth-line.incass-bank-pl
      bf_wth-pobj.incass-other-pl = bf_wth-line.incass-other-pl
      bf_wth-pobj.incass-cassa-pl = bf_wth-line.incass-cassa-pl
      bf_wth-pobj.income-cassa-pl = bf_wth-line.income-cassa-pl
      bf_wth-pobj.income-other-pl = bf_wth-line.income-other-pl
      .

   end.  /*g#news*/


   if p-wth-doc-close = true then do :       /*Обработка партий. Партии не закрываются только при пересчете документа. В новостях во всех УБД отрабатывает закрытие партии*/
        for each bf_wth-parts exclusive-lock where
          bf_wth-parts.out-code = bf_wth-line.doc-code
          and bf_wth-parts.wth-code = bf_wth-line.wth-code
          and bf_wth-parts.w-p-code = bf_wth-line.w-p-code
          break by bf_wth-parts.wth-code  by bf_wth-parts.par-code by bf_wth-parts.gds-code
            on error undo tr, return error substitute( "&1. &2&3&4", 'Ошибка при обработке партий', return-value, {&new-line}, error-status :get-message (1))
            on stop  undo, return error substitute( "&1. stop", vss-workfile )
            on quit  undo, return error substitute( "&1. endkey", vss-workfile )
            :
            assign
            bf_wth-parts.fact-order = bf_wth-doc.fact-order
            bf_wth-parts.fact-date  = bf_wth-doc.fact-date
            bf_wth-parts.fact-num   = bf_wth-doc.fact-num
            .
            run wth-doc-close in this-procedure (input recid(bf_wth-parts)) no-error.
            if error-status:error then undo tr, return error return-value + error-status:get-message(1).
            if first-of(bf_wth-parts.par-code) and not g#news then do:
              v-sum-dtl-rubl = 0.
              v-sum-dtl-base = 0.
            end.    /*last par-code*/

            if first-of(bf_wth-parts.gds-code) and not g#news then do:
              /* определяем бар-код */
              { gbl/gdsbcode.i
                bf_wth-parts.gds-code
                ?
                v-bar-code }
              /* определяем цену стеллы */
              { gbl/bcodeprc.i
              bf_wth-doc.obj-type
              bf_wth-doc.obj-code
              v-bar-code
              0
              0
              v-doc-num
              v-price-sale
              v-road-tax
              v-excise
              }
              /*определяем в какой валюте цена*/
              { gbl/curr-r-b.i v-curr-r-b }
              { gbl/baserate.i
              bf_wth-doc.host-code
              bf_wth-doc.DOC-DATE
              v-base-rate
              v-base-scale
              no-error }

             if v-curr-r-b = {&r-b-rubl} then do: /*если учет в р у б л ях, пересчитываем в ценах баз.валюты*/
             assign
              v-gds-price-rubl = v-price-sale
              v-gds-price-base = v-price-sale / v-base-rate
              .
             end.
             else do:
             assign
              v-gds-price-rubl = v-price-sale * v-base-rate
              v-gds-price-base = v-price-sale
              .
             end.
            end. /*first-of*/

            v-sum-line-rubl = v-sum-line-rubl + v-gds-price-rubl * bf_wth-parts.fact-qnty.
            v-sum-line-base = v-sum-line-base + v-gds-price-base * bf_wth-parts.fact-qnty.
            v-sum-dtl-rubl = v-sum-dtl-rubl + v-gds-price-rubl * bf_wth-parts.fact-qnty.
            v-sum-dtl-base = v-sum-dtl-base + v-gds-price-base * bf_wth-parts.fact-qnty.

            if last-of(bf_wth-parts.par-code) and not g#news then do:
              find first   bf_wth-dtl exclusive-lock where
                    bf_wth-dtl.doc-code = bf_wth-line.doc-code
                and bf_wth-dtl.wth-code = bf_wth-line.wth-code
                and bf_wth-dtl.par-code = bf_wth-parts.par-code .
              assign

              bf_wth-dtl.price-rubl = v-sum-dtl-rubl / bf_wth-dtl.fact-sum
              bf_wth-dtl.price-base = v-sum-dtl-base / bf_wth-dtl.fact-sum
              no-error.
            end.    /*last par-code*/
        end.   /*parts*/
        if not g#news then do: /*заполнение цены реализации только при закрытии документа на объекте создания*/
          assign
          bf_wth-line.fact-order = bf_wth-doc.fact-order
          bf_wth-line.fact-date  = bf_wth-doc.fact-date
          bf_wth-line.price-rubl = v-sum-line-rubl / bf_wth-line.fact-sum
          bf_wth-line.price-base = v-sum-line-base / bf_wth-line.fact-sum
          no-error .
        end.    /*не новости*/
     end. /*doc-close*/
  end.     /*for each wth-line*/
  if p-wth-doc-close = true
/*    and ( not g#news
          or (g#news and  g#db-num  = 0) )   */
         then do:
    /* Расчет архивов */
    run wth-arhdoc-close(input bf_wth-doc.doc-code) no-error.
        if error-status:error then undo tr, return error return-value + error-status:get-message(1).

  end.


end. /*transaction*/