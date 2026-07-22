using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.ref.sobj.sCustomer_trg:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def   temp-table cli-list no-undo like ub.clients
  field to-del as logical
  index obj  is primary unique obj-type obj-code
  index cli-name      obj-name
  .
   define public property stype as class ibs.th.ref.sobj.stype no-undo
   get.
   set.
   define public property ParamObj as class ibs.th.ref.sobj.sParamObj no-undo
   get.
   set.
   define public property ParamForm as class ibs.th.ref.sobj.sParamForm no-undo
   get.
   set.
   constructor public sCustomer_trg (  ):
      super ().
   end constructor.
   destructor public sCustomer_trg ( ):
   end destructor.
   method public character  VALUE-CHANGED_Radio-customer (input-output pRadioCustomer as character ):
      define variable ocustomer-name as character no-undo.
      define variable customer-recids as character no-undo.
      define variable v-ii as integer no-undo.
      define buffer buf_clients for ub.clients.
      define variable vRadioCustomer as integer  no-undo.
      vRadioCustomer = stype:RadioCustomerInt(pRadioCustomer).
      ParamObj:empty-g#customer().
      case vRadioCustomer :
         when 1 then do:
            ocustomer-name = 'все':U.
         end.
         when 2 then do:
            if ParamForm:temp-param-customer-type  = ""
            then
               ParamForm:temp-param-customer-type = 'все':U.
            run str/cli-list_class.p
                         ( ParamObj:my-handle
                         , ParamObj:my-cntxt-host-code-obj
                         , ParamObj:my-cntxt-obj-type
                         , ParamObj:my-cntxt-obj-code
                         ,output table cli-list
                            ) .
            if not can-find (first cli-list no-lock )
            then do:
                 ocustomer-name = 'все':U.
                 pRadiocustomer = stype:RadioCustomerLbl(1).
            end.
            else do:
                ocustomer-name = ''.
                for each cli-list  :
                   ParamObj:create_g#customer(cli-list.obj-type, cli-list.obj-code, cli-list.obj-name).
                    if length (ocustomer-name) >= 10000
                    then do:
                       ocustomer-name = trim(ocustomer-name , '...') .
                       ocustomer-name = ocustomer-name + '...' .
                    end.
                    else ocustomer-name = ocustomer-name + cli-list.obj-name + chr(10).
                end.
            end.
         end.
      end case.
      new-state ("RADIO-CUSTOMER="  + string(vRadiocustomer)).
      return ocustomer-name.
   end method.
   method public logical set_TextLb (itext as character ):
      paramobj:x-text-cust = itext.
   end method.
   method public void Assign-frame(iRadioCustomer as character ):
      define variable t-str as character no-undo.
      define variable vRadioCustomer as integer no-undo.
      vRadioCustomer = stype:RadioCustomerInt(iRadioCustomer).
      if ParamForm:temp-param-customer <> ""
      then do:
         t-str = paramobj:x-text-cust + ": " .
         t-str = t-str + paramobj:get-custumer-text().
         if vRadioCustomer = 1 then t-str = t-str + chr(10) + "все" .
         paramobj:strcust = t-str .
      end.
   end method.
   method private void new-state(istate as character ):
   end method.
end class.
