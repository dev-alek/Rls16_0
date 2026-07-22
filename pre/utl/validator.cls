using utl.*.
block-level on error undo, throw.
class utl.validator:
   method public void Validate(iPwd as class tech-prol-pwd ):
      if iPwd:f-date = ? then
         undo, throw new ValidateError("Не заполнена дата").
      if iPwd:f-time = ? then
         undo, throw new ValidateError("Не заполнено время").
      if not
(iPwd:f-host <> ? and iPwd:f-host <> "")
  then
         undo, throw new ValidateError("Не заполнен хост").
      if not
(iPwd:f-user <> ? and iPwd:f-user <> "")
  then
         undo, throw new ValidateError("Не заполнен пользователь").
      if not
(iPwd:shop-surr <> ? and iPwd:shop-surr <> "")
  then
         undo, throw new ValidateError("Не указан магазин").
      if not
(iPwd:cash-desk-surr <> ? and iPwd:cash-desk-surr <> "")
  then
         undo, throw new ValidateError("Не указана касса").
      if not can-do("И,Р",iPwd:f-pwd-type) then
         undo, throw new ValidateError(substitute("Неправильный тип пароля - []",iPwd:f-pwd-type)).
      return.
   end method.
end class.
