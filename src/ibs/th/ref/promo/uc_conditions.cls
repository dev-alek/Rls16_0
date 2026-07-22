 
/*------------------------------------------------------------------------
   File        : uc_Conditions
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : mshavlov
   Created     : Tue Jul 31 13:09:58 MSK 2018
   Notes       : 
 ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING Progress.Windows.UserControl.
using OpenEdge.Core.Collections.Array from propath.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ibs.th.ref.promo.uc_Conditions INHERITS UserControl: 
    
    define private variable bindPromoCrit                    as Progress.Data.BindingSource                    no-undo.
    DEFINE PRIVATE VARIABLE button2                          AS System.Windows.Forms.Button                    NO-UNDO.
    DEFINE PRIVATE VARIABLE button1                          AS System.Windows.Forms.Button                    NO-UNDO.
    DEFINE PRIVATE VARIABLE button3                          AS System.Windows.Forms.Button                    NO-UNDO.
    DEFINE PRIVATE VARIABLE button5                          AS System.Windows.Forms.Button                    NO-UNDO.
    DEFINE PRIVATE VARIABLE button4                          AS System.Windows.Forms.Button                    NO-UNDO.
    DEFINE PRIVATE VARIABLE components                       AS System.ComponentModel.IContainer               NO-UNDO.
    DEFINE PRIVATE VARIABLE panel1                           AS System.Windows.Forms.Panel                     NO-UNDO.
    DEFINE PRIVATE VARIABLE label3                           AS System.Windows.Forms.Label                     NO-UNDO.
    DEFINE PRIVATE VARIABLE label2                           AS System.Windows.Forms.Label                     NO-UNDO.
    define private variable spanDataGridViewTextBoxColumn    as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable spanBefDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable mincritDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable discontDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    DEFINE PRIVATE VARIABLE tableLayoutPanel2                AS System.Windows.Forms.TableLayoutPanel          NO-UNDO.
    DEFINE PRIVATE VARIABLE tableLayoutPanel1                AS System.Windows.Forms.TableLayoutPanel          NO-UNDO.
    DEFINE PRIVATE VARIABLE label1                           AS System.Windows.Forms.Label                     NO-UNDO.
    DEFINE PRIVATE VARIABLE dataGridView1                    AS System.Windows.Forms.DataGridView              NO-UNDO.
    define         variable mbindName                        as character                                      no-undo init "PromoCriterion".
    DEFINE PRIVATE VARIABLE tableLayoutPanel4                AS System.Windows.Forms.TableLayoutPanel          NO-UNDO.
    DEFINE PRIVATE VARIABLE textBox2                         AS System.Windows.Forms.TextBox                   NO-UNDO.
    DEFINE PRIVATE VARIABLE textBox1                         AS System.Windows.Forms.TextBox                   NO-UNDO.
    DEFINE PRIVATE VARIABLE tableLayoutPanel3                AS System.Windows.Forms.TableLayoutPanel          NO-UNDO.
    define         variable mNew                             as logical                                        no-undo.
    {ibs/th/ref/promo/promo_trg_heder.i }
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    method private void button1_Click( input sender as System.Object, input e as System.EventArgs ):
        /*bindPromoCrit:Assign(). 
    m-promo-trg:addgds(mbindName).
    bindPromoCrit:handle:query-open.
    bindPromoCrit:RefreshAll().*/
        editrow(yes).
        return.

    end method.


    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    method private void button2_Click( input sender as System.Object, input e as System.EventArgs ):
        m-promo-trg:delgds(mbindName).
        m-promo-trg:CreateCrits().
        bindPromoCrit:handle:query-open.
        bindPromoCrit:RefreshAll().
        return.

    end method.


    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    METHOD PRIVATE VOID button3_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
        editrow(no).
		
        RETURN.

    END METHOD.
    method private void editrow( input iadd as logical ):
        define variable vtext1 as character no-undo.
        define variable vtext2 as character no-undo.
        assign
            textBox1:text = ""
            textBox2:text = ""
            . 
          
        if not iadd 
            then 
        do:
            m-promo-trg:GetCrit(output vtext1,output vtext2).
            if vtext1 eq "?"
                then 
                iadd = yes.
            else assign
                    textBox1:text = vtext1
                    textBox2:text = vtext2
                    .
        end.
    
        assign
            dataGridView1:Visible = false
            button3:Enabled       = false
            button2:Enabled       = false
            button1:Enabled       = false
            mNew                  = iadd
            .
    
        return.

    end method.
    method private LOGICAL EndEditRow():
        define variable vOk as logical no-undo init yes.
        dec(textBox1:text) no-error.
        if error-status:error
            then 
        do:
            message "Поле '" label2:text "' должен быть числом."
                view-as alert-box.
            vOk = false.
        end.
        dec(textBox2:text) no-error.
        if error-status:error
            then 
        do:
            message "Поле '" label3:text " должен быть числом."
                view-as alert-box.
            vOk = false.
        end.
     
        if vOk then
            vOk = m-promo-trg:setCrit(mNew,dec(textBox1:text),dec(textBox2:text) ). 
        return vOk.    
    end method.      
  
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    METHOD PRIVATE VOID button4_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
        if EndEditRow()
            then 
        do:
            bindPromoCrit:handle:query-open.
            bindPromoCrit:RefreshAll().
            dataGridView1:Visible = true.
            button3:Enabled = true.
            button2:Enabled = true.
            button1:Enabled = true.
        end.	 
        RETURN.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    METHOD PRIVATE VOID button5_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
        dataGridView1:Visible = true.
        button3:Enabled = true.
        button2:Enabled = true.
        button1:Enabled = true.
        RETURN.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    method private void dataGridView1_CellMouseClick( input sender as System.Object, input e as System.Windows.Forms.DataGridViewCellMouseEventArgs ):
        m-promo-trg:PublicEventForForm("changeCrit", "").
        return.

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    method private void dataGridView1_CellValueChanged( input sender as System.Object, input e as System.Windows.Forms.DataGridViewCellEventArgs ):
	//	
        if valid-object(m-promo-trg)
            then 
        do: 
            bindPromoCrit:Assign().
            m-promo-trg:CreateCrits().
            bindPromoCrit:RefreshAll().
        end.	 
        return.

    end method.


    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
	
    method Public VOID SetBind( ):
        bindPromoCrit:handle = m-promo-trg:getQuery(mbindName).
        setDisable(m-promo-trg:modeview).
    end.
    method public VOID setDisable(input iModeView as logical  ):
        assign
            button1:enabled = not iModeview 
            button2:enabled = not iModeview
            button3:enabled = not iModeview .
        if m-promo-trg:typeCond <> 1 and m-promo-trg:typeCond <> 2 then THIS-OBJECT:dataGridView1:Columns[2]:Visible = no .
        else THIS-OBJECT:dataGridView1:Columns[2]:Visible = true .
            /*   THIS-OBJECT:dataGridView1:Columns[0]:ReadOnly = iModeview
               THIS-OBJECT:dataGridView1:Columns[2]:ReadOnly = iModeview */
            .
    end. 
    method Public VOID localEvent(input iEvent as character, input iEventParam as character  ):
        define variable check_   as logical no-undo .  
        define variable is_check as logical no-undo .

        if iEvent eq "CritLable"
            then 
        do:
            if num-entries(iEventParam,"#") > 4 then 
            do:
                check_ = logical(entry(1,iEventParam,"#")) .
                is_check = true .
            end.    
            if entry(1,iEventParam,"#") eq "?"
                then
                THIS-OBJECT:dataGridView1:Columns[0]:Visible = no.
            else 
            do:
                if is_check then 
                do:
                end.
                else 
                do:
                    THIS-OBJECT:dataGridView1:Columns[0]:Visible = yes.
                    THIS-OBJECT:dataGridView1:Columns[0]:HeaderText = entry(1,iEventParam,"#").
                    label2:text = entry(1,iEventParam,"#").
                end.
            end.    
            if num-entries ( iEventParam,"#") > 1
                then 
            do: 
                if entry(2,iEventParam,"#") eq "?"
                    then
                    THIS-OBJECT:dataGridView1:Columns[1]:Visible = no.
                else 
                do:
                    if is_check then 
                    do:
                        if not check_ then 
                        do:
                            THIS-OBJECT:dataGridView1:Columns[0]:Visible = no.
                            THIS-OBJECT:dataGridView1:Columns[3]:FillWeight = 60.
                            THIS-OBJECT:dataGridView1:Columns[2]:FillWeight = 60.
               
                        end.
                        else 
                        do:
                            THIS-OBJECT:dataGridView1:Columns[0]:Visible = yes.
                            THIS-OBJECT:dataGridView1:Columns[0]:HeaderText = entry(2,iEventParam,"#") + " для незав. условий".
                            label2:text = entry(2,iEventParam,"#").
                            THIS-OBJECT:dataGridView1:Columns[1]:FillWeight = 50.
                            THIS-OBJECT:dataGridView1:Columns[2]:FillWeight = 50.
                            THIS-OBJECT:dataGridView1:Columns[3]:FillWeight = 50.
                        end.
                    end.
                    else 
                    do:
                        THIS-OBJECT:dataGridView1:Columns[1]:Visible = yes.
                        THIS-OBJECT:dataGridView1:Columns[1]:HeaderText = entry(2,iEventParam,"#").
                    end.
                end.
                if num-entries ( iEventParam,"#") > 2
                    then 
                do: 
                    if entry(3,iEventParam,"#") eq "?"
                        then
                        THIS-OBJECT:dataGridView1:Columns[2]:Visible = no.
                    else 
                    do:
                        if is_check then 
                        do:
                            THIS-OBJECT:dataGridView1:Columns[1]:Visible = yes.
                            THIS-OBJECT:dataGridView1:Columns[1]:HeaderText = entry(3,iEventParam,"#").
                        end.
                        else 
                        do:
                            THIS-OBJECT:dataGridView1:Columns[2]:Visible = yes.
                            THIS-OBJECT:dataGridView1:Columns[2]:HeaderText = entry(3,iEventParam,"#").
                            label3:text = entry(3,iEventParam,"#").
                        end.
                    end.
                end.    
                if num-entries ( iEventParam,"#") > 3
                    then 
                do: 
                    if entry(4,iEventParam,"#") eq "?"
                        then
                        THIS-OBJECT:dataGridView1:Columns[3]:Visible = no.
                    else 
                    do:
                        if is_check then 
                        do:
                            THIS-OBJECT:dataGridView1:Columns[2]:Visible = yes.
                            THIS-OBJECT:dataGridView1:Columns[2]:HeaderText = entry(4,iEventParam,"#").
                            label3:text = entry(4,iEventParam,"#").                          
                        end.
                        else 
                        do:
                            THIS-OBJECT:dataGridView1:Columns[3]:Visible = yes.
                            THIS-OBJECT:dataGridView1:Columns[3]:HeaderText = entry(4,iEventParam,"#").
                            label3:text = entry(4,iEventParam,"#").
                        end.
                    end.
                end.    
                if num-entries ( iEventParam,"#") > 4
                    then 
                do: 
                    if entry(4,iEventParam,"#") eq "?"
                        then
                        THIS-OBJECT:dataGridView1:Columns[4]:Visible = no.
                    else 
                    do:
                        THIS-OBJECT:dataGridView1:Columns[3]:Visible = yes.
                        THIS-OBJECT:dataGridView1:Columns[3]:HeaderText = entry(5,iEventParam,"#").
                        label3:text = entry(5,iEventParam,"#").                          
                    end.
                end.
            end.  
         // THIS-OBJECT:dataGridView1:Columns[2]:Visible = logical(iEventParam) no-error.
        end.  
    end.
          
    CONSTRUCTOR PUBLIC uc_Conditions (  ):
        
        
        SUPER().
        InitializeComponent().
        THIS-OBJECT:ComponentsCollection:ADD(THIS-OBJECT:components).
        CATCH e AS Progress.Lang.Error:
            UNDO, THROW e.
        END CATCH.

    END CONSTRUCTOR.

    METHOD PRIVATE VOID InitializeComponent(  ):
        
        /* NOTE: The following method is automatically generated.
        
        We strongly suggest that the contents of this method only be modified using the
        Visual Designer to avoid any incompatible modifications.
        
        Modifying the contents of this method using a code editor will invalidate any support for this file. */
        this-object:components = new System.ComponentModel.Container().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable tableDesc1 as Progress.Data.TableDesc no-undo.
        tableDesc1 = new Progress.Data.TableDesc("tt-PromoCriterion-two").
        this-object:tableLayoutPanel1 = new System.Windows.Forms.TableLayoutPanel().
        this-object:tableLayoutPanel2 = new System.Windows.Forms.TableLayoutPanel().
        this-object:button3 = new System.Windows.Forms.Button().
        this-object:button1 = new System.Windows.Forms.Button().
        this-object:button2 = new System.Windows.Forms.Button().
        this-object:label1 = new System.Windows.Forms.Label().
        this-object:panel1 = new System.Windows.Forms.Panel().
        this-object:dataGridView1 = new System.Windows.Forms.DataGridView().
        this-object:mincritDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
        this-object:spanDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
        this-object:spanBefDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
        this-object:discontDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
        this-object:bindPromoCrit = new Progress.Data.BindingSource(this-object:components).
        this-object:tableLayoutPanel3 = new System.Windows.Forms.TableLayoutPanel().
        this-object:label2 = new System.Windows.Forms.Label().
        this-object:label3 = new System.Windows.Forms.Label().
        this-object:textBox1 = new System.Windows.Forms.TextBox().
        this-object:textBox2 = new System.Windows.Forms.TextBox().
        this-object:tableLayoutPanel4 = new System.Windows.Forms.TableLayoutPanel().
        this-object:button4 = new System.Windows.Forms.Button().
        this-object:button5 = new System.Windows.Forms.Button().
        this-object:tableLayoutPanel1:SuspendLayout().
        this-object:tableLayoutPanel2:SuspendLayout().
        this-object:panel1:SuspendLayout().
        cast(this-object:dataGridView1, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:bindPromoCrit, System.ComponentModel.ISupportInitialize):BeginInit().
        this-object:tableLayoutPanel3:SuspendLayout().
        this-object:tableLayoutPanel4:SuspendLayout().
        this-object:SuspendLayout().
        /*  */
        /* tableLayoutPanel1 */
        /*  */
        this-object:tableLayoutPanel1:ColumnCount = 1.
        this-object:tableLayoutPanel1:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
        this-object:tableLayoutPanel1:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(20))).
        this-object:tableLayoutPanel1:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(20))).
        this-object:tableLayoutPanel1:Controls:Add(this-object:tableLayoutPanel2, 0, 1).
        this-object:tableLayoutPanel1:Controls:Add(this-object:label1, 0, 0).
        this-object:tableLayoutPanel1:Controls:Add(this-object:panel1, 0, 2).
        this-object:tableLayoutPanel1:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:tableLayoutPanel1:Location = new System.Drawing.Point(0, 0).
        this-object:tableLayoutPanel1:Name = "tableLayoutPanel1".
        this-object:tableLayoutPanel1:RowCount = 3.
        this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(25))).
        this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(25))).
        this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
        this-object:tableLayoutPanel1:Size = new System.Drawing.Size(497, 396).
        this-object:tableLayoutPanel1:TabIndex = 5.
        /*  */
        /* tableLayoutPanel2 */
        /*  */
        this-object:tableLayoutPanel2:ColumnCount = 5.
        this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(80))).
        this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(100))).
        this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(80))).
        this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(120))).
        this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
        this-object:tableLayoutPanel2:Controls:Add(this-object:button3, 1, 0).
        this-object:tableLayoutPanel2:Controls:Add(this-object:button1, 0, 0).
        this-object:tableLayoutPanel2:Controls:Add(this-object:button2, 2, 0).
        this-object:tableLayoutPanel2:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:tableLayoutPanel2:Location = new System.Drawing.Point(3, 25).
        this-object:tableLayoutPanel2:Margin = new System.Windows.Forms.Padding(3, 0, 0, 0).
        this-object:tableLayoutPanel2:Name = "tableLayoutPanel2".
        this-object:tableLayoutPanel2:RowCount = 1.
        this-object:tableLayoutPanel2:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
        this-object:tableLayoutPanel2:Size = new System.Drawing.Size(494, 25).
        this-object:tableLayoutPanel2:TabIndex = 0.
        /*  */
        /* button3 */
        /*  */
        this-object:button3:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:button3:Location = new System.Drawing.Point(80, 0).
        this-object:button3:Margin = new System.Windows.Forms.Padding(0).
        this-object:button3:Name = "button3".
        this-object:button3:Size = new System.Drawing.Size(100, 25).
        this-object:button3:TabIndex = 2.
        this-object:button3:Text = "Редактировать".
        this-object:button3:UseCompatibleTextRendering = true.
        this-object:button3:UseVisualStyleBackColor = true.
        this-object:button3:Click:Subscribe(this-object:button3_Click).
        /*  */
        /* button1 */
        /*  */
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
        /*  */
        /* button2 */
        /*  */
        this-object:button2:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:button2:Location = new System.Drawing.Point(180, 0).
        this-object:button2:Margin = new System.Windows.Forms.Padding(0).
        this-object:button2:Name = "button2".
        this-object:button2:Size = new System.Drawing.Size(80, 25).
        this-object:button2:TabIndex = 1.
        this-object:button2:Text = "Удалить".
        this-object:button2:UseCompatibleTextRendering = true.
        this-object:button2:UseVisualStyleBackColor = true.
        this-object:button2:Click:Subscribe(this-object:button2_Click).
        /*  */
        /* label1 */
        /*  */
        this-object:label1:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:label1:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(12), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
        this-object:label1:Location = new System.Drawing.Point(3, 0).
        this-object:label1:Name = "label1".
        this-object:label1:Size = new System.Drawing.Size(491, 25).
        this-object:label1:TabIndex = 4.
        this-object:label1:Text = "Условия".
        this-object:label1:UseCompatibleTextRendering = true.
        /*  */
        /* panel1 */
        /*  */
        this-object:panel1:Controls:Add(this-object:dataGridView1).
        this-object:panel1:Controls:Add(this-object:tableLayoutPanel3).
        this-object:panel1:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:panel1:Location = new System.Drawing.Point(3, 53).
        this-object:panel1:Name = "panel1".
        this-object:panel1:Size = new System.Drawing.Size(491, 340).
        this-object:panel1:TabIndex = 5.
        /*  */
        /* dataGridView1 */
        /*  */
        this-object:dataGridView1:AllowUserToAddRows = false.
        this-object:dataGridView1:AllowUserToDeleteRows = false.
        this-object:dataGridView1:AutoGenerateColumns = false.
        this-object:dataGridView1:AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode:Fill.
        this-object:dataGridView1:ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode:AutoSize.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar0 as System.Windows.Forms.DataGridViewColumn extent 4 no-undo.
        arrayvar0[1] = this-object:mincritDataGridViewTextBoxColumn.
        arrayvar0[2] = this-object:spanDataGridViewTextBoxColumn.
        arrayvar0[3] = this-object:spanBefDataGridViewTextBoxColumn.
        arrayvar0[4] = this-object:discontDataGridViewTextBoxColumn.
        this-object:dataGridView1:Columns:AddRange(arrayvar0).
        this-object:dataGridView1:DataSource = this-object:bindPromoCrit.
        this-object:dataGridView1:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:dataGridView1:Location = new System.Drawing.Point(0, 0).
        this-object:dataGridView1:Name = "dataGridView1".
        this-object:dataGridView1:RowHeadersVisible = false.
        this-object:dataGridView1:Size = new System.Drawing.Size(491, 340).
        this-object:dataGridView1:TabIndex = 8.
        this-object:dataGridView1:CellMouseClick:Subscribe(this-object:dataGridView1_CellMouseClick).
        this-object:dataGridView1:CellValueChanged:Subscribe(this-object:dataGridView1_CellValueChanged).
        /*  */
        /* mincritDataGridViewTextBoxColumn */
        /*  */
        this-object:mincritDataGridViewTextBoxColumn:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:Fill.
        this-object:mincritDataGridViewTextBoxColumn:DataPropertyName = "mincrit".
        this-object:mincritDataGridViewTextBoxColumn:FillWeight = Progress.Util.CastUtil:ToSingle(55).
        this-object:mincritDataGridViewTextBoxColumn:HeaderText = "Количество, ед".
        this-object:mincritDataGridViewTextBoxColumn:Name = "mincritDataGridViewTextBoxColumn".
        this-object:mincritDataGridViewTextBoxColumn:ReadOnly = true.
        /*  */
        /* spanDataGridViewTextBoxColumn */
        /*  */
        this-object:spanDataGridViewTextBoxColumn:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:Fill.
        this-object:spanDataGridViewTextBoxColumn:DataPropertyName = "span".
        this-object:spanDataGridViewTextBoxColumn:FillWeight = Progress.Util.CastUtil:ToSingle(55).
        this-object:spanDataGridViewTextBoxColumn:HeaderText = "Диапозон действия, ед".
        this-object:spanDataGridViewTextBoxColumn:Name = "spanDataGridViewTextBoxColumn".
        this-object:spanDataGridViewTextBoxColumn:ReadOnly = true.
        /*  */
        /* spanBefDataGridViewTextBoxColumn */
        /*  */
        this-object:spanBefDataGridViewTextBoxColumn:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:Fill.
        this-object:spanBefDataGridViewTextBoxColumn:DataPropertyName = "spanBef".
        this-object:spanBefDataGridViewTextBoxColumn:FillWeight = Progress.Util.CastUtil:ToSingle(55).
        this-object:spanBefDataGridViewTextBoxColumn:HeaderText = "Диапозон действия, ед".
        this-object:spanBefDataGridViewTextBoxColumn:Name = "spanBefDataGridViewTextBoxColumn".
        this-object:spanBefDataGridViewTextBoxColumn:ReadOnly = true.
        /*  */
        /* discontDataGridViewTextBoxColumn */
        /*  */
        this-object:discontDataGridViewTextBoxColumn:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:Fill.
        this-object:discontDataGridViewTextBoxColumn:DataPropertyName = "discont".
        this-object:discontDataGridViewTextBoxColumn:HeaderText = "Скидка, ед".
        this-object:discontDataGridViewTextBoxColumn:Name = "discontDataGridViewTextBoxColumn".
        this-object:discontDataGridViewTextBoxColumn:ReadOnly = true.
        /*  */
        /* bindPromoCrit */
        /*  */
        this-object:bindPromoCrit:AutoSort = true.
        this-object:bindPromoCrit:AutoUpdate = true.
        this-object:bindPromoCrit:MaxDataGuess = 0.
        this-object:bindPromoCrit:NoLOBs = false.
        this-object:bindPromoCrit:Position = 0.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar1 as "Progress.Data.TableDesc[]" no-undo.
        arrayvar1 = new "Progress.Data.TableDesc[]"(0).
        tableDesc1:ChildTables = arrayvar1.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar2 as Progress.Data.ColumnPropDesc extent 4 no-undo.
        arrayvar2[1] = new Progress.Data.ColumnPropDesc("span", "Диапозон действия, ед", Progress.Data.DataType:CHARACTER).
        arrayvar2[2] = new Progress.Data.ColumnPropDesc("spanBef", "Диапозон действия, ед", Progress.Data.DataType:CHARACTER).
        arrayvar2[3] = new Progress.Data.ColumnPropDesc("discont", "Скидка, ед", Progress.Data.DataType:DECIMAL).
        arrayvar2[4] = new Progress.Data.ColumnPropDesc("mincrit", "Количество, ед", Progress.Data.DataType:DECIMAL).
        tableDesc1:Columns = arrayvar2.
        this-object:bindPromoCrit:TableSchema = tableDesc1.
        /*  */
        /* tableLayoutPanel3 */
        /*  */
        this-object:tableLayoutPanel3:ColumnCount = 2.
        this-object:tableLayoutPanel3:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(120))).
        this-object:tableLayoutPanel3:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
        this-object:tableLayoutPanel3:Controls:Add(this-object:label2, 0, 0).
        this-object:tableLayoutPanel3:Controls:Add(this-object:label3, 0, 1).
        this-object:tableLayoutPanel3:Controls:Add(this-object:textBox1, 1, 0).
        this-object:tableLayoutPanel3:Controls:Add(this-object:textBox2, 1, 1).
        this-object:tableLayoutPanel3:Controls:Add(this-object:tableLayoutPanel4, 0, 2).
        this-object:tableLayoutPanel3:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:tableLayoutPanel3:Location = new System.Drawing.Point(0, 0).
        this-object:tableLayoutPanel3:Name = "tableLayoutPanel3".
        this-object:tableLayoutPanel3:RowCount = 5.
        this-object:tableLayoutPanel3:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(30))).
        this-object:tableLayoutPanel3:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(30))).
        this-object:tableLayoutPanel3:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(30))).
        this-object:tableLayoutPanel3:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
        this-object:tableLayoutPanel3:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(30))).
        this-object:tableLayoutPanel3:Size = new System.Drawing.Size(491, 340).
        this-object:tableLayoutPanel3:TabIndex = 9.
        /*  */
        /* label2 */
        /*  */
        this-object:label2:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:label2:Location = new System.Drawing.Point(3, 3).
        this-object:label2:Margin = new System.Windows.Forms.Padding(3).
        this-object:label2:Name = "label2".
        this-object:label2:Size = new System.Drawing.Size(114, 24).
        this-object:label2:TabIndex = 0.
        this-object:label2:Text = "Количество, ед".
        this-object:label2:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
        this-object:label2:UseCompatibleTextRendering = true.
        /*  */
        /* label3 */
        /*  */
        this-object:label3:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:label3:Location = new System.Drawing.Point(3, 33).
        this-object:label3:Margin = new System.Windows.Forms.Padding(3).
        this-object:label3:Name = "label3".
        this-object:label3:Size = new System.Drawing.Size(114, 24).
        this-object:label3:TabIndex = 1.
        this-object:label3:Text = "Скидка".
        this-object:label3:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
        this-object:label3:UseCompatibleTextRendering = true.
        /*  */
        /* textBox1 */
        /*  */
        define variable nestedvar0 as System.Windows.Forms.AnchorStyles no-undo.
        nestedvar0 = cast(Progress.Util.EnumHelper:Or(cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Bottom), System.Windows.Forms.AnchorStyles), System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
        this-object:textBox1:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
        this-object:textBox1:Location = new System.Drawing.Point(123, 3).
        this-object:textBox1:Name = "textBox1".
        this-object:textBox1:Size = new System.Drawing.Size(365, 20).
        this-object:textBox1:TabIndex = 2.
        /*  */
        /* textBox2 */
        /*  */
        define variable nestedvar1 as System.Windows.Forms.AnchorStyles no-undo.
        nestedvar1 = cast(Progress.Util.EnumHelper:Or(cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Bottom), System.Windows.Forms.AnchorStyles), System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
        this-object:textBox2:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar1, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
        this-object:textBox2:Location = new System.Drawing.Point(123, 33).
        this-object:textBox2:Name = "textBox2".
        this-object:textBox2:Size = new System.Drawing.Size(365, 20).
        this-object:textBox2:TabIndex = 3.
        /*  */
        /* tableLayoutPanel4 */
        /*  */
        this-object:tableLayoutPanel4:ColumnCount = 3.
        this-object:tableLayoutPanel3:SetColumnSpan(this-object:tableLayoutPanel4, 2).
        this-object:tableLayoutPanel4:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
        this-object:tableLayoutPanel4:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(110))).
        this-object:tableLayoutPanel4:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(110))).
        this-object:tableLayoutPanel4:Controls:Add(this-object:button4, 1, 0).
        this-object:tableLayoutPanel4:Controls:Add(this-object:button5, 2, 0).
        this-object:tableLayoutPanel4:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:tableLayoutPanel4:Location = new System.Drawing.Point(3, 63).
        this-object:tableLayoutPanel4:Name = "tableLayoutPanel4".
        this-object:tableLayoutPanel4:RowCount = 1.
        this-object:tableLayoutPanel4:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
        this-object:tableLayoutPanel4:Size = new System.Drawing.Size(485, 24).
        this-object:tableLayoutPanel4:TabIndex = 4.
        /*  */
        /* button4 */
        /*  */
        this-object:button4:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:button4:Location = new System.Drawing.Point(265, 0).
        this-object:button4:Margin = new System.Windows.Forms.Padding(0).
        this-object:button4:Name = "button4".
        this-object:button4:Size = new System.Drawing.Size(110, 24).
        this-object:button4:TabIndex = 2.
        this-object:button4:Text = "Сохранить".
        this-object:button4:UseCompatibleTextRendering = true.
        this-object:button4:UseVisualStyleBackColor = true.
        this-object:button4:Click:Subscribe(this-object:button4_Click).
        /*  */
        /* button5 */
        /*  */
        this-object:button5:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:button5:Location = new System.Drawing.Point(375, 0).
        this-object:button5:Margin = new System.Windows.Forms.Padding(0).
        this-object:button5:Name = "button5".
        this-object:button5:Size = new System.Drawing.Size(110, 24).
        this-object:button5:TabIndex = 3.
        this-object:button5:Text = "Отмена".
        this-object:button5:UseCompatibleTextRendering = true.
        this-object:button5:UseVisualStyleBackColor = true.
        this-object:button5:Click:Subscribe(this-object:button5_Click).
        /*  */
        /* uc_Conditions */
        /*  */
        this-object:AutoScaleDimensions = new System.Drawing.SizeF(Progress.Util.CastUtil:ToSingle(6), Progress.Util.CastUtil:ToSingle(13)).
        this-object:Controls:Add(this-object:tableLayoutPanel1).
        this-object:Margin = new System.Windows.Forms.Padding(0).
        this-object:Name = "uc_Conditions".
        this-object:Size = new System.Drawing.Size(497, 396).
        this-object:tableLayoutPanel1:ResumeLayout(false).
        this-object:tableLayoutPanel2:ResumeLayout(false).
        this-object:panel1:ResumeLayout(false).
        cast(this-object:dataGridView1, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:bindPromoCrit, System.ComponentModel.ISupportInitialize):EndInit().
        this-object:tableLayoutPanel3:ResumeLayout(false).
        this-object:tableLayoutPanel3:PerformLayout().
        this-object:tableLayoutPanel4:ResumeLayout(false).
        this-object:ResumeLayout(false).
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.
    END METHOD.

    DESTRUCTOR PUBLIC uc_Conditions ( ):
        bindPromoCrit:Dispose().
    END DESTRUCTOR.

END CLASS.