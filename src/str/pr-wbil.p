block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: pr-wbil.p $
$Archive: str/pr-wbil.p $

Методы расчета переоценки

Автор: Чернова Светлана Александровна
Дата создания: 09/13/05
Author: Svetlana Chernova
Creation date: 09/13/05

11/06/03 1:49

Методы расчета переоценки

pr-calc-wbill
pr-calc-slt-wbill
*/

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: pr-wbil.p $":U .
def var vss-archive     as character no-undo init "$Archive: str/pr-wbil.p $":U .
def var vss-description as character no-undo init "Методы расчета переоценки".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/cont-ms-def.i }

define input parameter  p-type          as character no-undo .
define input parameter  p-met           as character no-undo .
define input parameter  rec-id-trn-doc  as recid no-undo .
define input parameter  rec-id-doc-line as recid no-undo .
define input parameter  rec-id-gds-dtl  as recid no-undo .
define input parameter  doc-code     as character no-undo .
define input parameter  v-gds-name   as character no-undo .
define input parameter  v-gds-code   as integer no-undo .
define input parameter  v-artic      as character no-undo .
define input parameter  v-prod-type  as character no-undo .
define input parameter  v-prod-code  as integer no-undo .
define input parameter  v-node-code  as integer no-undo .
define input parameter  p-pc         as decimal no-undo .
define input  parameter p-doc-price-rubl as decimal   no-undo . /* когда документ не создан */
define input  parameter p-doc-price-base as decimal   no-undo . /* когда документ не создан */
define output parameter v-price-calc as decimal no-undo .
define output parameter v-price-sale as decimal no-undo .

define variable var-pr-r-b as character no-undo .
{ gbl/curr-r-b.i  var-pr-r-b }
define variable g#log as logical   no-undo .

find first trn-doc no-lock where recid(trn-doc) = rec-id-trn-doc no-error .

if p-met = {&pr-calc-slt-wbill} then do:
   { gbl/pftxvalg.i v-gds-code {&slt-tax-code} ? trn-doc.host-code trn-doc.obj-type trn-doc.obj-code p-pc no-error }
end.

 if p-type = "pr-doc" then do:
       /* при вызове из интерфейса переоценки нужно искать исходную цену */
      if available trn-doc then do:
        if trn-doc.doc-type = {&income} and
         ( trn-doc.ext-doc-type = {&tdedt_pri_vnesh} /* or
           trn-doc.ext-doc-type = {&tdedt_pri_prvo}*/ ) then do:
          /* при внешнем приходе и производстве считаем от учетных цен */
          find doc-line where doc-line.doc-code = doc-code
                          and doc-line.artic     = v-artic
                          and doc-line.prod-type = v-prod-type
                          and doc-line.prod-code = v-prod-code no-lock no-error.
                if available doc-line then
                  assign
                    v-price-calc =  if var-pr-r-b = "rubl"  then doc-line.price-rubl else doc-line.price-base
                    v-price-sale =  v-price-calc * (1 + p-pc / 100)
                    .
                else
                  message "Нет строки в накладной :" doc-code "для товара :" v-artic  v-gds-name
                          "- расчет невозможен."
                          view-as alert-box question buttons OK-Cancel update g#log.
        end.
        else do:
          find gds-dtl where gds-dtl.doc-code  = doc-code
                         and gds-dtl.artic     =  v-artic
                         and gds-dtl.prod-type =  v-prod-type
                         and gds-dtl.prod-code =  v-prod-code
                         and gds-dtl.prt-code  =  v-node-code no-lock no-error.
          if not available gds-dtl then
            /* признак, точно соответствующий переоценке, в накладной не найден */
            find first gds-dtl where gds-dtl.doc-code = doc-code
                                 and gds-dtl.artic =  v-artic
                                 and gds-dtl.prod-type =  v-prod-type
                                 and gds-dtl.prod-code =  v-prod-code no-lock no-error.
          if available gds-dtl then
            assign
               v-price-calc = if var-pr-r-b = "rubl"  then gds-dtl.price-rubl else gds-dtl.price-base
               v-price-sale = v-price-calc * (1 + p-pc / 100)
              .
          else
            message "Нет строки в накладной :" doc-code "для товара :" v-artic v-gds-name
                    "- расчет невозможен."
                    view-as alert-box question buttons OK-Cancel update g#log.
        end.
      end.
      else
        message "Не прочитана накладная с номером" doc-code
                "- расчет невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.

 end.

 else do:

 /* при вызове из автомат переоценки (in-pr .p) все исходные цены должны быть */

/* bonus */
 define variable v-bonus as decimal   no-undo .
 v-bonus = 0.0 .

 define buffer buf_contract-specif-attr for ub.contract-specif-attr  .
 define buffer buf_goods for ub.goods  .

find first buf_goods no-lock where
           buf_goods.artic  =  v-artic and
           buf_goods.prod-type =  v-prod-type and
           buf_goods.prod-code =  v-prod-code no-error .
/*
    find first buf_contract-specif-attr no-lock where
              buf_contract-specif-attr.attr-code    = {&contract-specif-bonus}    and
              buf_contract-specif-attr.contract-num = trn-doc.contract-code  and
              buf_contract-specif-attr.host-code    = trn-doc.host-code  and
              buf_contract-specif-attr.gds-code     = buf_goods.gds-code no-error .
*/
    {str/cont-slave-inc.i
         &FIND_FIRST = YES
         &BUFFER_SPECIF     =  buf_contract-specif-attr
         &P_HOST_CODE       =  trn-doc.host-code
         &P_CONTRACT_NUM    =  trn-doc.contract-code
         &P_GDS_CODE        =  buf_goods.gds-code
         &P_ATTR_CODE       =  {&contract-specif-bonus}
         &NO_LOCK=YES
         &NO_ERROR=YES
    }

    if available buf_contract-specif-attr
       then v-bonus = decimal (buf_contract-specif-attr.attr-value) .
       else v-bonus = 0.0 .

      if trn-doc.doc-type = {&income} and
         ( trn-doc.ext-doc-type = {&tdedt_pri_vnesh} /* or
           trn-doc.ext-doc-type = {&tdedt_pri_prvo}*/  ) then do:
        /* при внешнем приходе  */
        find first doc-line no-lock where recid(doc-line) = rec-id-doc-line no-error .

        if available doc-line    then
            assign
              v-price-calc =  if var-pr-r-b = "rubl"  then doc-line.price-rubl else doc-line.price-base
              v-price-sale = v-price-calc * (1 + v-bonus / 100) * (1 + p-pc / 100)
              .
            else
            assign
              v-price-calc =  if var-pr-r-b = "rubl"  then p-doc-price-rubl else p-doc-price-base
              v-price-sale = v-price-calc * (1 + v-bonus / 100) * (1 + p-pc / 100)
              .
      end.
      else do:
          find first gds-dtl no-lock where recid(gds-dtl) = rec-id-gds-dtl no-error .
          if available gds-dtl then
            assign
              v-price-calc =  if var-pr-r-b = "rubl"  then gds-dtl.price-rubl else gds-dtl.price-base
              v-price-sale = v-price-calc * (1 + v-bonus / 100) * (1 + p-pc / 100)
              .
            else
            assign
              v-price-calc =  if var-pr-r-b = "rubl"  then p-doc-price-rubl else p-doc-price-base
              v-price-sale = v-price-calc * (1 + v-bonus / 100) * (1 + p-pc / 100)
              .
     end.
 end.
 /* message v-price-calc  skip v-price-sale. */