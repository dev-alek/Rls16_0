 
 /*------------------------------------------------------------------------
    File        : rformtest
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Nady
    Created     : Mon Mar 23 02:22:36 MSK 2020
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using ibs.th.ref.sobj.sUserFrame.

block-level on error undo, throw.

class ibs.th.rep.eddinam inherits sUserFrame: 
   {cmp\str-glbl.i class}
   define private variable components as System.ComponentModel.IContainer no-undo.
   define private variable TogDet as System.Windows.Forms.CheckBox no-undo.
   define private variable TogOper as System.Windows.Forms.CheckBox no-undo.

      
   constructor public eddinam  (  ):
      
      
      super().
      namereport = "Движение денежных средств.".
      procname   = "Old_proc".
      InitializeComponent().
      this-object:ComponentsCollection:ADD(this-object:components).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.

   end constructor.

   method private void InitializeComponent(  ):
      
      /* NOTE: The following method is automatically generated.
      
      We strongly suggest that the contents of this method only be modified using the
      Visual Designer to avoid any incompatible modifications.
      
      Modifying the contents of this method using a code editor will invalidate any support for this file. */
      this-object:TogDet = new System.Windows.Forms.CheckBox().
      this-object:TogOper = new System.Windows.Forms.CheckBox().
      this-object:SuspendLayout().
      /*  */
      /* TogDet */
      /*  */
      this-object:TogDet:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.75), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:TogDet:Location = new System.Drawing.Point(23, 13).
      this-object:TogDet:Name = "TogDet".
      this-object:TogDet:Size = new System.Drawing.Size(242, 24).
      this-object:TogDet:TabIndex = 0.
      this-object:TogDet:Text = "С детализацией по объектам".
      this-object:TogDet:UseCompatibleTextRendering = true.
      this-object:TogDet:UseVisualStyleBackColor = true.
      /*  */
      /* TogOper */
      /*  */
      this-object:TogOper:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.75), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:TogOper:Location = new System.Drawing.Point(23, 43).
      this-object:TogOper:Name = "TogOper".
      this-object:TogOper:Size = new System.Drawing.Size(150, 24).
      this-object:TogOper:TabIndex = 1.
      this-object:TogOper:Text = "Оперативный".
      this-object:TogOper:UseCompatibleTextRendering = true.
      this-object:TogOper:UseVisualStyleBackColor = true.
      /*  */
      /* eddinam */
      /*  */
      this-object:AutoScaleDimensions = new System.Drawing.SizeF(Progress.Util.CastUtil:ToSingle(6), Progress.Util.CastUtil:ToSingle(13)).
      this-object:Controls:Add(this-object:TogOper).
      this-object:Controls:Add(this-object:TogDet).
      this-object:Name = "eddinam".
      this-object:Size = new System.Drawing.Size(290, 156).
      this-object:ResumeLayout(false).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end method.

   destructor public eddinam  ( ):

   end destructor.
   
   method override public void My-var ():
      assign
         paramobj:ReportHeader = "С детализацией по объектам"
      .
   end.
   
   method override public void my-report ():
      run rep/r-ddinam.p
       (input paramobj
       ,input '' /*p-report-id*/
       ,input integer({&repcalc-type-operator}) /*p-batch*/
       ,input 0 /*p-codex-id*/
       ,input 0 /*p-ruleset-id*/
       ,input "" /*p-log-file-name*/
       ,input togdet:Checked
       ,input TOGoper:Checked
       ,input yes /*t-text*/
       ,input yes /*t-excel*/
       ,input '' /*p-dir-name*/
         ) no-error.
    /*  if error-status:error
      then
         message error-status:get-message (1)
         view-as alert-box. */
   end.
   
   method override public void my-params (p-action as character):
      /*
      define variable v-index-id as integer no-undo .
      define variable v-value-character as character no-undo .
      define variable v-value-date as date no-undo .
      define variable v-value-decimal as decimal no-undo .
      define variable v-value-integer as integer no-undo .
      define variable v-value-logical as logical no-undo .
     
      case p-action :
      when 'get' then do:
         if v-profile-id = 70  then do:
       v-index-id = 0.
       run rcps_get-value in parent-handle (
                                          input "p-output-type"
                                         ,input-output v-index-id
                                         ,output v-output-type /*p-value-character*/
                                         ,output v-value-date /*p-value-date*/
                                         ,output v-value-decimal /*p-value-decimal*/
                                         ,output v-value-integer /*p-value-integer*/
                                         ,output v-value-logical /*p-value-logical*/
                                         ) no-error .
       assign
       t-excel:screen-value in frame {&frame-name} =  string(lookup({&output-type-excel}, v-output-type) > 0)
       t-text:screen-value in frame {&frame-name} = string(lookup({&output-type-plain-text}, v-output-type) > 0)
       .

    end. /*IF v-profile-id = 69  THEN DO:*/
    run local-initialize in this-procedure.
  end.
  when 'set' then do:
    if v-profile-id = 70 then do:
      assign
      frame {&FRAME-NAME}
      t-text
      t-excel
      v-output-type = ","
      entry(1, v-output-type) = (if t-excel then {&output-type-excel} else '')
      entry(2, v-output-type) = (if t-text then {&output-type-plain-text} else '')
      v-output-type = trim(v-output-type, {&comma-char})
      .
      if not t-excel
      and not t-text then do:
        define variable glog as logical no-undo .
        message
        "Внимание!! Вы не выбрали ни вывод в текстовый файл, ни вывод в Excel!" skip
        "Продолжить?"
        view-as alert-box question buttons yes-no update glog.
        if not glog then return error.
      end.

      run rcps_set-value in parent-handle (
                                        input "p-output-type"
                                      ,input 0
                                      ,input v-output-type /*p-value-character*/
                                      ,input ?  /*p-value-date*/
                                      ,input 0.0 /*p-value-decimal*/
                                      ,input 0 /*p-value-integer*/
                                      ,input no /*p-value-logical*/
                                      ) no-error .
    end. /*IF v-profile-id = 70 THEN DO:*/
  end.
end case.
      */
   end method.
    
   
   
   

end class.