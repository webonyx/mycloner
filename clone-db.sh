#!/usr/bin/env bash

DB_HOST=${DB_HOST:-127.0.0.1}
DB_USER=${DB_USER:-root}
DB_PASS=${DB_PASS:-}
DB_NAME=${DB_NAME:-test}

CLONE_DB_HOST=${CLONE_DB_HOST:-$DB_HOST}
CLONE_DB_USER=${CLONE_DB_USER:-$DB_USER}
CLONE_DB_PASS=${CLONE_DB_PASS:-$DB_PASS}
CLONE_DB_NAME=${CLONE_DB_NAME:-"${DB_NAME}-copy"}

TEMPDIR="/tmp"
OUTDIR=${OUTDIR:-"${TEMPDIR}/outdir"}
SKIP_OUTDIR=${SKIP_OUTDIR:-"false"}

if [ ! -d "${OUTDIR}" ]; then
  mkdir -p $OUTDIR
fi

{ \
    echo [client]
    echo host=${DB_HOST}
    echo user=${DB_USER}
    echo password="${DB_PASS}"
    echo [mydumper]
} > "${TEMPDIR}/.mydumper.cnf"

{ \
    echo [client]
    echo host=${CLONE_DB_HOST}
    echo user=${CLONE_DB_USER}
    echo password="${CLONE_DB_PASS}"
    echo [myloader]
} > "${TEMPDIR}/.myloader.cnf"


mydumper --defaults-file ${TEMPDIR}/.mydumper.cnf -o $OUTDIR --routines --triggers --events --skip-definer --database "${DB_NAME}" --verbose 3 $EXTRA_MYDUMPER_ARGS

myloader --defaults-file ${TEMPDIR}/.myloader.cnf -d $OUTDIR --database "${CLONE_DB_NAME}" --verbose 3 $EXTRA_MYLOADER_ARGS

if [ "false" == "${SKIP_OUTDIR}" ]; then
  rm -rf $OUTDIR
fi

rm -f "${TEMPDIR}/.mydumper.cnf"
rm -f "${TEMPDIR}/.myloader.cnf"
