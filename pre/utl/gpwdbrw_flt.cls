using Progress.Lang.*.
using Progress.Windows.Form.
block-level on error undo, throw.
class utl.gpwdbrw_flt inherits Form:
   define private variable btnCancel as System.Windows.Forms.Button no-undo.
   define private variable btnApply as System.Windows.Forms.Button no-undo.
   define private variable btnCli as System.Windows.Forms.Button no-undo.
   define private variable btnGetUser as System.Windows.Forms.Button no-undo.
   define private variable btnObject as System.Windows.Forms.Button no-undo.
   define private variable btnReset as System.Windows.Forms.Button no-undo.
   define private variable components as System.ComponentModel.IContainer no-undo.
   define private variable gbModofier as System.Windows.Forms.GroupBox no-undo.
   define private variable rbOr as System.Windows.Forms.RadioButton no-undo.
   define private variable rbAnd as System.Windows.Forms.RadioButton no-undo.
   define private variable ucCashNum as utl.flt_condition_uc no-undo.
   define private variable ucDateGen as utl.flt_condition_uc no-undo.
   define private variable ucDateProl as utl.flt_condition_uc no-undo.
   define private variable ucFio as utl.flt_condition_uc no-undo.
   define private variable ucHostName as utl.flt_condition_uc no-undo.
   define private variable ucObject as utl.flt_condition_uc no-undo.
   define private variable ucUser as utl.flt_condition_uc no-undo.
   define private variable Filter as class utl.gpwdbrw-filter no-undo.
   constructor public gpwdbrw_flt (  ):
      super().
      InitializeComponent().
      this-object:ComponentsCollection:ADD(this-object:components).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end constructor.
        @VisualDesigner.
        method private void btnApply_Click( input sender as System.Object, input e as System.EventArgs ):
                this-object:FormToObject().
                this-object:DialogResult = System.Windows.Forms.DialogResult:ok.
                this-object:Close().
                return.
        end method.
        @VisualDesigner.
        method private void btnCancel_Click( input sender as System.Object, input e as System.EventArgs ):
                this-object:DialogResult = System.Windows.Forms.DialogResult:cancel.
                this-object:Close().
                return.
        end method.
        @VisualDesigner.
        method private void btnCli_Click( input sender as System.Object, input e as System.EventArgs ):
                this-object:ucFio:SetEnabledTo(true).
      ucFio:SetValue(this-object:GetCli()).
                return.
        end method.
        @VisualDesigner.
        method private void btnGetUser_Click( input sender as System.Object, input e as System.EventArgs ):
                this-object:ucUser:SetEnabledTo(true).
                this-object:ucUser:SetValue(this-object:GetUser()).
                return.
        end method.
        @VisualDesigner.
        method private void btnObject_Click( input sender as System.Object, input e as System.EventArgs ):
           this-object:ucObject:SetEnabledTo(true).
                this-object:ucObject:SetValue(this-object:GetShop()).
                return.
        end method.
        @VisualDesigner.
        method private void btnReset_Click( input sender as System.Object, input e as System.EventArgs ):
                this-object:ucCashNum:ResetAndDisable().
                this-object:ucDateGen:ResetAndDisable().
                this-object:ucDateProl:ResetAndDisable().
                this-object:ucFio:ResetAndDisable().
                this-object:ucHostName:ResetAndDisable().
                this-object:ucObject:ResetAndDisable().
                this-object:ucUser:ResetAndDisable().
                return.
        end method.
        @VisualDesigner.
        method private void gpwdbrw_flt_VisibleChanged( input sender as System.Object, input e as System.EventArgs ):
                return.
        end method.
   method private void InitializeComponent(  ):
      this-object:btnReset = new System.Windows.Forms.Button().
      this-object:btnCancel = new System.Windows.Forms.Button().
      this-object:btnApply = new System.Windows.Forms.Button().
      this-object:btnCli = new System.Windows.Forms.Button().
      this-object:btnObject = new System.Windows.Forms.Button().
      this-object:ucDateProl = new utl.flt_condition_uc().
      this-object:gbModofier = new System.Windows.Forms.GroupBox().
      this-object:rbAnd = new System.Windows.Forms.RadioButton().
      this-object:rbOr = new System.Windows.Forms.RadioButton().
      this-object:ucObject = new utl.flt_condition_uc().
      this-object:ucFio = new utl.flt_condition_uc().
      this-object:ucHostName = new utl.flt_condition_uc().
      this-object:ucUser = new utl.flt_condition_uc().
      this-object:ucCashNum = new utl.flt_condition_uc().
      this-object:ucDateGen = new utl.flt_condition_uc().
      this-object:btnGetUser = new System.Windows.Forms.Button().
      this-object:gbModofier:SuspendLayout().
      this-object:SuspendLayout().
      this-object:btnReset:Location = new System.Drawing.Point(240, 12).
      this-object:btnReset:Name = "btnReset".
      this-object:btnReset:Size = new System.Drawing.Size(108, 23).
      this-object:btnReset:TabIndex = 2.
      this-object:btnReset:Text = "Сбросить".
      this-object:btnReset:UseCompatibleTextRendering = true.
      this-object:btnReset:UseVisualStyleBackColor = true.
      this-object:btnReset:Click:Subscribe(this-object:btnReset_Click).
      this-object:btnCancel:DialogResult = System.Windows.Forms.DialogResult:Cancel.
      this-object:btnCancel:Location = new System.Drawing.Point(126, 12).
      this-object:btnCancel:Name = "btnCancel".
      this-object:btnCancel:Size = new System.Drawing.Size(108, 23).
      this-object:btnCancel:TabIndex = 1.
      this-object:btnCancel:Text = "Отказаться".
      this-object:btnCancel:UseCompatibleTextRendering = true.
      this-object:btnCancel:UseVisualStyleBackColor = true.
      this-object:btnCancel:Click:Subscribe(this-object:btnCancel_Click).
      this-object:btnApply:Location = new System.Drawing.Point(12, 12).
      this-object:btnApply:Name = "btnApply".
      this-object:btnApply:Size = new System.Drawing.Size(108, 23).
      this-object:btnApply:TabIndex = 0.
      this-object:btnApply:Text = "Применить".
      this-object:btnApply:UseCompatibleTextRendering = true.
      this-object:btnApply:UseVisualStyleBackColor = true.
      this-object:btnApply:Click:Subscribe(this-object:btnApply_Click).
      this-object:btnCli:Anchor = System.Windows.Forms.AnchorStyles:Right.
      this-object:btnCli:Location = new System.Drawing.Point(728, 110).
      this-object:btnCli:Name = "btnCli".
      this-object:btnCli:Size = new System.Drawing.Size(25, 23).
      this-object:btnCli:TabIndex = 9.
      this-object:btnCli:Text = "...".
      this-object:btnCli:UseCompatibleTextRendering = true.
      this-object:btnCli:UseVisualStyleBackColor = true.
      this-object:btnCli:Click:Subscribe(this-object:btnCli_Click).
      this-object:btnObject:Anchor = System.Windows.Forms.AnchorStyles:Right.
      this-object:btnObject:Location = new System.Drawing.Point(728, 242).
      this-object:btnObject:Name = "btnObject".
      this-object:btnObject:Size = new System.Drawing.Size(25, 23).
      this-object:btnObject:TabIndex = 8.
      this-object:btnObject:Text = "...".
      this-object:btnObject:UseCompatibleTextRendering = true.
      this-object:btnObject:UseVisualStyleBackColor = true.
      this-object:btnObject:Click:Subscribe(this-object:btnObject_Click).
      this-object:ucDateProl:Anchor = System.Windows.Forms.AnchorStyles:None.
      this-object:ucDateProl:Location = new System.Drawing.Point(14, 153).
      this-object:ucDateProl:Name = "ucDateProl".
      this-object:ucDateProl:Size = new System.Drawing.Size(750, 33).
      this-object:ucDateProl:TabIndex = 7.
      this-object:gbModofier:Anchor = System.Windows.Forms.AnchorStyles:None.
      this-object:gbModofier:Controls:Add(this-object:rbAnd).
      this-object:gbModofier:Controls:Add(this-object:rbOr).
      this-object:gbModofier:Location = new System.Drawing.Point(14, 327).
      this-object:gbModofier:Name = "gbModofier".
      this-object:gbModofier:Size = new System.Drawing.Size(336, 72).
      this-object:gbModofier:TabIndex = 6.
      this-object:gbModofier:TabStop = false.
      this-object:gbModofier:Text = "Способ объединения".
      this-object:gbModofier:UseCompatibleTextRendering = true.
      this-object:rbAnd:Checked = true.
      this-object:rbAnd:Location = new System.Drawing.Point(13, 32).
      this-object:rbAnd:Name = "rbAnd".
      this-object:rbAnd:Size = new System.Drawing.Size(62, 24).
      this-object:rbAnd:TabIndex = 0.
      this-object:rbAnd:TabStop = true.
      this-object:rbAnd:Text = "И".
      this-object:rbAnd:UseCompatibleTextRendering = true.
      this-object:rbAnd:UseVisualStyleBackColor = true.
      this-object:rbAnd:CheckedChanged:Subscribe(this-object:rbAnd_CheckedChanged).
      this-object:rbOr:Anchor = System.Windows.Forms.AnchorStyles:Left.
      this-object:rbOr:Location = new System.Drawing.Point(75, 31).
      this-object:rbOr:Name = "rbOr".
      this-object:rbOr:Size = new System.Drawing.Size(75, 24).
      this-object:rbOr:TabIndex = 1.
      this-object:rbOr:TabStop = true.
      this-object:rbOr:Text = "ИЛИ".
      this-object:rbOr:UseCompatibleTextRendering = true.
      this-object:rbOr:UseVisualStyleBackColor = true.
      this-object:ucObject:Anchor = System.Windows.Forms.AnchorStyles:None.
      this-object:ucObject:Location = new System.Drawing.Point(14, 242).
      this-object:ucObject:Name = "ucObject".
      this-object:ucObject:Size = new System.Drawing.Size(750, 33).
      this-object:ucObject:TabIndex = 5.
      this-object:ucFio:Anchor = System.Windows.Forms.AnchorStyles:None.
      this-object:ucFio:Location = new System.Drawing.Point(14, 110).
      this-object:ucFio:Name = "ucFio".
      this-object:ucFio:Size = new System.Drawing.Size(750, 33).
      this-object:ucFio:TabIndex = 4.
      this-object:ucHostName:Anchor = System.Windows.Forms.AnchorStyles:None.
      this-object:ucHostName:Location = new System.Drawing.Point(14, 36).
      this-object:ucHostName:Name = "ucHostName".
      this-object:ucHostName:Size = new System.Drawing.Size(750, 33).
      this-object:ucHostName:TabIndex = 1.
      this-object:ucUser:Anchor = System.Windows.Forms.AnchorStyles:None.
      this-object:ucUser:Location = new System.Drawing.Point(14, 72).
      this-object:ucUser:Name = "ucUser".
      this-object:ucUser:Size = new System.Drawing.Size(750, 33).
      this-object:ucUser:TabIndex = 0.
      this-object:ucCashNum:Anchor = System.Windows.Forms.AnchorStyles:None.
      this-object:ucCashNum:Location = new System.Drawing.Point(14, 290).
      this-object:ucCashNum:Name = "ucCashNum".
      this-object:ucCashNum:Size = new System.Drawing.Size(750, 33).
      this-object:ucCashNum:TabIndex = 6.
      this-object:ucDateGen:Anchor = System.Windows.Forms.AnchorStyles:None.
      this-object:ucDateGen:Location = new System.Drawing.Point(14, 196).
      this-object:ucDateGen:Name = "ucDateGen".
      this-object:ucDateGen:Size = new System.Drawing.Size(750, 33).
      this-object:ucDateGen:TabIndex = 2.
      this-object:btnGetUser:Anchor = System.Windows.Forms.AnchorStyles:Right.
      this-object:btnGetUser:Location = new System.Drawing.Point(728, 72).
      this-object:btnGetUser:Name = "btnGetUser".
      this-object:btnGetUser:Size = new System.Drawing.Size(25, 23).
      this-object:btnGetUser:TabIndex = 10.
      this-object:btnGetUser:Text = "...".
      this-object:btnGetUser:UseCompatibleTextRendering = true.
      this-object:btnGetUser:UseVisualStyleBackColor = true.
      this-object:btnGetUser:Click:Subscribe(this-object:btnGetUser_Click).
      this-object:CancelButton = this-object:btnCancel.
      this-object:ClientSize = new System.Drawing.Size(779, 406).
      this-object:Controls:Add(this-object:btnGetUser).
      this-object:Controls:Add(this-object:gbModofier).
      this-object:Controls:Add(this-object:btnReset).
      this-object:Controls:Add(this-object:btnApply).
      this-object:Controls:Add(this-object:btnCli).
      this-object:Controls:Add(this-object:btnObject).
      this-object:Controls:Add(this-object:ucDateProl).
      this-object:Controls:Add(this-object:ucObject).
      this-object:Controls:Add(this-object:ucFio).
      this-object:Controls:Add(this-object:ucDateGen).
      this-object:Controls:Add(this-object:ucHostName).
      this-object:Controls:Add(this-object:ucUser).
      this-object:Controls:Add(this-object:ucCashNum).
      this-object:Controls:Add(this-object:btnCancel).
      this-object:FormBorderStyle = System.Windows.Forms.FormBorderStyle:FixedDialog.
      this-object:Name = "gpwdbrw_flt".
      this-object:StartPosition = System.Windows.Forms.FormStartPosition:CenterScreen.
      this-object:Text = "Фильтры".
      this-object:VisibleChanged:Subscribe(this-object:gpwdbrw_flt_VisibleChanged).
      this-object:gbModofier:ResumeLayout(false).
      this-object:ResumeLayout(false).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end method.
   method public static utl.gpwdbrw_flt GetObject(iFilter as class utl.gpwdbrw-filter):
      def var vForm as class utl.gpwdbrw_flt.
      assign
         vForm = new utl.gpwdbrw_flt()
         vForm:Filter = iFilter
      .
      vForm:SetCondition("User",    vForm:Filter:User).
      vForm:SetCondition("HostName",vForm:Filter:HostName).
      vForm:SetCondition("DateGen", vForm:Filter:DateGen).
      vForm:SetCondition("Fio",     vForm:Filter:Fio).
      vForm:SetCondition("Object",  vForm:Filter:ObjectNum).
      vForm:SetCondition("CashNum", vForm:Filter:CashNum).
      vForm:SetCondition("DateProl", vForm:Filter:DateProl).
      vForm:ObjectToForm().
      return vForm.
   end method.
        @VisualDesigner.
        method private void rbAnd_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
                return.
        end method.
   method public void SetCondition(iControlName as char, iCond as utl.flt-condition):
      case iControlName:
         when "User"     then ucUser:Condition = iCond.
         when "HostName" then ucHostName:Condition = iCond.
         when "DateGen"  then ucDateGen:Condition = iCond.
         when "Fio"      then ucFio:Condition = iCond.
         when "Object"   then ucObject:Condition = iCond.
         when "CashNum" then ucCashNum:Condition = iCond.
         when "DateProl" then ucDateProl:Condition = iCond.
      end case.
   end method.
   method public void FormToObject():
      this-object:ucUser:FormToObject().
      this-object:ucFio:FormToObject().
      this-object:ucDateGen:FormToObject().
      this-object:ucObject:FormToObject().
      this-object:ucHostName:FormToObject().
      this-object:ucCashNum:FormToObject().
      this-object:ucDateProl:FormToObject().
      if this-object:rbAnd:Checked then
         this-object:Filter:Modifier = "and".
      if this-object:rbOr:Checked then
         this-object:Filter:Modifier = "or".
   end method.
   method public void ObjectToForm():
      this-object:ucUser:ObjectToForm().
      this-object:ucFio:ObjectToForm().
      this-object:ucDateGen:ObjectToForm().
      this-object:ucObject:ObjectToForm().
      this-object:ucHostName:ObjectToForm().
      this-object:ucCashNum:ObjectToForm().
      this-object:ucDateProl:ObjectToForm().
      if this-object:Filter:Modifier = "and" then
         this-object:rbAnd:Checked = yes.
      if this-object:Filter:Modifier = "or" then
         this-object:rbOr:Checked = yes.
   end method.
   method private char GetCli():
      def buffer bclients for clients.
      def var v-rid-list as char  no-undo.
      def var vCli       as char  no-undo.
      def var vI         as int64 no-undo.
      def var vParam     as char  no-undo.
      if this-object:ucFio:SelectedOp() = "список" then
         vParam = "b-sel,b-mark".
      else
         vParam = "b-sel".
      run ref/cli-all.w (utl.gpwdbrw:parParentProc
                  ,input vParam
                  ,input 'чел':U
                  ,input 'все':U
                  ,input 'текущие':U
                  ,input ?
                  ,input ",,,,,,NO,,"
                  ,input "":U
                  ,output v-rid-list).
      if v-rid-list <> "" or v-rid-list <> ? then
      do:
         do vI = 1 to num-entries(v-rid-list):
            find first bclients where
                 recid(bclients) = int64(entry(vI,v-rid-list))
            no-lock no-error.
            if avail bclients then
            do:
               vCli = substitute("&1,&2",
                                 vCli,
                                 string(bclients.obj-name)).
            end.
         end.
         vCli = trim(vCli,",").
      end.
      return vCli.
   end method.
   method private char GetShop():
      def buffer bclients for clients.
      def var v-rid-list as char  no-undo.
      def var vShopNum   as char  no-undo.
      def var vI         as int64 no-undo.
      def var vParam     as char  no-undo.
      if ucObject:SelectedOp() = "список" then
         vParam = "b-sel,b-mark".
      else
         vParam = "b-sel".
      run ref/cli-all.w (utl.gpwdbrw:parParentProc
                  ,input vParam
                  ,input 'маг':U
                  ,input 'все':U
                  ,input 'текущие':U
                  ,input ?
                  ,input ",,,,,,NO,,"
                  ,input "":U
                  ,output v-rid-list) no-error.
      if (v-rid-list <> "" or v-rid-list <> ?) then
      do:
         do vI = 1 to num-entries(v-rid-list):
            find first bclients where
                 recid(bclients) = int64(entry(vI,v-rid-list))
            no-lock no-error.
            if avail bclients then
            do:
               vShopNum = substitute("&1,&2",
                                     vShopNum,
                                     string(bclients.obj-code)).
            end.
         end.
         vShopNum = trim(vShopNum,",").
      end.
      return vShopNum.
   end method.
   method private char GetUser():
      def var v-cntxt-userid    as char no-undo.
      def var v-selected-userid as char no-undo.
      def var v-old-userid      as char no-undo.
      def var v-mode            as integer no-undo.
      def var v-accepted        as log no-undo.
      if ucUser:SelectedOp() = "список" then
         v-mode = 1.
      else
         v-mode = 2.
      run str/usersel2.p ( input utl.gpwdbrw:parParentProc
                         , input ""
                         , v-mode
                         , output v-selected-userid
                         , output v-old-userid
                         , output v-accepted
                        ).
      return v-selected-userid.
   end method.
   destructor public gpwdbrw_flt ( ):
   end destructor.
end class.
