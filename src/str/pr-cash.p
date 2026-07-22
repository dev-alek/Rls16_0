block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: pr-cash.p $
$Archive: str/pr-cash.p $

Проверки и взаимодействие с кассой при закрытии переоценки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/15/05
Author: Bakhtadze Natalya
Creation date: 12/15/05

*/

define input parameter parparentproc           as   widget-handle no-undo .
define input parameter p-new-price-doc-status_ like ub.price-doc.status_ no-undo .
define input parameter p-doc-num               like ub.price-doc.doc-num no-undo .
define input parameter p-obj-type              like ub.price-doc.obj-type no-undo .
define input parameter p-obj-code              like ub.price-doc.obj-code no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pr-cash.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/pr-cash.p $":U .
define variable vss-description as character no-undo init "Проверки и взаимодействие с кассой при закрытии переоценки".
{ cmp/vssrevis.i "substitute('&1|&2',p-new-price-doc-status_,p-doc-num)"}
{ cmp/trg-def.i }
{ cmp/library.i }

define variable v-mes as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .


if p-obj-type <> {&shop} then do:
  return . /* --->>>--- */
end.

run adm/shattri.p (
     input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  {&attr-autosale}
    ,input  {&attr-autosale_prcl-spl} /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
if error-status:error then do:
  delete object v-tth.
  return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
end.
delete object v-tth.
if v-value-logical <> yes then do:
  return.
end.

run str/diallog.w (  input parparentproc
              , input this-procedure
              , input ('str/get-chkf.p':U + {&delim-par} + string(0) + {&delim-par} + string(1) + {&delim-par} + string(1))
              , input (p-obj-type + {&delim-par} + string(p-obj-code) + {&delim-par} + string(0))
              , input yes /*p-auto-go*/
              , input '':U
              , input 'Прием чеков с касс') no-error .


if error-status:error then return error.

find ub.price-doc no-lock
  where ub.price-doc.doc-num = p-doc-num
  .

define buffer buf_bar-code for ub.bar-code .

for each ub.price-list no-lock
  where ub.price-list.doc-num = ub.price-doc.doc-num
,first buf_bar-code no-lock
  where buf_bar-code.b-code = ub.price-list.b-code
:
   /*если это не main-price то не сравниваем - потому что наличие корня уже достаточно для остановки работы */
   if not ub.price-list.main-price then NEXT.
  /* ищем чеки, мешающие переоценке */
  _chk-doc:
  FOR EACH ub.chk-doc No-lock
    where ub.chk-doc.obj-type = ub.price-list.obj-type
      AND ub.chk-doc.obj-code = ub.price-list.obj-code
      AND ub.chk-doc.out-code = ?,
          EACH  ub.chk-gds where
                ub.chk-gds.doc-code = ub.chk-doc.doc-code,
          FIRST ub.bar-code where
                ub.bar-code.b-code = ub.chk-gds.b-code no-lock :
    if lookup(string(ub.chk-doc.chk-type), {&no-docum-receipt-codes}) > 0
    or lookup(string(ub.chk-doc.chk-type), {&no-inkas-receipt-codes}) > 0
    then next _chk-doc.
    if ub.bar-code.gds-code = buf_bar-code.gds-code then do:
      assign
      v-mes = substitute("Найден неучтенный чек №  &1 от &2,&3"  +
                          "содержащий переоцениваемый товар: &4 бар-код: &5&3&3" +
                          "В соответствии с настройкой  <Значение цены в продаже брать из прайс-листа>&3" +
                          "требуется закрыть продажу с этим чеком до переоценки."
                          ,ub.chk-doc.doc-code
                          ,ub.chk-doc.chk-date
                          ,{&new-line}
                          , substitute("&1 &2 &3"
                                      , ub.price-list.artic
                                      , ub.price-list.prod-type
                                      , ub.price-list.prod-code)
                          , ub.chk-gds.b-code ).
      if not g#auto then do:
        message v-mes
        view-as alert-box.
        return error .
      end.
      else do:
        return error v-mes.
      end.
    end.
  END.
  /* ищем открытую продажу */
  for each ub.inkas where ub.inkas.obj-type = p-obj-type and
                         ub.inkas.obj-code = p-obj-code and
                         ub.inkas.status_ = {&g___new},
      EACH ub.chk-gds  NO-LOCK where
             ub.chk-gds.out-code = ub.inkas.inkas-code,
        FIRST ub.bar-code No-LOCK where
              ub.bar-code.b-code = ub.chk-gds.b-code:
      IF ub.bar-code.gds-code = buf_bar-code.gds-code then do:
        find ub.chk-doc where ub.chk-doc.doc-code = ub.chk-gds.doc-code no-lock.
        v-mes = substitute("Найден чек № &1, входящий в продажу № &2,&3"  +
                           "содержащий переоцениваемый товар: &4 бар-код:&3&3" +
                           "В соответствии с настройкой  <Значение цены в продаже брать из прайс-листа>&3" +
                           "требуется закрыть продажу с этим чеком до переоценки."
                           ,ub.chk-doc.doc-code
                            ,ub.inkas.inkas-code
                            , {&new-line}
                            ,substitute("&1 &2 &3"
                                        ,ub.price-list.artic
                                        ,ub.price-list.prod-type
                                        ,ub.price-list.prod-code)
                            ,ub.chk-gds.b-code).
        if not g#auto then do:
          message v-mes
          view-as alert-box .
          return error .
        end.
        else do:
          return error v-mes.
         end.
      end.
  end. /*for each inkas*/
end. /*for each price-list*/