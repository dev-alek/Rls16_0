using Progress.Lang.*.
using Progress.Windows.UserControl.
block-level on error undo, throw.
class ibs.th.ref.promo.uc_TabTypePay inherits UserControl:
  define private variable checkBox1 as System.Windows.Forms.CheckBox no-undo.
    define variable vss-revision       as character no-undo init "$Revision: 1ee1aa69dd2c, 3342, rls $":U .
    define variable vss-author         as character no-undo init "$Author: EShklyar $":U .
    define variable vss-date           as character no-undo init "$Date: 2023/05/19 13:37:10 $":U .
    define variable vss-workfile       as character no-undo init "$Workfile: uc_TabTypePay.cls $":U .
    define variable vss-archive        as character no-undo init "$Archive: ibs/th/ref/promo/uc_TabTypePay.cls $":U .
    define variable vss-description    as character no-undo init "Просмотр/редактирование одной акции".
    define private variable bindPromoPay as Progress.Data.BindingSource no-undo.
    define private variable bindPromoPay2 as Progress.Data.BindingSource no-undo.
    define private variable button2 as System.Windows.Forms.Button no-undo.
    define private variable button1 as System.Windows.Forms.Button no-undo.
    define private variable cdpaycodeDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable components as System.ComponentModel.IContainer no-undo.
    define private variable currcodeDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable dataGridView1 as System.Windows.Forms.DataGridView no-undo.
    define private variable m-promo-trg as class ibs.th.ref.promo.promo_trg no-undo.
    define private variable paycodeDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable objnameDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable tableLayoutPanel2 as System.Windows.Forms.TableLayoutPanel no-undo.
    define private variable tableLayoutPanel1 as System.Windows.Forms.TableLayoutPanel no-undo.
        @VisualDesigner.
        method private void button1_Click( input sender as System.Object, input e as System.EventArgs ):
                if m-promo-trg:addpay()
                then do:
                   bindPromoPay:handle:query-open().
                   bindPromoPay:RefreshAll().
                end.
                return.
        end method.
        @VisualDesigner.
        method private void button2_Click( input sender as System.Object, input e as System.EventArgs ):
                m-promo-trg:delgds("PromoPay").
    bindPromoPay:handle:query-open().
    bindPromoPay:RefreshAll().
    return.
        end method.
        @VisualDesigner.
        method private void checkBox1_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
                return.
        end method.
    method public void SetPromoTrg(input v-promo-trg as class ibs.th.ref.promo.promo_trg  ):
        m-promo-trg = v-promo-trg.
        SetBind().
    end.
    method public void SetBind( ):
         checkBox1:checked = m-promo-trg:getChangeBL().
         bindPromoPay:handle      = m-promo-trg:getQuery("PromoPay").
    end.
    constructor public uc_TabTypePay (  ):
        super().
        InitializeComponent().
        this-object:ComponentsCollection:ADD(this-object:components).
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.
    end constructor.
    method private void InitializeComponent(  ):
        THIS-OBJECT:components = NEW System.ComponentModel.Container().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        DEFINE VARIABLE dataGridViewCellStyle3 AS System.Windows.Forms.DataGridViewCellStyle NO-UNDO.
        dataGridViewCellStyle3 = NEW System.Windows.Forms.DataGridViewCellStyle().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        DEFINE VARIABLE dataGridViewCellStyle4 AS System.Windows.Forms.DataGridViewCellStyle NO-UNDO.
        dataGridViewCellStyle4 = NEW System.Windows.Forms.DataGridViewCellStyle().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        DEFINE VARIABLE tableDesc2 AS Progress.Data.TableDesc NO-UNDO.
        tableDesc2 = NEW Progress.Data.TableDesc("tt-CashPay").
        THIS-OBJECT:tableLayoutPanel1 = NEW System.Windows.Forms.TableLayoutPanel().
        THIS-OBJECT:tableLayoutPanel2 = NEW System.Windows.Forms.TableLayoutPanel().
        THIS-OBJECT:button2 = NEW System.Windows.Forms.Button().
        THIS-OBJECT:button1 = NEW System.Windows.Forms.Button().
        THIS-OBJECT:checkBox1 = NEW System.Windows.Forms.CheckBox().
        THIS-OBJECT:dataGridView1 = NEW System.Windows.Forms.DataGridView().
        THIS-OBJECT:cdpaycodeDataGridViewTextBoxColumn = NEW System.Windows.Forms.DataGridViewTextBoxColumn().
        THIS-OBJECT:objnameDataGridViewTextBoxColumn = NEW System.Windows.Forms.DataGridViewTextBoxColumn().
        THIS-OBJECT:currcodeDataGridViewTextBoxColumn = NEW System.Windows.Forms.DataGridViewTextBoxColumn().
        THIS-OBJECT:paycodeDataGridViewTextBoxColumn = NEW System.Windows.Forms.DataGridViewTextBoxColumn().
        THIS-OBJECT:bindPromoPay = NEW Progress.Data.BindingSource(THIS-OBJECT:components).
        THIS-OBJECT:tableLayoutPanel1:SuspendLayout().
        THIS-OBJECT:tableLayoutPanel2:SuspendLayout().
        CAST(THIS-OBJECT:dataGridView1, System.ComponentModel.ISupportInitialize):BeginInit().
        CAST(THIS-OBJECT:bindPromoPay, System.ComponentModel.ISupportInitialize):BeginInit().
        THIS-OBJECT:SuspendLayout().
        THIS-OBJECT:tableLayoutPanel1:ColumnCount = 1.
        THIS-OBJECT:tableLayoutPanel1:ColumnStyles:Add(NEW System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
        THIS-OBJECT:tableLayoutPanel1:Controls:Add(THIS-OBJECT:tableLayoutPanel2, 0, 1).
        THIS-OBJECT:tableLayoutPanel1:Controls:Add(THIS-OBJECT:dataGridView1, 0, 2).
        THIS-OBJECT:tableLayoutPanel1:Dock = System.Windows.Forms.DockStyle:Fill.
        THIS-OBJECT:tableLayoutPanel1:Location = NEW System.Drawing.Point(0, 0).
        THIS-OBJECT:tableLayoutPanel1:Name = "tableLayoutPanel1".
        THIS-OBJECT:tableLayoutPanel1:RowCount = 3.
        THIS-OBJECT:tableLayoutPanel1:RowStyles:Add(NEW System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(7))).
        THIS-OBJECT:tableLayoutPanel1:RowStyles:Add(NEW System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(25))).
        THIS-OBJECT:tableLayoutPanel1:RowStyles:Add(NEW System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
        THIS-OBJECT:tableLayoutPanel1:Size = NEW System.Drawing.Size(734, 291).
        THIS-OBJECT:tableLayoutPanel1:TabIndex = 5.
        THIS-OBJECT:tableLayoutPanel2:ColumnCount = 4.
        THIS-OBJECT:tableLayoutPanel2:ColumnStyles:Add(NEW System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(80))).
        THIS-OBJECT:tableLayoutPanel2:ColumnStyles:Add(NEW System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(80))).
        THIS-OBJECT:tableLayoutPanel2:ColumnStyles:Add(NEW System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(120))).
        THIS-OBJECT:tableLayoutPanel2:ColumnStyles:Add(NEW System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
        THIS-OBJECT:tableLayoutPanel2:Controls:Add(THIS-OBJECT:button2, 1, 0).
        THIS-OBJECT:tableLayoutPanel2:Controls:Add(THIS-OBJECT:button1, 0, 0).
        THIS-OBJECT:tableLayoutPanel2:Controls:Add(THIS-OBJECT:checkBox1, 3, 0).
        THIS-OBJECT:tableLayoutPanel2:Dock = System.Windows.Forms.DockStyle:Fill.
        THIS-OBJECT:tableLayoutPanel2:Location = NEW System.Drawing.Point(3, 7).
        THIS-OBJECT:tableLayoutPanel2:Margin = NEW System.Windows.Forms.Padding(3, 0, 0, 0).
        THIS-OBJECT:tableLayoutPanel2:Name = "tableLayoutPanel2".
        THIS-OBJECT:tableLayoutPanel2:RowCount = 1.
        THIS-OBJECT:tableLayoutPanel2:RowStyles:Add(NEW System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
        THIS-OBJECT:tableLayoutPanel2:Size = NEW System.Drawing.Size(731, 25).
        THIS-OBJECT:tableLayoutPanel2:TabIndex = 0.
        THIS-OBJECT:button2:Dock = System.Windows.Forms.DockStyle:Fill.
        THIS-OBJECT:button2:Location = NEW System.Drawing.Point(80, 0).
        THIS-OBJECT:button2:Margin = NEW System.Windows.Forms.Padding(0).
        THIS-OBJECT:button2:Name = "button2".
        THIS-OBJECT:button2:Size = NEW System.Drawing.Size(80, 25).
        THIS-OBJECT:button2:TabIndex = 1.
        THIS-OBJECT:button2:Text = "Удалить".
        THIS-OBJECT:button2:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:button2:UseVisualStyleBackColor = TRUE.
        THIS-OBJECT:button2:Click:Subscribe(THIS-OBJECT:button2_Click).
        THIS-OBJECT:button1:Dock = System.Windows.Forms.DockStyle:Fill.
        THIS-OBJECT:button1:Location = NEW System.Drawing.Point(0, 0).
        THIS-OBJECT:button1:Margin = NEW System.Windows.Forms.Padding(0).
        THIS-OBJECT:button1:Name = "button1".
        THIS-OBJECT:button1:Size = NEW System.Drawing.Size(80, 25).
        THIS-OBJECT:button1:TabIndex = 0.
        THIS-OBJECT:button1:Text = "Добавить".
        THIS-OBJECT:button1:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:button1:UseVisualStyleBackColor = TRUE.
        THIS-OBJECT:button1:Click:Subscribe(THIS-OBJECT:button1_Click).
        THIS-OBJECT:checkBox1:Location = NEW System.Drawing.Point(283, 3).
        THIS-OBJECT:checkBox1:Name = "checkBox1".
        THIS-OBJECT:checkBox1:Size = NEW System.Drawing.Size(242, 19).
        THIS-OBJECT:checkBox1:TabIndex = 2.
        THIS-OBJECT:checkBox1:Text = "Запрет начисления баллов лояльности".
        THIS-OBJECT:checkBox1:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:checkBox1:UseVisualStyleBackColor = TRUE.
        THIS-OBJECT:checkBox1:CheckedChanged:Subscribe(THIS-OBJECT:checkBox1_CheckedChanged).
        THIS-OBJECT:dataGridView1:AllowUserToAddRows = FALSE.
        THIS-OBJECT:dataGridView1:AllowUserToDeleteRows = FALSE.
        THIS-OBJECT:dataGridView1:AllowUserToOrderColumns = TRUE.
        THIS-OBJECT:dataGridView1:AutoGenerateColumns = FALSE.
        THIS-OBJECT:dataGridView1:AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode:Fill.
        THIS-OBJECT:dataGridView1:ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode:AutoSize.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        DEFINE VARIABLE arrayvar0 AS System.Windows.Forms.DataGridViewColumn EXTENT 4 NO-UNDO.
        arrayvar0[1] = THIS-OBJECT:cdpaycodeDataGridViewTextBoxColumn.
        arrayvar0[2] = THIS-OBJECT:objnameDataGridViewTextBoxColumn.
        arrayvar0[3] = THIS-OBJECT:currcodeDataGridViewTextBoxColumn.
        arrayvar0[4] = THIS-OBJECT:paycodeDataGridViewTextBoxColumn.
        THIS-OBJECT:dataGridView1:Columns:AddRange(arrayvar0).
        THIS-OBJECT:dataGridView1:DataSource = THIS-OBJECT:bindPromoPay.
        THIS-OBJECT:dataGridView1:Dock = System.Windows.Forms.DockStyle:Fill.
        THIS-OBJECT:dataGridView1:Location = NEW System.Drawing.Point(3, 35).
        THIS-OBJECT:dataGridView1:Name = "dataGridView1".
        THIS-OBJECT:dataGridView1:ReadOnly = TRUE.
        THIS-OBJECT:dataGridView1:Size = NEW System.Drawing.Size(728, 253).
        THIS-OBJECT:dataGridView1:TabIndex = 2.
        THIS-OBJECT:cdpaycodeDataGridViewTextBoxColumn:DataPropertyName = "cdpay-code".
        dataGridViewCellStyle3:Format = "0000".
        THIS-OBJECT:cdpaycodeDataGridViewTextBoxColumn:DefaultCellStyle = dataGridViewCellStyle3.
        THIS-OBJECT:cdpaycodeDataGridViewTextBoxColumn:HeaderText = "Код".
        THIS-OBJECT:cdpaycodeDataGridViewTextBoxColumn:Name = "cdpaycodeDataGridViewTextBoxColumn".
        THIS-OBJECT:cdpaycodeDataGridViewTextBoxColumn:ReadOnly = TRUE.
        THIS-OBJECT:objnameDataGridViewTextBoxColumn:DataPropertyName = "obj-name".
        THIS-OBJECT:objnameDataGridViewTextBoxColumn:HeaderText = "Название".
        THIS-OBJECT:objnameDataGridViewTextBoxColumn:Name = "objnameDataGridViewTextBoxColumn".
        THIS-OBJECT:objnameDataGridViewTextBoxColumn:ReadOnly = TRUE.
        THIS-OBJECT:currcodeDataGridViewTextBoxColumn:DataPropertyName = "curr-code".
        THIS-OBJECT:currcodeDataGridViewTextBoxColumn:HeaderText = "Код валюты".
        THIS-OBJECT:currcodeDataGridViewTextBoxColumn:Name = "currcodeDataGridViewTextBoxColumn".
        THIS-OBJECT:currcodeDataGridViewTextBoxColumn:ReadOnly = TRUE.
        THIS-OBJECT:paycodeDataGridViewTextBoxColumn:DataPropertyName = "pay-code".
        dataGridViewCellStyle4:Format = "00000".
        THIS-OBJECT:paycodeDataGridViewTextBoxColumn:DefaultCellStyle = dataGridViewCellStyle4.
        THIS-OBJECT:paycodeDataGridViewTextBoxColumn:HeaderText = "Оплата".
        THIS-OBJECT:paycodeDataGridViewTextBoxColumn:Name = "paycodeDataGridViewTextBoxColumn".
        THIS-OBJECT:paycodeDataGridViewTextBoxColumn:ReadOnly = TRUE.
        THIS-OBJECT:bindPromoPay:MaxDataGuess = 0.
        THIS-OBJECT:bindPromoPay:NoLOBs = FALSE.
        THIS-OBJECT:bindPromoPay:Position = 0.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        DEFINE VARIABLE arrayvar1 AS "Progress.Data.TableDesc[]" NO-UNDO.
        arrayvar1 = NEW "Progress.Data.TableDesc[]"(0).
        tableDesc2:ChildTables = arrayvar1.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        DEFINE VARIABLE arrayvar2 AS Progress.Data.ColumnPropDesc EXTENT 4 NO-UNDO.
        arrayvar2[1] = NEW Progress.Data.ColumnPropDesc("cdpay-code", "Код", Progress.Data.DataType:INTEGER).
        arrayvar2[2] = NEW Progress.Data.ColumnPropDesc("curr-code", "Код валюты", Progress.Data.DataType:INTEGER).
        arrayvar2[3] = NEW Progress.Data.ColumnPropDesc("obj-name", "Название", Progress.Data.DataType:CHARACTER).
        arrayvar2[4] = NEW Progress.Data.ColumnPropDesc("pay-code", "Оплата", Progress.Data.DataType:INTEGER).
        tableDesc2:Columns = arrayvar2.
        THIS-OBJECT:bindPromoPay:TableSchema = tableDesc2.
        THIS-OBJECT:AutoScaleDimensions = NEW System.Drawing.SizeF(Progress.Util.CastUtil:ToSingle(6), Progress.Util.CastUtil:ToSingle(13)).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:tableLayoutPanel1).
        THIS-OBJECT:Name = "uc_TabTypePay".
        THIS-OBJECT:Size = NEW System.Drawing.Size(734, 291).
        THIS-OBJECT:tableLayoutPanel1:ResumeLayout(FALSE).
        THIS-OBJECT:tableLayoutPanel2:ResumeLayout(FALSE).
        CAST(THIS-OBJECT:dataGridView1, System.ComponentModel.ISupportInitialize):EndInit().
        CAST(THIS-OBJECT:bindPromoPay, System.ComponentModel.ISupportInitialize):EndInit().
        THIS-OBJECT:ResumeLayout(FALSE).
        CATCH e AS Progress.Lang.Error:
            UNDO, THROW e.
        END CATCH.
    end method.
    destructor public uc_TabTypePay ( ):
      if valid-object (bindPromoPay:Handle) then bindPromoPay:Dispose().
           if valid-object(m-promo-trg) then closeBind().
    end destructor.
    method public void AssignBind( ):
      bindPromoPay:Assign().
    end method .
    method public void closeBind():
        if  dataGridView1:SelectedCells:Count > 0
        then
            dataGridView1:SelectedCells[0]:Selected = true.
        if valid-handle(bindPromoPay:handle)
        then
        bindPromoPay:Assign().
        bindPromoPay:Dispose().
    end.
end class.
