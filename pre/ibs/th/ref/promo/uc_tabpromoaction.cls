USING Progress.Lang.*.
USING Progress.Windows.UserControl.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS ibs.th.ref.promo.uc_TabPromoAction INHERITS UserControl:
   //define private variable m-promo-trg as ibs.th.ref.promo.promo_trg no-undo.
  define private variable radioButton3               as System.Windows.Forms.RadioButton      no-undo.
  define         variable vss-revision               as character                             no-undo init "$Revision: 1ee1aa69dd2c, 3342, rls $":U .
  define         variable vss-author                 as character                             no-undo init "$Author: EShklyar $":U .
  define         variable vss-date                   as character                             no-undo init "$Date: 2023/05/19 13:37:10 $":U .
  define         variable vss-workfile               as character                             no-undo init "$Workfile: uc_TabPromoAction.cls $":U .
  define         variable vss-archive                as character                             no-undo init "$Archive: ibs/th/ref/promo/uc_TabPromoAction.cls $":U .
  define         variable vss-description            as character                             no-undo init "Просмотр/редактирование одной акции".
  define private variable bindPromoActionOne         as Progress.Data.BindingSource           no-undo.
  DEFINE PRIVATE VARIABLE comboBox3                  AS System.Windows.Forms.ComboBox         NO-UNDO.
  DEFINE PRIVATE VARIABLE comboBox1                  AS System.Windows.Forms.ComboBox         NO-UNDO.
  DEFINE PRIVATE VARIABLE checkBox1                  AS System.Windows.Forms.CheckBox         NO-UNDO.
  DEFINE PRIVATE VARIABLE components                 AS System.ComponentModel.IContainer      NO-UNDO.
  DEFINE PRIVATE VARIABLE tableLayoutPanel7          AS System.Windows.Forms.TableLayoutPanel NO-UNDO.
  DEFINE PRIVATE VARIABLE tableLayoutPanel6          AS System.Windows.Forms.TableLayoutPanel NO-UNDO.
  DEFINE PRIVATE VARIABLE tableLayoutPanel20         AS System.Windows.Forms.TableLayoutPanel NO-UNDO.
  DEFINE PRIVATE VARIABLE tableLayoutPanel10         AS System.Windows.Forms.TableLayoutPanel NO-UNDO.
  DEFINE PRIVATE VARIABLE tableLayoutPanel1          AS System.Windows.Forms.TableLayoutPanel NO-UNDO.
  DEFINE PRIVATE VARIABLE radioButton2               AS System.Windows.Forms.RadioButton      NO-UNDO.
  DEFINE PRIVATE VARIABLE radioButton1               AS System.Windows.Forms.RadioButton      NO-UNDO.
  DEFINE PRIVATE VARIABLE panel_SelectConditionItems AS System.Windows.Forms.Panel            NO-UNDO.
  DEFINE PRIVATE VARIABLE label6                     AS System.Windows.Forms.Label            NO-UNDO.
  DEFINE PRIVATE VARIABLE label5                     AS System.Windows.Forms.Label            NO-UNDO.
  DEFINE PRIVATE VARIABLE label2                     AS System.Windows.Forms.Label            NO-UNDO.
  DEFINE PRIVATE VARIABLE label1                     AS System.Windows.Forms.Label            NO-UNDO.
  DEFINE         VARIABLE ucMain7                    AS ibs.th.ref.promo.uc_SelectsGCP        NO-UNDO.
  define private variable m-promo-type               as class                                 ibs.th.ref.promo.promoType no-undo.
   define temp-table ttMethodCalc
    field list  as character
    field item as character
    field code  as integer
 index  item list item
 index  code list code
 .
   define temp-table ttTypeCond
    field list  as character
    field item as character
    field code  as integer
 index  item list item
 index  code list code
 .
  define private variable m-promo-trg as class ibs.th.ref.promo.promo_trg no-undo.
method Public VOID SetPromoTrg(input v-promo-trg as class ibs.th.ref.promo.promo_trg  ):
    m-promo-trg = v-promo-trg.
       if valid-object (ucMain7) then ucMain7 :SetPromoTrg     (m-promo-trg).
        SetBind().
end.
method Public VOID PublicEvent (input iEvent as character, input iEventParam as character   ):
       if valid-object (ucMain7) then ucMain7 :PublicEvent     (iEvent, iEventParam).
end.
        @VisualDesigner.
        method private void checkBox1_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
                return.
        end method.
  @VisualDesigner.
  method private void panel_SelectConditionItems_Paint( input sender as System.Object, input e as System.Windows.Forms.PaintEventArgs ):
    return.
  end method.
  method Public VOID SetBind( ):
    bindPromoActionOne:handle = m-promo-trg:getQuery("promoActionOne2").
    setDisable(m-promo-trg:modeView).
  end.
  method public VOID setDisable(input iModeView as logical  ):
    assign
      radioButton1:enabled = not iModeview
      radioButton2:enabled = not iModeview
      radioButton3:enabled = not iModeview
      checkBox1:enabled = not iModeview
      comboBox1:enabled    = not iModeview
      comboBox3:enabled    = not iModeview
      .
  end.
  CONSTRUCTOR PUBLIC uc_TabPromoAction (  ):
    SUPER().
    InitializeComponent().
    m-promo-type = new ibs.th.ref.promo.promoType().
    Init_comboBox1(1).
    Init_comboBox3(1,1).
    THIS-OBJECT:ComponentsCollection:ADD(THIS-OBJECT:components).
    CATCH e AS Progress.Lang.Error:
      UNDO, THROW e.
    END CATCH.
  END CONSTRUCTOR.
  DESTRUCTOR PUBLIC uc_TabPromoAction ( ):
    if valid-object(m-promo-trg)
      then
    do:
      closeBind().
      m-promo-trg:saveTypediscont(radioButton1:Checked,
        radioButton2:Checked,
        radioButton2:Checked).
    end.
  END DESTRUCTOR.
  method private void closeBind():
    if valid-handle(bindPromoActionOne:handle)
    then
        bindPromoActionOne:Assign().
    bindPromoActionOne:Dispose().
  end.
  METHOD PUBLIC VOID Enabled_Controls(INPUT sender AS LOGICAL):
      //  panel_SelectConditionItems:Enabled = sender.
    tableLayoutPanel6:Enabled = sender.
    label6:Enabled = sender.
    comboBox3:Enabled = sender.
  END METHOD.
  define variable changecomboBox1 as logical no-undo init yes.
  METHOD PRIVATE VOID Init_comboBox1(INPUT sender AS integer ):
    define variable vtext as character no-undo.
    vtext = comboBox1:text.
    comboBox1:Items:Clear().
    m-promo-type:CangeTypeDiscont(sender).
    m-promo-type:typeTable("methodCalc", output table ttMethodCalc).
    for each ttMethodCalc:
      comboBox1:Items:Add(ttMethodCalc.item).
      if ttMethodCalc.item eq vtext
        then
      do:
        changecomboBox1 = no.
        comboBox1:text = vtext.
        changecomboBox1 = yes.
      end.
    end.
    IF sender eq 1 THEN
    DO:
      label2:Visible = true.
      comboBox1:Visible = true.
      label5:Visible = TRUE.
      label6:Visible = TRUE.
      checkBox1:Visible = TRUE.
      comboBox3:Visible = TRUE.
    END.
    ELSE
    DO:
      IF sender eq 2
        then
      do:
        label2:Visible = true.
        comboBox1:Visible = true.
        label5:Visible = TRUE.
        checkBox1:Visible = TRUE.
        label6:Visible = FALSE.
        comboBox3:Visible = FALSE.
      end.
      else
      do:
        label2:Visible = true.
        comboBox1:Visible = true.
        checkBox1:Visible = false.
        label6:Visible = true.
        comboBox3:Visible = true.
      end.
    END.
  END METHOD.
  METHOD PRIVATE VOID Init_comboBox_nUMBER(INPUT sender AS INTEGER):
    IF radioButton1:Checked THEN
    DO:
      label5:Visible = TRUE.
      label6:Visible = TRUE.
      checkBox1:Visible = TRUE.
      comboBox3:Visible = TRUE.
    END.
    if comboBox3:Text = "Скидка по ШК"
     then do:
      label5:Visible = false.
      checkBox1:Visible = false.
      m-promo-trg:ViewPage6(no).
    end.
    IF sender = 3  THEN
    DO:
      label5:Visible = FALSE.
      label6:Visible = FALSE.
      checkBox1:Visible = FALSE.
      comboBox3:Visible = FALSE.
    END.
    IF sender = 4  THEN
    DO:
      label5:Visible = FALSE.
      label6:Visible = FALSE.
      checkBox1:Visible = FALSE.
      comboBox3:Visible = FALSE.
    END.
    IF sender = 5  THEN
    DO:
      label5:Visible = FALSE.
      checkBox1:Visible = FALSE.
    END.
  END METHOD.
  define variable changecomboBox3 as logical no-undo init yes.
  METHOD PRIVATE VOID Init_comboBox3(INPUT itypeDiscont AS integer ,input iMethodCalc as integer ):
    define variable vtext as character no-undo.
    vtext = comboBox3:text.
    comboBox3:Items:Clear().
    label5:Text = "Независимые условия:".
    m-promo-type:CangeTypeDiscontAndMethodCalc(itypeDiscont,iMethodCalc).
    m-promo-type:typeTable("typecond", output table tttypecond).
    for each tttypecond:
      comboBox3:Items:Add(tttypecond.item).
      if tttypecond.item eq vtext
        then
      do:
        changecomboBox3 = no.
        comboBox3:text = vtext.
        changecomboBox3 = yes.
      end.
    end.
  END METHOD.
  METHOD PRIVATE VOID init_first_value_combobox(itypeDiscont as integer ):
    m-promo-type:CangeTypeDiscont(itypeDiscont).
    m-promo-type:typeTable("methodCalc", output table ttMethodCalc).
    for first ttMethodCalc:
      comboBox1:text = ttMethodCalc.item.
    end.
    if available ttMethodCalc
      then
    do:
      m-promo-type:CangeTypeDiscontAndMethodCalc(itypeDiscont,ttMethodCalc.code).
      m-promo-type:typeTable("typecond", output table tttypecond).
      for first tttypecond:
        comboBox3:text = tttypecond.item.
      end.
    end.
  END METHOD.
  METHOD PRIVATE VOID InitializeComponent(  ):
        this-object:components = new System.ComponentModel.Container().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable tableDesc1 as Progress.Data.TableDesc no-undo.
        tableDesc1 = new Progress.Data.TableDesc("tt-promoaction-one").
        this-object:tableLayoutPanel1 = new System.Windows.Forms.TableLayoutPanel().
        this-object:tableLayoutPanel20 = new System.Windows.Forms.TableLayoutPanel().
        this-object:tableLayoutPanel7 = new System.Windows.Forms.TableLayoutPanel().
        this-object:checkBox1 = new System.Windows.Forms.CheckBox().
        this-object:bindPromoActionOne = new Progress.Data.BindingSource(this-object:components).
        this-object:label5 = new System.Windows.Forms.Label().
        this-object:label6 = new System.Windows.Forms.Label().
        this-object:comboBox3 = new System.Windows.Forms.ComboBox().
        this-object:tableLayoutPanel6 = new System.Windows.Forms.TableLayoutPanel().
        this-object:label1 = new System.Windows.Forms.Label().
        this-object:label2 = new System.Windows.Forms.Label().
        this-object:tableLayoutPanel10 = new System.Windows.Forms.TableLayoutPanel().
        this-object:radioButton1 = new System.Windows.Forms.RadioButton().
        this-object:radioButton2 = new System.Windows.Forms.RadioButton().
        this-object:radioButton3 = new System.Windows.Forms.RadioButton().
        this-object:comboBox1 = new System.Windows.Forms.ComboBox().
        this-object:panel_SelectConditionItems = new System.Windows.Forms.Panel().
        this-object:tableLayoutPanel1:SuspendLayout().
        this-object:tableLayoutPanel20:SuspendLayout().
        this-object:tableLayoutPanel7:SuspendLayout().
        cast(this-object:bindPromoActionOne, System.ComponentModel.ISupportInitialize):BeginInit().
        this-object:tableLayoutPanel6:SuspendLayout().
        this-object:tableLayoutPanel10:SuspendLayout().
        this-object:SuspendLayout().
        this-object:tableLayoutPanel1:ColumnCount = 1.
        this-object:tableLayoutPanel1:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
        this-object:tableLayoutPanel1:Controls:Add(this-object:tableLayoutPanel20, 0, 0).
        this-object:tableLayoutPanel1:Controls:Add(this-object:panel_SelectConditionItems, 0, 2).
        this-object:tableLayoutPanel1:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:tableLayoutPanel1:Location = new System.Drawing.Point(0, 0).
        this-object:tableLayoutPanel1:Name = "tableLayoutPanel1".
        this-object:tableLayoutPanel1:RowCount = 3.
        this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(65))).
        this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(7))).
        this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
        this-object:tableLayoutPanel1:Size = new System.Drawing.Size(901, 263).
        this-object:tableLayoutPanel1:TabIndex = 1.
        this-object:tableLayoutPanel20:ColumnCount = 2.
        this-object:tableLayoutPanel20:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(50))).
        this-object:tableLayoutPanel20:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(50))).
        this-object:tableLayoutPanel20:Controls:Add(this-object:tableLayoutPanel7, 1, 0).
        this-object:tableLayoutPanel20:Controls:Add(this-object:tableLayoutPanel6, 0, 0).
        this-object:tableLayoutPanel20:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:tableLayoutPanel20:Location = new System.Drawing.Point(3, 3).
        this-object:tableLayoutPanel20:Name = "tableLayoutPanel20".
        this-object:tableLayoutPanel20:RowCount = 1.
        this-object:tableLayoutPanel20:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(50))).
        this-object:tableLayoutPanel20:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(50))).
        this-object:tableLayoutPanel20:Size = new System.Drawing.Size(895, 59).
        this-object:tableLayoutPanel20:TabIndex = 2.
        this-object:tableLayoutPanel7:ColumnCount = 2.
        this-object:tableLayoutPanel7:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(150))).
        this-object:tableLayoutPanel7:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
        this-object:tableLayoutPanel7:Controls:Add(this-object:checkBox1, 1, 0).
        this-object:tableLayoutPanel7:Controls:Add(this-object:label5, 0, 0).
        this-object:tableLayoutPanel7:Controls:Add(this-object:label6, 0, 1).
        this-object:tableLayoutPanel7:Controls:Add(this-object:comboBox3, 1, 1).
        this-object:tableLayoutPanel7:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:tableLayoutPanel7:Location = new System.Drawing.Point(447, 0).
        this-object:tableLayoutPanel7:Margin = new System.Windows.Forms.Padding(0).
        this-object:tableLayoutPanel7:Name = "tableLayoutPanel7".
        this-object:tableLayoutPanel7:RowCount = 2.
        this-object:tableLayoutPanel7:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(30))).
        this-object:tableLayoutPanel7:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(30))).
        this-object:tableLayoutPanel7:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(20))).
        this-object:tableLayoutPanel7:Size = new System.Drawing.Size(448, 59).
        this-object:tableLayoutPanel7:TabIndex = 1.
        this-object:tableLayoutPanel7:Paint:Subscribe(this-object:tableLayoutPanel7_Paint).
        this-object:checkBox1:DataBindings:Add(new System.Windows.Forms.Binding("Checked", this-object:bindPromoActionOne, "CritgoodsFl", true)).
        this-object:checkBox1:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:checkBox1:Location = new System.Drawing.Point(153, 3).
        this-object:checkBox1:Name = "checkBox1".
        this-object:checkBox1:Size = new System.Drawing.Size(292, 24).
        this-object:checkBox1:TabIndex = 8.
        this-object:checkBox1:Text = "Выбрать номенклатуру...".
        this-object:checkBox1:UseCompatibleTextRendering = true.
        this-object:checkBox1:UseVisualStyleBackColor = true.
        this-object:checkBox1:CheckedChanged:Subscribe(this-object:checkBox1_CheckedChanged).
        this-object:checkBox1:Click:Subscribe(this-object:checkBox1_Click).
        this-object:bindPromoActionOne:AutoUpdate = true.
        this-object:bindPromoActionOne:MaxDataGuess = 0.
        this-object:bindPromoActionOne:NoLOBs = false.
        this-object:bindPromoActionOne:Position = 0.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar0 as "Progress.Data.TableDesc[]" no-undo.
        arrayvar0 = new "Progress.Data.TableDesc[]"(0).
        tableDesc1:ChildTables = arrayvar0.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar1 as Progress.Data.ColumnPropDesc extent 6 no-undo.
        arrayvar1[1] = new Progress.Data.ColumnPropDesc("TypeDiscontsolo", "", Progress.Data.DataType:LOGICAL).
        arrayvar1[2] = new Progress.Data.ColumnPropDesc("methodCalclbl", "", Progress.Data.DataType:CHARACTER).
        arrayvar1[3] = new Progress.Data.ColumnPropDesc("typecondlbl", "", Progress.Data.DataType:CHARACTER).
        arrayvar1[4] = new Progress.Data.ColumnPropDesc("CritgoodsFl", "CritgoodsFl", Progress.Data.DataType:LOGICAL).
        arrayvar1[5] = new Progress.Data.ColumnPropDesc("TypeDiscontcombo", "", Progress.Data.DataType:LOGICAL).
        arrayvar1[6] = new Progress.Data.ColumnPropDesc("TypeDiscontvisa", "", Progress.Data.DataType:LOGICAL).
        tableDesc1:Columns = arrayvar1.
        this-object:bindPromoActionOne:TableSchema = tableDesc1.
        this-object:label5:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:label5:Location = new System.Drawing.Point(3, 3).
        this-object:label5:Margin = new System.Windows.Forms.Padding(3).
        this-object:label5:Name = "label5".
        this-object:label5:Size = new System.Drawing.Size(144, 24).
        this-object:label5:TabIndex = 4.
        this-object:label5:Text = "Независимые условия:".
        this-object:label5:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
        this-object:label5:UseCompatibleTextRendering = true.
        this-object:label6:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:label6:Location = new System.Drawing.Point(3, 33).
        this-object:label6:Margin = new System.Windows.Forms.Padding(3).
        this-object:label6:Name = "label6".
        this-object:label6:Size = new System.Drawing.Size(144, 24).
        this-object:label6:TabIndex = 5.
        this-object:label6:Text = "Вид условия:".
        this-object:label6:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
        this-object:label6:UseCompatibleTextRendering = true.
        this-object:comboBox3:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindPromoActionOne, "typecondlbl", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
        this-object:comboBox3:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:comboBox3:DropDownStyle = System.Windows.Forms.ComboBoxStyle:DropDownList.
        this-object:comboBox3:FormattingEnabled = true.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar2 as System.Object extent 3 no-undo.
        arrayvar2[1] = "Количество по строке".
        arrayvar2[2] = "Сумма по строке".
        arrayvar2[3] = "Итог чека".
        this-object:comboBox3:Items:AddRange(arrayvar2).
        this-object:comboBox3:Location = new System.Drawing.Point(153, 33).
        this-object:comboBox3:Name = "comboBox3".
        this-object:comboBox3:Size = new System.Drawing.Size(292, 21).
        this-object:comboBox3:TabIndex = 7.
        this-object:comboBox3:SelectedIndexChanged:Subscribe(this-object:comboBox3_SelectedIndexChanged).
        this-object:tableLayoutPanel6:ColumnCount = 2.
        this-object:tableLayoutPanel6:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(150))).
        this-object:tableLayoutPanel6:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
        this-object:tableLayoutPanel6:Controls:Add(this-object:label1, 0, 0).
        this-object:tableLayoutPanel6:Controls:Add(this-object:label2, 0, 1).
        this-object:tableLayoutPanel6:Controls:Add(this-object:tableLayoutPanel10, 1, 0).
        this-object:tableLayoutPanel6:Controls:Add(this-object:comboBox1, 1, 1).
        this-object:tableLayoutPanel6:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:tableLayoutPanel6:Location = new System.Drawing.Point(0, 0).
        this-object:tableLayoutPanel6:Margin = new System.Windows.Forms.Padding(0).
        this-object:tableLayoutPanel6:Name = "tableLayoutPanel6".
        this-object:tableLayoutPanel6:RowCount = 2.
        this-object:tableLayoutPanel6:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(30))).
        this-object:tableLayoutPanel6:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(30))).
        this-object:tableLayoutPanel6:Size = new System.Drawing.Size(447, 59).
        this-object:tableLayoutPanel6:TabIndex = 0.
        this-object:label1:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:label1:Location = new System.Drawing.Point(3, 3).
        this-object:label1:Margin = new System.Windows.Forms.Padding(3).
        this-object:label1:Name = "label1".
        this-object:label1:Size = new System.Drawing.Size(144, 24).
        this-object:label1:TabIndex = 0.
        this-object:label1:Text = "Вид скидки".
        this-object:label1:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
        this-object:label1:UseCompatibleTextRendering = true.
        this-object:label2:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:label2:Location = new System.Drawing.Point(3, 33).
        this-object:label2:Margin = new System.Windows.Forms.Padding(3).
        this-object:label2:Name = "label2".
        this-object:label2:Size = new System.Drawing.Size(144, 24).
        this-object:label2:TabIndex = 1.
        this-object:label2:Text = "Способ расчета".
        this-object:label2:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
        this-object:label2:UseCompatibleTextRendering = true.
        this-object:tableLayoutPanel10:ColumnCount = 3.
        this-object:tableLayoutPanel10:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(39.8712273))).
        this-object:tableLayoutPanel10:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(29.6156654))).
        this-object:tableLayoutPanel10:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(30.5131092))).
        this-object:tableLayoutPanel10:Controls:Add(this-object:radioButton1, 0, 0).
        this-object:tableLayoutPanel10:Controls:Add(this-object:radioButton2, 1, 0).
        this-object:tableLayoutPanel10:Controls:Add(this-object:radioButton3, 2, 0).
        this-object:tableLayoutPanel10:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:tableLayoutPanel10:Location = new System.Drawing.Point(153, 3).
        this-object:tableLayoutPanel10:Name = "tableLayoutPanel10".
        this-object:tableLayoutPanel10:RowCount = 1.
        this-object:tableLayoutPanel10:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
        this-object:tableLayoutPanel10:Size = new System.Drawing.Size(291, 24).
        this-object:tableLayoutPanel10:TabIndex = 4.
        this-object:radioButton1:Appearance = System.Windows.Forms.Appearance:Button.
        this-object:radioButton1:Checked = true.
        this-object:radioButton1:DataBindings:Add(new System.Windows.Forms.Binding("Checked", this-object:bindPromoActionOne, "TypeDiscontsolo", true)).
        this-object:radioButton1:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:radioButton1:ForeColor = System.Drawing.Color:Green.
        this-object:radioButton1:Location = new System.Drawing.Point(0, 0).
        this-object:radioButton1:Margin = new System.Windows.Forms.Padding(0).
        this-object:radioButton1:Name = "radioButton1".
        this-object:radioButton1:Size = new System.Drawing.Size(116, 24).
        this-object:radioButton1:TabIndex = 0.
        this-object:radioButton1:TabStop = true.
        this-object:radioButton1:Text = "Временная скидка".
        this-object:radioButton1:UseCompatibleTextRendering = true.
        this-object:radioButton1:UseVisualStyleBackColor = true.
        this-object:radioButton1:CheckedChanged:Subscribe(this-object:radioButton1_CheckedChanged).
        this-object:radioButton2:Appearance = System.Windows.Forms.Appearance:Button.
        this-object:radioButton2:DataBindings:Add(new System.Windows.Forms.Binding("Checked", this-object:bindPromoActionOne, "TypeDiscontcombo", true)).
        this-object:radioButton2:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:radioButton2:Location = new System.Drawing.Point(116, 0).
        this-object:radioButton2:Margin = new System.Windows.Forms.Padding(0).
        this-object:radioButton2:Name = "radioButton2".
        this-object:radioButton2:Size = new System.Drawing.Size(86, 24).
        this-object:radioButton2:TabIndex = 1.
        this-object:radioButton2:Text = "Промо-набор".
        this-object:radioButton2:UseCompatibleTextRendering = true.
        this-object:radioButton2:UseVisualStyleBackColor = true.
        this-object:radioButton2:CheckedChanged:Subscribe(this-object:radioButton1_CheckedChanged).
        this-object:radioButton3:Appearance = System.Windows.Forms.Appearance:Button.
        this-object:radioButton3:DataBindings:Add(new System.Windows.Forms.Binding("Checked", this-object:bindPromoActionOne, "TypeDiscontvisa", true)).
        this-object:radioButton3:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:radioButton3:Location = new System.Drawing.Point(202, 0).
        this-object:radioButton3:Margin = new System.Windows.Forms.Padding(0).
        this-object:radioButton3:Name = "radioButton3".
        this-object:radioButton3:Size = new System.Drawing.Size(89, 24).
        this-object:radioButton3:TabIndex = 2.
        this-object:radioButton3:Text = "Карта Visa".
        this-object:radioButton3:UseCompatibleTextRendering = true.
        this-object:radioButton3:UseVisualStyleBackColor = true.
        this-object:radioButton3:CheckedChanged:Subscribe(this-object:radioButton1_CheckedChanged).
        this-object:comboBox1:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindPromoActionOne, "methodCalclbl", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
        this-object:comboBox1:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:comboBox1:DropDownStyle = System.Windows.Forms.ComboBoxStyle:DropDownList.
        this-object:comboBox1:FormattingEnabled = true.
        this-object:comboBox1:Location = new System.Drawing.Point(153, 33).
        this-object:comboBox1:Name = "comboBox1".
        this-object:comboBox1:Size = new System.Drawing.Size(291, 21).
        this-object:comboBox1:TabIndex = 5.
        this-object:comboBox1:SelectedIndexChanged:Subscribe(this-object:comboBox1_SelectedIndexChanged).
        this-object:panel_SelectConditionItems:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:panel_SelectConditionItems:Location = new System.Drawing.Point(0, 72).
        this-object:panel_SelectConditionItems:Margin = new System.Windows.Forms.Padding(0).
        this-object:panel_SelectConditionItems:Name = "panel_SelectConditionItems".
        this-object:panel_SelectConditionItems:Size = new System.Drawing.Size(901, 191).
        this-object:panel_SelectConditionItems:TabIndex = 3.
        this-object:panel_SelectConditionItems:Paint:Subscribe(this-object:panel_SelectConditionItems_Paint).
        this-object:AutoScaleDimensions = new System.Drawing.SizeF(Progress.Util.CastUtil:ToSingle(6), Progress.Util.CastUtil:ToSingle(13)).
        this-object:Controls:Add(this-object:tableLayoutPanel1).
        this-object:Name = "uc_TabPromoAction".
        this-object:Size = new System.Drawing.Size(901, 263).
        this-object:tableLayoutPanel1:ResumeLayout(false).
        this-object:tableLayoutPanel20:ResumeLayout(false).
        this-object:tableLayoutPanel7:ResumeLayout(false).
        cast(this-object:bindPromoActionOne, System.ComponentModel.ISupportInitialize):EndInit().
        this-object:tableLayoutPanel6:ResumeLayout(false).
        this-object:tableLayoutPanel10:ResumeLayout(false).
        this-object:ResumeLayout(false).
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.
  END METHOD.
  @VisualDesigner.
  METHOD PRIVATE VOID radioButton1_CheckedChanged( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
    define variable vrabiobat as integer no-undo.
    THIS-OBJECT:panel_SelectConditionItems:Controls:Clear().
    Init_comboBox_nUMBER(0).
    if radioButton3:Checked then
    do:
      radioButton1:ForeColor  = System.Drawing.Color:Black.
      radioButton2:ForeColor  = System.Drawing.Color:Black.
      radioButton3:ForeColor  = System.Drawing.Color:Green.
      Show_Panet_SelectConditonItem().
    end.
    else
    do:
      if radioButton2:Checked then
      do:
        radioButton1:ForeColor  = System.Drawing.Color:Black.
        radioButton2:ForeColor  = System.Drawing.Color:Green.
        radioButton3:ForeColor  = System.Drawing.Color:Black.
      end.
      else
      do:
        radioButton1:ForeColor  = System.Drawing.Color:Green.
        radioButton2:ForeColor  = System.Drawing.Color:Black.
        radioButton3:ForeColor  = System.Drawing.Color:Black.
      end.
    end.
    vrabiobat = if radioButton3:checked then 3 else if radioButton2:checked then 2 else 1.
    Init_comboBox1(vrabiobat).
    find first ttMethodCalc where ttMethodCalc.item eq comboBox1:SelectedItem:ToString() no-lock no-error.
    if available ttMethodCalc
      then
      Init_comboBox3(vrabiobat,ttMethodCalc.code).
    RETURN.
  END METHOD.
  @VisualDesigner.
  METHOD PRIVATE VOID comboBox3_SelectedIndexChanged( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
    if changecomboBox3
      then
    do:
      IF radioButton1:Checked THEN
      DO:
        find first ttMethodCalc where ttMethodCalc.item eq comboBox1:SelectedItem:ToString() no-lock no-error.
        if available ttMethodCalc then
        do:
          Show_Panet_SelectConditonItem(ttMethodCalc.code ).
        end.
      END.
      else
      DO:
        find first ttMethodCalc where ttMethodCalc.item eq comboBox1:SelectedItem:ToString() no-lock no-error.
        if available ttMethodCalc then
        do:
          Show_Panet_SelectConditonItem(ttMethodCalc.code ).
        end.
      END.
    end.
    RETURN.
  END METHOD.
  @VisualDesigner.
  METHOD PRIVATE VOID comboBox1_SelectedIndexChanged( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
    if  changecomboBox1
      then
      Show_Panet_SelectConditonItem().
  end.
  METHOD public VOID Show_Panet_SelectConditonItem():
    if radioButton3:checked
      then
    do:
      init_first_value_combobox(3).
      Show_Panet_SelectConditonItem(61).
      m-promo-trg:ViewPage6(no).
    end.
    else
    do:
      find first ttMethodCalc where ttMethodCalc.item eq comboBox1:SelectedItem:ToString() no-lock no-error.
      if available ttMethodCalc
        then
      do:
        Init_comboBox3(if radioButton3:checked then 3 else if radioButton2:checked then 2 else 1,ttMethodCalc.code).
        Init_comboBox_nUMBER(0).
        if ttMethodCalc.code eq 7
          then
          m-promo-trg:ViewPage6(no).
        else
          m-promo-trg:ViewPage6(yes).
        case ttMethodCalc.code:
          when 1 then
            do: // "Скидка процентом"
              Show_Panet_SelectConditonItem(1).
              Init_comboBox_nUMBER(1).
            end .
          when 2 then
            do: // Абсолютная (скидка суммой от цены)
              Show_Panet_SelectConditonItem(2).
              Init_comboBox_nUMBER(2).
            end .
          when 3 then
            do: // Скидка количеством
              Show_Panet_SelectConditonItem(3).
              Init_comboBox_nUMBER(3).
            end .
          when 4 then
            do: //Скидка процентом за количество
              Show_Panet_SelectConditonItem(4).
              Init_comboBox_nUMBER(4).
            end .
          when 5 then
            do: // Фиксированная цена
              Show_Panet_SelectConditonItem(5).
              Init_comboBox_nUMBER(5).
            end .
          when 6 then
            do: // Выдача сообщения
              Show_Panet_SelectConditonItem(6).
              Init_comboBox_nUMBER(6).
            end .
          when 7 then
            do: // "Подарок"
              Show_Panet_SelectConditonItem(7).
                     //  tabControl1:TabPages:Remove(tabPage6).
            end .
        end case.
      end.
    end.
    RETURN.
  END METHOD.
  method public void cleanPanel():
    THIS-OBJECT:panel_SelectConditionItems:Controls:Clear().
    if valid-object(ucMain7)        then delete object ucMain7.
  end.
  METHOD PRIVATE VOID Show_Panet_SelectConditonItem( INPUT SelectItem AS int):
    cleanPanel().
    define variable vLoadForm as logical no-undo.
    assign
      label5:Visible    = FALSE
      checkBox1:Visible = label5:Visible
      .
    ucMain7 = NEW ibs.th.ref.promo.uc_SelectsGCP().
    case SelectItem:
      when 1 then
        do:
          IF radioButton1:Checked THEN
          DO:
            find first tttypeCond where tttypeCond.item eq comboBox3:SelectedItem:ToString() no-lock no-error.
            if available tttypeCond
              then
            do:
              if tttypeCond.code = 1 // "Количество по строке"
                then
              do:
                ucMain7:INIT_Panel(checkBox1:Checked, yes, yes, no).
                ucMain7:PublicEvent("CritLable", string(checkBox1:Checked) + "#Количество, ед#Диапазон действия,ед#Диапазон действия,ед#Скидка, %").
                assign
                  label5:Visible    = true
                  checkBox1:Visible = label5:Visible
                  .
                vLoadForm = yes.
              end.
              else IF tttypeCond.code = 2 // "Сумма по строке"
                  then
                do:
                  ucMain7:INIT_Panel(checkBox1:Checked, yes, yes, no).
                  ucMain7:PublicEvent("CritLable", string(checkBox1:checked) + "#Сумма, руб#Диапазон действия, руб#Диапазон действия, руб#Скидка, %").
                  assign
                    label5:Visible    = true
                    checkBox1:Visible = label5:Visible
                    .
                  vLoadForm = yes.
                end.
              IF tttypeCond.code = 3 // "Итог чека"
                then
              do:
                ucMain7:INIT_Panel(no, no, yes, no).
                ucMain7:PublicEvent("CritLable", "Сумма, руб#Диапазон действия, руб#Скидка, %").
                ucMain7:PublicEvent("swapCritAndDiscont", "").
                vLoadForm = yes.
              END.
              if tttypeCond.code = 4 // "Скидка по ШК"
                then
              do:
                ucMain7:INIT_BarCode(SelectItem).
                ucMain7:PublicEvent("CritOneLableCode", "Скидка, %").
                assign
                  label5:Visible    = false
                  checkBox1:Visible = false
                  .
                vLoadForm = yes.
              end.
            end.
          END.
          ELSE
          DO:
            ucMain7:INIT_PromoSet(SelectItem).
            ucMain7:PublicEvent("showDiscontForSet", "").
            ucMain7:PublicEvent("CritOneLable", "?").
            vLoadForm = yes.
          END.
        end .
      when 2 then
        do: // абсолютная
          find first tttypeCond where tttypeCond.item eq comboBox3:SelectedItem:ToString() no-lock no-error.
          if available tttypeCond
            then
          do:
            assign
              label5:Visible    = true
              checkBox1:Visible = label5:Visible
              .
            if tttypeCond.code = 1 // "Количество по строке"
              then
            do:
              ucMain7:INIT_Panel(checkBox1:Checked, yes, yes, no).
              ucMain7:PublicEvent("CritLable", string(checkBox1:checked) + "#Количество, ед#Диапазон действия,ед#Диапазон действия,ед#Скидка, руб").
              vLoadForm = yes.
            end.
            else if tttypeCond.code = 2 // "Сумма по строку"
                then
              do:
                ucMain7:INIT_Panel(checkBox1:Checked, yes, yes, no).
                ucMain7:PublicEvent("CritLable", string(checkBox1:checked) + "#Сумма, руб#Диапазон действия, руб#Диапазон действия, руб#Скидка, руб").
                vLoadForm = yes.
              end.
              else if tttypeCond.code = 4 // "Скидка по ШК"
              then
            do:
              assign
                label5:Visible    = false
                checkBox1:Visible = false
                .
              ucMain7:INIT_BarCode(SelectItem).
              ucMain7:PublicEvent("CritOneLableCode", "Скидка, абс").
              vLoadForm = yes.
            end.
          end.
        end .
      when 3 then
        do: // Скидка количеством
          ucMain7:INIT_Panel(no, yes, no, no, no,yes).
          ucMain7:PublicEvent("CritOneLable", "Бесплатно#из").
          ucMain7:PublicEvent("swapCritAndDiscont", "").
          vLoadForm = yes.
        end .
      when 4 then
        do: //Скидка процентом за количество
          ucMain7:INIT_Panel(no, yes, no, no, no, yes).
          ucMain7:PublicEvent("CritOneLable", "Каждый#со скидкой#%").
          vLoadForm = yes.
        end .
      when 5 then
        do: // Фиксированная цена
          IF radioButton1:Checked THEN
          DO:
            find first tttypeCond where tttypeCond.item eq comboBox3:SelectedItem:ToString() no-lock no-error.
            if available tttypeCond
              then
            do:
              if tttypeCond.code = 4 // "Скидка по ШК"
                then
              do:
                ucMain7:INIT_BarCode(SelectItem).
                ucMain7:PublicEvent("NotOneLable", "").
                assign
                  label5:Visible    = false
                  checkBox1:Visible = false
                  .
                vLoadForm = yes.
              end.
              if tttypeCond.code = 5 // "Скидка по картам лояльности"
                then
              do:
                ucMain7:INIT_GoodsFix(SelectItem).
                ucMain7:PublicEvent("NotOneLable", "").
                assign
                  label5:Visible    = false
                  checkBox1:Visible = false
                  .
                vLoadForm = yes.
              end.
            end .
            else do:
                ucMain7:INIT_GoodsFix(SelectItem).
                ucMain7:PublicEvent("NotOneLable", "").
                assign
                  label5:Visible    = false
                  checkBox1:Visible = false
                  .
                vLoadForm = yes.
            end.
          END.
          ELSE
          DO:
              ucMain7:INIT_PromoSet(SelectItem).
              ucMain7:PublicEvent("CritOneLable", "?#Цена, руб").
              vLoadForm = yes.
          end.
        END.
      when 6 then
        do:
          find first tttypeCond where tttypeCond.item eq comboBox3:SelectedItem:ToString() no-lock no-error.
          if available tttypeCond
            then
          do:
            if tttypeCond.code = 1 // "Количество по строке"
              then
            do:
              ucMain7:INIT_Panel(checkBox1:Checked, no, no, no,yes,yes).
              ucMain7:PublicEvent("CritOneLable", "Количество от, ед").
              assign
                label5:Visible    = true
                checkBox1:Visible = label5:Visible
                vLoadForm         = yes
                .
            end.
            else if    tttypeCond.code = 2 // "Сумма по строке"
                or tttypeCond.code = 3 // "Итог чека"
                then
              do :
                ucMain7:INIT_Panel(if tttypeCond.code = 3 then no else checkBox1:Checked, no, no, no,yes,yes).
                ucMain7:PublicEvent("CritOneLable", "Сумма от, руб").
                vLoadForm = yes.
                if    tttypeCond.code = 2 then
                  assign
                    label5:Visible    = true
                    checkBox1:Visible = label5:Visible
                    .
              end.
          end.
        end .
      when 7 then
        do:
          find first tttypeCond where tttypeCond.item eq comboBox3:SelectedItem:ToString() no-lock no-error.
          if available tttypeCond
            then
          do:
            if tttypeCond.code = 1 // "Количество по строке"
              then
            do:
              ucMain7:INIT_Panel(no, yes, yes, yes).
              ucMain7:PublicEvent("CritLable", "Количество, ед#Диапазон действия,ед#?").
              vLoadForm = yes.
            end.
            else if tttypeCond.code = 2 // "Сумма по строке"
                then
              do:
                ucMain7:INIT_Panel(no, yes, yes, yes).
                ucMain7:PublicEvent("CritLable", "Сумма, руб#Диапазон действия, Руб#?").
                vLoadForm = yes.
              end.
              else if tttypeCond.code = 3 // "Итог чека"
                  then
                do:
                  ucMain7:INIT_Panel(no, no, yes, yes).
                  ucMain7:PublicEvent("CritLable", "Сумма, руб#Диапазон действия, Руб#?").
                  vLoadForm = yes.
                end.
          end.
        end .
      when 61 then
        do:
          ucMain7:INIT_visa().
          ucMain7:PublicEvent("CritOneLable", "Сумма от, руб").
          ucMain7:PublicEvent("ViewGiftForAction", "").
          vLoadForm = yes.
        end.
    end case.
    if vLoadForm
      then
    do:
      ucMain7:SetPromoTrg(m-promo-trg).
      ucMain7:Dock = System.Windows.Forms.DockStyle:Fill.
      THIS-OBJECT:panel_SelectConditionItems:Controls:Add(ucMain7).
    end.
    else
      delete object ucMain7.
    RETURN.
  END METHOD.
  @VisualDesigner.
  METHOD PRIVATE VOID checkBox1_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
    if valid-object(ucMain7) then ucMain7:INIT_Panel(checkBox1:Checked).
    RETURN.
  END METHOD.
        @VisualDesigner.
        method private void tableLayoutPanel7_Paint( input sender as System.Object, input e as System.Windows.Forms.PaintEventArgs ):
                return.
        end method.
END CLASS.
