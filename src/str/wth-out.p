block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: wth-out.p $
$Archive: str/wth-out.p $

Создание документов внутреннего перемещени

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/08/05
Author: Bakhtadze Natalya
Creation date: 09/08/05

*/

define parameter buffer buf_wth-doc for ub.wth-doc.
define parameter buffer buf_out_wth-doc for ub.wth-doc.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wth-out.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/wth-out.p $":U .
define variable vss-description as character no-undo init "Создание документов внутреннего перемещения".
{ cmp/vssrevis.i }
{ cmp/library.i  }
{ cmp/str-glbl.i }
{ cmp/trg-def.i  }
define variable same_db as logical   no-undo initial no . /* при внутренних перемещениях в одной и той же УБД */
define variable v-base-code         like ub.currency.curr-code no-undo .

DEFINE VARIABLE vardoc-rec as recid no-undo .
DEFINE VARIABLE varline-rec as recid no-undo .
DEFINE VARIABLE vardtl-rec as recid no-undo .
DEFINE VARIABLE varparts-rec as recid no-undo .
DEFINE VARIABLE f-date     AS DATE NO-UNDO.
DEFINE VARIABLE f-time     AS INT  NO-UNDO.
DEFINE VARIABLE s-date     AS DATE NO-UNDO.
DEFINE VARIABLE s-num      AS INT  NO-UNDO.
DEFINE VARIABLE s-name     AS CHAR NO-UNDO.
DEFINE VARIABLE is-parts   AS log  NO-UNDO.
DEFINE VARIABLE is-dtl     AS log  NO-UNDO.

define buffer doc-obj      for ub.clients .
define buffer buf_cliobj   for ub.clients .
define buffer buf_wth-line for ub.wth-line.
define buffer buf_wth-dtl  for ub.wth-dtl.
define buffer buf_wth-parts   for ub.wth-parts.
define buffer buf_out_wth-line for ub.wth-line.
define buffer buf_out_wth-dtl  for ub.wth-dtl.
define buffer buf_wth-par      for ub.wth-par.
define temp-table tt-par-dtl  no-undo like ub.wth-par
{ str/ttpardt0.i }
.
define temp-table tt-wth-line no-undo like ub.wth-line.
define temp-table tt-wth-parts no-undo like ub.wth-parts.

define variable v-ext-type as char no-undo.
define variable v-doc-code as char no-undo.
define variable v-today    as date no-undo.


_main:
do on error undo _main, return error return-value
   on stop undo _main, return error:


  find current buf_wth-doc  no-error .
  if not available buf_wth-doc then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден документ" skip
      view-as alert-box .
    undo, return error .
  end.

  define variable v-host-code like buf_wth-doc.host-code no-undo .

  /* определяем код фирмы для объекта */
  { gbl/hostcode.i
    buf_wth-doc.obj-type
    buf_wth-doc.obj-code
    v-host-code
    no-error
  }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении кода фирмы для объекта с которого происходит перемещение" skip
      "Документ внутреннего перемещения" buf_wth-doc.doc-code skip
      "Объект" buf_wth-doc.obj-type buf_wth-doc.obj-code skip
      view-as alert-box error .
    undo, return error .
  end.

  /* определяем код базовой валюты для фирмы */
  { gbl/basecode.i
    v-host-code
    v-base-code
    no-error
  }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении кода базовой валюты для фирмы" skip
      "Документ внутреннего перемещения" buf_wth-doc.doc-code skip
      "Объект" buf_wth-doc.obj-type buf_wth-doc.obj-code skip
      view-as alert-box error .
    undo, return error .
  end.

  /* определяем код фирмы для объекта на который происходит перемещение */
  define variable v-cli-host-code like buf_wth-doc.host-code no-undo .
  { gbl/hostcode.i
    buf_wth-doc.cli-type
    buf_wth-doc.cli-code
    v-cli-host-code
    no-error
  }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении кода фирмы для объекта на который происходит перемещение" skip
      "Документ внутреннего перемещения" buf_wth-doc.doc-code skip
      "Объект" buf_wth-doc.cli-type buf_wth-doc.cli-code skip
      view-as alert-box error .
    undo, return error .
  end.

  if v-cli-host-code <> v-host-code then do:
    message
      vss-workfile vss-revision vss-description skip
      "Документ " buf_wth-doc.doc-code skip
      "Фирма объекта откуда происходит перемещение" skip
      "не совпадает с фирмой, куда происходит перемещение" skip
      "v-host-code"     v-host-code     skip
      "v-cli-host-code" v-cli-host-code skip
      "Закрытие документа невозможно" skip
      view-as alert-box error .
    undo, return error .
  end.

  find ub.clients no-lock
    where ub.clients.obj-type = buf_wth-doc.cli-type
      and ub.clients.obj-code = buf_wth-doc.cli-code
    no-error .
  if not available ub.clients then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестный клиент" skip
      "Документ " buf_wth-doc.doc-code skip
      "Объект" buf_wth-doc.obj-type buf_wth-doc.obj-code skip
      "Клиент" buf_wth-doc.cli-code buf_wth-doc.cli-type skip
      view-as alert-box .
    undo, return error .
  end.

  if  buf_wth-doc.cli-type <> {&stock}
  and buf_wth-doc.cli-type <> {&shop}
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Клиент документа внутреннего перемещения не является объектом"
      "Документ " buf_wth-doc.doc-code skip
      "Объект" buf_wth-doc.obj-type buf_wth-doc.obj-code skip
      "Клиент" buf_wth-doc.cli-code buf_wth-doc.cli-type skip
      view-as alert-box error .
    undo, return error .
  end.

  find doc-obj no-lock
    where doc-obj.obj-type = buf_wth-doc.obj-type
      and doc-obj.obj-code = buf_wth-doc.obj-code
    no-error .
  if not available doc-obj then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестный объект" skip
      "Документ " buf_wth-doc.doc-code skip
      "Объект" buf_wth-doc.obj-type buf_wth-doc.obj-code skip
      "Клиент" buf_wth-doc.cli-code buf_wth-doc.cli-type skip
      view-as alert-box .
    undo, return error .
  end.

  if  buf_wth-doc.obj-type <> {&stock}
  and buf_wth-doc.obj-type <> {&shop}
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Объект документа внутреннего перемещения не является объектом"
      "Документ " buf_wth-doc.doc-code skip
      "Объект" buf_wth-doc.obj-type buf_wth-doc.obj-code skip
      "Клиент" buf_wth-doc.cli-code buf_wth-doc.cli-type skip
      view-as alert-box error .
    undo, return error .
  end.

  if doc-obj.db-num = clients.db-num
  and clients.db-num > 0 then do:
    assign
      same_db = yes
    .
  end.

/*  if  buf_wth-doc.status_  = {&fact}*/
/*  and lookup(buf_wth-doc.doc-type, {&expense_income}) > 0*/
/*  and buf_wth-doc.internal = yes*/
/*  and buf_wth-doc.discnt-type <> {&manufactured} then do:*/
/*    /* правильный документ */*/
/*  end.*/
/*  else do:*/
/*    message*/
/*      vss-workfile vss-revision vss-description skip*/
/*      "Ошибка задания входных параметров" skip*/
/*      "В качестве параметра можно передавать только документы" skip*/
/*      "внутреннего прихода, внутреннего расход" skip*/
/*      "закрытые до статуса" {&fact} skip*/
/*      "Документ" buf_wth-doc.doc-code skip*/
/*      "Тип документа" buf_wth-doc.doc-type skip*/
/*      "Внутренний" buf_wth-doc.internal skip*/
/*      "discnt-type" buf_wth-doc.discnt-type skip*/
/*      "Статус" buf_wth-doc.status_ skip*/
/*      view-as alert-box error .*/
/*    undo, return error .*/
/*  end.*/



  if (doc-obj.db-num > 0 and g#db-num = 0 and same_db = no )
  or (doc-obj.db-num = 0 and g#db-num = 0)
  or (g#db-num > 0 and same_db = yes)
  then do:
    /* необходимо создавать документ прихода/возврата */
  end.
  else do:
    /* не надо порождать документ */
    return.  /* --->>>--- */
  end.

/*Если док-т внутр. прихода и нет линий или партий с данными по документу не совпадающими с фактом, то тогда надо создавать документ возврата */
if buf_wth-doc.doc-type = {&income} and not buf_wth-doc.exter and not buf_wth-doc.inter then do:
  if can-find(first buf_wth-parts where
              buf_wth-parts.out-code = buf_wth-doc.doc-code
              and (buf_wth-parts.fact-rangeFrom <> buf_wth-parts.doc-rangeFrom or
                   buf_wth-parts.fact-rangeTo <> buf_wth-parts.doc-rangeTo or buf_wth-parts.stts = 1 )
              )
  or can-find(first buf_wth-line where
              buf_wth-line.doc-code = buf_wth-doc.doc-code
              and buf_wth-line.doc-sum <> buf_wth-line.fact-sum)
  then.
  else return.
end.
if buf_wth-doc.ext-doc-type = {&WDEDT_Put_Cash} then do:
/*Если документ порождается при погашении через кассу, то номер создается как для нового документа*/
  run str/wth-inc1.p ( input yes, /*silent*/
                  input-output vardoc-rec,
                  input        {&add-def},
                  input "":U ,
                  input buf_wth-doc.host-code,
                  input buf_wth-doc.obj-type,
                  input buf_wth-doc.obj-code,
                  input "":U,  /*cli-type*/
                  input 0 , /*cli-code*/
                  input buf_wth-doc.doc-date,
                  input buf_wth-doc.fact-date,
                  input buf_wth-doc.shift-date,
                  input buf_wth-doc.shift-num,
                  input buf_wth-doc.shift-name,
                  input buf_wth-doc.operator,
                  input buf_wth-doc.deliver,
                  input buf_wth-doc.receiver,
                  input {&expense},
                  input buf_wth-doc.auto-fill,
                  input buf_wth-doc.exter_,
                  input buf_wth-doc.inter_,
                  input buf_wth-doc.doc-code,
                  input {&wthd-wth-doc},
                  input yes,
                  input 0,
                  input 0,
                  input buf_wth-doc.PS,
                  input {&wayb},
                  input no  ,
                  {&WDEDT_Exp_Int_Put}) .

end.
else  if buf_wth-doc.obj-type = buf_wth-doc.cli-type and      /*Если внутриобъектный документ*/
           buf_wth-doc.obj-code = buf_wth-doc.cli-code and
           buf_wth-doc.inter_ = yes

then do:
  if  buf_wth-doc.ext-doc-type = {&WDEDT_Exp_Obj} then v-ext-type = {&WDEDT_Inc_Obj}.
  else if  buf_wth-doc.ext-doc-type = {&WDEDT_Inc_Obj} then v-ext-type = {&WDEDT_Exp_Obj}.
  else if  buf_wth-doc.ext-doc-type = {&WDEDT_Exp_Obj_Put} then v-ext-type = {&WDEDT_Inc_Obj_Put}.
  else if  buf_wth-doc.ext-doc-type = {&WDEDT_Exp_Obj_Free} then v-ext-type = {&WDEDT_Inc_Obj_Free}.

     run str/wth-inc1.p ( input yes, /*silent*/
                  input-output vardoc-rec,
                  input        {&add-def},
                  input replace(buf_wth-doc.doc-code, "-", "=") ,
                  input buf_wth-doc.host-code,
                  input buf_wth-doc.obj-type,  /*obj*/
                  input buf_wth-doc.obj-code,
                  input buf_wth-doc.cli-type,   /*cli*/
                  input buf_wth-doc.cli-code,
                  input buf_wth-doc.doc-date,
                  input buf_wth-doc.fact-date,
                  input buf_wth-doc.shift-date,
                  input buf_wth-doc.shift-num,
                  input buf_wth-doc.shift-name,
                  input buf_wth-doc.operator,
                  input buf_wth-doc.deliver,
                  input buf_wth-doc.receiver,
                  input (if buf_wth-doc.doc-type = {&income} then {&expense} else {&income}),
                  input buf_wth-doc.auto-fill,
                  input buf_wth-doc.exter_,
                  input buf_wth-doc.inter_,
                  input buf_wth-doc.doc-code,
                  input {&wthd-wth-doc},
                  input yes,
                  input 0,
                  input 0,
                  input buf_wth-doc.PS,
                  input {&wayb},
                  input no ,
                  input v-ext-type ) no-error .
end.
else do:
  { gbl/curobjdt.i buf_wth-doc.cli-type buf_wth-doc.cli-code v-today }
  assign f-date = v-today.
  run gbl/factdate.p (
                     INPUT        buf_wth-doc.cli-type
                    ,INPUT        buf_wth-doc.cli-code
                    ,INPUT-OUTPUT f-date
                    ,INPUT-OUTPUT f-time
                    ,INPUT-OUTPUT s-date
                    ,INPUT-OUTPUT s-num
                    ,INPUT-OUTPUT s-name
                    ,INPUT        YES
                      ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    return error return-value.
  END.
  if  buf_wth-doc.ext-doc-type = {&WDEDT_Exp_Int_Put} then v-ext-type = {&WDEDT_Inc_Int_Put}.
  else if  buf_wth-doc.ext-doc-type = {&WDEDT_Inc_Int_Put}  then v-ext-type = {&WDEDT_Ret_Int_Put}.
  else if  buf_wth-doc.ext-doc-type = {&WDEDT_Exp_Int_Free} then v-ext-type = {&WDEDT_Inc_Int_Free}.
  else if  buf_wth-doc.ext-doc-type = {&WDEDT_Inc_Int_Free} then v-ext-type = {&WDEDT_Ret_Int_Free}.
  else if  buf_wth-doc.ext-doc-type = {&WDEDT_Inc_Int} then v-ext-type = {&WDEDT_Ret_Int}.
  else if  buf_wth-doc.ext-doc-type = {&WDEDT_Exp_Int} then v-ext-type = {&WDEDT_Inc_Int}.

  if buf_wth-doc.doc-type = {&expense}     then v-doc-code = replace(buf_wth-doc.doc-code, "-", "=").
  else if buf_wth-doc.doc-type = {&income} then v-doc-code = replace(buf_wth-doc.doc-code, "=", "*").
 /*      message buf_wth-doc.doc-code 'nn' v-doc-code buf_wth-doc.doc-type = {&expense}.*/
  run str/wth-inc1.p ( input yes, /*silent*/
                  input-output vardoc-rec,
                  input {&add-def},
                  input v-doc-code,
                  input buf_wth-doc.host-code,
                  input buf_wth-doc.cli-type,  /*obj*/
                  input buf_wth-doc.cli-code,
                  input buf_wth-doc.obj-type,   /*cli*/
                  input buf_wth-doc.obj-code,
                  input buf_wth-doc.doc-date,
                  input f-date,    /*fact-date*/
                  input s-date,
                  input s-num,
                  input s-name,
                  input buf_wth-doc.operator,
                  input buf_wth-doc.deliver,
                  input buf_wth-doc.receiver,
                  input (if buf_wth-doc.doc-type = {&income} then {&return} else {&income}),
                  input buf_wth-doc.auto-fill,
                  input buf_wth-doc.exter_,
                  input buf_wth-doc.inter_,
                  input buf_wth-doc.doc-code,
                  input {&wthd-wth-doc},
                  input yes,
                  input 0,
                  input 0,
                  input buf_wth-doc.PS,
                  input {&wayb},
                  input no,
                  input v-ext-type) no-error .
end.
  if error-status:error then do:
/*  message    'error' return-value.    */
    undo _main, return error return-value + {&new-line} + error-status:get-message(1) .
  end.

  FIND FIRST buf_out_wth-doc where
            recid(buf_out_wth-doc) = vardoc-rec No-ERROR.
  if not avail buf_out_wth-doc then do:
    undo _main, return error.
  end.
  for each buf_wth-line No-LOCK WHERE
          buf_wth-line.doc-code = buf_wth-doc.doc-code:
    for each tt-par-dtl:
      delete tt-par-dtl.
    end.
    is-parts = no.
    is-dtl   = no.
    for each buf_wth-dtl no-lock where
            buf_wth-dtl.doc-code = buf_wth-doc.doc-code AND
            buf_wth-dtl.wth-code = buf_wth-line.wth-code AND
            buf_wth-dtl.w-p-code = buf_wth-line.w-p-code
            , first buf_wth-par no-lock where
                    buf_wth-par.wth-code = buf_wth-dtl.wth-code
                and buf_wth-par.par-code = buf_wth-dtl.par-code
                   :
      for each buf_wth-parts no-lock where
        buf_wth-parts.out-code = buf_wth-line.doc-code and
        buf_wth-parts.wth-code = buf_wth-line.wth-code and
        buf_wth-parts.w-p-code = buf_wth-line.w-p-code  and
        buf_wth-parts.par-code = buf_wth-dtl.par-code
        :
        if buf_out_wth-doc.doc-type = {&return}
          and buf_wth-parts.fact-rangeFrom = buf_wth-parts.doc-rangeFrom
          and buf_wth-parts.fact-rangeTo = buf_wth-parts.doc-rangeTo
          and buf_wth-parts.stts = 0
        then next.
        if (buf_out_wth-doc.doc-type = {&return} and (buf_wth-parts.doc-rangeFrom <> buf_wth-parts.fact-rangeFrom  or buf_wth-parts.stts = 1))
          or buf_out_wth-doc.doc-type <> {&return} then do:
             run str/wthpartp.p (  {&add-def},
                       buf_out_wth-doc.obj-type    ,
                       buf_out_wth-doc.obj-code    ,
                       buf_wth-line.out-code       ,
                       buf_wth-parts.wth-code      ,
                       buf_wth-parts.par-code      ,
                       buf_wth-parts.in-code       ,
                       buf_out_wth-doc.doc-code ,
                       buf_wth-parts.ser-code      ,
                       buf_wth-parts.db-num        ,
                       buf_wth-parts.doc-rangeFrom,
                       ( if buf_wth-doc.doc-type = {&return} and buf_wth-parts.stts = 0 then buf_wth-parts.fact-rangeFrom - 1 else buf_wth-parts.fact-RangeTo ) ,
                       buf_wth-parts.doc-rangeFrom,
                       ( if buf_wth-doc.doc-type = {&return} and buf_wth-parts.stts = 0 then buf_wth-parts.fact-rangeFrom - 1 else buf_wth-parts.fact-RangeTo ) ,
                       buf_out_wth-doc.host-code     ,
                       buf_out_wth-doc.contract-code     ,
                       buf_wth-parts.price-rubl   ,
                       buf_wth-parts.price-base   ,
                       buf_wth-parts.supp-type    ,
                       buf_wth-parts.supp-code    ,
                       buf_wth-parts.in-obj-type    ,
                       buf_wth-parts.in-obj-code    ,
                       buf_out_wth-doc.ext-doc-type     ,
                       buf_wth-parts.gds-code    ,
                       0,
                       buf_wth-parts.beg-dt     ,
                       buf_wth-parts.end-dt     ,
                       buf_wth-parts.vat-pc     ,
                       buf_wth-parts.cli-code    ,
                       buf_wth-parts.cli-type    ,
                       buf_wth-parts.out-obj-code    ,
                       buf_wth-parts.out-obj-type    ,
                       buf_wth-parts.sale-obj-code   ,
                       buf_wth-parts.sale-obj-type   ,
                       buf_out_wth-doc.doc-code ,
                       yes,
                       buf_out_wth-doc.doc-type ,
                      input-output varparts-rec
                    ) no-error.

          if error-status:error then do:
            undo _main, return error "Ошибка при создании партии. " + return-value + {&new-line} + error-status:get-message(1).
          end.
        end.
        else if (buf_out_wth-doc.doc-type = {&return} and buf_wth-parts.doc-rangeTo <> buf_wth-parts.fact-rangeTo)
        then do:
             run str/wthpartp.p (  {&add-def} ,
                       buf_out_wth-doc.obj-type      ,
                       buf_out_wth-doc.obj-code      ,
                       buf_wth-line.out-code       ,
                       buf_wth-parts.wth-code      ,
                       buf_wth-parts.par-code      ,
                       buf_wth-parts.in-code        ,
                       buf_out_wth-doc.doc-code ,
                       buf_wth-parts.ser-code      ,
                       buf_wth-parts.db-num        ,
                       buf_wth-parts.fact-rangeTo + 1,
                       buf_wth-parts.doc-rangeTo  ,
                       buf_wth-parts.fact-rangeTo + 1,
                       buf_wth-parts.doc-rangeTo  ,
                       buf_out_wth-doc.host-code     ,
                       buf_out_wth-doc.contract-code     ,
                       buf_wth-parts.price-rubl    ,
                       buf_wth-parts.price-base    ,
                       buf_wth-parts.supp-type    ,
                       buf_wth-parts.supp-code    ,
                       buf_wth-parts.in-obj-type    ,
                       buf_wth-parts.in-obj-code    ,
                       buf_out_wth-doc.ext-doc-type     ,
                       buf_wth-parts.gds-code    ,
                       0,
                       buf_wth-parts.beg-dt   ,
                       buf_wth-parts.end-dt   ,
                       buf_wth-parts.vat-pc   ,
                       buf_wth-parts.cli-code  ,
                       buf_wth-parts.cli-type  ,
                       buf_wth-parts.out-obj-code  ,
                       buf_wth-parts.out-obj-type  ,
                       buf_wth-parts.sale-obj-code ,
                       buf_wth-parts.sale-obj-type ,
                       buf_out_wth-doc.doc-code ,
                       yes,
                       buf_out_wth-doc.doc-type ,
                      input-output varparts-rec
                    ) no-error.

          if error-status:error then do:
            undo _main, return error return-value + {&new-line} + error-status:get-message(1).
          end.
        end.
        is-parts = yes.
      end.  /*parts*/
      create tt-par-dtl.
      buffer-copy buf_wth-dtl to tt-par-dtl.
      assign
          tt-par-dtl.doc-code = buf_out_wth-doc.doc-code
          tt-par-dtl.w-p-code = buf_wth-line.out-code
          tt-par-dtl.par-rate = buf_wth-par.par-rate
      .
      if is-parts then do:
        { str/dtlsum.i tt-par-dtl buf_wth-parts }
      end.
      else if buf_out_wth-doc.doc-type = {&return} then do:
        tt-par-dtl.doc-sum = tt-par-dtl.doc-sum - tt-par-dtl.fact-sum.
        tt-par-dtl.fact-sum = tt-par-dtl.doc-sum.
      end.
      is-dtl = yes.
    end.
/*т.к. пока внутреннее перемещение только для сериных МЦ, то если создаем возврат и линия нулевая получается, то не создаем линию */
/* if  buf_wth-doc.doc-type = {&return} then do: */

    create tt-wth-line.
    buffer-copy buf_wth-line to tt-wth-line.
    assign
      tt-wth-line.doc-code = buf_out_wth-doc.doc-code
      tt-wth-line.w-p-code = buf_wth-line.out-code
      tt-wth-line.out-code = buf_wth-line.w-p-code
      .
      if is-dtl then do:
        { str/wthlnsum.i tt-wth-line tt-par-dtl}
      end.
      else if buf_out_wth-doc.doc-type = {&return} then do:
        tt-wth-line.doc-sum = tt-wth-line.doc-sum - tt-wth-line.fact-sum.
        tt-wth-line.fact-sum = tt-wth-line.doc-sum  .
      end.

     run str/wth-lnc1.p (input-output varline-rec,
                  input  {&add-def},
                  no,
                  buf_out_wth-doc.doc-code,
                  buf_wth-line.wth-code,
                  buf_wth-line.out-code,
                  buf_wth-line.w-p-code,
                  tt-wth-line.doc-sum,
                  tt-wth-line.fact-sum,
                  input table tt-par-dtl,
                  no  ,
                  buf_wth-line.ext-doc-type,
                  input tt-wth-line.sum-gds-rubl,
                  input tt-wth-line.sum-gds-base
                  ) no-error .
    if error-status:error then dO:
      undo _main, return error 'Ошибка при создании линии  ' + return-value + {&new-line} + error-status:get-message(1) .
    end.
  END.

end. /*DO*/