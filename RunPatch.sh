#!/bin/bash
ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
export ORACLE_HOME
ORACLE_SID=XE
export ORACLE_SID
NLS_LANG=`$ORACLE_HOME/bin/nls_lang.sh`
export NLS_LANG
PATH=$ORACLE_HOME/bin:$PATH
export PATH
echo exit | /u01/app/oracle/product/11.2.0/xe/bin/sqlplus STOCKMGR/xxxxxxxx @$1
rm $1
