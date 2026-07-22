/*

$Revision: adf14615eb79, 3434, rls $
$Author: DRuban $
$Date: 2023/10/16 15:13:32 $
$Workfile: uc_TabBase.cls $
$Archive: ibs/th/ref/promo/uc_TabBase.cls $
  
"Просмотр/редактирование одной акции"

Автор: Рубан Дмитрий Андреевич
Дата создания: 11/07/18
Author: 
Creation date: 11/07/18

*/
USING Progress.Lang.*.
USING Progress.Windows.UserControl.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ibs.th.ref.promo.uc_TabBase INHERITS UserControl: 
  /* --- для cmp/vssrevis.i --- */
    define variable vss-revision       as character no-undo init "$Revision: adf14615eb79, 3434, rls $":U .
    define variable vss-author         as character no-undo init "$Author: DRuban $":U .
    define variable vss-date           as character no-undo init "$Date: 2023/10/16 15:13:32 $":U .
    define variable vss-workfile       as character no-undo init "$Workfile: uc_TabBase.cls $":U .
    define variable vss-archive        as character no-undo init "$Archive: ibs/th/ref/promo/uc_TabBase.cls $":U .
    define variable vss-description    as character no-undo init "Просмотр/редактирование одной акции". 
  /* --- end_of для cmp/vssrevis.i --- */
    
    define private variable bindPromoActionOne as Progress.Data.BindingSource no-undo.
    DEFINE PRIVATE VARIABLE comboBox1 AS System.Windows.Forms.ComboBox NO-UNDO.
    DEFINE PRIVATE VARIABLE button1 AS System.Windows.Forms.Button NO-UNDO.
    DEFINE PRIVATE VARIABLE components AS System.ComponentModel.IContainer NO-UNDO.
    DEFINE PRIVATE VARIABLE textBox7 AS System.Windows.Forms.TextBox NO-UNDO.
    DEFINE PRIVATE VARIABLE textBox6 AS System.Windows.Forms.TextBox NO-UNDO.
    DEFINE PRIVATE VARIABLE textBox2 AS System.Windows.Forms.TextBox NO-UNDO.
    DEFINE PRIVATE VARIABLE textBox1 AS System.Windows.Forms.TextBox NO-UNDO.
    DEFINE PRIVATE VARIABLE tableLayoutPanel6 AS System.Windows.Forms.TableLayoutPanel NO-UNDO.
    DEFINE PRIVATE VARIABLE tableLayoutPanel5 AS System.Windows.Forms.TableLayoutPanel NO-UNDO.
    DEFINE PRIVATE VARIABLE tableLayoutPanel4 AS System.Windows.Forms.TableLayoutPanel NO-UNDO.
    DEFINE PRIVATE VARIABLE tableLayoutPanel3 AS System.Windows.Forms.TableLayoutPanel NO-UNDO.
    DEFINE PRIVATE VARIABLE tableLayoutPanel2 AS System.Windows.Forms.TableLayoutPanel NO-UNDO.
    DEFINE PRIVATE VARIABLE tableLayoutPanel1 AS System.Windows.Forms.TableLayoutPanel NO-UNDO.
    DEFINE PRIVATE VARIABLE label9 AS System.Windows.Forms.Label NO-UNDO.
    DEFINE PRIVATE VARIABLE label8 AS System.Windows.Forms.Label NO-UNDO.
    DEFINE PRIVATE VARIABLE label6 AS System.Windows.Forms.Label NO-UNDO.
    DEFINE PRIVATE VARIABLE label5 AS System.Windows.Forms.Label NO-UNDO.
    DEFINE PRIVATE VARIABLE label4 AS System.Windows.Forms.Label NO-UNDO.
    DEFINE PRIVATE VARIABLE label3 AS System.Windows.Forms.Label NO-UNDO.
    DEFINE PRIVATE VARIABLE label10 AS System.Windows.Forms.Label NO-UNDO.
    DEFINE PRIVATE VARIABLE label1 AS System.Windows.Forms.Label NO-UNDO.
    DEFINE PRIVATE VARIABLE dateTimePicker3 AS System.Windows.Forms.DateTimePicker NO-UNDO.
    DEFINE PRIVATE VARIABLE dateTimePicker2 AS System.Windows.Forms.DateTimePicker NO-UNDO.
    DEFINE PRIVATE VARIABLE dateTimePicker1 AS System.Windows.Forms.DateTimePicker NO-UNDO.
    
    {ibs/th/ref/promo/promoType.def ttStatus}
    {ibs/th/ref/promo/promo_trg_heder.i &NotLocalEvent} 
    
    method Public VOID SetBind( ):
        bindPromoActionOne:handle = m-promo-trg:getQuery("promoActionOne").
        setDisable(m-promo-trg:modeview,m-promo-trg:ModeChangeStatus,m-promo-trg:ModeEarlyTermination).
    end.
    
    method public VOID setDisable(input iModeView as logical,input iModeChangeStatus as logical,input iModeEarlyTermination as logical ):
        assign
            textBox1:enabled = not iModeview 
            textBox2:enabled = not iModeview
            textBox6:enabled = not iModeview 
            textBox7:enabled = not iModeview
            dateTimePicker1:enabled = not iModeview 
            dateTimePicker2:enabled = not iModeview
            dateTimePicker3:enabled = not iModeview
            //comboBox1:enabled = not iModeview
         .
         if iModeChangeStatus 
         then
            comboBox1:enabled = yes.
         if iModeEarlyTermination 
         then
            dateTimePicker3:enabled = yes.   
    end.    
        
    CONSTRUCTOR PUBLIC uc_TabBase (  ):
        SUPER().
        InitializeComponent().
        Init_comboBox1().
        THIS-OBJECT:ComponentsCollection:ADD(THIS-OBJECT:components).
        CATCH e AS Progress.Lang.Error:
            UNDO, THROW e.
        END CATCH.
    END CONSTRUCTOR.
    
    DESTRUCTOR PUBLIC uc_TabBase ( ):
        if valid-handle(bindPromoActionOne:handle)
        then
           bindPromoActionOne:Assign().
        bindPromoActionOne:Dispose().
    END DESTRUCTOR.

    METHOD PRIVATE VOID Init_comboBox1():
        define variable v-promo-type as class ibs.th.ref.promo.promotype no-undo.
        v-promo-type = new ibs.th.ref.promo.promoType().
        v-promo-type:Status_refresh().
        v-promo-type:typeTable("status_",output table ttStatus).
        for each ttStatus:
            comboBox1:Items:Add(ttStatus.item).
        end. 
        delete object v-promo-type.
    end.    
    METHOD PRIVATE VOID InitializeComponent(  ):
        
        /* NOTE: The following method is automatically generated.
        
        We strongly suggest that the contents of this method only be modified using the
        Visual Designer to avoid any incompatible modifications.
        
        Modifying the contents of this method using a code editor will invalidate any support for this file. */
    this-object:components = new System.ComponentModel.Container().
    @VisualDesigner.FormMember (NeedsInitialize="true").
    define variable tableDesc1 as Progress.Data.TableDesc no-undo.
    tableDesc1 = new Progress.Data.TableDesc("tt-promoaction-one").
    this-object:tableLayoutPanel1 = new System.Windows.Forms.TableLayoutPanel().
    this-object:tableLayoutPanel2 = new System.Windows.Forms.TableLayoutPanel().
    this-object:tableLayoutPanel3 = new System.Windows.Forms.TableLayoutPanel().
    this-object:label1 = new System.Windows.Forms.Label().
    this-object:textBox1 = new System.Windows.Forms.TextBox().
    this-object:bindPromoActionOne = new Progress.Data.BindingSource(this-object:components).
    this-object:label3 = new System.Windows.Forms.Label().
    this-object:tableLayoutPanel4 = new System.Windows.Forms.TableLayoutPanel().
    this-object:dateTimePicker2 = new System.Windows.Forms.DateTimePicker().
    this-object:dateTimePicker1 = new System.Windows.Forms.DateTimePicker().
    this-object:label5 = new System.Windows.Forms.Label().
    this-object:button1 = new System.Windows.Forms.Button().
    this-object:label4 = new System.Windows.Forms.Label().
    this-object:textBox2 = new System.Windows.Forms.TextBox().
    this-object:tableLayoutPanel5 = new System.Windows.Forms.TableLayoutPanel().
    this-object:label6 = new System.Windows.Forms.Label().
    this-object:label9 = new System.Windows.Forms.Label().
    this-object:dateTimePicker3 = new System.Windows.Forms.DateTimePicker().
    this-object:comboBox1 = new System.Windows.Forms.ComboBox().
    this-object:tableLayoutPanel6 = new System.Windows.Forms.TableLayoutPanel().
    this-object:label8 = new System.Windows.Forms.Label().
    this-object:label10 = new System.Windows.Forms.Label().
    this-object:textBox6 = new System.Windows.Forms.TextBox().
    this-object:textBox7 = new System.Windows.Forms.TextBox().
    this-object:tableLayoutPanel1:SuspendLayout().
    this-object:tableLayoutPanel2:SuspendLayout().
    this-object:tableLayoutPanel3:SuspendLayout().
    cast(this-object:bindPromoActionOne, System.ComponentModel.ISupportInitialize):BeginInit().
    this-object:tableLayoutPanel4:SuspendLayout().
    this-object:tableLayoutPanel5:SuspendLayout().
    this-object:tableLayoutPanel6:SuspendLayout().
    this-object:SuspendLayout().
    /*  */
    /* tableLayoutPanel1 */
    /*  */
    this-object:tableLayoutPanel1:ColumnCount = 1.
    this-object:tableLayoutPanel1:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    this-object:tableLayoutPanel1:Controls:Add(this-object:tableLayoutPanel2, 0, 0).
    this-object:tableLayoutPanel1:Controls:Add(this-object:tableLayoutPanel6, 0, 1).
    this-object:tableLayoutPanel1:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:tableLayoutPanel1:Location = new System.Drawing.Point(0, 0).
    this-object:tableLayoutPanel1:MinimumSize = new System.Drawing.Size(500, 0).
    this-object:tableLayoutPanel1:Name = "tableLayoutPanel1".
    this-object:tableLayoutPanel1:RowCount = 2.
    this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(80))).
    this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    this-object:tableLayoutPanel1:Size = new System.Drawing.Size(992, 357).
    this-object:tableLayoutPanel1:TabIndex = 1.
    /*  */
    /* tableLayoutPanel2 */
    /*  */
    this-object:tableLayoutPanel2:ColumnCount = 2.
    this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(50))).
    this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(50))).
    this-object:tableLayoutPanel2:Controls:Add(this-object:tableLayoutPanel3, 0, 0).
    this-object:tableLayoutPanel2:Controls:Add(this-object:tableLayoutPanel5, 1, 0).
    this-object:tableLayoutPanel2:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:tableLayoutPanel2:Location = new System.Drawing.Point(0, 0).
    this-object:tableLayoutPanel2:Margin = new System.Windows.Forms.Padding(0).
    this-object:tableLayoutPanel2:MinimumSize = new System.Drawing.Size(200, 0).
    this-object:tableLayoutPanel2:Name = "tableLayoutPanel2".
    this-object:tableLayoutPanel2:RowCount = 1.
    this-object:tableLayoutPanel2:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(50))).
    this-object:tableLayoutPanel2:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(50))).
    this-object:tableLayoutPanel2:Size = new System.Drawing.Size(992, 80).
    this-object:tableLayoutPanel2:TabIndex = 0.
    /*  */
    /* tableLayoutPanel3 */
    /*  */
    this-object:tableLayoutPanel3:ColumnCount = 2.
    this-object:tableLayoutPanel3:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(110))).
    this-object:tableLayoutPanel3:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    this-object:tableLayoutPanel3:Controls:Add(this-object:label1, 0, 0).
    this-object:tableLayoutPanel3:Controls:Add(this-object:textBox1, 1, 0).
    this-object:tableLayoutPanel3:Controls:Add(this-object:label3, 0, 1).
    this-object:tableLayoutPanel3:Controls:Add(this-object:tableLayoutPanel4, 1, 1).
    this-object:tableLayoutPanel3:Controls:Add(this-object:label4, 0, 2).
    this-object:tableLayoutPanel3:Controls:Add(this-object:textBox2, 1, 2).
    this-object:tableLayoutPanel3:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:tableLayoutPanel3:Location = new System.Drawing.Point(0, 0).
    this-object:tableLayoutPanel3:Margin = new System.Windows.Forms.Padding(0).
    this-object:tableLayoutPanel3:MinimumSize = new System.Drawing.Size(200, 0).
    this-object:tableLayoutPanel3:Name = "tableLayoutPanel3".
    this-object:tableLayoutPanel3:RowCount = 3.
    this-object:tableLayoutPanel3:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(33.3333321))).
    this-object:tableLayoutPanel3:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(33.3333321))).
    this-object:tableLayoutPanel3:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(33.3333321))).
    this-object:tableLayoutPanel3:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(20))).
    this-object:tableLayoutPanel3:Size = new System.Drawing.Size(496, 80).
    this-object:tableLayoutPanel3:TabIndex = 0.
    /*  */
    /* label1 */
    /*  */
    this-object:label1:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:label1:Location = new System.Drawing.Point(3, 0).
    this-object:label1:Name = "label1".
    this-object:label1:Size = new System.Drawing.Size(104, 26).
    this-object:label1:TabIndex = 0.
    this-object:label1:Text = "Наименование".
    this-object:label1:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
    this-object:label1:UseCompatibleTextRendering = true.
    /*  */
    /* textBox1 */
    /*  */
    this-object:textBox1:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindPromoActionOne, "nameAction", true)).
    this-object:textBox1:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:textBox1:Location = new System.Drawing.Point(113, 3).
    this-object:textBox1:Name = "textBox1".
    this-object:textBox1:Size = new System.Drawing.Size(380, 20).
    this-object:textBox1:TabIndex = 4.
    /*  */
    /* bindPromoActionOne */
    /*  */
    this-object:bindPromoActionOne:MaxDataGuess = 0.
    this-object:bindPromoActionOne:NoLOBs = false.
    this-object:bindPromoActionOne:Position = 0.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar0 as "Progress.Data.TableDesc[]" no-undo.
    arrayvar0 = new "Progress.Data.TableDesc[]"(0).
    tableDesc1:ChildTables = arrayvar0.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar1 as Progress.Data.ColumnPropDesc extent 9 no-undo.
    arrayvar1[1] = new Progress.Data.ColumnPropDesc("status_lbl", "", Progress.Data.DataType:CHARACTER).
    arrayvar1[2] = new Progress.Data.ColumnPropDesc("beg-date", "Дата начала", Progress.Data.DataType:DATE).
    arrayvar1[3] = new Progress.Data.ColumnPropDesc("changeDate", "Дата изменения", Progress.Data.DataType:DATE).
    arrayvar1[4] = new Progress.Data.ColumnPropDesc("comment", "Коментарий", Progress.Data.DataType:CHARACTER).
    arrayvar1[5] = new Progress.Data.ColumnPropDesc("description", "Описание", Progress.Data.DataType:CHARACTER).
    arrayvar1[6] = new Progress.Data.ColumnPropDesc("end-date", "Дата конца", Progress.Data.DataType:DATE).
    arrayvar1[7] = new Progress.Data.ColumnPropDesc("nameAction", "Наим. акции", Progress.Data.DataType:CHARACTER).
    arrayvar1[8] = new Progress.Data.ColumnPropDesc("priority", "Приоритет", Progress.Data.DataType:INTEGER).
    arrayvar1[9] = new Progress.Data.ColumnPropDesc("ChangDateFl", "установлена дата досрочного завершения", Progress.Data.DataType:LOGICAL).
    tableDesc1:Columns = arrayvar1.
    this-object:bindPromoActionOne:TableSchema = tableDesc1.
    /*  */
    /* label3 */
    /*  */
    this-object:label3:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:label3:Location = new System.Drawing.Point(3, 26).
    this-object:label3:Name = "label3".
    this-object:label3:Size = new System.Drawing.Size(104, 26).
    this-object:label3:TabIndex = 2.
    this-object:label3:Text = "Период с".
    this-object:label3:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
    this-object:label3:UseCompatibleTextRendering = true.
    /*  */
    /* tableLayoutPanel4 */
    /*  */
    this-object:tableLayoutPanel4:ColumnCount = 4.
    this-object:tableLayoutPanel4:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle()).
    this-object:tableLayoutPanel4:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle()).
    this-object:tableLayoutPanel4:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle()).
    this-object:tableLayoutPanel4:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle()).
    this-object:tableLayoutPanel4:Controls:Add(this-object:dateTimePicker2, 2, 0).
    this-object:tableLayoutPanel4:Controls:Add(this-object:dateTimePicker1, 0, 0).
    this-object:tableLayoutPanel4:Controls:Add(this-object:label5, 1, 0).
    this-object:tableLayoutPanel4:Controls:Add(this-object:button1, 3, 0).
    this-object:tableLayoutPanel4:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:tableLayoutPanel4:Location = new System.Drawing.Point(110, 26).
    this-object:tableLayoutPanel4:Margin = new System.Windows.Forms.Padding(0).
    this-object:tableLayoutPanel4:Name = "tableLayoutPanel4".
    this-object:tableLayoutPanel4:RowCount = 1.
    this-object:tableLayoutPanel4:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    this-object:tableLayoutPanel4:Size = new System.Drawing.Size(386, 26).
    this-object:tableLayoutPanel4:TabIndex = 8.
    /*  */
    /* dateTimePicker2 */
    /*  */
    this-object:dateTimePicker2:DataBindings:Add(new System.Windows.Forms.Binding("Value", this-object:bindPromoActionOne, "end-date", true)).
    this-object:dateTimePicker2:Location = new System.Drawing.Point(176, 3).
    this-object:dateTimePicker2:Name = "dateTimePicker2".
    this-object:dateTimePicker2:Size = new System.Drawing.Size(140, 20).
    this-object:dateTimePicker2:TabIndex = 3.
    /*  */
    /* dateTimePicker1 */
    /*  */
    this-object:dateTimePicker1:DataBindings:Add(new System.Windows.Forms.Binding("Value", this-object:bindPromoActionOne, "beg-date", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged, ?, "D")).
    this-object:dateTimePicker1:Location = new System.Drawing.Point(3, 3).
    this-object:dateTimePicker1:Name = "dateTimePicker1".
    this-object:dateTimePicker1:Size = new System.Drawing.Size(140, 20).
    this-object:dateTimePicker1:TabIndex = 1.
    /*  */
    /* label5 */
    /*  */
    this-object:label5:Location = new System.Drawing.Point(148, 0).
    this-object:label5:Margin = new System.Windows.Forms.Padding(2, 0, 0, 0).
    this-object:label5:Name = "label5".
    this-object:label5:Size = new System.Drawing.Size(25, 23).
    this-object:label5:TabIndex = 2.
    this-object:label5:Text = "по:".
    this-object:label5:TextAlign = System.Drawing.ContentAlignment:MiddleCenter.
    this-object:label5:UseCompatibleTextRendering = true.
    /*  */
    /* button1 */
    /*  */
    this-object:button1:Location = new System.Drawing.Point(322, 3).
    this-object:button1:Name = "button1".
    this-object:button1:Size = new System.Drawing.Size(40, 20).
    this-object:button1:TabIndex = 4.
    this-object:button1:Text = "(..)".
    this-object:button1:UseCompatibleTextRendering = true.
    this-object:button1:UseVisualStyleBackColor = true.
    /*  */
    /* label4 */
    /*  */
    this-object:label4:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:label4:Location = new System.Drawing.Point(3, 52).
    this-object:label4:Name = "label4".
    this-object:label4:Size = new System.Drawing.Size(104, 28).
    this-object:label4:TabIndex = 3.
    this-object:label4:Text = "Приоритет".
    this-object:label4:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
    this-object:label4:UseCompatibleTextRendering = true.
    /*  */
    /* textBox2 */
    /*  */
    this-object:textBox2:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindPromoActionOne, "priority", true)).
    this-object:textBox2:Location = new System.Drawing.Point(113, 55).
    this-object:textBox2:Name = "textBox2".
    this-object:textBox2:Size = new System.Drawing.Size(50, 20).
    this-object:textBox2:TabIndex = 9.
    /*  */
    /* tableLayoutPanel5 */
    /*  */
    this-object:tableLayoutPanel5:ColumnCount = 2.
    this-object:tableLayoutPanel5:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(110))).
    this-object:tableLayoutPanel5:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    this-object:tableLayoutPanel5:Controls:Add(this-object:label6, 0, 0).
    this-object:tableLayoutPanel5:Controls:Add(this-object:label9, 0, 1).
    this-object:tableLayoutPanel5:Controls:Add(this-object:dateTimePicker3, 1, 1).
    this-object:tableLayoutPanel5:Controls:Add(this-object:comboBox1, 1, 0).
    this-object:tableLayoutPanel5:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:tableLayoutPanel5:Location = new System.Drawing.Point(496, 0).
    this-object:tableLayoutPanel5:Margin = new System.Windows.Forms.Padding(0).
    this-object:tableLayoutPanel5:MinimumSize = new System.Drawing.Size(200, 0).
    this-object:tableLayoutPanel5:Name = "tableLayoutPanel5".
    this-object:tableLayoutPanel5:RowCount = 3.
    this-object:tableLayoutPanel5:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(33.3333321))).
    this-object:tableLayoutPanel5:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(33.3333321))).
    this-object:tableLayoutPanel5:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(33.3333321))).
    this-object:tableLayoutPanel5:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(20))).
    this-object:tableLayoutPanel5:Size = new System.Drawing.Size(496, 80).
    this-object:tableLayoutPanel5:TabIndex = 1.
    /*  */
    /* label6 */
    /*  */
    this-object:label6:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:label6:Location = new System.Drawing.Point(3, 0).
    this-object:label6:Name = "label6".
    this-object:label6:Size = new System.Drawing.Size(104, 26).
    this-object:label6:TabIndex = 4.
    this-object:label6:Text = "Статус".
    this-object:label6:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
    this-object:label6:UseCompatibleTextRendering = true.
    /*  */
    /* label9 */
    /*  */
    this-object:label9:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:label9:Location = new System.Drawing.Point(3, 26).
    this-object:label9:Name = "label9".
    this-object:label9:Size = new System.Drawing.Size(104, 26).
    this-object:label9:TabIndex = 7.
    this-object:label9:Text = "Дата досрочного завершения".
    this-object:label9:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
    this-object:label9:UseCompatibleTextRendering = true.
    /*  */
    /* dateTimePicker3 */
    /*  */
    this-object:dateTimePicker3:Checked = false.
    this-object:dateTimePicker3:DataBindings:Add(new System.Windows.Forms.Binding("Checked", this-object:bindPromoActionOne, "ChangDateFl", true)).
    this-object:dateTimePicker3:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindPromoActionOne, "changeDate", true)).
    this-object:dateTimePicker3:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:dateTimePicker3:Location = new System.Drawing.Point(113, 29).
    this-object:dateTimePicker3:Name = "dateTimePicker3".
    this-object:dateTimePicker3:ShowCheckBox = true.
    this-object:dateTimePicker3:Size = new System.Drawing.Size(380, 20).
    this-object:dateTimePicker3:TabIndex = 11.
    this-object:dateTimePicker3:Value = Progress.Util.DateTimeHelper:Create(2018, 8, 15, 0, 0, 0, 0).
    /*  */
    /* comboBox1 */
    /*  */
    this-object:comboBox1:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindPromoActionOne, "status_lbl", true)).
    this-object:comboBox1:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:comboBox1:DropDownStyle = System.Windows.Forms.ComboBoxStyle:DropDownList.
    this-object:comboBox1:Enabled = false.
    this-object:comboBox1:FormattingEnabled = true.
    this-object:comboBox1:ImeMode = System.Windows.Forms.ImeMode:NoControl.
    this-object:comboBox1:Location = new System.Drawing.Point(113, 3).
    this-object:comboBox1:Name = "comboBox1".
    this-object:comboBox1:Size = new System.Drawing.Size(380, 21).
    this-object:comboBox1:TabIndex = 12.
    this-object:comboBox1:TabStop = false.
    /*  */
    /* tableLayoutPanel6 */
    /*  */
    this-object:tableLayoutPanel6:ColumnCount = 2.
    this-object:tableLayoutPanel6:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(110))).
    this-object:tableLayoutPanel6:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    this-object:tableLayoutPanel6:Controls:Add(this-object:label8, 0, 0).
    this-object:tableLayoutPanel6:Controls:Add(this-object:label10, 0, 1).
    this-object:tableLayoutPanel6:Controls:Add(this-object:textBox6, 1, 0).
    this-object:tableLayoutPanel6:Controls:Add(this-object:textBox7, 1, 1).
    this-object:tableLayoutPanel6:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:tableLayoutPanel6:Location = new System.Drawing.Point(0, 80).
    this-object:tableLayoutPanel6:Margin = new System.Windows.Forms.Padding(0).
    this-object:tableLayoutPanel6:Name = "tableLayoutPanel6".
    this-object:tableLayoutPanel6:RowCount = 2.
    this-object:tableLayoutPanel6:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(50))).
    this-object:tableLayoutPanel6:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(50))).
    this-object:tableLayoutPanel6:Size = new System.Drawing.Size(992, 277).
    this-object:tableLayoutPanel6:TabIndex = 1.
    /*  */
    /* label8 */
    /*  */
    this-object:label8:Location = new System.Drawing.Point(3, 0).
    this-object:label8:Name = "label8".
    this-object:label8:Size = new System.Drawing.Size(100, 40).
    this-object:label8:TabIndex = 0.
    this-object:label8:Text = "Описание промо-акции".
    this-object:label8:TextAlign = System.Drawing.ContentAlignment:TopCenter.
    this-object:label8:UseCompatibleTextRendering = true.
    /*  */
    /* label10 */
    /*  */
    this-object:label10:Location = new System.Drawing.Point(3, 138).
    this-object:label10:Name = "label10".
    this-object:label10:Size = new System.Drawing.Size(104, 23).
    this-object:label10:TabIndex = 1.
    this-object:label10:Text = "Комментарии".
    this-object:label10:TextAlign = System.Drawing.ContentAlignment:TopCenter.
    this-object:label10:UseCompatibleTextRendering = true.
    /*  */
    /* textBox6 */
    /*  */
    this-object:textBox6:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindPromoActionOne, "description", true)).
    this-object:textBox6:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:textBox6:Location = new System.Drawing.Point(113, 7).
    this-object:textBox6:Margin = new System.Windows.Forms.Padding(3, 7, 3, 7).
    this-object:textBox6:Multiline = true.
    this-object:textBox6:Name = "textBox6".
    this-object:textBox6:Size = new System.Drawing.Size(876, 124).
    this-object:textBox6:TabIndex = 2.
    /*  */
    /* textBox7 */
    /*  */
    this-object:textBox7:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindPromoActionOne, "comment", true)).
    this-object:textBox7:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:textBox7:Location = new System.Drawing.Point(113, 145).
    this-object:textBox7:Margin = new System.Windows.Forms.Padding(3, 7, 3, 7).
    this-object:textBox7:Multiline = true.
    this-object:textBox7:Name = "textBox7".
    this-object:textBox7:Size = new System.Drawing.Size(876, 125).
    this-object:textBox7:TabIndex = 3.
    /*  */
    /* uc_TabBase */
    /*  */
    this-object:AutoScaleDimensions = new System.Drawing.SizeF(Progress.Util.CastUtil:ToSingle(6), Progress.Util.CastUtil:ToSingle(13)).
    this-object:Controls:Add(this-object:tableLayoutPanel1).
    this-object:Name = "uc_TabBase".
    this-object:Size = new System.Drawing.Size(992, 357).
    this-object:tableLayoutPanel1:ResumeLayout(false).
    this-object:tableLayoutPanel2:ResumeLayout(false).
    this-object:tableLayoutPanel3:ResumeLayout(false).
    this-object:tableLayoutPanel3:PerformLayout().
    cast(this-object:bindPromoActionOne, System.ComponentModel.ISupportInitialize):EndInit().
    this-object:tableLayoutPanel4:ResumeLayout(false).
    this-object:tableLayoutPanel5:ResumeLayout(false).
    this-object:tableLayoutPanel6:ResumeLayout(false).
    this-object:tableLayoutPanel6:PerformLayout().
    this-object:ResumeLayout(false).
    {gbl\ed_date_cls.i this-object:dateTimePicker1 This-object:dateTimePicker2 this-object:dateTimePicker3}
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.
    END METHOD.

END CLASS.