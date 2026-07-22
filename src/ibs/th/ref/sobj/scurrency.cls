 
 /*------------------------------------------------------------------------
    File        : sCurrency
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : druban
    Created     : Sun Mar 29 22:42:49 MSK 2020
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Progress.Windows.UserControl.

block-level on error undo, throw.

class ibs.th.ref.sobj.sCurrency inherits UserControl: 
   
   define private variable components as System.ComponentModel.IContainer no-undo.
   define private variable panel1 as System.Windows.Forms.Panel no-undo.
   define private variable SET_val_TYPE_two as System.Windows.Forms.RadioButton no-undo.
   define private variable SET_val_TYPE_nac as System.Windows.Forms.RadioButton no-undo.
   define private variable SET_val_TYPE_Val as System.Windows.Forms.RadioButton no-undo.
   define private variable SET_PAY_TYPE_doc as System.Windows.Forms.RadioButton no-undo.
   define private variable SET_PAY_TYPE_Uch as System.Windows.Forms.RadioButton no-undo.
   define private variable SET_PAY_TYPE_Prod as System.Windows.Forms.RadioButton no-undo.
   define private variable ShowSale as System.Windows.Forms.CheckBox no-undo.
   define private variable ShowCrsa as System.Windows.Forms.CheckBox no-undo.
   define private variable ShowCost as System.Windows.Forms.CheckBox no-undo.
   define private variable TEXT4 as System.Windows.Forms.Label no-undo.
   {cmp\str-glbl.i class}
   define property mTrgLoc as class ibs.th.ref.sobj.sCurrency_trg no-undo
   get.
   set.
   
   define property mTrgGlb as class ibs.th.ref.sobj.dReportTrg no-undo
   get.
   set.
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
   
   define public property SetPayType as character  no-undo
   get:
      return if      SET_PAY_TYPE_doc  :checked 
             then    SET_PAY_TYPE_doc  :text
             else if SET_PAY_TYPE_Uch  :checked 
             then    SET_PAY_TYPE_Uch  :text
             else if SET_PAY_TYPE_Prod :checked 
             then    SET_PAY_TYPE_Prod :text
             else "".
   end.
   set (iarg as character  ):
      if      iarg eq SET_PAY_TYPE_doc  :text
      then            SET_PAY_TYPE_doc  :checked = yes .   
      else if iarg eq SET_PAY_TYPE_Uch  :text
      then            SET_PAY_TYPE_Uch  :checked = yes . 
      else if iarg eq SET_PAY_TYPE_Prod :text
      then            SET_PAY_TYPE_Prod :checked = yes. 
      else
         message "Нет поля " iarg
         view-as alert-box.  
   end.
   
   define public property SetValType as character  no-undo
   get:
      return if      SET_val_TYPE_two  :checked 
             then    SET_val_TYPE_two  :text
             else if SET_val_TYPE_nac  :checked 
             then    SET_val_TYPE_nac  :text
             else if SET_val_TYPE_Val  :checked 
             then    SET_val_TYPE_Val  :text
             else "".
   end.
   set (iarg as character  ):
      if      iarg eq SET_val_TYPE_two  :text
      then            SET_val_TYPE_two  :checked = yes .   
      else if iarg eq SET_val_TYPE_nac  :text
      then            SET_val_TYPE_nac  :checked = yes . 
      else if iarg eq SET_val_TYPE_Val  :text
      then            SET_val_TYPE_Val  :checked = yes. 
      else
         message "Нет поля " iarg
         view-as alert-box.  
   end.
   
   define public property stype as class ibs.th.ref.sobj.stype no-undo
   get.
   set(iarg as ibs.th.ref.sobj.stype):
      stype = iarg.
      mTrgLoc:stype = iarg.
      SET_val_TYPE_nac:text = iarg:SetValTypeLbl(1).
      SET_val_TYPE_val:text = iarg:SetValTypeLbl(2).
      SET_val_TYPE_two:text = iarg:SetValTypeLbl(3).
      if ParamForm:v-r-b = {&r-b-base}
      then do:
         SETvalTYPE = iarg:setvaltypelbl(2) .
    
      end. 
      /*SelectObjectObjFirm  :text = iarg:SelectObjectLbl({&obj-firm}).
      SelectObjectObjCurr  :text = iarg:SelectObjectLbl({&obj-currency}).
      SelectObjectObjChoice:text = iarg:SelectObjectLbl({&obj-choice}).
      SelectObjectAll      :text = iarg:SelectObjectLbl({&all}).*/
   end.

   
   
	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void SET_PAY_TYPE_doc_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		VALUE-CHANGED_SET_PAY_TYPE().
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void SET_PAY_TYPE_Prod_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		VALUE-CHANGED_SET_PAY_TYPE().
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void SET_PAY_TYPE_Uch_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		VALUE-CHANGED_SET_PAY_TYPE().
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void SET_val_TYPE_nac_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		VALUE-CHANGED_SET_val_TYPE().
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void SET_val_TYPE_two_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		VALUE-CHANGED_SET_val_TYPE().
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void SET_val_TYPE_Val_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		VALUE-CHANGED_SET_val_TYPE().
		return.

	end method.

   method private void SetPayType_visible (iarg as character ):
      define variable varg as character  no-undo.
      define variable vVisible as logical no-undo.
      define variable vi as integer no-undo.
      if iarg eq "*" then  iarg = "1,2,3".
      do vi = 1 to 3:
         vVisible=  lookup(string(vi),iarg) ne 0.
         varg = stype:SetPayTypeLbl(vi)no-error.
         if      varg eq SET_PAY_TYPE_doc :Text
         then            SET_PAY_TYPE_doc :visible = vvisible .   
         else if varg eq SET_PAY_TYPE_Uch :Text
         then            SET_PAY_TYPE_Uch :visible = vvisible . 
         else if varg eq SET_PAY_TYPE_Prod:Text
         then            SET_PAY_TYPE_Prod:visible = vvisible .
         
      end.
   end.
   
   method private logical getSetPayType_visible ():
      return
               SET_PAY_TYPE_doc :visible    
         and   SET_PAY_TYPE_Uch :visible  
         and   SET_PAY_TYPE_Prod:visible 
      .
   end.
   
   method private void SetPayType_Enabled (iarg as character):
      define variable varg as character  no-undo.
      define variable vEnabled as logical no-undo.
      define variable vi as integer no-undo.
      if iarg eq "*" then iarg = "1,2,3".
      do vi = 1 to 3:
         vEnabled =  lookup(string(vi),iarg) ne 0.
         varg = stype:SetPayTypeLbl(vi)no-error.
         if      varg eq SET_PAY_TYPE_doc :Text
         then            SET_PAY_TYPE_doc :Enabled = vEnabled .   
         else if varg eq SET_PAY_TYPE_Uch :Text
         then            SET_PAY_TYPE_Uch :Enabled = vEnabled . 
         else if varg eq SET_PAY_TYPE_Prod:Text
         then            SET_PAY_TYPE_Prod:Enabled = vEnabled .
         
      end.
   end.
   
   method private void SetValType_Enabled(iarg as character  ):
      define variable varg as character  no-undo.
      define variable vEnabled as logical no-undo.
      define variable vi as integer no-undo.
      if iarg eq "*" then iarg = "1,2,3".
      do vi = 1 to 3:
         varg = stype:SetValTypeLbl(vi)no-error.
         vEnabled =  lookup(string(vi),iarg) ne 0.
         if      varg eq SET_val_TYPE_two:Text
         then            SET_val_TYPE_two:Enabled = vEnabled .   
         else if varg eq SET_val_TYPE_nac:Text
         then            SET_val_TYPE_nac:Enabled = vEnabled . 
         else if varg eq SET_val_TYPE_Val:Text
         then            SET_val_TYPE_Val:Enabled = vEnabled .
         
      end.
   end.
   
   method private void SetValType_Visible(iarg as character ):
      define variable varg as character  no-undo.
      define variable vVisible as logical no-undo.
      define variable vi as integer no-undo.
      if iarg eq "*" then iarg = "1,2,3".
      do vi = 1 to 3:
         vVisible=  lookup(string(vi),iarg) ne 0.
         varg = stype:SetValTypeLbl(vi)no-error.
         if      varg eq SET_val_TYPE_two:Text
         then            SET_val_TYPE_two:Visible = vVisible .   
         else if varg eq SET_val_TYPE_nac:Text
         then            SET_val_TYPE_nac:Enabled = vVisible . 
         else if varg eq SET_val_TYPE_Val:Text
         then            SET_val_TYPE_Val:Enabled = vVisible .
      end.
   end.

   
   
   
   constructor public sCurrency (  ):
      
      
      super().
      
  
      mTrgLoc = new ibs.th.ref.sobj.sCurrency_trg ().
      
      InitializeComponent().
      this-object:SET_val_TYPE_nac:Text = "{&abbr_rub}".
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
      this-object:TEXT4 = new System.Windows.Forms.Label().
      this-object:SET_PAY_TYPE_Prod = new System.Windows.Forms.RadioButton().
      this-object:SET_PAY_TYPE_Uch = new System.Windows.Forms.RadioButton().
      this-object:SET_PAY_TYPE_doc = new System.Windows.Forms.RadioButton().
      this-object:SET_val_TYPE_nac = new System.Windows.Forms.RadioButton().
      this-object:SET_val_TYPE_Val = new System.Windows.Forms.RadioButton().
      this-object:SET_val_TYPE_two = new System.Windows.Forms.RadioButton().
      this-object:ShowCrsa = new System.Windows.Forms.CheckBox().
      this-object:ShowSale = new System.Windows.Forms.CheckBox().
      this-object:ShowCost = new System.Windows.Forms.CheckBox().
      this-object:panel1 = new System.Windows.Forms.Panel().
      this-object:panel1:SuspendLayout().
      this-object:SuspendLayout().
      /*  */
      /* TEXT4 */
      /*  */
      this-object:TEXT4:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(12)).
      this-object:TEXT4:Location = new System.Drawing.Point(21, 12).
      this-object:TEXT4:Name = "TEXT4".
      this-object:TEXT4:Size = new System.Drawing.Size(100, 23).
      this-object:TEXT4:TabIndex = 0.
      this-object:TEXT4:Text = "Выбор цен".
      this-object:TEXT4:UseCompatibleTextRendering = true.
      /*  */
      /* SET_PAY_TYPE_Prod */
      /*  */
      this-object:SET_PAY_TYPE_Prod:Location = new System.Drawing.Point(4, 38).
      this-object:SET_PAY_TYPE_Prod:Name = "SET_PAY_TYPE_Prod".
      this-object:SET_PAY_TYPE_Prod:Size = new System.Drawing.Size(117, 20).
      this-object:SET_PAY_TYPE_Prod:TabIndex = 1.
      this-object:SET_PAY_TYPE_Prod:TabStop = true.
      this-object:SET_PAY_TYPE_Prod:Text = "Продажные цены".
      this-object:SET_PAY_TYPE_Prod:UseCompatibleTextRendering = true.
      this-object:SET_PAY_TYPE_Prod:UseVisualStyleBackColor = true.
      this-object:SET_PAY_TYPE_Prod:CheckedChanged:Subscribe(this-object:SET_PAY_TYPE_Prod_CheckedChanged).
      /*  */
      /* SET_PAY_TYPE_Uch */
      /*  */
      this-object:SET_PAY_TYPE_Uch:Location = new System.Drawing.Point(3, 64).
      this-object:SET_PAY_TYPE_Uch:Name = "SET_PAY_TYPE_Uch".
      this-object:SET_PAY_TYPE_Uch:Size = new System.Drawing.Size(104, 20).
      this-object:SET_PAY_TYPE_Uch:TabIndex = 2.
      this-object:SET_PAY_TYPE_Uch:TabStop = true.
      this-object:SET_PAY_TYPE_Uch:Text = "Учетные цены".
      this-object:SET_PAY_TYPE_Uch:UseCompatibleTextRendering = true.
      this-object:SET_PAY_TYPE_Uch:UseVisualStyleBackColor = true.
      this-object:SET_PAY_TYPE_Uch:CheckedChanged:Subscribe(this-object:SET_PAY_TYPE_Uch_CheckedChanged).
      /*  */
      /* SET_PAY_TYPE_doc */
      /*  */
      this-object:SET_PAY_TYPE_doc:Location = new System.Drawing.Point(3, 90).
      this-object:SET_PAY_TYPE_doc:Name = "SET_PAY_TYPE_doc".
      this-object:SET_PAY_TYPE_doc:Size = new System.Drawing.Size(118, 20).
      this-object:SET_PAY_TYPE_doc:TabIndex = 3.
      this-object:SET_PAY_TYPE_doc:TabStop = true.
      this-object:SET_PAY_TYPE_doc:Text = "Цены документа".
      this-object:SET_PAY_TYPE_doc:UseCompatibleTextRendering = true.
      this-object:SET_PAY_TYPE_doc:UseVisualStyleBackColor = true.
      this-object:SET_PAY_TYPE_doc:CheckedChanged:Subscribe(this-object:SET_PAY_TYPE_doc_CheckedChanged).
      /*  */
      /* SET_val_TYPE_nac */
      /*  */
      this-object:SET_val_TYPE_nac:Location = new System.Drawing.Point(4, 9).
      this-object:SET_val_TYPE_nac:Name = "SET_val_TYPE_nac".
      this-object:SET_val_TYPE_nac:Size = new System.Drawing.Size(52, 20).
      this-object:SET_val_TYPE_nac:TabIndex = 4.
      this-object:SET_val_TYPE_nac:TabStop = true.
      this-object:SET_val_TYPE_nac:Text = "~{&abbr_rub~}".
      this-object:SET_val_TYPE_nac:UseCompatibleTextRendering = true.
      this-object:SET_val_TYPE_nac:UseVisualStyleBackColor = true.
      this-object:SET_val_TYPE_nac:CheckedChanged:Subscribe(this-object:SET_val_TYPE_nac_CheckedChanged).
      /*  */
      /* SET_val_TYPE_Val */
      /*  */
      this-object:SET_val_TYPE_Val:Location = new System.Drawing.Point(62, 9).
      this-object:SET_val_TYPE_Val:Name = "SET_val_TYPE_Val".
      this-object:SET_val_TYPE_Val:Size = new System.Drawing.Size(45, 20).
      this-object:SET_val_TYPE_Val:TabIndex = 5.
      this-object:SET_val_TYPE_Val:TabStop = true.
      this-object:SET_val_TYPE_Val:Text = "вал".
      this-object:SET_val_TYPE_Val:UseCompatibleTextRendering = true.
      this-object:SET_val_TYPE_Val:UseVisualStyleBackColor = true.
      this-object:SET_val_TYPE_Val:CheckedChanged:Subscribe(this-object:SET_val_TYPE_Val_CheckedChanged).
      /*  */
      /* SET_val_TYPE_two */
      /*  */
      this-object:SET_val_TYPE_two:Location = new System.Drawing.Point(111, 5).
      this-object:SET_val_TYPE_two:Name = "SET_val_TYPE_two".
      this-object:SET_val_TYPE_two:Size = new System.Drawing.Size(86, 29).
      this-object:SET_val_TYPE_two:TabIndex = 6.
      this-object:SET_val_TYPE_two:TabStop = true.
      this-object:SET_val_TYPE_two:Text = "обе валюты".
      this-object:SET_val_TYPE_two:UseCompatibleTextRendering = true.
      this-object:SET_val_TYPE_two:UseVisualStyleBackColor = true.
      this-object:SET_val_TYPE_two:CheckedChanged:Subscribe(this-object:SET_val_TYPE_two_CheckedChanged).
      /*  */
      /* ShowCrsa */
      /*  */
      this-object:ShowCrsa:Location = new System.Drawing.Point(3, 61).
      this-object:ShowCrsa:Name = "ShowCrsa".
      this-object:ShowCrsa:Size = new System.Drawing.Size(122, 24).
      this-object:ShowCrsa:TabIndex = 8.
      this-object:ShowCrsa:Text = "Продажные цены".
      this-object:ShowCrsa:UseCompatibleTextRendering = true.
      this-object:ShowCrsa:UseVisualStyleBackColor = true.
      this-object:ShowCrsa:Visible = false.
      this-object:ShowCrsa:CheckedChanged:Subscribe(this-object:ShowCrsa_CheckedChanged).
      /*  */
      /* ShowSale */
      /*  */
      this-object:ShowSale:Location = new System.Drawing.Point(3, 91).
      this-object:ShowSale:Name = "ShowSale".
      this-object:ShowSale:Size = new System.Drawing.Size(122, 24).
      this-object:ShowSale:TabIndex = 9.
      this-object:ShowSale:Text = "Цены документа".
      this-object:ShowSale:UseCompatibleTextRendering = true.
      this-object:ShowSale:UseVisualStyleBackColor = true.
      this-object:ShowSale:Visible = false.
      this-object:ShowSale:CheckedChanged:Subscribe(this-object:ShowSale_CheckedChanged).
      /*  */
      /* ShowCost */
      /*  */
      this-object:ShowCost:Location = new System.Drawing.Point(4, 34).
      this-object:ShowCost:Name = "ShowCost".
      this-object:ShowCost:Size = new System.Drawing.Size(104, 24).
      this-object:ShowCost:TabIndex = 7.
      this-object:ShowCost:Text = "Учетные цены".
      this-object:ShowCost:UseCompatibleTextRendering = true.
      this-object:ShowCost:UseVisualStyleBackColor = true.
      this-object:ShowCost:Visible = false.
      this-object:ShowCost:CheckedChanged:Subscribe(this-object:ShowCost_CheckedChanged).
      /*  */
      /* panel1 */
      /*  */
      define variable nestedvar0 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar0 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:panel1:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:panel1:Controls:Add(this-object:SET_val_TYPE_nac).
      this-object:panel1:Controls:Add(this-object:SET_val_TYPE_Val).
      this-object:panel1:Controls:Add(this-object:SET_val_TYPE_two).
      this-object:panel1:Location = new System.Drawing.Point(0, 116).
      this-object:panel1:Name = "panel1".
      this-object:panel1:Size = new System.Drawing.Size(200, 32).
      this-object:panel1:TabIndex = 10.
      /*  */
      /* sCurrency */
      /*  */
      this-object:AutoScaleDimensions = new System.Drawing.SizeF(Progress.Util.CastUtil:ToSingle(6), Progress.Util.CastUtil:ToSingle(13)).
      this-object:Controls:Add(this-object:panel1).
      this-object:Controls:Add(this-object:ShowSale).
      this-object:Controls:Add(this-object:ShowCrsa).
      this-object:Controls:Add(this-object:ShowCost).
      this-object:Controls:Add(this-object:SET_PAY_TYPE_doc).
      this-object:Controls:Add(this-object:SET_PAY_TYPE_Uch).
      this-object:Controls:Add(this-object:SET_PAY_TYPE_Prod).
      this-object:Controls:Add(this-object:TEXT4).
      this-object:Name = "sCurrency".
      this-object:Size = new System.Drawing.Size(200, 150).
      this-object:panel1:ResumeLayout(false).
      this-object:ResumeLayout(false).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end method.

   destructor public sCurrency ( ):
       delete object mTrgLoc.
   end destructor.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void ShowCost_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		mtrgloc:setShowCost(ShowCost:Checked).
		return.
	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void ShowCrsa_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		mtrgloc:setShowCrsa(ShowCrsa:Checked).
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void ShowSale_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		mtrgloc:setShowSale(ShowSale:Checked).
		return.

	end method.

   method private void VALUE-CHANGED_SET_PAY_TYPE ():
      mtrgloc:VALUE-CHANGED_SET_PAY_TYPE ( SETPAYTYPE).
      
      set_val().
      
   end.

   method private void VALUE-CHANGED_SET_val_TYPE():
      mtrgloc:VALUE-CHANGED_SET_val_TYPE ( SETvalTYPE).
   end.
   
   method private void display-pay ():
/*Обработка 4 параметра - цены - как показывать блок  */


      if ParamForm:temp-param-pay = "" 
      then do:
         SetPayType_Enabled("").
         SetPayType_visible("").
         SETPAYTYPE= stype:setpaytypelbl(2).
      end.
      else do:
/*         SetPayType_Enabled("*", yes).*/
         SetPayType_Enabled(ParamForm:temp-param-pay).
         SetPayType_visible("*").
         SetValType_Enabled(ParamForm:temp-param-Pay-hide).
         SetValType_visible("*").
         TEXT4:visible = yes.
         
         if lookup(ParamForm:temp-param-pay, "{&p-cost}" ) > 0 
         then
            SETPAYTYPE= stype:setpaytypelbl(2).
      end.

      if ParamForm:temp-param-pay-hide = "" then do:
         SetValType_Enabled("").
         SetValType_visible("").
      end.
      else do:
         SetValType_Enabled(ParamForm:temp-param-Pay-hide).
         SetValType_visible("*").
         TEXT4:visible = yes .
   /*disable radio-set по номеру */
/*         SetValType_Enabled(ParamForm:temp-param-pay-hide, no).*/
      end.
/*
      if     temp-param-pay = ""  
         and temp-param-pay-hide = "" then do:
         disable  TEXT-4 SET_PAY_TYPE SET_val_TYPE  with frame {&FRAME-NAME} .
         hide TEXT-4  SET_PAY_TYPE SET_val_TYPE  in frame {&FRAME-NAME} .
                        end.
   else do:
         enable  TEXT-4   with frame {&FRAME-NAME} .
         display TEXT-4   with frame {&FRAME-NAME} .
         end.
*/
   end.

   method private void Set_VAl() :
      if not (ParamForm:temp-param-pay = "" and  ParamForm:temp-param-pay-hide = "")   
      then do:
         if SETPAYtYPE = stype:setpaytypelbl(1)  /*sale*/
         then
            SetValType_Enabled("").
         else
            SetValType_Enabled(ParamForm:temp-param-Pay-hide).   
      end.
   end.

   method public void Assign-frame():
      mTrgLoc:set_SET_PAY_TYPE(SETPAYTYPE).
      mTrgLoc:set_SET_val_TYPE(SETPAYTYPE).
      mTrgLoc:set_TextLb(TEXT4:Text).
      mTrgLoc:setShowCost(showcost:Checked).
      mTrgLoc:setShowCrsa(showcrsa:Checked).
      mTrgLoc:setShowSale(showsale:Checked).
      mtrgloc:Assign-frame().
   end.
   
   method public void local-apply-layout(iparamObj as class ibs.th.ref.sobj.sParamObj):
      if     iparamObj:X-SET_PAY_TYPE ne ?
         and iparamObj:X-SET_PAY_TYPE ne 0
      then
         SETPAYTYPE = stype:SetPayTypeLbl(iparamObj:X-SET_PAY_TYPE).
      if     iparamObj:X-SET_val_TYPE ne ?
         and iparamObj:X-SET_val_TYPE ne 0
      then
         SETvalTYPE = stype:SetValTypeLbl(iparamObj:X-SET_val_TYPE).
      if      (   Paramform:init-SET_PAY_TYPE <> 0 
               or Paramform:init-SET_PAY_TYPE <> ?)  
          and (   iparamObj:x-SET_PAY_TYPE = ? 
               or iparamObj:x-SET_PAY_TYPE = 0) 
          and Paramform:init-SET_PAY_TYPE  ne ?
          and Paramform:init-SET_PAY_TYPE  ne 0
      then do:
         SETPAYTYPE = stype:SetPayTypeLbl(Paramform:init-SET_PAY_TYPE).
      end.
      display-pay ().
      set_val().
      if iparamObj:params-only-mode  = {&lookup} 
      then do:
         showcrsa:enabled = no.
         showcost:enabled = no.
         showsale:enabled = no.
         SetPayType_Enabled("").
         SetValType_Enabled("").
      end.
   end method.
   
   method public void local-initialize(iparamObj as class ibs.th.ref.sobj.sParamObj):
      if iParamObj:Show-Cost 
      then do:
         Showcost:Checked = iParamObj:Show-cost.
         Showcost:enabled = yes.
         Showcost:visible = yes.
      end.
      if iParamObj:Show-Crsa 
      then do:
         Showcrsa:Checked = iParamObj:Show-crsa.
         Showcrsa:enabled = yes.
         Showcrsa:visible = yes.
      end.
      if iParamObj:Show-sale 
      then do:
         Showsale:Checked = iParamObj:Show-sale.
         Showsale:enabled = yes.
         Showsale:visible = yes.
      end.

      if paramform:Name-Sale-price <> "" 
      then do :
         stype:settypelbl("SetPayType",5,paramform:Name-Sale-price).
         showsale:Text = paramform:Name-Sale-price .
      end.
      if (paramform:init-SET_val_type <> 0)
/*      and getSetPayType_visible()*/
      then do:
         setvaltype = stype:SetValTypeLbl(paramform:init-SET_val_type).
      end.
      else
         if ParamForm:temp-param-Pay-hide ne ""
         then
         setvaltype = stype:SetValTypeLbl(int(entry(1,ParamForm:temp-param-Pay-hide))).
         
   end method.
   
end class.