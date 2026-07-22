 
 /*------------------------------------------------------------------------
    File        : sShift
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : druban
    Created     : Mon Mar 23 07:33:27 MSK 2020
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Progress.Windows.UserControl.

block-level on error undo, throw.

class ibs.th.ref.sobj.sShift inherits UserControl: 
   {cmp\r-page-pre.i}
   {cmp\str-glbl.i class}
   define private variable BtnShiftend as System.Windows.Forms.Button no-undo.
   define private variable BtnShiftStart as System.Windows.Forms.Button no-undo.
   define private variable BtnShift as System.Windows.Forms.Button no-undo.
   define private variable components as System.ComponentModel.IContainer no-undo.
   define private variable DateAloneLab as System.Windows.Forms.Label no-undo.
   define private variable DateAlone as System.Windows.Forms.DateTimePicker no-undo.
   define private variable DateEndlab as System.Windows.Forms.Label no-undo.
   define private variable DateStart as System.Windows.Forms.DateTimePicker no-undo.
   define private variable DateEnd as System.Windows.Forms.DateTimePicker no-undo.
   define private variable DateStartLab as System.Windows.Forms.Label no-undo.
   define private variable Radio_Period as System.Windows.Forms.ComboBox no-undo.
   define private variable Radio_Task as System.Windows.Forms.Panel no-undo.
   define private variable radioButton4 as System.Windows.Forms.RadioButton no-undo.
   define private variable radioButton3 as System.Windows.Forms.RadioButton no-undo.
   define private variable radioButton2 as System.Windows.Forms.RadioButton no-undo.
   define private variable radioButton1 as System.Windows.Forms.RadioButton no-undo.
   define private variable ShiftEndlab as System.Windows.Forms.Label no-undo.
   define private variable ShiftAlonelab as System.Windows.Forms.Label no-undo.
   define private variable ShiftStart as System.Windows.Forms.NumericUpDown no-undo.
   define private variable ShiftEnd as System.Windows.Forms.NumericUpDown no-undo.
   define private variable ShiftAlone as System.Windows.Forms.NumericUpDown no-undo.
   define private variable ShiftStartlab as System.Windows.Forms.Label no-undo.
   define private variable splitContainer1 as System.Windows.Forms.SplitContainer no-undo.
   define private variable text3 as System.Windows.Forms.Label no-undo.
   define private variable TOGShift2 as System.Windows.Forms.CheckBox no-undo.
   define private variable TOGShift as System.Windows.Forms.CheckBox no-undo.
   define property mTrgLoc as class ibs.th.ref.sobj.sShift_trg no-undo
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
   
   define property mTrgGlb as class ibs.th.ref.sobj.dReportTrg no-undo
   get.
   set.
   
   define public property stype as class ibs.th.ref.sobj.stype no-undo
   get.
   set(iarg as ibs.th.ref.sobj.stype):
      stype = iarg.
      mTrgLoc:stype = iarg.
      radioButton1:text = iarg:RadioTaskLbl(1).
      radioButton2:text = iarg:RadioTaskLbl(2).
      radioButton3:text = iarg:RadioTaskLbl(3).
      radioButton4:text = iarg:RadioTaskLbl(4).
   end.
   
   define public property RADIO-task as character  no-undo
   get:
      /*message if radioButton1:checked 
             then radioButton1:text
             else if radioButton2:checked 
             then radioButton2:text
             else if radioButton2:checked 
             then radioButton2:text
             else if radioButton3:checked 
             then radioButton3:text
             else if radioButton4:checked 
             then radioButton4:text
             else ""
      view-as alert-box.*/
      return if radioButton1:checked 
             then radioButton1:text
             else if radioButton2:checked 
             then radioButton2:text
             else if radioButton2:checked 
             then radioButton2:text
             else if radioButton3:checked 
             then radioButton3:text
             else if radioButton4:checked 
             then radioButton4:text
             else "".
   end.
   set (iarg as character  ):
      define variable varg as integer no-undo.
      varg = int(iarg)no-error.
      if varg eq 1
      then radioButton1:checked = yes .   
      else if varg eq 2
      then radioButton2:checked = yes . 
      else if varg eq 3
      then radioButton3:checked = yes . 
      else if varg eq 4
      then radioButton4:checked = yes .  
   end.
      
   constructor public sShift (  ):
      
      
      super().
      mTrgLoc = new ibs.th.ref.sobj.sShift_trg ().
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

   method public void Assign-frame(  ):
      define variable vtog-shift as logical no-undo.
      vtog-shift = togshift:checked.
      if    ParamForm:temp-param-date = 8  
         or ParamForm:temp-param-date = 7 
      then  
         vtog-shift = true .
      define variable vDate-End as date no-undo.
      define variable vShift-End as integer no-undo.
      
      define variable vDate-Alone as date no-undo.
      define variable vShift-Alone as integer no-undo.
      define variable vDate-Start as date no-undo.
      define variable vShift-Start as integer no-undo.
      define variable vFlg as logical no-undo.
      assign
         vDate-End = date(DateEnd:value)
         vShift-End = int(ShiftEnd:value)
         vDate-Alone = date(DateAlone:Value)
         vShift-Alone = int(ShiftAlone:value)
         vDate-Start = date(DateStart:Value)
         vShift-Start = int(ShiftStart:value)
      .
      if     vtog-shift 
         and togshift2:Checked 
      then assign
         vDate-End       = Datestart:Value
         vShift-End      = ShiftStart:Value
      . 
      mTrgLoc:set_Date-Alone    (vDate-Alone).
      mTrgLoc:set_Date-End      (vDate-End).
      mTrgLoc:set_Date-Start    (vDate-Start).
      mTrgLoc:set_Shift-Alone   (vShift-Alone).
      mTrgLoc:set_Shift-End     (vShift-End).
      mTrgLoc:set_Shift-Start   (vShift-Start).
  
/*  X-TEXT-3         = TEXT3*/
      mTrgLoc:set_TOG-Shift      ( vTOG-Shift).
      mTrgLoc:set_RADIO-task     ( RADIO-task).
  
      if     DateAlone:visible 
         and dateend:visible = false 
      then do:
         mTrgLoc:set_Date-Start    (vDate-Alone) .
         mTrgLoc:set_Date-End      (vDate-Alone)   .
      end.

      if radioButton4:Checked 
      then do:
         mTrgLoc:set_Shift-End     (vShift-Alone).
         mTrgLoc:set_Shift-Start   (vShift-Alone).
      end.
      define variable t-str as character no-undo.
      case ParamForm:temp-param-date :
         when 0 then t-str = "" .
         when 1 then t-str = " На " + string(vDate-Alone,"99/99/9999").
         when 2 then t-str = " За период с  " + string(vDate-Start,"99/99/9999") + "  по " + string(vDate-End,"99/99/9999") .
         when 3 then t-str = " По смене № " + string(vShift-Alone) + "  за период с " + string(vDate-Start,"99/99/9999") + "  по " + string(vDate-End,"99/99/9999") .
         when 4 then do:
            if     vtog-shift 
               and togshift2:Checked 
            then
               t-str = " По смене № "  + string(vShift-Start) + " на  " + string(vDate-Start,"99/99/9999") .
            else
                t-str =  (if vtog-shift then "Смены с "  + string(vShift-Start)   + " по "  + string(vShift-End)  else "" ) +
                " За период с  " + string(vDate-Start,"99/99/9999") + "  по " + string(vDate-End,"99/99/9999") .

                end.
         when 5 or when 6 then do:
            case yes:
               when radioButton1:Checked 
               then  
                  t-str = "Календарные сутки , За период с  " + string(vDate-Start,"99/99/9999") + "  по " + string(vDate-End,"99/99/9999") .
               when radioButton2:Checked  
               then  
                  t-str = "Сменные сутки , За период с  " + string(vDate-Start,"99/99/9999") + "  по " + string(vDate-End,"99/99/9999") .
               when radioButton3:Checked 
               then  
                  t-str = "Сменные сутки,  За период с  " + string(vDate-Start,"99/99/9999") + "  по " + string(vDate-End,"99/99/9999") +
                                  " Смены с "  + string(vShift-Start)   + " по "  + string(vShift-End)   .
               when radioButton4:Checked 
               then  
                  t-str = " По смене № " + string(vShift-Alone) + " За период с  " + string(vDate-Start,"99/99/9999") + "  по " + string(vDate-End,"99/99/9999") .


            end case.
         end.
         when 7 then t-str = " По смене № " + string(vShift-Alone) + "  дата открытия " + string(vDate-Start,"99/99/9999") .
         when 8 then do:
                t-str =
                "Смены с "  + string(vShift-Start)   + " по "  + string(vShift-End)  +
                " За период с  " + string(vDate-Start,"99/99/9999") + "  по " + string(vDate-End,"99/99/9999") .
         end.
         when 9 then do:
                t-str =
                "Период : за " + radio_period:Text .
         end.
      end case.
    /*даты*/
      mTrgLoc:set_strShift( t-str).
      return.
   end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void BtnShift_Click( input sender as System.Object, input e as System.EventArgs ):
		define variable vdate-start  as date no-undo.
		define variable vshift-alone as integer no-undo.
		vdate-start = DateStart:value.
      vshift-alone = shiftalone:value.
      
		mTrgLoc:BtnShift(input-output vdate-start ,input-output vshift-alone).
		DateStart:value = vdate-start .
      shiftalone:value = vshift-alone.
      
		datestart:visible = yes.
		shiftalone:visible = yes.
		datestartlab:visible = yes.
      shiftalonelab:visible = yes.
      
        LEAVE_Shift-Alone(vshift-alone) .
        LEAVE_date-start (vdate-start).
		
		return.

	end method.
	
	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void BtnShiftend_Click( input sender as System.Object, input e as System.EventArgs ):
		define variable vdate-end  as date no-undo.
      define variable vshift-end as integer no-undo.
      vdate-end = dateend:value.
      vshift-end = shiftend:value.
      
      mTrgLoc:BtnShift(input-output vdate-end ,input-output vshift-end).
      dateend:value = vdate-end .
      shiftend:value = vshift-end.
      
      dateend:visible = yes.
      shiftend:visible = yes.
      dateendlab:visible = yes.
      shiftendlab:visible = yes.
      

      LEAVE_Shift-End(vshift-end).
      define variable vDateStart  as date no-undo.
      vDateStart = DateStart:value.
      LEAVE_Date-End(vDateStart,vdate-end).
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void BtnShiftStart_Click( input sender as System.Object, input e as System.EventArgs ):
		define variable vdate-start  as date no-undo.
      define variable vshift-start as integer no-undo.
      vdate-start = datestart:value.
      vshift-start = shiftstart:value.
      
      mTrgLoc:BUTTON-Shift-Start(input-output vdate-start ,input-output vshift-start).
      datestart:value = vdate-start .
      shiftstart:value = vshift-start.
      leave_shift-start(vshift-start) .
      leave_date-start(vdate-start) .
      
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void DateAlone_Leave( input sender as System.Object, input e as System.EventArgs ):
		if mTrgGlb:canselForm()
      then 
         return.
      define variable vDateAlone as date no-undo.
      vDateAlone = DateAlone:value.
      LEAVE_Date-Alone(vDateAlone).
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void DateEnd_Leave( input sender as System.Object, input e as System.EventArgs ):
		
		if mTrgGlb:canselForm()
      then 
         return.
		define variable vDateStart  as date no-undo.
      vDateStart = DateStart:value.
      define variable vdate-end  as date no-undo.
      vdate-end = dateend:value.
		LEAVE_Date-End(vDateStart,vdate-end).
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void DateStart_Leave( input sender as System.Object, input e as System.EventArgs ):
		define variable vDate as date no-undo.
		if mTrgGlb:canselForm()
		then 
		   return.
		vDate = datestart:value.
		LEAVE_date-start(vdate).
		return.

	end method.

   

   method private  void LEAVE_Date-End (iDateStart as date, iDate-End as date): /* по */
      mTrgLoc:LEAVE_Date-End(iDateStart, iDate-End).
   end.
   
   method private  void LEAVE_Shift-End ( iShift-End as integer ): /* по */
      mTrgLoc:LEAVE_Shift-End(iShift-End).
   end.
   
   method private  void LEAVE_date-start(idate-start as date ):
      mTrgLoc:LEAVE_Date-Start(idate-start).
   end.
   
   method private  void LEAVE_Shift-Alone(iShift-Alone as integer ): /* смена */
      mTrgLoc:LEAVE_Shift-Alone(iShift-Alone).
   
      if ShiftEnd:visible  then  Shiftend:value = iShift-Alone .
      if Shiftstart:visible  then   Shiftend:value = iShift-Alone .
     
   end.
  
   method private void LEAVE_Shift-Start (iShift-Start as integer ): /* с */
      mTrgLoc:LEAVE_Shift-Start (iShift-Start).
   end.
  
   method private void InitializeComponent(  ):
      
      /* NOTE: The following method is automatically generated.
      
      We strongly suggest that the contents of this method only be modified using the
      Visual Designer to avoid any incompatible modifications.
      
      Modifying the contents of this method using a code editor will invalidate any support for this file. */
      @VisualDesigner.FormMember (NeedsInitialize="true").
      define variable resources as Progress.Util.ResourceManager no-undo.
      resources = new Progress.Util.ResourceManager("ibs.th.ref.sobj.sShift").
      this-object:radioButton1 = new System.Windows.Forms.RadioButton().
      this-object:radioButton2 = new System.Windows.Forms.RadioButton().
      this-object:radioButton3 = new System.Windows.Forms.RadioButton().
      this-object:radioButton4 = new System.Windows.Forms.RadioButton().
      this-object:text3 = new System.Windows.Forms.Label().
      this-object:DateStart = new System.Windows.Forms.DateTimePicker().
      this-object:DateStartLab = new System.Windows.Forms.Label().
      this-object:ShiftStartlab = new System.Windows.Forms.Label().
      this-object:DateEndlab = new System.Windows.Forms.Label().
      this-object:DateEnd = new System.Windows.Forms.DateTimePicker().
      this-object:ShiftStart = new System.Windows.Forms.NumericUpDown().
      this-object:BtnShiftStart = new System.Windows.Forms.Button().
      this-object:ShiftEndlab = new System.Windows.Forms.Label().
      this-object:ShiftEnd = new System.Windows.Forms.NumericUpDown().
      this-object:ShiftAlonelab = new System.Windows.Forms.Label().
      this-object:BtnShiftend = new System.Windows.Forms.Button().
      this-object:ShiftAlone = new System.Windows.Forms.NumericUpDown().
      this-object:BtnShift = new System.Windows.Forms.Button().
      this-object:DateAlone = new System.Windows.Forms.DateTimePicker().
      this-object:DateAloneLab = new System.Windows.Forms.Label().
      this-object:TOGShift = new System.Windows.Forms.CheckBox().
      this-object:TOGShift2 = new System.Windows.Forms.CheckBox().
      this-object:Radio_Task = new System.Windows.Forms.Panel().
      this-object:Radio_Period = new System.Windows.Forms.ComboBox().
      this-object:splitContainer1 = new System.Windows.Forms.SplitContainer().
      cast(this-object:ShiftStart, System.ComponentModel.ISupportInitialize):BeginInit().
      cast(this-object:ShiftEnd, System.ComponentModel.ISupportInitialize):BeginInit().
      cast(this-object:ShiftAlone, System.ComponentModel.ISupportInitialize):BeginInit().
      this-object:Radio_Task:SuspendLayout().
      cast(this-object:splitContainer1, System.ComponentModel.ISupportInitialize):BeginInit().
      this-object:splitContainer1:Panel1:SuspendLayout().
      this-object:splitContainer1:Panel2:SuspendLayout().
      this-object:splitContainer1:SuspendLayout().
      this-object:SuspendLayout().
      /*  */
      /* radioButton1 */
      /*  */
      this-object:radioButton1:Location = new System.Drawing.Point(7, 3).
      this-object:radioButton1:Name = "radioButton1".
      this-object:radioButton1:Size = new System.Drawing.Size(133, 24).
      this-object:radioButton1:TabIndex = 0.
      this-object:radioButton1:TabStop = true.
      this-object:radioButton1:Text = "Календарные даты".
      this-object:radioButton1:UseCompatibleTextRendering = true.
      this-object:radioButton1:UseVisualStyleBackColor = true.
      this-object:radioButton1:CheckedChanged:Subscribe(this-object:radioButton1_CheckedChanged).
      /*  */
      /* radioButton2 */
      /*  */
      this-object:radioButton2:Location = new System.Drawing.Point(7, 33).
      this-object:radioButton2:Name = "radioButton2".
      this-object:radioButton2:Size = new System.Drawing.Size(104, 24).
      this-object:radioButton2:TabIndex = 1.
      this-object:radioButton2:TabStop = true.
      this-object:radioButton2:Text = "Сменные сутки".
      this-object:radioButton2:UseCompatibleTextRendering = true.
      this-object:radioButton2:UseVisualStyleBackColor = true.
      this-object:radioButton2:CheckedChanged:Subscribe(this-object:radioButton2_CheckedChanged).
      /*  */
      /* radioButton3 */
      /*  */
      this-object:radioButton3:Location = new System.Drawing.Point(7, 61).
      this-object:radioButton3:Name = "radioButton3".
      this-object:radioButton3:Size = new System.Drawing.Size(163, 24).
      this-object:radioButton3:TabIndex = 2.
      this-object:radioButton3:TabStop = true.
      this-object:radioButton3:Text = "Сменные сутки и порядок".
      this-object:radioButton3:UseCompatibleTextRendering = true.
      this-object:radioButton3:UseVisualStyleBackColor = true.
      this-object:radioButton3:CheckedChanged:Subscribe(this-object:radioButton3_CheckedChanged).
      /*  */
      /* radioButton4 */
      /*  */
      this-object:radioButton4:Location = new System.Drawing.Point(7, 93).
      this-object:radioButton4:Name = "radioButton4".
      this-object:radioButton4:Size = new System.Drawing.Size(104, 24).
      this-object:radioButton4:TabIndex = 3.
      this-object:radioButton4:TabStop = true.
      this-object:radioButton4:Text = "По сменам".
      this-object:radioButton4:UseCompatibleTextRendering = true.
      this-object:radioButton4:UseVisualStyleBackColor = true.
      this-object:radioButton4:CheckedChanged:Subscribe(this-object:radioButton4_CheckedChanged).
      /*  */
      /* text3 */
      /*  */
      this-object:text3:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(12), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:text3:Location = new System.Drawing.Point(192, 0).
      this-object:text3:Name = "text3".
      this-object:text3:Size = new System.Drawing.Size(126, 23).
      this-object:text3:TabIndex = 4.
      this-object:text3:Text = "Задание даты".
      this-object:text3:UseCompatibleTextRendering = true.
      /*  */
      /* DateStart */
      /*  */
      this-object:DateStart:Format = System.Windows.Forms.DateTimePickerFormat:Short.
      this-object:DateStart:Location = new System.Drawing.Point(120, 101).
      this-object:DateStart:Name = "DateStart".
      this-object:DateStart:Size = new System.Drawing.Size(97, 20).
      this-object:DateStart:TabIndex = 5.
      this-object:DateStart:Leave:Subscribe(this-object:DateStart_Leave).
      /*  */
      /* DateStartLab */
      /*  */
      this-object:DateStartLab:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.75), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:DateStartLab:Location = new System.Drawing.Point(98, 101).
      this-object:DateStartLab:Name = "DateStartLab".
      this-object:DateStartLab:Size = new System.Drawing.Size(16, 20).
      this-object:DateStartLab:TabIndex = 6.
      this-object:DateStartLab:Text = "c:".
      this-object:DateStartLab:UseCompatibleTextRendering = true.
      /*  */
      /* ShiftStartlab */
      /*  */
      this-object:ShiftStartlab:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.75), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:ShiftStartlab:Location = new System.Drawing.Point(98, 71).
      this-object:ShiftStartlab:Name = "ShiftStartlab".
      this-object:ShiftStartlab:Size = new System.Drawing.Size(16, 23).
      this-object:ShiftStartlab:TabIndex = 7.
      this-object:ShiftStartlab:Text = "c:".
      this-object:ShiftStartlab:UseCompatibleTextRendering = true.
      /*  */
      /* DateEndlab */
      /*  */
      this-object:DateEndlab:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.75), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:DateEndlab:Location = new System.Drawing.Point(247, 101).
      this-object:DateEndlab:Name = "DateEndlab".
      this-object:DateEndlab:Size = new System.Drawing.Size(24, 23).
      this-object:DateEndlab:TabIndex = 8.
      this-object:DateEndlab:Text = "по:".
      this-object:DateEndlab:UseCompatibleTextRendering = true.
      /*  */
      /* DateEnd */
      /*  */
      this-object:DateEnd:Format = System.Windows.Forms.DateTimePickerFormat:Short.
      this-object:DateEnd:Location = new System.Drawing.Point(277, 101).
      this-object:DateEnd:Name = "DateEnd".
      this-object:DateEnd:Size = new System.Drawing.Size(91, 20).
      this-object:DateEnd:TabIndex = 9.
      this-object:DateEnd:Leave:Subscribe(this-object:DateEnd_Leave).
      /*  */
      /* ShiftStart */
      /*  */
      this-object:ShiftStart:Location = new System.Drawing.Point(120, 71).
      this-object:ShiftStart:Name = "ShiftStart".
      this-object:ShiftStart:Size = new System.Drawing.Size(38, 20).
      this-object:ShiftStart:TabIndex = 10.
      this-object:ShiftStart:Leave:Subscribe(this-object:ShiftStart_Leave).
      /*  */
      /* BtnShiftStart */
      /*  */
      this-object:BtnShiftStart:Image = cast(resources:GetObject("BtnShiftStart.Image"), System.Drawing.Image).
      this-object:BtnShiftStart:Location = new System.Drawing.Point(165, 71).
      this-object:BtnShiftStart:Name = "BtnShiftStart".
      this-object:BtnShiftStart:Size = new System.Drawing.Size(20, 20).
      this-object:BtnShiftStart:TabIndex = 11.
      this-object:BtnShiftStart:UseCompatibleTextRendering = true.
      this-object:BtnShiftStart:UseVisualStyleBackColor = true.
      this-object:BtnShiftStart:Click:Subscribe(this-object:BtnShiftStart_Click).
      /*  */
      /* ShiftEndlab */
      /*  */
      this-object:ShiftEndlab:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.75), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:ShiftEndlab:Location = new System.Drawing.Point(247, 75).
      this-object:ShiftEndlab:Name = "ShiftEndlab".
      this-object:ShiftEndlab:Size = new System.Drawing.Size(24, 23).
      this-object:ShiftEndlab:TabIndex = 12.
      this-object:ShiftEndlab:Text = "по:".
      this-object:ShiftEndlab:UseCompatibleTextRendering = true.
      /*  */
      /* ShiftEnd */
      /*  */
      this-object:ShiftEnd:Location = new System.Drawing.Point(277, 75).
      this-object:ShiftEnd:Name = "ShiftEnd".
      this-object:ShiftEnd:Size = new System.Drawing.Size(38, 20).
      this-object:ShiftEnd:TabIndex = 13.
      this-object:ShiftEnd:Leave:Subscribe(this-object:ShiftEnd_Leave).
      /*  */
      /* ShiftAlonelab */
      /*  */
      this-object:ShiftAlonelab:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.75), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:ShiftAlonelab:Location = new System.Drawing.Point(237, 45).
      this-object:ShiftAlonelab:Name = "ShiftAlonelab".
      this-object:ShiftAlonelab:Size = new System.Drawing.Size(53, 23).
      this-object:ShiftAlonelab:TabIndex = 14.
      this-object:ShiftAlonelab:Text = "Смена:".
      this-object:ShiftAlonelab:UseCompatibleTextRendering = true.
      /*  */
      /* BtnShiftend */
      /*  */
      this-object:BtnShiftend:Image = cast(resources:GetObject("BtnShiftend.Image"), System.Drawing.Image).
      this-object:BtnShiftend:Location = new System.Drawing.Point(322, 75).
      this-object:BtnShiftend:Name = "BtnShiftend".
      this-object:BtnShiftend:Size = new System.Drawing.Size(20, 20).
      this-object:BtnShiftend:TabIndex = 15.
      this-object:BtnShiftend:UseCompatibleTextRendering = true.
      this-object:BtnShiftend:UseVisualStyleBackColor = true.
      this-object:BtnShiftend:Click:Subscribe(this-object:BtnShiftend_Click).
      /*  */
      /* ShiftAlone */
      /*  */
      this-object:ShiftAlone:Location = new System.Drawing.Point(296, 45).
      this-object:ShiftAlone:Name = "ShiftAlone".
      this-object:ShiftAlone:Size = new System.Drawing.Size(35, 20).
      this-object:ShiftAlone:TabIndex = 16.
      this-object:ShiftAlone:Leave:Subscribe(this-object:ShiftAlone_Leave).
      /*  */
      /* BtnShift */
      /*  */
      this-object:BtnShift:Image = cast(resources:GetObject("BtnShift.Image"), System.Drawing.Image).
      this-object:BtnShift:Location = new System.Drawing.Point(338, 45).
      this-object:BtnShift:Name = "BtnShift".
      this-object:BtnShift:Size = new System.Drawing.Size(20, 20).
      this-object:BtnShift:TabIndex = 17.
      this-object:BtnShift:UseCompatibleTextRendering = true.
      this-object:BtnShift:UseVisualStyleBackColor = true.
      this-object:BtnShift:Click:Subscribe(this-object:BtnShift_Click).
      /*  */
      /* DateAlone */
      /*  */
      this-object:DateAlone:Format = System.Windows.Forms.DateTimePickerFormat:Short.
      this-object:DateAlone:Location = new System.Drawing.Point(135, 12).
      this-object:DateAlone:Name = "DateAlone".
      this-object:DateAlone:Size = new System.Drawing.Size(100, 20).
      this-object:DateAlone:TabIndex = 18.
      this-object:DateAlone:Leave:Subscribe(this-object:DateAlone_Leave).
      /*  */
      /* DateAloneLab */
      /*  */
      this-object:DateAloneLab:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.75), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:DateAloneLab:Location = new System.Drawing.Point(83, 12).
      this-object:DateAloneLab:Name = "DateAloneLab".
      this-object:DateAloneLab:Size = new System.Drawing.Size(46, 23).
      this-object:DateAloneLab:TabIndex = 19.
      this-object:DateAloneLab:Text = "Дата".
      this-object:DateAloneLab:UseCompatibleTextRendering = true.
      /*  */
      /* TOGShift */
      /*  */
      this-object:TOGShift:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.75), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:TOGShift:Location = new System.Drawing.Point(241, 1).
      this-object:TOGShift:Name = "TOGShift".
      this-object:TOGShift:Size = new System.Drawing.Size(104, 16).
      this-object:TOGShift:TabIndex = 20.
      this-object:TOGShift:Text = "Смены".
      this-object:TOGShift:UseCompatibleTextRendering = true.
      this-object:TOGShift:UseVisualStyleBackColor = true.
      this-object:TOGShift:CheckedChanged:Subscribe(this-object:TOGShift_CheckedChanged).
      /*  */
      /* TOGShift2 */
      /*  */
      this-object:TOGShift2:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.75), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:TOGShift2:Location = new System.Drawing.Point(241, 23).
      this-object:TOGShift2:Name = "TOGShift2".
      this-object:TOGShift2:Size = new System.Drawing.Size(104, 16).
      this-object:TOGShift2:TabIndex = 21.
      this-object:TOGShift2:Text = "Одна смена".
      this-object:TOGShift2:UseCompatibleTextRendering = true.
      this-object:TOGShift2:UseVisualStyleBackColor = true.
      this-object:TOGShift2:CheckedChanged:Subscribe(this-object:TOGShift2_CheckedChanged).
      /*  */
      /* Radio_Task */
      /*  */
      this-object:Radio_Task:Controls:Add(this-object:radioButton1).
      this-object:Radio_Task:Controls:Add(this-object:radioButton2).
      this-object:Radio_Task:Controls:Add(this-object:radioButton3).
      this-object:Radio_Task:Controls:Add(this-object:radioButton4).
      this-object:Radio_Task:Location = new System.Drawing.Point(3, 41).
      this-object:Radio_Task:Name = "Radio_Task".
      this-object:Radio_Task:Size = new System.Drawing.Size(173, 123).
      this-object:Radio_Task:TabIndex = 22.
      this-object:Radio_Task:Visible = false.
      /*  */
      /* Radio_Period */
      /*  */
      this-object:Radio_Period:FormattingEnabled = true.
      this-object:Radio_Period:Location = new System.Drawing.Point(10, 14).
      this-object:Radio_Period:Name = "Radio_Period".
      this-object:Radio_Period:Size = new System.Drawing.Size(121, 21).
      this-object:Radio_Period:TabIndex = 23.
      /*  */
      /* splitContainer1 */
      /*  */
      define variable nestedvar0 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar0 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:splitContainer1:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:splitContainer1:Location = new System.Drawing.Point(3, 19).
      this-object:splitContainer1:Name = "splitContainer1".
      /*  */
      /* splitContainer1.Panel1 */
      /*  */
      this-object:splitContainer1:Panel1:Controls:Add(this-object:Radio_Task).
      this-object:splitContainer1:Panel1:Controls:Add(this-object:Radio_Period).
      this-object:splitContainer1:Panel1Collapsed = true.
      /*  */
      /* splitContainer1.Panel2 */
      /*  */
      this-object:splitContainer1:Panel2:Controls:Add(this-object:ShiftAlonelab).
      this-object:splitContainer1:Panel2:Controls:Add(this-object:TOGShift2).
      this-object:splitContainer1:Panel2:Controls:Add(this-object:DateStart).
      this-object:splitContainer1:Panel2:Controls:Add(this-object:TOGShift).
      this-object:splitContainer1:Panel2:Controls:Add(this-object:DateStartLab).
      this-object:splitContainer1:Panel2:Controls:Add(this-object:DateAloneLab).
      this-object:splitContainer1:Panel2:Controls:Add(this-object:ShiftStartlab).
      this-object:splitContainer1:Panel2:Controls:Add(this-object:DateAlone).
      this-object:splitContainer1:Panel2:Controls:Add(this-object:DateEndlab).
      this-object:splitContainer1:Panel2:Controls:Add(this-object:BtnShift).
      this-object:splitContainer1:Panel2:Controls:Add(this-object:DateEnd).
      this-object:splitContainer1:Panel2:Controls:Add(this-object:ShiftAlone).
      this-object:splitContainer1:Panel2:Controls:Add(this-object:ShiftStart).
      this-object:splitContainer1:Panel2:Controls:Add(this-object:BtnShiftend).
      this-object:splitContainer1:Panel2:Controls:Add(this-object:BtnShiftStart).
      this-object:splitContainer1:Panel2:Controls:Add(this-object:ShiftEndlab).
      this-object:splitContainer1:Panel2:Controls:Add(this-object:ShiftEnd).
      this-object:splitContainer1:Size = new System.Drawing.Size(535, 125).
      this-object:splitContainer1:SplitterDistance = 178.
      this-object:splitContainer1:TabIndex = 24.
      /*  */
      /* sShift */
      /*  */
      this-object:AutoScaleDimensions = new System.Drawing.SizeF(Progress.Util.CastUtil:ToSingle(6), Progress.Util.CastUtil:ToSingle(13)).
      this-object:Controls:Add(this-object:splitContainer1).
      this-object:Controls:Add(this-object:text3).
      this-object:Name = "sShift".
      this-object:Size = new System.Drawing.Size(538, 157).
      cast(this-object:ShiftStart, System.ComponentModel.ISupportInitialize):EndInit().
      cast(this-object:ShiftEnd, System.ComponentModel.ISupportInitialize):EndInit().
      cast(this-object:ShiftAlone, System.ComponentModel.ISupportInitialize):EndInit().
      this-object:Radio_Task:ResumeLayout(false).
      this-object:splitContainer1:Panel1:ResumeLayout(false).
      this-object:splitContainer1:Panel2:ResumeLayout(false).
      cast(this-object:splitContainer1, System.ComponentModel.ISupportInitialize):EndInit().
      this-object:splitContainer1:ResumeLayout(false).
      this-object:ResumeLayout(false).
      {gbl\ed_date_cls.i this-object:DateStart this-object:DateEnd this-object:DateAlone }
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void radioButton1_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		
		if radioButton1:Checked
		then
		   VALUE-CHANGE_RADIO-task().
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void radioButton2_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		if radioButton2:Checked
      then
         VALUE-CHANGE_RADIO-task().
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void radioButton3_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		if radioButton3:Checked
      then
         VALUE-CHANGE_RADIO-task().
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void radioButton4_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		if radioButton4:Checked
      then
         VALUE-CHANGE_RADIO-task().
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void ShiftAlone_Leave( input sender as System.Object, input e as System.EventArgs ):
		if mTrgGlb:canselForm()
      then 
         return.
      
		define variable vShift-Alone as integer no-undo.
		vShift-Alone = ShiftAlone:value.
		LEAVE_Shift-Alone(vShift-Alone).
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void ShiftEnd_Leave( input sender as System.Object, input e as System.EventArgs ):
		
		if mTrgGlb:canselForm()
      then 
         return.
		define variable vShift-End as integer no-undo.
		vShift-End = ShiftEnd:value.
		LEAVE_Shift-End (vShift-End).
		return.

	end method.

   method private void LEAVE_Date-Alone (iDate-Alone as date): /* Дата */
      mTrgLoc:LEAVE_Date-Alone(iDate-Alone).
   end.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void ShiftStart_Leave( input sender as System.Object, input e as System.EventArgs ):
		define variable vShift-Start as integer no-undo.
      vShift-Start = ShiftStart:value.
		LEAVE_Shift-Start(vShift-Start).
		return.

	end method.
	
	
	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void TOGShift2_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		val-shift2().
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void TOGShift_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		val-shift().
		VALUE-CHANGED_TOG-Shift(TOGShift:Checked).
		return.

	end method.

   method private void  val-shift ():
   
      if TOGShift:Checked = true  
      then do:
         
         shiftstart:visible = yes.
         ShiftStartlab:visible = yes.
         togshift2:visible  = yes.
         if togshift2:Checked 
         then do:
            BtnShiftend:visible = no.
         end.
         else do:
            shiftend:visible = yes.
            shiftendlab:visible = yes.
         end.

         if  mTrgLoc:avail_shift-obj()
         then do:
            BtnShiftStart:visible = yes.
            BtnShiftend:visible = not togshift2:Checked.
         end.
      end.
      else do:
         TogShift2:Checked = false.
         dateend:visible = yes.
         dateendlab:visible = yes.
         ShiftEnd:visible = no.
         ShiftEndlab:visible = no.
         ShiftStart:visible = no. 
         ShiftStartlab:visible = no.
         TogShift2:visible = no. 
         btnshiftend:visible = no. 
         btnshiftstart:visible = no.
      end.

   end method.
   method private void  val-shift2 ():
      DateEnd:value  = DateStart:value.
      ShiftEnd:value = ShiftStart:Value.
      define variable vdateend as date no-undo.
      define variable vShiftEnd as integer no-undo.
      vdateend = DateStart:value.
      vShiftEnd = ShiftEnd:value.
      mTrgLoc:set-end(vdateend, vShiftEnd).

      if TOGShift2:Checked 
      then do:
         DateEnd:visible = no.
         shiftend:visible = no.
         DateEndlab:visible = no.
         shiftendlab:visible = no.
      end.
      else do:
         DateEnd:visible = yes.
         shiftend:visible = yes.
         DateEndlab:visible = yes.
         shiftendlab:visible = yes.
      end.

      if mTrgLoc:avail_shift-obj() 
      then do:
         btnshiftend:visible = not TOGShift2:Checked .
      end.
   end method.
  
   
   method private void  VALUE-CHANGED_TOG-Shift (itog-shift as logical):
      mTrgLoc:VALUE-CHANGED_TOG-Shift (itog-shift).
   end.

   method private void  VALUE-CHANGE_RADIO-task ():
      define variable v-Date-End as date no-undo.
      define variable v-Date-Start as date no-undo.
      
      v-Date-End    = DateEnd:Value .
      v-Date-Start  = dateStart:Value.
      mTrgLoc:Set_Date-Start(v-Date-Start).
      mTrgLoc:Set_Date-End(v-Date-End).
      define variable vshift as integer no-undo.
      vshift = shiftEnd:value.
      mTrgLoc:set_shift-End(vshift) .
      vshift = shiftEnd:value.
      mTrgLoc:set_shift-Start (vshift).
      vshift = shiftEnd:value.
      mTrgLoc:set_shift-alone (vshift).
      define variable vRADIO-task as character no-undo.
      vRADIO-task = RADIO-task.
      display-radio-task (vRADIO-task).
      mTrgLoc:VALUE-CHANGE_RADIO-task( vRADIO-task).

   end.

   method private void display-RAdio-task(iRAdio-task as character ) :
      define variable vRAdio-task as integer no-undo.
      vRAdio-task = sType:RAdiotaskInt(iRAdio-task).
      case vRAdio-task :
         when  1 
         then do:
            assign
               TOGShift:Checked = false
               DateAlone:Visible = no
               ShiftAlone:Visible = no
               DateAlonelab:Visible = no
               ShiftAlonelab:Visible = no
               
               Btnshift:Visible = no
               ShiftEnd:Visible = no
               ShiftStart:Visible = no
               ShiftEndlab:Visible = no
               ShiftStartlab:Visible = no
               
               TOGShift:Visible = no
            .
            assign
               DateEnd:Visible = yes
               DateStart:Visible = yes
               DateEndlab:Visible = yes
               DateStartlab:Visible = yes
            .
            mTrgLoc:set_tog-shift (false).
         end.
         when 2 then do:
            assign
               DateAlone:Visible = no
               ShiftAlone:Visible = no
               DateAlonelab:Visible = no
               ShiftAlonelab:Visible = no
               
               Btnshift:Visible = no
               ShiftEnd:Visible = no
               ShiftStart:Visible = no
               ShiftEndlab:Visible = no
               ShiftStartlab:Visible = no
               
               TOGShift:Visible = no
               TOGShift:checked = true
            .
            assign
               DateEnd:Visible = yes
               DateStart:Visible = yes
               DateEndlab:Visible = yes
               DateStartlab:Visible = yes
            .
            mTrgLoc:set_tog-shift ( true).
         end.
   
         when 3 then do:
            assign
               DateEnd:Visible = yes
               DateStart:Visible = yes
               ShiftEnd:Visible = yes
               ShiftStart:Visible = yes
               DateEndlab:Visible = yes
               DateStartlab:Visible = yes
               ShiftEndlab:Visible = yes
               ShiftStartlab:Visible = yes
               
            .
            assign
               TOGShift:checked = true
               DateAlone:Visible = no
               ShiftAlone:Visible = no
               DateAlonelab:Visible = no
               ShiftAlonelab:Visible = no
               
               Btnshift:Visible = no
               TOGShift:Visible = no
            .
            mTrgLoc:set_tog-shift ( true).
         end.
   
         when 4 then do:
            assign
               DateEnd:Visible = yes
               DateStart:Visible = yes
               ShiftAlone:Visible = yes
               DateEndlab:Visible = yes
               DateStartlab:Visible = yes
               ShiftAlonelab:Visible = yes
            .
            assign
               DateAlone:Visible = no
               ShiftEnd:Visible = no
               DateAlonelab:Visible = no
               ShiftEndlab:Visible = no
               
               Btnshift:Visible = no
               ShiftStart:Visible = no
               ShiftStartlab:Visible = no
               TOGShift:checked = true
               TOGShift:Visible = no
            .
            define variable vShiftAlone as integer no-undo.
            vShiftAlone = ShiftAlone:value.
            mTrgLoc:set_Shift-End(vShiftAlone).
            mTrgLoc:set_Shift-Start(vShiftAlone).
            assign
               Shiftstart:Value = vShiftAlone
               ShiftEnd:Value = vShiftAlone
            .
   
            mTrgLoc:set_tog-shift ( true).
         end.
      end.
   end method.
   
   method private void display-date () :
/*Обработка первого параметра - DATE - как показывать блок с датами */


   case ParamForm:temp-param-date:
      when 0 
      then do: /*блок пустой*/
         assign
            Radio_Task:Visible = no
            TEXT3:Visible = no
            DateAlone:Visible = no
            DateAlonelab:Visible = no
            Btnshift:Visible = no
            ShiftAlone:Visible = no
            DateEnd:Visible = no
            DateStart:Visible = no
            ShiftEnd:Visible = no
            ShiftStart:Visible = no
            ShiftAlonelab:Visible = no
            DateEndlab:Visible = no
            DateStartlab:Visible = no
            ShiftEndlab:Visible = no
            ShiftStartlab:Visible = no
            
            TOGShift:Visible = no
            Radio_Period:Visible = no
         .
      end.

      when 1 
      then do: /*1 дата*/
         assign
            TEXT3:Visible = yes  
            DateAlone:Visible = yes
            DateAlonelab:Visible = yes
         .
         assign
            Radio_task:Visible = no
            DateEnd:Visible = no
            DateStart:Visible = no
            ShiftAlone:Visible = no
            DateEndlab:Visible = no
            DateStartlab:Visible = no
            ShiftAlonelab:Visible = no
            Btnshift:Visible = no
            ShiftEnd:Visible = no
            ShiftStart:Visible = no
            ShiftEndlab:Visible = no
            ShiftStartlab:Visible = no
            TOGShift:Visible = no
            Radio_Period:Visible = no
         .
      end.

      when 2 
      then do: /*2 датЫ - период*/
         assign
            TEXT3:Visible = yes
            DateEnd:Visible = yes  
            DateStart:Visible = yes
            DateEndlab:Visible = yes  
            DateStartlab:Visible = yes  
         .  
         TEXT3:Text = 'Выбор периода'.
         assign
            Radio_task:Visible = no
            DateAlone:Visible = no
            ShiftAlone:Visible = no
            DateAlonelab:Visible = no
            ShiftAlonelab:Visible = no
            Btnshift:Visible = no
            ShiftEnd:Visible = no
            ShiftStart:Visible = no
            ShiftEndlab:Visible = no
            ShiftStartlab:Visible = no
            TOGShift:Visible = no
            Radio_Period:Visible = no
         .
      end.

      when 3 
      then do: /*2 даты и 1 смена*/
         assign
            TEXT3:Visible = yes
            DateEnd:Visible = yes  
            DateStart:Visible = yes
            ShiftStart:Visible = yes   
            ShiftAlone:Visible = yes
            DateEndlab:Visible = yes  
            DateStartlab:Visible = yes
            ShiftStartlab:Visible = yes   
            ShiftAlonelab:Visible = yes  
         .
         TEXT3:Text = 'Выбор смены'.
         assign 
            DateAlone:Visible = no
            ShiftEnd:Visible = no
            shiftstart:Visible = no
            DateAlonelab:Visible = no
            ShiftEndlab:Visible = no
            shiftstartlab:Visible = no
            TOGShift:Visible = no
            RADIO_task:Visible = no
            Radio_Period:Visible = no
         .
      end.

      when 4 
      then do: /*2 даты и 2 смены*/
         if TOGShift2:Checked 
         then do:
            assign
               DateEnd:Visible = no
               shiftend:Visible = no
               DateEndlab:Visible = no
               shiftendlab:Visible = no
            .
         end.
         else do:
            assign
               DateEnd:Visible = yes
               shiftend:Visible = yes
               DateEndlab:Visible = yes
               shiftendlab:Visible = yes
            .
         end.

         assign  
            TEXT3:Visible = yes
            DateStart:Visible = yes
            ShiftStart:Visible = yes
            DateStartlab:Visible = yes
            ShiftStartlab:Visible = yes
            
            TOGShift:Visible = yes
         .

         if not togshift:Checked 
         then do:
            assign
               Shiftstart:Visible = no
               shiftend:Visible = no
               Shiftstartlab:Visible = no
               shiftendlab:Visible = no
               BtnShiftend:Visible = no
               BtnShiftStart:Visible = no
               Radio_Period:Visible = no
            .
         end.
         else do:
            if togshift2:Checked 
            then do:
               assign
                  shiftend:ReadOnly = yes 
                  BtnShiftend:visible = no
                  DateEnd:enabled = no
                  DateEndlab:enabled = no 
               .
               assign
                  Shiftstart:ReadOnly = no
                   
                  BtnShiftStart:visible = yes
               .
               Shiftstart:visible = yes .
               Shiftstartlab:visible = yes .
               assign
                  TEXT3:visible = yes
                  DateStart:visible = yes
                  DateEnd:visible = yes
                  ShiftStart:visible = yes
                  ShiftEnd:visible = yes
                  DateStartlab:visible = yes
                  DateEndlab:visible = yes
                  ShiftStartlab:visible = yes
                  ShiftEndlab:visible = yes
                  TOGShift:visible = yes
               .
            end.
            else do:
               assign
                  Shiftstart:visible = yes
                  shiftend:visible = yes
                  Shiftstartlab:visible = yes
                  shiftendlab:visible = yes
                  BtnShiftend:visible = yes
                  BtnShiftStart:visible = yes
               .
               
               assign 
                  TEXT3:visible = yes
                  DateStart:visible = yes
                  DateEnd:visible = yes
                  ShiftStart:visible = yes
                  ShiftEnd:visible = yes
                  DateStartlab:visible = yes
                  DateEndlab:visible = yes
                  ShiftStartlab:visible = yes
                  ShiftEndlab:visible = yes
                  TOGShift:visible = yes
                  DateStart:Enabled = no
                  DateEnd:Enabled = no
                  ShiftStart:Enabled = no
                  ShiftEnd:Enabled = no
                  TOGShift:Enabled = no
               .
                end.
         end.
         assign 
            DateStart:visible = yes
            DateEnd:visible = yes
            DateStartlab:visible = yes
            DateEndlab:visible = yes
            TOGShift:visible = yes
            DateStart:Enabled = yes
            DateEnd:Enabled = yes
            TOGShift:Enabled = yes
         .

         assign 
            DateAlone:visible = no
            DateAlonelab:visible = no
            Btnshift:visible = no
            ShiftAlone:visible = no
            ShiftAlonelab:visible = no
            Radio_task:visible = no
            Radio_Period:visible = no
         .
         

         /* проверка если смен нет на текущем объекте смены только там где по текущему объекту */
         if ParamForm:temp-param-obj = "" 
         then do:
            if mTrgLoc:avail_shift-obj() 
            then  do:
               assign
                  ShiftStart:visible = no
                  ShiftStartlab:visible = no
                  TOGShift:visible = no
                  ShiftEnd:visible = no
                  ShiftEndlab:visible = no
                  TOGShift2:visible = no
                  BtnShiftend:visible = no
                  BtnShiftStart:visible = no
               .
            end.
            else do:
              if togshift:Checked 
              then do:
                 BtnShiftStart:visible = yes .
                 if not togshift2:Checked 
                 then
                    BtnShiftend:visible = yes .
              end.
           end.
        end.
     end.
     when 5 
     then do: /*выбор задания*/
         assign
            TEXT3:visible = yes
            DateEnd:visible = yes
            DateStart:visible = yes
            DateEndlab:visible = yes
            DateStartlab:visible = yes
            RADIO_task:visible = yes
         .
         assign
            DateAlone:visible = no
            DateAlonelab:visible = no
            Btnshift:visible = no
            ShiftAlone:visible = no
            ShiftAlonelab:visible = no
            TOGShift:visible = no
            Radio_Period:visible = no
         .
         end.
       when 6 
       then do: /*календарные сутки сменные сутки задания*/
   
            assign
               TEXT3:visible = yes
               DateEnd:visible = yes
               DateStart:visible = yes
               DateEndlab:visible = yes
               DateStartlab:visible = yes
               RADIO_task:visible = yes
            .
            assign 
               DateAlone:visible = no
               DateAlonelab:visible = no
               Btnshift:visible = no
               ShiftAlone:visible = no
               ShiftAlonelab:visible = no
               TOGShift:visible = no
               Radio_Period:visible = no
            .
            
            radioButton3:visible = no.
            radioButton4:visible = no.
       end.
   
       when 7 
       then do: /*1 даты и 1 смена*/
          TEXT3:Text = 'Выбор смены'.
          assign
             TEXT3:visible = yes
             DateStart:visible = yes
             ShiftStart:visible = yes
             ShiftAlone:visible = yes
             DateStartlab:visible = yes
             ShiftStartlab:visible = yes
             ShiftAlonelab:visible = yes
          .
          assign 
             DateAlone:visible = no
             dateend:visible = no
             ShiftEnd:visible = no
             shiftstart:visible = no
             DateAlonelab:visible = no
             dateendlab:visible = no
             ShiftEndlab:visible = no
             shiftstartlab:visible = no
             TOGShift:visible = no
             RADIO_task:visible = no
             Radio_Period:visible = no
          .
       end.
       when 8 
       then do: /*2 даты и 2 смены смены по умолчанию */
          togshift:Checked = true .
          togshift2:Checked = false  .
          mTrgLoc:set_tog-shift( true) .
          assign
             TEXT3:visible = yes
             DateStart:visible = yes
             ShiftStart:visible = yes
             DateEnd:visible = yes
             shiftend:visible = yes
             DateStartlab:visible = yes
             ShiftStartlab:visible = yes
             DateEndlab:visible = yes
             shiftendlab:visible = yes
             BtnShiftend:visible = yes
             BtnShiftStart:visible = yes
          .
          assign  
             DateAlone:visible = no
             DateAlonelab:visible = no
             Btnshift:visible = no
             ShiftAlone:visible = no
             ShiftAlonelab:visible = no
             Radio_task:visible = no
             togshift:visible = no
             togshift2:visible = no
             Radio_Period:visible = no
          .
       end.
       when 9 then do: /* Относительные периоды*/
            TEXT3:Text ='Выбор периода'.
            assign
               RADIO_period:visible = yes
               TEXT3:visible = yes
            .
            
            assign 
               DateAlone:visible = no
               DateAlonelab:visible = no
               Btnshift:visible = no
               ShiftAlone:visible = no
               ShiftAlonelab:visible = no
               TOGShift:visible = no
               Radio_task:visible = no
               DateStart:visible = no
               DateEnd:visible = no
               DateStartlab:visible = no
               DateEndlab:visible = no
            .
         end.
      end case.
   end method.
   
   method public void local-apply-layout(iparamObj as class ibs.th.ref.sobj.sParamObj):
      assign
         DateAlone:Value   = iparamObj:X-Date-Alone  when iparamObj:X-Date-Alone ne ?
         DateEnd:Value     = iparamObj:X-Date-End    when iparamObj:X-Date-End ne ?
         DateStart:Value   = iparamObj:X-Date-Start  when iparamObj:X-Date-Start ne ?
         ShiftAlone:Value  = iparamObj:X-Shift-Alone
         ShiftEnd:Value    = iparamObj:X-Shift-End
         ShiftStart:Value  = iparamObj:X-Shift-Start
         TOGShift:Checked  = iparamObj:X-TOG-Shift
         RADIO-task        = string(iparamObj:x-RADIO-task) when iparamObj:x-RADIO-task ne 0
      .
 
      if iparamObj:x-Date-Alone = date('') then  DateAlone:Value   = ParamForm:init-Date-Alone.
      if iparamObj:x-Date-End   = date('') then  DateEnd:Value     = ParamForm:init-Date-End  .
      if iparamObj:x-Date-Start = date('') then  DateStart:Value   = ParamForm:init-Date-Start.
      if iparamObj:x-Shift-alone = 0 then        Shiftalone:Value  = ParamForm:init-shift-alone.
      if iparamObj:x-Shift-start = 0 then        Shiftstart:Value  = ParamForm:init-shift-start.
      if iparamObj:x-Shift-end = 0 then          Shiftend:Value    = ParamForm:init-shift-end  .

      if      ParamForm:temp-param-date  = 9  
         and ( radio_period:Text = ? or radio_period:Text = "" ) 
      then do:
         if ParamForm:temp-param-date-type-period <> ? 
         then radio_period:Text  = ParamForm:temp-param-date-type-period.
      end.

   
     if mTrgLoc:avail_shift-obj() 
     then  do:
        if ParamForm:temp-param-date = 4 then  togshift:Checked = true .
        if    ParamForm:temp-param-date = 8 
           or ParamForm:temp-param-date = 7 
        then  assign
                 togshift:Checked = true
                 iparamObj:x-tog-shift = true
              .
     end.

      if    ParamForm:temp-param-date < 5 
         or ParamForm:temp-param-date = 7 
      then
         radioButton1:Checked = yes.
      

      val-shift() .
      display-date () .
      define variable vdatestart as date no-undo.
      define variable vdateend as date no-undo.
      vdatestart = datestart:value.
      vdateend   = dateend:value. 
      mTrgLoc:verify-date(vDateStart, vDateEnd)  .
      if    ParamForm:temp-param-date = 5  
         or ParamForm:temp-param-date = 6
      then  display-radio-task (RADIO-task).

      if iparamObj:params-only-mode  = {&lookup} 
      then do:
         assign
            radio_task:enabled = no
            datealone:enabled = no
            togshift2:enabled = no
            togshift:enabled = no
            shiftalone:enabled = no
            shiftend:enabled = no
            datestart:enabled = no
            dateend:enabled = no
            radio_period:enabled = no
         .
      end. 
   end.
   
   method public character  AssignParam():
      define variable vdatestart as date no-undo.
      define variable vdateend as date no-undo.
      define variable vtext as character no-undo.
      vdatestart = datestart:value.
      vdateend   = dateend:value. 
      vtext = mTrgLoc:verify-date(vDateStart, vDateEnd)  no-error.
      if error-status:error
      then
         return error vtext.
   end. 
   
   destructor public sShift ( ):
      delete object mTrgLoc no-error.
   end destructor.
   
   

end class.