 /*------------------------------------------------------------------------
    File        : Xattr
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : druban
    Created     : Sun Nov 08 11:12:53 MSK 2020
    Notes       : 
  ----------------------------------------------------------------------*/
using Progress.Windows.Form.
  
block-level on error undo, throw.
class ibs.th.ref.xproc.Xattr inherits Form : 

   define private variable bindattr as Progress.Data.BindingSource no-undo.
   define private variable btnlookup as System.Windows.Forms.ToolStripButton no-undo.
   define private variable btnEdit as System.Windows.Forms.ToolStripButton no-undo.
   define private variable btnDel as System.Windows.Forms.ToolStripButton no-undo.
   define private variable btnAdd as System.Windows.Forms.ToolStripButton no-undo.
   define private variable BtnExit as System.Windows.Forms.ToolStripButton no-undo.
   define private variable components as System.ComponentModel.IContainer no-undo.
   define private variable signinheritDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable progressFieldDataGridViewCheckBoxColumn as System.Windows.Forms.DataGridViewCheckBoxColumn no-undo.
   define private variable nameDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable descriptionDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable dataAttr as System.Windows.Forms.DataGridView no-undo.
   define private variable toolStrip1 as System.Windows.Forms.ToolStrip no-undo.
   define variable mtrg as class ibs.th.ref.xproc.xattr_trg no-undo.
   define private variable xattrCodeDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define variable mQrName as character no-undo init "xattr".
   constructor public Xattr( ):
   
      super().
      InitializeComponent ( ).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.      

   end constructor.

   constructor public Xattr (itrg as ibs.th.ref.xproc.xattr_trg ):
   
      super().
      InitializeComponent ( ).
      mTrg = itrg.
      bindattr:handle = mtrg:getquery("xattr").
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.      

   end constructor.

   destructor public Xattr( ):

      if valid-object(components) then do:
         cast(components, System.IDisposable):Dispose().
      end.

   end destructor.   

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void btnAdd_Click( input sender as System.Object, input e as System.EventArgs ):
		mtrg:addxattr().
      mtrg:getQuery(mQrName).
      bindattr:RefreshAll().
     
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void btnDel_Click( input sender as System.Object, input e as System.EventArgs ):
		if mtrg:delxattr()
      then do:
         mtrg:getQuery(mQrName).
         bindattr:RefreshAll().
      end.
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void btnEdit_Click( input sender as System.Object, input e as System.EventArgs ):
		mtrg:editxattr().
      bindattr:Refresh().
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void BtnExit_Click( input sender as System.Object, input e as System.EventArgs ):
		this-object:DialogResult = System.Windows.Forms.DialogResult:Cancel.
      this-object:Close ( ).
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void btnlookup_Click( input sender as System.Object, input e as System.EventArgs ):
		mtrg:lookxattr().
		return.

	end method.

    method private void okButton_Click (sender as System.Object, e as System.EventArgs):
      this-object:DialogResult = System.Windows.Forms.DialogResult:Ok.
      this-object:Close ( ). 
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
      
      this-object:components = new System.ComponentModel.Container().
      @VisualDesigner.FormMember (NeedsInitialize="true").
      define variable tableDesc1 as Progress.Data.TableDesc no-undo.
      tableDesc1 = new Progress.Data.TableDesc("Xattr").
      @VisualDesigner.FormMember (NeedsInitialize="true").
      define variable resources as Progress.Util.ResourceManager no-undo.
      resources = new Progress.Util.ResourceManager("ibs.th.ref.xproc.Xattr").
      this-object:dataAttr = new System.Windows.Forms.DataGridView().
      this-object:xattrCodeDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:descriptionDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:nameDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:progressFieldDataGridViewCheckBoxColumn = new System.Windows.Forms.DataGridViewCheckBoxColumn().
      this-object:signinheritDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:bindattr = new Progress.Data.BindingSource(this-object:components).
      this-object:toolStrip1 = new System.Windows.Forms.ToolStrip().
      this-object:BtnExit = new System.Windows.Forms.ToolStripButton().
      this-object:btnAdd = new System.Windows.Forms.ToolStripButton().
      this-object:btnEdit = new System.Windows.Forms.ToolStripButton().
      this-object:btnDel = new System.Windows.Forms.ToolStripButton().
      this-object:btnlookup = new System.Windows.Forms.ToolStripButton().
      cast(this-object:dataAttr, System.ComponentModel.ISupportInitialize):BeginInit().
      cast(this-object:bindattr, System.ComponentModel.ISupportInitialize):BeginInit().
      this-object:toolStrip1:SuspendLayout().
      this-object:SuspendLayout().
      /*  */
      /* dataAttr */
      /*  */
      this-object:dataAttr:AllowUserToAddRows = false.
      this-object:dataAttr:AllowUserToDeleteRows = false.
      this-object:dataAttr:AutoGenerateColumns = false.
      this-object:dataAttr:ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode:AutoSize.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar0 as System.Windows.Forms.DataGridViewColumn extent 5 no-undo.
      arrayvar0[1] = this-object:xattrCodeDataGridViewTextBoxColumn.
      arrayvar0[2] = this-object:descriptionDataGridViewTextBoxColumn.
      arrayvar0[3] = this-object:nameDataGridViewTextBoxColumn.
      arrayvar0[4] = this-object:progressFieldDataGridViewCheckBoxColumn.
      arrayvar0[5] = this-object:signinheritDataGridViewTextBoxColumn.
      this-object:dataAttr:Columns:AddRange(arrayvar0).
      this-object:dataAttr:DataSource = this-object:bindattr.
      this-object:dataAttr:Location = new System.Drawing.Point(12, 42).
      this-object:dataAttr:Name = "dataAttr".
      this-object:dataAttr:ReadOnly = true.
      this-object:dataAttr:RowHeadersVisible = false.
      this-object:dataAttr:Size = new System.Drawing.Size(578, 345).
      this-object:dataAttr:TabIndex = 2.
      /*  */
      /* xattrCodeDataGridViewTextBoxColumn */
      /*  */
      this-object:xattrCodeDataGridViewTextBoxColumn:DataPropertyName = "Xattr-Code".
      this-object:xattrCodeDataGridViewTextBoxColumn:HeaderText = "Код реквизита".
      this-object:xattrCodeDataGridViewTextBoxColumn:Name = "xattrCodeDataGridViewTextBoxColumn".
      this-object:xattrCodeDataGridViewTextBoxColumn:ReadOnly = true.
      /*  */
      /* descriptionDataGridViewTextBoxColumn */
      /*  */
      this-object:descriptionDataGridViewTextBoxColumn:DataPropertyName = "Description".
      this-object:descriptionDataGridViewTextBoxColumn:HeaderText = "Описание".
      this-object:descriptionDataGridViewTextBoxColumn:Name = "descriptionDataGridViewTextBoxColumn".
      this-object:descriptionDataGridViewTextBoxColumn:ReadOnly = true.
      /*  */
      /* nameDataGridViewTextBoxColumn */
      /*  */
      this-object:nameDataGridViewTextBoxColumn:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:Fill.
      this-object:nameDataGridViewTextBoxColumn:DataPropertyName = "Name".
      this-object:nameDataGridViewTextBoxColumn:HeaderText = "Наименование".
      this-object:nameDataGridViewTextBoxColumn:Name = "nameDataGridViewTextBoxColumn".
      this-object:nameDataGridViewTextBoxColumn:ReadOnly = true.
      /*  */
      /* progressFieldDataGridViewCheckBoxColumn */
      /*  */
      this-object:progressFieldDataGridViewCheckBoxColumn:DataPropertyName = "Progress-Field".
      this-object:progressFieldDataGridViewCheckBoxColumn:HeaderText = "Основной".
      this-object:progressFieldDataGridViewCheckBoxColumn:Name = "progressFieldDataGridViewCheckBoxColumn".
      this-object:progressFieldDataGridViewCheckBoxColumn:ReadOnly = true.
      this-object:progressFieldDataGridViewCheckBoxColumn:Width = 60.
      /*  */
      /* signinheritDataGridViewTextBoxColumn */
      /*  */
      this-object:signinheritDataGridViewTextBoxColumn:DataPropertyName = "sign-inherit".
      this-object:signinheritDataGridViewTextBoxColumn:HeaderText = "Признак наследования".
      this-object:signinheritDataGridViewTextBoxColumn:Name = "signinheritDataGridViewTextBoxColumn".
      this-object:signinheritDataGridViewTextBoxColumn:ReadOnly = true.
      /*  */
      /* bindattr */
      /*  */
      this-object:bindattr:MaxDataGuess = 0.
      this-object:bindattr:NoLOBs = false.
      this-object:bindattr:Position = 0.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar1 as "Progress.Data.TableDesc[]" no-undo.
      arrayvar1 = new "Progress.Data.TableDesc[]"(0).
      tableDesc1:ChildTables = arrayvar1.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar2 as Progress.Data.ColumnPropDesc extent 19 no-undo.
      arrayvar2[1] = new Progress.Data.ColumnPropDesc("Accuracy", "Точность", Progress.Data.DataType:INTEGER).
      arrayvar2[2] = new Progress.Data.ColumnPropDesc("Constant", "Неизменяемый", Progress.Data.DataType:LOGICAL).
      arrayvar2[3] = new Progress.Data.ColumnPropDesc("Data-Format", "Формат реквизита", Progress.Data.DataType:CHARACTER).
      arrayvar2[4] = new Progress.Data.ColumnPropDesc("Data-Type", "Тип реквизита", Progress.Data.DataType:CHARACTER).
      arrayvar2[5] = new Progress.Data.ColumnPropDesc("Description", "Описание", Progress.Data.DataType:CHARACTER).
      arrayvar2[6] = new Progress.Data.ColumnPropDesc("Domain-Code", "Домен", Progress.Data.DataType:CHARACTER).
      arrayvar2[7] = new Progress.Data.ColumnPropDesc("GroupObj-code", "Группа объекта", Progress.Data.DataType:CHARACTER).
      arrayvar2[8] = new Progress.Data.ColumnPropDesc("Hidden", "Скрытый", Progress.Data.DataType:LOGICAL).
      arrayvar2[9] = new Progress.Data.ColumnPropDesc("Initial", "Нач. значение", Progress.Data.DataType:CHARACTER).
      arrayvar2[10] = new Progress.Data.ColumnPropDesc("Mandatory", "Обязателен", Progress.Data.DataType:LOGICAL).
      arrayvar2[11] = new Progress.Data.ColumnPropDesc("Name", "Наименование", Progress.Data.DataType:CHARACTER).
      arrayvar2[12] = new Progress.Data.ColumnPropDesc("order", "Номер", Progress.Data.DataType:INTEGER).
      arrayvar2[13] = new Progress.Data.ColumnPropDesc("Overridable", "Переопределяемый", Progress.Data.DataType:LOGICAL).
      arrayvar2[14] = new Progress.Data.ColumnPropDesc("Progress-Field", "Основной", Progress.Data.DataType:LOGICAL).
      arrayvar2[15] = new Progress.Data.ColumnPropDesc("sign-inherit", "ПРИЗНАК!НАСЛЕДОВАНИЯ", Progress.Data.DataType:CHARACTER).
      arrayvar2[16] = new Progress.Data.ColumnPropDesc("Validation", "Валидация", Progress.Data.DataType:CHARACTER).
      arrayvar2[17] = new Progress.Data.ColumnPropDesc("xattr-clabel", "МЕТКА", Progress.Data.DataType:CHARACTER).
      arrayvar2[18] = new Progress.Data.ColumnPropDesc("Xattr-Code", "Код реквизита", Progress.Data.DataType:CHARACTER).
      arrayvar2[19] = new Progress.Data.ColumnPropDesc("xattr-label", "Метка", Progress.Data.DataType:CHARACTER).
      tableDesc1:Columns = arrayvar2.
      this-object:bindattr:TableSchema = tableDesc1.
      /*  */
      /* toolStrip1 */
      /*  */
      this-object:toolStrip1:ImageScalingSize = new System.Drawing.Size(32, 32).
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar3 as System.Windows.Forms.ToolStripItem extent 5 no-undo.
      arrayvar3[1] = this-object:BtnExit.
      arrayvar3[2] = this-object:btnAdd.
      arrayvar3[3] = this-object:btnEdit.
      arrayvar3[4] = this-object:btnDel.
      arrayvar3[5] = this-object:btnlookup.
      this-object:toolStrip1:Items:AddRange(arrayvar3).
      this-object:toolStrip1:Location = new System.Drawing.Point(0, 0).
      this-object:toolStrip1:Name = "toolStrip1".
      this-object:toolStrip1:Size = new System.Drawing.Size(602, 39).
      this-object:toolStrip1:TabIndex = 3.
      this-object:toolStrip1:Text = "toolStrip1".
      /*  */
      /* BtnExit */
      /*  */
      this-object:BtnExit:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
      this-object:BtnExit:Image = cast(resources:GetObject("BtnExit.Image"), System.Drawing.Image).
      this-object:BtnExit:ImageTransparentColor = System.Drawing.Color:Magenta.
      this-object:BtnExit:Name = "BtnExit".
      this-object:BtnExit:Size = new System.Drawing.Size(36, 36).
      this-object:BtnExit:Text = "Выход".
      this-object:BtnExit:Click:Subscribe(this-object:BtnExit_Click).
      /*  */
      /* btnAdd */
      /*  */
      this-object:btnAdd:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
      this-object:btnAdd:Image = cast(resources:GetObject("btnAdd.Image"), System.Drawing.Image).
      this-object:btnAdd:ImageTransparentColor = System.Drawing.Color:Magenta.
      this-object:btnAdd:Name = "btnAdd".
      this-object:btnAdd:Size = new System.Drawing.Size(36, 36).
      this-object:btnAdd:Text = "Добавить".
      this-object:btnAdd:Click:Subscribe(this-object:btnAdd_Click).
      /*  */
      /* btnEdit */
      /*  */
      this-object:btnEdit:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
      this-object:btnEdit:Image = cast(resources:GetObject("btnEdit.Image"), System.Drawing.Image).
      this-object:btnEdit:ImageTransparentColor = System.Drawing.Color:Magenta.
      this-object:btnEdit:Name = "btnEdit".
      this-object:btnEdit:Size = new System.Drawing.Size(36, 36).
      this-object:btnEdit:Text = "Изменить".
      this-object:btnEdit:Click:Subscribe(this-object:btnEdit_Click).
      /*  */
      /* btnDel */
      /*  */
      this-object:btnDel:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
      this-object:btnDel:Image = cast(resources:GetObject("btnDel.Image"), System.Drawing.Image).
      this-object:btnDel:ImageTransparentColor = System.Drawing.Color:Magenta.
      this-object:btnDel:Name = "btnDel".
      this-object:btnDel:Size = new System.Drawing.Size(36, 36).
      this-object:btnDel:Text = "Удалить".
      this-object:btnDel:Click:Subscribe(this-object:btnDel_Click).
      /*  */
      /* btnlookup */
      /*  */
      this-object:btnlookup:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
      this-object:btnlookup:Image = cast(resources:GetObject("btnlookup.Image"), System.Drawing.Image).
      this-object:btnlookup:ImageTransparentColor = System.Drawing.Color:Magenta.
      this-object:btnlookup:Name = "btnlookup".
      this-object:btnlookup:Size = new System.Drawing.Size(36, 36).
      this-object:btnlookup:Text = "Просмотр".
      this-object:btnlookup:Click:Subscribe(this-object:btnlookup_Click).
      /*  */
      /* Xattr */
      /*  */
      this-object:ClientSize = new System.Drawing.Size(602, 399).
      this-object:Controls:Add(this-object:toolStrip1).
      this-object:Controls:Add(this-object:dataAttr).
      this-object:FormBorderStyle = System.Windows.Forms.FormBorderStyle:FixedDialog.
      this-object:MaximizeBox = false.
      this-object:MinimizeBox = false.
      this-object:Name = "Xattr".
      this-object:ShowInTaskbar = false.
      this-object:StartPosition = System.Windows.Forms.FormStartPosition:CenterParent.
      this-object:Text = "Атрибуты".
      cast(this-object:dataAttr, System.ComponentModel.ISupportInitialize):EndInit().
      cast(this-object:bindattr, System.ComponentModel.ISupportInitialize):EndInit().
      this-object:toolStrip1:ResumeLayout(false).
      this-object:toolStrip1:PerformLayout().
      this-object:ResumeLayout(false).
      this-object:PerformLayout().
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end method. 
 
   method public void ShowModalDialog(  ):
      
      wait-for this-object:ShowDialog().

   end method.


 
end class.
