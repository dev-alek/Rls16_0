USING Progress.Lang.*.
USING Progress.Windows.UserControl.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS ibs.th.ref.promo.uc_Mess INHERITS UserControl:
    define private variable textBox2 as System.Windows.Forms.TextBox no-undo.
    define private variable tableLayoutPanel3 as System.Windows.Forms.TableLayoutPanel no-undo.
    define private variable label2 as System.Windows.Forms.Label no-undo.
    define variable vss-revision       as character no-undo init "$Revision$":U .
    define variable vss-author         as character no-undo init "$Author$":U .
    define variable vss-date           as character no-undo init "$Date$":U .
    define variable vss-workfile       as character no-undo init "$Workfile$":U .
    define variable vss-archive        as character no-undo init "$Archive$":U .
    define variable vss-description    as character no-undo init "Просмотр/редактирование одной акции".
    define private variable bindPromoCrit as Progress.Data.BindingSource no-undo.
    define private variable bindPromoMess as Progress.Data.BindingSource no-undo.
    define private variable bindPromoMess1 as Progress.Data.BindingSource no-undo.
    DEFINE PRIVATE VARIABLE components AS System.ComponentModel.IContainer NO-UNDO.
    DEFINE PRIVATE VARIABLE tableLayoutPanel2 AS System.Windows.Forms.TableLayoutPanel NO-UNDO.
    DEFINE PRIVATE VARIABLE textBox1 AS System.Windows.Forms.TextBox NO-UNDO.
    DEFINE PRIVATE VARIABLE tableLayoutPanel1 AS System.Windows.Forms.TableLayoutPanel NO-UNDO.
    DEFINE PRIVATE VARIABLE label1 AS System.Windows.Forms.Label NO-UNDO.
    define private variable m-promo-trg as class ibs.th.ref.promo.promo_trg no-undo.
method Public VOID SetPromoTrg(input v-promo-trg as class ibs.th.ref.promo.promo_trg  ):
    m-promo-trg = v-promo-trg.
end.
method Public VOID PublicEvent (input iEvent as character, input iEventParam as character   ):
end.
    method Public VOID SetBind( ):
        bindPromoMess:Handle = m-promo-trg:getQuery("promoMes").
        bindPromoMess1:Handle = m-promo-trg:getQuery("promoMes1").
      end.
    CONSTRUCTOR PUBLIC uc_Mess (  ):
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
        define variable tableDesc13 as Progress.Data.TableDesc no-undo.
        define variable tableDesc15 as Progress.Data.TableDesc no-undo.
        tableDesc13 = new Progress.Data.TableDesc("tt-PromoGift").
        tableDesc15 = new Progress.Data.TableDesc("tt-PromoGift").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable tableDesc14 as Progress.Data.TableDesc no-undo.
        tableDesc14 = new Progress.Data.TableDesc("tt-PromoCriterion").
        this-object:tableLayoutPanel1 = new System.Windows.Forms.TableLayoutPanel().
        this-object:tableLayoutPanel2 = new System.Windows.Forms.TableLayoutPanel().
        this-object:label1 = new System.Windows.Forms.Label().
        this-object:textBox1 = new System.Windows.Forms.TextBox().
        this-object:bindPromoMess = new Progress.Data.BindingSource(this-object:components).
        this-object:bindPromoMess1 = new Progress.Data.BindingSource(this-object:components).
        this-object:bindPromoCrit = new Progress.Data.BindingSource(this-object:components).
        this-object:textBox2 = new System.Windows.Forms.TextBox().
        this-object:tableLayoutPanel3 = new System.Windows.Forms.TableLayoutPanel().
        this-object:label2 = new System.Windows.Forms.Label().
        this-object:tableLayoutPanel1:SuspendLayout().
        this-object:tableLayoutPanel2:SuspendLayout().
        cast(this-object:bindPromoMess, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:bindPromoMess1, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:bindPromoCrit, System.ComponentModel.ISupportInitialize):BeginInit().
        this-object:tableLayoutPanel3:SuspendLayout().
        this-object:SuspendLayout().
        this-object:tableLayoutPanel1:ColumnCount = 1.
        this-object:tableLayoutPanel1:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
        this-object:tableLayoutPanel1:Controls:Add(this-object:tableLayoutPanel3, 0, 3).
        this-object:tableLayoutPanel1:Controls:Add(this-object:textBox2, 0, 3).
        this-object:tableLayoutPanel1:Controls:Add(this-object:tableLayoutPanel2, 0, 0).
        this-object:tableLayoutPanel1:Controls:Add(this-object:textBox1, 0, 1).
        this-object:tableLayoutPanel1:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:tableLayoutPanel1:Location = new System.Drawing.Point(0, 0).
        this-object:tableLayoutPanel1:Margin = new System.Windows.Forms.Padding(4, 4, 4, 4).
        this-object:tableLayoutPanel1:Name = "tableLayoutPanel1".
        this-object:tableLayoutPanel1:RowCount = 4.
        this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(43))).
        this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
        this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(8))).
        this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(36))).
        this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(220))).
        this-object:tableLayoutPanel1:Size = new System.Drawing.Size(741, 366).
        this-object:tableLayoutPanel1:TabIndex = 4.
        this-object:tableLayoutPanel2:ColumnCount = 2.
        this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(357))).
        this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(50))).
        this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(200))).
        this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(50))).
        this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(27))).
        this-object:tableLayoutPanel2:Controls:Add(this-object:label1, 0, 0).
        this-object:tableLayoutPanel2:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:tableLayoutPanel2:Location = new System.Drawing.Point(4, 4).
        this-object:tableLayoutPanel2:Margin = new System.Windows.Forms.Padding(4, 4, 4, 4).
        this-object:tableLayoutPanel2:Name = "tableLayoutPanel2".
        this-object:tableLayoutPanel2:RowCount = 1.
        this-object:tableLayoutPanel2:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
        this-object:tableLayoutPanel2:Size = new System.Drawing.Size(733, 35).
        this-object:tableLayoutPanel2:TabIndex = 5.
        this-object:label1:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:label1:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(12), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
        this-object:label1:Location = new System.Drawing.Point(4, 0).
        this-object:label1:Margin = new System.Windows.Forms.Padding(4, 0, 4, 0).
        this-object:label1:Name = "label1".
        this-object:label1:Size = new System.Drawing.Size(349, 35).
        this-object:label1:TabIndex = 6.
        this-object:label1:Text = "Сообщение для кассира".
        this-object:label1:UseCompatibleTextRendering = true.
        this-object:textBox1:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindPromoMess, "mess", true)).
        this-object:textBox1:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:textBox1:Location = new System.Drawing.Point(4, 47).
        this-object:textBox1:Margin = new System.Windows.Forms.Padding(4, 4, 4, 4).
        this-object:textBox1:Multiline = true.
        this-object:textBox1:Name = "textBox1".
        this-object:textBox1:Size = new System.Drawing.Size(733, 51).
        this-object:textBox1:TabIndex = 7.
        this-object:bindPromoMess:MaxDataGuess = 0.
        this-object:bindPromoMess:NoLOBs = false.
        this-object:bindPromoMess:Position = 0.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar0 as "Progress.Data.TableDesc[]" no-undo.
        arrayvar0 = new "Progress.Data.TableDesc[]"(0).
        tableDesc13:ChildTables = arrayvar0.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar1 as Progress.Data.ColumnPropDesc extent 1 no-undo.
        arrayvar1[1] = new Progress.Data.ColumnPropDesc("mess", "сообщение для кассира", Progress.Data.DataType:CHARACTER).
        tableDesc13:Columns = arrayvar1.
        this-object:bindPromoMess:TableSchema = tableDesc13.
        this-object:bindPromoMess1:MaxDataGuess = 0.
        this-object:bindPromoMess1:NoLOBs = false.
        this-object:bindPromoMess1:Position = 0.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar4 as "Progress.Data.TableDesc[]" no-undo.
        arrayvar4 = new "Progress.Data.TableDesc[]"(0).
        tableDesc15:ChildTables = arrayvar0.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar5 as Progress.Data.ColumnPropDesc extent 1 no-undo.
        arrayvar5[1] = new Progress.Data.ColumnPropDesc("mess-gks", "сообщение для ГКС", Progress.Data.DataType:CHARACTER).
        tableDesc15:Columns = arrayvar5.
        this-object:bindPromoMess1:TableSchema = tableDesc15.
        this-object:bindPromoCrit:MaxDataGuess = 0.
        this-object:bindPromoCrit:NoLOBs = false.
        this-object:bindPromoCrit:Position = 0.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar2 as "Progress.Data.TableDesc[]" no-undo.
        arrayvar2 = new "Progress.Data.TableDesc[]"(0).
        tableDesc14:ChildTables = arrayvar2.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar3 as Progress.Data.ColumnPropDesc extent 1 no-undo.
        arrayvar3[1] = new Progress.Data.ColumnPropDesc("mincrit", "минимальное значение критерия", Progress.Data.DataType:DECIMAL).
        tableDesc14:Columns = arrayvar3.
        this-object:bindPromoCrit:TableSchema = tableDesc14.
        this-object:textBox2:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindPromoMess1, "mess-gks", true)).
        this-object:textBox2:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:textBox2:Location = new System.Drawing.Point(4, 150).
        this-object:textBox2:Margin = new System.Windows.Forms.Padding(4).
        this-object:textBox2:Multiline = true.
        this-object:textBox2:Name = "textBox2".
        this-object:textBox2:Size = new System.Drawing.Size(733, 212).
        this-object:textBox2:TabIndex = 9.
        this-object:tableLayoutPanel3:ColumnCount = 2.
        this-object:tableLayoutPanel3:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(357))).
        this-object:tableLayoutPanel3:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(50))).
        this-object:tableLayoutPanel3:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(200))).
        this-object:tableLayoutPanel3:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(50))).
        this-object:tableLayoutPanel3:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(27))).
        this-object:tableLayoutPanel3:Controls:Add(this-object:label2, 0, 0).
        this-object:tableLayoutPanel3:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:tableLayoutPanel3:Location = new System.Drawing.Point(4, 114).
        this-object:tableLayoutPanel3:Margin = new System.Windows.Forms.Padding(4).
        this-object:tableLayoutPanel3:Name = "tableLayoutPanel3".
        this-object:tableLayoutPanel3:RowCount = 1.
        this-object:tableLayoutPanel3:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
        this-object:tableLayoutPanel3:Size = new System.Drawing.Size(733, 28).
        this-object:tableLayoutPanel3:TabIndex = 10.
        this-object:label2:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:label2:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(12), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
        this-object:label2:Location = new System.Drawing.Point(4, 0).
        this-object:label2:Margin = new System.Windows.Forms.Padding(4, 0, 4, 0).
        this-object:label2:Name = "label2".
        this-object:label2:Size = new System.Drawing.Size(349, 28).
        this-object:label2:TabIndex = 6.
        this-object:label2:Text = "Сообщение для ГКС".
        this-object:label2:UseCompatibleTextRendering = true.
        this-object:AutoScaleDimensions = new System.Drawing.SizeF(Progress.Util.CastUtil:ToSingle(8), Progress.Util.CastUtil:ToSingle(16)).
        this-object:Controls:Add(this-object:tableLayoutPanel1).
        this-object:Margin = new System.Windows.Forms.Padding(5, 5, 5, 5).
        this-object:Name = "uc_Mess".
        this-object:Size = new System.Drawing.Size(741, 366).
        this-object:tableLayoutPanel1:ResumeLayout(false).
        this-object:tableLayoutPanel1:PerformLayout().
        this-object:tableLayoutPanel2:ResumeLayout(false).
        cast(this-object:bindPromoMess, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:bindPromoMess1, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:bindPromoCrit, System.ComponentModel.ISupportInitialize):EndInit().
        this-object:tableLayoutPanel3:ResumeLayout(false).
        this-object:ResumeLayout(false).
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.
    END METHOD.
    DESTRUCTOR PUBLIC uc_Mess ( ):
        if valid-object(m-promo-trg) then closeBind().
    END DESTRUCTOR.
    method private void closeBind():
       if valid-handle(bindPromoMess:handle)
       then
          bindPromoMess:Assign().
          bindPromoMess:Dispose().
              if valid-handle(bindPromoMess1:handle)
       then
          bindPromoMess1:Assign().
          bindPromoMess1:Dispose().
    end.
END CLASS.
