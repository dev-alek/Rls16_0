using Progress.Lang.*.
using Progress.Windows.Form.
block-level on error undo, throw.
class ibs.th.ref.code.browsecode inherits Form final:
   define private variable bdel as System.Windows.Forms.ToolStripButton no-undo.
   define private variable bedit as System.Windows.Forms.ToolStripButton no-undo.
   define private variable bAdd as System.Windows.Forms.ToolStripButton no-undo.
   define private variable bexit as System.Windows.Forms.ToolStripButton no-undo.
   define private variable bexport as System.Windows.Forms.ToolStripButton no-undo.
   define private variable bfilt as System.Windows.Forms.ToolStripButton no-undo.
   define private variable bimport as System.Windows.Forms.ToolStripButton no-undo.
   define private variable bindCode as Progress.Data.BindingSource no-undo.
   define private variable bnext as System.Windows.Forms.ToolStripButton no-undo.
   define private variable bselect as System.Windows.Forms.ToolStripButton no-undo.
   define private variable childHist as System.Windows.Forms.ToolStripMenuItem no-undo.
   define private variable codeValueDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable codeNameDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable codeDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable components as System.ComponentModel.IContainer no-undo.
   define private variable dataGridView1 as System.Windows.Forms.DataGridView no-undo.
   define private variable dataGridViewCheckBoxColumn1 as System.Windows.Forms.DataGridViewCheckBoxColumn no-undo.
   define private variable ElemMenu as System.Windows.Forms.MenuStrip no-undo.
   define private variable fchange as System.Windows.Forms.DataGridViewCheckBoxColumn no-undo.
   define private variable Hist as System.Windows.Forms.ToolStripMenuItem no-undo.
   define private variable imageList1 as System.Windows.Forms.ImageList no-undo.
   define private variable oneHist as System.Windows.Forms.ToolStripMenuItem no-undo.
   define private variable openFileDialog1 as System.Windows.Forms.OpenFileDialog no-undo.
   define private variable saveFileDialog1 as System.Windows.Forms.SaveFileDialog no-undo.
   define private variable statusrow as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable toolStrip1 as System.Windows.Forms.ToolStrip no-undo.
   define private variable procviewDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable proceditDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable procdelDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable parentDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable misc9DataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable misc8DataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable misc7DataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable misc6DataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable misc5DataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable misc4DataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable misc3DataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable misc2DataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable misc1DataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable misc10DataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define variable mCodeTrg as class ibs.th.ref.code.code_trg no-undo.
   define variable mcretrg  as logical no-undo.
   define private variable vCurRow as integer no-undo extent 6 .
   define property chek-erpRN as logical no-undo
   set(input ichek-erpRN as logical):
    if ichek-erpRN
    then
       chek1cerp().
  end.
   constructor public browsecode (  ):
      super().
      InitializeComponent().
      mCodeTrg = new ibs.th.ref.code.code_trg().
      mcretrg  = yes.
      bnext:visible = not mCodeTrg:endLevel.
      bindCode:handle = mCodeTrg:getQuery("code").
      this-object:ComponentsCollection:ADD(this-object:components).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end constructor.
   constructor public browsecode ( imode as character ,itrg as class ibs.th.ref.code.code_trg ):
      super().
      InitializeComponent().
      BrwMode(imode).
      mCodeTrg = itrg.
      bnext:visible = not mCodeTrg:endLevel.
      mCodeTrg:mode = imode.
      bindCode:handle = mCodeTrg:getQuery("code").
      this-object:ComponentsCollection:ADD(this-object:components).
      statusrow:Visible = mCodeTrg:isVisibleStatus.
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end constructor.
   method private void BrwMode( input imode as character  ):
      if iMode eq 'ДОБАВЛЕНИЕ':U
      then do:
         assign
         bedit  :visible = false
         this-object:dataGridView1:Columns[0]:Visible = false.
      .
      end.
      else if iMode eq 'ПРОСМОТР':U
      then do:
         assign
         bAdd   :visible = false
         bdel   :visible = false
         bedit  :visible = false
         bexport:visible = false
         bimport:visible = false
         bselect:visible = false
         this-object:dataGridView1:Columns[0]:Visible = false.
      .
      end.
      else if iMode eq 'ВЫБОР':U
      then do:
         assign
         bAdd   :visible = false
         bdel   :visible = false
         bedit  :visible = false
         bexport:visible = false
         bimport:visible = false
         bselect:visible = true
         this-object:dataGridView1:Columns[0]:Visible = yes.
      .
      end.
      else do:
         if iMode eq "sysadm"
         then assign
            bAdd   :visible = yes
            bdel   :visible = yes
            bedit  :visible = yes
            bexport:visible = true
            bimport:visible = true
            bselect:visible = false
         .
         this-object:dataGridView1:Columns[0]:Visible = no.
      end.
      return.
   end method.
        @VisualDesigner.
        method private void bAdd_Click( input sender as System.Object, input e as System.EventArgs ):
                mCodeTrg:addCode().
                mCodeTrg:getQuery("code").
                bindcode:RefreshAll().
                return.
        end method.
        @VisualDesigner.
        method private void bdel_Click( input sender as System.Object, input e as System.EventArgs ):
                mCodeTrg:delCode().
                mCodeTrg:getQuery("code").
      bindcode:RefreshAll().
                return.
        end method.
        @VisualDesigner.
        method private void bedit_Click( input sender as System.Object, input e as System.EventArgs ):
                mCodeTrg:editCode().
                bindcode:Refresh().
                return.
        end method.
        @VisualDesigner.
        method private void bexit_Click( input sender as System.Object, input e as System.EventArgs ):
                if mCodeTrg:PrevLevel()
                then do:
                   bnext:visible = not mCodeTrg:endLevel.
       bindCode:RefreshAll().
       dataGridView1:CurrentCell = dataGridView1:Rows[vCurRow[mCodeTrg:curLevel + 1]]:Cells[1] .
    end.
    else
       Close().
                return.
        end method.
        @VisualDesigner.
        method private void bexport_Click( input sender as System.Object, input e as System.EventArgs ):
           saveFileDialog1:Filter = "xml files (*.xml)|*.xml|All files (*.*)|*.*"  .
                wait-for this-object:saveFileDialog1:ShowDialog().
                if   this-object:saveFileDialog1:FileName ne ""
                then
                   mCodeTrg:codeexport(this-object:saveFileDialog1:FileName).
                return.
        end method.
        @VisualDesigner.
        method private void bfilt_Click( input sender as System.Object, input e as System.EventArgs ):
                mCodeTrg:mviewdel = not mCodeTrg:mviewdel.
                mCodeTrg:getQuery("code").
                bindCode:RefreshAll().
                return.
        end method.
        @VisualDesigner.
        method private void bimport_Click( input sender as System.Object, input e as System.EventArgs ):
                wait-for this-object:openFileDialog1:ShowDialog().
      if   this-object:openFileDialog1:FileName ne ""
      then
         mCodeTrg:codeimport(this-object:openFileDialog1:FileName).
                return.
        end method.
        @VisualDesigner.
        method private void bnext_Click( input sender as System.Object, input e as System.EventArgs ):
           vCurRow[mCodeTrg:curLevel + 1] = dataGridView1:CurrentRow:Index no-error .
           mCodeTrg:NextLevel().
           bnext:visible = not mCodeTrg:endLevel.
     bindCode:RefreshAll().
     if mCodeTrg:extProcView
     then do :
       dataGridView1:CurrentCell = dataGridView1:Rows[vCurRow[mCodeTrg:curLevel + 1]]:Cells[1] .
     end .
                 return.
        end method.
        @VisualDesigner.
   method private void bselect_Click( input sender as System.Object, input e as System.EventArgs ):
      mCodeTrg:rid-keep().
      Close().
      return.
   end method.
        @VisualDesigner.
        method private void dataGridView1_CellContentClick( input sender as System.Object, input e as System.Windows.Forms.DataGridViewCellEventArgs ):
                mCodeTrg:changeRow(no).
                bindCode:Refresh().
                return.
        end method.
        @VisualDesigner.
        method private void dataGridView1_CellContentDoubleClick( input sender as System.Object, input e as System.Windows.Forms.DataGridViewCellEventArgs ):
      vCurRow[mCodeTrg:curLevel + 1] = dataGridView1:CurrentRow:Index no-error .
      mCodeTrg:NextLevel().
      bnext:visible = not mCodeTrg:endLevel.
      bindCode:RefreshAll().
      if mCodeTrg:extProcView
      then do :
        dataGridView1:CurrentCell = dataGridView1:Rows[vCurRow[mCodeTrg:curLevel + 1]]:Cells[1] .
      end .
      return.
        end method.
        @VisualDesigner.
        method private void bHistOne( input sender as System.Object, input e as System.EventArgs ):
                mCodeTrg:histOne().
                return.
        end method.
        @VisualDesigner.
   method private void bMenuItem( input sender as System.Object, input e as System.EventArgs ):
      mCodeTrg:runMenu(cast (sender,System.Windows.Forms.ToolStripMenuItem):name).
      mCodeTrg:getQuery("code").
      bindCode:RefreshAll().
      return.
   end method.
   @VisualDesigner.
   method private void bchildHist( input sender as System.Object, input e as System.EventArgs ):
      mCodeTrg:histChild().
      return.
   end method.
   method private void InitializeComponent(  ):
      this-object:components = new System.ComponentModel.Container().
      @VisualDesigner.FormMember (NeedsInitialize="true").
      define variable tableDesc2 as Progress.Data.TableDesc no-undo.
      tableDesc2 = new Progress.Data.TableDesc("Code").
      @VisualDesigner.FormMember (NeedsInitialize="true").
      define variable resources as Progress.Util.ResourceManager no-undo.
      resources = new Progress.Util.ResourceManager("ibs.th.ref.code.browsecode").
      this-object:dataGridView1 = new System.Windows.Forms.DataGridView().
      this-object:dataGridViewCheckBoxColumn1 = new System.Windows.Forms.DataGridViewCheckBoxColumn().
      this-object:codeDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:codeNameDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:codeValueDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:misc1DataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:misc2DataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:misc3DataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:misc4DataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:misc5DataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:misc6DataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:misc7DataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:misc8DataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:misc9DataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:misc10DataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:procviewDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:parentDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:procdelDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:proceditDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:statusrow = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:bindCode = new Progress.Data.BindingSource(this-object:components).
      this-object:toolStrip1 = new System.Windows.Forms.ToolStrip().
      this-object:bexit = new System.Windows.Forms.ToolStripButton().
      this-object:bnext = new System.Windows.Forms.ToolStripButton().
      this-object:bAdd = new System.Windows.Forms.ToolStripButton().
      this-object:bedit = new System.Windows.Forms.ToolStripButton().
      this-object:bexport = new System.Windows.Forms.ToolStripButton().
      this-object:bimport = new System.Windows.Forms.ToolStripButton().
      this-object:bdel = new System.Windows.Forms.ToolStripButton().
      this-object:bfilt = new System.Windows.Forms.ToolStripButton().
      this-object:bselect = new System.Windows.Forms.ToolStripButton().
      this-object:openFileDialog1 = new System.Windows.Forms.OpenFileDialog().
      this-object:saveFileDialog1 = new System.Windows.Forms.SaveFileDialog().
      this-object:ElemMenu = new System.Windows.Forms.MenuStrip().
      this-object:Hist = new System.Windows.Forms.ToolStripMenuItem().
      this-object:oneHist = new System.Windows.Forms.ToolStripMenuItem().
      this-object:childHist = new System.Windows.Forms.ToolStripMenuItem().
      this-object:imageList1 = new System.Windows.Forms.ImageList(this-object:components).
      cast(this-object:dataGridView1, System.ComponentModel.ISupportInitialize):BeginInit().
      cast(this-object:bindCode, System.ComponentModel.ISupportInitialize):BeginInit().
      this-object:toolStrip1:SuspendLayout().
      this-object:ElemMenu:SuspendLayout().
      this-object:SuspendLayout().
      this-object:dataGridView1:AccessibleRole = System.Windows.Forms.AccessibleRole:None.
      this-object:dataGridView1:AllowUserToAddRows = false.
      define variable nestedvar0 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar0 = cast(Progress.Util.EnumHelper:Or(cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Bottom), System.Windows.Forms.AnchorStyles), System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:dataGridView1:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:dataGridView1:AutoGenerateColumns = false.
      this-object:dataGridView1:AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode:Fill.
      this-object:dataGridView1:ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode:AutoSize.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar0 as System.Windows.Forms.DataGridViewColumn extent 19 no-undo.
      arrayvar0[1] = this-object:dataGridViewCheckBoxColumn1.
      arrayvar0[2] = this-object:codeDataGridViewTextBoxColumn.
      arrayvar0[3] = this-object:codeNameDataGridViewTextBoxColumn.
      arrayvar0[4] = this-object:codeValueDataGridViewTextBoxColumn.
      arrayvar0[5] = this-object:misc1DataGridViewTextBoxColumn.
      arrayvar0[6] = this-object:misc2DataGridViewTextBoxColumn.
      arrayvar0[7] = this-object:misc3DataGridViewTextBoxColumn.
      arrayvar0[8] = this-object:misc4DataGridViewTextBoxColumn.
      arrayvar0[9] = this-object:misc5DataGridViewTextBoxColumn.
      arrayvar0[10] = this-object:misc6DataGridViewTextBoxColumn.
      arrayvar0[11] = this-object:misc7DataGridViewTextBoxColumn.
      arrayvar0[12] = this-object:misc8DataGridViewTextBoxColumn.
      arrayvar0[13] = this-object:misc9DataGridViewTextBoxColumn.
      arrayvar0[14] = this-object:misc10DataGridViewTextBoxColumn.
      arrayvar0[15] = this-object:procviewDataGridViewTextBoxColumn.
      arrayvar0[16] = this-object:parentDataGridViewTextBoxColumn.
      arrayvar0[17] = this-object:procdelDataGridViewTextBoxColumn.
      arrayvar0[18] = this-object:proceditDataGridViewTextBoxColumn.
      arrayvar0[19] = this-object:statusrow.
      this-object:dataGridView1:Columns:AddRange(arrayvar0).
      this-object:dataGridView1:DataSource = this-object:bindCode.
      this-object:dataGridView1:Location = new System.Drawing.Point(0, 42).
      this-object:dataGridView1:MultiSelect = false.
      this-object:dataGridView1:Name = "dataGridView1".
      this-object:dataGridView1:ReadOnly = true.
      this-object:dataGridView1:SelectionMode = System.Windows.Forms.DataGridViewSelectionMode:FullRowSelect.
      this-object:dataGridView1:Size = new System.Drawing.Size(990, 576).
      this-object:dataGridView1:TabIndex = 0.
      this-object:dataGridView1:CellContentClick:Subscribe(this-object:dataGridView1_CellContentClick).
      this-object:dataGridView1:CellContentDoubleClick:Subscribe(this-object:dataGridView1_CellContentDoubleClick).
      this-object:dataGridViewCheckBoxColumn1:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:DisplayedCells.
      this-object:dataGridViewCheckBoxColumn1:DataPropertyName = "fchange".
      this-object:dataGridViewCheckBoxColumn1:HeaderText = "".
      this-object:dataGridViewCheckBoxColumn1:Name = "dataGridViewCheckBoxColumn1".
      this-object:dataGridViewCheckBoxColumn1:ReadOnly = true.
      this-object:dataGridViewCheckBoxColumn1:Width = 21.
      this-object:codeDataGridViewTextBoxColumn:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:DisplayedCells.
      this-object:codeDataGridViewTextBoxColumn:DataPropertyName = "code".
      this-object:codeDataGridViewTextBoxColumn:FillWeight = Progress.Util.CastUtil:ToSingle(159.8984833).
      this-object:codeDataGridViewTextBoxColumn:HeaderText = "Код".
      this-object:codeDataGridViewTextBoxColumn:Name = "codeDataGridViewTextBoxColumn".
      this-object:codeDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:codeDataGridViewTextBoxColumn:Width = 51.
      this-object:codeNameDataGridViewTextBoxColumn:DataPropertyName = "CodeName".
      this-object:codeNameDataGridViewTextBoxColumn:FillWeight = Progress.Util.CastUtil:ToSingle(70.0507584).
      this-object:codeNameDataGridViewTextBoxColumn:HeaderText = "Наименование".
      this-object:codeNameDataGridViewTextBoxColumn:Name = "codeNameDataGridViewTextBoxColumn".
      this-object:codeNameDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:codeValueDataGridViewTextBoxColumn:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:DisplayedCells.
      this-object:codeValueDataGridViewTextBoxColumn:DataPropertyName = "CodeValue".
      this-object:codeValueDataGridViewTextBoxColumn:FillWeight = Progress.Util.CastUtil:ToSingle(70.0507584).
      this-object:codeValueDataGridViewTextBoxColumn:HeaderText = "Значение".
      this-object:codeValueDataGridViewTextBoxColumn:Name = "codeValueDataGridViewTextBoxColumn".
      this-object:codeValueDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:codeValueDataGridViewTextBoxColumn:Width = 80.
      this-object:misc1DataGridViewTextBoxColumn:DataPropertyName = "misc1".
      this-object:misc1DataGridViewTextBoxColumn:HeaderText = "Доп поле 1".
      this-object:misc1DataGridViewTextBoxColumn:Name = "misc1DataGridViewTextBoxColumn".
      this-object:misc1DataGridViewTextBoxColumn:ReadOnly = true.
      this-object:misc1DataGridViewTextBoxColumn:Visible = false.
      this-object:misc2DataGridViewTextBoxColumn:DataPropertyName = "misc2".
      this-object:misc2DataGridViewTextBoxColumn:HeaderText = "Доп поле 2".
      this-object:misc2DataGridViewTextBoxColumn:Name = "misc2DataGridViewTextBoxColumn".
      this-object:misc2DataGridViewTextBoxColumn:ReadOnly = true.
      this-object:misc2DataGridViewTextBoxColumn:Visible = false.
      this-object:misc3DataGridViewTextBoxColumn:DataPropertyName = "misc3".
      this-object:misc3DataGridViewTextBoxColumn:HeaderText = "Доп поле 3".
      this-object:misc3DataGridViewTextBoxColumn:Name = "misc3DataGridViewTextBoxColumn".
      this-object:misc3DataGridViewTextBoxColumn:ReadOnly = true.
      this-object:misc3DataGridViewTextBoxColumn:Visible = false.
      this-object:misc4DataGridViewTextBoxColumn:DataPropertyName = "misc4".
      this-object:misc4DataGridViewTextBoxColumn:HeaderText = "Доп поле 4".
      this-object:misc4DataGridViewTextBoxColumn:Name = "misc4DataGridViewTextBoxColumn".
      this-object:misc4DataGridViewTextBoxColumn:ReadOnly = true.
      this-object:misc4DataGridViewTextBoxColumn:Visible = false.
      this-object:misc5DataGridViewTextBoxColumn:DataPropertyName = "misc5".
      this-object:misc5DataGridViewTextBoxColumn:HeaderText = "Доп поле 5".
      this-object:misc5DataGridViewTextBoxColumn:Name = "misc5DataGridViewTextBoxColumn".
      this-object:misc5DataGridViewTextBoxColumn:ReadOnly = true.
      this-object:misc5DataGridViewTextBoxColumn:Visible = false.
      this-object:misc6DataGridViewTextBoxColumn:DataPropertyName = "misc6".
      this-object:misc6DataGridViewTextBoxColumn:HeaderText = "Доп поле 6".
      this-object:misc6DataGridViewTextBoxColumn:Name = "misc6DataGridViewTextBoxColumn".
      this-object:misc6DataGridViewTextBoxColumn:ReadOnly = true.
      this-object:misc6DataGridViewTextBoxColumn:Visible = false.
      this-object:misc7DataGridViewTextBoxColumn:DataPropertyName = "misc7".
      this-object:misc7DataGridViewTextBoxColumn:HeaderText = "Доп поле 7".
      this-object:misc7DataGridViewTextBoxColumn:Name = "misc7DataGridViewTextBoxColumn".
      this-object:misc7DataGridViewTextBoxColumn:ReadOnly = true.
      this-object:misc7DataGridViewTextBoxColumn:Visible = false.
      this-object:misc8DataGridViewTextBoxColumn:DataPropertyName = "misc8".
      this-object:misc8DataGridViewTextBoxColumn:HeaderText = "Доп поле 8".
      this-object:misc8DataGridViewTextBoxColumn:Name = "misc8DataGridViewTextBoxColumn".
      this-object:misc8DataGridViewTextBoxColumn:ReadOnly = true.
      this-object:misc8DataGridViewTextBoxColumn:Visible = false.
      this-object:misc9DataGridViewTextBoxColumn:DataPropertyName = "misc9".
      this-object:misc9DataGridViewTextBoxColumn:HeaderText = "Доп поле 9".
      this-object:misc9DataGridViewTextBoxColumn:Name = "misc9DataGridViewTextBoxColumn".
      this-object:misc9DataGridViewTextBoxColumn:ReadOnly = true.
      this-object:misc9DataGridViewTextBoxColumn:Visible = false.
      this-object:misc10DataGridViewTextBoxColumn:DataPropertyName = "misc10".
      this-object:misc10DataGridViewTextBoxColumn:HeaderText = "Доп поле 10".
      this-object:misc10DataGridViewTextBoxColumn:Name = "misc10DataGridViewTextBoxColumn".
      this-object:misc10DataGridViewTextBoxColumn:ReadOnly = true.
      this-object:misc10DataGridViewTextBoxColumn:Visible = false.
      this-object:procviewDataGridViewTextBoxColumn:DataPropertyName = "procview".
      this-object:procviewDataGridViewTextBoxColumn:HeaderText = "Процедура просмотра".
      this-object:procviewDataGridViewTextBoxColumn:Name = "procviewDataGridViewTextBoxColumn".
      this-object:procviewDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:procviewDataGridViewTextBoxColumn:Visible = false.
      this-object:parentDataGridViewTextBoxColumn:DataPropertyName = "parent".
      this-object:parentDataGridViewTextBoxColumn:HeaderText = "parent".
      this-object:parentDataGridViewTextBoxColumn:Name = "parentDataGridViewTextBoxColumn".
      this-object:parentDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:parentDataGridViewTextBoxColumn:Visible = false.
      this-object:procdelDataGridViewTextBoxColumn:DataPropertyName = "procdel".
      this-object:procdelDataGridViewTextBoxColumn:HeaderText = "Процедура удаления".
      this-object:procdelDataGridViewTextBoxColumn:Name = "procdelDataGridViewTextBoxColumn".
      this-object:procdelDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:procdelDataGridViewTextBoxColumn:Visible = false.
      this-object:proceditDataGridViewTextBoxColumn:DataPropertyName = "procedit".
      this-object:proceditDataGridViewTextBoxColumn:HeaderText = "процедура редактирования".
      this-object:proceditDataGridViewTextBoxColumn:Name = "proceditDataGridViewTextBoxColumn".
      this-object:proceditDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:proceditDataGridViewTextBoxColumn:Visible = false.
      this-object:statusrow:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:DisplayedCells.
      this-object:statusrow:DataPropertyName = "fstatus".
      this-object:statusrow:HeaderText = "Статус".
      this-object:statusrow:Name = "statusrow".
      this-object:statusrow:ReadOnly = true.
      this-object:statusrow:Width = 66.
      this-object:bindCode:MaxDataGuess = 0.
      this-object:bindCode:NoLOBs = false.
      this-object:bindCode:Position = 0.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar1 as "Progress.Data.TableDesc[]" no-undo.
      arrayvar1 = new "Progress.Data.TableDesc[]"(0).
      tableDesc2:ChildTables = arrayvar1.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar2 as Progress.Data.ColumnPropDesc extent 19 no-undo.
      arrayvar2[1] = new Progress.Data.ColumnPropDesc("fchange", "", Progress.Data.DataType:LOGICAL).
      arrayvar2[2] = new Progress.Data.ColumnPropDesc("code", "Код", Progress.Data.DataType:CHARACTER).
      arrayvar2[3] = new Progress.Data.ColumnPropDesc("CodeName", "Наименование", Progress.Data.DataType:CHARACTER).
      arrayvar2[4] = new Progress.Data.ColumnPropDesc("CodeValue", "Значение", Progress.Data.DataType:CHARACTER).
      arrayvar2[5] = new Progress.Data.ColumnPropDesc("misc1", "Доп поле 1", Progress.Data.DataType:CHARACTER).
      arrayvar2[6] = new Progress.Data.ColumnPropDesc("misc2", "Доп поле 2", Progress.Data.DataType:CHARACTER).
      arrayvar2[7] = new Progress.Data.ColumnPropDesc("misc3", "Доп поле 3", Progress.Data.DataType:CHARACTER).
      arrayvar2[8] = new Progress.Data.ColumnPropDesc("misc4", "Доп поле 4", Progress.Data.DataType:CHARACTER).
      arrayvar2[9] = new Progress.Data.ColumnPropDesc("misc5", "Доп поле 5", Progress.Data.DataType:CHARACTER).
      arrayvar2[10] = new Progress.Data.ColumnPropDesc("misc6", "Доп поле 6", Progress.Data.DataType:CHARACTER).
      arrayvar2[11] = new Progress.Data.ColumnPropDesc("misc7", "Доп поле 7", Progress.Data.DataType:CHARACTER).
      arrayvar2[12] = new Progress.Data.ColumnPropDesc("misc8", "Доп поле 8", Progress.Data.DataType:CHARACTER).
      arrayvar2[13] = new Progress.Data.ColumnPropDesc("misc9", "Доп поле 9", Progress.Data.DataType:CHARACTER).
      arrayvar2[14] = new Progress.Data.ColumnPropDesc("misc10", "Доп поле 10", Progress.Data.DataType:CHARACTER).
      arrayvar2[15] = new Progress.Data.ColumnPropDesc("procview", "Процедура просмотра", Progress.Data.DataType:CHARACTER).
      arrayvar2[16] = new Progress.Data.ColumnPropDesc("parent", "", Progress.Data.DataType:CHARACTER).
      arrayvar2[17] = new Progress.Data.ColumnPropDesc("procdel", "Процедура удаления", Progress.Data.DataType:CHARACTER).
      arrayvar2[18] = new Progress.Data.ColumnPropDesc("procedit", "процедура редактирования", Progress.Data.DataType:CHARACTER).
      arrayvar2[19] = new Progress.Data.ColumnPropDesc("fstatus", "Статус", Progress.Data.DataType:CHARACTER).
      tableDesc2:Columns = arrayvar2.
      this-object:bindCode:TableSchema = tableDesc2.
      this-object:toolStrip1:Dock = System.Windows.Forms.DockStyle:None.
      this-object:toolStrip1:ImageScalingSize = new System.Drawing.Size(32, 32).
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar3 as System.Windows.Forms.ToolStripItem extent 9 no-undo.
      arrayvar3[1] = this-object:bexit.
      arrayvar3[2] = this-object:bnext.
      arrayvar3[3] = this-object:bAdd.
      arrayvar3[4] = this-object:bedit.
      arrayvar3[5] = this-object:bexport.
      arrayvar3[6] = this-object:bimport.
      arrayvar3[7] = this-object:bdel.
      arrayvar3[8] = this-object:bfilt.
      arrayvar3[9] = this-object:bselect.
      this-object:toolStrip1:Items:AddRange(arrayvar3).
      this-object:toolStrip1:Location = new System.Drawing.Point(0, 0).
      this-object:toolStrip1:Name = "toolStrip1".
      this-object:toolStrip1:Size = new System.Drawing.Size(228, 39).
      this-object:toolStrip1:TabIndex = 1.
      this-object:toolStrip1:Text = "toolStrip1".
      this-object:bexit:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
      this-object:bexit:Image = cast(resources:GetObject("bexit.Image"), System.Drawing.Image).
      this-object:bexit:ImageTransparentColor = System.Drawing.Color:Magenta.
      this-object:bexit:Name = "bexit".
      this-object:bexit:Size = new System.Drawing.Size(36, 36).
      this-object:bexit:Text = "Выход".
      this-object:bexit:Click:Subscribe(this-object:bexit_Click).
      this-object:bnext:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
      this-object:bnext:Image = cast(resources:GetObject("bnext.Image"), System.Drawing.Image).
      this-object:bnext:ImageTransparentColor = System.Drawing.Color:Magenta.
      this-object:bnext:Name = "bnext".
      this-object:bnext:Size = new System.Drawing.Size(36, 36).
      this-object:bnext:Text = "Подпараметры".
      this-object:bnext:Click:Subscribe(this-object:bnext_Click).
      this-object:bAdd:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
      this-object:bAdd:Image = cast(resources:GetObject("bAdd.Image"), System.Drawing.Image).
      this-object:bAdd:ImageTransparentColor = System.Drawing.Color:Magenta.
      this-object:bAdd:Name = "bAdd".
      this-object:bAdd:Size = new System.Drawing.Size(36, 36).
      this-object:bAdd:Text = "Добавить".
      this-object:bAdd:Click:Subscribe(this-object:bAdd_Click).
      this-object:bedit:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
      this-object:bedit:Image = cast(resources:GetObject("bedit.Image"), System.Drawing.Image).
      this-object:bedit:ImageTransparentColor = System.Drawing.Color:Magenta.
      this-object:bedit:Name = "bedit".
      this-object:bedit:Size = new System.Drawing.Size(36, 36).
      this-object:bedit:Text = "Изменить".
      this-object:bedit:Click:Subscribe(this-object:bedit_Click).
      this-object:bexport:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
      this-object:bexport:Image = cast(resources:GetObject("bexport.Image"), System.Drawing.Image).
      this-object:bexport:ImageTransparentColor = System.Drawing.Color:Magenta.
      this-object:bexport:Name = "bexport".
      this-object:bexport:Size = new System.Drawing.Size(36, 36).
      this-object:bexport:Text = "Экспорт".
      this-object:bexport:Visible = false.
      this-object:bexport:Click:Subscribe(this-object:bexport_Click).
      this-object:bimport:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
      this-object:bimport:Image = cast(resources:GetObject("bimport.Image"), System.Drawing.Image).
      this-object:bimport:ImageTransparentColor = System.Drawing.Color:Magenta.
      this-object:bimport:Name = "bimport".
      this-object:bimport:Size = new System.Drawing.Size(36, 36).
      this-object:bimport:Text = "Импорт".
      this-object:bimport:Visible = false.
      this-object:bimport:Click:Subscribe(this-object:bimport_Click).
      this-object:bdel:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
      this-object:bdel:Image = cast(resources:GetObject("bdel.Image"), System.Drawing.Image).
      this-object:bdel:ImageTransparentColor = System.Drawing.Color:Magenta.
      this-object:bdel:Name = "bdel".
      this-object:bdel:Size = new System.Drawing.Size(36, 36).
      this-object:bdel:Text = "Удалить".
      this-object:bdel:Click:Subscribe(this-object:bdel_Click).
      this-object:bfilt:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
      this-object:bfilt:Image = cast(resources:GetObject("bfilt.Image"), System.Drawing.Image).
      this-object:bfilt:ImageTransparentColor = System.Drawing.Color:Magenta.
      this-object:bfilt:Name = "bfilt".
      this-object:bfilt:Size = new System.Drawing.Size(36, 36).
      this-object:bfilt:Text = "Фильтр текущие/все".
      this-object:bfilt:Click:Subscribe(this-object:bfilt_Click).
      this-object:bselect:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
      this-object:bselect:Image = cast(resources:GetObject("bselect.Image"), System.Drawing.Image).
      this-object:bselect:ImageTransparentColor = System.Drawing.Color:Magenta.
      this-object:bselect:Name = "bselect".
      this-object:bselect:Size = new System.Drawing.Size(36, 36).
      this-object:bselect:Text = "Выбор".
      this-object:bselect:Visible = false.
      this-object:bselect:Click:Subscribe(this-object:bselect_Click).
      this-object:openFileDialog1:FileName = "openFileDialog1".
      this-object:ElemMenu:AllowMerge = false.
      define variable nestedvar1 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar1 = System.Windows.Forms.AnchorStyles:Top.
      this-object:ElemMenu:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar1, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:ElemMenu:BackColor = System.Drawing.SystemColors:ControlLight.
      this-object:ElemMenu:Dock = System.Windows.Forms.DockStyle:None.
      this-object:ElemMenu:ImageScalingSize = new System.Drawing.Size(28, 28).
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar4 as System.Windows.Forms.ToolStripItem extent 1 no-undo.
      arrayvar4[1] = this-object:Hist.
      this-object:ElemMenu:Items:AddRange(arrayvar4).
      this-object:ElemMenu:Location = new System.Drawing.Point(888, 0).
      this-object:ElemMenu:Name = "ElemMenu".
      this-object:ElemMenu:Size = new System.Drawing.Size(102, 36).
      this-object:ElemMenu:TabIndex = 3.
      this-object:ElemMenu:Text = "Меню".
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar5 as System.Windows.Forms.ToolStripItem extent 2 no-undo.
      arrayvar5[1] = this-object:oneHist.
      arrayvar5[2] = this-object:childHist.
      this-object:Hist:DropDownItems:AddRange(arrayvar5).
      this-object:Hist:Image = cast(resources:GetObject("Hist.Image"), System.Drawing.Image).
      this-object:Hist:Name = "Hist".
      this-object:Hist:Size = new System.Drawing.Size(94, 32).
      this-object:Hist:Text = "История".
      this-object:oneHist:Name = "oneHist".
      this-object:oneHist:Size = new System.Drawing.Size(130, 22).
      this-object:oneHist:Text = "Записи".
      this-object:oneHist:Click:Subscribe(this-object:bHistOne).
      this-object:childHist:Name = "childHist".
      this-object:childHist:Size = new System.Drawing.Size(130, 22).
      this-object:childHist:Text = "Потомков".
      this-object:childHist:Click:Subscribe(this-object:bchildHist).
      this-object:imageList1:ImageStream = cast(resources:GetObject("imageList1.ImageStream"), System.Windows.Forms.ImageListStreamer).
      this-object:imageList1:TransparentColor = System.Drawing.Color:Transparent.
      this-object:imageList1:Images:SetKeyName(0, "print_32x32.png").
      this-object:imageList1:Images:SetKeyName(1, "toolbox_32x32.png").
      this-object:ClientSize = new System.Drawing.Size(990, 618).
      this-object:Controls:Add(this-object:toolStrip1).
      this-object:Controls:Add(this-object:ElemMenu).
      this-object:Controls:Add(this-object:dataGridView1).
      this-object:Name = "browsecode".
      this-object:Text = "Справочники".
      cast(this-object:dataGridView1, System.ComponentModel.ISupportInitialize):EndInit().
      cast(this-object:bindCode, System.ComponentModel.ISupportInitialize):EndInit().
      this-object:toolStrip1:ResumeLayout(false).
      this-object:toolStrip1:PerformLayout().
      this-object:ElemMenu:ResumeLayout(false).
      this-object:ElemMenu:PerformLayout().
      this-object:ResumeLayout(false).
      this-object:PerformLayout().
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end method.
        @VisualDesigner.
   destructor public browsecode ( ):
      if mcretrg
      then
         delete object mCodeTrg.
   end destructor.
   method  public void Visual_Columns(input inum as integer ,iName as character ):
        if iname eq ?
        then
           this-object:dataGridView1:Columns[inum]:Visible = no.
        else assign
            this-object:dataGridView1:Columns[inum]:Visible = yes
            this-object:dataGridView1:Columns[inum]:HeaderText    = iName
        .
    end method.
    method  public void defColumn():
       Visual_Columns(1,"Код").
       Visual_Columns(2,"Наименование").
       Visual_Columns(3,"Значение").
    end method.
    method  public void chek1CERP():
          if mCodeTrg:get1CERP() and mCodeTrg:mode ne "sysadm"
          then do:
             assign
             this-object:bAdd:Visible    = no
             this-object:bdel:Visible    = no
             this-object:bedit:Visible   = no
             .
          end.
    end method.
   method public void addMenu (inum as integer, Ilable as character , ilistMenu as character ):
      define variable menuNew as System.Windows.Forms.ToolStripMenuItem no-undo.
      define variable menuItem as System.Windows.Forms.ToolStripMenuItem no-undo.
      menuNew = new System.Windows.Forms.ToolStripMenuItem().
      this-object:ElemMenu:Items:Add(menuNew).
      menuNew:Name = substitute ("MenuItem_&1",inum).
      menuNew:Size = new System.Drawing.Size(59, 20).
      menuNew:Text = Ilable.
      if Ilable begins "Печать"
      then do :
         menuNew:image = imageList1:Images[0].
         if trim(ilistMenu) eq ""
         then do :
            menuNew:Click:Subscribe(this-object:bMenuItem).
         end .
      end .
      else
         menuNew:image = imageList1:Images[1].
      define variable vi as integer no-undo.
      do vi = 1 to num-entries (ilistMenu):
         define variable vNameItem as character no-undo.
         vNameItem = entry(vi,ilistMenu).
         if vNameItem ne ""
         then do:
            menuItem = new System.Windows.Forms.ToolStripMenuItem().
            menuNew:DropDownItems:Add(menuItem).
            menuItem:Name = substitute ("MenuItem_&1_&2",inum,vi).
            menuItem:Size = new System.Drawing.Size(152, 22).
            menuItem:Text = vNameItem.
            menuItem:Click:Subscribe(this-object:bMenuItem).
         end.
      end.
   end.
end class.
