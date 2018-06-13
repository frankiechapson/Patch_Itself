declare
    -- APEX Execute Patch process
    V_BLOB          BLOB;
    V_FILE_NAME     varchar2(2000);
    V_FILE          utl_file.file_type;
    V_BUFFER        raw(32767);
    V_BUFFER_SIZE   binary_integer;
    V_AMOUNT        binary_integer;
    V_OFFSET        number(38) := 1;
    V_CHUNKSIZE     integer;
    V_NUMBER        number;
begin
    -- Get the uloaded file and write it into PATCHDIR Oracle Directory 
    for l_r in ( select * from APEX_APPLICATION_TEMP_FILES order by CREATED_ON desc ) 
    loop
        V_BLOB      := l_r.BLOB_CONTENT;
        V_FILE_NAME := l_r.FILENAME;
        V_CHUNKSIZE := dbms_lob.getchunksize( V_BLOB );
        if ( V_CHUNKSIZE < 32767 ) then
            V_BUFFER_SIZE := V_CHUNKSIZE;
        else
            V_BUFFER_SIZE := 32767;
        end if;
        V_AMOUNT := V_BUFFER_SIZE;
        dbms_lob.open( V_BLOB, dbms_lob.lob_readonly);
        V_FILE := utl_file.fopen( location => 'PATCHDIR', filename => V_FILE_NAME, open_mode => 'WB', max_linesize  => 32767 );
        while V_AMOUNT >= V_BUFFER_SIZE
        loop
            dbms_lob.read( lob_loc => V_BLOB, amount => V_AMOUNT, offset => V_OFFSET, buffer => V_BUFFER );
            V_OFFSET := V_OFFSET + V_AMOUNT;
            utl_file.put_raw ( file => V_FILE, buffer => V_BUFFER, autoflush => true );
            utl_file.fflush  ( file => V_FILE );
        end loop;
        utl_file.fflush( file => V_FILE );
        utl_file.fclose( V_FILE );
        dbms_lob.close ( V_BLOB );
        exit;
    end loop;  
    -- drop the previous job if it does exist
    begin
        DBMS_SCHEDULER.DROP_JOB(job_name => 'RUN_PATCH',  defer => false,  force => true);
    exception when others then
        null;
    end; 
    -- create a new job to run the shell script
    dbms_scheduler.create_job( job_name     => 'RUN_PATCH'
                             , program_name => 'EXE_PATCH'
                             , start_date   => systimestamp
                             , enabled      => FALSE
                             );
    -- set the patch file name as a parameter of the shell script
    dbms_scheduler.set_job_argument_value( job_name          => 'RUN_PATCH'
                                         , argument_position => 1
                                         , argument_value    => '/home/oracle/Patches/'||V_FILE_NAME
                                         );
    -- start it    
    dbms_scheduler.enable (name => 'RUN_PATCH');

    commit;

end;
