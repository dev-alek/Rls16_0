block-level on error undo, throw.
for each esys-route :
 find first esys-pck-sent no-lock where esys-pck-sent.esys-id = esys-route.esys-id
                                    and esys-pck-sent.db-num = esys-route.db-num
                                    and esys-pck-sent.esps-pack-num = esys-route.esr-last-pack
                                    no-error.
 if not available esys-pck-sent then next.
 if esys-pck-sent.esps-rcvd = no then next.
 for each esys-route-dump where esys-route-dump.esrd-dump-ord = esys-route.esr-dump-ord:
   delete esys-route-dump no-error .
 end.
 delete esys-route.
end.
message "Готово" view-as alert-box.
