 
 /*------------------------------------------------------------------------
    File        : sobj
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : druban
    Created     : Sun Mar 29 20:45:53 MSK 2020
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Progress.Windows.UserControl.
using ibs.th.ref.sobj.sType from propath.

block-level on error undo, throw.

class ibs.th.ref.sobj.sobj inherits UserControl: 
   {cmp\str-glbl.i class}
   {cmp\r-page-pre.i}
   define public  variable BtnObj as System.Windows.Forms.Button no-undo.
   define private variable components as System.ComponentModel.IContainer no-undo.
   define private variable ObjCount as System.Windows.Forms.TextBox no-undo.
   define private variable SelectObjectObjFirm as System.Windows.Forms.RadioButton no-undo.
   define private variable SelectObjectObjCurr as System.Windows.Forms.RadioButton no-undo.
   define private variable SelectObjectObjChoice as System.Windows.Forms.RadioButton no-undo.
   define private variable SelectObjectAll as System.Windows.Forms.RadioButton no-undo.
   define private variable TEXT1 as System.Windows.Forms.Label no-undo.

   define property mTrgLoc as class ibs.th.ref.sobj.sObj_trg no-undo
   get.
   set.
   
   define property mTrgGlb as class ibs.th.ref.sobj.dReportTrg no-undo
   get.
   set.
   
   define public property stype as class ibs.th.ref.sobj.stype no-undo
   get.
   set(iarg as ibs.th.ref.sobj.stype):
      stype = iarg.
      mTrgLoc:stype = iarg.
      SelectObjectObjFirm  :text = iarg:SelectObjectLbl({&obj-firm}).
      SelectObjectObjCurr  :text = iarg:SelectObjectLbl({&obj-currency}).
      SelectObjectObjChoice:text = iarg:SelectObjectLbl({&obj-choice}).
      SelectObjectAll      :text = iarg:SelectObjectLbl({&obj-all}).
   end.

   define public property SelectObject as character  no-undo
   get:
      return if      SelectObjectObjFirm  :checked 
             then    SelectObjectObjFirm  :text
             else if SelectObjectObjCurr  :checked 
             then    SelectObjectObjCurr  :text
             else if SelectObjectObjChoice:checked 
             then    SelectObjectObjChoice:text
             else if SelectObjectAll      :checked 
             then    SelectObjectAll      :text
             else "".
   end.
   set (iarg as character  ):
      if      iarg eq SelectObjectObjFirm  :text
      then            SelectObjectObjFirm  :checked = yes .   
      else if iarg eq SelectObjectObjCurr  :text
      then            SelectObjectObjCurr  :checked = yes . 
      else if iarg eq SelectObjectObjChoice:text
      then            SelectObjectObjChoice:checked = yes. 
      else if iarg eq SelectObjectAll      :text
      then            SelectObjectAll      :checked = yes. 
      else
         message "Нет поля " iarg
         view-as alert-box.  
   end.
   
   define public property SelectObject_disable as character  no-undo
   set (iarg as character  ):
      define variable varg as character  no-undo.
      define variable vi as integer no-undo.
      if not iarg eq "*" 
      then
      do vi = 1 to 4:
         if lookup(string(vi),iarg) eq 0
         then do:
            varg = stype:SelectObjectLbl(vi)no-error.
            if      varg eq SelectObjectObjFirm:Text
            then            SelectObjectObjFirm:Enabled = no .   
            else if varg eq SelectObjectObjCurr:Text
            then            SelectObjectObjCurr:Enabled = no . 
            else if varg eq SelectObjectObjChoice:Text
            then            SelectObjectObjChoice:Enabled = no . 
            else if varg eq SelectObjectAll:Text
            then            SelectObjectAll:Enabled = no .
         end.
      end.
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
   
   constructor public sobj (  ):
      
      
      super().
      mTrgLoc = new ibs.th.ref.sobj.sObj_trg (). 
      mTrgLoc:ObjForm = this-object.
      InitializeComponent().
      this-object:ComponentsCollection:ADD(this-object:components).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.

   end constructor.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void BtnObj_Click( input sender as System.Object, input e as System.EventArgs ):
		VALUE-CHANGED_SelectObject().
		return.

	end method.

   method private void InitializeComponent(  ):
      
      /* NOTE: The following method is automatically generated.
      
      We strongly suggest that the contents of this method only be modified using the
      Visual Designer to avoid any incompatible modifications.
      
      Modifying the contents of this method using a code editor will invalidate any support for this file. */
        @VisualDesigner.FormMember (NeedsInitialize="true").
        DEFINE VARIABLE resources AS Progress.Util.ResourceManager NO-UNDO.
        resources = NEW Progress.Util.ResourceManager("ibs.th.ref.sobj.sobj").
        THIS-OBJECT:TEXT1 = NEW System.Windows.Forms.Label().
        THIS-OBJECT:SelectObjectObjFirm = NEW System.Windows.Forms.RadioButton().
        THIS-OBJECT:SelectObjectObjCurr = NEW System.Windows.Forms.RadioButton().
        THIS-OBJECT:SelectObjectObjChoice = NEW System.Windows.Forms.RadioButton().
        THIS-OBJECT:SelectObjectAll = NEW System.Windows.Forms.RadioButton().
        THIS-OBJECT:BtnObj = NEW System.Windows.Forms.Button().
        THIS-OBJECT:ObjCount = NEW System.Windows.Forms.TextBox().
        THIS-OBJECT:SuspendLayout().
        /*  */
        /* TEXT1 */
        /*  */
        THIS-OBJECT:TEXT1:Font = NEW System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(12), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
        THIS-OBJECT:TEXT1:Location = NEW System.Drawing.Point(14, 12).
        THIS-OBJECT:TEXT1:Name = "TEXT1".
        THIS-OBJECT:TEXT1:Size = NEW System.Drawing.Size(140, 23).
        THIS-OBJECT:TEXT1:TabIndex = 0.
        THIS-OBJECT:TEXT1:Text = "Выбор объекта".
        THIS-OBJECT:TEXT1:UseCompatibleTextRendering = TRUE.
        /*  */
        /* SelectObjectObjFirm */
        /*  */
        THIS-OBJECT:SelectObjectObjFirm:Font = NEW System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.75), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
        THIS-OBJECT:SelectObjectObjFirm:Location = NEW System.Drawing.Point(4, 39).
        THIS-OBJECT:SelectObjectObjFirm:Name = "SelectObjectObjFirm".
        THIS-OBJECT:SelectObjectObjFirm:Size = NEW System.Drawing.Size(130, 20).
        THIS-OBJECT:SelectObjectObjFirm:TabIndex = 1.
        THIS-OBJECT:SelectObjectObjFirm:TabStop = TRUE.
        THIS-OBJECT:SelectObjectObjFirm:Text = "Все по фирме".
        THIS-OBJECT:SelectObjectObjFirm:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:SelectObjectObjFirm:UseVisualStyleBackColor = TRUE.
        THIS-OBJECT:SelectObjectObjFirm:CheckedChanged:Subscribe(THIS-OBJECT:SelectObjectObjFirm_CheckedChanged).
        /*  */
        /* SelectObjectObjCurr */
        /*  */
        THIS-OBJECT:SelectObjectObjCurr:Font = NEW System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.75), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
        THIS-OBJECT:SelectObjectObjCurr:Location = NEW System.Drawing.Point(3, 65).
        THIS-OBJECT:SelectObjectObjCurr:Name = "SelectObjectObjCurr".
        THIS-OBJECT:SelectObjectObjCurr:Size = NEW System.Drawing.Size(104, 20).
        THIS-OBJECT:SelectObjectObjCurr:TabIndex = 2.
        THIS-OBJECT:SelectObjectObjCurr:TabStop = TRUE.
        THIS-OBJECT:SelectObjectObjCurr:Text = "Текущий".
        THIS-OBJECT:SelectObjectObjCurr:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:SelectObjectObjCurr:UseVisualStyleBackColor = TRUE.
        THIS-OBJECT:SelectObjectObjCurr:CheckedChanged:Subscribe(THIS-OBJECT:SelectObjectObjCurr_CheckedChanged).
        /*  */
        /* SelectObjectObjChoice */
        /*  */
        THIS-OBJECT:SelectObjectObjChoice:Font = NEW System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.75), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
        THIS-OBJECT:SelectObjectObjChoice:Location = NEW System.Drawing.Point(4, 91).
        THIS-OBJECT:SelectObjectObjChoice:Name = "SelectObjectObjChoice".
        THIS-OBJECT:SelectObjectObjChoice:Size = NEW System.Drawing.Size(104, 20).
        THIS-OBJECT:SelectObjectObjChoice:TabIndex = 3.
        THIS-OBJECT:SelectObjectObjChoice:TabStop = TRUE.
        THIS-OBJECT:SelectObjectObjChoice:Text = "Выборочно".
        THIS-OBJECT:SelectObjectObjChoice:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:SelectObjectObjChoice:UseVisualStyleBackColor = TRUE.
        THIS-OBJECT:SelectObjectObjChoice:CheckedChanged:Subscribe(THIS-OBJECT:SelectObjectObjChoice_CheckedChanged).
        /*  */
        /* SelectObjectAll */
        /*  */
        THIS-OBJECT:SelectObjectAll:Font = NEW System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.75), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
        THIS-OBJECT:SelectObjectAll:Location = NEW System.Drawing.Point(4, 117).
        THIS-OBJECT:SelectObjectAll:Name = "SelectObjectAll".
        THIS-OBJECT:SelectObjectAll:Size = NEW System.Drawing.Size(104, 20).
        THIS-OBJECT:SelectObjectAll:TabIndex = 4.
        THIS-OBJECT:SelectObjectAll:TabStop = TRUE.
        THIS-OBJECT:SelectObjectAll:Text = "Все".
        THIS-OBJECT:SelectObjectAll:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:SelectObjectAll:UseVisualStyleBackColor = TRUE.
        THIS-OBJECT:SelectObjectAll:CheckedChanged:Subscribe(THIS-OBJECT:SelectObjectAll_CheckedChanged).
        /*  */
        /* BtnObj */
        /*  */
        THIS-OBJECT:BtnObj:Image = CAST(resources:GetObject("BtnObj.Image"), System.Drawing.Image).
        THIS-OBJECT:BtnObj:Location = NEW System.Drawing.Point(134, 91).
        THIS-OBJECT:BtnObj:Name = "BtnObj".
        THIS-OBJECT:BtnObj:Size = NEW System.Drawing.Size(20, 20).
        THIS-OBJECT:BtnObj:TabIndex = 5.
        THIS-OBJECT:BtnObj:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:BtnObj:UseVisualStyleBackColor = TRUE.
        THIS-OBJECT:BtnObj:Click:Subscribe(THIS-OBJECT:BtnObj_Click).
        /*  */
        /* ObjCount */
        /*  */
        DEFINE VARIABLE nestedvar0 AS System.Windows.Forms.AnchorStyles NO-UNDO.
        nestedvar0 = CAST(Progress.Util.EnumHelper:Or(CAST(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Bottom), System.Windows.Forms.AnchorStyles), System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
        THIS-OBJECT:ObjCount:Anchor = CAST(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
        THIS-OBJECT:ObjCount:Enabled = FALSE.
        THIS-OBJECT:ObjCount:Font = NEW System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.75), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
        THIS-OBJECT:ObjCount:Location = NEW System.Drawing.Point(4, 143).
        THIS-OBJECT:ObjCount:Multiline = TRUE.
        THIS-OBJECT:ObjCount:Name = "ObjCount".
        THIS-OBJECT:ObjCount:Size = NEW System.Drawing.Size(167, 34).
        THIS-OBJECT:ObjCount:TabIndex = 6.
        THIS-OBJECT:ObjCount:TextChanged:Subscribe(THIS-OBJECT:ObjCount_TextChanged).
        /*  */
        /* sobj */
        /*  */
        THIS-OBJECT:AutoScaleDimensions = NEW System.Drawing.SizeF(Progress.Util.CastUtil:ToSingle(6), Progress.Util.CastUtil:ToSingle(13)).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:ObjCount).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:BtnObj).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:SelectObjectAll).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:SelectObjectObjChoice).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:SelectObjectObjCurr).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:SelectObjectObjFirm).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:TEXT1).
        THIS-OBJECT:Name = "sobj".
        THIS-OBJECT:Size = NEW System.Drawing.Size(174, 180).
        THIS-OBJECT:ResumeLayout(FALSE).
        THIS-OBJECT:PerformLayout().
        CATCH e AS Progress.Lang.Error:
            UNDO, THROW e.
        END CATCH.
   end method.

   destructor public sobj ( ):
      delete object mTrgLoc.
   end destructor.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	METHOD PRIVATE VOID ObjCount_TextChanged( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
	
		RETURN.

	END METHOD.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void SelectObjectAll_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
	   if SelectObjectAll:Checked
	   then
		   VALUE-CHANGED_SelectObject().
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void SelectObjectObjChoice_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		if SelectObjectObjChoice:Checked
      then
         VALUE-CHANGED_SelectObject().
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void SelectObjectObjCurr_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		if SelectObjectObjCurr:Checked
      then
         VALUE-CHANGED_SelectObject().
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void SelectObjectObjFirm_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		if SelectObjectObjFirm:Checked
      then
         VALUE-CHANGED_SelectObjectF().              /* Все по фирме */
		return.

	end method.

   method private character verify-obj():
      mTrgLoc:verify-obj () no-error.
      if error-status:error then return error.
   end.
   

   method private void CHOOSE_BUTTON-obj ():
/*      assign SelectObject.*/
/*      my-request = false .*/
      mtrgloc:select-objects-proc (false) .
   end.
  
   method private void VALUE-CHANGED_SelectObject():
      /*Assign SelectObject.*/
      mtrgloc:select-objects-proc (no) .
      val-obj () .
      mtrgloc:VALUE-CHANGED_SelectObject(stype:SelectObjectchar(SelectObject)).
      ObjCount:text = mTrgLoc:Assign-frame(SelectObject).

   end.
   
   method private void VALUE-CHANGED_SelectObjectF():
      VALUE-CHANGED_SelectObject().
      ObjCount:text = "Выбор объекта: Все по фирме" .
   end.

   method private void display-obj ():
      /*Обработка 3 параметра - ОБЬЕКТЫ - как показывать блок с выбором объектов */

      define variable v-temp-str  as character no-undo .
      define variable J#          as integer   no-undo .
      define variable L#          as integer   no-undo .
      define variable RET#        as logical   no-undo .
      define variable R#          as integer   no-undo .

      /* IF temp-param-obj = ""
       then DO:
          disable TEXT-1 BUTTON-obj SelectObject Obj-count   with frame {&FRAME-NAME} .
          hide    TEXT-1  BUTTON-obj SelectObject Obj-count   in frame {&FRAME-NAME} .
       End.
       Else DO:  enable TEXT-1 with frame {&FRAME-NAME} .
                 display TEXT-1  SelectObject Obj-count  with frame {&FRAME-NAME} .
      */           
   /* disable radio-set по номеру */
     SelectObject_disable = mTrgLoc:ParamForm:temp-param-obj.
/*    { rep/radiohid.i temp-param-obj SelectObject}*/
  /*    if stype:SelectObjectchar(SelectObject) = {&obj-choice} 
      then do:
        if not can-find (first userobjs_temp-user-obj) then do:
         /*
         message 'заполняем из X-init_obj-list ' skip 'qqq' .
         */
          for each X-init_obj-list:
                create userobjs_temp-user-obj.
                assign
                  userobjs_temp-user-obj.obj-code = X-init_obj-list.obj-code
                  userobjs_temp-user-obj.obj-type = X-init_obj-list.obj-type
                .
          end.
         end.
    end.
*/
      if (mTrgLoc:ParamObj:my-cntxt-obj-type = {&stock} and mTrgLoc:ParamForm:temp-param-obj-type = 'shop')
      or (mTrgLoc:ParamObj:my-cntxt-obj-type = {&shop}  and mTrgLoc:ParamForm:temp-param-obj-type = 'stock')
      then do:
         SelectObject_disable = sType:SelectObjectchar(3).
         value-changed_selectobject().
      end.
   end.

   
   method private void val-obj ():
      BtnObj:enabled = selectobject eq stype:SelectObjectLbl({&obj-choice}).
   end.
   
   method public void Assign-frame():
      mTrgLoc:set_SelectObject(SelectObject).
      mTrgLoc:set_TextLb( TEXT1:text).
      ObjCount:text = mTrgLoc:Assign-frame(SelectObject).
   end.
   
   method public void local-apply-layout(iparamObj as class ibs.th.ref.sobj.sParamObj):
      if     iparamObj:X-SelectObject ne ?
         and iparamObj:X-SelectObject ne ""
      then 
         SelectObject = stype:SelectObjectLbl(iparamObj:X-SelectObject).
      display-obj ().
      val-obj () .
      if iparamObj:X-SelectObject = {&obj-all} then mTrgLoc:sss().
      if iparamObj:X-SelectObject = {&obj-firm} then mTrgLoc:sss().
      mTrgLoc:verify-check-currency () .
      if iparamObj:params-only-mode  = {&lookup} 
      then 
         SelectObject_disable = "".
   end method.

   method public void local-initialize(iparamObj as class ibs.th.ref.sobj.sParamObj):
      if    iparamObj:my-cntxt-level = {&cntxt-firm}  
         or iparamObj:my-cntxt-level = {&cntxt-global}   
      then do:
        assign
          SelectObjectObjCurr:visible = no.
      end.
      /* else do:
       assign
          SelectObject :radio-buttons =
              "Все по фирме" + {&comma-char} + {&obj-firm}
            + {&comma-char} + "Текущий" + {&comma-char} + {&obj-currency}
            + {&comma-char} + "Выборочно" + {&comma-char} + {&obj-choice}
            + {&comma-char} + "Все" + {&comma-char} + {&obj-all}
        .
        
      end.*/
      if ParamForm:temp-param-obj <> ""  
      then do:
         if not (    iparamObj:my-cntxt-level = {&cntxt-firm}  
                 or  iparamObj:my-cntxt-level = {&cntxt-global} )
         then    SelectObject =  stype:SelectObjectLbl({&obj-currency}) .

/*      Display SelectObject with frame {&frame-name}.*/
         if SelectObject =  stype:SelectObjectLbl({&obj-choice}) 
         then do:
            iparamObj:empty-obj-list().
         end.
         else do:
            iparamObj:create_obj-list(iparamObj:my-cntxt-obj-type, iparamObj:my-cntxt-obj-code ).
         end.
      end.
   end method.
   
   method public char AssignParam ():
       verify-obj() no-error.
       if error-status:error then return error.
   end method.
end class.