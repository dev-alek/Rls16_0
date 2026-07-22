USING Progress.Lang.*.
USING Progress.Windows.UserControl.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS ibs.th.ref.promo.uc_Presents INHERITS UserControl:
    define private variable bindPromoGift as Progress.Data.BindingSource no-undo.
    DEFINE PRIVATE VARIABLE button2 AS System.Windows.Forms.Button NO-UNDO.
    DEFINE PRIVATE VARIABLE button1 AS System.Windows.Forms.Button NO-UNDO.
    DEFINE PRIVATE VARIABLE components AS System.ComponentModel.IContainer NO-UNDO.
    define private variable gdscodeDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable gdsNameDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable qntyDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    DEFINE PRIVATE VARIABLE tableLayoutPanel2 AS System.Windows.Forms.TableLayoutPanel NO-UNDO.
    DEFINE PRIVATE VARIABLE tableLayoutPanel1 AS System.Windows.Forms.TableLayoutPanel NO-UNDO.
    DEFINE PRIVATE VARIABLE label1 AS System.Windows.Forms.Label NO-UNDO.
    DEFINE PRIVATE VARIABLE dataGridView1 AS System.Windows.Forms.DataGridView NO-UNDO.
    define variable mBindName as character no-undo init "PromoGiftForCrit"  .
    define private variable m-promo-trg as class ibs.th.ref.promo.promo_trg no-undo.
method Public VOID SetPromoTrg(input v-promo-trg as class ibs.th.ref.promo.promo_trg  ):
    m-promo-trg = v-promo-trg.
        SetBind().
end.
method Public VOID PublicEvent (input iEvent as character, input iEventParam as character   ):
        LocalEvent(iEvent, iEventParam).
end.
        @VisualDesigner.
        method private void button1_Click( input sender as System.Object, input e as System.EventArgs ):
        if valid-handle(bindPromoGift:handle)
        then
           bindPromoGift:Assign().
    m-promo-trg:addgds(mBindName).
    bindPromoGift:handle:query-open.
    bindPromoGift:RefreshAll().
                return.
        end method.
        @VisualDesigner.
        method private void button2_Click( input sender as System.Object, input e as System.EventArgs ):
                m-promo-trg:delgds("promogift"). //mBindName).
    bindPromoGift:handle:query-open.
    bindPromoGift:RefreshAll().
                return.
        end method.
    method Public VOID SetBind( ):
        SetBind(no).
        setDisable(m-promo-trg:modeview).
    end.
    method private VOID SetBind(input iflag as logical ):
        bindPromoGift:handle = m-promo-trg:getQuery(mBindName,iflag).
        if iflag
        then
            bindPromoGift:RefreshAll().
    end.
    method Public VOID LocalEvent(input iEvent as character, input iEventParam as character  ):
        if iEvent eq "changeCrit"
        then
            SetBind(yes).
        if iEvent eq "ViewGiftForAction"
        then
           mBindName =  "PromoGiftForAction".
    end.
    method public VOID setDisable(input iModeView as logical  ):
        assign
            button1:enabled = not iModeview
            button2:enabled = not iModeview
            THIS-OBJECT:dataGridView1:Columns[2]:ReadOnly = iModeview
         .
    end.
    CONSTRUCTOR PUBLIC uc_Presents (  ):
        SUPER().
        InitializeComponent().
        THIS-OBJECT:ComponentsCollection:ADD(THIS-OBJECT:components).
        CATCH e AS Progress.Lang.Error:
            UNDO, THROW e.
        END CATCH.
    END CONSTRUCTOR.
    CONSTRUCTOR PUBLIC uc_Presents (input a as class Progress.Data.BindingSource ):
        SUPER().
        InitializeComponent().
        THIS-OBJECT:ComponentsCollection:ADD(THIS-OBJECT:components).
        CATCH e AS Progress.Lang.Error:
            UNDO, THROW e.
        END CATCH.
    END CONSTRUCTOR.
    METHOD PRIVATE VOID InitializeComponent(  ):
    this-object:components = new System.ComponentModel.Container().
    @VisualDesigner.FormMember (NeedsInitialize="true").
    define variable tableDesc1 as Progress.Data.TableDesc no-undo.
    tableDesc1 = new Progress.Data.TableDesc("tt-PromoGift").
    @VisualDesigner.FormMember (NeedsInitialize="true").
    define variable dataGridViewCellStyle1 as System.Windows.Forms.DataGridViewCellStyle no-undo.
    dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle().
    this-object:tableLayoutPanel1 = new System.Windows.Forms.TableLayoutPanel().
    this-object:dataGridView1 = new System.Windows.Forms.DataGridView().
    this-object:bindPromoGift = new Progress.Data.BindingSource(this-object:components).
    this-object:tableLayoutPanel2 = new System.Windows.Forms.TableLayoutPanel().
    this-object:button2 = new System.Windows.Forms.Button().
    this-object:button1 = new System.Windows.Forms.Button().
    this-object:label1 = new System.Windows.Forms.Label().
    this-object:gdscodeDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:gdsNameDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:qntyDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:tableLayoutPanel1:SuspendLayout().
    cast(this-object:dataGridView1, System.ComponentModel.ISupportInitialize):BeginInit().
    cast(this-object:bindPromoGift, System.ComponentModel.ISupportInitialize):BeginInit().
    this-object:tableLayoutPanel2:SuspendLayout().
    this-object:SuspendLayout().
    this-object:tableLayoutPanel1:ColumnCount = 1.
    this-object:tableLayoutPanel1:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    this-object:tableLayoutPanel1:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(20))).
    this-object:tableLayoutPanel1:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(20))).
    this-object:tableLayoutPanel1:Controls:Add(this-object:dataGridView1, 0, 2).
    this-object:tableLayoutPanel1:Controls:Add(this-object:tableLayoutPanel2, 0, 1).
    this-object:tableLayoutPanel1:Controls:Add(this-object:label1, 0, 0).
    this-object:tableLayoutPanel1:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:tableLayoutPanel1:Location = new System.Drawing.Point(0, 0).
    this-object:tableLayoutPanel1:Name = "tableLayoutPanel1".
    this-object:tableLayoutPanel1:RowCount = 3.
    this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(25))).
    this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(25))).
    this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    this-object:tableLayoutPanel1:Size = new System.Drawing.Size(500, 400).
    this-object:tableLayoutPanel1:TabIndex = 5.
    this-object:dataGridView1:AllowUserToAddRows = false.
    this-object:dataGridView1:AllowUserToDeleteRows = false.
    this-object:dataGridView1:AutoGenerateColumns = false.
    this-object:dataGridView1:AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode:Fill.
    this-object:dataGridView1:ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode:AutoSize.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar0 as System.Windows.Forms.DataGridViewColumn extent 3 no-undo.
    arrayvar0[1] = this-object:gdscodeDataGridViewTextBoxColumn.
    arrayvar0[2] = this-object:gdsNameDataGridViewTextBoxColumn.
    arrayvar0[3] = this-object:qntyDataGridViewTextBoxColumn.
    this-object:dataGridView1:Columns:AddRange(arrayvar0).
    this-object:dataGridView1:DataSource = this-object:bindPromoGift.
    this-object:dataGridView1:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:dataGridView1:Location = new System.Drawing.Point(3, 53).
    this-object:dataGridView1:Name = "dataGridView1".
    this-object:dataGridView1:RowHeadersVisible = false.
    this-object:dataGridView1:Size = new System.Drawing.Size(494, 344).
    this-object:dataGridView1:TabIndex = 8.
    this-object:bindPromoGift:AutoUpdate = true.
    this-object:bindPromoGift:MaxDataGuess = 0.
    this-object:bindPromoGift:NoLOBs = false.
    this-object:bindPromoGift:Position = 0.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar1 as "Progress.Data.TableDesc[]" no-undo.
    arrayvar1 = new "Progress.Data.TableDesc[]"(0).
    tableDesc1:ChildTables = arrayvar1.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar2 as Progress.Data.ColumnPropDesc extent 3 no-undo.
    arrayvar2[1] = new Progress.Data.ColumnPropDesc("gdsName", "Номенклатура", Progress.Data.DataType:CHARACTER).
    arrayvar2[2] = new Progress.Data.ColumnPropDesc("gds-code", "Код товара", Progress.Data.DataType:INTEGER).
    arrayvar2[3] = new Progress.Data.ColumnPropDesc("qnty", "Количество", Progress.Data.DataType:DECIMAL).
    tableDesc1:Columns = arrayvar2.
    this-object:bindPromoGift:TableSchema = tableDesc1.
    this-object:tableLayoutPanel2:ColumnCount = 4.
    this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(80))).
    this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(80))).
    this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(120))).
    this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    this-object:tableLayoutPanel2:Controls:Add(this-object:button2, 1, 0).
    this-object:tableLayoutPanel2:Controls:Add(this-object:button1, 0, 0).
    this-object:tableLayoutPanel2:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:tableLayoutPanel2:Location = new System.Drawing.Point(3, 25).
    this-object:tableLayoutPanel2:Margin = new System.Windows.Forms.Padding(3, 0, 0, 0).
    this-object:tableLayoutPanel2:Name = "tableLayoutPanel2".
    this-object:tableLayoutPanel2:RowCount = 1.
    this-object:tableLayoutPanel2:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    this-object:tableLayoutPanel2:Size = new System.Drawing.Size(497, 25).
    this-object:tableLayoutPanel2:TabIndex = 0.
    this-object:button2:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:button2:Location = new System.Drawing.Point(80, 0).
    this-object:button2:Margin = new System.Windows.Forms.Padding(0).
    this-object:button2:Name = "button2".
    this-object:button2:Size = new System.Drawing.Size(80, 25).
    this-object:button2:TabIndex = 1.
    this-object:button2:Text = "Удалить".
    this-object:button2:UseCompatibleTextRendering = true.
    this-object:button2:UseVisualStyleBackColor = true.
    this-object:button2:Click:Subscribe(this-object:button2_Click).
    this-object:button1:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:button1:Location = new System.Drawing.Point(0, 0).
    this-object:button1:Margin = new System.Windows.Forms.Padding(0).
    this-object:button1:Name = "button1".
    this-object:button1:Size = new System.Drawing.Size(80, 25).
    this-object:button1:TabIndex = 0.
    this-object:button1:Text = "Добавить".
    this-object:button1:UseCompatibleTextRendering = true.
    this-object:button1:UseVisualStyleBackColor = true.
    this-object:button1:Click:Subscribe(this-object:button1_Click).
    this-object:label1:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:label1:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(12), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:label1:Location = new System.Drawing.Point(3, 0).
    this-object:label1:Name = "label1".
    this-object:label1:Size = new System.Drawing.Size(494, 25).
    this-object:label1:TabIndex = 4.
    this-object:label1:Text = "Подарки".
    this-object:label1:UseCompatibleTextRendering = true.
    this-object:gdscodeDataGridViewTextBoxColumn:DataPropertyName = "gds-code".
    this-object:gdscodeDataGridViewTextBoxColumn:FillWeight = Progress.Util.CastUtil:ToSingle(103.7735825).
    this-object:gdscodeDataGridViewTextBoxColumn:HeaderText = "Код товара".
    this-object:gdscodeDataGridViewTextBoxColumn:Name = "gdscodeDataGridViewTextBoxColumn".
    this-object:gdscodeDataGridViewTextBoxColumn:ReadOnly = true.
    this-object:gdsNameDataGridViewTextBoxColumn:DataPropertyName = "gdsName".
    this-object:gdsNameDataGridViewTextBoxColumn:FillWeight = Progress.Util.CastUtil:ToSingle(96.2264175).
    this-object:gdsNameDataGridViewTextBoxColumn:HeaderText = "Номенклатура".
    this-object:gdsNameDataGridViewTextBoxColumn:Name = "gdsNameDataGridViewTextBoxColumn".
    this-object:gdsNameDataGridViewTextBoxColumn:ReadOnly = true.
    this-object:qntyDataGridViewTextBoxColumn:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:ColumnHeader.
    this-object:qntyDataGridViewTextBoxColumn:DataPropertyName = "qnty".
    dataGridViewCellStyle1:Format = "N0".
    dataGridViewCellStyle1:NullValue = ?.
    this-object:qntyDataGridViewTextBoxColumn:DefaultCellStyle = dataGridViewCellStyle1.
    this-object:qntyDataGridViewTextBoxColumn:HeaderText = "Количество".
    this-object:qntyDataGridViewTextBoxColumn:Name = "qntyDataGridViewTextBoxColumn".
    this-object:qntyDataGridViewTextBoxColumn:Width = 91.
    this-object:AutoScaleDimensions = new System.Drawing.SizeF(Progress.Util.CastUtil:ToSingle(6), Progress.Util.CastUtil:ToSingle(13)).
    this-object:Controls:Add(this-object:tableLayoutPanel1).
    this-object:Margin = new System.Windows.Forms.Padding(0).
    this-object:Name = "uc_Presents".
    this-object:Size = new System.Drawing.Size(500, 400).
    this-object:tableLayoutPanel1:ResumeLayout(false).
    cast(this-object:dataGridView1, System.ComponentModel.ISupportInitialize):EndInit().
    cast(this-object:bindPromoGift, System.ComponentModel.ISupportInitialize):EndInit().
    this-object:tableLayoutPanel2:ResumeLayout(false).
    this-object:ResumeLayout(false).
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.
    END METHOD.
    DESTRUCTOR PUBLIC uc_Presents ( ):
        bindPromoGift:Dispose().
    END DESTRUCTOR.
END CLASS.
