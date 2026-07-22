block-level on error undo, throw.

/*------------------------------------------------------------------------
    File        : upd-gtin.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : SSlivenko
    Created     : Sun Apr 12 18:09:53 AST 2020
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
define variable vss-revision    as character no-undo init "$Revision: f866f7c13773, 3215, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2022/12/27 12:54:29 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: upd-gtin.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/upd-gtin.p $":U .
define variable vss-description as character no-undo init "Обновление gtin'а (изначально для табака)".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/getcntxa.i }
{ trg/new-bcod.i }
{ ref/send-ref.i }

define input parameter p-db-num as integer no-undo .
define input parameter p-b-code like ub.bar-code.b-code no-undo .
define input parameter p-gtin   like ub.prod-bc.b-str no-undo .
define input parameter p-send   as logical no-undo .

define variable parparentproc as widget-handle no-undo .
define variable v-cntxt-db-num        as integer   no-undo . /* текущая БД            */
define variable v-cntxt-userid        as character no-undo . /* текущий пользователь  */
define variable v-cntxt-level         as character no-undo . /* уровень контекста     */
define variable v-cntxt-host-code-obj as integer   no-undo . /* текущая фирма         */
define variable v-cntxt-obj-type      as character no-undo . /* тип текущего объекта  */
define variable v-cntxt-obj-code      as integer   no-undo . /* код текущего объекта  */
define variable v-cntxt-db-num-obj    as integer   no-undo . /* база текущего объекта */
define variable v-cntxt-is-admin      as logical   no-undo . /* база текущего объекта */

define variable v-b-str     as character  no-undo .
define variable v-rid-pbc   as recid      no-undo .
define variable v-err-mess  as character  no-undo .

define buffer buf_goods for ub.goods .
define buffer buf_bar-code for ub.bar-code .
define buffer buf_prod-bc for ub.prod-bc .

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

parparentproc = this-procedure:handle .

find first buf_bar-code no-lock where buf_bar-code.b-code = p-b-code  no-error.
if not available buf_bar-code 
then do:
   v-err-mess = substitute("Ошибка при сохранении GTIN &1 bar-code &5 &2&3&2&4"
                        , p-gtin
                        , {&new-line}
                        , error-status:get-message(1)
                        , return-value
                        , p-b-code ).
    undo, return error v-err-mess .
end.
find first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code no-error.
if not available buf_goods 
then do:
   v-err-mess = substitute("Ошибка при сохранении GTIN &1 gds-code &5 &2&3&2&4"
                        , p-gtin
                        , {&new-line}
                        , error-status:get-message(1)
                        , return-value
                        , buf_bar-code.gds-code ).
    undo, return error v-err-mess .
end.
   
v-b-str = p-gtin .
run trg/prod-bc2.p (
                     input  parparentproc
                    ,input yes /*p-silent*/
                    ,input ? /* dif-pdbc */
                    ,input ? /*pbc-veto*/
                    ,input (send-ref and p-send)
                    ,input {&gtin}
                    ,input ""
                    ,buffer buf_goods
                    ,input buf_bar-code.b-code
                    ,input no 
                    ,input-output v-b-str
                    ,output v-rid-pbc
                    ) no-error.
if error-status :error
or v-rid-pbc = ? then do:
  v-err-mess = substitute("Ошибка при сохранении GTIN &1&2&3&2&4"
                        , p-gtin
                        , {&new-line}
                        , error-status:get-message(1)
                        , return-value ).
    undo, return error v-err-mess .
end.
else do:
  find first buf_prod-bc no-lock
        where recid(buf_prod-bc) = v-rid-pbc.
  if  buf_prod-bc.bc-on
  and send-ref
  and p-send
  then do:
    run str/diallog.w
      (input parparentproc
      ,input this-procedure
      ,input 'str/s-prodbc.p':U
      ,input string(v-rid-pbc) + {&delim-par} + "U":U
      ,input yes /*p-auto-go*/
      ,input '':U
      ,input "Пересылка ДопБК на кассы"
      ) .
  end.
end.


procedure mainmenu_getcntxt :
  define output parameter v-cntxt-db-num        as integer   no-undo . /* текущая БД            */   
  define output parameter v-cntxt-userid        as character no-undo . /* текущий пользователь  */   
  define output parameter v-cntxt-level         as character no-undo . /* уровень контекста     */   
  define output parameter v-cntxt-host-code-obj as integer   no-undo . /* текущая фирма         */   
  define output parameter v-cntxt-obj-type      as character no-undo . /* тип текущего объекта  */   
  define output parameter v-cntxt-obj-code      as integer   no-undo . /* код текущего объекта  */   
  define output parameter v-cntxt-db-num-obj    as integer   no-undo . /* база текущего объекта */   
  define output parameter v-cntxt-is-admin      as logical   no-undo . /* база текущего объекта */  
  
  find first ub.clients no-lock where ub.clients.db-num   = p-db-num
                                  and ub.clients.obj-type = {&shop}
                                  and ub.clients.stts = 0 .
  
  v-cntxt-db-num = p-db-num .
  v-cntxt-userid = ? .
  v-cntxt-level = ? .
  v-cntxt-host-code-obj = ub.clients.host-code .
  v-cntxt-obj-type = ub.clients.obj-type .
  v-cntxt-obj-code = ub.clients.obj-code .
  v-cntxt-db-num-obj = ub.clients.db-num .
  v-cntxt-is-admin =  ? .
end procedure .

