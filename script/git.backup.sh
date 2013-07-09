#! /bin/bash

# git リモートリポジトリよりもローカルリポジトリが古ければ
# pull してバックアップを取得する。
# オプション引数
# -f : フルバックアップ（変更のないリポジトリもバックアップする）

#### 定数定義
# ローカルリポジトリ置き場
LOCAL_GIT=${HOME}/git/
mkdir -p ${LOCAL_GIT}


# 引数解析
FULL=0
while getopts ":f" opts
do
	case $opts in
	f)
		FULL=1
		;;
	esac
done

# バックアップファイル名
BACKUP_FILE=${HOME}/backup/git.backup.`date +'%Y%m%d-%H%M'`.tgz
if test ${FULL} -eq 1
then
	BACKUP_FILE=${HOME}/backup/git.full-backup.`date +'%Y%m%d-%H%M'`.tgz
fi
mkdir -p ${BACKUP_FILE%/*}


BACKUP_REPOS=""

# リポジトリを1つずつ
for repo in `ls ${LOCAL_GIT}`
do
	cd ${LOCAL_GIT}${repo}
	# フルバックアップならとにかく pull
	if test ${FULL} -eq 1
	then
		git pull origin > /dev/null
		BACKUP_REPOS=${BACKUP_REPOS}" "${repo}
	else
		# リモートリポジトリのコミットIDを取得する
		RCID=`git ls-remote origin HEAD | cut -f 1`
		# そのIDがローカルにあるか？
		EXIST=`git log | grep ${RCID} | wc -l`
		if test ${EXIST} -eq 0
		then
			# なければ pull
			git pull origin > /dev/null
			BACKUP_REPOS=${BACKUP_REPOS}" "${repo}
		fi
	fi
done


# そしてバックアップ
if test -n "${BACKUP_REPOS}"
then
	cd ${LOCAL_GIT}
	tar cvfz ${BACKUP_FILE} ${BACKUP_REPOS} > /dev/null
fi


# 5日より古いものは削除
find ${BACKUP_FILE%/*} -mtime +5 -exec rm -f {} \;





