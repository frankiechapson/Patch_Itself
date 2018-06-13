BEGIN
    DBMS_SCHEDULER.create_program( program_name         => 'EXE_PATCH'
                                 , program_action       => 'home/oracle/Patches/RunPatch.sh'
                                 , program_type         => 'EXECUTABLE'
                                 , number_of_arguments  => 1
                                 , comments             => NULL
                                 , enabled              => TRUE
                                 );
        
    DBMS_SCHEDULER.define_program_argument( program_name        => 'EXE_PATCH'
                                          , argument_name       => 'PARAM1'
                                          , argument_position   => 1
                                          , argument_type       => 'VARCHAR2'
                                          , out_argument        => FALSE
                                          );
    commit;
END;