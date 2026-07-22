 
 /*------------------------------------------------------------------------
    File        : sCli
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : druban
    Created     : Sun Mar 29 23:20:54 MSK 2020
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Progress.Windows.UserControl.

block-level on error undo, throw.

class ibs.th.ref.sobj.sCustomer inherits UserControl: 
   {cmp\str-glbl.i class}
   define private variable components as System.ComponentModel.IContainer no-undo.
   define private variable CustomerName as System.Windows.Forms.TextBox no-undo.
   define private variable RadioCustomerChange as System.Windows.Forms.RadioButton no-undo.
   define private variable RadioCustomerAll as System.Windows.Forms.RadioButton no-undo.
   define private variable text5 as System.Windows.Forms.Label no-undo.

   define property mTrgLoc as class ibs.th.ref.sobj.sCustomer_trg no-undo
   get.
   set.
   
   define public property mTrgGlb as class ibs.th.ref.sobj.dReportTrg no-undo
   get.
   set.
   
   define public property stype as class ibs.th.ref.sobj.stype no-undo
   get.
   set(iarg as ibs.th.ref.sobj.stype):
      stype = iarg.
      mTrgLoc:stype = iarg.
      /*SelectObjectObjFirm  :text = iarg:SelectObjectLbl({&obj-firm}).
      SelectObjectObjCurr  :text = iarg:SelectObjectLbl({&obj-currency}).
      SelectObjectObjChoice:text = iarg:SelectObjectLbl({&obj-choice}).
      SelectObjectAll      :text = iarg:SelectObjectLbl({&all}).*/
   end.
   
   define public property ParamObj as class ibs.th.ref.sobj.sParamObj no-undo
   
   set(iarg as ibs.th.ref.sobj.sParamObj):
      mTrgLoc:ParamObj = iarg.
   end.   
   
   define public property ParamForm as class ibs.th.ref.sobj.sParamForm no-undo
   get.
   set(iarg as ibs.th.ref.sobj.sParamForm):
      mTrgLoc:ParamForm = iarg.
      ParamForm = iarg.
   end.
   
   define public property RadioCustomer as character  no-undo
   get:
      return if      RadioCustomerAll  :checked 
             then    RadioCustomerAll  :text
             else if RadioCustomerChange :checked 
             then    RadioCustomerChange :text
             else "".
   end.
   set (iarg as character  ):
      if      iarg eq RadioCustomerAll  :text
      then            RadioCustomerAll  :checked = yes .   
      else if iarg eq RadioCustomerChange :text
      then            RadioCustomerChange :checked = yes. 
      else
         message "Нет поля " iarg
         view-as alert-box.  
   end.
      
   method private void RadioCustomer_Visible (iVisible as logical):
      RadioCustomerAll:Visible = iVisible.
      RadioCustomerChange:Visible = iVisible. 
   end method .
   
   method private void RadioCustomer_Enabled (iEnabled as logical):
      RadioCustomerAll:Enabled = iEnabled.
      RadioCustomerChange:Enabled = iEnabled. 
   end method .
   
   constructor public sCustomer (  ):
      
      
      super().
      InitializeComponent().
      mTrgLoc = new ibs.th.ref.sobj.sCustomer_trg().
      this-object:ComponentsCollection:ADD(this-object:components).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.

   end constructor.

   method private void InitializeComponent(  ):
      
      /* NOTE: The following method is automatically generated.
      
      We strongly suggest that the contents of this method only be modified using the
      Visual Designer to avoid any incompatible modifications.
      
      Modifying the contents of this method using a code editor will invalidate any support for this file. */
      this-object:text5 = new System.Windows.Forms.Label().
      this-object:RadioCustomerAll = new System.Windows.Forms.RadioButton().
      this-object:RadioCustomerChange = new System.Windows.Forms.RadioButton().
      this-object:CustomerName = new System.Windows.Forms.TextBox().
      this-object:SuspendLayout().
      /*  */
      /* text5 */
      /*  */
      this-object:text5:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(12)).
      this-object:text5:Location = new System.Drawing.Point(4, 4).
      this-object:text5:Name = "text5".
      this-object:text5:Size = new System.Drawing.Size(156, 23).
      this-object:text5:TabIndex = 0.
      this-object:text5:Text = "Выбор поставщика".
      this-object:text5:UseCompatibleTextRendering = true.
      /*  */
      /* RadioCustomerAll */
      /*  */
      this-object:RadioCustomerAll:Location = new System.Drawing.Point(4, 31).
      this-object:RadioCustomerAll:Name = "RadioCustomerAll".
      this-object:RadioCustomerAll:Size = new System.Drawing.Size(104, 20).
      this-object:RadioCustomerAll:TabIndex = 1.
      this-object:RadioCustomerAll:TabStop = true.
      this-object:RadioCustomerAll:Text = "Все".
      this-object:RadioCustomerAll:UseCompatibleTextRendering = true.
      this-object:RadioCustomerAll:UseVisualStyleBackColor = true.
      this-object:RadioCustomerAll:CheckedChanged:Subscribe(this-object:RadioCustomerAll_CheckedChanged).
      /*  */
      /* RadioCustomerChange */
      /*  */
      this-object:RadioCustomerChange:Location = new System.Drawing.Point(4, 57).
      this-object:RadioCustomerChange:Name = "RadioCustomerChange".
      this-object:RadioCustomerChange:Size = new System.Drawing.Size(104, 20).
      this-object:RadioCustomerChange:TabIndex = 2.
      this-object:RadioCustomerChange:TabStop = true.
      this-object:RadioCustomerChange:Text = "Выборочно".
      this-object:RadioCustomerChange:UseCompatibleTextRendering = true.
      this-object:RadioCustomerChange:UseVisualStyleBackColor = true.
      this-object:RadioCustomerChange:CheckedChanged:Subscribe(this-object:RadioCustomerChange_CheckedChanged).
      /*  */
      /* CustomerName */
      /*  */
      define variable nestedvar0 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar0 = cast(Progress.Util.EnumHelper:Or(cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Bottom), System.Windows.Forms.AnchorStyles), System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:CustomerName:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:CustomerName:Enabled = false.
      this-object:CustomerName:Location = new System.Drawing.Point(4, 84).
      this-object:CustomerName:Multiline = true.
      this-object:CustomerName:Name = "CustomerName".
      this-object:CustomerName:Size = new System.Drawing.Size(150, 21).
      this-object:CustomerName:TabIndex = 3.
      /*  */
      /* sCustomer */
      /*  */
      this-object:AutoScaleDimensions = new System.Drawing.SizeF(Progress.Util.CastUtil:ToSingle(6), Progress.Util.CastUtil:ToSingle(13)).
      this-object:Controls:Add(this-object:CustomerName).
      this-object:Controls:Add(this-object:RadioCustomerChange).
      this-object:Controls:Add(this-object:RadioCustomerAll).
      this-object:Controls:Add(this-object:text5).
      this-object:Name = "sCustomer".
      this-object:Size = new System.Drawing.Size(157, 108).
      this-object:ResumeLayout(false).
      this-object:PerformLayout().
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end method.

   destructor public sCustomer ( ):
      delete object mTrgLoc.
   end destructor.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void RadioCustomerAll_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		VALUE-CHANGED_Radio-customer().
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void RadioCustomerChange_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		VALUE-CHANGED_Radio-customer().
		return.

	end method.

   method private character  VALUE-CHANGED_Radio-customer ():
      CustomerName:text = mtrgloc:VALUE-CHANGED_Radio-customer(input-output Radiocustomer).
   end.
   
   method public void Assign-frame():
      mTrgLoc:set_TextLb(text5:Text).
      if RadioCustomer eq "" then RadioCustomer = stype:RadioCustomerlbl(1).
      mTrgLoc:Assign-frame(RadioCustomer).
   end method.
   
   
   method private void sel-customer ():
      do
      on error undo, return error return-value
      :
         if paramform:temp-param-customer ne "" 
         then do:
            text5:Text = paramform:temp-param-customer .
       
         end.
         /*else do:
                 RadioCustomer_Visible(no).
     hide Radio-customer in frame {&frame-name}
     CustomerName: text-5 rect-7 in frame {&frame-name} .
    
         end. */
      end.  /* do */
   end method.
  
   method public void local-apply-layout(iparamObj as class ibs.th.ref.sobj.sParamObj):
      sel-customer ()  .
      if iparamObj:params-only-mode  = {&lookup} 
      then 
         RadioCustomer_Enabled(no).
   end method.
    
    

end class.