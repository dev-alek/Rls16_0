/*------------------------------------------------------------------------
   File        : cashbookfrm
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : sslivenko
   Created     : Thu Dec 06 09:59:03 MSK 2018
   Notes       : 
 ----------------------------------------------------------------------*/
using Progress.Windows.Form.
using ibs.th.ref.cashbookstorage from propath.
  
block-level on error undo, throw.
class ibs.th.ref.cashbookfrm inherits Form : 
  { cmp/str-glbl.i   class}
  
   { ibs/th/ref/ttCashBook.i }
  
  define private variable BankRecipacct      as System.Windows.Forms.TextBox     no-undo.
  define private variable bChooseCli         as System.Windows.Forms.Button      no-undo.
  define private variable bChooseCliVne      as System.Windows.Forms.Button      no-undo.
  define private variable bChooseCliAvans    as System.Windows.Forms.Button      no-undo.
  define private variable bChooseCorRko      as System.Windows.Forms.Button      no-undo.
  define private variable bChooseCorPko      as System.Windows.Forms.Button      no-undo.
  define private variable bChooseCorPkoVne   as System.Windows.Forms.Button      no-undo.
  define private variable bChooseCorPkoAvans as System.Windows.Forms.Button      no-undo.
  define private variable bChooseOsnAcct     as System.Windows.Forms.Button      no-undo.
  define private variable bindingSource1     as Progress.Data.BindingSource      no-undo.
  define private variable btbankrec          as System.Windows.Forms.Button      no-undo.
  define private variable btbankdep          as System.Windows.Forms.Button      no-undo.
  define private variable btcash             as System.Windows.Forms.Button      no-undo.
  define private variable btcorrRKOincas     as System.Windows.Forms.Button      no-undo.
  define private variable button1            as System.Windows.Forms.Button      no-undo.
  define private variable button3            as System.Windows.Forms.Button      no-undo.
  define private variable button2            as System.Windows.Forms.Button      no-undo.
  define private variable components         as System.ComponentModel.IContainer no-undo.
  define private variable buttonOk           as System.Windows.Forms.Button      no-undo.
  define private variable buttonCancel       as System.Windows.Forms.Button      no-undo.
  define private variable fCorpko            as System.Windows.Forms.TextBox     no-undo.
  define private variable fCorpkoVne         as System.Windows.Forms.TextBox     no-undo.
  define private variable fCorpkoAvans       as System.Windows.Forms.TextBox     no-undo.
  define private variable FcorRko            as System.Windows.Forms.TextBox     no-undo.
  define private variable FcorrRKOincas      as System.Windows.Forms.TextBox     no-undo.
  define private variable fcorrtrans         as System.Windows.Forms.TextBox     no-undo.
  define private variable fExtCode           as System.Windows.Forms.TextBox     no-undo.
  define private variable FlagSepFuel        as System.Windows.Forms.CheckBox    no-undo.
  define private variable FlagSepCash        as System.Windows.Forms.CheckBox    no-undo.
  define private variable FOsnIncas          as System.Windows.Forms.ComboBox    no-undo.
  define private variable fosntrans          as System.Windows.Forms.ComboBox    no-undo.
  define private variable fRuleOsnRko        as System.Windows.Forms.ComboBox    no-undo.
  define private variable fRuleOsnPko        as System.Windows.Forms.ComboBox    no-undo.
  define private variable fRuleOsnPkoVne     as System.Windows.Forms.ComboBox    no-undo.
  define private variable fRuleOsnPkoAvans   as System.Windows.Forms.ComboBox    no-undo.
  define private variable fOsnacct           as System.Windows.Forms.TextBox     no-undo.
  define private variable fRulePril          as System.Windows.Forms.ComboBox    no-undo.
  define private variable fName              as System.Windows.Forms.TextBox     no-undo.
  define private variable fSourceCode        as System.Windows.Forms.ComboBox    no-undo.
  define private variable fTakenFrom         as System.Windows.Forms.TextBox     no-undo.
  define private variable fTakenFromVne      as System.Windows.Forms.TextBox     no-undo.
  define private variable fTakenFromAvans    as System.Windows.Forms.TextBox     no-undo.
  define private variable groupBox2          as System.Windows.Forms.GroupBox    no-undo.
  define private variable groupBox1          as System.Windows.Forms.GroupBox    no-undo.
  define private variable groupBox3          as System.Windows.Forms.GroupBox    no-undo.
  define private variable groupBox4          as System.Windows.Forms.GroupBox    no-undo.
  define private variable groupBox5          as System.Windows.Forms.GroupBox    no-undo.
  define private variable groupBox6          as System.Windows.Forms.GroupBox    no-undo.
  define private variable label1             as System.Windows.Forms.Label       no-undo.
  define private variable label10            as System.Windows.Forms.Label       no-undo.
  define private variable label12            as System.Windows.Forms.Label       no-undo.
  define private variable label14            as System.Windows.Forms.Label       no-undo.
  define private variable label13            as System.Windows.Forms.Label       no-undo.
  define private variable label11            as System.Windows.Forms.Label       no-undo.
  define private variable label15            as System.Windows.Forms.Label       no-undo.
  define private variable label16            as System.Windows.Forms.Label       no-undo.
  define private variable label18            as System.Windows.Forms.Label       no-undo.
  define private variable label19            as System.Windows.Forms.Label       no-undo.
  define private variable label17            as System.Windows.Forms.Label       no-undo.
  define private variable label2             as System.Windows.Forms.Label       no-undo.
  define private variable label25            as System.Windows.Forms.Label       no-undo.
  define private variable label26            as System.Windows.Forms.Label       no-undo.
  define private variable label20            as System.Windows.Forms.Label       no-undo.
  define private variable label23            as System.Windows.Forms.Label       no-undo.
  define private variable label22            as System.Windows.Forms.Label       no-undo.
  define private variable label21            as System.Windows.Forms.Label       no-undo.
  define private variable label24            as System.Windows.Forms.Label       no-undo.
  define private variable label4             as System.Windows.Forms.Label       no-undo.
  define private variable label41            as System.Windows.Forms.Label       no-undo.
  define private variable label42            as System.Windows.Forms.Label       no-undo.
  define private variable label3             as System.Windows.Forms.Label       no-undo.
  define private variable label6             as System.Windows.Forms.Label       no-undo.
  define private variable label5             as System.Windows.Forms.Label       no-undo.
  define private variable label51            as System.Windows.Forms.Label       no-undo.
  define private variable label52            as System.Windows.Forms.Label       no-undo.
  define private variable label7             as System.Windows.Forms.Label       no-undo.
  
  define private variable label8             as System.Windows.Forms.Label       no-undo.
  define private variable label81            as System.Windows.Forms.Label       no-undo.
  define private variable label82            as System.Windows.Forms.Label       no-undo.
  define private variable label9             as System.Windows.Forms.Label       no-undo.
  define private variable lbankrec           as System.Windows.Forms.Label       no-undo.
  define private variable lbankdep           as System.Windows.Forms.Label       no-undo.
  define private variable lcashcli           as System.Windows.Forms.Label       no-undo.
  define private variable lCli               as System.Windows.Forms.Label       no-undo.
  define private variable lCliVne            as System.Windows.Forms.Label       no-undo.
  define private variable lCliAvans          as System.Windows.Forms.Label       no-undo.
  define private variable lclitrans          as System.Windows.Forms.Label       no-undo.
  define private variable Lincasagent        as System.Windows.Forms.Label       no-undo.
  define         variable mCashBook          as class                            ibs.th.ref.cashbookstorage no-undo .
  define private variable textBox2           as System.Windows.Forms.TextBox     no-undo.
  define private variable textBox1           as System.Windows.Forms.TextBox     no-undo.
  define         variable v-cashbookId       as int64                            no-undo .
  
   define buffer buf_cashbook     for ub.cashbook .
   define buffer buf_cashbookrule for ub.cashbookrule .
   { cmp/library.i class}
   { gbl/getcntxt.i def }
   define         variable v-host-code      as integer   no-undo .
   define         variable v-obj-date       as date      no-undo .
   define private variable vss-include-info{&vssseq} as CHARACTER no-undo.
   define property parparentproc as handle no-undo
      private get.
      set(input iH as handle):
         parparentproc = ih.
         { gbl/getcntxt.i get }
         { gbl/hostcode.i v-cntxt-obj-type v-cntxt-obj-code v-host-code }
         { gbl/objdtget.i v-cntxt-obj-type v-cntxt-obj-code v-obj-date no-error }
         if error-status:error then
            message substitute( "Ошибка чтения текущей даты на объекте &1&2" ,
               v-cntxt-obj-type, v-cntxt-obj-code) view-as alert-box.
      end.
  
   /*define property host-code as integer no-undo
   private get.
   set(input iH as integer):
         host-code = ih.
   end.*/
  
   constructor public cashbookfrm (Mode as character, p-id as int64 ):
    
      super().
    
      mCashBook = new cashbookstorage () .
    
      empty temp-table tt-cashbook .
      create tt-CashBook .
      case Mode: 
         when {&add-def} then 
            do:
               tt-cashbook.id = ? .
            end.
         when {&update}
         or 
         when {&lookup} then 
            do:
               find first buf_cashbook no-lock where buf_cashbook.id = p-id .
               buffer-copy buf_cashbook except buf_cashbook.RulePril buf_cashbook.RuleOsnPko to tt-cashbook .
               tt-cashbook.RulePril = getRulePrilName(integer (buf_cashbook.RulePril)) .
               tt-cashbook.RuleOsnPko = getRuleOsnName(buf_cashbook.RuleOsnPko) .
               mCashBook:ttCashbooksaturation(buffer tt-cashbook:handle).
            end. 
      end case .

      InitializeComponent().
      Visual_form(Mode).
      bindingSource1:Handle = buffer tt-CashBook:handle . 
    
      this-object:ComponentsCollection:ADD(this-object:components).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.

   end constructor.
   
   constructor public cashbookfrm( ):
   
      super().
      InitializeComponent ( ).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.      

   end constructor.

   destructor public cashbookfrm( ):
    
      delete object mCashBook no-error .

      if valid-object(components) then 
      do:
         cast(components, System.IDisposable):Dispose().
      end.

   end destructor.   



   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void bChooseCli_Click( input sender as System.Object, input e as System.EventArgs ):
    
      define variable ref-rec  as recid     no-undo .
      define variable ref-list as character no-undo.
    
      run ref/cli-all.w ( input parParentProc
         ,input "b-sel"
         ,input {&all}
         ,input ?
         ,input ?
         ,input ?
         ,input ?
         ,input ?
         ,output ref-list) .
      if ref-list = "" then 
      do:
         return .
      end.
      ref-rec = integer( ref-list ).
      FIND ub.clients WHERE recid (ub.clients) = ref-rec NO-LOCK .
      this-object:lCli:Text = ub.clients.obj-type + string(ub.clients.obj-code) + "   " + ub.clients.obj-name .
      this-object:lCli:Focus().
      assign
         tt-CashBook.cli-type = ub.clients.obj-type
         tt-CashBook.cli-code = ub.clients.obj-code
         .  
    
      return.

   end method.

   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void bChooseCliAvans_Click( input sender as System.Object, input e as System.EventArgs ):
    
      define variable ref-rec  as recid     no-undo .
      define variable ref-list as character no-undo.
    
      run ref/cli-all.w ( input parParentProc
         ,input "b-sel"
         ,input {&all}
         ,input ?
         ,input ?
         ,input ?
         ,input ?
         ,input ?
         ,output ref-list) .
      if ref-list = "" then 
      do:
         return .
      end.
      ref-rec = integer( ref-list ).
      FIND ub.clients WHERE recid (ub.clients) = ref-rec NO-LOCK .
      this-object:lCliAvans:Text = ub.clients.obj-type + string(ub.clients.obj-code) + "   " + ub.clients.obj-name .
      this-object:lCliAvans:Focus().
      assign
         tt-CashBook.Avanscli-type = ub.clients.obj-type
         tt-CashBook.Avanscli-code = ub.clients.obj-code
         .  
    
      return.

   end method.
   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void bChooseCliVne_Click( input sender as System.Object, input e as System.EventArgs ):
    
      define variable ref-rec  as recid     no-undo .
      define variable ref-list as character no-undo.
    
      run ref/cli-all.w ( input parParentProc
         ,input "b-sel"
         ,input {&all}
         ,input ?
         ,input ?
         ,input ?
         ,input ?
         ,input ?
         ,output ref-list) .
      if ref-list = "" then 
      do:
         return .
      end.
      ref-rec = integer( ref-list ).
      FIND ub.clients WHERE recid (ub.clients) = ref-rec NO-LOCK .
      this-object:lCliVne:Text = ub.clients.obj-type + string(ub.clients.obj-code) + "   " + ub.clients.obj-name .
      this-object:lCliVne:Focus().
      assign
         tt-CashBook.Vnecli-type = ub.clients.obj-type
         tt-CashBook.Vnecli-code = ub.clients.obj-code
         .  
    
      return.

   end method.
   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void bChooseCredit_Click( input sender as System.Object, input e as System.EventArgs ):
      define variable rid-list as character no-undo.
      rid-list = "":U .
      run ref/fwcode-1.w (
         parParentProc
         ,"b-sel"
         ,{&all}
         ,input ?
         ,input ?
         ,output rid-list ).
    
      if rid-list <> "":U then 
      do:
         FIND FIRST fin-code-cor-acc WHERE
            recid( fin-code-cor-acc ) = integer(entry(1, rid-list)) NO-LOCK .
         if fin-code-cor-acc.status_ <> integer({&current-status-int}) then 
         do:
            message
               "Нельзя выбрать удаленный корр счет"
               view-as alert-box error .
            return .
         end.
         this-object:fCorpko:Text = fin-code-cor-acc.code-value .
         this-object:fCorpko:focus() .
      end.
      return.

   end method.

   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void bChooseCreditVne_Click( input sender as System.Object, input e as System.EventArgs ):
      define variable rid-list as character no-undo.
      rid-list = "":U .
      run ref/fwcode-1.w (
         parParentProc
         ,"b-sel"
         ,{&all}
         ,input ?
         ,input ?
         ,output rid-list ).
    
      if rid-list <> "":U then 
      do:
         FIND FIRST fin-code-cor-acc WHERE
            recid( fin-code-cor-acc ) = integer(entry(1, rid-list)) NO-LOCK .
         if fin-code-cor-acc.status_ <> integer({&current-status-int}) then 
         do:
            message
               "Нельзя выбрать удаленный корр счет"
               view-as alert-box error .
            return .
         end.
         this-object:fCorpkoVne:Text = fin-code-cor-acc.code-value .
         this-object:fCorpkoVne:focus() .
      end.
      return.

   end method.

   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void bChooseCreditAvans_Click( input sender as System.Object, input e as System.EventArgs ):
      define variable rid-list as character no-undo.
      rid-list = "":U .
      run ref/fwcode-1.w (
         parParentProc
         ,"b-sel"
         ,{&all}
         ,input ?
         ,input ?
         ,output rid-list ).
    
      if rid-list <> "":U then 
      do:
         FIND FIRST fin-code-cor-acc WHERE
            recid( fin-code-cor-acc ) = integer(entry(1, rid-list)) NO-LOCK .
         if fin-code-cor-acc.status_ <> integer({&current-status-int}) then 
         do:
            message
               "Нельзя выбрать удаленный корр счет"
               view-as alert-box error .
            return .
         end.
         this-object:fCorpkoAvans:Text = fin-code-cor-acc.code-value .
         this-object:fCorpkoAvans:focus() .
      end.
      return.

   end method.   
   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void bChooseDebit_Click( input sender as System.Object, input e as System.EventArgs ):
      define variable rid-list as character no-undo.
      rid-list = "":U .
      run ref/fwcode-1.w (
         parParentProc
         ,"b-sel"
         ,{&all}
         ,input ?
         ,input ?
         ,output rid-list ).
    
      if rid-list <> "":U then 
      do:
         FIND FIRST fin-code-cor-acc WHERE
            recid( fin-code-cor-acc ) = integer(entry(1, rid-list)) NO-LOCK .
         if fin-code-cor-acc.status_ <> integer({&current-status-int}) then 
         do:
            message
               "Нельзя выбрать удаленный корр счет"
               view-as alert-box error .
            return .
         end.
         this-object:fOsnacct:Text = fin-code-cor-acc.code-value .
         this-object:fOsnacct:focus() .
      end.
      return.

   end method.

   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void btbankdep_Click( input sender as System.Object, input e as System.EventArgs ):
      define variable v-rid-list as character no-undo .
      define variable v-status_  like ub.fin-bank.status_ no-undo init {&current-status}.
      run ref/finbanks.w
         (input parparentproc
         ,input v-cntxt-host-code-obj
         ,input "b-sel":U
         ,input {&all}
         ,input v-cntxt-host-code-obj
         ,input-output v-status_
         ,input-output v-rid-list
         ).
      find first fin-bank where recid(fin-bank) eq integer (v-rid-list) no-lock no-error.
      if available fin-bank 
         then
         assign
            lbankdep:text              = fin-bank.bank-name
            tt-cashbook.BankDepos-host = fin-bank.host-code
            tt-cashbook.BankDepos-code = fin-bank.code-bank
            . 
      return.

   end method.

   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void btbankrec_Click( input sender as System.Object, input e as System.EventArgs ):
      define variable v-rid-list as character no-undo .
      define variable v-status_  like ub.fin-bank.status_ no-undo init {&current-status}.
      run ref/finbanks.w
         (input parparentproc
         ,input v-cntxt-host-code-obj
         ,input "b-sel":U
         ,input {&all}
         ,input v-cntxt-host-code-obj
         ,input-output v-status_
         ,input-output v-rid-list
         ).
      find first fin-bank where recid(fin-bank) eq integer (v-rid-list) no-lock no-error.
      if available fin-bank 
         then
         assign
            lbankrec:text              = fin-bank.bank-name
            tt-cashbook.BankRecip-host = fin-bank.host-code
            tt-cashbook.BankRecip-code = fin-bank.code-bank
            . 
      return.

   end method.

   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void btcorrRKOincas_Click( input sender as System.Object, input e as System.EventArgs ):
      define variable rid-list as character no-undo.
      rid-list = "":U .
      run ref/fwcode-1.w (
         parParentProc
         ,"b-sel"
         ,{&all}
         ,input ?
         ,input ?
         ,output rid-list ).
    
      if rid-list <> "":U then 
      do:
         FIND FIRST fin-code-cor-acc WHERE
            recid( fin-code-cor-acc ) = integer(entry(1, rid-list)) NO-LOCK .
         if fin-code-cor-acc.status_ <> integer({&current-status-int}) then 
         do:
            message
               "Нельзя выбрать удаленный корр счет"
               view-as alert-box error .
            return .
         end.
         this-object:FcorrRKOincas:Text = fin-code-cor-acc.code-value .
         this-object:FcorrRKOincas:focus() .
      end.
      return.

   end method.

   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void btincas_Click( input sender as System.Object, input e as System.EventArgs ):
      define variable ref-rec  as recid     no-undo .
      define variable ref-list as character no-undo.
    
      run ref/cli-all.w ( input parParentProc
         ,input "b-sel"
         ,input {&all}
         ,input ?
         ,input ?
         ,input ?
         ,input ?
         ,input ?
         ,output ref-list) .
      if ref-list = "" then 
      do:
         return .
      end.
      ref-rec = integer( ref-list ).
      FIND ub.clients WHERE recid (ub.clients) = ref-rec NO-LOCK .
      this-object:lcashcli:Text = ub.clients.obj-type + string(ub.clients.obj-code) + "   " + ub.clients.obj-name .
      this-object:lcashcli:Focus().
      assign
         tt-CashBook.CountCash-type = ub.clients.obj-type
         tt-CashBook.CountCash-code = ub.clients.obj-code
         . 
      return.

   end method.

   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void button1_Click( input sender as System.Object, input e as System.EventArgs ):
      define variable ref-rec  as recid     no-undo .
      define variable ref-list as character no-undo.
    
      run ref/cli-all.w ( input parParentProc
         ,input "b-sel"
         ,input {&all}
         ,input ?
         ,input ?
         ,input ?
         ,input ?
         ,input ?
         ,output ref-list) .
      if ref-list = "" then 
      do:
         return .
      end.
      ref-rec = integer( ref-list ).
      FIND ub.clients WHERE recid (ub.clients) = ref-rec NO-LOCK .
      this-object:Lincasagent:Text = ub.clients.obj-type + string(ub.clients.obj-code) + "   " + ub.clients.obj-name .
      this-object:Lincasagent:Focus().
      assign
         tt-CashBook.CountCollect-type = ub.clients.obj-type
         tt-CashBook.CountCollect-code = ub.clients.obj-code
         .
      return.

   end method.

   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void button2_Click( input sender as System.Object, input e as System.EventArgs ):
      define variable ref-rec  as recid     no-undo .
      define variable ref-list as character no-undo.
    
      run ref/cli-all.w ( input parParentProc
         ,input "b-sel"
         ,input {&all}
         ,input ?
         ,input ?
         ,input ?
         ,input ?
         ,input ?
         ,output ref-list) .
      if ref-list = "" then 
      do:
         return .
      end.
      ref-rec = integer( ref-list ).
      FIND ub.clients WHERE recid (ub.clients) = ref-rec NO-LOCK .
      this-object:lclitrans:Text = ub.clients.obj-type + string(ub.clients.obj-code) + "   " + ub.clients.obj-name .
      this-object:lclitrans:Focus().
      assign
         tt-CashBook.contr-type-transf = ub.clients.obj-type
         tt-CashBook.contr-code-transf = ub.clients.obj-code
         .
      return.

   end method.

   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void cashbookfrm_Load( input sender as System.Object, input e as System.EventArgs ):
    
      return.

   end method.

   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void fRuleOsnPko_SelectedIndexChanged( input sender as System.Object, input e as System.EventArgs ):
    
      return.

   end method.

   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void fRuleOsnPkoAvans_SelectedIndexChanged( input sender as System.Object, input e as System.EventArgs ):
    
      return.

   end method.
   
  
   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void fRuleOsnPkoVne_SelectedIndexChanged( input sender as System.Object, input e as System.EventArgs ):
    
      return.

   end method.
   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void fTakenFrom_TextChanged( input sender as System.Object, input e as System.EventArgs ):
    
      return.

   end method.
   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void fTakenFromVne_TextChanged( input sender as System.Object, input e as System.EventArgs ):
    
      return.

   end method.
   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void fTakenFromAvans_TextChanged( input sender as System.Object, input e as System.EventArgs ):
    
      return.

   end method.
   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void bCorRko_Click( input sender as System.Object, input e as System.EventArgs ):
      define variable rid-list as character no-undo.
      rid-list = "":U .
      run ref/fwcode-1.w (
         parParentProc
         ,"b-sel"
         ,{&all}
         ,input ?
         ,input ?
         ,output rid-list ).
    
      if rid-list <> "":U then 
      do:
         FIND FIRST fin-code-cor-acc WHERE
            recid( fin-code-cor-acc ) = integer(entry(1, rid-list)) NO-LOCK .
         if fin-code-cor-acc.status_ <> integer({&current-status-int}) then 
         do:
            message
               "Нельзя выбрать удаленный корр счет"
               view-as alert-box error .
            return .
         end.
         this-object:FcorRko:Text = fin-code-cor-acc.code-value .
         this-object:FcorRko:focus() .
      end.
      
      return.

   end method.


   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void groupBox2_Enter( input sender as System.Object, input e as System.EventArgs ):
    
      return.

   end method.

   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void groupBox3_Enter( input sender as System.Object, input e as System.EventArgs ):
    
      return.

   end method.

   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void label13_Click( input sender as System.Object, input e as System.EventArgs ):
    
      return.

   end method.

   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void label14_Click( input sender as System.Object, input e as System.EventArgs ):
    
      return.

   end method.


  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void label8_Click( input sender as System.Object, input e as System.EventArgs ):
    
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void label81_Click( input sender as System.Object, input e as System.EventArgs ):
    
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void label82_Click( input sender as System.Object, input e as System.EventArgs ):
    
    return.

  end method.
    
  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void lbankrec_Click( input sender as System.Object, input e as System.EventArgs ):
    
    return.

  end method.

   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void lCli_Click( input sender as System.Object, input e as System.EventArgs ):
    
      return.

   end method.

   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void lCliVne_Click( input sender as System.Object, input e as System.EventArgs ):
    
      return.

   end method.

   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void lCliAvans_Click( input sender as System.Object, input e as System.EventArgs ):
    
      return.

   end method.
      
   method private void okButton_Click (sender as System.Object, e as System.EventArgs):
      bindingSource1:Assign().
      if tt-cashbook.id = ?
         then 
      do :
         mCashBook:insertDB(buffer tt-cashbook, output v-cashbookId) .
      end.
      else 
      do :
         mCashBook:updateDB(buffer tt-cashbook) .
      end.
      if mCashBook:Msg <> ""
         then 
      do :
         message mCashBook:Msg view-as alert-box .
         return .
      end.
      this-object:DialogResult = System.Windows.Forms.DialogResult:Ok.
      this-object:Close ( ). 
   end method.

   method private void cancelButton_Click (sender as System.Object, e as System.EventArgs):
      this-object:DialogResult = System.Windows.Forms.DialogResult:Cancel.
      this-object:Close ( ).
   end method.
    
   method private void InitializeComponent ( ):

     /* NOTE: The following method is automatically generated.
         
        We strongly suggest that the contents of this method only be modified using the 
        Visual Designer to avoid any incompatible modifications.
         
        Modifying the contents of this method using a code editor will invalidate any support for this file. */
      
     this-object:components = new System.ComponentModel.Container().
     @VisualDesigner.FormMember (NeedsInitialize="true").
     define variable tableDesc1 as Progress.Data.TableDesc no-undo.
     tableDesc1 = new Progress.Data.TableDesc("tt-CashBook").
     this-object:buttonOk = new System.Windows.Forms.Button().
     this-object:buttonCancel = new System.Windows.Forms.Button().
     this-object:label1 = new System.Windows.Forms.Label().
     this-object:fName = new System.Windows.Forms.TextBox().
     this-object:bindingSource1 = new Progress.Data.BindingSource(this-object:components).
     this-object:label5 = new System.Windows.Forms.Label().
     this-object:label51 = new System.Windows.Forms.Label().
     this-object:label52 = new System.Windows.Forms.Label().
     this-object:label6 = new System.Windows.Forms.Label().
     this-object:FlagSepFuel = new System.Windows.Forms.CheckBox().
     this-object:FlagSepCash = new System.Windows.Forms.CheckBox().
     this-object:label3 = new System.Windows.Forms.Label().
     this-object:fExtCode = new System.Windows.Forms.TextBox().
     this-object:label4 = new System.Windows.Forms.Label().
     this-object:label41 = new System.Windows.Forms.Label().
     this-object:label42 = new System.Windows.Forms.Label().
     this-object:label7 = new System.Windows.Forms.Label().
     this-object:fCorpko = new System.Windows.Forms.TextBox().
     this-object:fCorpkoVne = new System.Windows.Forms.TextBox().
     this-object:fCorpkoAvans = new System.Windows.Forms.TextBox().
     this-object:fOsnacct = new System.Windows.Forms.TextBox().
     this-object:fRulePril = new System.Windows.Forms.ComboBox().
     this-object:bChooseCorPko = new System.Windows.Forms.Button().
     this-object:bChooseCorPkoVne = new System.Windows.Forms.Button().
     this-object:bChooseCorPkoAvans = new System.Windows.Forms.Button().
     this-object:bChooseOsnAcct = new System.Windows.Forms.Button().
     this-object:label2 = new System.Windows.Forms.Label().
     this-object:label25 = new System.Windows.Forms.Label().
     this-object:label26 = new System.Windows.Forms.Label().
     this-object:label8 = new System.Windows.Forms.Label().
     this-object:label81 = new System.Windows.Forms.Label().
     this-object:label82 = new System.Windows.Forms.Label().
     this-object:fTakenFrom = new System.Windows.Forms.TextBox().
     this-object:fTakenFromVne = new System.Windows.Forms.TextBox().
     this-object:fTakenFromAvans = new System.Windows.Forms.TextBox().
     this-object:bChooseCli = new System.Windows.Forms.Button().
     this-object:bChooseCliVne = new System.Windows.Forms.Button().
     this-object:bChooseCliAvans = new System.Windows.Forms.Button().
     this-object:lCli = new System.Windows.Forms.Label().
     this-object:lCliVne = new System.Windows.Forms.Label().
     this-object:lCliAvans = new System.Windows.Forms.Label().
     this-object:FcorRko = new System.Windows.Forms.TextBox().
     this-object:bChooseCorRko = new System.Windows.Forms.Button().
     this-object:label9 = new System.Windows.Forms.Label().
     this-object:fRuleOsnRko = new System.Windows.Forms.ComboBox().
     this-object:label10 = new System.Windows.Forms.Label().
     this-object:fRuleOsnPko = new System.Windows.Forms.ComboBox().
     this-object:fRuleOsnPkoVne = new System.Windows.Forms.ComboBox().
     this-object:fRuleOsnPkoAvans = new System.Windows.Forms.ComboBox().
     this-object:label11 = new System.Windows.Forms.Label().
     this-object:lcashcli = new System.Windows.Forms.Label().
     this-object:label13 = new System.Windows.Forms.Label().
     this-object:label14 = new System.Windows.Forms.Label().
     this-object:btcash = new System.Windows.Forms.Button().
     this-object:label15 = new System.Windows.Forms.Label().
     this-object:fSourceCode = new System.Windows.Forms.ComboBox().
     this-object:lbankdep = new System.Windows.Forms.Label().
     this-object:lbankrec = new System.Windows.Forms.Label().
     this-object:btbankdep = new System.Windows.Forms.Button().
     this-object:btbankrec = new System.Windows.Forms.Button().
     this-object:label12 = new System.Windows.Forms.Label().
     this-object:BankRecipacct = new System.Windows.Forms.TextBox().
     this-object:label16 = new System.Windows.Forms.Label().
     this-object:btcorrRKOincas = new System.Windows.Forms.Button().
     this-object:FcorrRKOincas = new System.Windows.Forms.TextBox().
     this-object:label17 = new System.Windows.Forms.Label().
     this-object:FOsnIncas = new System.Windows.Forms.ComboBox().
     this-object:button1 = new System.Windows.Forms.Button().
     this-object:Lincasagent = new System.Windows.Forms.Label().
     this-object:label19 = new System.Windows.Forms.Label().
     this-object:groupBox1 = new System.Windows.Forms.GroupBox().
     this-object:groupBox2 = new System.Windows.Forms.GroupBox().
     this-object:textBox1 = new System.Windows.Forms.TextBox().
     this-object:label20 = new System.Windows.Forms.Label().
     this-object:groupBox3 = new System.Windows.Forms.GroupBox().
     this-object:label18 = new System.Windows.Forms.Label().
     this-object:groupBox4 = new System.Windows.Forms.GroupBox().
     this-object:textBox2 = new System.Windows.Forms.TextBox().
     this-object:groupBox5 = new System.Windows.Forms.GroupBox().
     this-object:groupBox6 = new System.Windows.Forms.GroupBox().
     /*      this-object:textBox2 = new System.Windows.Forms.TextBox().*/
     this-object:label24 = new System.Windows.Forms.Label().
     this-object:fosntrans = new System.Windows.Forms.ComboBox().
     this-object:lclitrans = new System.Windows.Forms.Label().
     this-object:button2 = new System.Windows.Forms.Button().
     this-object:label21 = new System.Windows.Forms.Label().
     this-object:button3 = new System.Windows.Forms.Button().
     this-object:fcorrtrans = new System.Windows.Forms.TextBox().
     this-object:label22 = new System.Windows.Forms.Label().
     this-object:label23 = new System.Windows.Forms.Label().
     cast(this-object:bindingSource1, System.ComponentModel.ISupportInitialize):BeginInit().
     this-object:groupBox1:SuspendLayout().
     this-object:groupBox2:SuspendLayout().
     this-object:groupBox3:SuspendLayout().
     this-object:groupBox4:SuspendLayout().
     this-object:groupBox5:SuspendLayout().
     this-object:groupBox6:SuspendLayout().
     this-object:SuspendLayout().
      /*  */
      /* buttonOk */
      /*  */
      this-object:buttonOk:Location = new System.Drawing.Point(12, 12).
      this-object:buttonOk:Name = "buttonOk".
      this-object:buttonOk:Size = new System.Drawing.Size(75, 23).
      this-object:buttonOk:TabIndex = 0.
      this-object:buttonOk:Text = "Ввод".
      this-object:buttonOk:UseCompatibleTextRendering = true.
      this-object:buttonOk:Click:Subscribe(this-object:okButton_Click).
      /*  */
      /* buttonCancel */
      /*  */
      this-object:buttonCancel:DialogResult = System.Windows.Forms.DialogResult:Cancel.
      this-object:buttonCancel:Location = new System.Drawing.Point(93, 12).
      this-object:buttonCancel:Name = "buttonCancel".
      this-object:buttonCancel:Size = new System.Drawing.Size(75, 23).
      this-object:buttonCancel:TabIndex = 1.
      this-object:buttonCancel:Text = "Отмена".
      this-object:buttonCancel:UseCompatibleTextRendering = true.
      this-object:buttonCancel:Click:Subscribe(this-object:cancelButton_Click).
      /*  */
      /* label1 */
      /*  */
      this-object:label1:Location = new System.Drawing.Point(12, 38).
      this-object:label1:Name = "label1".
      this-object:label1:Size = new System.Drawing.Size(199, 23).
      this-object:label1:TabIndex = 2.
      this-object:label1:Text = "Наименование типа кассовой книги:".
      this-object:label1:UseCompatibleTextRendering = true.
      /*  */
      /* fName */
      /*  */
      this-object:fName:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "CashBookName", true)).
      this-object:fName:Location = new System.Drawing.Point(268, 35).
      this-object:fName:Name = "fName".
      this-object:fName:Size = new System.Drawing.Size(156, 20).
      this-object:fName:TabIndex = 3.
      /*  */
      /* bindingSource1 */
      /*  */
      this-object:bindingSource1:MaxDataGuess = 0.
      this-object:bindingSource1:NoLOBs = false.
      this-object:bindingSource1:Position = 0.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar0 as "Progress.Data.TableDesc[]" no-undo.
      arrayvar0 = new "Progress.Data.TableDesc[]"(0).
      tableDesc1:ChildTables = arrayvar0.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar1 as Progress.Data.ColumnPropDesc extent 27 no-undo.
      arrayvar1[1] = new Progress.Data.ColumnPropDesc("CashBookName", "Наименование", Progress.Data.DataType:CHARACTER).
      arrayvar1[2] = new Progress.Data.ColumnPropDesc("corrPko", "Корсчет для ПКО", Progress.Data.DataType:CHARACTER).
      arrayvar1[3] = new Progress.Data.ColumnPropDesc("osnAcct", "дебит", Progress.Data.DataType:CHARACTER).
      arrayvar1[4] = new Progress.Data.ColumnPropDesc("ext-code", "ext-code", Progress.Data.DataType:CHARACTER).
      arrayvar1[5] = new Progress.Data.ColumnPropDesc("FlagSepCash", "Отд. для кажд. кассы", Progress.Data.DataType:LOGICAL).
      arrayvar1[6] = new Progress.Data.ColumnPropDesc("FlagSepFull", "Раздельно НП и ТНП", Progress.Data.DataType:LOGICAL).
      arrayvar1[7] = new Progress.Data.ColumnPropDesc("id", "id", Progress.Data.DataType:INT64).
      arrayvar1[8] = new Progress.Data.ColumnPropDesc("RuleOsnPko", "Прав. запол.ПКО", Progress.Data.DataType:CHARACTER).
      arrayvar1[9] = new Progress.Data.ColumnPropDesc("RulePril", "Прав. запол.", Progress.Data.DataType:CHARACTER).
      arrayvar1[10] = new Progress.Data.ColumnPropDesc("Status_", "Статус", Progress.Data.DataType:INTEGER).
      arrayvar1[11] = new Progress.Data.ColumnPropDesc("takenfrom", "Принято от", Progress.Data.DataType:CHARACTER).
      arrayvar1[12] = new Progress.Data.ColumnPropDesc("CorrRko", "Корсчет для ПКО", Progress.Data.DataType:CHARACTER).
      arrayvar1[13] = new Progress.Data.ColumnPropDesc("RuleOsnRko", "Прав. запол.РКО", Progress.Data.DataType:CHARACTER).
      arrayvar1[14] = new Progress.Data.ColumnPropDesc("SourceCode", "Код источника поступления", Progress.Data.DataType:CHARACTER).
      arrayvar1[15] = new Progress.Data.ColumnPropDesc("BankRecip-acct", "Счет в банке получателе", Progress.Data.DataType:CHARACTER).
      arrayvar1[16] = new Progress.Data.ColumnPropDesc("BasisIncas", "Основание для инкассации", Progress.Data.DataType:CHARACTER).
      arrayvar1[17] = new Progress.Data.ColumnPropDesc("CorrAcctIncas", "Кор. Счет для инкассации", Progress.Data.DataType:CHARACTER).
      arrayvar1[18] = new Progress.Data.ColumnPropDesc("Corr-transf", "корсчет", Progress.Data.DataType:CHARACTER).
      arrayvar1[19] = new Progress.Data.ColumnPropDesc("rule-osn-transf", "правило", Progress.Data.DataType:CHARACTER).
      arrayvar1[20] = new Progress.Data.ColumnPropDesc("rule-payer-transf", "Выдать\Принять от", Progress.Data.DataType:CHARACTER).
      arrayvar1[21] = new Progress.Data.ColumnPropDesc("rule-payer-rko", "Выдать", Progress.Data.DataType:CHARACTER).
      arrayvar1[22] = new Progress.Data.ColumnPropDesc("corrPkoVne", "Корсчет для внереализационного дохода", Progress.Data.DataType:CHARACTER).
      arrayvar1[23] = new Progress.Data.ColumnPropDesc("takenfromVne", "Принято от", Progress.Data.DataType:CHARACTER).
      arrayvar1[24] = new Progress.Data.ColumnPropDesc("RuleOsnPkoVne", "Прав. запол.ПКО", Progress.Data.DataType:CHARACTER).
      arrayvar1[25] = new Progress.Data.ColumnPropDesc("corrPkoAvans", "Корсчет для аванса", Progress.Data.DataType:CHARACTER).
      arrayvar1[26] = new Progress.Data.ColumnPropDesc("takenfromAvans", "Принято от", Progress.Data.DataType:CHARACTER).
      arrayvar1[27] = new Progress.Data.ColumnPropDesc("RuleOsnPkoAvans", "Прав. запол.ПКО", Progress.Data.DataType:CHARACTER).
      tableDesc1:Columns = arrayvar1.
      this-object:bindingSource1:TableSchema = tableDesc1.
      /*  */
      /* label5 */
      /*  */
      this-object:label5:Location = new System.Drawing.Point(4, 43).
      this-object:label5:Name = "label5".
      this-object:label5:Size = new System.Drawing.Size(237, 23).
      this-object:label5:TabIndex = 10.
      this-object:label5:Text = "Правило заполнения графы ~"Основание~":".
      this-object:label5:UseCompatibleTextRendering = true.
      /*  */
      /* label51 */
      /*  */
      this-object:label51:Location = new System.Drawing.Point(4, 43).
      this-object:label51:Name = "label51".
      this-object:label51:Size = new System.Drawing.Size(237, 23).
      this-object:label51:TabIndex = 10.
      this-object:label51:Text = "Правило заполнения графы ~"Основание~":".
      this-object:label51:UseCompatibleTextRendering = true.
      /*  */
      /* label52 */
      /*  */
      this-object:label52:Location = new System.Drawing.Point(4, 43).
      this-object:label52:Name = "label52".
      this-object:label52:Size = new System.Drawing.Size(237, 23).
      this-object:label52:TabIndex = 10.
      this-object:label52:Text = "Правило заполнения графы ~"Основание~":".
      this-object:label52:UseCompatibleTextRendering = true.

      /*  */
      /* label6 */
      /*  */
      this-object:label6:Location = new System.Drawing.Point(11, 107).
      this-object:label6:Name = "label6".
      this-object:label6:Size = new System.Drawing.Size(242, 23).
      this-object:label6:TabIndex = 12.
      this-object:label6:Text = "Правило заполнения графы ~"Приложение~":".
      this-object:label6:UseCompatibleTextRendering = true.
      /*  */
      /* FlagSepFuel */
      /*  */
      this-object:FlagSepFuel:DataBindings:Add(new System.Windows.Forms.Binding("Checked", this-object:bindingSource1, "FlagSepFull", true)).
      this-object:FlagSepFuel:Location = new System.Drawing.Point(258, 160).
      this-object:FlagSepFuel:Name = "FlagSepFuel".
      this-object:FlagSepFuel:Size = new System.Drawing.Size(147, 24).
      this-object:FlagSepFuel:TabIndex = 10.
      this-object:FlagSepFuel:Text = "Раздельно НП и ТНП".
      this-object:FlagSepFuel:UseCompatibleTextRendering = true.
      this-object:FlagSepFuel:UseVisualStyleBackColor = true.
      /*  */
      /* FlagSepCash */
      /*  */
      this-object:FlagSepCash:DataBindings:Add(new System.Windows.Forms.Binding("Checked", this-object:bindingSource1, "FlagSepCash", true)).
      this-object:FlagSepCash:Location = new System.Drawing.Point(12, 160).
      this-object:FlagSepCash:Name = "FlagSepCash".
      this-object:FlagSepCash:Size = new System.Drawing.Size(240, 24).
      this-object:FlagSepCash:TabIndex = 9.
      this-object:FlagSepCash:Text = "Отдельный ПКО/РКО для каждой кассы".
      this-object:FlagSepCash:UseCompatibleTextRendering = true.
      this-object:FlagSepCash:UseVisualStyleBackColor = true.
      /*  */
      /* label3 */
      /*  */
      this-object:label3:Location = new System.Drawing.Point(12, 61).
      this-object:label3:Name = "label3".
      this-object:label3:Size = new System.Drawing.Size(199, 23).
      this-object:label3:TabIndex = 19.
      this-object:label3:Text = "Код/номер типа кассовой книги:".
      this-object:label3:UseCompatibleTextRendering = true.
      /*  */
      /* fExtCode */
      /*  */
      this-object:fExtCode:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "id", true)).
      this-object:fExtCode:Location = new System.Drawing.Point(268, 58).
      this-object:fExtCode:Name = "fExtCode".
      this-object:fExtCode:ReadOnly = true.
      this-object:fExtCode:Size = new System.Drawing.Size(156, 20).
      this-object:fExtCode:TabIndex = 4.
      /*  */
      /* label4 */
      /*  */
      this-object:label4:Location = new System.Drawing.Point(4, 20).
      this-object:label4:Name = "label4".
      this-object:label4:Size = new System.Drawing.Size(57, 23).
      this-object:label4:TabIndex = 21.
      this-object:label4:Text = "Кор.счет:".
      this-object:label4:UseCompatibleTextRendering = true.
      /*  */
      /* label41 */
      /*  */
      this-object:label41:Location = new System.Drawing.Point(4, 20).
      this-object:label41:Name = "label41".
      this-object:label41:Size = new System.Drawing.Size(57, 23).
      this-object:label41:TabIndex = 21.
      this-object:label41:Text = "Кор.счет:".
      this-object:label41:UseCompatibleTextRendering = true.
      /*  */
      /* label42 */
      /*  */
      this-object:label42:Location = new System.Drawing.Point(4, 20).
      this-object:label42:Name = "label42".
      this-object:label42:Size = new System.Drawing.Size(57, 23).
      this-object:label42:TabIndex = 21.
      this-object:label42:Text = "Кор.счет:".
      this-object:label42:UseCompatibleTextRendering = true.
      /*  */
      /* label7 */
      /*  */
      this-object:label7:Location = new System.Drawing.Point(11, 84).
      this-object:label7:Name = "label7".
      this-object:label7:Size = new System.Drawing.Size(199, 23).
      this-object:label7:TabIndex = 22.
      this-object:label7:Text = "Основной счет:".
      this-object:label7:UseCompatibleTextRendering = true.
      /*  */
      /* fCorpko */
      /*  */
      this-object:fCorpko:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "corrPko", true)).
      this-object:fCorpko:Location = new System.Drawing.Point(56, 19).
      this-object:fCorpko:Name = "fCorpko".
      this-object:fCorpko:Size = new System.Drawing.Size(52, 20).
      this-object:fCorpko:TabIndex = 5.
      /*  */
      /* fCorpkoVne */
      /*  */
      this-object:fCorpkoVne:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "corrPkoVne", true)).
      this-object:fCorpkoVne:Location = new System.Drawing.Point(56, 19).
      this-object:fCorpkoVne:Name = "fCorpkoVne".
      this-object:fCorpkoVne:Size = new System.Drawing.Size(52, 20).
      this-object:fCorpkoVne:TabIndex = 5.
      /*  */
      /* fCorpkoAvans */
      /*  */
      this-object:fCorpkoAvans:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "corrPkoAvans", true)).
      this-object:fCorpkoAvans:Location = new System.Drawing.Point(56, 19).
      this-object:fCorpkoAvans:Name = "fCorpkoAvans".
      this-object:fCorpkoAvans:Size = new System.Drawing.Size(52, 20).
      this-object:fCorpkoAvans:TabIndex = 5.
      /*  */
      /* fOsnacct */
      /*  */
      this-object:fOsnacct:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "osnAcct", true)).
      this-object:fOsnacct:Location = new System.Drawing.Point(267, 81).
      this-object:fOsnacct:Name = "fOsnacct".
      this-object:fOsnacct:Size = new System.Drawing.Size(128, 20).
      this-object:fOsnacct:TabIndex = 6.
      /*  */
      /* fRulePril */
      /*  */
      this-object:fRulePril:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "RulePril", true)).
      this-object:fRulePril:DropDownStyle = System.Windows.Forms.ComboBoxStyle:DropDownList.
      this-object:fRulePril:FormattingEnabled = true.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar2 as System.Object extent 2 no-undo.
      arrayvar2[1] = "Номера Z-отчетов".
      arrayvar2[2] = "Не заполнять".
      this-object:fRulePril:Items:AddRange(arrayvar2).
      this-object:fRulePril:Location = new System.Drawing.Point(267, 107).
      this-object:fRulePril:Name = "fRulePril".
      this-object:fRulePril:Size = new System.Drawing.Size(157, 21).
      this-object:fRulePril:TabIndex = 24.
      /*  */
      /* bChooseCorPko */
      /*  */
      this-object:bChooseCorPko:Location = new System.Drawing.Point(111, 17).
      this-object:bChooseCorPko:Name = "bChooseCorPko".
      this-object:bChooseCorPko:Size = new System.Drawing.Size(23, 23).
      this-object:bChooseCorPko:TabIndex = 25.
      this-object:bChooseCorPko:UseCompatibleTextRendering = true.
      this-object:bChooseCorPko:UseVisualStyleBackColor = true.
      this-object:bChooseCorPko:Click:Subscribe(this-object:bChooseCredit_Click).
      /*  */
      /* bChooseCorPkoVne */
      /*  */
      this-object:bChooseCorPkoVne:Location = new System.Drawing.Point(111, 17).
      this-object:bChooseCorPkoVne:Name = "bChooseCorPkoVne".
      this-object:bChooseCorPkoVne:Size = new System.Drawing.Size(23, 23).
      this-object:bChooseCorPkoVne:TabIndex = 25.
      this-object:bChooseCorPkoVne:UseCompatibleTextRendering = true.
      this-object:bChooseCorPkoVne:UseVisualStyleBackColor = true.
      this-object:bChooseCorPkoVne:Click:Subscribe(this-object:bChooseCreditVne_Click).
      /*  */
      /* bChooseCorPkoAvans */
      /*  */
      this-object:bChooseCorPkoAvans:Location = new System.Drawing.Point(111, 17).
      this-object:bChooseCorPkoAvans:Name = "bChooseCorPkoVne".
      this-object:bChooseCorPkoAvans:Size = new System.Drawing.Size(23, 23).
      this-object:bChooseCorPkoAvans:TabIndex = 25.
      this-object:bChooseCorPkoAvans:UseCompatibleTextRendering = true.
      this-object:bChooseCorPkoAvans:UseVisualStyleBackColor = true.
      this-object:bChooseCorPkoAvans:Click:Subscribe(this-object:bChooseCreditAvans_Click).
      /*  */
      /* bChooseOsnAcct */
      /*  */
      this-object:bChooseOsnAcct:Location = new System.Drawing.Point(401, 81).
      this-object:bChooseOsnAcct:Name = "bChooseOsnAcct".
      this-object:bChooseOsnAcct:Size = new System.Drawing.Size(23, 23).
      this-object:bChooseOsnAcct:TabIndex = 26.
      this-object:bChooseOsnAcct:UseCompatibleTextRendering = true.
      this-object:bChooseOsnAcct:UseVisualStyleBackColor = true.
      this-object:bChooseOsnAcct:Click:Subscribe(this-object:bChooseDebit_Click).
      /*  */
      /* label2 */
      /*  */
      this-object:label2:Location = new System.Drawing.Point(140, 20).
      this-object:label2:Name = "label2".
      this-object:label2:Size = new System.Drawing.Size(70, 24).
      this-object:label2:TabIndex = 27.
      this-object:label2:Text = "Контрагент:".
      this-object:label2:UseCompatibleTextRendering = true.
      /*  */
      /* label25 */
      /*  */
      this-object:label25:Location = new System.Drawing.Point(140, 20).
      this-object:label25:Name = "label25".
      this-object:label25:Size = new System.Drawing.Size(70, 24).
      this-object:label25:TabIndex = 27.
      this-object:label25:Text = "Контрагент:".
      this-object:label25:UseCompatibleTextRendering = true.
      /*  */
      /* label26 */
      /*  */
      this-object:label26:Location = new System.Drawing.Point(140, 20).
      this-object:label26:Name = "label26".
      this-object:label26:Size = new System.Drawing.Size(70, 24).
      this-object:label26:TabIndex = 27.
      this-object:label26:Text = "Контрагент:".
      this-object:label26:UseCompatibleTextRendering = true.
      /*  */
      /* label8 */
      /*  */
      this-object:label8:Location = new System.Drawing.Point(6, 69).
      this-object:label8:Name = "label8".
      this-object:label8:Size = new System.Drawing.Size(103, 15).
      this-object:label8:TabIndex = 28.
      this-object:label8:Text = "Принято от:".
      this-object:label8:UseCompatibleTextRendering = true.
      this-object:label8:Click:Subscribe(this-object:label8_Click).
      /*  */
      /* label81 */
      /*  */
      this-object:label81:Location = new System.Drawing.Point(6, 69).
      this-object:label81:Name = "label81".
      this-object:label81:Size = new System.Drawing.Size(103, 15).
      this-object:label81:TabIndex = 28.
      this-object:label81:Text = "Принято от:".
      this-object:label81:UseCompatibleTextRendering = true.
      this-object:label81:Click:Subscribe(this-object:label81_Click).
      /*  */
      /* label821 */
      /*  */
      this-object:label82:Location = new System.Drawing.Point(6, 69).
      this-object:label82:Name = "label82".
      this-object:label82:Size = new System.Drawing.Size(103, 15).
      this-object:label82:TabIndex = 28.
      this-object:label82:Text = "Принято от:".
      this-object:label82:UseCompatibleTextRendering = true.
      this-object:label82:Click:Subscribe(this-object:label82_Click).
      /*  */
      /* fTakenFrom */
      /*  */
      this-object:fTakenFrom:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "takenfrom", true)).
      this-object:fTakenFrom:Location = new System.Drawing.Point(121, 66).
      this-object:fTakenFrom:Name = "fTakenFrom".
      this-object:fTakenFrom:Size = new System.Drawing.Size(292, 20).
      this-object:fTakenFrom:TabIndex = 29.
      /*  */
      /* fTakenFromVne */
      /*  */
      this-object:fTakenFromVne:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "takenfromVne", true)).
      this-object:fTakenFromVne:Location = new System.Drawing.Point(121, 66).
      this-object:fTakenFromVne:Name = "fTakenFromVne".
      this-object:fTakenFromVne:Size = new System.Drawing.Size(292, 20).
      this-object:fTakenFromVne:TabIndex = 29.
      /*  */
      /* fTakenFromAvans */
      /*  */
      this-object:fTakenFromAvans:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "takenfromAvans", true)).
      this-object:fTakenFromAvans:Location = new System.Drawing.Point(121, 66).
      this-object:fTakenFromAvans:Name = "fTakenFromAvans".
      this-object:fTakenFromAvans:Size = new System.Drawing.Size(292, 20).
      this-object:fTakenFromAvans:TabIndex = 29.
      /*  */
      /* bChooseCli */
      /*  */
      this-object:bChooseCli:Location = new System.Drawing.Point(390, 12).
      this-object:bChooseCli:Name = "bChooseCli".
      this-object:bChooseCli:Size = new System.Drawing.Size(23, 23).
      this-object:bChooseCli:TabIndex = 30.
      this-object:bChooseCli:UseCompatibleTextRendering = true.
      this-object:bChooseCli:UseVisualStyleBackColor = true.
      this-object:bChooseCli:Click:Subscribe(this-object:bChooseCli_Click).
      /*  */
      /* bChooseCliVne */
      /*  */
      this-object:bChooseCliVne:Location = new System.Drawing.Point(390, 12).
      this-object:bChooseCliVne:Name = "bChooseCliVne".
      this-object:bChooseCliVne:Size = new System.Drawing.Size(23, 23).
      this-object:bChooseCliVne:TabIndex = 30.
      this-object:bChooseCliVne:UseCompatibleTextRendering = true.
      this-object:bChooseCliVne:UseVisualStyleBackColor = true.
      this-object:bChooseCliVne:Click:Subscribe(this-object:bChooseCliVne_Click).
      /*  */
      /* bChooseCliAvans */
      /*  */
      this-object:bChooseCliAvans:Location = new System.Drawing.Point(390, 12).
      this-object:bChooseCliAvans:Name = "bChooseCliAvans".
      this-object:bChooseCliAvans:Size = new System.Drawing.Size(23, 23).
      this-object:bChooseCliAvans:TabIndex = 30.
      this-object:bChooseCliAvans:UseCompatibleTextRendering = true.
      this-object:bChooseCliAvans:UseVisualStyleBackColor = true.
      this-object:bChooseCliAvans:Click:Subscribe(this-object:bChooseCliAvans_Click).
      /*  */
      /* lCli */
      /*  */
      this-object:lCli:Location = new System.Drawing.Point(206, 22).
      this-object:lCli:Name = "lCli".
      this-object:lCli:Size = new System.Drawing.Size(178, 15).
      this-object:lCli:TabIndex = 31.
      this-object:lCli:UseCompatibleTextRendering = true.
      this-object:lCli:Click:Subscribe(this-object:lCli_Click).
      /*  */
      /* lCliVne */
      /*  */
      this-object:lCliVne:Location = new System.Drawing.Point(206, 22).
      this-object:lCliVne:Name = "lCliVne".
      this-object:lCliVne:Size = new System.Drawing.Size(178, 15).
      this-object:lCliVne:TabIndex = 63.
      this-object:lCliVne:UseCompatibleTextRendering = true.
      this-object:lCliVne:Click:Subscribe(this-object:lCliVne_Click).
      /*  */
      /* lCliAvans */
      /*  */
      this-object:lCliAvans:Location = new System.Drawing.Point(206, 22).
      this-object:lCliAvans:Name = "lCliAvans".
      this-object:lCliAvans:Size = new System.Drawing.Size(178, 15).
      this-object:lCliAvans:TabIndex = 63.
      this-object:lCliAvans:UseCompatibleTextRendering = true.
      this-object:lCliAvans:Click:Subscribe(this-object:lCliAvans_Click).
      /*  */
      /* FcorRko */
      /*  */
      this-object:FcorRko:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "CorrRko", true)).
      this-object:FcorRko:Location = new System.Drawing.Point(58, 14).
      this-object:FcorRko:Name = "FcorRko".
      this-object:FcorRko:Size = new System.Drawing.Size(50, 20).
      this-object:FcorRko:TabIndex = 33.
      /*  */
      /* bChooseCorRko */
      /*  */
      this-object:bChooseCorRko:Location = new System.Drawing.Point(109, 14).
      this-object:bChooseCorRko:Name = "bChooseCorRko".
      this-object:bChooseCorRko:Size = new System.Drawing.Size(23, 23).
      this-object:bChooseCorRko:TabIndex = 34.
      this-object:bChooseCorRko:UseCompatibleTextRendering = true.
      this-object:bChooseCorRko:UseVisualStyleBackColor = true.
      this-object:bChooseCorRko:Click:Subscribe(this-object:bCorRko_Click).
      /*  */
      /* label9 */
      /*  */
      this-object:label9:Location = new System.Drawing.Point(4, 14).
      this-object:label9:Name = "label9".
      this-object:label9:Size = new System.Drawing.Size(54, 20).
      this-object:label9:TabIndex = 35.
      this-object:label9:Text = "Кор.счет:".
      this-object:label9:UseCompatibleTextRendering = true.
      /*  */
      /* fRuleOsnRko */
      /*  */
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true", Type="System.String").
      define variable arrayvar3 as CHARACTER extent 3 no-undo.
      arrayvar3[1] = "Выручка от реализации".
      arrayvar3[2] = "Номера Z-отчетов".
      arrayvar3[3] = "Не заполнять".
      this-object:fRuleOsnRko:AutoCompleteCustomSource:AddRange(arrayvar3).
      this-object:fRuleOsnRko:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "RuleOsnRko", true)).
      this-object:fRuleOsnRko:FormattingEnabled = true.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar4 as System.Object extent 3 no-undo.
      arrayvar4[1] = "Выручка от реализации".
      arrayvar4[2] = "Номера Z-отчетов".
      arrayvar4[3] = "Не заполнять".
      this-object:fRuleOsnRko:Items:AddRange(arrayvar4).
      this-object:fRuleOsnRko:Location = new System.Drawing.Point(247, 43).
      this-object:fRuleOsnRko:Name = "fRuleOsnRko".
      this-object:fRuleOsnRko:Size = new System.Drawing.Size(166, 21).
      this-object:fRuleOsnRko:TabIndex = 36.
      /*  */
      /* label10 */
      /*  */
      this-object:label10:Location = new System.Drawing.Point(4, 46).
      this-object:label10:Name = "label10".
      this-object:label10:Size = new System.Drawing.Size(237, 18).
      this-object:label10:TabIndex = 37.
      this-object:label10:Text = "Правило заполнения графы ~"Основание~":".
      this-object:label10:UseCompatibleTextRendering = true.
      /*  */
      /* fRuleOsnPko */
      /*  */
      this-object:fRuleOsnPko:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "RuleOsnPko", true)).
      this-object:fRuleOsnPko:FormattingEnabled = true.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar5 as System.Object extent 3 no-undo.
      arrayvar5[1] = "Выручка от реализации".
      arrayvar5[2] = "Номера Z-отчетов".
      arrayvar5[3] = "Не заполнять".
      this-object:fRuleOsnPko:Items:AddRange(arrayvar5).
      this-object:fRuleOsnPko:Location = new System.Drawing.Point(247, 43).
      this-object:fRuleOsnPko:Name = "fRuleOsnPko".
      this-object:fRuleOsnPko:Size = new System.Drawing.Size(166, 21).
      this-object:fRuleOsnPko:TabIndex = 38.
      this-object:fRuleOsnPko:SelectedIndexChanged:Subscribe(this-object:fRuleOsnPko_SelectedIndexChanged).
      /*  */
      /* fRuleOsnPkoAvans */
      /*  */
      this-object:fRuleOsnPkoAvans:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "RuleOsnPkoAvans", true)).
      this-object:fRuleOsnPkoAvans:FormattingEnabled = true.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar11 as System.Object extent 3 no-undo.
      arrayvar11[1] = "Авансы полученные – предоплата (аванс)".
      arrayvar11[2] = "Номера Z-отчетов".
      arrayvar11[3] = "Не заполнять".
      this-object:fRuleOsnPkoAvans:Items:AddRange(arrayvar5).
      this-object:fRuleOsnPkoAvans:Location = new System.Drawing.Point(247, 43).
      this-object:fRuleOsnPkoAvans:Name = "fRuleOsnPkoAvans".
      this-object:fRuleOsnPkoAvans:Size = new System.Drawing.Size(166, 21).
      this-object:fRuleOsnPkoAvans:TabIndex = 63.
      this-object:fRuleOsnPkoAvans:SelectedIndexChanged:Subscribe(this-object:fRuleOsnPkoAvans_SelectedIndexChanged).
      /*  */

      /* fRuleOsnPkoVne */
      /*  */
      this-object:fRuleOsnPkoVne:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "RuleOsnPkoVne", true)).
      this-object:fRuleOsnPkoVne:FormattingEnabled = true.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar10 as System.Object extent 3 no-undo.
      arrayvar10[1] = "Поступление денежных средств в возмещение причиненных Обществу убытков".
      arrayvar10[2] = "Номера Z-отчетов".
      arrayvar10[3] = "Не заполнять".
      this-object:fRuleOsnPkoVne:Items:AddRange(arrayvar10).
      this-object:fRuleOsnPkoVne:Location = new System.Drawing.Point(247, 43).
      this-object:fRuleOsnPkoVne:Name = "fRuleOsnPkoVne".
      this-object:fRuleOsnPkoVne:Size = new System.Drawing.Size(166, 21).
      this-object:fRuleOsnPkoVne:TabIndex = 62.
      this-object:fRuleOsnPkoVne:SelectedIndexChanged:Subscribe(this-object:fRuleOsnPkoVne_SelectedIndexChanged).
      /*  */
      /* label11 */
      /*  */
      this-object:label11:Location = new System.Drawing.Point(140, 19).
      this-object:label11:Name = "label11".
      this-object:label11:Size = new System.Drawing.Size(70, 18).
      this-object:label11:TabIndex = 39.
      this-object:label11:Text = "Контрагент:".
      this-object:label11:UseCompatibleTextRendering = true.
      /*  */
      /* lcashcli */
      /*  */
      this-object:lcashcli:Location = new System.Drawing.Point(216, 19).
      this-object:lcashcli:Name = "lcashcli".
      this-object:lcashcli:Size = new System.Drawing.Size(168, 15).
      this-object:lcashcli:TabIndex = 40.
      this-object:lcashcli:UseCompatibleTextRendering = true.
      /*  */
      /* label13 */
      /*  */
      this-object:label13:Location = new System.Drawing.Point(4, 73).
      this-object:label13:Name = "label13".
      this-object:label13:Size = new System.Drawing.Size(100, 23).
      this-object:label13:TabIndex = 41.
      this-object:label13:Text = "Банк-вноситель:".
      this-object:label13:UseCompatibleTextRendering = true.
      this-object:label13:Click:Subscribe(this-object:label13_Click).
      /*  */
      /* label14 */
      /*  */
      this-object:label14:Location = new System.Drawing.Point(4, 105).
      this-object:label14:Name = "label14".
      this-object:label14:Size = new System.Drawing.Size(100, 23).
      this-object:label14:TabIndex = 42.
      this-object:label14:Text = "Банк-получатель:".
      this-object:label14:UseCompatibleTextRendering = true.
      this-object:label14:Click:Subscribe(this-object:label14_Click).
      /*  */
      /* btcash */
      /*  */
      this-object:btcash:Location = new System.Drawing.Point(390, 14).
      this-object:btcash:Name = "btcash".
      this-object:btcash:Size = new System.Drawing.Size(23, 23).
      this-object:btcash:TabIndex = 43.
      this-object:btcash:UseCompatibleTextRendering = true.
      this-object:btcash:UseVisualStyleBackColor = true.
      this-object:btcash:Click:Subscribe(this-object:btincas_Click).
      /*  */
      /* label15 */
      /*  */
      this-object:label15:Location = new System.Drawing.Point(4, 168).
      this-object:label15:Name = "label15".
      this-object:label15:Size = new System.Drawing.Size(156, 23).
      this-object:label15:TabIndex = 44.
      this-object:label15:Text = "Код источника поступления:".
      this-object:label15:UseCompatibleTextRendering = true.
      /*  */
      /* fSourceCode */
      /*  */
      this-object:fSourceCode:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "SourceCode", true)).
      this-object:fSourceCode:FormattingEnabled = true.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar6 as System.Object extent 2 no-undo.
      arrayvar6[1] = "02".
      arrayvar6[2] = "32".
      this-object:fSourceCode:Items:AddRange(arrayvar6).
      this-object:fSourceCode:Location = new System.Drawing.Point(166, 167).
      this-object:fSourceCode:Name = "fSourceCode".
      this-object:fSourceCode:Size = new System.Drawing.Size(247, 21).
      this-object:fSourceCode:TabIndex = 45.
      /*  */
      /* lbankdep */
      /*  */
      this-object:lbankdep:AutoEllipsis = true.
      this-object:lbankdep:Location = new System.Drawing.Point(111, 73).
      this-object:lbankdep:Name = "lbankdep".
      this-object:lbankdep:Size = new System.Drawing.Size(273, 15).
      this-object:lbankdep:TabIndex = 46.
      this-object:lbankdep:UseCompatibleTextRendering = true.
      /*  */
      /* lbankrec */
      /*  */
      this-object:lbankrec:AutoEllipsis = true.
      this-object:lbankrec:Location = new System.Drawing.Point(112, 105).
      this-object:lbankrec:Name = "lbankrec".
      this-object:lbankrec:Size = new System.Drawing.Size(272, 15).
      this-object:lbankrec:TabIndex = 47.
      this-object:lbankrec:UseCompatibleTextRendering = true.
      this-object:lbankrec:Click:Subscribe(this-object:lbankrec_Click).
      /*  */
      /* btbankdep */
      /*  */
      this-object:btbankdep:Location = new System.Drawing.Point(390, 69).
      this-object:btbankdep:Name = "btbankdep".
      this-object:btbankdep:Size = new System.Drawing.Size(23, 23).
      this-object:btbankdep:TabIndex = 48.
      this-object:btbankdep:UseCompatibleTextRendering = true.
      this-object:btbankdep:UseVisualStyleBackColor = true.
      this-object:btbankdep:Click:Subscribe(this-object:btbankdep_Click).
      /*  */
      /* btbankrec */
      /*  */
      this-object:btbankrec:Location = new System.Drawing.Point(390, 105).
      this-object:btbankrec:Name = "btbankrec".
      this-object:btbankrec:Size = new System.Drawing.Size(23, 23).
      this-object:btbankrec:TabIndex = 49.
      this-object:btbankrec:UseCompatibleTextRendering = true.
      this-object:btbankrec:UseVisualStyleBackColor = true.
      this-object:btbankrec:Click:Subscribe(this-object:btbankrec_Click).
      /*  */
      /* label12 */
      /*  */
      this-object:label12:Location = new System.Drawing.Point(4, 139).
      this-object:label12:Name = "label12".
      this-object:label12:Size = new System.Drawing.Size(100, 23).
      this-object:label12:TabIndex = 50.
      this-object:label12:Text = "Счет получателя:".
      this-object:label12:UseCompatibleTextRendering = true.
      /*  */
      /* BankRecipacct */
      /*  */
      this-object:BankRecipacct:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "BankRecip-acct", true)).
      this-object:BankRecipacct:Location = new System.Drawing.Point(166, 139).
      this-object:BankRecipacct:Name = "BankRecipacct".
      this-object:BankRecipacct:Size = new System.Drawing.Size(247, 20).
      this-object:BankRecipacct:TabIndex = 51.
      /*  */
      /* label16 */
      /*  */
      this-object:label16:Location = new System.Drawing.Point(4, 19).
      this-object:label16:Name = "label16".
      this-object:label16:Size = new System.Drawing.Size(54, 23).
      this-object:label16:TabIndex = 54.
      this-object:label16:Text = "Кор.счет:".
      this-object:label16:UseCompatibleTextRendering = true.
      /*  */
      /* btcorrRKOincas */
      /*  */
      this-object:btcorrRKOincas:Location = new System.Drawing.Point(109, 17).
      this-object:btcorrRKOincas:Name = "btcorrRKOincas".
      this-object:btcorrRKOincas:Size = new System.Drawing.Size(23, 23).
      this-object:btcorrRKOincas:TabIndex = 53.
      this-object:btcorrRKOincas:UseCompatibleTextRendering = true.
      this-object:btcorrRKOincas:UseVisualStyleBackColor = true.
      this-object:btcorrRKOincas:Click:Subscribe(this-object:btcorrRKOincas_Click).
      /*  */
      /* FcorrRKOincas */
      /*  */
      this-object:FcorrRKOincas:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "CorrAcctIncas", true)).
      this-object:FcorrRKOincas:Location = new System.Drawing.Point(58, 19).
      this-object:FcorrRKOincas:Name = "FcorrRKOincas".
      this-object:FcorrRKOincas:Size = new System.Drawing.Size(50, 20).
      this-object:FcorrRKOincas:TabIndex = 52.
      /*  */
      /* label17 */
      /*  */
      this-object:label17:Location = new System.Drawing.Point(14, 499).
      this-object:label17:Name = "label17".
      this-object:label17:Size = new System.Drawing.Size(254, 30).
      this-object:label17:TabIndex = 56.
      this-object:label17:Text = "Правило заполнения графы ~"Основание~" РКО: (Инкассация)".
      this-object:label17:UseCompatibleTextRendering = true.
      /*  */
      /* FOsnIncas */
      /*  */
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true", Type="System.String").
      define variable arrayvar7 as CHARACTER extent 3 no-undo.
      arrayvar7[1] = "Выручка от реализации".
      arrayvar7[2] = "Номера Z-отчетов".
      arrayvar7[3] = "Не заполнять".
      this-object:FOsnIncas:AutoCompleteCustomSource:AddRange(arrayvar7).
      this-object:FOsnIncas:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "BasisIncas", true)).
      this-object:FOsnIncas:FormattingEnabled = true.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar8 as System.Object extent 3 no-undo.
      arrayvar8[1] = "Выручка от реализации".
      arrayvar8[2] = "Номера Z-отчетов".
      arrayvar8[3] = "Не заполнять".
      this-object:FOsnIncas:Items:AddRange(arrayvar8).
      this-object:FOsnIncas:Location = new System.Drawing.Point(238, 42).
      this-object:FOsnIncas:Name = "FOsnIncas".
      this-object:FOsnIncas:Size = new System.Drawing.Size(175, 21).
      this-object:FOsnIncas:TabIndex = 55.
      /*  */
      /* button1 */
      /*  */
      this-object:button1:Location = new System.Drawing.Point(390, 14).
      this-object:button1:Name = "button1".
      this-object:button1:Size = new System.Drawing.Size(23, 23).
      this-object:button1:TabIndex = 59.
      this-object:button1:UseCompatibleTextRendering = true.
      this-object:button1:UseVisualStyleBackColor = true.
      this-object:button1:Click:Subscribe(this-object:button1_Click).
      /*  */
      /* Lincasagent */
      /*  */
      this-object:Lincasagent:Location = new System.Drawing.Point(206, 19).
      this-object:Lincasagent:Name = "Lincasagent".
      this-object:Lincasagent:Size = new System.Drawing.Size(178, 15).
      this-object:Lincasagent:TabIndex = 58.
      this-object:Lincasagent:UseCompatibleTextRendering = true.
      /*  */
      /* label19 */
      /*  */
      this-object:label19:Location = new System.Drawing.Point(138, 19).
      this-object:label19:Name = "label19".
      this-object:label19:Size = new System.Drawing.Size(72, 23).
      this-object:label19:TabIndex = 57.
      this-object:label19:Text = "Контрагент:".
      this-object:label19:UseCompatibleTextRendering = true.
      /*  */
      /* groupBox5 */
      /*  */
      this-object:groupBox5:Controls:Add(this-object:fRuleOsnPkoVne).
      this-object:groupBox5:Controls:Add(this-object:lCliVne).
      this-object:groupBox5:Controls:Add(this-object:bChooseCliVne).
      this-object:groupBox5:Controls:Add(this-object:label25).
      this-object:groupBox5:Controls:Add(this-object:bChooseCorPkoVne).
      this-object:groupBox5:Controls:Add(this-object:fTakenFromVne).
      this-object:groupBox5:Controls:Add(this-object:fCorpkoVne).
      this-object:groupBox5:Controls:Add(this-object:label81).
      this-object:groupBox5:Controls:Add(this-object:label41).
      this-object:groupBox5:Controls:Add(this-object:label51).
      this-object:groupBox5:Location = new System.Drawing.Point(14, 293).
      this-object:groupBox5:Name = "groupBox5".
      this-object:groupBox5:Size = new System.Drawing.Size(428, 97).
      this-object:groupBox5:TabIndex = 61.
      this-object:groupBox5:TabStop = false.
      this-object:groupBox5:Text = "ПКО (внереализационный доход)".
      this-object:groupBox5:UseCompatibleTextRendering = true.
      /*  */
      /* groupBox6 */
      /*  */
      this-object:groupBox6:Controls:Add(this-object:fRuleOsnPkoAvans).
      this-object:groupBox6:Controls:Add(this-object:lCliAvans).
      this-object:groupBox6:Controls:Add(this-object:bChooseCliAvans).
      this-object:groupBox6:Controls:Add(this-object:label26).
      this-object:groupBox6:Controls:Add(this-object:bChooseCorPkoAvans).
      this-object:groupBox6:Controls:Add(this-object:fTakenFromAvans).
      this-object:groupBox6:Controls:Add(this-object:fCorpkoAvans).
      this-object:groupBox6:Controls:Add(this-object:label82).
      this-object:groupBox6:Controls:Add(this-object:label42).
      this-object:groupBox6:Controls:Add(this-object:label52).
      this-object:groupBox6:Location = new System.Drawing.Point(16, 396).
      this-object:groupBox6:Name = "groupBox6".
      this-object:groupBox6:Size = new System.Drawing.Size(428, 97).
      this-object:groupBox6:TabIndex = 62.
      this-object:groupBox6:TabStop = false.
      this-object:groupBox6:Text = "ПКО (аванс)".
      this-object:groupBox6:UseCompatibleTextRendering = true.
      /*  */
      /* groupBox1 */
      /*  */
      this-object:groupBox1:Controls:Add(this-object:fRuleOsnPko).
      this-object:groupBox1:Controls:Add(this-object:lCli).
      this-object:groupBox1:Controls:Add(this-object:bChooseCli).
      this-object:groupBox1:Controls:Add(this-object:label2).
      this-object:groupBox1:Controls:Add(this-object:bChooseCorPko).
      this-object:groupBox1:Controls:Add(this-object:fTakenFrom).
      this-object:groupBox1:Controls:Add(this-object:fCorpko).
      this-object:groupBox1:Controls:Add(this-object:label8).
      this-object:groupBox1:Controls:Add(this-object:label4).
      this-object:groupBox1:Controls:Add(this-object:label5).
      this-object:groupBox1:Location = new System.Drawing.Point(12, 190).
      this-object:groupBox1:Name = "groupBox1".
      this-object:groupBox1:Size = new System.Drawing.Size(428, 97).
      this-object:groupBox1:TabIndex = 60.
      this-object:groupBox1:TabStop = false.
      this-object:groupBox1:Text = "ПКО (авто)".
      this-object:groupBox1:UseCompatibleTextRendering = true.
      /*  */
      /* groupBox2 */
      /*  */
      this-object:groupBox2:Controls:Add(this-object:textBox1).
      this-object:groupBox2:Controls:Add(this-object:label20).
      this-object:groupBox2:Controls:Add(this-object:label10).
      this-object:groupBox2:Controls:Add(this-object:fRuleOsnRko).
      this-object:groupBox2:Controls:Add(this-object:label9).
      this-object:groupBox2:Controls:Add(this-object:bChooseCorRko).
      this-object:groupBox2:Controls:Add(this-object:FcorRko).
      this-object:groupBox2:Controls:Add(this-object:label11).
      this-object:groupBox2:Controls:Add(this-object:lcashcli).
      this-object:groupBox2:Controls:Add(this-object:btcash).
      this-object:groupBox2:Location = new System.Drawing.Point(14, 499).
      this-object:groupBox2:Name = "groupBox2".
      this-object:groupBox2:Size = new System.Drawing.Size(428, 94).
      this-object:groupBox2:TabIndex = 61.
      this-object:groupBox2:TabStop = false.
      this-object:groupBox2:Text = "РКО (авто)".
      this-object:groupBox2:UseCompatibleTextRendering = true.
      this-object:groupBox2:Enter:Subscribe(this-object:groupBox2_Enter).
      /*  */
      /* textBox1 */
      /*  */
      this-object:textBox1:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "rule-payer-rko", true)).
      this-object:textBox1:Location = new System.Drawing.Point(121, 67).
      this-object:textBox1:Name = "textBox1".
      this-object:textBox1:Size = new System.Drawing.Size(292, 20).
      this-object:textBox1:TabIndex = 39.
      /*  */
      /* label20 */
      /*  */
      this-object:label20:Location = new System.Drawing.Point(6, 70).
      this-object:label20:Name = "label20".
      this-object:label20:Size = new System.Drawing.Size(103, 15).
      this-object:label20:TabIndex = 44.
      this-object:label20:Text = "Выдать:".
      this-object:label20:UseCompatibleTextRendering = true.
      /*  */
      /* groupBox3 */
      /*  */
      this-object:groupBox3:Controls:Add(this-object:label18).
      this-object:groupBox3:Controls:Add(this-object:button1).
      this-object:groupBox3:Controls:Add(this-object:Lincasagent).
      this-object:groupBox3:Controls:Add(this-object:label19).
      this-object:groupBox3:Controls:Add(this-object:FOsnIncas).
      this-object:groupBox3:Controls:Add(this-object:label16).
      this-object:groupBox3:Controls:Add(this-object:btcorrRKOincas).
      this-object:groupBox3:Controls:Add(this-object:FcorrRKOincas).
      this-object:groupBox3:Controls:Add(this-object:BankRecipacct).
      this-object:groupBox3:Controls:Add(this-object:label12).
      this-object:groupBox3:Controls:Add(this-object:btbankrec).
      this-object:groupBox3:Controls:Add(this-object:btbankdep).
      this-object:groupBox3:Controls:Add(this-object:lbankrec).
      this-object:groupBox3:Controls:Add(this-object:lbankdep).
      this-object:groupBox3:Controls:Add(this-object:fSourceCode).
      this-object:groupBox3:Controls:Add(this-object:label15).
      this-object:groupBox3:Controls:Add(this-object:label14).
      this-object:groupBox3:Controls:Add(this-object:label13).
      this-object:groupBox3:Location = new System.Drawing.Point(14, 596).
      this-object:groupBox3:Name = "groupBox3".
      this-object:groupBox3:Size = new System.Drawing.Size(428, 198).
      this-object:groupBox3:TabIndex = 62.
      this-object:groupBox3:TabStop = false.
      this-object:groupBox3:Text = " РКО (Инкассация)".
      this-object:groupBox3:UseCompatibleTextRendering = true.
      this-object:groupBox3:Enter:Subscribe(this-object:groupBox3_Enter).
      /*  */
      /* label18 */
      /*  */
      this-object:label18:Location = new System.Drawing.Point(4, 42).
      this-object:label18:Name = "label18".
      this-object:label18:Size = new System.Drawing.Size(226, 21).
      this-object:label18:TabIndex = 60.
      this-object:label18:Text = "Правило заполнения графы ~"Основание~":".
      this-object:label18:UseCompatibleTextRendering = true.
      /*  */
      /* groupBox4 */
      /*  */
      this-object:groupBox4:Controls:Add(this-object:textBox2).
      this-object:groupBox4:Controls:Add(this-object:label24).
      this-object:groupBox4:Controls:Add(this-object:fosntrans).
      this-object:groupBox4:Controls:Add(this-object:lclitrans).
      this-object:groupBox4:Controls:Add(this-object:button2).
      this-object:groupBox4:Controls:Add(this-object:label21).
      this-object:groupBox4:Controls:Add(this-object:button3).
      this-object:groupBox4:Controls:Add(this-object:fcorrtrans).
      this-object:groupBox4:Controls:Add(this-object:label22).
      this-object:groupBox4:Controls:Add(this-object:label23).
      this-object:groupBox4:Location = new System.Drawing.Point(14, 804).
      this-object:groupBox4:Name = "groupBox4".
      this-object:groupBox4:Size = new System.Drawing.Size(428, 103).
      this-object:groupBox4:TabIndex = 61.
      this-object:groupBox4:TabStop = false.
      this-object:groupBox4:Text = "ПКО/РКО (перемещения ДС)".
      this-object:groupBox4:UseCompatibleTextRendering = true.
      /*  */
      /* textBox2 */
      /*  */
      this-object:textBox2:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "rule-payer-transf", true)).
      this-object:textBox2:Location = new System.Drawing.Point(121, 69).
      this-object:textBox2:Name = "textBox2".
      this-object:textBox2:Size = new System.Drawing.Size(292, 20).
      this-object:textBox2:TabIndex = 45.
      /*  */
      /* label24 */
      /*  */
      this-object:label24:Location = new System.Drawing.Point(6, 72).
      this-object:label24:Name = "label24".
      this-object:label24:Size = new System.Drawing.Size(109, 15).
      this-object:label24:TabIndex = 45.
      this-object:label24:Text = "Выдать\Принято от:".
      this-object:label24:UseCompatibleTextRendering = true.
      /*  */
      /* fosntrans */
      /*  */
      this-object:fosntrans:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "rule-osn-transf", true)).
      this-object:fosntrans:FormattingEnabled = true.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar9 as System.Object extent 3 no-undo.
      arrayvar9[1] = "Выручка от реализации".
      arrayvar9[2] = "Номера Z-отчетов".
      arrayvar9[3] = "Не заполнять".
      this-object:fosntrans:Items:AddRange(arrayvar9).
      this-object:fosntrans:Location = new System.Drawing.Point(247, 43).
      this-object:fosntrans:Name = "fosntrans".
      this-object:fosntrans:Size = new System.Drawing.Size(166, 21).
      this-object:fosntrans:TabIndex = 38.
      /*  */
      /* lclitrans */
      /*  */
      this-object:lclitrans:Location = new System.Drawing.Point(206, 20).
      this-object:lclitrans:Name = "lclitrans".
      this-object:lclitrans:Size = new System.Drawing.Size(178, 15).
      this-object:lclitrans:TabIndex = 31.
      this-object:lclitrans:UseCompatibleTextRendering = true.
      /*  */
      /* button2 */
      /*  */
      this-object:button2:Location = new System.Drawing.Point(390, 12).
      this-object:button2:Name = "button2".
      this-object:button2:Size = new System.Drawing.Size(23, 23).
      this-object:button2:TabIndex = 30.
      this-object:button2:UseCompatibleTextRendering = true.
      this-object:button2:UseVisualStyleBackColor = true.
      this-object:button2:Click:Subscribe(this-object:button2_Click).
      /*  */
      /* label21 */
      /*  */
      this-object:label21:Location = new System.Drawing.Point(140, 20).
      this-object:label21:Name = "label21".
      this-object:label21:Size = new System.Drawing.Size(70, 24).
      this-object:label21:TabIndex = 27.
      this-object:label21:Text = "Контрагент:".
      this-object:label21:UseCompatibleTextRendering = true.
      /*  */
      /* button3 */
      /*  */
      this-object:button3:Location = new System.Drawing.Point(111, 17).
      this-object:button3:Name = "button3".
      this-object:button3:Size = new System.Drawing.Size(23, 23).
      this-object:button3:TabIndex = 25.
      this-object:button3:UseCompatibleTextRendering = true.
      this-object:button3:UseVisualStyleBackColor = true.
      /*  */
      /* fcorrtrans */
      /*  */
      this-object:fcorrtrans:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "Corr-transf", true)).
      this-object:fcorrtrans:Location = new System.Drawing.Point(58, 20).
      this-object:fcorrtrans:Name = "fcorrtrans".
      this-object:fcorrtrans:Size = new System.Drawing.Size(52, 20).
      this-object:fcorrtrans:TabIndex = 5.
      /*  */
      /* label22 */
      /*  */
      this-object:label22:Location = new System.Drawing.Point(4, 20).
      this-object:label22:Name = "label22".
      this-object:label22:Size = new System.Drawing.Size(54, 23).
      this-object:label22:TabIndex = 21.
      this-object:label22:Text = "Кор.счет:".
      this-object:label22:UseCompatibleTextRendering = true.
      /*  */
      /* label23 */
      /*  */
      this-object:label23:Location = new System.Drawing.Point(4, 43).
      this-object:label23:Name = "label23".
      this-object:label23:Size = new System.Drawing.Size(237, 23).
      this-object:label23:TabIndex = 10.
      this-object:label23:Text = "Правило заполнения графы ~"Основание~":".
      this-object:label23:UseCompatibleTextRendering = true.
      /*  */
      /* cashbookfrm */
      /*  */
      this-object:AcceptButton = this-object:buttonOk.
      this-object:CancelButton = this-object:buttonCancel.
      this-object:ClientSize = new System.Drawing.Size(458, 916).
      this-object:Controls:Add(this-object:groupBox5).
      this-object:Controls:Add(this-object:groupBox6).
      this-object:Controls:Add(this-object:groupBox4).
      this-object:Controls:Add(this-object:groupBox3).
      this-object:Controls:Add(this-object:groupBox2).
      this-object:Controls:Add(this-object:groupBox1).
      this-object:Controls:Add(this-object:label17).
      this-object:Controls:Add(this-object:bChooseOsnAcct).
      this-object:Controls:Add(this-object:fRulePril).
      this-object:Controls:Add(this-object:fOsnacct).
      this-object:Controls:Add(this-object:label7).
      this-object:Controls:Add(this-object:fExtCode).
      this-object:Controls:Add(this-object:label3).
      this-object:Controls:Add(this-object:FlagSepCash).
      this-object:Controls:Add(this-object:FlagSepFuel).
      this-object:Controls:Add(this-object:label6).
      this-object:Controls:Add(this-object:fName).
      this-object:Controls:Add(this-object:label1).
      this-object:Controls:Add(this-object:buttonCancel).
      this-object:Controls:Add(this-object:buttonOk).
      this-object:FormBorderStyle = System.Windows.Forms.FormBorderStyle:FixedDialog.
      this-object:MaximizeBox = false.
      this-object:MinimizeBox = false.
      this-object:Name = "cashbookfrm".
      this-object:ShowInTaskbar = false.
      this-object:StartPosition = System.Windows.Forms.FormStartPosition:CenterParent.
      this-object:Text = "Кассовая книга".
      this-object:Load:Subscribe(this-object:cashbookfrm_Load).
      cast(this-object:bindingSource1, System.ComponentModel.ISupportInitialize):EndInit().
      this-object:groupBox1:ResumeLayout(false).
      this-object:groupBox1:PerformLayout().
      this-object:groupBox2:ResumeLayout(false).
      this-object:groupBox2:PerformLayout().
      this-object:groupBox3:ResumeLayout(false).
      this-object:groupBox3:PerformLayout().
      this-object:groupBox4:ResumeLayout(false).
      this-object:groupBox4:PerformLayout().
      this-object:groupBox5:ResumeLayout(false).
      this-object:groupBox5:PerformLayout().      
      this-object:groupBox6:ResumeLayout(false).
      this-object:groupBox6:PerformLayout().    
      this-object:ResumeLayout(false).
      this-object:PerformLayout().
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end method. 
 
   method public void ShowModalDialog(  ):
      
      wait-for this-object:ShowDialog().

   end method.

   method public void Visual_form( input iChange AS character ): 
    
      find first ub.clients no-lock where ub.clients.obj-type = tt-cashbook.cli-type
         and ub.clients.obj-code = tt-cashbook.cli-code
         no-error .
      if available ub.clients
         then 
      do :
         this-object:lCli:Text = ub.clients.obj-type + string(ub.clients.obj-code) + "   " + ub.clients.obj-name .
      end.

      find first ub.clients no-lock where ub.clients.obj-type = tt-cashbook.Vnecli-type
         and ub.clients.obj-code = tt-cashbook.Vnecli-code
         no-error .
      if available ub.clients
         then 
      do :
         this-object:lCliVne:Text = ub.clients.obj-type + string(ub.clients.obj-code) + "   " + ub.clients.obj-name .
      end.

      find first ub.clients no-lock where ub.clients.obj-type = tt-cashbook.Avanscli-type
         and ub.clients.obj-code = tt-cashbook.Avanscli-code
         no-error .
      if available ub.clients
         then 
      do :
         this-object:lCliAvans:Text = ub.clients.obj-type + string(ub.clients.obj-code) + "   " + ub.clients.obj-name .
      end.
                
      find first ub.clients no-lock where ub.clients.obj-type = tt-cashbook.CountCash-type
         and ub.clients.obj-code = tt-cashbook.CountCash-code
         no-error .
      if available ub.clients
         then 
      do :
         this-object:lcashcli:Text = ub.clients.obj-type + string(ub.clients.obj-code) + "   " + ub.clients.obj-name .
      end.
      find first ub.clients no-lock where ub.clients.obj-type = tt-cashbook.CountCollect-type
         and ub.clients.obj-code = tt-cashbook.CountCollect-code
         no-error .
      if available ub.clients
         then 
      do :
         this-object:Lincasagent:Text = ub.clients.obj-type + string(ub.clients.obj-code) + "   " + ub.clients.obj-name .
      end.
      find first ub.clients no-lock where ub.clients.obj-type = tt-cashbook.contr-type-transf
         and ub.clients.obj-code = tt-cashbook.contr-code-transf
         no-error .
      if available ub.clients
         then 
      do :
         this-object:lclitrans:Text = ub.clients.obj-type + string(ub.clients.obj-code) + "   " + ub.clients.obj-name .
      end.
      find first fin-bank where fin-bank.host-code = tt-cashbook.BankRecip-host  
         and fin-bank.code-bank = tt-cashbook.BankRecip-code  no-lock no-error.
      if available fin-bank 
         then
         lbankrec:text              = fin-bank.bank-name.                                 
    
      find first fin-bank where fin-bank.host-code = tt-cashbook.Bankdepos-host  
         and fin-bank.code-bank = tt-cashbook.Bankdepos-code  no-lock no-error.
      if available fin-bank 
         then
         lbankdep:text              = fin-bank.bank-name.                                 
    
      
      if iChange = {&lookup} then 
      do:  
        assign
          this-object:fExtCode:ReadOnly          = true
          this-object:fName:ReadOnly             = true
          this-object:fCorpko:ReadOnly           = true
          this-object:fCorpkoVne:ReadOnly        = true
          this-object:fCorpkoAvans:ReadOnly      = true
          this-object:FcorRko:ReadOnly           = true
          this-object:fOsnacct:ReadOnly          = true
          this-object:fTakenFrom:ReadOnly        = true
          this-object:fTakenFromVne:ReadOnly     = true
          this-object:fTakenFromAvans:ReadOnly   = true
          this-object:fRuleOsnPko:Enabled        = false
          this-object:fRuleOsnPkoAvans:Enabled   = false
          this-object:fRuleOsnPkoVne:Enabled     = false
          this-object:fRuleOsnRko:Enabled        = false
          this-object:fRulePril:Enabled          = false
          this-object:FlagSepCash:Enabled        = false
          this-object:FlagSepFuel:Enabled        = false
          this-object:buttonOk:Enabled           = false
          this-object:bChooseOsnAcct:Enabled     = false
          this-object:bChooseCorPko:Enabled      = false
          this-object:bChooseCorPkoVne:Enabled   = false
          this-object:bChooseCorPkoAvans:Enabled = false
          this-object:bChooseCorRko:Enabled      = false
          this-object:bChooseCli:Enabled         = false
          this-object:bChooseCliVne:Enabled      = false
          this-object:bChooseCliAvans:Enabled    = false
          this-object:groupBox5:Enabled          = false
          this-object:groupBox6:Enabled          = false
          this-object:groupBox4:Enabled          = false
          this-object:groupBox3:Enabled          = false
          this-object:groupBox2:Enabled          = false
          this-object:groupBox1:Enabled          = false
            
          .
      end.
      return.
   end method .
 
end class.
