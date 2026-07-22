using Progress.Windows.Form.
block-level on error undo, throw.
class ibs.th.ref.xproc.attr inherits Form :
   define private variable attrvalueDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable attrnameDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable attrcodeDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable bindattr as Progress.Data.BindingSource no-undo.
   define private variable btnEdit as System.Windows.Forms.ToolStripButton no-undo.
   define private variable BtnAll as System.Windows.Forms.ToolStripButton no-undo.
   define private variable components as System.ComponentModel.IContainer no-undo.
    define private variable buttonOk as System.Windows.Forms.Button no-undo.
    define private variable buttonCancel as System.Windows.Forms.Button no-undo.
   define private variable dataatrr as System.Windows.Forms.DataGridView no-undo.
   define private variable mandatoryfDataGridViewCheckBoxColumn as System.Windows.Forms.DataGridViewCheckBoxColumn no-undo.
    define variable mtrg as class ibs.th.ref.xproc.attr_trg no-undo.
   define private variable toolStrip1 as System.Windows.Forms.ToolStrip no-undo.
   constructor public attr( ):
      super().
      InitializeComponent ( ).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end constructor.
   constructor public attr(itrg as ibs.th.ref.xproc.attr_trg ):
      super().
      InitializeComponent ( ).
      mtrg = itrg.
      bindattr:handle = mtrg:getQuery("tt-attr").
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end constructor.
   destructor public attr( ):
      if valid-object(components) then do:
         cast(components, System.IDisposable):Dispose().
      end.
   end destructor.
        @VisualDesigner.
        method private void BtnAll_Click( input sender as System.Object, input e as System.EventArgs ):
                mtrg:mAll = not mtrg:mAll.
                bindattr:handle = mtrg:getQuery("tt-attr").
                bindattr:RefreshAll().
                return.
        end method.
        @VisualDesigner.
        method private void btnEdit_Click( input sender as System.Object, input e as System.EventArgs ):
                editattr().
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
      this-object:components = new System.ComponentModel.Container().
      @VisualDesigner.FormMember (NeedsInitialize="true").
      define variable tableDesc1 as Progress.Data.TableDesc no-undo.
      tableDesc1 = new Progress.Data.TableDesc("utd-attr").
      @VisualDesigner.FormMember (NeedsInitialize="true").
      define variable resources as Progress.Util.ResourceManager no-undo.
      resources = new Progress.Util.ResourceManager("ibs.th.ref.xproc.attr").
      this-object:buttonOk = new System.Windows.Forms.Button().
      this-object:buttonCancel = new System.Windows.Forms.Button().
      this-object:dataatrr = new System.Windows.Forms.DataGridView().
      this-object:attrcodeDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:attrnameDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:attrvalueDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:mandatoryfDataGridViewCheckBoxColumn = new System.Windows.Forms.DataGridViewCheckBoxColumn().
      this-object:bindattr = new Progress.Data.BindingSource(this-object:components).
      this-object:toolStrip1 = new System.Windows.Forms.ToolStrip().
      this-object:btnEdit = new System.Windows.Forms.ToolStripButton().
      this-object:BtnAll = new System.Windows.Forms.ToolStripButton().
      cast(this-object:dataatrr, System.ComponentModel.ISupportInitialize):BeginInit().
      cast(this-object:bindattr, System.ComponentModel.ISupportInitialize):BeginInit().
      this-object:toolStrip1:SuspendLayout().
      this-object:SuspendLayout().
      define variable nestedvar0 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar0 = System.Windows.Forms.AnchorStyles:Bottom.
      this-object:buttonOk:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:buttonOk:Location = new System.Drawing.Point(285, 388).
      this-object:buttonOk:Name = "buttonOk".
      this-object:buttonOk:Size = new System.Drawing.Size(75, 23).
      this-object:buttonOk:TabIndex = 0.
      this-object:buttonOk:Text = "OK".
      this-object:buttonOk:UseCompatibleTextRendering = true.
      this-object:buttonOk:Click:Subscribe(this-object:okButton_Click).
      define variable nestedvar1 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar1 = System.Windows.Forms.AnchorStyles:Bottom.
      this-object:buttonCancel:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar1, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:buttonCancel:DialogResult = System.Windows.Forms.DialogResult:Cancel.
      this-object:buttonCancel:Location = new System.Drawing.Point(369, 388).
      this-object:buttonCancel:Name = "buttonCancel".
      this-object:buttonCancel:Size = new System.Drawing.Size(75, 23).
      this-object:buttonCancel:TabIndex = 1.
      this-object:buttonCancel:Text = "Cancel".
      this-object:buttonCancel:UseCompatibleTextRendering = true.
      this-object:buttonCancel:Click:Subscribe(this-object:cancelButton_Click).
      this-object:dataatrr:AllowUserToAddRows = false.
      this-object:dataatrr:AllowUserToDeleteRows = false.
      this-object:dataatrr:AutoGenerateColumns = false.
      this-object:dataatrr:ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode:AutoSize.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar0 as System.Windows.Forms.DataGridViewColumn extent 4 no-undo.
      arrayvar0[1] = this-object:attrcodeDataGridViewTextBoxColumn.
      arrayvar0[2] = this-object:attrnameDataGridViewTextBoxColumn.
      arrayvar0[3] = this-object:attrvalueDataGridViewTextBoxColumn.
      arrayvar0[4] = this-object:mandatoryfDataGridViewCheckBoxColumn.
      this-object:dataatrr:Columns:AddRange(arrayvar0).
      this-object:dataatrr:DataSource = this-object:bindattr.
      this-object:dataatrr:Location = new System.Drawing.Point(13, 51).
      this-object:dataatrr:Name = "dataatrr".
      this-object:dataatrr:ReadOnly = true.
      this-object:dataatrr:RowHeadersVisible = false.
      this-object:dataatrr:Size = new System.Drawing.Size(431, 319).
      this-object:dataatrr:TabIndex = 2.
      this-object:attrcodeDataGridViewTextBoxColumn:DataPropertyName = "attr-code".
      this-object:attrcodeDataGridViewTextBoxColumn:HeaderText = "Код".
      this-object:attrcodeDataGridViewTextBoxColumn:Name = "attrcodeDataGridViewTextBoxColumn".
      this-object:attrcodeDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:attrnameDataGridViewTextBoxColumn:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:Fill.
      this-object:attrnameDataGridViewTextBoxColumn:DataPropertyName = "attr-name".
      this-object:attrnameDataGridViewTextBoxColumn:HeaderText = "Наименование".
      this-object:attrnameDataGridViewTextBoxColumn:Name = "attrnameDataGridViewTextBoxColumn".
      this-object:attrnameDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:attrvalueDataGridViewTextBoxColumn:DataPropertyName = "attr-value".
      this-object:attrvalueDataGridViewTextBoxColumn:HeaderText = "Значение".
      this-object:attrvalueDataGridViewTextBoxColumn:Name = "attrvalueDataGridViewTextBoxColumn".
      this-object:attrvalueDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:mandatoryfDataGridViewCheckBoxColumn:DataPropertyName = "mandatoryf".
      this-object:mandatoryfDataGridViewCheckBoxColumn:HeaderText = "Обязательный".
      this-object:mandatoryfDataGridViewCheckBoxColumn:Name = "mandatoryfDataGridViewCheckBoxColumn".
      this-object:mandatoryfDataGridViewCheckBoxColumn:ReadOnly = true.
      this-object:bindattr:MaxDataGuess = 0.
      this-object:bindattr:NoLOBs = false.
      this-object:bindattr:Position = 0.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar1 as "Progress.Data.TableDesc[]" no-undo.
      arrayvar1 = new "Progress.Data.TableDesc[]"(0).
      tableDesc1:ChildTables = arrayvar1.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar2 as Progress.Data.ColumnPropDesc extent 5 no-undo.
      arrayvar2[1] = new Progress.Data.ColumnPropDesc("attr-code", "Код", Progress.Data.DataType:CHARACTER).
      arrayvar2[2] = new Progress.Data.ColumnPropDesc("attr-value", "Значение", Progress.Data.DataType:CHARACTER).
      arrayvar2[3] = new Progress.Data.ColumnPropDesc("recidf", "recid", Progress.Data.DataType:RECID).
      arrayvar2[4] = new Progress.Data.ColumnPropDesc("mandatoryf", "Обязательный", Progress.Data.DataType:LOGICAL).
      arrayvar2[5] = new Progress.Data.ColumnPropDesc("attr-name", "Наименование", Progress.Data.DataType:CHARACTER).
      tableDesc1:Columns = arrayvar2.
      this-object:bindattr:TableSchema = tableDesc1.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar3 as System.Windows.Forms.ToolStripItem extent 2 no-undo.
      arrayvar3[1] = this-object:btnEdit.
      arrayvar3[2] = this-object:BtnAll.
      this-object:toolStrip1:Items:AddRange(arrayvar3).
      this-object:toolStrip1:Location = new System.Drawing.Point(0, 0).
      this-object:toolStrip1:Name = "toolStrip1".
      this-object:toolStrip1:Size = new System.Drawing.Size(458, 25).
      this-object:toolStrip1:TabIndex = 3.
      this-object:toolStrip1:Text = "toolStrip1".
      this-object:btnEdit:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
      this-object:btnEdit:Image = cast(resources:GetObject("btnEdit.Image"), System.Drawing.Image).
      this-object:btnEdit:ImageTransparentColor = System.Drawing.Color:Magenta.
      this-object:btnEdit:Name = "btnEdit".
      this-object:btnEdit:Size = new System.Drawing.Size(23, 22).
      this-object:btnEdit:Text = "toolStripButton1".
      this-object:btnEdit:Click:Subscribe(this-object:btnEdit_Click).
      this-object:BtnAll:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
      this-object:BtnAll:Image = cast(resources:GetObject("BtnAll.Image"), System.Drawing.Image).
      this-object:BtnAll:ImageTransparentColor = System.Drawing.Color:Magenta.
      this-object:BtnAll:Name = "BtnAll".
      this-object:BtnAll:Size = new System.Drawing.Size(23, 22).
      this-object:BtnAll:Text = "toolStripButton1".
      this-object:BtnAll:Click:Subscribe(this-object:BtnAll_Click).
      this-object:AcceptButton = this-object:buttonOk.
      this-object:CancelButton = this-object:buttonCancel.
      this-object:ClientSize = new System.Drawing.Size(458, 425).
      this-object:Controls:Add(this-object:toolStrip1).
      this-object:Controls:Add(this-object:dataatrr).
      this-object:Controls:Add(this-object:buttonCancel).
      this-object:Controls:Add(this-object:buttonOk).
      this-object:FormBorderStyle = System.Windows.Forms.FormBorderStyle:FixedDialog.
      this-object:MaximizeBox = false.
      this-object:MinimizeBox = false.
      this-object:Name = "attr".
      this-object:ShowInTaskbar = false.
      this-object:StartPosition = System.Windows.Forms.FormStartPosition:CenterParent.
      this-object:Text = "Атрибуты".
      cast(this-object:dataatrr, System.ComponentModel.ISupportInitialize):EndInit().
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
   method public void editattr(  ):
      mtrg:editform().
      bindattr:Refresh().
   end.
end class.
