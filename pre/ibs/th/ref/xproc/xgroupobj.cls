using Progress.Windows.Form.
using ibs.th.ref.xproc.xgroupobj_trg from propath.
block-level on error undo, throw.
class ibs.th.ref.xproc.xgroupobj inherits Form :
   define private variable bindxgroup as Progress.Data.BindingSource no-undo.
   define private variable btnAdd as System.Windows.Forms.ToolStripButton no-undo.
   define private variable BtnExit as System.Windows.Forms.ToolStripButton no-undo.
   define private variable btnLook as System.Windows.Forms.ToolStripButton no-undo.
   define private variable Btndel as System.Windows.Forms.ToolStripButton no-undo.
   define private variable BtnEdit as System.Windows.Forms.ToolStripButton no-undo.
   define private variable components as System.ComponentModel.IContainer no-undo.
   define private variable nameDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable groupObjCodeDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable descriptionDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable NextLevel as System.Windows.Forms.ToolStripButton no-undo.
   define private variable toolStrip1 as System.Windows.Forms.ToolStrip no-undo.
   define private variable dataGridView1 as System.Windows.Forms.DataGridView no-undo.
   define variable mtrg as ibs.th.ref.xproc.xgroupobj_trg no-undo.
   define variable mQrName as character no-undo init "xgroupobj".
   constructor public xgroupobj( ):
      super().
      InitializeComponent ( ).
      mtrg = new ibs.th.ref.xproc.xgroupobj_trg().
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end constructor.
   destructor public xgroupobj( ):
      if valid-object(mtrg)
      then
         delete object mtrg.
      if valid-object(components) then do:
         cast(components, System.IDisposable):Dispose().
      end.
   end destructor.
        @VisualDesigner.
        method private void btnAdd_Click( input sender as System.Object, input e as System.EventArgs ):
                mtrg:addgroupobj().
                mtrg:getQuery(mQrName).
                bindxgroup:RefreshAll().
                NextLevel:visible = mtrg:validNextLevel().
                return.
        end method.
        @VisualDesigner.
        method private void Btndel_Click( input sender as System.Object, input e as System.EventArgs ):
                if mtrg:delgroupobj()
                then do:
                mtrg:getQuery(mQrName).
                bindxgroup:RefreshAll().
                NextLevel:visible = mtrg:validNextLevel().
                end.
                return.
        end method.
        @VisualDesigner.
        method private void BtnEdit_Click( input sender as System.Object, input e as System.EventArgs ):
                mtrg:editgroupobj().
                bindxgroup:Refresh().
                NextLevel:visible = mtrg:validNextLevel().
                return.
        end method.
        @VisualDesigner.
        method private void BtnExit_Click( input sender as System.Object, input e as System.EventArgs ):
           if mtrg:PrevLevel()
      then do:
         mtrg:getQuery(mQrName).
         bindxgroup:RefreshAll().
         NextLevel:visible = mtrg:validNextLevel().
      end.
      else do:
                this-object:DialogResult = System.Windows.Forms.DialogResult:Cancel.
      this-object:Close ( ).
      end.
                return.
        end method.
        @VisualDesigner.
        method private void btnLook_Click( input sender as System.Object, input e as System.EventArgs ):
                mtrg:lookgroupobj().
                return.
        end method.
        @VisualDesigner.
        method private void dataGridView1_CellClick( input sender as System.Object, input e as System.Windows.Forms.DataGridViewCellEventArgs ):
                NextLevel:visible = mtrg:validNextLevel().
                return.
        end method.
        @VisualDesigner.
        method private void dataGridView1_CellContextMenuStripNeeded( input sender as System.Object, input e as System.Windows.Forms.DataGridViewCellContextMenuStripNeededEventArgs ):
                mtrg:ViewMenu().
                return.
        end method.
        @VisualDesigner.
        method private void NextLevel_Click( input sender as System.Object, input e as System.EventArgs ):
           message
      view-as alert-box.
                mtrg:nextlevel().
                mtrg:getQuery(mQrName).
                bindxgroup:RefreshAll().
                NextLevel:visible = mtrg:validNextLevel().
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
      define variable dataGridViewCellStyle1 as System.Windows.Forms.DataGridViewCellStyle no-undo.
      dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle().
      @VisualDesigner.FormMember (NeedsInitialize="true").
      define variable dataGridViewCellStyle2 as System.Windows.Forms.DataGridViewCellStyle no-undo.
      dataGridViewCellStyle2 = new System.Windows.Forms.DataGridViewCellStyle().
      @VisualDesigner.FormMember (NeedsInitialize="true").
      define variable dataGridViewCellStyle3 as System.Windows.Forms.DataGridViewCellStyle no-undo.
      dataGridViewCellStyle3 = new System.Windows.Forms.DataGridViewCellStyle().
      @VisualDesigner.FormMember (NeedsInitialize="true").
      define variable tableDesc1 as Progress.Data.TableDesc no-undo.
      tableDesc1 = new Progress.Data.TableDesc("xGroupObj").
      @VisualDesigner.FormMember (NeedsInitialize="true").
      define variable resources as Progress.Util.ResourceManager no-undo.
      resources = new Progress.Util.ResourceManager("ibs.th.ref.xproc.xgroupobj").
      this-object:dataGridView1 = new System.Windows.Forms.DataGridView().
      this-object:groupObjCodeDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:nameDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:descriptionDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:bindxgroup = new Progress.Data.BindingSource(this-object:components).
      this-object:btnAdd = new System.Windows.Forms.ToolStripButton().
      this-object:toolStrip1 = new System.Windows.Forms.ToolStrip().
      this-object:BtnExit = new System.Windows.Forms.ToolStripButton().
      this-object:BtnEdit = new System.Windows.Forms.ToolStripButton().
      this-object:Btndel = new System.Windows.Forms.ToolStripButton().
      this-object:btnLook = new System.Windows.Forms.ToolStripButton().
      this-object:NextLevel = new System.Windows.Forms.ToolStripButton().
      cast(this-object:dataGridView1, System.ComponentModel.ISupportInitialize):BeginInit().
      cast(this-object:bindxgroup, System.ComponentModel.ISupportInitialize):BeginInit().
      this-object:toolStrip1:SuspendLayout().
      this-object:SuspendLayout().
      this-object:dataGridView1:AllowUserToAddRows = false.
      this-object:dataGridView1:AllowUserToDeleteRows = false.
      this-object:dataGridView1:AutoGenerateColumns = false.
      dataGridViewCellStyle1:Alignment = System.Windows.Forms.DataGridViewContentAlignment:MiddleLeft.
      dataGridViewCellStyle1:BackColor = System.Drawing.SystemColors:Control.
      dataGridViewCellStyle1:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(8.25), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      dataGridViewCellStyle1:ForeColor = System.Drawing.SystemColors:WindowText.
      dataGridViewCellStyle1:SelectionBackColor = System.Drawing.SystemColors:Highlight.
      dataGridViewCellStyle1:SelectionForeColor = System.Drawing.SystemColors:HighlightText.
      dataGridViewCellStyle1:WrapMode = System.Windows.Forms.DataGridViewTriState:True.
      this-object:dataGridView1:ColumnHeadersDefaultCellStyle = dataGridViewCellStyle1.
      this-object:dataGridView1:ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode:AutoSize.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar0 as System.Windows.Forms.DataGridViewColumn extent 3 no-undo.
      arrayvar0[1] = this-object:groupObjCodeDataGridViewTextBoxColumn.
      arrayvar0[2] = this-object:nameDataGridViewTextBoxColumn.
      arrayvar0[3] = this-object:descriptionDataGridViewTextBoxColumn.
      this-object:dataGridView1:Columns:AddRange(arrayvar0).
      this-object:dataGridView1:DataSource = this-object:bindxgroup.
      dataGridViewCellStyle2:Alignment = System.Windows.Forms.DataGridViewContentAlignment:MiddleLeft.
      dataGridViewCellStyle2:BackColor = System.Drawing.SystemColors:Window.
      dataGridViewCellStyle2:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(8.25), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      dataGridViewCellStyle2:ForeColor = System.Drawing.SystemColors:ControlText.
      dataGridViewCellStyle2:SelectionBackColor = System.Drawing.SystemColors:Highlight.
      dataGridViewCellStyle2:SelectionForeColor = System.Drawing.SystemColors:HighlightText.
      dataGridViewCellStyle2:WrapMode = System.Windows.Forms.DataGridViewTriState:False.
      this-object:dataGridView1:DefaultCellStyle = dataGridViewCellStyle2.
      this-object:dataGridView1:Location = new System.Drawing.Point(9, 61).
      this-object:dataGridView1:Name = "dataGridView1".
      this-object:dataGridView1:ReadOnly = true.
      dataGridViewCellStyle3:Alignment = System.Windows.Forms.DataGridViewContentAlignment:MiddleLeft.
      dataGridViewCellStyle3:BackColor = System.Drawing.SystemColors:Control.
      dataGridViewCellStyle3:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(8.25), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      dataGridViewCellStyle3:ForeColor = System.Drawing.SystemColors:WindowText.
      dataGridViewCellStyle3:SelectionBackColor = System.Drawing.SystemColors:Highlight.
      dataGridViewCellStyle3:SelectionForeColor = System.Drawing.SystemColors:HighlightText.
      dataGridViewCellStyle3:WrapMode = System.Windows.Forms.DataGridViewTriState:True.
      this-object:dataGridView1:RowHeadersDefaultCellStyle = dataGridViewCellStyle3.
      this-object:dataGridView1:RowHeadersVisible = false.
      this-object:dataGridView1:SelectionMode = System.Windows.Forms.DataGridViewSelectionMode:FullRowSelect.
      this-object:dataGridView1:Size = new System.Drawing.Size(716, 425).
      this-object:dataGridView1:TabIndex = 3.
      this-object:dataGridView1:CellClick:Subscribe(this-object:dataGridView1_CellClick).
      this-object:dataGridView1:CellContextMenuStripNeeded:Subscribe(this-object:dataGridView1_CellContextMenuStripNeeded).
      this-object:groupObjCodeDataGridViewTextBoxColumn:DataPropertyName = "GroupObj-Code".
      this-object:groupObjCodeDataGridViewTextBoxColumn:HeaderText = "Группа объектов".
      this-object:groupObjCodeDataGridViewTextBoxColumn:Name = "groupObjCodeDataGridViewTextBoxColumn".
      this-object:groupObjCodeDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:nameDataGridViewTextBoxColumn:DataPropertyName = "Name".
      this-object:nameDataGridViewTextBoxColumn:HeaderText = "Наименование".
      this-object:nameDataGridViewTextBoxColumn:Name = "nameDataGridViewTextBoxColumn".
      this-object:nameDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:descriptionDataGridViewTextBoxColumn:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:Fill.
      this-object:descriptionDataGridViewTextBoxColumn:DataPropertyName = "Description".
      this-object:descriptionDataGridViewTextBoxColumn:HeaderText = "Описание".
      this-object:descriptionDataGridViewTextBoxColumn:Name = "descriptionDataGridViewTextBoxColumn".
      this-object:descriptionDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:bindxgroup:MaxDataGuess = 0.
      this-object:bindxgroup:NoLOBs = false.
      this-object:bindxgroup:Position = 0.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar1 as "Progress.Data.TableDesc[]" no-undo.
      arrayvar1 = new "Progress.Data.TableDesc[]"(0).
      tableDesc1:ChildTables = arrayvar1.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar2 as Progress.Data.ColumnPropDesc extent 7 no-undo.
      arrayvar2[1] = new Progress.Data.ColumnPropDesc("Description", "Описание", Progress.Data.DataType:CHARACTER).
      arrayvar2[2] = new Progress.Data.ColumnPropDesc("GroupObj-Code", "групп объектов", Progress.Data.DataType:CHARACTER).
      arrayvar2[3] = new Progress.Data.ColumnPropDesc("Hierarchy", "Иерархия", Progress.Data.DataType:LOGICAL).
      arrayvar2[4] = new Progress.Data.ColumnPropDesc("Name", "Наименование", Progress.Data.DataType:CHARACTER).
      arrayvar2[5] = new Progress.Data.ColumnPropDesc("Parent-GroupObj", "Группы объектов-родители", Progress.Data.DataType:CHARACTER).
      arrayvar2[6] = new Progress.Data.ColumnPropDesc("Progress-Code", "Таблица Progress", Progress.Data.DataType:CHARACTER).
      arrayvar2[7] = new Progress.Data.ColumnPropDesc("Progress-Table", "Таблица", Progress.Data.DataType:LOGICAL).
      tableDesc1:Columns = arrayvar2.
      this-object:bindxgroup:TableSchema = tableDesc1.
      this-object:btnAdd:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
      this-object:btnAdd:Image = cast(resources:GetObject("btnAdd.Image"), System.Drawing.Image).
      this-object:btnAdd:ImageTransparentColor = System.Drawing.Color:Magenta.
      this-object:btnAdd:Name = "btnAdd".
      this-object:btnAdd:Size = new System.Drawing.Size(36, 36).
      this-object:btnAdd:Text = "Добавить".
      this-object:btnAdd:Click:Subscribe(this-object:btnAdd_Click).
      this-object:toolStrip1:Dock = System.Windows.Forms.DockStyle:None.
      this-object:toolStrip1:ImageScalingSize = new System.Drawing.Size(32, 32).
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar3 as System.Windows.Forms.ToolStripItem extent 6 no-undo.
      arrayvar3[1] = this-object:BtnExit.
      arrayvar3[2] = this-object:btnAdd.
      arrayvar3[3] = this-object:BtnEdit.
      arrayvar3[4] = this-object:Btndel.
      arrayvar3[5] = this-object:btnLook.
      arrayvar3[6] = this-object:NextLevel.
      this-object:toolStrip1:Items:AddRange(arrayvar3).
      this-object:toolStrip1:Location = new System.Drawing.Point(9, 9).
      this-object:toolStrip1:Name = "toolStrip1".
      this-object:toolStrip1:Size = new System.Drawing.Size(228, 39).
      this-object:toolStrip1:TabIndex = 2.
      this-object:toolStrip1:Text = "toolStrip1".
      this-object:BtnExit:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
      this-object:BtnExit:Image = cast(resources:GetObject("BtnExit.Image"), System.Drawing.Image).
      this-object:BtnExit:ImageTransparentColor = System.Drawing.Color:Magenta.
      this-object:BtnExit:Name = "BtnExit".
      this-object:BtnExit:Size = new System.Drawing.Size(36, 36).
      this-object:BtnExit:Text = "Выход".
      this-object:BtnExit:Click:Subscribe(this-object:BtnExit_Click).
      this-object:BtnEdit:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
      this-object:BtnEdit:Image = cast(resources:GetObject("BtnEdit.Image"), System.Drawing.Image).
      this-object:BtnEdit:ImageTransparentColor = System.Drawing.Color:Magenta.
      this-object:BtnEdit:Name = "BtnEdit".
      this-object:BtnEdit:Size = new System.Drawing.Size(36, 36).
      this-object:BtnEdit:Text = "Изменить".
      this-object:BtnEdit:Click:Subscribe(this-object:BtnEdit_Click).
      this-object:Btndel:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
      this-object:Btndel:Image = cast(resources:GetObject("Btndel.Image"), System.Drawing.Image).
      this-object:Btndel:ImageTransparentColor = System.Drawing.Color:Magenta.
      this-object:Btndel:Name = "Btndel".
      this-object:Btndel:Size = new System.Drawing.Size(36, 36).
      this-object:Btndel:Text = "Удалить".
      this-object:Btndel:Click:Subscribe(this-object:Btndel_Click).
      this-object:btnLook:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
      this-object:btnLook:Image = cast(resources:GetObject("btnLook.Image"), System.Drawing.Image).
      this-object:btnLook:ImageTransparentColor = System.Drawing.Color:Magenta.
      this-object:btnLook:Name = "btnLook".
      this-object:btnLook:Size = new System.Drawing.Size(36, 36).
      this-object:btnLook:Text = "Просмотр".
      this-object:btnLook:Click:Subscribe(this-object:btnLook_Click).
      this-object:NextLevel:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
      this-object:NextLevel:Image = cast(resources:GetObject("NextLevel.Image"), System.Drawing.Image).
      this-object:NextLevel:ImageTransparentColor = System.Drawing.Color:Magenta.
      this-object:NextLevel:Name = "NextLevel".
      this-object:NextLevel:Size = new System.Drawing.Size(36, 36).
      this-object:NextLevel:Text = "Потомки".
      this-object:NextLevel:Click:Subscribe(this-object:NextLevel_Click).
      this-object:ClientSize = new System.Drawing.Size(737, 498).
      this-object:Controls:Add(this-object:dataGridView1).
      this-object:Controls:Add(this-object:toolStrip1).
      this-object:FormBorderStyle = System.Windows.Forms.FormBorderStyle:FixedDialog.
      this-object:MaximizeBox = false.
      this-object:MinimizeBox = false.
      this-object:Name = "xgroupobj".
      this-object:ShowInTaskbar = false.
      this-object:StartPosition = System.Windows.Forms.FormStartPosition:CenterParent.
      this-object:Text = "Группы объектов".
      cast(this-object:dataGridView1, System.ComponentModel.ISupportInitialize):EndInit().
      cast(this-object:bindxgroup, System.ComponentModel.ISupportInitialize):EndInit().
      this-object:toolStrip1:ResumeLayout(false).
      this-object:toolStrip1:PerformLayout().
      this-object:ResumeLayout(false).
      this-object:PerformLayout().
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end method.
   method public void ShowModalDialog(  ):
      bindxgroup:handle = mtrg:getQuery(mQrName).
      NextLevel:visible = mtrg:validNextLevel().
      wait-for this-object:ShowDialog().
   end method.
end class.
