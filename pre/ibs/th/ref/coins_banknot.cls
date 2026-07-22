using Progress.Lang.*.
using Progress.Windows.UserControl.
block-level on error undo, throw.
class ibs.th.ref.Coins_Banknot inherits UserControl:
  define temp-table tt-coins no-undo XML-NODE-NAME "coins" serialize-name  "coins"
  field id       as decimal
  field qnty     as decimal
  field sum-qnty as decimal
  index pi is primary unique id desc.
define temp-table tt-banknots no-undo XML-NODE-NAME "banknots" serialize-name  "banknots"
  field id       as integer
  field qnty     as integer
  field sum-qnty as integer
  index pi is primary unique id desc.
define temp-table tt-cover-sheet no-undo
  field num-bag      as character
  field depos-code   as integer
  field depos-bank   as character
  field repos-code   as integer
  field repos-bank   as character
  field pin02        as character
  field source_      as character
  field total-sum    as decimal
  index pi num-bag
.
define dataset ds-banknots XML-NODE-NAME "money" serialize-name  "money" for tt-banknots,
  tt-coins .
define         variable hQueryCoins                           as handle                                         no-undo .
define         variable hQueryBanknot                         as handle                                         no-undo .
method private handle add_Coints():
   define variable v-list-coints as character no-undo .
   define variable ii            as integer   no-undo .
   v-list-coints = "10;5;2;1;0.5;0.1;0.05" .
    define variable ddd as decimal no-undo.
    do ii = 1 to num-entries (v-list-coints,";"):
      find first tt-coins where tt-coins.id       = decimal (entry(ii,v-list-coints,";"))
      no-error.
      if not available tt-coins
      then do:
         create tt-coins .
         assign
           tt-coins.id       = decimal(entry(ii,v-list-coints,";"))
           tt-coins.qnty     = 0
           tt-coins.sum-qnty = 0
           .
       end.
    end.
end.
method private handle getq_Coints():
if valid-handle(hQueryCoins)  then delete object hQueryCoins.
    create query hQueryCoins.
    hQueryCoins:set-buffers(buffer tt-coins:HANDLE).
    hQueryCoins:query-prepare("FOR EACH tt-coins by tt-coins.id desc").
    hQueryCoins:query-open.
    return hQueryCoins.
end.
method private handle add_Banknot():
   define variable v-list-banknot as character no-undo .
   define variable ii             as integer   no-undo .
   v-list-banknot = "5000;2000;1000;500;200;100;50;10" .
    do ii = 1 to num-entries (v-list-banknot,";"):
      find first tt-banknots where tt-banknots.id       = integer(entry(ii,v-list-banknot,";"))
      no-error.
      if not available tt-banknots
      then do:
         create tt-banknots .
         assign
           tt-banknots.id       = integer(entry(ii,v-list-banknot,";"))
           tt-banknots.qnty     = 0
           tt-banknots.sum-qnty = 0
           .
       end.
    end.
end.
method private handle getq_Banknot():
   if valid-handle(hQueryBanknot)  then delete object hQueryBanknot.
    create query hQueryBanknot.
    hQueryBanknot:set-buffers(buffer tt-banknots:HANDLE).
    hQueryBanknot:query-prepare("FOR EACH tt-banknots by tt-banknots.id desc").
    hQueryBanknot:query-open.
    return hQueryBanknot.
end.
  define private variable bindingSource_Coins               as Progress.Data.BindingSource                    no-undo.
  define private variable bindingSource_Bank                as Progress.Data.BindingSource                    no-undo.
  define private variable components                        as System.ComponentModel.IContainer               no-undo.
  define private variable dataGridView2                     as System.Windows.Forms.DataGridView              no-undo.
  define private variable dataGridView1                     as System.Windows.Forms.DataGridView              no-undo.
  define private variable label1 as System.Windows.Forms.Label no-undo.
  define public variable Fsumm as System.Windows.Forms.TextBox no-undo.
  define private variable sumqntyDataGridViewTextBoxColumn1 as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable sumqntyDataGridViewTextBoxColumn  as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable qntyDataGridViewTextBoxColumn1    as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable qntyDataGridViewTextBoxColumn     as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable idDataGridViewTextBoxColumn1      as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable idDataGridViewTextBoxColumn       as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define public variable v-total-sum                       as decimal                                        no-undo .
  constructor public Coins_Banknot (  ):
    super().
    InitializeComponent().
    bindingSource_Coins:Handle = browse_Coints().
    bindingSource_Bank:Handle = browse_Banknot().
    this-object:ComponentsCollection:ADD(this-object:components).
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.
  end constructor.
  @VisualDesigner.
  method private void dataGridView1_CellValueChanged( input sender as System.Object, input e as System.Windows.Forms.DataGridViewCellEventArgs ):
    define buffer buf_tt-banknots for tt-banknots.
    define variable vi as integer no-undo.
    bindingSource_Bank:Assign().
    if e:RowIndex >= 0
       and e:ColumnIndex eq 1
    then do:
       define variable msum1 as integer   no-undo.
       define variable msum2 as integer   no-undo.
       msum1 = dataGridView1:rows[e:RowIndex]:Cells[1]:Value.
       msum2 = dataGridView1:rows[e:RowIndex]:Cells[0]:Value.
       dataGridView1:rows[e:RowIndex]:Cells[2]:Value = msum1 * msum2.
       find first buf_tt-banknots where buf_tt-banknots.id eq msum2
       no-error.
       if not available buf_tt-banknots
       then do:
          create buf_tt-banknots.
          buf_tt-banknots.id = msum2.
       end.
       buf_tt-banknots.qnty = msum1.
       buf_tt-banknots.sum-qnty = msum1 * msum2.
        bindingSource_Bank:Assign().
    end.
    setItog().
    return.
  end method.
  @VisualDesigner.
  method private void dataGridView2_CellValueChanged( input sender as System.Object, input e as System.Windows.Forms.DataGridViewCellEventArgs ):
    define buffer tt-coins     for tt-coins.
    define buffer buf_tt-coins for tt-coins.
    define variable vi as integer no-undo.
    bindingSource_Coins:Assign().
    if e:RowIndex >= 0
       and e:ColumnIndex eq 1
    then do:
       define variable msum1 as decimal  no-undo.
       define variable msum2 as decimal  no-undo.
       msum1 = dataGridView2:rows[e:RowIndex]:Cells[1]:Value.
       msum2 = dataGridView2:rows[e:RowIndex]:Cells[0]:Value.
       dataGridView2:rows[e:RowIndex]:Cells[2]:Value = msum1 * msum2.
       find first  buf_tt-coins where  buf_tt-coins.id eq msum2
       no-error.
       if not available  buf_tt-coins
       then do:
          create  buf_tt-coins.
          buf_tt-coins.id = msum2.
       end.
        buf_tt-coins.qnty = msum1.
        buf_tt-coins.sum-qnty = msum1 * msum2.
        bindingSource_Coins:Assign().
    end.
    setItog().
    return.
  end method.
  method private void InitializeComponent(  ):
    this-object:components = new System.ComponentModel.Container().
    @VisualDesigner.FormMember (NeedsInitialize="true").
    define variable dataGridViewCellStyle1 as System.Windows.Forms.DataGridViewCellStyle no-undo.
    dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle().
    @VisualDesigner.FormMember (NeedsInitialize="true").
    define variable dataGridViewCellStyle2 as System.Windows.Forms.DataGridViewCellStyle no-undo.
    dataGridViewCellStyle2 = new System.Windows.Forms.DataGridViewCellStyle().
    @VisualDesigner.FormMember (NeedsInitialize="true").
    define variable dataGridViewCellStyle3 as System.Windows.Forms.DataGridViewCellStyle no-undo.
    dataGridViewCellStyle3 = new System.Windows.Forms.DataGridViewCellStyle().
    @VisualDesigner.FormMember (NeedsInitialize="true").
    define variable dataGridViewCellStyle4 as System.Windows.Forms.DataGridViewCellStyle no-undo.
    dataGridViewCellStyle4 = new System.Windows.Forms.DataGridViewCellStyle().
    @VisualDesigner.FormMember (NeedsInitialize="true").
    define variable tableDesc1 as Progress.Data.TableDesc no-undo.
    tableDesc1 = new Progress.Data.TableDesc("tt-banknots").
    @VisualDesigner.FormMember (NeedsInitialize="true").
    define variable dataGridViewCellStyle5 as System.Windows.Forms.DataGridViewCellStyle no-undo.
    dataGridViewCellStyle5 = new System.Windows.Forms.DataGridViewCellStyle().
    @VisualDesigner.FormMember (NeedsInitialize="true").
    define variable dataGridViewCellStyle6 as System.Windows.Forms.DataGridViewCellStyle no-undo.
    dataGridViewCellStyle6 = new System.Windows.Forms.DataGridViewCellStyle().
    @VisualDesigner.FormMember (NeedsInitialize="true").
    define variable dataGridViewCellStyle7 as System.Windows.Forms.DataGridViewCellStyle no-undo.
    dataGridViewCellStyle7 = new System.Windows.Forms.DataGridViewCellStyle().
    @VisualDesigner.FormMember (NeedsInitialize="true").
    define variable dataGridViewCellStyle8 as System.Windows.Forms.DataGridViewCellStyle no-undo.
    dataGridViewCellStyle8 = new System.Windows.Forms.DataGridViewCellStyle().
    @VisualDesigner.FormMember (NeedsInitialize="true").
    define variable tableDesc2 as Progress.Data.TableDesc no-undo.
    tableDesc2 = new Progress.Data.TableDesc("tt-coins").
    this-object:dataGridView1 = new System.Windows.Forms.DataGridView().
    this-object:idDataGridViewTextBoxColumn1 = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:qntyDataGridViewTextBoxColumn1 = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:sumqntyDataGridViewTextBoxColumn1 = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:bindingSource_Bank = new Progress.Data.BindingSource(this-object:components).
    this-object:dataGridView2 = new System.Windows.Forms.DataGridView().
    this-object:idDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:qntyDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:sumqntyDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:bindingSource_Coins = new Progress.Data.BindingSource(this-object:components).
    this-object:Fsumm = new System.Windows.Forms.TextBox().
    this-object:label1 = new System.Windows.Forms.Label().
    cast(this-object:dataGridView1, System.ComponentModel.ISupportInitialize):BeginInit().
    cast(this-object:bindingSource_Bank, System.ComponentModel.ISupportInitialize):BeginInit().
    cast(this-object:dataGridView2, System.ComponentModel.ISupportInitialize):BeginInit().
    cast(this-object:bindingSource_Coins, System.ComponentModel.ISupportInitialize):BeginInit().
    this-object:SuspendLayout().
    this-object:dataGridView1:AllowUserToAddRows = false.
    this-object:dataGridView1:AllowUserToDeleteRows = false.
    this-object:dataGridView1:AutoGenerateColumns = false.
    this-object:dataGridView1:BackgroundColor = System.Drawing.SystemColors:ButtonFace.
    dataGridViewCellStyle1:Alignment = System.Windows.Forms.DataGridViewContentAlignment:TopCenter.
    dataGridViewCellStyle1:BackColor = System.Drawing.SystemColors:ControlDark.
    dataGridViewCellStyle1:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(8.25), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    dataGridViewCellStyle1:ForeColor = System.Drawing.SystemColors:WindowText.
    dataGridViewCellStyle1:SelectionBackColor = System.Drawing.SystemColors:HighlightText.
    dataGridViewCellStyle1:SelectionForeColor = System.Drawing.SystemColors:HighlightText.
    dataGridViewCellStyle1:WrapMode = System.Windows.Forms.DataGridViewTriState:True.
    this-object:dataGridView1:ColumnHeadersDefaultCellStyle = dataGridViewCellStyle1.
    this-object:dataGridView1:ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode:AutoSize.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar0 as System.Windows.Forms.DataGridViewColumn extent 3 no-undo.
    arrayvar0[1] = this-object:idDataGridViewTextBoxColumn1.
    arrayvar0[2] = this-object:qntyDataGridViewTextBoxColumn1.
    arrayvar0[3] = this-object:sumqntyDataGridViewTextBoxColumn1.
    this-object:dataGridView1:Columns:AddRange(arrayvar0).
    this-object:dataGridView1:DataSource = this-object:bindingSource_Bank.
    this-object:dataGridView1:Location = new System.Drawing.Point(12, 13).
    this-object:dataGridView1:Name = "dataGridView1".
    this-object:dataGridView1:RowHeadersVisible = false.
    this-object:dataGridView1:RowTemplate:Height = 26.
    this-object:dataGridView1:Size = new System.Drawing.Size(300, 231).
    this-object:dataGridView1:TabIndex = 0.
    this-object:dataGridView1:CellValueChanged:Subscribe(this-object:dataGridView1_CellValueChanged).
    this-object:idDataGridViewTextBoxColumn1:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:None.
    this-object:idDataGridViewTextBoxColumn1:DataPropertyName = "id".
    dataGridViewCellStyle2:Alignment = System.Windows.Forms.DataGridViewContentAlignment:MiddleCenter.
    dataGridViewCellStyle2:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(8.25), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:idDataGridViewTextBoxColumn1:DefaultCellStyle = dataGridViewCellStyle2.
    this-object:idDataGridViewTextBoxColumn1:Frozen = true.
    this-object:idDataGridViewTextBoxColumn1:HeaderText = "Банкноты".
    this-object:idDataGridViewTextBoxColumn1:Name = "idDataGridViewTextBoxColumn1".
    this-object:idDataGridViewTextBoxColumn1:ReadOnly = true.
    this-object:idDataGridViewTextBoxColumn1:Width = 99.
    this-object:qntyDataGridViewTextBoxColumn1:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:None.
    this-object:qntyDataGridViewTextBoxColumn1:DataPropertyName = "qnty".
    dataGridViewCellStyle3:Alignment = System.Windows.Forms.DataGridViewContentAlignment:MiddleCenter.
    this-object:qntyDataGridViewTextBoxColumn1:DefaultCellStyle = dataGridViewCellStyle3.
    this-object:qntyDataGridViewTextBoxColumn1:HeaderText = "Кол-во".
    this-object:qntyDataGridViewTextBoxColumn1:Name = "qntyDataGridViewTextBoxColumn1".
    this-object:qntyDataGridViewTextBoxColumn1:Resizable = System.Windows.Forms.DataGridViewTriState:False.
    this-object:qntyDataGridViewTextBoxColumn1:Width = 99.
    this-object:sumqntyDataGridViewTextBoxColumn1:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:Fill.
    this-object:sumqntyDataGridViewTextBoxColumn1:DataPropertyName = "sum-qnty".
    dataGridViewCellStyle4:Alignment = System.Windows.Forms.DataGridViewContentAlignment:MiddleCenter.
    this-object:sumqntyDataGridViewTextBoxColumn1:DefaultCellStyle = dataGridViewCellStyle4.
    this-object:sumqntyDataGridViewTextBoxColumn1:HeaderText = "Сумма".
    this-object:sumqntyDataGridViewTextBoxColumn1:Name = "sumqntyDataGridViewTextBoxColumn1".
    this-object:sumqntyDataGridViewTextBoxColumn1:ReadOnly = true.
    this-object:bindingSource_Bank:AutoUpdate = true.
    this-object:bindingSource_Bank:MaxDataGuess = 0.
    this-object:bindingSource_Bank:NoLOBs = false.
    this-object:bindingSource_Bank:Position = 0.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar1 as "Progress.Data.TableDesc[]" no-undo.
    arrayvar1 = new "Progress.Data.TableDesc[]"(0).
    tableDesc1:ChildTables = arrayvar1.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar2 as Progress.Data.ColumnPropDesc extent 3 no-undo.
    arrayvar2[1] = new Progress.Data.ColumnPropDesc("id", "", Progress.Data.DataType:INTEGER).
    arrayvar2[2] = new Progress.Data.ColumnPropDesc("qnty", "", Progress.Data.DataType:INTEGER).
    arrayvar2[3] = new Progress.Data.ColumnPropDesc("sum-qnty", "", Progress.Data.DataType:INTEGER).
    tableDesc1:Columns = arrayvar2.
    this-object:bindingSource_Bank:TableSchema = tableDesc1.
    this-object:dataGridView2:AllowUserToAddRows = false.
    this-object:dataGridView2:AllowUserToDeleteRows = false.
    this-object:dataGridView2:AutoGenerateColumns = false.
    this-object:dataGridView2:BackgroundColor = System.Drawing.SystemColors:ButtonFace.
    dataGridViewCellStyle5:Alignment = System.Windows.Forms.DataGridViewContentAlignment:TopCenter.
    dataGridViewCellStyle5:BackColor = System.Drawing.SystemColors:ControlDark.
    dataGridViewCellStyle5:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(8.25), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    dataGridViewCellStyle5:ForeColor = System.Drawing.SystemColors:WindowText.
    dataGridViewCellStyle5:SelectionBackColor = System.Drawing.SystemColors:HighlightText.
    dataGridViewCellStyle5:SelectionForeColor = System.Drawing.SystemColors:HighlightText.
    dataGridViewCellStyle5:WrapMode = System.Windows.Forms.DataGridViewTriState:True.
    this-object:dataGridView2:ColumnHeadersDefaultCellStyle = dataGridViewCellStyle5.
    this-object:dataGridView2:ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode:AutoSize.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar3 as System.Windows.Forms.DataGridViewColumn extent 3 no-undo.
    arrayvar3[1] = this-object:idDataGridViewTextBoxColumn.
    arrayvar3[2] = this-object:qntyDataGridViewTextBoxColumn.
    arrayvar3[3] = this-object:sumqntyDataGridViewTextBoxColumn.
    this-object:dataGridView2:Columns:AddRange(arrayvar3).
    this-object:dataGridView2:DataSource = this-object:bindingSource_Coins.
    this-object:dataGridView2:Location = new System.Drawing.Point(359, 12).
    this-object:dataGridView2:Name = "dataGridView2".
    this-object:dataGridView2:RowHeadersVisible = false.
    this-object:dataGridView2:RowTemplate:Height = 30.
    this-object:dataGridView2:Size = new System.Drawing.Size(300, 233).
    this-object:dataGridView2:TabIndex = 1.
    this-object:dataGridView2:CellValueChanged:Subscribe(this-object:dataGridView2_CellValueChanged).
    this-object:idDataGridViewTextBoxColumn:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:None.
    this-object:idDataGridViewTextBoxColumn:DataPropertyName = "id".
    dataGridViewCellStyle6:Alignment = System.Windows.Forms.DataGridViewContentAlignment:MiddleCenter.
    dataGridViewCellStyle6:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(8.25), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:idDataGridViewTextBoxColumn:DefaultCellStyle = dataGridViewCellStyle6.
    this-object:idDataGridViewTextBoxColumn:HeaderText = "Монеты".
    this-object:idDataGridViewTextBoxColumn:Name = "idDataGridViewTextBoxColumn".
    this-object:idDataGridViewTextBoxColumn:ReadOnly = true.
    this-object:idDataGridViewTextBoxColumn:Width = 97.
    this-object:qntyDataGridViewTextBoxColumn:DataPropertyName = "qnty".
    dataGridViewCellStyle7:Alignment = System.Windows.Forms.DataGridViewContentAlignment:MiddleCenter.
    this-object:qntyDataGridViewTextBoxColumn:DefaultCellStyle = dataGridViewCellStyle7.
    this-object:qntyDataGridViewTextBoxColumn:HeaderText = "Кол-во".
    this-object:qntyDataGridViewTextBoxColumn:Name = "qntyDataGridViewTextBoxColumn".
    this-object:sumqntyDataGridViewTextBoxColumn:DataPropertyName = "sum-qnty".
    dataGridViewCellStyle8:Alignment = System.Windows.Forms.DataGridViewContentAlignment:MiddleCenter.
    this-object:sumqntyDataGridViewTextBoxColumn:DefaultCellStyle = dataGridViewCellStyle8.
    this-object:sumqntyDataGridViewTextBoxColumn:HeaderText = "Сумма".
    this-object:sumqntyDataGridViewTextBoxColumn:Name = "sumqntyDataGridViewTextBoxColumn".
    this-object:sumqntyDataGridViewTextBoxColumn:ReadOnly = true.
    this-object:bindingSource_Coins:AutoUpdate = true.
    this-object:bindingSource_Coins:MaxDataGuess = 0.
    this-object:bindingSource_Coins:NoLOBs = false.
    this-object:bindingSource_Coins:Position = 0.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar4 as "Progress.Data.TableDesc[]" no-undo.
    arrayvar4 = new "Progress.Data.TableDesc[]"(0).
    tableDesc2:ChildTables = arrayvar4.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar5 as Progress.Data.ColumnPropDesc extent 3 no-undo.
    arrayvar5[1] = new Progress.Data.ColumnPropDesc("id", "", Progress.Data.DataType:DECIMAL).
    arrayvar5[2] = new Progress.Data.ColumnPropDesc("qnty", "", Progress.Data.DataType:DECIMAL).
    arrayvar5[3] = new Progress.Data.ColumnPropDesc("sum-qnty", "", Progress.Data.DataType:DECIMAL).
    tableDesc2:Columns = arrayvar5.
    this-object:bindingSource_Coins:TableSchema = tableDesc2.
    this-object:Fsumm:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.25), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:Fsumm:Location = new System.Drawing.Point(516, 250).
    this-object:Fsumm:Name = "Fsumm".
    this-object:Fsumm:Size = new System.Drawing.Size(143, 21).
    this-object:Fsumm:TabIndex = 2.
    this-object:label1:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.25), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:label1:Location = new System.Drawing.Point(453, 251).
    this-object:label1:Name = "label1".
    this-object:label1:Size = new System.Drawing.Size(57, 23).
    this-object:label1:TabIndex = 3.
    this-object:label1:Text = "Итого:".
    this-object:label1:UseCompatibleTextRendering = true.
    this-object:AutoScaleDimensions = new System.Drawing.SizeF(Progress.Util.CastUtil:ToSingle(6), Progress.Util.CastUtil:ToSingle(13)).
    this-object:Controls:Add(this-object:label1).
    this-object:Controls:Add(this-object:Fsumm).
    this-object:Controls:Add(this-object:dataGridView2).
    this-object:Controls:Add(this-object:dataGridView1).
    this-object:Name = "Coins_Banknot".
    this-object:Size = new System.Drawing.Size(668, 292).
    cast(this-object:dataGridView1, System.ComponentModel.ISupportInitialize):EndInit().
    cast(this-object:bindingSource_Bank, System.ComponentModel.ISupportInitialize):EndInit().
    cast(this-object:dataGridView2, System.ComponentModel.ISupportInitialize):EndInit().
    cast(this-object:bindingSource_Coins, System.ComponentModel.ISupportInitialize):EndInit().
    this-object:ResumeLayout(false).
    this-object:PerformLayout().
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.
  end method.
  method public void Update_Banknots (input table1 as handle):
    define variable vB as handle no-undo.
    define buffer tt-banknots for tt-banknots.
    vB = table1:get-buffer-handle (1).
    table1:get-first( ).
    do while table1:query-off-end <> true:
       find first tt-banknots where tt-banknots.id       = vB::id
       no-error.
       if not available tt-banknots
       then
          create tt-banknots.
       assign
          tt-banknots.id       = vB::id
          tt-banknots.qnty     = vB::qnty
          tt-banknots.sum-qnty = vB::sum-qnty.
       table1:get-next( ).
    end.
    setItog().
    bindingSource_Bank:Handle = table1 .
  end.
  method public void Update_coints (input table2 as handle):
     define variable vB as handle no-undo.
     define buffer tt-coins for tt-coins.
     vB = table2:get-buffer-handle (1).
    do while table2:query-off-end <> true:
       find first tt-coins where tt-coins.id       = vB::id
       no-error.
       if not available tt-coins
       then
          create tt-coins.
       assign
          tt-coins.id       = vB::id
          tt-coins.qnty     = vB::qnty
          tt-coins.sum-qnty = vB::sum-qnty.
       table2:get-next(  ).
    end.
    setItog().
    bindingSource_Coins:Handle = table2 .
  end.
  method private handle browse_Coints():
    add_Coints().
    return getq_Coints() .
  end method .
  method private handle browse_Banknot():
    add_Banknot().
    return getq_Banknot().
  end method .
  method private void setItog():
     define buffer tt-coins     for tt-coins.
     define buffer tt-banknots  for tt-banknots.
     define variable vSumm as decimal no-undo.
     for each tt-coins:
        VSumm = vSumm + tt-coins.sum-qnty.
     end.
     for each tt-banknots :
        VSumm = vSumm + tt-banknots .sum-qnty.
     end.
     Fsumm:text = string(VSumm,">>>>>>>>>9.99").
     v-total-sum = vSumm .
  end.
  method private void ChekItog():
  end.
  destructor public Coins_Banknot ( ):
  end destructor.
end class.
