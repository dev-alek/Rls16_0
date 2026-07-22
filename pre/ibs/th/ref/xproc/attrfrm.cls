using Progress.Windows.Form.
block-level on error undo, throw.
class ibs.th.ref.xproc.attrfrm inherits Form :
 define public property vss-revision    as character no-undo init "$Revision:$":U get .
  define public property vss-author      as character no-undo init "$Author:$":U get.
  define public property vss-date        as character no-undo init "$Date:$":U get.
  define public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define public property vss-archive     as character no-undo init "$Archive:$":U get.
  define public property vss-description as character no-undo init "Редатктор атрибутов" get.
   define public variable checkBox as System.Windows.Forms.CheckBox no-undo.
   define public variable comboBox as System.Windows.Forms.ComboBox no-undo.
   define public variable button as System.Windows.Forms.Button no-undo.
   define private variable components as System.ComponentModel.IContainer no-undo.
    define private variable buttonOk as System.Windows.Forms.Button no-undo.
    define private variable buttonCancel as System.Windows.Forms.Button no-undo.
   define public variable textBox as System.Windows.Forms.TextBox no-undo.
   define public variable numericUpDown as System.Windows.Forms.NumericUpDown no-undo.
   define public variable dateTimePicker as System.Windows.Forms.DateTimePicker no-undo.
   define variable mtrg as class ibs.th.ref.xproc.attrFrm_trg no-undo.
   constructor public attrfrm( ):
      super().
      InitializeComponent ( ).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end constructor.
   constructor public attrfrm(itrg as  ibs.th.ref.xproc.attrFrm_trg ):
      super().
      InitializeComponent ( ).
      mtrg = itrg.
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end constructor.
   destructor public attrfrm( ):
      if valid-object(components) then do:
         cast(components, System.IDisposable):Dispose().
      end.
   end destructor.
        @VisualDesigner.
        method private void button_Click( input sender as System.Object, input e as System.EventArgs ):
                textBox:text = mtrg:btnCode(textBox:text).
                return.
        end method.
    method private void okButton_Click (sender as System.Object, e as System.EventArgs):
      mtrg:setresult().
      if mtrg:CheckAttr()
      then do:
         this-object:DialogResult = System.Windows.Forms.DialogResult:Ok.
         this-object:Close ( ).
      end.
   end method.
   method private void cancelButton_Click (sender as System.Object, e as System.EventArgs):
      this-object:DialogResult = System.Windows.Forms.DialogResult:Cancel.
      this-object:Close ( ).
   end method.
   method private void InitializeComponent ( ):
      this-object:buttonOk = new System.Windows.Forms.Button().
      this-object:buttonCancel = new System.Windows.Forms.Button().
      this-object:dateTimePicker = new System.Windows.Forms.DateTimePicker().
      this-object:textBox = new System.Windows.Forms.TextBox().
      this-object:comboBox = new System.Windows.Forms.ComboBox().
      this-object:numericUpDown = new System.Windows.Forms.NumericUpDown().
      this-object:button = new System.Windows.Forms.Button().
      this-object:checkBox = new System.Windows.Forms.CheckBox().
      cast(this-object:numericUpDown, System.ComponentModel.ISupportInitialize):BeginInit().
      this-object:SuspendLayout().
      define variable nestedvar0 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar0 = System.Windows.Forms.AnchorStyles:Bottom.
      this-object:buttonOk:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:buttonOk:Location = new System.Drawing.Point(121, 170).
      this-object:buttonOk:Name = "buttonOk".
      this-object:buttonOk:Size = new System.Drawing.Size(75, 23).
      this-object:buttonOk:TabIndex = 0.
      this-object:buttonOk:Text = "OK".
      this-object:buttonOk:UseCompatibleTextRendering = true.
      this-object:buttonOk:Click:Subscribe(this-object:okButton_Click).
      define variable nestedvar1 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar1 = System.Windows.Forms.AnchorStyles:Bottom.
      this-object:buttonCancel:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar1, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:buttonCancel:DialogResult = System.Windows.Forms.DialogResult:Cancel.
      this-object:buttonCancel:Location = new System.Drawing.Point(205, 170).
      this-object:buttonCancel:Name = "buttonCancel".
      this-object:buttonCancel:Size = new System.Drawing.Size(75, 23).
      this-object:buttonCancel:TabIndex = 1.
      this-object:buttonCancel:Text = "Cancel".
      this-object:buttonCancel:UseCompatibleTextRendering = true.
      this-object:buttonCancel:Click:Subscribe(this-object:cancelButton_Click).
      this-object:dateTimePicker:Location = new System.Drawing.Point(3, 13).
      this-object:dateTimePicker:Name = "dateTimePicker".
      this-object:dateTimePicker:Size = new System.Drawing.Size(153, 20).
      this-object:dateTimePicker:TabIndex = 2.
      this-object:dateTimePicker:Visible = false.
      define variable nestedvar2 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar2 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:textBox:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar2, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:textBox:Location = new System.Drawing.Point(3, 39).
      this-object:textBox:Name = "textBox".
      this-object:textBox:Size = new System.Drawing.Size(257, 20).
      this-object:textBox:TabIndex = 3.
      this-object:textBox:Visible = false.
      define variable nestedvar3 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar3 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:comboBox:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar3, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:comboBox:DropDownStyle = System.Windows.Forms.ComboBoxStyle:DropDownList.
      this-object:comboBox:FormattingEnabled = true.
      this-object:comboBox:Location = new System.Drawing.Point(3, 66).
      this-object:comboBox:Name = "comboBox".
      this-object:comboBox:Size = new System.Drawing.Size(288, 21).
      this-object:comboBox:TabIndex = 4.
      this-object:comboBox:Visible = false.
      define variable nestedvar4 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar4 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:numericUpDown:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar4, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:numericUpDown:Location = new System.Drawing.Point(3, 93).
      this-object:numericUpDown:Name = "numericUpDown".
      this-object:numericUpDown:Size = new System.Drawing.Size(288, 20).
      this-object:numericUpDown:TabIndex = 5.
      this-object:numericUpDown:Visible = false.
      define variable nestedvar5 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar5 = System.Windows.Forms.AnchorStyles:Top.
      this-object:button:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar5, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:button:Location = new System.Drawing.Point(266, 37).
      this-object:button:Name = "button".
      this-object:button:Size = new System.Drawing.Size(25, 23).
      this-object:button:TabIndex = 6.
      this-object:button:UseCompatibleTextRendering = true.
      this-object:button:UseVisualStyleBackColor = true.
      this-object:button:Visible = false.
      this-object:button:Click:Subscribe(this-object:button_Click).
      define variable nestedvar6 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar6 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:checkBox:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar6, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:checkBox:Location = new System.Drawing.Point(3, 120).
      this-object:checkBox:Name = "checkBox".
      this-object:checkBox:Size = new System.Drawing.Size(288, 24).
      this-object:checkBox:TabIndex = 7.
      this-object:checkBox:Text = "checkBox".
      this-object:checkBox:UseCompatibleTextRendering = true.
      this-object:checkBox:UseVisualStyleBackColor = true.
      this-object:checkBox:Visible = false.
      this-object:AcceptButton = this-object:buttonOk.
      this-object:CancelButton = this-object:buttonCancel.
      this-object:ClientSize = new System.Drawing.Size(294, 207).
      this-object:Controls:Add(this-object:checkBox).
      this-object:Controls:Add(this-object:button).
      this-object:Controls:Add(this-object:numericUpDown).
      this-object:Controls:Add(this-object:comboBox).
      this-object:Controls:Add(this-object:textBox).
      this-object:Controls:Add(this-object:dateTimePicker).
      this-object:Controls:Add(this-object:buttonCancel).
      this-object:Controls:Add(this-object:buttonOk).
      this-object:FormBorderStyle = System.Windows.Forms.FormBorderStyle:FixedDialog.
      this-object:MaximizeBox = false.
      this-object:MinimizeBox = false.
      this-object:Name = "attrfrm".
      this-object:ShowInTaskbar = false.
      this-object:StartPosition = System.Windows.Forms.FormStartPosition:CenterParent.
      this-object:Text = "Редактирование атрибута".
      cast(this-object:numericUpDown, System.ComponentModel.ISupportInitialize):EndInit().
      this-object:ResumeLayout(false).
      this-object:PerformLayout().
this-object:dateTimePicker:KeyDown:Subscribe(this-object:date_KeyDown).
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
   end method.
   method public void ShowModalDialog(  ):
      wait-for this-object:ShowDialog().
   end method.
end class.
