/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 2 марта 2021 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 2 марта 2021 г.

*/


using Progress.Windows.Form.
  
block-level on error undo, throw.
class ibs.th.ref.sobj.dreport inherits Form : 
   define variable vss-revision    as character no-undo init "$Revision:$":U .
   define variable vss-author      as character no-undo init "$Author:$":U .
   define variable vss-date        as character no-undo init "$Date:$":U .
   define variable vss-workfile    as character no-undo init "$Workfile:$":U .
   define variable vss-archive     as character no-undo init "$Archive:$":U .
   define variable vss-description as character no-undo init "Форма фильтров для отчетов ".
      
   define public  variable b_ach as System.Windows.Forms.Button no-undo.
   define private variable Blkp as System.Windows.Forms.Button no-undo.
   define private variable components as System.ComponentModel.IContainer no-undo.
   define private variable buttonOk as System.Windows.Forms.Button no-undo.
   define private variable buttonCancel as System.Windows.Forms.Button no-undo.
   
   define private variable panel1 as System.Windows.Forms.Panel no-undo.
   define public  variable splitContainer2 as System.Windows.Forms.SplitContainer no-undo.
   define public variable splitContainer1 as System.Windows.Forms.SplitContainer no-undo.
   define public variable splitContainer3 as System.Windows.Forms.SplitContainer no-undo.
   define public variable splitContainer4 as System.Windows.Forms.SplitContainer no-undo.
   define public variable splitContainer5 as System.Windows.Forms.SplitContainer no-undo.
   define private variable tabObject as System.Windows.Forms.TabPage no-undo.
   define private variable tabContin as System.Windows.Forms.TabPage no-undo.
   define private variable tabControl1 as System.Windows.Forms.TabControl no-undo.
   define public variable TogListHist as System.Windows.Forms.CheckBox no-undo.
   define public variable TogExcel  as System.Windows.Forms.CheckBox no-undo.
   define public variable mUserframe as ibs.th.ref.sobj.sUserFrame no-undo.
   define public variable mShift    as class ibs.th.ref.sobj.sShift no-undo.
   define public variable mGoods    as class ibs.th.ref.sobj.sGoods no-undo.
   define public variable mObj      as class ibs.th.ref.sobj.sobj no-undo.
   define public variable mSchet    as class ibs.th.ref.sobj.sSchet no-undo.
   define public variable mCurrency as class ibs.th.ref.sobj.sCurrency no-undo.
   define public variable mCustomer as class ibs.th.ref.sobj.sCustomer no-undo.
   define public  variable mListF   as class ibs.th.ref.sobj.slistf no-undo.
   define private variable mTRG   as class ibs.th.ref.sobj.dreportTrg no-undo.
   define variable mClass as character no-undo init "ibs.th.ref.sobj.rformtest".
   
   constructor public dreport( ):
      this-object(mClass).
      
   end constructor.
   
   constructor public dreport( iClass as character  ):
      super().
      InitializeComponent ( ).
      mClass = iclass.
      mUserframe = dynamic-new iClass ().
      mTRG = new  ibs.th.ref.sobj.dreportTrg().
      
      mUserframe:Dock = System.Windows.Forms.DockStyle:Fill.
      this-object:panel1:Controls:Add(mUserframe).
      
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.      

   end constructor.
   
   constructor public dreport( iClass as character,itrg as class ibs.th.ref.sobj.dreportTrg ):
      super().
      mTRG = itrg.
      InitializeComponent ( ).
      mUserframe = dynamic-new iClass ().
      mUserframe:Dock = System.Windows.Forms.DockStyle:Fill.
      mTRG:mDReport = this-object.
      this-object:panel1:Controls:Add(mUserframe).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.      

   end constructor.

   destructor public dreport( ):

      if valid-object(components) then do:
         cast(components, System.IDisposable):Dispose().
      end.

   end destructor.   

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void b_ach_Click( input sender as System.Object, input e as System.EventArgs ):
		mTRG:make-ach().
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void Blkp_Click( input sender as System.Object, input e as System.EventArgs ):
      if valid-object (mTRG) then mTRG:blbt().
		return.

	end method.

   method public logical canselForm():
      return buttonCancel:Focused. 
   end.
    method private void okButton_Click (sender as System.Object, e as System.EventArgs):
       if valid-object (mTRG) then mTRG:bOk().
       
     /* this-object:DialogResult = System.Windows.Forms.DialogResult:Ok.
      this-object:Close ( ).*/ 
   end method.

   method private void cancelButton_Click (sender as System.Object, e as System.EventArgs):
      this-object:DialogResult = System.Windows.Forms.DialogResult:Cancel.
      this-object:Close ( ).
   end method.
    
   method private void InitializeComponent ( ):

      /* NOTE: The following method is automatically generated.
         
         We strongly suggest that the contents of this method only be modified using the 
         Visual Designer to avoid any incompatible modifications.
         
         Modifying the contents of this method using a code editor will invalidate any support for this file. */
      
      @VisualDesigner.FormMember (NeedsInitialize="true").
      define variable resources as Progress.Util.ResourceManager no-undo.
      resources = new Progress.Util.ResourceManager("ibs.th.ref.sobj.dreport").
      this-object:buttonOk = new System.Windows.Forms.Button().
      this-object:buttonCancel = new System.Windows.Forms.Button().
      this-object:tabControl1 = new System.Windows.Forms.TabControl().
      this-object:tabObject = new System.Windows.Forms.TabPage().
      this-object:splitContainer5 = new System.Windows.Forms.SplitContainer().
      this-object:mShift = new ibs.th.ref.sobj.sShift().
      this-object:mCurrency = new ibs.th.ref.sobj.sCurrency().
      this-object:splitContainer1 = new System.Windows.Forms.SplitContainer().
      this-object:splitContainer2 = new System.Windows.Forms.SplitContainer().
      this-object:splitContainer4 = new System.Windows.Forms.SplitContainer().
      this-object:mGoods = new ibs.th.ref.sobj.sGoods().
      this-object:TogListHist = new System.Windows.Forms.CheckBox().
      this-object:TogExcel = new System.Windows.Forms.CheckBox().
      this-object:splitContainer3 = new System.Windows.Forms.SplitContainer().
      this-object:mObj = new ibs.th.ref.sobj.sobj().
      this-object:mSchet = new ibs.th.ref.sobj.sSchet().
      this-object:mCustomer = new ibs.th.ref.sobj.sCustomer().
      this-object:tabContin = new System.Windows.Forms.TabPage().
      this-object:panel1 = new System.Windows.Forms.Panel().
      this-object:Blkp = new System.Windows.Forms.Button().
      this-object:b_ach = new System.Windows.Forms.Button().
      this-object:tabControl1:SuspendLayout().
      this-object:tabObject:SuspendLayout().
      cast(this-object:splitContainer5, System.ComponentModel.ISupportInitialize):BeginInit().
      this-object:splitContainer5:Panel1:SuspendLayout().
      this-object:splitContainer5:Panel2:SuspendLayout().
      this-object:splitContainer5:SuspendLayout().
      cast(this-object:splitContainer1, System.ComponentModel.ISupportInitialize):BeginInit().
      this-object:splitContainer1:Panel1:SuspendLayout().
      this-object:splitContainer1:Panel2:SuspendLayout().
      this-object:splitContainer1:SuspendLayout().
      cast(this-object:splitContainer2, System.ComponentModel.ISupportInitialize):BeginInit().
      this-object:splitContainer2:Panel1:SuspendLayout().
      this-object:splitContainer2:Panel2:SuspendLayout().
      this-object:splitContainer2:SuspendLayout().
      cast(this-object:splitContainer4, System.ComponentModel.ISupportInitialize):BeginInit().
      this-object:splitContainer4:Panel1:SuspendLayout().
      this-object:splitContainer4:Panel2:SuspendLayout().
      this-object:splitContainer4:SuspendLayout().
      cast(this-object:splitContainer3, System.ComponentModel.ISupportInitialize):BeginInit().
      this-object:splitContainer3:Panel1:SuspendLayout().
      this-object:splitContainer3:Panel2:SuspendLayout().
      this-object:splitContainer3:SuspendLayout().
      this-object:tabContin:SuspendLayout().
      this-object:SuspendLayout().
      /*  */
      /* buttonOk */
      /*  */
      resources:ApplyResources(this-object:buttonOk, "buttonOk").
      this-object:buttonOk:Name = "buttonOk".
      this-object:buttonOk:UseCompatibleTextRendering = true.
      this-object:buttonOk:Click:Subscribe(this-object:okButton_Click).
      /*  */
      /* buttonCancel */
      /*  */
      this-object:buttonCancel:DialogResult = System.Windows.Forms.DialogResult:Cancel.
      resources:ApplyResources(this-object:buttonCancel, "buttonCancel").
      this-object:buttonCancel:Name = "buttonCancel".
      this-object:buttonCancel:UseCompatibleTextRendering = true.
      this-object:buttonCancel:Click:Subscribe(this-object:cancelButton_Click).
      /*  */
      /* tabControl1 */
      /*  */
      resources:ApplyResources(this-object:tabControl1, "tabControl1").
      this-object:tabControl1:Controls:Add(this-object:tabObject).
      this-object:tabControl1:Controls:Add(this-object:tabContin).
      this-object:tabControl1:Selected:Subscribe(this-object:tabControl1_Selected).
      this-object:tabControl1:Name = "tabControl1".
      this-object:tabControl1:SelectedIndex = 0.
      /*  */
      /* tabObject */
      /*  */
      this-object:tabObject:BackColor = System.Drawing.Color:Gainsboro.
      this-object:tabObject:BorderStyle = System.Windows.Forms.BorderStyle:Fixed3D.
      this-object:tabObject:Controls:Add(this-object:splitContainer5).
      this-object:tabObject:Controls:Add(this-object:splitContainer1).
      resources:ApplyResources(this-object:tabObject, "tabObject").
      this-object:tabObject:Name = "tabObject".
      this-object:tabObject:Click:Subscribe(this-object:tabPage1_Click).
      /*  */
      /* splitContainer5 */
      /*  */
      resources:ApplyResources(this-object:splitContainer5, "splitContainer5").
      this-object:splitContainer5:Name = "splitContainer5".
      /*  */
      /* splitContainer5.Panel1 */
      /*  */
      this-object:splitContainer5:Panel1:Controls:Add(this-object:mShift).
      /*  */
      /* splitContainer5.Panel2 */
      /*  */
      this-object:splitContainer5:Panel2:Controls:Add(this-object:mCurrency).
      /*  */
      /* mShift */
      /*  */
      this-object:mShift:AllowDrop = true.
      resources:ApplyResources(this-object:mShift, "mShift").
      this-object:mShift:BorderStyle = System.Windows.Forms.BorderStyle:Fixed3D.
      this-object:mShift:Name = "mShift".
      /*  */
      /* mCurrency */
      /*  */
      resources:ApplyResources(this-object:mCurrency, "mCurrency").
      this-object:mCurrency:BorderStyle = System.Windows.Forms.BorderStyle:Fixed3D.
      this-object:mCurrency:Name = "mCurrency".
      /*  */
      /* splitContainer1 */
      /*  */
      resources:ApplyResources(this-object:splitContainer1, "splitContainer1").
      this-object:splitContainer1:Name = "splitContainer1".
      /*  */
      /* splitContainer1.Panel1 */
      /*  */
      this-object:splitContainer1:Panel1:Controls:Add(this-object:splitContainer2).
      /*  */
      /* splitContainer1.Panel2 */
      /*  */
      this-object:splitContainer1:Panel2:Controls:Add(this-object:mCustomer).
      /*  */
      /* splitContainer2 */
      /*  */
      resources:ApplyResources(this-object:splitContainer2, "splitContainer2").
      this-object:splitContainer2:Name = "splitContainer2".
      /*  */
      /* splitContainer2.Panel1 */
      /*  */
      this-object:splitContainer2:Panel1:Controls:Add(this-object:splitContainer4).
      /*  */
      /* splitContainer2.Panel2 */
      /*  */
      this-object:splitContainer2:Panel2:Controls:Add(this-object:splitContainer3).
      this-object:splitContainer2:SplitterMoved:Subscribe(this-object:splitContainer2_SplitterMoved).
      /*  */
      /* splitContainer4 */
      /*  */
      resources:ApplyResources(this-object:splitContainer4, "splitContainer4").
      this-object:splitContainer4:Name = "splitContainer4".
      /*  */
      /* splitContainer4.Panel1 */
      /*  */
      this-object:splitContainer4:Panel1:Controls:Add(this-object:mGoods).
      /*  */
      /* splitContainer4.Panel2 */
      /*  */
      this-object:splitContainer4:Panel2:Controls:Add(this-object:TogListHist).
      this-object:splitContainer4:Panel2:Controls:Add(this-object:TogExcel).
      /*  */
      /* mGoods */
      /*  */
      this-object:mGoods:AllowDrop = true.
      resources:ApplyResources(this-object:mGoods, "mGoods").
      this-object:mGoods:BorderStyle = System.Windows.Forms.BorderStyle:Fixed3D.
      this-object:mGoods:Name = "mGoods".
      /*  */
      /* TogListHist */
      /*  */
      resources:ApplyResources(this-object:TogListHist, "TogListHist").
      this-object:TogListHist:Name = "TogListHist".
      this-object:TogListHist:UseCompatibleTextRendering = true.
      this-object:TogListHist:UseVisualStyleBackColor = true.
      this-object:TogListHist:CheckedChanged:Subscribe(this-object:TogListHist_CheckedChanged).
      /*  */
      /* TogExcel */
      /*  */
      resources:ApplyResources(this-object:TogExcel, "TogExcel").
      this-object:TogExcel:Name = "TogExcel".
      this-object:TogExcel:UseCompatibleTextRendering = true.
      this-object:TogExcel:UseVisualStyleBackColor = true.
      this-object:TogExcel:CheckedChanged:Subscribe(this-object:TogExcel_CheckedChanged).
      /*  */
      /* splitContainer3 */
      /*  */
      resources:ApplyResources(this-object:splitContainer3, "splitContainer3").
      this-object:splitContainer3:Name = "splitContainer3".
      /*  */
      /* splitContainer3.Panel1 */
      /*  */
      this-object:splitContainer3:Panel1:Controls:Add(this-object:mObj).
      /*  */
      /* splitContainer3.Panel2 */
      /*  */
      this-object:splitContainer3:Panel2:Controls:Add(this-object:mSchet).
      /*  */
      /* mObj */
      /*  */
      this-object:mObj:AllowDrop = true.
      resources:ApplyResources(this-object:mObj, "mObj").
      this-object:mObj:BorderStyle = System.Windows.Forms.BorderStyle:Fixed3D.
      this-object:mObj:Name = "mObj".
      /*  */
      /* mSchet */
      /*  */
      this-object:mSchet:AllowDrop = true.
      resources:ApplyResources(this-object:mSchet, "mSchet").
      this-object:mSchet:BorderStyle = System.Windows.Forms.BorderStyle:Fixed3D.
      this-object:mSchet:Name = "mSchet".
      /*  */
      /* mCustomer */
      /*  */
      resources:ApplyResources(this-object:mCustomer, "mCustomer").
      this-object:mCustomer:BorderStyle = System.Windows.Forms.BorderStyle:Fixed3D.
      this-object:mCustomer:Name = "mCustomer".
      /*  */
      /* tabContin */
      /*  */
      this-object:tabContin:BackColor = System.Drawing.Color:Gainsboro.
      this-object:tabContin:BorderStyle = System.Windows.Forms.BorderStyle:Fixed3D.
      this-object:tabContin:Controls:Add(this-object:panel1).
      resources:ApplyResources(this-object:tabContin, "tabContin").
      this-object:tabContin:Name = "tabContin".
      /*  */
      /* panel1 */
      /*  */
      resources:ApplyResources(this-object:panel1, "panel1").
      this-object:panel1:BackColor = System.Drawing.Color:Gainsboro.
      this-object:panel1:Name = "panel1".
      /*  */
      /* Blkp */
      /*  */
      resources:ApplyResources(this-object:Blkp, "Blkp").
      this-object:Blkp:Name = "Blkp".
      this-object:Blkp:UseCompatibleTextRendering = true.
      this-object:Blkp:UseVisualStyleBackColor = true.
      this-object:Blkp:Click:Subscribe(this-object:Blkp_Click).
      /*  */
      /* b_ach */
      /*  */
      resources:ApplyResources(this-object:b_ach, "b_ach").
      this-object:b_ach:Name = "b_ach".
      this-object:b_ach:UseCompatibleTextRendering = true.
      this-object:b_ach:UseVisualStyleBackColor = true.
      this-object:b_ach:Click:Subscribe(this-object:b_ach_Click).
      /*  */
      /* dreport */
      /*  */
      this-object:AcceptButton = this-object:buttonOk.
      this-object:AllowDrop = true.
      this-object:CancelButton = this-object:buttonCancel.
      resources:ApplyResources(this-object, "$this").
      this-object:Controls:Add(this-object:b_ach).
      this-object:Controls:Add(this-object:Blkp).
      this-object:Controls:Add(this-object:tabControl1).
      this-object:Controls:Add(this-object:buttonCancel).
      this-object:Controls:Add(this-object:buttonOk).
      this-object:MaximizeBox = false.
      this-object:MinimizeBox = false.
      this-object:Name = "dreport".
      this-object:tabControl1:ResumeLayout(false).
      this-object:tabObject:ResumeLayout(false).
      this-object:splitContainer5:Panel1:ResumeLayout(false).
      this-object:splitContainer5:Panel2:ResumeLayout(false).
      cast(this-object:splitContainer5, System.ComponentModel.ISupportInitialize):EndInit().
      this-object:splitContainer5:ResumeLayout(false).
      this-object:splitContainer1:Panel1:ResumeLayout(false).
      this-object:splitContainer1:Panel2:ResumeLayout(false).
      cast(this-object:splitContainer1, System.ComponentModel.ISupportInitialize):EndInit().
      this-object:splitContainer1:ResumeLayout(false).
      this-object:splitContainer2:Panel1:ResumeLayout(false).
      this-object:splitContainer2:Panel2:ResumeLayout(false).
      cast(this-object:splitContainer2, System.ComponentModel.ISupportInitialize):EndInit().
      this-object:splitContainer2:ResumeLayout(false).
      this-object:splitContainer4:Panel1:ResumeLayout(false).
      this-object:splitContainer4:Panel2:ResumeLayout(false).
      cast(this-object:splitContainer4, System.ComponentModel.ISupportInitialize):EndInit().
      this-object:splitContainer4:ResumeLayout(false).
      this-object:splitContainer3:Panel1:ResumeLayout(false).
      this-object:splitContainer3:Panel2:ResumeLayout(false).
      cast(this-object:splitContainer3, System.ComponentModel.ISupportInitialize):EndInit().
      this-object:splitContainer3:ResumeLayout(false).
      this-object:tabContin:ResumeLayout(false).
      this-object:ResumeLayout(false).
      {gbl\ed_date_cls.i this-object}
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end method. 
 
   method public void ShowModalDialog(  ):
      
      wait-for this-object:ShowDialog().

   end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void splitContainer2_SplitterMoved( input sender as System.Object, input e as System.Windows.Forms.SplitterEventArgs ):
		
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void tabPage1_Click( input sender as System.Object, input e as System.EventArgs ):
		
		return.

	end method.
	
   method public void params-only-mode_lookup( input ilookup as logical ):
      if ilookup
      then do:
         this-object:buttonCancel:text = '&Выход' .
         this-object:buttonOk:Visible  = no.
      end.
      else do:
         this-object:buttonOk:Text = '&Ввод' .
         this-object:buttonCancel:text = '&Отмена' .
      end.
      return.

   end method.

	/*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    method private void TogExcel_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
        VALUE-CHANGED_TOG-Excel().
        return.

    end method.
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    method private void tabControl1_Selected( input sender as System.Object, input e as System.EventArgs ):
        Mtrg:my_select()  .
        mUserframe:my-secected().
       
        return.

    end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void TogListHist_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		VALUE-CHANGED_TOG-list-hist().
		return.

	end method.

   /*
   method public void my-Var():
      mUserFrame:my-var(). 
   end.
   */
   
   method private void VALUE-CHANGED_TOG-Excel() /* Есть экспорт в Excel */
   :
      mtrg:VALUE-CHANGED_TOG-Excel(TogExcel:Checked).
   end.

   method private void  VALUE-CHANGED_TOG-list-hist() /* Печать истории формир. списков */
   :
      mtrg:VALUE-CHANGED_TOG-list-hist(TogListHist:Checked).
   end.


end class.
