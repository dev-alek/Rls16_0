 
 /*------------------------------------------------------------------------
    File        : attrfrm_trg
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : druban
    Created     : Sun Nov 15 10:04:13 MSK 2020
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class ibs.th.ref.xproc.attrfrm_trg: 
   {cmp\str-glbl.i class}
   {gbl/tmprecid.i }
   {gbl\attr-lib.i class}
   define public variable GroupObj    as character no-undo.
   define public variable AttrCode    as character no-undo.
   define public variable resultValue as character no-undo.
   
      
   constructor public attrfrm_trg (  ):
      super ().
      
   end constructor.

   destructor public attrfrm_trg ( ):

   end destructor.
   define variable mValue as character no-undo.
   define variable mNum   as logical no-undo.
   define variable mDate  as logical no-undo.
   define variable mCheck as logical no-undo.
   define variable mtext  as logical no-undo.
   define variable mComb  as logical no-undo.
   define variable vMaxDec as decimal no-undo init ?.
   define variable vMinDec as decimal no-undo init ?.
   define variable vMaxDat as date no-undo init ?.
   define variable vMinDat as date no-undo init ?.
   define variable vMaxStr as character  no-undo.
   define variable vMinStr as character  no-undo.
   define variable vdec as char no-undo.
   define variable vi as integer no-undo.
   
   define variable vpos as integer no-undo.
   
               
   define variable mfrm as class ibs.th.ref.xproc.attrfrm no-undo.
   method public logical  FrmAttr(ivalue as character ):
      define buffer xattr for xattr.
      
      mFrm = new ibs.th.ref.xproc.attrfrm (this-object).
      find first xattr where Xattr.GroupObj-code eq GroupObj
                         and Xattr.Xattr-Code    eq AttrCode
      no-lock no-error.
      if available xattr
      then do:
         if Xattr.Data-Type eq {&ABL-datatype-Decimal}
         then do:
            
            vdec =  replace(entry(1,Xattr.Data-Format,"."),",","").
            if Xattr.Validation ne ""
            then do:
               vpos = index(Xattr.Validation,"<<").
               if vpos ne 0
               then do: 
                  vminstr = substring(Xattr.Validation,1,vpos - 1).
                  vmaxStr = substring(Xattr.Validation,vpos + 2).
                  if vminstr ne ""
                  then
                     vmindec = decimal (vminstr)no-error.
                  if vmaxStr ne ""
                  then
                     vmaxdec = decimal (vmaxStr)no-error.
               end.
                              
            end.
            if vdec begins "-"
            then do:
               assign
                  vmindec = decimal("-" + fill("9",length(vdec) - 1) + if Xattr.Accuracy > 0 then ("." + fill("9",Xattr.Accuracy)) else "" ) when vmindec eq ?
                  vmaxdec = decimal(      fill("9",length(vdec) - 1) + if Xattr.Accuracy > 0 then ("." + fill("9",Xattr.Accuracy)) else "")  when vmaxdec eq ?
               .
            end.
            else
               assign 
                  vmindec = 0                                                                                                               when vmindec eq ?
                  vmaxdec = decimal(      fill("9",length(vdec)    ) + if Xattr.Accuracy > 0 then ("." + fill("9",Xattr.Accuracy)) else "") when vmaxdec eq ?
               .
            mfrm:numericUpDown:Minimum = vmindec.
            mfrm:numericUpDown:Maximum = vmaxdec.
            if     ivalue = ?
            then do:
               if Xattr.Initial ne ""
               then
                  ivalue = Xattr.Initial.
               else
                  ivalue = string(vMindec).
            end. 
            
            mfrm:numericUpDown:Visible = yes.
            mfrm:numericUpDown:DecimalPlaces = Xattr.Accuracy.
            mNum = yes.
         end.
         else if Xattr.Data-Type eq {&ABL-datatype-Date}
         then do :
            if Xattr.Validation ne ""
            then do:
               vpos = index(Xattr.Validation,"<<").
               if vpos ne 0
               then do:
                  vminstr = substring(Xattr.Validation,1,vpos - 1).
                  vmaxStr = substring(Xattr.Validation,vpos + 2).
                  if vminstr ne ""
                  then
                     vmindat = date  (vminstr) no-error.
                  if vmaxStr ne ""
                  then
                     vmaxdat = date (vmaxStr) no-error.
                  assign
                     mfrm:dateTimePicker:mindate = vmindat when vmindat ne ?
                     mfrm:dateTimePicker:maxdate = vmaxdat when vmaxdat ne ?
                  .
               end.
               
            end.
            
            mfrm:dateTimePicker:Visible = yes.
            mdate = yes.
         end.
         else if Xattr.Data-Type eq {&ABL-datatype-integer}
         then do:
            vdec =  replace(entry(1,Xattr.Data-Format,"."),",","").
            if Xattr.Validation ne ""
            then do:
               vpos = index(Xattr.Validation,"<<").
               if vpos ne 0
               then do:
                  vminstr = substring(Xattr.Validation,1,vpos - 1).
                  vmaxStr = substring(Xattr.Validation,vpos + 2).
                  if vminstr ne ""
                  then
                     vmindec = integer  (vminstr)no-error.
                  if vmaxStr ne ""
                  then
                     vmaxdec = integer (vmaxStr)no-error.
               end.
                              
            end.
            if vdec begins "-"
            then do:
               assign
                  vmindec = decimal("-" + fill("9",length(vdec) - 1)  ) when vmindec eq ?
                  vmaxdec = decimal(      fill("9",length(vdec) - 1)  ) when vmaxdec eq ?
               .
            end.
            else
               assign 
                  vmindec = 0                                          when vmindec eq ?
                  vmaxdec = decimal(      fill("9",length(vdec)    ) ) when vmaxdec eq ?
               .
            mfrm:numericUpDown:Minimum = vmindec.
            mfrm:numericUpDown:Maximum = vmaxdec.
            if     ivalue = ?
            then do:
               if Xattr.Initial ne ""
               then
                  ivalue = Xattr.Initial.
               else
                  ivalue = string(vMindec).
            end. 
            mfrm:numericUpDown:Visible = yes.
            mnum = yes.
         end. 
         else if Xattr.Data-Type eq {&ABL-datatype-Logical}
         then do: 
            mfrm:checkBox:Visible = yes.
            mfrm:checkBox:Text    = Xattr.Name.
            mcheck = yes.
         end.
         else do:
            if xattr.listValue
            then do:
               mfrm:textBox:Visible = true.
               mfrm:button:Visible  =  Xattr.Domain-Code ne "".
               mtext = yes.
                
            end.
            else if Xattr.Domain-Code ne ""
            then do:
               mfrm:comboBox:Visible = true.
               mComb = yes.
               define variable vParent as character no-undo.
               vParent = replace(Xattr.Domain-Code, "\", {&delim-par}).
               for each code where code.parent  eq  vParent 
                               and code.status_ ne {&bef-deleted-status-int} 
               no-lock:
                  mfrm:comboBox:Items:Add(code.code).
               end.
                
            end.
            else if     Xattr.Validation ne ""
                    and index (Xattr.Validation,".") eq 0
                    and index (Xattr.Validation,"*") eq 0
            then do:
               mComb = yes.
               do vi = 1 to num-entries(Xattr.Validation):
                  mfrm:comboBox:Items:Add(entry(vi,Xattr.Validation)).
               end.
               
                
            end.
            else do:
               
               mfrm:textBox:Visible = true.
               mtext = yes.
            end.
         end.
      end.
      else do:
         mfrm:textBox:Visible = true.
         mtext = yes.
      end.
      resultValue = ivalue.
      if mnum
      then
          mfrm:numericUpDown:Value = dec(resultValue) no-error.
      else if mdate
      then
         mfrm:dateTimePicker:Value = date(resultValue) no-error.
      else if mcheck
      then
         mfrm:checkBox:Checked = logical(resultValue) no-error.
      else if mComb
      then
         mfrm:comboBox:text = resultValue.
      else if mtext
      then
         mfrm:textBox:text = resultValue.
      mFrm:ShowModalDialog().
      if mFrm:DialogResult = System.Windows.Forms.DialogResult:Ok
      then do:
         resultValue = mValue.
         
         return yes.
      end.
      return no.
      finally:
         delete object mFrm no-error.
      end finally.
   end method.
   
   method public void setresult ():
      if mnum
         then
            mValue = string(mfrm:numericUpDown:Value).
         else if mdate
         then
            mValue = string(mfrm:dateTimePicker:Value).
         else if mcheck
         then
            mValue = string(mfrm:checkBox:Checked).
         else if mComb
         then
            mValue = mfrm:comboBox:text.
         else if mtext
         then
            mValue = mfrm:textBox:text.
   end.
  
   method public character  btnCode(iValue as character ):
      define buffer xattr for xattr.
      define buffer code for code.
      define variable vParent as character no-undo.
      define variable vCode   as character no-undo.
      define variable oValue as character no-undo.
      oValue = ivalue.
      find first xattr where Xattr.GroupObj-code eq GroupObj
                         and Xattr.Xattr-Code    eq AttrCode
      no-lock no-error.
      if num-entries(Xattr.Domain-Code,"\") eq 1
      then
         vcode = Xattr.Domain-Code.
      else 
         assign
            vparent = Xattr.Domain-Code
            vcode   = entry ( num-entries(vparent,"\"),vparent,"\")
            entry ( num-entries(vparent,"\"),vparent,"\") = ""
            vParent = replace(trim(Xattr.Domain-Code, "\"),"\", {&delim-par})
         .
      run ref/codelayout.p({&select},vParent,vcode, ?,output table tmprecid).
      for each tmprecid,
        first code where recid(code) eq tmprecid.Frecid:
        if lookup(code.code, oValue) = 0 
        then
           oValue = oValue + "," + code.code.
      end.
      ovalue = trim(ovalue,",").
      return ovalue.
   end method.
   
   method public logical CheckAttr():
      &scop proc-name attr-Check-group
            {&run_proc_attr-lib}
                 (GroupObj,
                  AttrCode ,
                  mValue) no-error.
      if error-status:error
      then do:
         message   return-value
         view-as alert-box.
         return no.
      end.
      return yes.
   end.
end class.