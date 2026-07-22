using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.impgoods implements ibs.th.bge.1crn.import.iimpsubject:
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
      if available buf_goods and buf_goods.stts = integer('1':U)
      then do :
          v-stts = integer('0':U) .
          run ref/goods02.p (
                    input recid(buf_goods)
                    ,input yes
                    ,input-output v-stts) no-error.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in ibs.th.gbl.gbl-hndllib:g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output v-is-petrol
  , output v-is-pieces
  ) .
          if v-is-petrol = yes
          then do:
            Msg = includeShortBarCode(buf_goods.gds-code).
            if Msg <> "" then
              return false.
          end.
      end.
      run ref/imp-goods-1C-RN.p (input objGoods) no-error .
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
          v-stts = integer('1':U) .
          run ref/goods02.p (
                    input recid(buf_goods)
                    ,input yes
                    ,input-output v-stts) no-error.
      end.
      return true .
      catch exAppErrors as class Progress.Lang.AppError :
         Msg = exAppErrors:ReturnValue .
         if Msg > "" then . else do :
            Msg = exAppErrors:GetMessage(1) .
            if Msg > "" then . else Msg = "AppError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ibs\th\bge\1crn\import\impgoods.cls" .
         end .
         return false.
      end catch .
      catch exProErrors as class Progress.Lang.ProError :
         msg = exProErrors:GetMessage(1) .
         if msg > "" then . else msg = "ProError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ibs\th\bge\1crn\import\impgoods.cls" .
         return false.
      end catch .
      catch exAnyErrors as class Progress.Lang.Error:
         msg = "Unexpected error в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ibs\th\bge\1crn\import\impgoods.cls " + exAnyErrors:GetMessage(1).
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
