 
/*------------------------------------------------------------------------
   File        : Сover_Sheet
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : eshklyar
   Created     : Tue Nov 05 09:17:49 MSK 2019
   Notes       : 
 ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Progress.Windows.Form.
using System.ComponentModel.RefreshEventHandler from assembly.
using ibs.th.ref.*.

block-level on error undo, throw.

class ibs.th.ref.Cover_Sheet inherits Form: 

  {cmp/str-glbl.i class}
  { gbl/getcntxt.i def }
  { ibs/th/ref/Coins_Bank_tt.i }
  { ref/clean_char.i}  
  define private variable b_bank_recip   as System.Windows.Forms.Button      no-undo.
  define private variable b_deposit_bank as System.Windows.Forms.Button      no-undo.
  define private variable b_save         as System.Windows.Forms.Button      no-undo.
  define private variable b_print        as System.Windows.Forms.Button      no-undo.
  define private variable b_exit         as System.Windows.Forms.Button      no-undo.
  define private variable bank_recip     as System.Windows.Forms.TextBox     no-undo.
  define private variable components     as System.ComponentModel.IContainer no-undo.
  define private variable label5         as System.Windows.Forms.Label       no-undo.
  define private variable label4         as System.Windows.Forms.Label       no-undo.
  define private variable label3         as System.Windows.Forms.Label       no-undo.
  define private variable num_bag        as System.Windows.Forms.TextBox     no-undo.
  define private variable label2         as System.Windows.Forms.Label       no-undo.
  define private variable deposit_bank   as System.Windows.Forms.TextBox     no-undo.
  define private variable label1         as System.Windows.Forms.Label       no-undo.
  define private variable source_rec     as System.Windows.Forms.ComboBox    no-undo.
  define private variable pin02          as System.Windows.Forms.TextBox     no-undo.
  define private variable v-host-code    as integer                          no-undo .
  define private variable v-fin-code     as integer                          no-undo .
  define private variable v-CashBookId   as integer                          no-undo .
  define private variable v-sum-doc      as decimal                          no-undo .
  
  define private variable v-status       as character                        no-undo init "тек".
  define private variable v-rid-list     as character                        no-undo . 
  define private variable v-total-sum    as decimal                          no-undo .
  
  
  DEFINE BUFFER find_fin-bank     FOR ub.fin-bank.
  DEFINE BUFFER find_fin-doc-attr FOR ub.fin-doc-attr.
  define private variable v-deposit_bank   as integer                  no-undo .
  define private variable v-recip_bank     as integer                  no-undo .
  define         variable v-recip_schet    as character                no-undo .
  define         variable vBankDepos-host  as integer                  no-undo.
  define         variable vBankDepos-code  as integer                  no-undo.
  define         variable vBankRecip-host  as integer                  no-undo.
  define         variable vBankRecip-code  as integer                  no-undo.
  define private variable windowContainer1 as ibs.th.ref.Coins_Banknot no-undo.
  define public  variable v-num-bag        as character                no-undo .
  define         variable mCashBook        as class                    ibs.th.ref.cashbookstorage no-undo .
  define property parparentproc as handle no-undo
    private get.
    set(input iH as handle):
      parparentproc = ih.
    end.
        
  constructor public Cover_Sheet (p-host-code as integer, p-fin-code as integer, p-CashBookId as integer, p-sum-doc as decimal, p-mode as character ):
    
    super().
    v-host-code = p-host-code .    
    v-fin-code  = p-fin-code .
    v-CashBookId = p-CashBookId .
    v-sum-doc = p-sum-doc .
    
    InitializeComponent().
    Visual(p-mode) .

    this-object:ComponentsCollection:ADD(this-object:components).
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.

  end constructor.
  
  constructor public Cover_Sheet ( ):
    
    super().
    InitializeComponent().
    this-object:ComponentsCollection:ADD(this-object:components).
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.

  end constructor.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void b_bank_recip_Click( input sender as System.Object, input e as System.EventArgs ):
    
    run ref/finbanks.w (input parParentProc
      , input v-host-code
      , input "b-sel":U
      , input {&company}
      , input v-host-code
      , input-output v-status
      , input-output v-rid-list) no-error .
    if v-rid-list <> "" then 
    do:
      FIND FIRST find_fin-bank No-LOCK where
        recid(find_fin-bank) = integer(entry(1, v-rid-list)) No-ERROR.
      if not avail find_fin-bank then 
      do:
        message
          "Неверное значение параметра вызова v-rid-list" v-rid-list
          view-as alert-box error .
        return error.
      end.
      this-object:bank_recip:Text = find_fin-bank.bank-name.
      v-recip_bank = find_fin-bank.code-bank .
      find first ub.fin-schet no-lock where ub.fin-schet.code-bank = v-recip_bank no-error .
      if available (ub.fin-schet) then v-recip_schet = ub.fin-schet.r-schet .
    end.         
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void b_deposit_bank_Click( input sender as System.Object, input e as System.EventArgs ):
	  
    run ref/finbanks.w (input parParentProc
      , input v-host-code
      , input "b-sel":U
      , input {&company}
      , input v-host-code
      , input-output v-status
      , input-output v-rid-list) no-error .
    if v-rid-list <> "" then 
    do:
      FIND FIRST find_fin-bank No-LOCK where
        recid(find_fin-bank) = integer(entry(1, v-rid-list)) No-ERROR.
      if not avail find_fin-bank then 
      do:
        message
          "Неверное значение параметра вызова v-rid-list" v-rid-list
          view-as alert-box error .
        return error.
      end.
      this-object:deposit_bank:Text = find_fin-bank.bank-name.
      v-deposit_bank = find_fin-bank.code-bank .
    end.              
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void b_exit_Click( input sender as System.Object, input e as System.EventArgs ):
    Close().
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void b_save_Click( input sender as System.Object, input e as System.EventArgs ):

    define variable CSJson as longchar no-undo .
    define variable CShtt  as handle   no-undo .
    define buffer bf_fin-doc-attr for ub.fin-doc-attr .
    define variable attr-value as character no-undo .
    define variable v-source   as character no-undo .
    define buffer buf_fin-doc for ub.fin-doc .
    
    
    if v-sum-doc <> windowContainer1:v-total-sum and v-sum-doc <> decimal(windowContainer1:Fsumm:Text) then 
    do:
      message "Сумма документа " + string(v-sum-doc) + " не равна сумме " + string(windowContainer1:v-total-sum) + " из препроводительной ведомости."
        view-as alert-box.
      return no-apply .
    end.   
      
    if this-object:num_bag:Text = "" then 
    do:
      message "Номер сумки не заполнен"
        view-as alert-box.
      return no-apply .
    end.   
    find first bf_fin-doc-attr exclusive-lock where bf_fin-doc-attr.attr-code = "pre-vedom" and bf_fin-doc-attr.host-code = v-host-code
      and bf_fin-doc-attr.fin-doc-code = v-fin-code no-error . 
    if not available (bf_fin-doc-attr) then 
    do:
      create bf_fin-doc-attr .
      assign
        bf_fin-doc-attr.attr-code    = "pre-vedom"
        bf_fin-doc-attr.fin-doc-code = v-fin-code
        bf_fin-doc-attr.host-code    = v-host-code
        .
    end.  
    if this-object:source_rec:Text = "Поступления от продажи товаров" then v-source = "02" .
    else v-source = "32" .
    attr-value = clean_char(this-object:num_bag:Text) + ";" + string(v-deposit_bank) + ";" + string(v-recip_bank) + ";" + 
      this-object:pin02:Text + ";" + this-object:source_rec:Text + ";" + string(windowContainer1:v-total-sum) + ";" + v-recip_schet . 
    bf_fin-doc-attr.attr-value = attr-value .
    
    dataset ds-banknots:handle:write-json ("longchar",CSJson) .
    if CSJson <> ? then 
    do:
    
      find first find_fin-doc-attr where find_fin-doc-attr.host-code = v-host-code and find_fin-doc-attr.attr-code = "cover_sheet" 
        and find_fin-doc-attr.fin-doc-code = v-fin-code no-error .
      if not available (find_fin-doc-attr) then
      do:
        create find_fin-doc-attr .
        assign
          find_fin-doc-attr.attr-code    = "cover_sheet"
          find_fin-doc-attr.fin-doc-code = v-fin-code
          find_fin-doc-attr.host-code    = v-host-code  
          .
      end.  
    
      find_fin-doc-attr.attr-value = CSJson . 
    end.
    this-object:DialogResult = System.Windows.Forms.DialogResult:Ok.
    Close().

    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void Cover_Sheet_Load( input sender as System.Object, input e as System.EventArgs ):
    define variable ii     as integer  no-undo .
    define variable CSJson as longchar no-undo .
    define variable CShtt  as handle   no-undo .
    define buffer bf_fin-doc-attr for ub.fin-doc-attr .
    define variable attr-value as character no-undo .
    define buffer buf_cashbook for ub.CashBook .
    { gbl/getcntxt.i def }
    { gbl/getcntxt.i get }
    find first bf_fin-doc-attr exclusive-lock where bf_fin-doc-attr.attr-code = "pre-vedom" and bf_fin-doc-attr.host-code = v-host-code
      and bf_fin-doc-attr.fin-doc-code = v-fin-code and bf_fin-doc-attr.attr-value begins this-object:num_bag:Text no-error . 
    if available (bf_fin-doc-attr) then 
    do:
      assign
        this-object:num_bag:Text     = entry(1,bf_fin-doc-attr.attr-value,";")
        this-object:pin02:Text       = entry(4,bf_fin-doc-attr.attr-value,";")
        this-object:source_rec:Text  = entry(5,bf_fin-doc-attr.attr-value,";")
        windowContainer1:v-total-sum = decimal(entry(6,bf_fin-doc-attr.attr-value,";"))
        v-recip_schet                = entry(7,bf_fin-doc-attr.attr-value,";")
        .
        
      FIND FIRST find_fin-bank No-LOCK where find_fin-bank.code-bank = integer(entry(2,bf_fin-doc-attr.attr-value,";")) and find_fin-bank.host-code = v-host-code No-ERROR.
      if avail find_fin-bank then 
      do:
        this-object:deposit_bank:Text = find_fin-bank.bank-name .
        v-deposit_bank = find_fin-bank.code-bank .
      end. 
      FIND FIRST find_fin-bank No-LOCK where find_fin-bank.code-bank = integer(entry(3,bf_fin-doc-attr.attr-value,";")) and find_fin-bank.host-code = v-host-code No-ERROR.
      if avail find_fin-bank then 
      do:
        this-object:bank_recip:Text = find_fin-bank.bank-name .
        v-recip_bank = find_fin-bank.code-bank .
      end.
    end.  
    else 
    do:
      for first buf_cashbook no-lock where buf_cashbook.id = v-CashBookId:
        if buf_cashbook.id = 0 then 
        do:
          this-object:source_rec:Text = "Поступления от продажи товаров" .
        end.
        else 
        do:  
          this-object:source_rec:Text = "Прочие поступления".
        end.
        define variable mCashBook as class ibs.th.ref.cashbookstorage NO-UNDO.
        mCashBook = new  ibs.th.ref.cashbookstorage().
        vBankDepos-host = int(mCashBook:getSinglRule(v-CashBookId, {&by_all}, 0, "BankDepos-host")) .
        vBankDepos-code = int(mCashBook:getSinglRule(v-CashBookId, {&by_all}, 0, "BankDepos-code") ).
        vBankRecip-host = int(mCashBook:getSinglRule(v-CashBookId, {&by_all}, 0, "BankRecip-host")) .
        vBankRecip-code = int(mCashBook:getSinglRule(v-CashBookId, {&by_all}, 0, "BankRecip-code") ).
        v-recip_schet = mCashBook:getSinglRule(v-CashBookId, {&by_all}, 0, "BankRecip-acct") .
        delete object mCashBook no-error.
          
        FIND FIRST find_fin-bank No-LOCK where find_fin-bank.code-bank = vBankDepos-code 
          and find_fin-bank.host-code = vBankDepos-host No-ERROR.
        if avail find_fin-bank then 
        do:
          this-object:deposit_bank:Text = find_fin-bank.bank-name .
          v-deposit_bank = find_fin-bank.code-bank .
        end. 
        FIND FIRST find_fin-bank No-LOCK where find_fin-bank.code-bank = vBankRecip-code 
          and find_fin-bank.host-code = vBankRecip-host No-ERROR.
        if avail find_fin-bank then 
        do:
          this-object:bank_recip:Text = find_fin-bank.bank-name .
          v-recip_bank = find_fin-bank.code-bank .
        end. 
          

        /*mCashBook = new ibs.th.ref.cashbookstorage () .                                                           */
        /*mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "BankRecip-acct").*/
        /*delete object mCashBook no-error .                                                                        */


        for first ub.CashBookRule no-lock where 
          ub.cashbookrule.CashBookID  = buf_cashbook.id and
          ub.cashbookrule.host-code   = string(v-host-code) and
          ub.CashBookRule.Obj-code   =  v-cntxt-obj-code and
          ub.CashBookRule.Obj-type   = string(v-cntxt-obj-type) and
          ub.cashbookrule.Status_     = 0 and
          ub.cashbookrule.Code        = "Pin" /* ПИН */:
           
          this-object:pin02:Text = ub.cashbookrule.RuleValue .
        end.
      end.  
    end.  

   

    find first find_fin-doc-attr where find_fin-doc-attr.host-code = v-host-code and find_fin-doc-attr.attr-code = "cover_sheet"
      and find_fin-doc-attr.fin-doc-code = v-fin-code no-error .

    if available (find_fin-doc-attr) then 
    do:
      CSJson = find_fin-doc-attr.attr-value .
      if CSJson <> ? and CSJson <> "" then 
        dataset ds-banknots:handle:read-json ("longchar",CSJson) .
    end.   
    add_Banknot().
    windowContainer1:Update_Banknots (getq_Banknot()).
    add_Coints(). 
    windowContainer1:Update_coints( getq_Coints()). 
	
	
	
    return.

  end method.

  method private void InitializeComponent(  ):
    
    /* NOTE: The following method is automatically generated.
    
    We strongly suggest that the contents of this method only be modified using the
    Visual Designer to avoid any incompatible modifications.
    
    Modifying the contents of this method using a code editor will invalidate any support for this file. */
      @VisualDesigner.FormMember (NeedsInitialize="true").
      define variable resources as Progress.Util.ResourceManager no-undo.
      resources = new Progress.Util.ResourceManager("ibs.th.ref.Cover_Sheet").
      this-object:b_exit = new System.Windows.Forms.Button().
      this-object:b_save = new System.Windows.Forms.Button().
      this-object:b_print = new System.Windows.Forms.Button().
      this-object:num_bag = new System.Windows.Forms.TextBox().
      this-object:label1 = new System.Windows.Forms.Label().
      this-object:deposit_bank = new System.Windows.Forms.TextBox().
      this-object:b_deposit_bank = new System.Windows.Forms.Button().
      this-object:label2 = new System.Windows.Forms.Label().
      this-object:label3 = new System.Windows.Forms.Label().
      this-object:b_bank_recip = new System.Windows.Forms.Button().
      this-object:bank_recip = new System.Windows.Forms.TextBox().
      this-object:label4 = new System.Windows.Forms.Label().
      this-object:pin02 = new System.Windows.Forms.TextBox().
      this-object:label5 = new System.Windows.Forms.Label().
      this-object:windowContainer1 = new ibs.th.ref.Coins_Banknot().
      this-object:source_rec = new System.Windows.Forms.ComboBox().
      this-object:SuspendLayout().
      /*  */
      /* b_exit */
      /*  */
      this-object:b_exit:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.25), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:b_exit:Location = new System.Drawing.Point(572, 2).
      this-object:b_exit:Name = "b_exit".
      this-object:b_exit:Size = new System.Drawing.Size(100, 25).
      this-object:b_exit:TabIndex = 0.
      this-object:b_exit:Text = "Выход".
      this-object:b_exit:UseCompatibleTextRendering = true.
      this-object:b_exit:UseVisualStyleBackColor = true.
      this-object:b_exit:Click:Subscribe(this-object:b_exit_Click).
      /*  */
      /* b_save */
      /*  */
      this-object:b_save:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.25), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:b_save:Location = new System.Drawing.Point(471, 2).
      this-object:b_save:Name = "b_save".
      this-object:b_save:Size = new System.Drawing.Size(100, 25).
      this-object:b_save:TabIndex = 1.
      this-object:b_save:Text = "Сохранить".
      this-object:b_save:UseCompatibleTextRendering = true.
      this-object:b_save:UseVisualStyleBackColor = true.
      this-object:b_save:Click:Subscribe(this-object:b_save_Click).
      /*  */
      /* b_print */
      /*  */
      this-object:b_print:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.25), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:b_print:Location = new System.Drawing.Point(370, 2).
      this-object:b_print:Name = "b_print".
      this-object:b_print:Size = new System.Drawing.Size(100, 25).
      this-object:b_print:TabIndex = 2.
      this-object:b_print:Text = "Печать".
      this-object:b_print:UseCompatibleTextRendering = true.
      this-object:b_print:UseVisualStyleBackColor = true.
      this-object:b_print:Visible = false.
      /*  */
      /* num_bag */
      /*  */
      this-object:num_bag:Location = new System.Drawing.Point(173, 44).
      this-object:num_bag:Name = "num_bag".
      this-object:num_bag:Size = new System.Drawing.Size(177, 20).
      this-object:num_bag:TabIndex = 3.
      /*  */
      /* label1 */
      /*  */
      this-object:label1:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.25), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:label1:Location = new System.Drawing.Point(41, 44).
      this-object:label1:Name = "label1".
      this-object:label1:Size = new System.Drawing.Size(100, 20).
      this-object:label1:TabIndex = 4.
      this-object:label1:Text = "Номер сумки:".
      this-object:label1:UseCompatibleTextRendering = true.
      /*  */
      /* deposit_bank */
      /*  */
      this-object:deposit_bank:Location = new System.Drawing.Point(173, 70).
      this-object:deposit_bank:Name = "deposit_bank".
      this-object:deposit_bank:ReadOnly = true.
      this-object:deposit_bank:Size = new System.Drawing.Size(314, 20).
      this-object:deposit_bank:TabIndex = 5.
      /*  */
      /* b_deposit_bank */
      /*  */
      this-object:b_deposit_bank:Image = cast(resources:GetObject("b_deposit_bank.Image"), System.Drawing.Image).
      this-object:b_deposit_bank:Location = new System.Drawing.Point(493, 69).
      this-object:b_deposit_bank:Name = "b_deposit_bank".
      this-object:b_deposit_bank:Size = new System.Drawing.Size(25, 23).
      this-object:b_deposit_bank:TabIndex = 14.
      this-object:b_deposit_bank:UseCompatibleTextRendering = true.
      this-object:b_deposit_bank:UseVisualStyleBackColor = true.
      this-object:b_deposit_bank:Click:Subscribe(this-object:b_deposit_bank_Click).
      /*  */
      /* label2 */
      /*  */
      this-object:label2:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.25), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:label2:Location = new System.Drawing.Point(41, 67).
      this-object:label2:Name = "label2".
      this-object:label2:Size = new System.Drawing.Size(119, 23).
      this-object:label2:TabIndex = 15.
      this-object:label2:Text = "Банк-вноситель:".
      this-object:label2:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
      this-object:label2:UseCompatibleTextRendering = true.
      /*  */
      /* label3 */
      /*  */
      this-object:label3:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.25), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:label3:Location = new System.Drawing.Point(41, 93).
      this-object:label3:Name = "label3".
      this-object:label3:Size = new System.Drawing.Size(119, 23).
      this-object:label3:TabIndex = 18.
      this-object:label3:Text = "Банк-получатель:".
      this-object:label3:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
      this-object:label3:UseCompatibleTextRendering = true.
      /*  */
      /* b_bank_recip */
      /*  */
      this-object:b_bank_recip:Image = cast(resources:GetObject("b_bank_recip.Image"), System.Drawing.Image).
      this-object:b_bank_recip:Location = new System.Drawing.Point(493, 95).
      this-object:b_bank_recip:Name = "b_bank_recip".
      this-object:b_bank_recip:Size = new System.Drawing.Size(25, 23).
      this-object:b_bank_recip:TabIndex = 17.
      this-object:b_bank_recip:UseCompatibleTextRendering = true.
      this-object:b_bank_recip:UseVisualStyleBackColor = true.
      this-object:b_bank_recip:Click:Subscribe(this-object:b_bank_recip_Click).
      /*  */
      /* bank_recip */
      /*  */
      this-object:bank_recip:Location = new System.Drawing.Point(173, 96).
      this-object:bank_recip:Name = "bank_recip".
      this-object:bank_recip:ReadOnly = true.
      this-object:bank_recip:Size = new System.Drawing.Size(314, 20).
      this-object:bank_recip:TabIndex = 16.
      /*  */
      /* label4 */
      /*  */
      this-object:label4:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.25), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:label4:Location = new System.Drawing.Point(41, 122).
      this-object:label4:Name = "label4".
      this-object:label4:Size = new System.Drawing.Size(100, 20).
      this-object:label4:TabIndex = 20.
      this-object:label4:Text = "ПИН:".
      this-object:label4:UseCompatibleTextRendering = true.
      /*  */
      /* pin02 */
      /*  */
      this-object:pin02:Location = new System.Drawing.Point(173, 122).
      this-object:pin02:Name = "pin02".
      this-object:pin02:Size = new System.Drawing.Size(177, 20).
      this-object:pin02:TabIndex = 19.
      /*  */
      /* label5 */
      /*  */
      this-object:label5:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.25), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:label5:Location = new System.Drawing.Point(12, 148).
      this-object:label5:Name = "label5".
      this-object:label5:Size = new System.Drawing.Size(155, 20).
      this-object:label5:TabIndex = 22.
      this-object:label5:Text = "Источник поступления:".
      this-object:label5:UseCompatibleTextRendering = true.
      /*  */
      /* windowContainer1 */
      /*  */
      this-object:windowContainer1:Location = new System.Drawing.Point(12, 171).
      this-object:windowContainer1:Name = "windowContainer1".
      this-object:windowContainer1:Size = new System.Drawing.Size(669, 284).
      this-object:windowContainer1:TabIndex = 25.
      this-object:windowContainer1:Load:Subscribe(this-object:windowContainer1_Load).
      /*  */
      /* source_rec */
      /*  */
      this-object:source_rec:FormattingEnabled = true.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar0 as System.Object extent 2 no-undo.
      arrayvar0[1] = "Поступления от продажи товаров".
      arrayvar0[2] = "Прочие поступления".
      this-object:source_rec:Items:AddRange(arrayvar0).
      this-object:source_rec:Location = new System.Drawing.Point(173, 147).
      this-object:source_rec:Name = "source_rec".
      this-object:source_rec:Size = new System.Drawing.Size(499, 21).
      this-object:source_rec:TabIndex = 26.
      /*  */
      /* Cover_Sheet */
      /*  */
      this-object:ClientSize = new System.Drawing.Size(684, 467).
      this-object:Controls:Add(this-object:source_rec).
      this-object:Controls:Add(this-object:windowContainer1).
      this-object:Controls:Add(this-object:label5).
      this-object:Controls:Add(this-object:label4).
      this-object:Controls:Add(this-object:pin02).
      this-object:Controls:Add(this-object:label3).
      this-object:Controls:Add(this-object:b_bank_recip).
      this-object:Controls:Add(this-object:bank_recip).
      this-object:Controls:Add(this-object:label2).
      this-object:Controls:Add(this-object:b_deposit_bank).
      this-object:Controls:Add(this-object:deposit_bank).
      this-object:Controls:Add(this-object:label1).
      this-object:Controls:Add(this-object:num_bag).
      this-object:Controls:Add(this-object:b_print).
      this-object:Controls:Add(this-object:b_save).
      this-object:Controls:Add(this-object:b_exit).
      this-object:Name = "Cover_Sheet".
      this-object:Text = "Препроводительная ведомость".
      this-object:Load:Subscribe(this-object:Cover_Sheet_Load).
      this-object:ResumeLayout(false).
      this-object:PerformLayout().
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
  end method.


  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void windowContainer1_Load( input sender as System.Object, input e as System.EventArgs ):
		
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void Visual( input mode as character ):
    if mode = {&lookup} then 
    do:
      assign
        this-object:b_save:Enabled       = false
        this-object:num_bag:Enabled      = false
        this-object:deposit_bank:Enabled = false
        this-object:bank_recip:Enabled   = false
        this-object:pin02:Enabled        = false
        this-object:source_rec:Enabled   = false
        windowContainer1:Enabled         = false
        /*        windowContainer1:Enabled         = false*/
        .
    end.   
    return.

  end method.
  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/


  destructor public Cover_Sheet ( ):

  end destructor.

end class.