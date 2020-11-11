::---------------------------------介绍 1.0.1----------------------------------
::支持一键更改JAVA路径
::支持一键设置外置登录
::支持自动重启，支持限制重启次数
::支持服务器开关日志
::初夏完成外置登录以及日志相关脚本
::--------------------------------初始化设置-------------------------------
@echo off
::关闭回显
set restart=0
::设置重启次数初始值，默认为1，请勿修改

color 80
::设置背景色为灰前景色为黑
set LOGS_FILE_NAME=serverlogs.txt
::设置服务器启动日志名字
set RESTART_WAIT_TIME=5
::设置重启等待时间，单位秒
set MAX_RESTART=1
::重启多少次后不再重启,设置成-1关闭重启，-2关闭重启限制
set SERVER_NAME=SERVER_NAME
::服务器名称，会在服务端的标题处显示
set MIN_RAM=128M
::最小内存，默认128M
set MAX_RAM=8192M
::最大内存，默认8192M
set SERVER_JAR_NAME=SERVER_JAR_NAME.jar
::设置服务端核心名称，默认路径为服务器根目录，需要写入文件后缀
set SERVER_PATH=
::服务器根目录，空为当前目录，无需加""
set JAVA_PATH=java
::set JAVA_PATH="%JAVA_HOME%/bin/java.exe"
::JAVA路径，路径请保留""
set SERVER_JAR_AFTER=
::服务端JAR后面的参数，Thermos建议加上--log-strip-color

::注意，在此次更改无效！请到JVM_STR中找到相应参数
::-XX:+AggressiveOpts //加快编译
::-XX:+UseCompressedOops 
::-XX:+UseCMSCompactAtFullCollection //在FULL GC的时候， 对年老代的压缩
::-XX:+UseFastAccessorMethods //原始类型的快速优化
::-XX:ParallelGCThreads=4 //并行收集器的线程数
::-XX:+UseConcMarkSweepGC //使用CMS内存收集
::-XX:CMSFullGCsBeforeCompaction=2 //多少次后进行内存压缩
::-XX:CMSInitiatingOccupancyFraction=70 //使用cms作为垃圾回收,使用70％后开始CMS收集
::-XX:-DisableExplicitGC //关闭System.gc()
::-XX:TargetSurvivorRatio=90
::-Dfile.encoding=UTF-8 //使用UTF-8编码
::-XX:+UseG1GC
::-XX:StringTableSize=1000003
::-XX:+UseFastAccessorMethods
::-XX:+OptimizeStringConcat
::-XX:MetaspaceSize=512m
::-XX:MaxMetaspaceSize=4096m
::-XX:+UseStringDeduplication
::-XX:hashCode=5
set JVM_STR=-Xss512K -XX:+AggressiveOpts -XX:+UseCompressedOops -XX:+UseCMSCompactAtFullCollection -XX:+UseFastAccessorMethods -XX:ParallelGCThreads=4 -XX:+UseConcMarkSweepGC -XX:CMSFullGCsBeforeCompaction=2 -XX:CMSInitiatingOccupancyFraction=70 -XX:-DisableExplicitGC  -XX:TargetSurvivorRatio=90 -Dfile.encoding=UTF-8 


::一下为外置登录相关
set isauth=0
::设置开启外置登录，0为关闭，1为开启
set auth_url=https://YOUR_URL/api/yggdrasil
::外置登录地址
set isautodownload=1
::是否开启自动下载authlib-injector，1开启，0关闭
set authlib_version=34
::authlib-injector的版本，最后两位数字
set authlib_jar=authlib-injector-1.1.%authlib_version%.jar
::authlib-injector核心名字，若开启自动下载不建议更改
set authlib_dir=.\libraries\moe\yushi\authlib-injector\artifact\%authlib_version%\
::authlib-injector核心存储的位置，若开启自动下载不建议更改
set authlib_url=https://authlib-injector.yushi.moe/artifact/%authlib_version%/authlib-injector-1.1.%authlib_version%.jar
::authlib-injector核心下载地址
::--------------------------------初始化设置-------------------------------




::-----------------------------------主体----------------------------------
cd /d %SERVER_PATH%
::切换目录至服务器根目录

echo [S]:%date% %time:~0,2%点%time:~3,2%分%time:~6,2%秒 bat run>>%LOGS_FILE_NAME%
::bat开启日志输出

if %isauth% == 1 (if %isautodownload% == 1 (if exist %authlib_dir% (goto s) else (echo 外置登录核心不存在！正在下载...)) else (goto s)) else (goto s)
::authlib-injector核心相关判断
md %authlib_dir%
::创建目录
powershell (new-object System.Net.WebClient).DownloadFile('%authlib_url%','%authlib_dir%\%authlib_jar%')
::下载authlib-injector
echo 下载完成！正在启动服务器
echo [D]:%date% %time:~0,2%点%time:~3,2%分%time:~6,2%秒 authlib-injector downloaded>>%LOGS_FILE_NAME%

:s
echo [S]:%date% %time:~0,2%点%time:~3,2%分%time:~6,2%秒 server start>>%LOGS_FILE_NAME%
::服务器开启日志输出

:start
::start节点
cls
::清除屏幕上内容
echo. 
echo 现在时间：%date% %time:~0,2%点%time:~3,2%分%time:~6,2%秒
echo -----------------------------------------------------------------
echo                         %SERVER_NAME%服务器    
echo                服务器目录：%SERVER_PATH%
echo           注意:关闭服务器前请在后台输入stop保存玩家数据
echo                      否则可能会出现回档情况
echo.
echo                      服务器正在启动中,请稍等……
echo.
echo -----------------------------------------------------------------
::启动时的一些显示


if %MAX_RESTART% == -1 (title %SERVER_NAME%服务器 最大内存%MAX_RAM%M) else (title %SERVER_NAME%服务器 最大内存%MAX_RAM%M 重启次数%restart%次)
::设置的服务端标题，调用上面的一些变量，可酌情修改

if %isauth% == 1 (goto authlib) else (goto noauthlib)
:authlib
%JAVA_PATH% -server -Xincgc -javaagent:%authlib_dir%\%authlib_jar%=%auth_url% -Xmx%MAX_RAM% -Xms%MIN_RAM% %JVM_STR% -jar %SERVER_JAR_NAME% %SERVER_JAR_AFTER%
goto isstop
::外置登录启动参数
:noauthlib
%JAVA_PATH% -server -Xincgc -Xmx%MAX_RAM% -Xms%MIN_RAM% %JVM_STR% -jar %SERVER_JAR_NAME% %SERVER_JAR_AFTER%
::正常启动参数

:isstop
echo ------------------------===服务端关闭===-------------------------
echo.
echo               %SERVER_NAME% --- 玩家数据保存完毕 已关服
echo.
echo -----------------------------------------------------------------


if %MAX_RESTART% == -1 (goto end) else (goto restart)
::判断是否开启重启

:restart
::restart标签
if %restart% == %MAX_RESTART% (goto end)
::判断是否达到重启最大数量
set/a restart=restart+1
::设置重启次数自加一，请勿修改
echo [R]:%date% %time:~0,2%点%time:~3,2%分%time:~6,2%秒 server restart %restart%/%MAX_RESTART%>>%LOGS_FILE_NAME%
::服务器重启日志输出
echo 服务器将于%RESTART_WAIT_TIME%秒后重启，请按Ctrl+C关闭
::显示提示信息
timeout /t %RESTART_WAIT_TIME% /NOBREAK
::等待RESTART_WAIT_TIME秒后重启
goto start
::跳转到开始标签

:end
::end标签
color 84
::设置背景色为灰前景色为红
echo [E]:%date% %time:~0,2%点%time:~3,2%分%time:~6,2%秒 server stop>>%LOGS_FILE_NAME%
::服务器关闭日志输出
if %MAX_RESTART% == -1 (echo 未开启自动重启，如果需要，请到bat中开启) else (echo 已经自动重启%MAX_RESTART%次，停止自动重启，按任意键关闭)
::显示提示信息
echo [E]:%date% %time:~0,2%点%time:~3,2%分%time:~6,2%秒 bat end>>%LOGS_FILE_NAME%
::bat停止日志输出
pause
::暂停bat
