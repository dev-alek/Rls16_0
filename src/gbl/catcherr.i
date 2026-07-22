define variable v-err-msg as character no-undo .  
catch exAppErrors as class Progress.Lang.AppError :
    v-err-msg = exAppErrors:ReturnValue .
    if v-err-msg > "" then . else do :
       v-err-msg = exAppErrors:GetMessage(1) .
      if v-err-msg > "" 
      then v-err-msg = "AppError в модуле {&FILE-NAME}" + v-err-msg. 
      else v-err-msg = "AppError в модуле {&FILE-NAME}" .
    end .
  end catch .
  catch exProErrors as class Progress.Lang.ProError :
    v-err-msg = exProErrors:GetMessage(1) . 
    if v-err-msg > "" 
    then v-err-msg = "ProError в модуле {&FILE-NAME}" + v-err-msg. 
    else v-err-msg = "ProError в модуле {&FILE-NAME}" .
    return error v-err-msg.
  end catch .
  catch exAnyErrors as class Progress.Lang.Error:
    v-err-msg = "Unexpected error в модуле {&FILE-NAME} " + exAnyErrors:GetMessage(1).
    return error v-err-msg.
end catch .
