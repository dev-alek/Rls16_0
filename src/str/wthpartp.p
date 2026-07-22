block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: wthpartp.p $
$Archive: str/wthpartp.p $

Сохранение партии МЦ

Автор: Гридчина Полина Дмитриевна
Дата создания: 01/07/07
Author: Polina Gridchina
Creation date: 01/07/07

*/

define input parameter    p-mode            AS   character NO-UNDO.
define input PARAMETER    p-obj-type        LIKE ub.wth-parts.obj-type.       /*Перечислимый тип объекта учета товара: склад, магазин*/
define input PARAMETER    p-obj-code        LIKE ub.wth-parts.obj-code.       /*Код объекта - уникальный внутри конкретного справочника*/
define input parameter    p-w-p-code        LIKE ub.wth-parts.w-p-code.       /*Код места хранения мат. ценности*/
define input parameter    p-wth-code        LIKE ub.wth-parts.wth-code.       /*Код мат.ценности*/
define input parameter    p-par-code        LIKE ub.wth-parts.par-code.       /*уникальный код номинала МЦ*/
define input parameter    p-in-code         LIKE ub.wth-parts.in-code .       /*накладная порождения партии*/
define input parameter    p-out-code        LIKE ub.wth-parts.out-code.       /*накладная или зона принадлежности*/
define input parameter    p-ser-code        LIKE ub.wth-parts.ser-code.       /*Внутренний код серии*/
define input parameter    p-db-num          LIKE ub.wth-parts.db-num  .       /*Номер БД: 0 -- главная, > 0 -- удаленные*/
define input parameter    p-Fact-RangeFrom  LIKE ub.wth-parts.Fact-RangeFrom. /*Начало диапазона фактическое*/
define input parameter    p-Fact-RangeTo    LIKE ub.wth-parts.Fact-RangeTo.   /*конец диапазона фактическое*/
define input parameter    p-Doc-RangeFrom   LIKE ub.wth-parts.doc-RangeFrom.  /*Начало диапазона заявленное*/
define input parameter    p-Doc-RangeTo     LIKE ub.wth-parts.doc-RangeTo.    /*конец диапазона заявленное*/
define input parameter    p-host-code       LIKE ub.wth-parts.host-code  .    /*Код объекта - уникальный внутри конкретного справочника*/
define input parameter    p-contract-code   LIKE ub.wth-parts.contract-code.  /*Уникальный номер, формируется автоматически, включает host-code, sequence в пределах фирмы*/
define input parameter    p-price-rubl      LIKE ub.wth-parts.price-rubl .    /*средняя цена по связанным товарам в рублях в ценах покупателя*/
define input parameter    p-price-base      LIKE ub.wth-parts.price-base .    /*средняя цена по связанным товарам в базовой валюте в ценах покупателя.*/
define input parameter    p-supp-type       LIKE ub.wth-parts.supp-type  .    /*Перечислимый тип объекта учета товара: склад, магазин, физ. лицо и т.д.*/
define input parameter    p-supp-code       LIKE ub.wth-parts.supp-code  .    /*Код поставщика начального приобретения - уникальный внутри конкретного справочника*/
define input parameter    p-in-obj-type     LIKE ub.wth-parts.in-obj-type.    /*тип объекта начального приобретения*/
define input parameter    p-in-obj-code     LIKE ub.wth-parts.in-obj-code.    /*код объекта начального приобретения*/
define input parameter    p-ext-doc-type    LIKE ub.wth-parts.ext-doc-type.   /*Расширенный тип документа*/
define input parameter    p-gds-code        LIKE ub.wth-parts.gds-code   .    /*уникальный код товара*/
define input parameter    p-stts            LIKE ub.wth-parts.stts       .    /*Статус*/
define input parameter    p-beg-dt          LIKE ub.wth-parts.beg-dt     .    /*Дата начала срока годности МЦ*/
define input parameter    p-end-dt          LIKE ub.wth-parts.end-dt     .    /*Дата окончания срока дествия*/
define input parameter    p-vat-pc          LIKE ub.wth-parts.vat-pc     .    /*НДС*/
define input parameter    p-cli-code        LIKE ub.wth-parts.cli-code   .    /*Код Покупателя - уникальный внутри конкретного справочника*/
define input parameter    p-cli-type        LIKE ub.wth-parts.cli-type   .    /*Перечислимый тип : организация, физ. лицо и т.д.*/
define input parameter    p-out-obj-code    LIKE ub.wth-parts.out-obj-code.   /*код объекта погашения*/
define input parameter    p-out-obj-type    LIKE ub.wth-parts.out-obj-type.   /*тип объекта погашения*/
define input parameter    p-sale-obj-code   LIKE ub.wth-parts.sale-obj-code.  /*код объекта реализации*/
define input parameter    p-sale-obj-type   LIKE ub.wth-parts.sale-obj-type.  /*тип объекта реализации*/
define input parameter    p-doc-code        LIKE ub.wth-parts.doc-code.
define input parameter    p-silent          as logical   no-undo .
define input parameter    p-type            LIKE ub.wth-parts.type.
define input-output parameter p-rec         as recid     no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wthpartp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/wthpartp.p $":U .
define variable vss-description as character no-undo init "Сохранение партии МЦ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/trg-def.i  }

DEFINE BUFFER buf_wth-parts FOR ub.wth-parts.
define buffer buf_wealth    for ub.wealth.
define buffer buf_wth-par   for ub.wth-par.
define buffer buf_wth-doc   for ub.wth-doc.
define buffer buf_wth-gds   for ub.wth-gds.
define buffer b_wth-parts   for ub.wth-parts.
define variable v-mess    as character    no-undo.
if p-mode  = {&add-def} then p-rec = ?.
  if p-wth-code > 0 then.
  else do:
      v-mess =  "Не указан код МЦ" .
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'wth-code':U).
    /*RETURN ERROR   "Не указан код МЦ" . */
  end.
  if p-doc-RangeTo - p-doc-RangeFrom + 1 > 0 THEN.
  else do:
        v-mess =  "Некорректно указаны фактические границы диапазона" .
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'doc-RangeFrom':U).

   /* RETURN ERROR  "Некорректно указаны границы диапазона" .*/
  end.
  if p-fact-RangeTo - p-fact-RangeFrom + 1 > 0 THEN.
  else do:
        v-mess =  "Некорректно указаны границы диапазона" .
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'fact-RangeFrom':U).

   /* RETURN ERROR  "Некорректно указаны границы диапазона" .*/
  end.
  if p-doc-rangeFrom > p-fact-rangeFrom
      or p-doc-rangeTo   < p-fact-rangeTo  then do:
    v-mess =  substitute('Нельзя увеличивать границы диапазона.&1Диапазон партии &2-&3.',{&new-line},p-doc-rangeFrom,p-doc-rangeTo).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'fact-RangeFrom':U).
  end.

  if p-ser-code > 0 then.
  else do:
          v-mess =  "Не указана серия МЦ" .
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'ser-code':U).

   /* RETURN ERROR  "Не указана серия МЦ" . */
  end.
  find first buf_wealth no-lock where
          buf_wealth.wth-code = p-wth-code no-error .
  if not available buf_wealth then do:
        v-mess = substitute("Не найдена МЦ &1!",p-wth-code).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'wth-code':U).

    /*RETURN ERROR  substitute("Не найдена МЦ &1!",p-wth-code).  */
  end.

  if p-par-code > 0 then.
  else do:
          v-mess =  "Не указан код номинала МЦ" .
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'par-code':U).

  /*  RETURN ERROR  "Не указан код номинала МЦ" .  */
  end.
  find first buf_wth-par no-lock where
          buf_wth-par.par-code = p-par-code
          and buf_wth-par.wth-code = p-wth-code no-error .
  if not available buf_wth-par then do:
    v-mess =   substitute("Не найден номинал МЦ с кодом &1 и кодом МЦ &2!",p-par-code,p-wth-code).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'par-code':U).

    /*RETURN ERROR  substitute("Не найден номинал МЦ с кодом &1 и кодом МЦ &2!",p-par-code,p-wth-code).     */
  end.

  IF LOOKUP(p-out-code, {&WDEDT_List-Zone}) = 0 THEN DO:
      find first buf_wth-doc no-lock where
              buf_wth-doc.doc-code = p-out-code no-error .
      if not available buf_wth-doc then do:
        v-mess =  substitute("Не найден Документ МЦ с кодом &1 !",p-out-code).
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else 'out-code':U).

     /*   RETURN ERROR  substitute("Не найден Документ МЦ с кодом &1 !",p-out-code).      */
      end.
  END.
  else do:
      find first buf_wth-doc no-lock where
              buf_wth-doc.doc-code = p-doc-code no-error .
  end.
  find first buf_wth-gds no-lock where
          buf_wth-gds.wth-code = p-wth-code
      and buf_wth-gds.gds-code = p-gds-code no-error .
  if not available buf_wth-gds then do:
        v-mess =  substitute("Не найдена Связка товара &2 c МЦ с кодом &1 !",p-wth-code,p-gds-code).
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else 'gds-code':U).

    /*RETURN ERROR  substitute("Не найден Связка товара &2 c МЦ с кодом &1 !",p-wth-code,p-gds-code). */
  end.
  if p-beg-dt <> ? and p-end-dt <> ? and p-beg-dt > p-end-dt then do:
        v-mess =  substitute('Неверно указан срок действия партии: &1 - &2!',p-beg-dt,p-end-dt).
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else 'beg-dt':U).
  end.
 if p-mode = {&update}
 then do:
    FIND FIRST buf_wth-parts no-LOCK WHERE recid(buf_wth-parts) = p-rec  no-error.
    if not available buf_wth-parts then return error substitute('Неверно указаны параметры. Не найдена партия с recid &1',p-rec).
    if buf_wth-parts.ser-code = p-ser-code and buf_wth-parts.db-num = p-db-num then.
    else do:
            v-mess =  substitute("Нельзя изменить код Серии или № БД в партии МЦ &1" +
                               "старый код серии - &2 № БД - &3"
                               ,{&new-line}
                               , buf_wth-parts.ser-code
                               , buf_wth-parts.db-num).
.
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else 'gds-code':U).

/*          RETURN ERROR substitute("Нельзя изменить код Серии или № БД в партии МЦ &1" +
                               "старый код серии - &2 № БД - &3"
                               ,{&new-line}
                               , buf_wth-parts.ser-code
                               , buf_wth-parts.db-num).   */

    end.
 end.

 find first b_wth-parts no-lock where
                 b_wth-parts.obj-type = p-obj-type
             and b_wth-parts.obj-code = p-obj-code
             and b_wth-parts.w-p-code = p-w-p-code
             and b_wth-parts.wth-code = p-wth-code
             and b_wth-parts.par-code = p-par-code
             and ((buf_wth-doc.ext-doc-type <> {&WDEDT_Inc_Ext} and b_wth-parts.in-code  = p-in-code)
                  or   buf_wth-doc.ext-doc-type = {&WDEDT_Inc_Ext})
             and b_wth-parts.out-code = p-out-code
             and b_wth-parts.ser-code = p-ser-code
             and b_wth-parts.db-num   = p-db-num
             and ((b_wth-parts.fact-rangeFrom <= p-fact-rangeFrom
                     and b_wth-parts.fact-rangeTo >= p-fact-rangeFrom )
                  or (b_wth-parts.fact-rangeFrom <= p-fact-rangeTo
                      and b_wth-parts.fact-rangeTo >= p-fact-rangeTo )
                  or (b_wth-parts.fact-rangeFrom >= p-fact-rangeFrom
                      and b_wth-parts.fact-rangeTo <= p-fact-rangeTo )
                  )
             and recid(b_wth-parts) <> p-rec
             no-error.
   if available b_wth-parts then do:
    if g#news /*and ( p-out-code = {&put-zone} )*/ then  do:
    p-in-code = p-in-code + {&forged}.
    end.
    else do:
        v-mess =  substitute('Существует партия с пересекающимся диапазоном. &1 Указанный диапазон: &2 - &3&1Диапазон существующей партии: &4 - &5&1
                             документ порождения - &6 &1
                             документ/зона - &7' ,
                            {&new-line}
                            ,p-fact-rangeFrom
                            ,p-fact-rangeTo
                            ,b_wth-parts.fact-rangeFrom
                            ,b_wth-parts.fact-rangeTo
                            ,p-in-code
                            ,p-out-code) .
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else 'fact-rangeFrom':U).
    end.
/*    return error substitute('Существует партия с пересекающимся диапазоном. &1&1 Указанный диапазон: &2 - &3&1Диапазон существующей партии: &4 - &5',
                            {&new-line}
                            ,p-fact-rangeFrom
                            ,p-fact-rangeTo
                            ,b_wth-parts.fact-rangeFrom
                            ,b_wth-parts.fact-rangeTo
                            )  .    */
   end.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

IF p-mode = {&add-def} THEN DO:
    create buf_wth-parts.
END.
ELSE DO:
    FIND FIRST buf_wth-parts WHERE recid(buf_wth-parts) = p-rec EXCLUSIVE-LOCK.
END.

    assign
        buf_wth-parts.obj-type        =   p-obj-type
        buf_wth-parts.obj-code        =   p-obj-code
        buf_wth-parts.w-p-code        =   p-w-p-code
        buf_wth-parts.wth-code        =   p-wth-code
        buf_wth-parts.par-code        =   p-par-code
        buf_wth-parts.in-code         =   p-in-code
        buf_wth-parts.out-code        =   p-out-code
        buf_wth-parts.ser-code        =   p-ser-code
        buf_wth-parts.db-num          =   p-db-num
        buf_wth-parts.Fact-RangeFrom  =   p-Fact-RangeFrom
        buf_wth-parts.Fact-RangeTo    =   p-Fact-RangeTo
        buf_wth-parts.doc-RangeFrom   =   p-Doc-RangeFrom
        buf_wth-parts.doc-RangeTo     =   p-Doc-RangeTo
        buf_wth-parts.host-code       =   p-host-code
        buf_wth-parts.contract-code   =   p-contract-code
        buf_wth-parts.price-rubl      =   IF p-price-rubl = ? THEN 0 ELSE p-price-rubl
        buf_wth-parts.price-base      =   IF p-price-base = ? THEN 0 ELSE p-price-base
        buf_wth-parts.supp-type       =   p-supp-type
        buf_wth-parts.supp-code       =   p-supp-code
        buf_wth-parts.in-obj-type     =   p-in-obj-type
        buf_wth-parts.in-obj-code     =   p-in-obj-code
        buf_wth-parts.ext-doc-type    =   p-ext-doc-type
        buf_wth-parts.gds-code        =   p-gds-code
        buf_wth-parts.stts            =   p-stts
        buf_wth-parts.beg-dt          =   p-beg-dt
        buf_wth-parts.end-dt          =   p-end-dt
        buf_wth-parts.vat-pc          =   p-vat-pc
        buf_wth-parts.cli-code        =   p-cli-code
        buf_wth-parts.cli-type        =   p-cli-type
        buf_wth-parts.out-obj-code    =   p-out-obj-code
        buf_wth-parts.out-obj-type    =   p-out-obj-type
        buf_wth-parts.sale-obj-code   =   p-sale-obj-code
        buf_wth-parts.sale-obj-type   =   p-sale-obj-type
        buf_wth-parts.doc-code        =   p-doc-code
        buf_wth-parts.type            =   p-type
       .

        if available buf_wth-doc then do:
        assign
          buf_wth-parts.fact-date       =   buf_wth-doc.fact-date
          buf_wth-parts.fact-num        =   buf_wth-doc.fact-num
          buf_wth-parts.fact-order      =   buf_wth-doc.fact-order
          buf_wth-parts.shift-num       =   buf_wth-doc.shift-num
          buf_wth-parts.shift-date      =   buf_wth-doc.shift-date
          buf_wth-parts.ext-doc-type    =   buf_wth-doc.ext-doc-type
        /*  buf_wth-parts.contract-code   =   buf_wth-doc.contract-code    */

        .
        IF LOOKUP(p-out-code, {&WDEDT_List-Zone}) = 0 THEN
        case buf_wth-doc.ext-doc-type:
          when {&WDEDT_Inc_Ext} then assign
                                    buf_wth-parts.in-obj-type     =   buf_wth-doc.obj-type
                                    buf_wth-parts.in-obj-code     =   buf_wth-doc.obj-code
                                    buf_wth-parts.supp-type       =   buf_wth-doc.cli-type
                                    buf_wth-parts.supp-code       =   buf_wth-doc.cli-code
                                    buf_wth-parts.in-code         =   buf_wth-doc.doc-code
                                           .
          when {&WDEDT_Exp_Ext} then assign
                  buf_wth-parts.cli-code        =   buf_wth-doc.cli-code
                  buf_wth-parts.cli-type        =   buf_wth-doc.cli-type
                  buf_wth-parts.sale-obj-code   =   buf_wth-doc.obj-code
                  buf_wth-parts.sale-obj-type   =   buf_wth-doc.obj-type
                 .
          when {&WDEDT_Put_Cash} or when {&WDEDT_Put_Cli} then assign
                  buf_wth-parts.out-obj-code   =   buf_wth-doc.obj-code
                  buf_wth-parts.out-obj-type   =   buf_wth-doc.obj-type
                 .
          when {&WDEDT_Put_Sale} then assign
                  buf_wth-parts.out-obj-code   =   buf_wth-doc.cli-code
                  buf_wth-parts.out-obj-type   =   buf_wth-doc.cli-type
                 .
          when {&WDEDT_Exch}  then do:
             if buf_wth-parts.type = {&income} then assign
                  buf_wth-parts.out-obj-code   =   buf_wth-doc.obj-code
                  buf_wth-parts.out-obj-type   =   buf_wth-doc.obj-type
                 .
             else assign
                  buf_wth-parts.cli-code        =   buf_wth-doc.cli-code
                  buf_wth-parts.cli-type        =   buf_wth-doc.cli-type
                  buf_wth-parts.sale-obj-code   =   buf_wth-doc.obj-code
                  buf_wth-parts.sale-obj-type   =   buf_wth-doc.obj-type
                 .

          end.
        end case.
      end.
      case buf_wth-parts.out-code:
        when {&free-code} then assign
                  buf_wth-parts.cli-code        =   0
                  buf_wth-parts.cli-type        =   '':U
                  buf_wth-parts.sale-obj-code   =   0
                  buf_wth-parts.sale-obj-type   =   '':U
                  buf_wth-parts.out-obj-code    =   0
                  buf_wth-parts.out-obj-type    =   '':U
                  buf_wth-parts.beg-dt          = ?
                  buf_wth-parts.end-dt          = ?
                  buf_wth-parts.price-rubl      = 0
                  buf_wth-parts.price-base      = 0
                  .
        when {&cli-zone} then assign
                  buf_wth-parts.out-obj-code    =   0
                  buf_wth-parts.out-obj-type    =   '':U
                  buf_wth-parts.obj-code        = buf_wth-parts.cli-code
                  buf_wth-parts.obj-type        = buf_wth-parts.cli-type
                  buf_wth-parts.w-p-code        = 0
           .
      end case. /*out-code*/
      /*Соединяем партии по pi */
      find first b_wth-parts no-lock where
                 b_wth-parts.obj-type = buf_wth-parts.obj-type
             and b_wth-parts.obj-code = buf_wth-parts.obj-code
             and b_wth-parts.w-p-code = buf_wth-parts.w-p-code
             and b_wth-parts.wth-code = buf_wth-parts.wth-code
             and b_wth-parts.par-code = buf_wth-parts.par-code
             and b_wth-parts.in-code  = buf_wth-parts.in-code
             and b_wth-parts.out-code = buf_wth-parts.out-code
             and b_wth-parts.ser-code = buf_wth-parts.ser-code
             and b_wth-parts.db-num   = buf_wth-parts.db-num
             and b_wth-parts.stts   = buf_wth-parts.stts
             and b_wth-parts.fact-rangeTo = buf_wth-parts.fact-rangeFrom - 1
             /*and b_wth-parts.fact-rangeFrom < buf_wth-parts.fact-rangeFrom   */
              and b_wth-parts.doc-code = buf_wth-parts.doc-code

                                    no-error.
      if available b_wth-parts then do:
        find current b_wth-parts exclusive-lock.
        assign
        buf_wth-parts.fact-rangeFrom =  b_wth-parts.fact-rangeFrom
        buf_wth-parts.doc-rangeFrom =  b_wth-parts.doc-rangeFrom
        .
        delete b_wth-parts no-error.
        if error-status:error then undo, return error return-value.
      end.
      find first b_wth-parts exclusive-lock where
                 b_wth-parts.obj-type = buf_wth-parts.obj-type
             and b_wth-parts.obj-code = buf_wth-parts.obj-code
             and b_wth-parts.w-p-code = buf_wth-parts.w-p-code
             and b_wth-parts.wth-code = buf_wth-parts.wth-code
             and b_wth-parts.par-code = buf_wth-parts.par-code
             and b_wth-parts.in-code  = buf_wth-parts.in-code
             and b_wth-parts.out-code = buf_wth-parts.out-code
             and b_wth-parts.doc-code = buf_wth-parts.doc-code
             and b_wth-parts.ser-code = buf_wth-parts.ser-code
             and b_wth-parts.db-num   = buf_wth-parts.db-num
             and b_wth-parts.stts   = buf_wth-parts.stts
             and b_wth-parts.fact-rangeFrom = buf_wth-parts.fact-rangeTo + 1
             and b_wth-parts.fact-rangeTo >= buf_wth-parts.fact-rangeTo + 1
             no-error.
      if available b_wth-parts then do:
      assign
        buf_wth-parts.fact-rangeTo =  b_wth-parts.fact-rangeTo
        buf_wth-parts.doc-rangeTo =  b_wth-parts.doc-rangeTo
        .
        delete b_wth-parts no-error.
        if error-status:error then undo, return error return-value.
      end.
    assign
     buf_wth-parts.fact-qnty       =  buf_wth-parts.fact-rangeTo - buf_wth-parts.fact-RangeFrom + 1
     buf_wth-parts.qnty-doc        =  buf_wth-parts.doc-rangeTo  - buf_wth-parts.doc-RangeFrom  + 1
     .

    p-rec = RECID (buf_wth-parts).
end.
PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Партия МЦ: Код серии &1-&2 Код МЦ &4 Диапазон &5 - &6&3&7"
                         , p-ser-code
                         , p-db-num
                         , {&new-line}
                         , p-wth-code
                         , p-Fact-RangeFrom
                         , p-Fact-RangeTo
                         , p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.