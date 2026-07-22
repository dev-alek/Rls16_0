using Progress.Lang.*.
using Progress.Windows.UserControl.
block-level on error undo, throw.
class ibs.th.ref.sobj.sSchet inherits UserControl:
   define private variable BtnSchetVal as System.Windows.Forms.Button no-undo.
   define private variable BtnSchetOne as System.Windows.Forms.Button no-undo.
   define private variable BtnSchet as System.Windows.Forms.Button no-undo.
   define private variable components as System.ComponentModel.IContainer no-undo.
   define private variable LkpSchet as System.Windows.Forms.TextBox no-undo.
   define private variable label1 as System.Windows.Forms.Label no-undo.
   define private variable RadioSchetOne as System.Windows.Forms.RadioButton no-undo.
   define private variable RadioSchetMy as System.Windows.Forms.RadioButton no-undo.
   define private variable RadioSchetFirm as System.Windows.Forms.RadioButton no-undo.
   define private variable RadioSchetCurrency as System.Windows.Forms.RadioButton no-undo.
   define private variable RadioSchetChang as System.Windows.Forms.RadioButton no-undo.
   define private variable RadioSchetAll as System.Windows.Forms.RadioButton no-undo.
   define private variable RadioSchetAbbr as System.Windows.Forms.RadioButton no-undo.
   define property mTrgLoc as class ibs.th.ref.sobj.sSchet_trg no-undo
   get.
   set.
   define property mTrgGlb as class ibs.th.ref.sobj.dReportTrg no-undo
   get.
   set.
   define public property ParamObj as class ibs.th.ref.sobj.sParamObj no-undo
   set(iarg as ibs.th.ref.sobj.sParamObj):
      mTrgLoc:ParamObj = iarg.
   end.
   define public property ParamForm as class ibs.th.ref.sobj.sParamForm no-undo
   get.
   set(iarg as ibs.th.ref.sobj.sParamForm):
      mTrgLoc:ParamForm = iarg.
      ParamForm = iarg.
   end.
   define public property stype as class ibs.th.ref.sobj.stype no-undo
   get.
   set(iarg as ibs.th.ref.sobj.stype):
      stype = iarg.
      mTrgLoc:stype = iarg.
      RadioSchetFirm      :text = iarg:RadioSchetLbl(1).
      RadioSchetMy        :text = iarg:RadioSchetLbl(2).
      RadioSchetChang     :text = iarg:RadioSchetLbl(3).
      RadioSchetOne       :text = iarg:RadioSchetLbl(4).
      RadioSchetAbbr      :text = iarg:RadioSchetLbl(5).
      RadioSchetAll       :text = iarg:RadioSchetLbl(6).
      RadioSchetCurrency  :text = iarg:RadioSchetLbl(7).
   end.
   define public property RadioSchet as character  no-undo
   get:
      return if      RadioSchetOne           :checked
             then    RadioSchetOne           :text
             else if RadioSchetMy            :checked
             then    RadioSchetMy            :text
             else if RadioSchetFirm          :checked
             then    RadioSchetFirm          :text
             else if RadioSchetCurrency      :checked
             then    RadioSchetCurrency      :text
             else if RadioSchetChang         :checked
             then    RadioSchetChang         :text
             else if RadioSchetAbbr          :checked
             then    RadioSchetAbbr          :text
             else if RadioSchetAll           :checked
             then    RadioSchetAll           :text
             else "".
   end.
   set (iarg as character  ):
      if      iarg eq RadioSchetOne          :text
      then            RadioSchetOne          :checked = yes .
      else if iarg eq RadioSchetMy           :text
      then            RadioSchetMy           :checked = yes .
      else if iarg eq RadioSchetFirm         :text
      then            RadioSchetFirm         :checked = yes.
      else if iarg eq RadioSchetCurrency     :text
      then            RadioSchetCurrency     :checked = yes.
      else if iarg eq RadioSchetChang        :text
      then            RadioSchetChang        :checked = yes .
      else if iarg eq RadioSchetAbbr         :text
      then            RadioSchetAbbr         :checked = yes.
      else if iarg eq RadioSchetAll          :text
      then            RadioSchetAll          :checked = yes.
      else
         message "Нет поля " iarg
         view-as alert-box.
   end.
   define public property RadioSchet_disable as character  no-undo
   set (iarg as character  ):
      define variable varg as character  no-undo.
      define variable vi as integer no-undo.
      if iarg = "*" then "".
      do vi = 1 to 7:
         if lookup(string(vi),iarg) eq 0
         then do:
         varg = stype:SelectObjectLbl(vi)no-error.
         if      varg eq RadioSchetOne:Text
         then            assign
                         BtnSchetOne :visible  = no
                         RadioSchetOne:Enabled = no
                        .
         else if varg eq RadioSchetMy:Text
         then            RadioSchetMy:Enabled = no .
         else if varg eq RadioSchetFirm:Text
         then            RadioSchetFirm:Enabled = no .
         else if varg eq RadioSchetCurrency:Text
         then            assign
                         BtnSchetVal:visible = no
                         RadioSchetCurrency:Enabled = no .
         else if varg eq RadioSchetChang:Text
         then            assign
                         BtnSchet:visible = no
                         RadioSchetChang:Enabled = no .
         else if varg eq RadioSchetAbbr:Text
         then            RadioSchetAbbr:Enabled = no .
         else if varg eq RadioSchetAll:Text
         then            RadioSchetAll:Enabled = no .
      end.
      end.
   end.
   constructor public sSchet (  ):
      super().
      mTrgLoc = new ibs.th.ref.sobj.sSchet_trg ().
      InitializeComponent().
      this-object:RadioSchetAbbr:Text = "Все рублевые".
      this-object:ComponentsCollection:ADD(this-object:components).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end constructor.
        @VisualDesigner.
        method private void BtnSchet_Click( input sender as System.Object, input e as System.EventArgs ):
                CHOOSE_BUTTON-schet().
                return.
        end method.
        @VisualDesigner.
        method private void BtnSchetOne_Click( input sender as System.Object, input e as System.EventArgs ):
                CHOOSE_BUTTON-schet-one().
                return.
        end method.
        @VisualDesigner.
        method private void BtnSchetVal_Click( input sender as System.Object, input e as System.EventArgs ):
                CHOOSE_BUTTON-schet-val().
                return.
        end method.
   method private void InitializeComponent(  ):
      this-object:label1 = new System.Windows.Forms.Label().
      this-object:RadioSchetFirm = new System.Windows.Forms.RadioButton().
      this-object:RadioSchetMy = new System.Windows.Forms.RadioButton().
      this-object:RadioSchetOne = new System.Windows.Forms.RadioButton().
      this-object:RadioSchetChang = new System.Windows.Forms.RadioButton().
      this-object:RadioSchetAll = new System.Windows.Forms.RadioButton().
      this-object:RadioSchetAbbr = new System.Windows.Forms.RadioButton().
      this-object:RadioSchetCurrency = new System.Windows.Forms.RadioButton().
      this-object:BtnSchet = new System.Windows.Forms.Button().
      this-object:BtnSchetOne = new System.Windows.Forms.Button().
      this-object:BtnSchetVal = new System.Windows.Forms.Button().
      this-object:LkpSchet = new System.Windows.Forms.TextBox().
      this-object:SuspendLayout().
      this-object:label1:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(12), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:label1:Location = new System.Drawing.Point(23, 9).
      this-object:label1:Name = "label1".
      this-object:label1:Size = new System.Drawing.Size(135, 23).
      this-object:label1:TabIndex = 0.
      this-object:label1:Text = "Выбор счета".
      this-object:label1:UseCompatibleTextRendering = true.
      this-object:RadioSchetFirm:Location = new System.Drawing.Point(3, 29).
      this-object:RadioSchetFirm:Name = "RadioSchetFirm".
      this-object:RadioSchetFirm:Size = new System.Drawing.Size(104, 20).
      this-object:RadioSchetFirm:TabIndex = 1.
      this-object:RadioSchetFirm:TabStop = true.
      this-object:RadioSchetFirm:Text = "Все по фирме".
      this-object:RadioSchetFirm:UseCompatibleTextRendering = true.
      this-object:RadioSchetFirm:UseVisualStyleBackColor = true.
      this-object:RadioSchetFirm:CheckedChanged:Subscribe(this-object:RadioSchetFirm_CheckedChanged).
      this-object:RadioSchetMy:Location = new System.Drawing.Point(3, 55).
      this-object:RadioSchetMy:Name = "RadioSchetMy".
      this-object:RadioSchetMy:Size = new System.Drawing.Size(104, 20).
      this-object:RadioSchetMy:TabIndex = 2.
      this-object:RadioSchetMy:TabStop = true.
      this-object:RadioSchetMy:Text = "Своей фирмы".
      this-object:RadioSchetMy:UseCompatibleTextRendering = true.
      this-object:RadioSchetMy:UseVisualStyleBackColor = true.
      this-object:RadioSchetMy:CheckedChanged:Subscribe(this-object:RadioSchetMy_CheckedChanged).
      this-object:RadioSchetOne:Location = new System.Drawing.Point(3, 107).
      this-object:RadioSchetOne:Name = "RadioSchetOne".
      this-object:RadioSchetOne:Size = new System.Drawing.Size(104, 20).
      this-object:RadioSchetOne:TabIndex = 4.
      this-object:RadioSchetOne:TabStop = true.
      this-object:RadioSchetOne:Text = "Один".
      this-object:RadioSchetOne:UseCompatibleTextRendering = true.
      this-object:RadioSchetOne:UseVisualStyleBackColor = true.
      this-object:RadioSchetOne:CheckedChanged:Subscribe(this-object:RadioSchetOne_CheckedChanged).
      this-object:RadioSchetChang:Location = new System.Drawing.Point(3, 81).
      this-object:RadioSchetChang:Name = "RadioSchetChang".
      this-object:RadioSchetChang:Size = new System.Drawing.Size(104, 20).
      this-object:RadioSchetChang:TabIndex = 3.
      this-object:RadioSchetChang:TabStop = true.
      this-object:RadioSchetChang:Text = "Выборочно".
      this-object:RadioSchetChang:UseCompatibleTextRendering = true.
      this-object:RadioSchetChang:UseVisualStyleBackColor = true.
      this-object:RadioSchetChang:CheckedChanged:Subscribe(this-object:RadioSchetChang_CheckedChanged).
      this-object:RadioSchetAll:Location = new System.Drawing.Point(3, 159).
      this-object:RadioSchetAll:Name = "RadioSchetAll".
      this-object:RadioSchetAll:Size = new System.Drawing.Size(104, 20).
      this-object:RadioSchetAll:TabIndex = 6.
      this-object:RadioSchetAll:TabStop = true.
      this-object:RadioSchetAll:Text = "Все валютные".
      this-object:RadioSchetAll:UseCompatibleTextRendering = true.
      this-object:RadioSchetAll:UseVisualStyleBackColor = true.
      this-object:RadioSchetAll:CheckedChanged:Subscribe(this-object:RadioSchetAll_CheckedChanged).
      this-object:RadioSchetAbbr:Location = new System.Drawing.Point(3, 133).
      this-object:RadioSchetAbbr:Name = "RadioSchetAbbr".
      this-object:RadioSchetAbbr:Size = new System.Drawing.Size(119, 20).
      this-object:RadioSchetAbbr:TabIndex = 5.
      this-object:RadioSchetAbbr:TabStop = true.
      this-object:RadioSchetAbbr:Text = "Все abbr_rublevye".
      this-object:RadioSchetAbbr:UseCompatibleTextRendering = true.
      this-object:RadioSchetAbbr:UseVisualStyleBackColor = true.
      this-object:RadioSchetAbbr:CheckedChanged:Subscribe(this-object:RadioSchetAbbr_CheckedChanged).
      this-object:RadioSchetCurrency:Location = new System.Drawing.Point(3, 185).
      this-object:RadioSchetCurrency:Name = "RadioSchetCurrency".
      this-object:RadioSchetCurrency:Size = new System.Drawing.Size(104, 20).
      this-object:RadioSchetCurrency:TabIndex = 7.
      this-object:RadioSchetCurrency:TabStop = true.
      this-object:RadioSchetCurrency:Text = "По валюте".
      this-object:RadioSchetCurrency:UseCompatibleTextRendering = true.
      this-object:RadioSchetCurrency:UseVisualStyleBackColor = true.
      this-object:RadioSchetCurrency:CheckedChanged:Subscribe(this-object:RadioSchetCurrency_CheckedChanged).
      this-object:BtnSchet:Location = new System.Drawing.Point(137, 81).
      this-object:BtnSchet:Name = "BtnSchet".
      this-object:BtnSchet:Size = new System.Drawing.Size(20, 20).
      this-object:BtnSchet:TabIndex = 8.
      this-object:BtnSchet:UseCompatibleTextRendering = true.
      this-object:BtnSchet:UseVisualStyleBackColor = true.
      this-object:BtnSchet:Click:Subscribe(this-object:BtnSchet_Click).
      this-object:BtnSchetOne:Location = new System.Drawing.Point(137, 107).
      this-object:BtnSchetOne:Name = "BtnSchetOne".
      this-object:BtnSchetOne:Size = new System.Drawing.Size(20, 20).
      this-object:BtnSchetOne:TabIndex = 9.
      this-object:BtnSchetOne:UseCompatibleTextRendering = true.
      this-object:BtnSchetOne:UseVisualStyleBackColor = true.
      this-object:BtnSchetOne:Click:Subscribe(this-object:BtnSchetOne_Click).
      this-object:BtnSchetVal:Location = new System.Drawing.Point(137, 185).
      this-object:BtnSchetVal:Name = "BtnSchetVal".
      this-object:BtnSchetVal:Size = new System.Drawing.Size(20, 20).
      this-object:BtnSchetVal:TabIndex = 10.
      this-object:BtnSchetVal:UseCompatibleTextRendering = true.
      this-object:BtnSchetVal:UseVisualStyleBackColor = true.
      this-object:BtnSchetVal:Click:Subscribe(this-object:BtnSchetVal_Click).
      define variable nestedvar0 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar0 = cast(Progress.Util.EnumHelper:Or(cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Bottom), System.Windows.Forms.AnchorStyles), System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:LkpSchet:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:LkpSchet:Enabled = false.
      this-object:LkpSchet:Location = new System.Drawing.Point(3, 212).
      this-object:LkpSchet:Multiline = true.
      this-object:LkpSchet:Name = "LkpSchet".
      this-object:LkpSchet:Size = new System.Drawing.Size(158, 40).
      this-object:LkpSchet:TabIndex = 11.
      this-object:AutoScaleDimensions = new System.Drawing.SizeF(Progress.Util.CastUtil:ToSingle(6), Progress.Util.CastUtil:ToSingle(13)).
      this-object:Controls:Add(this-object:LkpSchet).
      this-object:Controls:Add(this-object:BtnSchetVal).
      this-object:Controls:Add(this-object:BtnSchetOne).
      this-object:Controls:Add(this-object:BtnSchet).
      this-object:Controls:Add(this-object:RadioSchetCurrency).
      this-object:Controls:Add(this-object:RadioSchetAll).
      this-object:Controls:Add(this-object:RadioSchetAbbr).
      this-object:Controls:Add(this-object:RadioSchetOne).
      this-object:Controls:Add(this-object:RadioSchetChang).
      this-object:Controls:Add(this-object:RadioSchetMy).
      this-object:Controls:Add(this-object:RadioSchetFirm).
      this-object:Controls:Add(this-object:label1).
      this-object:Name = "sSchet".
      this-object:Size = new System.Drawing.Size(165, 252).
      this-object:ResumeLayout(false).
      this-object:PerformLayout().
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end method.
   destructor public sSchet ( ):
   end destructor.
   method private void init-radio-schet ():
      do
      on error undo, return error return-value
      :
         define variable ll as integer no-undo .
         label1:text = ParamForm:temp-param-schet .
         if ParamForm:temp-param-schet-init <> "" then do:
            radioschet = stype:RadioSchetLbl(  4 ).
         end.
         if ParamForm:temp-param-schet-hide <> ""
         then do:
            if radioschet eq stype:RadioSchetLbl(4)
            then
            repeat ll = 1 to num-entries(ParamForm:temp-param-schet-hide) - 1 :
              if entry(ll,ParamForm:temp-param-schet-hide) =  string( 4 )
                 then message "Не верно заданы параметры для блока ВЫБОР СЧЕТА в вызывающей процедуре g- " view-as alert-box error .
            end.
            radioschet_disable=ParamForm:temp-param-schet-hide.
            if radioschet = stype:RadioSchetLbl(  4 )
            then do:
               block-rep:
               repeat ll = 1 to 7 :
                  if lookup( string(ll) , ParamForm:temp-param-schet-hide) eq 0
                  then do:
                     radioschet = stype:RadioSchetLbl(ll) .
                     leave block-rep.
                  end.
               end.
            end.
            if stype:RadioSchetint(radioschet) eq  4
            then do:
               mTrgLoc:initschet ().
            end.
            select-radio-schet-no-apply(yes).
         end.
      end.
   end.
        @VisualDesigner.
        method private void RadioSchetAbbr_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
                select-Radio-schet().
                return.
        end method.
        @VisualDesigner.
        method private void RadioSchetAll_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
                select-Radio-schet().
                return.
        end method.
        @VisualDesigner.
        method private void RadioSchetChang_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
                select-Radio-schet().
                return.
        end method.
        @VisualDesigner.
        method private void RadioSchetCurrency_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
                select-Radio-schet().
                return.
        end method.
        @VisualDesigner.
        method private void RadioSchetFirm_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
                select-Radio-schet().
                return.
        end method.
        @VisualDesigner.
        method private void RadioSchetMy_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
                select-Radio-schet().
                return.
        end method.
        @VisualDesigner.
        method private void RadioSchetOne_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
                select-Radio-schet().
                return.
        end method.
   method private void select-radio-schet-no-apply (init as logical ):
      do on error undo, return error return-value:
         case stype:RadioSchetint(radioschet) :
            when 3 then do:
               assign
                  BtnSchet:enabled    = yes
                  BtnSchetOne:enabled = no
                  BtnSchetVal:enabled = no
               .
               if not init
               then
                  CHOOSE_BUTTON-schet ().
            end.
            when 4 then do:
               assign
                  BtnSchet:enabled    = no
                  BtnSchetOne:enabled = yes
                  BtnSchetVal:enabled = no
               .
               if init
               then
                  mTrgLoc:initschet().
               else
                  CHOOSE_BUTTON-schet-one().
            end.
            when 7 then do:
               assign
                  BtnSchet:enabled    = no
                  BtnSchetOne:enabled = no
                  BtnSchetVal:enabled = yes
               .
               if not init
               then
                  CHOOSE_BUTTON-schet().
            end.
            otherwise do:
               assign
                  BtnSchet:enabled    = no
                  BtnSchetOne:enabled = no
                  BtnSchetVal:enabled = no
               .
            end.
         end case.
         setlkpschet().
         lkpschet:text  = lkpschet:text + mtrgloc:getschettext().
      end.
   end.
   method private void  CHOOSE_BUTTON-schet():
      mtrgloc:CHOOSE_BUTTON-schet().
      setlkpschet().
   end.
   method private void  setlkpschet():
      lkpschet:text = ParamForm:temp-param-schet + " по : " + RADIOschet + chr(10) .
      lkpschet:text  = lkpschet:text + mtrgloc:getschettext().
   end.
   method private void  CHOOSE_BUTTON-schet-one():
      mtrgloc:CHOOSE_BUTTON-schet-one().
      setlkpschet().
   end.
   method private void CHOOSE_BUTTON-schet-val():
      mtrgloc:CHOOSE_BUTTON-schet-val().
   end.
   method private void VALUE-CHANGED_Radio-schet ():
      select-radio-schet() .
   end.
   method private void select-Radio-schet ():
      do
      on error undo, return error return-value
      :
         select-radio-schet-no-apply(no).
         mtrgloc:select-Radio-schet(RadioSchet).
      end.
   end.
   method public void Assign-frame():
      if RadioSchet = "" then RadioSchet = stype:RadioSchetLbl(1).
      mTrgLoc:Assign-frame(lkpschet:Text).
   end method.
   method public void local-apply-layout(iparamObj as class ibs.th.ref.sobj.sParamObj):
      if iparamObj:params-only-mode  = 'ПРОСМОТР':U
      then
         RadioSchet_disable = "*".
   end method.
   method public void local-initialize(iparamObj as class ibs.th.ref.sobj.sParamObj):
      init-radio-schet() .
   end method.
end class.
