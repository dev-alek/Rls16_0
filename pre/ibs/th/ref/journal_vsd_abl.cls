USING Progress.Lang.*.
USING Progress.Windows.Form.
USING ibs.th.ref.journal_vsd_trg.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS ibs.th.ref.journal_vsd_abl INHERITS Form:
    DEFINE PRIVATE VARIABLE bindttFilt AS Progress.Data.BindingSource NO-UNDO.
    DEFINE PRIVATE VARIABLE Btn_clen AS System.Windows.Forms.Button NO-UNDO.
    DEFINE PRIVATE VARIABLE btn_edit AS System.Windows.Forms.Button NO-UNDO.
    DEFINE PRIVATE VARIABLE Btn_Cancel AS System.Windows.Forms.Button NO-UNDO.
    DEFINE PRIVATE VARIABLE btn_Filt AS System.Windows.Forms.Button NO-UNDO.
    DEFINE PRIVATE VARIABLE Btn_gds AS System.Windows.Forms.Button NO-UNDO.
    DEFINE PRIVATE VARIABLE btn_gds_merc AS System.Windows.Forms.Button NO-UNDO.
    DEFINE PRIVATE VARIABLE Btn_lookup AS System.Windows.Forms.Button NO-UNDO.
    DEFINE PRIVATE VARIABLE btn_prn AS System.Windows.Forms.Button NO-UNDO.
    DEFINE PRIVATE VARIABLE btn_ref AS System.Windows.Forms.Button NO-UNDO.
    DEFINE PRIVATE VARIABLE btn_trndoc AS System.Windows.Forms.Button NO-UNDO.
    DEFINE PRIVATE VARIABLE dateTimePicker1 AS System.Windows.Forms.DateTimePicker NO-UNDO.
    DEFINE PRIVATE VARIABLE dateTimePicker2 AS System.Windows.Forms.DateTimePicker NO-UNDO.
    DEFINE PRIVATE VARIABLE FalVerif AS System.Windows.Forms.CheckBox NO-UNDO.
    DEFINE PRIVATE VARIABLE FalExting AS System.Windows.Forms.CheckBox NO-UNDO.
    DEFINE PRIVATE VARIABLE gdscode AS System.Windows.Forms.TextBox NO-UNDO.
    DEFINE PRIVATE VARIABLE gdsguid AS System.Windows.Forms.TextBox NO-UNDO.
    DEFINE PRIVATE VARIABLE gdsmercguid AS System.Windows.Forms.TextBox NO-UNDO.
    DEFINE PRIVATE VARIABLE gdsname AS System.Windows.Forms.TextBox NO-UNDO.
    DEFINE PRIVATE VARIABLE gdsnamemerc AS System.Windows.Forms.TextBox NO-UNDO.
    DEFINE PRIVATE VARIABLE label1 AS System.Windows.Forms.Label NO-UNDO.
    DEFINE PRIVATE VARIABLE label2 AS System.Windows.Forms.Label NO-UNDO.
    DEFINE PRIVATE VARIABLE label3 AS System.Windows.Forms.Label NO-UNDO.
    DEFINE PRIVATE VARIABLE label4 AS System.Windows.Forms.Label NO-UNDO.
    DEFINE PRIVATE VARIABLE label5 AS System.Windows.Forms.Label NO-UNDO.
    DEFINE PRIVATE VARIABLE label7 AS System.Windows.Forms.Label NO-UNDO.
    DEFINE PRIVATE VARIABLE label6 AS System.Windows.Forms.Label NO-UNDO.
    DEFINE PRIVATE VARIABLE msgerr AS System.Windows.Forms.TextBox NO-UNDO.
    DEFINE PRIVATE VARIABLE NomTTH AS System.Windows.Forms.TextBox NO-UNDO.
    DEFINE PRIVATE VARIABLE numericUpDown1 AS System.Windows.Forms.NumericUpDown NO-UNDO.
    DEFINE PRIVATE VARIABLE panel1 AS System.Windows.Forms.Panel NO-UNDO.
    DEFINE PRIVATE VARIABLE panel2 AS System.Windows.Forms.Panel NO-UNDO.
    DEFINE PRIVATE VARIABLE Rep AS System.Windows.Forms.CheckBox NO-UNDO.
    DEFINE PRIVATE VARIABLE ReqVerif AS System.Windows.Forms.CheckBox NO-UNDO.
    DEFINE PRIVATE VARIABLE Sent AS System.Windows.Forms.CheckBox NO-UNDO.
    DEFINE PRIVATE VARIABLE tableLayoutPanel1 AS System.Windows.Forms.TableLayoutPanel NO-UNDO.
    DEFINE PRIVATE VARIABLE ToExtin AS System.Windows.Forms.CheckBox NO-UNDO.
    DEFINE PRIVATE VARIABLE unitcliDataGridViewTextBoxColumn AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.
    DEFINE PRIVATE VARIABLE statusvsdDataGridViewTextBoxColumn AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.
    DEFINE PRIVATE VARIABLE prodcodeDataGridViewTextBoxColumn AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.
    DEFINE PRIVATE VARIABLE postDataGridViewTextBoxColumn AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.
    DEFINE PRIVATE VARIABLE ojdDataGridViewTextBoxColumn AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.
    DEFINE PRIVATE VARIABLE nomTTHpostDataGridViewTextBoxColumn AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.
    DEFINE PRIVATE VARIABLE nomTTHDataGridViewTextBoxColumn AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.
    DEFINE PRIVATE VARIABLE nomAZSDataGridViewTextBoxColumn AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.
    DEFINE PRIVATE VARIABLE gdsnameDataGridViewTextBoxColumn AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.
    DEFINE PRIVATE VARIABLE dateTTHDataGridViewTextBoxColumn AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.
    DEFINE PRIVATE VARIABLE cOLobjDataGridViewTextBoxColumn AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.
    DEFINE PRIVATE VARIABLE articDataGridViewTextBoxColumn AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.
    DEFINE PRIVATE VARIABLE uUIDDataGridViewTextBoxColumn AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.
    DEFINE PRIVATE VARIABLE COLobj AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.
    DEFINE PRIVATE VARIABLE vsdtypelblDataGridViewTextBoxColumn AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.
    DEFINE PRIVATE VARIABLE uUIDDataGridViewTextBoxColumn1 AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.
    DEFINE VARIABLE vss-revision       AS CHARACTER NO-UNDO INIT "$Revision$":U .
    DEFINE VARIABLE vss-author         AS CHARACTER NO-UNDO INIT "$Author$":U .
    DEFINE VARIABLE vss-date           AS CHARACTER NO-UNDO INIT "$Date$":U .
    DEFINE VARIABLE vss-workfile       AS CHARACTER NO-UNDO INIT "$Workfile$":U .
    DEFINE VARIABLE vss-archive        AS CHARACTER NO-UNDO INIT "$Archive$":U .
    DEFINE VARIABLE vss-description    AS CHARACTER NO-UNDO INIT "Журнал ВСД".
    DEFINE PRIVATE VARIABLE bingvsd AS Progress.Data.BindingSource NO-UNDO.
    DEFINE PRIVATE VARIABLE hbingvsd AS HANDLE NO-UNDO.
    DEFINE PRIVATE VARIABLE components AS System.ComponentModel.IContainer NO-UNDO.
    DEFINE PRIVATE VARIABLE dataGridView1 AS System.Windows.Forms.DataGridView NO-UNDO.
    DEFINE PRIVATE VARIABLE hDSFILt   AS HANDLE    NO-UNDO.
    DEFINE PRIVATE VARIABLE hDSVSd    AS HANDLE    NO-UNDO.
    DEFINE VARIABLE parparentproc     AS HANDLE    NO-UNDO.
    DEFINE STREAM OutStr-html.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
   //111  { gbl/prn-lib.i   }
    DEFINE TEMP-TABLE t-obj-list NO-UNDO
    FIELD obj-type  AS CHARACTER
    FIELD obj-code  AS INTEGER
    FIELD host-code AS INTEGER
    INDEX pi IS UNIQUE PRIMARY obj-type  obj-code
    INDEX firm                 host-code.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table tt-gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define    temp-table tt-gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
DEFINE TEMP-TABLE tt-vsd-filt NO-UNDO
FIELD date-end AS DATE
FIELD date-start AS DATE
FIELD fTime  AS INTEGER
FIELD FalExting AS LOGICAL
FIELD FalVerif  AS LOGICAL
FIELD Rep       AS LOGICAL
FIELD ReqVerif  AS LOGICAL
FIELD ToExtin   AS LOGICAL
FIELD Sent      AS LOGICAL
FIELD doc-code  AS CHARACTER
.
DEFINE DATASET ds-vsd-set
FOR tt-vsd-filt, t-obj-list,  tt-gds-list .
DEFINE TEMP-TABLE ttvsd NO-UNDO LIKE ub.vsd
        FIELD dateTTH     AS DATE
        FIELD NomTTH      AS CHAR
        FIELD NomTTHpost  AS CHAR
        FIELD NomAZS      AS CHAR
        FIELD Post        AS CHAR
        FIELD artic       AS CHAR
        FIELD gdsname     AS CHAR
        FIELD prod-code   AS CHAR
        FIELD COLobj      AS DEC
        FIELD unit-cli    AS CHAR
        FIELD unit-base   AS CHAR
        FIELD statusvsd   AS CHAR
        FIELD ojd         AS DEC
        FIELD gdsmercguid AS CHAR
        FIELD vsdtypelbl  AS CHAR
        FIELD vsdsubs     AS CLASS Progress.Lang.Object.
    DEFINE DATASET dsVSd FOR ttVSd.
    DEFINE VARIABLE v-object-available    AS LOGICAL   NO-UNDO .
    DEFINE VARIABLE vjournalvsdTrg AS CLASS journal_vsd_trg.
    CONSTRUCTOR PUBLIC journal_vsd_abl ( INPUT p-paparparentproc AS HANDLE  ):
        SUPER().
        InitializeComponent().
        THIS-OBJECT:ComponentsCollection:ADD(THIS-OBJECT:components).
        vjournalvsdTrg = NEW ibs.th.ref.journal_vsd_trg (p-paparparentproc).
        parparentproc = p-paparparentproc.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
        CREATE tt-vsd-filt.
        ASSIGN
            tt-vsd-filt.date-end   = TODAY
            tt-vsd-filt.date-start = TODAY
            tt-vsd-filt.FalExting  = YES
            tt-vsd-filt.FalVerif   = YES
            tt-vsd-filt.Rep        = YES
            tt-vsd-filt.ReqVerif   = YES
            tt-vsd-filt.ToExtin    = YES
            tt-vsd-filt.Sent    = YES
            tt-vsd-filt.fTime      = 0
            .
        FOR EACH db NO-LOCK
            ON ERROR UNDO, RETURN NO-APPLY
            :
            FOR EACH clients NO-LOCK
                WHERE clients.db-num = db.db-num
                ON ERROR UNDO, RETURN NO-APPLY
                :
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run usobjava in ibs.th.gbl.gbl-hndllib:g#library2
  (input  v-cntxt-db-num
  ,input  0
  ,input  v-cntxt-userid
  ,input  clients.obj-type
  ,input  clients.obj-code
  ,output v-object-available
  ) no-error .
                IF ERROR-STATUS :ERROR
                    THEN
                DO:
                    MESSAGE
                        vss-workfile vss-revision vss-description SKIP
                        "Ошибка при вызове процедуры gbl/usobjava.i" SKIP
                        ERROR-STATUS :GET-MESSAGE(1) SKIP
                        RETURN-VALUE SKIP
                        VIEW-AS ALERT-BOX ERROR .
                    UNDO, RETURN NO-APPLY .
                END.
                IF v-object-available = TRUE
                    THEN
                DO:
                    CREATE t-obj-list .
                    ASSIGN
                        t-obj-list.obj-type = clients.obj-type
                        t-obj-list.obj-code = clients.obj-code
                        .
                END.
            END.
        END.
        vjournalvsdTrg:CreateTT(INPUT DATASET ds-vsd-set, OUTPUT TABLE ttvsd).
        hDSVSd = DATASET dsVSd:HANDLE.
        bingvsd:HANDLE =  hDSvsd:TOP-NAV-QUERY.
        hbingvsd = bingvsd:HANDLE.
        hDSFILt = DATASET ds-vsd-set:HANDLE.
        bindttfilt:HANDLE = hDSFILt:TOP-NAV-QUERY.
        CATCH e AS Progress.Lang.Error:
            UNDO, THROW e.
        END CATCH.
    END CONSTRUCTOR.
        @VisualDesigner.
        METHOD PRIVATE VOID Btn_Cancel_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
                THIS-OBJECT:DialogResult = System.Windows.Forms.DialogResult:Ok.
        THIS-OBJECT:Close ( ).
                RETURN.
        END METHOD.
        @VisualDesigner.
        METHOD PRIVATE VOID Btn_clen_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
                vjournalvsdTrg:filt-clen(OUTPUT DATASET ds-vsd-set).
                bindttfilt:Refresh().
        vjournalvsdTrg:CreateTT(INPUT DATASET ds-vsd-set, OUTPUT TABLE ttvsd).
        hbingvsd:QUERY-OPEN ().
        bingvsd:RefreshAll().
                RETURN.
        END METHOD.
        @VisualDesigner.
        METHOD PRIVATE VOID btn_edit_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
            IF AVAILABLE ttvsd THEN
                  vjournalvsdTrg:VSD_edit(ttvsd.id, ttvsd.db-num, ttvsd.vsdsubs).
                RETURN.
        END METHOD.
        @VisualDesigner.
        METHOD PRIVATE VOID btn_Filt_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
            bindttfilt:Assign().
                RUN bge/vsd-filt.w(parparentproc,INPUT-OUTPUT DATASET ds-vsd-set ).
                bindttfilt:Refresh().
                vjournalvsdTrg:CreateTT(INPUT DATASET ds-vsd-set, OUTPUT TABLE ttvsd).
        hbingvsd:QUERY-OPEN ().
        bingvsd:RefreshAll().
                RETURN.
        END METHOD.
        @VisualDesigner.
        METHOD PRIVATE VOID Btn_gds_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
            IF AVAILABLE ttvsd THEN
                  vjournalvsdTrg:gds_lock(ttvsd.gds-code, ttvsd.obj-type, ttvsd.obj-code).
                RETURN.
        END METHOD.
        @VisualDesigner.
        METHOD PRIVATE VOID btn_gds_merc_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
            IF AVAILABLE ttvsd THEN
                  vjournalvsdTrg:gds_merc_lock(ttvsd.gds-code).
                RETURN.
        END METHOD.
        @VisualDesigner.
        METHOD PRIVATE VOID Btn_lookup_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
                IF AVAILABLE ttvsd THEN
        vjournalvsdTrg:VSD_lock(ttvsd.id, ttvsd.db-num, ttvsd.vsdsubs).
                RETURN.
        END METHOD.
        @VisualDesigner.
        METHOD PRIVATE VOID btn_prn_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
                bindttfilt:Assign().
                RUN rep/printvsd.p ( parparentproc,
                                      tt-vsd-filt.date-start,
                                        tt-vsd-filt.date-end,
                                        INPUT TABLE ttvsd).
                RETURN.
        END METHOD.
        @VisualDesigner.
        DEFINE VARIABLE vssss AS INTEGER NO-UNDO INIT 190.
        @VisualDesigner.
        METHOD PRIVATE VOID btn_ref_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
                bindttfilt:Assign().
                vjournalvsdTrg:CreateTT(INPUT DATASET ds-vsd-set, OUTPUT TABLE ttvsd).
        hbingvsd:QUERY-OPEN ().
        bingvsd:RefreshAll().
                RETURN.
        END METHOD.
        @VisualDesigner.
        METHOD PRIVATE VOID btn_trndoc_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
            vjournalvsdTrg:trn_doc_lock(ttvsd.part-key,ttvsd.gds-code).
                RETURN.
        END METHOD.
        METHOD PRIVATE VOID button1_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
            vjournalvsdTrg:CreateTT(INPUT DATASET ds-vsd-set, OUTPUT TABLE ttvsd).
            hbingvsd:QUERY-OPEN ().
            bingvsd:RefreshAll().
            IF AVAILABLE ttvsd THEN DO:
            vjournalvsdTrg:VSD_lock(ttvsd.id, ttvsd.db-num, ttvsd.vsdsubs).
            END.
            ELSE
            MESSAGE "Не выбран объект для отображения."
        VIEW-AS ALERT-BOX.
            RETURN.
        END METHOD.
        @VisualDesigner.
        METHOD PRIVATE VOID dataGridView1_CellContentClick( INPUT sender AS System.Object, INPUT e AS System.Windows.Forms.DataGridViewCellEventArgs ):
                RETURN.
        END METHOD.
        @VisualDesigner.
    METHOD PRIVATE VOID InitializeComponent(  ):
      this-object:components = new System.ComponentModel.Container().
      @VisualDesigner.FormMember (NeedsInitialize="true").
      define variable tableDesc1 as Progress.Data.TableDesc no-undo.
      tableDesc1 = new Progress.Data.TableDesc("vsd").
      @VisualDesigner.FormMember (NeedsInitialize="true").
      define variable resources as Progress.Util.ResourceManager no-undo.
      resources = new Progress.Util.ResourceManager("ibs.th.ref.journal_vsd_abl").
      @VisualDesigner.FormMember (NeedsInitialize="true").
      define variable tableDesc2 as Progress.Data.TableDesc no-undo.
      tableDesc2 = new Progress.Data.TableDesc("ttfilt").
      @VisualDesigner.FormMember (NeedsInitialize="true").
      define variable dataGridViewCellStyle1 as System.Windows.Forms.DataGridViewCellStyle no-undo.
      dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle().
      this-object:Btn_lookup = new System.Windows.Forms.Button().
      this-object:dataGridView1 = new System.Windows.Forms.DataGridView().
      this-object:bingvsd = new Progress.Data.BindingSource(this-object:components).
      this-object:uUIDDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:COLobj = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:tableLayoutPanel1 = new System.Windows.Forms.TableLayoutPanel().
      this-object:gdsname = new System.Windows.Forms.TextBox().
      this-object:gdsnamemerc = new System.Windows.Forms.TextBox().
      this-object:gdscode = new System.Windows.Forms.TextBox().
      this-object:gdsmercguid = new System.Windows.Forms.TextBox().
      this-object:label1 = new System.Windows.Forms.Label().
      this-object:label2 = new System.Windows.Forms.Label().
      this-object:gdsguid = new System.Windows.Forms.TextBox().
      this-object:Btn_gds = new System.Windows.Forms.Button().
      this-object:btn_gds_merc = new System.Windows.Forms.Button().
      this-object:NomTTH = new System.Windows.Forms.TextBox().
      this-object:label3 = new System.Windows.Forms.Label().
      this-object:btn_trndoc = new System.Windows.Forms.Button().
      this-object:panel1 = new System.Windows.Forms.Panel().
      this-object:panel2 = new System.Windows.Forms.Panel().
      this-object:Btn_clen = new System.Windows.Forms.Button().
      this-object:Sent = new System.Windows.Forms.CheckBox().
      this-object:bindttFilt = new Progress.Data.BindingSource(this-object:components).
      this-object:btn_Filt = new System.Windows.Forms.Button().
      this-object:numericUpDown1 = new System.Windows.Forms.NumericUpDown().
      this-object:btn_ref = new System.Windows.Forms.Button().
      this-object:Rep = new System.Windows.Forms.CheckBox().
      this-object:FalVerif = new System.Windows.Forms.CheckBox().
      this-object:ToExtin = new System.Windows.Forms.CheckBox().
      this-object:FalExting = new System.Windows.Forms.CheckBox().
      this-object:ReqVerif = new System.Windows.Forms.CheckBox().
      this-object:dateTimePicker2 = new System.Windows.Forms.DateTimePicker().
      this-object:label7 = new System.Windows.Forms.Label().
      this-object:label6 = new System.Windows.Forms.Label().
      this-object:dateTimePicker1 = new System.Windows.Forms.DateTimePicker().
      this-object:label5 = new System.Windows.Forms.Label().
      this-object:btn_prn = new System.Windows.Forms.Button().
      this-object:btn_edit = new System.Windows.Forms.Button().
      this-object:Btn_Cancel = new System.Windows.Forms.Button().
      this-object:msgerr = new System.Windows.Forms.TextBox().
      this-object:label4 = new System.Windows.Forms.Label().
      this-object:dateTTHDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:nomTTHDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:nomAZSDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:articDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:vsdtypelblDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:uUIDDataGridViewTextBoxColumn1 = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:statusvsdDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:nomTTHpostDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:postDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:gdsnameDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:prodcodeDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:cOLobjDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:unitcliDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:ojdDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      cast(this-object:dataGridView1, System.ComponentModel.ISupportInitialize):BeginInit().
      cast(this-object:bingvsd, System.ComponentModel.ISupportInitialize):BeginInit().
      this-object:tableLayoutPanel1:SuspendLayout().
      this-object:panel1:SuspendLayout().
      this-object:panel2:SuspendLayout().
      cast(this-object:bindttFilt, System.ComponentModel.ISupportInitialize):BeginInit().
      cast(this-object:numericUpDown1, System.ComponentModel.ISupportInitialize):BeginInit().
      this-object:SuspendLayout().
      this-object:Btn_lookup:Location = new System.Drawing.Point(204, 12).
      this-object:Btn_lookup:Name = "Btn_lookup".
      this-object:Btn_lookup:Size = new System.Drawing.Size(75, 23).
      this-object:Btn_lookup:TabIndex = 0.
      this-object:Btn_lookup:Text = "Просмотр".
      this-object:Btn_lookup:UseCompatibleTextRendering = true.
      this-object:Btn_lookup:UseVisualStyleBackColor = true.
      this-object:Btn_lookup:Click:Subscribe(this-object:Btn_lookup_Click).
      this-object:dataGridView1:AllowUserToAddRows = false.
      this-object:dataGridView1:AllowUserToDeleteRows = false.
      this-object:dataGridView1:AllowUserToOrderColumns = true.
      this-object:dataGridView1:AutoGenerateColumns = false.
      this-object:dataGridView1:ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode:AutoSize.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar0 as System.Windows.Forms.DataGridViewColumn extent 14 no-undo.
      arrayvar0[1] = this-object:dateTTHDataGridViewTextBoxColumn.
      arrayvar0[2] = this-object:nomTTHDataGridViewTextBoxColumn.
      arrayvar0[3] = this-object:nomAZSDataGridViewTextBoxColumn.
      arrayvar0[4] = this-object:articDataGridViewTextBoxColumn.
      arrayvar0[5] = this-object:vsdtypelblDataGridViewTextBoxColumn.
      arrayvar0[6] = this-object:uUIDDataGridViewTextBoxColumn1.
      arrayvar0[7] = this-object:statusvsdDataGridViewTextBoxColumn.
      arrayvar0[8] = this-object:nomTTHpostDataGridViewTextBoxColumn.
      arrayvar0[9] = this-object:postDataGridViewTextBoxColumn.
      arrayvar0[10] = this-object:gdsnameDataGridViewTextBoxColumn.
      arrayvar0[11] = this-object:prodcodeDataGridViewTextBoxColumn.
      arrayvar0[12] = this-object:cOLobjDataGridViewTextBoxColumn.
      arrayvar0[13] = this-object:unitcliDataGridViewTextBoxColumn.
      arrayvar0[14] = this-object:ojdDataGridViewTextBoxColumn.
      this-object:dataGridView1:Columns:AddRange(arrayvar0).
      this-object:dataGridView1:DataSource = this-object:bingvsd.
      this-object:dataGridView1:Location = new System.Drawing.Point(-2, 103).
      this-object:dataGridView1:Name = "dataGridView1".
      this-object:dataGridView1:ReadOnly = true.
      this-object:dataGridView1:Size = new System.Drawing.Size(852, 273).
      this-object:dataGridView1:TabIndex = 1.
      this-object:dataGridView1:CellContentClick:Subscribe(this-object:dataGridView1_CellContentClick).
      this-object:bingvsd:AutoSort = true.
      this-object:bingvsd:AutoUpdate = true.
      this-object:bingvsd:MaxDataGuess = 0.
      this-object:bingvsd:NoLOBs = false.
      this-object:bingvsd:Position = 0.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar1 as "Progress.Data.TableDesc[]" no-undo.
      arrayvar1 = new "Progress.Data.TableDesc[]"(0).
      tableDesc1:ChildTables = arrayvar1.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar2 as Progress.Data.ColumnPropDesc extent 41 no-undo.
      arrayvar2[1] = new Progress.Data.ColumnPropDesc("cli-code", "?", Progress.Data.DataType:INTEGER).
      arrayvar2[2] = new Progress.Data.ColumnPropDesc("cli-type", "?", Progress.Data.DataType:CHARACTER).
      arrayvar2[3] = new Progress.Data.ColumnPropDesc("date-cr", "Дата оформления", Progress.Data.DataType:DATE).
      arrayvar2[4] = new Progress.Data.ColumnPropDesc("date-out", "Дата выробатки", Progress.Data.DataType:CHARACTER).
      arrayvar2[5] = new Progress.Data.ColumnPropDesc("db-num", "База данных создания", Progress.Data.DataType:INTEGER).
      arrayvar2[6] = new Progress.Data.ColumnPropDesc("economic-sub", "Хоз. субъект", Progress.Data.DataType:CHARACTER).
      arrayvar2[7] = new Progress.Data.ColumnPropDesc("expiry-date", "Срок годности", Progress.Data.DataType:CHARACTER).
      arrayvar2[8] = new Progress.Data.ColumnPropDesc("expiry-date-2", "Срок годости 2", Progress.Data.DataType:CHARACTER).
      arrayvar2[9] = new Progress.Data.ColumnPropDesc("expiry-out-date", "Срок выпуска", Progress.Data.DataType:CHARACTER).
      arrayvar2[10] = new Progress.Data.ColumnPropDesc("fact-datetime", "?", Progress.Data.DataType:DATETIME_TZ).
      arrayvar2[11] = new Progress.Data.ColumnPropDesc("gds-code", "?", Progress.Data.DataType:INTEGER).
      arrayvar2[12] = new Progress.Data.ColumnPropDesc("gds-guid", "GUID товара", Progress.Data.DataType:CHARACTER).
      arrayvar2[13] = new Progress.Data.ColumnPropDesc("gds-name-merc", "Наименование товара в Меркурии", Progress.Data.DataType:CHARACTER).
      arrayvar2[14] = new Progress.Data.ColumnPropDesc("ID", "?", Progress.Data.DataType:INTEGER).
      arrayvar2[15] = new Progress.Data.ColumnPropDesc("msg-err", "Описание ошибки", Progress.Data.DataType:CHARACTER).
      arrayvar2[16] = new Progress.Data.ColumnPropDesc("note", "Примечание", Progress.Data.DataType:CHARACTER).
      arrayvar2[17] = new Progress.Data.ColumnPropDesc("num-part", "Номер партии", Progress.Data.DataType:CHARACTER).
      arrayvar2[18] = new Progress.Data.ColumnPropDesc("obj-code", "?", Progress.Data.DataType:INTEGER).
      arrayvar2[19] = new Progress.Data.ColumnPropDesc("obj-type", "?", Progress.Data.DataType:CHARACTER).
      arrayvar2[20] = new Progress.Data.ColumnPropDesc("part-key", "Ключ партии", Progress.Data.DataType:CHARACTER).
      arrayvar2[21] = new Progress.Data.ColumnPropDesc("qnty", "Количество", Progress.Data.DataType:DECIMAL).
      arrayvar2[22] = new Progress.Data.ColumnPropDesc("status_", "Статус ВСД", Progress.Data.DataType:INTEGER).
      arrayvar2[23] = new Progress.Data.ColumnPropDesc("type-prod", "?", Progress.Data.DataType:CHARACTER).
      arrayvar2[24] = new Progress.Data.ColumnPropDesc("UUID", "Номер ВСД", Progress.Data.DataType:CHARACTER).
      arrayvar2[25] = new Progress.Data.ColumnPropDesc("vsd-num", "Номер ВСД", Progress.Data.DataType:CHARACTER).
      arrayvar2[26] = new Progress.Data.ColumnPropDesc("vsd-type", "Тип ВСД", Progress.Data.DataType:INTEGER).
      arrayvar2[27] = new Progress.Data.ColumnPropDesc("dateTTH", "Дата ТТН", Progress.Data.DataType:DATE).
      arrayvar2[28] = new Progress.Data.ColumnPropDesc("NomTTH", "Номер ТТН", Progress.Data.DataType:CHARACTER).
      arrayvar2[29] = new Progress.Data.ColumnPropDesc("NomAZS", "Объект", Progress.Data.DataType:CHARACTER).
      arrayvar2[30] = new Progress.Data.ColumnPropDesc("artic", "Артикул товара", Progress.Data.DataType:CHARACTER).
      arrayvar2[31] = new Progress.Data.ColumnPropDesc("vsdtypelbl", "Тип", Progress.Data.DataType:CHARACTER).
      arrayvar2[32] = new Progress.Data.ColumnPropDesc("statusvsd", "Статус ВСД", Progress.Data.DataType:CHARACTER).
      arrayvar2[33] = new Progress.Data.ColumnPropDesc("NomTTHpost", "Номер ТТН поставщика", Progress.Data.DataType:CHARACTER).
      arrayvar2[34] = new Progress.Data.ColumnPropDesc("Post", "Поставщик", Progress.Data.DataType:CHARACTER).
      arrayvar2[35] = new Progress.Data.ColumnPropDesc("gdsname", "Наименование товара", Progress.Data.DataType:CHARACTER).
      arrayvar2[36] = new Progress.Data.ColumnPropDesc("prod-code", "Производитель", Progress.Data.DataType:CHARACTER).
      arrayvar2[37] = new Progress.Data.ColumnPropDesc("COLobj", "Кол-во ВСД", Progress.Data.DataType:DECIMAL).
      arrayvar2[38] = new Progress.Data.ColumnPropDesc("unit-base", "Ед.изм.уч.", Progress.Data.DataType:CHARACTER).
      arrayvar2[39] = new Progress.Data.ColumnPropDesc("unit-cli", "Ед.изм.пост.", Progress.Data.DataType:CHARACTER).
      arrayvar2[40] = new Progress.Data.ColumnPropDesc("ojd", "Ожидает гашения(Ч.)", Progress.Data.DataType:DECIMAL).
      arrayvar2[41] = new Progress.Data.ColumnPropDesc("gdsmercguid", "gdsmercguid", Progress.Data.DataType:CHARACTER).
      tableDesc1:Columns = arrayvar2.
      this-object:bingvsd:TableSchema = tableDesc1.
      this-object:uUIDDataGridViewTextBoxColumn:DataPropertyName = "UUID".
      this-object:uUIDDataGridViewTextBoxColumn:HeaderText = "Номер ВСД".
      this-object:uUIDDataGridViewTextBoxColumn:Name = "uUIDDataGridViewTextBoxColumn".
      this-object:COLobj:DataPropertyName = "COLobj".
      this-object:COLobj:HeaderText = "Кол-во ВСД".
      this-object:COLobj:Name = "COLobj".
      this-object:COLobj:ReadOnly = true.
      define variable nestedvar0 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar0 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Bottom, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:tableLayoutPanel1:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:tableLayoutPanel1:ColumnCount = 5.
      this-object:tableLayoutPanel1:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(120))).
      this-object:tableLayoutPanel1:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(33))).
      this-object:tableLayoutPanel1:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(33))).
      this-object:tableLayoutPanel1:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(34))).
      this-object:tableLayoutPanel1:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(30))).
      this-object:tableLayoutPanel1:Controls:Add(this-object:gdsname, 2, 0).
      this-object:tableLayoutPanel1:Controls:Add(this-object:gdsnamemerc, 2, 1).
      this-object:tableLayoutPanel1:Controls:Add(this-object:gdscode, 1, 0).
      this-object:tableLayoutPanel1:Controls:Add(this-object:gdsmercguid, 3, 0).
      this-object:tableLayoutPanel1:Controls:Add(this-object:label1, 0, 0).
      this-object:tableLayoutPanel1:Controls:Add(this-object:label2, 0, 1).
      this-object:tableLayoutPanel1:Controls:Add(this-object:gdsguid, 3, 1).
      this-object:tableLayoutPanel1:Controls:Add(this-object:Btn_gds, 4, 0).
      this-object:tableLayoutPanel1:Controls:Add(this-object:btn_gds_merc, 4, 1).
      this-object:tableLayoutPanel1:Controls:Add(this-object:NomTTH, 1, 2).
      this-object:tableLayoutPanel1:Controls:Add(this-object:label3, 0, 2).
      this-object:tableLayoutPanel1:Controls:Add(this-object:btn_trndoc, 4, 2).
      this-object:tableLayoutPanel1:Location = new System.Drawing.Point(2, 384).
      this-object:tableLayoutPanel1:Name = "tableLayoutPanel1".
      this-object:tableLayoutPanel1:RowCount = 3.
      this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(30))).
      this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(30))).
      this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(30))).
      this-object:tableLayoutPanel1:Size = new System.Drawing.Size(848, 90).
      this-object:tableLayoutPanel1:TabIndex = 2.
      define variable nestedvar1 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar1 = System.Windows.Forms.AnchorStyles:Left.
      this-object:gdsname:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar1, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:gdsname:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bingvsd, "gdsname", true)).
      this-object:gdsname:Location = new System.Drawing.Point(353, 5).
      this-object:gdsname:Name = "gdsname".
      this-object:gdsname:ReadOnly = true.
      this-object:gdsname:Size = new System.Drawing.Size(224, 20).
      this-object:gdsname:TabIndex = 1.
      define variable nestedvar2 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar2 = System.Windows.Forms.AnchorStyles:Left.
      this-object:gdsnamemerc:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar2, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:gdsnamemerc:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bingvsd, "gds-name-merc", true)).
      this-object:gdsnamemerc:Location = new System.Drawing.Point(353, 35).
      this-object:gdsnamemerc:Name = "gdsnamemerc".
      this-object:gdsnamemerc:ReadOnly = true.
      this-object:gdsnamemerc:Size = new System.Drawing.Size(224, 20).
      this-object:gdsnamemerc:TabIndex = 3.
      define variable nestedvar3 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar3 = System.Windows.Forms.AnchorStyles:Left.
      this-object:gdscode:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar3, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:gdscode:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bingvsd, "gds-code", true, System.Windows.Forms.DataSourceUpdateMode:OnValidation, ?, "N0")).
      this-object:gdscode:Location = new System.Drawing.Point(123, 5).
      this-object:gdscode:Name = "gdscode".
      this-object:gdscode:ReadOnly = true.
      this-object:gdscode:Size = new System.Drawing.Size(224, 20).
      this-object:gdscode:TabIndex = 0.
      define variable nestedvar4 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar4 = System.Windows.Forms.AnchorStyles:Left.
      this-object:gdsmercguid:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar4, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:gdsmercguid:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bingvsd, "gdsmercguid", true)).
      this-object:gdsmercguid:Location = new System.Drawing.Point(583, 5).
      this-object:gdsmercguid:Name = "gdsmercguid".
      this-object:gdsmercguid:ReadOnly = true.
      this-object:gdsmercguid:Size = new System.Drawing.Size(231, 20).
      this-object:gdsmercguid:TabIndex = 2.
      this-object:label1:Dock = System.Windows.Forms.DockStyle:Fill.
      this-object:label1:Location = new System.Drawing.Point(3, 0).
      this-object:label1:Name = "label1".
      this-object:label1:Size = new System.Drawing.Size(114, 30).
      this-object:label1:TabIndex = 4.
      this-object:label1:Text = "Товар TH".
      this-object:label1:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
      this-object:label1:UseCompatibleTextRendering = true.
      this-object:label1:Click:Subscribe(this-object:label1_Click_1).
      this-object:label2:Dock = System.Windows.Forms.DockStyle:Fill.
      this-object:label2:Location = new System.Drawing.Point(3, 30).
      this-object:label2:Name = "label2".
      this-object:label2:Size = new System.Drawing.Size(114, 30).
      this-object:label2:TabIndex = 5.
      this-object:label2:Text = "Товар ВСД".
      this-object:label2:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
      this-object:label2:UseCompatibleTextRendering = true.
      define variable nestedvar5 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar5 = System.Windows.Forms.AnchorStyles:Left.
      this-object:gdsguid:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar5, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:gdsguid:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bingvsd, "gds-guid", true)).
      this-object:gdsguid:Location = new System.Drawing.Point(583, 35).
      this-object:gdsguid:Name = "gdsguid".
      this-object:gdsguid:ReadOnly = true.
      this-object:gdsguid:Size = new System.Drawing.Size(231, 20).
      this-object:gdsguid:TabIndex = 6.
      this-object:Btn_gds:Anchor = System.Windows.Forms.AnchorStyles:Left.
      this-object:Btn_gds:Image = cast(resources:GetObject("Btn_gds.Image"), System.Drawing.Image).
      this-object:Btn_gds:Location = new System.Drawing.Point(820, 3).
      this-object:Btn_gds:Name = "Btn_gds".
      this-object:Btn_gds:Size = new System.Drawing.Size(25, 23).
      this-object:Btn_gds:TabIndex = 7.
      this-object:Btn_gds:UseCompatibleTextRendering = true.
      this-object:Btn_gds:UseVisualStyleBackColor = true.
      this-object:Btn_gds:Click:Subscribe(this-object:Btn_gds_Click).
      this-object:btn_gds_merc:Image = cast(resources:GetObject("btn_gds_merc.Image"), System.Drawing.Image).
      this-object:btn_gds_merc:Location = new System.Drawing.Point(820, 33).
      this-object:btn_gds_merc:Name = "btn_gds_merc".
      this-object:btn_gds_merc:Size = new System.Drawing.Size(25, 23).
      this-object:btn_gds_merc:TabIndex = 8.
      this-object:btn_gds_merc:UseCompatibleTextRendering = true.
      this-object:btn_gds_merc:UseVisualStyleBackColor = true.
      this-object:btn_gds_merc:Click:Subscribe(this-object:btn_gds_merc_Click).
      define variable nestedvar6 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar6 = System.Windows.Forms.AnchorStyles:Left.
      this-object:NomTTH:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar6, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:NomTTH:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bingvsd, "NomTTH", true)).
      this-object:NomTTH:Location = new System.Drawing.Point(123, 65).
      this-object:NomTTH:Name = "NomTTH".
      this-object:NomTTH:ReadOnly = true.
      this-object:NomTTH:Size = new System.Drawing.Size(224, 20).
      this-object:NomTTH:TabIndex = 9.
      this-object:label3:Location = new System.Drawing.Point(3, 60).
      this-object:label3:Name = "label3".
      this-object:label3:Size = new System.Drawing.Size(100, 23).
      this-object:label3:TabIndex = 10.
      this-object:label3:Text = "Накладная".
      this-object:label3:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
      this-object:label3:UseCompatibleTextRendering = true.
      this-object:btn_trndoc:Image = cast(resources:GetObject("btn_trndoc.Image"), System.Drawing.Image).
      this-object:btn_trndoc:Location = new System.Drawing.Point(820, 63).
      this-object:btn_trndoc:Name = "btn_trndoc".
      this-object:btn_trndoc:Size = new System.Drawing.Size(25, 23).
      this-object:btn_trndoc:TabIndex = 11.
      this-object:btn_trndoc:UseCompatibleTextRendering = true.
      this-object:btn_trndoc:UseVisualStyleBackColor = true.
      this-object:btn_trndoc:Click:Subscribe(this-object:btn_trndoc_Click).
      this-object:panel1:Controls:Add(this-object:panel2).
      this-object:panel1:Controls:Add(this-object:btn_prn).
      this-object:panel1:Controls:Add(this-object:btn_edit).
      this-object:panel1:Controls:Add(this-object:Btn_Cancel).
      this-object:panel1:Controls:Add(this-object:Btn_lookup).
      this-object:panel1:Dock = System.Windows.Forms.DockStyle:Top.
      this-object:panel1:Location = new System.Drawing.Point(0, 0).
      this-object:panel1:Name = "panel1".
      this-object:panel1:Size = new System.Drawing.Size(850, 100).
      this-object:panel1:TabIndex = 3.
      this-object:panel2:BackColor = System.Drawing.SystemColors:Control.
      this-object:panel2:Controls:Add(this-object:Btn_clen).
      this-object:panel2:Controls:Add(this-object:Sent).
      this-object:panel2:Controls:Add(this-object:btn_Filt).
      this-object:panel2:Controls:Add(this-object:numericUpDown1).
      this-object:panel2:Controls:Add(this-object:btn_ref).
      this-object:panel2:Controls:Add(this-object:Rep).
      this-object:panel2:Controls:Add(this-object:FalVerif).
      this-object:panel2:Controls:Add(this-object:ToExtin).
      this-object:panel2:Controls:Add(this-object:FalExting).
      this-object:panel2:Controls:Add(this-object:ReqVerif).
      this-object:panel2:Controls:Add(this-object:dateTimePicker2).
      this-object:panel2:Controls:Add(this-object:label7).
      this-object:panel2:Controls:Add(this-object:label6).
      this-object:panel2:Controls:Add(this-object:dateTimePicker1).
      this-object:panel2:Controls:Add(this-object:label5).
      this-object:panel2:Location = new System.Drawing.Point(41, 42).
      this-object:panel2:Name = "panel2".
      this-object:panel2:Size = new System.Drawing.Size(765, 55).
      this-object:panel2:TabIndex = 5.
      this-object:Btn_clen:Location = new System.Drawing.Point(575, 5).
      this-object:Btn_clen:Name = "Btn_clen".
      this-object:Btn_clen:Size = new System.Drawing.Size(75, 23).
      this-object:Btn_clen:TabIndex = 15.
      this-object:Btn_clen:Text = "Сброс".
      this-object:Btn_clen:UseCompatibleTextRendering = true.
      this-object:Btn_clen:UseVisualStyleBackColor = true.
      this-object:Btn_clen:Click:Subscribe(this-object:Btn_clen_Click).
      this-object:Sent:DataBindings:Add(new System.Windows.Forms.Binding("CheckState", this-object:bindttFilt, "sent", true)).
      this-object:Sent:Location = new System.Drawing.Point(575, 29).
      this-object:Sent:Name = "Sent".
      this-object:Sent:Size = new System.Drawing.Size(82, 18).
      this-object:Sent:TabIndex = 14.
      this-object:Sent:Text = "Отправлен".
      this-object:Sent:UseCompatibleTextRendering = true.
      this-object:Sent:UseVisualStyleBackColor = true.
      this-object:bindttFilt:MaxDataGuess = 0.
      this-object:bindttFilt:NoLOBs = false.
      this-object:bindttFilt:Position = 0.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar3 as "Progress.Data.TableDesc[]" no-undo.
      arrayvar3 = new "Progress.Data.TableDesc[]"(0).
      tableDesc2:ChildTables = arrayvar3.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar4 as Progress.Data.ColumnPropDesc extent 10 no-undo.
      arrayvar4[1] = new Progress.Data.ColumnPropDesc("date-end", "date-end", Progress.Data.DataType:DATE).
      arrayvar4[2] = new Progress.Data.ColumnPropDesc("date-start", "date-start", Progress.Data.DataType:DATE).
      arrayvar4[3] = new Progress.Data.ColumnPropDesc("fTime", "fTime", Progress.Data.DataType:INTEGER).
      arrayvar4[4] = new Progress.Data.ColumnPropDesc("FalExting", "FalExting", Progress.Data.DataType:LOGICAL).
      arrayvar4[5] = new Progress.Data.ColumnPropDesc("FalVerif", "FalVerif", Progress.Data.DataType:LOGICAL).
      arrayvar4[6] = new Progress.Data.ColumnPropDesc("Rep", "Rep", Progress.Data.DataType:LOGICAL).
      arrayvar4[7] = new Progress.Data.ColumnPropDesc("ReqVerif", "ReqVerif", Progress.Data.DataType:LOGICAL).
      arrayvar4[8] = new Progress.Data.ColumnPropDesc("ToExtin", "ToExtin", Progress.Data.DataType:LOGICAL).
      arrayvar4[9] = new Progress.Data.ColumnPropDesc("doc-code", "doc-code", Progress.Data.DataType:CHARACTER).
      arrayvar4[10] = new Progress.Data.ColumnPropDesc("sent", " отправлен", Progress.Data.DataType:LOGICAL).
      tableDesc2:Columns = arrayvar4.
      this-object:bindttFilt:TableSchema = tableDesc2.
      this-object:btn_Filt:Location = new System.Drawing.Point(663, 26).
      this-object:btn_Filt:Name = "btn_Filt".
      this-object:btn_Filt:Size = new System.Drawing.Size(99, 23).
      this-object:btn_Filt:TabIndex = 13.
      this-object:btn_Filt:Text = "Расшир. фильтр".
      this-object:btn_Filt:UseCompatibleTextRendering = true.
      this-object:btn_Filt:UseVisualStyleBackColor = true.
      this-object:btn_Filt:Click:Subscribe(this-object:btn_Filt_Click).
      this-object:numericUpDown1:DataBindings:Add(new System.Windows.Forms.Binding("Value", this-object:bindttFilt, "fTime", true, System.Windows.Forms.DataSourceUpdateMode:OnValidation, ?, "N0")).
      this-object:numericUpDown1:Location = new System.Drawing.Point(109, 3).
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true", Type="System.Int32").
      define variable arrayvar5 as INTEGER extent 4 no-undo.
      arrayvar5[1] = 999999.
      arrayvar5[2] = 0.
      arrayvar5[3] = 0.
      arrayvar5[4] = 0.
      this-object:numericUpDown1:Maximum = Progress.Util.DecimalHelper:Create(arrayvar5).
      this-object:numericUpDown1:Name = "numericUpDown1".
      this-object:numericUpDown1:Size = new System.Drawing.Size(79, 20).
      this-object:numericUpDown1:TabIndex = 12.
      this-object:btn_ref:Location = new System.Drawing.Point(663, 3).
      this-object:btn_ref:Name = "btn_ref".
      this-object:btn_ref:Size = new System.Drawing.Size(99, 23).
      this-object:btn_ref:TabIndex = 11.
      this-object:btn_ref:Text = "Обновить".
      this-object:btn_ref:UseCompatibleTextRendering = true.
      this-object:btn_ref:UseVisualStyleBackColor = true.
      this-object:btn_ref:Click:Subscribe(this-object:btn_ref_Click).
      this-object:Rep:DataBindings:Add(new System.Windows.Forms.Binding("CheckState", this-object:bindttFilt, "Rep", true)).
      this-object:Rep:Location = new System.Drawing.Point(500, 26).
      this-object:Rep:Name = "Rep".
      this-object:Rep:Size = new System.Drawing.Size(78, 24).
      this-object:Rep:TabIndex = 10.
      this-object:Rep:Text = "Погашен".
      this-object:Rep:UseCompatibleTextRendering = true.
      this-object:Rep:UseVisualStyleBackColor = true.
      this-object:FalVerif:DataBindings:Add(new System.Windows.Forms.Binding("CheckState", this-object:bindttFilt, "FalVerif", true)).
      this-object:FalVerif:Location = new System.Drawing.Point(130, 26).
      this-object:FalVerif:Name = "FalVerif".
      this-object:FalVerif:Size = new System.Drawing.Size(152, 24).
      this-object:FalVerif:TabIndex = 9.
      this-object:FalVerif:Text = "Ошибка проверки ВСД".
      this-object:FalVerif:UseCompatibleTextRendering = true.
      this-object:FalVerif:UseVisualStyleBackColor = true.
      this-object:ToExtin:DataBindings:Add(new System.Windows.Forms.Binding("CheckState", this-object:bindttFilt, "ToExtin", true)).
      this-object:ToExtin:Location = new System.Drawing.Point(288, 26).
      this-object:ToExtin:Name = "ToExtin".
      this-object:ToExtin:Size = new System.Drawing.Size(82, 24).
      this-object:ToExtin:TabIndex = 8.
      this-object:ToExtin:Text = "К гашению".
      this-object:ToExtin:UseCompatibleTextRendering = true.
      this-object:ToExtin:UseVisualStyleBackColor = true.
      this-object:FalExting:DataBindings:Add(new System.Windows.Forms.Binding("CheckState", this-object:bindttFilt, "FalExting", true)).
      this-object:FalExting:Location = new System.Drawing.Point(376, 26).
      this-object:FalExting:Name = "FalExting".
      this-object:FalExting:Size = new System.Drawing.Size(118, 24).
      this-object:FalExting:TabIndex = 7.
      this-object:FalExting:Text = "Ошибка гашения".
      this-object:FalExting:UseCompatibleTextRendering = true.
      this-object:FalExting:UseVisualStyleBackColor = true.
      this-object:ReqVerif:DataBindings:Add(new System.Windows.Forms.Binding("CheckState", this-object:bindttFilt, "ReqVerif", true)).
      this-object:ReqVerif:Location = new System.Drawing.Point(3, 26).
      this-object:ReqVerif:Name = "ReqVerif".
      this-object:ReqVerif:Size = new System.Drawing.Size(121, 24).
      this-object:ReqVerif:TabIndex = 6.
      this-object:ReqVerif:Text = "Требует проверки".
      this-object:ReqVerif:UseCompatibleTextRendering = true.
      this-object:ReqVerif:UseVisualStyleBackColor = true.
      this-object:dateTimePicker2:DataBindings:Add(new System.Windows.Forms.Binding("Value", this-object:bindttFilt, "date-end", true, System.Windows.Forms.DataSourceUpdateMode:OnValidation, ?, "D")).
      this-object:dateTimePicker2:Location = new System.Drawing.Point(408, 4).
      this-object:dateTimePicker2:Name = "dateTimePicker2".
      this-object:dateTimePicker2:Size = new System.Drawing.Size(137, 20).
      this-object:dateTimePicker2:TabIndex = 5.
      this-object:label7:Location = new System.Drawing.Point(368, 4).
      this-object:label7:Name = "label7".
      this-object:label7:Size = new System.Drawing.Size(34, 20).
      this-object:label7:TabIndex = 4.
      this-object:label7:Text = "По:".
      this-object:label7:TextAlign = System.Drawing.ContentAlignment:MiddleCenter.
      this-object:label7:UseCompatibleTextRendering = true.
      this-object:label6:ImageAlign = System.Drawing.ContentAlignment:MiddleLeft.
      this-object:label6:Location = new System.Drawing.Point(194, 3).
      this-object:label6:Name = "label6".
      this-object:label6:Size = new System.Drawing.Size(23, 20).
      this-object:label6:TabIndex = 3.
      this-object:label6:Text = "C:".
      this-object:label6:TextAlign = System.Drawing.ContentAlignment:MiddleCenter.
      this-object:label6:UseCompatibleTextRendering = true.
      this-object:dateTimePicker1:DataBindings:Add(new System.Windows.Forms.Binding("Value", this-object:bindttFilt, "date-start", true, System.Windows.Forms.DataSourceUpdateMode:OnValidation, ?, "D")).
      this-object:dateTimePicker1:Location = new System.Drawing.Point(223, 4).
      this-object:dateTimePicker1:Name = "dateTimePicker1".
      this-object:dateTimePicker1:Size = new System.Drawing.Size(139, 20).
      this-object:dateTimePicker1:TabIndex = 2.
      this-object:dateTimePicker1:Value = Progress.Util.DateTimeHelper:Create(2018, 6, 15, 0, 0, 0, 0).
      this-object:label5:ImageAlign = System.Drawing.ContentAlignment:MiddleLeft.
      this-object:label5:Location = new System.Drawing.Point(3, 3).
      this-object:label5:Name = "label5".
      this-object:label5:Size = new System.Drawing.Size(100, 20).
      this-object:label5:TabIndex = 0.
      this-object:label5:Text = "Время гашения :".
      this-object:label5:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
      this-object:label5:UseCompatibleTextRendering = true.
      this-object:btn_prn:Location = new System.Drawing.Point(285, 12).
      this-object:btn_prn:Name = "btn_prn".
      this-object:btn_prn:Size = new System.Drawing.Size(75, 23).
      this-object:btn_prn:TabIndex = 4.
      this-object:btn_prn:Text = "Печать".
      this-object:btn_prn:UseCompatibleTextRendering = true.
      this-object:btn_prn:UseVisualStyleBackColor = true.
      this-object:btn_prn:Click:Subscribe(this-object:btn_prn_Click).
      this-object:btn_edit:Location = new System.Drawing.Point(123, 12).
      this-object:btn_edit:Name = "btn_edit".
      this-object:btn_edit:Size = new System.Drawing.Size(75, 23).
      this-object:btn_edit:TabIndex = 2.
      this-object:btn_edit:Text = "Изменить".
      this-object:btn_edit:UseCompatibleTextRendering = true.
      this-object:btn_edit:UseVisualStyleBackColor = true.
      this-object:btn_edit:Click:Subscribe(this-object:btn_edit_Click).
      this-object:Btn_Cancel:Location = new System.Drawing.Point(41, 13).
      this-object:Btn_Cancel:Name = "Btn_Cancel".
      this-object:Btn_Cancel:Size = new System.Drawing.Size(75, 23).
      this-object:Btn_Cancel:TabIndex = 1.
      this-object:Btn_Cancel:Text = "Выход".
      this-object:Btn_Cancel:UseCompatibleTextRendering = true.
      this-object:Btn_Cancel:UseVisualStyleBackColor = true.
      this-object:Btn_Cancel:Click:Subscribe(this-object:Btn_Cancel_Click).
      define variable nestedvar7 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar7 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Bottom, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:msgerr:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar7, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:msgerr:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bingvsd, "msg-err", true)).
      this-object:msgerr:Location = new System.Drawing.Point(12, 503).
      this-object:msgerr:Multiline = true.
      this-object:msgerr:Name = "msgerr".
      this-object:msgerr:ReadOnly = true.
      this-object:msgerr:Size = new System.Drawing.Size(826, 40).
      this-object:msgerr:TabIndex = 4.
      this-object:label4:Anchor = System.Windows.Forms.AnchorStyles:Bottom.
      this-object:label4:Location = new System.Drawing.Point(24, 477).
      this-object:label4:Name = "label4".
      this-object:label4:Size = new System.Drawing.Size(792, 23).
      this-object:label4:TabIndex = 5.
      this-object:label4:Text = "Описание ошибки".
      this-object:label4:TextAlign = System.Drawing.ContentAlignment:MiddleCenter.
      this-object:label4:UseCompatibleTextRendering = true.
      this-object:dateTTHDataGridViewTextBoxColumn:DataPropertyName = "dateTTH".
      this-object:dateTTHDataGridViewTextBoxColumn:HeaderText = "Дата ТТН".
      this-object:dateTTHDataGridViewTextBoxColumn:Name = "dateTTHDataGridViewTextBoxColumn".
      this-object:dateTTHDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:nomTTHDataGridViewTextBoxColumn:DataPropertyName = "NomTTH".
      this-object:nomTTHDataGridViewTextBoxColumn:HeaderText = "Номер ТТН".
      this-object:nomTTHDataGridViewTextBoxColumn:Name = "nomTTHDataGridViewTextBoxColumn".
      this-object:nomTTHDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:nomAZSDataGridViewTextBoxColumn:DataPropertyName = "NomAZS".
      this-object:nomAZSDataGridViewTextBoxColumn:HeaderText = "Объект".
      this-object:nomAZSDataGridViewTextBoxColumn:Name = "nomAZSDataGridViewTextBoxColumn".
      this-object:nomAZSDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:articDataGridViewTextBoxColumn:DataPropertyName = "artic".
      this-object:articDataGridViewTextBoxColumn:HeaderText = "Артикул товара".
      this-object:articDataGridViewTextBoxColumn:Name = "articDataGridViewTextBoxColumn".
      this-object:articDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:vsdtypelblDataGridViewTextBoxColumn:DataPropertyName = "vsdtypelbl".
      this-object:vsdtypelblDataGridViewTextBoxColumn:HeaderText = "Тип".
      this-object:vsdtypelblDataGridViewTextBoxColumn:Name = "vsdtypelblDataGridViewTextBoxColumn".
      this-object:vsdtypelblDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:uUIDDataGridViewTextBoxColumn1:DataPropertyName = "UUID".
      this-object:uUIDDataGridViewTextBoxColumn1:HeaderText = "Номер ВСД".
      this-object:uUIDDataGridViewTextBoxColumn1:Name = "uUIDDataGridViewTextBoxColumn1".
      this-object:uUIDDataGridViewTextBoxColumn1:ReadOnly = true.
      this-object:statusvsdDataGridViewTextBoxColumn:DataPropertyName = "statusvsd".
      this-object:statusvsdDataGridViewTextBoxColumn:HeaderText = "Статус ВСД".
      this-object:statusvsdDataGridViewTextBoxColumn:Name = "statusvsdDataGridViewTextBoxColumn".
      this-object:statusvsdDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:nomTTHpostDataGridViewTextBoxColumn:DataPropertyName = "NomTTHpost".
      this-object:nomTTHpostDataGridViewTextBoxColumn:HeaderText = "Номер ТТН поставщика".
      this-object:nomTTHpostDataGridViewTextBoxColumn:Name = "nomTTHpostDataGridViewTextBoxColumn".
      this-object:nomTTHpostDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:postDataGridViewTextBoxColumn:DataPropertyName = "Post".
      this-object:postDataGridViewTextBoxColumn:HeaderText = "Поставщик".
      this-object:postDataGridViewTextBoxColumn:Name = "postDataGridViewTextBoxColumn".
      this-object:postDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:gdsnameDataGridViewTextBoxColumn:DataPropertyName = "gdsname".
      this-object:gdsnameDataGridViewTextBoxColumn:HeaderText = "Наименование товара".
      this-object:gdsnameDataGridViewTextBoxColumn:Name = "gdsnameDataGridViewTextBoxColumn".
      this-object:gdsnameDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:prodcodeDataGridViewTextBoxColumn:DataPropertyName = "prod-code".
      this-object:prodcodeDataGridViewTextBoxColumn:HeaderText = "Производитель".
      this-object:prodcodeDataGridViewTextBoxColumn:Name = "prodcodeDataGridViewTextBoxColumn".
      this-object:prodcodeDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:cOLobjDataGridViewTextBoxColumn:DataPropertyName = "COLobj".
      dataGridViewCellStyle1:Format = "N3".
      dataGridViewCellStyle1:NullValue = ?.
      this-object:cOLobjDataGridViewTextBoxColumn:DefaultCellStyle = dataGridViewCellStyle1.
      this-object:cOLobjDataGridViewTextBoxColumn:HeaderText = "Кол-во ВСД".
      this-object:cOLobjDataGridViewTextBoxColumn:Name = "cOLobjDataGridViewTextBoxColumn".
      this-object:cOLobjDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:unitcliDataGridViewTextBoxColumn:DataPropertyName = "unit-cli".
      this-object:unitcliDataGridViewTextBoxColumn:HeaderText = "Ед.изм.ВСД".
      this-object:unitcliDataGridViewTextBoxColumn:Name = "unitcliDataGridViewTextBoxColumn".
      this-object:unitcliDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:ojdDataGridViewTextBoxColumn:DataPropertyName = "ojd".
      this-object:ojdDataGridViewTextBoxColumn:HeaderText = "Ожидает гашения(Ч.)".
      this-object:ojdDataGridViewTextBoxColumn:Name = "ojdDataGridViewTextBoxColumn".
      this-object:ojdDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:ClientSize = new System.Drawing.Size(850, 546).
      this-object:Controls:Add(this-object:label4).
      this-object:Controls:Add(this-object:msgerr).
      this-object:Controls:Add(this-object:tableLayoutPanel1).
      this-object:Controls:Add(this-object:dataGridView1).
      this-object:Controls:Add(this-object:panel1).
      this-object:Name = "journal_vsd_abl".
      this-object:Text = "Журнал ВСД".
      this-object:Load:Subscribe(this-object:journal_vsd_abl_Load).
      cast(this-object:dataGridView1, System.ComponentModel.ISupportInitialize):EndInit().
      cast(this-object:bingvsd, System.ComponentModel.ISupportInitialize):EndInit().
      this-object:tableLayoutPanel1:ResumeLayout(false).
      this-object:tableLayoutPanel1:PerformLayout().
      this-object:panel1:ResumeLayout(false).
      this-object:panel2:ResumeLayout(false).
      cast(this-object:bindttFilt, System.ComponentModel.ISupportInitialize):EndInit().
      cast(this-object:numericUpDown1, System.ComponentModel.ISupportInitialize):EndInit().
      this-object:ResumeLayout(false).
      this-object:PerformLayout().
this-object:dateTimePicker1:KeyDown:Subscribe(this-object:date_KeyDown).
this-object:dateTimePicker2:KeyDown:Subscribe(this-object:date_KeyDown).
this-object:KeyPreview = true.
this-object:KeyDown:Subscribe(this-object:obj_KeyDown).
catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
end method.
method void proc-alt-shift-f2 ():
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
method void proc-alt-shift-f3 ():
   define variable vdebugalert   as logical no-undo .
   assign
      vdebugalert = session:debug-alert
      session:debug-alert = yes
   .
message program-name( 1 ) skip( 1 )
          vss-revision                  skip( 0 )
          vss-author                    skip( 0 )
          vss-date                      skip( 0 )
          vss-workfile                  skip( 0 )
          vss-archive                   skip( 1 )
          vss-description               skip( 1 )
  view-as alert-box title "Текущая программа".
  session:debug-alert = vdebugalert.
end.
define variable v-inform-launched as logical no-undo initial false .
method void proc-alt-shift-f4 ():
end.
method void proc-alt-f1 ():
end .
method private void obj_KeyDown( input sender as System.Object, input e as System.Windows.Forms.KeyEventArgs ):
      if   e:KeyCode = System.Windows.Forms.Keys:F3 and e:Shift and e:Alt
      then do:
          proc-alt-shift-f3 ().
      end.
      else if   e:KeyCode = System.Windows.Forms.Keys:F2 and e:Shift and e:Alt
      then do:
          proc-alt-shift-f2 ().
      end.
end method.
method private void End_obj_KeyDown():
catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
end method.
method private void date_KeyDown( input sender as System.Object, input e as System.Windows.Forms.KeyEventArgs ):
   define variable vdate as System.Windows.Forms.DateTimePicker no-undo.
   define variable v-curr-sv-date as date no-undo .
   define variable v-new-sv-date  as date no-undo .
   if   e:KeyCode = System.Windows.Forms.Keys:D and e:Control
   then do:
      vdate = cast(sender ,System.Windows.Forms.DateTimePicker).
      run gbl/getcurdt.p
         (output v-curr-sv-date
      ) .
      vdate:value = v-curr-sv-date.
   end.
   else if   e:KeyCode = System.Windows.Forms.Keys:B and e:Control
   then do:
      vdate = cast(sender ,System.Windows.Forms.DateTimePicker).
      v-curr-sv-date = vdate:value .
      if v-curr-sv-date = ?
      then do:
         run gbl/getcurdt.p
            (output v-curr-sv-date
         ) .
      end.
      if v-curr-sv-date <> ?
      then do:
         assign
            v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
            vdate:value = v-new-sv-date
         .
      end.
   end.
   else if   e:KeyCode = System.Windows.Forms.Keys:E and e:Control
   then do:
      vdate = cast(sender ,System.Windows.Forms.DateTimePicker).
      v-curr-sv-date = vdate:value.
      if v-curr-sv-date = ?
      then do:
         run gbl/getcurdt.p
            (output v-curr-sv-date
         ) .
      end.
      if v-curr-sv-date <> ?
      then do:
         run gbl/lastdate.p
            (input  v-curr-sv-date
            ,output v-new-sv-date
         ).
         vdate:value = v-new-sv-date.
      end.
   end.
   else if   e:KeyCode = System.Windows.Forms.Keys:F and e:Control
   then do:
      vdate = cast(sender ,System.Windows.Forms.DateTimePicker).
      define variable v-description   as character no-undo .
      define variable v-ok            as logical no-undo.
      v-curr-sv-date = vdate:value.
      if v-curr-sv-date = ?
      then do:
         run gbl/getcurdt.p
            (output v-curr-sv-date
         ) .
      end.
      if v-curr-sv-date <> ?
      then do:
         run gbl/d-inpday.w
            (input ?
            ,input "Выбор даты"
            ,input v-description
            ,input ""
            ,input-output v-curr-sv-date
            ,output v-ok
         ).
         if v-ok = true
         then do:
            vdate:value = v-curr-sv-date .
         end.
      end.
   end.
end method.
method private void End_date_KeyDown():
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
    END METHOD.
        @VisualDesigner.
        METHOD PRIVATE VOID journal_vsd_abl_Load( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
                RETURN.
        END METHOD.
        @VisualDesigner.
        METHOD PRIVATE VOID label1_Click_1( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
                RETURN.
        END METHOD.
        METHOD PUBLIC VOID ShowModalDialog(  ):
      WAIT-FOR THIS-OBJECT:ShowDialog().
    END METHOD.
    DESTRUCTOR PUBLIC journal_vsd_abl ( ):
        DELETE  OBJECT vjournalvsdTrg NO-ERROR.
    END DESTRUCTOR.
END CLASS.
