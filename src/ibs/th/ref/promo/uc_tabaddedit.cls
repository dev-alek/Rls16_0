/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$
  
"Промо-акции вкладка Расписание"

Автор: Рубан Дмитрий Андреевич
Дата создания: 16/07/18
Author: 
Creation date: 16/07/18

*/
using Progress.Windows.UserControl.

block-level on error undo, throw.
CLASS ibs.th.ref.promo.uc_TabAddEdit INHERITS UserControl: 
    { cmp/str-glbl.i class }
  define variable vss-revision    as character no-undo initial "$Revision$":U .
  define variable vss-author      as character no-undo initial "$Author$":U .
  define variable vss-date        as character no-undo initial "$Date$":U .
  define variable vss-workfile    as character no-undo initial "$Workfile$":U .
  define variable vss-archive     as character no-undo initial "$Archive$":U . 
  define variable vss-description as character no-undo initial "Промо-акции вкладка Расписание". 
    
  DEFINE PRIVATE VARIABLE bindingSchedWeek3 AS Progress.Data.BindingSource NO-UNDO.
  DEFINE PRIVATE VARIABLE button1 AS System.Windows.Forms.Button NO-UNDO.
  DEFINE PRIVATE VARIABLE tableLayoutPanel1 AS System.Windows.Forms.TableLayoutPanel NO-UNDO.
  DEFINE PRIVATE VARIABLE label2 AS System.Windows.Forms.Label NO-UNDO.
  DEFINE PRIVATE VARIABLE label1 AS System.Windows.Forms.Label NO-UNDO.
  DEFINE PRIVATE VARIABLE flowLayoutPanel2 AS System.Windows.Forms.FlowLayoutPanel NO-UNDO.
  DEFINE PRIVATE VARIABLE dateTimePicker4 AS System.Windows.Forms.DateTimePicker NO-UNDO.
  DEFINE PRIVATE VARIABLE dateTimePicker3 AS System.Windows.Forms.DateTimePicker NO-UNDO.
  DEFINE PRIVATE VARIABLE checkBox9 AS System.Windows.Forms.CheckBox NO-UNDO.
  DEFINE PRIVATE VARIABLE checkBox14 AS System.Windows.Forms.CheckBox NO-UNDO.
  DEFINE PRIVATE VARIABLE checkBox13 AS System.Windows.Forms.CheckBox NO-UNDO.
  DEFINE PRIVATE VARIABLE checkBox12 AS System.Windows.Forms.CheckBox NO-UNDO.
  DEFINE PRIVATE VARIABLE checkBox11 AS System.Windows.Forms.CheckBox NO-UNDO.
  DEFINE PRIVATE VARIABLE checkBox10 AS System.Windows.Forms.CheckBox NO-UNDO.
  DEFINE PRIVATE VARIABLE checkBox1 AS System.Windows.Forms.CheckBox NO-UNDO.
  DEFINE PRIVATE VARIABLE bindPromoActionOne AS Progress.Data.BindingSource NO-UNDO.
  DEFINE PRIVATE VARIABLE bindingSchedWeek AS Progress.Data.BindingSource NO-UNDO.
  DEFINE PRIVATE VARIABLE bindingSchedWeek2 AS Progress.Data.BindingSource NO-UNDO.
  DEFINE PRIVATE VARIABLE dtimeendDataGridViewTextBoxColumn AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.
  DEFINE PRIVATE VARIABLE dtimebegDataGridViewTextBoxColumn AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.
    DEFINE PRIVATE VARIABLE checkBox8 AS System.Windows.Forms.CheckBox NO-UNDO.
    DEFINE PRIVATE VARIABLE checkBox7 AS System.Windows.Forms.CheckBox NO-UNDO.
    DEFINE PRIVATE VARIABLE checkBox6 AS System.Windows.Forms.CheckBox NO-UNDO.
    DEFINE PRIVATE VARIABLE checkBox5 AS System.Windows.Forms.CheckBox NO-UNDO.
    DEFINE PRIVATE VARIABLE checkBox4 AS System.Windows.Forms.CheckBox NO-UNDO.
    DEFINE PRIVATE VARIABLE checkBox3 AS System.Windows.Forms.CheckBox NO-UNDO.
    DEFINE PRIVATE VARIABLE checkBox2 AS System.Windows.Forms.CheckBox NO-UNDO.
    DEFINE PRIVATE VARIABLE button9 AS System.Windows.Forms.Button NO-UNDO.
    DEFINE PRIVATE VARIABLE components AS System.ComponentModel.IContainer NO-UNDO.
    DEFINE PRIVATE VARIABLE textBox2 AS System.Windows.Forms.TextBox NO-UNDO.
    DEFINE PRIVATE VARIABLE textBox1 AS System.Windows.Forms.TextBox NO-UNDO.
    DEFINE PRIVATE VARIABLE tableLayoutPanel9 AS System.Windows.Forms.TableLayoutPanel NO-UNDO.
    DEFINE PRIVATE VARIABLE tableLayoutPanel13 AS System.Windows.Forms.TableLayoutPanel NO-UNDO.
    DEFINE PRIVATE VARIABLE tableLayoutPanel12 AS System.Windows.Forms.TableLayoutPanel NO-UNDO.
    DEFINE PRIVATE VARIABLE tableL_Easily AS System.Windows.Forms.TableLayoutPanel NO-UNDO.
    DEFINE PRIVATE VARIABLE tableL_Detailed AS System.Windows.Forms.TableLayoutPanel NO-UNDO.
    DEFINE PRIVATE VARIABLE radioButton6 AS System.Windows.Forms.RadioButton NO-UNDO.
    DEFINE PRIVATE VARIABLE radioButton5 AS System.Windows.Forms.RadioButton NO-UNDO.
    DEFINE PRIVATE VARIABLE label9 AS System.Windows.Forms.Label NO-UNDO.
    DEFINE PRIVATE VARIABLE label8 AS System.Windows.Forms.Label NO-UNDO.
    DEFINE PRIVATE VARIABLE label13 AS System.Windows.Forms.Label NO-UNDO.
    DEFINE PRIVATE VARIABLE label12 AS System.Windows.Forms.Label NO-UNDO.
    DEFINE PRIVATE VARIABLE label11 AS System.Windows.Forms.Label NO-UNDO.
    DEFINE PRIVATE VARIABLE label10 AS System.Windows.Forms.Label NO-UNDO.
    DEFINE PRIVATE VARIABLE flowLayoutPanel1 AS System.Windows.Forms.FlowLayoutPanel NO-UNDO.
    DEFINE PRIVATE VARIABLE dateTimePicker2 AS System.Windows.Forms.DateTimePicker NO-UNDO.
    DEFINE PRIVATE VARIABLE dateTimePicker1 AS System.Windows.Forms.DateTimePicker NO-UNDO.
    DEFINE PRIVATE VARIABLE dataGridView1 AS System.Windows.Forms.DataGridView NO-UNDO.
  DEFINE PRIVATE VARIABLE wdaynum AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.

    define private variable m-promo-trg as class ibs.th.ref.promo.promo_trg no-undo.

  define private variable g-week-days as character no-undo initial
    "понедельник,вторник,среда,четверг,пятница,суббота,воскресенье" .
  define private variable a-week-days as character extent 7 no-undo initial
    ["понедельник","вторник","среда","четверг","пятница","суббота","воскресенье"] .
    
    
    CONSTRUCTOR PUBLIC uc_TabAddEdit (  ):
        SUPER().
        InitializeComponent().
        THIS-OBJECT:ComponentsCollection:ADD(THIS-OBJECT:components).
        CATCH e AS Progress.Lang.Error:
            UNDO, THROW e.
        END CATCH.
    END CONSTRUCTOR.
    
    DESTRUCTOR PUBLIC uc_TabAddEdit ( ):
      if valid-object(bindingSchedWeek3:Handle)  then bindingSchedWeek3:Dispose().
      if valid-object(bindingSchedWeek2:Handle)  then bindingSchedWeek2:Dispose().
      if valid-object(bindingSchedWeek:Handle)   then bindingSchedWeek:Dispose().
      if valid-object(bindPromoActionOne:Handle) then bindPromoActionOne:Dispose().
    END DESTRUCTOR.


    method Public VOID SetPromoTrg(input v-promo-trg as class ibs.th.ref.promo.promo_trg  ):
        m-promo-trg = v-promo-trg.
        SetBind().
    end method.
    
    method Public VOID SetBind( ):
        bindPromoActionOne:handle  = m-promo-trg:getQuery("promoActionOne3").
        // развести открытие запросов в зависимоси от типа расписания?
        bindingSchedWeek:handle    = m-promo-trg:getQuery("promoSchedWeek").
        bindingSchedWeek2:handle   = m-promo-trg:getQuery("promoSchedWeek2").
        bindingSchedWeek3:handle   = m-promo-trg:getQuery("promoSchedWeek3").
    end method.
        
    method public void AssignBind( ):
      bindingSchedWeek2:Assign().
      bindingSchedWeek:Assign().
      bindPromoActionOne:Assign().
    end method .


    METHOD PRIVATE VOID InitializeComponent(  ):
        
        /* NOTE: The following method is automatically generated.
        
        We strongly suggest that the contents of this method only be modified using the
        Visual Designer to avoid any incompatible modifications.
        
        Modifying the contents of this method using a code editor will invalidate any support for this file. */
    THIS-OBJECT:components = NEW System.ComponentModel.Container().
    @VisualDesigner.FormMember (NeedsInitialize="true").
    DEFINE VARIABLE tableDesc9 AS Progress.Data.TableDesc NO-UNDO.
    tableDesc9 = NEW Progress.Data.TableDesc("tt-promo-schedule-week3").
    @VisualDesigner.FormMember (NeedsInitialize="true").
    DEFINE VARIABLE dataGridViewCellStyle5 AS System.Windows.Forms.DataGridViewCellStyle NO-UNDO.
    dataGridViewCellStyle5 = NEW System.Windows.Forms.DataGridViewCellStyle().
    @VisualDesigner.FormMember (NeedsInitialize="true").
    DEFINE VARIABLE dataGridViewCellStyle6 AS System.Windows.Forms.DataGridViewCellStyle NO-UNDO.
    dataGridViewCellStyle6 = NEW System.Windows.Forms.DataGridViewCellStyle().
    @VisualDesigner.FormMember (NeedsInitialize="true").
    DEFINE VARIABLE tableDesc10 AS Progress.Data.TableDesc NO-UNDO.
    tableDesc10 = NEW Progress.Data.TableDesc("tt-promo-schedule-week2").
    @VisualDesigner.FormMember (NeedsInitialize="true").
    DEFINE VARIABLE tableDesc11 AS Progress.Data.TableDesc NO-UNDO.
    tableDesc11 = NEW Progress.Data.TableDesc("tt-promoaction-one").
    @VisualDesigner.FormMember (NeedsInitialize="true").
    DEFINE VARIABLE tableDesc12 AS Progress.Data.TableDesc NO-UNDO.
    tableDesc12 = NEW Progress.Data.TableDesc("tt-promo-schedule-week").
    THIS-OBJECT:tableLayoutPanel9 = NEW System.Windows.Forms.TableLayoutPanel().
    THIS-OBJECT:tableL_Detailed = NEW System.Windows.Forms.TableLayoutPanel().
    THIS-OBJECT:button1 = NEW System.Windows.Forms.Button().
    THIS-OBJECT:tableLayoutPanel1 = NEW System.Windows.Forms.TableLayoutPanel().
    THIS-OBJECT:flowLayoutPanel2 = NEW System.Windows.Forms.FlowLayoutPanel().
    THIS-OBJECT:checkBox1 = NEW System.Windows.Forms.CheckBox().
    THIS-OBJECT:bindingSchedWeek3 = NEW Progress.Data.BindingSource(THIS-OBJECT:components).
    THIS-OBJECT:checkBox9 = NEW System.Windows.Forms.CheckBox().
    THIS-OBJECT:checkBox10 = NEW System.Windows.Forms.CheckBox().
    THIS-OBJECT:checkBox11 = NEW System.Windows.Forms.CheckBox().
    THIS-OBJECT:checkBox12 = NEW System.Windows.Forms.CheckBox().
    THIS-OBJECT:checkBox13 = NEW System.Windows.Forms.CheckBox().
    THIS-OBJECT:checkBox14 = NEW System.Windows.Forms.CheckBox().
    THIS-OBJECT:label1 = NEW System.Windows.Forms.Label().
    THIS-OBJECT:dateTimePicker3 = NEW System.Windows.Forms.DateTimePicker().
    THIS-OBJECT:label2 = NEW System.Windows.Forms.Label().
    THIS-OBJECT:dateTimePicker4 = NEW System.Windows.Forms.DateTimePicker().
    THIS-OBJECT:dataGridView1 = NEW System.Windows.Forms.DataGridView().
    THIS-OBJECT:wdaynum = NEW System.Windows.Forms.DataGridViewTextBoxColumn().
    THIS-OBJECT:dtimebegDataGridViewTextBoxColumn = NEW System.Windows.Forms.DataGridViewTextBoxColumn().
    THIS-OBJECT:dtimeendDataGridViewTextBoxColumn = NEW System.Windows.Forms.DataGridViewTextBoxColumn().
    THIS-OBJECT:bindingSchedWeek2 = NEW Progress.Data.BindingSource(THIS-OBJECT:components).
    THIS-OBJECT:button9 = NEW System.Windows.Forms.Button().
    THIS-OBJECT:label8 = NEW System.Windows.Forms.Label().
    THIS-OBJECT:label9 = NEW System.Windows.Forms.Label().
    THIS-OBJECT:textBox1 = NEW System.Windows.Forms.TextBox().
    THIS-OBJECT:bindPromoActionOne = NEW Progress.Data.BindingSource(THIS-OBJECT:components).
    THIS-OBJECT:label10 = NEW System.Windows.Forms.Label().
    THIS-OBJECT:tableLayoutPanel12 = NEW System.Windows.Forms.TableLayoutPanel().
    THIS-OBJECT:radioButton5 = NEW System.Windows.Forms.RadioButton().
    THIS-OBJECT:radioButton6 = NEW System.Windows.Forms.RadioButton().
    THIS-OBJECT:tableLayoutPanel13 = NEW System.Windows.Forms.TableLayoutPanel().
    THIS-OBJECT:label11 = NEW System.Windows.Forms.Label().
    THIS-OBJECT:textBox2 = NEW System.Windows.Forms.TextBox().
    THIS-OBJECT:tableL_Easily = NEW System.Windows.Forms.TableLayoutPanel().
    THIS-OBJECT:flowLayoutPanel1 = NEW System.Windows.Forms.FlowLayoutPanel().
    THIS-OBJECT:checkBox2 = NEW System.Windows.Forms.CheckBox().
    THIS-OBJECT:bindingSchedWeek = NEW Progress.Data.BindingSource(THIS-OBJECT:components).
    THIS-OBJECT:checkBox3 = NEW System.Windows.Forms.CheckBox().
    THIS-OBJECT:checkBox4 = NEW System.Windows.Forms.CheckBox().
    THIS-OBJECT:checkBox5 = NEW System.Windows.Forms.CheckBox().
    THIS-OBJECT:checkBox6 = NEW System.Windows.Forms.CheckBox().
    THIS-OBJECT:checkBox7 = NEW System.Windows.Forms.CheckBox().
    THIS-OBJECT:checkBox8 = NEW System.Windows.Forms.CheckBox().
    THIS-OBJECT:label12 = NEW System.Windows.Forms.Label().
    THIS-OBJECT:dateTimePicker1 = NEW System.Windows.Forms.DateTimePicker().
    THIS-OBJECT:label13 = NEW System.Windows.Forms.Label().
    THIS-OBJECT:dateTimePicker2 = NEW System.Windows.Forms.DateTimePicker().
    THIS-OBJECT:tableLayoutPanel9:SuspendLayout().
    THIS-OBJECT:tableL_Detailed:SuspendLayout().
    THIS-OBJECT:tableLayoutPanel1:SuspendLayout().
    THIS-OBJECT:flowLayoutPanel2:SuspendLayout().
    CAST(THIS-OBJECT:bindingSchedWeek3, System.ComponentModel.ISupportInitialize):BeginInit().
    CAST(THIS-OBJECT:dataGridView1, System.ComponentModel.ISupportInitialize):BeginInit().
    CAST(THIS-OBJECT:bindingSchedWeek2, System.ComponentModel.ISupportInitialize):BeginInit().
    CAST(THIS-OBJECT:bindPromoActionOne, System.ComponentModel.ISupportInitialize):BeginInit().
    THIS-OBJECT:tableLayoutPanel12:SuspendLayout().
    THIS-OBJECT:tableLayoutPanel13:SuspendLayout().
    THIS-OBJECT:tableL_Easily:SuspendLayout().
    THIS-OBJECT:flowLayoutPanel1:SuspendLayout().
    CAST(THIS-OBJECT:bindingSchedWeek, System.ComponentModel.ISupportInitialize):BeginInit().
    THIS-OBJECT:SuspendLayout().
    /*  */
    /* tableLayoutPanel9 */
    /*  */
    THIS-OBJECT:tableLayoutPanel9:ColumnCount = 2.
    THIS-OBJECT:tableLayoutPanel9:ColumnStyles:Add(NEW System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(150))).
    THIS-OBJECT:tableLayoutPanel9:ColumnStyles:Add(NEW System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    THIS-OBJECT:tableLayoutPanel9:Controls:Add(THIS-OBJECT:tableL_Detailed, 0, 4).
    THIS-OBJECT:tableLayoutPanel9:Controls:Add(THIS-OBJECT:label8, 0, 0).
    THIS-OBJECT:tableLayoutPanel9:Controls:Add(THIS-OBJECT:label9, 0, 1).
    THIS-OBJECT:tableLayoutPanel9:Controls:Add(THIS-OBJECT:textBox1, 1, 1).
    THIS-OBJECT:tableLayoutPanel9:Controls:Add(THIS-OBJECT:label10, 0, 2).
    THIS-OBJECT:tableLayoutPanel9:Controls:Add(THIS-OBJECT:tableLayoutPanel12, 1, 2).
    THIS-OBJECT:tableLayoutPanel9:Controls:Add(THIS-OBJECT:tableLayoutPanel13, 0, 5).
    THIS-OBJECT:tableLayoutPanel9:Controls:Add(THIS-OBJECT:tableL_Easily, 0, 3).
    THIS-OBJECT:tableLayoutPanel9:Dock = System.Windows.Forms.DockStyle:Fill.
    THIS-OBJECT:tableLayoutPanel9:Location = NEW System.Drawing.Point(0, 0).
    THIS-OBJECT:tableLayoutPanel9:Name = "tableLayoutPanel9".
    THIS-OBJECT:tableLayoutPanel9:RowCount = 6.
    THIS-OBJECT:tableLayoutPanel9:RowStyles:Add(NEW System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(30))).
    THIS-OBJECT:tableLayoutPanel9:RowStyles:Add(NEW System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(30))).
    THIS-OBJECT:tableLayoutPanel9:RowStyles:Add(NEW System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(30))).
    THIS-OBJECT:tableLayoutPanel9:RowStyles:Add(NEW System.Windows.Forms.RowStyle()).
    THIS-OBJECT:tableLayoutPanel9:RowStyles:Add(NEW System.Windows.Forms.RowStyle()).
    THIS-OBJECT:tableLayoutPanel9:RowStyles:Add(NEW System.Windows.Forms.RowStyle()).
    THIS-OBJECT:tableLayoutPanel9:RowStyles:Add(NEW System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(20))).
    THIS-OBJECT:tableLayoutPanel9:Size = NEW System.Drawing.Size(773, 393).
    THIS-OBJECT:tableLayoutPanel9:TabIndex = 5.
    /*  */
    /* tableL_Detailed */
    /*  */
    DEFINE VARIABLE nestedvar0 AS System.Windows.Forms.AnchorStyles NO-UNDO.
    nestedvar0 = CAST(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
    THIS-OBJECT:tableL_Detailed:Anchor = CAST(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
    THIS-OBJECT:tableL_Detailed:BackColor = System.Drawing.SystemColors:Control.
    THIS-OBJECT:tableL_Detailed:ColumnCount = 4.
    THIS-OBJECT:tableLayoutPanel9:SetColumnSpan(THIS-OBJECT:tableL_Detailed, 2).
    THIS-OBJECT:tableL_Detailed:ColumnStyles:Add(NEW System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(150))).
    THIS-OBJECT:tableL_Detailed:ColumnStyles:Add(NEW System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(130))).
    THIS-OBJECT:tableL_Detailed:ColumnStyles:Add(NEW System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(130))).
    THIS-OBJECT:tableL_Detailed:ColumnStyles:Add(NEW System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    THIS-OBJECT:tableL_Detailed:Controls:Add(THIS-OBJECT:button1, 1, 0).
    THIS-OBJECT:tableL_Detailed:Controls:Add(THIS-OBJECT:tableLayoutPanel1, 0, 1).
    THIS-OBJECT:tableL_Detailed:Controls:Add(THIS-OBJECT:dataGridView1, 0, 2).
    THIS-OBJECT:tableL_Detailed:Controls:Add(THIS-OBJECT:button9, 0, 0).
    THIS-OBJECT:tableL_Detailed:Location = NEW System.Drawing.Point(0, 120).
    THIS-OBJECT:tableL_Detailed:Margin = NEW System.Windows.Forms.Padding(0).
    THIS-OBJECT:tableL_Detailed:Name = "tableL_Detailed".
    THIS-OBJECT:tableL_Detailed:RowCount = 3.
    THIS-OBJECT:tableL_Detailed:RowStyles:Add(NEW System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(30))).
    THIS-OBJECT:tableL_Detailed:RowStyles:Add(NEW System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(30))).
    THIS-OBJECT:tableL_Detailed:RowStyles:Add(NEW System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    THIS-OBJECT:tableL_Detailed:RowStyles:Add(NEW System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(20))).
    THIS-OBJECT:tableL_Detailed:Size = NEW System.Drawing.Size(773, 300).
    THIS-OBJECT:tableL_Detailed:TabIndex = 9.
    THIS-OBJECT:tableL_Detailed:Visible = false.
    /*  */
    /* button1 */
    /*  */
    THIS-OBJECT:button1:Dock = System.Windows.Forms.DockStyle:Fill.
    THIS-OBJECT:button1:Location = NEW System.Drawing.Point(153, 3).
    THIS-OBJECT:button1:Name = "button1".
    THIS-OBJECT:button1:Size = NEW System.Drawing.Size(124, 24).
    THIS-OBJECT:button1:TabIndex = 10.
    THIS-OBJECT:button1:Text = "Удалить".
    THIS-OBJECT:button1:UseCompatibleTextRendering = true.
    THIS-OBJECT:button1:UseVisualStyleBackColor = true.
    THIS-OBJECT:button1:Click:Subscribe(THIS-OBJECT:button1_Click).
    /*  */
    /* tableLayoutPanel1 */
    /*  */
    DEFINE VARIABLE nestedvar1 AS System.Windows.Forms.AnchorStyles NO-UNDO.
    nestedvar1 = CAST(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
    THIS-OBJECT:tableLayoutPanel1:Anchor = CAST(Progress.Util.EnumHelper:Or(nestedvar1, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
    THIS-OBJECT:tableLayoutPanel1:BackColor = System.Drawing.SystemColors:Control.
    THIS-OBJECT:tableLayoutPanel1:ColumnCount = 5.
    THIS-OBJECT:tableL_Detailed:SetColumnSpan(THIS-OBJECT:tableLayoutPanel1, 4).
    THIS-OBJECT:tableLayoutPanel1:ColumnStyles:Add(NEW System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(150))).
    THIS-OBJECT:tableLayoutPanel1:ColumnStyles:Add(NEW System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(50))).
    THIS-OBJECT:tableLayoutPanel1:ColumnStyles:Add(NEW System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(30))).
    THIS-OBJECT:tableLayoutPanel1:ColumnStyles:Add(NEW System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(50))).
    THIS-OBJECT:tableLayoutPanel1:ColumnStyles:Add(NEW System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(271))).
    THIS-OBJECT:tableLayoutPanel1:Controls:Add(THIS-OBJECT:flowLayoutPanel2, 4, 0).
    THIS-OBJECT:tableLayoutPanel1:Controls:Add(THIS-OBJECT:label1, 2, 0).
    THIS-OBJECT:tableLayoutPanel1:Controls:Add(THIS-OBJECT:dateTimePicker3, 1, 0).
    THIS-OBJECT:tableLayoutPanel1:Controls:Add(THIS-OBJECT:label2, 0, 0).
    THIS-OBJECT:tableLayoutPanel1:Controls:Add(THIS-OBJECT:dateTimePicker4, 3, 0).
    THIS-OBJECT:tableLayoutPanel1:Location = NEW System.Drawing.Point(0, 30).
    THIS-OBJECT:tableLayoutPanel1:Margin = NEW System.Windows.Forms.Padding(0).
    THIS-OBJECT:tableLayoutPanel1:Name = "tableLayoutPanel1".
    THIS-OBJECT:tableLayoutPanel1:RowCount = 1.
    THIS-OBJECT:tableLayoutPanel1:RowStyles:Add(NEW System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    THIS-OBJECT:tableLayoutPanel1:Size = NEW System.Drawing.Size(773, 30).
    THIS-OBJECT:tableLayoutPanel1:TabIndex = 9.
    THIS-OBJECT:tableLayoutPanel1:Visible = false.
    /*  */
    /* flowLayoutPanel2 */
    /*  */
    THIS-OBJECT:flowLayoutPanel2:Controls:Add(THIS-OBJECT:checkBox1).
    THIS-OBJECT:flowLayoutPanel2:Controls:Add(THIS-OBJECT:checkBox9).
    THIS-OBJECT:flowLayoutPanel2:Controls:Add(THIS-OBJECT:checkBox10).
    THIS-OBJECT:flowLayoutPanel2:Controls:Add(THIS-OBJECT:checkBox11).
    THIS-OBJECT:flowLayoutPanel2:Controls:Add(THIS-OBJECT:checkBox12).
    THIS-OBJECT:flowLayoutPanel2:Controls:Add(THIS-OBJECT:checkBox13).
    THIS-OBJECT:flowLayoutPanel2:Controls:Add(THIS-OBJECT:checkBox14).
    THIS-OBJECT:flowLayoutPanel2:Dock = System.Windows.Forms.DockStyle:Fill.
    THIS-OBJECT:flowLayoutPanel2:Location = NEW System.Drawing.Point(509, 0).
    THIS-OBJECT:flowLayoutPanel2:Margin = NEW System.Windows.Forms.Padding(7, 0, 0, 0).
    THIS-OBJECT:flowLayoutPanel2:MinimumSize = NEW System.Drawing.Size(250, 0).
    THIS-OBJECT:flowLayoutPanel2:Name = "flowLayoutPanel2".
    THIS-OBJECT:flowLayoutPanel2:Size = NEW System.Drawing.Size(264, 30).
    THIS-OBJECT:flowLayoutPanel2:TabIndex = 15.
    /*  */
    /* checkBox1 */
    /*  */
    THIS-OBJECT:checkBox1:AutoSize = true.
    THIS-OBJECT:checkBox1:Checked = true.
    THIS-OBJECT:checkBox1:CheckState = System.Windows.Forms.CheckState:Checked.
    THIS-OBJECT:checkBox1:DataBindings:Add(NEW System.Windows.Forms.Binding("Checked", THIS-OBJECT:bindingSchedWeek3, "isday_mon", true)).
    THIS-OBJECT:checkBox1:Location = NEW System.Drawing.Point(0, 4).
    THIS-OBJECT:checkBox1:Margin = NEW System.Windows.Forms.Padding(0, 4, 0, 0).
    THIS-OBJECT:checkBox1:Name = "checkBox1".
    THIS-OBJECT:checkBox1:Size = NEW System.Drawing.Size(38, 18).
    THIS-OBJECT:checkBox1:TabIndex = 0.
    THIS-OBJECT:checkBox1:Text = "Пн".
    THIS-OBJECT:checkBox1:UseCompatibleTextRendering = true.
    THIS-OBJECT:checkBox1:UseVisualStyleBackColor = true.
    /*  */
    /* bindingSchedWeek3 */
    /*  */
    THIS-OBJECT:bindingSchedWeek3:MaxDataGuess = 0.
    THIS-OBJECT:bindingSchedWeek3:NoLOBs = false.
    THIS-OBJECT:bindingSchedWeek3:Position = 0.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    DEFINE VARIABLE arrayvar0 AS "Progress.Data.TableDesc[]" NO-UNDO.
    arrayvar0 = NEW "Progress.Data.TableDesc[]"(0).
    tableDesc9:ChildTables = arrayvar0.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    DEFINE VARIABLE arrayvar1 AS Progress.Data.ColumnPropDesc EXTENT 9 NO-UNDO.
    arrayvar1[1] = NEW Progress.Data.ColumnPropDesc("dtime-beg", "", Progress.Data.DataType:DATETIME).
    arrayvar1[2] = NEW Progress.Data.ColumnPropDesc("dtime-end", "", Progress.Data.DataType:DATETIME).
    arrayvar1[3] = NEW Progress.Data.ColumnPropDesc("isday_mon", "", Progress.Data.DataType:LOGICAL).
    arrayvar1[4] = NEW Progress.Data.ColumnPropDesc("isday_tue", "", Progress.Data.DataType:LOGICAL).
    arrayvar1[5] = NEW Progress.Data.ColumnPropDesc("isday_wed", "", Progress.Data.DataType:LOGICAL).
    arrayvar1[6] = NEW Progress.Data.ColumnPropDesc("isday_thu", "", Progress.Data.DataType:LOGICAL).
    arrayvar1[7] = NEW Progress.Data.ColumnPropDesc("isday_fri", "", Progress.Data.DataType:LOGICAL).
    arrayvar1[8] = NEW Progress.Data.ColumnPropDesc("isday_sat", "", Progress.Data.DataType:LOGICAL).
    arrayvar1[9] = NEW Progress.Data.ColumnPropDesc("isday_sun", "", Progress.Data.DataType:LOGICAL).
    tableDesc9:Columns = arrayvar1.
    THIS-OBJECT:bindingSchedWeek3:TableSchema = tableDesc9.
    /*  */
    /* checkBox9 */
    /*  */
    THIS-OBJECT:checkBox9:AutoSize = true.
    THIS-OBJECT:checkBox9:Checked = true.
    THIS-OBJECT:checkBox9:CheckState = System.Windows.Forms.CheckState:Checked.
    THIS-OBJECT:checkBox9:DataBindings:Add(NEW System.Windows.Forms.Binding("Checked", THIS-OBJECT:bindingSchedWeek3, "isday_tue", true)).
    THIS-OBJECT:checkBox9:Location = NEW System.Drawing.Point(38, 4).
    THIS-OBJECT:checkBox9:Margin = NEW System.Windows.Forms.Padding(0, 4, 0, 0).
    THIS-OBJECT:checkBox9:Name = "checkBox9".
    THIS-OBJECT:checkBox9:Size = NEW System.Drawing.Size(36, 18).
    THIS-OBJECT:checkBox9:TabIndex = 1.
    THIS-OBJECT:checkBox9:Text = "Вт".
    THIS-OBJECT:checkBox9:UseCompatibleTextRendering = true.
    THIS-OBJECT:checkBox9:UseVisualStyleBackColor = true.
    /*  */
    /* checkBox10 */
    /*  */
    THIS-OBJECT:checkBox10:AutoSize = true.
    THIS-OBJECT:checkBox10:Checked = true.
    THIS-OBJECT:checkBox10:CheckState = System.Windows.Forms.CheckState:Checked.
    THIS-OBJECT:checkBox10:DataBindings:Add(NEW System.Windows.Forms.Binding("Checked", THIS-OBJECT:bindingSchedWeek3, "isday_wed", true)).
    THIS-OBJECT:checkBox10:Location = NEW System.Drawing.Point(74, 4).
    THIS-OBJECT:checkBox10:Margin = NEW System.Windows.Forms.Padding(0, 4, 0, 0).
    THIS-OBJECT:checkBox10:Name = "checkBox10".
    THIS-OBJECT:checkBox10:Size = NEW System.Drawing.Size(38, 18).
    THIS-OBJECT:checkBox10:TabIndex = 2.
    THIS-OBJECT:checkBox10:Text = "Ср".
    THIS-OBJECT:checkBox10:UseCompatibleTextRendering = true.
    THIS-OBJECT:checkBox10:UseVisualStyleBackColor = true.
    /*  */
    /* checkBox11 */
    /*  */
    THIS-OBJECT:checkBox11:AutoSize = true.
    THIS-OBJECT:checkBox11:Checked = true.
    THIS-OBJECT:checkBox11:CheckState = System.Windows.Forms.CheckState:Checked.
    THIS-OBJECT:checkBox11:DataBindings:Add(NEW System.Windows.Forms.Binding("Checked", THIS-OBJECT:bindingSchedWeek3, "isday_thu", true)).
    THIS-OBJECT:checkBox11:Location = NEW System.Drawing.Point(112, 4).
    THIS-OBJECT:checkBox11:Margin = NEW System.Windows.Forms.Padding(0, 4, 0, 0).
    THIS-OBJECT:checkBox11:Name = "checkBox11".
    THIS-OBJECT:checkBox11:Size = NEW System.Drawing.Size(36, 18).
    THIS-OBJECT:checkBox11:TabIndex = 3.
    THIS-OBJECT:checkBox11:Text = "Чт".
    THIS-OBJECT:checkBox11:UseCompatibleTextRendering = true.
    THIS-OBJECT:checkBox11:UseVisualStyleBackColor = true.
    /*  */
    /* checkBox12 */
    /*  */
    THIS-OBJECT:checkBox12:AutoSize = true.
    THIS-OBJECT:checkBox12:Checked = true.
    THIS-OBJECT:checkBox12:CheckState = System.Windows.Forms.CheckState:Checked.
    THIS-OBJECT:checkBox12:DataBindings:Add(NEW System.Windows.Forms.Binding("Checked", THIS-OBJECT:bindingSchedWeek3, "isday_fri", true)).
    THIS-OBJECT:checkBox12:Location = NEW System.Drawing.Point(148, 4).
    THIS-OBJECT:checkBox12:Margin = NEW System.Windows.Forms.Padding(0, 4, 0, 0).
    THIS-OBJECT:checkBox12:Name = "checkBox12".
    THIS-OBJECT:checkBox12:Size = NEW System.Drawing.Size(37, 18).
    THIS-OBJECT:checkBox12:TabIndex = 4.
    THIS-OBJECT:checkBox12:Text = "Пт".
    THIS-OBJECT:checkBox12:UseCompatibleTextRendering = true.
    THIS-OBJECT:checkBox12:UseVisualStyleBackColor = true.
    /*  */
    /* checkBox13 */
    /*  */
    THIS-OBJECT:checkBox13:AutoSize = true.
    THIS-OBJECT:checkBox13:DataBindings:Add(NEW System.Windows.Forms.Binding("Checked", THIS-OBJECT:bindingSchedWeek3, "isday_sat", true)).
    THIS-OBJECT:checkBox13:ForeColor = System.Drawing.Color:Red.
    THIS-OBJECT:checkBox13:Location = NEW System.Drawing.Point(185, 4).
    THIS-OBJECT:checkBox13:Margin = NEW System.Windows.Forms.Padding(0, 4, 0, 0).
    THIS-OBJECT:checkBox13:Name = "checkBox13".
    THIS-OBJECT:checkBox13:Size = NEW System.Drawing.Size(38, 18).
    THIS-OBJECT:checkBox13:TabIndex = 5.
    THIS-OBJECT:checkBox13:Text = "Сб".
    THIS-OBJECT:checkBox13:UseCompatibleTextRendering = true.
    THIS-OBJECT:checkBox13:UseVisualStyleBackColor = true.
    /*  */
    /* checkBox14 */
    /*  */
    THIS-OBJECT:checkBox14:AutoSize = true.
    THIS-OBJECT:checkBox14:DataBindings:Add(NEW System.Windows.Forms.Binding("Checked", THIS-OBJECT:bindingSchedWeek3, "isday_sun", true)).
    THIS-OBJECT:checkBox14:ForeColor = System.Drawing.Color:Red.
    THIS-OBJECT:checkBox14:Location = NEW System.Drawing.Point(223, 4).
    THIS-OBJECT:checkBox14:Margin = NEW System.Windows.Forms.Padding(0, 4, 0, 0).
    THIS-OBJECT:checkBox14:Name = "checkBox14".
    THIS-OBJECT:checkBox14:Size = NEW System.Drawing.Size(36, 18).
    THIS-OBJECT:checkBox14:TabIndex = 6.
    THIS-OBJECT:checkBox14:Text = "Вс".
    THIS-OBJECT:checkBox14:UseCompatibleTextRendering = true.
    THIS-OBJECT:checkBox14:UseVisualStyleBackColor = true.
    /*  */
    /* label1 */
    /*  */
    THIS-OBJECT:label1:Location = NEW System.Drawing.Point(314, 0).
    THIS-OBJECT:label1:Name = "label1".
    THIS-OBJECT:label1:Size = NEW System.Drawing.Size(24, 23).
    THIS-OBJECT:label1:TabIndex = 14.
    THIS-OBJECT:label1:Text = "по:".
    THIS-OBJECT:label1:TextAlign = System.Drawing.ContentAlignment:MiddleCenter.
    THIS-OBJECT:label1:UseCompatibleTextRendering = true.
    /*  */
    /* dateTimePicker3 */
    /*  */
    THIS-OBJECT:dateTimePicker3:CustomFormat = "HH:mm".
    THIS-OBJECT:dateTimePicker3:DataBindings:Add(NEW System.Windows.Forms.Binding("Value", THIS-OBJECT:bindingSchedWeek3, "dtime-beg", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
    THIS-OBJECT:dateTimePicker3:Dock = System.Windows.Forms.DockStyle:Fill.
    THIS-OBJECT:dateTimePicker3:Format = System.Windows.Forms.DateTimePickerFormat:Custom.
    THIS-OBJECT:dateTimePicker3:Location = NEW System.Drawing.Point(153, 4).
    THIS-OBJECT:dateTimePicker3:Margin = NEW System.Windows.Forms.Padding(3, 4, 0, 0).
    THIS-OBJECT:dateTimePicker3:Name = "dateTimePicker3".
    THIS-OBJECT:dateTimePicker3:ShowUpDown = true.
    THIS-OBJECT:dateTimePicker3:Size = NEW System.Drawing.Size(158, 20).
    THIS-OBJECT:dateTimePicker3:TabIndex = 12.
    THIS-OBJECT:dateTimePicker3:ValueChanged:Subscribe(THIS-OBJECT:dateTimePicker3_ValueChanged).
    /*  */
    /* label2 */
    /*  */
    THIS-OBJECT:label2:Dock = System.Windows.Forms.DockStyle:Fill.
    THIS-OBJECT:label2:Location = NEW System.Drawing.Point(3, 0).
    THIS-OBJECT:label2:Name = "label2".
    THIS-OBJECT:label2:Size = NEW System.Drawing.Size(144, 30).
    THIS-OBJECT:label2:TabIndex = 0.
    THIS-OBJECT:label2:Text = "Время с:".
    THIS-OBJECT:label2:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
    THIS-OBJECT:label2:UseCompatibleTextRendering = true.
    /*  */
    /* dateTimePicker4 */
    /*  */
    THIS-OBJECT:dateTimePicker4:CustomFormat = "HH:mm".
    THIS-OBJECT:dateTimePicker4:DataBindings:Add(NEW System.Windows.Forms.Binding("Value", THIS-OBJECT:bindingSchedWeek3, "dtime-end", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
    THIS-OBJECT:dateTimePicker4:Dock = System.Windows.Forms.DockStyle:Fill.
    THIS-OBJECT:dateTimePicker4:Format = System.Windows.Forms.DateTimePickerFormat:Custom.
    THIS-OBJECT:dateTimePicker4:Location = NEW System.Drawing.Point(344, 4).
    THIS-OBJECT:dateTimePicker4:Margin = NEW System.Windows.Forms.Padding(3, 4, 0, 0).
    THIS-OBJECT:dateTimePicker4:Name = "dateTimePicker4".
    THIS-OBJECT:dateTimePicker4:ShowUpDown = true.
    THIS-OBJECT:dateTimePicker4:Size = NEW System.Drawing.Size(158, 20).
    THIS-OBJECT:dateTimePicker4:TabIndex = 13.
    /*  */
    /* dataGridView1 */
    /*  */
    THIS-OBJECT:dataGridView1:AllowUserToAddRows = false.
    THIS-OBJECT:dataGridView1:AllowUserToDeleteRows = false.
    THIS-OBJECT:dataGridView1:AllowUserToResizeRows = false.
    THIS-OBJECT:dataGridView1:AutoGenerateColumns = false.
    THIS-OBJECT:dataGridView1:AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode:Fill.
    THIS-OBJECT:dataGridView1:ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode:AutoSize.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    DEFINE VARIABLE arrayvar2 AS System.Windows.Forms.DataGridViewColumn EXTENT 3 NO-UNDO.
    arrayvar2[1] = THIS-OBJECT:wdaynum.
    arrayvar2[2] = THIS-OBJECT:dtimebegDataGridViewTextBoxColumn.
    arrayvar2[3] = THIS-OBJECT:dtimeendDataGridViewTextBoxColumn.
    THIS-OBJECT:dataGridView1:Columns:AddRange(arrayvar2).
    THIS-OBJECT:tableL_Detailed:SetColumnSpan(THIS-OBJECT:dataGridView1, 4).
    THIS-OBJECT:dataGridView1:DataSource = THIS-OBJECT:bindingSchedWeek2.
    THIS-OBJECT:dataGridView1:Dock = System.Windows.Forms.DockStyle:Fill.
    THIS-OBJECT:dataGridView1:Location = NEW System.Drawing.Point(3, 63).
    THIS-OBJECT:dataGridView1:Name = "dataGridView1".
    THIS-OBJECT:dataGridView1:ReadOnly = true.
    THIS-OBJECT:dataGridView1:RowHeadersVisible = false.
    THIS-OBJECT:dataGridView1:Size = NEW System.Drawing.Size(767, 234).
    THIS-OBJECT:dataGridView1:TabIndex = 0.
    THIS-OBJECT:dataGridView1:CellFormatting:Subscribe(THIS-OBJECT:dataGridView1_CellFormatting).
    /*  */
    /* wdaynum */
    /*  */
    THIS-OBJECT:wdaynum:DataPropertyName = "wdaynum".
    THIS-OBJECT:wdaynum:HeaderText = "день недели".
    THIS-OBJECT:wdaynum:Name = "wdaynum".
    THIS-OBJECT:wdaynum:ReadOnly = true.
    /*  */
    /* dtimebegDataGridViewTextBoxColumn */
    /*  */
    THIS-OBJECT:dtimebegDataGridViewTextBoxColumn:DataPropertyName = "dtime-beg".
    dataGridViewCellStyle5:Format = "t".
    dataGridViewCellStyle5:NullValue = ?.
    THIS-OBJECT:dtimebegDataGridViewTextBoxColumn:DefaultCellStyle = dataGridViewCellStyle5.
    THIS-OBJECT:dtimebegDataGridViewTextBoxColumn:HeaderText = "время с".
    THIS-OBJECT:dtimebegDataGridViewTextBoxColumn:Name = "dtimebegDataGridViewTextBoxColumn".
    THIS-OBJECT:dtimebegDataGridViewTextBoxColumn:ReadOnly = true.
    /*  */
    /* dtimeendDataGridViewTextBoxColumn */
    /*  */
    THIS-OBJECT:dtimeendDataGridViewTextBoxColumn:DataPropertyName = "dtime-end".
    dataGridViewCellStyle6:Format = "t".
    dataGridViewCellStyle6:NullValue = ?.
    THIS-OBJECT:dtimeendDataGridViewTextBoxColumn:DefaultCellStyle = dataGridViewCellStyle6.
    THIS-OBJECT:dtimeendDataGridViewTextBoxColumn:HeaderText = "время по".
    THIS-OBJECT:dtimeendDataGridViewTextBoxColumn:Name = "dtimeendDataGridViewTextBoxColumn".
    THIS-OBJECT:dtimeendDataGridViewTextBoxColumn:ReadOnly = true.
    /*  */
    /* bindingSchedWeek2 */
    /*  */
    THIS-OBJECT:bindingSchedWeek2:AutoSort = true.
    THIS-OBJECT:bindingSchedWeek2:MaxDataGuess = 0.
    THIS-OBJECT:bindingSchedWeek2:NoLOBs = false.
    THIS-OBJECT:bindingSchedWeek2:Position = 0.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    DEFINE VARIABLE arrayvar3 AS "Progress.Data.TableDesc[]" NO-UNDO.
    arrayvar3 = NEW "Progress.Data.TableDesc[]"(0).
    tableDesc10:ChildTables = arrayvar3.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    DEFINE VARIABLE arrayvar4 AS Progress.Data.ColumnPropDesc EXTENT 3 NO-UNDO.
    arrayvar4[1] = NEW Progress.Data.ColumnPropDesc("wdaynum", "день недели", Progress.Data.DataType:INTEGER).
    arrayvar4[2] = NEW Progress.Data.ColumnPropDesc("dtime-beg", "время с", Progress.Data.DataType:DATETIME).
    arrayvar4[3] = NEW Progress.Data.ColumnPropDesc("dtime-end", "время по", Progress.Data.DataType:DATETIME).
    tableDesc10:Columns = arrayvar4.
    THIS-OBJECT:bindingSchedWeek2:TableSchema = tableDesc10.
    /*  */
    /* button9 */
    /*  */
    THIS-OBJECT:button9:Dock = System.Windows.Forms.DockStyle:Fill.
    THIS-OBJECT:button9:Location = NEW System.Drawing.Point(3, 3).
    THIS-OBJECT:button9:Name = "button9".
    THIS-OBJECT:button9:Size = NEW System.Drawing.Size(144, 24).
    THIS-OBJECT:button9:TabIndex = 4.
    THIS-OBJECT:button9:Text = "Добавить".
    THIS-OBJECT:button9:UseCompatibleTextRendering = true.
    THIS-OBJECT:button9:UseVisualStyleBackColor = true.
    THIS-OBJECT:button9:Click:Subscribe(THIS-OBJECT:button9_Click).
    /*  */
    /* label8 */
    /*  */
    THIS-OBJECT:tableLayoutPanel9:SetColumnSpan(THIS-OBJECT:label8, 2).
    THIS-OBJECT:label8:Dock = System.Windows.Forms.DockStyle:Fill.
    THIS-OBJECT:label8:Font = NEW System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.75), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    THIS-OBJECT:label8:Location = NEW System.Drawing.Point(7, 7).
    THIS-OBJECT:label8:Margin = NEW System.Windows.Forms.Padding(7).
    THIS-OBJECT:label8:Name = "label8".
    THIS-OBJECT:label8:Size = NEW System.Drawing.Size(759, 16).
    THIS-OBJECT:label8:TabIndex = 1.
    THIS-OBJECT:label8:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
    THIS-OBJECT:label8:UseCompatibleTextRendering = true.
    /*  */
    /* label9 */
    /*  */
    THIS-OBJECT:label9:Dock = System.Windows.Forms.DockStyle:Fill.
    THIS-OBJECT:label9:Location = NEW System.Drawing.Point(3, 33).
    THIS-OBJECT:label9:Margin = NEW System.Windows.Forms.Padding(3).
    THIS-OBJECT:label9:Name = "label9".
    THIS-OBJECT:label9:Size = NEW System.Drawing.Size(144, 24).
    THIS-OBJECT:label9:TabIndex = 3.
    THIS-OBJECT:label9:Text = "Наименование:".
    THIS-OBJECT:label9:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
    THIS-OBJECT:label9:UseCompatibleTextRendering = true.
    /*  */
    /* textBox1 */
    /*  */
    THIS-OBJECT:textBox1:DataBindings:Add(NEW System.Windows.Forms.Binding("Text", THIS-OBJECT:bindPromoActionOne, "scheduleName", true)).
    THIS-OBJECT:textBox1:Dock = System.Windows.Forms.DockStyle:Fill.
    THIS-OBJECT:textBox1:Location = NEW System.Drawing.Point(150, 30).
    THIS-OBJECT:textBox1:Margin = NEW System.Windows.Forms.Padding(0).
    THIS-OBJECT:textBox1:Multiline = true.
    THIS-OBJECT:textBox1:Name = "textBox1".
    THIS-OBJECT:textBox1:Size = NEW System.Drawing.Size(623, 30).
    THIS-OBJECT:textBox1:TabIndex = 4.
    THIS-OBJECT:textBox1:TextChanged:Subscribe(THIS-OBJECT:textBox1_TextChanged).
    /*  */
    /* bindPromoActionOne */
    /*  */
    THIS-OBJECT:bindPromoActionOne:MaxDataGuess = 0.
    THIS-OBJECT:bindPromoActionOne:NoLOBs = false.
    THIS-OBJECT:bindPromoActionOne:Position = 0.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    DEFINE VARIABLE arrayvar5 AS "Progress.Data.TableDesc[]" NO-UNDO.
    arrayvar5 = NEW "Progress.Data.TableDesc[]"(0).
    tableDesc11:ChildTables = arrayvar5.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    DEFINE VARIABLE arrayvar6 AS Progress.Data.ColumnPropDesc EXTENT 2 NO-UNDO.
    arrayvar6[1] = NEW Progress.Data.ColumnPropDesc("scheduleName", "", Progress.Data.DataType:CHARACTER).
    arrayvar6[2] = NEW Progress.Data.ColumnPropDesc("scheduleType", "", Progress.Data.DataType:LOGICAL).
    tableDesc11:Columns = arrayvar6.
    THIS-OBJECT:bindPromoActionOne:TableSchema = tableDesc11.
    /*  */
    /* label10 */
    /*  */
    THIS-OBJECT:label10:Dock = System.Windows.Forms.DockStyle:Fill.
    THIS-OBJECT:label10:Location = NEW System.Drawing.Point(3, 63).
    THIS-OBJECT:label10:Margin = NEW System.Windows.Forms.Padding(3).
    THIS-OBJECT:label10:Name = "label10".
    THIS-OBJECT:label10:Size = NEW System.Drawing.Size(144, 24).
    THIS-OBJECT:label10:TabIndex = 5.
    THIS-OBJECT:label10:Text = "Вариант расписания:".
    THIS-OBJECT:label10:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
    THIS-OBJECT:label10:UseCompatibleTextRendering = true.
    /*  */
    /* tableLayoutPanel12 */
    /*  */
    THIS-OBJECT:tableLayoutPanel12:BackColor = System.Drawing.SystemColors:Control.
    THIS-OBJECT:tableLayoutPanel12:ColumnCount = 3.
    THIS-OBJECT:tableLayoutPanel12:ColumnStyles:Add(NEW System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(130))).
    THIS-OBJECT:tableLayoutPanel12:ColumnStyles:Add(NEW System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(130))).
    THIS-OBJECT:tableLayoutPanel12:ColumnStyles:Add(NEW System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    THIS-OBJECT:tableLayoutPanel12:Controls:Add(THIS-OBJECT:radioButton5, 0, 0).
    THIS-OBJECT:tableLayoutPanel12:Controls:Add(THIS-OBJECT:radioButton6, 0, 0).
    THIS-OBJECT:tableLayoutPanel12:Dock = System.Windows.Forms.DockStyle:Fill.
    THIS-OBJECT:tableLayoutPanel12:Location = NEW System.Drawing.Point(150, 60).
    THIS-OBJECT:tableLayoutPanel12:Margin = NEW System.Windows.Forms.Padding(0).
    THIS-OBJECT:tableLayoutPanel12:Name = "tableLayoutPanel12".
    THIS-OBJECT:tableLayoutPanel12:RowCount = 1.
    THIS-OBJECT:tableLayoutPanel12:RowStyles:Add(NEW System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    THIS-OBJECT:tableLayoutPanel12:Size = NEW System.Drawing.Size(623, 30).
    THIS-OBJECT:tableLayoutPanel12:TabIndex = 6.
    /*  */
    /* radioButton5 */
    /*  */
    THIS-OBJECT:radioButton5:Appearance = System.Windows.Forms.Appearance:Button.
    THIS-OBJECT:radioButton5:DataBindings:Add(NEW System.Windows.Forms.Binding("Checked", THIS-OBJECT:bindPromoActionOne, "scheduleType", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
    THIS-OBJECT:radioButton5:Dock = System.Windows.Forms.DockStyle:Fill.
    THIS-OBJECT:radioButton5:Location = NEW System.Drawing.Point(133, 3).
    THIS-OBJECT:radioButton5:Name = "radioButton5".
    THIS-OBJECT:radioButton5:Size = NEW System.Drawing.Size(124, 24).
    THIS-OBJECT:radioButton5:TabIndex = 9.
    THIS-OBJECT:radioButton5:Text = "Детальное".
    THIS-OBJECT:radioButton5:TextAlign = System.Drawing.ContentAlignment:MiddleCenter.
    THIS-OBJECT:radioButton5:UseCompatibleTextRendering = true.
    THIS-OBJECT:radioButton5:UseVisualStyleBackColor = true.
    /*  */
    /* radioButton6 */
    /*  */
    THIS-OBJECT:radioButton6:Appearance = System.Windows.Forms.Appearance:Button.
    THIS-OBJECT:radioButton6:Checked = true.
    THIS-OBJECT:radioButton6:Dock = System.Windows.Forms.DockStyle:Fill.
    THIS-OBJECT:radioButton6:ForeColor = System.Drawing.Color:Green.
    THIS-OBJECT:radioButton6:Location = NEW System.Drawing.Point(3, 3).
    THIS-OBJECT:radioButton6:Name = "radioButton6".
    THIS-OBJECT:radioButton6:Size = NEW System.Drawing.Size(124, 24).
    THIS-OBJECT:radioButton6:TabIndex = 8.
    THIS-OBJECT:radioButton6:TabStop = true.
    THIS-OBJECT:radioButton6:Text = "Простое".
    THIS-OBJECT:radioButton6:TextAlign = System.Drawing.ContentAlignment:MiddleCenter.
    THIS-OBJECT:radioButton6:UseCompatibleTextRendering = true.
    THIS-OBJECT:radioButton6:UseVisualStyleBackColor = true.
    THIS-OBJECT:radioButton6:CheckedChanged:Subscribe(THIS-OBJECT:radioButton6_CheckedChanged).
    /*  */
    /* tableLayoutPanel13 */
    /*  */
    THIS-OBJECT:tableLayoutPanel13:BackColor = System.Drawing.SystemColors:Control.
    THIS-OBJECT:tableLayoutPanel13:ColumnCount = 2.
    THIS-OBJECT:tableLayoutPanel9:SetColumnSpan(THIS-OBJECT:tableLayoutPanel13, 2).
    THIS-OBJECT:tableLayoutPanel13:ColumnStyles:Add(NEW System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(150))).
    THIS-OBJECT:tableLayoutPanel13:ColumnStyles:Add(NEW System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    THIS-OBJECT:tableLayoutPanel13:ColumnStyles:Add(NEW System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(70))).
    THIS-OBJECT:tableLayoutPanel13:Controls:Add(THIS-OBJECT:label11, 0, 0).
    THIS-OBJECT:tableLayoutPanel13:Controls:Add(THIS-OBJECT:textBox2, 1, 0).
    THIS-OBJECT:tableLayoutPanel13:Dock = System.Windows.Forms.DockStyle:Fill.
    THIS-OBJECT:tableLayoutPanel13:Location = NEW System.Drawing.Point(0, 420).
    THIS-OBJECT:tableLayoutPanel13:Margin = NEW System.Windows.Forms.Padding(0).
    THIS-OBJECT:tableLayoutPanel13:Name = "tableLayoutPanel13".
    THIS-OBJECT:tableLayoutPanel13:RowCount = 1.
    THIS-OBJECT:tableLayoutPanel13:RowStyles:Add(NEW System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    THIS-OBJECT:tableLayoutPanel13:Size = NEW System.Drawing.Size(773, 50).
    THIS-OBJECT:tableLayoutPanel13:TabIndex = 7.
    /*  */
    /* label11 */
    /*  */
    THIS-OBJECT:label11:Dock = System.Windows.Forms.DockStyle:Fill.
    THIS-OBJECT:label11:Location = NEW System.Drawing.Point(3, 3).
    THIS-OBJECT:label11:Margin = NEW System.Windows.Forms.Padding(3).
    THIS-OBJECT:label11:Name = "label11".
    THIS-OBJECT:label11:Size = NEW System.Drawing.Size(144, 44).
    THIS-OBJECT:label11:TabIndex = 0.
    THIS-OBJECT:label11:Text = "Комментарий:".
    THIS-OBJECT:label11:UseCompatibleTextRendering = true.
    /*  */
    /* textBox2 */
    /*  */
    THIS-OBJECT:textBox2:Dock = System.Windows.Forms.DockStyle:Fill.
    THIS-OBJECT:textBox2:Location = NEW System.Drawing.Point(150, 0).
    THIS-OBJECT:textBox2:Margin = NEW System.Windows.Forms.Padding(0, 0, 0, 7).
    THIS-OBJECT:textBox2:Multiline = true.
    THIS-OBJECT:textBox2:Name = "textBox2".
    THIS-OBJECT:textBox2:ScrollBars = System.Windows.Forms.ScrollBars:Vertical.
    THIS-OBJECT:textBox2:Size = NEW System.Drawing.Size(623, 43).
    THIS-OBJECT:textBox2:TabIndex = 1.
    /*  */
    /* tableL_Easily */
    /*  */
    DEFINE VARIABLE nestedvar2 AS System.Windows.Forms.AnchorStyles NO-UNDO.
    nestedvar2 = CAST(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
    THIS-OBJECT:tableL_Easily:Anchor = CAST(Progress.Util.EnumHelper:Or(nestedvar2, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
    THIS-OBJECT:tableL_Easily:BackColor = System.Drawing.SystemColors:Control.
    THIS-OBJECT:tableL_Easily:ColumnCount = 5.
    THIS-OBJECT:tableLayoutPanel9:SetColumnSpan(THIS-OBJECT:tableL_Easily, 2).
    THIS-OBJECT:tableL_Easily:ColumnStyles:Add(NEW System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(150))).
    THIS-OBJECT:tableL_Easily:ColumnStyles:Add(NEW System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(50))).
    THIS-OBJECT:tableL_Easily:ColumnStyles:Add(NEW System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(30))).
    THIS-OBJECT:tableL_Easily:ColumnStyles:Add(NEW System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(50))).
    THIS-OBJECT:tableL_Easily:ColumnStyles:Add(NEW System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(270))).
    THIS-OBJECT:tableL_Easily:Controls:Add(THIS-OBJECT:flowLayoutPanel1, 4, 0).
    THIS-OBJECT:tableL_Easily:Controls:Add(THIS-OBJECT:label12, 2, 0).
    THIS-OBJECT:tableL_Easily:Controls:Add(THIS-OBJECT:dateTimePicker1, 1, 0).
    THIS-OBJECT:tableL_Easily:Controls:Add(THIS-OBJECT:label13, 0, 0).
    THIS-OBJECT:tableL_Easily:Controls:Add(THIS-OBJECT:dateTimePicker2, 3, 0).
    THIS-OBJECT:tableL_Easily:Location = NEW System.Drawing.Point(0, 90).
    THIS-OBJECT:tableL_Easily:Margin = NEW System.Windows.Forms.Padding(0).
    THIS-OBJECT:tableL_Easily:Name = "tableL_Easily".
    THIS-OBJECT:tableL_Easily:RowCount = 1.
    THIS-OBJECT:tableL_Easily:RowStyles:Add(NEW System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    THIS-OBJECT:tableL_Easily:Size = NEW System.Drawing.Size(773, 30).
    THIS-OBJECT:tableL_Easily:TabIndex = 8.
    /*  */
    /* flowLayoutPanel1 */
    /*  */
    THIS-OBJECT:flowLayoutPanel1:Controls:Add(THIS-OBJECT:checkBox2).
    THIS-OBJECT:flowLayoutPanel1:Controls:Add(THIS-OBJECT:checkBox3).
    THIS-OBJECT:flowLayoutPanel1:Controls:Add(THIS-OBJECT:checkBox4).
    THIS-OBJECT:flowLayoutPanel1:Controls:Add(THIS-OBJECT:checkBox5).
    THIS-OBJECT:flowLayoutPanel1:Controls:Add(THIS-OBJECT:checkBox6).
    THIS-OBJECT:flowLayoutPanel1:Controls:Add(THIS-OBJECT:checkBox7).
    THIS-OBJECT:flowLayoutPanel1:Controls:Add(THIS-OBJECT:checkBox8).
    THIS-OBJECT:flowLayoutPanel1:Dock = System.Windows.Forms.DockStyle:Fill.
    THIS-OBJECT:flowLayoutPanel1:Location = NEW System.Drawing.Point(509, 0).
    THIS-OBJECT:flowLayoutPanel1:Margin = NEW System.Windows.Forms.Padding(7, 0, 0, 0).
    THIS-OBJECT:flowLayoutPanel1:MinimumSize = NEW System.Drawing.Size(250, 0).
    THIS-OBJECT:flowLayoutPanel1:Name = "flowLayoutPanel1".
    THIS-OBJECT:flowLayoutPanel1:Size = NEW System.Drawing.Size(264, 30).
    THIS-OBJECT:flowLayoutPanel1:TabIndex = 15.
    /*  */
    /* checkBox2 */
    /*  */
    THIS-OBJECT:checkBox2:AutoSize = true.
    THIS-OBJECT:checkBox2:Checked = true.
    THIS-OBJECT:checkBox2:CheckState = System.Windows.Forms.CheckState:Checked.
    THIS-OBJECT:checkBox2:DataBindings:Add(NEW System.Windows.Forms.Binding("Checked", THIS-OBJECT:bindingSchedWeek, "isday_mon", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
    THIS-OBJECT:checkBox2:Location = NEW System.Drawing.Point(0, 4).
    THIS-OBJECT:checkBox2:Margin = NEW System.Windows.Forms.Padding(0, 4, 0, 0).
    THIS-OBJECT:checkBox2:Name = "checkBox2".
    THIS-OBJECT:checkBox2:Size = NEW System.Drawing.Size(38, 18).
    THIS-OBJECT:checkBox2:TabIndex = 0.
    THIS-OBJECT:checkBox2:Text = "Пн".
    THIS-OBJECT:checkBox2:UseCompatibleTextRendering = true.
    THIS-OBJECT:checkBox2:UseVisualStyleBackColor = true.
    /*  */
    /* bindingSchedWeek */
    /*  */
    THIS-OBJECT:bindingSchedWeek:MaxDataGuess = 0.
    THIS-OBJECT:bindingSchedWeek:NoLOBs = false.
    THIS-OBJECT:bindingSchedWeek:Position = 0.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    DEFINE VARIABLE arrayvar7 AS "Progress.Data.TableDesc[]" NO-UNDO.
    arrayvar7 = NEW "Progress.Data.TableDesc[]"(0).
    tableDesc12:ChildTables = arrayvar7.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    DEFINE VARIABLE arrayvar8 AS Progress.Data.ColumnPropDesc EXTENT 9 NO-UNDO.
    arrayvar8[1] = NEW Progress.Data.ColumnPropDesc("isday_mon", "", Progress.Data.DataType:LOGICAL).
    arrayvar8[2] = NEW Progress.Data.ColumnPropDesc("isday_tue", "", Progress.Data.DataType:LOGICAL).
    arrayvar8[3] = NEW Progress.Data.ColumnPropDesc("isday_wed", "", Progress.Data.DataType:LOGICAL).
    arrayvar8[4] = NEW Progress.Data.ColumnPropDesc("isday_thu", "", Progress.Data.DataType:LOGICAL).
    arrayvar8[5] = NEW Progress.Data.ColumnPropDesc("isday_fri", "", Progress.Data.DataType:LOGICAL).
    arrayvar8[6] = NEW Progress.Data.ColumnPropDesc("isday_sat", "", Progress.Data.DataType:LOGICAL).
    arrayvar8[7] = NEW Progress.Data.ColumnPropDesc("isday_sun", "", Progress.Data.DataType:LOGICAL).
    arrayvar8[8] = NEW Progress.Data.ColumnPropDesc("dtime-beg", "время с", Progress.Data.DataType:DATETIME).
    arrayvar8[9] = NEW Progress.Data.ColumnPropDesc("dtime-end", "время по", Progress.Data.DataType:DATETIME).
    tableDesc12:Columns = arrayvar8.
    THIS-OBJECT:bindingSchedWeek:TableSchema = tableDesc12.
    /*  */
    /* checkBox3 */
    /*  */
    THIS-OBJECT:checkBox3:AutoSize = true.
    THIS-OBJECT:checkBox3:Checked = true.
    THIS-OBJECT:checkBox3:CheckState = System.Windows.Forms.CheckState:Checked.
    THIS-OBJECT:checkBox3:DataBindings:Add(NEW System.Windows.Forms.Binding("Checked", THIS-OBJECT:bindingSchedWeek, "isday_tue", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
    THIS-OBJECT:checkBox3:Location = NEW System.Drawing.Point(38, 4).
    THIS-OBJECT:checkBox3:Margin = NEW System.Windows.Forms.Padding(0, 4, 0, 0).
    THIS-OBJECT:checkBox3:Name = "checkBox3".
    THIS-OBJECT:checkBox3:Size = NEW System.Drawing.Size(36, 18).
    THIS-OBJECT:checkBox3:TabIndex = 1.
    THIS-OBJECT:checkBox3:Text = "Вт".
    THIS-OBJECT:checkBox3:UseCompatibleTextRendering = true.
    THIS-OBJECT:checkBox3:UseVisualStyleBackColor = true.
    /*  */
    /* checkBox4 */
    /*  */
    THIS-OBJECT:checkBox4:AutoSize = true.
    THIS-OBJECT:checkBox4:Checked = true.
    THIS-OBJECT:checkBox4:CheckState = System.Windows.Forms.CheckState:Checked.
    THIS-OBJECT:checkBox4:DataBindings:Add(NEW System.Windows.Forms.Binding("Checked", THIS-OBJECT:bindingSchedWeek, "isday_wed", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
    THIS-OBJECT:checkBox4:Location = NEW System.Drawing.Point(74, 4).
    THIS-OBJECT:checkBox4:Margin = NEW System.Windows.Forms.Padding(0, 4, 0, 0).
    THIS-OBJECT:checkBox4:Name = "checkBox4".
    THIS-OBJECT:checkBox4:Size = NEW System.Drawing.Size(38, 18).
    THIS-OBJECT:checkBox4:TabIndex = 2.
    THIS-OBJECT:checkBox4:Text = "Ср".
    THIS-OBJECT:checkBox4:UseCompatibleTextRendering = true.
    THIS-OBJECT:checkBox4:UseVisualStyleBackColor = true.
    /*  */
    /* checkBox5 */
    /*  */
    THIS-OBJECT:checkBox5:AutoSize = true.
    THIS-OBJECT:checkBox5:Checked = true.
    THIS-OBJECT:checkBox5:CheckState = System.Windows.Forms.CheckState:Checked.
    THIS-OBJECT:checkBox5:DataBindings:Add(NEW System.Windows.Forms.Binding("Checked", THIS-OBJECT:bindingSchedWeek, "isday_thu", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
    THIS-OBJECT:checkBox5:Location = NEW System.Drawing.Point(112, 4).
    THIS-OBJECT:checkBox5:Margin = NEW System.Windows.Forms.Padding(0, 4, 0, 0).
    THIS-OBJECT:checkBox5:Name = "checkBox5".
    THIS-OBJECT:checkBox5:Size = NEW System.Drawing.Size(36, 18).
    THIS-OBJECT:checkBox5:TabIndex = 3.
    THIS-OBJECT:checkBox5:Text = "Чт".
    THIS-OBJECT:checkBox5:UseCompatibleTextRendering = true.
    THIS-OBJECT:checkBox5:UseVisualStyleBackColor = true.
    /*  */
    /* checkBox6 */
    /*  */
    THIS-OBJECT:checkBox6:AutoSize = true.
    THIS-OBJECT:checkBox6:Checked = true.
    THIS-OBJECT:checkBox6:CheckState = System.Windows.Forms.CheckState:Checked.
    THIS-OBJECT:checkBox6:DataBindings:Add(NEW System.Windows.Forms.Binding("Checked", THIS-OBJECT:bindingSchedWeek, "isday_fri", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
    THIS-OBJECT:checkBox6:Location = NEW System.Drawing.Point(148, 4).
    THIS-OBJECT:checkBox6:Margin = NEW System.Windows.Forms.Padding(0, 4, 0, 0).
    THIS-OBJECT:checkBox6:Name = "checkBox6".
    THIS-OBJECT:checkBox6:Size = NEW System.Drawing.Size(37, 18).
    THIS-OBJECT:checkBox6:TabIndex = 4.
    THIS-OBJECT:checkBox6:Text = "Пт".
    THIS-OBJECT:checkBox6:UseCompatibleTextRendering = true.
    THIS-OBJECT:checkBox6:UseVisualStyleBackColor = true.
    /*  */
    /* checkBox7 */
    /*  */
    THIS-OBJECT:checkBox7:AutoSize = true.
    THIS-OBJECT:checkBox7:DataBindings:Add(NEW System.Windows.Forms.Binding("Checked", THIS-OBJECT:bindingSchedWeek, "isday_sat", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
    THIS-OBJECT:checkBox7:ForeColor = System.Drawing.Color:Red.
    THIS-OBJECT:checkBox7:Location = NEW System.Drawing.Point(185, 4).
    THIS-OBJECT:checkBox7:Margin = NEW System.Windows.Forms.Padding(0, 4, 0, 0).
    THIS-OBJECT:checkBox7:Name = "checkBox7".
    THIS-OBJECT:checkBox7:Size = NEW System.Drawing.Size(38, 18).
    THIS-OBJECT:checkBox7:TabIndex = 5.
    THIS-OBJECT:checkBox7:Text = "Сб".
    THIS-OBJECT:checkBox7:UseCompatibleTextRendering = true.
    THIS-OBJECT:checkBox7:UseVisualStyleBackColor = true.
    /*  */
    /* checkBox8 */
    /*  */
    THIS-OBJECT:checkBox8:AutoSize = true.
    THIS-OBJECT:checkBox8:DataBindings:Add(NEW System.Windows.Forms.Binding("Checked", THIS-OBJECT:bindingSchedWeek, "isday_sun", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
    THIS-OBJECT:checkBox8:ForeColor = System.Drawing.Color:Red.
    THIS-OBJECT:checkBox8:Location = NEW System.Drawing.Point(223, 4).
    THIS-OBJECT:checkBox8:Margin = NEW System.Windows.Forms.Padding(0, 4, 0, 0).
    THIS-OBJECT:checkBox8:Name = "checkBox8".
    THIS-OBJECT:checkBox8:Size = NEW System.Drawing.Size(36, 18).
    THIS-OBJECT:checkBox8:TabIndex = 6.
    THIS-OBJECT:checkBox8:Text = "Вс".
    THIS-OBJECT:checkBox8:UseCompatibleTextRendering = true.
    THIS-OBJECT:checkBox8:UseVisualStyleBackColor = true.
    /*  */
    /* label12 */
    /*  */
    THIS-OBJECT:label12:Location = NEW System.Drawing.Point(314, 0).
    THIS-OBJECT:label12:Name = "label12".
    THIS-OBJECT:label12:Size = NEW System.Drawing.Size(24, 23).
    THIS-OBJECT:label12:TabIndex = 14.
    THIS-OBJECT:label12:Text = "по:".
    THIS-OBJECT:label12:TextAlign = System.Drawing.ContentAlignment:MiddleCenter.
    THIS-OBJECT:label12:UseCompatibleTextRendering = true.
    /*  */
    /* dateTimePicker1 */
    /*  */
    THIS-OBJECT:dateTimePicker1:CustomFormat = "HH:mm".
    THIS-OBJECT:dateTimePicker1:DataBindings:Add(NEW System.Windows.Forms.Binding("Value", THIS-OBJECT:bindingSchedWeek, "dtime-beg", true)).
    THIS-OBJECT:dateTimePicker1:Dock = System.Windows.Forms.DockStyle:Fill.
    THIS-OBJECT:dateTimePicker1:Format = System.Windows.Forms.DateTimePickerFormat:Custom.
    THIS-OBJECT:dateTimePicker1:Location = NEW System.Drawing.Point(153, 4).
    THIS-OBJECT:dateTimePicker1:Margin = NEW System.Windows.Forms.Padding(3, 4, 0, 0).
    THIS-OBJECT:dateTimePicker1:Name = "dateTimePicker1".
    THIS-OBJECT:dateTimePicker1:ShowUpDown = true.
    THIS-OBJECT:dateTimePicker1:Size = NEW System.Drawing.Size(158, 20).
    THIS-OBJECT:dateTimePicker1:TabIndex = 12.
    /*  */
    /* label13 */
    /*  */
    THIS-OBJECT:label13:Dock = System.Windows.Forms.DockStyle:Fill.
    THIS-OBJECT:label13:Location = NEW System.Drawing.Point(3, 0).
    THIS-OBJECT:label13:Name = "label13".
    THIS-OBJECT:label13:Size = NEW System.Drawing.Size(144, 30).
    THIS-OBJECT:label13:TabIndex = 0.
    THIS-OBJECT:label13:Text = "Время с:".
    THIS-OBJECT:label13:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
    THIS-OBJECT:label13:UseCompatibleTextRendering = true.
    /*  */
    /* dateTimePicker2 */
    /*  */
    THIS-OBJECT:dateTimePicker2:CustomFormat = "HH:mm".
    THIS-OBJECT:dateTimePicker2:DataBindings:Add(NEW System.Windows.Forms.Binding("Value", THIS-OBJECT:bindingSchedWeek, "dtime-end", true)).
    THIS-OBJECT:dateTimePicker2:Dock = System.Windows.Forms.DockStyle:Fill.
    THIS-OBJECT:dateTimePicker2:Format = System.Windows.Forms.DateTimePickerFormat:Custom.
    THIS-OBJECT:dateTimePicker2:Location = NEW System.Drawing.Point(344, 4).
    THIS-OBJECT:dateTimePicker2:Margin = NEW System.Windows.Forms.Padding(3, 4, 0, 0).
    THIS-OBJECT:dateTimePicker2:Name = "dateTimePicker2".
    THIS-OBJECT:dateTimePicker2:ShowUpDown = true.
    THIS-OBJECT:dateTimePicker2:Size = NEW System.Drawing.Size(158, 20).
    THIS-OBJECT:dateTimePicker2:TabIndex = 13.
    /*  */
    /* uc_TabAddEdit */
    /*  */
    THIS-OBJECT:AutoScaleDimensions = NEW System.Drawing.SizeF(Progress.Util.CastUtil:ToSingle(6), Progress.Util.CastUtil:ToSingle(13)).
    THIS-OBJECT:Controls:Add(THIS-OBJECT:tableLayoutPanel9).
    THIS-OBJECT:Name = "uc_TabAddEdit".
    THIS-OBJECT:Size = NEW System.Drawing.Size(773, 393).
    THIS-OBJECT:tableLayoutPanel9:ResumeLayout(false).
    THIS-OBJECT:tableLayoutPanel9:PerformLayout().
    THIS-OBJECT:tableL_Detailed:ResumeLayout(false).
    THIS-OBJECT:tableLayoutPanel1:ResumeLayout(false).
    THIS-OBJECT:flowLayoutPanel2:ResumeLayout(false).
    THIS-OBJECT:flowLayoutPanel2:PerformLayout().
    CAST(THIS-OBJECT:bindingSchedWeek3, System.ComponentModel.ISupportInitialize):EndInit().
    CAST(THIS-OBJECT:dataGridView1, System.ComponentModel.ISupportInitialize):EndInit().
    CAST(THIS-OBJECT:bindingSchedWeek2, System.ComponentModel.ISupportInitialize):EndInit().
    CAST(THIS-OBJECT:bindPromoActionOne, System.ComponentModel.ISupportInitialize):EndInit().
    THIS-OBJECT:tableLayoutPanel12:ResumeLayout(false).
    THIS-OBJECT:tableLayoutPanel13:ResumeLayout(false).
    THIS-OBJECT:tableLayoutPanel13:PerformLayout().
    THIS-OBJECT:tableL_Easily:ResumeLayout(false).
    THIS-OBJECT:flowLayoutPanel1:ResumeLayout(false).
    THIS-OBJECT:flowLayoutPanel1:PerformLayout().
    CAST(THIS-OBJECT:bindingSchedWeek, System.ComponentModel.ISupportInitialize):EndInit().
    THIS-OBJECT:ResumeLayout(false).
    CATCH e AS Progress.Lang.Error:
      UNDO, THROW e.
    END CATCH.
    END METHOD.


	/*------------------------------------------------------------------------------
	 Purpose: переключение расписания ПРОСТОЕ-ДЕТАЛЬНОЕ
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	METHOD PRIVATE VOID radioButton6_CheckedChanged( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
        if radioButton6:Checked then do: // детальное -> простое 
           // 16/VIII-2018 - отменено копирование расписания при переключении
           radioButton6:ForeColor  = System.Drawing.Color:Green.
           radioButton5:ForeColor  = System.Drawing.Color:Black.
           tableL_Detailed:Visible = false.
           tableL_Easily:Visible = true.
        end.
        else do: // простое -> детальное
           // 16/VIII-2018 - отменено копирование расписания при переключении
           radioButton6:ForeColor  = System.Drawing.Color:Black.
           radioButton5:ForeColor  = System.Drawing.Color:Green.
           tableL_Easily:Visible = false.
           tableL_Detailed:Visible = true.
        end.

		RETURN.
	END METHOD.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  METHOD PRIVATE VOID dataGridView1_CellFormatting(
   INPUT sender AS System.Object
 , INPUT e      AS System.Windows.Forms.DataGridViewCellFormattingEventArgs ):
   define variable v-iday as integer no-undo .
   
   // выводить наименования дней недели вместо номеров дней недели
   if (dataGridView1:Columns[e:ColumnIndex]:Name = "wdaynum") then do :
     v-iday = e:Value .
     if v-iday > 0 then assign 
       e:Value = a-week-days[v-iday]
       e:FormattingApplied = true
     .       
   end .
   
    RETURN.
  END METHOD.


  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  METHOD PRIVATE VOID dateTimePicker3_ValueChanged( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
    dateTimePicker4:MinDate = dateTimePicker3:Value .
    RETURN.
  END METHOD.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  METHOD PRIVATE VOID button9_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
    define variable v-has-errors as logical no-undo .
    
      if tableLayoutPanel1:Visible then do :
        // добавить введённые данные в список и закрыть панель
         dateTimePicker3:Value = dateTimePicker3:Value .         
         dateTimePicker4:Value = dateTimePicker4:Value .         
         bindingSchedWeek3:Assign().
         
         v-has-errors = m-promo-trg:add2Detail("promoSchedWeek2") .
         if v-has-errors then
           bindingSchedWeek3:Refresh() .
         else assign
           button1:Text = "Удалить" 
           tableLayoutPanel1:Visible = false    
         .
      end .
      else assign
        button1:Text = "Не добавлять" 
        tableLayoutPanel1:Visible = true    
      .
      
    RETURN.
  END METHOD.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  METHOD PRIVATE VOID button1_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
      if tableLayoutPanel1:Visible then do :
        tableLayoutPanel1:Visible = false .   
        button1:Text = "Удалить" .
      end .
      else do :
        // удалить из списка строку под курсором; панель не открывать 
         m-promo-trg:delFromDetail("promoSchedWeek2") .
      end .
      
    RETURN.
  END METHOD.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	METHOD PRIVATE VOID textBox1_TextChanged( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
		label8:Text = textBox1:Text .
		RETURN.
	END METHOD.

END CLASS.