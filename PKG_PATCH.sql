/*============================================================================================*/
create or replace PACKAGE PKG_PATCH IS
/*============================================================================================*/

/* --------------------------------------------------------------------------------------------

    History of changes
    yyyy.mm.dd | Version | Author         | Changes
    -----------+---------+----------------+-------------------------
    2017.01.06 |  1.0    | Ferenc Toth    | Created 

-------------------------------------------------------------------------------------------- */

    G_VERSION  NUMBER ( 10 );

    PROCEDURE INSTALL( I_VERSION IN NUMBER
                     , I_NAME    IN VARCHAR  
                     );

    PROCEDURE DONE   ( I_VERSION IN NUMBER DEFAULT G_VERSION );

END PKG_PATCH;


/*============================================================================================*/
create or replace PACKAGE BODY PKG_PATCH IS
/*============================================================================================*/

/* --------------------------------------------------------------------------------------------

    History of changes
    yyyy.mm.dd | Version | Author         | Changes
    -----------+---------+----------------+-------------------------
    2017.01.06 |  1.0    | Ferenc Toth    | Created 

-------------------------------------------------------------------------------------------- */

    -------------------------------------------------------------------------------------------------
    PROCEDURE INSTALL( I_VERSION IN NUMBER
                     , I_NAME    IN VARCHAR  
                     ) IS
    -------------------------------------------------------------------------------------------------
        PRAGMA AUTONOMOUS_TRANSACTION;
        V_LAST_SUCCESS  NUMBER;
        V_PATCH         PA_PATCHES%ROWTYPE;
    BEGIN

        G_VERSION := NULL;

        SELECT MAX( VERSION )
          INTO V_LAST_SUCCESS
          FROM PA_PATCHES
         WHERE SUCCESS = 1;

        IF V_LAST_SUCCESS IS NULL THEN
            V_LAST_SUCCESS := 0;
        END IF;

        BEGIN
            SELECT *
              INTO V_PATCH
              FROM PA_PATCHES
             WHERE VERSION = I_VERSION;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            NULL;
        END;


        IF I_VERSION = V_LAST_SUCCESS + 1 THEN

            IF V_PATCH.VERSION IS NULL THEN
                V_PATCH.VERSION         := I_VERSION;
                V_PATCH.NAME            := I_NAME;
                V_PATCH.DATE_OF_INSTALL := SYSDATE;
                V_PATCH.SUCCESS         := 0;        
                INSERT INTO PA_PATCHES VALUES V_PATCH;
            ELSE
                UPDATE PA_PATCHES SET DATE_OF_INSTALL = SYSDATE WHERE VERSION = I_VERSION;
            END IF;

            COMMIT;

            G_VERSION := I_VERSION;

        ELSIF I_VERSION > V_LAST_SUCCESS + 1 THEN

            RAISE_APPLICATION_ERROR( -20003, 'This version is not the subsequent. The given: '||I_VERSION||', The latest succes: '||V_LAST_SUCCESS||'. Check the process!' );

        ELSIF V_PATCH.VERSION IS NULL OR V_PATCH.NAME != I_NAME THEN

            RAISE_APPLICATION_ERROR( -20002, 'This version has already installed with a different name: '||I_VERSION||' - '||I_NAME||'. Previous name: '||V_PATCH.NAME||'. Check the process!' );  

        ELSE

            RAISE_APPLICATION_ERROR( -20001, 'This patch has already installed: '||I_VERSION||' - '||I_NAME||'. Run the next script!'  );

        END IF;

    END;

    -------------------------------------------------------------------------------------------------
    PROCEDURE DONE   ( I_VERSION IN NUMBER DEFAULT G_VERSION ) IS
    -------------------------------------------------------------------------------------------------
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN

        UPDATE PA_PATCHES SET SUCCESS = 1 WHERE VERSION = nvl( I_VERSION, G_VERSION);
        COMMIT;

    END;

END PKG_PATCH;