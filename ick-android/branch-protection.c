/* Ordinary C at the compiler qualification boundary. A non-tail call
 * exercises both PAC-return and BTI declarations in the output object. */
__attribute__((noinline)) int protected_callee(int value)
{
    return value + 1;
}
__attribute__((noinline)) int protected_caller(int value)
{
    return protected_callee(value) + 1;
}
