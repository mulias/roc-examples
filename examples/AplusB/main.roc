app "example"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.3.1/97mY3sUwo433-pcnEQUlMhn-sWiIf_J9bPhcAFZoqY4.tar.br" }
    imports [
        pf.Stdout,
        pf.Task.{ await },
        pf.Arg,
    ]
    provides [main] to pf

TaskErrors : [InvalidArg, InvalidNumStr]

main =
    task =
        args <- readArgs |> await

        sum = args.a + args.b
        aStr = Num.toStr args.a
        bStr = Num.toStr args.b
        sumStr = Num.toStr sum

        Task.succeed "The sum of \(aStr) and \(bStr) is \(sumStr)"

    taskResult <- Task.attempt task

    when taskResult is
        Ok result -> Stdout.line result
        Err InvalidArg -> Stdout.line "Error: Please provide two integers between -1000 and 1000 as arguments."
        Err InvalidNumStr -> Stdout.line "Error: Invalid number format. Please provide two integers between -1000 and 1000."

## Reads two command-line arguments, attempts to parse them as `I32` numbers,
## and returns a task containing a record with two fields, `a` and `b`, holding
## the parsed `I32` values.
##
## If the arguments are missing, if there's an issue with parsing the arguments
## as `I32` numbers, or if the parsed numbers are outside the expected range
## (-1000 to 1000), the function will return a task that fails with an
## error `InvalidArg` or `InvalidNumStr`.
readArgs : Task.Task { a : I32, b : I32 } TaskErrors
readArgs =
    Arg.list
    |> Task.mapFail \_ -> InvalidArg
    |> await \args ->
        when args is
            [_, aArg, bArg, ..] ->
                when (Str.toI32 aArg, Str.toI32 bArg) is
                    (Ok a, Ok b) -> Task.succeed { a, b }
                    _ -> Task.fail InvalidNumStr

            _ ->
                Task.fail InvalidNumStr
