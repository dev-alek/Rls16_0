 
/*------------------------------------------------------------------------
   File        : report_hdd
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : eshklyar
   Created     : Sun Oct 27 08:50:34 MSK 2019
   Notes       : 
 ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Progress.Windows.Form.

block-level on error undo, throw.

class ibs.th.ref.report_hdd inherits Form: 
   define public property vss-revision    as character no-undo init "$Revision:$":U get .
  define public property vss-author      as character no-undo init "$Author:$":U get.
  define public property vss-date        as character no-undo init "$Date:$":U get.
  define public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define public property vss-archive     as character no-undo init "$Archive:$":U get.
  define public property vss-description as character no-undo init "Отчет HDD" get.
  define private variable attr_type     as System.Windows.Forms.TextBox        no-undo.
  define private variable attr_name     as System.Windows.Forms.TextBox        no-undo.
  define private variable b_run         as System.Windows.Forms.Button         no-undo.
  define private variable bobj_list     as System.Windows.Forms.Button         no-undo.
  define private variable b_exit        as System.Windows.Forms.Button         no-undo.
  define private variable components    as System.ComponentModel.IContainer    no-undo.
  define private variable date_start    as System.Windows.Forms.DateTimePicker no-undo.
  define private variable date_end      as System.Windows.Forms.DateTimePicker no-undo.
  define private variable label6        as System.Windows.Forms.Label          no-undo.
  define private variable label5        as System.Windows.Forms.Label          no-undo.
  define private variable label4        as System.Windows.Forms.Label          no-undo.
  define private variable label3        as System.Windows.Forms.Label          no-undo.
  define private variable label2        as System.Windows.Forms.Label          no-undo.
  define private variable label10       as System.Windows.Forms.Label          no-undo.
  define private variable label1        as System.Windows.Forms.Label          no-undo.
  define private variable groupBox1     as System.Windows.Forms.GroupBox       no-undo.
  define private variable label7 as System.Windows.Forms.Label no-undo.
  define private variable obj_list      as System.Windows.Forms.TextBox        no-undo.
  define private variable time_start    as System.Windows.Forms.DateTimePicker no-undo.
  define private variable time_end      as System.Windows.Forms.DateTimePicker no-undo.
  define private variable NamePK        as System.Windows.Forms.TextBox        no-undo.
  define private variable ModelDisk     as System.Windows.Forms.TextBox        no-undo.
  
  define private variable v-DateStart   as date                                no-undo .
  define private variable v-DateEnd     as date                                no-undo .
  define private variable v-TimeStart   as datetime                            no-undo .
  define private variable v-TimeEnd     as datetime                            no-undo .
  define private variable v-NamePK      as character                           no-undo .
  define private variable v-ModelDisk   as character                           no-undo .
  define private variable v-AttrName    as character                           no-undo .
  define private variable v-AttrType    as character                           no-undo .
  define private variable v-ChahgeRaw   as logical                             no-undo .  
  define private variable v-ChahgeValue as logical                             no-undo .
  define private variable v-obj-list    as character                           no-undo .
  define private variable v-RawValue    as decimal                             no-undo .
  define private variable v-ThreshDisk  as decimal                             no-undo .
  define private variable v-ValueDisk   as decimal                             no-undo .
      
  define temp-table userobjs_temp-user-obj no-undo
    field obj-type as character
    field obj-code as integer
    field db-num   as integer
    index xpk is primary unique obj-type obj-code db-num
    .
  
  define temp-table temp_obj-list no-undo
    field obj-type as character
    field obj-code as integer
    field db-num   as integer
    index pi is primary unique obj-type obj-code db-num
    .  

  define property parparentproc as handle no-undo
    private get.
    set(input iH as handle):
      parparentproc = ih.
    end.
   
  define property p-callback-handle as handle no-undo
    private get.
    set(input iH as handle):
      p-callback-handle = ih.
    end.
  { cmp/library.i  class }
    
  constructor public report_hdd (  ):

    super().
    InitializeComponent().
    this-object:ComponentsCollection:ADD(this-object:components).
    this-object:date_start:Value = today .
    this-object:date_end:Value = today .
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.

  end constructor.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void b_exit_Click( input sender as System.Object, input e as System.EventArgs ):
    close() .
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void button_click_run( input sender as System.Object, input e as System.EventArgs ):
    
    assign
      v-DateStart   = date(this-object:date_start:Text)
      v-DateEnd     = date(this-object:date_end:Text)
      v-TimeStart   = this-object:time_start:Value
      v-TimeEnd     = this-object:time_end:Value
      v-NamePK      = this-object:NamePK:Text
      v-ModelDisk   = this-object:ModelDisk:Text
      v-AttrName    = this-object:attr_name:Text
      v-AttrType    = this-object:attr_type:Text
      .

    run rep/hdd-report.p (input parparentproc,
      input v-DateStart,
      input v-DateEnd,
      input v-TimeStart,
      input v-TimeEnd,
      input v-NamePK,
      input v-ModelDisk,
      input v-AttrName,
      input v-AttrType,
      input v-obj-list) no-error .

    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void change_odject( input sender as System.Object, input e as System.EventArgs ):
    /*	p-obj-list = this-object:obj_list:Text .	*/
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void click_choice_obj( input sender as System.Object, input e as System.EventArgs ):
    define variable v-host-code like ub.sysconf.host-code no-undo .
    define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
    define variable v-select-obj-type  as character no-undo .
    define variable v-select-obj-code  as integer   no-undo .
    define variable v-object-available as logical   no-undo .
    define variable p-obj-list         as character no-undo .
            
    { cmp/str-glbl.i class }
    { gbl/getcntxt.i def }
    { gbl/getcntxt.i get }

    for each buf_userobjs_temp-user-obj
      on error undo, return error return-value
      :
      delete buf_userobjs_temp-user-obj .
    end.

    { gbl/usobjava.i
         v-cntxt-db-num
         {&action-head-code-main}
         v-cntxt-userid
         v-cntxt-obj-type
         v-cntxt-obj-code
         v-object-available
         no-error
    }
    if error-status :error
      then
    do:
      message
        "Ошибка при вызове процедуры gbl/usobjava.i" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return no-apply .
    end.

    if v-object-available = true
      then
    do:

      find first buf_userobjs_temp-user-obj
        where buf_userobjs_temp-user-obj.obj-type = v-cntxt-obj-type
        and buf_userobjs_temp-user-obj.obj-code = v-cntxt-obj-code
        and buf_userobjs_temp-user-obj.db-num = v-cntxt-db-num
        no-error .
      if not available buf_userobjs_temp-user-obj
        then
      do:
        create buf_userobjs_temp-user-obj .
        assign
          buf_userobjs_temp-user-obj.obj-type = v-cntxt-obj-type
          buf_userobjs_temp-user-obj.obj-code = v-cntxt-obj-code
          buf_userobjs_temp-user-obj.db-num   = v-cntxt-db-num
          .
      end.
    end.

    define variable v-user-select as logical no-undo .
    run gbl/userobjs.w
      (input  parparentproc          /* parparentproc        */
      ,input  p-callback-handle /* p-callback-handle    */
      ,input  v-cntxt-db-num               /* p-db-num             */
      ,input  v-cntxt-userid              /* p-user-id            */
      ,input  v-cntxt-host-code-obj        /* p-curr-host-code-obj */
      ,input  v-cntxt-obj-type             /* p-curr-obj-type      */
      ,input  v-cntxt-obj-code             /* p-curr-obj-code      */
      ,INPUT  "b-sel,b-mark"         /* p-bttn               */
      ,output v-user-select          /* p-user-select        */
      ,output v-select-obj-type      /* p-select-obj-type    */
      ,output v-select-obj-code      /* p-select-obj-code    */
      ) .

    if v-user-select <> true
      then
    do:
      message
        "Объект не выбран"
        view-as alert-box information .
      assign
        p-obj-list = ""
        v-obj-list = ""
        .
    end.
    else 
    do:
    
      for each temp_obj-list:
        delete temp_obj-list.
      end.

      for each buf_userobjs_temp-user-obj
        on error undo, return no-apply
        :
        create temp_obj-list.
        assign
          temp_obj-list.obj-type = buf_userobjs_temp-user-obj.obj-type
          temp_obj-list.obj-code = buf_userobjs_temp-user-obj.obj-code
          .
      end.

      assign
        p-obj-list = ""
        v-obj-list = ""
        .
      for each temp_obj-list
        :
        assign
          p-obj-list = p-obj-list + "," + temp_obj-list.obj-type + "," + string( temp_obj-list.obj-code )
          .
        find first ub.clients no-lock where ub.clients.obj-code = userobjs_temp-user-obj.obj-code and ub.clients.obj-type = userobjs_temp-user-obj.obj-type no-error .
          if available (ub.clients) then v-obj-list = v-obj-list + "," + string( ub.clients.db-num).
          else v-obj-list = v-obj-list + "," + string(temp_obj-list.obj-code ).
        
      end.
      p-obj-list = trim (p-obj-list,",") .
      v-obj-list = trim(v-obj-list,",").
    end.    
    this-object:obj_list:Text = string(p-obj-list) .
    
    return.

  end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void date_end_Leave( input sender as System.Object, input e as System.EventArgs ):
		  if this-object:date_start:Value > this-object:date_end:Value then do:
      message "Дата " + this-object:date_start:Text + " больше даты " + this-object:date_end:Text 
      view-as alert-box.
      return no-apply .
    end.  
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void date_start_Leave( input sender as System.Object, input e as System.EventArgs ):
		if date(this-object:date_start:Value) > date(today) then do:
		  message "Дата больше текущей даты."
      view-as alert-box.
      return no-apply .
		end.  
		return.

	end method.

  method private void InitializeComponent(  ):
    
    /* NOTE: The following method is automatically generated.
    
    We strongly suggest that the contents of this method only be modified using the
    Visual Designer to avoid any incompatible modifications.
    
    Modifying the contents of this method using a code editor will invalidate any support for this file. */
    @VisualDesigner.FormMember (NeedsInitialize="true").
    define variable resources as Progress.Util.ResourceManager no-undo.
    resources = new Progress.Util.ResourceManager("ibs.th.ref.report_hdd").
    this-object:date_start = new System.Windows.Forms.DateTimePicker().
    this-object:bobj_list = new System.Windows.Forms.Button().
    this-object:obj_list = new System.Windows.Forms.TextBox().
    this-object:time_start = new System.Windows.Forms.DateTimePicker().
    this-object:ModelDisk = new System.Windows.Forms.TextBox().
    this-object:NamePK = new System.Windows.Forms.TextBox().
    this-object:b_exit = new System.Windows.Forms.Button().
    this-object:b_run = new System.Windows.Forms.Button().
    this-object:label1 = new System.Windows.Forms.Label().
    this-object:date_end = new System.Windows.Forms.DateTimePicker().
    this-object:time_end = new System.Windows.Forms.DateTimePicker().
    this-object:label2 = new System.Windows.Forms.Label().
    this-object:label3 = new System.Windows.Forms.Label().
    this-object:label4 = new System.Windows.Forms.Label().
    this-object:label5 = new System.Windows.Forms.Label().
    this-object:groupBox1 = new System.Windows.Forms.GroupBox().
    this-object:label7 = new System.Windows.Forms.Label().
    this-object:label10 = new System.Windows.Forms.Label().
    this-object:attr_type = new System.Windows.Forms.TextBox().
    this-object:label6 = new System.Windows.Forms.Label().
    this-object:attr_name = new System.Windows.Forms.TextBox().
    this-object:groupBox1:SuspendLayout().
    this-object:SuspendLayout().
    /*  */
    /* date_start */
    /*  */
    this-object:date_start:Format = System.Windows.Forms.DateTimePickerFormat:Short.
    this-object:date_start:Location = new System.Drawing.Point(131, 47).
    this-object:date_start:Name = "date_start".
    this-object:date_start:Size = new System.Drawing.Size(93, 20).
    this-object:date_start:TabIndex = 4.
    this-object:date_start:Value = Progress.Util.DateTimeHelper:Create(2019, 10, 29, 0, 0, 0, 0).
    this-object:date_start:Leave:Subscribe(this-object:date_start_Leave).
    /*  */
    /* bobj_list */
    /*  */
    this-object:bobj_list:Image = cast(resources:GetObject("bobj_list.Image"), System.Drawing.Image).
    this-object:bobj_list:Location = new System.Drawing.Point(489, 5).
    this-object:bobj_list:Name = "bobj_list".
    this-object:bobj_list:Size = new System.Drawing.Size(25, 23).
    this-object:bobj_list:TabIndex = 3.
    this-object:bobj_list:UseCompatibleTextRendering = true.
    this-object:bobj_list:UseVisualStyleBackColor = true.
    this-object:bobj_list:Click:Subscribe(this-object:click_choice_obj).
    /*  */
    /* obj_list */
    /*  */
    this-object:obj_list:Location = new System.Drawing.Point(230, 6).
    this-object:obj_list:Name = "obj_list".
    this-object:obj_list:Size = new System.Drawing.Size(254, 20).
    this-object:obj_list:TabIndex = 2.
    this-object:obj_list:TextChanged:Subscribe(this-object:change_odject).
    /*  */
    /* time_start */
    /*  */
    this-object:time_start:AllowDrop = true.
    this-object:time_start:DropDownAlign = System.Windows.Forms.LeftRightAlignment:Right.
    this-object:time_start:Format = System.Windows.Forms.DateTimePickerFormat:Time.
    this-object:time_start:Location = new System.Drawing.Point(230, 47).
    this-object:time_start:Name = "time_start".
    this-object:time_start:ShowUpDown = true.
    this-object:time_start:Size = new System.Drawing.Size(67, 20).
    this-object:time_start:TabIndex = 5.
    this-object:time_start:ValueChanged:Subscribe(this-object:time_start_ValueChanged).
    /*  */
    /* ModelDisk */
    /*  */
    this-object:ModelDisk:Location = new System.Drawing.Point(131, 117).
    this-object:ModelDisk:Name = "ModelDisk".
    this-object:ModelDisk:Size = new System.Drawing.Size(310, 20).
    this-object:ModelDisk:TabIndex = 9.
    /*  */
    /* NamePK */
    /*  */
    this-object:NamePK:Location = new System.Drawing.Point(131, 86).
    this-object:NamePK:Name = "NamePK".
    this-object:NamePK:Size = new System.Drawing.Size(310, 20).
    this-object:NamePK:TabIndex = 8.
    /*  */
    /* b_exit */
    /*  */
    this-object:b_exit:FlatStyle = System.Windows.Forms.FlatStyle:Popup.
    this-object:b_exit:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(10), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:b_exit:Location = new System.Drawing.Point(4, 3).
    this-object:b_exit:Name = "b_exit".
    this-object:b_exit:Size = new System.Drawing.Size(94, 23).
    this-object:b_exit:TabIndex = 1.
    this-object:b_exit:Text = "Выход".
    this-object:b_exit:UseCompatibleTextRendering = true.
    this-object:b_exit:UseVisualStyleBackColor = true.
    this-object:b_exit:Click:Subscribe(this-object:b_exit_Click).
    /*  */
    /* b_run */
    /*  */
    this-object:b_run:FlatStyle = System.Windows.Forms.FlatStyle:Popup.
    this-object:b_run:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(10), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:b_run:Location = new System.Drawing.Point(535, 3).
    this-object:b_run:Name = "b_run".
    this-object:b_run:Size = new System.Drawing.Size(94, 23).
    this-object:b_run:TabIndex = 17.
    this-object:b_run:Text = "Запустить".
    this-object:b_run:UseCompatibleTextRendering = true.
    this-object:b_run:UseVisualStyleBackColor = true.
    this-object:b_run:Click:Subscribe(this-object:button_click_run).
    /*  */
    /* label1 */
    /*  */
    this-object:label1:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(10), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:label1:Location = new System.Drawing.Point(104, 6).
    this-object:label1:Name = "label1".
    this-object:label1:Size = new System.Drawing.Size(120, 23).
    this-object:label1:TabIndex = 34.
    this-object:label1:Text = "Выбор объектов:".
    this-object:label1:TextAlign = System.Drawing.ContentAlignment:MiddleCenter.
    this-object:label1:UseCompatibleTextRendering = true.
    /*  */
    /* date_end */
    /*  */
    this-object:date_end:Format = System.Windows.Forms.DateTimePickerFormat:Short.
    this-object:date_end:Location = new System.Drawing.Point(348, 47).
    this-object:date_end:Name = "date_end".
    this-object:date_end:Size = new System.Drawing.Size(93, 20).
    this-object:date_end:TabIndex = 6.
    this-object:date_end:Value = Progress.Util.DateTimeHelper:Create(2019, 10, 29, 0, 0, 0, 0).
    this-object:date_end:Leave:Subscribe(this-object:date_end_Leave).
    /*  */
    /* time_end */
    /*  */
    this-object:time_end:AllowDrop = true.
    this-object:time_end:DropDownAlign = System.Windows.Forms.LeftRightAlignment:Right.
    this-object:time_end:Format = System.Windows.Forms.DateTimePickerFormat:Time.
    this-object:time_end:Location = new System.Drawing.Point(447, 47).
    this-object:time_end:Name = "time_end".
    this-object:time_end:ShowUpDown = true.
    this-object:time_end:Size = new System.Drawing.Size(67, 20).
    this-object:time_end:TabIndex = 7.
    /*  */
    /* label2 */
    /*  */
    this-object:label2:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(10), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:label2:Location = new System.Drawing.Point(100, 47).
    this-object:label2:Name = "label2".
    this-object:label2:Size = new System.Drawing.Size(22, 23).
    this-object:label2:TabIndex = 37.
    this-object:label2:Text = "с:".
    this-object:label2:UseCompatibleTextRendering = true.
    /*  */
    /* label3 */
    /*  */
    this-object:label3:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(10), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:label3:Location = new System.Drawing.Point(316, 47).
    this-object:label3:Name = "label3".
    this-object:label3:Size = new System.Drawing.Size(26, 23).
    this-object:label3:TabIndex = 38.
    this-object:label3:Text = "по:".
    this-object:label3:UseCompatibleTextRendering = true.
    /*  */
    /* label4 */
    /*  */
    this-object:label4:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:label4:Location = new System.Drawing.Point(28, 86).
    this-object:label4:Name = "label4".
    this-object:label4:Size = new System.Drawing.Size(59, 23).
    this-object:label4:TabIndex = 39.
    this-object:label4:Text = "Имя ПК:".
    this-object:label4:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
    this-object:label4:UseCompatibleTextRendering = true.
    /*  */
    /* label5 */
    /*  */
    this-object:label5:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:label5:Location = new System.Drawing.Point(28, 114).
    this-object:label5:Name = "label5".
    this-object:label5:Size = new System.Drawing.Size(94, 23).
    this-object:label5:TabIndex = 40.
    this-object:label5:Text = "Модель диска:".
    this-object:label5:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
    this-object:label5:UseCompatibleTextRendering = true.
    /*  */
    /* groupBox1 */
    /*  */
    this-object:groupBox1:Controls:Add(this-object:label7).
    this-object:groupBox1:Controls:Add(this-object:label10).
    this-object:groupBox1:Controls:Add(this-object:attr_type).
    this-object:groupBox1:Controls:Add(this-object:label6).
    this-object:groupBox1:Controls:Add(this-object:attr_name).
    this-object:groupBox1:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(10), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:groupBox1:Location = new System.Drawing.Point(7, 154).
    this-object:groupBox1:Name = "groupBox1".
    this-object:groupBox1:Size = new System.Drawing.Size(622, 130).
    this-object:groupBox1:TabIndex = 41.
    this-object:groupBox1:TabStop = false.
    this-object:groupBox1:Text = "Атрибуты диска:".
    this-object:groupBox1:UseCompatibleTextRendering = true.
    /*  */
    /* label7 */
    /*  */
    this-object:label7:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:label7:Location = new System.Drawing.Point(22, 25).
    this-object:label7:Name = "label7".
    this-object:label7:Size = new System.Drawing.Size(93, 23).
    this-object:label7:TabIndex = 32.
    this-object:label7:Text = "Название:".
    this-object:label7:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
    this-object:label7:UseCompatibleTextRendering = true.
    this-object:label7:UseMnemonic = false.
    /*  */
    /* label10 */
    /*  */
    this-object:label10:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:label10:Location = new System.Drawing.Point(21, 52).
    this-object:label10:Name = "label10".
    this-object:label10:Size = new System.Drawing.Size(94, 23).
    this-object:label10:TabIndex = 31.
    this-object:label10:Text = "Тип:".
    this-object:label10:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
    this-object:label10:UseCompatibleTextRendering = true.
    this-object:label10:UseMnemonic = false.
    /*  */
    /* attr_type */
    /*  */
    this-object:attr_type:Location = new System.Drawing.Point(124, 52).
    this-object:attr_type:Name = "attr_type".
    this-object:attr_type:Size = new System.Drawing.Size(158, 23).
    this-object:attr_type:TabIndex = 11.
    /*  */
    /* label6 */
    /*  */
    define variable nestedvar0 as System.Windows.Forms.AnchorStyles no-undo.
    nestedvar0 = cast(Progress.Util.EnumHelper:Or(cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Bottom), System.Windows.Forms.AnchorStyles), System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
    this-object:label6:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
    this-object:label6:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:label6:Location = new System.Drawing.Point(21, 25).
    this-object:label6:Name = "label6".
    this-object:label6:Size = new System.Drawing.Size(101, 0).
    this-object:label6:TabIndex = 1.
    this-object:label6:Text = "Название:".
    this-object:label6:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
    this-object:label6:UseCompatibleTextRendering = true.
    this-object:label6:UseMnemonic = false.
    /*  */
    /* attr_name */
    /*  */
    this-object:attr_name:Location = new System.Drawing.Point(124, 25).
    this-object:attr_name:Name = "attr_name".
    this-object:attr_name:Size = new System.Drawing.Size(278, 23).
    this-object:attr_name:TabIndex = 10.
    /*  */
    /* report_hdd */
    /*  */
    this-object:ClientSize = new System.Drawing.Size(636, 301).
    this-object:Controls:Add(this-object:groupBox1).
    this-object:Controls:Add(this-object:label5).
    this-object:Controls:Add(this-object:label4).
    this-object:Controls:Add(this-object:label3).
    this-object:Controls:Add(this-object:label2).
    this-object:Controls:Add(this-object:date_end).
    this-object:Controls:Add(this-object:time_end).
    this-object:Controls:Add(this-object:label1).
    this-object:Controls:Add(this-object:b_run).
    this-object:Controls:Add(this-object:b_exit).
    this-object:Controls:Add(this-object:date_start).
    this-object:Controls:Add(this-object:bobj_list).
    this-object:Controls:Add(this-object:obj_list).
    this-object:Controls:Add(this-object:time_start).
    this-object:Controls:Add(this-object:ModelDisk).
    this-object:Controls:Add(this-object:NamePK).
    this-object:Name = "report_hdd".
    this-object:Text = "Результаты проверки HDD".
    this-object:groupBox1:ResumeLayout(false).
    this-object:groupBox1:PerformLayout().
    this-object:ResumeLayout(false).
    this-object:PerformLayout().
    {gbl\ed_date_cls.i this-object:date_start this-object:date_end This-object }
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.
  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void time_start_ValueChanged( input sender as System.Object, input e as System.EventArgs ):
		
    return.

  end method.

  destructor public report_hdd ( ):

  end destructor.

end class.