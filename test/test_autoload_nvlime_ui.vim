function! NewDummyBuffer()
    noswapfile tabedit nvlime_test_dummy_buffer
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal nobuflisted
endfunction

function! CleanupDummyBuffer()
    bunload!
endfunction


function! TestCurrentPackage()
    call NewDummyBuffer()
    try
        let ui = nvlime#ui#New()
        call assert_equal(['COMMON-LISP-USER', 'CL-USER'], ui.GetCurrentPackage())

        call append(line('$'), '(in-package :dummy-package-1)')
        call setpos('.', [0, line('$'), 1, 0])
        call assert_equal(['DUMMY-PACKAGE-1', 'DUMMY-PACKAGE-1'], ui.GetCurrentPackage())

        call ui.SetCurrentPackage(['DUMMY-PACKAGE-2', 'DUMMY-PACKAGE-2'])
        call assert_equal(['DUMMY-PACKAGE-2', 'DUMMY-PACKAGE-2'], ui.GetCurrentPackage())
    finally
        call CleanupDummyBuffer()
    endtry
endfunction

function! TestCurInPackage()
    call NewDummyBuffer()
    try
        call append(line('$'), '(in-package :dummy-package-1)')
        call assert_equal('DUMMY-PACKAGE-1', nvlime#ui#CurInPackage())

        normal! ggVG_d
        call append(line('$'), '(in-package :dummy-package-1')
        call assert_equal('', nvlime#ui#CurInPackage())

        normal! ggVG_d
        call append(line('$'), '(in-package :dummy-package-1 ()')
        call assert_equal('', nvlime#ui#CurInPackage())
    finally
        call CleanupDummyBuffer()
    endtry
endfunction

function! TestCurrentThread()
    let ui = nvlime#ui#New()
    call assert_equal(v:true, ui.GetCurrentThread())

    call ui.SetCurrentThread(1)
    call assert_equal(1, ui.GetCurrentThread())
endfunction

function! TestWithBuffer()
    function! s:DummyWithBufferAction()
        set filetype=nvlime_test_dummy_ft
        let b:nvlime_test_dummy_value = 2
    endfunction

    augroup NvlimeTestWithBuffer
        autocmd!
        autocmd FileType nvlime_test_dummy_ft let b:nvlime_test_dummy_au_value = 4
    augroup end

    let b:nvlime_test_dummy_value = 1
    let b:nvlime_test_dummy_au_value = 3
    let new_buf = bufnr('nvlime_test_with_buffer', v:true)
    call nvlime#ui#WithBuffer(new_buf, function('s:DummyWithBufferAction'))
    call assert_equal(1, b:nvlime_test_dummy_value)
    call assert_equal(2, getbufvar(new_buf, 'nvlime_test_dummy_value'))
    call assert_equal(3, b:nvlime_test_dummy_au_value)
    call assert_equal(4, getbufvar(new_buf, 'nvlime_test_dummy_au_value'))
endfunction

function! TestOpenBuffer()
    let buf = nvlime#ui#OpenBuffer(
                \ 'nvlime_test_open_buffer', v:true, 'botright')
    call assert_equal('nvlime_test_open_buffer', expand('%'))
    execute 'bunload!' buf

    let cur_buf_name = expand('%')
    let buf = nvlime#ui#OpenBuffer(
                \ 'nvlime_test_open_buffer_2', v:true, v:false)
    call assert_notequal('nvlime_test_open_buffer_2', expand('%'))
endfunction

function! TestCloseBuffer()
    let new_buf = bufnr('nvlime_test_close_buffer', v:true)
    let cur_win_id = win_getid()
    for i in range(5)
        execute 'tabedit #' . new_buf
    endfor
    call win_gotoid(cur_win_id)
    call nvlime#ui#CloseBuffer(new_buf)
    call assert_equal(cur_win_id, win_getid())
    call assert_equal([], win_findbuf(new_buf))
endfunction

function! TestCurBufferContent()
    call NewDummyBuffer()
    try
        call append(0, ['line 1', 'line 2'])
        call assert_equal("line 1\nline 2\n", nvlime#ui#CurBufferContent())
    finally
        call CleanupDummyBuffer()
    endtry
endfunction

function! TestCurChar()
    call NewDummyBuffer()
    try
        call append(line('$'), 'a')
        call setpos('.', [0, line('$'), 1, 0])
        call assert_equal('a', nvlime#ui#CurChar())

        call append(line('$'), '字')
        call setpos('.', [0, line('$'), 1, 0])
        call assert_equal('字', nvlime#ui#CurChar())
    finally
        call CleanupDummyBuffer()
    endtry
endfunction

function! TestCurAtom()
    call NewDummyBuffer()
    try
        call append(line('$'), 'dummy-atom-name')
        call setpos('.', [0, line('$'), 1, 0])
        call assert_equal('dummy-atom-name', nvlime#ui#CurAtom())

        call append(line('$'), 'dummy/atom/name another-name')
        call setpos('.', [0, line('$'), 1, 0])
        call assert_equal('dummy/atom/name', nvlime#ui#CurAtom())

        call append(line('$'), '*dummy-atom-name* another-name')
        call setpos('.', [0, line('$'), 1, 0])
        call assert_equal('*dummy-atom-name*', nvlime#ui#CurAtom())

        call append(line('$'), '+dummy-atom-name+ another-name')
        call setpos('.', [0, line('$'), 1, 0])
        call assert_equal('+dummy-atom-name+', nvlime#ui#CurAtom())

        call append(line('$'), 'yet-another-name dummy-package:dummy-atom-name another-name')
        call setpos('.', [0, line('$'), 18, 0])
        call assert_equal('dummy-package:dummy-atom-name', nvlime#ui#CurAtom())
    finally
        call CleanupDummyBuffer()
    endtry
endfunction

function! TestCurExpr()
    call NewDummyBuffer()
    try
        call append(line('$'), '(cons 1 2)')
        call setpos('.', [0, line('$'), 1, 0])
        let cur_line = line('.')
        call assert_equal(['(cons 1 2)', [cur_line, 1], [cur_line, 10]],
                    \ nvlime#ui#CurExpr(v:true))

        call append(line('$'), '(cons (cons 1 2) 3)')
        call setpos('.', [0, line('$'), 1, 0])
        let cur_line = line('.')
        call assert_equal(['(cons (cons 1 2) 3)', [cur_line, 1], [cur_line, 19]],
                    \ nvlime#ui#CurExpr(v:true))

        call append(line('$'), '(cons (cons 1 2) 3)')
        call setpos('.', [0, line('$'), 7, 0])
        let cur_line = line('.')
        call assert_equal(['(cons 1 2)', [cur_line, 7], [cur_line, 16]],
                    \ nvlime#ui#CurExpr(v:true))

        call append(line('$'), ['(cons', '1 2)'])
        call setpos('.', [0, line('$'), 1, 0])
        let cur_line = line('.')
        call assert_equal(["(cons\n1 2)", [cur_line - 1, 1], [cur_line, 4]],
                    \ nvlime#ui#CurExpr(v:true))
    finally
        call CleanupDummyBuffer()
    endtry
endfunction

function! TestCurTopExpr()
    call NewDummyBuffer()
    try
        call append(line('$'), '(cons 1 2)')
        call setpos('.', [0, line('$'), 1, 0])
        let cur_line = line('.')
        call assert_equal(['(cons 1 2)', [cur_line, 1], [cur_line, 10]],
                    \ nvlime#ui#CurTopExpr(v:true))

        call setpos('.', [0, line('$'), 2, 0])
        call assert_equal(['(cons 1 2)', [cur_line, 1], [cur_line, 10]],
                    \ nvlime#ui#CurTopExpr(v:true))

        call setpos('.', [0, line('$'), 10, 0])
        call assert_equal(['(cons 1 2)', [cur_line, 1], [cur_line, 10]],
                    \ nvlime#ui#CurTopExpr(v:true))

        call append(line('$'), ' (cons 1 2) ')
        call setpos('.', [0, line('$'), 12, 0])
        let cur_line = line('.')
        call assert_equal(['', [0, 0], [0, 0]],
                    \ nvlime#ui#CurTopExpr(v:true))

        call setpos('.', [0, line('$'), 1, 0])
        call assert_equal(['', [0, 0], [0, 0]],
                    \ nvlime#ui#CurTopExpr(v:true))

        call append(line('$'), '(list (cons 1 2) 3)')
        call setpos('.', [0, line('$'), 7, 0])
        let cur_line = line('.')
        call assert_equal(['(list (cons 1 2) 3)', [cur_line, 1], [cur_line, 19]],
                    \ nvlime#ui#CurTopExpr(v:true))

        call setpos('.', [0, line('$'), 8, 0])
        call assert_equal(['(list (cons 1 2) 3)', [cur_line, 1], [cur_line, 19]],
                    \ nvlime#ui#CurTopExpr(v:true))

        call setpos('.', [0, line('$'), 16, 0])
        call assert_equal(['(list (cons 1 2) 3)', [cur_line, 1], [cur_line, 19]],
                    \ nvlime#ui#CurTopExpr(v:true))

        call append(line('$'), '(cons (list (cons 1 2) 3) 4)')
        call setpos('.', [0, line('$'), 18, 0])
        let cur_line = line('.')
        call assert_equal(['(cons (list (cons 1 2) 3) 4)', [cur_line, 1], [cur_line, 28]],
                    \ nvlime#ui#CurTopExpr(v:true))

        " Enable syntax highlighting, and see if comments and strings are
        " correctly recognized.
        syntax on
        set filetype=lisp

        call append(line('$'), ['#| #(, |# (cons 1 2) #| ) |#'])
        call setpos('.', [0, line('$'), 12, 0])
        let cur_line = line('.')
        call assert_equal(['(cons 1 2)', [cur_line, 11], [cur_line, 20]],
                    \ nvlime#ui#CurTopExpr(v:true))

        call append(line('$'), [';; #(,', '(cons 1 2)', ';; )'])
        call setpos('.', [0, line('$') - 1, 2, 0])
        let cur_line = line('.')
        call assert_equal(['(cons 1 2)', [cur_line, 1], [cur_line, 10]],
                    \ nvlime#ui#CurTopExpr(v:true))

        call append(line('$'), ['"#(,"', '(cons 1 2)', '")"'])
        call setpos('.', [0, line('$') - 1, 2, 0])
        let cur_line = line('.')
        call assert_equal(['(cons 1 2)', [cur_line, 1], [cur_line, 10]],
                    \ nvlime#ui#CurTopExpr(v:true))

        call append(line('$'), ['"\\"', '(cons 1 2)'])
        call setpos('.', [0, line('$'), 2, 0])
        let cur_line = line('.')
        call assert_equal(['(cons 1 2)', [cur_line, 1], [cur_line, 10]],
                    \ nvlime#ui#CurTopExpr(v:true))

        call append(line('$'), ['#\"', '(cons 1 2)'])
        call setpos('.', [0, line('$'), 2, 0])
        let cur_line = line('.')
        call assert_equal(['(cons 1 2)', [cur_line, 1], [cur_line, 10]],
                    \ nvlime#ui#CurTopExpr(v:true))

        "call append(line('$'), ['#| #(, |# (cons 1 2) #| ) |#'])
        call setpos('.', [0, line('$') - 10, 12, 0])
        let cur_line = line('.')
        call assert_equal(['(cons 1 2)', [cur_line, 11], [cur_line, 20]],
                    \ nvlime#ui#CurTopExpr(v:true))

        "call append(line('$'), [';; #(,', '(cons 1 2)', ';; )'])
        call setpos('.', [0, line('$') - 8, 2, 0])
        let cur_line = line('.')
        call assert_equal(['(cons 1 2)', [cur_line, 1], [cur_line, 10]],
                    \ nvlime#ui#CurTopExpr(v:true))

        "call append(line('$'), ['"#(,"', '(cons 1 2)', '")"'])
        call setpos('.', [0, line('$') - 5, 2, 0])
        let cur_line = line('.')
        call assert_equal(['(cons 1 2)', [cur_line, 1], [cur_line, 10]],
                    \ nvlime#ui#CurTopExpr(v:true))

        "call append(line('$'), ['"\\"', '(cons 1 2)'])
        call setpos('.', [0, line('$') - 2, 2, 0])
        let cur_line = line('.')
        call assert_equal(['(cons 1 2)', [cur_line, 1], [cur_line, 10]],
                    \ nvlime#ui#CurTopExpr(v:true))

        "call append(line('$'), ['#\"', '(cons 1 2)'])
        call setpos('.', [0, line('$'), 2, 0])
        let cur_line = line('.')
        call assert_equal(['(cons 1 2)', [cur_line, 1], [cur_line, 10]],
                    \ nvlime#ui#CurTopExpr(v:true))
    finally
        call CleanupDummyBuffer()
    endtry
endfunction

function! TestCurOperator()
    call NewDummyBuffer()
    try
        call append(line('$'), ' (cons 1 2) ')
        call setpos('.', [0, line('$'), 1, 0])
        call assert_equal('', nvlime#ui#CurOperator())

        call setpos('.', [0, line('$'), 2, 0])
        call assert_equal('cons', nvlime#ui#CurOperator())

        call setpos('.', [0, line('$'), 3, 0])
        call assert_equal('cons', nvlime#ui#CurOperator())

        call setpos('.', [0, line('$'), 11, 0])
        call assert_equal('cons', nvlime#ui#CurOperator())

        call setpos('.', [0, line('$'), 12, 0])
        call assert_equal('', nvlime#ui#CurOperator())

        call append(line('$'), '(cons (list 1 2) 3)')
        call setpos('.', [0, line('$'), 6, 0])
        call assert_equal('cons', nvlime#ui#CurOperator())

        call append(line('$'), '(cons (list 1 2) 3)')
        call setpos('.', [0, line('$'), 7, 0])
        call assert_equal('list', nvlime#ui#CurOperator())

        call append(line('$'), '(cons (list 1 2) 3)')
        call setpos('.', [0, line('$'), 16, 0])
        call assert_equal('list', nvlime#ui#CurOperator())

        call append(line('$'), '(cons (list 1 2) 3)')
        call setpos('.', [0, line('$'), 17, 0])
        call assert_equal('cons', nvlime#ui#CurOperator())

        call append(line('$'), '(cons (list 1 2')
        call setpos('.', [0, line('$'), 1, 0])
        call assert_equal('cons', nvlime#ui#CurOperator())

        call setpos('.', [0, line('$'), 6, 0])
        call assert_equal('cons', nvlime#ui#CurOperator())

        call setpos('.', [0, line('$'), 7, 0])
        call assert_equal('list', nvlime#ui#CurOperator())

        call setpos('.', [0, line('$'), 15, 0])
        call assert_equal('list', nvlime#ui#CurOperator())

        call append(line('$'), '((aa bb) cc')
        call setpos('.', [0, line('$'), 11, 0])
        call assert_equal('', nvlime#ui#CurOperator())
    finally
        call CleanupDummyBuffer()
    endtry
endfunction

function! TestSurroundingOperator()
    call NewDummyBuffer()
    try
        call append(line('$'), '(cons (list 1 2) 3)')
        call setpos('.', [0, line('$'), 6, 0])
        call assert_equal('cons', nvlime#ui#SurroundingOperator())

        call setpos('.', [0, line('$'), 7, 0])
        call assert_equal('cons', nvlime#ui#SurroundingOperator())

        call setpos('.', [0, line('$'), 8, 0])
        call assert_equal('list', nvlime#ui#SurroundingOperator())

        call setpos('.', [0, line('$'), 16, 0])
        call assert_equal('list', nvlime#ui#SurroundingOperator())

        call setpos('.', [0, line('$'), 17, 0])
        call assert_equal('cons', nvlime#ui#SurroundingOperator())

        call append(line('$'), '((a b) (c d))')
        call setpos('.', [0, line('$'), 2, 0])
        call assert_equal('', nvlime#ui#SurroundingOperator())

        call setpos('.', [0, line('$'), 8, 0])
        call assert_equal('', nvlime#ui#SurroundingOperator())
    finally
        call CleanupDummyBuffer()
    endtry
endfunction

function! TestCurArgPosForIndent()
    call NewDummyBuffer()
    try
        call append(line('$'), '(aa bb cc dd)')
        call setpos('.', [0, line('$'), 1, 0])
        call assert_equal(-1, nvlime#ui#CurArgPos())

        call setpos('.', [0, line('$'), 2, 0])
        call assert_equal(0, nvlime#ui#CurArgPos())

        call setpos('.', [0, line('$'), 4, 0])
        call assert_equal(1, nvlime#ui#CurArgPos())

        call setpos('.', [0, line('$'), 5, 0])
        call assert_equal(1, nvlime#ui#CurArgPos())

        call setpos('.', [0, line('$'), 7, 0])
        call assert_equal(2, nvlime#ui#CurArgPos())

        call setpos('.', [0, line('$'), 8, 0])
        call assert_equal(2, nvlime#ui#CurArgPos())

        call setpos('.', [0, line('$'), 13, 0])
        call assert_equal(3, nvlime#ui#CurArgPos())

        call append(line('$'), '(aa bb cc dd )')
        call setpos('.', [0, line('$'), 14, 0])
        call assert_equal(4, nvlime#ui#CurArgPos())

        call append(line('$'), ['(aa bb', 'cc dd)'])
        call setpos('.', [0, line('$'), 1, 0])
        call assert_equal(2, nvlime#ui#CurArgPos())

        call append(line('$'), ['(aa bb', '  cc dd)'])
        call setpos('.', [0, line('$'), 1, 0])
        call assert_equal(2, nvlime#ui#CurArgPos())

        call append(line('$'), '(aa bb (cc dd) ee)')
        call setpos('.', [0, line('$'), 8, 0])
        call assert_equal(2, nvlime#ui#CurArgPos())

        call setpos('.', [0, line('$'), 9, 0])
        call assert_equal(0, nvlime#ui#CurArgPos())

        call setpos('.', [0, line('$'), 11, 0])
        call assert_equal(1, nvlime#ui#CurArgPos())

        call setpos('.', [0, line('$'), 12, 0])
        call assert_equal(1, nvlime#ui#CurArgPos())

        call setpos('.', [0, line('$'), 15, 0])
        call assert_equal(3, nvlime#ui#CurArgPos())

        call setpos('.', [0, line('$'), 16, 0])
        call assert_equal(3, nvlime#ui#CurArgPos())

        call append(line('$'), '((aa bb) (cc dd) ee)')
        call setpos('.', [0, line('$'), 2, 0])
        call assert_equal(0, nvlime#ui#CurArgPos())

        call setpos('.', [0, line('$'), 10, 0])
        call assert_equal(1, nvlime#ui#CurArgPos())

        call setpos('.', [0, line('$'), 18, 0])
        call assert_equal(2, nvlime#ui#CurArgPos())

        call append(line('$'), "(aa bb '(cc dd) ee)")
        call setpos('.', [0, line('$'), 9, 0])
        call assert_equal(2, nvlime#ui#CurArgPos())

        call append(line('$'), ["(aa", "  bb)"])
        call setpos('.', [0, line('$') - 1, 3, 0])
        call assert_equal(0, nvlime#ui#CurArgPos())
    finally
        call CleanupDummyBuffer()
    endtry
endfunction

function! TestAppendString()
    call NewDummyBuffer()
    try
        call assert_equal(0, nvlime#ui#AppendString('line1'))
        call assert_equal(1, nvlime#ui#AppendString(" line1 line1\n"))
        call assert_equal(1, nvlime#ui#AppendString("line2\nline3"))
        call assert_equal(3, nvlime#ui#AppendString("\nline5\nline6\nline7"))
        call assert_equal("line1 line1 line1\nline2\nline3\nline5\nline6\nline7",
                    \ nvlime#ui#CurBufferContent())

        call assert_equal(1, nvlime#ui#AppendString(" and\nline2.1\n", 2))
        call assert_equal("line1 line1 line1\nline2 and\nline2.1\nline3\nline5\nline6\nline7",
                    \ nvlime#ui#CurBufferContent())
        call assert_equal(0, nvlime#ui#AppendString("\nline2.2 and ", 3))
        call assert_equal("line1 line1 line1\nline2 and\nline2.1\nline2.2 and line3\nline5\nline6\nline7",
                    \ nvlime#ui#CurBufferContent())
        call assert_equal(1, nvlime#ui#AppendString("line0\n", 0))
        call assert_equal("line0\nline1 line1 line1\nline2 and\nline2.1\nline2.2 and line3\nline5\nline6\nline7",
                    \ nvlime#ui#CurBufferContent())

        call assert_equal(2, nvlime#ui#ReplaceContent("new line5\nnew line6\n", 6, 7))
        call assert_equal("line0\nline1 line1 line1\nline2 and\nline2.1\nline2.2 and line3\nnew line5\nnew line6\nline7",
                    \ nvlime#ui#CurBufferContent())

        call assert_equal(1, nvlime#ui#ReplaceContent("replaced\ncontent"))
        call assert_equal("replaced\ncontent", nvlime#ui#CurBufferContent())

        call assert_equal(1, nvlime#ui#ReplaceContent("some other\ntext"))
        call assert_equal("some other\ntext", nvlime#ui#CurBufferContent())
    finally
        call CleanupDummyBuffer()
    endtry
endfunction

function! TestMatchCoord()
    let coord = {
                \ 'begin': [1, 2],
                \ 'end': [1, 2],
                \ 'type': 'DUMMY',
                \ 'id': 1,
                \ }
    call assert_true(nvlime#ui#MatchCoord(coord, 1, 2))
    call assert_false(nvlime#ui#MatchCoord(coord, 1, 1))
    call assert_false(nvlime#ui#MatchCoord(coord, 1, 3))
    call assert_false(nvlime#ui#MatchCoord(coord, 2, 2))

    let coord = {
                \ 'begin': [1, 2],
                \ 'end': [1, 12],
                \ 'type': 'DUMMY',
                \ 'id': 1,
                \ }
    call assert_true(nvlime#ui#MatchCoord(coord, 1, 2))
    call assert_true(nvlime#ui#MatchCoord(coord, 1, 7))
    call assert_true(nvlime#ui#MatchCoord(coord, 1, 12))
    call assert_false(nvlime#ui#MatchCoord(coord, 1, 1))
    call assert_false(nvlime#ui#MatchCoord(coord, 1, 13))
    call assert_false(nvlime#ui#MatchCoord(coord, 2, 7))

    let coord = {
                \ 'begin': [1, 10],
                \ 'end': [2, 5],
                \ 'type': 'DUMMY',
                \ 'id': 1,
                \ }
    call assert_true(nvlime#ui#MatchCoord(coord, 1, 15))
    call assert_true(nvlime#ui#MatchCoord(coord, 2, 3))
    call assert_false(nvlime#ui#MatchCoord(coord, 1, 5))
    call assert_false(nvlime#ui#MatchCoord(coord, 2, 7))
endfunction

let v:errors = []
call TestCurrentPackage()
call TestCurInPackage()
call TestCurrentThread()
call TestWithBuffer()
" call TestOpenBuffer()
call TestCloseBuffer()
call TestCurBufferContent()
call TestCurChar()
call TestCurAtom()
call TestCurExpr()
call TestCurTopExpr()
call TestCurOperator()
call TestSurroundingOperator()
call TestCurArgPosForIndent()
call TestAppendString()
call TestMatchCoord()
