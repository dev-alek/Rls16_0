using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.ref.sobj.sCurrency_trg:
   define property ParamObj as class ibs.th.ref.sobj.sParamObj no-undo
   get.
   set.
   define property ParamForm as class ibs.th.ref.sobj.sParamForm no-undo
   get.
   set.
   define property ObjForm as class ibs.th.ref.sobj.sobj no-undo
   get.
   set.
   define public property stype as class ibs.th.ref.sobj.stype no-undo
   get.
   set.
   constructor public sCurrency_trg (  ):
      super ().
   end constructor.
   destructor public sCurrency_trg ( ):
   end destructor.
   method public void set_SET_PAY_TYPE (iSET_PAY_TYPE as char):
      ParamObj:X-SET_PAY_TYPE   = stype:setPayTypeInt( iSET_PAY_TYPE).
   end method.
   method public void set_SET_val_TYPE (iSET_val_TYPE as char):
      ParamObj:x-SET_val_TYPE   = stype:setvalTypeInt( iSET_val_TYPE).
   end method.
   method public void VALUE-CHANGED_SET_PAY_TYPE (iSET_PAY_TYPE as character  ):
      define variable vSET_PAY_TYPE as integer no-undo.
      set_SET_PAY_TYPE(iSET_PAY_TYPE).
      vSET_PAY_TYPE = stype:setPayTypeInt( iSET_PAY_TYPE).
      new-state ( "SET_PAY_TYPE ="  + String(vSET_PAY_TYPE)).
   end method.
   method public void VALUE-CHANGED_SET_val_TYPE(iSET_val_TYPE as char):
      set_SET_val_TYPE ( iSET_val_TYPE).
      if ParamForm:Verify-Arc-stk
      then do:
         if ParamForm:var-report-r-b = "base"
         then do:
            if     ParamObj:X-SET_val_TYPE = 1
               and ParamObj:my-base-code <> 0
            then message
               "¬ валютной версии программы при базовой валюте, не равной . - " skip
               "в колонках остатки по товару и автоматическа€ переоценка не будет учтена курсова€" skip
               "разница при печати отчета в продажных ценах и . "
               view-as alert-box information title "¬ н и м а н и е".
         end.
         else do:
         end.
      end.
      new-state ("SET_VAL_TYPE="  + String(iSET_val_TYPE)).
   end method.
   method private void new-state(istate as character ):
   end method.
   method public void setShowCost(iarg as logical ):
      ParamObj:Show-Cost = iarg.
   end method.
   method public void setShowCrsa(iarg as logical ):
      ParamObj:Show-Crsa = iarg.
   end method.
   method public void setShowSale(iarg as logical ):
      ParamObj:Show-Sale = iarg.
   end method.
   method public logical set_TextLb (itext as character ):
      paramobj:x-text-Curr = itext.
   end method.
   method public void Assign-frame():
      if ParamForm:temp-param-pay = ""
      then paramobj:strcurr =''.
      else do:
         if      (     ParamObj:x-SET_val_TYPE = 0
                   and Paramobj:my-base-code=0)
              or ParamObj:x-SET_val_TYPE=1
         then  do:
            case ParamObj:X-SET_PAY_TYPE :
               when 1 then paramobj:strcurr = paramobj:x-text-Curr + ": "    +  "в  ценах –≈јЋ»«ј÷»»".
               when 2 then paramobj:strcurr = paramobj:x-text-Curr + ": "    +  "в ”„≈“Ќџ’  ценах".
               when 3 then paramobj:strcurr = paramobj:x-text-Curr + ": "    +  "в  ценах ƒќ ”ћ≈Ќ“ј".
            end case.
         end.
         else  do:
            case ParamObj:X-SET_PAY_TYPE :
               when 1 then paramobj:strcurr = paramobj:x-text-Curr + ": "    +  "в валютных ценах –≈јЋ»«ј÷»»".
               when 2 then paramobj:strcurr = paramobj:x-text-Curr + ": "    +  "в ”„≈“Ќџ’ валютных ценах".
               when 3 then paramobj:strcurr = paramobj:x-text-Curr + ": "    +  "в валютных ценах ƒќ ”ћ≈Ќ“ј".
            end case.
         end.
      end.
   end method.
end class.
