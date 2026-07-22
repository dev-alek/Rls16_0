using Progress.Lang.*.
using Progress.Windows.Form.
using System.ComponentModel.RefreshEventHandler from assembly.
block-level on error undo, throw.
class ibs.th.ref.bpa.BPA_browse inherits Form:
  define temp-table tt-query
    field ext-code  as character label "Код"
    field OsTypeRas as character label "Тип расчёта"
    field OsType    as character label "Тип"
    field OSname    as character label "Наим.Оператора"
    field Status_   as character label "Статус"
    field Mark      as character label "*"
    field id        as integer
    .
  define temp-table tt-OperServ like ub.OperServ .
  define private variable bindingSource1                   as Progress.Data.BindingSource                    no-undo.
  define private variable CalcType                         as System.Windows.Forms.ComboBox                  no-undo.
  define private variable components                       as System.ComponentModel.IContainer               no-undo.
  define private variable dataGridView1                    as System.Windows.Forms.DataGridView              no-undo.
   define private variable dataGridViewTextBoxColumn1 as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable id as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable label1                           as System.Windows.Forms.Label                     no-undo.
  define private variable markDataGridViewTextBoxColumn    as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable menuStrip                        as System.Windows.Forms.MenuStrip                 no-undo.
  define private variable osTypeDataGridViewTextBoxColumn  as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable oSnameDataGridViewTextBoxColumn  as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable OsTypeRas                        as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable radioButton3                     as System.Windows.Forms.RadioButton               no-undo.
  define private variable radioButton2                     as System.Windows.Forms.RadioButton               no-undo.
  define private variable radioButton1                     as System.Windows.Forms.RadioButton               no-undo.
  define private variable sortgroup                        as System.Windows.Forms.GroupBox                  no-undo.
  define private variable statusDataGridViewTextBoxColumn  as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable toolStripMenuGoods               as System.Windows.Forms.ToolStripMenuItem         no-undo.
  define private variable toolStripMenuHist                as System.Windows.Forms.ToolStripMenuItem         no-undo.
  define private variable toolStripMenuExit                as System.Windows.Forms.ToolStripMenuItem         no-undo.
  define private variable toolStripMenuEdit                as System.Windows.Forms.ToolStripMenuItem         no-undo.
  define private variable toolStripMenuDel                 as System.Windows.Forms.ToolStripMenuItem         no-undo.
  define private variable toolStripMenuCopy                as System.Windows.Forms.ToolStripMenuItem         no-undo.
  define private variable toolStripMenuChoose              as System.Windows.Forms.ToolStripMenuItem         no-undo.
  define private variable toolStripMenuAdd                 as System.Windows.Forms.ToolStripMenuItem         no-undo.
  define private variable toolStripMark                    as System.Windows.Forms.ToolStripMenuItem         no-undo.
  define private variable pMode                            as character                                      no-undo .
   define private variable toolStripMenuItem3 as System.Windows.Forms.ToolStripMenuItem no-undo.
   define private variable toolStripMenuItem2 as System.Windows.Forms.ToolStripMenuItem no-undo.
  define private variable toolStripMenuLookUp              as System.Windows.Forms.ToolStripMenuItem         no-undo.
  define         variable hQuery                           as handle                                         no-undo .
  define         variable v-status                         as character                                      no-undo .
  define         variable v-CalcType                       as integer                                        no-undo .
  define         variable v-id                             as integer                                        no-undo .
  define         variable v-list                           as character                                      no-undo .
  define         variable m-bpa-goods                      as class                                          ibs.th.ref.bpa.BPA_Goods      no-undo .
  define public  variable oBPAActionSubs                   as class                                          ibs.th.ref.bpa.BpaActionsSubs no-undo .
  define private variable iH                               as handle                                         no-undo .
  define public  variable p-list                           as character                                      no-undo .
  define         variable glog                             as logical                                        no-undo .
  define buffer buf_goods-attr for ub.goods-attr .
  define property parparentproc as handle no-undo
    private get.
    set(input iH as handle):
      parparentproc = ih.
    end.
  constructor public BPA_browse (iChange as character):
    super().
    pMode = iChange .
    InitializeComponent().
    Visual_form(pMode) .
    v-status = 'тек':U.
    this-object:CalcType:Text = "Все" .
    v-CalcType   = 0 .
    bindingSource1:Handle = browse_OperServ(v-status, v-CalcType).
    this-object:ComponentsCollection:ADD(this-object:components).
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.
  end constructor.
  constructor public BPA_browse ():
super().
    pMode = 'ИЗМЕНЕНИЕ':U .
    InitializeComponent().
    Visual_form(pMode) .
    v-status = 'тек':U.
    this-object:CalcType:Text = "Все" .
    v-CalcType   = 0 .
    bindingSource1:Handle = browse_OperServ(v-status, v-CalcType).
    this-object:ComponentsCollection:ADD(this-object:components).
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.
  end constructor.
  @VisualDesigner.
  method private void add_BPA( input sender as System.Object, input e as System.EventArgs ):
    button_addBPA_Click('ДОБАВЛЕНИЕ':U, v-id) .
    return.
  end method.
  @VisualDesigner.
  method private void b_edit( input sender as System.Object, input e as System.EventArgs ):
    button_Edit(tt-query.id, tt-query.OsType) .
    return.
  end method.
  @VisualDesigner.
  method private void b_lookup( input sender as System.Object, input e as System.EventArgs ):
    define variable vPos as integer no-undo.
    vPos = bindingSource1:Position.
    button_addBPA_Click('ПРОСМОТР':U , tt-query.id ) .
    bindingSource1:Handle = browse_OperServ(v-status, v-CalcType).
    bindingSource1:position = vPos.
    return.
  end method.
  method private void button_Edit( input p-id as integer, input p-type as character ):
    define variable vPos as integer no-undo.
    vPos = bindingSource1:Position.
    button_addBPA_Click('ИЗМЕНЕНИЕ':U , p-id) .
    bindingSource1:Handle = browse_OperServ(v-status, v-CalcType).
    bindingSource1:Position = vPos .
    return.
  end method.
  @VisualDesigner.
  method private void button1_Click( input sender as System.Object, input e as System.EventArgs ):
                //Выход
    Close().
    return.
  end method.
  @VisualDesigner.
  @VisualDesigner.
  method private void button_addBPA_Click(iChange as character, v-id as integer):
    define variable vPos      as integer   no-undo.
    define variable v-listact-brw as class ibs.th.ref.bpa.BPA_form no-undo .
    v-listact-brw = new ibs.th.ref.bpa.BPA_form (iChange,v-id).
    v-listact-brw:parparentproc = parparentproc.
    wait-for  v-listact-brw:ShowDialog() .
    vPos = bindingSource1:Position.
    bindingSource1:Handle = browse_OperServ(v-status, v-CalcType).
    bindingSource1:Position = vPos .
  end method.
  @VisualDesigner.
  method private void click_delete( input sender as System.Object, input e as System.EventArgs ):
    define variable vPos as integer no-undo.
    vPos = bindingSource1:Position.
    find first ub.OperServ exclusive-lock where ub.OperServ.id = tt-query.id and ub.OperServ.Status_ = 0 no-error .
    if available (ub.OperServ) then
    do:
      for each buf_goods-attr exclusive-lock where buf_goods-attr.attr-code = 'oper-serv-idd':U
        and buf_goods-attr.attr-value = string(tt-query.id):
        delete buf_goods-attr .
      end.
      ub.OperServ.Status_ = 1 .
    end.
    else
    do:
      find first ub.OperServ exclusive-lock where ub.OperServ.id = tt-query.id and ub.OperServ.Status_ = 1 no-error .
      if available (ub.OperServ) then
      do:
        MESSAGE
          "Востановить запись?"
          VIEW-AS ALERT-BOX QUESTION BUTTONS yes-no UPDATE glog.
        IF NOT glog THEN RETURN ERROR.
        else
        do:
          ub.OperServ.Status_ = 0 .
        end.
      end.
    end.
    bindingSource1:Handle = browse_OperServ(v-status, v-CalcType).
    bindingSource1:Position = vPos .
    return.
  end method.
  @VisualDesigner.
  method private void click_mark( input sender as System.Object, input e as System.EventArgs ):
    define variable vPos as integer no-undo.
    vPos = bindingSource1:Position.
    v-list = "" .
    if tt-query.Mark = "*" then tt-query.Mark = "" .
    else tt-query.Mark = "*" .
    for each tt-query no-lock where tt-query.Mark = "*":
      v-list = v-list + chr(6) + string(tt-query.id) .
    end.
    p-list = trim (v-list,chr(6)) .
    bindingSource1:Position = vPos + 1 .
    bindingSource1:Refresh() .
    return.
  end method.
  @VisualDesigner.
  method private void click_select( input sender as System.Object, input e as System.EventArgs):
    select_bpa(p-list) .
    close().
    return.
  end method.
        @VisualDesigner.
        method private void dataGridView1_CellClick( input sender as System.Object, input e as System.Windows.Forms.DataGridViewCellEventArgs ):
    if pmode ne 'ВЫБОР':U then return.
    v-list = "" .
    if tt-query.Mark = "*" then tt-query.Mark = "" .
    else tt-query.Mark = "*" .
    for each tt-query no-lock where tt-query.Mark = "*":
      v-list = v-list + chr(6) + string(tt-query.id) .
    end.
    p-list = trim (v-list,chr(6)) .
    bindingSource1:Refresh() .
                return.
        end method.
        @VisualDesigner.
        method private void dataGridView1_CellContentClick( input sender as System.Object, input e as System.Windows.Forms.DataGridViewCellEventArgs ):
    if pmode ne 'ВЫБОР':U then return.
    v-list = "" .
    if tt-query.Mark = "*" then tt-query.Mark = "" .
    else tt-query.Mark = "*" .
    for each tt-query no-lock where tt-query.Mark = "*":
      v-list = v-list + chr(6) + string(tt-query.id) .
    end.
    p-list = trim (v-list,chr(6)) .
    bindingSource1:Refresh() .
    return.
        end method.
        @VisualDesigner.
        method private void dataGridView1_CellContentDoubleClick( input sender as System.Object, input e as System.Windows.Forms.DataGridViewCellEventArgs ):
    if pmode ne 'ВЫБОР':U then return.
    v-list = "" .
    if tt-query.Mark = "*" then tt-query.Mark = "" .
    else tt-query.Mark = "*" .
    for each tt-query no-lock where tt-query.Mark = "*":
      v-list = v-list + chr(6) + string(tt-query.id) .
    end.
    p-list = trim (v-list,chr(6)) .
    bindingSource1:Refresh() .
    return.
        end method.
        @VisualDesigner.
        method private void menuStrip_DoubleClick( input sender as System.Object, input e as System.EventArgs ):
                this-object:dataGridView1:Columns[1]:Visible = not this-object:dataGridView1:Columns[1]:Visible .
                return.
        end method.
  @VisualDesigner.
  method private void select_bpa( output p-list as character):
    p-list = v-list .
    return.
  end method.
  method private void InitializeComponent(  ):
      this-object:components = new System.ComponentModel.Container().
      @VisualDesigner.FormMember (NeedsInitialize="true").
      define variable tableDesc1 as Progress.Data.TableDesc no-undo.
      tableDesc1 = new Progress.Data.TableDesc("tt-query").
      this-object:bindingSource1 = new Progress.Data.BindingSource(this-object:components).
      this-object:menuStrip = new System.Windows.Forms.MenuStrip().
      this-object:toolStripMenuExit = new System.Windows.Forms.ToolStripMenuItem().
      this-object:toolStripMark = new System.Windows.Forms.ToolStripMenuItem().
      this-object:toolStripMenuChoose = new System.Windows.Forms.ToolStripMenuItem().
      this-object:toolStripMenuAdd = new System.Windows.Forms.ToolStripMenuItem().
      this-object:toolStripMenuCopy = new System.Windows.Forms.ToolStripMenuItem().
      this-object:toolStripMenuEdit = new System.Windows.Forms.ToolStripMenuItem().
      this-object:toolStripMenuLookUp = new System.Windows.Forms.ToolStripMenuItem().
      this-object:toolStripMenuDel = new System.Windows.Forms.ToolStripMenuItem().
      this-object:toolStripMenuGoods = new System.Windows.Forms.ToolStripMenuItem().
      this-object:toolStripMenuHist = new System.Windows.Forms.ToolStripMenuItem().
      this-object:toolStripMenuItem2 = new System.Windows.Forms.ToolStripMenuItem().
      this-object:toolStripMenuItem3 = new System.Windows.Forms.ToolStripMenuItem().
      this-object:dataGridView1 = new System.Windows.Forms.DataGridView().
      this-object:markDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:dataGridViewTextBoxColumn1 = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:id = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:OsTypeRas = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:osTypeDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:oSnameDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:statusDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:radioButton3 = new System.Windows.Forms.RadioButton().
      this-object:radioButton2 = new System.Windows.Forms.RadioButton().
      this-object:radioButton1 = new System.Windows.Forms.RadioButton().
      this-object:CalcType = new System.Windows.Forms.ComboBox().
      this-object:label1 = new System.Windows.Forms.Label().
      this-object:sortgroup = new System.Windows.Forms.GroupBox().
      cast(this-object:bindingSource1, System.ComponentModel.ISupportInitialize):BeginInit().
      this-object:menuStrip:SuspendLayout().
      cast(this-object:dataGridView1, System.ComponentModel.ISupportInitialize):BeginInit().
      this-object:sortgroup:SuspendLayout().
      this-object:SuspendLayout().
      this-object:bindingSource1:MaxDataGuess = 0.
      this-object:bindingSource1:NoLOBs = false.
      this-object:bindingSource1:Position = 0.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar0 as "Progress.Data.TableDesc[]" no-undo.
      arrayvar0 = new "Progress.Data.TableDesc[]"(0).
      tableDesc1:ChildTables = arrayvar0.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar1 as Progress.Data.ColumnPropDesc extent 7 no-undo.
      arrayvar1[1] = new Progress.Data.ColumnPropDesc("OsTypeRas", "Тип расчёта", Progress.Data.DataType:CHARACTER).
      arrayvar1[2] = new Progress.Data.ColumnPropDesc("OsType", "Тип", Progress.Data.DataType:CHARACTER).
      arrayvar1[3] = new Progress.Data.ColumnPropDesc("OSname", "Наим.Оператора", Progress.Data.DataType:CHARACTER).
      arrayvar1[4] = new Progress.Data.ColumnPropDesc("Status_", "Статус", Progress.Data.DataType:CHARACTER).
      arrayvar1[5] = new Progress.Data.ColumnPropDesc("Mark", "*", Progress.Data.DataType:CHARACTER).
      arrayvar1[6] = new Progress.Data.ColumnPropDesc("id", "", Progress.Data.DataType:INTEGER).
      arrayvar1[7] = new Progress.Data.ColumnPropDesc("ext-code", "ext-code", Progress.Data.DataType:CHARACTER).
      tableDesc1:Columns = arrayvar1.
      this-object:bindingSource1:TableSchema = tableDesc1.
      this-object:menuStrip:Font = new System.Drawing.Font("Segoe UI", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Bold).
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar2 as System.Windows.Forms.ToolStripItem extent 10 no-undo.
      arrayvar2[1] = this-object:toolStripMenuExit.
      arrayvar2[2] = this-object:toolStripMark.
      arrayvar2[3] = this-object:toolStripMenuChoose.
      arrayvar2[4] = this-object:toolStripMenuAdd.
      arrayvar2[5] = this-object:toolStripMenuCopy.
      arrayvar2[6] = this-object:toolStripMenuEdit.
      arrayvar2[7] = this-object:toolStripMenuLookUp.
      arrayvar2[8] = this-object:toolStripMenuDel.
      arrayvar2[9] = this-object:toolStripMenuGoods.
      arrayvar2[10] = this-object:toolStripMenuHist.
      this-object:menuStrip:Items:AddRange(arrayvar2).
      this-object:menuStrip:Location = new System.Drawing.Point(0, 0).
      this-object:menuStrip:Name = "menuStrip".
      this-object:menuStrip:Padding = new System.Windows.Forms.Padding(15, 4, 0, 4).
      this-object:menuStrip:Size = new System.Drawing.Size(797, 27).
      this-object:menuStrip:TabIndex = 16.
      this-object:menuStrip:Text = "menuStrip1".
      this-object:menuStrip:DoubleClick:Subscribe(this-object:menuStrip_DoubleClick).
      this-object:toolStripMenuExit:Name = "toolStripMenuExit".
      this-object:toolStripMenuExit:Size = new System.Drawing.Size(58, 19).
      this-object:toolStripMenuExit:Text = "Выход".
      this-object:toolStripMenuExit:Click:Subscribe(this-object:button1_Click).
      this-object:toolStripMark:Name = "toolStripMark".
      this-object:toolStripMark:Size = new System.Drawing.Size(24, 19).
      this-object:toolStripMark:Text = "*".
      this-object:toolStripMark:Click:Subscribe(this-object:click_mark).
      this-object:toolStripMenuChoose:Name = "toolStripMenuChoose".
      this-object:toolStripMenuChoose:Size = new System.Drawing.Size(58, 19).
      this-object:toolStripMenuChoose:Text = "Выбор".
      this-object:toolStripMenuChoose:Click:Subscribe(this-object:click_select).
      this-object:toolStripMenuAdd:Name = "toolStripMenuAdd".
      this-object:toolStripMenuAdd:Size = new System.Drawing.Size(75, 19).
      this-object:toolStripMenuAdd:Text = "Добавить".
      this-object:toolStripMenuAdd:Click:Subscribe(this-object:add_BPA).
      this-object:toolStripMenuCopy:Name = "toolStripMenuCopy".
      this-object:toolStripMenuCopy:Size = new System.Drawing.Size(88, 19).
      this-object:toolStripMenuCopy:Text = "Копировать".
      this-object:toolStripMenuCopy:Click:Subscribe(this-object:menu_copy).
      this-object:toolStripMenuEdit:Name = "toolStripMenuEdit".
      this-object:toolStripMenuEdit:Size = new System.Drawing.Size(77, 19).
      this-object:toolStripMenuEdit:Text = "Изменить".
      this-object:toolStripMenuEdit:Click:Subscribe(this-object:b_edit).
      this-object:toolStripMenuLookUp:Name = "toolStripMenuLookUp".
      this-object:toolStripMenuLookUp:Size = new System.Drawing.Size(76, 19).
      this-object:toolStripMenuLookUp:Text = "Просмотр".
      this-object:toolStripMenuLookUp:Click:Subscribe(this-object:b_lookup).
      this-object:toolStripMenuDel:Name = "toolStripMenuDel".
      this-object:toolStripMenuDel:Size = new System.Drawing.Size(65, 19).
      this-object:toolStripMenuDel:Text = "Удалить".
      this-object:toolStripMenuDel:Click:Subscribe(this-object:click_delete).
      this-object:toolStripMenuGoods:Name = "toolStripMenuGoods".
      this-object:toolStripMenuGoods:Size = new System.Drawing.Size(62, 19).
      this-object:toolStripMenuGoods:Text = "Товары".
      this-object:toolStripMenuGoods:Click:Subscribe(this-object:select_goods).
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar3 as System.Windows.Forms.ToolStripItem extent 2 no-undo.
      arrayvar3[1] = this-object:toolStripMenuItem2.
      arrayvar3[2] = this-object:toolStripMenuItem3.
      this-object:toolStripMenuHist:DropDownItems:AddRange(arrayvar3).
      this-object:toolStripMenuHist:Name = "toolStripMenuHist".
      this-object:toolStripMenuHist:Size = new System.Drawing.Size(68, 19).
      this-object:toolStripMenuHist:Text = "История".
      this-object:toolStripMenuItem2:Name = "toolStripMenuItem2".
      this-object:toolStripMenuItem2:Size = new System.Drawing.Size(189, 22).
      this-object:toolStripMenuItem2:Text = "Платежных агентов".
      this-object:toolStripMenuItem2:Click:Subscribe(this-object:toolStripMenuItem2_Click).
      this-object:toolStripMenuItem3:Name = "toolStripMenuItem3".
      this-object:toolStripMenuItem3:Size = new System.Drawing.Size(189, 22).
      this-object:toolStripMenuItem3:Text = "Привязки товаров".
      this-object:toolStripMenuItem3:Click:Subscribe(this-object:toolStripMenuItem3_Click).
      this-object:dataGridView1:AllowUserToAddRows = false.
      this-object:dataGridView1:AllowUserToDeleteRows = false.
      this-object:dataGridView1:AllowUserToOrderColumns = true.
      this-object:dataGridView1:AllowUserToResizeRows = false.
      define variable nestedvar0 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar0 = cast(Progress.Util.EnumHelper:Or(cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Bottom), System.Windows.Forms.AnchorStyles), System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:dataGridView1:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:dataGridView1:AutoGenerateColumns = false.
      this-object:dataGridView1:AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode:Fill.
      this-object:dataGridView1:BorderStyle = System.Windows.Forms.BorderStyle:None.
      this-object:dataGridView1:ClipboardCopyMode = System.Windows.Forms.DataGridViewClipboardCopyMode:Disable.
      this-object:dataGridView1:ColumnHeadersBorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle:Single.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar4 as System.Windows.Forms.DataGridViewColumn extent 7 no-undo.
      arrayvar4[1] = this-object:markDataGridViewTextBoxColumn.
      arrayvar4[2] = this-object:dataGridViewTextBoxColumn1.
      arrayvar4[3] = this-object:id.
      arrayvar4[4] = this-object:OsTypeRas.
      arrayvar4[5] = this-object:osTypeDataGridViewTextBoxColumn.
      arrayvar4[6] = this-object:oSnameDataGridViewTextBoxColumn.
      arrayvar4[7] = this-object:statusDataGridViewTextBoxColumn.
      this-object:dataGridView1:Columns:AddRange(arrayvar4).
      this-object:dataGridView1:DataSource = this-object:bindingSource1.
      this-object:dataGridView1:EnableHeadersVisualStyles = false.
      this-object:dataGridView1:ImeMode = System.Windows.Forms.ImeMode:NoControl.
      this-object:dataGridView1:Location = new System.Drawing.Point(5, 91).
      this-object:dataGridView1:MultiSelect = false.
      this-object:dataGridView1:Name = "dataGridView1".
      this-object:dataGridView1:RightToLeft = System.Windows.Forms.RightToLeft:No.
      this-object:dataGridView1:RowHeadersVisible = false.
      this-object:dataGridView1:ScrollBars = System.Windows.Forms.ScrollBars:Vertical.
      this-object:dataGridView1:SelectionMode = System.Windows.Forms.DataGridViewSelectionMode:FullRowSelect.
      this-object:dataGridView1:Size = new System.Drawing.Size(786, 457).
      this-object:dataGridView1:TabIndex = 15.
      this-object:dataGridView1:CellClick:Subscribe(this-object:dataGridView1_CellClick).
      this-object:dataGridView1:CellContentClick:Subscribe(this-object:dataGridView1_CellContentClick).
      this-object:dataGridView1:CellContentDoubleClick:Subscribe(this-object:dataGridView1_CellContentDoubleClick).
      this-object:markDataGridViewTextBoxColumn:DataPropertyName = "Mark".
      this-object:markDataGridViewTextBoxColumn:FillWeight = Progress.Util.CastUtil:ToSingle(21.952177).
      this-object:markDataGridViewTextBoxColumn:HeaderText = "*".
      this-object:markDataGridViewTextBoxColumn:Name = "markDataGridViewTextBoxColumn".
      this-object:markDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:markDataGridViewTextBoxColumn:Resizable = System.Windows.Forms.DataGridViewTriState:False.
      this-object:dataGridViewTextBoxColumn1:DataPropertyName = "ext-code".
      this-object:dataGridViewTextBoxColumn1:HeaderText = "Внешний ключ".
      this-object:dataGridViewTextBoxColumn1:Name = "dataGridViewTextBoxColumn1".
      this-object:dataGridViewTextBoxColumn1:Visible = false.
      this-object:id:DataPropertyName = "id".
      this-object:id:HeaderText = "Код".
      this-object:id:Name = "id".
      this-object:id:ReadOnly = true.
      this-object:OsTypeRas:DataPropertyName = "OsTypeRas".
      this-object:OsTypeRas:FillWeight = Progress.Util.CastUtil:ToSingle(152.2842865).
      this-object:OsTypeRas:HeaderText = "Тип".
      this-object:OsTypeRas:Name = "OsTypeRas".
      this-object:OsTypeRas:ReadOnly = true.
      this-object:osTypeDataGridViewTextBoxColumn:DataPropertyName = "OsType".
      this-object:osTypeDataGridViewTextBoxColumn:FillWeight = Progress.Util.CastUtil:ToSingle(155.7800751).
      this-object:osTypeDataGridViewTextBoxColumn:HeaderText = "Тип расчёта".
      this-object:osTypeDataGridViewTextBoxColumn:Name = "osTypeDataGridViewTextBoxColumn".
      this-object:osTypeDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:oSnameDataGridViewTextBoxColumn:DataPropertyName = "OSname".
      this-object:oSnameDataGridViewTextBoxColumn:FillWeight = Progress.Util.CastUtil:ToSingle(172.8451538).
      this-object:oSnameDataGridViewTextBoxColumn:HeaderText = "Наим.Оператора".
      this-object:oSnameDataGridViewTextBoxColumn:MinimumWidth = 10.
      this-object:oSnameDataGridViewTextBoxColumn:Name = "oSnameDataGridViewTextBoxColumn".
      this-object:oSnameDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:statusDataGridViewTextBoxColumn:DataPropertyName = "Status_".
      this-object:statusDataGridViewTextBoxColumn:FillWeight = Progress.Util.CastUtil:ToSingle(48.569191).
      this-object:statusDataGridViewTextBoxColumn:HeaderText = "Статус".
      this-object:statusDataGridViewTextBoxColumn:Name = "statusDataGridViewTextBoxColumn".
      this-object:statusDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:radioButton3:Location = new System.Drawing.Point(165, 20).
      this-object:radioButton3:Name = "radioButton3".
      this-object:radioButton3:Size = new System.Drawing.Size(104, 24).
      this-object:radioButton3:TabIndex = 2.
      this-object:radioButton3:Text = "Удаленные".
      this-object:radioButton3:UseCompatibleTextRendering = true.
      this-object:radioButton3:UseVisualStyleBackColor = true.
      this-object:radioButton3:CheckedChanged:Subscribe(this-object:r_status_Checked).
      this-object:radioButton2:Checked = true.
      this-object:radioButton2:Location = new System.Drawing.Point(71, 20).
      this-object:radioButton2:Name = "radioButton2".
      this-object:radioButton2:Size = new System.Drawing.Size(77, 24).
      this-object:radioButton2:TabIndex = 1.
      this-object:radioButton2:TabStop = true.
      this-object:radioButton2:Text = "Текущие".
      this-object:radioButton2:UseCompatibleTextRendering = true.
      this-object:radioButton2:UseVisualStyleBackColor = true.
      this-object:radioButton2:CheckedChanged:Subscribe(this-object:r_status_Checked).
      this-object:radioButton1:Location = new System.Drawing.Point(8, 20).
      this-object:radioButton1:Name = "radioButton1".
      this-object:radioButton1:Size = new System.Drawing.Size(54, 24).
      this-object:radioButton1:TabIndex = 0.
      this-object:radioButton1:Text = "Все".
      this-object:radioButton1:UseCompatibleTextRendering = true.
      this-object:radioButton1:UseVisualStyleBackColor = true.
      this-object:radioButton1:CheckedChanged:Subscribe(this-object:r_status_Checked).
      this-object:CalcType:DropDownStyle = System.Windows.Forms.ComboBoxStyle:DropDownList.
      this-object:CalcType:FormattingEnabled = true.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar5 as System.Object extent 4 no-undo.
      arrayvar5[1] = "Все".
      arrayvar5[2] = "Оплата Сотовой связи".
      arrayvar5[3] = "Начисление на карту".
      arrayvar5[4] = "Платежный агент".
      this-object:CalcType:Items:AddRange(arrayvar5).
      this-object:CalcType:Location = new System.Drawing.Point(474, 17).
      this-object:CalcType:Name = "CalcType".
      this-object:CalcType:Size = new System.Drawing.Size(306, 23).
      this-object:CalcType:TabIndex = 18.
      this-object:CalcType:SelectedIndexChanged:Subscribe(this-object:r_type_Checked).
      this-object:label1:Location = new System.Drawing.Point(413, 20).
      this-object:label1:Name = "label1".
      this-object:label1:Size = new System.Drawing.Size(55, 23).
      this-object:label1:TabIndex = 19.
      this-object:label1:Text = "По типу:".
      this-object:label1:UseCompatibleTextRendering = true.
      this-object:sortgroup:Controls:Add(this-object:radioButton3).
      this-object:sortgroup:Controls:Add(this-object:label1).
      this-object:sortgroup:Controls:Add(this-object:radioButton2).
      this-object:sortgroup:Controls:Add(this-object:radioButton1).
      this-object:sortgroup:Controls:Add(this-object:CalcType).
      this-object:sortgroup:Location = new System.Drawing.Point(5, 30).
      this-object:sortgroup:Name = "sortgroup".
      this-object:sortgroup:Size = new System.Drawing.Size(786, 55).
      this-object:sortgroup:TabIndex = 20.
      this-object:sortgroup:TabStop = false.
      this-object:sortgroup:Text = "Сортировка".
      this-object:sortgroup:UseCompatibleTextRendering = true.
      this-object:ClientSize = new System.Drawing.Size(797, 549).
      this-object:Controls:Add(this-object:sortgroup).
      this-object:Controls:Add(this-object:dataGridView1).
      this-object:Controls:Add(this-object:menuStrip).
      this-object:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:Name = "BPA_browse".
      this-object:Text = "СПРАВОЧНИК ПЛАТЕЖНЫХ АГЕНТОВ/ОПЕРАТОРОВ".
      cast(this-object:bindingSource1, System.ComponentModel.ISupportInitialize):EndInit().
      this-object:menuStrip:ResumeLayout(false).
      this-object:menuStrip:PerformLayout().
      cast(this-object:dataGridView1, System.ComponentModel.ISupportInitialize):EndInit().
      this-object:sortgroup:ResumeLayout(false).
      this-object:ResumeLayout(false).
      this-object:PerformLayout().
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
  end method.
  @VisualDesigner.
  method private void menu_copy( input sender as System.Object, input e as System.EventArgs ):
    define buffer buf_OperServ for ub.OperServ .
    define variable type_ as character no-undo .
    define variable p-id  as integer   no-undo .
    find first buf_OperServ no-lock where buf_OperServ.id = tt-query.id no-error .
    if available (buf_OperServ) then
    do:
      create tt-OperServ .
      buffer-copy buf_OperServ except buf_OperServ.id to tt-OperServ .
      tt-OperServ.id = next-value (s-operserv-id) .
      create ub.OperServ .
      buffer-copy tt-OperServ to ub.OperServ .
      p-id = ub.OperServ.id .
      case ub.OperServ.OsType:
        when 0 then
          do:
            type_ = "" .
          end.
        when 1 then
          do:
            type_ = "ОСС (OpenWay)".
          end.
        when 2 then
          do:
            type_ = "Автопомощь".
          end.
        when 3 then
          do:
            type_ = "Пополнение ВБРР" .
          end.
        when 5 then
          do:
            type_ = "Выдача наличных" .
          end.
      end case .
      button_Edit( p-id , type_ ) .
    end.
    return.
  end method.
  @VisualDesigner.
  method private void r_status_Checked( input sender as System.Object, input e as System.EventArgs ):
    if this-object:radioButton1:Checked = true then v-status = 'все':U .
    if this-object:radioButton2:Checked = true then v-status = 'тек':U .
    if this-object:radioButton3:Checked = true then v-status = 'удал':U .
    bindingSource1:Handle = browse_OperServ(v-status, v-CalcType).
    return.
  end method.
  @VisualDesigner.
  method private void r_type_Checked( input sender as System.Object, input e as System.EventArgs ):
    case this-object:CalcType:Text:
      when "Все" then
        do:
          v-CalcType = 0 .
        end.
      when "Оплата Сотовой связи" then
        do:
          v-CalcType = 1 .
        end.
      when "Оплата по договору" then
        do:
          v-CalcType = 2 .
        end.
      when "Оплата Счёта" then
        do:
          v-CalcType = 3 .
        end.
      when "Начисление на карту" then
        do:
          v-CalcType = 4 .
        end.
      when "Платежный агент" then
        do:
          v-CalcType = 5 .
        end.
    end case.
    bindingSource1:Handle = browse_OperServ(v-status, v-CalcType).
    return.
  end method.
  @VisualDesigner.
  method private void select_goods( input sender as System.Object, input e as System.EventArgs ):
    define variable v-listact-brw as class ibs.th.ref.bpa.BPA_Goods no-undo .
    v-listact-brw = new ibs.th.ref.bpa.BPA_Goods (pMode,string( tt-query.id), 'oper-serv-idd':U).
 //v-listact-brw:Visual_form(iChange).
    v-listact-brw:parparentproc = parparentproc.
    wait-for  v-listact-brw:ShowDialog() .
    define variable v-err-msg as character no-undo .
    define variable vPos      as integer   no-undo.
    vPos = bindingSource1:Position.
    bindingSource1:Handle = browse_OperServ(v-status, v-CalcType).
    bindingSource1:Position = vPos.
    catch exAppErrors as class Progress.Lang.AppError :
      v-err-msg = exAppErrors:ReturnValue .
      if v-err-msg > "" then .
      else
      do :
        v-err-msg = exAppErrors:GetMessage(1) .
        if v-err-msg > "" then .
        else v-err-msg = "AppError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ibs\th\ref\bpa\bpa_browse.cls" .
      end .
      message v-err-msg  view-as alert-box.
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      v-err-msg = exProErrors:GetMessage(1) .
      if v-err-msg > "" then .
      else v-err-msg = "ProError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ibs\th\ref\bpa\bpa_browse.cls" .
      message "ProError" skip(1) v-err-msg  view-as alert-box.
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      v-err-msg = "Unexpected error в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ibs\th\ref\bpa\bpa_browse.cls " + exAnyErrors:GetMessage(1).
      message "LangError" skip(1) v-err-msg  view-as alert-box.
    end catch .
    finally:
      if valid-object(v-listact-brw) then delete object v-listact-brw no-error .
    end finally.
  end method.
  method private void add_query(buffer buf_OperServ for OperServ):
      create tt-query .
      assign
        tt-query.ext-code = buf_OperServ.ext-code
        tt-query.id       = buf_OperServ.id
        tt-query.OSname   = buf_OperServ.OSname
        .
      case buf_OperServ.OsType:
        when 0 then
          do:
            tt-query.OsType = "" .
          end.
        when 1 then
          do:
            tt-query.OsType = "ОСС (OpenWay)" .
          end.
        when 2 then
          do:
            tt-query.OsType = "Автопомощь" .
          end.
        when 3 then
          do:
            tt-query.OsType = "Пополнение ВБРР" .
          end.
          when 5 then
          do:
            tt-query.OsType = "Выдача наличных" .
          end.
      end case .
      case buf_OperServ.CalcType:
        when 1 then
          do:
            tt-query.OsTypeRas = "Оплата Сотовой связи" .
          end.
        when 2 then
          do:
            tt-query.OsTypeRas = "Оплата по договору" .
          end.
        when 3 then
          do:
            tt-query.OsTypeRas = "Оплата Счёта" .
          end.
        when 4 then
          do:
            tt-query.OsTypeRas = "Начисление на карту" .
          end.
        when 5 then
          do:
            tt-query.OsTypeRas = "Платежный агент" .
          end.
      end case .
      if buf_OperServ.Status_ = 0 then tt-query.Status_ = 'тек':U .
      else tt-query.Status_ = 'удал':U .
  end.
  method private handle browse_OperServ(status_ as character, type_ as integer):
    define buffer buf_OperServ for ub.OperServ .
    empty temp-table tt-query .
    case type_ :
      when 0 then
      do:
         case status_ :
            when 'все':U then
            do:
               for each buf_OperServ no-lock :
                  add_query(buffer buf_OperServ).
               end.
            end.
            when 'тек':U then
            do:
               for each buf_OperServ no-lock where buf_OperServ.Status_ = 0:
                  add_query(buffer buf_OperServ).
               end.
            end.
            when 'удал':U then
            do:
               for each buf_OperServ no-lock where buf_OperServ.Status_ = 1:
                  add_query(buffer buf_OperServ).
               end.
            end.
         end case.
      end.
      when 1 then
      do:
         case status_ :
         when 'все':U then
         do:
            for each buf_OperServ no-lock where buf_OperServ.CalcType = type_:
               add_query(buffer buf_OperServ).
            end.
         end.
         when 'тек':U then
         do:
            for each buf_OperServ no-lock where buf_OperServ.Status_ = 0 and buf_OperServ.CalcType = type_:
               add_query(buffer buf_OperServ).
            end.
         end.
         when 'удал':U then
         do:
            for each buf_OperServ no-lock where buf_OperServ.Status_ = 1 and buf_OperServ.CalcType = type_:
               add_query(buffer buf_OperServ).
            end.
         end.
         end case.
      end .
      when 4 then
        do:
          case status_ :
            when 'все':U then
              do:
                for each buf_OperServ no-lock where buf_OperServ.CalcType = type_:
                  add_query(buffer buf_OperServ).
                end.
              end.
            when 'тек':U then
              do:
                for each buf_OperServ no-lock where buf_OperServ.Status_ = 0 and buf_OperServ.CalcType = type_:
                  add_query(buffer buf_OperServ).
                end.
              end.
            when 'удал':U then
              do:
                for each buf_OperServ no-lock where buf_OperServ.Status_ = 1 and buf_OperServ.CalcType = type_:
                  add_query(buffer buf_OperServ).
                end.
              end.
          end case.
        end.
      when 5 then
        do:
          case status_ :
            when 'все':U then
              do:
                for each buf_OperServ no-lock where buf_OperServ.CalcType = type_:
                  add_query(buffer buf_OperServ).
                end.
              end.
            when 'тек':U then
              do:
                for each buf_OperServ no-lock where buf_OperServ.Status_ = 0 and buf_OperServ.CalcType = type_:
                  add_query(buffer buf_OperServ).
                end.
              end.
            when 'удал':U then
              do:
                for each buf_OperServ no-lock where buf_OperServ.Status_ = 1 and buf_OperServ.CalcType = type_:
                  add_query(buffer buf_OperServ).
                end.
              end.
          end case.
        end.
    end case .
    if valid-handle(hQuery)  THEN DELETE object hQuery.
    create query hQuery.
    hQuery:set-buffers(buffer tt-query:HANDLE).
    hQuery:query-prepare("FOR EACH tt-query").
    hQuery:query-open.
    return hQuery .
  end method .
        @VisualDesigner.
        method private void toolStripMenuItem2_Click( input sender as System.Object, input e as System.EventArgs ):
                define variable v-rid-list as character no-undo.
      if available tt-query
      then
      run ref/coshist.w (tt-query.id, // id
                   parparentproc,
                   0,
                   "",
                   0,
                   "",
                   "one",
                   ?,
                   "",
                   "",
                   ibs.th.gbl.gbl-var:g#db-num,
                   ?,
                   input-output v-rid-list ).
      return.
        end method.
        @VisualDesigner.
        method private void toolStripMenuItem3_Click( input sender as System.Object, input e as System.EventArgs ):
                define variable v-rid-list as character no-undo.
      if available tt-query
      then
      run ref/cosghist.w (tt-query.id, // id
                   parparentproc,
                   0,
                   "",
                   0,
                   "",
                   "one",
                   ?,
                   "",
                   "",
                   ibs.th.gbl.gbl-var:g#db-num,
                   ?,
                   input-output v-rid-list ).
                return.
        end method.
  METHOD PUBLIC VOID Visual_form( INPUT iChange AS character ):
    case iChange:
      when 'ИЗМЕНЕНИЕ':U then
        do:
          assign
            this-object:toolStripMark:Enabled = false.
          this-object:toolStripMenuChoose:Enabled = false.
          .
        end.
      when 'ВЫБОР':U then
        do:
          assign
          this-object:toolStripMenuAdd:Enabled = false .
          this-object:toolStripMenuCopy:Enabled = false .
          this-object:toolStripMenuDel:Enabled = false .
          this-object:toolStripMenuEdit:Enabled = false .
          this-object:toolStripMenuGoods:Enabled  = false .
          .
        end.
      when 'ПРОСМОТР':U then
        do:
          assign
          this-object:toolStripMenuAdd:Enabled = false .
          this-object:toolStripMenuCopy:Enabled = false .
          this-object:toolStripMenuDel:Enabled = false .
          this-object:toolStripMenuEdit:Enabled = false .
          this-object:toolStripMenuGoods:Enabled  = true .
          this-object:toolStripMark:Enabled = false.
          this-object:toolStripMenuChoose:Enabled = false.
          .
        end.
    end case .
    return.
  end method .
  destructor public BPA_browse ( ):
  end destructor.
end class.
