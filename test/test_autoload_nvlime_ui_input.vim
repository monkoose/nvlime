function! TestSaveHistory()
    call assert_false(exists('g:nvlime_input_history'))

    call nvlime#ui#input#SaveHistory('some text')
    call assert_equal(['some text'], g:nvlime_input_history)

    call nvlime#ui#input#SaveHistory('other text')
    call assert_equal(['some text', 'other text'], g:nvlime_input_history)

    call nvlime#ui#input#SaveHistory('some other text')
    call assert_equal(['some text', 'other text', 'some other text'], g:nvlime_input_history)

    unlet g:nvlime_input_history
endfunction

function! TestGetHistory()
    call assert_false(exists('g:nvlime_input_history'))
    call nvlime#ui#input#SaveHistory('some text')
    call nvlime#ui#input#SaveHistory('other text')
    call nvlime#ui#input#SaveHistory('some other text')

    call assert_equal([2, 'some other text'], nvlime#ui#input#GetHistory())
    call assert_equal([1, 'other text'], nvlime#ui#input#GetHistory('backward', 2))
    call assert_equal([0, 'some text'], nvlime#ui#input#GetHistory('backward', 1))
    call assert_equal([0, ''], nvlime#ui#input#GetHistory('backward', 0))

    call assert_equal([1, 'other text'], nvlime#ui#input#GetHistory('forward', 0))
    call assert_equal([2, 'some other text'], nvlime#ui#input#GetHistory('forward', 1))
    call assert_equal([3, ''], nvlime#ui#input#GetHistory('forward', 2))
    call assert_equal([3, ''], nvlime#ui#input#GetHistory('forward', 3))
    call assert_equal([3, ''], nvlime#ui#input#GetHistory('forward'))

    let g:nvlime_input_history = []
    call assert_equal([0, ''], nvlime#ui#input#GetHistory('backward'))
    call assert_equal([0, ''], nvlime#ui#input#GetHistory('backward', 0))
    call assert_equal([0, ''], nvlime#ui#input#GetHistory('backward', 1))
    call assert_equal([0, ''], nvlime#ui#input#GetHistory('forward'))
    call assert_equal([0, ''], nvlime#ui#input#GetHistory('forward', 0))
    call assert_equal([0, ''], nvlime#ui#input#GetHistory('forward', 1))

    unlet g:nvlime_input_history
    call assert_equal([0, ''], nvlime#ui#input#GetHistory('backward'))
    call assert_equal([0, ''], nvlime#ui#input#GetHistory('backward', 0))
    call assert_equal([0, ''], nvlime#ui#input#GetHistory('backward', 1))
    call assert_equal([0, ''], nvlime#ui#input#GetHistory('forward'))
    call assert_equal([0, ''], nvlime#ui#input#GetHistory('forward', 0))
    call assert_equal([0, ''], nvlime#ui#input#GetHistory('forward', 1))
endfunction

function! TestNextHistoryItem()
    call assert_false(exists('g:nvlime_input_history'))
    call nvlime#ui#input#SaveHistory('some text')
    call nvlime#ui#input#SaveHistory('other text')
    call nvlime#ui#input#SaveHistory('some other text')

    noswapfile tabedit nvlime_test_dummy_buffer
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal nobuflisted

    try
        call nvlime#ui#AppendString('original text')
        call assert_equal('original text', nvlime#ui#CurBufferContent())

        call nvlime#ui#input#NextHistoryItem('forward')
        call assert_equal('original text', nvlime#ui#CurBufferContent())

        call nvlime#ui#input#NextHistoryItem('backward')
        call assert_equal('some other text', nvlime#ui#CurBufferContent())

        call nvlime#ui#input#NextHistoryItem('backward')
        call assert_equal('other text', nvlime#ui#CurBufferContent())

        call nvlime#ui#input#NextHistoryItem('backward')
        call assert_equal('some text', nvlime#ui#CurBufferContent())

        call nvlime#ui#input#NextHistoryItem('backward')
        call assert_equal('some text', nvlime#ui#CurBufferContent())

        call nvlime#ui#input#NextHistoryItem('forward')
        call assert_equal('other text', nvlime#ui#CurBufferContent())

        call nvlime#ui#input#NextHistoryItem('forward')
        call assert_equal('some other text', nvlime#ui#CurBufferContent())

        call nvlime#ui#input#NextHistoryItem('forward')
        call assert_equal('original text', nvlime#ui#CurBufferContent())

        call nvlime#ui#input#NextHistoryItem('forward')
        call assert_equal('original text', nvlime#ui#CurBufferContent())
    finally
        bdelete!
        unlet g:nvlime_input_history
    endtry
endfunction

let v:errors = []
call TestSaveHistory()
call TestGetHistory()
call TestNextHistoryItem()
