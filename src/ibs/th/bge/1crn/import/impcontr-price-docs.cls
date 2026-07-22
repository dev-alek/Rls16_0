/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Класс ипорта данных impcontr-price-docs из 1С

Автор: Александр Морозов
Дата создания: 26/09/17
Author: Morozov Alexandr
Creation date: 26/09/17

*/

using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
USING ibs.th.str.specattr from propath.
USING ibs.th.ref.spegrpmt from propath.

block-level on error undo, throw.

class ibs.th.bge.1crn.import.impcontr-price-docs implements ibs.th.bge.1crn.import.iimpsubject: 
  
  { cmp/str-glbl.i class }
//  { cmp/str-glbl.i }
   
  define variable specattr as class specattr no-undo .   
  define variable spegrpmt as class spegrpmt no-undo . 
   
  define property Msg as character no-undo
    get. 
    set.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):

    define variable v-ContrPrice as class   contr-price-docs            no-undo.
    define variable v-Gds-sale   as class   contr-price-docs_price-list no-undo.
    define variable v_price-list as class   subjects                    no-undo.
    
    define variable v-contr-code as integer no-undo .
    define variable v-gds-code   as integer no-undo .
    define variable v-unit-cli   as character no-undo .
    define variable v-cli-base-rate as decimal no-undo .
    define variable ii           as integer no-undo .
    define variable is-create    as logical no-undo .
    
    define buffer b_contract-specif for ub.contract-specif .
    define buffer b_goods           for ub.goods .
    define buffer buf_contract      for ub.contract .
    
    v-ContrPrice = cast (subjectObj, contr-price-docs).
    assign
      v-contr-code = integer(v-ContrPrice:cont-code)
      v_price-list = v-ContrPrice:price-list
    .
    
    /*Найти договор, к которому относиться спецификация*/
    find first buf_contract no-lock
         where buf_contract.contract-code = v-contr-code
        // and buf_contract.host-code     = v-host-code
      no-error .
    if not AVAILABLE buf_contract then do:
      Msg = "Контракт не найден с кодом:" + v-ContrPrice:cont-code .
      undo, throw new Progress.Lang.AppError(Msg) .
      // return error Msg.
    end.  
 

      if VALID-OBJECT (v_price-list) then 
      do:
        do ii = 1 to v_price-list:Get(ii):
          v-Gds-sale = cast (v_price-list:SubjectObjCurr, contr-price-docs_price-list).
          assign
            v-gds-code = INTEGER (v-Gds-sale:gds-code)
            v-unit-cli =          v-Gds-sale:unit-spl-code
            v-cli-base-rate =     v-Gds-sale:unit-k
          .
          find first b_goods no-lock where b_goods.gds-code = v-gds-code no-error .
          if not AVAILABLE b_goods then do:
            Msg = "Товар не найден с кодом:" + v-Gds-sale:gds-code .
            undo, throw new Progress.Lang.AppError(Msg) .
            // return error Msg.
          end .
          
            find first ub.contract-specif EXCLUSIVE-LOCK
              where ub.contract-specif.host-code    = buf_contract.host-code
              and ub.contract-specif.contract-num = buf_contract.contract-code
              and ub.contract-specif.gds-code     = b_goods.gds-code
              no-error no-wait .
            if locked(ub.contract-specif) then do:
              Msg = substitute("Запись с товаром [&1] в спецификации договора [&2] занята другим пользователем",
                               b_goods.gds-code, buf_contract.contract-code ) .
              undo, throw new Progress.Lang.AppError(Msg) .
            end . 
            if NOT available ub.contract-specif then 
            do:

              create ub.contract-specif .
              assign
                ub.contract-specif.host-code    = buf_contract.host-code
                ub.contract-specif.contract-num = buf_contract.contract-code
                ub.contract-specif.gds-code     = b_goods.gds-code
                .
            end.  
            
            ASSIGN
              UB.contract-specif.gds-name          = b_goods.gds-name
              ub.contract-specif.artic             = b_goods.artic
              ub.contract-specif.prod-type         = b_goods.prod-type
              ub.contract-specif.prod-code         = b_goods.prod-code
              ub.contract-specif.cli-base-rate     = b_goods.cli-base-rate
              ub.contract-specif.price-cli         = v-Gds-sale:price-sale
              ub.contract-specif.unit-base         = b_goods.unit-base
              ub.contract-specif.unit-cli          = if (v-unit-cli > "") then v-unit-cli else b_goods.unit-base
              ub.contract-specif.unit-cli-ord      = b_goods.unit-base
              ub.contract-specif.unit-cli-rcv      = b_goods.unit-base
              ub.contract-specif.cli-base-rate     = if (v-cli-base-rate > 0) then v-cli-base-rate else 1
              ub.contract-specif.cli-base-rate-ord = 1
              ub.contract-specif.cli-base-rate-rcv = 1
              
              ub.contract-specif.VAT-type          = if v-Gds-sale:nds-code = -1 then {&without-VAT} else {&inc-vat}
              ub.contract-specif.VAT-pc            = if v-Gds-sale:nds-code = -1 then 0 else v-Gds-sale:nds-code
              ub.contract-specif.prc               = v-Gds-sale:max-otkl
              ub.contract-specif.db-num            = buf_contract.db-num
              .

            find first ub.contract-specif-attr exclusive-lock  where
              ub.contract-specif-attr.contract-num = buf_contract.contract-code  and
              ub.contract-specif-attr.host-code    = buf_contract.host-code     and
              ub.contract-specif-attr.gds-code     = b_goods.gds-code      and
              ub.contract-specif-attr.attr-code    = {&contract-specif-prc-min}
              no-error .
            if not AVAILABLE (ub.contract-specif-attr) then 
            do:
              create ub.contract-specif-attr .
              assign
                ub.contract-specif-attr.contract-num = buf_contract.contract-code
                ub.contract-specif-attr.host-code    = buf_contract.host-code     
                ub.contract-specif-attr.gds-code     = b_goods.gds-code      
                ub.contract-specif-attr.attr-code    = {&contract-specif-prc-min}
                .
            end.
            ub.contract-specif-attr.attr-value = string(v-Gds-sale:min-otkl) .               

        end.
      end.

  end method.
/* 18/IX-2018 - не используется  
  method private character date-1C (inValue as character):
    
    def var v-str as character no-undo.
    if inValue = "0001-01-01" then v-str = ? .
    else v-str = entry (3, string(inValue), "-") + "/" + entry (2, string(inValue), "-") + "/" + entry (1, string(inValue), "-") .

    return v-str.
    
  end.
*/
end class.