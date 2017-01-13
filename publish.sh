#!/bin/sh
#create publish dir
echo "-------------create publish dir-------------------"
if [ ! -d "../publish" ];
	then
		mkdir "../publish"
fi
CURTIME=`date "+%y-%m-%d-server_sample-release-0.00"`
CURTIME=${CURTIME}$@
PUBLISHROOT=../publish/${CURTIME}

rm -rf ${PUBLISHROOT}
mkdir ${PUBLISHROOT}

mkdir $PUBLISHROOT/patches

echo "---------------------cp src------------------------"
cp -rf ./* ${PUBLISHROOT}/

echo "-------------------complie src---------------------"
find ${PUBLISHROOT} -type f -name '*.lua' -print -exec skynet/3rd/lua/luac -o {} {} \;

echo "---------------------remove nuuse-----------------"
find ${PUBLISHROOT} -type f -name '*.c' -print -exec rm {} \;
find ${PUBLISHROOT} -type f -name '*.h' -print -exec rm {} \;
find ${PUBLISHROOT} -type f -name '*.o' -print -exec rm {} \;
find ${PUBLISHROOT} -type f -name '*.a' -print -exec rm {} \;
find ${PUBLISHROOT} -type f -name '*.txt' -print -exec rm {} \;
find ${PUBLISHROOT} -type f -name 'LICENSE' -print -exec rm {} \;
find ${PUBLISHROOT} -type f -name '*Makefile*' -print -exec rm {} \;
find ${PUBLISHROOT} -type f -name '*.md' -print -exec rm {} \;
find ${PUBLISHROOT} -type f -name '*.log' -print -exec rm {} \;

echo "------------------------tar package----------------"
tar -zcvf ${PUBLISHROOT}.tar.gz ${PUBLISHROOT}

echo "-------------------------delete temp file-----------"
rm -rf ${PUBLISHROOT}

#ehco
echo "****************************************************************************"
echo "publish on ${PUBLISHROOT}"
echo "you should remove ${PUBLISHROOT} date"
echo "you should cp config.example to config and change it,if not existed!"
echo "type kill <pid> to stop launch! or ./stop_all.sh"
echo "type ./start.sh to start launch!"
echo "****************************************************************************"

exit 1