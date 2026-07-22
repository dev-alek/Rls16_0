function getCliKassa returns logical (input p-type as character, input p-code as integer, input p-attr as character, cashbookId as integer) :
define buffer bf_CashBookRule  for ub.CashBookRule .
define buffer buf_CashBookRule for ub.CashBookRule .
   
find first bf_CashBookRule no-lock where bf_CashBookRule.CashBookID = cashbookId
  and bf_CashBookRule.Obj-type   = {&by_all}
  and bf_CashBookRule.Obj-code   = 0
  and bf_CashBookRule.Code       = p-attr + "-type"
  no-error.
if available (bf_CashBookRule) then 
do:  
  if p-type = bf_CashBookRule.RuleValue then 
  do:
    find first buf_CashBookRule no-lock where buf_CashBookRule.CashBookID = cashbookId
      and buf_CashBookRule.Obj-type   = {&by_all}
      and buf_CashBookRule.Obj-code   = 0
      and buf_CashBookRule.Code       = p-attr + "-code"
      no-error.
    if available (buf_CashBookRule) then do:
        if p-code = integer(buf_CashBookRule.RuleValue) then return true .
  
    end.  
  end.    
  
end.                               

return false .

end function . 