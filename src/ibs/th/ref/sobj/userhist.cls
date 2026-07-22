 
 /*------------------------------------------------------------------------
    File        : userhist
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : svvtm
    Created     : Fri Nov 15 11:46:29 MSK 2024
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING ibs.th.ref.sobj.*.
USING ibs.th.ref.sobj.sUserFrame.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ibs.th.ref.sobj.userhist INHERITS sUserFrame: 
    
    DEFINE PRIVATE VARIABLE bindingSource1 AS Progress.Data.BindingSource NO-UNDO.
    DEFINE PRIVATE VARIABLE button1 AS System.Windows.Forms.Button NO-UNDO.
    DEFINE PRIVATE VARIABLE button2 AS System.Windows.Forms.Button NO-UNDO.
    DEFINE PRIVATE VARIABLE components AS System.ComponentModel.IContainer NO-UNDO.
    DEFINE PRIVATE VARIABLE dataGridView1 AS System.Windows.Forms.DataGridView NO-UNDO.
    DEFINE PRIVATE VARIABLE dataGridView150 AS System.Windows.Forms.DataGridView NO-UNDO.
    DEFINE PRIVATE VARIABLE dataGridViewCheckBoxColumn1 AS System.Windows.Forms.DataGridViewCheckBoxColumn NO-UNDO.
    DEFINE PRIVATE VARIABLE flg AS System.Windows.Forms.DataGridViewCheckBoxColumn NO-UNDO.
    DEFINE PRIVATE VARIABLE label1 AS System.Windows.Forms.Label NO-UNDO.
    DEFINE PRIVATE VARIABLE label2 AS System.Windows.Forms.Label NO-UNDO.
    DEFINE PRIVATE VARIABLE nameDataGridViewTextBoxColumn AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.
    DEFINE PRIVATE VARIABLE splitContainer1 AS System.Windows.Forms.SplitContainer NO-UNDO.
    DEFINE PRIVATE VARIABLE users AS Progress.Data.BindingSource NO-UNDO.
    DEFINE PRIVATE VARIABLE usernameDataGridViewTextBoxColumn AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.
    DEFINE PRIVATE VARIABLE useridDataGridViewTextBoxColumn AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.
    DEFINE PRIVATE VARIABLE dbnumDataGridViewTextBoxColumn AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.
    DEFINE         VARIABLE usertableObj AS CLASS ibs.th.ref.sobj.usertable no-undo.  
    DEFINE         VARIABLE mparamObj AS CLASS ibs.th.ref.sobj.sParamObj no-undo.
    DEFINE PRIVATE VARIABLE srt as logical. 
    DEFINE         VARIABLE str2 as logical.
      
    CONSTRUCTOR PUBLIC userhist (  ):
        
    SUPER().
    InitializeComponent().
    
    usertableObj = new usertable (THIS-OBJECT).
    users:Handle = usertableObj:query_user-account.
    bindingSource1:Handle = usertableObj:query_user-table.         
    srt = yes.    
        
        CATCH e AS Progress.Lang.Error:
            UNDO, THROW e.
        END CATCH.
 
    END CONSTRUCTOR.


	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	METHOD PRIVATE VOID button1_Click_1( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
    usertableObj:mark_user_all().
    users:RefreshALL().        
		RETURN.
	END METHOD.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	METHOD PRIVATE VOID button2_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
		usertableObj:mark_table_all() . 
        bindingSource1:RefreshAll().
		RETURN.
	END METHOD.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	METHOD PRIVATE VOID dataGridView1_CellContentClick( INPUT sender AS System.Object, INPUT e AS System.Windows.Forms.DataGridViewCellEventArgs ):
	usertableObj:mark_user().
	users:Refresh().
		RETURN.
	END METHOD.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	METHOD PRIVATE VOID dataGridView1_ColumnHeaderMouseClick( INPUT sender AS System.Object, INPUT e AS System.Windows.Forms.DataGridViewCellMouseEventArgs ):
    /* переключение сортировки пользователей */
	srt =  not srt. 
	if srt then      usertableObj:query_user-account:query-prepare("FOR EACH tt-user-account BY tt-user-account.user_name ").
	if not srt then  usertableObj:query_user-account:query-prepare("FOR EACH tt-user-account BY tt-user-account.user-id_ ").
    users:handle:query-open. 
    users:RefreshAll() .
      	
	RETURN.

	END METHOD.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	METHOD PRIVATE VOID dataGridView2_CellContentClick( INPUT sender AS System.Object, INPUT e AS System.Windows.Forms.DataGridViewCellEventArgs ):
    usertableObj:mark_table() . 
    bindingSource1:Refresh().		
		RETURN.

	END METHOD.

    METHOD PRIVATE VOID InitializeComponent(  ):
        
        /* NOTE: The following method is automatically generated.
        
        We strongly suggest that the contents of this method only be modified using the
        Visual Designer to avoid any incompatible modifications.
        
        Modifying the contents of this method using a code editor will invalidate any support for this file. */
        THIS-OBJECT:components = NEW System.ComponentModel.Container().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        DEFINE VARIABLE dataGridViewCellStyle1 AS System.Windows.Forms.DataGridViewCellStyle NO-UNDO.
        dataGridViewCellStyle1 = NEW System.Windows.Forms.DataGridViewCellStyle().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        DEFINE VARIABLE dataGridViewCellStyle2 AS System.Windows.Forms.DataGridViewCellStyle NO-UNDO.
        dataGridViewCellStyle2 = NEW System.Windows.Forms.DataGridViewCellStyle().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        DEFINE VARIABLE dataGridViewCellStyle3 AS System.Windows.Forms.DataGridViewCellStyle NO-UNDO.
        dataGridViewCellStyle3 = NEW System.Windows.Forms.DataGridViewCellStyle().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        DEFINE VARIABLE tableDesc1 AS Progress.Data.TableDesc NO-UNDO.
        tableDesc1 = NEW Progress.Data.TableDesc("tt-user-account").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        DEFINE VARIABLE tableDesc2 AS Progress.Data.TableDesc NO-UNDO.
        tableDesc2 = NEW Progress.Data.TableDesc("tt-objects").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        DEFINE VARIABLE dataGridViewCellStyle4 AS System.Windows.Forms.DataGridViewCellStyle NO-UNDO.
        dataGridViewCellStyle4 = NEW System.Windows.Forms.DataGridViewCellStyle().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        DEFINE VARIABLE dataGridViewCellStyle5 AS System.Windows.Forms.DataGridViewCellStyle NO-UNDO.
        dataGridViewCellStyle5 = NEW System.Windows.Forms.DataGridViewCellStyle().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        DEFINE VARIABLE dataGridViewCellStyle6 AS System.Windows.Forms.DataGridViewCellStyle NO-UNDO.
        dataGridViewCellStyle6 = NEW System.Windows.Forms.DataGridViewCellStyle().
        THIS-OBJECT:dataGridView1 = NEW System.Windows.Forms.DataGridView().
        THIS-OBJECT:flg = NEW System.Windows.Forms.DataGridViewCheckBoxColumn().
        THIS-OBJECT:useridDataGridViewTextBoxColumn = NEW System.Windows.Forms.DataGridViewTextBoxColumn().
        THIS-OBJECT:usernameDataGridViewTextBoxColumn = NEW System.Windows.Forms.DataGridViewTextBoxColumn().
        THIS-OBJECT:dbnumDataGridViewTextBoxColumn = NEW System.Windows.Forms.DataGridViewTextBoxColumn().
        THIS-OBJECT:users = NEW Progress.Data.BindingSource(THIS-OBJECT:components).
        THIS-OBJECT:bindingSource1 = NEW Progress.Data.BindingSource(THIS-OBJECT:components).
        THIS-OBJECT:dataGridView150 = NEW System.Windows.Forms.DataGridView().
        THIS-OBJECT:dataGridViewCheckBoxColumn1 = NEW System.Windows.Forms.DataGridViewCheckBoxColumn().
        THIS-OBJECT:nameDataGridViewTextBoxColumn = NEW System.Windows.Forms.DataGridViewTextBoxColumn().
        THIS-OBJECT:splitContainer1 = NEW System.Windows.Forms.SplitContainer().
        THIS-OBJECT:button1 = NEW System.Windows.Forms.Button().
        THIS-OBJECT:label1 = NEW System.Windows.Forms.Label().
        THIS-OBJECT:button2 = NEW System.Windows.Forms.Button().
        THIS-OBJECT:label2 = NEW System.Windows.Forms.Label().
        CAST(THIS-OBJECT:dataGridView1, System.ComponentModel.ISupportInitialize):BeginInit().
        CAST(THIS-OBJECT:users, System.ComponentModel.ISupportInitialize):BeginInit().
        CAST(THIS-OBJECT:bindingSource1, System.ComponentModel.ISupportInitialize):BeginInit().
        CAST(THIS-OBJECT:dataGridView150, System.ComponentModel.ISupportInitialize):BeginInit().
        CAST(THIS-OBJECT:splitContainer1, System.ComponentModel.ISupportInitialize):BeginInit().
        THIS-OBJECT:splitContainer1:Panel1:SuspendLayout().
        THIS-OBJECT:splitContainer1:Panel2:SuspendLayout().
        THIS-OBJECT:splitContainer1:SuspendLayout().
        THIS-OBJECT:SuspendLayout().
        /*  */
        /* dataGridView1 */
        /*  */
        THIS-OBJECT:dataGridView1:AccessibleDescription = "".
        THIS-OBJECT:dataGridView1:AccessibleName = "".
        THIS-OBJECT:dataGridView1:AllowUserToAddRows = FALSE.
        THIS-OBJECT:dataGridView1:AllowUserToDeleteRows = FALSE.
        DEFINE VARIABLE nestedvar0 AS System.Windows.Forms.AnchorStyles NO-UNDO.
        nestedvar0 = CAST(Progress.Util.EnumHelper:Or(CAST(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Bottom), System.Windows.Forms.AnchorStyles), System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
        THIS-OBJECT:dataGridView1:Anchor = CAST(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
        THIS-OBJECT:dataGridView1:AutoGenerateColumns = FALSE.
        dataGridViewCellStyle1:Alignment = System.Windows.Forms.DataGridViewContentAlignment:MiddleLeft.
        dataGridViewCellStyle1:BackColor = System.Drawing.SystemColors:Control.
        dataGridViewCellStyle1:Font = NEW System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(8.25), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
        dataGridViewCellStyle1:ForeColor = System.Drawing.SystemColors:WindowText.
        dataGridViewCellStyle1:SelectionBackColor = System.Drawing.SystemColors:Highlight.
        dataGridViewCellStyle1:SelectionForeColor = System.Drawing.SystemColors:HighlightText.
        dataGridViewCellStyle1:WrapMode = System.Windows.Forms.DataGridViewTriState:True.
        THIS-OBJECT:dataGridView1:ColumnHeadersDefaultCellStyle = dataGridViewCellStyle1.
        THIS-OBJECT:dataGridView1:ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode:AutoSize.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        DEFINE VARIABLE arrayvar0 AS System.Windows.Forms.DataGridViewColumn EXTENT 4 NO-UNDO.
        arrayvar0[1] = THIS-OBJECT:flg.
        arrayvar0[2] = THIS-OBJECT:useridDataGridViewTextBoxColumn.
        arrayvar0[3] = THIS-OBJECT:usernameDataGridViewTextBoxColumn.
        arrayvar0[4] = THIS-OBJECT:dbnumDataGridViewTextBoxColumn.
        THIS-OBJECT:dataGridView1:Columns:AddRange(arrayvar0).
        THIS-OBJECT:dataGridView1:DataSource = THIS-OBJECT:users.
        dataGridViewCellStyle2:Alignment = System.Windows.Forms.DataGridViewContentAlignment:MiddleLeft.
        dataGridViewCellStyle2:BackColor = System.Drawing.SystemColors:Window.
        dataGridViewCellStyle2:Font = NEW System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(8.25), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
        dataGridViewCellStyle2:ForeColor = System.Drawing.SystemColors:ControlText.
        dataGridViewCellStyle2:SelectionBackColor = System.Drawing.SystemColors:Highlight.
        dataGridViewCellStyle2:SelectionForeColor = System.Drawing.SystemColors:HighlightText.
        dataGridViewCellStyle2:WrapMode = System.Windows.Forms.DataGridViewTriState:False.
        THIS-OBJECT:dataGridView1:DefaultCellStyle = dataGridViewCellStyle2.
        THIS-OBJECT:dataGridView1:Location = NEW System.Drawing.Point(3, 32).
        THIS-OBJECT:dataGridView1:Name = "dataGridView1".
        THIS-OBJECT:dataGridView1:ReadOnly = TRUE.
        dataGridViewCellStyle3:Alignment = System.Windows.Forms.DataGridViewContentAlignment:MiddleLeft.
        dataGridViewCellStyle3:BackColor = System.Drawing.SystemColors:Control.
        dataGridViewCellStyle3:Font = NEW System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(8.25), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
        dataGridViewCellStyle3:ForeColor = System.Drawing.SystemColors:WindowText.
        dataGridViewCellStyle3:SelectionBackColor = System.Drawing.SystemColors:Highlight.
        dataGridViewCellStyle3:SelectionForeColor = System.Drawing.SystemColors:HighlightText.
        dataGridViewCellStyle3:WrapMode = System.Windows.Forms.DataGridViewTriState:True.
        THIS-OBJECT:dataGridView1:RowHeadersDefaultCellStyle = dataGridViewCellStyle3.
        THIS-OBJECT:dataGridView1:RowHeadersVisible = FALSE.
        THIS-OBJECT:dataGridView1:Size = NEW System.Drawing.Size(1088, 279).
        THIS-OBJECT:dataGridView1:TabIndex = 0.
        THIS-OBJECT:dataGridView1:CellContentClick:Subscribe(THIS-OBJECT:dataGridView1_CellContentClick).
        THIS-OBJECT:dataGridView1:ColumnHeaderMouseClick:Subscribe(THIS-OBJECT:dataGridView1_ColumnHeaderMouseClick).
        /*  */
        /* flg */
        /*  */
        THIS-OBJECT:flg:DataPropertyName = "flg".
        THIS-OBJECT:flg:HeaderText = "".
        THIS-OBJECT:flg:Name = "flg".
        THIS-OBJECT:flg:ReadOnly = TRUE.
        THIS-OBJECT:flg:Width = 50.
        /*  */
        /* useridDataGridViewTextBoxColumn */
        /*  */
        THIS-OBJECT:useridDataGridViewTextBoxColumn:DataPropertyName = "user-id_".
        THIS-OBJECT:useridDataGridViewTextBoxColumn:HeaderText = " ID".
        THIS-OBJECT:useridDataGridViewTextBoxColumn:Name = "useridDataGridViewTextBoxColumn".
        THIS-OBJECT:useridDataGridViewTextBoxColumn:ReadOnly = TRUE.
        THIS-OBJECT:useridDataGridViewTextBoxColumn:Width = 60.
        /*  */
        /* usernameDataGridViewTextBoxColumn */
        /*  */
        THIS-OBJECT:usernameDataGridViewTextBoxColumn:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:Fill.
        THIS-OBJECT:usernameDataGridViewTextBoxColumn:DataPropertyName = "user_name".
        THIS-OBJECT:usernameDataGridViewTextBoxColumn:FillWeight = Progress.Util.CastUtil:ToSingle(200).
        THIS-OBJECT:usernameDataGridViewTextBoxColumn:HeaderText = " Имя пользователя".
        THIS-OBJECT:usernameDataGridViewTextBoxColumn:Name = "usernameDataGridViewTextBoxColumn".
        THIS-OBJECT:usernameDataGridViewTextBoxColumn:ReadOnly = TRUE.
        /*  */
        /* dbnumDataGridViewTextBoxColumn */
        /*  */
        THIS-OBJECT:dbnumDataGridViewTextBoxColumn:DataPropertyName = "db-num".
        THIS-OBJECT:dbnumDataGridViewTextBoxColumn:HeaderText = " БД ".
        THIS-OBJECT:dbnumDataGridViewTextBoxColumn:Name = "dbnumDataGridViewTextBoxColumn".
        THIS-OBJECT:dbnumDataGridViewTextBoxColumn:ReadOnly = TRUE.
        THIS-OBJECT:dbnumDataGridViewTextBoxColumn:Width = 80.
        /*  */
        /* users */
        /*  */
        THIS-OBJECT:users:MaxDataGuess = 0.
        THIS-OBJECT:users:NoLOBs = FALSE.
        THIS-OBJECT:users:Position = 0.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        DEFINE VARIABLE arrayvar1 AS "Progress.Data.TableDesc[]" NO-UNDO.
        arrayvar1 = NEW "Progress.Data.TableDesc[]"(0).
        tableDesc1:ChildTables = arrayvar1.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        DEFINE VARIABLE arrayvar2 AS Progress.Data.ColumnPropDesc EXTENT 4 NO-UNDO.
        arrayvar2[1] = NEW Progress.Data.ColumnPropDesc("user-id_", "ID", Progress.Data.DataType:CHARACTER).
        arrayvar2[2] = NEW Progress.Data.ColumnPropDesc("user_name", "Имя пользователя", Progress.Data.DataType:CHARACTER).
        arrayvar2[3] = NEW Progress.Data.ColumnPropDesc("db-num", "БД ", Progress.Data.DataType:INTEGER).
        arrayvar2[4] = NEW Progress.Data.ColumnPropDesc("flg", " * ", Progress.Data.DataType:LOGICAL).
        tableDesc1:Columns = arrayvar2.
        THIS-OBJECT:users:TableSchema = tableDesc1.
        /*  */
        /* bindingSource1 */
        /*  */
        THIS-OBJECT:bindingSource1:MaxDataGuess = 0.
        THIS-OBJECT:bindingSource1:NoLOBs = FALSE.
        THIS-OBJECT:bindingSource1:Position = 0.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        DEFINE VARIABLE arrayvar3 AS "Progress.Data.TableDesc[]" NO-UNDO.
        arrayvar3 = NEW "Progress.Data.TableDesc[]"(0).
        tableDesc2:ChildTables = arrayvar3.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        DEFINE VARIABLE arrayvar4 AS Progress.Data.ColumnPropDesc EXTENT 2 NO-UNDO.
        arrayvar4[1] = NEW Progress.Data.ColumnPropDesc("name_", "", Progress.Data.DataType:CHARACTER).
        arrayvar4[2] = NEW Progress.Data.ColumnPropDesc("flg", "***", Progress.Data.DataType:LOGICAL).
        tableDesc2:Columns = arrayvar4.
        THIS-OBJECT:bindingSource1:TableSchema = tableDesc2.
        /*  */
        /* dataGridView150 */
        /*  */
        THIS-OBJECT:dataGridView150:AllowUserToAddRows = FALSE.
        THIS-OBJECT:dataGridView150:AllowUserToDeleteRows = FALSE.
        DEFINE VARIABLE nestedvar1 AS System.Windows.Forms.AnchorStyles NO-UNDO.
        nestedvar1 = CAST(Progress.Util.EnumHelper:Or(CAST(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Bottom), System.Windows.Forms.AnchorStyles), System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
        THIS-OBJECT:dataGridView150:Anchor = CAST(Progress.Util.EnumHelper:Or(nestedvar1, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
        THIS-OBJECT:dataGridView150:AutoGenerateColumns = FALSE.
        dataGridViewCellStyle4:Alignment = System.Windows.Forms.DataGridViewContentAlignment:MiddleLeft.
        dataGridViewCellStyle4:BackColor = System.Drawing.SystemColors:Control.
        dataGridViewCellStyle4:Font = NEW System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(8.25), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
        dataGridViewCellStyle4:ForeColor = System.Drawing.SystemColors:WindowText.
        dataGridViewCellStyle4:SelectionBackColor = System.Drawing.SystemColors:Highlight.
        dataGridViewCellStyle4:SelectionForeColor = System.Drawing.SystemColors:HighlightText.
        dataGridViewCellStyle4:WrapMode = System.Windows.Forms.DataGridViewTriState:True.
        THIS-OBJECT:dataGridView150:ColumnHeadersDefaultCellStyle = dataGridViewCellStyle4.
        THIS-OBJECT:dataGridView150:ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode:AutoSize.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        DEFINE VARIABLE arrayvar5 AS System.Windows.Forms.DataGridViewColumn EXTENT 2 NO-UNDO.
        arrayvar5[1] = THIS-OBJECT:dataGridViewCheckBoxColumn1.
        arrayvar5[2] = THIS-OBJECT:nameDataGridViewTextBoxColumn.
        THIS-OBJECT:dataGridView150:Columns:AddRange(arrayvar5).
        THIS-OBJECT:dataGridView150:DataSource = THIS-OBJECT:bindingSource1.
        dataGridViewCellStyle5:Alignment = System.Windows.Forms.DataGridViewContentAlignment:MiddleLeft.
        dataGridViewCellStyle5:BackColor = System.Drawing.SystemColors:Window.
        dataGridViewCellStyle5:Font = NEW System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(8.25), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
        dataGridViewCellStyle5:ForeColor = System.Drawing.SystemColors:ControlText.
        dataGridViewCellStyle5:SelectionBackColor = System.Drawing.SystemColors:Highlight.
        dataGridViewCellStyle5:SelectionForeColor = System.Drawing.SystemColors:HighlightText.
        dataGridViewCellStyle5:WrapMode = System.Windows.Forms.DataGridViewTriState:False.
        THIS-OBJECT:dataGridView150:DefaultCellStyle = dataGridViewCellStyle5.
        THIS-OBJECT:dataGridView150:Location = NEW System.Drawing.Point(3, 26).
        THIS-OBJECT:dataGridView150:Name = "dataGridView150".
        dataGridViewCellStyle6:Alignment = System.Windows.Forms.DataGridViewContentAlignment:MiddleLeft.
        dataGridViewCellStyle6:BackColor = System.Drawing.SystemColors:Control.
        dataGridViewCellStyle6:Font = NEW System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(8.25), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
        dataGridViewCellStyle6:ForeColor = System.Drawing.SystemColors:WindowText.
        dataGridViewCellStyle6:SelectionBackColor = System.Drawing.SystemColors:Highlight.
        dataGridViewCellStyle6:SelectionForeColor = System.Drawing.SystemColors:HighlightText.
        dataGridViewCellStyle6:WrapMode = System.Windows.Forms.DataGridViewTriState:True.
        THIS-OBJECT:dataGridView150:RowHeadersDefaultCellStyle = dataGridViewCellStyle6.
        THIS-OBJECT:dataGridView150:RowHeadersVisible = FALSE.
        THIS-OBJECT:dataGridView150:Size = NEW System.Drawing.Size(1088, 281).
        THIS-OBJECT:dataGridView150:TabIndex = 1.
        THIS-OBJECT:dataGridView150:CellContentClick:Subscribe(THIS-OBJECT:dataGridView2_CellContentClick).
        /*  */
        /* dataGridViewCheckBoxColumn1 */
        /*  */
        THIS-OBJECT:dataGridViewCheckBoxColumn1:DataPropertyName = "flg".
        THIS-OBJECT:dataGridViewCheckBoxColumn1:HeaderText = "".
        THIS-OBJECT:dataGridViewCheckBoxColumn1:Name = "dataGridViewCheckBoxColumn1".
        THIS-OBJECT:dataGridViewCheckBoxColumn1:Width = 50.
        /*  */
        /* nameDataGridViewTextBoxColumn */
        /*  */
        THIS-OBJECT:nameDataGridViewTextBoxColumn:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:Fill.
        THIS-OBJECT:nameDataGridViewTextBoxColumn:DataPropertyName = "name_".
        THIS-OBJECT:nameDataGridViewTextBoxColumn:HeaderText = "Типы событий".
        THIS-OBJECT:nameDataGridViewTextBoxColumn:Name = "nameDataGridViewTextBoxColumn".
        /*  */
        /* splitContainer1 */
        /*  */
        THIS-OBJECT:splitContainer1:Dock = System.Windows.Forms.DockStyle:Fill.
        THIS-OBJECT:splitContainer1:Location = NEW System.Drawing.Point(0, 0).
        THIS-OBJECT:splitContainer1:Name = "splitContainer1".
        THIS-OBJECT:splitContainer1:Orientation = System.Windows.Forms.Orientation:Horizontal.
        /*  */
        /* splitContainer1.Panel1 */
        /*  */
        THIS-OBJECT:splitContainer1:Panel1:Controls:Add(THIS-OBJECT:button1).
        THIS-OBJECT:splitContainer1:Panel1:Controls:Add(THIS-OBJECT:label1).
        THIS-OBJECT:splitContainer1:Panel1:Controls:Add(THIS-OBJECT:dataGridView1).
        /*  */
        /* splitContainer1.Panel2 */
        /*  */
        THIS-OBJECT:splitContainer1:Panel2:Controls:Add(THIS-OBJECT:button2).
        THIS-OBJECT:splitContainer1:Panel2:Controls:Add(THIS-OBJECT:label2).
        THIS-OBJECT:splitContainer1:Panel2:Controls:Add(THIS-OBJECT:dataGridView150).
        THIS-OBJECT:splitContainer1:Size = NEW System.Drawing.Size(1094, 628).
        THIS-OBJECT:splitContainer1:SplitterDistance = 314.
        THIS-OBJECT:splitContainer1:TabIndex = 4.
        /*  */
        /* button1 */
        /*  */
        THIS-OBJECT:button1:Location = NEW System.Drawing.Point(121, 4).
        THIS-OBJECT:button1:Name = "button1".
        THIS-OBJECT:button1:Size = NEW System.Drawing.Size(55, 20).
        THIS-OBJECT:button1:TabIndex = 4.
        THIS-OBJECT:button1:Text = "Все".
        THIS-OBJECT:button1:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:button1:UseVisualStyleBackColor = TRUE.
        THIS-OBJECT:button1:Click:Subscribe(THIS-OBJECT:button1_Click_1).
        /*  */
        /* label1 */
        /*  */
        THIS-OBJECT:label1:Location = NEW System.Drawing.Point(23, 0).
        THIS-OBJECT:label1:Name = "label1".
        THIS-OBJECT:label1:Size = NEW System.Drawing.Size(282, 29).
        THIS-OBJECT:label1:TabIndex = 3.
        THIS-OBJECT:label1:Text = "Пользователи:".
        THIS-OBJECT:label1:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
        THIS-OBJECT:label1:UseCompatibleTextRendering = TRUE.
        /*  */
        /* button2 */
        /*  */
        THIS-OBJECT:button2:Location = NEW System.Drawing.Point(121, 0).
        THIS-OBJECT:button2:Name = "button2".
        THIS-OBJECT:button2:Size = NEW System.Drawing.Size(55, 20).
        THIS-OBJECT:button2:TabIndex = 5.
        THIS-OBJECT:button2:Text = "Все".
        THIS-OBJECT:button2:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:button2:UseVisualStyleBackColor = TRUE.
        THIS-OBJECT:button2:Click:Subscribe(THIS-OBJECT:button2_Click).
        /*  */
        /* label2 */
        /*  */
        THIS-OBJECT:label2:Location = NEW System.Drawing.Point(23, 0).
        THIS-OBJECT:label2:Name = "label2".
        THIS-OBJECT:label2:Size = NEW System.Drawing.Size(153, 23).
        THIS-OBJECT:label2:TabIndex = 4.
        THIS-OBJECT:label2:Text = "Типы событий:".
        THIS-OBJECT:label2:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
        THIS-OBJECT:label2:UseCompatibleTextRendering = TRUE.
        /*  */
        /* userhist */
        /*  */
        THIS-OBJECT:AutoScaleDimensions = NEW System.Drawing.SizeF(Progress.Util.CastUtil:ToSingle(6), Progress.Util.CastUtil:ToSingle(13)).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:splitContainer1).
        THIS-OBJECT:Name = "userhist".
        THIS-OBJECT:Size = NEW System.Drawing.Size(1094, 628).
        CAST(THIS-OBJECT:dataGridView1, System.ComponentModel.ISupportInitialize):EndInit().
        CAST(THIS-OBJECT:users, System.ComponentModel.ISupportInitialize):EndInit().
        CAST(THIS-OBJECT:bindingSource1, System.ComponentModel.ISupportInitialize):EndInit().
        CAST(THIS-OBJECT:dataGridView150, System.ComponentModel.ISupportInitialize):EndInit().
        THIS-OBJECT:splitContainer1:Panel1:ResumeLayout(FALSE).
        THIS-OBJECT:splitContainer1:Panel2:ResumeLayout(FALSE).
        CAST(THIS-OBJECT:splitContainer1, System.ComponentModel.ISupportInitialize):EndInit().
        THIS-OBJECT:splitContainer1:ResumeLayout(FALSE).
        THIS-OBJECT:ResumeLayout(FALSE).
        CATCH e AS Progress.Lang.Error:
            UNDO, THROW e.
        END CATCH.
    END METHOD.


    METHOD OVERRIDE PUBLIC VOID my-report ():
        
    if  str2 = yes then do:
       usertableObj:my_report().  /* запуск печати отчета */
       /*usertableObj:init_tt().   /* формирование заново временных таблиц и обновление экрана */ */
       bindingSource1:handle:query-open.  
       bindingSource1:RefreshAll() .
       users:handle:query-open.          
       users:RefreshAll() .
       RETURN.
    END.
    else do:
        message "Необходимо сходить на закладку <Продолжение...> !". 
        RETURN.
    end.
    
    END METHOD.

    METHOD OVERRIDE PUBLIC VOID my-secected(  ):
  
    str2 =  yes .
       
    usertableObj:init_tt().      /* формирование заново временных таблиц и обновление экрана */
    bindingSource1:handle:query-open.
    bindingSource1:RefreshAll() .
    users:handle:query-open.
    users:RefreshAll() .
    
    RETURN.
    
    END METHOD.

    DESTRUCTOR PUBLIC userhist ( ):

        IF VALID-OBJECT(components) THEN DO:
            CAST(components, System.IDisposable):Dispose().
        END.

    END DESTRUCTOR.

END CLASS.