using Progress.Lang.*.
using Progress.Windows.Form.
block-level on error undo, throw.
class ibs.th.ref.bpa.BPA_Goods inherits Form:
  define temp-table tt-goods
    field gds-code  like ub.goods.gds-code
    field artic     like ub.goods.artic
    field gds-name  like ub.goods.gds-name
    field gds-type  like ub.goods.gds-type
    field prod-type like ub.goods.prod-type
    field prod-code like ub.goods.prod-code
    index pi gds-code
    .
  define temp-table tt-goods-attr like ub.goods-attr.
  define property parparentproc as handle no-undo
  private get.
  set(input iH as handle):
    parparentproc = iH.
  end.
  define private variable bindingSource1                   as Progress.Data.BindingSource                    no-undo.
  define private variable articDataGridViewTextBoxColumn   as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable components                       as System.ComponentModel.IContainer               no-undo.
  define private variable gdstypeDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable gdsnameDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable gdscodeDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable toolStripMenuDelAll              as System.Windows.Forms.ToolStripMenuItem         no-undo.
  define private variable toolStripMenuDel                 as System.Windows.Forms.ToolStripMenuItem         no-undo.
  define private variable toolStripMenuCancel              as System.Windows.Forms.ToolStripMenuItem         no-undo.
  define private variable toolStripMenuAdd                 as System.Windows.Forms.ToolStripMenuItem         no-undo.
  define private variable menuGoods                        as System.Windows.Forms.MenuStrip                 no-undo.
  define private variable dataGridView1                    as System.Windows.Forms.DataGridView              no-undo.
  define         variable p-attr-code                      as character                                      no-undo .
  define         variable hQuery                           as handle                                         no-undo .
  define         variable id_                              as character                                      no-undo .
  constructor public BPA_Goods (iChange as character, p-id as character, p-attr as character  ):
    super().
    p-attr-code = p-attr .
    id_         = p-id   .
    InitializeComponent().
    Visual_form(iChange) .
    bindingSource1:Handle = browse_Goods().
    this-object:ComponentsCollection:ADD(this-object:components).
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.
  end constructor.
  constructor public BPA_Goods ( ):
  end constructor.
  @VisualDesigner.
  method private void click_add( input sender as System.Object, input e as System.EventArgs ):
    add_attr().
    return.
  end method.
  @VisualDesigner.
  method private void add_attr():
    define variable v-GdsList as character no-undo .
    define variable ii        as integer   no-undo .
    define buffer bf_goods-attr     for ub.goods-attr .
    define buffer buf_tt-goods-attr for tt-goods-attr .
    define variable glog     as logical no-undo .
    define variable v-glog   as logical no-undo .
    define variable goods-ok as logical no-undo .
    define buffer buf_OperServ  for ub.OperServ .
    define variable v-name  as character no-undo .
    empty temp-table tt-goods-attr .
    run str/gdslist.p ( input parparentproc
      , output v-GdsList).
    if v-GdsList <> "" then
    do:
      v-GdsList = trim(v-GdsList,chr(6)) .
      do ii = 1 to num-entries (v-GdsList,chr(6)):
        find first ub.goods-attr where ub.goods-attr.attr-code = p-attr-code and
          ub.goods-attr.gds-code   = integer(entry(ii,v-GdsList,chr(6))) no-error .
        if not available (ub.goods-attr) then
        do:
          CREATE ub.goods-attr.
          ASSIGN
            ub.goods-attr.attr-code  = p-attr-code
            ub.goods-attr.attr-value = string(id_)
            ub.goods-attr.gds-code   = integer(entry(ii,v-GdsList,chr(6)))
            .
        end.
        else
        do:
          create tt-goods-attr.
          ASSIGN
            tt-goods-attr.attr-code  = p-attr-code
            tt-goods-attr.attr-value = ub.goods-attr.attr-value
            tt-goods-attr.gds-code   = integer(entry(ii,v-GdsList,chr(6)))
            .
        end.
      end.
    end.
    find first buf_tt-goods-attr no-error .
    if available (buf_tt-goods-attr) then
    do:
      MESSAGE
        "Перепривязать товары?"
        VIEW-AS ALERT-BOX QUESTION BUTTONS yes-no UPDATE glog.
      IF NOT glog THEN RETURN ERROR.
      else
      do:
        MESSAGE
          "Для всех товаров?"
          VIEW-AS ALERT-BOX QUESTION BUTTONS yes-no UPDATE v-glog.
        IF NOT v-glog THEN
        do:
          for each tt-goods-attr:
            for first ub.goods no-lock where ub.goods.gds-code = tt-goods-attr.gds-code:
            if p-attr-code = 'oper-serv-idd':U then do:
            find first buf_OperServ no-lock where buf_OperServ.id = integer(tt-goods-attr.attr-value) no-error .
            if available (buf_OperServ) then v-name = buf_OperServ.OSname .
            end.
            else do:
              find first ub.CashBook no-lock where ub.CashBook.id = integer(tt-goods-attr.attr-value) no-error .
              if available (ub.CashBook) then v-name = ub.CashBook.CashBookName .
            end.
            message "Товар: " + ub.goods.gds-name + " привязан к " + v-name + ", перепривязать?"
              view-as alert-box question buttons yes-no update goods-ok .
            if goods-ok then
            do:
              find first bf_goods-attr exclusive-lock where bf_goods-attr.gds-code = tt-goods-attr.gds-code
                and bf_goods-attr.attr-code = tt-goods-attr.attr-code .
              delete bf_goods-attr .
              create bf_goods-attr .
              assign
                bf_goods-attr.gds-code   = tt-goods-attr.gds-code
                bf_goods-attr.attr-code  = tt-goods-attr.attr-code
                bf_goods-attr.attr-value = string(id_)
                .
            end.
          end.
          end.
        end.
        else
        do:
          for each tt-goods-attr:
            find first bf_goods-attr exclusive-lock where bf_goods-attr.gds-code = tt-goods-attr.gds-code
              and bf_goods-attr.attr-code = tt-goods-attr.attr-code .
            delete bf_goods-attr .
            create bf_goods-attr .
            assign
              bf_goods-attr.gds-code   = tt-goods-attr.gds-code
              bf_goods-attr.attr-code  = tt-goods-attr.attr-code
              bf_goods-attr.attr-value = string(id_)
              .
          end.
        end.
      end.
    end.
    bindingSource1:Handle = browse_Goods().
    return.
  end method.
  @VisualDesigner.
  method private void click_cancel( input sender as System.Object, input e as System.EventArgs ):
    Close().
    return.
  end method.
  @VisualDesigner.
  method private void click_del( input sender as System.Object, input e as System.EventArgs ):
    define buffer buf_goods-attr for ub.goods-attr .
                define variable vPos as integer no-undo.
    vPos = bindingSource1:Position.
    find first buf_goods-attr exclusive-lock where buf_goods-attr.gds-code = tt-goods.gds-code and buf_goods-attr.attr-code = p-attr-code no-error .
    if available (buf_goods-attr) then
    do:
      delete buf_goods-attr .
    end.
    bindingSource1:Handle = browse_Goods().
    return.
  end method.
        @VisualDesigner.
        method private void click_del_all( input sender as System.Object, input e as System.EventArgs ):
                define buffer buf_goods-attr for ub.goods-attr .
                for each buf_goods-attr exclusive-lock where buf_goods-attr.attr-code = p-attr-code
                and buf_goods-attr.attr-value = string(id_):
                  delete buf_goods-attr .
                end.
                bindingSource1:Handle = browse_Goods().
                return.
        end method.
  METHOD PUBLIC VOID Visual_form( INPUT iChange AS character ):
    if iChange = 'ПРОСМОТР':U then
    do:
      assign
      this-object:toolStripMenuAdd:Enabled = false.
      this-object:toolStripMenuDel:Enabled = false.
      this-object:toolStripMenuDelAll:Enabled = false .
      .
    end.
    return.
  end method .
  method private handle browse_Goods():
    define buffer buf_goods-attr for ub.goods-attr .
    define buffer buf_goods      for ub.goods .
    empty temp-table tt-goods .
    for each buf_goods-attr no-lock where buf_goods-attr.attr-code = p-attr-code
    and buf_goods-attr.attr-value = string(id_),
      first buf_goods no-lock where buf_goods.gds-code = buf_goods-attr.gds-code:
      create tt-goods .
      assign
        tt-goods.artic    = buf_goods.artic
        tt-goods.gds-code = buf_goods.gds-code
        tt-goods.gds-name = buf_goods.gds-name
        tt-goods.gds-type = buf_goods.gds-type
        .
    end.
    if valid-handle(hQuery)  THEN DELETE object hQuery.
    create query hQuery.
    hQuery:set-buffers(buffer tt-goods:HANDLE).
    hQuery:query-prepare("FOR EACH tt-goods").
    hQuery:query-open.
    return hQuery .
  end method .
  method private void InitializeComponent(  ):
    this-object:components = new System.ComponentModel.Container().
    @VisualDesigner.FormMember (NeedsInitialize="true").
    define variable tableDesc1 as Progress.Data.TableDesc no-undo.
    tableDesc1 = new Progress.Data.TableDesc("tt-goods").
    this-object:menuGoods = new System.Windows.Forms.MenuStrip().
    this-object:toolStripMenuCancel = new System.Windows.Forms.ToolStripMenuItem().
    this-object:toolStripMenuAdd = new System.Windows.Forms.ToolStripMenuItem().
    this-object:toolStripMenuDel = new System.Windows.Forms.ToolStripMenuItem().
    this-object:toolStripMenuDelAll = new System.Windows.Forms.ToolStripMenuItem().
    this-object:dataGridView1 = new System.Windows.Forms.DataGridView().
    this-object:gdscodeDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:articDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:gdsnameDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:gdstypeDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:bindingSource1 = new Progress.Data.BindingSource(this-object:components).
    this-object:menuGoods:SuspendLayout().
    cast(this-object:dataGridView1, System.ComponentModel.ISupportInitialize):BeginInit().
    cast(this-object:bindingSource1, System.ComponentModel.ISupportInitialize):BeginInit().
    this-object:SuspendLayout().
    this-object:menuGoods:Font = new System.Drawing.Font("Tahoma", Progress.Util.CastUtil:ToSingle(9.75), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar0 as System.Windows.Forms.ToolStripItem extent 4 no-undo.
    arrayvar0[1] = this-object:toolStripMenuCancel.
    arrayvar0[2] = this-object:toolStripMenuAdd.
    arrayvar0[3] = this-object:toolStripMenuDel.
    arrayvar0[4] = this-object:toolStripMenuDelAll.
    this-object:menuGoods:Items:AddRange(arrayvar0).
    this-object:menuGoods:Location = new System.Drawing.Point(0, 0).
    this-object:menuGoods:Name = "menuGoods".
    this-object:menuGoods:Size = new System.Drawing.Size(628, 24).
    this-object:menuGoods:TabIndex = 0.
    this-object:menuGoods:Text = "menuStrip1".
    this-object:toolStripMenuCancel:Name = "toolStripMenuCancel".
    this-object:toolStripMenuCancel:Size = new System.Drawing.Size(63, 20).
    this-object:toolStripMenuCancel:Text = "Выход".
    this-object:toolStripMenuCancel:Click:Subscribe(this-object:click_cancel).
    this-object:toolStripMenuAdd:Name = "toolStripMenuAdd".
    this-object:toolStripMenuAdd:Size = new System.Drawing.Size(83, 20).
    this-object:toolStripMenuAdd:Text = "Добавить".
    this-object:toolStripMenuAdd:Click:Subscribe(this-object:click_add).
    this-object:toolStripMenuDel:Name = "toolStripMenuDel".
    this-object:toolStripMenuDel:Size = new System.Drawing.Size(76, 20).
    this-object:toolStripMenuDel:Text = "Удалить".
    this-object:toolStripMenuDel:Click:Subscribe(this-object:click_del).
    this-object:toolStripMenuDelAll:Name = "toolStripMenuDelAll".
    this-object:toolStripMenuDelAll:Size = new System.Drawing.Size(79, 20).
    this-object:toolStripMenuDelAll:Text = "Очистить".
    this-object:toolStripMenuDelAll:Click:Subscribe(this-object:click_del_all).
    this-object:dataGridView1:AllowUserToAddRows = false.
    this-object:dataGridView1:AllowUserToDeleteRows = false.
    this-object:dataGridView1:AutoGenerateColumns = false.
    this-object:dataGridView1:AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode:Fill.
    this-object:dataGridView1:ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode:AutoSize.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar1 as System.Windows.Forms.DataGridViewColumn extent 4 no-undo.
    arrayvar1[1] = this-object:gdscodeDataGridViewTextBoxColumn.
    arrayvar1[2] = this-object:articDataGridViewTextBoxColumn.
    arrayvar1[3] = this-object:gdsnameDataGridViewTextBoxColumn.
    arrayvar1[4] = this-object:gdstypeDataGridViewTextBoxColumn.
    this-object:dataGridView1:Columns:AddRange(arrayvar1).
    this-object:dataGridView1:DataSource = this-object:bindingSource1.
    this-object:dataGridView1:EnableHeadersVisualStyles = false.
    this-object:dataGridView1:Location = new System.Drawing.Point(0, 27).
    this-object:dataGridView1:Name = "dataGridView1".
    this-object:dataGridView1:ReadOnly = true.
    this-object:dataGridView1:RowHeadersVisible = false.
    this-object:dataGridView1:Size = new System.Drawing.Size(628, 414).
    this-object:dataGridView1:TabIndex = 1.
    this-object:gdscodeDataGridViewTextBoxColumn:DataPropertyName = "gds-code".
    this-object:gdscodeDataGridViewTextBoxColumn:FillWeight = Progress.Util.CastUtil:ToSingle(58.8832512).
    this-object:gdscodeDataGridViewTextBoxColumn:HeaderText = "Код товара".
    this-object:gdscodeDataGridViewTextBoxColumn:Name = "gdscodeDataGridViewTextBoxColumn".
    this-object:gdscodeDataGridViewTextBoxColumn:ReadOnly = true.
    this-object:articDataGridViewTextBoxColumn:DataPropertyName = "artic".
    this-object:articDataGridViewTextBoxColumn:FillWeight = Progress.Util.CastUtil:ToSingle(58.8832512).
    this-object:articDataGridViewTextBoxColumn:HeaderText = "Артикул".
    this-object:articDataGridViewTextBoxColumn:Name = "articDataGridViewTextBoxColumn".
    this-object:articDataGridViewTextBoxColumn:ReadOnly = true.
    this-object:gdsnameDataGridViewTextBoxColumn:DataPropertyName = "gds-name".
    this-object:gdsnameDataGridViewTextBoxColumn:FillWeight = Progress.Util.CastUtil:ToSingle(223.3502502).
    this-object:gdsnameDataGridViewTextBoxColumn:HeaderText = "Название товара".
    this-object:gdsnameDataGridViewTextBoxColumn:Name = "gdsnameDataGridViewTextBoxColumn".
    this-object:gdsnameDataGridViewTextBoxColumn:ReadOnly = true.
    this-object:gdstypeDataGridViewTextBoxColumn:DataPropertyName = "gds-type".
    this-object:gdstypeDataGridViewTextBoxColumn:FillWeight = Progress.Util.CastUtil:ToSingle(58.8832512).
    this-object:gdstypeDataGridViewTextBoxColumn:HeaderText = "Тип".
    this-object:gdstypeDataGridViewTextBoxColumn:Name = "gdstypeDataGridViewTextBoxColumn".
    this-object:gdstypeDataGridViewTextBoxColumn:ReadOnly = true.
    this-object:bindingSource1:MaxDataGuess = 0.
    this-object:bindingSource1:NoLOBs = false.
    this-object:bindingSource1:Position = 0.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar2 as "Progress.Data.TableDesc[]" no-undo.
    arrayvar2 = new "Progress.Data.TableDesc[]"(0).
    tableDesc1:ChildTables = arrayvar2.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar3 as Progress.Data.ColumnPropDesc extent 4 no-undo.
    arrayvar3[1] = new Progress.Data.ColumnPropDesc("gds-code", "Код товара", Progress.Data.DataType:INTEGER).
    arrayvar3[2] = new Progress.Data.ColumnPropDesc("artic", "Артикул", Progress.Data.DataType:CHARACTER).
    arrayvar3[3] = new Progress.Data.ColumnPropDesc("gds-name", "Название товара", Progress.Data.DataType:CHARACTER).
    arrayvar3[4] = new Progress.Data.ColumnPropDesc("gds-type", "Тип", Progress.Data.DataType:CHARACTER).
    tableDesc1:Columns = arrayvar3.
    this-object:bindingSource1:TableSchema = tableDesc1.
    this-object:ClientSize = new System.Drawing.Size(628, 453).
    this-object:Controls:Add(this-object:dataGridView1).
    this-object:Controls:Add(this-object:menuGoods).
    this-object:Font = new System.Drawing.Font("Times New Roman", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:MainMenuStrip = this-object:menuGoods.
    this-object:Name = "BPA_Goods".
    this-object:Text = "Товары".
    this-object:menuGoods:ResumeLayout(false).
    this-object:menuGoods:PerformLayout().
    cast(this-object:dataGridView1, System.ComponentModel.ISupportInitialize):EndInit().
    cast(this-object:bindingSource1, System.ComponentModel.ISupportInitialize):EndInit().
    this-object:ResumeLayout(false).
    this-object:PerformLayout().
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.
  end method.
  destructor public BPA_Goods ( ):
  end destructor.
end class.
