using Progress.Lang.*.
using Progress.Windows.UserControl.
block-level on error undo, throw.
class utl.flt_condition_uc inherits UserControl:
   define private variable cbOp as System.Windows.Forms.ComboBox no-undo.
   define private variable cbEnabled as System.Windows.Forms.CheckBox no-undo.
   define private variable components as System.ComponentModel.IContainer no-undo.
   define private variable dtPicker2 as System.Windows.Forms.DateTimePicker no-undo.
   define private variable dtPicker1 as System.Windows.Forms.DateTimePicker no-undo.
   define private variable splitContainer4 as System.Windows.Forms.SplitContainer no-undo.
   define private variable tbName as System.Windows.Forms.TextBox no-undo.
   define private variable splitContainer3 as System.Windows.Forms.SplitContainer no-undo.
   define private variable splitContainer2 as System.Windows.Forms.SplitContainer no-undo.
   define private variable splitContainer1 as System.Windows.Forms.SplitContainer no-undo.
   define private variable panel1 as System.Windows.Forms.Panel no-undo.
   define private variable mtbValue as System.Windows.Forms.MaskedTextBox no-undo.
   define private var condition_ as class utl.flt-condition no-undo.
   define public property Condition as class utl.flt-condition no-undo
   get:
      return this-object:condition_.
   end get.
   set(iCond as class utl.flt-condition):
      this-object:condition_ = iCond.
   end set.
   constructor public flt_condition_uc (  ):
      super().
      InitializeComponent().
      this-object:ComponentsCollection:ADD(this-object:components).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end constructor.
        @VisualDesigner.
        method private void cbEnabled_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
           def var vEnabled as log no-undo.
           vEnabled = cast(sender,System.Windows.Forms.CheckBox):checked.
           assign
             cbOp:enabled      = vEnabled
             mtbValue:enabled  = vEnabled and this-object:cbOp:Text <> ""
             dtPicker1:enabled = vEnabled and this-object:cbOp:Text <> ""
             dtPicker2:enabled = vEnabled and this-object:cbOp:Text <> ""
           .
        end method.
        @VisualDesigner.
        method private void cbOp_SelectedIndexChanged( input sender as System.Object, input e as System.EventArgs ):
                SetComponentsToEnabled().
                SetVisible().
        end method.
   method private void InitializeComponent(  ):
      this-object:panel1 = new System.Windows.Forms.Panel().
      this-object:splitContainer1 = new System.Windows.Forms.SplitContainer().
      this-object:splitContainer3 = new System.Windows.Forms.SplitContainer().
      this-object:cbEnabled = new System.Windows.Forms.CheckBox().
      this-object:tbName = new System.Windows.Forms.TextBox().
      this-object:splitContainer2 = new System.Windows.Forms.SplitContainer().
      this-object:cbOp = new System.Windows.Forms.ComboBox().
      this-object:mtbValue = new System.Windows.Forms.MaskedTextBox().
      this-object:splitContainer4 = new System.Windows.Forms.SplitContainer().
      this-object:dtPicker1 = new System.Windows.Forms.DateTimePicker().
      this-object:dtPicker2 = new System.Windows.Forms.DateTimePicker().
      this-object:panel1:SuspendLayout().
      cast(this-object:splitContainer1, System.ComponentModel.ISupportInitialize):BeginInit().
      this-object:splitContainer1:Panel1:SuspendLayout().
      this-object:splitContainer1:Panel2:SuspendLayout().
      this-object:splitContainer1:SuspendLayout().
      cast(this-object:splitContainer3, System.ComponentModel.ISupportInitialize):BeginInit().
      this-object:splitContainer3:Panel1:SuspendLayout().
      this-object:splitContainer3:Panel2:SuspendLayout().
      this-object:splitContainer3:SuspendLayout().
      cast(this-object:splitContainer2, System.ComponentModel.ISupportInitialize):BeginInit().
      this-object:splitContainer2:Panel1:SuspendLayout().
      this-object:splitContainer2:Panel2:SuspendLayout().
      this-object:splitContainer2:SuspendLayout().
      cast(this-object:splitContainer4, System.ComponentModel.ISupportInitialize):BeginInit().
      this-object:splitContainer4:Panel1:SuspendLayout().
      this-object:splitContainer4:Panel2:SuspendLayout().
      this-object:splitContainer4:SuspendLayout().
      this-object:SuspendLayout().
      this-object:panel1:Controls:Add(this-object:splitContainer1).
      this-object:panel1:Dock = System.Windows.Forms.DockStyle:Fill.
      this-object:panel1:Location = new System.Drawing.Point(0, 0).
      this-object:panel1:Name = "panel1".
      this-object:panel1:Size = new System.Drawing.Size(776, 33).
      this-object:panel1:TabIndex = 0.
      this-object:splitContainer1:Dock = System.Windows.Forms.DockStyle:Fill.
      this-object:splitContainer1:IsSplitterFixed = true.
      this-object:splitContainer1:Location = new System.Drawing.Point(0, 0).
      this-object:splitContainer1:Name = "splitContainer1".
      this-object:splitContainer1:Panel1:Controls:Add(this-object:splitContainer3).
      this-object:splitContainer1:Panel2:Controls:Add(this-object:splitContainer2).
      this-object:splitContainer1:Size = new System.Drawing.Size(776, 33).
      this-object:splitContainer1:SplitterDistance = 230.
      this-object:splitContainer1:TabIndex = 0.
      this-object:splitContainer3:Dock = System.Windows.Forms.DockStyle:Fill.
      this-object:splitContainer3:IsSplitterFixed = true.
      this-object:splitContainer3:Location = new System.Drawing.Point(0, 0).
      this-object:splitContainer3:Name = "splitContainer3".
      this-object:splitContainer3:Panel1:Controls:Add(this-object:cbEnabled).
      this-object:splitContainer3:Panel2:Controls:Add(this-object:tbName).
      this-object:splitContainer3:Size = new System.Drawing.Size(230, 33).
      this-object:splitContainer3:SplitterDistance = 25.
      this-object:splitContainer3:TabIndex = 0.
      this-object:cbEnabled:Dock = System.Windows.Forms.DockStyle:Top.
      this-object:cbEnabled:Location = new System.Drawing.Point(0, 0).
      this-object:cbEnabled:Name = "cbEnabled".
      this-object:cbEnabled:Size = new System.Drawing.Size(25, 24).
      this-object:cbEnabled:TabIndex = 0.
      this-object:cbEnabled:UseCompatibleTextRendering = true.
      this-object:cbEnabled:UseVisualStyleBackColor = true.
      this-object:cbEnabled:CheckedChanged:Subscribe(this-object:cbEnabled_CheckedChanged).
      this-object:tbName:Dock = System.Windows.Forms.DockStyle:Top.
      this-object:tbName:Enabled = false.
      this-object:tbName:Location = new System.Drawing.Point(0, 0).
      this-object:tbName:Name = "tbName".
      this-object:tbName:Size = new System.Drawing.Size(201, 20).
      this-object:tbName:TabIndex = 0.
      this-object:splitContainer2:Dock = System.Windows.Forms.DockStyle:Fill.
      this-object:splitContainer2:IsSplitterFixed = true.
      this-object:splitContainer2:Location = new System.Drawing.Point(0, 0).
      this-object:splitContainer2:Name = "splitContainer2".
      this-object:splitContainer2:Panel1:Controls:Add(this-object:cbOp).
      this-object:splitContainer2:Panel2:Controls:Add(this-object:mtbValue).
      this-object:splitContainer2:Panel2:Controls:Add(this-object:splitContainer4).
      this-object:splitContainer2:Size = new System.Drawing.Size(542, 33).
      this-object:splitContainer2:SplitterDistance = 130.
      this-object:splitContainer2:TabIndex = 0.
      this-object:cbOp:Dock = System.Windows.Forms.DockStyle:Top.
      this-object:cbOp:DropDownStyle = System.Windows.Forms.ComboBoxStyle:DropDownList.
      this-object:cbOp:FormattingEnabled = true.
      this-object:cbOp:Location = new System.Drawing.Point(0, 0).
      this-object:cbOp:Name = "cbOp".
      this-object:cbOp:Size = new System.Drawing.Size(130, 21).
      this-object:cbOp:TabIndex = 0.
      this-object:cbOp:SelectedIndexChanged:Subscribe(this-object:cbOp_SelectedIndexChanged).
      define variable nestedvar0 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar0 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:mtbValue:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:mtbValue:Location = new System.Drawing.Point(0, 0).
      this-object:mtbValue:Name = "mtbValue".
      this-object:mtbValue:Size = new System.Drawing.Size(365, 20).
      this-object:mtbValue:TabIndex = 0.
      define variable nestedvar1 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar1 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:splitContainer4:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar1, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:splitContainer4:IsSplitterFixed = true.
      this-object:splitContainer4:Location = new System.Drawing.Point(0, 0).
      this-object:splitContainer4:Name = "splitContainer4".
      this-object:splitContainer4:Panel1:Controls:Add(this-object:dtPicker1).
      this-object:splitContainer4:Panel2:Controls:Add(this-object:dtPicker2).
      this-object:splitContainer4:Size = new System.Drawing.Size(405, 33).
      this-object:splitContainer4:SplitterDistance = 197.
      this-object:splitContainer4:TabIndex = 1.
      this-object:dtPicker1:Dock = System.Windows.Forms.DockStyle:Top.
      this-object:dtPicker1:Format = System.Windows.Forms.DateTimePickerFormat:Custom.
      this-object:dtPicker1:Location = new System.Drawing.Point(0, 0).
      this-object:dtPicker1:Name = "dtPicker1".
      this-object:dtPicker1:Size = new System.Drawing.Size(197, 20).
      this-object:dtPicker1:TabIndex = 1.
      this-object:dtPicker2:Dock = System.Windows.Forms.DockStyle:Top.
      this-object:dtPicker2:Format = System.Windows.Forms.DateTimePickerFormat:Custom.
      this-object:dtPicker2:Location = new System.Drawing.Point(0, 0).
      this-object:dtPicker2:Name = "dtPicker2".
      this-object:dtPicker2:Size = new System.Drawing.Size(204, 20).
      this-object:dtPicker2:TabIndex = 0.
      this-object:AutoScaleDimensions = new System.Drawing.SizeF(Progress.Util.CastUtil:ToSingle(6), Progress.Util.CastUtil:ToSingle(13)).
      this-object:Controls:Add(this-object:panel1).
      this-object:Name = "flt_condition_uc".
      this-object:Size = new System.Drawing.Size(776, 33).
      this-object:panel1:ResumeLayout(false).
      this-object:splitContainer1:Panel1:ResumeLayout(false).
      this-object:splitContainer1:Panel2:ResumeLayout(false).
      cast(this-object:splitContainer1, System.ComponentModel.ISupportInitialize):EndInit().
      this-object:splitContainer1:ResumeLayout(false).
      this-object:splitContainer3:Panel1:ResumeLayout(false).
      this-object:splitContainer3:Panel2:ResumeLayout(false).
      this-object:splitContainer3:Panel2:PerformLayout().
      cast(this-object:splitContainer3, System.ComponentModel.ISupportInitialize):EndInit().
      this-object:splitContainer3:ResumeLayout(false).
      this-object:splitContainer2:Panel1:ResumeLayout(false).
      this-object:splitContainer2:Panel2:ResumeLayout(false).
      this-object:splitContainer2:Panel2:PerformLayout().
      cast(this-object:splitContainer2, System.ComponentModel.ISupportInitialize):EndInit().
      this-object:splitContainer2:ResumeLayout(false).
      this-object:splitContainer4:Panel1:ResumeLayout(false).
      this-object:splitContainer4:Panel2:ResumeLayout(false).
      cast(this-object:splitContainer4, System.ComponentModel.ISupportInitialize):EndInit().
      this-object:splitContainer4:ResumeLayout(false).
      this-object:ResumeLayout(false).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end method.
   method public void ObjectToForm():
      def var vI as int64 no-undo.
      if valid-object(this-object:Condition) then
      do:
         do vI = 1 to num-entries(this-object:Condition:SupportOp):
            this-object:cbOp:Items:Add(entry(vI,this-object:Condition:SupportOp)).
         end.
         assign
            this-object:cbEnabled:Checked = this-object:Condition:Enabled
            this-object:tbName:Text       = this-object:Condition:FieldName
            this-object:mtbValue:Text     = this-object:Condition:Value
            this-object:cbOp:Text         = this-object:Condition:Operation
         .
         SetComponentsToEnabled().
         SetVisible().
         case this-object:Condition:FieldType:
            when "date" then
            do:
               assign
                  this-object:dtPicker1:CustomFormat = "dd/MM/yyyy"
                  this-object:dtPicker2:CustomFormat = "dd/MM/yyyy"
                  this-object:dtPicker1:Text = this-object:Condition:value
                  this-object:dtPicker2:Text = this-object:Condition:value1
               .
            end.
            when "datetime" then
            do:
               assign
                  this-object:dtPicker1:CustomFormat = "dd/MM/yyyy HH:mm"
                  this-object:dtPicker2:CustomFormat = "dd/MM/yyyy HH:mm"
                  this-object:dtPicker1:Text = this-object:Condition:value
                  this-object:dtPicker2:Text = this-object:Condition:value1
               .
            end.
         end case.
      end.
   end method.
   method private void SetVisible():
      if not valid-object(this-object:Condition) then return.
      case this-object:Condition:FieldType:
         when "date" then
         do:
            assign
               this-object:mtbValue:Visible = no
               this-object:dtPicker1:visible = yes
               this-object:dtPicker2:visible = (this-object:cbOp:Text = "между")
            .
         end.
         when "datetime" then
         do:
            assign
               this-object:mtbValue:Visible = no
               this-object:dtPicker1:visible = yes
               this-object:dtPicker2:visible = (this-object:cbOp:Text = "между")
            .
         end.
         otherwise
         do:
            assign
               this-object:mtbValue:Visible = yes
               this-object:dtPicker1:visible = no
               this-object:dtPicker2:visible = no
            .
         end.
      end case.
   end method.
   method private void SetComponentsToEnabled():
      assign
         this-object:cbOp:enabled      = this-object:cbEnabled:Checked
         this-object:mtbValue:enabled  = this-object:cbEnabled:Checked and this-object:cbOp:Text <> ""
         this-object:dtPicker1:enabled = this-object:cbEnabled:Checked and this-object:cbOp:Text <> ""
         this-object:dtPicker2:enabled = this-object:cbEnabled:Checked and this-object:cbOp:Text <> ""
      .
   end method.
   method public void SetEnabledTo(iState as log):
      this-object:cbEnabled:Checked = iState.
   end method.
   method public void FormToObject():
      def var vIsDate as log no-undo.
      if valid-object(this-object:Condition) then
      do:
         assign
            this-object:Condition:enabled   = this-object:cbEnabled:Checked
            this-object:Condition:value     = this-object:mtbValue:Text
            this-object:Condition:Operation = this-object:cbOp:Text
         .
         if this-object:Condition:FieldType = "date" or
            this-object:Condition:FieldType = "datetime" then
         do:
            assign
               this-object:Condition:value = this-object:dtPicker1:Text
               this-object:Condition:value1 = this-object:dtPicker2:Text
            .
         end.
      end.
      return.
   end method.
   method public void SetValue(iValue as char):
      if cbEnabled:checked then
      do:
         if cbOp:text = "список" then
         do:
            assign
               mtbValue:text = substitute("&1,&2",mtbValue:text,iValue)
               mtbValue:text = trim(mtbValue:text,",")
            .
         end.
         else
         do:
            mtbValue:text = iValue.
         end.
      end.
   end method.
   method public void fReset():
      assign
         this-object:mtbValue:Text = ""
         this-object:cbOp:Text = ""
      .
   end method.
   method public void ResetAndDisable():
      this-object:fReset().
      this-object:SetEnabledTo(no).
   end method.
   method public char SelectedOp():
      return this-object:cbOp:Text.
   end method.
   destructor public flt_condition_uc ( ):
   end destructor.
end class.
