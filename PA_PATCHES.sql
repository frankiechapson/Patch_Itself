Prompt *************************************
Prompt   PA_PATCHES
Prompt *************************************
/*-------------------------------------------
    PA_PATCHES 
    This table administrates the installed patches. 

    History of changes
    yyyy.mm.dd | Version | Author         | Changes
    -----------+---------+----------------+-------------------------
    2017.01.06 |  1.0    | Ferenc Toth    | Created 
-------------------------------------------*/
CREATE TABLE PA_PATCHES (
    VERSION                         NUMBER   (   10 )   CONSTRAINT PA_PATCHES_NN1 NOT NULL,
    NAME                            VARCHAR2 (  500 )   CONSTRAINT PA_PATCHES_NN2 NOT NULL,
    DATE_OF_INSTALL                 DATE                DEFAULT SYSDATE CONSTRAINT PA_PATCHES_NN3 NOT NULL,
    SUCCESS                         NUMBER   (  1,0 )   DEFAULT 0       CONSTRAINT PA_PATCHES_NN4 NOT NULL
  );
ALTER TABLE PA_PATCHES ADD CONSTRAINT PA_PATCHES_PK  PRIMARY KEY ( VERSION );
ALTER TABLE PA_PATCHES ADD CONSTRAINT PA_PATCHES_CH1 CHECK ( SUCCESS IN ( 0, 1 ) );

INSERT INTO PA_PATCHES ( VERSION, NAME, DATE_OF_INSTALL, SUCCESS ) VALUES ( 1, 'PATCHES', sysdate, 1 );
COMMIT;

