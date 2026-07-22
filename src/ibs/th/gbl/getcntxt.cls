/*

$Revision: a5f04f494b3d, 1100, rls $
$Author: EShklyar $
$Date: Thu Dec 14 02:13:52 2017 +0300 $
$Workfile: getcntxt.cls $
$Archive: ibs/th/gbl/getcntxt.cls $



Автор: Шкляр Елена Львовна
Дата создания: 01/30/15
Author: Elena Shklyar
Creation date: 01/30/15

*/

using Progress.Lang.*.
block-level on error undo, throw.


class ibs.th.gbl.getcntxt: 

  define property ReturnMsg as character no-undo
    get.
    private set.

  define variable hndl-proc-getcntxt as handle.
 
  constructor public getcntxt ():
    
    run gbl\getcntxt.p persistent (output hndl-proc-getcntxt) no-error.
    
  end constructor.

  method public void MainMenuGetcntxt (  
  output v-cntxt-db-num        as integer, /* текущая БД            */
  output v-cntxt-userid        as character, /* текущий пользователь  */
  output v-cntxt-level         as character, /* уровень контекста     */
  output v-cntxt-host-code-obj as integer, /* текущая фирма         */
  output v-cntxt-obj-type      as character, /* тип текущего объекта  */
  output v-cntxt-obj-code      as integer, /* код текущего объекта  */
  output v-cntxt-db-num-obj    as integer, /* база текущего объекта */
  output v-cntxt-is-admin      as logical /* база текущего объекта */
  ):
    
    run mainmenu_getcntxt in hndl-proc-getcntxt (   
    output v-cntxt-db-num,
    output v-cntxt-userid,
    output v-cntxt-level,
    output v-cntxt-host-code-obj,
    output v-cntxt-obj-type,
    output v-cntxt-obj-code,
    output v-cntxt-db-num-obj,
    output v-cntxt-is-admin) no-error.
    
    if error-status:error
      then 
    do:
      
    end.
    
  end.
  
        
  destructor public getcntxt ():
    
    delete object hndl-proc-getcntxt no-error.
    
    if error-status:error
      then 
    do:
      
    end.
    
  end destructor.
  

end class.