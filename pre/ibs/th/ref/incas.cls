using Progress.Lang.*.
using Progress.Windows.Form.
block-level on error undo, throw.
class ibs.th.ref.incas inherits Form:
   define private variable Bt_ok as System.Windows.Forms.Button no-undo.
   define private variable button1 as System.Windows.Forms.Button no-undo.
   define private variable components as System.ComponentModel.IContainer no-undo.
   define private variable fOsn as System.Windows.Forms.TextBox no-undo.
   define private variable label2 as System.Windows.Forms.Label no-undo.
   define private variable label1 as System.Windows.Forms.Label no-undo.
   define private variable fSum as System.Windows.Forms.TextBox no-undo.
   define private variable windowContainer1 as ibs.th.ref.Coins_Banknot no-undo.
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
define temp-table tt-cashBookOst no-undo
field chang      as logical
field cashbookid as int64
field cashbookname as character
field ost        as decimal
field ostrasch   as decimal
field osnpko     as decimal
field osnrko     as decimal
index pi cashbookid.
   define public variable mSumm as decimal  no-undo.
   define public variable mosnbag as character no-undo.
   define public variable mdopbag as character no-undo.
   define public variable mMoney as character no-undo.
   define private variable OstCash as class ibs.th.ref.ostcashbook no-undo.
   define private variable mtrgOst as class ibs.th.ref.ostcashbook_trg no-undo.
  define public property maxSum    as decimal  no-undo init ?
  private get.
  set(input isum as decimal ):
    maxSum = iSum.
    fSum:text = string(maxSum).
  end.
   constructor public incas (  ):
      super().
      mtrgOst = new ibs.th.ref.ostcashbook_trg().
      InitializeComponent().
      OstCash:trgOst = mtrgOst.
      add_Banknot().
      windowContainer1:Update_Banknots (getq_Banknot()).
      add_Coints().
      windowContainer1:Update_coints( getq_Coints()).
      windowContainer1:Fsumm:ReadOnly = yes.
      this-object:ComponentsCollection:ADD(this-object:components).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end constructor.
        @VisualDesigner.
        method private void Bt_ok_Click( input sender as System.Object, input e as System.EventArgs ):
           define variable Vmoney as longchar  no-undo.
           if     windowContainer1:v-total-sum ne 0
              and windowContainer1:v-total-sum ne dec(fSum:text)
           then do:
              message "Введенная сумма не соответствует введенным номиналам"
         view-as alert-box.
         return.
      end.
      if      maxSum ne ?
          and dec(fSum:text) > maxSum
      then do:
         message "Сумма инкассации " dec(fSum:text) " не может быть больше суммы денег в кассе " maxSum
         view-as alert-box.
         return.
      end.
      if  mtrgOst:ChekSumm
          and mtrgOst:summ < dec(fSum:text)
      then do:
         message "Сумма инкассации " dec(fSum:text) " по не основным кассовым книгам не может быть больше суммы денег в кассе " mtrgOst:summ
         view-as alert-box.
         return.
      end.
      if trim(fOsn:text) eq ""
      then do:
         message "Не указан номер сумки."
         view-as alert-box.
         return.
      end.
              if windowContainer1:v-total-sum eq 0
              then
                 Vmoney = "".
              else
                 dataset ds-banknots:write-json("longchar", Vmoney).
           this-object:mSumm = dec(fSum:text).
           this-object:mosnbag = trim(fOsn:text).
          // this-object:mdopbag = trim(if fDop:text eq "" or fDop:text eq ? then fOsn:text else fDop:text).
           this-object:mMoney  = Vmoney.
                this-object:DialogResult = System.Windows.Forms.DialogResult:Ok.
                this-object:Close ( ).
                return.
        end method.
        @VisualDesigner.
        method private void button1_Click( input sender as System.Object, input e as System.EventArgs ):
           this-object:Close ( ).
           return.
        end method.
        @VisualDesigner.
        method private void fOsn_TextChanged( input sender as System.Object, input e as System.EventArgs ):
                //fDop:visible    = fosn:text ne "" and fosn:text ne ?.
                //label3:visible  = fosn:text ne "" and fosn:text ne ?.
                return.
        end method.
   method private void InitializeComponent(  ):
      this-object:windowContainer1 = new ibs.th.ref.Coins_Banknot().
      this-object:button1 = new System.Windows.Forms.Button().
      this-object:Bt_ok = new System.Windows.Forms.Button().
      this-object:fSum = new System.Windows.Forms.TextBox().
      this-object:label1 = new System.Windows.Forms.Label().
      this-object:fOsn = new System.Windows.Forms.TextBox().
      this-object:label2 = new System.Windows.Forms.Label().
      this-object:ostcash = new ibs.th.ref.ostcashbook().
      this-object:SuspendLayout().
      this-object:windowContainer1:Location = new System.Drawing.Point(24, 237).
      this-object:windowContainer1:Name = "windowContainer1".
      this-object:windowContainer1:Size = new System.Drawing.Size(677, 285).
      this-object:windowContainer1:TabIndex = 0.
      this-object:button1:Location = new System.Drawing.Point(403, 528).
      this-object:button1:Name = "button1".
      this-object:button1:Size = new System.Drawing.Size(75, 23).
      this-object:button1:TabIndex = 1.
      this-object:button1:Text = "Отмена".
      this-object:button1:UseCompatibleTextRendering = true.
      this-object:button1:UseVisualStyleBackColor = true.
      this-object:button1:Click:Subscribe(this-object:button1_Click).
      this-object:Bt_ok:Location = new System.Drawing.Point(269, 528).
      this-object:Bt_ok:Name = "Bt_ok".
      this-object:Bt_ok:Size = new System.Drawing.Size(110, 23).
      this-object:Bt_ok:TabIndex = 2.
      this-object:Bt_ok:Text = "Сформировать".
      this-object:Bt_ok:UseCompatibleTextRendering = true.
      this-object:Bt_ok:UseVisualStyleBackColor = true.
      this-object:Bt_ok:Click:Subscribe(this-object:Bt_ok_Click).
      this-object:fSum:Location = new System.Drawing.Point(130, 185).
      this-object:fSum:Name = "fSum".
      this-object:fSum:Size = new System.Drawing.Size(556, 20).
      this-object:fSum:TabIndex = 3.
      this-object:label1:Location = new System.Drawing.Point(43, 182).
      this-object:label1:Name = "label1".
      this-object:label1:Size = new System.Drawing.Size(51, 23).
      this-object:label1:TabIndex = 4.
      this-object:label1:Text = "Сумма:".
      this-object:label1:UseCompatibleTextRendering = true.
      this-object:label1:Click:Subscribe(this-object:label1_Click).
      this-object:fOsn:Location = new System.Drawing.Point(130, 211).
      this-object:fOsn:Name = "fOsn".
      this-object:fOsn:Size = new System.Drawing.Size(556, 20).
      this-object:fOsn:TabIndex = 5.
      this-object:fOsn:TextChanged:Subscribe(this-object:fOsn_TextChanged).
      this-object:label2:Location = new System.Drawing.Point(43, 214).
      this-object:label2:Name = "label2".
      this-object:label2:Size = new System.Drawing.Size(87, 23).
      this-object:label2:TabIndex = 7.
      this-object:label2:Text = "Номер сумки:".
      this-object:label2:UseCompatibleTextRendering = true.
      this-object:label2:Click:Subscribe(this-object:label2_Click).
      this-object:OstCash:Location = new System.Drawing.Point(34, 12).
      this-object:OstCash:Name = "windowContainer2".
      this-object:OstCash:Size = new System.Drawing.Size(652, 167).
      this-object:OstCash:TabIndex = 8.
      this-object:ClientSize = new System.Drawing.Size(756, 578).
      this-object:Controls:Add(this-object:OstCash).
      this-object:Controls:Add(this-object:label2).
      this-object:Controls:Add(this-object:fOsn).
      this-object:Controls:Add(this-object:label1).
      this-object:Controls:Add(this-object:fSum).
      this-object:Controls:Add(this-object:Bt_ok).
      this-object:Controls:Add(this-object:button1).
      this-object:Controls:Add(this-object:windowContainer1).
      this-object:Cursor = System.Windows.Forms.Cursors:Default.
      this-object:Name = "incas".
      this-object:Text = "Инкасcация".
      this-object:ResumeLayout(false).
      this-object:PerformLayout().
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end method.
        @VisualDesigner.
        method private void label1_Click( input sender as System.Object, input e as System.EventArgs ):
                return.
        end method.
        @VisualDesigner.
        method private void label2_Click( input sender as System.Object, input e as System.EventArgs ):
                return.
        end method.
   method public void settt (input table tt-cashBookOst bind):
      mtrgOst:settt(input table tt-cashBookOst).
      OstCash:setbin().
   end.
   method public void gettt (output table tt-cashBookOst bind):
      mtrgOst:gettt(output table tt-cashBookOst).
   end.
   destructor public incas ( ):
      delete object mtrgOst no-error.
   end destructor.
end class.
