using Progress.Windows.Form.
block-level on error undo, throw.
class ibs.th.ref.xproc.XgroupObjFrm inherits Form :
   define private variable bindXGroupObj as Progress.Data.BindingSource no-undo.
   define private variable components as System.ComponentModel.IContainer no-undo.
    define private variable buttonOk as System.Windows.Forms.Button no-undo.
    define private variable buttonCancel as System.Windows.Forms.Button no-undo.
   define private variable fName as System.Windows.Forms.TextBox no-undo.
   define private variable Descr as System.Windows.Forms.TextBox no-undo.
   define private variable label3 as System.Windows.Forms.Label no-undo.
   define private variable ProgressCode as System.Windows.Forms.TextBox no-undo.
   define private variable label2 as System.Windows.Forms.Label no-undo.
   define private variable label1 as System.Windows.Forms.Label no-undo.
   define private variable ProgressTable as System.Windows.Forms.CheckBox no-undo.
   define private variable Hierarchy as System.Windows.Forms.CheckBox no-undo.
   define private variable GroupObjCode as System.Windows.Forms.TextBox no-undo.
   define variable mtrg as class ibs.th.ref.xproc.xgroupobj_trg no-undo.
   define variable mtrgCr as logical no-undo.
   constructor public XgroupObjFrm( ):
      super().
      mtrg = new ibs.th.ref.xproc.xgroupobj_trg().
      mtrgCr = yes.
      InitializeComponent ( ).
      lockField(no).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end constructor.
   constructor public XgroupObjFrm( itrg as ibs.th.ref.xproc.xgroupobj_trg):
      super().
      mtrg = itrg.
      InitializeComponent ( ).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end constructor.
   destructor public XgroupObjFrm( ):
      if mtrgCr
      then
         delete object mtrg.
      if valid-object(components) then do:
         cast(components, System.IDisposable):Dispose().
      end.
   end destructor.
   method private void lockField(ienable as logical):
      buttonOk:enabled = ienable.
      ProgressCode:enabled = ienable.
      ProgressTable:enabled = ienable.
      Hierarchy:enabled = ienable.
      GroupObjCode:enabled = ienable.
      fName:enabled = ienable.
      Descr:enabled = ienable.
   end.
   method private void okButton_Click (sender as System.Object, e as System.EventArgs):
      bindXGroupObj:Assign().
      if mtrg:CheckRec()
      then do:
         this-object:DialogResult = System.Windows.Forms.DialogResult:Ok.
         this-object:Close ( ).
      end.
   end method.
   method private void cancelButton_Click (sender as System.Object, e as System.EventArgs):
      this-object:DialogResult = System.Windows.Forms.DialogResult:Cancel.
      this-object:Close ( ).
   end method.
   method private void InitializeComponent ( ):
      this-object:components = new System.ComponentModel.Container().
      @VisualDesigner.FormMember (NeedsInitialize="true").
      define variable tableDesc1 as Progress.Data.TableDesc no-undo.
      tableDesc1 = new Progress.Data.TableDesc("xGroupObj").
      this-object:buttonOk = new System.Windows.Forms.Button().
      this-object:buttonCancel = new System.Windows.Forms.Button().
      this-object:bindXGroupObj = new Progress.Data.BindingSource(this-object:components).
      this-object:GroupObjCode = new System.Windows.Forms.TextBox().
      this-object:label1 = new System.Windows.Forms.Label().
      this-object:fName = new System.Windows.Forms.TextBox().
      this-object:label2 = new System.Windows.Forms.Label().
      this-object:Hierarchy = new System.Windows.Forms.CheckBox().
      this-object:ProgressTable = new System.Windows.Forms.CheckBox().
      this-object:ProgressCode = new System.Windows.Forms.TextBox().
      this-object:label3 = new System.Windows.Forms.Label().
      this-object:Descr = new System.Windows.Forms.TextBox().
      cast(this-object:bindXGroupObj, System.ComponentModel.ISupportInitialize):BeginInit().
      this-object:SuspendLayout().
      define variable nestedvar0 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar0 = System.Windows.Forms.AnchorStyles:Bottom.
      this-object:buttonOk:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:buttonOk:Location = new System.Drawing.Point(208, 246).
      this-object:buttonOk:Name = "buttonOk".
      this-object:buttonOk:Size = new System.Drawing.Size(75, 23).
      this-object:buttonOk:TabIndex = 0.
      this-object:buttonOk:Text = "&Ввод".
      this-object:buttonOk:UseCompatibleTextRendering = true.
      this-object:buttonOk:Click:Subscribe(this-object:okButton_Click).
      define variable nestedvar1 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar1 = System.Windows.Forms.AnchorStyles:Bottom.
      this-object:buttonCancel:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar1, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:buttonCancel:DialogResult = System.Windows.Forms.DialogResult:Cancel.
      this-object:buttonCancel:Location = new System.Drawing.Point(292, 246).
      this-object:buttonCancel:Name = "buttonCancel".
      this-object:buttonCancel:Size = new System.Drawing.Size(75, 23).
      this-object:buttonCancel:TabIndex = 1.
      this-object:buttonCancel:Text = "&Отмена".
      this-object:buttonCancel:UseCompatibleTextRendering = true.
      this-object:buttonCancel:Click:Subscribe(this-object:cancelButton_Click).
      this-object:bindXGroupObj:MaxDataGuess = 0.
      this-object:bindXGroupObj:NoLOBs = false.
      this-object:bindXGroupObj:Position = 0.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar0 as "Progress.Data.TableDesc[]" no-undo.
      arrayvar0 = new "Progress.Data.TableDesc[]"(0).
      tableDesc1:ChildTables = arrayvar0.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar1 as Progress.Data.ColumnPropDesc extent 7 no-undo.
      arrayvar1[1] = new Progress.Data.ColumnPropDesc("Description", "Описание", Progress.Data.DataType:CHARACTER).
      arrayvar1[2] = new Progress.Data.ColumnPropDesc("GroupObj-Code", "Группа объектов", Progress.Data.DataType:CHARACTER).
      arrayvar1[3] = new Progress.Data.ColumnPropDesc("Hierarchy", "Иерархия", Progress.Data.DataType:LOGICAL).
      arrayvar1[4] = new Progress.Data.ColumnPropDesc("Name", "Наименование", Progress.Data.DataType:CHARACTER).
      arrayvar1[5] = new Progress.Data.ColumnPropDesc("Parent-GroupObj", "Группы объектов-родители", Progress.Data.DataType:CHARACTER).
      arrayvar1[6] = new Progress.Data.ColumnPropDesc("Progress-Code", "Таблица Progress", Progress.Data.DataType:CHARACTER).
      arrayvar1[7] = new Progress.Data.ColumnPropDesc("Progress-Table", "Таблица", Progress.Data.DataType:LOGICAL).
      tableDesc1:Columns = arrayvar1.
      this-object:bindXGroupObj:TableSchema = tableDesc1.
      define variable nestedvar2 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar2 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:GroupObjCode:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar2, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:GroupObjCode:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindXGroupObj, "GroupObj-Code", true)).
      this-object:GroupObjCode:Location = new System.Drawing.Point(119, 12).
      this-object:GroupObjCode:Name = "GroupObjCode".
      this-object:GroupObjCode:Size = new System.Drawing.Size(250, 20).
      this-object:GroupObjCode:TabIndex = 2.
      this-object:label1:Location = new System.Drawing.Point(13, 12).
      this-object:label1:Name = "label1".
      this-object:label1:Size = new System.Drawing.Size(100, 23).
      this-object:label1:TabIndex = 3.
      this-object:label1:Text = "Группа объектов".
      this-object:label1:UseCompatibleTextRendering = true.
      define variable nestedvar3 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar3 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:fName:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar3, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:fName:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindXGroupObj, "Name", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
      this-object:fName:Location = new System.Drawing.Point(119, 39).
      this-object:fName:Name = "fName".
      this-object:fName:Size = new System.Drawing.Size(250, 20).
      this-object:fName:TabIndex = 4.
      this-object:label2:Location = new System.Drawing.Point(13, 35).
      this-object:label2:Name = "label2".
      this-object:label2:Size = new System.Drawing.Size(100, 23).
      this-object:label2:TabIndex = 5.
      this-object:label2:Text = "Наименование".
      this-object:label2:UseCompatibleTextRendering = true.
      this-object:Hierarchy:DataBindings:Add(new System.Windows.Forms.Binding("CheckState", this-object:bindXGroupObj, "Hierarchy", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
      this-object:Hierarchy:Location = new System.Drawing.Point(119, 66).
      this-object:Hierarchy:Name = "Hierarchy".
      this-object:Hierarchy:Size = new System.Drawing.Size(76, 24).
      this-object:Hierarchy:TabIndex = 6.
      this-object:Hierarchy:Text = "Иерархия".
      this-object:Hierarchy:UseCompatibleTextRendering = true.
      this-object:Hierarchy:UseVisualStyleBackColor = true.
      define variable nestedvar4 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar4 = System.Windows.Forms.AnchorStyles:Top.
      this-object:ProgressTable:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar4, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:ProgressTable:DataBindings:Add(new System.Windows.Forms.Binding("CheckState", this-object:bindXGroupObj, "Progress-Table", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
      this-object:ProgressTable:Location = new System.Drawing.Point(301, 65).
      this-object:ProgressTable:Name = "ProgressTable".
      this-object:ProgressTable:Size = new System.Drawing.Size(68, 24).
      this-object:ProgressTable:TabIndex = 7.
      this-object:ProgressTable:Text = "Таблица".
      this-object:ProgressTable:UseCompatibleTextRendering = true.
      this-object:ProgressTable:UseVisualStyleBackColor = true.
      this-object:ProgressTable:CheckedChanged:Subscribe(this-object:ProgressTable_CheckedChanged).
      define variable nestedvar5 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar5 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:ProgressCode:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar5, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:ProgressCode:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindXGroupObj, "Progress-Code", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
      this-object:ProgressCode:Location = new System.Drawing.Point(119, 97).
      this-object:ProgressCode:Name = "ProgressCode".
      this-object:ProgressCode:Size = new System.Drawing.Size(250, 20).
      this-object:ProgressCode:TabIndex = 8.
      this-object:ProgressCode:Visible = false.
      this-object:label3:Location = new System.Drawing.Point(13, 97).
      this-object:label3:Name = "label3".
      this-object:label3:Size = new System.Drawing.Size(100, 23).
      this-object:label3:TabIndex = 9.
      this-object:label3:Text = "Таблица Progress".
      this-object:label3:UseCompatibleTextRendering = true.
      define variable nestedvar6 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar6 = cast(Progress.Util.EnumHelper:Or(cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Bottom), System.Windows.Forms.AnchorStyles), System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:Descr:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar6, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:Descr:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindXGroupObj, "Description", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
      this-object:Descr:Location = new System.Drawing.Point(119, 124).
      this-object:Descr:Multiline = true.
      this-object:Descr:Name = "Descr".
      this-object:Descr:Size = new System.Drawing.Size(250, 107).
      this-object:Descr:TabIndex = 10.
      this-object:AcceptButton = this-object:buttonOk.
      this-object:CancelButton = this-object:buttonCancel.
      this-object:ClientSize = new System.Drawing.Size(381, 283).
      this-object:Controls:Add(this-object:Descr).
      this-object:Controls:Add(this-object:label3).
      this-object:Controls:Add(this-object:ProgressCode).
      this-object:Controls:Add(this-object:ProgressTable).
      this-object:Controls:Add(this-object:Hierarchy).
      this-object:Controls:Add(this-object:label2).
      this-object:Controls:Add(this-object:fName).
      this-object:Controls:Add(this-object:label1).
      this-object:Controls:Add(this-object:GroupObjCode).
      this-object:Controls:Add(this-object:buttonCancel).
      this-object:Controls:Add(this-object:buttonOk).
      this-object:FormBorderStyle = System.Windows.Forms.FormBorderStyle:FixedDialog.
      this-object:MaximizeBox = false.
      this-object:MinimizeBox = false.
      this-object:Name = "XgroupObjFrm".
      this-object:ShowInTaskbar = false.
      this-object:StartPosition = System.Windows.Forms.FormStartPosition:CenterParent.
      this-object:Text = "XgroupObjFrm".
      cast(this-object:bindXGroupObj, System.ComponentModel.ISupportInitialize):EndInit().
      this-object:ResumeLayout(false).
      this-object:PerformLayout().
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end method.
        @VisualDesigner.
        method private void ProgressTable_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
                ProgressCode:visible = ProgressTable:checked.
                return.
        end method.
   method public void ShowModalDialog( ihandle as handle ):
      bindXGroupObj:handle = ihandle.
      ProgressCode:visible = ProgressTable:checked.
      wait-for this-object:ShowDialog().
   end method.
end class.
