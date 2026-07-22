 
/*------------------------------------------------------------------------
   File        : BPA_browse
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : eshklyar
   Created     : Tue Dec 18 15:32:11 MSK 2018
   Notes       : 
 ----------------------------------------------------------------------*/



using Progress.Lang.*.
using Progress.Windows.Form.
using System.ComponentModel.RefreshEventHandler from assembly.
using ref.HDD_browse from propath.

block-level on error undo, throw.

class ref.HDD_browse inherits Form: 
  {cmp/str-glbl.i class}
  { gbl/getcntxt.i def }
  { gbl/color.i }
  { cmp/library.i  class }

  define temp-table tt-devicePC no-undo
    field id          as integer
    field modeldevice like ub.devisPC.modeldevice
    field ModelPC     like ub.devisPC.ModelPC
    field namepc      like ub.devisPC.namepc
    field date_       as date
    field time_       as character
    field time_int    as integer
    field ProcDisk    as decimal
    field UserProc    as decimal
    field status_     as character
    field db-num      as integer 
    field ii          as integer
    index pi id db-num asc date_ asc time_int 
    .
  
define temp-table tt-devicePCAttr no-undo
  field id        as integer
  field name_     as character
  field value_    as decimal
  field tresh     as decimal
  field type_     as character
  field raw_value as character
  field date_     as date
  field time_     as integer
  field db-num    as integer
  field ii        as integer
  index pi id db-num date_ time_
  .

  define private variable b_exit                                as System.Windows.Forms.Button                    no-undo.
  define private variable b_print                               as System.Windows.Forms.Button                    no-undo.
  define private variable bindingSource1                        as Progress.Data.BindingSource                    no-undo.
  define private variable bindingSource2                        as Progress.Data.BindingSource                    no-undo.
  define private variable bindingSource3                        as Progress.Data.BindingSource                    no-undo.
  define private variable bobj_list                             as System.Windows.Forms.Button                    no-undo.
  define private variable browseHDD                             as System.Windows.Forms.DataGridView              no-undo.
  define private variable Column1                               as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable components                            as System.ComponentModel.IContainer               no-undo.
  define private variable dataGridViewTextBoxColumn8            as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable dataGridViewTextBoxColumn7            as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable dataGridViewTextBoxColumn6            as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable dataGridViewTextBoxColumn5            as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable dataGridViewTextBoxColumn4            as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable dataGridViewTextBoxColumn3            as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable dataGridViewTextBoxColumn2            as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable dataGridViewTextBoxColumn1            as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable dateDataGridViewTextBoxColumn         as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable dateDataGridViewTextBoxColumn1        as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable delta                                 as System.Windows.Forms.NumericUpDown             no-undo.
  define private variable drowseHDDAttr                         as System.Windows.Forms.DataGridView              no-undo.
  define private variable groupBox1                             as System.Windows.Forms.GroupBox                  no-undo.
  define private variable HDDbrowseGBD                          as System.Windows.Forms.DataGridView              no-undo.
  define private variable label3                                as System.Windows.Forms.Label                     no-undo.
  define private variable label2                                as System.Windows.Forms.Label                     no-undo.
  define private variable label4                                as System.Windows.Forms.Label                     no-undo.
  define private variable label6                                as System.Windows.Forms.Label                     no-undo.
  define private variable label5                                as System.Windows.Forms.Label                     no-undo.
  define private variable lnamePK                               as System.Windows.Forms.Label                     no-undo.
  define private variable lobj_list                             as System.Windows.Forms.Label                     no-undo.
  define private variable lProcDisk                             as System.Windows.Forms.Label                     no-undo.
  define private variable lModelDisk                            as System.Windows.Forms.Label                     no-undo.
  define private variable lsortDate                             as System.Windows.Forms.Label                     no-undo.
  define private variable label1                                as System.Windows.Forms.Label                     no-undo.
  define private variable lUserDisk                             as System.Windows.Forms.Label                     no-undo.
  define private variable lStatus                               as System.Windows.Forms.Label                     no-undo.
  define private variable modeldeviceDataGridViewTextBoxColumn1 as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable ModelDisk                             as System.Windows.Forms.TextBox                   no-undo.
  define private variable modelPCDataGridViewTextBoxColumn1     as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable nameDataGridViewTextBoxColumn         as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable namepcDataGridViewTextBoxColumn       as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable modeldeviceDataGridViewTextBoxColumn  as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable modelPCDataGridViewTextBoxColumn      as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable namepcDataGridViewTextBoxColumn1      as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable NamePK                                as System.Windows.Forms.TextBox                   no-undo.
  define private variable obj_list                              as System.Windows.Forms.TextBox                   no-undo.
  define private variable procDiskDataGridViewTextBoxColumn     as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable procDiskDataGridViewTextBoxColumn1    as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable radioButton3                          as System.Windows.Forms.RadioButton               no-undo.
  define private variable radioButton2                          as System.Windows.Forms.RadioButton               no-undo.
  define private variable radioButton1                          as System.Windows.Forms.RadioButton               no-undo.
  define private variable ProcDisk                              as System.Windows.Forms.NumericUpDown             no-undo.
  define private variable radioButton4 as System.Windows.Forms.RadioButton no-undo.
  define private variable rawvalueDataGridViewTextBoxColumn     as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable sort_date                             as System.Windows.Forms.DateTimePicker            no-undo.
  define private variable sort_time                             as System.Windows.Forms.DateTimePicker            no-undo.
  define private variable pMode                                 as character                                      no-undo .
  define         variable hQuery1                               as handle                                         no-undo .
  define         variable hQuery2                               as handle                                         no-undo .
  define private variable sort_time_end                         as System.Windows.Forms.DateTimePicker            no-undo.
  define private variable statusDataGridViewTextBoxColumn       as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable statusDataGridViewTextBoxColumn1      as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable timeDataGridViewTextBoxColumn         as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable timeDataGridViewTextBoxColumn1        as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable treshDataGridViewTextBoxColumn        as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable TreshDisk                             as System.Windows.Forms.NumericUpDown             no-undo.
  define private variable typeDataGridViewTextBoxColumn         as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable UserDisk                              as System.Windows.Forms.NumericUpDown             no-undo.
  define private variable userProcDataGridViewTextBoxColumn     as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable userProcDataGridViewTextBoxColumn1    as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable valueDataGridViewTextBoxColumn        as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable ValueDisk                             as System.Windows.Forms.NumericUpDown             no-undo.
  
  define         variable v-SortDate                            as date                                           no-undo .
  define         variable v-SortTime                            as integer                                        no-undo .
  define         variable v-SortTime-end                        as integer                                        no-undo .
  define         variable v-SortTimeInt                         as integer                                        no-undo .
  define         variable v-NamePK                              as character                                      no-undo .
  define         variable v-ModelDisk                           as character                                      no-undo .
  define         variable v-ValueDisk                           as decimal                                        no-undo .
  define         variable v-TreshDisk                           as decimal                                        no-undo .
  define         variable v-Delta                               as decimal                                        no-undo .
  define         variable v-ProcDisk                            as decimal                                        no-undo .
  define         variable v-UserDisk                            as decimal                                        no-undo .
  define         variable v-idDisk                              as integer                                        no-undo . 
  define         variable v-status                              as integer                                        no-undo .
  define         variable p-db-num                              as integer                                        no-undo .
  define         variable v-db-list                             as character                                      no-undo .
  define         variable vPos                                  as integer                                        no-undo.

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
  
  constructor public HDD_browse (pdb-num as integer):
    super().
    InitializeComponent().
    Visual_form(pdb-num) .
    p-db-num = pdb-num .
    v-status = -1 .
    this-object:sort_date:Value = today .
    if v-SortDate = ? then v-SortDate = today .
    this-object:sort_time:Value = today .
    this-object:sort_time_end:text = "23:59:59" .
    /*      v-time-start = mtime (p-Time-start) / 1000 .*/
    /*  v-time-end  = mtime (p-Time-end) / 1000 .       */
    if v-SortTime = ? then v-SortTime = time.
    if v-SortTime-end = ? then v-SortTime-end = time.
    v-SortTime = mtime (this-object:sort_time:value) / 1000 .
    v-SortTime-end = mtime (this-object:sort_time_end:value) / 1000 .
    
    if p-db-num <> 0 then bindingSource1:Handle = browse_HDD(v-SortDate, v-SortTime, v-SortTime-end, v-NamePK, v-ModelDisk, v-ProcDisk, v-UserDisk, v-status, v-ValueDisk, v-TreshDisk, v-Delta) no-error .
    else bindingSource3:Handle = browse_HDDGBD(v-SortDate, v-SortTime, v-SortTime-end, v-NamePK, v-ModelDisk, v-ProcDisk, v-UserDisk, v-status, v-ValueDisk, v-TreshDisk, v-Delta) no-error .
    bindingSource2:Handle = browse_HDDattr(v-ValueDisk, v-TreshDisk, v-Delta) no-error.


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
  method private void BPA_browse_Load( input sender as System.Object, input e as System.EventArgs ):
		
    return.

  end method.


  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void browseHDD_CellContentClick( input sender as System.Object, input e as System.Windows.Forms.DataGridViewCellEventArgs ):
		
    return.

  end method.


  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void browseHDD_RowPostPaint( input sender as System.Object, input e as System.Windows.Forms.DataGridViewRowPostPaintEventArgs ):
    define buffer tt-devicePC for tt-devicePC .
    define variable kk as integer no-undo .
      
    for each tt-devicePC:
      tt-devicePC.ii = kk .
      kk = kk + 1.
    end.  
    if e:RowIndex > -1 then 
    do:
      for each tt-devicePC no-lock where tt-devicePC.ii = e:RowIndex and 
        (tt-devicePC.UserProc = 100 or
        tt-devicePC.ProcDisk = 100 or
        tt-devicePC.status_ <> "Пройдена"):
          browseHDD:Rows[e:RowIndex]:DefaultCellStyle:BackColor = System.Drawing.Color:Red.
          browseHDD:Rows[e:RowIndex]:DefaultCellStyle:ForeColor = System.Drawing.Color:White.
      end.  
    end.
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void button1_Click( input sender as System.Object, input e as System.EventArgs ):
		//Выход
    Close().
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
        v-db-list  = ""
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
        v-db-list  = ""
        .
      for each temp_obj-list
        :
        assign
          p-obj-list = p-obj-list + "," + temp_obj-list.obj-type + "," + string( temp_obj-list.obj-code )
          .
        find first ub.clients no-lock where ub.clients.obj-code = userobjs_temp-user-obj.obj-code and ub.clients.obj-type = userobjs_temp-user-obj.obj-type no-error .
        if available (ub.clients) and ub.clients.db-num <> ? then v-db-list = v-db-list + "," + string( ub.clients.db-num).
        else v-db-list = v-db-list + "," + string (temp_obj-list.obj-code) . 
        
 
      end.
      v-db-list = trim (v-db-list,",") .
      p-obj-list = trim (p-obj-list,",") .
    end.    
    this-object:obj_list:Text = string(p-obj-list) .

    bindingSource3:Handle = browse_HDDGBD(v-SortDate, v-SortTime, v-SortTime-end, v-NamePK, v-ModelDisk, v-ProcDisk, v-UserDisk, v-status, v-ValueDisk, v-TreshDisk, v-Delta) no-error .
    bindingSource2:Handle = browse_HDDattr(v-ValueDisk, v-TreshDisk, v-Delta).
    
    return.

  end method.


  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void Click_print( input sender as System.Object, input e as System.EventArgs ):
    
    run rep/hdd-interface.p(input parparentproc,
      input v-NamePK,
      input v-ModelDisk,
      input v-status,
      input v-ProcDisk,
      input v-UserDisk,
      input v-SortDate,
      input v-SortTime,
      input v-SortTime-end,
      input v-db-list,
      input v-ValueDisk,
      input v-TreshDisk,
      input v-Delta) no-error .
		
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void dataGridView1_CellClick( input sender as System.Object, input e as System.Windows.Forms.DataGridViewCellEventArgs ):
    
    bindingSource2:Handle = browse_HDDattr(v-ValueDisk, v-TreshDisk, v-Delta).    
    bindingSource2:Refresh() .
    return.

  end method.


  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void delta_ValueChanged( input sender as System.Object, input e as System.EventArgs ):
    v-Delta = decimal(this-object:delta:Text) .
    if p-db-num <> 0 then bindingSource1:Handle = browse_HDD(v-SortDate, v-SortTime, v-SortTime-end, v-NamePK, v-ModelDisk, v-ProcDisk, v-UserDisk, v-status, v-ValueDisk, v-TreshDisk, v-Delta) no-error .
    else bindingSource3:Handle = browse_HDDGBD(v-SortDate, v-SortTime, v-SortTime-end, v-NamePK, v-ModelDisk, v-ProcDisk, v-UserDisk, v-status, v-ValueDisk, v-TreshDisk, v-Delta) no-error .
    
    bindingSource2:Handle = browse_HDDattr(v-ValueDisk, v-TreshDisk, v-Delta) no-error.
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void drowseHDDAttr_CellPainting( input sender as System.Object, input e as System.Windows.Forms.DataGridViewCellPaintingEventArgs ):
		
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void drowseHDDAttr_CursorChanged( input sender as System.Object, input e as System.EventArgs ):
		
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void drowseHDDAttr_RowPostPaint( input sender as System.Object, input e as System.Windows.Forms.DataGridViewRowPostPaintEventArgs ):
		
    define variable kk as integer no-undo .
    define buffer tt-devicePCAttr for tt-devicePCAttr.
    for each tt-devicePCAttr:
      tt-devicePCAttr.ii = kk .
      kk = kk + 1 .
    end.  
    if e:RowIndex > -1 then 
    do:
      for each tt-devicePCAttr no-lock where tt-devicePCAttr.ii = e:RowIndex and tt-devicePCAttr.value_ <= tt-devicePCAttr.tresh:
        drowseHDDAttr:Rows[e:RowIndex]:DefaultCellStyle:BackColor = System.Drawing.Color:Red.
        drowseHDDAttr:Rows[e:RowIndex]:DefaultCellStyle:ForeColor = System.Drawing.Color:White.
      end.  
    end.
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void enter_NamePK( input sender as System.Object, input e as System.EventArgs ):
    v-NamePK = this-object:NamePK:Text .
    if p-db-num <> 0 then bindingSource1:Handle = browse_HDD(v-SortDate, v-SortTime, v-SortTime-end, v-NamePK, v-ModelDisk, v-ProcDisk, v-UserDisk, v-status, v-ValueDisk, v-TreshDisk, v-Delta) no-error.
    else bindingSource3:Handle = browse_HDDGBD(v-SortDate, v-SortTime, v-SortTime-end, v-NamePK, v-ModelDisk, v-ProcDisk, v-UserDisk, v-status, v-ValueDisk, v-TreshDisk, v-Delta) no-error.

    bindingSource2:Handle = browse_HDDattr(v-ValueDisk, v-TreshDisk, v-Delta).
		
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void groupBox1_Enter( input sender as System.Object, input e as System.EventArgs ):
		
    return.

  end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void HDDbrowseGBD_CellClick( input sender as System.Object, input e as System.Windows.Forms.DataGridViewCellEventArgs ):

    bindingSource2:Handle = browse_HDDattr(v-ValueDisk, v-TreshDisk, v-Delta).    
    bindingSource2:Refresh() .
		return.

	end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void HDDbrowseGBD_CellContentClick( input sender as System.Object, input e as System.Windows.Forms.DataGridViewCellEventArgs ):
		
    return.

  end method.


  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void HDDbrowse_CellPainting( input sender as System.Object, input e as System.Windows.Forms.DataGridViewCellPaintingEventArgs ):

    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void HDDbrowseGBD_RowPostPaint( input sender as System.Object, input e as System.Windows.Forms.DataGridViewRowPostPaintEventArgs ):
    define buffer tt-devicePC for tt-devicePC .
    define variable kk as integer no-undo .

    for each tt-devicePC:
      tt-devicePC.ii = kk .
      kk = kk + 1.
    end.  
    if e:RowIndex > -1 then 
    do:
      for each tt-devicePC no-lock where tt-devicePC.ii = e:RowIndex and 
        (tt-devicePC.UserProc = 100 or
        tt-devicePC.ProcDisk = 100 or
        tt-devicePC.status_ <> "Пройдена"):
          HDDbrowseGBD:Rows[e:RowIndex]:DefaultCellStyle:BackColor = System.Drawing.Color:Red.
          HDDbrowseGBD:Rows[e:RowIndex]:DefaultCellStyle:ForeColor = System.Drawing.Color:White.
  
      end.  
    end.
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void label5_Click( input sender as System.Object, input e as System.EventArgs ):
		
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void leave_ModelDisk( input sender as System.Object, input e as System.EventArgs ):
    v-ModelDisk = this-object:ModelDisk:Text .
    if p-db-num <> 0 then bindingSource1:Handle = browse_HDD(v-SortDate, v-SortTime, v-SortTime-end, v-NamePK, v-ModelDisk, v-ProcDisk, v-UserDisk, v-status, v-ValueDisk, v-TreshDisk, v-Delta) no-error.
    else bindingSource3:Handle = browse_HDDGBD(v-SortDate, v-SortTime, v-SortTime-end, v-NamePK, v-ModelDisk, v-ProcDisk, v-UserDisk, v-status, v-ValueDisk, v-TreshDisk, v-Delta) no-error.

    bindingSource2:Handle = browse_HDDattr(v-ValueDisk, v-TreshDisk, v-Delta) no-error.
    return.

  end method.


  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void leave_NamePK( input sender as System.Object, input e as System.EventArgs ):
    v-NamePK = this-object:NamePK:Text .
    if p-db-num <> 0 then bindingSource1:Handle = browse_HDD(v-SortDate, v-SortTime, v-SortTime-end, v-NamePK, v-ModelDisk, v-ProcDisk, v-UserDisk, v-status, v-ValueDisk, v-TreshDisk, v-Delta) no-error.
    else bindingSource3:Handle = browse_HDDGBD(v-SortDate, v-SortTime, v-SortTime-end, v-NamePK, v-ModelDisk, v-ProcDisk, v-UserDisk, v-status, v-ValueDisk, v-TreshDisk, v-Delta) no-error.

    bindingSource2:Handle = browse_HDDattr(v-ValueDisk, v-TreshDisk, v-Delta) no-error.
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void leave_ProcDisk( input sender as System.Object, input e as System.EventArgs ):

    v-ProcDisk = decimal(this-object:ProcDisk:Text) .
    if p-db-num <> 0 then bindingSource1:Handle = browse_HDD(v-SortDate, v-SortTime, v-SortTime-end, v-NamePK, v-ModelDisk, v-ProcDisk, v-UserDisk, v-status, v-ValueDisk, v-TreshDisk, v-Delta) no-error.
    else bindingSource3:Handle = browse_HDDGBD(v-SortDate, v-SortTime, v-SortTime-end, v-NamePK, v-ModelDisk, v-ProcDisk, v-UserDisk, v-status, v-ValueDisk, v-TreshDisk, v-Delta) no-error.

    bindingSource2:Handle = browse_HDDattr(v-ValueDisk, v-TreshDisk, v-Delta) no-error.
    return.

  end method.


  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void leave_sort_date( input sender as System.Object, input e as System.EventArgs ):
    if date(this-object:sort_date:Value) > date(today) then 
    do:
      message "Дата больше текущей даты."
        view-as alert-box.
      return no-apply .
    end.  
    v-SortDate = date(this-object:sort_date:Text) .
    if p-db-num <> 0 then bindingSource1:Handle = browse_HDD(v-SortDate, v-SortTime, v-SortTime-end, v-NamePK, v-ModelDisk, v-ProcDisk, v-UserDisk, v-status, v-ValueDisk, v-TreshDisk, v-Delta) no-error.
    else bindingSource3:Handle = browse_HDDGBD(v-SortDate, v-SortTime, v-SortTime-end, v-NamePK, v-ModelDisk, v-ProcDisk, v-UserDisk, v-status, v-ValueDisk, v-TreshDisk, v-Delta) no-error.

    bindingSource2:Handle = browse_HDDattr(v-ValueDisk, v-TreshDisk, v-Delta) no-error.
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void leave_sort_time( input sender as System.Object, input e as System.EventArgs ):
    v-SortTime = mtime (this-object:sort_time:value) / 1000 . 
    if p-db-num <> 0 then bindingSource1:Handle = browse_HDD(v-SortDate, v-SortTime, v-SortTime-end, v-NamePK, v-ModelDisk, v-ProcDisk, v-UserDisk, v-status, v-ValueDisk, v-TreshDisk, v-Delta) no-error .
    else bindingSource3:Handle = browse_HDDGBD(v-SortDate, v-SortTime, v-SortTime-end, v-NamePK, v-ModelDisk, v-ProcDisk, v-UserDisk, v-status, v-ValueDisk, v-TreshDisk, v-Delta) no-error .
    
    bindingSource2:Handle = browse_HDDattr(v-ValueDisk, v-TreshDisk, v-Delta) no-error.
  
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void leave_Tresh( input sender as System.Object, input e as System.EventArgs ):
    v-TreshDisk = decimal(this-object:TreshDisk:Text) .
    if p-db-num <> 0 then bindingSource1:Handle = browse_HDD(v-SortDate, v-SortTime, v-SortTime-end, v-NamePK, v-ModelDisk, v-ProcDisk, v-UserDisk, v-status, v-ValueDisk, v-TreshDisk, v-Delta) no-error .
    else bindingSource3:Handle = browse_HDDGBD(v-SortDate, v-SortTime, v-SortTime-end, v-NamePK, v-ModelDisk, v-ProcDisk, v-UserDisk, v-status, v-ValueDisk, v-TreshDisk, v-Delta) no-error .
    
    bindingSource2:Handle = browse_HDDattr(v-ValueDisk, v-TreshDisk, v-Delta) no-error.
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void leave_UserDisk( input sender as System.Object, input e as System.EventArgs ):
    v-UserDisk = decimal(this-object:UserDisk:Text) .
    if p-db-num <> 0 then bindingSource1:Handle = browse_HDD(v-SortDate, v-SortTime, v-SortTime-end, v-NamePK, v-ModelDisk, v-ProcDisk, v-UserDisk, v-status, v-ValueDisk, v-TreshDisk, v-Delta) no-error.
    else bindingSource3:Handle = browse_HDDGBD(v-SortDate, v-SortTime, v-SortTime-end, v-NamePK, v-ModelDisk, v-ProcDisk, v-UserDisk, v-status, v-ValueDisk, v-TreshDisk, v-Delta) no-error.

    bindingSource2:Handle = browse_HDDattr(v-ValueDisk, v-TreshDisk, v-Delta) no-error.
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void leave_Value( input sender as System.Object, input e as System.EventArgs ):
    v-ValueDisk = decimal(this-object:ValueDisk:Text) .
    if p-db-num <> 0 then bindingSource1:Handle = browse_HDD(v-SortDate, v-SortTime, v-SortTime-end, v-NamePK, v-ModelDisk, v-ProcDisk, v-UserDisk, v-status, v-ValueDisk, v-TreshDisk, v-Delta) no-error .
    else bindingSource3:Handle = browse_HDDGBD(v-SortDate, v-SortTime, v-SortTime-end, v-NamePK, v-ModelDisk, v-ProcDisk, v-UserDisk, v-status, v-ValueDisk, v-TreshDisk, v-Delta) no-error .
    
    bindingSource2:Handle = browse_HDDattr(v-ValueDisk, v-TreshDisk, v-Delta) no-error.
    return.

  end method.


  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void InitializeComponent(  ):
    
    /* NOTE: The following method is automatically generated.
    
    We strongly suggest that the contents of this method only be modified using the
    Visual Designer to avoid any incompatible modifications.
    
    Modifying the contents of this method using a code editor will invalidate any support for this file. */
    this-object:components = new System.ComponentModel.Container().
    @VisualDesigner.FormMember (NeedsInitialize="true").
    define variable tableDesc1 as Progress.Data.TableDesc no-undo.
    tableDesc1 = new Progress.Data.TableDesc("tt-devicePC").
    @VisualDesigner.FormMember (NeedsInitialize="true").
    define variable resources as Progress.Util.ResourceManager no-undo.
    resources = new Progress.Util.ResourceManager("ref.HDD_browse").
    @VisualDesigner.FormMember (NeedsInitialize="true").
    define variable tableDesc2 as Progress.Data.TableDesc no-undo.
    tableDesc2 = new Progress.Data.TableDesc("tt-devicePCAttr").
    @VisualDesigner.FormMember (NeedsInitialize="true").
    define variable tableDesc3 as Progress.Data.TableDesc no-undo.
    tableDesc3 = new Progress.Data.TableDesc("tt-devicePC").
    this-object:bindingSource1 = new Progress.Data.BindingSource(this-object:components).
    this-object:browseHDD = new System.Windows.Forms.DataGridView().
    this-object:dateDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:timeDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:namepcDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:modelPCDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:modeldeviceDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:procDiskDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:userProcDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:statusDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:b_exit = new System.Windows.Forms.Button().
    this-object:groupBox1 = new System.Windows.Forms.GroupBox().
    this-object:label6 = new System.Windows.Forms.Label().
    this-object:label5 = new System.Windows.Forms.Label().
    this-object:sort_time_end = new System.Windows.Forms.DateTimePicker().
    this-object:sort_time = new System.Windows.Forms.DateTimePicker().
    this-object:sort_date = new System.Windows.Forms.DateTimePicker().
    this-object:b_print = new System.Windows.Forms.Button().
    this-object:UserDisk = new System.Windows.Forms.NumericUpDown().
    this-object:lUserDisk = new System.Windows.Forms.Label().
    this-object:ProcDisk = new System.Windows.Forms.NumericUpDown().
    this-object:lProcDisk = new System.Windows.Forms.Label().
    this-object:lModelDisk = new System.Windows.Forms.Label().
    this-object:ModelDisk = new System.Windows.Forms.TextBox().
    this-object:lnamePK = new System.Windows.Forms.Label().
    this-object:NamePK = new System.Windows.Forms.TextBox().
    this-object:label1 = new System.Windows.Forms.Label().
    this-object:lsortDate = new System.Windows.Forms.Label().
    this-object:label4 = new System.Windows.Forms.Label().
    this-object:delta = new System.Windows.Forms.NumericUpDown().
    this-object:label3 = new System.Windows.Forms.Label().
    this-object:ValueDisk = new System.Windows.Forms.NumericUpDown().
    this-object:label2 = new System.Windows.Forms.Label().
    this-object:TreshDisk = new System.Windows.Forms.NumericUpDown().
    this-object:lStatus = new System.Windows.Forms.Label().
    this-object:radioButton3 = new System.Windows.Forms.RadioButton().
    this-object:radioButton2 = new System.Windows.Forms.RadioButton().
    this-object:radioButton1 = new System.Windows.Forms.RadioButton().
    this-object:drowseHDDAttr = new System.Windows.Forms.DataGridView().
    this-object:nameDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:valueDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:treshDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:typeDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:rawvalueDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:bindingSource2 = new Progress.Data.BindingSource(this-object:components).
    this-object:obj_list = new System.Windows.Forms.TextBox().
    this-object:lobj_list = new System.Windows.Forms.Label().
    this-object:bobj_list = new System.Windows.Forms.Button().
    this-object:bindingSource3 = new Progress.Data.BindingSource(this-object:components).
    this-object:HDDbrowseGBD = new System.Windows.Forms.DataGridView().
    this-object:Column1 = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:dataGridViewTextBoxColumn1 = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:dataGridViewTextBoxColumn2 = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:dataGridViewTextBoxColumn3 = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:dataGridViewTextBoxColumn4 = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:dataGridViewTextBoxColumn5 = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:dataGridViewTextBoxColumn6 = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:dataGridViewTextBoxColumn7 = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:dataGridViewTextBoxColumn8 = new System.Windows.Forms.DataGridViewTextBoxColumn().
    this-object:radioButton4 = new System.Windows.Forms.RadioButton().
    cast(this-object:bindingSource1, System.ComponentModel.ISupportInitialize):BeginInit().
    cast(this-object:browseHDD, System.ComponentModel.ISupportInitialize):BeginInit().
    this-object:groupBox1:SuspendLayout().
    cast(this-object:UserDisk, System.ComponentModel.ISupportInitialize):BeginInit().
    cast(this-object:ProcDisk, System.ComponentModel.ISupportInitialize):BeginInit().
    cast(this-object:delta, System.ComponentModel.ISupportInitialize):BeginInit().
    cast(this-object:ValueDisk, System.ComponentModel.ISupportInitialize):BeginInit().
    cast(this-object:TreshDisk, System.ComponentModel.ISupportInitialize):BeginInit().
    cast(this-object:drowseHDDAttr, System.ComponentModel.ISupportInitialize):BeginInit().
    cast(this-object:bindingSource2, System.ComponentModel.ISupportInitialize):BeginInit().
    cast(this-object:bindingSource3, System.ComponentModel.ISupportInitialize):BeginInit().
    cast(this-object:HDDbrowseGBD, System.ComponentModel.ISupportInitialize):BeginInit().
    this-object:SuspendLayout().
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
    define variable arrayvar1 as Progress.Data.ColumnPropDesc extent 8 no-undo.
    arrayvar1[1] = new Progress.Data.ColumnPropDesc("modeldevice", "Модель диска", Progress.Data.DataType:CHARACTER).
    arrayvar1[2] = new Progress.Data.ColumnPropDesc("ModelPC", "Модель ПК", Progress.Data.DataType:CHARACTER).
    arrayvar1[3] = new Progress.Data.ColumnPropDesc("namepc", "Имя ПК", Progress.Data.DataType:CHARACTER).
    arrayvar1[4] = new Progress.Data.ColumnPropDesc("date_", "Дата теста", Progress.Data.DataType:DATE).
    arrayvar1[5] = new Progress.Data.ColumnPropDesc("time_", "Время теста", Progress.Data.DataType:CHARACTER).
    arrayvar1[6] = new Progress.Data.ColumnPropDesc("ProcDisk", "% заполнения диска", Progress.Data.DataType:DECIMAL).
    arrayvar1[7] = new Progress.Data.ColumnPropDesc("UserProc", "Использование системного раздела, %", Progress.Data.DataType:DECIMAL).
    arrayvar1[8] = new Progress.Data.ColumnPropDesc("status_", "Статус проверки", Progress.Data.DataType:CHARACTER).
    tableDesc1:Columns = arrayvar1.
    this-object:bindingSource1:TableSchema = tableDesc1.
    /*  */
    /* browseHDD */
    /*  */
    this-object:browseHDD:AllowUserToAddRows = false.
    this-object:browseHDD:AllowUserToDeleteRows = false.
    this-object:browseHDD:AllowUserToOrderColumns = true.
    this-object:browseHDD:AllowUserToResizeRows = false.
    this-object:browseHDD:AutoGenerateColumns = false.
    this-object:browseHDD:AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode:Fill.
    this-object:browseHDD:BorderStyle = System.Windows.Forms.BorderStyle:None.
    this-object:browseHDD:ClipboardCopyMode = System.Windows.Forms.DataGridViewClipboardCopyMode:Disable.
    this-object:browseHDD:ColumnHeadersBorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle:Single.
    this-object:browseHDD:ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode:AutoSize.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar2 as System.Windows.Forms.DataGridViewColumn extent 8 no-undo.
    arrayvar2[1] = this-object:dateDataGridViewTextBoxColumn.
    arrayvar2[2] = this-object:timeDataGridViewTextBoxColumn.
    arrayvar2[3] = this-object:namepcDataGridViewTextBoxColumn.
    arrayvar2[4] = this-object:modelPCDataGridViewTextBoxColumn.
    arrayvar2[5] = this-object:modeldeviceDataGridViewTextBoxColumn.
    arrayvar2[6] = this-object:procDiskDataGridViewTextBoxColumn.
    arrayvar2[7] = this-object:userProcDataGridViewTextBoxColumn.
    arrayvar2[8] = this-object:statusDataGridViewTextBoxColumn.
    this-object:browseHDD:Columns:AddRange(arrayvar2).
    this-object:browseHDD:DataSource = this-object:bindingSource1.
    this-object:browseHDD:EnableHeadersVisualStyles = false.
    this-object:browseHDD:ImeMode = System.Windows.Forms.ImeMode:NoControl.
    this-object:browseHDD:Location = new System.Drawing.Point(5, 134).
    this-object:browseHDD:MultiSelect = false.
    this-object:browseHDD:Name = "browseHDD".
    this-object:browseHDD:ReadOnly = true.
    this-object:browseHDD:RightToLeft = System.Windows.Forms.RightToLeft:No.
    this-object:browseHDD:RowHeadersVisible = false.
    this-object:browseHDD:ScrollBars = System.Windows.Forms.ScrollBars:Vertical.
    this-object:browseHDD:SelectionMode = System.Windows.Forms.DataGridViewSelectionMode:FullRowSelect.
    this-object:browseHDD:Size = new System.Drawing.Size(828, 196).
    this-object:browseHDD:TabIndex = 13.
    this-object:browseHDD:CellClick:Subscribe(this-object:dataGridView1_CellClick).
    this-object:browseHDD:CellContentClick:Subscribe(this-object:browseHDD_CellContentClick).
    this-object:browseHDD:RowPostPaint:Subscribe(this-object:browseHDD_RowPostPaint).
    /*  */
    /* dateDataGridViewTextBoxColumn */
    /*  */
    this-object:dateDataGridViewTextBoxColumn:DataPropertyName = "date_".
    this-object:dateDataGridViewTextBoxColumn:HeaderText = "Дата теста".
    this-object:dateDataGridViewTextBoxColumn:Name = "dateDataGridViewTextBoxColumn".
    this-object:dateDataGridViewTextBoxColumn:ReadOnly = true.
    /*  */
    /* timeDataGridViewTextBoxColumn */
    /*  */
    this-object:timeDataGridViewTextBoxColumn:DataPropertyName = "time_".
    this-object:timeDataGridViewTextBoxColumn:HeaderText = "Время теста".
    this-object:timeDataGridViewTextBoxColumn:Name = "timeDataGridViewTextBoxColumn".
    this-object:timeDataGridViewTextBoxColumn:ReadOnly = true.
    /*  */
    /* namepcDataGridViewTextBoxColumn */
    /*  */
    this-object:namepcDataGridViewTextBoxColumn:DataPropertyName = "namepc".
    this-object:namepcDataGridViewTextBoxColumn:HeaderText = "Имя ПК".
    this-object:namepcDataGridViewTextBoxColumn:Name = "namepcDataGridViewTextBoxColumn".
    this-object:namepcDataGridViewTextBoxColumn:ReadOnly = true.
    /*  */
    /* modelPCDataGridViewTextBoxColumn */
    /*  */
    this-object:modelPCDataGridViewTextBoxColumn:DataPropertyName = "ModelPC".
    this-object:modelPCDataGridViewTextBoxColumn:HeaderText = "Модель ПК".
    this-object:modelPCDataGridViewTextBoxColumn:Name = "modelPCDataGridViewTextBoxColumn".
    this-object:modelPCDataGridViewTextBoxColumn:ReadOnly = true.
    /*  */
    /* modeldeviceDataGridViewTextBoxColumn */
    /*  */
    this-object:modeldeviceDataGridViewTextBoxColumn:DataPropertyName = "modeldevice".
    this-object:modeldeviceDataGridViewTextBoxColumn:HeaderText = "Модель диска".
    this-object:modeldeviceDataGridViewTextBoxColumn:Name = "modeldeviceDataGridViewTextBoxColumn".
    this-object:modeldeviceDataGridViewTextBoxColumn:ReadOnly = true.
    /*  */
    /* procDiskDataGridViewTextBoxColumn */
    /*  */
    this-object:procDiskDataGridViewTextBoxColumn:DataPropertyName = "ProcDisk".
    this-object:procDiskDataGridViewTextBoxColumn:HeaderText = "% заполнения диска".
    this-object:procDiskDataGridViewTextBoxColumn:Name = "procDiskDataGridViewTextBoxColumn".
    this-object:procDiskDataGridViewTextBoxColumn:ReadOnly = true.
    /*  */
    /* userProcDataGridViewTextBoxColumn */
    /*  */
    this-object:userProcDataGridViewTextBoxColumn:DataPropertyName = "UserProc".
    this-object:userProcDataGridViewTextBoxColumn:HeaderText = "Использование системного раздела, %".
    this-object:userProcDataGridViewTextBoxColumn:Name = "userProcDataGridViewTextBoxColumn".
    this-object:userProcDataGridViewTextBoxColumn:ReadOnly = true.
    /*  */
    /* statusDataGridViewTextBoxColumn */
    /*  */
    this-object:statusDataGridViewTextBoxColumn:DataPropertyName = "status_".
    this-object:statusDataGridViewTextBoxColumn:HeaderText = "Статус проверки".
    this-object:statusDataGridViewTextBoxColumn:Name = "statusDataGridViewTextBoxColumn".
    this-object:statusDataGridViewTextBoxColumn:ReadOnly = true.
    /*  */
    /* b_exit */
    /*  */
    this-object:b_exit:FlatStyle = System.Windows.Forms.FlatStyle:Popup.
    this-object:b_exit:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(10), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:b_exit:Location = new System.Drawing.Point(7, 17).
    this-object:b_exit:Name = "b_exit".
    this-object:b_exit:Size = new System.Drawing.Size(94, 23).
    this-object:b_exit:TabIndex = 14.
    this-object:b_exit:Text = "Выход".
    this-object:b_exit:UseCompatibleTextRendering = true.
    this-object:b_exit:UseVisualStyleBackColor = true.
    this-object:b_exit:Click:Subscribe(this-object:button1_Click).
    /*  */
    /* groupBox1 */
    /*  */
    this-object:groupBox1:Controls:Add(this-object:label6).
    this-object:groupBox1:Controls:Add(this-object:label5).
    this-object:groupBox1:Controls:Add(this-object:sort_time_end).
    this-object:groupBox1:Controls:Add(this-object:sort_time).
    this-object:groupBox1:Controls:Add(this-object:sort_date).
    this-object:groupBox1:Controls:Add(this-object:b_print).
    this-object:groupBox1:Controls:Add(this-object:UserDisk).
    this-object:groupBox1:Controls:Add(this-object:b_exit).
    this-object:groupBox1:Controls:Add(this-object:lUserDisk).
    this-object:groupBox1:Controls:Add(this-object:ProcDisk).
    this-object:groupBox1:Controls:Add(this-object:lProcDisk).
    this-object:groupBox1:Controls:Add(this-object:lModelDisk).
    this-object:groupBox1:Controls:Add(this-object:ModelDisk).
    this-object:groupBox1:Controls:Add(this-object:lnamePK).
    this-object:groupBox1:Controls:Add(this-object:NamePK).
    this-object:groupBox1:Controls:Add(this-object:label1).
    this-object:groupBox1:Controls:Add(this-object:lsortDate).
    this-object:groupBox1:FlatStyle = System.Windows.Forms.FlatStyle:Popup.
    this-object:groupBox1:Location = new System.Drawing.Point(5, -6).
    this-object:groupBox1:Name = "groupBox1".
    this-object:groupBox1:Size = new System.Drawing.Size(828, 109).
    this-object:groupBox1:TabIndex = 22.
    this-object:groupBox1:TabStop = false.
    this-object:groupBox1:UseCompatibleTextRendering = true.
    this-object:groupBox1:Enter:Subscribe(this-object:groupBox1_Enter).
    /*  */
    /* label6 */
    /*  */
    this-object:label6:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:label6:Location = new System.Drawing.Point(218, 75).
    this-object:label6:Name = "label6".
    this-object:label6:Size = new System.Drawing.Size(23, 23).
    this-object:label6:TabIndex = 17.
    this-object:label6:Text = "по:".
    this-object:label6:UseCompatibleTextRendering = true.
    /*  */
    /* label5 */
    /*  */
    this-object:label5:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:label5:Location = new System.Drawing.Point(117, 75).
    this-object:label5:Name = "label5".
    this-object:label5:Size = new System.Drawing.Size(16, 23).
    this-object:label5:TabIndex = 16.
    this-object:label5:Text = "с:".
    this-object:label5:UseCompatibleTextRendering = true.
    this-object:label5:Click:Subscribe(this-object:label5_Click).
    /*  */
    /* sort_time_end */
    /*  */
    this-object:sort_time_end:AllowDrop = true.
    this-object:sort_time_end:DropDownAlign = System.Windows.Forms.LeftRightAlignment:Right.
    this-object:sort_time_end:Format = System.Windows.Forms.DateTimePickerFormat:Time.
    this-object:sort_time_end:Location = new System.Drawing.Point(242, 75).
    this-object:sort_time_end:Name = "sort_time_end".
    this-object:sort_time_end:ShowUpDown = true.
    this-object:sort_time_end:Size = new System.Drawing.Size(75, 21).
    this-object:sort_time_end:TabIndex = 5.
    this-object:sort_time_end:Leave:Subscribe(this-object:sort_time_end_Leave).
    /*  */
    /* sort_time */
    /*  */
    this-object:sort_time:AllowDrop = true.
    this-object:sort_time:DropDownAlign = System.Windows.Forms.LeftRightAlignment:Right.
    this-object:sort_time:Format = System.Windows.Forms.DateTimePickerFormat:Time.
    this-object:sort_time:Location = new System.Drawing.Point(137, 75).
    this-object:sort_time:Name = "sort_time".
    this-object:sort_time:ShowUpDown = true.
    this-object:sort_time:Size = new System.Drawing.Size(75, 21).
    this-object:sort_time:TabIndex = 4.
    this-object:sort_time:Leave:Subscribe(this-object:leave_sort_time).
    /*  */
    /* sort_date */
    /*  */
    this-object:sort_date:Format = System.Windows.Forms.DateTimePickerFormat:Short.
    this-object:sort_date:Location = new System.Drawing.Point(175, 48).
    this-object:sort_date:Name = "sort_date".
    this-object:sort_date:Size = new System.Drawing.Size(109, 21).
    this-object:sort_date:TabIndex = 3.
    this-object:sort_date:Value = Progress.Util.DateTimeHelper:Create(2019, 9, 16, 0, 0, 0, 0).
    this-object:sort_date:Leave:Subscribe(this-object:leave_sort_date).
    /*  */
    /* b_print */
    /*  */
    this-object:b_print:Image = cast(resources:GetObject("b_print.Image"), System.Drawing.Image).
    this-object:b_print:Location = new System.Drawing.Point(798, 17).
    this-object:b_print:Name = "b_print".
    this-object:b_print:Size = new System.Drawing.Size(25, 21).
    this-object:b_print:TabIndex = 13.
    this-object:b_print:UseCompatibleTextRendering = true.
    this-object:b_print:UseVisualStyleBackColor = true.
    this-object:b_print:Click:Subscribe(this-object:Click_print).
    /*  */
    /* UserDisk */
    /*  */
    this-object:UserDisk:Location = new System.Drawing.Point(756, 77).
    this-object:UserDisk:Name = "UserDisk".
    this-object:UserDisk:Size = new System.Drawing.Size(67, 21).
    this-object:UserDisk:TabIndex = 9.
    this-object:UserDisk:ValueChanged:Subscribe(this-object:leave_UserDisk).
    this-object:UserDisk:Enter:Subscribe(this-object:leave_UserDisk).
    this-object:UserDisk:Leave:Subscribe(this-object:leave_UserDisk).
    /*  */
    /* lUserDisk */
    /*  */
    this-object:lUserDisk:FlatStyle = System.Windows.Forms.FlatStyle:Popup.
    this-object:lUserDisk:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:lUserDisk:Location = new System.Drawing.Point(616, 77).
    this-object:lUserDisk:Name = "lUserDisk".
    this-object:lUserDisk:Size = new System.Drawing.Size(136, 23).
    this-object:lUserDisk:TabIndex = 11.
    this-object:lUserDisk:Text = "% исп. сист. раздела:".
    this-object:lUserDisk:UseCompatibleTextRendering = true.
    /*  */
    /* ProcDisk */
    /*  */
    this-object:ProcDisk:Location = new System.Drawing.Point(756, 48).
    this-object:ProcDisk:Name = "ProcDisk".
    this-object:ProcDisk:Size = new System.Drawing.Size(67, 21).
    this-object:ProcDisk:TabIndex = 8.
    this-object:ProcDisk:ValueChanged:Subscribe(this-object:leave_ProcDisk).
    this-object:ProcDisk:Enter:Subscribe(this-object:leave_ProcDisk).
    this-object:ProcDisk:Leave:Subscribe(this-object:leave_ProcDisk).
    /*  */
    /* lProcDisk */
    /*  */
    this-object:lProcDisk:FlatStyle = System.Windows.Forms.FlatStyle:Popup.
    this-object:lProcDisk:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:lProcDisk:Location = new System.Drawing.Point(616, 48).
    this-object:lProcDisk:Name = "lProcDisk".
    this-object:lProcDisk:Size = new System.Drawing.Size(136, 23).
    this-object:lProcDisk:TabIndex = 8.
    this-object:lProcDisk:Text = "% заполнения диска:".
    this-object:lProcDisk:UseCompatibleTextRendering = true.
    /*  */
    /* lModelDisk */
    /*  */
    this-object:lModelDisk:FlatStyle = System.Windows.Forms.FlatStyle:Popup.
    this-object:lModelDisk:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:lModelDisk:Location = new System.Drawing.Point(326, 75).
    this-object:lModelDisk:Name = "lModelDisk".
    this-object:lModelDisk:Size = new System.Drawing.Size(95, 23).
    this-object:lModelDisk:TabIndex = 7.
    this-object:lModelDisk:Text = "Модель диска:".
    this-object:lModelDisk:UseCompatibleTextRendering = true.
    /*  */
    /* ModelDisk */
    /*  */
    this-object:ModelDisk:Location = new System.Drawing.Point(426, 75).
    this-object:ModelDisk:Name = "ModelDisk".
    this-object:ModelDisk:Size = new System.Drawing.Size(184, 21).
    this-object:ModelDisk:TabIndex = 7.
    this-object:ModelDisk:TextChanged:Subscribe(this-object:leave_ModelDisk).
    this-object:ModelDisk:Enter:Subscribe(this-object:leave_ModelDisk).
    this-object:ModelDisk:Leave:Subscribe(this-object:leave_ModelDisk).
    /*  */
    /* lnamePK */
    /*  */
    this-object:lnamePK:FlatStyle = System.Windows.Forms.FlatStyle:Popup.
    this-object:lnamePK:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:lnamePK:Location = new System.Drawing.Point(326, 48).
    this-object:lnamePK:Name = "lnamePK".
    this-object:lnamePK:Size = new System.Drawing.Size(95, 23).
    this-object:lnamePK:TabIndex = 5.
    this-object:lnamePK:Text = "Имя ПК:".
    this-object:lnamePK:UseCompatibleTextRendering = true.
    /*  */
    /* NamePK */
    /*  */
    this-object:NamePK:Location = new System.Drawing.Point(426, 48).
    this-object:NamePK:Name = "NamePK".
    this-object:NamePK:Size = new System.Drawing.Size(184, 21).
    this-object:NamePK:TabIndex = 6.
    this-object:NamePK:TextChanged:Subscribe(this-object:leave_NamePK).
    this-object:NamePK:Enter:Subscribe(this-object:enter_NamePK).
    this-object:NamePK:Leave:Subscribe(this-object:leave_NamePK).
    /*  */
    /* label1 */
    /*  */
    this-object:label1:FlatStyle = System.Windows.Forms.FlatStyle:Popup.
    this-object:label1:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:label1:Location = new System.Drawing.Point(6, 75).
    this-object:label1:Name = "label1".
    this-object:label1:Size = new System.Drawing.Size(105, 23).
    this-object:label1:TabIndex = 3.
    this-object:label1:Text = "Время проверки".
    this-object:label1:UseCompatibleTextRendering = true.
    /*  */
    /* lsortDate */
    /*  */
    this-object:lsortDate:FlatStyle = System.Windows.Forms.FlatStyle:Popup.
    this-object:lsortDate:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:lsortDate:Location = new System.Drawing.Point(68, 48).
    this-object:lsortDate:Name = "lsortDate".
    this-object:lsortDate:Size = new System.Drawing.Size(100, 23).
    this-object:lsortDate:TabIndex = 1.
    this-object:lsortDate:Text = "Дата проверки:".
    this-object:lsortDate:UseCompatibleTextRendering = true.
    /*  */
    /* label4 */
    /*  */
    this-object:label4:FlatStyle = System.Windows.Forms.FlatStyle:Popup.
    this-object:label4:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:label4:Location = new System.Drawing.Point(409, 344).
    this-object:label4:Name = "label4".
    this-object:label4:Size = new System.Drawing.Size(51, 23).
    this-object:label4:TabIndex = 32.
    this-object:label4:Text = "Delta:".
    this-object:label4:TextAlign = System.Drawing.ContentAlignment:MiddleCenter.
    this-object:label4:UseCompatibleTextRendering = true.
    /*  */
    /* delta */
    /*  */
    this-object:delta:Location = new System.Drawing.Point(463, 346).
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true", Type="System.Int32").
    define variable arrayvar3 as INTEGER extent 4 no-undo.
    arrayvar3[1] = -1981284353.
    arrayvar3[2] = -1966660860.
    arrayvar3[3] = 0.
    arrayvar3[4] = 0.
    this-object:delta:Maximum = Progress.Util.DecimalHelper:Create(arrayvar3).
    this-object:delta:Name = "delta".
    this-object:delta:Size = new System.Drawing.Size(70, 21).
    this-object:delta:TabIndex = 0.
    this-object:delta:ValueChanged:Subscribe(this-object:delta_ValueChanged).
    /*  */
    /* label3 */
    /*  */
    this-object:label3:FlatStyle = System.Windows.Forms.FlatStyle:Popup.
    this-object:label3:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:label3:Location = new System.Drawing.Point(558, 344).
    this-object:label3:Name = "label3".
    this-object:label3:Size = new System.Drawing.Size(51, 23).
    this-object:label3:TabIndex = 30.
    this-object:label3:Text = "Value:".
    this-object:label3:TextAlign = System.Drawing.ContentAlignment:MiddleCenter.
    this-object:label3:UseCompatibleTextRendering = true.
    /*  */
    /* ValueDisk */
    /*  */
    this-object:ValueDisk:Location = new System.Drawing.Point(617, 346).
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true", Type="System.Int32").
    define variable arrayvar4 as INTEGER extent 4 no-undo.
    arrayvar4[1] = 1874919423.
    arrayvar4[2] = 2328306.
    arrayvar4[3] = 0.
    arrayvar4[4] = 0.
    this-object:ValueDisk:Maximum = Progress.Util.DecimalHelper:Create(arrayvar4).
    this-object:ValueDisk:Name = "ValueDisk".
    this-object:ValueDisk:Size = new System.Drawing.Size(70, 21).
    this-object:ValueDisk:TabIndex = 1.
    this-object:ValueDisk:ValueChanged:Subscribe(this-object:leave_Value).
    this-object:ValueDisk:Enter:Subscribe(this-object:leave_Value).
    this-object:ValueDisk:Leave:Subscribe(this-object:leave_Value).
    /*  */
    /* label2 */
    /*  */
    this-object:label2:FlatStyle = System.Windows.Forms.FlatStyle:Popup.
    this-object:label2:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:label2:Location = new System.Drawing.Point(709, 344).
    this-object:label2:Name = "label2".
    this-object:label2:Size = new System.Drawing.Size(51, 23).
    this-object:label2:TabIndex = 28.
    this-object:label2:Text = "Thresh:".
    this-object:label2:TextAlign = System.Drawing.ContentAlignment:MiddleCenter.
    this-object:label2:UseCompatibleTextRendering = true.
    /*  */
    /* TreshDisk */
    /*  */
    this-object:TreshDisk:Location = new System.Drawing.Point(762, 346).
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true", Type="System.Int32").
    define variable arrayvar5 as INTEGER extent 4 no-undo.
    arrayvar5[1] = -159383553.
    arrayvar5[2] = 46653770.
    arrayvar5[3] = 5421.
    arrayvar5[4] = 0.
    this-object:TreshDisk:Maximum = Progress.Util.DecimalHelper:Create(arrayvar5).
    this-object:TreshDisk:Name = "TreshDisk".
    this-object:TreshDisk:Size = new System.Drawing.Size(70, 21).
    this-object:TreshDisk:TabIndex = 2.
    this-object:TreshDisk:ValueChanged:Subscribe(this-object:leave_Tresh).
    this-object:TreshDisk:Enter:Subscribe(this-object:leave_Tresh).
    this-object:TreshDisk:Leave:Subscribe(this-object:leave_Tresh).
    /*  */
    /* lStatus */
    /*  */
    this-object:lStatus:FlatStyle = System.Windows.Forms.FlatStyle:Popup.
    this-object:lStatus:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:lStatus:Location = new System.Drawing.Point(376, 106).
    this-object:lStatus:Name = "lStatus".
    this-object:lStatus:Size = new System.Drawing.Size(122, 23).
    this-object:lStatus:TabIndex = 26.
    this-object:lStatus:Text = "Статус проверки:".
    this-object:lStatus:TextAlign = System.Drawing.ContentAlignment:MiddleCenter.
    this-object:lStatus:UseCompatibleTextRendering = true.
    /*  */
    /* radioButton3 */
    /*  */
    this-object:radioButton3:FlatStyle = System.Windows.Forms.FlatStyle:Popup.
    this-object:radioButton3:Location = new System.Drawing.Point(743, 106).
    this-object:radioButton3:Name = "radioButton3".
    this-object:radioButton3:Size = new System.Drawing.Size(69, 24).
    this-object:radioButton3:TabIndex = 13.
    this-object:radioButton3:Text = "Ошибка".
    this-object:radioButton3:UseCompatibleTextRendering = true.
    this-object:radioButton3:UseVisualStyleBackColor = true.
    this-object:radioButton3:CheckedChanged:Subscribe(this-object:r_status_Checked).
    /*  */
    /* radioButton2 */
    /*  */
    this-object:radioButton2:FlatStyle = System.Windows.Forms.FlatStyle:Popup.
    this-object:radioButton2:Location = new System.Drawing.Point(550, 106).
    this-object:radioButton2:Name = "radioButton2".
    this-object:radioButton2:Size = new System.Drawing.Size(83, 24).
    this-object:radioButton2:TabIndex = 12.
    this-object:radioButton2:Text = "Пройдена".
    this-object:radioButton2:UseCompatibleTextRendering = true.
    this-object:radioButton2:UseVisualStyleBackColor = true.
    this-object:radioButton2:CheckedChanged:Subscribe(this-object:r_status_Checked).
    /*  */
    /* radioButton1 */
    /*  */
    this-object:radioButton1:Checked = true.
    this-object:radioButton1:FlatStyle = System.Windows.Forms.FlatStyle:Popup.
    this-object:radioButton1:Location = new System.Drawing.Point(499, 106).
    this-object:radioButton1:Name = "radioButton1".
    this-object:radioButton1:Size = new System.Drawing.Size(49, 24).
    this-object:radioButton1:TabIndex = 11.
    this-object:radioButton1:TabStop = true.
    this-object:radioButton1:Text = "Все".
    this-object:radioButton1:UseCompatibleTextRendering = true.
    this-object:radioButton1:UseVisualStyleBackColor = true.
    this-object:radioButton1:CheckedChanged:Subscribe(this-object:r_status_Checked).
    /*  */
    /* drowseHDDAttr */
    /*  */
    this-object:drowseHDDAttr:AllowUserToAddRows = false.
    this-object:drowseHDDAttr:AllowUserToDeleteRows = false.
    this-object:drowseHDDAttr:AllowUserToOrderColumns = true.
    this-object:drowseHDDAttr:AllowUserToResizeRows = false.
    this-object:drowseHDDAttr:AutoGenerateColumns = false.
    this-object:drowseHDDAttr:AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode:Fill.
    this-object:drowseHDDAttr:BorderStyle = System.Windows.Forms.BorderStyle:None.
    this-object:drowseHDDAttr:ClipboardCopyMode = System.Windows.Forms.DataGridViewClipboardCopyMode:Disable.
    this-object:drowseHDDAttr:ColumnHeadersBorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle:Single.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar6 as System.Windows.Forms.DataGridViewColumn extent 5 no-undo.
    arrayvar6[1] = this-object:nameDataGridViewTextBoxColumn.
    arrayvar6[2] = this-object:valueDataGridViewTextBoxColumn.
    arrayvar6[3] = this-object:treshDataGridViewTextBoxColumn.
    arrayvar6[4] = this-object:typeDataGridViewTextBoxColumn.
    arrayvar6[5] = this-object:rawvalueDataGridViewTextBoxColumn.
    this-object:drowseHDDAttr:Columns:AddRange(arrayvar6).
    this-object:drowseHDDAttr:DataSource = this-object:bindingSource2.
    this-object:drowseHDDAttr:EnableHeadersVisualStyles = false.
    this-object:drowseHDDAttr:ImeMode = System.Windows.Forms.ImeMode:NoControl.
    this-object:drowseHDDAttr:Location = new System.Drawing.Point(5, 373).
    this-object:drowseHDDAttr:MultiSelect = false.
    this-object:drowseHDDAttr:Name = "drowseHDDAttr".
    this-object:drowseHDDAttr:ReadOnly = true.
    this-object:drowseHDDAttr:RightToLeft = System.Windows.Forms.RightToLeft:No.
    this-object:drowseHDDAttr:RowHeadersVisible = false.
    this-object:drowseHDDAttr:ScrollBars = System.Windows.Forms.ScrollBars:Vertical.
    this-object:drowseHDDAttr:SelectionMode = System.Windows.Forms.DataGridViewSelectionMode:FullRowSelect.
    this-object:drowseHDDAttr:Size = new System.Drawing.Size(828, 206).
    this-object:drowseHDDAttr:TabIndex = 14.
    this-object:drowseHDDAttr:CellPainting:Subscribe(this-object:drowseHDDAttr_CellPainting).
    this-object:drowseHDDAttr:RowPostPaint:Subscribe(this-object:drowseHDDAttr_RowPostPaint).
    this-object:drowseHDDAttr:CursorChanged:Subscribe(this-object:drowseHDDAttr_CursorChanged).
    /*  */
    /* nameDataGridViewTextBoxColumn */
    /*  */
    this-object:nameDataGridViewTextBoxColumn:DataPropertyName = "name_".
    this-object:nameDataGridViewTextBoxColumn:HeaderText = "Название".
    this-object:nameDataGridViewTextBoxColumn:Name = "nameDataGridViewTextBoxColumn".
    this-object:nameDataGridViewTextBoxColumn:ReadOnly = true.
    /*  */
    /* valueDataGridViewTextBoxColumn */
    /*  */
    this-object:valueDataGridViewTextBoxColumn:DataPropertyName = "value_".
    this-object:valueDataGridViewTextBoxColumn:HeaderText = "Value".
    this-object:valueDataGridViewTextBoxColumn:Name = "valueDataGridViewTextBoxColumn".
    this-object:valueDataGridViewTextBoxColumn:ReadOnly = true.
    /*  */
    /* treshDataGridViewTextBoxColumn */
    /*  */
    this-object:treshDataGridViewTextBoxColumn:DataPropertyName = "tresh".
    this-object:treshDataGridViewTextBoxColumn:HeaderText = "Thresh".
    this-object:treshDataGridViewTextBoxColumn:Name = "treshDataGridViewTextBoxColumn".
    this-object:treshDataGridViewTextBoxColumn:ReadOnly = true.
    /*  */
    /* typeDataGridViewTextBoxColumn */
    /*  */
    this-object:typeDataGridViewTextBoxColumn:DataPropertyName = "type_".
    this-object:typeDataGridViewTextBoxColumn:HeaderText = "Тип".
    this-object:typeDataGridViewTextBoxColumn:Name = "typeDataGridViewTextBoxColumn".
    this-object:typeDataGridViewTextBoxColumn:ReadOnly = true.
    /*  */
    /* rawvalueDataGridViewTextBoxColumn */
    /*  */
    this-object:rawvalueDataGridViewTextBoxColumn:DataPropertyName = "raw_value".
    this-object:rawvalueDataGridViewTextBoxColumn:HeaderText = "Raw_Value".
    this-object:rawvalueDataGridViewTextBoxColumn:Name = "rawvalueDataGridViewTextBoxColumn".
    this-object:rawvalueDataGridViewTextBoxColumn:ReadOnly = true.
    /*  */
    /* bindingSource2 */
    /*  */
    this-object:bindingSource2:MaxDataGuess = 0.
    this-object:bindingSource2:NoLOBs = false.
    this-object:bindingSource2:Position = 0.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar7 as "Progress.Data.TableDesc[]" no-undo.
    arrayvar7 = new "Progress.Data.TableDesc[]"(0).
    tableDesc2:ChildTables = arrayvar7.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar8 as Progress.Data.ColumnPropDesc extent 5 no-undo.
    arrayvar8[1] = new Progress.Data.ColumnPropDesc("name_", "Название", Progress.Data.DataType:CHARACTER).
    arrayvar8[2] = new Progress.Data.ColumnPropDesc("value_", "Value", Progress.Data.DataType:DECIMAL).
    arrayvar8[3] = new Progress.Data.ColumnPropDesc("tresh", "Tresh", Progress.Data.DataType:DECIMAL).
    arrayvar8[4] = new Progress.Data.ColumnPropDesc("type_", "Тип", Progress.Data.DataType:CHARACTER).
    arrayvar8[5] = new Progress.Data.ColumnPropDesc("raw_value", "Raw_Value", Progress.Data.DataType:CHARACTER).
    tableDesc2:Columns = arrayvar8.
    this-object:bindingSource2:TableSchema = tableDesc2.
    /*  */
    /* obj_list */
    /*  */
    this-object:obj_list:Location = new System.Drawing.Point(85, 109).
    this-object:obj_list:Name = "obj_list".
    this-object:obj_list:Size = new System.Drawing.Size(254, 21).
    this-object:obj_list:TabIndex = 23.
    this-object:obj_list:Visible = false.
    this-object:obj_list:TextChanged:Subscribe(this-object:obj_list_TextChanged).
    /*  */
    /* lobj_list */
    /*  */
    this-object:lobj_list:FlatStyle = System.Windows.Forms.FlatStyle:Popup.
    this-object:lobj_list:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:lobj_list:Location = new System.Drawing.Point(12, 109).
    this-object:lobj_list:Name = "lobj_list".
    this-object:lobj_list:Size = new System.Drawing.Size(67, 23).
    this-object:lobj_list:TabIndex = 24.
    this-object:lobj_list:Text = "Объект:".
    this-object:lobj_list:UseCompatibleTextRendering = true.
    this-object:lobj_list:Visible = false.
    /*  */
    /* bobj_list */
    /*  */
    this-object:bobj_list:Image = cast(resources:GetObject("bobj_list.Image"), System.Drawing.Image).
    this-object:bobj_list:Location = new System.Drawing.Point(345, 109).
    this-object:bobj_list:Name = "bobj_list".
    this-object:bobj_list:Size = new System.Drawing.Size(25, 23).
    this-object:bobj_list:TabIndex = 9.
    this-object:bobj_list:UseCompatibleTextRendering = true.
    this-object:bobj_list:UseVisualStyleBackColor = true.
    this-object:bobj_list:Visible = false.
    this-object:bobj_list:Click:Subscribe(this-object:click_choice_obj).
    /*  */
    /* bindingSource3 */
    /*  */
    this-object:bindingSource3:MaxDataGuess = 0.
    this-object:bindingSource3:NoLOBs = false.
    this-object:bindingSource3:Position = 0.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar9 as "Progress.Data.TableDesc[]" no-undo.
    arrayvar9 = new "Progress.Data.TableDesc[]"(0).
    tableDesc3:ChildTables = arrayvar9.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar10 as Progress.Data.ColumnPropDesc extent 9 no-undo.
    arrayvar10[1] = new Progress.Data.ColumnPropDesc("modeldevice", "Модель диска", Progress.Data.DataType:CHARACTER).
    arrayvar10[2] = new Progress.Data.ColumnPropDesc("ModelPC", "Модель ПК", Progress.Data.DataType:CHARACTER).
    arrayvar10[3] = new Progress.Data.ColumnPropDesc("namepc", "Имя ПК", Progress.Data.DataType:CHARACTER).
    arrayvar10[4] = new Progress.Data.ColumnPropDesc("date_", "", Progress.Data.DataType:DATE).
    arrayvar10[5] = new Progress.Data.ColumnPropDesc("time_", "", Progress.Data.DataType:CHARACTER).
    arrayvar10[6] = new Progress.Data.ColumnPropDesc("ProcDisk", "", Progress.Data.DataType:DECIMAL).
    arrayvar10[7] = new Progress.Data.ColumnPropDesc("UserProc", "", Progress.Data.DataType:DECIMAL).
    arrayvar10[8] = new Progress.Data.ColumnPropDesc("status_", "", Progress.Data.DataType:CHARACTER).
    arrayvar10[9] = new Progress.Data.ColumnPropDesc("db-num", "", Progress.Data.DataType:INTEGER).
    tableDesc3:Columns = arrayvar10.
    this-object:bindingSource3:TableSchema = tableDesc3.
    /*  */
    /* HDDbrowseGBD */
    /*  */
    this-object:HDDbrowseGBD:AllowUserToAddRows = false.
    this-object:HDDbrowseGBD:AllowUserToDeleteRows = false.
    this-object:HDDbrowseGBD:AllowUserToOrderColumns = true.
    this-object:HDDbrowseGBD:AllowUserToResizeRows = false.
    this-object:HDDbrowseGBD:AutoGenerateColumns = false.
    this-object:HDDbrowseGBD:AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode:Fill.
    this-object:HDDbrowseGBD:BorderStyle = System.Windows.Forms.BorderStyle:None.
    this-object:HDDbrowseGBD:ClipboardCopyMode = System.Windows.Forms.DataGridViewClipboardCopyMode:Disable.
    this-object:HDDbrowseGBD:ColumnHeadersBorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle:Single.
    this-object:HDDbrowseGBD:ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode:AutoSize.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar11 as System.Windows.Forms.DataGridViewColumn extent 9 no-undo.
    arrayvar11[1] = this-object:Column1.
    arrayvar11[2] = this-object:dataGridViewTextBoxColumn1.
    arrayvar11[3] = this-object:dataGridViewTextBoxColumn2.
    arrayvar11[4] = this-object:dataGridViewTextBoxColumn3.
    arrayvar11[5] = this-object:dataGridViewTextBoxColumn4.
    arrayvar11[6] = this-object:dataGridViewTextBoxColumn5.
    arrayvar11[7] = this-object:dataGridViewTextBoxColumn6.
    arrayvar11[8] = this-object:dataGridViewTextBoxColumn7.
    arrayvar11[9] = this-object:dataGridViewTextBoxColumn8.
    this-object:HDDbrowseGBD:Columns:AddRange(arrayvar11).
    this-object:HDDbrowseGBD:DataSource = this-object:bindingSource3.
    this-object:HDDbrowseGBD:EnableHeadersVisualStyles = false.
    this-object:HDDbrowseGBD:ImeMode = System.Windows.Forms.ImeMode:NoControl.
    this-object:HDDbrowseGBD:Location = new System.Drawing.Point(5, 134).
    this-object:HDDbrowseGBD:MultiSelect = false.
    this-object:HDDbrowseGBD:Name = "HDDbrowseGBD".
    this-object:HDDbrowseGBD:ReadOnly = true.
    this-object:HDDbrowseGBD:RightToLeft = System.Windows.Forms.RightToLeft:No.
    this-object:HDDbrowseGBD:RowHeadersVisible = false.
    this-object:HDDbrowseGBD:RowHeadersWidthSizeMode = System.Windows.Forms.DataGridViewRowHeadersWidthSizeMode:AutoSizeToAllHeaders.
    this-object:HDDbrowseGBD:ScrollBars = System.Windows.Forms.ScrollBars:Vertical.
    this-object:HDDbrowseGBD:SelectionMode = System.Windows.Forms.DataGridViewSelectionMode:FullRowSelect.
    this-object:HDDbrowseGBD:Size = new System.Drawing.Size(828, 196).
    this-object:HDDbrowseGBD:TabIndex = 25.
    this-object:HDDbrowseGBD:CellClick:Subscribe(this-object:HDDbrowseGBD_CellClick).
    this-object:HDDbrowseGBD:CellContentClick:Subscribe(this-object:HDDbrowseGBD_CellContentClick).
    this-object:HDDbrowseGBD:RowPostPaint:Subscribe(this-object:HDDbrowseGBD_RowPostPaint).
    /*  */
    /* Column1 */
    /*  */
    this-object:Column1:DataPropertyName = "db-num".
    this-object:Column1:HeaderText = "АЗК".
    this-object:Column1:Name = "Column1".
    this-object:Column1:ReadOnly = true.
    /*  */
    /* dataGridViewTextBoxColumn1 */
    /*  */
    this-object:dataGridViewTextBoxColumn1:DataPropertyName = "date_".
    this-object:dataGridViewTextBoxColumn1:HeaderText = "Дата теста".
    this-object:dataGridViewTextBoxColumn1:Name = "dataGridViewTextBoxColumn1".
    this-object:dataGridViewTextBoxColumn1:ReadOnly = true.
    /*  */
    /* dataGridViewTextBoxColumn2 */
    /*  */
    this-object:dataGridViewTextBoxColumn2:DataPropertyName = "time_".
    this-object:dataGridViewTextBoxColumn2:HeaderText = "Время теста".
    this-object:dataGridViewTextBoxColumn2:Name = "dataGridViewTextBoxColumn2".
    this-object:dataGridViewTextBoxColumn2:ReadOnly = true.
    /*  */
    /* dataGridViewTextBoxColumn3 */
    /*  */
    this-object:dataGridViewTextBoxColumn3:DataPropertyName = "namepc".
    this-object:dataGridViewTextBoxColumn3:HeaderText = "Имя ПК".
    this-object:dataGridViewTextBoxColumn3:Name = "dataGridViewTextBoxColumn3".
    this-object:dataGridViewTextBoxColumn3:ReadOnly = true.
    /*  */
    /* dataGridViewTextBoxColumn4 */
    /*  */
    this-object:dataGridViewTextBoxColumn4:DataPropertyName = "ModelPC".
    this-object:dataGridViewTextBoxColumn4:HeaderText = "Модель ПК".
    this-object:dataGridViewTextBoxColumn4:Name = "dataGridViewTextBoxColumn4".
    this-object:dataGridViewTextBoxColumn4:ReadOnly = true.
    /*  */
    /* dataGridViewTextBoxColumn5 */
    /*  */
    this-object:dataGridViewTextBoxColumn5:DataPropertyName = "modeldevice".
    this-object:dataGridViewTextBoxColumn5:HeaderText = "Модель диска".
    this-object:dataGridViewTextBoxColumn5:Name = "dataGridViewTextBoxColumn5".
    this-object:dataGridViewTextBoxColumn5:ReadOnly = true.
    /*  */
    /* dataGridViewTextBoxColumn6 */
    /*  */
    this-object:dataGridViewTextBoxColumn6:DataPropertyName = "ProcDisk".
    this-object:dataGridViewTextBoxColumn6:HeaderText = "% заполнения диска".
    this-object:dataGridViewTextBoxColumn6:Name = "dataGridViewTextBoxColumn6".
    this-object:dataGridViewTextBoxColumn6:ReadOnly = true.
    /*  */
    /* dataGridViewTextBoxColumn7 */
    /*  */
    this-object:dataGridViewTextBoxColumn7:DataPropertyName = "UserProc".
    this-object:dataGridViewTextBoxColumn7:HeaderText = "Использ сист раздела, %".
    this-object:dataGridViewTextBoxColumn7:Name = "dataGridViewTextBoxColumn7".
    this-object:dataGridViewTextBoxColumn7:ReadOnly = true.
    /*  */
    /* dataGridViewTextBoxColumn8 */
    /*  */
    this-object:dataGridViewTextBoxColumn8:DataPropertyName = "status_".
    this-object:dataGridViewTextBoxColumn8:HeaderText = "Статус проверки".
    this-object:dataGridViewTextBoxColumn8:Name = "dataGridViewTextBoxColumn8".
    this-object:dataGridViewTextBoxColumn8:ReadOnly = true.
    /*  */
    /* radioButton4 */
    /*  */
    this-object:radioButton4:FlatStyle = System.Windows.Forms.FlatStyle:Popup.
    this-object:radioButton4:Location = new System.Drawing.Point(634, 106).
    this-object:radioButton4:Name = "radioButton4".
    this-object:radioButton4:Size = new System.Drawing.Size(109, 24).
    this-object:radioButton4:TabIndex = 33.
    this-object:radioButton4:Text = "Не пройдена".
    this-object:radioButton4:UseCompatibleTextRendering = true.
    this-object:radioButton4:UseVisualStyleBackColor = true.
    this-object:radioButton4:CheckedChanged:Subscribe(this-object:r_status_Checked).
    /*  */
    /* HDD_browse */
    /*  */
    this-object:ClientSize = new System.Drawing.Size(838, 592).
    this-object:Controls:Add(this-object:radioButton4).
    this-object:Controls:Add(this-object:label4).
    this-object:Controls:Add(this-object:HDDbrowseGBD).
    this-object:Controls:Add(this-object:bobj_list).
    this-object:Controls:Add(this-object:lobj_list).
    this-object:Controls:Add(this-object:delta).
    this-object:Controls:Add(this-object:obj_list).
    this-object:Controls:Add(this-object:drowseHDDAttr).
    this-object:Controls:Add(this-object:label3).
    this-object:Controls:Add(this-object:groupBox1).
    this-object:Controls:Add(this-object:browseHDD).
    this-object:Controls:Add(this-object:radioButton2).
    this-object:Controls:Add(this-object:ValueDisk).
    this-object:Controls:Add(this-object:radioButton1).
    this-object:Controls:Add(this-object:radioButton3).
    this-object:Controls:Add(this-object:label2).
    this-object:Controls:Add(this-object:lStatus).
    this-object:Controls:Add(this-object:TreshDisk).
    this-object:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:Name = "HDD_browse".
    this-object:Text = "Результаты проверки HDD".
    this-object:Load:Subscribe(this-object:BPA_browse_Load).
    cast(this-object:bindingSource1, System.ComponentModel.ISupportInitialize):EndInit().
    cast(this-object:browseHDD, System.ComponentModel.ISupportInitialize):EndInit().
    this-object:groupBox1:ResumeLayout(false).
    this-object:groupBox1:PerformLayout().
    cast(this-object:UserDisk, System.ComponentModel.ISupportInitialize):EndInit().
    cast(this-object:ProcDisk, System.ComponentModel.ISupportInitialize):EndInit().
    cast(this-object:delta, System.ComponentModel.ISupportInitialize):EndInit().
    cast(this-object:ValueDisk, System.ComponentModel.ISupportInitialize):EndInit().
    cast(this-object:TreshDisk, System.ComponentModel.ISupportInitialize):EndInit().
    cast(this-object:drowseHDDAttr, System.ComponentModel.ISupportInitialize):EndInit().
    cast(this-object:bindingSource2, System.ComponentModel.ISupportInitialize):EndInit().
    cast(this-object:bindingSource3, System.ComponentModel.ISupportInitialize):EndInit().
    cast(this-object:HDDbrowseGBD, System.ComponentModel.ISupportInitialize):EndInit().
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
  method private void obj_list_TextChanged( input sender as System.Object, input e as System.EventArgs ):
    
    return.

  end method.

  /*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void r_status_Checked( input sender as System.Object, input e as System.EventArgs ):
    if this-object:radioButton1:Checked = true then v-status = -1 .
    if this-object:radioButton2:Checked = true then v-status = 0 .
    if this-object:radioButton4:Checked = true then v-status = 1 .
    if this-object:radioButton3:Checked = true then v-status = 2 .
    if p-db-num <> 0 then bindingSource1:Handle = browse_HDD(v-SortDate, v-SortTime, v-SortTime-end, v-NamePK, v-ModelDisk, v-ProcDisk, v-UserDisk, v-status, v-ValueDisk, v-TreshDisk, v-Delta) no-error .
    else bindingSource3:Handle = browse_HDDGBD(v-SortDate, v-SortTime, v-SortTime-end, v-NamePK, v-ModelDisk, v-ProcDisk, v-UserDisk, v-status, v-ValueDisk, v-TreshDisk, v-Delta) no-error .
    
    bindingSource2:Handle = browse_HDDattr(v-ValueDisk, v-TreshDisk, v-Delta) no-error.
    
    return.

  end method.
  
  method private handle browse_HDD(date_ as date, time_ as integer, time_end as integer, namePk_ as character, ModelDisk_ as character, ProcDisk_ as decimal, UserDisk_ as decimal, Status_ as integer, ValueDisk_ as decimal, TreshDisk_ as decimal, Delta_ as decimal):
  
    define buffer buf_devisPC     for ub.devisPC .
    define buffer buf_devisPCAttr for ub.devisPC-attr .
    define buffer bf_devisPCAttr  for ub.devisPC-attr .
    define buffer bt_devisPCAttr  for ub.devisPC-attr .
    define variable v-ProcDisk   as decimal   no-undo .
    define variable v-UserDisk   as decimal   no-undo .
    define variable v-TestStatus as character no-undo .
    define variable v-Date       as decimal   no-undo .
    define variable v-TimeST     as character no-undo .
    define variable v-TimeST1    as character no-undo .          
    define variable ii           as integer   no-undo .
    
    empty temp-table tt-devicePC .
    empty temp-table tt-devicePCAttr .

    for each buf_devisPC no-lock where buf_devisPC.DB-num = p-db-num:
      if buf_devisPC.namepc begins namePk_ and buf_devisPC.modeldevice begins ModelDisk_ then 
      do:
        next_:
        for each buf_devisPCAttr no-lock where buf_devisPCAttr.id = buf_devisPC.id and buf_devisPCAttr.date >= date_:
          if buf_devisPCAttr.time_ < time_ then next next_.
          if buf_devisPCAttr.time_ > time_end then next next_.          
          v-ProcDisk = 0 .
          v-UserDisk = 0 .
          v-TestStatus = "" .
          if buf_devisPCAttr.attr-code = "ProcDisk" then 
          do:
            v-ProcDisk = decimal(entry(1,buf_devisPCAttr.attr-value,"%")) .
          end.
          if buf_devisPCAttr.attr-code = "UserProc" then 
          do:
            v-UserDisk = decimal(entry(1,buf_devisPCAttr.attr-value,"%")) .
          end.  
          if buf_devisPCAttr.attr-code = "TestStatus" then 
          do:
            v-TestStatus = buf_devisPCAttr.attr-value .
          end.
          find first tt-devicePC exclusive-lock where tt-devicePC.id = buf_devisPC.id and tt-devicePC.modeldevice = buf_devisPC.modeldevice
            and tt-devicePC.ModelPC     = buf_devisPC.ModelPC and tt-devicePC.namepc      = buf_devisPC.namepc and tt-devicePC.date_       = buf_devisPCAttr.date and 
            tt-devicePC.time_int       = buf_devisPCAttr.time_ and tt-devicePC.db-num = p-db-num no-error .
          if not available (tt-devicePC) then 
          do: 
            create tt-devicePC .
            assign
              tt-devicePC.id          = buf_devisPC.id
              tt-devicePC.db-num      = p-db-num
              tt-devicePC.modeldevice = buf_devisPC.modeldevice
              tt-devicePC.ModelPC     = buf_devisPC.ModelPC
              tt-devicePC.namepc      = buf_devisPC.namepc
              tt-devicePC.date_       = buf_devisPCAttr.date
              tt-devicePC.ii          = ii
              tt-devicePC.time_int    = buf_devisPCAttr.time_
              tt-devicePC.time_       = string(truncate (buf_devisPCAttr.time_ / 3600, 0)) + ":" + string((buf_devisPCAttr.time_ modulo 3600) / 60,"99") + ":" + string((buf_devisPCAttr.time_ modulo 3600) / 360,"99")
              .
            ii = ii + 1 .
          end.
          find first tt-devicePCAttr exclusive-lock where tt-devicePCAttr.id = buf_devisPCattr.id and tt-devicePCAttr.name_ = buf_devisPCattr.attr-code and tt-devicePCAttr.date_  = buf_devisPCAttr.date
            and    tt-devicePCAttr.time_       = buf_devisPCAttr.time_ and tt-devicePCAttr.db-num = p-db-num no-error .
          if not available (tt-devicePCAttr) then 
          do:
            if buf_devisPCattr.attr-code <> "ProcDisk" and buf_devisPCattr.attr-code <> "UserProc" and buf_devisPCattr.attr-code <> "TestStatus" then 
            do:
              create tt-devicePCAttr .
              assign
                tt-devicePCAttr.id        = buf_devisPCattr.id
                tt-devicePCAttr.db-num    = p-db-num
                tt-devicePCAttr.name_     = buf_devisPCattr.attr-code
                tt-devicePCAttr.raw_value = buf_devisPCattr.attr-Raw-value
                tt-devicePCAttr.tresh     = decimal(buf_devisPCattr.tresh)
                tt-devicePCAttr.value_    = decimal(buf_devisPCattr.attr-value)
                tt-devicePCAttr.type_     = buf_devisPCattr.type
                tt-devicePCAttr.date_     = buf_devisPCAttr.date
                tt-devicePCAttr.time_     = buf_devisPCAttr.time_
                .  
            end.
          end.
          if v-TestStatus <> "" then tt-devicePC.status_  = v-TestStatus .
          if v-ProcDisk <> 0 then tt-devicePC.ProcDisk = v-ProcDisk .
          if v-UserDisk <> 0 then tt-devicePC.UserProc = v-UserDisk .
        end.
      end.
    end.
    if ProcDisk_ > 0 then 
    do:
      for each tt-devicePC exclusive-lock where tt-devicePC.ProcDisk < ProcDisk_:
        delete tt-devicePC . 
      end.  
    end.   
    if UserDisk_ > 0 then 
    do:
      for each tt-devicePC exclusive-lock where tt-devicePC.UserProc < UserDisk_:
        delete tt-devicePC . 
      end.  
    end.  
    case Status_:
    when 0 then 
    do:
        for each tt-devicePC exclusive-lock where tt-devicePC.status_ <> "Пройдена":
          delete tt-devicePC .
        end.  
    end.
    when 1 then 
      do:
        for each tt-devicePC exclusive-lock where tt-devicePC.status_ <> "Не пройдена":
          delete tt-devicePC .
        end.  
    end.
    when 2 then do:  
        for each tt-devicePC exclusive-lock where tt-devicePC.status_ = "Пройдена" or tt-devicePC.status_ = "Не пройдена":
          delete tt-devicePC .
        end.  
      end.  
    end case .
    if v-ValueDisk > 0 then 
    do:
      for each tt-devicePCAttr where tt-devicePCAttr.value_ < v-ValueDisk:
        delete tt-devicePCAttr .
      end.  
    end.         
    if v-TreshDisk > 0 then 
    do:
      for each tt-devicePCAttr where tt-devicePCAttr.tresh < v-TreshDisk:
        delete tt-devicePCAttr .
      end.  
    end.
    if v-Delta > 0 then 
    do:
      for each tt-devicePCAttr where abs(tt-devicePCAttr.value_ - tt-devicePCAttr.tresh) > v-Delta:
        delete tt-devicePCAttr .
      end.  
    end.       

    for each tt-devicePC:
      find first tt-devicePCAttr where tt-devicePCAttr.id = tt-devicePC.id and tt-devicePCAttr.date_ = tt-devicePC.date_ and tt-devicePCAttr.time_ = tt-devicePC.time_int no-error .
      if not available (tt-devicePCAttr) then 
      do:
        if tt-devicePC.status_ = "не закончена" then next . 
        delete tt-devicePC .
      end.
    end.


    vPos = bindingSource1:Position.
    if valid-handle(hQuery1)  THEN DELETE object hQuery1.
    create query hQuery1. 
    hQuery1:set-buffers(buffer tt-devicePC:HANDLE).
    hQuery1:query-prepare("FOR EACH tt-devicePC").
    hQuery1:query-open.

    bindingSource1:Refresh() .
    return hQuery1 .                        
  
  end method .  

  method private handle browse_HDDGBD(date_ as date, time_ as integer, time_end as integer, namePk_ as character, ModelDisk_ as character, ProcDisk_ as decimal, UserDisk_ as decimal, Status_ as integer, ValueDisk_ as decimal, TreshDisk_ as decimal, Delta_ as decimal):
  
    define buffer buf_devisPC     for ub.devisPC .
    define buffer buf_devisPCAttr for ub.devisPC-attr .
    define buffer bf_devisPCAttr  for ub.devisPC-attr .
    define buffer bt_devisPCAttr  for ub.devisPC-attr .
    define variable ii           as integer   no-undo .
    define variable jj           as integer   no-undo .
    define variable v-ProcDisk   as decimal   no-undo .
    define variable v-UserDisk   as decimal   no-undo .
    define variable v-TestStatus as character no-undo .
    define variable v-Date       as decimal   no-undo .
    define variable v-TimeST     as character no-undo .
    define variable v-TimeST1    as character no-undo .   

    empty temp-table tt-devicePC .
    empty temp-table tt-devicePCAttr .
    if v-db-list = "" then v-db-list = string (v-cntxt-db-num) .
    do ii = 1 to num-entries (v-db-list,","):
      for each buf_devisPC no-lock where buf_devisPC.DB-num = integer(entry(ii,v-db-list,",")):
        if buf_devisPC.namepc begins namePk_ and buf_devisPC.modeldevice begins ModelDisk_ then 
        do:
          next_:
          for each buf_devisPCAttr no-lock where buf_devisPCAttr.id = buf_devisPC.id and buf_devisPCAttr.date >= date_:
            if buf_devisPCAttr.time_ < time_ then next next_.
            if buf_devisPCAttr.time_ > time_end then next next_.    
            v-ProcDisk = 0 .
            v-UserDisk = 0 .
            v-TestStatus = "" .
            if buf_devisPCAttr.attr-code = "ProcDisk" then 
            do:
              v-ProcDisk = decimal(entry(1,buf_devisPCAttr.attr-value,"%")) .
            end.
            if buf_devisPCAttr.attr-code = "UserProc" then 
            do:
              v-UserDisk = decimal(entry(1,buf_devisPCAttr.attr-value,"%")) .
            end.  
            if buf_devisPCAttr.attr-code = "TestStatus" then 
            do:
              v-TestStatus = buf_devisPCAttr.attr-value .
            end.  
            find first tt-devicePC exclusive-lock where tt-devicePC.id = buf_devisPC.id and tt-devicePC.modeldevice = buf_devisPC.modeldevice
              and tt-devicePC.ModelPC     = buf_devisPC.ModelPC and tt-devicePC.namepc      = buf_devisPC.namepc and tt-devicePC.date_       = buf_devisPCAttr.date and 
              tt-devicePC.time_int       = buf_devisPCAttr.time_ and tt-devicePC.db-num      = integer(entry(ii,v-db-list,",")) no-error .
            if not available (tt-devicePC) then 
            do: 
              create tt-devicePC .
              assign
                tt-devicePC.id          = buf_devisPC.id
                tt-devicePC.db-num      = integer(entry(ii,v-db-list,","))
                tt-devicePC.modeldevice = buf_devisPC.modeldevice
                tt-devicePC.ModelPC     = buf_devisPC.ModelPC
                tt-devicePC.ii          = jj
                tt-devicePC.namepc      = buf_devisPC.namepc
                tt-devicePC.date_       = buf_devisPCAttr.date
                tt-devicePC.time_int    = buf_devisPCAttr.time_
                tt-devicePC.time_       = string(truncate (buf_devisPCAttr.time_ / 3600, 0)) + ":" + string((buf_devisPCAttr.time_ modulo 3600) / 60,"99")
                .
              jj = jj + 1 . 
            end.
            find first tt-devicePCAttr exclusive-lock where tt-devicePCAttr.id = buf_devisPCattr.id and tt-devicePCAttr.name_ = buf_devisPCattr.attr-code and tt-devicePCAttr.date_  = buf_devisPCAttr.date
              and    tt-devicePCAttr.time_       = buf_devisPCAttr.time_ and tt-devicePCAttr.db-num      = integer(entry(ii,v-db-list,",")) no-error .
            if not available (tt-devicePCAttr) then 
            do:
              if buf_devisPCattr.attr-code <> "ProcDisk" and buf_devisPCattr.attr-code <> "UserProc" and buf_devisPCattr.attr-code <> "TestStatus" then 
              do:
                create tt-devicePCAttr .
                assign
                  tt-devicePCAttr.id        = buf_devisPCattr.id
                  tt-devicePCAttr.db-num    = integer(entry(ii,v-db-list,","))
                  tt-devicePCAttr.name_     = buf_devisPCattr.attr-code
                  tt-devicePCAttr.raw_value = buf_devisPCattr.attr-Raw-value
                  tt-devicePCAttr.tresh     = decimal(buf_devisPCattr.tresh)
                  tt-devicePCAttr.value_    = decimal(buf_devisPCattr.attr-value)
                  tt-devicePCAttr.type_     = buf_devisPCattr.type
                  tt-devicePCAttr.date_     = buf_devisPCAttr.date
                  tt-devicePCAttr.time_     = buf_devisPCAttr.time_
                  .  
              end.
            end.
            if v-TestStatus <> "" then tt-devicePC.status_  = v-TestStatus .
            if v-ProcDisk <> 0 then tt-devicePC.ProcDisk = v-ProcDisk .
            if v-UserDisk <> 0 then tt-devicePC.UserProc = v-UserDisk .
          end.
        end.
      end.
      if ProcDisk_ > 0 then 
      do:
        for each tt-devicePC exclusive-lock where tt-devicePC.ProcDisk < ProcDisk_:
          delete tt-devicePC . 
        end.  
      end.   
      if UserDisk_ > 0 then 
      do:
        for each tt-devicePC exclusive-lock where tt-devicePC.UserProc < UserDisk_:
          delete tt-devicePC . 
        end.  
      end.  
    case Status_:
    when 0 then 
    do:
        for each tt-devicePC exclusive-lock where tt-devicePC.status_ <> "Пройдена":
          delete tt-devicePC .
        end.  
    end.
    when 1 then 
      do:
        for each tt-devicePC exclusive-lock where tt-devicePC.status_ <> "Не пройдена":
          delete tt-devicePC .
        end.  
    end.
    when 2 then do:  
        for each tt-devicePC exclusive-lock where tt-devicePC.status_ = "Пройдена" or tt-devicePC.status_ = "Не пройдена":
          delete tt-devicePC .
        end.  
      end.  
    end case .   
      if v-ValueDisk > 0 then 
      do:
        for each tt-devicePCAttr where tt-devicePCAttr.value_ < v-ValueDisk:
          delete tt-devicePCAttr .
        end.  
      end.         
      if v-TreshDisk > 0 then 
      do:
        for each tt-devicePCAttr where tt-devicePCAttr.tresh < v-TreshDisk:
          delete tt-devicePCAttr .
        end.  
      end.
      if v-Delta > 0 then 
      do:
        for each tt-devicePCAttr where abs(tt-devicePCAttr.value_ - tt-devicePCAttr.tresh) > v-Delta:
          delete tt-devicePCAttr .
        end.  
      end.       
    end.


    for each tt-devicePC:
      find first tt-devicePCAttr where tt-devicePCAttr.id = tt-devicePC.id and tt-devicePCAttr.date_ = tt-devicePC.date_ and tt-devicePCAttr.time_ = tt-devicePC.time_int and tt-devicePCAttr.db-num = tt-devicePC.db-num no-error .
      if not available (tt-devicePCAttr) then 
      do:
        if tt-devicePC.status_ = "не закончена" then next . 
        delete tt-devicePC .
      end.
    end.

    

    vPos = bindingSource3:Position.
    if valid-handle(hQuery1)  THEN DELETE object hQuery1.
    create query hQuery1. 
    hQuery1:set-buffers(buffer tt-devicePC:HANDLE).
    hQuery1:query-prepare("FOR EACH tt-devicePC").
    hQuery1:query-open.
    bindingSource1:Refresh() .
    return hQuery1 .                        
  
  end method .  

  method private handle browse_HDDattr(ValueDisk_ as decimal, TreshDisk_ as decimal, Delta_ as decimal):
    define variable v-TimeST  as character no-undo .
    define variable v-TimeST1 as character no-undo .   
    define buffer buf_devisPC-attr for ub.devisPC-attr .
    define variable ii as integer no-undo .
    empty temp-table tt-devicePCAttr .

    next_:
    for each buf_devisPC-attr no-lock where buf_devisPC-attr.id = tt-devicePC.id and buf_devisPC-attr.date = tt-devicePC.date_ and buf_devisPC-attr.db-num = tt-devicePC.db-num  
      and buf_devisPC-attr.attr-code <> "ProcDisk" and buf_devisPC-attr.attr-code <> "UserProc" and buf_devisPC-attr.attr-code <> "testStatus" :
      if buf_devisPC-Attr.time_ <> tt-devicePC.time_int then next next_.
       
      create tt-devicePCAttr .
      assign
        tt-devicePCAttr.id        = buf_devisPC-attr.id
        tt-devicePCAttr.db-num    = buf_devisPC-attr.db-num
        tt-devicePCAttr.ii        = ii
        tt-devicePCAttr.name_     = buf_devisPC-attr.attr-code
        tt-devicePCAttr.raw_value = buf_devisPC-attr.attr-Raw-value
        tt-devicePCAttr.tresh     = decimal(buf_devisPC-attr.tresh)
        tt-devicePCAttr.value_    = decimal(buf_devisPC-attr.attr-value)
        tt-devicePCAttr.type_     = buf_devisPC-attr.type 
        . 
      ii = ii + 1 . 
    end.   
    if v-ValueDisk > 0 then 
    do:
      for each tt-devicePCAttr where tt-devicePCAttr.value_ < v-ValueDisk:
        delete tt-devicePCAttr .
      end.  
    end.         
    if v-TreshDisk > 0 then 
    do:
      for each tt-devicePCAttr where tt-devicePCAttr.tresh < v-TreshDisk:
        delete tt-devicePCAttr .
      end.  
    end.
    if v-Delta > 0 then 
    do:
      for each tt-devicePCAttr where abs(tt-devicePCAttr.value_ - tt-devicePCAttr.tresh) > v-Delta:
        delete tt-devicePCAttr .
      end.  
    end.    

    if valid-handle(hQuery2)  THEN DELETE object hQuery2.
    create query hQuery2. 
    hQuery2:set-buffers(buffer tt-devicePCAttr:HANDLE).
    hQuery2:query-prepare("FOR EACH tt-devicePCAttr").
    hQuery2:query-open.
    bindingSource2:Refresh() .
    return hQuery2 .                        
      
  end method .  

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void sort_time_end_Leave( input sender as System.Object, input e as System.EventArgs ):
    v-SortTime-end = mtime (this-object:sort_time_end:value) / 1000 . 
    if p-db-num <> 0 then bindingSource1:Handle = browse_HDD(v-SortDate, v-SortTime, v-SortTime-end, v-NamePK, v-ModelDisk, v-ProcDisk, v-UserDisk, v-status, v-ValueDisk, v-TreshDisk, v-Delta) no-error .
    else bindingSource3:Handle = browse_HDDGBD(v-SortDate, v-SortTime, v-SortTime-end, v-NamePK, v-ModelDisk, v-ProcDisk, v-UserDisk, v-status, v-ValueDisk, v-TreshDisk, v-Delta) no-error .
    
    bindingSource2:Handle = browse_HDDattr(v-ValueDisk, v-TreshDisk, v-Delta) no-error.
  
    return.

  end method.



  /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
  METHOD PUBLIC VOID Visual_form( INPUT p-db-num as integer ): 
      
    if p-db-num = 0 then 
    do:
      this-object:lobj_list:Visible = true .
      this-object:obj_list:Visible = true .
      this-object:obj_list:ReadOnly = true .
      this-object:bobj_list:Visible = true .
      this-object:browseHDD:Visible = false .
      this-object:HDDbrowseGBD:Visible = true .
    end.
    else 
    do:
      this-object:browseHDD:Visible = true .
      this-object:HDDbrowseGBD:Visible = false .
    end.  
    return.
  end method .
  
  destructor public HDD_browse ( ):

  end destructor.

end class.

