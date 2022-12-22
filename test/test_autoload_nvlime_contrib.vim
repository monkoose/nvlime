function! TestCallInitializers()
    function! s:DummyContribInitializer(conn)
        let b:nvlime_test_dummy_contrib_initializer_called = v:true
    endfunction

    function! s:DummyUserContribInitializer(conn)
        let b:nvlime_test_dummy_user_contrib_initializer_called = v:true
    endfunction

    function! s:DummyInitializersCB(conn)
        let b:nvlime_test_dummy_initializers_cb_called = v:true
    endfunction

    let conn = nvlime#New()
    let conn['cb_data'] = {}
    " XXX: autoload nvlime/contrib.vim
    call nvlime#contrib#CallInitializers(conn)

    let conn['cb_data'] = {'contribs': ["DUMMY-CONTRIB"]}
    let g:nvlime_contrib_initializers['DUMMY-CONTRIB'] =
                \ function('s:DummyContribInitializer')
    let g:nvlime_user_contrib_initializers =
                \ {'DUMMY-CONTRIB': function('s:DummyUserContribInitializer')}
    let b:nvlime_test_dummy_contrib_initializer_called = v:false
    let b:nvlime_test_dummy_user_contrib_initializer_called = v:false
    let b:nvlime_test_dummy_initializers_cb_called = v:false
    call nvlime#contrib#CallInitializers(conn, v:null, function('s:DummyInitializersCB'))
    call assert_true(b:nvlime_test_dummy_contrib_initializer_called)
    call assert_false(b:nvlime_test_dummy_user_contrib_initializer_called)
    call assert_true(b:nvlime_test_dummy_initializers_cb_called)

    call remove(g:nvlime_contrib_initializers, 'DUMMY-CONTRIB')
    let b:nvlime_test_dummy_contrib_initializer_called = v:false
    let b:nvlime_test_dummy_user_contrib_initializer_called = v:false
    call nvlime#contrib#CallInitializers(conn, v:null, function('s:DummyInitializersCB'))
    call assert_false(b:nvlime_test_dummy_contrib_initializer_called)
    call assert_true(b:nvlime_test_dummy_user_contrib_initializer_called)

    unlet b:nvlime_test_dummy_contrib_initializer_called
    unlet b:nvlime_test_dummy_user_contrib_initializer_called
    unlet b:nvlime_test_dummy_initializers_cb_called
endfunction

let v:errors = []
call TestCallInitializers()
