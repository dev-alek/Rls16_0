using Progress.Lang.*.
using Progress.Windows.Form.
block-level on error undo, throw.
class ibs.th.ref.marktype inherits Form:
  define public property vss-revision    as character no-undo init "$Revision:$":U get .
  define public property vss-author      as character no-undo init "$Author:$":U get.
  define public property vss-date        as character no-undo init "$Date:$":U get.
  define public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define public property vss-archive     as character no-undo init "$Archive:$":U get.
  define public property vss-description as character no-undo init "Отчет HDD" get.
  define private variable labelCode      as System.Windows.Forms.Label          no-undo.
  define private variable labelCodeValue as System.Windows.Forms.Label          no-undo.
  define private variable labelCodeName  as System.Windows.Forms.Label          no-undo.
  define private variable labelMisc1     as System.Windows.Forms.Label          no-undo.
  define private variable labelMisc2     as System.Windows.Forms.Label          no-undo.
  define private variable labelMisc3     as System.Windows.Forms.Label          no-undo.
  define private variable fillCode       as System.Windows.Forms.TextBox        no-undo.
  define private variable fillCodeValue  as System.Windows.Forms.TextBox        no-undo.
  define private variable fillCodeName   as System.Windows.Forms.TextBox        no-undo.
  define private variable fillMisc1      as System.Windows.Forms.TextBox        no-undo.
  define private variable checkMisc2      as System.Windows.Forms.CheckBox        no-undo.
  define private variable fillMisc3      as System.Windows.Forms.DateTimePicker no-undo.
  define private variable fillMisc4      as System.Windows.Forms.DateTimePicker no-undo.
  define private variable buttonEnter    as System.Windows.Forms.Button         no-undo.
  define private variable buttonExit     as System.Windows.Forms.Button         no-undo.
  define private variable components     as System.ComponentModel.IContainer    no-undo.
  define private variable groupBox       as System.Windows.Forms.GroupBox       no-undo.
  define property parparentproc as handle no-undo
    private get.
    set(input iH as handle):
      parparentproc = ih.
    end.
  define property mode as character no-undo
    get.
    set.
  define property codeType as character no-undo
    get.
    set.
  define property codeValue as character no-undo
    get.
    set.
  define property codeName as character no-undo
    get.
    set.
  define property codeMisc1 as character no-undo
    get.
    set.
  define property codeMisc2 as character no-undo
    get.
    set.
  define property codeMisc3 as character no-undo
    get.
    set.
  define property codeMisc4 as character no-undo
    get.
    set.
  define property isUpdated as logical no-undo
    get.
    set.
  constructor public marktype (
     iParentProc as handle,
     iMode as character,
     iCode      like ub.code.code,
     iCodeValue like ub.code.codevalue,
     iCodeName  like ub.code.codename,
     iMisc1     like ub.code.misc1,
     iMisc2     like ub.code.misc2,
     iMisc3     like ub.code.misc3,
     iMisc4     like ub.code.misc4
     ):
    define buffer bufCode for ub.code.
    super().
    assign
      parparentproc = iParentProc
      mode = iMode
    .
    InitializeComponent().
    this-object:ComponentsCollection:ADD(this-object:components).
    this-object:fillCode:text = iCode.
    if mode = 'ДОБАВЛЕНИЕ':U then
    do:
        assign
          this-object:fillMisc3:Value    = today
          this-object:fillMisc4:Value    = datetime(today, 0)
          this-object:checkMisc2:Checked = true
        .
    end.
    else
    do:
        assign
          this-object:fillCodeValue:text    = iCodeValue
          this-object:fillCodeName:text     = iCodeName
          this-object:fillMisc1:text        = iMisc1
          this-object:checkMisc2:Checked    = logical(iMisc2)
          this-object:fillMisc3:Value       = date(iMisc3)
          this-object:fillMisc4:Value       = datetime(date(iMisc3), int(IMisc4) * 1000)
        .
        if can-find(first bufCode where
                          bufCode.parent = "MarkType"
                      and bufCode.code   = this-object:fillCode:text
                    ) then
        do:
            assign
              this-object:fillCode:Enabled      = false
              this-object:fillCodeValue:Enabled = false
              this-object:fillMisc1:Enabled     = false
            .
        end.
    end.
    this-object:groupBox:Focus().
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.
  end constructor.
  @VisualDesigner.
  method private void mButtonExit( input sender as System.Object, input e as System.EventArgs ):
    isUpdated = false.
    close() .
    return.
  end method.
  @VisualDesigner.
  method private void mButtonEnter( input sender as System.Object, input e as System.EventArgs ):
    define buffer bufCode for ub.code.
    if this-object:fillCodeValue:text = "" or
       this-object:fillCodeName:text = "" or
       int(this-object:fillMisc1:text) = 0 then
    do:
        message "Все поля формы должны быть заполнены." view-as alert-box.
        return.
    end.
    if mode = 'ДОБАВЛЕНИЕ':U then
    do:
        find first bufCode where
                   bufCode.parent  = "MarkType"
               and (bufCode.code    = string(int(this-object:fillCode:text))
                or bufCode.codevalue = this-object:fillCodeValue:text)
             no-lock no-error.
        if avail bufCode then
        do:
            message
              substitute(
                  "В системе уже есть запись в кодом маркировки &1 и значением &2.~nСохранение невозможно.",
                  quoter(bufCode.code),
                  quoter(bufCode.codevalue)
              ) view-as alert-box.
            return.
        end.
    end.
    assign
        codeType  = this-object:fillCode:text
        codeValue = this-object:fillCodeValue:text
        codeName  = this-object:fillCodeName:text
        codeMisc1 = this-object:fillMisc1:text
        codeMisc2 = if this-object:checkMisc2:Checked then "yes" else "no"
        codeMisc3 = string(this-object:fillMisc3:Value,"99.99.9999")
        codeMisc4 = string(mtime(this-object:fillMisc4:Value) / 1000)
        isUpdated = true
    .
    close() .
    return.
  end method.
  @VisualDesigner.
  method private void mCheckDigit(input sender as System.Object, input e as System.EventArgs):
    define variable vTextBox as System.Windows.Forms.TextBox no-undo.
    define variable vText    as integer                      no-undo.
    vTextBox = cast(sender, System.Windows.Forms.TextBox).
    if vTextBox:Text = "" then return.
    vText = integer(vTextBox:text) no-error.
    if error-status:error or
       substring(vTextBox:text, 1, length(vTextBox:text)) = "." or
       substring(vTextBox:text, 1, length(vTextBox:text)) = "," or
       length(vTextBox:text) > 2 then
    do:
        vTextBox:text = substring(vTextBox:text, 1, length(vTextBox:text) - 1).
        vTextBox:SelectionStart = length(vTextBox:Text).
    end.
  end method.
  @VisualDesigner.
  method private void mCheckInputCodeValue(input sender as System.Object, input e as System.EventArgs):
    define variable vTextBox as System.Windows.Forms.TextBox no-undo.
    define variable vAscii as integer no-undo.
    define variable vCount as integer   no-undo.
    define variable vValue as character no-undo.
    vTextBox = cast(sender, System.Windows.Forms.TextBox).
    if vTextBox:Text = "" then return.
    do vCount = 1 to length(vTextBox:Text):
      vAscii   = asc(substring(vTextBox:text, vCount, 1)).
      if not ((vAscii >= 48 and vAscii <= 57) or
              (vAscii >= 65 and vAscii <= 90) or
              (vAscii >= 97 and vAscii <= 122)) then
      do:
        message
          "Разрешен ввод только цифр и латинских букв." skip
          "Проверьте раскладку клавиатуры."
          view-as alert-box.
        substring(vTextBox:text, vCount, 1) = "".
        vTextBox:SelectionStart = length(vTextBox:Text).
      end.
    end.
  end method.
  method private void InitializeComponent(  ):
    define variable vTopPosition as integer no-undo.
    define variable vFillWidth   as integer no-undo.
    @VisualDesigner.FormMember (NeedsInitialize="true").
    define variable resources as Progress.Util.ResourceManager no-undo.
    resources = new Progress.Util.ResourceManager("ibs.th.ref.marktype").
    this-object:labelCode      = new System.Windows.Forms.Label().
    this-object:labelCodeValue = new System.Windows.Forms.Label().
    this-object:labelCodeName  = new System.Windows.Forms.Label().
    this-object:labelMisc1     = new System.Windows.Forms.Label().
    this-object:labelMisc2     = new System.Windows.Forms.Label().
    this-object:labelMisc3     = new System.Windows.Forms.Label().
    this-object:fillCode       = new System.Windows.Forms.TextBox().
    this-object:fillCodeValue  = new System.Windows.Forms.TextBox().
    this-object:fillCodeName   = new System.Windows.Forms.TextBox().
    this-object:fillMisc1      = new System.Windows.Forms.TextBox().
    this-object:checkMisc2      = new System.Windows.Forms.CheckBox().
    this-object:fillMisc3      = new System.Windows.Forms.DateTimePicker().
    this-object:fillMisc4      = new System.Windows.Forms.DateTimePicker().
    this-object:buttonEnter    = new System.Windows.Forms.Button().
    this-object:buttonExit     = new System.Windows.Forms.Button().
    this-object:groupBox       = new System.Windows.Forms.GroupBox().
    this-object:groupBox:SuspendLayout().
    this-object:SuspendLayout().
    this-object:buttonEnter:FlatStyle = System.Windows.Forms.FlatStyle:Popup.
    this-object:buttonEnter:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(10), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:buttonEnter:Location = new System.Drawing.Point(5, 2).
    this-object:buttonEnter:Name = "buttonEnter".
    this-object:buttonEnter:Size = new System.Drawing.Size(94, 23).
    this-object:buttonEnter:TabIndex = 8.
    this-object:buttonEnter:Text = "Ввод".
    this-object:buttonEnter:UseCompatibleTextRendering = true.
    this-object:buttonEnter:UseVisualStyleBackColor = true.
    this-object:buttonEnter:Click:Subscribe(this-object:mButtonEnter).
    this-object:buttonExit:FlatStyle = System.Windows.Forms.FlatStyle:Popup.
    this-object:buttonExit:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(10), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:buttonExit:Location = new System.Drawing.Point(100, 2).
    this-object:buttonExit:Name = "buttonExit".
    this-object:buttonExit:Size = new System.Drawing.Size(94, 23).
    this-object:buttonExit:TabIndex = 9.
    this-object:buttonExit:Text = "Выход".
    this-object:buttonExit:UseCompatibleTextRendering = true.
    this-object:buttonExit:UseVisualStyleBackColor = true.
    this-object:buttonExit:Click:Subscribe(this-object:mButtonExit).
    vTopPosition  = 10.
    vFillWidth = 20.
    this-object:labelCode:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(10), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:labelCode:Location = new System.Drawing.Point(1, vTopPosition).
    this-object:labelCode:Name = "labelCode".
    this-object:labelCode:Size = new System.Drawing.Size(175, 23).
    this-object:labelCode:Text = "Код:".
    this-object:labelCode:TextAlign = System.Drawing.ContentAlignment:MiddleRight.
    this-object:labelCode:UseCompatibleTextRendering = true.
    this-object:fillCode:Location = new System.Drawing.Point(176, vTopPosition).
    this-object:fillCode:Name = "fillCode".
    this-object:fillCode:Size = new System.Drawing.Size(vFillWidth, 23).
    this-object:fillCode:TabIndex = 1.
    this-object:fillCode:TextChanged:Subscribe(this-object:mCheckDigit).
    vTopPosition = 10 + 1 * 25.
    vFillWidth = 80.
    this-object:labelCodeValue:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(10), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:labelCodeValue:Location = new System.Drawing.Point(1, vTopPosition).
    this-object:labelCodeValue:Name = "labelCodeValue".
    this-object:labelCodeValue:Size = new System.Drawing.Size(175, 23).
    this-object:labelCodeValue:Text = "Значение:".
    this-object:labelCodeValue:TextAlign = System.Drawing.ContentAlignment:MiddleRight.
    this-object:labelCodeValue:UseCompatibleTextRendering = true.
    this-object:fillCodeValue:Location = new System.Drawing.Point(176, vTopPosition).
    this-object:fillCodeValue:Name = "fillCodeValue".
    this-object:fillCodeValue:Size = new System.Drawing.Size(vFillWidth, 23).
    this-object:fillCodeValue:TabIndex = 2.
    this-object:fillCodeValue:TextChanged:Subscribe(this-object:mCheckInputCodeValue).
    vTopPosition = 10 + 2 * 25.
    vFillWidth = 400.
    this-object:labelCodeName:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(10), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:labelCodeName:Location = new System.Drawing.Point(1, vTopPosition).
    this-object:labelCodeName:Name = "labelCodeName".
    this-object:labelCodeName:Size = new System.Drawing.Size(175, 23).
    this-object:labelCodeName:TabIndex = 34.
    this-object:labelCodeName:Text = "Наименование:".
    this-object:labelCodeName:TextAlign = System.Drawing.ContentAlignment:MiddleRight.
    this-object:labelCodeName:UseCompatibleTextRendering = true.
    this-object:fillCodeName:Location = new System.Drawing.Point(176, vTopPosition).
    this-object:fillCodeName:Name = "fillCodeName".
    this-object:fillCodeName:Size = new System.Drawing.Size(vFillWidth, 23).
    this-object:fillCodeName:TabIndex = 3.
    vTopPosition = 10 + 3 * 25.
    vFillWidth = 20.
    this-object:labelMisc1:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(10), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:labelMisc1:Location = new System.Drawing.Point(1, vTopPosition).
    this-object:labelMisc1:Name = "labelMisc1".
    this-object:labelMisc1:Size = new System.Drawing.Size(175, 23).
    this-object:labelMisc1:TabIndex = 34.
    this-object:labelMisc1:Text = "Длина серийного номера:".
    this-object:labelMisc1:TextAlign = System.Drawing.ContentAlignment:MiddleRight.
    this-object:labelMisc1:UseCompatibleTextRendering = true.
    this-object:fillMisc1:Location = new System.Drawing.Point(176, vTopPosition).
    this-object:fillMisc1:Name = "fillMisc1".
    this-object:fillMisc1:Size = new System.Drawing.Size(vFillWidth, 23).
    this-object:fillMisc1:TabIndex = 4.
    this-object:fillMisc1:TextChanged:Subscribe(this-object:mCheckDigit).
    vTopPosition = 10 + 4 * 25.
    vFillWidth = 30.
    this-object:labelMisc2:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(10), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:labelMisc2:Location = new System.Drawing.Point(1, vTopPosition).
    this-object:labelMisc2:Name = "labelMisc2".
    this-object:labelMisc2:Size = new System.Drawing.Size(175, 23).
    this-object:labelMisc2:Text = "Конфигурация для кассы :".
    this-object:labelMisc2:TextAlign = System.Drawing.ContentAlignment:MiddleRight.
    this-object:labelMisc2:UseCompatibleTextRendering = true.
    this-object:checkMisc2:Location = new System.Drawing.Point(176, vTopPosition).
    this-object:checkMisc2:Name = "checkMisc2".
    this-object:checkMisc2:Size = new System.Drawing.Size(vFillWidth, 23).
    this-object:checkMisc2:TabIndex = 5.
    vTopPosition = 10 + 5 * 25.
    vFillWidth = 93.
    this-object:labelMisc3:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(10), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:labelMisc3:Location = new System.Drawing.Point(1, vTopPosition).
    this-object:labelMisc3:Name = "labelMisc3".
    this-object:labelMisc3:Size = new System.Drawing.Size(175, 23).
    this-object:labelMisc3:Text = "Дата/Время:".
    this-object:labelMisc3:TextAlign = System.Drawing.ContentAlignment:MiddleRight.
    this-object:labelMisc3:UseCompatibleTextRendering = true.
    this-object:fillMisc3:Format = System.Windows.Forms.DateTimePickerFormat:Short.
    this-object:fillMisc3:Location = new System.Drawing.Point(176, vTopPosition).
    this-object:fillMisc3:Name = "DataMatrix".
    this-object:fillMisc3:Size = new System.Drawing.Size(vFillWidth, 23).
    this-object:fillMisc3:TabIndex = 6.
    this-object:fillMisc3:Value = Progress.Util.DateTimeHelper:Create(2019, 10, 29, 0, 0, 0, 0).
    this-object:fillMisc4:AllowDrop = true.
    this-object:fillMisc4:DropDownAlign = System.Windows.Forms.LeftRightAlignment:Right.
    this-object:fillMisc4:Format = System.Windows.Forms.DateTimePickerFormat:Custom.
    this-object:fillMisc4:CustomFormat = "HH:mm".
    this-object:fillMisc4:Location = new System.Drawing.Point(176 + vFillWidth, vTopPosition).
    this-object:fillMisc4:Name = "fillMisc4".
    this-object:fillMisc4:ShowUpDown = true.
    this-object:fillMisc4:Size = new System.Drawing.Size(60, 23).
    this-object:fillMisc4:TabIndex = 7.
    this-object:groupBox:Controls:Add(this-object:labelCode).
    this-object:groupBox:Controls:Add(this-object:fillCode).
    this-object:groupBox:Controls:Add(this-object:labelCodeValue).
    this-object:groupBox:Controls:Add(this-object:fillCodeValue).
    this-object:groupBox:Controls:Add(this-object:labelCodeName).
    this-object:groupBox:Controls:Add(this-object:fillCodeName).
    this-object:groupBox:Controls:Add(this-object:labelMisc1).
    this-object:groupBox:Controls:Add(this-object:fillMisc1).
    this-object:groupBox:Controls:Add(this-object:labelMisc2).
    this-object:groupBox:Controls:Add(this-object:checkMisc2).
    this-object:groupBox:Controls:Add(this-object:labelMisc3).
    this-object:groupBox:Controls:Add(this-object:fillMisc3).
    this-object:groupBox:Controls:Add(this-object:fillMisc4).
    this-object:groupBox:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(10), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:groupBox:Location = new System.Drawing.Point(5, 25).
    this-object:groupBox:Name = "groupBox".
    this-object:groupBox:Size = new System.Drawing.Size(622, 265).
    this-object:groupBox:TabStop = false.
    this-object:groupBox:UseCompatibleTextRendering = true.
    this-object:ClientSize = new System.Drawing.Size(636, 301).
    this-object:Controls:Add(this-object:groupBox).
    this-object:Controls:Add(this-object:buttonExit).
    this-object:Controls:Add(this-object:buttonEnter).
    this-object:Name = "MarkType".
    this-object:Text = substitute("&1 ~"Типы маркировки~"", if mode = 'ДОБАВЛЕНИЕ':U then "Добавление" else "Редактирование").
    this-object:StartPosition = System.Windows.Forms.FormStartPosition:CenterParent.
    this-object:groupBox:ResumeLayout(false).
    this-object:groupBox:PerformLayout().
    this-object:ResumeLayout(false).
    this-object:PerformLayout().
this-object:fillMisc3:KeyDown:Subscribe(this-object:date_KeyDown).
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
  destructor public marktype ( ):
  end destructor.
end class.
