#pragma once
#import <FunSDK/JObject.h>

#define JK_AlarmFunction "AlarmFunction" 
class AlarmFunction : public JObject
{
public:
	JBoolObj		AlarmConfig;
	JBoolObj		BlindDetect;
	JBoolObj		Consumer433Alarm;
	JBoolObj		ConsumerRemote;
	JBoolObj		IPCAlarm;
	JBoolObj		LossDetect;
	JBoolObj		MotionDetect;
	JBoolObj		NetAbort;
	JBoolObj		NetAbortExtend;
	JBoolObj		NetAlarm;
	JBoolObj		NetIpConflict;
	JBoolObj		SensorAlarmCenter;
	JBoolObj		SerialAlarm;
	JBoolObj		StorageFailure;
	JBoolObj		StorageLowSpace;
	JBoolObj		StorageNotExist;
	JBoolObj		VideoAnalyze;
    JBoolObj        PEAInHumanPed;          // 是否支持人形检测
    JBoolObj        IntellAlertAlarm;       // 智是否支持联动警戒
    JBoolObj        ManuIntellAlertAlarm;   // 是否支持手动警戒报警
    JBoolObj        MotionHumanDection;     // 支持移动追踪和人形报警同时开启
    JBoolObj        NewVideoAnalyze;
    JBoolObj        PIRAlarm;
public:
    AlarmFunction(JObject *pParent = NULL, const char *szName = JK_AlarmFunction):
    JObject(pParent,szName),
	AlarmConfig(this, "AlarmConfig"),
	BlindDetect(this, "BlindDetect"),
	Consumer433Alarm(this, "Consumer433Alarm"),
	ConsumerRemote(this, "ConsumerRemote"),
	IPCAlarm(this, "IPCAlarm"),
	LossDetect(this, "LossDetect"),
	MotionDetect(this, "MotionDetect"),
	NetAbort(this, "NetAbort"),
	NetAbortExtend(this, "NetAbortExtend"),
	NetAlarm(this, "NetAlarm"),
	NetIpConflict(this, "NetIpConflict"),
	SensorAlarmCenter(this, "SensorAlarmCenter"),
	SerialAlarm(this, "SerialAlarm"),
	StorageFailure(this, "StorageFailure"),
	StorageLowSpace(this, "StorageLowSpace"),
	StorageNotExist(this, "StorageNotExist"),
	VideoAnalyze(this, "VideoAnalyze"),
    PEAInHumanPed(this, "PEAInHumanPed"),
    IntellAlertAlarm(this, "IntellAlertAlarm"),
    ManuIntellAlertAlarm(this, "ManuIntellAlertAlarm"),
    MotionHumanDection(this, "MotionHumanDection"),
    NewVideoAnalyze(this, "NewVideoAnalyze"),
    PIRAlarm(this, "PIRAlarm"){
	};

    ~AlarmFunction(void){};
};
