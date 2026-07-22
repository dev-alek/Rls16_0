USING Progress.Lang.*.
USING Progress.Windows.UserControl.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS ibs.th.ref.promo.uc_TabAZS INHERITS UserControl:
    define variable vss-revision       as character no-undo init "$Revision$":U .
    define variable vss-author         as character no-undo init "$Author$":U .
    define variable vss-date           as character no-undo init "$Date$":U .
    define variable vss-workfile       as character no-undo init "$Workfile$":U .
    define variable vss-archive        as character no-undo init "$Archive$":U .
    define variable vss-description    as character no-undo init "Просмотр/редактирование одной акции".
    define private variable bindPromoObject as Progress.Data.BindingSource no-undo.
    DEFINE PRIVATE VARIABLE button3 AS System.Windows.Forms.Button NO-UNDO.
    DEFINE PRIVATE VARIABLE button2 AS System.Windows.Forms.Button NO-UNDO.
    DEFINE PRIVATE VARIABLE button1 AS System.Windows.Forms.Button NO-UNDO.
    DEFINE PRIVATE VARIABLE components AS System.ComponentModel.IContainer NO-UNDO.
    DEFINE PRIVATE VARIABLE dataGridView1 AS System.Windows.Forms.DataGridView NO-UNDO.
    define private variable objtypeDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable objcodeDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable objNameDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable objDbNumDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable firmNameDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable firmCodeDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable enddateDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    DEFINE PRIVATE VARIABLE tableLayoutPanel2 AS System.Windows.Forms.TableLayoutPanel NO-UNDO.
    DEFINE PRIVATE VARIABLE tableLayoutPanel1 AS System.Windows.Forms.TableLayoutPanel NO-UNDO.
    define private variable m-promo-trg as class ibs.th.ref.promo.promo_trg no-undo.
        @VisualDesigner.
        method private void button1_Click( input sender as System.Object, input e as System.EventArgs ):
                if m-promo-trg:addObject()
                then do:
                bindPromoObject:handle:query-open().
                bindPromoObject:RefreshAll().
                end.
                return.
        end method.
        @VisualDesigner.
        method private void button2_Click( input sender as System.Object, input e as System.EventArgs ):
                m-promo-trg:delgds("PromoObject").
      bindPromoObject:handle:query-open().
      bindPromoObject:RefreshAll().
    return.
        end method.
    method Public VOID SetPromoTrg(input v-promo-trg as class ibs.th.ref.promo.promo_trg  ):
        m-promo-trg = v-promo-trg.
        setDisable(m-promo-trg:modeVIEW).
        SetBind().
    end.
    method public VOID setDisable(input iModeView as logical  ):
        assign
            button1:enabled = not iModeview
            button2:enabled = not iModeview
            button3:enabled = not iModeview
            THIS-OBJECT:dataGridView1:Columns[6]:ReadOnly = iModeview
         //   THIS-OBJECT:dataGridView1:Columns[6]:ReadOnly = pMode
        .
    end.
    method Public VOID SetBind( ):
         bindPromoObject:handle = m-promo-trg:getQuery("PromoObject").
    end.
    CONSTRUCTOR PUBLIC uc_TabAZS (  ):
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
    tableDesc1 = new Progress.Data.TableDesc("tt-PromoObject").
    this-object:tableLayoutPanel1 = new System.Windows.Forms.TableLayoutPanel().
    this-object:tableLayoutPanel2 = new System.Windows.Forms.TableLayoutPanel().
    this-object:button3 = new System.Windows.Forms.Button().
    this-object:button2 = new System.Windows.Forms.Button().
    this-object:button1 = new System.Windows.Forms.Button().
    this-object:dataGridView1 = new System.Windows.Forms.DataGridView().
    this-object:objtypeDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:objcodeDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:objNameDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:objDbNumDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:firmCodeDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:firmNameDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:enddateDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:bindPromoObject = new Progress.Data.BindingSource(this-object:components).
    this-object:tableLayoutPanel1:SuspendLayout().
    this-object:tableLayoutPanel2:SuspendLayout().
    cast(this-object:dataGridView1, System.ComponentModel.ISupportInitialize):BeginInit().
    cast(this-object:bindPromoObject, System.ComponentModel.ISupportInitialize):BeginInit().
    this-object:SuspendLayout().
    this-object:tableLayoutPanel1:ColumnCount = 1.
    this-object:tableLayoutPanel1:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    this-object:tableLayoutPanel1:Controls:Add(this-object:tableLayoutPanel2, 0, 1).
    this-object:tableLayoutPanel1:Controls:Add(this-object:dataGridView1, 0, 2).
    this-object:tableLayoutPanel1:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:tableLayoutPanel1:Location = new System.Drawing.Point(0, 0).
    this-object:tableLayoutPanel1:Name = "tableLayoutPanel1".
    this-object:tableLayoutPanel1:RowCount = 3.
    this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(7))).
    this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(25))).
    this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    this-object:tableLayoutPanel1:Size = new System.Drawing.Size(503, 297).
    this-object:tableLayoutPanel1:TabIndex = 4.
    this-object:tableLayoutPanel2:ColumnCount = 4.
    this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(80))).
    this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(80))).
    this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(120))).
    this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    this-object:tableLayoutPanel2:Controls:Add(this-object:button3, 2, 0).
    this-object:tableLayoutPanel2:Controls:Add(this-object:button2, 1, 0).
    this-object:tableLayoutPanel2:Controls:Add(this-object:button1, 0, 0).
    this-object:tableLayoutPanel2:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:tableLayoutPanel2:Location = new System.Drawing.Point(3, 7).
    this-object:tableLayoutPanel2:Margin = new System.Windows.Forms.Padding(3, 0, 0, 0).
    this-object:tableLayoutPanel2:Name = "tableLayoutPanel2".
    this-object:tableLayoutPanel2:RowCount = 1.
    this-object:tableLayoutPanel2:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    this-object:tableLayoutPanel2:Size = new System.Drawing.Size(500, 25).
    this-object:tableLayoutPanel2:TabIndex = 0.
    this-object:button3:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:button3:Location = new System.Drawing.Point(160, 0).
    this-object:button3:Margin = new System.Windows.Forms.Padding(0).
    this-object:button3:Name = "button3".
    this-object:button3:Size = new System.Drawing.Size(120, 25).
    this-object:button3:TabIndex = 2.
    this-object:button3:Text = "Добавить по отбору".
    this-object:button3:UseCompatibleTextRendering = true.
    this-object:button3:UseVisualStyleBackColor = true.
    this-object:button3:Visible = false.
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
    this-object:dataGridView1:AllowUserToAddRows = false.
    this-object:dataGridView1:AllowUserToDeleteRows = false.
    this-object:dataGridView1:AllowUserToOrderColumns = true.
    this-object:dataGridView1:AutoGenerateColumns = false.
    this-object:dataGridView1:AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode:Fill.
    this-object:dataGridView1:ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode:AutoSize.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar0 as System.Windows.Forms.DataGridViewColumn extent 7 no-undo.
    arrayvar0[1] = this-object:objtypeDataGridViewTextBoxColumn.
    arrayvar0[2] = this-object:objcodeDataGridViewTextBoxColumn.
    arrayvar0[3] = this-object:objNameDataGridViewTextBoxColumn.
    arrayvar0[4] = this-object:objDbNumDataGridViewTextBoxColumn.
    arrayvar0[5] = this-object:firmCodeDataGridViewTextBoxColumn.
    arrayvar0[6] = this-object:firmNameDataGridViewTextBoxColumn.
    arrayvar0[7] = this-object:enddateDataGridViewTextBoxColumn.
    this-object:dataGridView1:Columns:AddRange(arrayvar0).
    this-object:dataGridView1:DataSource = this-object:bindPromoObject.
    this-object:dataGridView1:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:dataGridView1:Location = new System.Drawing.Point(3, 35).
    this-object:dataGridView1:Name = "dataGridView1".
    this-object:dataGridView1:Size = new System.Drawing.Size(497, 259).
    this-object:dataGridView1:TabIndex = 2.
    this-object:objtypeDataGridViewTextBoxColumn:DataPropertyName = "obj-type".
    this-object:objtypeDataGridViewTextBoxColumn:HeaderText = "Тип".
    this-object:objtypeDataGridViewTextBoxColumn:Name = "objtypeDataGridViewTextBoxColumn".
    this-object:objtypeDataGridViewTextBoxColumn:ReadOnly = true.
    this-object:objcodeDataGridViewTextBoxColumn:DataPropertyName = "obj-code".
    this-object:objcodeDataGridViewTextBoxColumn:HeaderText = "Код".
    this-object:objcodeDataGridViewTextBoxColumn:Name = "objcodeDataGridViewTextBoxColumn".
    this-object:objcodeDataGridViewTextBoxColumn:ReadOnly = true.
    this-object:objNameDataGridViewTextBoxColumn:DataPropertyName = "objName".
    this-object:objNameDataGridViewTextBoxColumn:HeaderText = "Название".
    this-object:objNameDataGridViewTextBoxColumn:Name = "objNameDataGridViewTextBoxColumn".
    this-object:objNameDataGridViewTextBoxColumn:ReadOnly = true.
    this-object:objDbNumDataGridViewTextBoxColumn:DataPropertyName = "objDbNum".
    this-object:objDbNumDataGridViewTextBoxColumn:HeaderText = "БД".
    this-object:objDbNumDataGridViewTextBoxColumn:Name = "objDbNumDataGridViewTextBoxColumn".
    this-object:objDbNumDataGridViewTextBoxColumn:ReadOnly = true.
    this-object:firmCodeDataGridViewTextBoxColumn:DataPropertyName = "FirmCode".
    this-object:firmCodeDataGridViewTextBoxColumn:HeaderText = "Фирма".
    this-object:firmCodeDataGridViewTextBoxColumn:Name = "firmCodeDataGridViewTextBoxColumn".
    this-object:firmCodeDataGridViewTextBoxColumn:ReadOnly = true.
    this-object:firmNameDataGridViewTextBoxColumn:DataPropertyName = "FirmName".
    this-object:firmNameDataGridViewTextBoxColumn:HeaderText = "Название Фирмы".
    this-object:firmNameDataGridViewTextBoxColumn:Name = "firmNameDataGridViewTextBoxColumn".
    this-object:firmNameDataGridViewTextBoxColumn:ReadOnly = true.
    this-object:enddateDataGridViewTextBoxColumn:DataPropertyName = "end-date".
    this-object:enddateDataGridViewTextBoxColumn:HeaderText = "Дата завершения акции".
    this-object:enddateDataGridViewTextBoxColumn:Name = "enddateDataGridViewTextBoxColumn".
    this-object:bindPromoObject:AutoUpdate = true.
    this-object:bindPromoObject:MaxDataGuess = 0.
    this-object:bindPromoObject:NoLOBs = false.
    this-object:bindPromoObject:Position = 0.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar1 as "Progress.Data.TableDesc[]" no-undo.
    arrayvar1 = new "Progress.Data.TableDesc[]"(0).
    tableDesc1:ChildTables = arrayvar1.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar2 as Progress.Data.ColumnPropDesc extent 7 no-undo.
    arrayvar2[1] = new Progress.Data.ColumnPropDesc("objName", "", Progress.Data.DataType:CHARACTER).
    arrayvar2[2] = new Progress.Data.ColumnPropDesc("FirmCode", "", Progress.Data.DataType:INTEGER).
    arrayvar2[3] = new Progress.Data.ColumnPropDesc("FirmName", "", Progress.Data.DataType:CHARACTER).
    arrayvar2[4] = new Progress.Data.ColumnPropDesc("objDbNum", "", Progress.Data.DataType:INTEGER).
    arrayvar2[5] = new Progress.Data.ColumnPropDesc("end-date", "Дата завершения акции", Progress.Data.DataType:DATE).
    arrayvar2[6] = new Progress.Data.ColumnPropDesc("obj-code", "Объект", Progress.Data.DataType:INTEGER).
    arrayvar2[7] = new Progress.Data.ColumnPropDesc("obj-type", "Тип объекта", Progress.Data.DataType:CHARACTER).
    tableDesc1:Columns = arrayvar2.
    this-object:bindPromoObject:TableSchema = tableDesc1.
    this-object:AutoScaleDimensions = new System.Drawing.SizeF(Progress.Util.CastUtil:ToSingle(6), Progress.Util.CastUtil:ToSingle(13)).
    this-object:Controls:Add(this-object:tableLayoutPanel1).
    this-object:Margin = new System.Windows.Forms.Padding(0).
    this-object:Name = "uc_TabAZS".
    this-object:Size = new System.Drawing.Size(503, 297).
    this-object:tableLayoutPanel1:ResumeLayout(false).
    this-object:tableLayoutPanel2:ResumeLayout(false).
    cast(this-object:dataGridView1, System.ComponentModel.ISupportInitialize):EndInit().
    cast(this-object:bindPromoObject, System.ComponentModel.ISupportInitialize):EndInit().
    this-object:ResumeLayout(false).
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.
    END METHOD.
    DESTRUCTOR PUBLIC uc_TabAZS ( ):
        if  dataGridView1:SelectedCells:Count >0
        then
            dataGridView1:SelectedCells[0]:Selected = true.
        if valid-handle(bindPromoObject:handle)
        then
           bindPromoObject:Assign().
        bindPromoObject:dispose().
    END DESTRUCTOR.
END CLASS.
