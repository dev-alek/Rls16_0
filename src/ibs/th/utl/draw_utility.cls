 
 /*------------------------------------------------------------------------
    File        : draw_utility
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : druban
    Created     : Mon Oct 22 02:27:27 MSK 2018
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Progress.Windows.Form.

block-level on error undo, throw.

class ibs.th.utl.draw_utility inherits Form: 
  
  DEFINE PRIVATE VARIABLE button10 AS System.Windows.Forms.Button NO-UNDO.
  define private variable button11 as System.Windows.Forms.Button no-undo.
  define private variable button12 as System.Windows.Forms.Button no-undo.
  define private variable button2 as System.Windows.Forms.Button no-undo.
  define private variable button3 as System.Windows.Forms.Button no-undo.
  define private variable button4 as System.Windows.Forms.Button no-undo.
  define private variable button5 as System.Windows.Forms.Button no-undo.
    define private variable button6 as System.Windows.Forms.Button no-undo.
   define private variable button7 as System.Windows.Forms.Button no-undo.
   define private variable button9 as System.Windows.Forms.Button no-undo.
   define private variable button8 as System.Windows.Forms.Button no-undo.
  define private variable checkBox18 as System.Windows.Forms.CheckBox no-undo.
  define private variable checkBox17 as System.Windows.Forms.CheckBox no-undo.
  define private variable checkBox16 as System.Windows.Forms.CheckBox no-undo.
  define private variable checkBox15 as System.Windows.Forms.CheckBox no-undo.
  define private variable checkBox14 as System.Windows.Forms.CheckBox no-undo.
  define private variable checkBox13 as System.Windows.Forms.CheckBox no-undo.
  define private variable checkBox12 as System.Windows.Forms.CheckBox no-undo.
  define private variable checkBox11 as System.Windows.Forms.CheckBox no-undo.
  define private variable checkBox10 as System.Windows.Forms.CheckBox no-undo.
    define private variable checkBox19 as System.Windows.Forms.CheckBox no-undo.
    define private variable checkBox21 as System.Windows.Forms.CheckBox no-undo.
    define private variable checkBox20 as System.Windows.Forms.CheckBox no-undo.
    define private variable checkBox22 as System.Windows.Forms.CheckBox no-undo.
    define private variable checkBox24 as System.Windows.Forms.CheckBox no-undo.
    define private variable checkBox23 as System.Windows.Forms.CheckBox no-undo.
  define private variable checkBox25 as System.Windows.Forms.CheckBox no-undo.
  define private variable checkBox26 as System.Windows.Forms.CheckBox no-undo.
  define private variable checkBox27 as System.Windows.Forms.CheckBox no-undo.
   define private variable checkBox29 as System.Windows.Forms.CheckBox no-undo.
  define private variable checkBox30 as System.Windows.Forms.CheckBox no-undo.
  define private variable checkBox6 as System.Windows.Forms.CheckBox no-undo.
  define private variable checkBox5 as System.Windows.Forms.CheckBox no-undo.
  define private variable checkBox4 as System.Windows.Forms.CheckBox no-undo.
  define private variable checkBox3 as System.Windows.Forms.CheckBox no-undo.
  define private variable checkBox2 as System.Windows.Forms.CheckBox no-undo.
  define private variable checkBox1 as System.Windows.Forms.CheckBox no-undo.
  define private variable button1 as System.Windows.Forms.Button no-undo.
  define private variable checkBox8 as System.Windows.Forms.CheckBox no-undo.
  define private variable checkBox7 as System.Windows.Forms.CheckBox no-undo.
  define private variable checkBox9 as System.Windows.Forms.CheckBox no-undo.
  define private variable components as System.ComponentModel.IContainer no-undo.
   define private variable delemc as System.Windows.Forms.CheckBox no-undo.
  define private variable label19 as System.Windows.Forms.Label no-undo.
  define private variable label2 as System.Windows.Forms.Label no-undo.
  define private variable label3 as System.Windows.Forms.Label no-undo.
   define private variable label4 as System.Windows.Forms.Label no-undo.
  define private variable label5 as System.Windows.Forms.Label no-undo.
  define private variable Lincasagent as System.Windows.Forms.Label no-undo.
    define private variable listBox1 as System.Windows.Forms.ListBox no-undo.
   define private variable listBox2 as System.Windows.Forms.ListBox no-undo.
  define private variable openFileDialog1 as System.Windows.Forms.OpenFileDialog no-undo.
   define private variable sendemc as System.Windows.Forms.CheckBox no-undo.
   define private variable tabPage4 as System.Windows.Forms.TabPage no-undo.
   define private variable tabPage5 as System.Windows.Forms.TabPage no-undo.
  define private variable textBox1 as System.Windows.Forms.TextBox no-undo.
  define private variable tabPage3 as System.Windows.Forms.TabPage no-undo.
  define private variable tabPage2 as System.Windows.Forms.TabPage no-undo.
  define private variable tabPage1 as System.Windows.Forms.TabPage no-undo.
  define private variable tabControl1 as System.Windows.Forms.TabControl no-undo.
  define private variable label1 as System.Windows.Forms.Label no-undo.
  define private variable mUtil  as class ibs.th.utl.method-for-draw-utility no-undo.
  define private variable textBox2 as System.Windows.Forms.TextBox no-undo.
  define private variable textBox3 as System.Windows.Forms.TextBox no-undo.
   define private variable textBox4 as System.Windows.Forms.TextBox no-undo.
  define property parparentproc as handle no-undo
  get.
  set(input iH as handle):
     parparentproc = iH.
     mUtil:parparentproc = parparentproc.
     InitChekBox().
  end.
     
  constructor public draw_utility (  ):
   {cmp/str-glbl.i class}
    super().
    InitializeComponent().
    this-object:ComponentsCollection:ADD(this-object:components).
    mUtil  = new ibs.th.utl.method-for-draw-utility().
    mutil:write-log:SUBSCRIBE (this-object:write-log).
      textBox1:text = getPARAM("host").
      if textBox1:text eq ""
      then 
      textBox1:text = "localhost:8080".
      textBox2:text = getPARAM("correspondence_gds").
      textBox3:text = getPARAM("correspondence_supp").

    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.
    
  end constructor.
  
	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void button10_Click( input sender as System.Object, input e as System.EventArgs ):
    mutil:verify_rest(textbox1:Text, textbox2:text).
    return.
  end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void button11_Click( input sender as System.Object, input e as System.EventArgs ):
      define variable ref-rec  as recid     no-undo .
      define variable ref-list as character no-undo.
    
      run ref/cli-all.w ( input parParentProc
         ,input "b-sel"
         ,input "все"
         ,input ?
         ,input ?
         ,input ?
         ,input ?
         ,input ?
         ,output ref-list) .
      if ref-list = "" then 
      do:
         return .
      end.
      ref-rec = integer( ref-list ).
      FIND ub.clients WHERE recid (ub.clients) = ref-rec NO-LOCK .
      this-object:Lincasagent:Text = ub.clients.obj-type + string(ub.clients.obj-code) + "_" + ub.clients.obj-name .
      this-object:Lincasagent:Focus().
      return.
	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void button12_Click( input sender as System.Object, input e as System.EventArgs ):
   
   define variable vi as integer no-undo.
   define variable vleg as integer no-undo.
   this-object:openFileDialog1:FileName = this-object:listBox2:Text.
   this-object:openFileDialog1:Multiselect = true .
   wait-for this-object:openFileDialog1:ShowDialog().
   
   do vi = 0 to this-object:openFileDialog1:FileNames:Length - 1:
   if not listBox2:Items:Contains(this-object:openFileDialog1:FileNames:GetValue(vi))
   then do:
      listBox2:Items:add(this-object:openFileDialog1:FileNames:GetValue(vi)).
      listBox2:SetSelected(listBox2:Items:IndexOf(this-object:openFileDialog1:FileNames:GetValue(vi)), true).
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
	    
		BtnStart().
		return.

	end method.


	

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void button7_Click( input sender as System.Object, input e as System.EventArgs ):
		close_shift().
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void button8_Click( input sender as System.Object, input e as System.EventArgs ):
		mutil:sendcleanCash(textBox4:text).
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void button9_Click( input sender as System.Object, input e as System.EventArgs ):
		textBox4:text = mutil:cangecash(textBox4:text).
		return.

	end method.


	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void checkBox21_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		
		return.

	end method.


	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void delemc_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void label19_Click( input sender as System.Object, input e as System.EventArgs ):
		
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void label2_Click( input sender as System.Object, input e as System.EventArgs ):
		
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
	method private void listBox2_SelectedIndexChanged( input sender as System.Object, input e as System.EventArgs ):
		
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void sendemc_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void tabPage2_Click( input sender as System.Object, input e as System.EventArgs ):
		
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void tabPage4_Click( input sender as System.Object, input e as System.EventArgs ):
    
		return.

	end method.

    method public void write-log (iText as char ):
       listBox1:Items:Add(iText).
        listBox1:SelectedIndex =listBox1:Items:Count - 1.  
    end method . 
    
	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void checkBox30_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):

		return.

	end method.

   
	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void button2_Click( input sender as System.Object, input e as System.EventArgs ):
	  define variable v-send-param as logical no-undo .
	  
	  assign
  	  checkBox7:checked  = no
  	  checkBox8:checked  = no
  	  checkBox9:checked  = no
  	  checkBox10:checked = no
  	  checkBox11:checked = no
  	  checkBox12:checked = no
  	  checkBox13:checked = no
  	  checkBox14:checked = no
  	  checkBox15:checked = no
  	  checkBox16:checked = no
  	  checkBox17:checked = no
  	  checkBox18:checked = no
          checkBox23:checked = no
          checkBox24:checked = no
          sendemc:checked = no
          delemc:checked  = no
          checkBox24:checked = no
          v-send-param = no
	  .
	   define variable vtestlg as logical no-undo init no.

	   for each ub.cash-desk no-lock where ub.cash-desk.pos-type = "IBM-XML":
	     mutil:sendnum(string(ub.cash-desk.cash-num)) .
	   end.
	   find first ub.cash-desk-attr exclusive-lock where ub.cash-desk-attr.attr-code = "string-cash" and
                                                        ub.cash-desk-attr.cash-num = 0 no-error .
      if available (ub.cash-desk-attr) then do:
        if ub.cash-desk-attr.attr-value-character <> "" then  
        mutil:sendnum(ub.cash-desk-attr.attr-value-character) .
      end.    

       
      mUtil:put-log("Начато   : удаление кассиров с касс").
      checkBox7:checked =mutil:sendcode(1).
      mUtil:put-log("Выполнено: удаление кассиров с касс").
      
      if vtestlg then message "выполнено "   checkBox7:text         view-as alert-box.
      
      mUtil:put-log("Начато   : передача кассиров на кассы").
      checkBox8:checked = mutil:sendcode(2).
      mUtil:put-log("Выполнено: передача кассиров на кассы").
      if vtestlg then message "выполнено "   checkBox8:text view-as alert-box.
      
      mUtil:put-log("Начато   : удаление налогов с касс").
        checkBox10:checked = mutil:sendcode(3).
      mUtil:put-log("Выполнено: удаление налогов с касс").
      if vtestlg then message "выполнено "   checkBox10:text view-as alert-box.
      
      mUtil:put-log("Начато   : передача налогов на кассы").
      checkBox9:checked = mutil:sendcode(4).
        mUtil:put-log("Выполнено: передача налогов на кассы").
      if vtestlg then message "выполнено "   checkBox9:text view-as alert-box.
      
      mUtil:put-log("Начато   : удаление типов платежей с касс").
      checkBox11:checked = mutil:sendcode(5).
      mUtil:put-log("Выполнено: удаление типов платежей с касс").
      if vtestlg then message "выполнено "   checkBox11:text view-as alert-box.
     
        mUtil:put-log("Начато   : передача типов платежей на кассы").
      checkBox12:checked = mutil:sendcode(6).
        mUtil:put-log("Выполнено: передача типов платежей на кассы").
      if vtestlg then message "выполнено "   checkBox12:Text view-as alert-box.
     
        mUtil:put-log("Начато   : удаление клиентов с касс").
      checkBox13:checked = mutil:sendcode(7). 
        mUtil:put-log("Выполнено: удаление клиентов с касс").
      if vtestlg then message "выполнено "   checkBox13:text view-as alert-box.
    
        mUtil:put-log("Начато   : передача клиентов на кассы").
      checkBox14:checked = mutil:sendcode(8).
        mUtil:put-log("Выполнено: передача клиентов на кассы").
      if vtestlg then message "выполнено "   checkBox14:text view-as alert-box.
    
        mUtil:put-log("Начато   : удаление масок карт с касс").
      checkBox15:checked = mutil:sendcode(9).
        mUtil:put-log("Выполнено: удаление масок карт с касс").
      if vtestlg then message "выполнено "   checkBox15:text view-as alert-box.
      
        mUtil:put-log("Начато   : передача масок карт на кассы").
      checkBox16:checked = mutil:sendcode(10).
        mUtil:put-log("Выполнено: передача масок карт на кассы").
      if vtestlg then message "выполнено "   checkBox16:text view-as alert-box.
    
        mUtil:put-log("Начато   : удаление справочника ОСС с касс").
       checkBox17:checked = mutil:sendcode(11).
        mUtil:put-log("Выполнено: удаление справочника ОСС с касс").
      if vtestlg then message "выполнено "   checkBox17:text view-as alert-box.
    
        mUtil:put-log("Начато   : передача справочника ОСС на кассы").
      checkBox17:checked = mutil:sendcode(12).
        checkBox18:checked = checkBox17:checked.
        mUtil:put-log("Выполнено: передача справочника ОСС на кассы").
      if vtestlg then message "выполнено "   checkBox18:text view-as alert-box.

        mUtil:put-log("Начато   : удаление ЕМС с касс").
      delemc:checked = mutil:sendcode(16).
        mUtil:put-log("Выполнено: удаление ЕМС с касс").
      if vtestlg then message "выполнено "   delemc:text view-as alert-box.
      
        mUtil:put-log("Начато   : передача ЕМС на кассы").
      sendemc:checked = mutil:sendcode(17).
        mUtil:put-log("Выполнено: передача ЕМС на кассы").
      if vtestlg then message "выполнено "   sendemc:text view-as alert-box.

        mUtil:put-log("Начато   : удаление товаров с касс").
      checkBox23:checked = mutil:sendcode(13).
        mUtil:put-log("Выполнено: удаление товаров с касс").
      if vtestlg then message "выполнено "   checkBox23:text view-as alert-box.
      
        mUtil:put-log("Начато   : передача товаров на кассы").
      checkBox24:checked = mutil:sendcode(14).
        mUtil:put-log("Выполнено: передача товаров на кассы").
      if vtestlg then message "выполнено "   checkBox24:text view-as alert-box.

        if listBox2:Text = "" then do:
          mUtil:put-log("Ошибка: отсутствует файл для загрузки новых параметров").
        end.
        else do:  
        mUtil:put-log("Начато   : передача параметров на кассы").
        define variable vi as integer no-undo .
        define variable listParam as character no-undo .
           do vi = 0 to listBox2:SelectedItems:Count - 1:
              listParam = listParam + {&delim-par} + string(listBox2:SelectedItems[vi]) .
           end.
        listParam = trim(listParam,{&delim-par}) .
        v-send-param = mutil:sendparam(listParam).
        if v-send-param then mUtil:put-log("Выполнено: передача параметров на кассы").
        else mUtil:put-log("Ошибка: при передаче параметров на кассы").
      if vtestlg then message "выполнено " .
        end.
      return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void button3_Click( input sender as System.Object, input e as System.EventArgs ):
	   this-object:openFileDialog1:FileName=this-object:textBox2:Text.
		wait-for this-object:openFileDialog1:ShowDialog().
		
		this-object:textBox2:Text = this-object:openFileDialog1:FileName.
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void button4_Click( input sender as System.Object, input e as System.EventArgs ):
	   this-object:openFileDialog1:FileName = this-object:textBox3:Text.
		wait-for this-object:openFileDialog1:ShowDialog().
    this-object:textBox3:Text = this-object:openFileDialog1:FileName.
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void button5_Click( input sender as System.Object, input e as System.EventArgs ):
		load_rest().
		return.

	end method.
  method private void load_rest(  ):
    if not mutil:chek_rvs()
    then do:
       message "Выполните этап 1"
       view-as alert-box.
       return.
    end.      

    mutil:mAddr = textbox1:Text.
    if checkBox19:checked and checkBox19:Enabled = true
    then do:
       checkBox19:checked = mutil:load_rest(textbox3:text,textbox2:text,"").
    if not checkBox19:checked
      then .
    else checkBox19:Enabled = false .
    end.  
    if checkBox20:checked and checkBox20:Enabled = true
    then do:
       checkBox20:checked = mutil:load_rest_ptrl(textbox3:text,textbox2:text,"").
    if not checkBox20:checked
      then .
    else checkBox20:Enabled = false .
    end. 
    if checkBox30:checked and checkBox30:Enabled = true
    then do:
       checkBox30:checked = mutil:load_rest_fin(textbox3:text,textbox2:text,Lincasagent:Text,"").
    if not checkBox30:checked
      then .
    else checkBox30:Enabled = false .  
    end.       
   end method.
   
   method private void close_shift(  ):
    
    if not checkBox20:checked
    then do:
       message "Выполните этап 3"
       view-as alert-box.
       return.
    end.
    mutil:mAddr = textbox1:Text.
     
    checkBox21:checked =  mutil:chek_rvs-shift().
    if not checkBox21:checked
    then
       checkBox21:checked = mutil:load_rvs(textbox2:text).
    if    checkBox21:checked
    then
       checkBox22:checked =  mutil:chek_rvs-close().
    if        checkBox21:checked 
      and not checkBox22:checked
    then
        checkBox22:checked = mutil:close-rvs-all ().
    return.

  end method.
	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void checkBox7_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		
		return.

	end method.

  method private void InitChekBox():

     checkBox1:checked = mutil:Chek_Shem().
     checkBox2:checked = mutil:chek_cash_desk().
     checkBox3:checked = mutil:chek-sht-open().
     checkBox4:checked = mutil:chek_rvs().
     checkBox5:checked = mutil:chek_price().
     checkBox6:checked = mutil:chek_pumpdoc().
     
     define variable v-log-param as logical no-undo .
     /* Перед переносом паролей кассиров таблица с кассирами уже заполнена:
        пароль кассира обязательное поле БД,
        поэтому при приеме нулевого пакета от 1С пароль кассира тоже заполнен и равен номеру кассира. 
     */
     v-log-param = logical( getPARAM("darw_util_pswd") ) no-error .      
     checkBox25:checked = if v-log-param then true else false.
     /* и таблица с пользователями тоже заполнена, но, возможно, не полностью */
     v-log-param = logical( getPARAM("darw_util_user") ) no-error .      
    checkBox21:checked =  mutil:chek_rvs-shift().
    checkBox22:checked = mutil:chek_rvs-close().
    checkBox26:checked = if v-log-param then true else false.
    checkBox19:checked = mutil:chek_rest().
    if checkBox19:Checked then checkBox19:Enabled = false .
    checkBox20:checked = mutil:chek_rest_ptrl().
    if checkBox20:Checked then checkBox20:Enabled = false .
    checkBox30:checked = mutil:chek_rest_fin().
    if checkBox30:Checked then checkBox30:Enabled = false .
    checkBox27:checked = mutil:chek_schedule().
    checkBox29:checked = mutil:chek_fbrgds().

  end method .  
  
  method private void BtnStart():
    define variable string-cash as character no-undo .
    mutil:mAddr = textbox1:Text.
    mUtil:load_version().
    checkBox1:checked = mutil:Chek_Shem().
    if not checkBox1:checked
    then do:
       mutil:load_schem(textBox2:text).
       checkBox1:checked = mutil:Chek_Shem(). 
    end. 
      
     checkBox2:checked = mutil:chek_cash_desk().
     if         checkBox1:checked
        and not checkBox2:checked
     then do:
        string-cash = mutil:load_cashdesk().
/*        if string-cash <> "" or string-cash <> ? then*/
/*        mutil:sendnum(string-cash) .                 */
        checkBox2:checked = mutil:chek_cash_desk().
     end.
     checkBox3:checked = mutil:chek-sht-open().
     if         checkBox2:checked
        and not checkBox3:checked
     then do:
        mutil:sht-open().
        checkBox3:checked = mutil:chek-sht-open().
     end.
      checkBox5:checked = mutil:chek_price().
     if         checkBox3:checked
        and not checkBox5:checked
     then do:
        mutil:load_price(textBox2:text).
       checkBox5:checked = mutil:chek_price(). 
    end.
     checkBox4:checked = mutil:chek_rvs().
      if        checkBox5:checked
        and not checkBox4:checked       
     then do:
           mutil:rvs-auto().
           checkBox4:checked = mutil:chek_rvs().
     end.
     //checkBox4:checked = mutil:chek-sht-open().
    
     checkBox6:checked = mutil:chek_pumpdoc().
     if         checkBox4:checked
        and not checkBox6:checked
    then do:
       mutil:load_pumpdoc(textBox2:text).
       checkBox6:checked = mutil:chek_pumpdoc(). 
    end.
   
    if        checkBox4:checked
      and not checkBox25:checked then do :
       mutil:load_cash_passwd () .
       checkBox25:checked = mutil:chek_cash_passwd().
    end .
    
    if        checkBox4:checked
      and not checkBox26:checked then do :
       mutil:load_user () .
       checkBox26:checked = mutil:chek_user().
    end .    
    
    checkBox27:checked = mutil:Chek_Schedule().
    if not checkBox27:checked
    then do:
       mutil:load_Schedule().
       checkBox27:checked = mutil:Chek_Schedule().
    end.
    checkBox29:checked = mutil:Chek_fbrgds().
    if not checkBox29:checked
    then do:
       mutil:load_fbrgds(textBox2:text).
       checkBox29:checked = mutil:Chek_fbrgds().
    end.    
  end.  
  
  
  method private void InitializeComponent(  ):
    
    /* NOTE: The following method is automatically generated.
    
    We strongly suggest that the contents of this method only be modified using the
    Visual Designer to avoid any incompatible modifications.
    
    Modifying the contents of this method using a code editor will invalidate any support for this file. */
      @VisualDesigner.FormMember (NeedsInitialize="true").
      define variable resources as Progress.Util.ResourceManager no-undo.
      resources = new Progress.Util.ResourceManager("ibs.th.utl.draw_utility").
      this-object:label1 = new System.Windows.Forms.Label().
      this-object:textBox1 = new System.Windows.Forms.TextBox().
      this-object:tabControl1 = new System.Windows.Forms.TabControl().
      this-object:tabPage1 = new System.Windows.Forms.TabPage().
      this-object:checkBox29 = new System.Windows.Forms.CheckBox().
      this-object:checkBox27 = new System.Windows.Forms.CheckBox().
      this-object:checkBox25 = new System.Windows.Forms.CheckBox().
      this-object:checkBox26 = new System.Windows.Forms.CheckBox().
      this-object:checkBox6 = new System.Windows.Forms.CheckBox().
      this-object:checkBox5 = new System.Windows.Forms.CheckBox().
      this-object:checkBox4 = new System.Windows.Forms.CheckBox().
      this-object:checkBox3 = new System.Windows.Forms.CheckBox().
      this-object:checkBox2 = new System.Windows.Forms.CheckBox().
      this-object:checkBox1 = new System.Windows.Forms.CheckBox().
      this-object:button1 = new System.Windows.Forms.Button().
      this-object:tabPage2 = new System.Windows.Forms.TabPage().
      this-object:delemc = new System.Windows.Forms.CheckBox().
      this-object:sendemc = new System.Windows.Forms.CheckBox().
      this-object:listBox2 = new System.Windows.Forms.ListBox().
      this-object:label5 = new System.Windows.Forms.Label().
      this-object:button12 = new System.Windows.Forms.Button().
      this-object:checkBox24 = new System.Windows.Forms.CheckBox().
      this-object:checkBox23 = new System.Windows.Forms.CheckBox().
      this-object:checkBox17 = new System.Windows.Forms.CheckBox().
      this-object:checkBox18 = new System.Windows.Forms.CheckBox().
      this-object:checkBox15 = new System.Windows.Forms.CheckBox().
      this-object:checkBox16 = new System.Windows.Forms.CheckBox().
      this-object:checkBox13 = new System.Windows.Forms.CheckBox().
      this-object:checkBox14 = new System.Windows.Forms.CheckBox().
      this-object:checkBox11 = new System.Windows.Forms.CheckBox().
      this-object:checkBox12 = new System.Windows.Forms.CheckBox().
      this-object:checkBox10 = new System.Windows.Forms.CheckBox().
      this-object:checkBox9 = new System.Windows.Forms.CheckBox().
      this-object:checkBox8 = new System.Windows.Forms.CheckBox().
      this-object:checkBox7 = new System.Windows.Forms.CheckBox().
      this-object:button2 = new System.Windows.Forms.Button().
      this-object:tabPage3 = new System.Windows.Forms.TabPage().
      this-object:button11 = new System.Windows.Forms.Button().
      this-object:Lincasagent = new System.Windows.Forms.Label().
      this-object:label19 = new System.Windows.Forms.Label().
      this-object:checkBox30 = new System.Windows.Forms.CheckBox().
      this-object:checkBox20 = new System.Windows.Forms.CheckBox().
      this-object:checkBox19 = new System.Windows.Forms.CheckBox().
      this-object:button5 = new System.Windows.Forms.Button().
      this-object:tabPage4 = new System.Windows.Forms.TabPage().
      this-object:button7 = new System.Windows.Forms.Button().
      this-object:checkBox22 = new System.Windows.Forms.CheckBox().
      this-object:checkBox21 = new System.Windows.Forms.CheckBox().
      this-object:tabPage5 = new System.Windows.Forms.TabPage().
      this-object:button10 = new System.Windows.Forms.Button().
      this-object:label4 = new System.Windows.Forms.Label().
      this-object:button9 = new System.Windows.Forms.Button().
      this-object:textBox4 = new System.Windows.Forms.TextBox().
      this-object:button8 = new System.Windows.Forms.Button().
      this-object:openFileDialog1 = new System.Windows.Forms.OpenFileDialog().
      this-object:textBox2 = new System.Windows.Forms.TextBox().
      this-object:button3 = new System.Windows.Forms.Button().
      this-object:label2 = new System.Windows.Forms.Label().
      this-object:label3 = new System.Windows.Forms.Label().
      this-object:button4 = new System.Windows.Forms.Button().
      this-object:textBox3 = new System.Windows.Forms.TextBox().
      this-object:listBox1 = new System.Windows.Forms.ListBox().
      this-object:button6 = new System.Windows.Forms.Button().
      this-object:tabControl1:SuspendLayout().
      this-object:tabPage1:SuspendLayout().
      this-object:tabPage2:SuspendLayout().
      this-object:tabPage3:SuspendLayout().
      this-object:tabPage4:SuspendLayout().
      this-object:tabPage5:SuspendLayout().
      this-object:SuspendLayout().
      /*  */
      /* label1 */
      /*  */
      this-object:label1:Location = new System.Drawing.Point(97, 18).
      this-object:label1:Name = "label1".
      this-object:label1:Size = new System.Drawing.Size(196, 23).
      this-object:label1:TabIndex = 0.
      this-object:label1:Text = "Адрес сокет-сервера".
      this-object:label1:UseCompatibleTextRendering = true.
      /*  */
      /* textBox1 */
      /*  */
      this-object:textBox1:Location = new System.Drawing.Point(328, 15).
      this-object:textBox1:Name = "textBox1".
      this-object:textBox1:Size = new System.Drawing.Size(209, 20).
      this-object:textBox1:TabIndex = 1.
      this-object:textBox1:Text = "localhost:8080".
      /*  */
      /* tabControl1 */
      /*  */
      this-object:tabControl1:Controls:Add(this-object:tabPage1).
      this-object:tabControl1:Controls:Add(this-object:tabPage2).
      this-object:tabControl1:Controls:Add(this-object:tabPage3).
      this-object:tabControl1:Controls:Add(this-object:tabPage4).
      this-object:tabControl1:Controls:Add(this-object:tabPage5).
      this-object:tabControl1:Location = new System.Drawing.Point(12, 111).
      this-object:tabControl1:Name = "tabControl1".
      this-object:tabControl1:SelectedIndex = 0.
      this-object:tabControl1:Size = new System.Drawing.Size(404, 501).
      this-object:tabControl1:TabIndex = 2.
      /*  */
      /* tabPage1 */
      /*  */
      this-object:tabPage1:Controls:Add(this-object:checkBox29).
      this-object:tabPage1:Controls:Add(this-object:checkBox27).
      this-object:tabPage1:Controls:Add(this-object:checkBox25).
      this-object:tabPage1:Controls:Add(this-object:checkBox26).
      this-object:tabPage1:Controls:Add(this-object:checkBox6).
      this-object:tabPage1:Controls:Add(this-object:checkBox5).
      this-object:tabPage1:Controls:Add(this-object:checkBox4).
      this-object:tabPage1:Controls:Add(this-object:checkBox3).
      this-object:tabPage1:Controls:Add(this-object:checkBox2).
      this-object:tabPage1:Controls:Add(this-object:checkBox1).
      this-object:tabPage1:Controls:Add(this-object:button1).
      this-object:tabPage1:Location = new System.Drawing.Point(4, 22).
      this-object:tabPage1:Name = "tabPage1".
      this-object:tabPage1:Padding = new System.Windows.Forms.Padding(3).
      this-object:tabPage1:Size = new System.Drawing.Size(396, 475).
      this-object:tabPage1:TabIndex = 0.
      this-object:tabPage1:Text = "Этап 1".
      this-object:tabPage1:UseVisualStyleBackColor = true.
      /*  */
      /* checkBox29 */
      /*  */
      this-object:checkBox29:Enabled = false.
      this-object:checkBox29:Location = new System.Drawing.Point(118, 301).
      this-object:checkBox29:Name = "checkBox29".
      this-object:checkBox29:Size = new System.Drawing.Size(249, 24).
      this-object:checkBox29:TabIndex = 11.
      this-object:checkBox29:Text = "Перенос атрибутов автопроизводства".
      this-object:checkBox29:UseCompatibleTextRendering = true.
      this-object:checkBox29:UseVisualStyleBackColor = true.
      /*  */
      /* checkBox27 */
      /*  */
      this-object:checkBox27:Enabled = false.
      this-object:checkBox27:Location = new System.Drawing.Point(118, 271).
      this-object:checkBox27:Name = "checkBox27".
      this-object:checkBox27:Size = new System.Drawing.Size(249, 24).
      this-object:checkBox27:TabIndex = 9.
      this-object:checkBox27:Text = "Создание расписания автозаданий".
      this-object:checkBox27:UseCompatibleTextRendering = true.
      this-object:checkBox27:UseVisualStyleBackColor = true.
      /*  */
      /* checkBox25 */
      /*  */
      this-object:checkBox25:Enabled = false.
      this-object:checkBox25:Location = new System.Drawing.Point(118, 211).
      this-object:checkBox25:Name = "checkBox25".
      this-object:checkBox25:Size = new System.Drawing.Size(249, 24).
      this-object:checkBox25:TabIndex = 8.
      this-object:checkBox25:Text = "Перенос паролей кассиров".
      this-object:checkBox25:UseCompatibleTextRendering = true.
      this-object:checkBox25:UseVisualStyleBackColor = true.
      /*  */
      /* checkBox26 */
      /*  */
      this-object:checkBox26:Enabled = false.
      this-object:checkBox26:Location = new System.Drawing.Point(118, 241).
      this-object:checkBox26:Name = "checkBox26".
      this-object:checkBox26:Size = new System.Drawing.Size(249, 24).
      this-object:checkBox26:TabIndex = 8.
      this-object:checkBox26:Text = "Перенос пользователей".
      this-object:checkBox26:UseCompatibleTextRendering = true.
      this-object:checkBox26:UseVisualStyleBackColor = true.
      /*  */
      /* checkBox6 */
      /*  */
      this-object:checkBox6:Enabled = false.
      this-object:checkBox6:Location = new System.Drawing.Point(118, 181).
      this-object:checkBox6:Name = "checkBox6".
      this-object:checkBox6:Size = new System.Drawing.Size(249, 24).
      this-object:checkBox6:TabIndex = 6.
      this-object:checkBox6:Text = "Перенос инвентаризация счетчиков ТРК ".
      this-object:checkBox6:UseCompatibleTextRendering = true.
      this-object:checkBox6:UseVisualStyleBackColor = true.
      /*  */
      /* checkBox5 */
      /*  */
      this-object:checkBox5:Enabled = false.
      this-object:checkBox5:Location = new System.Drawing.Point(118, 121).
      this-object:checkBox5:Name = "checkBox5".
      this-object:checkBox5:Size = new System.Drawing.Size(104, 24).
      this-object:checkBox5:TabIndex = 5.
      this-object:checkBox5:Text = "Перенос цен".
      this-object:checkBox5:UseCompatibleTextRendering = true.
      this-object:checkBox5:UseVisualStyleBackColor = true.
      /*  */
      /* checkBox4 */
      /*  */
      this-object:checkBox4:Enabled = false.
      this-object:checkBox4:Location = new System.Drawing.Point(118, 151).
      this-object:checkBox4:Name = "checkBox4".
      this-object:checkBox4:Size = new System.Drawing.Size(233, 24).
      this-object:checkBox4:TabIndex = 4.
      this-object:checkBox4:Text = "Создание нулевой контрольной сверки ".
      this-object:checkBox4:UseCompatibleTextRendering = true.
      this-object:checkBox4:UseVisualStyleBackColor = true.
      /*  */
      /* checkBox3 */
      /*  */
      this-object:checkBox3:Enabled = false.
      this-object:checkBox3:Location = new System.Drawing.Point(118, 91).
      this-object:checkBox3:Name = "checkBox3".
      this-object:checkBox3:Size = new System.Drawing.Size(219, 24).
      this-object:checkBox3:TabIndex = 3.
      this-object:checkBox3:Text = "Открытие технологической смены ".
      this-object:checkBox3:UseCompatibleTextRendering = true.
      this-object:checkBox3:UseVisualStyleBackColor = true.
      /*  */
      /* checkBox2 */
      /*  */
      this-object:checkBox2:Enabled = false.
      this-object:checkBox2:Location = new System.Drawing.Point(118, 61).
      this-object:checkBox2:Name = "checkBox2".
      this-object:checkBox2:Size = new System.Drawing.Size(190, 24).
      this-object:checkBox2:TabIndex = 2.
      this-object:checkBox2:Text = "Перенос справочника касс".
      this-object:checkBox2:UseCompatibleTextRendering = true.
      this-object:checkBox2:UseVisualStyleBackColor = true.
      /*  */
      /* checkBox1 */
      /*  */
      this-object:checkBox1:Enabled = false.
      this-object:checkBox1:Location = new System.Drawing.Point(118, 31).
      this-object:checkBox1:Name = "checkBox1".
      this-object:checkBox1:Size = new System.Drawing.Size(206, 24).
      this-object:checkBox1:TabIndex = 1.
      this-object:checkBox1:Text = "Перенос топологии".
      this-object:checkBox1:UseCompatibleTextRendering = true.
      this-object:checkBox1:UseVisualStyleBackColor = true.
      /*  */
      /* button1 */
      /*  */
      this-object:button1:Location = new System.Drawing.Point(7, 32).
      this-object:button1:Name = "button1".
      this-object:button1:Size = new System.Drawing.Size(75, 23).
      this-object:button1:TabIndex = 0.
      this-object:button1:Text = "Старт".
      this-object:button1:UseCompatibleTextRendering = true.
      this-object:button1:UseVisualStyleBackColor = true.
      this-object:button1:Click:Subscribe(this-object:button1_Click).
      /*  */
      /* tabPage2 */
      /*  */
      this-object:tabPage2:Controls:Add(this-object:delemc).
      this-object:tabPage2:Controls:Add(this-object:sendemc).
      this-object:tabPage2:Controls:Add(this-object:listBox2).
      this-object:tabPage2:Controls:Add(this-object:label5).
      this-object:tabPage2:Controls:Add(this-object:button12).
      this-object:tabPage2:Controls:Add(this-object:checkBox24).
      this-object:tabPage2:Controls:Add(this-object:checkBox23).
      this-object:tabPage2:Controls:Add(this-object:checkBox17).
      this-object:tabPage2:Controls:Add(this-object:checkBox18).
      this-object:tabPage2:Controls:Add(this-object:checkBox15).
      this-object:tabPage2:Controls:Add(this-object:checkBox16).
      this-object:tabPage2:Controls:Add(this-object:checkBox13).
      this-object:tabPage2:Controls:Add(this-object:checkBox14).
      this-object:tabPage2:Controls:Add(this-object:checkBox11).
      this-object:tabPage2:Controls:Add(this-object:checkBox12).
      this-object:tabPage2:Controls:Add(this-object:checkBox10).
      this-object:tabPage2:Controls:Add(this-object:checkBox9).
      this-object:tabPage2:Controls:Add(this-object:checkBox8).
      this-object:tabPage2:Controls:Add(this-object:checkBox7).
      this-object:tabPage2:Controls:Add(this-object:button2).
      this-object:tabPage2:Location = new System.Drawing.Point(4, 22).
      this-object:tabPage2:Name = "tabPage2".
      this-object:tabPage2:Padding = new System.Windows.Forms.Padding(3).
      this-object:tabPage2:Size = new System.Drawing.Size(396, 475).
      this-object:tabPage2:TabIndex = 1.
      this-object:tabPage2:Text = "Этап 2".
      this-object:tabPage2:UseVisualStyleBackColor = true.
      this-object:tabPage2:Click:Subscribe(this-object:tabPage2_Click).
      /*  */
      /* delemc */
      /*  */
      this-object:delemc:Enabled = false.
      this-object:delemc:Location = new System.Drawing.Point(149, 306).
      this-object:delemc:Name = "delemc".
      this-object:delemc:Size = new System.Drawing.Size(208, 24).
      this-object:delemc:TabIndex = 18.
      this-object:delemc:Text = "ЕМЦ удалены с касс".
      this-object:delemc:UseCompatibleTextRendering = true.
      this-object:delemc:UseVisualStyleBackColor = true.
      this-object:delemc:CheckedChanged:Subscribe(this-object:delemc_CheckedChanged).
      /*  */
      /* sendemc */
      /*  */
      this-object:sendemc:Enabled = false.
      this-object:sendemc:Location = new System.Drawing.Point(149, 331).
      this-object:sendemc:Name = "sendemc".
      this-object:sendemc:Size = new System.Drawing.Size(228, 24).
      this-object:sendemc:TabIndex = 17.
      this-object:sendemc:Text = "ЕМЦ переданы на кассы".
      this-object:sendemc:UseCompatibleTextRendering = true.
      this-object:sendemc:UseVisualStyleBackColor = true.
      this-object:sendemc:CheckedChanged:Subscribe(this-object:sendemc_CheckedChanged).
      /*  */
      /* listBox2 */
      /*  */
      this-object:listBox2:AllowDrop = true.
      this-object:listBox2:CausesValidation = false.
      this-object:listBox2:FormattingEnabled = true.
      this-object:listBox2:HorizontalScrollbar = true.
      this-object:listBox2:ImeMode = System.Windows.Forms.ImeMode:Katakana.
      this-object:listBox2:Location = new System.Drawing.Point(165, 409).
      this-object:listBox2:Name = "listBox2".
      this-object:listBox2:SelectionMode = System.Windows.Forms.SelectionMode:MultiExtended.
      this-object:listBox2:Size = new System.Drawing.Size(192, 56).
      this-object:listBox2:Sorted = true.
      this-object:listBox2:TabIndex = 16.
      this-object:listBox2:TabStop = false.
      this-object:listBox2:SelectedIndexChanged:Subscribe(this-object:listBox2_SelectedIndexChanged).
      /*  */
      /* label5 */
      /*  */
      this-object:label5:Location = new System.Drawing.Point(6, 428).
      this-object:label5:Name = "label5".
      this-object:label5:Size = new System.Drawing.Size(165, 14).
      this-object:label5:TabIndex = 15.
      this-object:label5:Text = "Новые параметры для кассы:".
      this-object:label5:UseCompatibleTextRendering = true.
      this-object:label5:Click:Subscribe(this-object:label5_Click).
      /*  */
      /* button12 */
      /*  */
      this-object:button12:Location = new System.Drawing.Point(363, 409).
      this-object:button12:Name = "button12".
      this-object:button12:Size = new System.Drawing.Size(28, 23).
      this-object:button12:TabIndex = 12.
      this-object:button12:UseCompatibleTextRendering = true.
      this-object:button12:UseVisualStyleBackColor = true.
      this-object:button12:Click:Subscribe(this-object:button12_Click).
      /*  */
      /* checkBox24 */
      /*  */
      this-object:checkBox24:Enabled = false.
      this-object:checkBox24:Location = new System.Drawing.Point(149, 381).
      this-object:checkBox24:Name = "checkBox24".
      this-object:checkBox24:Size = new System.Drawing.Size(228, 24).
      this-object:checkBox24:TabIndex = 14.
      this-object:checkBox24:Text = "Товары переданы на кассы".
      this-object:checkBox24:UseCompatibleTextRendering = true.
      this-object:checkBox24:UseVisualStyleBackColor = true.
      /*  */
      /* checkBox23 */
      /*  */
      this-object:checkBox23:Enabled = false.
      this-object:checkBox23:Location = new System.Drawing.Point(149, 356).
      this-object:checkBox23:Name = "checkBox23".
      this-object:checkBox23:Size = new System.Drawing.Size(228, 24).
      this-object:checkBox23:TabIndex = 13.
      this-object:checkBox23:Text = "Товары удалены с касс".
      this-object:checkBox23:UseCompatibleTextRendering = true.
      this-object:checkBox23:UseVisualStyleBackColor = true.
      /*  */
      /* checkBox17 */
      /*  */
      this-object:checkBox17:Enabled = false.
      this-object:checkBox17:Location = new System.Drawing.Point(149, 256).
      this-object:checkBox17:Name = "checkBox17".
      this-object:checkBox17:Size = new System.Drawing.Size(228, 24).
      this-object:checkBox17:TabIndex = 12.
      this-object:checkBox17:Text = "Справочник ОСС удалены с касс".
      this-object:checkBox17:UseCompatibleTextRendering = true.
      this-object:checkBox17:UseVisualStyleBackColor = true.
      /*  */
      /* checkBox18 */
      /*  */
      this-object:checkBox18:Enabled = false.
      this-object:checkBox18:Location = new System.Drawing.Point(149, 281).
      this-object:checkBox18:Name = "checkBox18".
      this-object:checkBox18:Size = new System.Drawing.Size(228, 24).
      this-object:checkBox18:TabIndex = 11.
      this-object:checkBox18:Text = "Справочник ОСС переданы на кассы".
      this-object:checkBox18:UseCompatibleTextRendering = true.
      this-object:checkBox18:UseVisualStyleBackColor = true.
      /*  */
      /* checkBox15 */
      /*  */
      this-object:checkBox15:Enabled = false.
      this-object:checkBox15:Location = new System.Drawing.Point(149, 206).
      this-object:checkBox15:Name = "checkBox15".
      this-object:checkBox15:Size = new System.Drawing.Size(228, 24).
      this-object:checkBox15:TabIndex = 10.
      this-object:checkBox15:Text = "Маски карт удалены с касс".
      this-object:checkBox15:UseCompatibleTextRendering = true.
      this-object:checkBox15:UseVisualStyleBackColor = true.
      /*  */
      /* checkBox16 */
      /*  */
      this-object:checkBox16:Enabled = false.
      this-object:checkBox16:Location = new System.Drawing.Point(149, 231).
      this-object:checkBox16:Name = "checkBox16".
      this-object:checkBox16:Size = new System.Drawing.Size(228, 24).
      this-object:checkBox16:TabIndex = 9.
      this-object:checkBox16:Text = "Маски карт переданы на кассы".
      this-object:checkBox16:UseCompatibleTextRendering = true.
      this-object:checkBox16:UseVisualStyleBackColor = true.
      /*  */
      /* checkBox13 */
      /*  */
      this-object:checkBox13:Enabled = false.
      this-object:checkBox13:Location = new System.Drawing.Point(149, 156).
      this-object:checkBox13:Name = "checkBox13".
      this-object:checkBox13:Size = new System.Drawing.Size(228, 24).
      this-object:checkBox13:TabIndex = 8.
      this-object:checkBox13:Text = "Клиенты удалены с касс".
      this-object:checkBox13:UseCompatibleTextRendering = true.
      this-object:checkBox13:UseVisualStyleBackColor = true.
      /*  */
      /* checkBox14 */
      /*  */
      this-object:checkBox14:Enabled = false.
      this-object:checkBox14:Location = new System.Drawing.Point(149, 181).
      this-object:checkBox14:Name = "checkBox14".
      this-object:checkBox14:Size = new System.Drawing.Size(228, 24).
      this-object:checkBox14:TabIndex = 7.
      this-object:checkBox14:Text = "Клиенты переданы на кассы".
      this-object:checkBox14:UseCompatibleTextRendering = true.
      this-object:checkBox14:UseVisualStyleBackColor = true.
      /*  */
      /* checkBox11 */
      /*  */
      this-object:checkBox11:Enabled = false.
      this-object:checkBox11:Location = new System.Drawing.Point(149, 106).
      this-object:checkBox11:Name = "checkBox11".
      this-object:checkBox11:Size = new System.Drawing.Size(228, 24).
      this-object:checkBox11:TabIndex = 6.
      this-object:checkBox11:Text = "Типы платежей удалены с касс".
      this-object:checkBox11:UseCompatibleTextRendering = true.
      this-object:checkBox11:UseVisualStyleBackColor = true.
      /*  */
      /* checkBox12 */
      /*  */
      this-object:checkBox12:Enabled = false.
      this-object:checkBox12:Location = new System.Drawing.Point(149, 131).
      this-object:checkBox12:Name = "checkBox12".
      this-object:checkBox12:Size = new System.Drawing.Size(228, 24).
      this-object:checkBox12:TabIndex = 5.
      this-object:checkBox12:Text = "Типы платежей переданы на кассы".
      this-object:checkBox12:UseCompatibleTextRendering = true.
      this-object:checkBox12:UseVisualStyleBackColor = true.
      /*  */
      /* checkBox10 */
      /*  */
      this-object:checkBox10:Enabled = false.
      this-object:checkBox10:Location = new System.Drawing.Point(149, 56).
      this-object:checkBox10:Name = "checkBox10".
      this-object:checkBox10:Size = new System.Drawing.Size(228, 24).
      this-object:checkBox10:TabIndex = 4.
      this-object:checkBox10:Text = "Налоги удалены с касс".
      this-object:checkBox10:UseCompatibleTextRendering = true.
      this-object:checkBox10:UseVisualStyleBackColor = true.
      /*  */
      /* checkBox9 */
      /*  */
      this-object:checkBox9:Enabled = false.
      this-object:checkBox9:Location = new System.Drawing.Point(149, 81).
      this-object:checkBox9:Name = "checkBox9".
      this-object:checkBox9:Size = new System.Drawing.Size(228, 24).
      this-object:checkBox9:TabIndex = 3.
      this-object:checkBox9:Text = "Налоги переданы на кассы".
      this-object:checkBox9:UseCompatibleTextRendering = true.
      this-object:checkBox9:UseVisualStyleBackColor = true.
      /*  */
      /* checkBox8 */
      /*  */
      this-object:checkBox8:Enabled = false.
      this-object:checkBox8:Location = new System.Drawing.Point(149, 31).
      this-object:checkBox8:Name = "checkBox8".
      this-object:checkBox8:Size = new System.Drawing.Size(228, 24).
      this-object:checkBox8:TabIndex = 2.
      this-object:checkBox8:Text = "Кассиры переданы на кассы".
      this-object:checkBox8:UseCompatibleTextRendering = true.
      this-object:checkBox8:UseVisualStyleBackColor = true.
      /*  */
      /* checkBox7 */
      /*  */
      this-object:checkBox7:Enabled = false.
      this-object:checkBox7:Location = new System.Drawing.Point(149, 6).
      this-object:checkBox7:Name = "checkBox7".
      this-object:checkBox7:Size = new System.Drawing.Size(228, 24).
      this-object:checkBox7:TabIndex = 1.
      this-object:checkBox7:Text = "Кассиры удалены с касс".
      this-object:checkBox7:UseCompatibleTextRendering = true.
      this-object:checkBox7:UseVisualStyleBackColor = true.
      this-object:checkBox7:CheckedChanged:Subscribe(this-object:checkBox7_CheckedChanged).
      /*  */
      /* button2 */
      /*  */
      this-object:button2:Location = new System.Drawing.Point(23, 48).
      this-object:button2:Name = "button2".
      this-object:button2:Size = new System.Drawing.Size(91, 53).
      this-object:button2:TabIndex = 0.
      this-object:button2:Text = "Отправить данные на кассы".
      this-object:button2:UseCompatibleTextRendering = true.
      this-object:button2:UseVisualStyleBackColor = true.
      this-object:button2:Click:Subscribe(this-object:button2_Click).
      /*  */
      /* tabPage3 */
      /*  */
      this-object:tabPage3:Controls:Add(this-object:button11).
      this-object:tabPage3:Controls:Add(this-object:Lincasagent).
      this-object:tabPage3:Controls:Add(this-object:label19).
      this-object:tabPage3:Controls:Add(this-object:checkBox30).
      this-object:tabPage3:Controls:Add(this-object:checkBox20).
      this-object:tabPage3:Controls:Add(this-object:checkBox19).
      this-object:tabPage3:Controls:Add(this-object:button5).
      this-object:tabPage3:Location = new System.Drawing.Point(4, 22).
      this-object:tabPage3:Name = "tabPage3".
      this-object:tabPage3:Size = new System.Drawing.Size(396, 475).
      this-object:tabPage3:TabIndex = 2.
      this-object:tabPage3:Text = "Этап 3".
      this-object:tabPage3:UseVisualStyleBackColor = true.
      /*  */
      /* button11 */
      /*  */
      this-object:button11:Location = new System.Drawing.Point(321, 116).
      this-object:button11:Name = "button11".
      this-object:button11:Size = new System.Drawing.Size(23, 23).
      this-object:button11:TabIndex = 62.
      this-object:button11:UseCompatibleTextRendering = true.
      this-object:button11:UseVisualStyleBackColor = true.
      this-object:button11:Click:Subscribe(this-object:button11_Click).
      /*  */
      /* Lincasagent */
      /*  */
      this-object:Lincasagent:Location = new System.Drawing.Point(137, 121).
      this-object:Lincasagent:Name = "Lincasagent".
      this-object:Lincasagent:Size = new System.Drawing.Size(178, 15).
      this-object:Lincasagent:TabIndex = 61.
      this-object:Lincasagent:UseCompatibleTextRendering = true.
      /*  */
      /* label19 */
      /*  */
      this-object:label19:Location = new System.Drawing.Point(3, 115).
      this-object:label19:Name = "label19".
      this-object:label19:Size = new System.Drawing.Size(128, 32).
      this-object:label19:TabIndex = 60.
      this-object:label19:Text = "Контрагент для ПКО\РКО:".
      this-object:label19:UseCompatibleTextRendering = true.
      this-object:label19:Click:Subscribe(this-object:label19_Click).
      /*  */
      /* checkBox30 */
      /*  */
      this-object:checkBox30:Location = new System.Drawing.Point(117, 88).
      this-object:checkBox30:Name = "checkBox30".
      this-object:checkBox30:Size = new System.Drawing.Size(223, 24).
      this-object:checkBox30:TabIndex = 3.
      this-object:checkBox30:Text = "Перенос денежных остатков".
      this-object:checkBox30:UseCompatibleTextRendering = true.
      this-object:checkBox30:UseVisualStyleBackColor = true.
      this-object:checkBox30:CheckedChanged:Subscribe(this-object:checkBox30_CheckedChanged).
      /*  */
      /* checkBox20 */
      /*  */
      this-object:checkBox20:Location = new System.Drawing.Point(117, 58).
      this-object:checkBox20:Name = "checkBox20".
      this-object:checkBox20:Size = new System.Drawing.Size(223, 24).
      this-object:checkBox20:TabIndex = 2.
      this-object:checkBox20:Text = "Перенос остатков по топливу".
      this-object:checkBox20:UseCompatibleTextRendering = true.
      this-object:checkBox20:UseVisualStyleBackColor = true.
      /*  */
      /* checkBox19 */
      /*  */
      this-object:checkBox19:Location = new System.Drawing.Point(117, 27).
      this-object:checkBox19:Name = "checkBox19".
      this-object:checkBox19:Size = new System.Drawing.Size(223, 24).
      this-object:checkBox19:TabIndex = 1.
      this-object:checkBox19:Text = "Перенос остатков по товару".
      this-object:checkBox19:UseCompatibleTextRendering = true.
      this-object:checkBox19:UseVisualStyleBackColor = true.
      /*  */
      /* button5 */
      /*  */
      this-object:button5:Location = new System.Drawing.Point(24, 27).
      this-object:button5:Name = "button5".
      this-object:button5:Size = new System.Drawing.Size(75, 55).
      this-object:button5:TabIndex = 0.
      this-object:button5:Text = "Перенести остатки".
      this-object:button5:UseCompatibleTextRendering = true.
      this-object:button5:UseVisualStyleBackColor = true.
      this-object:button5:Click:Subscribe(this-object:button5_Click).
      /*  */
      /* tabPage4 */
      /*  */
      this-object:tabPage4:Controls:Add(this-object:button7).
      this-object:tabPage4:Controls:Add(this-object:checkBox22).
      this-object:tabPage4:Controls:Add(this-object:checkBox21).
      this-object:tabPage4:Location = new System.Drawing.Point(4, 22).
      this-object:tabPage4:Name = "tabPage4".
      this-object:tabPage4:Size = new System.Drawing.Size(396, 475).
      this-object:tabPage4:TabIndex = 3.
      this-object:tabPage4:Text = "Этап 4".
      this-object:tabPage4:UseVisualStyleBackColor = true.
      this-object:tabPage4:Click:Subscribe(this-object:tabPage4_Click).
      /*  */
      /* button7 */
      /*  */
      this-object:button7:Location = new System.Drawing.Point(22, 30).
      this-object:button7:Name = "button7".
      this-object:button7:Size = new System.Drawing.Size(75, 59).
      this-object:button7:TabIndex = 13.
      this-object:button7:Text = "Закрыть смену".
      this-object:button7:UseCompatibleTextRendering = true.
      this-object:button7:UseVisualStyleBackColor = true.
      this-object:button7:Click:Subscribe(this-object:button7_Click).
      /*  */
      /* checkBox22 */
      /*  */
      this-object:checkBox22:Enabled = false.
      this-object:checkBox22:Location = new System.Drawing.Point(110, 61).
      this-object:checkBox22:Name = "checkBox22".
      this-object:checkBox22:Size = new System.Drawing.Size(104, 28).
      this-object:checkBox22:TabIndex = 12.
      this-object:checkBox22:Text = "Закрытие смены".
      this-object:checkBox22:UseCompatibleTextRendering = true.
      this-object:checkBox22:UseVisualStyleBackColor = true.
      /*  */
      /* checkBox21 */
      /*  */
      this-object:checkBox21:Enabled = false.
      this-object:checkBox21:Location = new System.Drawing.Point(110, 30).
      this-object:checkBox21:Name = "checkBox21".
      this-object:checkBox21:Size = new System.Drawing.Size(223, 24).
      this-object:checkBox21:TabIndex = 11.
      this-object:checkBox21:Text = "Сменная сверка ".
      this-object:checkBox21:UseCompatibleTextRendering = true.
      this-object:checkBox21:UseVisualStyleBackColor = true.
      this-object:checkBox21:CheckedChanged:Subscribe(this-object:checkBox21_CheckedChanged).
      /*  */
      /* tabPage5 */
      /*  */
      this-object:tabPage5:Controls:Add(this-object:button10).
      this-object:tabPage5:Controls:Add(this-object:label4).
      this-object:tabPage5:Controls:Add(this-object:button9).
      this-object:tabPage5:Controls:Add(this-object:textBox4).
      this-object:tabPage5:Controls:Add(this-object:button8).
      this-object:tabPage5:Location = new System.Drawing.Point(4, 22).
      this-object:tabPage5:Name = "tabPage5".
      this-object:tabPage5:Size = new System.Drawing.Size(396, 475).
      this-object:tabPage5:TabIndex = 4.
      this-object:tabPage5:Text = "Утилиты".
      this-object:tabPage5:UseVisualStyleBackColor = true.
      /*  */
      /* button10 */
      /*  */
      this-object:button10:Location = new System.Drawing.Point(20, 101).
      this-object:button10:Name = "button10".
      this-object:button10:Size = new System.Drawing.Size(98, 59).
      this-object:button10:TabIndex = 4.
      this-object:button10:Text = "Сравнение остатков".
      this-object:button10:UseCompatibleTextRendering = true.
      this-object:button10:UseVisualStyleBackColor = true.
      this-object:button10:Click:Subscribe(this-object:button10_Click).
      /*  */
      /* label4 */
      /*  */
      this-object:label4:Location = new System.Drawing.Point(145, 36).
      this-object:label4:Name = "label4".
      this-object:label4:Size = new System.Drawing.Size(153, 23).
      this-object:label4:TabIndex = 3.
      this-object:label4:Text = "Номера выбранных касс".
      this-object:label4:UseCompatibleTextRendering = true.
      /*  */
      /* button9 */
      /*  */
      this-object:button9:AllowDrop = true.
      this-object:button9:AutoSize = true.
      this-object:button9:Image = cast(resources:GetObject("button9.Image"), System.Drawing.Image).
      this-object:button9:ImageAlign = System.Drawing.ContentAlignment:TopCenter.
      this-object:button9:Location = new System.Drawing.Point(345, 62).
      this-object:button9:Name = "button9".
      this-object:button9:Size = new System.Drawing.Size(33, 22).
      this-object:button9:TabIndex = 2.
      this-object:button9:TextAlign = System.Drawing.ContentAlignment:BottomCenter.
      this-object:button9:UseCompatibleTextRendering = true.
      this-object:button9:UseVisualStyleBackColor = true.
      this-object:button9:Click:Subscribe(this-object:button9_Click).
      /*  */
      /* textBox4 */
      /*  */
      this-object:textBox4:Location = new System.Drawing.Point(124, 62).
      this-object:textBox4:Name = "textBox4".
      this-object:textBox4:Size = new System.Drawing.Size(215, 20).
      this-object:textBox4:TabIndex = 1.
      /*  */
      /* button8 */
      /*  */
      this-object:button8:Location = new System.Drawing.Point(20, 36).
      this-object:button8:Name = "button8".
      this-object:button8:Size = new System.Drawing.Size(98, 59).
      this-object:button8:TabIndex = 0.
      this-object:button8:Text = "Резервное копирование базы кассы и удаление чеков".
      this-object:button8:UseCompatibleTextRendering = true.
      this-object:button8:UseVisualStyleBackColor = true.
      this-object:button8:Click:Subscribe(this-object:button8_Click).
      /*  */
      /* openFileDialog1 */
      /*  */
      this-object:openFileDialog1:FileName = "openFileDialog1".
      /*  */
      /* textBox2 */
      /*  */
      this-object:textBox2:Location = new System.Drawing.Point(328, 42).
      this-object:textBox2:Name = "textBox2".
      this-object:textBox2:Size = new System.Drawing.Size(209, 20).
      this-object:textBox2:TabIndex = 3.
      /*  */
      /* button3 */
      /*  */
      this-object:button3:Image = cast(resources:GetObject("button3.Image"), System.Drawing.Image).
      this-object:button3:Location = new System.Drawing.Point(553, 42).
      this-object:button3:Name = "button3".
      this-object:button3:Size = new System.Drawing.Size(28, 23).
      this-object:button3:TabIndex = 4.
      this-object:button3:UseCompatibleTextRendering = true.
      this-object:button3:UseVisualStyleBackColor = true.
      this-object:button3:Click:Subscribe(this-object:button3_Click).
      /*  */
      /* label2 */
      /*  */
      this-object:label2:Location = new System.Drawing.Point(97, 47).
      this-object:label2:Name = "label2".
      this-object:label2:Size = new System.Drawing.Size(196, 14).
      this-object:label2:TabIndex = 5.
      this-object:label2:Text = "Файл соответствия товаров".
      this-object:label2:UseCompatibleTextRendering = true.
      this-object:label2:Click:Subscribe(this-object:label2_Click).
      /*  */
      /* label3 */
      /*  */
      this-object:label3:Location = new System.Drawing.Point(97, 73).
      this-object:label3:Name = "label3".
      this-object:label3:Size = new System.Drawing.Size(196, 14).
      this-object:label3:TabIndex = 8.
      this-object:label3:Text = "Файл соответствия поставщиков".
      this-object:label3:UseCompatibleTextRendering = true.
      /*  */
      /* button4 */
      /*  */
      this-object:button4:Image = cast(resources:GetObject("button4.Image"), System.Drawing.Image).
      this-object:button4:Location = new System.Drawing.Point(553, 68).
      this-object:button4:Name = "button4".
      this-object:button4:Size = new System.Drawing.Size(28, 23).
      this-object:button4:TabIndex = 7.
      this-object:button4:UseCompatibleTextRendering = true.
      this-object:button4:UseVisualStyleBackColor = true.
      this-object:button4:Click:Subscribe(this-object:button4_Click).
      /*  */
      /* textBox3 */
      /*  */
      this-object:textBox3:Location = new System.Drawing.Point(328, 68).
      this-object:textBox3:Name = "textBox3".
      this-object:textBox3:Size = new System.Drawing.Size(209, 20).
      this-object:textBox3:TabIndex = 6.
      this-object:textBox3:TextChanged:Subscribe(this-object:textBox3_TextChanged).
      /*  */
      /* listBox1 */
      /*  */
      define variable nestedvar0 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar0 = cast(Progress.Util.EnumHelper:Or(cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Bottom), System.Windows.Forms.AnchorStyles), System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:listBox1:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:listBox1:FormattingEnabled = true.
      this-object:listBox1:Location = new System.Drawing.Point(449, 133).
      this-object:listBox1:Name = "listBox1".
      this-object:listBox1:Size = new System.Drawing.Size(326, 446).
      this-object:listBox1:TabIndex = 9.
      /*  */
      /* button6 */
      /*  */
      this-object:button6:DialogResult = System.Windows.Forms.DialogResult:Cancel.
      this-object:button6:Location = new System.Drawing.Point(16, 13).
      this-object:button6:Name = "button6".
      this-object:button6:Size = new System.Drawing.Size(75, 23).
      this-object:button6:TabIndex = 10.
      this-object:button6:Text = "Выход".
      this-object:button6:UseCompatibleTextRendering = true.
      this-object:button6:UseVisualStyleBackColor = true.
      this-object:button6:Click:Subscribe(this-object:button6_Click).
      /*  */
      /* draw_utility */
      /*  */
      this-object:CancelButton = this-object:button6.
      this-object:ClientSize = new System.Drawing.Size(795, 617).
      this-object:Controls:Add(this-object:button6).
      this-object:Controls:Add(this-object:listBox1).
      this-object:Controls:Add(this-object:label3).
      this-object:Controls:Add(this-object:button4).
      this-object:Controls:Add(this-object:textBox3).
      this-object:Controls:Add(this-object:label2).
      this-object:Controls:Add(this-object:button3).
      this-object:Controls:Add(this-object:textBox2).
      this-object:Controls:Add(this-object:tabControl1).
      this-object:Controls:Add(this-object:textBox1).
      this-object:Controls:Add(this-object:label1).
      this-object:Name = "draw_utility".
      this-object:Text = "Тиражная утилита".
      this-object:tabControl1:ResumeLayout(false).
      this-object:tabPage1:ResumeLayout(false).
      this-object:tabPage2:ResumeLayout(false).
      this-object:tabPage3:ResumeLayout(false).
      this-object:tabPage4:ResumeLayout(false).
      this-object:tabPage5:ResumeLayout(false).
      this-object:tabPage5:PerformLayout().
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
	method private void textBox3_TextChanged( input sender as System.Object, input e as System.EventArgs ):
		
		return.

    end method.
	
   &GLOBAL-DEFINE PARAM-BEG-TAG SUBSTITUTE("<PARAM name='&1'>", iName)
   &GLOBAL-DEFINE PARAM-END-TAG SUBSTITUTE("</PARAM name='&1'>", iName)
   &GLOBAL-DEFINE filename "draw-util-param.txt"
    method public  void SavePARAMs ():
        SavePARAMs({&filename }).
    end method.    
    method public  void SavePARAMs (  input iFile as char ):
        output to value (iFile).
        SavePARAM("host",textBox1:Text).
        SavePARAM("correspondence_gds",  textBox2:Text).
        SavePARAM("correspondence_supp", textBox3:Text).
        SavePARAM("darw_util_pswd",      string(checkBox25:checked)).
        SavePARAM("darw_util_user",      string(checkBox26:checked)).
        output close.
    end method.
    method public  void SavePARAM ( input iName as char, input iValue as char ):
        put unformatted {&PARAM-BEG-TAG}.
        put unformatted iValue.
        put unformatted {&PARAM-END-TAG} skip.
    end method.
    method public char GetPARAM (  input iName as char ):
         return GetPARAM ( {&filename }, iName  ).
    end method.         
    method public char GetPARAM ( input iFile as char, input iName as char ):
        def var vLob  as longchar no-undo.
        def var vFrom as int64    no-undo.
        def var vTo   as int64    no-undo.
        if not FileExists (iFile) then return ?.
        copy-lob file iFile to vLob no-error.
        vFrom = index(vLob, {&PARAM-BEG-TAG}).
        if vFrom <= 0 then return ?.
        assign
            vTo = index(vLob, {&PARAM-END-TAG})
            vFrom = vFrom + LENGTH({&PARAM-BEG-TAG}). 
        if vTo < vFrom then return ?.
        return string(substring(vLob, vFrom, vTo - vFrom)).
    end method.
    method public logical FileExists  (input  ifolder as character ):
        return objExists(ifolder,"F") ne ?.
    end.   
    method public character  objExists  (input  ifolder as character,
        input  iType   as character  ):
        define variable vPureName  as character no-undo.
        define variable vFullPath as character no-undo.
        define variable vFileType as character no-undo.                                  
        file-information:file-name = ifolder.
        if index( file-information:file-type, iType ) > 0 then return file-information:full-pathname .
        file-information:file-name = "./" + ifolder.
        if index( file-information:file-type, iType ) > 0 then return file-information:full-pathname .
    
        return ? .
   end method.

    /*------------------------------------------------------------------------------
      Purpose:
      Notes:
     ------------------------------------------------------------------------------*/
    @VisualDesigner.
    method private void button6_Click( input sender as System.Object, input e as System.EventArgs ):
        SavePARAMs().
        return.

    end method.
   	 

  destructor public draw_utility ( ):
      mutil:write-log:unSUBSCRIBE (this-object:write-log).
      
     delete object mUtil.
  end destructor.

end class.