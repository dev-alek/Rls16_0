/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Форма редактирования и генерации пароля техпролива

Автор: Сергей Палагин
Дата создания: 21/10/18
Author: Sergey Palagin
Creation date: 21/10/18

*/
 
using Progress.Lang.*.
using Progress.Windows.Form.
using System.Windows.Forms.* from assembly.
using utl.*.
using System.Collections.Generic.*.

block-level on error undo, throw.

class utl.gpwdfrm inherits Form:
    
   define private variable btnFio as System.Windows.Forms.Button no-undo.
   define private variable btnGenerate       as System.Windows.Forms.Button         no-undo.
   define private variable btnExit           as System.Windows.Forms.Button         no-undo.
   define private variable btnToBuff         as System.Windows.Forms.Button         no-undo.
   define private variable cmbTimeEnd        as System.Windows.Forms.ComboBox       no-undo.
   define private variable cmbTimeBeg        as System.Windows.Forms.ComboBox       no-undo.
   define private variable cmbShop           as System.Windows.Forms.ComboBox       no-undo.
   define private variable cmbFio            as System.Windows.Forms.ComboBox       no-undo.
   define private variable cmbCash           as System.Windows.Forms.ComboBox       no-undo.
   define private variable components        as System.ComponentModel.IContainer    no-undo.

   define private variable dateTimePicker1   as System.Windows.Forms.DateTimePicker no-undo.
   define private variable groupBox1         as System.Windows.Forms.GroupBox       no-undo.
   define private variable label1            as System.Windows.Forms.Label          no-undo.
   define private variable label2            as System.Windows.Forms.Label          no-undo.
   define private variable label3            as System.Windows.Forms.Label          no-undo.
   define private variable label5            as System.Windows.Forms.Label          no-undo.
   define private variable label4            as System.Windows.Forms.Label          no-undo.
   define private variable label6            as System.Windows.Forms.Label          no-undo.
   define private variable label8            as System.Windows.Forms.Label          no-undo.
   define private variable label7            as System.Windows.Forms.Label          no-undo.
   define private variable lblShop as System.Windows.Forms.Label no-undo.
   define private variable maskedTextBox1 as System.Windows.Forms.MaskedTextBox no-undo.
   define private variable mtbDate as System.Windows.Forms.MaskedTextBox no-undo.
   define private variable panel1            as System.Windows.Forms.Panel          no-undo.
   define private variable panel2            as System.Windows.Forms.Panel          no-undo.
   define private variable rbtnOnce          as System.Windows.Forms.RadioButton    no-undo.
   define private variable rbtnInterval      as System.Windows.Forms.RadioButton    no-undo.
   
   define private variable tech-prol-pwd-obj as class tech-prol-pwd no-undo.
   define private variable p_state           as character no-undo. 

   define public property State as character no-undo 
      get:
         return p_state.
      end get.
      private set(iState as character):
         if not can-do("Add,Edit,View",iState) then
            undo, throw new AppError(
               substitute("Неправильный статус окна - [&1]",iState), 
               -1).
            
         p_state = iState.
         this-object:EnableDisable().
         
      end set. 

   define variable DataProvider as class utl.gpwdfrm-data no-undo.

   constructor public gpwdfrm (  ):
       
      super().
      InitializeComponent().
      this-object:ComponentsCollection:ADD(this-object:components). 
      
   end constructor.

   constructor public gpwdfrm ( 
      iState as character, 
      obj as class tech-prol-pwd):
      
      super().
      InitializeComponent().
      this-object:ComponentsCollection:ADD(this-object:components).
      
      assign
         State             = iState 
         tech-prol-pwd-obj = obj
         .
      
      Inits().
      
   end constructor.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void btnFio_Click( input sender as System.Object, input e as System.EventArgs ):
		
		cmbFio:text = DataProvider:GetCli().
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void btnGenerate_Click( input sender as System.Object, input e as System.EventArgs ):

      def var vSelectedItem as net-item no-undo.
      
      main:
      do on error undo, throw:
            
         assign 
            vSelectedItem = cast(cmbShop:SelectedItem,net-item)
         no-error.
         
         if not valid-object(vSelectedItem) then
         do:
            
         end.   
   		
   		ValidateForm().
   		
         label8:Text = string(new gpwd():gen-pwd(
            int64(cast(cmbShop:SelectedItem,net-item):DisplayName), 
            int64(cast(cmbCash:SelectedItem,net-item):DisplayName), 
            date(replace(mtbDate:Text,",",".")), 
            cmbTimeBeg:Text,
            cmbTimeEnd:Text)).
            
         this-object:tech-prol-pwd-obj = new tech-prol-pwd().
         
         tech-prol-pwd-obj:f-user = DataProvider:GetUserLogin().
         
         FormToObject(tech-prol-pwd-obj).
         
         new repoPwd(tech-prol-pwd-obj):Save().
         
         catch vErr as ValidateError :
            
            System.Windows.Forms.MessageBox:Show(
               vErr:GetMessage(1),
               "Внимание!",
               System.Windows.Forms.MessageBoxButtons:OK,
               System.Windows.Forms.MessageBoxIcon:Error).
                  
         end catch.
      end. /* main */
	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void btnToBuff_Click( input sender as System.Object, input e as System.EventArgs ):
		
		if label8:Text <> "" then
         System.Windows.Forms.Clipboard:SetText(label8:Text).
		
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void cmbCash_Validating( input sender as System.Object, input e as System.ComponentModel.CancelEventArgs ):
		
		cmbCash:text = cmbCash:text. 
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void cmbShop_SelectedValueChanged( input sender as System.Object, input e as System.EventArgs ):
		
		cmbShop-SelectedValueChanged(sender,e).

		return.

	end method.

   method private void cmbShop-SelectedValueChanged( input sender as System.Object, input e as System.EventArgs ):
      
      def var vSelectedItem as net-item no-undo.
      def var vItems as "System.Collections.Generic.List<System.Object>" no-undo.
      
      assign 
         vSelectedItem = cast(cmbShop:SelectedItem,net-item)
      no-error.
      
      if valid-object(vSelectedItem) then
      do:
         assign
            lblShop:Text = vSelectedItem:Desctiption
            vItems = DataProvider:GetCashDeskList(vSelectedItem:Value)
         .
         
         if vItems:Count = 0 then
         do:
            vItems:Add(new net-item()).
            cmbCash:DataSource = vItems.
         end.
         else
            cmbCash:DataSource = vItems. 
      end.   
      
      return.

   end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void cmbShop_Validating( input sender as System.Object, input e as System.ComponentModel.CancelEventArgs ):
		
		def var vSurr as char no-undo.
		def var vCombo as System.Windows.Forms.ComboBox no-undo.
		def var vNetItem as utl.net-item no-undo.
		
		main:
		do on error undo, throw:
		   
		   assign
            vCombo = cast(sender,System.Windows.Forms.ComboBox)
            vSurr = DataProvider:GetShopSurrogate(vCombo:text)
         .
   		
   		if vSurr = "" then
   		do:
   		   System.Windows.Forms.MessageBox:Show(
               "Нет такого кода магазина",
               "Внимание!",
               System.Windows.Forms.MessageBoxButtons:OK,
               System.Windows.Forms.MessageBoxIcon:Error).
   		   
   		   e:Cancel = yes.
   		   leave main.
         end.
         
         vNetItem = DataProvider:GetShop(vSurr).
         
         if valid-object(vNetItem) then
         do:
            assign
               vCombo:SelectedValue = vNetItem
               vCombo:Text = vNetItem:DisplayName
               lblShop:Text = vNetItem:Desctiption
            .
         end.
         
      end.
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void cmbTimeBeg_Leave( input sender as System.Object, input e as System.EventArgs ):
		
		def var vComboBox as System.Windows.Forms.ComboBox no-undo.
		def var vText as char.
		
		vComboBox = cast(sender, System.Windows.Forms.ComboBox).
		if length(vComboBox:text) = 4 then
		do:
		   assign
   		   vText = substitute("&1:&2",
   		                      substring(vComboBox:text,1,2),
   		                      substring(vComboBox:text,3,2))
   		   vComboBox:text = vText
   		.
		end.
		                       
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void cmbTimeBeg_TextChanged( input sender as System.Object, input e as System.EventArgs ):
		
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void cmbTimeBeg_Validating( input sender as System.Object, input e as System.ComponentModel.CancelEventArgs ):
      
      ValidateTimes(cast(sender, System.Windows.Forms.ComboBox)).
      
      catch vErr as ValidateError :
         
         System.Windows.Forms.MessageBox:Show(
            vErr:GetMessage(1),
            "Внимание!",
            System.Windows.Forms.MessageBoxButtons:OK,
            System.Windows.Forms.MessageBoxIcon:Error).
         e:Cancel = yes.      
      end catch.


	end method.


	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void cmbTimeEnd_Leave( input sender as System.Object, input e as System.EventArgs ):
		
      def var vComboBox as System.Windows.Forms.ComboBox no-undo.
      def var vText as char.
      
      vComboBox = cast(sender, System.Windows.Forms.ComboBox).
      if length(vComboBox:text) = 4 then
      do:
         assign
            vText = substitute("&1:&2",
                               substring(vComboBox:text,1,2),
                               substring(vComboBox:text,3,2))
            vComboBox:text = vText
         .
      end.

		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void cmbTimeEnd_Validating( input sender as System.Object, input e as System.ComponentModel.CancelEventArgs ):
	   
      ValidateTimes(cast(sender, System.Windows.Forms.ComboBox)).
      
      catch vErr as ValidateError :
         
         System.Windows.Forms.MessageBox:Show(
            vErr:GetMessage(1),
            "Внимание!",
            System.Windows.Forms.MessageBoxButtons:OK,
            System.Windows.Forms.MessageBoxIcon:Error).
         e:Cancel = yes.      
      end catch.
		
	end method.



	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void dateTimePicker1_ValueChanged( input sender as System.Object, input e as System.EventArgs ):
		
      define variable vPicker as System.Windows.Forms.DateTimePicker no-undo.
      
      vPicker = cast(sender, System.Windows.Forms.DateTimePicker).
      mtbDate:text = string(date(vPicker:value),"99.99.99").

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void gpwdfrm_KeyPress( input sender as System.Object, input e as System.Windows.Forms.KeyPressEventArgs ):
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void gpwdfrm_KeyUp( input sender as System.Object, input e as System.Windows.Forms.KeyEventArgs ):

      if e:control and e:keycode = System.Windows.Forms.Keys:d then
      do:
         dateTimePicker1:value = datetime(today).
         mtbDate:text = string(today,"99.99.99").
      end.
		
		return.

	end method.


   method public void Inits():
      
      def buffer b-clients for clients.
      def buffer b-cash-desk for cash-desk.
      
      def var vItem as class net-item no-undo.

      assign
         cmbShop:DisplayMember = "DisplayName"
         cmbShop:ValueMember = "Value"
         
         cmbCash:DisplayMember = "DisplayName"
         cmbCash:ValueMember = "Value"
         this-object:DataProvider = new gpwdfrm-data()
      .
             
      if this-object:State = "Add" then
      do:      
         assign
            cmbShop:DataSource = DataProvider:GetShopList() 
            cmbFio:DataSource =  DataProvider:GetUserList() 
         .
      end.
      
      ObjectToForm(tech-prol-pwd-obj).
      cmbShop:Focus().   
      return.

   end method.

   
   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void btnExit_Click( input sender as System.Object, input e as System.EventArgs ):
      this-object:Close().
      return.

   end method.

   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void comboBox5_SelectedIndexChanged( input sender as System.Object, input e as System.EventArgs ):
		
      return.

   end method.


	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void mtbDate_Validated( input sender as System.Object, input e as System.EventArgs ):
		
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void mtbDate_Validating( input sender as System.Object, input e as System.ComponentModel.CancelEventArgs ):
      define variable vTextBox as System.Windows.Forms.MaskedTextBox no-undo.
      define variable vDate as date no-undo.
      vTextBox = cast(sender, System.Windows.Forms.MaskedTextBox).
      
      assign 
         vDate = date(replace(vTextBox:text,",","."))
      no-error.
      if vDate = ? then
         undo, throw new utl.ValidateError("Неверная дата",-1).
      
      catch vErr as ValidateError :
         
         System.Windows.Forms.MessageBox:Show(
            vErr:GetMessage(1),
            "Внимание!",
            System.Windows.Forms.MessageBoxButtons:OK,
            System.Windows.Forms.MessageBoxIcon:Error).
         e:Cancel = yes.      
      end catch.
		

	end method.

   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void rbtnInterval_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		
      rbtnInterval-CheckedChanged(sender,e).
      return.

   end method.

   method private void rbtnInterval-CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
      
      define variable vButton as System.Windows.Forms.RadioButton no-undo.
      
      vButton = cast(sender,System.Windows.Forms.RadioButton).
      
      if valid-object(vButton) and
         vButton:Checked then
      do:
         this-object:EnableTimes().
      end.
      
      return.

   end method.

   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void rbtnOnce_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		
      rbtnOnce-CheckedChanged(sender,e).
		
      return.

   end method.

   method private void rbtnOnce-CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
      
      define variable vButton as System.Windows.Forms.RadioButton no-undo.
      
      vButton = cast(sender,System.Windows.Forms.RadioButton).
      
      if valid-object(vButton) and
         vButton:Checked then
      do:
         this-object:DisableTimes().
         this-object:ClearTimes().
      end.
      
      return.

   end method.

   method public void Wait ( ):
      wait-for Application:Run ( this-object ).
   end method.

   method private void InitializeComponent(  ):
      
      /* NOTE: The following method is automatically generated.
      
      We strongly suggest that the contents of this method only be modified using the
      Visual Designer to avoid any incompatible modifications.
      
      Modifying the contents of this method using a code editor will invalidate any support for this file. */
      this-object:panel1 = new System.Windows.Forms.Panel().
      this-object:panel2 = new System.Windows.Forms.Panel().
      this-object:mtbDate = new System.Windows.Forms.MaskedTextBox().
      this-object:maskedTextBox1 = new System.Windows.Forms.MaskedTextBox().
      this-object:lblShop = new System.Windows.Forms.Label().
      this-object:label8 = new System.Windows.Forms.Label().
      this-object:label7 = new System.Windows.Forms.Label().
      this-object:cmbFio = new System.Windows.Forms.ComboBox().
      this-object:label6 = new System.Windows.Forms.Label().
      this-object:cmbTimeEnd = new System.Windows.Forms.ComboBox().
      this-object:cmbTimeBeg = new System.Windows.Forms.ComboBox().
      this-object:label4 = new System.Windows.Forms.Label().
      this-object:label5 = new System.Windows.Forms.Label().
      this-object:dateTimePicker1 = new System.Windows.Forms.DateTimePicker().
      this-object:cmbCash = new System.Windows.Forms.ComboBox().
      this-object:cmbShop = new System.Windows.Forms.ComboBox().
      this-object:rbtnInterval = new System.Windows.Forms.RadioButton().
      this-object:rbtnOnce = new System.Windows.Forms.RadioButton().
      this-object:groupBox1 = new System.Windows.Forms.GroupBox().
      this-object:label3 = new System.Windows.Forms.Label().
      this-object:label2 = new System.Windows.Forms.Label().
      this-object:label1 = new System.Windows.Forms.Label().
      this-object:btnGenerate = new System.Windows.Forms.Button().
      this-object:btnExit = new System.Windows.Forms.Button().
      this-object:btnToBuff = new System.Windows.Forms.Button().
      this-object:btnFio = new System.Windows.Forms.Button().
      this-object:panel1:SuspendLayout().
      this-object:panel2:SuspendLayout().
      this-object:SuspendLayout().
      /*  */
      /* panel1 */
      /*  */
      this-object:panel1:Controls:Add(this-object:panel2).
      this-object:panel1:Controls:Add(this-object:btnGenerate).
      this-object:panel1:Controls:Add(this-object:btnExit).
      this-object:panel1:Location = new System.Drawing.Point(0, 3).
      this-object:panel1:Name = "panel1".
      this-object:panel1:Size = new System.Drawing.Size(669, 326).
      this-object:panel1:TabIndex = 0.
      /*  */
      /* panel2 */
      /*  */
      this-object:panel2:BorderStyle = System.Windows.Forms.BorderStyle:Fixed3D.
      this-object:panel2:Controls:Add(this-object:mtbDate).
      this-object:panel2:Controls:Add(this-object:maskedTextBox1).
      this-object:panel2:Controls:Add(this-object:lblShop).
      this-object:panel2:Controls:Add(this-object:label8).
      this-object:panel2:Controls:Add(this-object:label7).
      this-object:panel2:Controls:Add(this-object:cmbFio).
      this-object:panel2:Controls:Add(this-object:label6).
      this-object:panel2:Controls:Add(this-object:cmbTimeEnd).
      this-object:panel2:Controls:Add(this-object:cmbTimeBeg).
      this-object:panel2:Controls:Add(this-object:label4).
      this-object:panel2:Controls:Add(this-object:label5).
      this-object:panel2:Controls:Add(this-object:dateTimePicker1).
      this-object:panel2:Controls:Add(this-object:cmbCash).
      this-object:panel2:Controls:Add(this-object:cmbShop).
      this-object:panel2:Controls:Add(this-object:rbtnInterval).
      this-object:panel2:Controls:Add(this-object:rbtnOnce).
      this-object:panel2:Controls:Add(this-object:groupBox1).
      this-object:panel2:Controls:Add(this-object:label3).
      this-object:panel2:Controls:Add(this-object:label2).
      this-object:panel2:Controls:Add(this-object:label1).
      this-object:panel2:Location = new System.Drawing.Point(12, 53).
      this-object:panel2:Name = "panel2".
      this-object:panel2:Size = new System.Drawing.Size(657, 273).
      this-object:panel2:TabIndex = 2.
      /*  */
      /* mtbDate */
      /*  */
      this-object:mtbDate:Location = new System.Drawing.Point(67, 107).
      this-object:mtbDate:Mask = "00.00.00".
      this-object:mtbDate:Name = "mtbDate".
      this-object:mtbDate:Size = new System.Drawing.Size(90, 26).
      this-object:mtbDate:TabIndex = 3.
      this-object:mtbDate:Validating:Subscribe(this-object:mtbDate_Validating).
      this-object:mtbDate:Validated:Subscribe(this-object:mtbDate_Validated).
      /*  */
      /* maskedTextBox1 */
      /*  */
      this-object:maskedTextBox1:Location = new System.Drawing.Point(67, 109).
      this-object:maskedTextBox1:Mask = "00.00.00".
      this-object:maskedTextBox1:Name = "maskedTextBox1".
      this-object:maskedTextBox1:Size = new System.Drawing.Size(90, 26).
      this-object:maskedTextBox1:TabIndex = 17.
      /*  */
      /* lblShop */
      /*  */
      this-object:lblShop:Location = new System.Drawing.Point(219, 29).
      this-object:lblShop:Name = "lblShop".
      this-object:lblShop:Size = new System.Drawing.Size(100, 23).
      this-object:lblShop:TabIndex = 16.
      this-object:lblShop:UseCompatibleTextRendering = true.
      /*  */
      /* label8 */
      /*  */
      this-object:label8:Location = new System.Drawing.Point(279, 183).
      this-object:label8:Name = "label8".
      this-object:label8:Size = new System.Drawing.Size(111, 23).
      this-object:label8:TabIndex = 15.
      this-object:label8:UseCompatibleTextRendering = true.
      /*  */
      /* label7 */
      /*  */
      this-object:label7:Location = new System.Drawing.Point(219, 183).
      this-object:label7:Name = "label7".
      this-object:label7:Size = new System.Drawing.Size(72, 23).
      this-object:label7:TabIndex = 14.
      this-object:label7:Text = "Пароль:".
      this-object:label7:UseCompatibleTextRendering = true.
      /*  */
      /* cmbFio */
      /*  */
      this-object:cmbFio:FormattingEnabled = true.
      this-object:cmbFio:Location = new System.Drawing.Point(396, 142).
      this-object:cmbFio:Name = "cmbFio".
      this-object:cmbFio:Size = new System.Drawing.Size(175, 21).
      this-object:cmbFio:TabIndex = 6.
      this-object:cmbFio:SelectedIndexChanged:Subscribe(this-object:comboBox5_SelectedIndexChanged).
      /*  */
      /* label6 */
      /*  */
      this-object:label6:Location = new System.Drawing.Point(219, 142).
      this-object:label6:Name = "label6".
      this-object:label6:Size = new System.Drawing.Size(171, 23).
      this-object:label6:TabIndex = 13.
      this-object:label6:Text = "ФИО заказчика пароля:".
      this-object:label6:UseCompatibleTextRendering = true.
      /*  */
      /* cmbTimeEnd */
      /*  */
      this-object:cmbTimeEnd:FormattingEnabled = true.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar0 as System.Object extent 49 no-undo.
      arrayvar0[1] = "".
      arrayvar0[2] = "00:00".
      arrayvar0[3] = "00:30".
      arrayvar0[4] = "01:00".
      arrayvar0[5] = "01:30".
      arrayvar0[6] = "02:00".
      arrayvar0[7] = "02:30".
      arrayvar0[8] = "03:00".
      arrayvar0[9] = "03:30".
      arrayvar0[10] = "04:00".
      arrayvar0[11] = "04:30".
      arrayvar0[12] = "05:00".
      arrayvar0[13] = "05:30".
      arrayvar0[14] = "06:00".
      arrayvar0[15] = "06:30".
      arrayvar0[16] = "07:00".
      arrayvar0[17] = "07:30".
      arrayvar0[18] = "08:00".
      arrayvar0[19] = "08:30".
      arrayvar0[20] = "09:00".
      arrayvar0[21] = "09:30".
      arrayvar0[22] = "10:00".
      arrayvar0[23] = "10:30".
      arrayvar0[24] = "11:00".
      arrayvar0[25] = "11:30".
      arrayvar0[26] = "12:00".
      arrayvar0[27] = "12:30".
      arrayvar0[28] = "13:00".
      arrayvar0[29] = "13:30".
      arrayvar0[30] = "14:00".
      arrayvar0[31] = "14:30".
      arrayvar0[32] = "15:00".
      arrayvar0[33] = "15:30".
      arrayvar0[34] = "16:00".
      arrayvar0[35] = "16:30".
      arrayvar0[36] = "17:00".
      arrayvar0[37] = "17:30".
      arrayvar0[38] = "18:00".
      arrayvar0[39] = "18:30".
      arrayvar0[40] = "19:00".
      arrayvar0[41] = "19:30".
      arrayvar0[42] = "20:00".
      arrayvar0[43] = "20:30".
      arrayvar0[44] = "21:00".
      arrayvar0[45] = "21:30".
      arrayvar0[46] = "22:00".
      arrayvar0[47] = "22:30".
      arrayvar0[48] = "23:00".
      arrayvar0[49] = "23:30".
      this-object:cmbTimeEnd:Items:AddRange(arrayvar0).
      this-object:cmbTimeEnd:Location = new System.Drawing.Point(396, 97).
      this-object:cmbTimeEnd:Name = "cmbTimeEnd".
      this-object:cmbTimeEnd:Size = new System.Drawing.Size(121, 21).
      this-object:cmbTimeEnd:TabIndex = 5.
      this-object:cmbTimeEnd:Leave:Subscribe(this-object:cmbTimeEnd_Leave).
      this-object:cmbTimeEnd:Validating:Subscribe(this-object:cmbTimeEnd_Validating).
      /*  */
      /* cmbTimeBeg */
      /*  */
      this-object:cmbTimeBeg:FormattingEnabled = true.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar1 as System.Object extent 49 no-undo.
      arrayvar1[1] = "".
      arrayvar1[2] = "00:00".
      arrayvar1[3] = "00:30".
      arrayvar1[4] = "01:00".
      arrayvar1[5] = "01:30".
      arrayvar1[6] = "02:00".
      arrayvar1[7] = "02:30".
      arrayvar1[8] = "03:00".
      arrayvar1[9] = "03:30".
      arrayvar1[10] = "04:00".
      arrayvar1[11] = "04:30".
      arrayvar1[12] = "05:00".
      arrayvar1[13] = "05:30".
      arrayvar1[14] = "06:00".
      arrayvar1[15] = "06:30".
      arrayvar1[16] = "07:00".
      arrayvar1[17] = "07:30".
      arrayvar1[18] = "08:00".
      arrayvar1[19] = "08:30".
      arrayvar1[20] = "09:00".
      arrayvar1[21] = "09:30".
      arrayvar1[22] = "10:00".
      arrayvar1[23] = "10:30".
      arrayvar1[24] = "11:00".
      arrayvar1[25] = "11:30".
      arrayvar1[26] = "12:00".
      arrayvar1[27] = "12:30".
      arrayvar1[28] = "13:00".
      arrayvar1[29] = "13:30".
      arrayvar1[30] = "14:00".
      arrayvar1[31] = "14:30".
      arrayvar1[32] = "15:00".
      arrayvar1[33] = "15:30".
      arrayvar1[34] = "16:00".
      arrayvar1[35] = "16:30".
      arrayvar1[36] = "17:00".
      arrayvar1[37] = "17:30".
      arrayvar1[38] = "18:00".
      arrayvar1[39] = "18:30".
      arrayvar1[40] = "19:00".
      arrayvar1[41] = "19:30".
      arrayvar1[42] = "20:00".
      arrayvar1[43] = "20:30".
      arrayvar1[44] = "21:00".
      arrayvar1[45] = "21:30".
      arrayvar1[46] = "22:00".
      arrayvar1[47] = "22:30".
      arrayvar1[48] = "23:00".
      arrayvar1[49] = "23:30".
      this-object:cmbTimeBeg:Items:AddRange(arrayvar1).
      this-object:cmbTimeBeg:Location = new System.Drawing.Point(396, 62).
      this-object:cmbTimeBeg:Name = "cmbTimeBeg".
      this-object:cmbTimeBeg:Size = new System.Drawing.Size(121, 21).
      this-object:cmbTimeBeg:TabIndex = 4.
      this-object:cmbTimeBeg:TextChanged:Subscribe(this-object:cmbTimeBeg_TextChanged).
      this-object:cmbTimeBeg:Leave:Subscribe(this-object:cmbTimeBeg_Leave).
      this-object:cmbTimeBeg:Validating:Subscribe(this-object:cmbTimeBeg_Validating).
      /*  */
      /* label4 */
      /*  */
      this-object:label4:Location = new System.Drawing.Point(219, 97).
      this-object:label4:Name = "label4".
      this-object:label4:Size = new System.Drawing.Size(171, 23).
      this-object:label4:TabIndex = 11.
      this-object:label4:Text = "Время завершения:".
      this-object:label4:UseCompatibleTextRendering = true.
      /*  */
      /* label5 */
      /*  */
      this-object:label5:Location = new System.Drawing.Point(219, 62).
      this-object:label5:Name = "label5".
      this-object:label5:Size = new System.Drawing.Size(171, 23).
      this-object:label5:TabIndex = 10.
      this-object:label5:Text = "Время начала:".
      this-object:label5:UseCompatibleTextRendering = true.
      /*  */
      /* dateTimePicker1 */
      /*  */
      this-object:dateTimePicker1:CustomFormat = "dd.MM.yyyy".
      this-object:dateTimePicker1:Format = System.Windows.Forms.DateTimePickerFormat:Custom.
      this-object:dateTimePicker1:Location = new System.Drawing.Point(67, 107).
      this-object:dateTimePicker1:Name = "dateTimePicker1".
      this-object:dateTimePicker1:Size = new System.Drawing.Size(121, 26).
      this-object:dateTimePicker1:TabIndex = 3.
      this-object:dateTimePicker1:TabStop = false.
      this-object:dateTimePicker1:ValueChanged:Subscribe(this-object:dateTimePicker1_ValueChanged).
      /*  */
      /* cmbCash */
      /*  */
      this-object:cmbCash:FormattingEnabled = true.
      this-object:cmbCash:Location = new System.Drawing.Point(67, 64).
      this-object:cmbCash:Name = "cmbCash".
      this-object:cmbCash:Size = new System.Drawing.Size(121, 21).
      this-object:cmbCash:TabIndex = 2.
      this-object:cmbCash:Validating:Subscribe(this-object:cmbCash_Validating).
      /*  */
      /* cmbShop */
      /*  */
      this-object:cmbShop:FormattingEnabled = true.
      this-object:cmbShop:Location = new System.Drawing.Point(67, 29).
      this-object:cmbShop:Name = "cmbShop".
      this-object:cmbShop:Size = new System.Drawing.Size(121, 21).
      this-object:cmbShop:TabIndex = 1.
      this-object:cmbShop:SelectedValueChanged:Subscribe(this-object:cmbShop_SelectedValueChanged).
      this-object:cmbShop:Validating:Subscribe(this-object:cmbShop_Validating).
      /*  */
      /* rbtnInterval */
      /*  */
      this-object:rbtnInterval:Checked = true.
      this-object:rbtnInterval:Location = new System.Drawing.Point(9, 214).
      this-object:rbtnInterval:Name = "rbtnInterval".
      this-object:rbtnInterval:Size = new System.Drawing.Size(164, 24).
      this-object:rbtnInterval:TabIndex = 5.
      this-object:rbtnInterval:TabStop = true.
      this-object:rbtnInterval:Text = "Интервальный".
      this-object:rbtnInterval:UseCompatibleTextRendering = true.
      this-object:rbtnInterval:UseVisualStyleBackColor = true.
      this-object:rbtnInterval:Visible = false.
      this-object:rbtnInterval:CheckedChanged:Subscribe(this-object:rbtnInterval_CheckedChanged).
      /*  */
      /* rbtnOnce */
      /*  */
      this-object:rbtnOnce:Location = new System.Drawing.Point(9, 184).
      this-object:rbtnOnce:Name = "rbtnOnce".
      this-object:rbtnOnce:Size = new System.Drawing.Size(137, 24).
      this-object:rbtnOnce:TabIndex = 4.
      this-object:rbtnOnce:Text = "Разовый".
      this-object:rbtnOnce:UseCompatibleTextRendering = true.
      this-object:rbtnOnce:UseVisualStyleBackColor = true.
      this-object:rbtnOnce:Visible = false.
      this-object:rbtnOnce:CheckedChanged:Subscribe(this-object:rbtnOnce_CheckedChanged).
      /*  */
      /* groupBox1 */
      /*  */
      this-object:groupBox1:Location = new System.Drawing.Point(3, 153).
      this-object:groupBox1:Name = "groupBox1".
      this-object:groupBox1:Size = new System.Drawing.Size(185, 100).
      this-object:groupBox1:TabIndex = 5.
      this-object:groupBox1:TabStop = false.
      this-object:groupBox1:Text = "Тип пароля:".
      this-object:groupBox1:UseCompatibleTextRendering = true.
      this-object:groupBox1:Visible = false.
      /*  */
      /* label3 */
      /*  */
      this-object:label3:Location = new System.Drawing.Point(0, 107).
      this-object:label3:Name = "label3".
      this-object:label3:Size = new System.Drawing.Size(100, 23).
      this-object:label3:TabIndex = 2.
      this-object:label3:Text = "Дата:".
      this-object:label3:UseCompatibleTextRendering = true.
      /*  */
      /* label2 */
      /*  */
      this-object:label2:Location = new System.Drawing.Point(3, 64).
      this-object:label2:Name = "label2".
      this-object:label2:Size = new System.Drawing.Size(100, 23).
      this-object:label2:TabIndex = 1.
      this-object:label2:Text = "Касса:".
      this-object:label2:UseCompatibleTextRendering = true.
      /*  */
      /* label1 */
      /*  */
      this-object:label1:Location = new System.Drawing.Point(3, 29).
      this-object:label1:Name = "label1".
      this-object:label1:Size = new System.Drawing.Size(100, 23).
      this-object:label1:TabIndex = 0.
      this-object:label1:Text = "Магазин:".
      this-object:label1:UseCompatibleTextRendering = true.
      /*  */
      /* btnGenerate */
      /*  */
      this-object:btnGenerate:Location = new System.Drawing.Point(104, 24).
      this-object:btnGenerate:Name = "btnGenerate".
      this-object:btnGenerate:Size = new System.Drawing.Size(96, 23).
      this-object:btnGenerate:TabIndex = 8.
      this-object:btnGenerate:Text = "Генерация".
      this-object:btnGenerate:UseCompatibleTextRendering = true.
      this-object:btnGenerate:UseVisualStyleBackColor = true.
      this-object:btnGenerate:Click:Subscribe(this-object:btnGenerate_Click).
      /*  */
      /* btnExit */
      /*  */
      this-object:btnExit:Location = new System.Drawing.Point(12, 23).
      this-object:btnExit:Name = "btnExit".
      this-object:btnExit:Size = new System.Drawing.Size(86, 23).
      this-object:btnExit:TabIndex = 0.
      this-object:btnExit:Text = "Выход".
      this-object:btnExit:UseCompatibleTextRendering = true.
      this-object:btnExit:UseVisualStyleBackColor = true.
      this-object:btnExit:Click:Subscribe(this-object:btnExit_Click).
      /*  */
      /* btnToBuff */
      /*  */
      this-object:btnToBuff:Location = new System.Drawing.Point(410, 238).
      this-object:btnToBuff:Name = "btnToBuff".
      this-object:btnToBuff:Size = new System.Drawing.Size(94, 23).
      this-object:btnToBuff:TabIndex = 8.
      this-object:btnToBuff:Text = "в буфер".
      this-object:btnToBuff:UseCompatibleTextRendering = true.
      this-object:btnToBuff:UseVisualStyleBackColor = true.
      this-object:btnToBuff:Click:Subscribe(this-object:btnToBuff_Click).
      /*  */
      /* btnFio */
      /*  */
      this-object:btnFio:Location = new System.Drawing.Point(589, 200).
      this-object:btnFio:Name = "btnFio".
      this-object:btnFio:Size = new System.Drawing.Size(55, 23).
      this-object:btnFio:TabIndex = 7.
      this-object:btnFio:Text = "ФИО".
      this-object:btnFio:UseCompatibleTextRendering = true.
      this-object:btnFio:UseVisualStyleBackColor = true.
      this-object:btnFio:Click:Subscribe(this-object:btnFio_Click).
      /*  */
      /* gpwdfrm */
      /*  */
      this-object:ClientSize = new System.Drawing.Size(669, 346).
      this-object:Controls:Add(this-object:btnFio).
      this-object:Controls:Add(this-object:btnToBuff).
      this-object:Controls:Add(this-object:panel1).
      this-object:Name = "gpwdfrm".
      this-object:Text = "Генерация пароля для технологического пролива".
      this-object:KeyPress:Subscribe(this-object:gpwdfrm_KeyPress).
      this-object:KeyUp:Subscribe(this-object:gpwdfrm_KeyUp).
      this-object:panel1:ResumeLayout(false).
      this-object:panel2:ResumeLayout(false).
      this-object:panel2:PerformLayout().
      this-object:ResumeLayout(false).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end method.

   method public static utl.gpwdfrm GetObject(
      iState as character, 
      iPwd as class tech-prol-pwd):
         
      return new gpwdfrm(iState,iPwd).
      
   end method.

   method public void EnableDisable():
      
      main:
      do:
         case this-object:State:
            when "View" then EnableDisableForView(). 
            when "Add" or 
            when "Edit" then EnableDisableForAddEdit().
         end case. 
      end.
      
   end method.
   
   method public void EnableDisableForView():
      
      assign 
         btnGenerate:Enabled     = no
         btnGenerate:visible     = no
         cmbTimeBeg:Enabled      = no
         cmbTimeEnd:Enabled      = no
         cmbShop:Enabled         = no
         cmbCash:Enabled         = no
         dateTimePicker1:Enabled = no
         dateTimePicker1:visible = no
         cmbFio:Enabled          = no
         rbtnOnce:Enabled        = no
         rbtnInterval:Enabled    = no
         btnFio:enabled          = no
         btnFio:visible          = no
         mtbDate:enabled         = no
         .
   end method.

   method public void EnableDisableForAddEdit():
      
      assign 
         btnGenerate:Enabled     = yes
         cmbShop:Enabled         = yes
         cmbCash:Enabled         = yes
         dateTimePicker1:Enabled = yes
         cmbFio:Enabled          = yes
         rbtnOnce:Enabled        = yes
         rbtnInterval:Enabled    = yes
         label8:Visible          = yes
         btnToBuff:Visible       = yes
         btnToBuff:Enabled       = yes
         btnFio:enabled          = yes
         
         .
         
      if rbtnOnce:Checked then
         DisableTimes().
      else
         EnableTimes().
         
   end method.
   

   method public void EnableTimes():
      
      assign
         cmbTimeBeg:Enabled = yes
         cmbTimeEnd:Enabled = yes
         .
      
   end method.
   
   method public void DisableTimes():
      
      assign
         cmbTimeBeg:Enabled = no
         cmbTimeEnd:Enabled = no
         .
      
   end method.

   method public void ClearTimes():
      
      assign
         /* cmbTimeBeg:Text = "" */
         cmbTimeEnd:Text = ""
         .
      
   end method.

   method public void FormToObject(iObj as class tech-prol-pwd):
      
      def var vNow as datetime no-undo.
      
      assign
         vNow = now
         iObj:f-beg-time = cmbTimeBeg:Text
         iObj:f-end-time = cmbTimeEnd:Text 
         iObj:f-host = System.Net.Dns:GetHostName()
         iObj:cash-desk-surr = cast(cmbCash:SelectedItem,utl.net-item):value
         iObj:shop-surr = cast(cmbShop:SelectedItem,utl.net-item):value
         iObj:f-date = date(replace(mtbDate:text,",","."))
         iObj:f-time = vNow
         iObj:f-fio = cmbFio:Text
         iObj:f-pwd-type = if rbtnOnce:Checked then "Р" else "И"
         iObj:f-pwd = label8:Text
      .
            
   end method.

   method public void ObjectToForm(iObj as class tech-prol-pwd):
      
      def var vNetItem as class net-item no-undo.
      
      assign
         cmbTimeBeg:Text = iObj:f-beg-time
         cmbTimeEnd:Text = iObj:f-end-time  
         cmbFio:Text = iObj:f-fio
         label8:Text = iObj:f-pwd
      .
      if tech-prol-pwd-obj:f-pwd-type = "Р" then 
         rbtnOnce:Checked = yes. 
      else 
         rbtnInterval:Checked = yes.
         
      vNetItem = DataProvider:GetShop(iObj:shop-surr).
      
      if valid-object(vNetItem) then
      do:
         assign
            cmbShop:SelectedValue = vNetItem
            cmbShop:Text = vNetItem:DisplayName
            lblShop:Text = vNetItem:Desctiption
         .
      end.
      
      vNetItem = DataProvider:GetCashDesk(iObj:cash-desk-surr).
      if valid-object(vNetItem) then
      do:
         assign
            cmbCash:SelectedValue = vNetItem
            cmbCash:Text = vNetItem:DisplayName
         .
      end.
      define variable vDate as date no-undo.
      
      vDate = if iObj:f-date = ? then today else iObj:f-date.
      
      dateTimePicker1:value = datetime(vDate).
      mtbDate:text = string(vDate,"99.99.99").
   end method.

   method public void ValidateForm():
      
      def var vShop as int64 no-undo.
      
      DataProvider:ValidateShop(cmbShop:Text, cmbShop).
      DataProvider:ValidateCashDesk(
         DataProvider:GetShopSurrogate(cmbShop:Text),
         cmbCash:Text, 
         cmbCash).
         
      if rbtnInterval:Checked then
      do:
         if cmbTimeBeg:Text = "" then
         do:
            cmbTimeBeg:Focus().
            undo, throw new ValidateError("Не указано время начала техпролива",-1).
         end.
         if cmbTimeEnd:Text = "" then
         do:
            cmbTimeEnd:Focus().
            undo, throw new ValidateError("Не указано время окончания техпролива",-1).
         end. 
         if cmbTimeBeg:text > cmbTimeEnd:text then do:
            cmbTimeEnd:Focus().
            undo, throw new ValidateError("Время начала позже времени конца",-1).
         end.
      end.
      
      ValidateTimes(cmbTimeBeg).
      ValidateTimes(cmbTimeEnd).
      
      if cmbFio:Text = "" then
      do:
         cmbFio:Focus().
         undo, throw new ValidateError("Не указано ФИО заказчика техпролива",-1).
      end.
      
      
            
   end method.
   
   method public void ValidateTimes(iComboBox as System.Windows.Forms.ComboBox):
      
      define variable vDigit as int64 no-undo.
      
      if num-entries(iComboBox:Text, ":") <> 2 then
      do:
         iComboBox:Focus().
         undo, throw new ValidateError("Введено некорректное время",-1).
      end.   
      
      assign
         vDigit = int64(entry(1,iComboBox:Text,":"))
      no-error.
      
      if error-status:error or 
         not (vDigit >= 0 and vDigit <= 23) then
      do:
         iComboBox:Focus().
         undo, throw new ValidateError("Введено некорректное время",-1).
      end.   
            
      assign
         vDigit = int64(entry(2,iComboBox:Text,":"))
      no-error.
      
      if error-status:error or 
         not (vDigit = 0 or vDigit = 30) then
      do:
         iComboBox:Focus().
         undo, throw new ValidateError("Введено некорректное время",-1).
      end.   
      
   end method.
   
   destructor public gpwdfrm ( ):

   end destructor.

end class.