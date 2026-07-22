using Progress.Windows.Form.
block-level on error undo, throw.
class ibs.th.ref.counter.counterBrw inherits Form  final:
   define private variable codeDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable bindCounter as Progress.Data.BindingSource no-undo.
   define private variable components as System.ComponentModel.IContainer no-undo.
    define private variable buttonOk as System.Windows.Forms.Button no-undo.
    define private variable buttonCancel as System.Windows.Forms.Button no-undo.
   define private variable sysInfoDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable ruleDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable nameDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable keyDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable idDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable filenameDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable dataGridView1 as System.Windows.Forms.DataGridView no-undo.
   define private variable countValueDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define variable mCounterStor as class ibs.th.ref.counter.counterstorage.
   constructor public counterBrw( ):
      super().
      InitializeComponent ( ).
      mCounterStor = new ibs.th.ref.counter.counterstorage().
      bindCounter:handle = mCounterStor:getquery().
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end constructor.
   destructor public counterBrw( ):
      delete object mCounterStor.
      bindCounter:Dispose().
      if valid-object(components) then do:
         cast(components, System.IDisposable):Dispose().
      end.
   end destructor.
    method private void okButton_Click (sender as System.Object, e as System.EventArgs):
      bindCounter:Assign().
      mCounterStor:saveChange().
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
      tableDesc1 = new Progress.Data.TableDesc("counter").
      this-object:buttonOk = new System.Windows.Forms.Button().
      this-object:buttonCancel = new System.Windows.Forms.Button().
      this-object:bindCounter = new Progress.Data.BindingSource(this-object:components).
      this-object:dataGridView1 = new System.Windows.Forms.DataGridView().
      this-object:filenameDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:keyDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:codeDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:countValueDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:idDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:nameDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:ruleDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:sysInfoDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      cast(this-object:bindCounter, System.ComponentModel.ISupportInitialize):BeginInit().
      cast(this-object:dataGridView1, System.ComponentModel.ISupportInitialize):BeginInit().
      this-object:SuspendLayout().
      define variable nestedvar0 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar0 = System.Windows.Forms.AnchorStyles:Bottom.
      this-object:buttonOk:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:buttonOk:Location = new System.Drawing.Point(668, 468).
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
      this-object:buttonCancel:Location = new System.Drawing.Point(752, 468).
      this-object:buttonCancel:Name = "buttonCancel".
      this-object:buttonCancel:Size = new System.Drawing.Size(75, 23).
      this-object:buttonCancel:TabIndex = 1.
      this-object:buttonCancel:Text = "Cancel".
      this-object:buttonCancel:UseCompatibleTextRendering = true.
      this-object:buttonCancel:Click:Subscribe(this-object:cancelButton_Click).
      this-object:bindCounter:AutoUpdate = true.
      this-object:bindCounter:MaxDataGuess = 0.
      this-object:bindCounter:NoLOBs = false.
      this-object:bindCounter:Position = 0.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar0 as "Progress.Data.TableDesc[]" no-undo.
      arrayvar0 = new "Progress.Data.TableDesc[]"(0).
      tableDesc1:ChildTables = arrayvar0.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar1 as Progress.Data.ColumnPropDesc extent 8 no-undo.
      arrayvar1[1] = new Progress.Data.ColumnPropDesc("code", "Код Счетчика", Progress.Data.DataType:CHARACTER).
      arrayvar1[2] = new Progress.Data.ColumnPropDesc("CountValue", "Значение счетчика", Progress.Data.DataType:INT64).
      arrayvar1[3] = new Progress.Data.ColumnPropDesc("file-name", "Имя таблицы", Progress.Data.DataType:CHARACTER).
      arrayvar1[4] = new Progress.Data.ColumnPropDesc("id", "id", Progress.Data.DataType:INT64).
      arrayvar1[5] = new Progress.Data.ColumnPropDesc("key", "Ключ записи", Progress.Data.DataType:CHARACTER).
      arrayvar1[6] = new Progress.Data.ColumnPropDesc("name", "Наименование счетчика", Progress.Data.DataType:CHARACTER).
      arrayvar1[7] = new Progress.Data.ColumnPropDesc("Rule", "Правила", Progress.Data.DataType:CHARACTER).
      arrayvar1[8] = new Progress.Data.ColumnPropDesc("sysInfo", "Системная информация", Progress.Data.DataType:CHARACTER).
      tableDesc1:Columns = arrayvar1.
      this-object:bindCounter:TableSchema = tableDesc1.
      this-object:dataGridView1:AllowUserToAddRows = false.
      this-object:dataGridView1:AllowUserToDeleteRows = false.
      define variable nestedvar2 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar2 = cast(Progress.Util.EnumHelper:Or(cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Bottom), System.Windows.Forms.AnchorStyles), System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:dataGridView1:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar2, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:dataGridView1:AutoGenerateColumns = false.
      this-object:dataGridView1:AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode:DisplayedCells.
      this-object:dataGridView1:BorderStyle = System.Windows.Forms.BorderStyle:Fixed3D.
      this-object:dataGridView1:ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode:AutoSize.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar2 as System.Windows.Forms.DataGridViewColumn extent 8 no-undo.
      arrayvar2[1] = this-object:filenameDataGridViewTextBoxColumn.
      arrayvar2[2] = this-object:keyDataGridViewTextBoxColumn.
      arrayvar2[3] = this-object:codeDataGridViewTextBoxColumn.
      arrayvar2[4] = this-object:countValueDataGridViewTextBoxColumn.
      arrayvar2[5] = this-object:idDataGridViewTextBoxColumn.
      arrayvar2[6] = this-object:nameDataGridViewTextBoxColumn.
      arrayvar2[7] = this-object:ruleDataGridViewTextBoxColumn.
      arrayvar2[8] = this-object:sysInfoDataGridViewTextBoxColumn.
      this-object:dataGridView1:Columns:AddRange(arrayvar2).
      this-object:dataGridView1:DataSource = this-object:bindCounter.
      this-object:dataGridView1:Location = new System.Drawing.Point(13, 30).
      this-object:dataGridView1:Name = "dataGridView1".
      this-object:dataGridView1:Size = new System.Drawing.Size(816, 387).
      this-object:dataGridView1:TabIndex = 2.
      this-object:filenameDataGridViewTextBoxColumn:DataPropertyName = "file-name".
      this-object:filenameDataGridViewTextBoxColumn:HeaderText = "Имя таблицы".
      this-object:filenameDataGridViewTextBoxColumn:Name = "filenameDataGridViewTextBoxColumn".
      this-object:filenameDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:filenameDataGridViewTextBoxColumn:Width = 92.
      this-object:keyDataGridViewTextBoxColumn:DataPropertyName = "key".
      this-object:keyDataGridViewTextBoxColumn:HeaderText = "Ключ записи".
      this-object:keyDataGridViewTextBoxColumn:Name = "keyDataGridViewTextBoxColumn".
      this-object:keyDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:keyDataGridViewTextBoxColumn:Width = 89.
      this-object:codeDataGridViewTextBoxColumn:DataPropertyName = "code".
      this-object:codeDataGridViewTextBoxColumn:HeaderText = "Код Счетчика".
      this-object:codeDataGridViewTextBoxColumn:Name = "codeDataGridViewTextBoxColumn".
      this-object:codeDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:codeDataGridViewTextBoxColumn:Width = 92.
      this-object:countValueDataGridViewTextBoxColumn:DataPropertyName = "CountValue".
      this-object:countValueDataGridViewTextBoxColumn:HeaderText = "Значение счетчика".
      this-object:countValueDataGridViewTextBoxColumn:Name = "countValueDataGridViewTextBoxColumn".
      this-object:countValueDataGridViewTextBoxColumn:Width = 117.
      this-object:idDataGridViewTextBoxColumn:DataPropertyName = "id".
      this-object:idDataGridViewTextBoxColumn:HeaderText = "id".
      this-object:idDataGridViewTextBoxColumn:Name = "idDataGridViewTextBoxColumn".
      this-object:idDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:idDataGridViewTextBoxColumn:Visible = false.
      this-object:idDataGridViewTextBoxColumn:Width = 40.
      this-object:nameDataGridViewTextBoxColumn:DataPropertyName = "name".
      this-object:nameDataGridViewTextBoxColumn:HeaderText = "Наименование счетчика".
      this-object:nameDataGridViewTextBoxColumn:Name = "nameDataGridViewTextBoxColumn".
      this-object:nameDataGridViewTextBoxColumn:Width = 142.
      this-object:ruleDataGridViewTextBoxColumn:DataPropertyName = "Rule".
      this-object:ruleDataGridViewTextBoxColumn:HeaderText = "Правила".
      this-object:ruleDataGridViewTextBoxColumn:Name = "ruleDataGridViewTextBoxColumn".
      this-object:ruleDataGridViewTextBoxColumn:Width = 76.
      this-object:sysInfoDataGridViewTextBoxColumn:DataPropertyName = "sysInfo".
      this-object:sysInfoDataGridViewTextBoxColumn:HeaderText = "Системная информация".
      this-object:sysInfoDataGridViewTextBoxColumn:Name = "sysInfoDataGridViewTextBoxColumn".
      this-object:sysInfoDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:sysInfoDataGridViewTextBoxColumn:Width = 141.
      this-object:AcceptButton = this-object:buttonOk.
      this-object:CancelButton = this-object:buttonCancel.
      this-object:ClientSize = new System.Drawing.Size(841, 505).
      this-object:Controls:Add(this-object:dataGridView1).
      this-object:Controls:Add(this-object:buttonCancel).
      this-object:Controls:Add(this-object:buttonOk).
      this-object:FormBorderStyle = System.Windows.Forms.FormBorderStyle:FixedDialog.
      this-object:MaximizeBox = false.
      this-object:MinimizeBox = false.
      this-object:Name = "counterBrw".
      this-object:ShowInTaskbar = false.
      this-object:StartPosition = System.Windows.Forms.FormStartPosition:CenterParent.
      this-object:Text = "counterBrw".
      cast(this-object:bindCounter, System.ComponentModel.ISupportInitialize):EndInit().
      cast(this-object:dataGridView1, System.ComponentModel.ISupportInitialize):EndInit().
      this-object:ResumeLayout(false).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end method.
   method public void ShowModalDialog(  ):
      wait-for this-object:ShowDialog().
   end method.
end class.
