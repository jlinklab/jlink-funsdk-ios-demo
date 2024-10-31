/**
 * @file Fun_BluetoothClient.h
 * @brief 蓝牙协议客户端相关接口
 * @author baixu
 * @date 2024/05/21
 */

#ifndef __FUN_BLUETOOTH_CLIENT_H_
#define __FUN_BLUETOOTH_CLIENT_H_

#include "XTypes.h"

/**
 * @brief 蓝牙搜索
 * @return 异步消息: 1.开启搜索 ID:8936;Param1:>=0成功 2.搜索结果返回 ID:8938;Param1:>=0;Str:搜索结果 3.搜索停止 ID:8937;Param1:>=0
 */
XSDK_API int BluetoothClient_Search(int hUser, int nSeq);

/**
 * @brief 取消蓝牙搜索
 * @return 异步消息: 1.取消搜索 ID:8939;Param1:>=0成功
 */
XSDK_API int BluetoothClient_CancelSearch(int hUser, int nSeq);

/**
 * @brief 蓝牙连接
 * @param hUser 结果接收用户
 * @param uuid  蓝牙标识, android：mac地址, ios: uuid
 * @return >0: 蓝牙对象句柄 <0: 失败
 * 回调消息: id: EMSG_BLUETOOTH_ON_CONNECT, param1: 连接结果, str: 蓝牙标识
 */
XSDK_API int BluetoothClient_Connect(int hUser, const char* uuid);

/**
 * @brief 蓝牙断开连接
 * @param bluetooth_obj 蓝牙对象句柄, 上面连接的返回值
 * @param uuid  蓝牙标识, android：mac地址, ios: uuid
 * @return 无意义
 * 回调消息: id: EMSG_BLUETOOTH_ON_DISCONNECT, str: 蓝牙标识
 */
XSDK_API int BluetoothClient_Disconnect(int bluetooth_obj);

/**
 * @brief 异步发送蓝牙数据
 * @param bluetooth_obj 蓝牙对象句柄, 上面连接的返回值
 * @param data 数据指针
 * @param len 数据长度
 * @return 
 * 数据结果回调消息
 * id: EMSG_BLUETOOTH_ON_RECVDATA
 * param1: 数据长度
 * object: 数据
 * str: 蓝牙标识
*/
XSDK_API int BluetoothClient_SendData(int bluetooth_obj, const char* data, int len);

#endif //__FUN_BLUETOOTH_CLIENT_H_
