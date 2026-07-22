 
 /*------------------------------------------------------------------------
    File        : impgoods
    Purpose     : 
    Syntax      : 
    Description : Класс импорта данных по товарам из 1С
    Author(s)   : SSlivenko
    Created     : Fri Oct 20 17:21:36 AST 2017
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
block-level on error undo, throw.

class ibs.th.bge.1crn.import.impgoods implements ibs.th.bge.1crn.import.iimpsubject:
     
  { cmp/str-glbl.i class }
  { cmp/str-glbl.i }
  { str/lib-trn.i  class }
  
  define property Msg as character no-undo
    get. 
    set.
  
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
      
      define buffer buf_goods for ub.goods.
      define buffer buf_bar-code for ub.bar-code.
      define buffer buf_prod-bc for ub.prod-bc.
      
      define variable objGoods as class goods no-undo .
      
      define variable v-stts            as integer      no-undo .
      define variable v-is-petrol       as logical      no-undo.
      define variable v-is-pieces       as logical      no-undo.
      
      objGoods = cast (subjectObj, goods).
      
      find first buf_goods no-lock where buf_goods.gds-code = integer(objGoods:code_) no-error.
      if available buf_goods and buf_goods.stts = integer({&deleted-status-int})
      then do :
          v-stts = integer({&current-status-int}) .
          run ref/goods02.p (
                    input recid(buf_goods)
                    ,input yes /*p-silent*/
                    ,input-output v-stts) no-error. 
          /* BTS-1143: если восстанавливается топливный товар, то включаем все короткие доп бар коды */
          { str/is-petrl.i
            buf_goods.artic
            buf_goods.prod-type
            buf_goods.prod-code
            v-is-petrol
            v-is-pieces
          }
          if v-is-petrol = yes 
          then do:
            Msg = includeShortBarCode(buf_goods.gds-code).
            if Msg <> "" then
              return false. 
          end.
                   
      end.
      
      run ref/imp-goods-1C-RN.p (input objGoods) no-error .
      /* чтобы перехватить throw надо отдельно проверить return-value */
      if error-status:error
      then do :
          Msg = return-value + " " + error-status:get-message (1) .
          return false.
      end.                          
          
      if objGoods:del-f = 1
      or objGoods:del-l = 1
      then do :
          find first buf_goods no-lock where buf_goods.gds-code = integer(objGoods:code_) no-error.
          if not available buf_goods
          then do :
              Msg = ("Нет товара с кодом " + objGoods:code_ + " . Удаление невозможно") .
              return false .
          end.
          for each buf_bar-code no-lock where buf_bar-code.gds-code = integer(objGoods:code_),
            each buf_prod-bc exclusive-lock where buf_prod-bc.b-code = buf_bar-code.b-code :
               buf_prod-bc.bc-on = false .  
          end.
          v-stts = integer({&deleted-status-int}) .
          run ref/goods02.p (
                    input recid(buf_goods)
                    ,input yes /*p-silent*/
                    ,input-output v-stts) no-error. 
      end.
      return true .
      catch exAppErrors as class Progress.Lang.AppError :
         Msg = exAppErrors:ReturnValue .
         if Msg > "" then . else do :
            Msg = exAppErrors:GetMessage(1) .
            if Msg > "" then . else Msg = "AppError в модуле {&FILE-NAME}" .
         end .
         return false.
      end catch .
      catch exProErrors as class Progress.Lang.ProError :
         msg = exProErrors:GetMessage(1) . 
         if msg > "" then . else msg = "ProError в модуле {&FILE-NAME}" .
         return false.
      end catch .
      catch exAnyErrors as class Progress.Lang.Error:
         msg = "Unexpected error в модуле {&FILE-NAME} " + exAnyErrors:GetMessage(1).
         return false.
      end catch .
       
      
      
  end method.    

  method private character includeShortBarCode(
    input iGdsCode like ub.goods.gds-code  
  ):
    
    define variable vError     as  character no-undo.     
    define buffer buf_bar-code for ub.bar-code .
    define buffer buf_prod-bc  for ub.prod-bc .

    for each buf_bar-code where
             buf_bar-code.gds-code = iGdsCode
        no-lock,
        each buf_prod-bc where
             buf_prod-bc.b-code = buf_bar-code.b-code
        exclusive-lock:
       if length(buf_prod-bc.b-str) <= 2 then
       do:
          buf_prod-bc.bc-on = true.
          validate buf_prod-bc no-error.
          if error-status:error then do:
            vError = substitute("&1;&2", vError, error-status:get-message(1)).  
          end.
       end.     
    end.
    return left-trim(vError, ";").
  end method.
    
end class.