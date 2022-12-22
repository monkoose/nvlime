Data types
----------

Separate return type with arrow `->`.
`T V -> U` is a function of two arguments of types T and V which returns type U.

Built-in data types (string, integer, float, ...) are in lowercase. Custom ones
are capitalized (BufNr, WinID, ...).

- Arrays or lists are enclosed in square brackets (`[string]` - list of strings).
`[any]` - for lists of any type.
- Tuples (multiple value returns) are enclosed in parentheses (used only for
return types).
- Hash tables - `{any}` for any type, or specify types with `{key
value}`.
- Functions - `(fn [arg1-type arg2-type] return-type)`.

- `?` before the type T means that it could be T or nil (example: `?string` could
be string or nil).
- `|` between two or more types to combine them
(example: `string|integer` could be string or integer)

- **LineNr** - positive *integer* (line number of a buffer)
- **Row** - positive *integer* (row number of a screen)
- **Col** - positive *integer* (column number of a buffer or screen)
- **BufNr** - positive *integer* (buffer number)
- **BufName** - *string* (buffer name)
- **WinID** - positive *integer* (window id, starts from 1000)
- **FileType** *string* filetype of a buffer

Conventions
-----------

Number of `;` for comments are the same as in common lisp
- ;;;; - for top-level source file documentation
- ;;; - for function documentation
- ;; - nested comments inside some scope
- ; - for comments at the end of a line

`?` at the start of an argument represents optional arguments. `?` at the end
used for arguments or functions returning boolean value
(example: `buf-exists?` should answer question `Is buffer exists?`)

Exported function's docstring should follow fennel convention - string right after its definition.
Local function's docstring should be a comment above it's definition.
