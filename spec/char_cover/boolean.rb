### Simple if
    if 1 || 2
#>          x
      "hello"
    else
#>X
      "never"
#>X
    end
#>  ---
    "after"

    dummy_method(1 || 2)
#>              -     x-
    dummy_method(1 && 2)


    dummy_method(1 && raise)
#>  xxxxxxxxxxxx-          -
